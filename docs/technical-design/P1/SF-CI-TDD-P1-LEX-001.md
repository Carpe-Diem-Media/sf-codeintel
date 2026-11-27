# SF-CI-TDD-P1-LEX-001 | Synthetic lexical CLI and MCP

| Document control | Value |
|---|---|
| Revision | 0.1 |
| Status | Proposed |
| Issue | SFCI-17, Track A |
| Author | SFCI-17 documentation delegate |
| Design owner and acceptance authority | Lead Orchestrator under GOV §4.1 |
| Authoring base | `9ed2080ec00db2622168a287ea2f5a982ca0f809` |
| Companion decision | [ADR-002 v0.1](../../adr/ADR-002-synthetic-lexical-mcp-stdio.md), Proposed |
| Predecessor | None |
| Execution authorization | Separate bounded grant pending |

## 1. Authority and scope

Apply [GOV v0.4](../../governance/SF-CI-GOV-001.md) §§4, 6–8, [TDD v0.1](../SF-CI-TDD-001.md) §§2–6 and [SEQ v0.1](../../governance/SF-CI-SEQ-001.md) under the [SFCI-16 activation](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/35b39857-d11f-43b4-88dd-20f7867c40cc#comment-7ecfb0dc-56a1-4f7d-b420-31896879f262). Authority for authoring comes from the [original proposal](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/685e53a0-6e84-4285-9eb0-831ca53f746e#comment-aacc6cfa-bb8d-40a5-8ef4-3ab09225452d), [Lead correction](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/685e53a0-6e84-4285-9eb0-831ca53f746e#comment-472f76c0-c729-4136-84ab-51c03d7d21ae), [binding addendum](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/685e53a0-6e84-4285-9eb0-831ca53f746e#comment-de78656a-bd25-4512-8ef4-07775bf7c08b) and [prospective approval](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/685e53a0-6e84-4285-9eb0-831ca53f746e#comment-f8fd49bc-ae14-45e9-a4fb-37eb9d5b6280). The addendum controls the amended clauses.

Deliver one dependency-free Elixir escript for diagnostics and MCP source inspection over one explicitly approved read-only synthetic root per launch. Scope includes module and function discovery, exact declaration-key lookup, lexical call candidates, bounded byte retrieval and freshness observations. The product uses no target AST, evaluation, macro expansion, compilation or target Mix invocation. Exclude persistent storage, indexing workers, structural graph ownership, remote access, real repositories and Factory integration. The SEQ exception changes only P0 exit and backend-decision timing for Track A. ADR-001 remains Proposed. Track B retains the SEQ hold, including SFCI-5 Blocked, P0-A `NOT ADMITTED / NOT RUN` and clock `NOT STARTED`. SFCI-6–11 retain their applicable gates and relations. This increment supplies no P0 qualification, full P1 exit or later-phase entry evidence. P0-B still requires a separate grant or explicit deferral under its applicable gate. The held qualification records, limits and STOP conditions in SEQ Track B remain in force.

## 2. Launch and component contracts

`sf-codeintel --root ABSOLUTE_APPROVED_ROOT doctor|mcp` accepts one absolute root from the trusted launcher. Neither mode infers scope from cwd, target configuration or client input. The CLI owns argument validation and binding. `doctor` uses the same binding and source checks as server mode and emits one JSON object with schema version, supported profile, status and coverage. Exit 0 for usable binding, 2 for invalid launch arguments or denied root, and 1 for operational failure.

`SourceAdapter.capture(binding)` returns an immutable manifest and bounded captured bytes, or a typed denial, budget or operational failure. The local adapter owns filesystem access. The lexical extractor consumes only captured bytes and keeps identifiers as binaries. One query module validates tool inputs, compares captures and constructs results. The stdio module owns framing, JSON-RPC, the session and the five public tool schemas. Both entry points share the same adapter. Mix uses `deps: []` and OTP `:crypto`, with the generated executable under `_build/`.

| Tool | Input and behavior |
|---|---|
| `discover` | Empty object. Return supported module and function declarations. |
| `definition` | Required strings `module` and `function` and integer `arity` (0–8), using §3 token rules. Match exact normalized declaration keys. |
| `references` | Same key as definition. Match literal qualified callee spelling and syntactic argument count. Label each item `lexical_candidate`, including when a declaration matches. Local calls, alias resolution, dynamic dispatch, captures and generated functions are outside the profile. |
| `read_source` | Required slot string `path`, integer `start_byte` and `end_byte`, optional `expected_sha256`. Return the exact base64 byte slice for a nonempty zero-based half-open range inside the file, up to 4,096 bytes. A digest mismatch suppresses the excerpt. |
| `check_source` | Required slot string `path` and `expected_sha256`. Compare the expected full-file digest with the stable observed digest at that slot. |

Reject unknown keys and wrong types. Use SHA-256 hex strings for digests. A slot outside the allowlist is denied before filesystem access.

## 3. Lexical profile

Accept UTF-8, LF or CRLF and an optional final newline. Consume the whole file. Ignore blank lines and standalone `#` comments. Require exactly one top-level `defmodule Alias.Path do` block closed by `end`. Inside it, admit single-line `def` and `defp` declarations with explicit parameter parentheses and `, do:` followed by one body. Horizontal whitespace is ASCII space or tab. A body is a value or one literal qualified call of the form `Alias.Path.function(values)`. Values are parameter reads, integers or strings. Calls have no nesting. Reject unsupported or malformed files as a unit. Inline comments, guards, defaults, nested modules and other body forms fall outside the profile.

- A module is one to four dot-separated `[A-Z][A-Za-z0-9_]{0,31}` segments. Reject `Elixir` as the first segment.
- Function, callee and parameter tokens match `[a-z][a-z0-9_]{0,31}` and exclude the reserved names below.
- Declarations and calls allow zero to eight comma-separated entries. Parameters must be distinct. Every bare name in a body or argument must name a parameter of that declaration. Repeated reads and unused parameters are allowed.
- Integers match `0|[1-9][0-9]{0,8}`. Double-quoted strings allow at most 256 UTF-8 content bytes. Exclude line breaks, control characters, backslashes, unescaped double quotes and `#{`.
- Use fixed binary matching or bounded anchored patterns. Retain original bytes for all offsets.

```text
after alias and case catch cond def defdelegate defexception defguard defguardp
defimpl defmacro defmacrop defmodule defp defprotocol defstruct do else end
false fn for if import in nil not or quote receive require rescue super true
try unless unquote unquote_splicing use when with
```

## 4. Custody, evidence and freshness

Read only the flat slots `caller.ex`, `duplicate.ex`, `renamed.ex`, `sample.ex`, `unsupported.ex`, in bytewise order. Record missing slots. The launcher records the approved root's device and inode before launch and passes the approved path directly. Before each slot open, check the root identity and canonical ancestor chain with `lstat`. Reject symlinks, non-regular files, multiple links and files on another device. Verify opened descriptor identity and size. Read at most 16 KiB plus one sentinel byte per slot and admit at most 80 KiB per pass. Fail closed on denial or unverifiable capture. Use diagnostic codes and approved relative paths only.

The root, ancestor paths and mount topology must be protected against untrusted mutation throughout requests. Path checks and repeated hashes depend on that custody. The operator must supply a private dedicated root with mode `0700`, owner and canonical ancestor owner/mode/ACL evidence, and evidence that untrusted principals cannot replace, write or remount the path. Name the launcher operator and sole fixture writer before acceptance. The test driver changes fixture bytes only between calls, except deterministic capture failure injection through the adapter test. An already approved OS-enforced boundary may establish custody where required. Stop before implementation if custody cannot be established. Arbitrary hostile repositories and shared local writers are outside scope.

For every call, capture presence, size and full-file SHA-256, prepare results from those bytes and recapture before delivery. Hash a versioned, unambiguous ordered manifest of the path, presence, size and digest for each slot. The first manifest binds source evidence to immutable captured bytes. The second pass compares all five slots before expected-digest comparisons. Drop captured bytes and extracted facts after the response. Two matching reads establish observations at check time. An atomic snapshot and subsequent freshness are outside this guarantee.

Results carry integer `schema_version: 1`, `status`, `coverage`, boolean `truncated`, `items` and bounded machine-readable `diagnostics`. Capture-backed results carry opaque launcher binding ID, manifest SHA-256, backend/profile version and UTC `checked_at`. Source items include relative path, full-file SHA-256 and zero-based half-open byte span. A declaration span covers the identifier token and a candidate span covers the qualified callee token. Order source items by bytewise path, then start offset.

Compute lexical coverage and definition cardinality before truncation. All present slots passing the profile yields `complete_for_profile`. Confirmed missing slots preserve that coverage. Any readable unsupported slot makes coverage `partial` and contributes diagnostics even when observed evidence is positive. Stable readable bytes remain retrievable regardless of lexical coverage.

| Result | Complete coverage | Partial coverage |
|---|---|---|
| Definition, zero observed spans | `unresolved` | `unsupported` |
| Definition, one span | `ok`, `uniqueness: "unique_in_profile"` | `ok`, `uniqueness: "unknown"` |
| Definition, multiple spans | `ambiguous`, alternatives | `ambiguous`, alternatives |
| References, positive | `ok`, `lexical_candidate` | `ok`, `lexical_candidate` |
| References, empty | `unresolved` | `unsupported` |
| Discovery, positive | `ok` | `ok` |
| Discovery, empty | `unresolved` | `unsupported` |

Reference coverage applies to spelling and arity within this profile. Use `invalid_input` for invalid tool inputs, `denied` for forbidden scope, `limit_exceeded` for exceeded budgets and `unavailable` for failed capture with unknown evidence. Return `unavailable` coverage for a failed capture. Return no source evidence when scope or capture checks fail.

Each capture-backed response includes a `freshness` object with `state`, UTC `checked_at`, `method`, `checked_slots`, `comparison_slots` and first and second manifest IDs when available.

- Use `double_capture_slot_sha256` for comparison across all five slots and list those slots in `comparison_slots`. For `check_source` and digest-guarded `read_source`, use `double_capture_slot_sha256_and_expected_digest` and identify the requested slot in `comparison_slots` when comparing the expected digest.
- On full revalidation, `checked_slots` equals `["caller.ex","duplicate.ex","renamed.ex","sample.ex","unsupported.ex"]`. A failed second pass reports only the verified subset, freshness `unknown` and no complete second manifest ID. Withhold items.
- A second-pass mismatch yields `changed_since_check` for the five-slot comparison, lists all five slots in `comparison_slots` and withholds all items. After stable captures, a missing requested slot or an expected digest mismatch yields `changed_since_check` for that slot. Return no excerpt on mismatch.
- A successful applicable comparison yields `matched_at_check`. A same-byte replacement can match. A rename leaves the old slot missing even if identical bytes now occupy another approved slot.

## 5. MCP transport and lifecycle

Use [MCP 2025-06-18 stdio](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports), [lifecycle](https://modelcontextprotocol.io/specification/2025-06-18/basic/lifecycle), [ping](https://modelcontextprotocol.io/specification/2025-06-18/basic/utilities/ping) and [tools](https://modelcontextprotocol.io/specification/2025-06-18/server/tools) as the pinned wire contract. At startup set `:io.setopts(:standard_io, [:binary, {:encoding, :latin1}])` and fail closed on failure. Read with `:file.read(:standard_io, 1)` and write with `:file.write(:standard_io, frame)`. Read one byte at a time so LF triggers immediate dispatch while stdin stays open. Cap accumulated bytes at 16,384 before LF including a terminal CR. Close on the first excess non-LF byte or EOF with an unfinished frame. Strip one terminal CR, then validate UTF-8 and JSON.

Require one JSON-RPC object per LF frame. Reject batches, embedded physical newlines, duplicate keys, trailing data, invalid UTF-8, depth above 16 and integer literals above 16 digits. Use bounded validation and OTP `:json` decoder callbacks. Require non-null integer or string request IDs, up to 64 bytes for strings, and validate method-specific objects. Use JSON-RPC errors `-32700` for parse errors, `-32600` for invalid requests or lifecycle violations, `-32601` for unknown methods and `-32602` for invalid method parameters. Notifications receive no responses.

| State | Trigger and effect |
|---|---|
| Bound, awaiting initialize | Validate `initialize.params.protocolVersion`, `capabilities` and `clientInfo` against the pinned schema. For every well-formed version proposal return `protocolVersion: "2025-06-18"`, `capabilities: {"tools":{"listChanged":false}}` and `serverInfo: {"name":"sf-codeintel","version":"0.1.0"}`. The client disconnects if it cannot use the returned version. |
| Awaiting initialized | A valid `notifications/initialized` after the initialize response enables tools. |
| Ready | `tools/list` advertises only §2's five static tool schemas. `tools/call` validates the named tool and arguments and returns the domain outcome in `structuredContent` with a matching JSON text block. |
| Any live state | Valid `ping` returns `{}` with the same ID and preserves state. Premature tool requests and duplicate initialize return `-32600`. |
| Terminal | EOF, oversized or abandoned frame, terminal I/O failure, expiry or revocation closes the session. The launcher owns the PID and pipes and terminates and reaps the child when interruption is required, including during a stalled read. |

Serialize requests. Use a two-second deadline per tool and a launcher-enforced ceiling of 100 frames or five monotonic minutes, capped by grant expiry. The launcher enforces immediate revocation and owns cancellation requiring immediate interruption. Per-request preemption on a busy pipe is outside scope. Read retries recapture source in a fresh request. No replay cache, background indexing or surviving state. Stdout carries protocol frames only and stderr carries bounded diagnostics.

Cap each encoded response at 32 KiB, including both result representations and protocol framing, and return at most 32 items. Discovery and references may return the ordered prefix with `truncated: true`. Preserve observed ambiguity when capping alternatives. If required evidence cannot fit, return `limit_exceeded` without source bytes.

## 6. Delivery paths

The later implementation assignment may write these tracked paths only, subject to its grant.

- `mix.exs`, `lib/sf_codeintel/cli.ex`, `README.md`
- `lib/sf_codeintel/source_adapter.ex`, `lib/sf_codeintel/local_source.ex`, `lib/sf_codeintel/lexical.ex`, `lib/sf_codeintel/query.ex`, `lib/sf_codeintel/mcp_stdio.ex`
- `test/test_helper.exs`, `test/local_source_test.exs`, `test/lexical_test.exs`, `test/query_test.exs`, `test/mcp_stdio_test.py`
- `test/fixtures/lexical/sample.ex`, `test/fixtures/lexical/caller.ex`, `.github/workflows/ci.yml`

Commit only two files under the fixture directory. Create duplicate, unsupported, renamed and denial cases in a private disposable fixture copy. Use ExUnit for adapter, lexical and query contracts. Use Python's standard library to drive the same built escript as the CLI over subprocess pipes, separate stderr, enforce timeouts and verify process exit. README documents the profile, protocol, trust boundary and operator commands.

## 7. Acceptance checks

All product checks are pending. These obligations exercise slices of PA-02/03/04/05/10 and CI-R02/03/04/06/07/08/09/10/11/13/14 under architecture §§05A–07, 09, 11–14 and 15A–17.

1. **LEX-V1. Real client and service.** Send a short initialize as the first frame and wait for the reply before writing anything else. Keep stdin open. Verify server identity and fallback version in a separate session. Exercise ping both before initialize and while awaiting initialized, rejection of pre-ready tools, initialized and normal tool operation. Check IDs, tool list and all five calls, version negotiation, notifications, malformed and oversized frames, stdout cleanliness, doctor exit behavior, EOF and shortened-deadline expiry with bounded termination and reaping.
2. **LEX-V2. Exact evidence.** Compare discovery keys and arities with fixture expectations. Independently slice declaration and candidate spans, including CRLF and multibyte content before a span. Verify base64 excerpts and SHA-256 independently. Check overloads and duplicates, candidate labels, comment and string handling, reserved names, duplicate parameters and unbound body or call arguments. With one unsupported slot check zero, one and multiple definitions, positive and empty references, diagnostics and supported-byte retrieval. Check complete-profile missing keys as well.
3. **LEX-V3. Freshness.** In one service session, edit a file to different same-length bytes, rename into an approved slot and delete between requests. Check stale evidence, new slot visibility, digest-guarded excerpt suppression, freshness methods, exact checked and comparison slots and the second manifest ID. Inject a changed or failed second capture in adapter tests and verify withholding and the appropriate freshness state.
4. **LEX-V4. Scope and budgets.** Deny traversal, absolute and cross-root paths, unknown slots, symlink root or file, hardlink and non-regular source before byte ingestion. Check source, frame, result and range ceilings. Include inert synthetic source that would create a sentinel if evaluated and assert sentinel absence. Verify only the driver writes fixtures and that child and scratch cleanup finish.
5. **LEX-V5. Exact hosted head.** Run the real product job `product / lexical-cli-mcp` on an approved Linux x86-64 hosted runner. Check out the explicit PR head SHA, and assert `git rev-parse HEAD` matches before execution. Record pinned version output, actual completed check and tested SHA. The job requires every command below to succeed. The fixture `.ex` files stay outside the formatter. Mock results and optional `Proof` provide no product CI evidence.
6. **LEX-V6. Authority and persistence.** Record accepted exact TDD and ADR revisions, the separate effective grant, scoped commits and restart checkpoint. Capture branch, base, head, approvals, limits and debits, tests and cleanup. Keep durable records in the issue-linked Git branch and Plane. On restart reconcile the worktree, recorded evidence and still-effective conditions before resuming. Independent review verifies the full hosted base/head diff, protections, required checks, authority and exact-head CI. The Lead performs the separate GOV §8 integration check. Changes to the candidate or applicable authority require fresh verification.

```sh
mix format --check-formatted mix.exs 'lib/**/*.ex' 'test/**/*.exs'
mix compile --warnings-as-errors
mix test
mix escript.build
python3 test/mcp_stdio_test.py
```

## 8. Blocking evidence and bounded execution

**Before design acceptance.** Independently review both exact submitted documents. Record the named launcher operator and sole fixture writer, actual root and custody evidence from §4, PID and pipe ownership, and how the launcher enforces monotonic expiry capped by grant expiry, immediate revocation and termination and reaping on stalled stdin. The Lead records accountable acceptance separately against the exact documents and evidence. The plan review covers prospective authoring only.

**Before dispatch.** Verify the approved local and hosted environments and per-run custody. The binding addendum reports local Elixir 1.19.3 and OTP 28.1.1, including the installed `OTP_VERSION` record. A version observation leaves the execution environment unverified. The observed group-writable `~/.local` ancestor means custody needs proof at the actual selected location. Record supported host OS/CPU, exact versions, Python and process-limit tooling, actual hosted runner image and immutable action commit pins. Approve exact hosted toolchain acquisition channels and artifacts if needed. Use a read-only contents token and disable persisted checkout credentials. The job gets neither deployment permission nor secrets. Verify the runtime controls in the authorized subprocess tests, including shortened expiry and reaping.

**Separate proposed grant.** Bind a named implementation delegate and separate reviewer, the issue-linked worktree, approved root per session, approved tooling, permitted commands and writes, actor, dates and expiry. Proposed ceilings are two local hours, 512 MiB generated disk state, one service process at a time, two BEAM schedulers and a verified 512 MiB per-service memory limit. Cap each hosted job at ten minutes, with one initial run and one rerun for a diagnosed transient failure or scoped correction. Limit authorized activity to the listed Mix, test, escript and fixture operations, scoped Git/PR operations and writes to the tracked paths, `_build/` and dedicated scratch. Only authorized project checkout and hosted bootstrap traffic are eligible. Dependency fetches, backend acquisition, private data, target execution, privilege changes and added spending are excluded. Stop on authority or containment failure, unavailable required check, exhaustion or unresolved cleanup. Terminate and reap the service and remove only disposable scratch. Preserve durable evidence of cleanup.

An unresolved material interface or trust change returns to exact proposal review under TDD §6 and ADR governance. Revoke launch permission to stop use and clean up the ephemeral child and scratch. There is no persisted application schema to migrate or roll back.

## 9. Review and revision record

Revision 0.1 is the initial proposal. Independent review of the committed document bytes, actual environment evidence, design acceptance and the separate execution grant are pending. Record the immutable proposal identity, independent findings, accountable actor, exact authority, date, scope and effective conditions in the trusted decision record.
