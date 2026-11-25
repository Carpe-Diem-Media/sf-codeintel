# ADR-001 — Generic Language and Structural Backend Selection

| Document control | Value |
|---|---|
| ADR ID | ADR-001 |
| Proposal revision | 0.1 |
| Date | 25 November 2026 |
| Status | Proposed — pre-qualification; no backend selected |
| Decision key | `structural_backend_ownership` |
| Intended repository | `sf-codeintel` |
| Intended canonical path | `docs/adr/ADR-001-backend-selection.md` |
| Proposer | Draft prepared for project owner; accountable submitting identity pending |
| Decision owner / acceptance authority | Pending designation under SF-CI-ADR-001 |
| Scope | Generic Elixir language indexing, structural graph/ranking reuse, ownership, generation binding and integration boundary |
| Phase applicability | P0-A informs this decision; an accepted selection may inform the separately authorized P1 design |
| Dependencies / supersedes | Applicable accepted product, architecture and qualification baseline; no predecessor ADR |
| Execution authorization | None. P0-A admission and all subsequent work require separate approval. |

> **Decision deferred pending evidence.** Dexter and Dexterity are the leading candidates to qualify, not approved production dependencies. This is a pre-qualification decision record, not the evidence-backed ADR deliverable required at the conclusion of P0-A.

## 1. Context and decision question

SF CodeIntel is intended to provide compact, source-grounded and framework-aware evidence to coding agents across authorized Elixir, Phoenix and Ash repositories. It should reuse existing language intelligence rather than develop a general-purpose language server or duplicate a structural engine unnecessarily.

The decision to be made is:

**Which smallest qualified backend combination should own generic symbol indexing, structural graph construction, graph traversal, ranking, invalidation and generation identity for the initial CodeIntel implementation?**

The architecture identifies Dexter as the leading static symbol/reference candidate and Dexterity as a candidate structural kernel. Their documented capabilities motivate qualification but do not establish correctness, compatibility, security, latency or maintenance fitness for CodeIntel. The design must remain able to reject either candidate.

The decision is needed before finalizing the P1 detailed technical design. It determines which capabilities can be reused, which adapter boundaries are necessary, and what data CodeIntel must own directly. It does not establish the final Ash/Phoenix extraction design, authority registry implementation, MCP transport library, physical storage schema, deployment topology, or optional semantic retrieval strategy.

### 1.1 Ownership boundaries

This ADR is intended to own only the eventual choice of generic language/structural backend and the associated ownership and compatibility conditions. The architecture owns the technical invariants; the PRD owns product outcomes; P0 owns qualification execution and scoring. The eventual ADR must not amend any of those by implication.

CodeIntel remains responsible for its canonical evidence contract, source provenance, access-policy enforcement, framework and authority enrichment and response composition. Backend data structures must not become the product's public evidence schema or its security boundary. An accepted backend choice may inform future interfaces, but exact implementation contracts belong in the applicable TDD.

## 2. Applicable authorities and constraints

### 2.1 Baseline adoption

The current reviewed combined architecture and qualification baseline remains v0.2.1 until the proposed separated documents are explicitly accepted. The references below describe the proposed separated baseline for this ADR. Before submission for acceptance, the proposer must record the exact applicable accepted revisions and resolve any mismatch. Downloads, document hashes and this ADR's status field do not establish acceptance.

| Authority | Relevant provisions | Effect on decision |
|---|---|---|
| SF-CI-PRD-001 v0.1 | §7: CI-R01–04, CI-R06–09, CI-R11, CI-R13–14; §13: PA-02/03/05/10/12 | Reusable scoped source intelligence, honest resolution and freshness, read-only retrieval, pre-ingestion confinement and reuse before duplication |
| SF-CI-PRD-001 v0.1 | §§11–13; CI-R05, CI-R10, CI-R12 | Preserve future framework, mandatory authority and independent-review capabilities without treating them as P0 deliverables |
| SF-CI-SPEC-001 v0.3 | §§01–03 and Q0 | Authority boundaries, structural ownership, candidate stack and qualification strategy |
| SF-CI-SPEC-001 v0.3 | §§05–07, 08–09 | Source extraction, canonical evidence, generations, context retrieval and backend-independent interfaces |
| SF-CI-SPEC-001 v0.3 | §§11–13 | Lifecycles, pre-ingestion containment, execution authorization and Factory boundary |
| SF-CI-SPEC-001 v0.3 | §§14–16, 18 | Operational measures, phase gates and independent review findings, including CI-F04 and CI-F20 |
| SF-CI-P0-001 v0.3 | §§0–2, 4–7 and 5A | Exact admission, fixture expectations, measurements, scoring, STOP conditions and P0 gate decision |
| SF-CI-ADR-001 v0.1 | §§3–8 | Decision roles, evidence, lifecycle, mandatory gates and independent acceptance |

These references are navigation and traceability, not newly defined product requirements or duplicated qualification thresholds. The full PRD and system-level confirmatory gates are not automatically P0 pass criteria.

### 2.2 Non-negotiable constraints

- Static discovery must not require target evaluation, compilation or application startup under the admitted P0-A envelope. Upstream tool build authorization is separate.
- OS-enforced containment must prevent unauthorized data ingestion, writes, target execution, network use and cross-worktree state reuse; output filtering is insufficient.
- Evidence must be attributable to an exact captured input and backend generation or a qualified frozen-materialization strategy. Mutable live freshness is an observation, not a future guarantee.
- Unsupported, inferred, ambiguous and dynamic relationships must remain distinguishable from resolved relationships. Generated or effective Ash semantics are not presumed from a generic reference graph.
- Canonical evidence must not depend on a private upstream database schema. If a private read-only schema interface is unavoidable, qualification must establish the need and a version-specific adapter boundary.
- The selection must justify one logical structural owner and any necessary duplication, without a second full graph or index merely for convenience.
- License, dependency identity, compatibility and operational limitations must be assessed before a positive recommendation assumes their availability.

These constraints cannot be waived by better benchmark scores or by a positive vote on this ADR.

## 3. Alternatives and evaluation method

### 3.1 Alternatives

The following options are evaluation candidates or possible gate outcomes. No option is selected, and this table does not expand the P0-A execution envelope.

| Option | Candidate ownership and boundary | Potential benefit | Material unknowns / trade-offs | Evaluation status |
|---|---|---|---|---|
| A — Direct lexical/source discovery | `rg` and direct source reads; no persistent structural kernel | Simple independent comparison and fallback; no dependency on a graph store | May require repeated reads; not equivalent to qualified symbol resolution, ranking or impact retrieval | P0 baseline; NOT RUN |
| B — Dexter without Dexterity | Dexter provides generic symbol/reference indexing; structural operations limited to qualified existing interfaces; unresolved graph needs remain explicit | Fewer dependencies and integration boundaries if sufficient | May not provide all needed export, ranking, map, impact or generation capabilities; no authorization to fill gaps by building a new engine | P0 candidate configuration; NOT RUN |
| C — Dexter with Dexterity (preferred qualification hypothesis) | Dexter supplies indexed facts; Dexterity is candidate structural graph/ranking owner; CodeIntel adds scoped evidence and framework enrichment | Potentially reuses most generic structural functionality; avoids duplicated implementation | Compatibility, stable generation, cache ownership, export coverage, token budgets, licensing, resource use, isolation and lifecycle coupling unverified | P0 candidate configuration; NOT RUN |
| D — Bounded wrapping or extension of qualified tooling | Reuse B or C with a specifically identified adapter or bounded upstream improvement | May address a measured integration gap without wholesale replacement | Extension scope, ongoing maintenance, compatibility and security verification; cannot assume a missing gate will pass after a hypothetical fix | Recommendation possible after P0; implementation requires separate authorization |
| E — Alternative backend qualification | Expert, ElixirLS or a narrowly scoped alternative selected for a documented gap | Potential compiler/generated-code enrichment or alternative structural capability | Different execution model, operational complexity and possibly different supported scope; source and compiled paths require separate qualification | Outside P0-A; follow-up only if separately authorized |
| F — Reject or defer selection | No selected structural backend; retain direct source baseline where independently authorized | Avoids premature commitment when mandatory gates fail or evidence is inadequate | P1 may be delayed or require revised scope; no claim of full product capability | Valid evidence-backed gate outcome |

A custom language server or replacement graph engine is not an authorized P0 option. A future proposal for such an engine would require evidence that qualified reuse and proportionate alternatives are inadequate, together with an explicit architectural change and separate authorization. No such proposal is made here.

### 3.2 Mandatory criteria and scoring ownership

Use the frozen, independently reviewed fixture and scoring manifest required by SF-CI-P0-001 §§1A and 5A. Qualification PASS / PARTIAL / FAIL / NOT RUN is not an ADR lifecycle. Record actual counts and supported scope rather than calculating a single weighted score that hides a mandatory failure.

| Criterion | Decision use | Controlling source |
|---|---|---|
| Reproducibility, exact revision pair and licenses | Establish what was actually tested and legally/operationally available | P0 §5A Reproducibility |
| Supported exact definition lookup | 100% correctness on predeclared supported assertions | P0 §5A Exact lookup |
| Supported reference precision and recall | At least 98% precision and 90% recall on the agreed assertions; include raw counts and unresolved/unsupported coverage | P0 §5A Supported references |
| Structural capabilities and token-budgeted maps | Required public operations, graph direction and export/generation contract must match fixture expectations; report actual tokenizer limitations | P0 §5A Structural reuse |
| Framework limitations | Explicit source-only and generated/effective coverage distinction; no target execution to fill gaps | P0 §5A Framework gaps |
| Refresh and generation integrity | Supported mutation cases pass; no observed mixed-generation claims | P0 §5A Refresh and generation |
| Security and cleanup | All applicable containment cases pass, with independently established OS controls and verified cleanup | P0 §5A Security; §§1A, 6 |
| Resource and latency measurements | Compare reproducible costs within approved limits; include materialization and freshness verification; no small-corpus production SLA claim | P0 §5A Performance; CI-F20 |
| Agent value | Not required for P0-A; no productivity claim without separately authorized measured evidence | P0 §§3, 5A, 7; CI-F14 |
| Structural ownership and minimal duplication | Recommend one owner or explicitly unresolved; no positive adoption without needed evidence | P0 §5A Decision; architecture §§02–03 |

All numerical values in this table are inherited from the proposed P0 contract; they must be ratified before execution. They do not create independent ADR thresholds. If the accepted P0 revision differs, follow its criteria and revise this record for review rather than silently choosing a convenient value.

### 3.3 Comparison rule

1. Verify admission, frozen expectations, exact revisions and the scope of the test. An unauthorized or uncontained run cannot support positive qualification.
2. Apply the mandatory correctness, structural/generation and security gates of the applicable P0 contract. A missing required result is not a pass. A missing non-advertised Ash semantic capability does not by itself disqualify a generic structural backend.
3. Among feasible options, compare actual useful supported coverage, required interfaces, operational cost, deployment and license obligations, maintainability, failure/recovery and additional complexity. Report any difference that cannot be measured comparably.
4. Prefer the smallest sufficient combination, including a thinner backend-only option if justified. If no option satisfies the necessary gates, propose rejection, deferral or narrowly scoped further qualification instead of a conditional positive selection.
5. Submit exact evidence and recommendation for independent review. P0-A closure is possible with negative results. P0-B can be separately authorized or explicitly deferred to P1.

No scores, weights, acceptance margins or extra experiments are introduced by this ADR. If a tie-break or new comparison is required, document and approve its method before any new testing. Preserve previous runs rather than retrofitting scoring rules.

## 4. Evidence and findings

### 4.1 Evidence available at revision 0.1

| Evidence reference | Classification | Observation and limitation |
|---|---|---|
| Architecture §§02–03 | Source-derived design rationale | Dexter and Dexterity are leading candidates; actual operation and compatibility unverified. |
| [Dexter upstream repository](https://github.com/remoteoss/dexter) | Reference inherited from architecture [R1] | Candidate source/CLI/LSP indexing interface. Exact revision, source inspection, supported capabilities and measurements pending. |
| [Dexterity upstream repository](https://github.com/nshkrdotcom/dexterity) | Reference inherited from architecture [R2] | Candidate structural kernel. Exact public APIs, dependencies and generation binding pending verification. |
| SF-CI-P0-001 §§1A, 2, 5A | Proposed qualification protocol | Defines evidence to be produced; not evidence of observed behavior. |
| Independent reviews of combined baseline, CI-F01–CI-F21 dispositions in architecture §18 | Design-level findings and review history | Relevant concerns identified; not backend implementation verification or adoption. |

No new upstream research, pinned source audit, tool installation or executable qualification was performed for this draft. No performance, security or correctness figures are asserted as observations.

### 4.2 Qualification results register

Fill in the following register from the actual qualification report; each row must identify the configuration, fixture/measurement identity, expected versus observed result, raw artifact reference, classification and reviewer disposition. Where B and C were exercised separately, preserve the distinct results. If either was not exercised, say so.

| P0 matrix category | Verdict at draft | Evidence / blocker |
|---|---|---|
| Reproducibility | NOT RUN | Admission, toolchain, pinned revision pair and license evidence not supplied |
| Correctness | NOT RUN | Frozen fixture expectations and raw definition/reference assertions not supplied |
| Dexterity reuse | NOT RUN | Structural export, map, ranking, impact and generation observations not supplied |
| Framework gap | NOT RUN | Supported static fixtures and effective/generated limitations not evaluated |
| Refresh | NOT RUN | Mutation, deletion, broken source and generation tests not executed |
| Security | NOT RUN | Containment, negative canaries, worktree segregation and descendant cleanup not verified |
| Performance | NOT RUN | Cold/warm and refresh samples, resource use, output and end-to-end verification cost not supplied |
| Agent value | NOT RUN | P0-B not authorized by this record; actual deferral/authorization disposition to be recorded at P0 gate |
| Decision | NOT RUN | No evidence-backed reuse/wrap/extend/reject recommendation yet |

`NOT RUN` means no qualifying evidence is available to this proposal; it is not a failing implementation verdict. Exact accepted baseline, admission outcome, tool revisions, actual execution limits and independent reviewer remain pending. No conclusion may be inferred from this register beyond those limits.

### 4.3 Required evidence handoff

The paths below are **planned deliverable locations**, not claims that files exist:

- `docs/qualification/P0-backend-verdict.md` — category verdicts, observed limitations, exact revisions, compatible pair, ownership recommendation and next-gate proposal.
- `benchmarks/results/p0/admission.md` — approved environment, effective OS boundaries and ceilings, fixture/revision manifest, approval identities and admission record.
- `benchmarks/corpus/p0/` — exact synthetic source, independently reviewed supported/unsupported classifications, expected assertions and frozen scoring manifest.
- `benchmarks/runners/p0/` — reproducible approved commands, runner revision and environment/containment setup.
- `benchmarks/results/p0/` — raw/sanitized results, run IDs, checksums, logs or permitted digests, measurements, observed security evidence and cleanup verification.

The P0 contract owns exact deliverable requirements, output limits, authorized retention and STOP rules. Do not copy secrets, unauthorized source or excessive logs into the ADR. Record immutable artifact references or identify missing evidence, not invented filenames or run identifiers.

## 5. Proposed decision

### 5.1 Current disposition

**No generic language backend or structural kernel is selected.** The preferred qualification hypothesis is Dexter plus Dexterity, with Dexter alone compared where sufficient. This preference derives from the existing architecture, not observed superiority.

This draft is a decision scaffold, not a request to accept a positive backend adoption or a final decision to reject/defer the project. It should be revised after P0-A to contain an evidence-backed recommendation. If qualification cannot proceed, an independently reviewed negative or deferral recommendation can instead be proposed with the actual blocker and next gate.

### 5.2 Decision statements required in the next submitted revision

The evidence-backed successor must explicitly identify:

1. Selected option or negative/defer outcome; exact supported versions, checksums and compatibility scope where applicable.
2. Rationale against the remaining alternatives and the predeclared gates, with any missing or failed categories visible.
3. One structural owner, clear generic index and graph responsibility, invalidation propagation and generation identity; identify any unresolved ownership rather than inventing a binding choice.
4. Integration interface selection and its stability, with public interfaces preferred; any private storage access, duplicate representation or wrapping requirement justified by observed limitations.
5. Supported and excluded operations; static versus compiled boundaries, dynamic/unsupported behavior, stale evidence treatment, and evidence-verification obligations.
6. Operational/security conditions, license obligations, residual risks, exact downstream TDD obligations and reevaluation triggers.
7. P0-B disposition and recommended next gate; no automatic P1 authorization or agent benefit claims.

Do not mark this revision accepted solely because the architecture approved the candidate evaluation. Do not approve positive selection subject to mandatory tests being performed at a later time.

### 5.3 Structural responsibility matrix to resolve

| Responsibility | Candidate allocation (not binding) | Required qualification or downstream decision |
|---|---|---|
| Generic source definitions/references | Dexter if selected | Verify supported public operations, scope, refresh and reference accuracy |
| Generic graph construction/ranking/maps/impact | Dexterity if selected; otherwise qualified existing capability or explicitly unresolved | Establish exact owner, dependency direction, export consistency and useful supported coverage |
| Generic invalidation and generation identity | Single logical structural owner; precise coordination unresolved | Establish how both layers bind to the same captured input; demonstrate no stale or mixed-generation claim |
| Canonical evidence, provenance and coverage | CodeIntel, as established by architecture | Normalize without tying public contract to backend schema; exact types in TDD |
| Framework and authority enrichment | CodeIntel adapters, later phases | No implication that generic backend supplies effective Ash metadata or mandatory authority resolution |
| Authorization, filesystem boundary and execution | Trusted launch/control boundary; CodeIntel enforces scoped retrieval | Establish OS containment and independent authorization; never delegate security to graph or MCP output |
| Storage and cache lifecycle | Backend-owned derived data plus minimal CodeIntel-owned evidence as needed | Measure duplication, cleanup, ownership and compatibility; do not select a physical schema here |

The architectural distinction between a canonical evidence model and a complete physical copy of generic structural data remains binding where the architecture is applicable. A thin adapter may refer to a qualified version-bound export; it may not attach provenance that was not established. If an immutable generation is unavailable, assess a frozen source materialization under P0. If that is insufficient, mark the gap and block any positive consistency claim.

## 6. Consequences and risks

The following are prospective trade-offs, not findings about the pinned implementations. Owners must be assigned before applicable obligations are accepted.

| Risk or consequence | Impact if realized | Mitigation or obligation | Owner / due gate |
|---|---|---|---|
| Dexter/Dexterity version or schema coupling | Upgrade breakage, unreliable queries | Pin compatible pair; document contract and test boundaries; qualify updates | P0 proposer / before selection |
| Structural duplication | Redundant indexing, divergent freshness, storage cost | Require one logical owner and evidence for additional representations | Decision owner / before selection |
| Unstable exports or mutable backend state | Evidence not attributable to exact inputs | Verify generation identity or qualified frozen materialization; reject unsupported claims | P0 proposer / before selection |
| Backend reads, subprocesses, IPC or caches outside scope | Unauthorized data persistence, execution or leakage | OS containment, source inspection, canaries and verified cleanup; failure blocks positive security verdict | Qualification operator / before and during P0 |
| Incomplete or dynamic symbol resolution | Misleading callers or missing critical context | Report supported scope, recall and abstentions; retain direct verification fallback | P0 proposer; P1 design / before relevant release |
| Inadequate generated Ash coverage | False inference about effective action semantics | Keep static versus compiled evidence separate; later isolated enrichment only if authorized | P0 report; P2/P4 designs |
| Licensing or redistribution uncertainty | Packaging or deployment blocked | Review exact license texts, transitive obligations and permitted use; resolve before relying on rights | Decision owner / before applicable adoption |
| Backend maintenance or resource cost | Expensive upgrades or multi-worktree operation | Measure actual overhead and document maintenance owner; defer scale optimizations until needed | P0 measurement; P1/P5 design |
| Candidate failure or lack of feasible backend | Delay or changed MVP scope | Stop at gate; propose a bounded alternative or explicit no-go; do not build unauthorized replacements | Decision authority / P0 gate |

No application dependency changes, production migration or rollback mechanism are authorized by this record. For the eventual selected backend, the P1 design must describe install/disable/remove/rebuild behavior and version rollback/requalification conditions within its scope. Existing projects must continue operating without CodeIntel, as required by CI-R09. P0 disposal and quarantine remain governed by the qualification contract.

## 7. Validation and downstream contracts

| Obligation | Evidence required | Required before | Current state |
|---|---|---|---|
| Establish applicable authority baseline and decision owner | Exact accepted revisions, trusted governance references | Acceptance review | Pending |
| Admit qualification | Approved P0 admission, frozen expectations, permitted scope | P0-A execution | Pending; no admission granted here |
| Complete P0-A report | Reproducible raw evidence and category verdicts; negative outcome permitted | Evidence-backed ADR submission | NOT RUN |
| Select or reject backend with reasoned alternatives | Independent review of mandatory gates, limits, ownership and exact proposal | ADR acceptance | Pending |
| Define P1 contracts | Selected qualified interfaces, evidence types, consistency, errors, scoped workspace, read-only MCP/CLI and verification tests | P1 implementation | Not authorized |
| Establish useful product value | Actual agent comparison under separately ratified methodology; product and technical acceptance evidence | Applicable P1/later gates | Unverified |
| Extend compiled and Factory support | Applicable phase designs, authorized execution and environment-specific security tests | P4/P5 gates | Deferred |

Future ADR topics and technical designs should be created only when their material decision remains unresolved. This ADR does not authorize the exact P1 design before qualification, comprehensive Ash extraction, runtime authority registry, persistent Factory orchestration, optional embeddings, or a duplicate structural engine.

### 7.1 Reevaluation triggers

Proposed triggers for the eventual accepted decision: upstream major or schema/API compatibility changes; license or distribution changes; loss of supported operations; observed containment, cleanup or generation-integrity failure; inability to meet supported correctness or operational requirements; or independently measured evidence that a simpler qualified alternative suffices.

A newly discovered security or integrity failure must be handled under the applicable stop/revocation and operational authorities. Do not assume an old accepted ADR makes a new incompatible release or workspace safe. Requalification and any replacement decision require their own approved scope and review; preserve historical versions and decision records.

## 8. Independent review

| Review field | State |
|---|---|
| Exact proposal revision reviewed | Not yet submitted for independent acceptance |
| Reviewer identity and decision authority | Pending designation |
| Qualification evidence reviewed | None available |
| Blocking findings | Mandatory evidence not yet produced; applicable authority adoption and admission remain pending |
| Review recommendation | Pending; draft only |
| Acceptance event | None |

The evidence-backed successor must be reviewed against the applicable approved authority revisions, pinned backend source, admission, raw qualification artifacts, test expectations, and exact recommendation. Before any merge recommendation, independently verify the exact candidate PR diff, CI for that candidate, and all applicable approved authority references, including relevant source. Qualification completion and ADR acceptance cannot replace this obligation.

## 9. Decision event reference and history

No trusted acceptance, rejection, withdrawal, supersession or revocation event has been recorded. The current revision is proposed and non-binding. The ADR governance lifecycle in SF-CI-ADR-001 §6 applies upon adoption: accepted revisions require authorized review and approval; historical terminal revisions cannot be silently reactivated. The exact reviewed revision and immutable reference must be recorded in a separate trusted decision event; this file does not self-approve.

| Revision | Change | Decision / evidence reference |
|---|---|---|
| 0.1 | Initial pre-qualification alternatives, criteria mapping, ownership questions and evidence register | Proposed; no selected backend or acceptance event |

### 9.1 Source baseline and integrity

The following hashes identify the actual source files consulted in drafting this ADR. They do not establish approval or prove that any backend has been tested.

| Source file / revision | SHA-256 |
|---|---|
| SF-CI-PRD-001-v0.1.md | `f5374a4de6e6c021334e4965c25bb0dfe4ddf5d7671bbd007412e5a497c56a30` |
| SF-CI-SPEC-001-v0.3.md | `5c7f7712b86638075c280fd236b9958c2973df7979a8b273809933e38341424e` |
| SF-CI-P0-001-v0.3.md | `b6021234fd7bb8d16d128a758c581a4abf288208e0f0a64f171a39f3ececec85` |
| SF-CI-ADR-001-v0.1.md | `ebeb0d092ef7f134feb628df5c462a264d4246f7cf4cd846d3ecb9395ed4528f` |

The options, responsibility matrix and reevaluation triggers are proposed decision-record organization, not independent requirements or validated backend capabilities. Source documents were not amended. No backend revision was selected, no target repository accessed, no qualification executed and no benchmark evidence fabricated.

**Next gate:** Ratify applicable authority and P0-A admission, freeze fixture expectations, execute only the authorized qualification, then revise this ADR with actual evidence and submit it for independent review. Do not treat this scaffold as the completed P0 deliverable. P0-B and P1+ remain separately authorized work. No qualification, implementation, merge, release or deployment authority is granted by this ADR.
