# SFCI-3 P0-A admission draft

**P0-A: `NOT ADMITTED / NOT RUN`. Qualification clock: `NOT STARTED`.**

This record covers documentation preparation. Host, permission, and ratification evidence is pending. No host inspection, canary check, acquisition, build, qualification, or measurement took place for this draft. SFCI-3 and the independently approved SFCI-4 corpus are prerequisites for SFCI-5 admission. SFCI-6 execution depends on SFCI-5. [SFCI-3][issue] · [SFCI-4][corpus] · [SFCI-5][admission] · [SFCI-6][execution]

## Applicable authority

The SFCI-2 dispositions and activation event establish the effective baseline at `9a7d6192b83bc066168d54ef1d46e40b29dfa144`. PRD v0.1 and architecture v0.4 apply jointly. P0 v0.3 and GOV v0.3 apply under separate adoption decisions. Backend ADR-001 remains Proposed. [Applicability record][adoption-record] · [Accountable dispositions][dispositions] · [Verified activation][activation]

| Source at the pinned base | Git blob |
| --- | --- |
| [Repository instructions][agents] | `d49693823b91b5038ccb7c9c34ad1705ca52e03c` |
| [SFCI-2 applicability record][adoption-record] | `6abcbaeb9fbb9df6dd0d5f8bbcbd2d4a8c4917d3` |
| GOV v0.3 [§4.1][gov-mandate], [§6.1][gov-phases], [§6.2][gov-gate], [§7][gov-routing], [§8][gov-review] | `3dee30660683148184b7a9a52c4db476adc33242` |
| P0 v0.3 [§0][p0-authority], [§1][p0-scope], [§1A][p0-envelope], [§5A][p0-scoring], [§6][p0-stop] | `6ef652088dab7d979d3fb80ff34e7a2962baf6a0` |
| Architecture v0.4 [§03][arch-tools], [§07][arch-snapshot], [§12][arch-security], [§16][arch-roadmap] | `887185154c94cc78e858fe33d853a97e49666e43` |
| [PRD v0.1][prd] | `a10a072b9e6772d300f4be7fa4120efeefd9545f` |

The independent plan review passed 6/6 on the original plan and the exact Plane addendum. The verdict applies to drafting this file. Final candidate review follows GOV §8. [Assignment record][assignment] · [Original plan][plan] · [Exact addendum][addendum] · [Independent PASS][review]

- Original plan item `turn-item:provider:codex:native-item:msg_011fae785fc0ce19016b07d6bd899c87d0858ba903eab7fa8f`.
- Independent PASS item `turn-item:provider:codex:native-item:msg_0b911e92f4cd80a1016b07d827a8b887d0b539363d172d3467`.

## 1. Operator approval and independent reviewer

**Pending.** The Lead Orchestrator records the named execution operator and independent admission reviewer under the standing mandate. Record their designations, approval dates, exact task and evidence revisions, allowed operations and budget. The reviewer verifies admission evidence independently. The designated operator ratifies admission within the verified grant and enforces the limits and cleanup. The Lead Orchestrator checks dispatch eligibility. The mandate is recorded in owner directive item `turn-item:message:ecf61b59-1925-4c56-a5cb-d3e9d7a4c921`, §7. [GOV §4.1][gov-mandate] · [Owner directive][directive] · [Trusted owner authorization event][owner-event]

Host access, preflight, synthetic canary checks, acquisition/build and qualification permissions are pending in the reviewed records. For each applicable grant the Lead Orchestrator verifies the trusted reference, issuer, authorized actor, environment and execution identity, operations, limits, effective period and revocation status. Access or budget expansion beyond the standing mandate goes to the owner. [Preparation record][preparation] · [GOV §6][gov-gate]

## 2. Host, OS and hardware

**Pending.** The reference proposal is a dedicated disposable Linux VM or an equivalently verified isolated Linux environment with 4 vCPU and 8 GiB RAM. Within granted preflight scope, the operator records the actual host ID, isolation mechanism, OS/kernel, architecture, logical CPU count, RAM, disk, versioned toolchain, and evidence that production and shared developer credentials are absent. The independent reviewer verifies the evidence. [P0 §1A][p0-envelope]

## 3. Effective limits

**Pending.** The operator records actual enforcement and descendant coverage. The operator and independent reviewer must ratify all effective ceilings and the specific containment mechanism before any backend installation or qualification execution. They may ratify lower ceilings before execution. Higher ceilings require explicit reauthorization. [P0 §1A][p0-envelope] · [Exact addendum][addendum]

| Resource | Proposed ceiling or mandatory control |
| --- | --- |
| CPU and memory | 4 logical CPUs and 6 GiB RAM aggregate for qualification workers and descendants. Disable or explicitly bound swap. |
| Storage | 15 GiB total writable qualification storage, including clones, indexes, WAL, caches, traces and staging. Retain at most 256 MiB of evidence. Writes are limited to approved scratch and exclude the target application. |
| Processes | 256 tasks/threads in the qualification process group or cgroup, at most two concurrent backend worker trees, and no persistent detached services. |
| Command time | 30 s for ordinary lookups or inspection, 120 s for indexing, export or refresh, and 600 s for separately approved upstream acquisition/build commands. The remaining aggregate budget bounds every deadline. Clean up on timeout. |
| Input and output | 1 MiB per synthetic source file, 20 MiB fixture source total and 16 MiB per raw command/export artifact. Bound AST depth and parsing work where applicable. Reject oversized input or output or record it as unsupported. Silent truncation cannot count as complete evidence. |

## 4. Filesystem and execution boundary

**Pending.** The operator records the OS-enforced sandbox identity, worker credentials, mount and read/write/execute allowlists, symlink and ancestor-path policy, dependency and standard-library paths, per-worktree state, scratch, cache, temporary paths, IPC and inherited descriptors.

Grant-scoped, non-sensitive preflight and harmless synthetic canary checks may establish admission evidence. The independent reviewer verifies the OS controls and observed blocking of out-of-scope reads, writes, execution, network and cross-worktree access. Establish the OS controls and approved read and execute boundaries independently before any backend tests against the fixture. Traces can corroborate enforcement. A sandbox label, timeout, same-UID setup, read-only MCP interface, filtered output or absence of trace events is insufficient.

Use source-only analysis. The current envelope prohibits target or fixture Mix evaluation, compilation, application start, macro execution, arbitrary project evaluation and runtime bridging. Any change requires separately authorized amended scope. [P0 §1A][p0-envelope] · [Architecture §12][arch-security] · [Exact addendum][addendum]

## 5. Network

**Pending.** The operator records enforcement of mandatory analysis egress denial for independent verification. If granted separately, upstream acquisition/build uses a distinct approved stage. Record exact allowed sources, hosts, protocols, pinned artifacts and checksums, dependency policy and staging isolation before relying on it. Report unavailable offline dependencies as blockers. Unrestricted network, private Git access, model/provider access and source transmission are prohibited. P0-A external model expenditure is zero. [P0 §1A][p0-envelope]

## 6. Source and expectations

**Pending.** The SFCI-4 corpus author supplies the immutable fixture revision, canonical fixture manifest hash and expectation/scoring manifest hash for independent approval. The proposal is one disposable synthetic Git repository, at most two isolated worktrees of it and harmless out-of-scope canaries. The proposed corpus is 40 prelabelled cases. The 30–50 range requires ratification before execution. [SFCI-4][corpus] · [P0 §1A][p0-envelope]

Before observing backend results, freeze the corpus, expectations and all §5A scoring rules. The independent reviewer approves labelled expectations and each backend's support classifications. Enumerate every positive, negative and unresolved assertion, including exact identity and arity, paths and ranges, edge direction, scope, expected absence, applicable generation and scoring denominators. Record unsupported coverage in advance. Preserve original results and scoring if the corpus or labels need revision after a run. Obtain separate approval for a new qualification manifest. [P0 §5A][p0-scoring] · [Exact addendum][addendum]

Ratify the proposed thresholds before testing. They require 100% supported exact-definition accuracy, at least 98% supported reference precision and at least 90% recall. Predeclare the proposed 1,200-token map cap with a named local tokenizer. Report reference counts, denominators, unresolved/abstained cases and unsupported coverage separately. A zero or inadequate denominator is `NOT RUN` or `PARTIAL`. If only bytes or characters can be measured, record the limitation and withhold token-cap PASS. [P0 §5A][p0-scoring]

Record the exact immutable materialized inputs, including relevant untracked files, deletions, dependency lock, configuration, runtime/toolchain, backend and extractor versions and extraction policy. Bind backend generations and exports to those bytes. Record live freshness observations separately with manifest ID, timestamp, method, checked scope and observed generation when available. [Architecture §07][arch-snapshot]

During later authorized qualification, the qualification agent records cold/warm, incremental and query latency, peak memory, disk and export size within admitted ceilings. If budget permits, record at least three comparable cold or refresh runs and ten warm exact lookups, with raw samples and workload identity. Record materialization and freshness-check costs separately and end-to-end. These are descriptive measurements for the fixture. [P0 §5A][p0-scoring] · [Exact addendum][addendum]

## 7. Backend pair

**Pending.** Qualification is limited to Dexter and Dexterity plus the direct-source baseline. The operator records one compatible pinned primary pair and at most one justified pinned fallback pair. Verify exact source and binary hashes, lock and toolchain compatibility, platform and API versions, licenses and redistribution evidence, SBOM, reproducible build procedure, schema coupling and export identity before relying on backend evidence. A fallback used for recovery counts toward the recovery budget. Alternative backends require a separate assignment. [P0 §1A][p0-envelope] · [Architecture §03][arch-tools]

## 8. Cleanup and evidence

**Pending.** The operator records a named cleanup owner and approved procedure for deadline or STOP termination of the entire worker tree, daemon/socket and IPC cleanup, scratch/cache removal, shutdown or quarantine, and sanitized checksummed evidence retention. The independent reviewer confirms that all launched processes have stopped and disposable state was removed or retained only as authorized evidence within 256 MiB. Report unresolved cleanup as a failure. Unverified cleanup prevents a positive security verdict. [P0 §1A][p0-envelope] · [P0 §5A][p0-scoring] · [P0 §6][p0-stop]

## 9. Admission decision

**`NOT ADMITTED / NOT RUN`.** At SFCI-5, resolve all nine fields, obtain independent verification and designated operator ratification, and verify an effective bounded grant before dispatching SFCI-6. The pre-installation ratification in field 3 and the pre-test containment verification in field 4 apply. The Lead Orchestrator records the trusted decision and verifies the prerequisites. [P0 §1A][p0-envelope] · [GOV §6][gov-gate] · [SFCI-5][admission] · [Exact addendum][addendum]

P0-B is `NOT RUN`. Its separate grant and accountable deferral decision are pending. If the applicable P0 gate proceeds without P0-B, the accountable authority must explicitly defer it to P1. Explicit deferral does not block P0-A completion. P1 dispatch requires the applicable P0 exit, an accepted viable backend decision, an independently reviewed and accepted P1 design, and a bounded P1 grant. [GOV §6.1][gov-phases] · [Architecture §16][arch-roadmap]

## Qualification clock and STOP rules

The first authorized acquisition, build or qualification command starts one 120-minute wall-clock budget across agents, sessions, descendants and fallback attempts. The operator records the start event, timestamps, elapsed time and recoveries. Stop new work at minute 105. Reserve the final 15 minutes for termination, cleanup and a partial report. Allow at most two targeted diagnostic or recovery attempts per upstream blocker and six overall, including fallback recovery. Budget resets and silent extensions are prohibited.

Stop affected work on missing, revoked or conflicting authority, missing admission for qualification, unfrozen or unapproved fixture expectations, unverifiable containment or cleanup, unauthorized access, execution, network use or cost, containment failure, any envelope violation, or exhausted time or recovery limits. Terminate the full worker tree and quarantine affected artifacts where applicable. If cleanup overruns the budget, invoke the approved shutdown or quarantine procedure and report the failure. Record unresolved blockers and unrelated defects in the qualification report or an explicitly authorized tracker.

Stop qualification once its outputs and proposed ADR are complete. Upstream repairs, dependency upgrades, unrelated service startup, production changes or implementation, and P1+ work are outside the envelope. [P0 §1A][p0-envelope] · [P0 §6][p0-stop] · [GOV §6][gov-gate]

[agents]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/AGENTS.md
[adoption-record]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/governance/sfci-2-baseline-adoption.md
[gov-mandate]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/governance/SF-CI-GOV-001.md#41-standing-owner-directive
[gov-phases]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/governance/SF-CI-GOV-001.md#61-phase-navigation
[gov-gate]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/governance/SF-CI-GOV-001.md#62-p0-a-admission-blockers-and-next-steps
[gov-routing]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/governance/SF-CI-GOV-001.md#7-agent-entry-point-and-assignment-routing
[gov-review]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/governance/SF-CI-GOV-001.md#8-verification-independent-review-and-merge-boundary
[p0-authority]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/qualification/SF-CI-P0-001.md#0-qualification-authority-and-document-governance
[p0-scope]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/qualification/SF-CI-P0-001.md#1-objective-and-boundaries
[p0-envelope]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/qualification/SF-CI-P0-001.md#1a-execution-envelope-and-admission-record-ci-f15
[p0-scoring]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/qualification/SF-CI-P0-001.md#5a-predeclared-fixture-expectations-and-p0-pass-conditions
[p0-stop]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/qualification/SF-CI-P0-001.md#6-stop-conditions
[arch-tools]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/architecture/SF-CI-SPEC-001.md#03--technology-stack-and-qualification
[arch-snapshot]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/architecture/SF-CI-SPEC-001.md#07--persistence-snapshot-identity-and-refresh
[arch-security]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/architecture/SF-CI-SPEC-001.md#12--security-and-trust-model
[arch-roadmap]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/architecture/SF-CI-SPEC-001.md#16--implementation-roadmap-and-work-packages
[prd]: https://github.com/Carpe-Diem-Media/sf-codeintel/blob/9a7d6192b83bc066168d54ef1d46e40b29dfa144/docs/product/SF-CI-PRD-001.md
[issue]: https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/bdb1e5e7-f4df-4d26-b94d-feca40f5c41b
[preparation]: https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/bdb1e5e7-f4df-4d26-b94d-feca40f5c41b#comment-d83304ba-da32-46eb-8d69-22cbb06d5f97
[assignment]: https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/bdb1e5e7-f4df-4d26-b94d-feca40f5c41b#comment-bc7a4e11-81b0-45d8-8f56-e24976ebe700
[addendum]: https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/bdb1e5e7-f4df-4d26-b94d-feca40f5c41b#comment-7d344632-e085-4101-9639-5eddbb3cb12d
[corpus]: https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/899d7e05-11ef-4b1b-aaa7-499a44dc370f
[admission]: https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/d658fe4a-3473-4231-bd0a-0f5cc77e7251
[execution]: https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/31a5cb81-4d06-4ffe-b77e-e36cf535933e
[dispositions]: https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/758bc9f3-fb7e-4974-ac35-fbe4e760b280#comment-0b429715-1e42-45f6-91be-4fdaff5ca689
[activation]: https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/758bc9f3-fb7e-4974-ac35-fbe4e760b280#comment-92671d6a-1ed6-44b6-af5f-f09e84ed897c
[owner-event]: https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/758bc9f3-fb7e-4974-ac35-fbe4e760b280#comment-6fb273b0-ae84-4ba7-a9a2-07251faef323
[directive]: t3-thread://v2/fdfd1f03-53cf-41e7-8d37-6f5313c72d55/2211b596-9b80-4ba4-b4fd-5343f5000a87
[plan]: t3-thread://v2/fdfd1f03-53cf-41e7-8d37-6f5313c72d55/thread:delegated-task:command%3Amcp%3Ad061fd9d-b466-4644-b991-9c4669c7e6bf%3Adelegate-task%3A4d09c5e6-89ba-4751-8dc7-a3307158814c
[review]: t3-thread://v2/fdfd1f03-53cf-41e7-8d37-6f5313c72d55/thread:delegated-task:command%3Amcp%3Ad061fd9d-b466-4644-b991-9c4669c7e6bf%3Adelegate-task%3A0c92a0b4-cd0f-4160-8a30-92d2c91f131f
