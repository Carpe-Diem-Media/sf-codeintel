#!/usr/bin/env python3
"""Drive the built escript using only the standard library and an approved root."""

import base64
import contextlib
from datetime import datetime, timedelta
import errno
import hashlib
import json
import os
from pathlib import Path
import resource
import select
import signal
import stat
import subprocess
import sys
import threading
import time
import unittest
import uuid


PROJECT = Path(__file__).resolve().parents[1]
FIXTURES = PROJECT / "test" / "fixtures" / "lexical"
ESCRIPT = PROJECT / "_build" / "sf-codeintel"
SLOTS = ["caller.ex", "duplicate.ex", "renamed.ex", "sample.ex", "unsupported.ex"]
GRANT = "0d2db704-dc15-4c01-a7ee-03d1bea6f399"
GRANT_EXPIRY_NS = 1_795_820_400_000_000_000
LOCAL_ROOT = Path("/home/jcschoeman96/.sfci-19/fixtures")
LOCAL_IDENTITY = (66306, 104642611)
AS_LIMIT = 512 * 1024 * 1024
TIMEOUT = 8
MAX_FRAME = 16_384
MAX_RESPONSE = 32_768
TOOLS = {"discover", "definition", "references", "read_source", "check_source"}
KEY = {"module": "Demo.Sample", "function": "echo", "arity": 1}
MISSING_KEY = {**KEY, "function": "absent"}
ABSENT = object()


def boottime_ns():
    return time.clock_gettime_ns(time.CLOCK_BOOTTIME)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def bounded_address_space():
    resource.setrlimit(resource.RLIMIT_AS, (AS_LIMIT, AS_LIMIT))


def acl_kinds(path):
    for kind in ("access", "default"):
        try:
            os.getxattr(path, f"system.posix_acl_{kind}", follow_symlinks=False)
        except OSError as error:
            if error.errno != errno.ENODATA:
                raise
        else:
            yield kind


def verify_no_acl(path):
    if next(acl_kinds(path), None) is not None:
        raise RuntimeError("fixture custody requires an ACL-free path")


def verify_root(root, expected, *, hosted):
    if not root.is_absolute() or root.resolve() != root:
        raise RuntimeError("fixture root must be absolute and canonical")
    info = root.lstat()
    if (
        not stat.S_ISDIR(info.st_mode)
        or stat.S_IMODE(info.st_mode) != 0o700
        or info.st_uid != os.getuid()
        or (info.st_dev, info.st_ino) != expected
    ):
        raise RuntimeError("fixture root does not match the approved identity")
    verify_no_acl(root)
    for parent in root.parents:
        info = parent.lstat()
        if (
            not stat.S_ISDIR(info.st_mode)
            or info.st_uid not in {0, os.getuid()}
            or info.st_mode & 0o022
        ):
            raise RuntimeError("unsafe fixture ancestor")
        if hosted:
            # The group mode bits include the access ACL mask. Default ACLs
            # affect new children, which must pass their own strict ACL check.
            kinds = ", ".join(acl_kinds(parent))
            if kinds:
                print(
                    f"Hosted ancestor {parent} has {kinds} ACL. "
                    f"Verified uid={info.st_uid}, mode={stat.S_IMODE(info.st_mode):04o}."
                )
        else:
            verify_no_acl(parent)


class FixtureRoot:
    """The launcher owns this initially empty root and writes between calls."""

    def __init__(self):
        self.root = Path(os.environ["SFCI_FIXTURE_ROOT"])
        self.identity = tuple(map(int, os.environ["SFCI_FIXTURE_DEV_INO"].split(":")))
        self.scratch = Path(os.environ["SFCI_TEST_SCRATCH"])
        if (
            self.scratch == self.root
            or self.scratch in self.root.parents
            or self.root in self.scratch.parents
        ):
            raise RuntimeError("scratch must be separate from the fixture root")
        self.hosted = os.environ.get("GITHUB_ACTIONS") == "true"
        if self.hosted:
            run_dir = self.root.parent
            if (
                run_dir.parent != Path.home()
                or not run_dir.name.startswith(".sfci-19-ci.")
                or self.root.name != "fixtures"
                or self.scratch != run_dir / "scratch"
            ):
                raise RuntimeError("wrong hosted fixture scope")
        elif (self.root, self.identity) != (LOCAL_ROOT, LOCAL_IDENTITY):
            raise RuntimeError("wrong local fixture scope")
        scratch_info = self.scratch.lstat()
        self.scratch_identity = (scratch_info.st_dev, scratch_info.st_ino)
        self.approved()
        verify_root(self.scratch, self.scratch_identity, hosted=self.hosted)
        if list(self.root.iterdir()) or list(self.scratch.iterdir()):
            raise RuntimeError("fixture root and scratch must start empty")
        self.owned = set()

    def approved(self):
        verify_root(self.root, self.identity, hosted=self.hosted)
        if time.time_ns() >= GRANT_EXPIRY_NS:
            raise RuntimeError("execution grant expired")

    def path(self, slot):
        if slot not in SLOTS:
            raise ValueError("outside fixture slot")
        return self.root / slot

    def create(self, slot, namespace_operation):
        path = self.path(slot)
        self.approved()
        namespace_operation(path)
        self.owned.add(path)

    def write(self, slot, data):
        path = self.path(slot)
        if path in self.owned:
            self.approved()
            if not stat.S_ISREG(path.lstat().st_mode) or path.lstat().st_nlink != 1:
                raise RuntimeError("fixture replacement requires an exclusive regular file")
            path.write_bytes(data)
        else:
            self.create(slot, lambda target: self.write_new(target, data))

    @staticmethod
    def write_new(path, data):
        with path.open("xb") as output:
            output.write(data)

    def rename(self, old, new):
        self.approved()
        source = self.path(old)
        target = self.path(new)
        if source not in self.owned or target.exists() or target.is_symlink():
            raise RuntimeError("fixture rename would replace an existing path")
        source.rename(target)
        self.owned.remove(source)
        self.owned.add(target)

    def remove(self, slot):
        self.approved()
        self.unlink(self.path(slot))

    def unlink(self, path):
        if path not in self.owned:
            raise RuntimeError("refusing to remove a path the driver did not create")
        path.unlink()
        self.owned.remove(path)

    def close(self):
        verify_root(self.root, self.identity, hosted=self.hosted)
        verify_root(self.scratch, self.scratch_identity, hosted=self.hosted)
        for path in sorted(self.owned):
            self.unlink(path)
        if list(self.root.iterdir()) or list(self.scratch.iterdir()):
            raise RuntimeError("unexpected data remains after fixture cleanup")


class Client:
    def __init__(self, fixtures, *, mode="mcp", root=None, binding=True, lifetime_ms=45_000,
                 alter_binding=None):
        fixtures.approved()
        approved = fixtures.root
        if root is None:
            root = approved
        now_ns = boottime_ns()
        remaining_ns = GRANT_EXPIRY_NS - time.time_ns()
        if remaining_ns <= 0:
            raise RuntimeError("execution grant expired before launch")
        self.started = now_ns // 1_000_000
        grant_deadline = (now_ns + remaining_ns) // 1_000_000
        self.deadline = min(self.started + lifetime_ms, grant_deadline)
        if self.deadline <= self.started:
            raise RuntimeError("no time remains in the execution grant")

        environment = {
            "PATH": os.environ["PATH"],
            "LC_ALL": "C.UTF-8",
            "ERL_FLAGS": "+S 2:2 +SDcpu 1:1 +SDio 1 +A 1 +MIscs 64",
            "ERL_CRASH_DUMP_SECONDS": "0",
        }
        if binding:
            launch = {
                "root": str(root),
                "device": fixtures.identity[0],
                "inode": fixtures.identity[1],
                "uid": os.getuid(),
                "binding_id": uuid.uuid4().hex,
                "grant_id": GRANT,
                "launch_monotonic_ms": self.started,
                "deadline_monotonic_ms": self.deadline,
                "grant_deadline_monotonic_ms": grant_deadline,
            }
            if alter_binding:
                launch.update(alter_binding)
            environment["SFCI_LAUNCH_BINDING"] = json.dumps(launch)

        self.buffer = b""
        self.next_id = 0
        self.frames = 0
        self.process = subprocess.Popen(
            [str(ESCRIPT), "--root", str(root), mode],
            cwd=PROJECT,
            env=environment,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            start_new_session=True,
            preexec_fn=bounded_address_space,
        )
        self.stop = threading.Event()
        self.disposition = None
        self.watch = threading.Thread(target=self.enforce_deadline, daemon=True)
        self.watch.start()

    def enforce_deadline(self):
        while not self.stop.is_set():
            remaining = self.deadline / 1000 - boottime_ns() / 1_000_000_000
            if remaining <= 0:
                self.terminate("expired")
                return
            self.stop.wait(min(0.05, remaining))

    def terminate(self, reason):
        if self.process.poll() is None:
            self.disposition = reason
            self.process.kill()

    def send_raw(self, data):
        self.frames += 1
        if self.frames > 100 or boottime_ns() // 1_000_000 >= self.deadline:
            self.terminate("launcher_limit")
            raise RuntimeError("launcher frame or time ceiling reached")
        pipe = self.process.stdin.fileno()
        os.set_blocking(pipe, False)
        time_limit = time.monotonic() + TIMEOUT
        while data:
            _, writable, _ = select.select([], [pipe], [], max(0, time_limit - time.monotonic()))
            if not writable:
                raise AssertionError("timed out writing a client frame")
            try:
                data = data[os.write(pipe, data):]
            except BlockingIOError:
                continue

    def send(self, message):
        self.send_raw(json.dumps(message, ensure_ascii=False).encode() + b"\n")

    def receive(self):
        time_limit = time.monotonic() + TIMEOUT
        while b"\n" not in self.buffer:
            readable, _, _ = select.select(
                [self.process.stdout], [], [], max(0, time_limit - time.monotonic())
            )
            if not readable:
                raise AssertionError("timed out waiting for a server frame")
            data = os.read(self.process.stdout.fileno(), 8192)
            if not data:
                raise AssertionError("service closed before the expected response")
            self.buffer += data
            if len(self.buffer) > MAX_RESPONSE:
                raise AssertionError("server exceeded the response byte ceiling")
        line, self.buffer = self.buffer.split(b"\n", 1)
        return json.loads(line)

    def request(self, method, params=ABSENT, request_id=ABSENT):
        self.next_id += 1
        if request_id is ABSENT:
            request_id = self.next_id
        message = {"jsonrpc": "2.0", "id": request_id, "method": method}
        if params is not ABSENT:
            message["params"] = params
        self.send(message)
        response = self.receive()
        if response.get("id") != request_id or response.get("jsonrpc") != "2.0":
            raise AssertionError("unexpected JSON-RPC response identity")
        return response

    def initialize(self, version="2025-06-18"):
        return self.request("initialize", {
            "protocolVersion": version,
            "capabilities": {},
            "clientInfo": {"name": "sfci-protocol-test", "version": "1"},
        })["result"]

    def ready(self):
        self.send({"jsonrpc": "2.0", "method": "notifications/initialized"})

    def call(self, tool, args):
        reply = self.request("tools/call", {"name": tool, "arguments": args})["result"]
        content = reply["content"]
        data = reply["structuredContent"]
        if len(content) != 1 or content[0]["type"] != "text" or json.loads(content[0]["text"]) != data:
            raise AssertionError("tool representations disagree")
        return data

    def no_response(self):
        readable, _, _ = select.select([self.process.stdout], [], [], 0.08)
        if self.buffer or readable:
            raise AssertionError("unexpected stdout during notification or stalled input")

    def finish(self, *, close_input=True):
        if close_input:
            self.process.stdin.close()
        status = self.process.wait(timeout=TIMEOUT)
        stdout = self.buffer + self.process.stdout.read()
        stderr = self.process.stderr.read()
        if Path(f"/proc/{self.process.pid}").exists():
            raise AssertionError("child PID remains after wait")
        return status, stdout, stderr

    def close(self):
        try:
            self.terminate("cleanup")
            self.process.wait(timeout=TIMEOUT)
        finally:
            self.stop.set()
            self.watch.join(timeout=1)
            for pipe in (self.process.stdin, self.process.stdout, self.process.stderr):
                pipe.close()


class ProtocolTest(unittest.TestCase):
    def setUp(self):
        self.fixtures = FixtureRoot()
        self.addCleanup(self.fixtures.close)
        self.sample = (FIXTURES / "sample.ex").read_bytes()
        self.caller = b"# caf\xc3\xa9\r\n" + (FIXTURES / "caller.ex").read_bytes().replace(b"\n", b"\r\n")
        self.fixtures.write("sample.ex", self.sample)
        self.fixtures.write("caller.ex", self.caller)

    @contextlib.contextmanager
    def client(self, *, ready=False, **kwargs):
        client = Client(self.fixtures, **kwargs)
        try:
            if ready:
                client.initialize()
                client.ready()
            yield client
        finally:
            client.close()

    def assert_clean_eof(self, client):
        self.assertEqual(client.finish(), (0, b"", b""))

    def assert_error(self, response, code):
        self.assertEqual(response["error"]["code"], code)

    def test_initialize_first_with_stdin_open_and_normal_lifecycle(self):
        with self.client() as client:
            self.assertEqual(client.initialize(), {
                "protocolVersion": "2025-06-18",
                "capabilities": {"tools": {"listChanged": False}},
                "serverInfo": {"name": "sf-codeintel", "version": "0.1.0"},
            })
            self.assertEqual(resource.prlimit(client.process.pid, resource.RLIMIT_AS),
                             (AS_LIMIT, AS_LIMIT))
            self.assertEqual(client.request("ping", request_id="é")["result"], {})
            self.assert_error(client.request("tools/list"), -32600)
            self.assert_error(client.request("tools/call", {"name": "discover"}), -32600)
            self.assert_error(client.request("initialize"), -32600)
            client.send({"jsonrpc": "2.0", "method": "notifications/initialized", "params": []})
            client.no_response()
            self.assert_error(client.request("tools/list"), -32600)
            client.ready()
            client.no_response()
            tools = client.request("tools/list")["result"]["tools"]
            self.assertEqual({tool["name"] for tool in tools}, TOOLS)
            self.assertEqual(len(tools), len(TOOLS))
            self.assertTrue(all(tool["inputSchema"]["additionalProperties"] is False for tool in tools))
            self.assert_error(client.request("tools/call", {"name": "other"}), -32602)
            self.assert_error(client.request("missing"), -32601)
            self.assert_clean_eof(client)

    def test_pre_initialize_ping_and_fallback_version(self):
        with self.client() as client:
            self.assertEqual(client.request("ping")["result"], {})
            self.assert_error(client.request("initialize", {
                "protocolVersion": "older", "capabilities": {"roots": {"listChanged": 1}},
                "clientInfo": {"name": "test", "version": "1"},
            }), -32602)
            self.assertEqual(client.initialize("1900-01-01")["protocolVersion"], "2025-06-18")
            self.assert_clean_eof(client)

    def test_framing_and_request_limits(self):
        with self.client() as client:
            for frame in (
                b"{\n", b"{\"x\":\"\xff\"}\n", b"{}{}\n", b'{"x":1,"x":2}\n',
                b'{"x":' + (b"[" * 16) + b"0" + (b"]" * 16) + b"}\n",
                b'{"x":12345678901234567}\n',
            ):
                client.send_raw(frame)
                self.assert_error(client.receive(), -32700)

            for message in (
                [], {"jsonrpc": "2.0", "method": "ping", "id": None},
                {"jsonrpc": "2.0", "method": "ping", "id": "é" * 33},
            ):
                client.send(message)
                self.assert_error(client.receive(), -32600)

            ping = b'{"jsonrpc":"2.0","id":900,"method":"ping"}'
            client.send_raw(ping + b" " * (MAX_FRAME - len(ping) - 1) + b"\r\n")
            self.assertEqual(client.receive(), {"jsonrpc": "2.0", "id": 900, "result": {}})
            client.send_raw(b" " * (MAX_FRAME + 1))
            code, output, stderr = client.finish(close_input=False)
            self.assertEqual((code, output), (1, b""))
            self.assertEqual(stderr, b"frame_too_large\n")

        with self.client() as client:
            client.send_raw(b'{')
            self.assertEqual(client.finish(), (1, b"", b"unfinished_frame\n"))

    def test_expiry_and_revocation_reap_stalled_processes(self):
        with self.client(lifetime_ms=3_000) as client:
            client.initialize()
            client.no_response()
            self.assertEqual(client.finish(close_input=False), (-signal.SIGKILL, b"", b""))
            self.assertEqual(client.disposition, "expired")

        with self.client() as client:
            client.initialize()
            client.terminate("revoked")
            self.assertEqual(client.finish(close_input=False), (-signal.SIGKILL, b"", b""))
            self.assertEqual(client.disposition, "revoked")

    def test_server_closes_after_the_hundredth_frame(self):
        with self.client() as client:
            for _ in range(100):
                self.assertEqual(client.request("ping")["result"], {})
            self.assertEqual(client.finish(close_input=False), (0, b"", b""))

    def test_doctor_and_launch_denials(self):
        with self.client(mode="doctor") as client:
            code, output, stderr = client.finish()
            self.assertEqual((code, stderr), (0, b""))
            self.assertEqual(output.count(b"\n"), 1)
            self.assertEqual(json.loads(output), {
                "schema_version": 1, "profile_version": "synthetic_lexical_v1",
                "status": "ok", "coverage": "complete_for_profile", "diagnostics": [],
            })
        for kwargs in (
            {"binding": False}, {"alter_binding": {"inode": 0}},
            {"alter_binding": {"deadline_monotonic_ms": 0}},
            {"alter_binding": {"root": "/"}},
        ):
            with self.client(mode="doctor", **kwargs) as client:
                self.assertEqual(client.finish(), (2, b"", b"launch_denied\n"))
        with self.client(mode="invalid") as client:
            self.assertEqual(client.finish(), (2, b"", b"invalid_launch_arguments\n"))

        self.fixtures.write("sample.ex", b" " * (MAX_FRAME + 1))
        with self.client(mode="doctor") as client:
            status, output, stderr = client.finish()
            self.assertEqual((status, stderr), (1, b""))
            self.assertEqual(json.loads(output)["status"], "limit_exceeded")

    def test_exact_discovery_definitions_candidates_and_bytes(self):
        with self.client(ready=True) as client:
            discovery = client.call("discover", {})
            self.assertEqual(discovery["status"], "ok")
            self.assertEqual(discovery["coverage"], "complete_for_profile")
            expected = [
                ("caller.ex", "Demo.Caller", None, None),
                ("caller.ex", "Demo.Caller", "run", 0),
                ("sample.ex", "Demo.Sample", None, None),
                ("sample.ex", "Demo.Sample", "echo", 0),
                ("sample.ex", "Demo.Sample", "echo", 1),
                ("sample.ex", "Demo.Sample", "count", 0),
            ]
            got = [(i["path"], i["module"], i.get("function"), i.get("arity"))
                   for i in discovery["items"]]
            self.assertEqual(got, expected)
            for item in discovery["items"]:
                raw = self.sample if item["path"] == "sample.ex" else self.caller
                spelling = item.get("function", item["module"]).encode()
                self.assertEqual(raw[item["start_byte"]:item["end_byte"]], spelling)
                self.assertEqual(item["sha256"], sha256(raw))
            for arity in (0, 1):
                definition = client.call("definition", {**KEY, "arity": arity})
                self.assertEqual(definition["uniqueness"], "unique_in_profile")
                self.assertEqual(len(definition["items"]), 1)
                self.assertEqual(definition["items"][0]["arity"], arity)
            reference = client.call("references", KEY)
            item, = reference["items"]
            self.assertEqual(item["kind"], "lexical_candidate")
            self.assertEqual(item["sha256"], sha256(self.caller))
            self.assertEqual(item["start_byte"], self.caller.index(b"Demo.Sample.echo"))
            self.assertEqual(self.caller[item["start_byte"]:item["end_byte"]], b"Demo.Sample.echo")
            self.assertEqual(client.call("definition", MISSING_KEY)["status"], "unresolved")
            self.assertEqual(client.call("references", MISSING_KEY)["status"], "unresolved")
            self.assertEqual(client.call("discover", {"root": "/"})["status"], "invalid_input")

            excerpt = client.call("read_source", {"path": "sample.ex", "start_byte": 2, "end_byte": 53})
            self.assert_fresh(excerpt, "ok", "matched_at_check")
            self.assertEqual(base64.b64decode(excerpt["items"][0]["base64"]), self.sample[2:53])
            self.assertEqual(excerpt["items"][0]["sha256"], sha256(self.sample))
            self.assert_clean_eof(client)

    def test_partial_coverage_preserves_positive_evidence_and_supported_bytes(self):
        sentinel = self.fixtures.scratch / "sentinel"
        target = json.dumps(str(sentinel))
        inert = f'defmodule Demo.Inert do\n  File.write!({target}, "unsafe")\nend\n'.encode()
        self.fixtures.write("unsupported.ex", inert)
        with self.client(ready=True) as client:
            missing = client.call("definition", MISSING_KEY)
            self.assertEqual((missing["status"], missing["coverage"]), ("unsupported", "partial"))
            self.assertEqual(missing["diagnostics"], [
                {"code": "unsupported_source", "path": "unsupported.ex"},
            ])
            self.assertEqual(client.call("definition", KEY)["uniqueness"], "unknown")
            self.assertEqual(client.call("references", KEY)["status"], "ok")
            self.assertEqual(client.call("references", MISSING_KEY)["status"], "unsupported")
            self.fixtures.write("duplicate.ex", self.sample)
            duplicates = client.call("definition", KEY)
            self.assertEqual(duplicates["status"], "ambiguous")
            self.assertEqual([i["path"] for i in duplicates["items"]], ["duplicate.ex", "sample.ex"])
            source = client.call("read_source", {
                "path": "unsupported.ex", "start_byte": 0, "end_byte": len(inert),
            })
            self.assertEqual(base64.b64decode(source["items"][0]["base64"]), inert)
            self.assertFalse(sentinel.exists())
            self.assert_clean_eof(client)

    def assert_fresh(self, response, status, state, guarded_path=None):
        fresh = response["freshness"]
        self.assertEqual((response["status"], fresh["state"]), (status, state))
        self.assertEqual(fresh["checked_slots"], SLOTS)
        if guarded_path:
            self.assertEqual(fresh["comparison_slots"], [guarded_path])
            self.assertEqual(fresh["method"], "double_capture_slot_sha256_and_expected_digest")
        else:
            self.assertEqual(fresh["comparison_slots"], SLOTS)
            self.assertEqual(fresh["method"], "double_capture_slot_sha256")
        self.assertEqual(response["manifest_sha256"], fresh["first_manifest_sha256"])
        self.assertEqual(fresh["first_manifest_sha256"], fresh["second_manifest_sha256"])
        self.assertEqual(fresh["checked_at"], response["checked_at"])

    def test_freshness_across_edit_rename_delete_in_one_session(self):
        check = {"path": "sample.ex", "expected_sha256": sha256(self.sample)}
        read = {"path": "sample.ex", "start_byte": 0, "end_byte": 3}
        with self.client(ready=True) as client:
            first = client.call("check_source", check)
            self.assert_fresh(first, "ok", "matched_at_check", "sample.ex")
            self.assertEqual(first["items"], [])
            guarded = client.call("read_source", {**read, **check})
            self.assert_fresh(guarded, "ok", "matched_at_check", "sample.ex")
            self.assertEqual(base64.b64decode(guarded["items"][0]["base64"]), self.sample[:3])

            edited = self.sample.replace(b"do: 7", b"do: 8")
            self.assertEqual(len(edited), len(self.sample))
            self.assertNotEqual(edited, self.sample)
            self.fixtures.write("sample.ex", edited)
            changed = client.call("read_source", {**read, **check})
            self.assert_fresh(changed, "changed_since_check", "changed_since_check", "sample.ex")
            self.assertEqual(changed["items"], [])
            self.assertNotEqual(first["manifest_sha256"], changed["manifest_sha256"])

            self.fixtures.rename("sample.ex", "renamed.ex")
            missing = client.call("read_source", read)
            self.assert_fresh(missing, "unresolved", "matched_at_check")
            self.assertEqual(missing["items"], [])
            self.assertNotEqual(changed["manifest_sha256"], missing["manifest_sha256"])
            old_slot = client.call("check_source", {**check, "expected_sha256": sha256(edited)})
            self.assert_fresh(old_slot, "changed_since_check", "changed_since_check", "sample.ex")
            self.assertEqual(old_slot["items"], [])
            new_slot = client.call("check_source", {"path": "renamed.ex", "expected_sha256": sha256(edited)})
            self.assert_fresh(new_slot, "ok", "matched_at_check", "renamed.ex")

            self.fixtures.remove("renamed.ex")
            deleted = client.call("read_source", {**read, "path": "renamed.ex", "expected_sha256": sha256(edited)})
            self.assert_fresh(deleted, "changed_since_check", "changed_since_check", "renamed.ex")
            self.assertEqual(deleted["items"], [])
            self.assertNotEqual(new_slot["manifest_sha256"], deleted["manifest_sha256"])
            self.assert_clean_eof(client)

    def test_search_text_and_guarded_read(self):
        needle = '"café"'
        needle_bytes = needle.encode()
        search_args = {"name": "search_text", "arguments": {"query": needle}}

        def tool_result(response, *, is_error=False):
            self.assertEqual(set(response), {"jsonrpc", "id", "result"}, response)
            result = response["result"]
            data = result["structuredContent"]
            self.assertEqual(set(result), {"structuredContent", "content", "isError"})
            self.assertIs(result["isError"], is_error)
            (block,) = result["content"]
            self.assertEqual(set(block), {"type", "text"})
            self.assertEqual(block["type"], "text")
            self.assertEqual(json.loads(block["text"]), data)
            return data

        def common(status, coverage="complete_for_profile", items=(), diagnostics=()):
            return {
                "schema_version": 1, "status": status, "coverage": coverage,
                "truncated": False, "items": list(items), "diagnostics": list(diagnostics),
            }

        def assert_observation(data, expected, sample, *, guarded=False, changed=False):
            manifest = bytearray(b"sf-codeintel-manifest-v1\0")
            captured = {"caller.ex": self.caller, "sample.ex": sample}
            for slot in SLOTS:
                path = slot.encode()
                manifest.extend(len(path).to_bytes(2, "big") + path)
                if slot in captured:
                    raw = captured[slot]
                    manifest.extend(b"\x01" + len(raw).to_bytes(4, "big") + sha256(raw).encode())
                else:
                    manifest.extend(b"\x00")
            digest = sha256(manifest)
            checked_at = data["checked_at"]
            self.assertTrue(checked_at.endswith("Z"))
            self.assertEqual(datetime.fromisoformat(checked_at.replace("Z", "+00:00")).utcoffset(),
                             timedelta(0))
            self.assertRegex(data["binding_id"], r"^[0-9a-f]{32}$")
            self.assertEqual(data, {
                **expected,
                "binding_id": data["binding_id"],
                "backend_version": "local_source_v1",
                "profile_version": "synthetic_lexical_v1" if guarded else "synthetic_text_search_v1",
                "checked_at": checked_at,
                "manifest_sha256": digest,
                "freshness": {
                    "state": "changed_since_check" if changed else "matched_at_check",
                    "checked_at": checked_at,
                    "method": ("double_capture_slot_sha256_and_expected_digest" if guarded
                               else "double_capture_slot_sha256"),
                    "comparison_slots": ["sample.ex"] if guarded else SLOTS,
                    "checked_slots": SLOTS,
                    "first_manifest_sha256": digest,
                    "second_manifest_sha256": digest,
                },
            })

        def assert_search(response, sample, start):
            data = tool_result(response)
            item = {
                "kind": "text_match", "path": "sample.ex", "sha256": sha256(sample),
                "start_byte": start, "end_byte": start + len(needle_bytes),
            }
            assert_observation(data, common("ok", items=[item]), sample)
            return data["items"][0]

        with self.client(ready=True) as client:
            pid = client.process.pid
            limits = resource.prlimit(pid, resource.RLIMIT_AS)
            names = [
                comm.read_text().strip()
                for comm in Path(f"/proc/{pid}/task").glob("*/comm")
            ]
            schedulers = sorted(name for name in names if name.startswith("erts_sched_")
                                and name.removeprefix("erts_sched_").isdecimal())
            self.assertEqual(limits, (AS_LIMIT, AS_LIMIT))
            self.assertEqual(schedulers, ["erts_sched_1", "erts_sched_2"], names)
            print(f"child pid={pid} RLIMIT_AS={limits} normal schedulers={schedulers}",
                  file=sys.stderr, flush=True)

            item = assert_search(client.request("tools/call", search_args), self.sample,
                                 self.sample.index(needle_bytes))

            tools = client.request("tools/list")["result"]["tools"]
            self.assertEqual([tool for tool in tools if tool["name"] == "search_text"], [{
                "name": "search_text",
                "description": "Find literal case-sensitive byte matches in the five approved "
                               "synthetic slots. Returns up to 32 ordered matches with byte "
                               "ranges and full-slot SHA-256 digests.",
                "inputSchema": {
                    "type": "object",
                    "properties": {"query": {"type": "string"}},
                    "required": ["query"],
                    "additionalProperties": False,
                },
            }])

            for params in [
                {"name": "search_text", "arguments": []},
                {"name": "search_text", "arguments": {"query": needle}, "extra": True},
                {"arguments": {"query": needle}},
                {"name": "other"},
            ]:
                error = client.request("tools/call", params)
                self.assertEqual(set(error), {"jsonrpc", "id", "error"})
                self.assertEqual(error["error"], {"code": -32602, "message": "Invalid params"})

            for params in [{"name": "search_text"}, {"name": "search_text", "arguments": {}}]:
                data = tool_result(client.request("tools/call", params), is_error=True)
                self.assertEqual(data, common("invalid_input", "unavailable",
                                              diagnostics=[{"code": "invalid_input"}]))

            read_args = {key: item[key] for key in ("path", "start_byte", "end_byte")}
            read_args["expected_sha256"] = item["sha256"]
            start = self.sample.index(needle_bytes)
            self.assertEqual(read_args, {
                "path": "sample.ex", "start_byte": start, "end_byte": start + len(needle_bytes),
                "expected_sha256": sha256(self.sample),
            })
            read_params = {"name": "read_source", "arguments": read_args}
            read = tool_result(client.request("tools/call", read_params))
            excerpt = {
                "path": "sample.ex", "sha256": sha256(self.sample),
                "start_byte": start, "end_byte": start + len(needle_bytes),
                "base64": base64.b64encode(needle_bytes).decode("ascii"),
            }
            assert_observation(read, common("ok", items=[excerpt]), self.sample, guarded=True)

            prefix = b"# Updated\n"
            edited = prefix + self.sample
            self.fixtures.write("sample.ex", edited)
            stale = tool_result(client.request("tools/call", read_params))
            assert_observation(stale, common("changed_since_check"), edited,
                               guarded=True, changed=True)
            assert_search(client.request("tools/call", search_args), edited, start + len(prefix))
            self.assert_clean_eof(client)

    def test_scope_and_budget_failures(self):
        alias = self.fixtures.scratch / "root-link"
        alias.symlink_to(self.fixtures.root, target_is_directory=True)
        try:
            with self.client(root=alias) as client:
                self.assertEqual(client.finish(), (2, b"", b"launch_denied\n"))
        finally:
            alias.unlink()

        with self.client(ready=True) as client:
            read = {"start_byte": 0, "end_byte": 1}
            for outside in ("../sample.ex", "/sample.ex", "missing.ex", str(self.fixtures.scratch / "sample.ex")):
                denied = client.call("read_source", {**read, "path": outside})
                self.assertEqual((denied["status"], denied["items"]), ("denied", []))
                self.assertNotIn("freshness", denied)

            for make in (
                lambda p: p.symlink_to(self.fixtures.path("sample.ex")),
                lambda p: os.link(self.fixtures.path("sample.ex"), p),
                lambda p: os.mkfifo(p, 0o600),
            ):
                self.fixtures.create("duplicate.ex", make)
                denied = client.call("discover", {})
                self.assertEqual((denied["status"], denied["items"]), ("denied", []))
                self.assertEqual(denied["freshness"]["state"], "unknown")
                self.fixtures.remove("duplicate.ex")

            self.fixtures.write("sample.ex", b" " * (MAX_FRAME + 1))
            over = client.call("discover", {})
            self.assertEqual((over["status"], over["items"]), ("limit_exceeded", []))
            self.assertEqual(over["freshness"]["state"], "unknown")
            self.fixtures.write("sample.ex", b" " * MAX_FRAME)
            over = client.call("read_source", {"path": "sample.ex", "start_byte": 0, "end_byte": 4097})
            self.assert_fresh(over, "limit_exceeded", "matched_at_check")
            maximum = client.call("read_source", {
                "path": "sample.ex", "start_byte": MAX_FRAME - 4096, "end_byte": MAX_FRAME,
            })
            self.assert_fresh(maximum, "ok", "matched_at_check")
            self.assertEqual(base64.b64decode(maximum["items"][0]["base64"]), b" " * 4096)
            bad = client.call("read_source", {"path": "sample.ex", "start_byte": 4, "end_byte": 4})
            self.assert_fresh(bad, "invalid_input", "matched_at_check")

            many = b"defmodule Demo.Sample do\n" + b"def echo(value), do: value\n" * 50 + b"end\n"
            self.fixtures.write("sample.ex", many)
            result = client.call("definition", KEY)
            self.assertEqual(result["status"], "ambiguous")
            self.assertIs(result["truncated"], True)
            self.assertEqual(len(result["items"]), 32)
            starts = [item["start_byte"] for item in result["items"]]
            self.assertEqual(starts, sorted(starts))
            self.assert_clean_eof(client)


def interrupt(_signal, _frame):
    raise KeyboardInterrupt


if __name__ == "__main__":
    signal.signal(signal.SIGTERM, interrupt)
    unittest.main(verbosity=2)
