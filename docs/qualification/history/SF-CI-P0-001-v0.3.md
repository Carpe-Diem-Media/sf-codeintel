# SF CodeIntel
## P0 Qualification Specification and Bounded Agent Assignment

| Document control | Value |
|---|---|
| Document ID / Task ID | SF-CI-P0-001 |
| Revision | 0.3 — Standalone qualification and execution authority (proposed document separation) |
| Date | 25 November 2026 |
| Intended repository path | `docs/qualification/SF-CI-P0-001.md` |
| Governing scope | P0 qualification, execution admission, limits, required evidence, scoring, deliverables and STOP conditions |
| Status | Proposed revision; P0-A approved in principle by supplied independent review, but execution NOT ADMITTED. P0-B and P1+ not authorized. |
| Reviewed baseline | SF-CI-P0-001 v0.2.1 and SF-CI-SPEC-001 v0.2.1 |
| Proposed companion authorities | SF-CI-PRD-001 v0.1 and SF-CI-SPEC-001 v0.3 |
| Backend adoption / implementation / release authorization | None granted by this document |

> **Index broadly. Retrieve selectively. Verify precisely. Execute securely.**

## 0. Qualification authority and document governance

### 0.1 Purpose and ownership

This document governs **how P0 is admitted, executed, scored, stopped and reported**. It is both a qualification specification and the bounded assignment for the P0 agent. The objective is to obtain evidence for a technical decision, not to implement the architecture or prove product value prematurely. The qualification task may be completed with a negative backend verdict.

| Artifact | Owns | Boundary for this assignment |
|---|---|---|
| SF-CI-PRD-001 | Product purpose, outcomes, capabilities, scope and acceptance scenarios | Does not select Dexter/Dexterity or prescribe P0 execution permissions |
| SF-CI-SPEC-001 | Technical architecture, invariants, security boundaries, Q0 strategy, technical gates and phase dependencies | Does not independently admit P0 or override its narrower execution envelope |
| SF-CI-P0-001 (this document) | P0-A/B separation, admission, permitted scope, budgets, fixture and scoring requirements, deliverables, STOP conditions and next-gate reporting | Does not redefine product obligations, waive architecture/security constraints, accept ADRs or authorize later phases |
| Approved admission record and frozen fixture manifest | Actual environment, effective limits, permissions, pinned inputs and predeclared assertions for a particular run | Must satisfy this specification; cannot unilaterally expand its limits or change the scoring rules |
| ADR-001 and applicable accepted ADRs | Specific technical decisions and rationale | P0 produces a proposed ADR-001; a proposed or accepted ADR alone is not permission to execute P1 |
| Phase-specific detailed technical designs (TDDs) | Exact implementation contracts for the relevant phase | No production TDD implementation belongs to P0 |
| Qualification evidence and independent review | Observed results, category verdicts, unresolved findings and gate recommendations | Cannot retrospectively change expectations, authorize subsequent phases or certify untested capabilities |

Authority is scoped, not an unconditional document hierarchy. All applicable security and execution constraints must hold simultaneously. When clauses conflict, stop the affected operation, record exact document identifiers, revisions and clauses, and request an accepted clarification from the responsible authority. Missing permission means the operation is not permitted. Neither a newer document nor a successful test overrides an applicable constraint.

### 0.2 Adoption and revision control

The existing SF-CI-P0-001 v0.2.1 remains the qualification baseline until this proposed revision is explicitly accepted. The proposed PRD v0.1 and architecture v0.3 must be accepted together before their separated product and technical authorities replace the combined architecture v0.2.1. Record the exact adopted revisions and the qualification revision in the admission record; do not assume acceptance from a file name or a download. References in the proposed PRD and architecture to SF-CI-P0-001 v0.2.1 identify their source baseline; explicitly record adoption of this successor if approved. If any separation is not accepted, the existing applicable reviewed baseline remains in force and no execution restriction is lifted.

The document revision lifecycle follows SF-CI-PRD-001 §1.3 upon its acceptance. Proposed amendments do not change accepted authority; accepted replacements explicitly supersede previous revisions; rejected, withdrawn, superseded and revoked revisions remain historical records. This is documentation governance, not authorization to build a workflow engine.

### 0.3 P0 authorization and interpretation

- P0-A is approved in principle only. Actual execution requires the completed, ratified admission record in §1A. Host access and acquisition/preflight require their own approved scope as described there.
- P0-B is a separately authorized exploratory agent experiment, conditional on safe access and sufficient basic correctness. If not authorized, record NOT RUN and explicit deferral to P1; absence of P0-B is not a P0-A failure (CI-F14).
- The §1A execution envelope governs P0-A. In particular, target and synthetic fixture code execution/compilation are prohibited under the current envelope. An amended authorization is required to change that restriction; approval to build the upstream tools is not target execution approval. Synthetic source edits, renames, deletions and conflicting worktree contents are permitted only as admitted fixture preparation or test stimuli under §§1A–2; this does not authorize changes to private or production applications.
- The ceilings and thresholds in §§1A and 5A are inherited proposals requiring ratification before execution. No changes to these budgets or pass criteria are introduced by this revision. General product targets and architecture G1–G14 are not automatically P0 pass criteria.
- Approval to run qualification, completion of qualification, a positive backend recommendation, ADR acceptance, P1 implementation authorization and release approval are distinct decisions. No automatic promotion is permitted.

### 0.4 Traceability to the separated authorities

This mapping is a navigation aid, not new P0 scoring criteria. References to the proposed PRD and architecture become applicable upon coordinated adoption. The exact assertions and thresholds remain those ratified under §§1A and 5A.

| Qualification concern | This document | Product / architecture reference |
|---|---|---|
| Source-only operation and no unauthorized execution | §§1–2, 5A, 6 | CI-R02, CI-R08; PA-02; architecture §§05A, 12, Q0 |
| Exact definition and reference evidence | §§2, 5–5A | CI-R03, CI-R04; PA-03; architecture §§05–06, Q0 |
| Refresh, generation identity and honest freshness | §§2, 5A | CI-R07, CI-R13; PA-05; architecture §§07, 11A |
| OS containment, isolated worktrees and cleanup | §§1A–2, 5A–6 | CI-R04, CI-R08, CI-R11; PA-10; architecture §§12–13, Q0 |
| Structural reuse and single ownership | §§2, 4–5A, 7 | CI-R14; PA-12; architecture §§02–03, 16 |
| Optional agent value measurement | §§3, 5–5A, 7 | PA-14 (exploratory only); architecture §§08A, 15–16 |
| Qualification envelope and sequencing | §§1A, 3, 6–7 | CI-F14, CI-F15; architecture §§16, 18 |
| Materialization/freshness-check cost | §§2, 5A | CI-F20; architecture §§07, 14–15 |

Full Ash semantics, authority completeness, compiled bridge, production lifecycle machinery and confirmatory agent-economic gates remain future work. P0 evidence for a mapped scenario is not acceptance of the full product requirement.

---

The following §§1–7 preserve the reviewed qualification assignment from v0.2.1 verbatim. Read them with the authority and admission clarifications above.

## 1. Objective and boundaries

Determine whether Dexter and Dexterity can be reused as the generic structural intelligence foundation. Establish whether a thin task-context layer is worth pursuing. Do not build the production CodeIntel service, custom graph engine, language server, persistent Ash control plane, embeddings, or Factory integration.

Use one approved disposable synthetic Elixir/Ash fixture only (multiple worktrees of that fixture are allowed for isolation checks). Private or additional target repositories are outside this envelope and require a separate amended authorization. Do not modify target application code, upgrade its dependencies or execute its code. Synthetic fixture execution, tool installation/build and dependency acquisition require explicit permitted environment and network policy; separate tool build from target analysis. If compiled Ash evidence becomes necessary, record a follow-up requiring separate authorization, rather than starting the application.

## 1A. Execution envelope and admission record (CI-F15)

The following are **proposed hard ceilings**, not a claim about the actual host or permission to use it. The operator and independent reviewer must ratify them and the specific containment mechanism before any backend installation or qualification execution. A smaller environment may lower ceilings before the run; a higher limit requires explicit reauthorization, not an automatic retry. No budget resets across fallback revisions, subprocesses or recovery attempts.

| Constraint | Proposed ceiling / policy |
|---|---|
| Target | One disposable synthetic Git repository; at most two isolated worktrees of that repository for conflicting definitions, plus harmless out-of-scope canaries |
| Fixture corpus | 40 prelabelled cases; permitted range 30–50 only if ratified before execution |
| Candidates | Dexter and Dexterity only; one pinned primary compatible revision pair plus at most one justified pinned fallback pair |
| Total elapsed execution | 120 minutes from first acquisition/build/qualification command; stop new work at 105 minutes, reserve final 15 minutes for termination, cleanup and partial report |
| Recovery | At most two targeted attempts per blocker, six across the entire run; a fallback attempted to recover from a failure counts toward this limit |
| Host | Dedicated disposable Linux VM or equivalently verified isolated Linux environment; record exact OS/kernel, architecture, toolchain and sandbox mechanism; no production or shared developer credentials |
| CPU / RAM | Reference host proposed: 4 vCPU, 8 GiB RAM; aggregate qualification worker limit 4 logical CPUs and 6 GiB memory (including descendants); swap disabled or explicitly bounded; record actual enforced values |
| Disk | At most 15 GiB total writable qualification storage, including clones, dependency/build caches, indexes, WAL, traces and staging; no writes to target application or host paths outside approved scratch; at most 256 MiB retained evidence |
| Processes | At most 256 tasks/threads in the qualification process group or cgroup; at most two concurrent backend worker trees; no detached persistent services |
| Per-command deadlines | 30 s for ordinary lookups/inspection; 120 s for indexing/export/refresh; 600 s for separately approved upstream acquisition/build commands. All deadlines subject to remaining aggregate budget; cleanup on timeout is mandatory |
| Input/output limits | Maximum 1 MiB per synthetic source file, 20 MiB fixture source total, 16 MiB per raw command/export artifact; bound AST nesting/work where applicable; oversized results are rejected or recorded as unsupported, never silently truncated and scored as complete |
| Network | Denied during target analysis. Optional upstream tool acquisition/build in a separate approved stage using exact pinned artifacts and explicitly allowed hosts/protocols; no unrestricted network, no private Git access, no model/provider access. If offline dependencies unavailable, report blocker |
| Target execution | Prohibited: no fixture or target Mix evaluation, compilation, application start, macro execution, arbitrary project eval, or runtime bridge without separately authorized amended scope. Upstream tool build/test in a separate approved environment is not authorization to execute target code |
| External model expenditure | Zero P0-A; no model API experiment or source transmission |
| Production implementation | Prohibited: no production gateway, control plane, application changes, Redis, PubSub, custom graph engine, new caching, embeddings, or upstream repair |

### Admission record (must be completed and approved before dispatch)

Record the following in `benchmarks/results/p0/admission.md`, with immutable manifest/checksum references. The preparer may draft the record and prepare synthetic fixture source and expected assertions without executing target code, but cannot self-authorize missing permissions or change the acceptance criteria after seeing results. Preparing the admission record is distinct from admitted backend execution. Any acquisition or host preflight requires its own approved access scope; the first authorized acquisition/build/qualification command starts the aggregate clock.

| Field | Required actual value / evidence |
|---|---|
| Operator approval and independent reviewer | Named accountable approvals, date, task revision, allowed operations and budget |
| Host / OS / hardware | Host identifier, isolation type, kernel/architecture, logical CPUs, RAM, disk and toolchain versions |
| Effective limits | Actual enforced CPU, memory, swap, storage, process/thread, timeout and output ceilings; verify limits cover descendants |
| Filesystem and execution boundary | Approved sandbox identity, mount/read/write allowlists, symlink policy, target no-execution controls, process credentials and IPC/cache paths |
| Network | Denied analysis network; if acquisition is authorized, exact allowed sources/hosts, pinned input identities and separate staging policy |
| Source and expectations | Fixture revision/content hashes, independently reviewed expected results, support classification, negative-case expectations and frozen scoring criteria |
| Backend pair | Pinned primary revisions and lock/toolchain compatibility; any fallback must be pinned and explicitly justified before testing it |
| Cleanup / evidence | Owner, process-tree termination procedure, quarantine and artifact retention policy; confirm no unauthorized state survives |
| Admission decision | ADMITTED only if all fields are resolved and approved; otherwise NOT ADMITTED / NOT RUN |

Perform non-sensitive environment preflight and synthetic canary checks only as authorized. Tracing is evidence, not containment. A sandbox name, process timeout, same-UID configuration, read-only MCP surface, or filtered output is not proof of isolation. Do not execute backend tests against the fixture until the OS controls and approved read/execute boundaries are independently established. Do not claim the host has the proposed resources until measured. If safe containment or cleanup cannot be established, stop and report.

## 2. P0-A — backend qualification (first assignment)

1. Pin exact Dexter and Dexterity revisions/releases, license texts, checksums, build/runtime/toolchain identity and public interface versions. Record the exact compatible pair, if any. Review transitive licenses and schema dependencies; do not assume compatibility or redistribution rights.
2. Inspect pinned implementations for daemon startup, path resolution, filesystem discovery, dependencies/stdlib, cache and IPC ownership, external subprocesses, formatting/rename/reindex, macro expansion/evaluation and network behavior. Establish OS-level confinement before giving tools access to any sensitive repository. Run with a disposable workspace, approved inputs only, no inherited production credentials, bounded resources and separate backend state. Prove process-tree termination and cleanup. Use harmless synthetic canaries outside the allowed mount; do not use real secrets to test isolation.
3. Verify the frozen, independently labelled fixtures cover exact definitions, alias/import scopes, default arities, multi-clause functions, delegates, generated-interface gaps, umbrella duplicates, dynamic calls, broken source, file deletion and rename. Include explicit Ash DSL and small HEEx/SQL/config examples. Expected results must distinguish resolved, candidate, unresolved, and unsupported.
4. Run `rg` and direct source reads as a baseline; compare documented Dexter commands and Dexterity APIs at the pinned revisions. Use existing supported interfaces before reading internal storage. Inspect structural exports, ranking, repo-map token budgets, reference direction, impact queries and snapshot/generation behavior. If a stable generation is unavailable, test a frozen input materialization or record the gap. A source capture is not necessarily an atomic live-worktree view.
5. Test separate disposable worktrees containing conflicting definitions and a deleted symbol; attempt unauthorized reads and stale-cache reuse. Record observed filesystem operations, process identity, cache isolation, and cleanup. Test at least one concurrent modification while reading, distinguishing snapshot integrity from freshness at check time. Do not claim strong isolation solely from filtered responses or same-UID configuration.
6. Measure cold/warm indexing and lookups, refresh, peak memory, disk including WAL/cache/staging, export size, compact result size and tool calls. Record hardware, repetitions, actual commands, exit codes, stdout/stderr artifacts or sanitized digests. Treat all upstream figures as unverified until reproduced. Do not add caching or optimize based on one run.
7. Produce backend decision: reuse, wrap/extend, or reject. Recommend one structural owner and explain the minimum necessary duplication; document supported contracts, version coupling, invalidation and unresolved semantic gaps. Expert/ElixirLS comparison is a separate bounded follow-up if decision risk or compiler-coverage gaps justify it.

## 3. P0-B — optional agent value experiment (separately authorized)

Only proceed if P0-A establishes safe access and sufficient basic correctness for the intended test. If not, mark blocked. Use a disposable script or existing MCP, not a production gateway; no target compilation or arbitrary execution. If the trial is not approved, carry it into P1 and do not claim agent benefits.

- A: normal direct source discovery; B: same discovery with improved guidance/UsageRules; C: B + Dexter; D: C + Dexterity; E: D + minimal bounded task-context response. Use identical instructions between matched arms except for the deliberate intervention. Keep direct source verification available in all arms.
- Use a small independently labelled set of discovery tasks, including simple tasks where indexing adds no value, Ash action and policy discovery, missed/generated references, and abstention. Use actual authorized client/model combinations and record versions/settings. Run matched trials with order randomized and report uncertainty. The pilot estimates benefit and variance; it does not establish confirmatory non-inferiority.
- Measure correctness of the returned evidence, critical omissions, tokens to first useful evidence, tool calls, actual client/session tokens and cost where observable (including schemas, output wrappers and repeated context). Record unavailable metrics explicitly. Compare compact text and JSON only if this can be done within the approved pilot budget. No model API calls or private source transmission without specific approval.

## 4. Outputs

- `docs/qualification/P0-backend-verdict.md`: decision, category results, exact environment and revisions, evidence paths, limitations, and next gate.
- `docs/adr/ADR-001-backend-selection.md`: **proposed**, not accepted; structural ownership and compatibility contract, alternatives, risks and decision evidence.
- `benchmarks/corpus/p0/`: disposable fixtures and independently reviewed expectations.
- `benchmarks/runners/p0/`: minimal reproducible scripts, approved commands and bounded execution.
- `benchmarks/results/p0/`: raw/sanitized results, manifests, hashes, run IDs, command/exit records, resource measurements, and optional P0-B results. No secrets or unauthorized private source in committed results.

## 5. Qualification matrix

| Category | Required evidence |
|---|---|
| Reproducibility | Exact revisions, environment, commands, checksums, dependencies and license review |
| Correctness | Expected vs observed definition/reference/arity/alias results, unresolved categories |
| Dexterity reuse | Actual structural export, repo map, ranking, impact and generation behavior |
| Framework gap | Explicit Ash DSL vs generated/effective metadata limitations |
| Refresh | Edit/rename/delete, invalid source, stale evidence labeling |
| Security | OS confinement, no unauthorized access or execution, independent worktree state, bounded cleanup |
| Performance | Cold/warm and incremental latency, memory, disk, output size with workload and uncertainty |
| Agent value | P0-B only: paired exploratory evidence; otherwise not run/blocked |
| Decision | Reuse/extend/reject with supporting artifacts; no duplicate structural engine without justification |

For each category report PASS, PARTIAL, FAIL or NOT RUN, with evidence references and blockers. PASS applies only to the declared scope; missing evidence cannot be PASS. A material isolation failure blocks further backend use with private repositories. A partial benchmark is not proof of benefit or approval of subsequent phases.

## 5A. Predeclared fixture expectations and P0 pass conditions

Freeze the fixture corpus, expected evidence and scoring manifest **before** observing backend results. An independent reviewer must approve the labelled expectations and support classification for each backend capability. The proposed allocation below totals 40 cases. Cases may contain multiple assertions; every expected positive, negative and unresolved reference must be enumerated, not just the number of cases. Record exact identifiers/arity, paths/ranges, edge direction, scope, expected absence and applicable generation. Do not redefine a failed supported feature as unsupported after running the test. Unadvertised or deliberately out-of-scope features may be marked unsupported in advance and remain visible in the report.

| Cases | Fixture category | Minimum expected behaviour |
|---:|---|---|
| 8 | Exact definitions, clauses, default arities | Correct qualified identity, arity, location; distinguish clauses and generated default exports as supported |
| 6 | Alias, import, delegate and behaviour references | Correct scope and direction; no incorrect resolved target |
| 4 | Umbrella and duplicate module identity | Correct application/workspace association or explicit ambiguity; never falsely resolve a duplicate |
| 4 | Dynamic calls and generated interfaces | Resolved only with evidence; candidate/unresolved/unsupported must not be presented as exact |
| 4 | Ash DSL, HEEx, SQL and config | Find explicit source through supported structural or lexical interface; distinguish generated/effective metadata gaps |
| 5 | Edit, delete, rename and broken source | Remove obsolete live results; preserve explicitly historical evidence only; report degradation |
| 3 | Structural export, ranking and impact | Correct graph directions, expected reachable/direct symbols, bounded map and reproducible export identity |
| 3 | Generation and concurrent mutation | Frozen capture reproducible; live freshness observation honest; no mixed-generation claims |
| 3 | Containment, worktree separation and cleanup | Negative canaries inaccessible; no cross-worktree state reuse; no forbidden execution/network; all descendants stopped |
| **40** | **Total** | **Every case receives an independently reviewed expected-result record.** |

### Scoring and required thresholds (proposed; ratify before testing)

| Category | PASS condition |
|---|---|
| Reproducibility | All executed runs identify pinned input/backend revisions, dependency/toolchain identity, exact commands, checksums, exit records and fixture expectation version; license/redistribution and transitive schema risks documented. Missing license or redistribution permission blocks any recommendation that assumes it. |
| Exact lookup | 100% of predeclared supported exact-definition assertions correct, including identity/arity and verifiable location; missing, wrong or ambiguous results count as failures unless ambiguity was expected. |
| Supported references | At least 98% precision and 90% recall over independently labelled supported reference assertions (TP / (TP+FP), TP / (TP+FN)); report raw counts, unresolved/abstentions, denominators and unsupported coverage separately. No unsupported claim of exact resolution. A zero or inadequate denominator is NOT RUN/PARTIAL, not PASS. |
| Structural reuse | Required public operations (definition/reference, structural export, bounded repo map, ranking, impact) produce results matching the frozen fixture expectations; returned graph ownership, version coupling and generation binding established. Predeclare a model-facing map cap (proposed 1,200 tokens using a named locally available tokenizer; if only bytes/characters can be measured, report that limitation and no token-cap PASS). No assumed coverage from an API name. |
| Framework gaps | All declared source-only Ash/HEEx/SQL/config expectations scored, and generated/effective Ash limitations explicitly distinguished; no target evaluation to fill missing data. Missing non-advertised framework semantics does not alone reject generic structural reuse. |
| Refresh and generation | Every supported edit/rename/delete and isolation case passes; stale/deleted symbols not presented as current, ambiguous/incomplete captures explicitly labelled. Frozen input identity and live freshness checks documented. Zero observed mixed-generation claims. |
| Security | Every applicable positive/negative containment assertion passes with OS-enforced boundaries, independently observed no unauthorized read/write/execute/network access, no cross-worktree leakage, and complete descendant/IPC/cache cleanup. Containment failure, unauthorized operations, or unverified cleanup prevents positive security qualification. Never infer safety solely from an absence of trace events. |
| Performance | Record cold/warm, incremental and query latency, peak memory, disk and export size within admitted ceilings; at least three comparable cold/refresh runs and ten warm exact lookups if budget permits, with raw samples and workload identity. Include materialization and freshness-check cost separately and end-to-end (CI-F20). Descriptive only for a small fixture; no claim of statistically stable p95 or production SLA. Proposed reference targets from specification remain unproven. |
| Agent value | NOT RUN / explicitly deferred to P1 unless separately approved P0-B; no model-cost, token-saving or productivity claim based on static output size alone. |
| Decision | Evidence-backed reuse/wrap/extend/reject ADR; assign exactly one structural owner or record unresolved ownership. No positive production adoption or P1 authorization. |

A PASS verdict is bounded to the tested operation and inputs; it is not a certification of the backend. The full P0-A exercise can finish with a negative decision, PARTIAL or FAIL. A positive reuse recommendation requires passing the necessary supported correctness, structural/generation and security categories; otherwise propose narrowly scoped remediation, alternate backend qualification or rejection. NOT RUN is appropriate for intentionally deferred or unexecuted tests. Record performance limitations without inventing measurements. If the corpus or labels need revision after a run, preserve the original results and request separate approval for a new qualification manifest; do not retroactively alter the scoring rules.

## 6. Stop conditions

- Stop on unapproved code execution, data access, network use or cost; stop on containment failure and quarantine affected artifacts.
- At most two targeted diagnostic/recovery attempts per upstream blocker and six total, including fallback recovery; record unresolved blocker and do not rewrite the tool to make qualification pass.
- Stop new work at 105 minutes and on any resource, time, fixture, revision, process, output, network or other envelope violation. Terminate the entire worker tree and use the reserved cleanup/report period; if cleanup exceeds the budget, invoke the approved containment shutdown/quarantine procedure and report the failure. No silent extension or budget reset.
- STOP if admission is missing, fixture expectations are not frozen/approved, or the containment/cleanup mechanism cannot be verified. Do not treat partial evidence as a positive security result.
- Stop when the qualification outputs and proposed ADR are complete. No P1+ implementation, no production application changes, no unrelated service startup or dependency upgrades.
- Record unrelated defects separately in the qualification report (or an explicitly authorized issue tracker) without expanding scope.
- Confirm all launched processes are terminated and disposable state is removed or retained only as authorized test evidence. Report any cleanup failure as unresolved.

## 7. Gate decision and independent review

The independent reviewer verifies the exact candidate implementation diff (if any), CI, pinned tool sources and all applicable approved authorities before recommending a merge. P0-A may close with reproducible evidence and a proposed reuse/extend/reject decision, with P0-B separately authorized or explicitly deferred to P1. P0-B absence is not a P0-A blocker (CI-F14). P0 results may recommend P1, a limited follow-up qualification or stopping the project. They cannot authorize P1, a production deployment, backend adoption or a claim of token savings by themselves. A real-agent pilot is not a statistically powered release gate; ratify the later non-inferiority margin, sample size, security criteria and cost targets separately.


---

## 8. Authority separation and revision record

### 8.1 Source artifacts

| Document | Exact revision | Role |
|---|---|---|
| SF-CI-P0-001 | 0.2.1 | Original qualification assignment; §§1–7 retained verbatim |
| SF-CI-SPEC-001 | 0.2.1 | Existing reviewed combined architecture and product baseline |
| SF-CI-PRD-001 | 0.1 (proposed) | Standalone product authority candidate |
| SF-CI-SPEC-001 | 0.3 (proposed) | Standalone technical architecture authority candidate |

SHA-256 values for the source artifacts inspected during this revision. These hashes identify files, not signatures, approvals or verified execution evidence.

```text
b35b92081956fffc7f50ef973afa9591da3e5aef291254af82f12f9db9c2a2ce  SF-CodeIntel-P0-Qualification-v0.2.1.md
eec236699730173e0612bd9bfbe6d100f417119c3efe3397de2ad24905b85ced  SF-CodeIntel-Specification-v0.2.1.md
f5374a4de6e6c021334e4965c25bb0dfe4ddf5d7671bbd007412e5a497c56a30  SF-CI-PRD-001-v0.1.md
5c7f7712b86638075c280fd236b9958c2973df7979a8b273809933e38341424e  SF-CI-SPEC-001-v0.3.md
```

### 8.2 Revision history

| Revision | Change | Status |
|---|---|---|
| 0.2 | Bounded P0-A qualification and separately authorized P0-B assignment | Historical |
| 0.2.1 | Admission record, execution envelope, fixture allocation and predeclared scoring (CI-F14/F15) | Existing qualification baseline; admission outstanding |
| 0.3 | Standalone authority and adoption rules, interpretation and cross-document traceability; qualification body unchanged | Proposed; independent acceptance pending |

### 8.3 Outstanding decisions and next gate

- Independently review and accept this exact revision and its relationship to the applicable product and architecture revisions. No independent acceptance of the authority split is evidenced here.
- Complete §1A admission with actual approved host, enforced resource limits, containment and cleanup evidence, approved tool/input acquisition, pinned backend revisions, frozen fixture expectations and scoring rules. Proposed ceilings are not a claim about the actual environment.
- Only after admission, execute P0-A under its bounded assignment. Report PASS, PARTIAL, FAIL or NOT RUN per category; retain exact evidence and a proposed ADR-001, even if the recommendation is rejection or follow-up qualification.
- CI-F16–CI-F19 and CI-F21 remain assigned to the future gates specified in architecture §18. CI-F20 contributes measurements in P0/P1 only; no optimization implementation is authorized here.
- No upstream tool installation, source audit, fixture execution, benchmark, private repository access, Factory integration, dependency selection or implementation was performed for this document revision. No actual environment, admission or test result is supplied by this document.

**End of SF-CI-P0-001.**
