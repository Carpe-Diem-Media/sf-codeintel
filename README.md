# SF CodeIntel

SF CodeIntel is a proposed Elixir code intelligence tool for coding agents. The project will qualify existing indexing and structural analysis tools before choosing a backend.

The synthetic lexical increment has its own design and execution authority. P0-A is not admitted, and backend selection is undecided.

- [Governance and authority register](docs/governance/SF-CI-GOV-001.md)
- [Product requirements](docs/product/SF-CI-PRD-001.md)
- [Architecture](docs/architecture/SF-CI-SPEC-001.md)
- [Qualification assignment](docs/qualification/SF-CI-P0-001.md)
- [ADR process](docs/adr/SF-CI-ADR-001.md) and [backend decision record](docs/adr/ADR-001-backend-selection.md)
- [Technical design process](docs/technical-design/SF-CI-TDD-001.md)
- [Bootstrap verification](docs/governance/bootstrap-verification.md)

## Synthetic lexical CLI and MCP

SFCI-17 implements the Track A synthetic lexical increment under the adopted
[design](docs/technical-design/P1/SF-CI-TDD-P1-LEX-001.md) and
[ADR-002](docs/adr/ADR-002-synthetic-lexical-mcp-stdio.md). P0-A remains on hold.
The structural backend decision and full P1 acceptance have their own gates.

The executable runs on the approved Linux x86-64 environment with Elixir
1.19.3 and OTP 28.1.1. It accepts read-only requests for five slots in one
approved synthetic root.

    _build/sf-codeintel --root ABSOLUTE_APPROVED_ROOT doctor
    _build/sf-codeintel --root ABSOLUTE_APPROVED_ROOT mcp

Doctor emits a JSON summary for a valid binding. Exit 0 reports usable
source access, including supported, partial or empty lexical coverage.
Exit 2 reports invalid arguments or denied scope. Exit 1 reports an
operational failure. Invalid or expired launch authority suppresses stdout.

MCP uses newline-delimited JSON-RPC over stdio and negotiates
`2025-06-18`. Initialize, send `notifications/initialized`, then call
`tools/list` or `tools/call`. Stdout carries protocol frames. Stderr
carries diagnostic codes. The profile supports a single Elixir module
and single-line `def` and `defp` declarations with explicit parentheses.
Supported bodies are integers, bounded strings, parameter reads and
literal qualified calls. See the design for the grammar and exclusions.

- `discover` lists module and function declarations.
- `definition` matches the exact module, function and arity. Duplicate
  observations are ambiguous. A partial capture leaves uniqueness unknown.
- `references` reports qualified call candidates based on spelling and
  argument count.
- `read_source` takes a slot and a zero-based, half-open byte range and
  returns up to 4,096 bytes in base64. An optional expected SHA-256 guards
  the read.
- `check_source` compares the SHA-256 of a slot against an expected digest.
- `search_text` finds literal, case-sensitive byte matches in the five
  synthetic slots. Pass a `query` of 1–128 UTF-8 bytes without NUL, CR or LF.

The flat slots are `caller.ex`, `duplicate.ex`, `renamed.ex`,
`sample.ex` and `unsupported.ex`. Each result uses captured bytes and
rechecks the manifest across all five slots before delivery. The comparison
reports the observations at check time. Unsupported readable files make
lexical coverage partial and can still be read as bytes. The lexer never
evaluates, compiles or loads fixture source.

### Search and guarded reads

SFCI-19 adds MCP-only literal search under the
[search design](docs/technical-design/P1/SF-CI-TDD-P1-LEX-002.md) and
[ADR-002 supplement](docs/adr/ADR-002-SFCI-19-synthetic-text-search.md).
Search matches raw bytes, including comments and unsupported source. It
returns non-overlapping matches in path and byte-offset order. A stable
miss returns `unresolved` with no items. A 33rd match sets `truncated` and
the response keeps the first 32 matches.

Each match includes its path, zero-based half-open byte range and the
SHA-256 of the complete slot. To retrieve the matched bytes, pass the
match's `path`, `start_byte` and `end_byte` to `read_source` with its digest
as `expected_sha256`. Search and read each check their own captures and
report their own `checked_at`. A stale digest returns `changed_since_check`
with no bytes. Search again to get the current range and digest.

### Launcher and checks

The trusted launcher verifies the effective grant, root ownership, device
and inode, canonical ancestor modes and ACLs, and mount custody. It supplies
an operator-controlled, private `SFCI_LAUNCH_BINDING` JSON object at exec time.
It contains `root`, `device` (Linux `st_dev`), `inode`, `uid`, `binding_id`,
`grant_id`, `launch_monotonic_ms`, `deadline_monotonic_ms` and
`grant_deadline_monotonic_ms`. The child binds those values once. The trusted
launcher controls the environment, executable, child PID and pipes. Client
messages cannot set approval or select the root.

Use Linux boot-time monotonic milliseconds in the same time namespace for
both processes. Sample monotonic time before UTC when converting the grant
expiry. Cap the effective deadline at five minutes after launch and at the
grant deadline. The child rounds the kernel's centisecond uptime reading
up before admission and delivery checks. The launcher enforces the clock
deadline independently, limits sessions to 100 frames, and terminates and
reaps the child on revocation, deadline or I/O failure. Keep an exclusive
mode-0700 root under trusted ancestors and allow fixture writes only between
requests by the authorized operator. The child checks path and descriptor
identity. Filesystem custody is an operator prerequisite.

The Lead runs these commands after verifying the effective run grant and
the toolchain, process and fixture controls:

```sh
mix format --check-formatted mix.exs 'lib/**/*.ex' 'test/**/*.exs'
mix compile --warnings-as-errors
mix test
mix escript.build
python3 test/mcp_stdio_test.py
```

The Python driver launches the built executable, writes temporary fixtures
as the authorized launcher, and verifies timeout and reaping behavior.
Set `SFCI_FIXTURE_ROOT` to the approved empty root,
`SFCI_FIXTURE_DEV_INO` to its preverified device and inode as `DEV:INO`,
and `SFCI_TEST_SCRATCH` to a separate empty private directory. The driver
uses the SFCI-19 execution grant and its recorded expiry. A later run
requires effective authority and approved launcher settings.

The hosted job checks the explicit same-repository PR head on the standard
Ubuntu 24.04 x64 runner. The Lead verifies the workflow and authorizes the
single run under the bounded grant. The job records the image, tools,
fixture identity, tested SHA and sampled allocated bytes in its log.
