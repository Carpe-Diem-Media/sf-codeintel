# SF CodeIntel — Project Governance and Authority Register

| Document control | Value |
|---|---|
| Document ID | SF-CI-GOV-001 |
| Revision | 0.2 |
| Date | 26 November 2026 |
| Status | Proposed. Exact-revision independent review and authorized adoption are pending |
| Intended repository | `sf-codeintel` |
| Intended canonical path | `docs/governance/SF-CI-GOV-001.md` |
| Authority domain | Project-level document coordination, authority registration, gate and assignment routing, approval records and conflict escalation |
| Project owner / accountable acceptance authorities | Project owner verified in the standing directive. Check each delegated mandate in its trusted record |
| Current delivery gate | P0-A admission preparation; NOT ADMITTED / NOT RUN |
| Phase execution authorization | P0-A, P0-B and P1 require separate permissions. See §6 |

> **Index broadly. Retrieve selectively. Verify precisely. Execute securely.**

## 1. Purpose and boundaries

This document is the central navigation and coordination entry point for SF CodeIntel developers, coding agents, reviewers and project operators. It identifies which document owns each decision, the applicable revision and approval status, the current delivery gate, and the evidence required before work advances.

It does not restate the product requirements, redesign the technical architecture, select a backend, set new qualification thresholds, specify production code, or authorize an agent to execute work. It is a documentation and human-reviewed governance contract. Initially, version-controlled Markdown and trusted review/approval records are sufficient; no runtime governance engine, new database or orchestration service is required.

The governing product requirements remain `CI-R01`–`CI-R14`; product acceptance scenarios `PA-01`–`PA-14` belong to the standalone PRD upon adoption. Technical gates `G1`–`G14` and `Q0` belong to the architecture. P0's specific pass criteria belong to the qualification specification. These identifiers are references, not new scoring rules. A project-level status summary must not be mistaken for evidence that any requirement has passed.

MUST and MUST NOT in this document express proposed coordination obligations upon adoption. Existing applicable baseline constraints remain in force regardless of whether this document is accepted.

## 2. Scoped authority model

| Authority | Owns | Does not own |
|---|---|---|
| SF-CI-GOV-001 (this document) | Authority index, adoption routing, status coordination and escalation | Product, architectural, ADR, technical or execution contract content; cannot self-approve |
| SF-CI-PRD-001 | Product purpose, users, capabilities, scope, experience, product outcomes and acceptance | Dependency choices, exact schemas or permission to execute |
| SF-CI-SPEC-001 | Architecture, technical invariants, component ownership, security boundaries, technical validation and phase dependencies | Unilateral changes to product intent, specific execution grants |
| SF-CI-ADR-001 | Governance of technical decisions, decision lifecycle and ADR template | Specific technology selection or production implementation |
| Individual accepted ADRs | Named, scoped technical decisions and rationale | Waiving mandatory requirements or authorizing an assignment |
| SF-CI-TDD-001 | Completeness and review standard for detailed designs | Concrete phase design or dependency selection |
| Accepted phase-specific TDDs and their designated contracts | Exact interfaces, data types, errors, states, guards, side effects, test assertions and operational design | Changes to superior scope obligations or permission to implement other phases |
| SF-CI-P0-001 | P0 admission, budgets, permitted activities, frozen expectations, scoring, STOP rules and deliverables | Product acceptance, production backend adoption, P1 authorization |
| Approved admission records and bounded assignments | Effective run/work scope, permissions, resources, revisions, deliverables and stopping conditions | Waivers of applicable security or design invariants, unilateral budget expansion |
| Qualification results, tests, CI and independent reviews | Observations, failures, verified scope and recommendations | Amendments to requirements, retrospective scoring changes or self-issued approvals |
| Trusted decision and authorization records | Evidence of accountable approval, effective scope, dates and conditions | New technical facts unsupported by evidence |

Authority is scoped, not a universal precedence ranking. All applicable accepted constraints and valid execution limits MUST hold together. A newer file, successful test, repository comment, model recommendation or search ranking does not override an applicable accepted authority. A document may contain explanatory references to another authority without owning the referenced requirement. If a phase TDD delegates a normative schema to a versioned contract, use that exact designated contract rather than independently editable copies.

The technical architecture's security model governs CodeIntel's future retrieval of target-project authorities. This register governs the **SF CodeIntel project itself**. It does not grant access to other repositories or implement runtime scope resolution. Do not conflate the two.

## 3. Authority register and adoption status

### 3.1 Current reviewed baseline

The supplied independent reviews approved the inherited architecture in principle and P0-A subject to admission. Narrow amendments v0.2.1 addressed CI-F14 and the design portion of CI-F15. The subsequently separated documents expressly state that they are proposed until adopted. The following existing baseline therefore remains the conservative working reference pending coordinated adoption; no verified trusted approval record for the new exact revisions has been supplied.

| Document | Current baseline revision | Status / application |
|---|---|---|
| SF-CI-SPEC-001 | 0.2.1 | Existing reviewed combined architecture and product baseline; no production implementation authority |
| SF-CI-P0-001 | 0.2.1 | Existing qualification baseline; execution conditional on actual admission |

The wording “reviewed baseline” is not an assertion that the exact v0.2.1 amendment hashes have independently received formal acceptance. Record amendment review and applicable revisions before admission. If acceptance evidence establishes a different valid baseline, reconcile the register explicitly rather than silently selecting one.

### 3.2 Separated authority set awaiting formal adoption

| Document / revision | Canonical repository path | Recorded status / next action |
|---|---|---|
| SF-CI-PRD-001 v0.1 | `docs/product/SF-CI-PRD-001.md` | Proposed; coordinated review with architecture v0.3 |
| SF-CI-SPEC-001 v0.3 | `docs/architecture/SF-CI-SPEC-001.md` | Proposed; preserves reviewed technical design, pending separation acceptance |
| SF-CI-P0-001 v0.3 | `docs/qualification/SF-CI-P0-001.md` | Proposed; explicitly adopt successor and preserve admission restrictions |
| SF-CI-ADR-001 v0.1 | `docs/adr/SF-CI-ADR-001.md` | Proposed governance; independent review and adoption required |
| ADR-001 v0.1 | `docs/adr/ADR-001-backend-selection.md` | Proposed pre-qualification scaffold; no selected backend; evidence NOT RUN |
| SF-CI-TDD-001 v0.1 | `docs/technical-design/SF-CI-TDD-001.md` | User concurrence expressed in conversation; independent exact-revision acceptance not established |
| SF-CI-GOV-001 v0.2 | `docs/governance/SF-CI-GOV-001.md` | Proposed. The owner directive has its own authority under §4.1 |

### 3.3 Coordinated adoption procedure

SFCI-2 owns the actual baseline adoption. SFCI-12 records the procedure. A designated accountable acceptance authority may adopt exact revisions within a verified, recorded mandate after independent review and prerequisite verification. The mandate covers routine decisions without a further owner vote. Route gaps and conflicts under §4.2.

1. Verify the accountable owner, independent reviewer, authorized decision maker and scope of the decision maker's mandate in a trusted project record.
2. Review the exact PRD v0.1 and architecture v0.3 together against the reviewed combined v0.2.1 baseline, including normative IDs, security, scope and phase gates. Resolve material mismatches before adoption. Accept the pair together with explicit supersession and effective scope, or retain the applicable combined baseline.
3. Record separately which exact P0 revision governs admission and the disposition of the P0 v0.3 successor. Review the exact successor before accepting it and preserve the admission restrictions.
4. Record a separate exact-revision disposition for each governance, ADR and TDD standard. Keep the backend decision in ADR-001 proposed until actual qualification evidence, independent review and accountable decision acceptance support it.
5. Record each exact revision and immutable reference, independent review, decision maker and mandate, disposition, effective scope and date, and conditions or supersession under §3.4. A coordinated record may carry multiple decisions if it identifies each one explicitly.
6. Update the register from those trusted records and retain historical revisions and links. Apply separate decisions for document adoption, technical acceptance, phase execution, merge and release.

### 3.4 Minimum trusted record (human-readable)

Use the existing ADR decision-event requirements (SF-CI-ADR-001 §7.2) and TDD acceptance requirements (SF-CI-TDD-001 §6) for their respective records. For project-level coordination, record at least:

- Decision/event identifier and type; exact document/task ID and revision; immutable Git object/commit or content digest, canonical path and effective scope.
- Proposer, accountable owner, independent reviewer and authorized decision maker; review reference and decision time.
- Decision, rationale, applicable evidence, unresolved non-blocking limitations, conditions and explicit supersession/revocation references where applicable.
- Impacted dependent contracts, assignments and gate state; notification or follow-up owner; explicit distinction between design approval and execution permission.

A hash establishes content identity, not trust, authorship or approval. Preserve the approved event separately from the document content it identifies; never require a file to contain its own final hash. Repository text or an agent-generated event is not sufficient proof of a trusted decision. Use the actual authorized review process to establish provenance.

## 4. Accountability and conflict handling

Verify each role's mandate in the applicable trusted record. A person may hold compatible roles if explicitly authorized. Assign independent plan and candidate review to people or agents other than the respective authors.

| Role | Responsibility |
|---|---|
| Project owner | Sets product direction and authorizes reserved decisions. Issues, supersedes or revokes the standing directive |
| Lead Orchestrator | Coordinates the queue and assignments, designates accountable technical and design approval roles, verifies integration and merges within the standing mandate |
| Product acceptance authority | PRD revisions and product outcome acceptance |
| Architecture / decision owner | Architecture and scoped ADR decisions; resolve technical conflicts |
| Design owner | TDD readiness, contract completeness and controlled amendments |
| Designated execution operator | Ratifies P0-A admission within verified permissions and enforces the approved environment, resource ceilings and cleanup |
| Qualification / implementation agent | Perform only admitted work, preserve evidence, report blockers and propose decisions |
| Independent reviewer | Verify exact revisions, applicable authority, raw evidence and relevant code; recommend or reject gates |
| Accountable acceptance authority | Adopts exact revisions within a verified mandate under §3.3 |
| Release authority | Decides on release and deployment under separate owner authorization |

### 4.1 Standing owner directive

The verified issuer is the SF CodeIntel project owner acting in that role. The directive is dated 26 November 2026. Its source is the owner's message in [SF CodeIntel Governed Delivery Loop](t3-thread://v2/fdfd1f03-53cf-41e7-8d37-6f5313c72d55/2211b596-9b80-4ba4-b4fd-5343f5000a87), tracked in Plane SFCI-12. The owner designated the persistent Lead Orchestrator to coordinate delivery through P0-A and P1 as each phase becomes eligible. The directive applies from issuance within its recorded scope and conditions.

The Lead Orchestrator may manage the SFCI Plane queue, verify eligibility, promote and claim work, create bounded tickets from accepted designs, delegate assignments and corrections, and manage PRs through subagents. The mandate covers routine merges that satisfy §8, checkout synchronization, evidence recording, closure and advancement. Verify the relevant permissions and prerequisites before dispatch. The orchestrator coordinates, performs read-only verification and integrates independently reviewed work. It delegates substantive authoring, fixtures, test development, qualification execution and corrective work.

Designate accountable technical and design approval roles within the authorized scope. Record the actor and mandate before relying on a decision. Those roles may approve ordinary technical designs and scoped technical decisions after exact-revision independent review and verification of applicable requirements and acceptance evidence. The orchestrator records each decision and its evidence. Route any decision that exceeds a recorded mandate to the accountable authority. Use §3.3 for adoption and §6 for admission and execution.

The owner reserves material product or scope decisions, deployment, P2–P7 implementation, and increases in risk, permissions or resource budgets. Separate authorization is required for those decisions. The directive grants routine coordination and conditional merge authority. Phase execution depends on separate effective permissions under §6.

Before dispatch and merge, verify the current directive, mandate, applicable scope and any revocation or supersession. If the owner revokes or supersedes the directive, record the trusted decision, effective time, affected scope and assignments, and replacement authority where applicable. Notify affected roles and stop affected reliance until effective authority and evidence are reconciled. Use the same checks for affected delegated mandates.

### 4.2 Conflict and missing-authority protocol

1. Identify the affected operation, contract or decision and stop that portion of work. If security or scope separation cannot be established, stop all affected execution.
2. Record the exact competing document IDs, immutable revisions, clauses, scope and observed evidence. Mark uncertain applicability or missing mandatory authority explicitly; do not select an interpretation on relevance alone.
3. Route the issue to the relevant owner. Require the smallest reviewed clarification, ADR or amendment needed; coordinate multiple owners if the conflict crosses authority domains.
4. Record the accepted resolution, affected revisions, impact on tests and active assignments. Resume only with valid authorization and applicable revised contracts.

Safely separable authorized work may continue. Record unrelated defects separately in the project issue register or approved tracker; do not expand the current assignment to repair them. This document creates no tracker issues itself.

## 5. Document lifecycle and operational status

Use the document lifecycle in SF-CI-PRD-001 §1.3 upon adoption, supplemented by SF-CI-ADR-001 §6 and SF-CI-TDD-001 §6 for their own scopes. The table is a navigation summary, not a replacement lifecycle contract.

| Transition | Required guard | Coordination effect |
|---|---|---|
| Proposed → Accepted | Exact revision, independent review, authorized acceptance and applicable prerequisites satisfied | Register active scope and effective revision; notify affected owners |
| Proposed → Rejected | Authorized reason recorded | Preserve historical proposal and review |
| Proposed → Withdrawn | Authorized withdrawal before acceptance | Remove proposal from consideration; retain history |
| Accepted → Superseded | Explicit accepted replacement with compatibility and scope resolved | Replace active authority and reassess dependent work |
| Accepted → Revoked | Authorized invalidation and affected scope recorded | End active eligibility, notify and stop affected reliance |

Rejected, withdrawn, superseded and revoked are terminal for normal authority eligibility of that revision. Do not resurrect a predecessor automatically after revocation. Amendments create new proposals; preserve immutable history. This does not alter the architecture's technical domain lifecycles. The runtime authority terminology difference (architecture §11B versus PRD §1.3) remains a P3 clarification, not a P0 implementation requirement.

Maintain distinct status axes:

| Axis | Current observation |
|---|---|
| Architecture direction | Approved in principle by supplied independent reviews |
| Separated document adoption | Pending under SFCI-2. Governance v0.2 remains Proposed |
| Operating authorization | Standing owner directive applies within §4.1 |
| Routine merge | Authorized for the Lead Orchestrator when §8 is satisfied |
| P0-A execution | NOT ADMITTED / NOT RUN |
| P0-A backend category verdicts | NOT RUN; no evidence yet |
| ADR-001 technical selection | Proposed; undecided |
| P0-B | Not authorized; may be deferred to P1 |
| P1–P7 implementation | Not authorized |
| Product acceptance | Not established |
| Production/Factory deployment | Requires separate owner authorization |

A completed qualification may recommend rejection or further qualification. A passing category, completed report, accepted ADR, accepted design, merged PR or successful CI is not an automatic state transition on another axis. Actual execution attempts and domain resources must use their governing lifecycle contracts; this manual register does not introduce new durable operational state machines.

## 6. Current gate — P0-A admission and bounded qualification

### 6.1 Phase navigation

| Phase | Purpose | Gate / current authorization |
|---|---|---|
| P0-A | Dexter/Dexterity qualification and structural ownership decision | Independent admission verification, execution operator ratification and effective bounded permission required before dispatch |
| P0-B | Optional early agent-value experiment | Separate authorization; otherwise explicitly defer to P1 |
| P1 | Thin CLI and experimental read-only MCP/context MVP | Await applicable P0 exit, accepted viable backend decision, independently reviewed and accepted P1 design, and a bounded P1 execution grant |
| P2 | Ash action intelligence | Await P1 exit and applicable design/admission |
| P3 | Phoenix/LiveView, authority and test associations | Await P2 exit and authority contract clarification |
| P4 | Isolated compiled metadata enrichment | Await P3 exit and approved execution/compatibility contract |
| P5 | Software Factory integration | Await P4 exit and verified Factory security/execution boundaries |
| P6 | PR/refactoring and verification intelligence | Await P5 exit and revision-bound review contracts |
| P7 | Optional advanced retrieval/optimization | Only if measured gap warrants an approved decision and design |

Use architecture §16, PRD §11 upon adoption and the phase design standard for phase prerequisites. P2–P7 also require separate owner authorization. A narrow separately authorized experiment may precede a production phase only where the applicable contracts and assignment allow it.

### 6.2 P0-A admission blockers and next steps

The authoritative admission record belongs at `benchmarks/results/p0/admission.md` and MUST follow the selected accepted/applicable SF-CI-P0-001 §1A. Keep P0-A `NOT ADMITTED / NOT RUN` until independent verification of that record and ratification by the designated execution operator. Before dispatch, verify a bounded grant covering the actual environment, authorized preflight and acquisition/build policy, execution scope and resource ceilings.

| Required before dispatch | Present state |
|---|---|
| Applicable exact authority/task revisions and accountable approvals | Not recorded in a trusted admission event |
| Actual host, OS, toolchain and enforceable resource limits | Not verified |
| OS-enforced read/write/execution, IPC/cache and network boundary | Not verified |
| Authorized acquisition/build and host-preflight scope | Not granted here |
| Pinned compatible backend primary pair, justified fallback policy and licenses | Not established |
| Synthetic fixture manifest, independently reviewed expected assertions and supported categories | Not frozen or reviewed here |
| Effective ceilings and predeclared scoring | Proposed in qualification §§1A, 5A; actual ratification outstanding |
| Process-tree termination, cleanup, quarantine and evidence retention | Not verified |
| Final admission decision | NOT ADMITTED / NOT RUN |

Use the qualification specification's exact envelope and STOP rules. In particular, do not access private repositories, compile or execute target/fixture code, consume external model credits, repair upstream tools, or begin production implementation under the P0-A envelope. Synthetic source edits for fixture preparation and testing are distinct from executing target code. The aggregate clock begins at the first authorized acquisition/build/qualification command; preflight and acquisition permissions must be explicit. Track cumulative budgets across agents and sessions. The execution operator enforces the ratified limits and cleanup. Stop on containment failure, unauthorized access or execution, exceeded limits, or unresolved cleanup as specified.

After admission is ratified and bounded execution permission is verified, execute only the admitted P0-A assignment. Produce the qualification verdict, reproducible fixture/runner/evidence artifacts and an evidence-backed **proposed** ADR-001. The current ADR scaffold is not the final deliverable. Report PASS, PARTIAL, FAIL or NOT RUN per category with exact evidence, denominators and blockers according to the qualification specification. P0-B may be explicitly deferred without blocking P0-A completion (CI-F14). Do not claim token savings, productivity or backend correctness from unexecuted or incomplete trials.

### 6.3 Next gate decision

The independent reviewer examines the actual qualification evidence, pinned source, admission and frozen assertions, cleanup and safety observations, limitations, and exact proposed ADR. A viable backend choice requires the applicable mandatory evidence, not a favourable average score or upstream performance claim. Record one of the supported outcomes: reuse, bounded wrap/extension, rejection or narrowly scoped further qualification/deferment. Any alternative backend qualification requires its own bounded authorization.

Finalize the P1 TDD after the applicable P0 exit and an accepted viable backend decision. Dispatch P1 only after independent review and acceptance of the exact P1 design and verification of an effective bounded P1 execution grant covering the assignment. Obtain separate authorization for P0-B or record explicit deferral.

## 7. Agent entry point and assignment routing

Start agent sessions with repository `AGENTS.md`. Use this register to find the applicable clauses and exact source authorities for the assignment.

| Assignment | Minimum authority and evidence package |
|---|---|
| Documentation/adoption review | This register, exact proposed and predecessor revisions, applicable governance clauses, independent review record |
| P0 admission preparation | Applicable P0 §§0–1A, 5A, 6; architecture §§03, 07, 12, 16; approved preflight/fixture preparation scope |
| P0-A execution | Ratified admission, exact P0 assignment, frozen fixtures, applicable architecture/security and reuse constraints, ADR-001 scaffold |
| P0 independent review | Same approved inputs, pinned upstream identities, actual raw results, verdict, cleanup and exact ADR revision |
| P1 design | P0 verdict, accepted backend/ownership decisions, PRD requirements, architecture and TDD standard |
| Phase implementation | Exact accepted phase TDD and designated contracts, applicable product/architecture/ADRs, authorized assignment and verification expectations |
| Security review | Applicable threat model, identity/grant and enforcement contracts, negative cases, exact revision and evidence |
| Final PR review | Exact candidate diff, candidate-specific CI, all applicable authority references, relevant actual source and tests, unresolved findings |

Every assignment records the actor, ticket and goal, exact authorities and inputs, allowed paths and tools, permissions and prohibitions, deliverables and acceptance checks, retry and execution budgets, STOP conditions, and the applicable execution identity or approval record. Reviewers work within their own authorized scope.

### 7.1 Delivery loop

1. Keep one Lead Orchestrator and one active implementation ticket. Refresh Plane, the repository, open PRs, dependencies, blockers, authorities and checks before assigning work. Reconcile unfinished work first.
2. Verify and record prerequisites before moving eligible Backlog or Blocked work to Ready. Claim the assignment and move it to In Progress when delegating it.
3. Assign planning, independent plan review, implementation, independent candidate review, and testing or specialist verification where applicable. Require exact-plan approval before authoring on an issue-linked branch. Route adoption, design, technical decisions and execution authorization to their designated accountable authorities.
4. Move work to In Review when the implementation and required evidence are available. Return confirmed findings to the responsible author within the assigned scope and retry budget. Move the ticket back to In Progress for correction, rerun affected checks and renew invalidated approvals and evidence.
5. Open a narrow issue-linked PR through a subagent. Apply §8 before integration. Record the PR, merged SHA, reviews, check results, acceptance evidence, limitations and follow-ups in Plane. Verify the recorded evidence and resulting issue state before advancing. Mark the assignment Done after acceptance and integration. Done and Cancelled are terminal for that assignment.
6. Refresh the queue and continue eligible work. Use Blocked for a genuine blocker and Awaiting Approval for a decision outside the standing mandate.

Stop affected work for missing, revoked, conflicting or out-of-scope authority or permission, security or containment failure, unresolved cleanup, unavailable mandatory independent review or exact verification, exhausted retry or execution budgets, or a decision beyond the mandate. Record the evidence and resume only after verified resolution. Continue safely separable eligible work. End the loop when no eligible authorized work remains or the authorized MVP acceptance gate is reached.

## 8. Verification, independent review and merge boundary

The PRD owns product acceptance; the architecture owns system technical gates; the P0 specification owns qualification scoring; phase TDDs own exact implementation assertions. The independent reviewer must distinguish source association, intended verification, observed execution and a passing test in a particular run. Neither a related test nor absence of an index edge proves an invariant.

Before recommending merge, the independent candidate reviewer must verify and record the exact final hosted PR base and head, complete actual diff with relevant source and tests, applicable authorities and their exact revisions, required checks and exact-head CI results, and unresolved findings. Reconcile any pre-PR review against the final hosted candidate. Record each finding with evidence, scope and severity. Bind the approval to that candidate and resolve material findings before recommending merge.

The Lead Orchestrator performs a separate integration check before merging:

- Verify the live Plane issue, current remote `main`, and final hosted PR base, head and complete diff. Reconcile any pre-PR review against the exact final PR.
- Confirm the applicable authorities, exact approved plan, independent candidate approval, acceptance results, mandatory CI for the exact head, required GitHub approvals and branch protections, and absence of unresolved material findings.
- Confirm the unrevoked standing directive applies to the candidate. Any failed, missing, skipped, cancelled or unexecuted mandatory check blocks merge. Changes to base, head, applicable authority or evidence require fresh verification and renewal of invalidated approvals.

When these conditions hold, the Lead Orchestrator may merge under the standing directive without a further owner vote. For SFCI-12, §§2, 5 and 11 of the 26 November directive provide that authority while this revision remains Proposed. The one-time documentation exception applies only to PR #1. After integration, verify the resulting remote `main` SHA and merged content and record the evidence under §7.1. Release and deployment require separate authorization.

No performance or economic threshold is ratified by this register. The system-level proposals and confirmatory methodology remain in the PRD and architecture; P0 only uses its ratified specific qualification criteria. Inconclusive evidence remains inconclusive.

## 9. Outstanding findings and decisions

Architecture §18 remains the authoritative independent-review disposition register. The following is a coordination view, not a second findings database or a claim of closure.

| Reference | Routing / current state |
|---|---|
| CI-F01–CI-F13 | Addressed at design level in v0.2 per supplied independent review; implementation verification outstanding at their architecture §18 gates |
| CI-F14 | P0/P0-B inconsistency corrected at specification level in v0.2.1; preserve explicit optional deferral and amendment review |
| CI-F15 | Execution-envelope design amendment complete; actual environment, thresholds, containment and authorization outstanding before P0-A |
| CI-F16 | P3: target discovery and mandatory authority scope; uncertain scope remains incomplete |
| CI-F17 | P3: bind authority revision to context and clarify withdrawal/delivery eligibility |
| CI-F18 | P1/P2: useful coverage, recall and excessive abstention |
| CI-F19 | P5: delivery/revocation ordering, buffered responses and lease release |
| CI-F20 | P0/P1: measure materialization and freshness verification costs; no premature optimization |
| CI-F21 | Before confirmatory benchmark: comparable workloads and cost allocation |
| Document/runtime terminology difference | P3: reconcile architecture §11B authority withdrawal terminology with PRD §1.3 document revocation; see ADR governance compatibility note |

Outstanding decisions include backend selection and structural ownership, compatible exact tool revisions, MCP and storage integration contracts, supported framework/version matrix, actual pilot projects and final benchmark ratification. These belong to their respective owners and gates, not this coordination document. Factory execution/security APIs must be verified before their applicable integration design. Do not create speculative ADRs or TDDs to close unknowns prematurely.

## 10. Repository placement and maintenance

Suggested initial layout (create directories only as needed):

```text
sf-codeintel/
├── README.md
├── AGENTS.md
├── docs/
│   ├── governance/SF-CI-GOV-001.md
│   ├── product/SF-CI-PRD-001.md
│   ├── architecture/SF-CI-SPEC-001.md
│   ├── qualification/SF-CI-P0-001.md
│   ├── adr/SF-CI-ADR-001.md
│   ├── adr/ADR-001-backend-selection.md
│   └── technical-design/SF-CI-TDD-001.md
└── benchmarks/
    ├── corpus/p0/      # when authorized for preparation
    ├── runners/p0/     # when authorized
    └── results/p0/     # admission and actual evidence
```

Keep historical revisions, trusted acceptance/review records and immutable content references available in version control or the designated approved records system. Canonical paths identify a document family, not an accepted immutable revision. Do not overwrite history by replacing a file without recording its predecessor. Add phase TDDs, contracts and evidence as required, not as empty speculative modules. The operator must ensure committed evidence contains no unauthorized source or secrets and meets applicable retention policy.

Update this register when a trusted decision changes document applicability, a gate decision changes phase readiness, or a recorded blocker is resolved. Treat status updates as factual coordination changes with evidence references; amendments to governance rules themselves require review and acceptance of a new revision. Keep this entry point compact; do not copy technical thresholds, full schemas, lifecycle tables or ADR templates into it. A stale register must not override the underlying accepted authority or trusted authorization record.

## 11. Source identity and revision history

The source hashes below are preserved from [SF-CI-GOV-001 v0.1](history/SF-CI-GOV-001-v0.1.md). See the [bootstrap verification record](bootstrap-verification.md) for the archived v0.1 digest and links to all nine verified source blobs. The hashes establish content identity. Adoption and qualification require their own evidence.

| Source file | SHA-256 |
|---|---|
| SF-CodeIntel-Specification-v0.2.1.md | `eec236699730173e0612bd9bfbe6d100f417119c3efe3397de2ad24905b85ced` |
| SF-CodeIntel-P0-Qualification-v0.2.1.md | `b35b92081956fffc7f50ef973afa9591da3e5aef291254af82f12f9db9c2a2ce` |
| SF-CI-PRD-001-v0.1.md | `f5374a4de6e6c021334e4965c25bb0dfe4ddf5d7671bbd007412e5a497c56a30` |
| SF-CI-SPEC-001-v0.3.md | `5c7f7712b86638075c280fd236b9958c2973df7979a8b273809933e38341424e` |
| SF-CI-P0-001-v0.3.md | `b6021234fd7bb8d16d128a758c581a4abf288208e0f0a64f171a39f3ececec85` |
| SF-CI-ADR-001-v0.1.md | `ebeb0d092ef7f134feb628df5c462a264d4246f7cf4cd846d3ecb9395ed4528f` |
| ADR-001-backend-selection-v0.1.md | `708ff8f35bbe818476fd9153053413ae6fc86e592942f43c73e9e531f3d71417` |
| SF-CI-TDD-001-v0.1.md | `ba2bdd1a242b92c2b9db9b1ab3599414ec6a41227ca005d96aa17147001bbd93` |

The v0.1 archive preserves the original review and document-creation context. The standing directive and its scope are recorded in §4.1.

| Revision | Change | Approval status |
|---|---|---|
| 0.1 | Initial scoped authority register, adoption procedure, accountability, gate routing, merge boundary and coordination of inherited findings | Proposed; exact-revision independent review and authorized acceptance outstanding |
| 0.2 | Records the standing owner directive, delegated adoption and decision mandates, delivery loop, final hosted PR review and separate phase permissions under SFCI-12 | Proposed. Exact-revision independent review and adoption are pending |

SFCI-2 owns coordinated adoption. P0-A remains `NOT ADMITTED / NOT RUN`.
