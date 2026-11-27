# SF-CI-TDD-P1-LEX-002. Synthetic literal text search

**Proposed v0.1** · [SFCI-19](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/4d229902-9c98-46a7-aa74-6131b8775364) · Track A

## 1. Authority and scope

Design author: SFCI-19 documentation delegate. Design and technical acceptance owner: Lead Orchestrator within the standing mandate. The independent design reviewer, implementation author, independent final reviewer, ratified operator and sole fixture writer must be recorded before their respective assignments. Record any authorized role combinations separately from independent review and acceptance.

The immutable design base is `63eaf5563df6c01d8f171b9782b6c2cac320ee51`. Apply [PRD v0.1](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/product/SF-CI-PRD-001.md), [architecture v0.4](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/architecture/SF-CI-SPEC-001.md), [GOV v0.4 §§4, 7–8](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/governance/SF-CI-GOV-001.md), [TDD governance v0.1 §§2.3, 3, 5–6](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/technical-design/SF-CI-TDD-001.md) and [ADR governance v0.1](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/adr/SF-CI-ADR-001.md).

The [SFCI-18 activation](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/a2315b0a-de1b-4622-b601-c91d143c8851#comment-2bf7c15f-5216-45d0-9121-094368f3165e) took effect at 2026-11-27T18:34:47.630154Z and permits this slice to precede applicable P0 exit and acceptance of a viable backend. SFCI-16 retains its original scope. Track B and SFCI-5–11 retain their gates. P0-A remains `NOT ADMITTED / NOT RUN` with clock `NOT STARTED`. P0-B, Q0, backend selection, structural ownership and full P1 exit remain separately governed.

The [SFCI-17 activation](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/685e53a0-6e84-4285-9eb0-831ca53f746e#comment-2386c1e9-a9b2-4f64-abd4-c5bc71366fce) binds the [lexical TDD v0.1](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/technical-design/P1/SF-CI-TDD-P1-LEX-001.md), blob `ee34141f15479054ee9550e52fcbc85fa777f473`, SHA-256 `6d3e389ab0890bb033efc6784c83cd817470ec9fc03caf03b37f32a896353ff0`, and [ADR-002](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/adr/ADR-002-synthetic-lexical-mcp-stdio.md), blob `0473f65ac3f63eb518bed7ec8a96c4151be6edec`, SHA-256 `9d1429f2c8f70567a16dcabf024a773ecb1d33890972a0f0c0330128a0355edc`. Inherit the CLI launch, source adapter and five tool contracts from [§2](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/technical-design/P1/SF-CI-TDD-P1-LEX-001.md#2-launch-and-component-contracts), the lexical profile from [§3](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/technical-design/P1/SF-CI-TDD-P1-LEX-001.md#3-lexical-profile), custody, evidence and guarded reads from [§4](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/technical-design/P1/SF-CI-TDD-P1-LEX-001.md#4-custody-evidence-and-freshness), MCP lifecycle and framing from [§5](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/technical-design/P1/SF-CI-TDD-P1-LEX-001.md#5-mcp-transport-and-lifecycle), delivery paths from [§6](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/technical-design/P1/SF-CI-TDD-P1-LEX-001.md#6-delivery-paths), acceptance and regression checks from [§7](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/technical-design/P1/SF-CI-TDD-P1-LEX-001.md#7-acceptance-checks), and execution conditions from [§8](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/technical-design/P1/SF-CI-TDD-P1-LEX-001.md#8-blocking-evidence-and-bounded-execution). The [proposed ADR supplement](../../adr/ADR-002-SFCI-19-synthetic-text-search.md) seeks affirmative disposition of the six-tool inventory only.

Authority for these drafts comes from the [authoring release](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/4d229902-9c98-46a7-aa74-6131b8775364#comment-bd1e6c1a-a5fe-43b5-b6a7-b215e91ab7ca), [design checkpoint](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/4d229902-9c98-46a7-aa74-6131b8775364#comment-4bd2fb6a-6367-41d7-99a9-735ddea776c6) and [design corrections](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/4d229902-9c98-46a7-aa74-6131b8775364#comment-28c885ba-eb60-429c-ad01-1c21200af5b5). The [implementation plan accepted for planning](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/4d229902-9c98-46a7-aa74-6131b8775364#comment-a52054c7-3e6e-4a6d-8db0-57b209c7b158) binds item `turn-item:provider:codex:native-item:msg_01d57175ebc0a929016b09c2f8bfac87d0971934574edff08f` in full, with the [hosted correction](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/4d229902-9c98-46a7-aa74-6131b8775364#comment-e92e4a97-c059-4286-810a-332eba90f238) taking precedence.

Search is read-only, MCP-only and confined to these ordered slots: `caller.ex`, `duplicate.ex`, `renamed.ex`, `sample.ex`, `unsupported.ex`. Scope excludes ingestion, indexing, persistence, parser changes, structural relationships, real or private roots, target execution and new dependencies.

## 2. Wire contract

Add this entry to the existing static `tools/list` response. The existing five entries retain their names, descriptions and schemas.

```json
{
  "name": "search_text",
  "description": "Find literal case-sensitive byte matches in the five approved synthetic slots. Returns up to 32 ordered matches with byte ranges and full-slot SHA-256 digests.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {"type": "string"}
    },
    "required": ["query"],
    "additionalProperties": false
  }
}
```

Runtime validation requires exactly one `query` string of 1–128 UTF-8 bytes and rejects NUL, CR and LF. Reject before capture. An omitted `arguments` key follows the existing default of `{}` and yields tool-level `invalid_input`. Non-object `arguments`, unknown tool names, missing names and disallowed `params` keys follow existing ready-state `tools/call` validation and return `{"jsonrpc":"2.0","id":ID,"error":{"code":-32602,"message":"Invalid params"}}`. JSON parse, JSON-RPC envelope, notification and initialization handling stay on their baseline paths.

For a tool result, `S` is the structured object below. The outer response is `{"jsonrpc":"2.0","id":ID,"result":{"structuredContent":S,"content":[{"type":"text","text":JSON_ENCODED_S}],"isError":BOOLEAN}}`, followed by LF. The text block decodes to the identical object. The common six keys in `S` are `schema_version: 1`, `status`, `coverage`, `truncated`, `items` and `diagnostics`.

Each match has exactly this shape. `sha256` is the lowercase SHA-256 of the **entire raw slot in the first capture**. Offsets are zero-based and half-open.

```json
{"kind":"text_match","path":"sample.ex","sha256":"<64 lowercase hex digits>","start_byte":3,"end_byte":7}
```

Use these outcome rules:

- **Stable hits.** `status: "ok"`, `coverage: "complete_for_profile"`, `items` holding one to 32 matches, `diagnostics: []`, `isError: false`. `truncated` is true only after finding a 33rd match. In that case the evidence covers the exact ordered first 32 and establishes that a 33rd exists.
- **Stable miss.** `status: "unresolved"`, `coverage: "complete_for_profile"`, `truncated: false`, `items: []`, `diagnostics: []`, `isError: false`. This includes all slots missing.
- **Invalid fields.** `status: "invalid_input"`, `coverage: "unavailable"`, `truncated: false`, `items: []`, `diagnostics: [{"code":"invalid_input"}]`, `isError: true`. This outcome has only the six common keys.
- **First or second capture failure.** Use the adapter's `denied`, `unavailable` or `limit_exceeded` status and one unchanged adapter diagnostic `{"code":CODE,"path":SLOT}`. Examples include `slot_type_or_identity`, `slot_open_failed` and `capture_byte_limit`. A capture task exit uses `unavailable` and `{"code":"capture_failed"}` with no path. Use `coverage: "unavailable"`, `truncated: false`, `items: []`, `isError: true`.
- **Changed second capture.** `status: "changed_since_check"`, `coverage: "unavailable"`, `truncated: false`, `items: []`, `diagnostics: [{"code":"capture_changed"}]`, `isError: false`.
- **Tool deadline.** `status: "limit_exceeded"`, `coverage: "unavailable"`, `truncated: false`, `items: []`, `diagnostics: [{"code":"tool_deadline"}]`, `isError: true`. An expired deadline takes precedence over a prepared outcome, including a changed result. Session expiry or revocation still takes the existing launcher/transport path and can suppress the frame entirely.
- **Response size fallback.** If the encoded search reply including LF exceeds 32,768 bytes, emit `status: "limit_exceeded"`, `coverage: "unavailable"`, `truncated: true`, `items: []`, `diagnostics: [{"code":"response_byte_limit"}]`, `isError: true`. Here `truncated` reports the transport fallback. Retain the evidence of the completed observation and use the original request ID. Verify the fallback fits under the bound for the maximum admitted ID. Preserve the old fallback for the five legacy tools.

Every valid-arguments outcome adds `binding_id` from the validated binding, `backend_version: "local_source_v1"`, `profile_version: "synthetic_text_search_v1"`, ISO 8601 UTC `checked_at`, and `freshness`. That nested object has exactly `state`, `checked_at` equal to the top-level timestamp, `method: "double_capture_slot_sha256"`, `comparison_slots` containing all five slots in the order above, and `checked_slots`. Also include `freshness.first_manifest_sha256` and top-level `manifest_sha256` when a complete first capture exists. Include `freshness.second_manifest_sha256` only when a complete second capture exists. These are existing manifest digests, independent of the item digest.

For stable and changed observations, use `matched_at_check` and `changed_since_check`, respectively, with all five checked slots. For a capture failure or deadline use `unknown`, with the completed slot list or reported checked prefix from the latest phase. A capture task that returns no progress reports `[]` for that phase. A scan deadline after the first capture reports the five slots from that capture. A response-size fallback retains the observation's state and evidence. There are no null placeholders, lexical diagnostics, snippets, echoed queries, counts or cursors.

### Search and guarded read

Search bytes in ascending path order and ascending byte offset. Exact matching is case-sensitive and non-overlapping. After a hit, advance by the needle's full byte length. Missing slots yield zero hits. The same matching rule applies to comments, invalid UTF-8 in files and unsupported source. Compare both full manifests, including presence or absence of all five slots, even when search stopped on match 33.

The client passes `path`, `start_byte`, `end_byte` and `expected_sha256` from the item to `read_source`. A successful guarded read returns the exact range as base64. It checks its own fresh captures and the supplied digest. With two equal read captures and a stale expected digest, preserve baseline `changed_since_check`, empty items, `isError: false`, lexical coverage and diagnostics, and `freshness.state: "changed_since_check"`. Preserve `method: "double_capture_slot_sha256_and_expected_digest"`, all five `checked_slots`, `comparison_slots: [path]` and the read's own manifest digests. If the read's captures differ, the baseline manifest-change path applies first. Search and read provide evidence at their respective check times. [Query](../../../lib/sf_codeintel/query.ex) · [MCP stdio](../../../lib/sf_codeintel/mcp_stdio.ex)

## 3. Observation and deadline

Use `LocalSource` for both full captures and keep the existing manifest and capture error semantics. Hold the observation in memory. Compile the needle once, search at most 16 KiB in any binary search operation and skip lexical extraction and whole-file decoding. Keep at most 32 result maps. Hit 33 exits both scan loops without constructing a map for that hit. Every returned hit requires successful revalidation of all five slots.

Start a single absolute monotonic deadline at the start of valid observation, now plus 2,000 ms. Pass the remaining time to each capture and apply the existing task shutdown discipline to a stall. Check before scan entry, at every slot, before and after every bounded search, before and after the second capture, and immediately before Query returns. Use `System.monotonic_time(:millisecond)` in production. Keep the deterministic test clock private to the internal search path and inaccessible through MCP, launch JSON and environment. Transport applies its existing pre-write authority check and separate reply byte limit.

## 4. Custody and launcher lifecycle

Retain one trusted launcher, one authorized child and one launcher-supplied binding. Preserve admission, source ownership and identity validation, the 16 KiB slot and 80 KiB capture limits, 4,096-byte guarded reads, 16,384-byte request frames, 100 frames and the five-minute session cap further bounded by grant expiry. Preserve watchdog enforcement and the Python I/O stall timeout. At EOF, expiry, revocation or stall, apply existing shutdown and context cleanup, kill when needed, wait, close pipes and verify reaping. Record any STOP outcome and cleanup against the run.

Retain all Python fixture-scope predicates. Verify empty private roots, real paths, device/inode, effective ownership, mode `0700`, trusted ancestors and mount custody. Require a sole writer. Keep root and scratch separate and non-nested. Hosted mode requires the runner work directory directly under the runner home with the grant-bound prefix, root named `fixtures` and scratch at its sibling `scratch`. Local mode requires the exact authorized root and identity. Keep the existing slot allowlist, pre-write grant and identity checks, exclusive regular-file replacement and child environment and launch checks. Ordinary edits occur between completed calls. A deliberate containment mutation requires explicit baseline test coverage and grant authorization.

## 5. Verification and implementation boundary

### 5.1 RED, GREEN and regression

Add these ExUnit cases to [query_test.exs](../../../test/query_test.exs). Run `mix test test/query_test.exs`. The anticipated RED class is an ExUnit assertion mismatch between the baseline unknown-tool `invalid_input` result and the expected search outcome. The invalid-argument test also asserts the tool is registered so it cannot pass solely on baseline rejection.

| ExUnit test | Assertions after GREEN |
| --- | --- |
| `search_text_matches_literal_bytes_in_path_and_offset_order` | Match `a.*` literally in an unsupported slot and beside invalid UTF-8, reject `A.*`, and assert offsets after multibyte prefixes, whole-slot digest and identical repeated order. Use `aa` in `aaa` to assert one non-overlapping match. |
| `search_text_reports_a_stable_miss_for_missing_and_present_slots` | Assert exact miss shape with all slots missing, then with a present nonmatching slot. |
| `search_text_reports_an_ordered_prefix_only_after_hit_33` | Exactly 32 hits yields false. Put hit 33 in the next path and assert the unchanged 32-item prefix and true. Use a scan observer confined to the internal test seam, or a pure scanner test, to prove later paths are skipped. The second capture still checks every slot. |
| `search_text_rejects_invalid_arguments_without_capture` | Check tool registration. Reject missing, extra, missing query, wrong type, empty, over 128 UTF-8 bytes and each forbidden byte. Accept 128 bytes. Assert zero capture calls for each rejected input. |
| `search_text_suppresses_results_when_captures_cannot_be_verified` | Script first denial, first unavailable, first capture byte limit, second failure and an unrelated second-slot change. Assert exact diagnostic, evidence, manifest keys and capture count for each. |
| `search_text_deadline_never_releases_prepared_items` | Script the three expiration points above. Assert exact deadline result, `unknown` freshness, empty items, first/second manifest presence and completed phases. |

For the deadline RED, first run the external search assertions against the baseline API. When adding the private clock seam, run the scripted assertions with the seam connected and the deadline enforcement still absent. Expect an assertion showing that evaluation proceeded past the selected expired phase or returned prepared data. A compile failure from a missing test seam is not RED evidence. Use an analogous focused transport test for response-size fallback, with a synthetic oversized prepared search result at the server framing boundary. RED is either the old fallback's retained coverage or a failure of the exact fallback shape. Build failure, expired authorization, fixture mismatch and launcher denial do not count as product RED.

In [mcp_stdio_test.py](../../../test/mcp_stdio_test.py), add `ProtocolTest.test_search_text_and_guarded_read`. Leave `TOOLS` at the baseline five for the RED run. Initialize and enter ready state, then submit `search_text` and require an exact tool result. The baseline RED is JSON-RPC `-32602` where the test expects a successful tool envelope. In GREEN, verify the literal new schema, no duplicate inventory entries, and exact baseline descriptors/schemas for the other five. Assert both error layers, the result key sets, `structuredContent`/text equality, first-capture digest and guarded-read bytes. Edit the matched slot between completed calls, assert the exact stale guarded-read state above and re-search to observe the new digest. Verify clean EOF and reaping. Include the new tool in the full six-entry inventory expectation only in GREEN. Preserve baseline lifecycle, expiry, revocation, scope, framing, declaration, references and read tests.

Proposed command allowlist for a future successor grant:

```sh
mix test test/query_test.exs
mix escript.build
python3 test/mcp_stdio_test.py ProtocolTest.test_search_text_and_guarded_read
mix format lib/sf_codeintel/query.ex lib/sf_codeintel/mcp_stdio.ex test/query_test.exs
mix format --check-formatted mix.exs 'lib/**/*.ex' 'test/**/*.exs'
mix compile --warnings-as-errors
mix test
mix escript.build
python3 test/mcp_stdio_test.py
git diff --check
```

Run the focused cases in RED and GREEN. After any refactor, repeat them and the full checks. Retain observed outputs, exit statuses and exact tested revision. Compare the full tracked diff against the accepted base. Pin Linux x86-64, Elixir 1.19.3 and OTP 28.1.1. No dependency acquisition is part of the local command set.


#### Exact capture and deadline assertions

In `search_text_suppresses_results_when_captures_cannot_be_verified`, script the following cases with an ordered successful prefix before the failed slot. An unsuccessful slot is excluded from the checked prefix. A first manifest means both the top-level digest and nested first digest. Each present digest must equal the corresponding completed capture's digest.

| Case | Diagnostic | Checked slots | Manifest keys | Capture calls |
| --- | --- | --- | --- | --- |
| First denial | `slot_type_or_identity` and failed path | First checked prefix | Neither | 1 |
| First unavailable | `slot_open_failed` and failed path | First checked prefix | Neither | 1 |
| First limit | `capture_byte_limit` and failed path | First checked prefix | Neither | 1 |
| Second adapter failure | Script `slot_open_failed` with failed path | Second checked prefix | First only | 2 |
| First or second task exit | `capture_failed` without path | Empty for the failed phase | Neither on first exit, first only on second exit | 1 or 2 respectively |
| Unrelated slot change during revalidation | `capture_changed` without path | All five | Both | 2 |

Assert each row's exact status and flags under §2 and that it exposes no prepared items. In `search_text_deadline_never_releases_prepared_items`, advance the private clock after the completed first capture to expire before scan entry, at a selected scan check after the first capture, and after a successful second capture. Assert `tool_deadline` without path, `unknown` freshness and all five checked slots. The first two cases make one capture and carry only the first manifest. The final case makes two captures and carries both. Assert no scan in the first case, early scan termination in the second, and successful revalidation followed by suppression of prepared items in the third. Exercise precedence over a prepared manifest-change outcome as well. Check exact evidence key sets, timestamp equality, empty items and false truncation in all three cases.

### 5.2 Traceability and phase classification

| Requirement or threat | Enforcement and planned evidence |
| --- | --- |
| CI-R02 and CI-R08, literal static search without target execution | §3 scans raw bytes only. The literal, stable miss and ordered prefix cases verify the scoped profile. The full diff and retained launcher checks verify unchanged execution boundaries. |
| CI-R04 and CI-R13, exact retrieval and stale evidence | §2 evidence feeds guarded read. `ProtocolTest.test_search_text_and_guarded_read` verifies exact bytes, stale digest and renewed digest. The scripted capture failures and unrelated change verify suppression. |
| CI-R06, compact bounded results and explicit gaps | §2 statuses and key sets, 32/33 test, no-progress and prefix assertions, and focused framing fallback verify the result boundary. |
| Unauthorized arguments, root, path or client | §2 validation before capture and retained launch binding in §4. Invalid argument and real MCP error layer assertions plus `test_doctor_and_launch_denials` and `test_scope_and_budget_failures`. |
| Resource exhaustion | §§2–4 caps and deadlines. Invalid argument, ordered prefix, capture limit, deadline and oversized frame tests plus `test_framing_and_request_limits` and `test_server_closes_after_the_hundredth_frame`. Hosted disk evidence under §5.3 verifies each checkpoint and STOP path. |
| Expiry, revocation, stall or unreaped child | §4 watchdog, authority checks and cleanup. `test_expiry_and_revocation_reap_stalled_processes` and normal EOF assertions, plus grant-time equivalence and child limit evidence under §§5.3 and 6. |

[PRD §13](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/product/SF-CI-PRD-001.md#13-product-acceptance-scenarios-and-traceability) scenarios applicable in this slice are PA-02 static access, PA-03 exact spans with predecessor symbol behavior retained, PA-04 bounded results, PA-05 stale evidence and PA-10 synthetic denial and cleanup. Verify them through §§5.1–5.2. PA-14 is exploratory in the P1 pilot with separately ratified workloads. PA-13 has a P1 packaging obligation and a release removal/rebuild check. Defer PA-01 to multi-repository P1, PA-06 to P2/P4, PA-07–08 to P3, PA-09 to P4, Factory PA-10 to P5, PA-11 to P6 and PA-12 to P0-A qualification. Those scenarios need environments, data or capabilities outside this slice.

Architecture §15A G8 applies to scope and evidence, and G14 applies to bounded child, time, sampled disk and cleanup through §§4, 5.3 and 6. G1 is inherited for the synthetic predecessor and deferred for full curated structural evidence. G2 and G4 require later graph and critical-profile evidence. G3 and G5–7 and G11–13 remain exploratory for applicable pilots and require ratified workloads and confirmatory evaluation before product gate claims. The current negative checks exercise the relevant G13 safety subset. G9 snapshot recovery is deferred to persistent snapshot phases. G10 full compatibility, license/SBOM and install/removal/rebuild are release checks. The exact-head real-client check exercises only the declared synthetic client, platform and protocol. No slice assertion substitutes for full P1 or qualification.

### 5.3 Hosted checks

The proposed product allowlist is `lib/sf_codeintel/query.ex`, `lib/sf_codeintel/mcp_stdio.ex`, `test/query_test.exs`, `test/mcp_stdio_test.py`, `README.md` and `.github/workflows/ci.yml`. Use inline fixtures. Document search, truncation, misses and separate observation times in the README. The later grant must expressly cover the workflow.

Python may replace `GRANT`, `GRANT_EXPIRY_NS`, `LOCAL_ROOT` and `LOCAL_IDENTITY` with verified successor values. The only prefix-literal change is the same grant-bound SFCI-19 prefix in the existing Python predicate and workflow. Preserve all other Python fixture predicates in §4. Verify by exact diff and retained scope and launch tests. Verify that the Python nanosecond and workflow UTC-second expiries encode the same authorized instant. Check the exact diff for absence of the private clock from protocol, launch JSON and environment. Its deterministic tests drive the clock through the private seam only.

Restrict workflow changes to the grant-bound branch selector, proposed `sfci-19/synthetic-search-text`, printed grant ID, UTC expiry, allowed attempt, matched prefix, `check_disk` and its affected call sites. An attempt limit of one permits the initial attempt only. A limit of two needs explicit rerun authority. Account for every eligible fresh trigger and retry separately against the total hosted allowance. Preserve public same-repository PR predicates, `opened` and `synchronize` against `main`, repository identity, Ubuntu 24.04 x64, pinned checkout action, no stored credentials, archive URLs and checksums, HTTPS-only acquisition with existing bounds, exact PR head, `within_grant` timeouts, cleanup and final clean tracked-diff checks.

Use `du -s -B1` with pipefail over disjoint generated roots: the entire runner work directory and repository `_build` when present. Count fixture and scratch through the work directory. Label each phase and measure immediately after work-directory creation, after each download and verification, immediately after each extraction while the archive is still present, after OTP installation and after every write-capable format, build, test, verification or escript step. Log the labeled allocated-byte count before comparing with 536870912 bytes. Invalid, unavailable and excess readings must each log the phase and reason and return nonzero before the next work step. Keep the cleanup trap and child reaping. Verify by exact workflow diff and, under later authorization, checkpoint logs and planned negative evidence for each STOP path and cleanup. Sampling can miss transient peaks. A hard ceiling requires separate quota evidence and grant disposition.

## 6. Acceptance, dispatch and change control

Design acceptance requires independent review of the exact proposed documents, traceability under TDD §§2.3, 3 and 5.1–5.2, and a separate accountable disposition of the TDD and the six-tool ADR supplement. Custody and launcher feasibility remain unresolved and block acceptance wherever needed to substantiate safety, compatibility or required tests. The Lead must obtain evidence that the declared transport/platform, trusted launcher, root and scratch custody and sole writer can support these assertions. Record reviewer, actor, authority, exact immutable revision, rationale, conditions, effective time and affected assignments. Material deviation requires renewed exact review and accountable disposition.

The implementation author may choose private scan organization and either an internal observer or pure scanner test to prove early exit. Preserve literal byte order, the exact clock checks, no public seam, bounded memory, exact evidence and all named assertions. The independent reviewer verifies invariants and the Lead resolves changes outside them. Grant values, operator ratification, actual child limits, acquisition and root identities are unresolved operational blockers. Backend selection, structural qualification and full P1 evidence are deferred to their governing phases.

Dispatch is separately blocked until the Lead verifies authority, intervening base changes, ratified operator, actual local and hosted Linux x86-64, Elixir 1.19.3 and OTP 28.1.1, dependencies and acquisition, actual custody and retention, launcher process control and a fresh bounded grant for local and hosted CI. Bind the grant to base, branch, paths, commands, operations, expiry, resources, bootstrap traffic and aggregate triggers and retries. Planning values only are one live service, two normal BEAM schedulers with inherited dirty scheduler and async settings, 512 MiB service `RLIMIT_AS`, up to 60 minutes local elapsed and one exact-head hosted run up to ten minutes. Verify `resource.prlimit` and effective scheduler settings on the actual child. PR #13 supplies no entitlement.

Record persistent worktree and evidence paths before dispatch. Checkpoint RED, GREEN, full regression, hosted checks, resource debits and cleanup. After interruption reconcile Git, live processes, custody, authority and remaining budgets. Stop affected work on base or authority discrepancy, containment or cleanup failure, expiry, revocation, exhausted budgets or unavailable required checks. Retry only after reconciliation under an effective grant with explicit remaining budget. Final integration requires independent exact hosted base/head, complete diff, checks and findings review, then the separate Lead GOV §8 check. This proposal records no runtime, custody readiness, grant, design acceptance or integration decision.
