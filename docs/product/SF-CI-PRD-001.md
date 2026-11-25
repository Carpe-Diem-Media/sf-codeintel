# SF CodeIntel — Product Requirements Specification

| Document control | Value |
|---|---|
| Document ID | SF-CI-PRD-001 |
| Revision | 0.1 |
| Date | 25 November 2026 |
| Status | Proposed product baseline — pending independent review and explicit acceptance |
| Intended repository | `sf-codeintel` |
| Intended canonical path | `docs/product/SF-CI-PRD-001.md` |
| Authority domain | Product purpose, users, capabilities, experience, scope and outcome acceptance |
| Source baseline | SF-CI-SPEC-001 v0.2.1 and SF-CI-P0-001 v0.2.1 |
| Product owner / acceptance authority | To be designated by project governance |
| Implementation authorization | None granted by this document |

> **Index broadly. Retrieve selectively. Verify precisely. Execute securely.**

## 1. Document authority and governance

### 1.1 Purpose

This document defines **what SF CodeIntel must achieve, for whom, and how its value will be assessed**. It is independent of the selection of individual parsers, language servers, graph engines, storage technologies and model providers. It consolidates the product requirements in the reviewed technical architecture rather than replacing that architecture or expanding the approved work.

The normative requirement identifiers `CI-R01` through `CI-R14` are preserved from SF-CI-SPEC-001 §01. The descriptions below refine their product-facing meaning. New use-case identifiers (`UC-*`) and product acceptance scenarios (`PA-*`) are traceability aids, not additional execution authorization. Normative terms MUST, MUST NOT and SHOULD describe intended obligations once the document is accepted; they do not assert that any feature currently exists.

### 1.2 Separation of authorities

| Artifact | Owns | Does not own |
|---|---|---|
| **SF-CI-PRD-001 (this document)** | Product outcomes, target users, product capabilities and boundaries, product acceptance and scope | Backend selection, exact protocol/schema, execution grants, release approval |
| SF-CI-SPEC-001 | System architecture, technical invariants, component boundaries, technical acceptance strategy and roadmap | Unilateral changes to product intent or phase authorization |
| Accepted ADRs | Specific technical decisions within approved architecture, with rationale and alternatives | Waiving product or security requirements |
| Phase-specific technical design (TDD) | Implementation contracts, exact schemas, errors, state transitions, tests and operational design for an authorized phase | Authorizing other phases or replacing accepted requirements |
| SF-CI-P0-001 and subsequent bounded assignments | Permitted work, execution envelope, deliverables, stop conditions and phase-specific qualification criteria | Selecting production dependencies or authorizing subsequent work by implication |
| Verification evidence and independent review | Observed outcomes, findings, exact revision and test/benchmark evidence | Changing requirements merely because tests pass or fail |

Authority is scoped, not a simple universal document ranking. An execution assignment cannot waive a mandatory security constraint; an architecture decision cannot silently change a product outcome. An accepted PRD governs product intent, while the accepted architecture and applicable technical/security contracts govern implementation. Where a conflict remains, stop the affected decision, record exact document references and obtain a reviewed amendment from the relevant authority. Do not resolve conflicts by choosing the newest file, the highest search rank, or a coding agent's preference.

Until this PRD is accepted, SF-CI-SPEC-001 v0.2.1 remains the existing reviewed design baseline and SF-CI-P0-001 v0.2.1 remains the qualification assignment. Acceptance of this PRD would establish product authority for the shared requirement IDs; the architecture's product section can subsequently reference this document in a separately reviewed amendment. This extraction does not edit or supersede either source document.

### 1.3 Document lifecycle

| Transition | Guard | Side effect |
|---|---|---|
| Proposed → Accepted | Designated owner and independent review accept the exact revision; applicable conflicts resolved | Register accepted revision and scope as product authority |
| Proposed → Rejected | Authorized decision with recorded reasons | Preserve rejected revision for audit; no active authority |
| Proposed → Withdrawn | Authorized withdrawal before acceptance | Remove from consideration; preserve history |
| Accepted → Superseded | An authorized replacement revision is accepted with explicit supersession | Replace active product authority; retain previous revision for historical reviews |
| Accepted → Revoked | Authorized invalidation identifies affected scope and reason | Remove active eligibility and notify affected work owners; re-evaluate dependent decisions |

Rejected, withdrawn, superseded and revoked revisions are terminal for normal authority eligibility. Amendments create a new proposed revision; do not rewrite accepted history. Review feedback alone is not a release or execution grant. This is proposed document governance, not a requirement to implement a document workflow engine in P0 or P1.

## 2. Product vision

SF CodeIntel is a reusable, framework-aware code intelligence and evidence retrieval product that helps coding agents and developers discover, understand, implement, test and review software changes more accurately and efficiently. It provides the smallest sufficient set of relevant, verifiable evidence for a task, preserving architectural, security and lifecycle requirements while minimizing irrelevant context.

Build and maintain the tool once; use it across compatible Elixir repositories, including Phoenix, LiveView and Ash applications and umbrella projects. Each authorized workspace supplies its own source and project-specific knowledge. The product must not become a production dependency of inspected applications.

The strategic opportunity is to make smaller, less expensive implementation models capable of completing a greater proportion of engineering tasks correctly, while making stronger planning and independent review models more efficient. This is a hypothesis to prove, not an established product result.

## 3. Problem statement and opportunity

| Problem | Consequence today | Desired outcome |
|---|---|---|
| Repeated repository exploration | Agents spend calls and context locating the same functionality | Reusable, scoped knowledge and compact discovery |
| Generic symbol search misses declarative behaviour | Generated Ash actions, interfaces and applicable global changes can be overlooked | Framework-aware retrieval with explicit coverage |
| Irrelevant source and repetitive tool output | Higher context usage and weaker focus | Targeted source spans, deduplication and progressive retrieval |
| Incomplete dependency understanding | Refactors miss callers, generated interfaces or side effects | Evidence-backed relationships and impact investigation |
| Incorrect framework knowledge | Agents guess APIs or use incompatible versions | Relevant version-matched dependency guidance |
| Missing approved requirements | Technically valid changes violate business or architecture invariants | Deterministic applicable authority retrieval |
| Confusing tests with proof | Related or passing tests are treated as complete verification | Separate associations, obligations and observed results |
| Stale or cross-worktree evidence | Agents reason about a different revision or another agent's edits | Revision-bound evidence and scoped access |
| Smaller model false confidence | Unsupported conclusions are presented as complete | Explicit uncertainty, abstention and targeted next steps |

CodeIntel is an evidence-navigation product, not a substitute for engineering reasoning, direct source inspection or execution-based verification. The meaningful economic outcome is lower total cost per independently accepted task, not merely smaller index size or more impressive search results.

## 4. Target users and jobs to be done

| User | Job to be done | Desired experience |
|---|---|---|
| Developer / maintainer | Understand unfamiliar code and locate exact implementation | Install once, register a repository, search and inspect without application startup |
| Implementation agent | Make a correct change under relevant requirements | Receive compact target, contracts, constraints and tests; request exact evidence as needed |
| Planning agent | Identify boundaries, work scope and dependencies | Obtain a repository/domain orientation and uncertainty before assigning work |
| Refactoring agent | Change shared behaviour without missing affected interfaces | See incoming references, contract changes, dynamic gaps and relevant verification |
| Test / debugging agent | Investigate failures and missing behavioural evidence | Locate error sites, associated tests, lifecycle and negative-path obligations |
| Security reviewer | Examine authorization and alternate entry points | Find actor/tenant propagation, policies, bypass candidates and gaps |
| Independent final reviewer | Assess exact candidate changes against authorities and CI | Receive an investigation package without delegating merge authority |
| Software Factory operator | Enable repeatable, bounded access across concurrent attempts | Provision isolated workspace intelligence and observe availability, usage and failures |

Initial delivery serves local developers and experimental coding agents. Persistent multi-agent administration and sophisticated review workflows are later capabilities, not MVP prerequisites.

## 5. Product objectives and non-goals

### 5.1 Objectives

1. Reduce unnecessary file exploration, discovery calls and model-facing context.
2. Increase accurate discovery of relevant symbols, domain behaviour, dependencies and requirements.
3. Improve or preserve independently assessed implementation quality and first-pass acceptance.
4. Support multiple repositories without introducing per-application production infrastructure.
5. Provide transparent, revision-bound evidence with precise source locations and uncertainty.
6. Preserve security, authorization, lifecycle and independent verification requirements throughout optimization.
7. Reduce total cost per accepted task, including implementation retries, verification and allocated operating costs.

### 5.2 Explicit non-goals

- A replacement IDE, general-purpose language server, autonomous coding agent, or orchestration platform.
- Automatic merge approval, branch-protection bypass, or certification that a change is safe.
- Arbitrary application evaluation, production database access, code generation or modification through the read-only intelligence interface.
- A perfect runtime call graph, proof of all possible behaviours, or guaranteed discovery of every dependency in arbitrary metaprogrammed code.
- Mandatory cloud inference, external embedding APIs, model training or GPU infrastructure.
- Cross-project knowledge disclosure by default or automatic organization-wide graph traversal.
- Full semantic support for all programming languages, distributed scheduling, advanced vectors, or a graphical dashboard as a prerequisite for initial delivery.

Authorized non-Elixir source and operational artifacts remain discoverable as basic source/lexical evidence where relevant. Full semantic adapters for other languages are deferred. A future controlled code-transformation product must have a separate write-authority boundary.

## 6. Product scope and compatibility

| Project type | Intended experience |
|---|---|
| Plain Elixir library/application | Generic symbol, source, reference and test discovery |
| Phoenix / LiveView application | Generic intelligence plus supported routes, pipelines, sessions, hooks, handlers and template relationships |
| Ash application | Generic intelligence plus supported domain, resource and action-centred evidence |
| Ash + Phoenix | Combined supported cross-framework relationships |
| Umbrella application | Application-aware identities, dependencies and ambiguity reporting |
| Projects using Ash extensions | Additional intelligence only for explicitly supported and qualified extensions/versions |
| Temporarily broken/uncompiled source | Useful static results where possible, with explicit degradation |

Support is a declared compatibility matrix, not a promise that every Elixir, OTP, Phoenix or Ash version will work. A project may be supported for static navigation but not effective compiled metadata. The product must detect and report such differences. It must not upgrade the inspected project's dependencies to make indexing easier.

Project-specific requirements, custom DSLs and conventions may need approved configuration, annotations or future adapters. Generic framework understanding cannot infer unknown business intent. Repository settings can narrow or request capabilities but cannot grant access or mark themselves approved.

## 7. Normative product requirements

The following IDs are retained from the architecture baseline (§01). Detailed implementation constraints remain in SF-CI-SPEC-001 and applicable accepted TDDs/ADRs. A supported capability is accepted only when its declared scope and verification criteria are met; partial results are useful but do not establish full support.

| ID | Product obligation |
|---|---|
| CI-R01 | One independently maintained installation MUST support multiple authorized repositories and compatible Elixir/Phoenix/Ash versions, including umbrella layouts. Repository-specific knowledge MUST remain appropriately scoped. |
| CI-R02 | Static discovery MUST work without evaluating target code, starting the application or requiring its database. Given installed tools and permitted inputs, deterministic retrieval MUST not depend on external model calls. |
| CI-R03 | Results MUST distinguish declared, compiler-observed, inferred, dynamic, unresolved and runtime-observed evidence. Unsupported or ambiguous relationships MUST NOT be presented as confirmed facts. |
| CI-R04 | Every result MUST be scoped to an authorized workspace, captured input manifest and snapshot. Source excerpts MUST have independently verifiable ranges and hashes. |
| CI-R05 | Within declared support, framework intelligence MUST surface applicable actions, interfaces, policies, validations, transitions and associated tests. It MUST expose gaps in effective or dynamic behaviour. |
| CI-R06 | Retrieval MUST enforce token and work budgets, disclose truncation and missing mandatory evidence, and enable targeted follow-up. Mandatory evidence MUST NOT be silently discarded to satisfy a budget. |
| CI-R07 | Updates MUST remove obsolete live evidence and publish consistent generations. A broken compilation MUST NOT suppress useful static evidence. Historical and live evidence MUST be distinguishable. |
| CI-R08 | The agent intelligence interface MUST be read-only. Build, application execution and runtime evaluation require separate authorization. |
| CI-R09 | CodeIntel MUST be optional to target applications. Its absence, failure or removal MUST NOT prevent ordinary development or production execution. |
| CI-R10 | Independent review MUST verify the exact PR diff, CI and all applicable approved authority references, including relevant source. CodeIntel MUST NOT approve merges. |
| CI-R11 | Backend access MUST be confined before data ingestion. Filtering output after unauthorized data has already been read or persisted is insufficient. |
| CI-R12 | Mandatory authority MUST be resolved deterministically before ranking can exclude requirements. Incomplete scope, conflict or budget MUST NOT be described as complete. |
| CI-R13 | Live freshness MUST be reported as an observation at a specified check, not as a guarantee of future filesystem state. |
| CI-R14 | Reuse MUST be evaluated before duplicating generic structural graph/ranking functionality. Technical ownership and adoption decisions require qualification. |

CI-R14 is a product delivery constraint preserving simplicity and maintainability; it does not mandate a particular vendor or package. CI-R05 and CI-R12 describe the long-term product and do not imply all framework/authority intelligence is required for P0 or the thin P1 pilot.

## 8. Capability catalogue

### 8.1 Structural and source intelligence

The product should locate exact module/function/action identifiers, signatures, arities and declaration spans, and discover relevant functionality from natural-language task descriptions. It should find incoming and outgoing relationships, delegate targets, relevant documentation and tests within supported coverage. Exact lookup should not depend on semantic similarity. Dynamic or ambiguous resolution must be identified as such.

Users must be able to retrieve source evidence directly when a compact signature or relationship is insufficient. Authorized templates, migrations, SQL, configuration, JavaScript, CI, infrastructure and operational documentation must remain discoverable where relevant, even without dedicated semantic parsers.

### 8.2 Ash action-centred intelligence

The primary framework navigation unit is an Ash action. A task-oriented action view should attempt to locate the following evidence categories. Delivery is progressive; support for each category must be qualified independently.

| Category | Desired evidence |
|---|---|
| Contract | Action type, accepted attributes, arguments, defaults, types, return expectations, generated interface mapping and options |
| Scope | Actor, tenant and scope propagation; explicit bypass or override candidates |
| Authorization | Applicable resource/domain authorization, policy conditions, authorizers, bypasses and field policies |
| Behaviour | Local/global changes, validations, conditions, ordering, preparations and atomic compatibility |
| Persistence | Relationship management, destination actions, identities, constraints, migration intent, data-layer configuration, calculations and aggregates |
| Atomicity and transactions | Declared atomic requirements, locking, transaction boundaries, hooks and external effects |
| Lifecycle | Initial states, transitions, guards, side effects, explicit terminal states and rejected paths |
| Entry points and effects | Generated interfaces, callers, web entry points, jobs, notifications and relevant external dependencies |
| Verification | Associated tests, approved verification obligations, and independently identified run results when available |

The product must distinguish declared DSL from effective compiled metadata and from observed runtime behaviour. For example, a policy declaration is not proof that a particular actor is authorized, a migration declaration is not proof of deployed database state, and a missing outgoing edge is not proof that a state is terminal. A runtime observation establishes only what was observed in its identified conditions.

### 8.3 Phoenix and LiveView intelligence

The product should connect supported routes and pipelines to controllers or LiveViews, live sessions, mount hooks, event bindings and handlers, code interfaces and underlying actions. Progressively include components, assigns, verified navigation, JavaScript hooks, streams and PubSub candidates. Constructed topics and dynamically selected event targets remain unresolved unless evidence establishes them. HTTP pipeline protection alone does not establish authorization of LiveView behaviour.

### 8.4 Architectural authority intelligence

The product should retrieve accepted project-level, domain-level, resource/action, cross-cutting and feature-specific requirements as applicable to a task. An approved registry and deterministic scope rules establish mandatory authority independently of optional relevance ranking. Version-matched dependency guidance is supplementary, not project approval. Repository text claiming approval cannot establish its own authority.

When scope is uncertain, the result must identify unresolved applicability. Conflicting accepted requirements must be reported and escalated. If mandatory requirements exceed the budget, the response must identify incomplete coverage and offer a bounded continuation or budget error. Inferred associations may guide investigation but cannot satisfy mandatory scope. The independent reviewer must verify all applicable accepted authorities, not merely those the index returned.

### 8.5 Verification and review intelligence

The product should distinguish a source reference to a test, a test association, a reviewed intended requirement-to-test mapping, observed execution and a passing test in an identified run. These must not be collapsed into a generic claim of verified behaviour.

Later review capabilities should compare exact base/head revisions, describe structural changes, locate direct and potential impacts, surface removed/renamed entities and identify verification obligations. Unresolved impact is not verified unaffected. The result is a review investigation aid; the independent reviewer retains responsibility for exact diff, CI for the candidate revision, source and all applicable approved authority references.

### 8.6 Task-oriented evidence and context efficiency

Return a compact orientation or task package first, with targeted source retrieval as needed. Attempt relevant evidence profiles for discovery, action implementation, authorization, lifecycle changes, refactoring, debugging and review. Provide relevance reasons, source references, freshness, coverage, remaining obligations and follow-up options. Deduplicate repeated source spans and avoid repeated context only when the client can establish it remains available to the model.

The user and agent must be able to request more detail without rebuilding the index. Full machine-readable evidence may differ from compact model-facing output, but neither may misrepresent provenance or completeness. Product success is measured using actual agent sessions, including tool schemas, serialization and repeated context, not simply raw internal response size.

## 9. Product experience and principal use cases

The following are intended workflows, not existing commands or tested behaviour. Exact CLI commands, configuration keys, MCP schema and error contracts belong in the technical authority.

| ID | User journey | Expected product outcome |
|---|---|---|
| UC-01 | Install and register a permitted repository | Detect compatible capabilities and produce a useful static index without application changes or unexpected execution |
| UC-02 | Connect a supported coding agent | Preview setup, preserve existing settings, bind permitted workspace and expose a small read-only tool surface |
| UC-03 | Discover unfamiliar functionality | Return ranked relevant candidates, exact locations, meaningful relationships and honest gaps |
| UC-04 | Implement an Ash action change | Retrieve contract, applicable guards/policies/effects, lifecycle, callers, requirements and tests within declared coverage |
| UC-05 | Investigate authorization or lifecycle | Surface alternate entry points, actor/tenant context, transitions, guards, effects and negative-path verification obligations |
| UC-06 | Refactor a shared interface | Identify confirmed and potential impacts, direct callers, unresolved paths and related contracts |
| UC-07 | Work while editing or compilation fails | Continue supported static navigation; disclose stale or invalid evidence; remove obsolete live results after refresh |
| UC-08 | Verify a reported fact | Retrieve exact source and evidence identity; allow direct repository inspection |
| UC-09 | Review a PR | Bind investigation to exact immutable revisions and independently accessible CI/authority evidence; never approve the merge |
| UC-10 | Run multiple Factory attempts | Each authorized attempt receives scoped intelligence without access to another unauthorized worktree |
| UC-11 | Recover or remove the tool | Rebuild derived state or uninstall without breaking the target application; preserve only authorized retained evidence |

### 9.1 Local developer journey

1. Install a verified supported release independently of the target application.
2. Register the authorized repository and inspect detected language/framework coverage.
3. Build or refresh static knowledge and verify health/status.
4. Preview and configure an agent integration, or use the command-line interface directly.
5. Ask for task context, inspect the necessary exact source and perform normal edits using existing tools.
6. Refresh affected evidence, perform separately authorized compilation/tests and continue independent review.

Simple changes may be faster with direct source reads. CodeIntel must not force an expensive graph query into every task. If the product or backend is unavailable, the user should be able to fall back to normal development tools.

### 9.2 Illustrative implementation journey

Task: prevent a suspended account from updating a profile. In a fictional Ash/Phoenix application, CodeIntel would locate the profile update action and account-status declaration, attempt to retrieve applicable authorization and lifecycle requirements, identify callers and existing tests, and report any unresolved dynamic check. The agent reads the exact source, selects the correct enforcement layer, implements the change and verifies negative paths. This illustration is not a claim about the actual NewYou repository.

### 9.3 Factory journey (later)

A Factory-authorized work item is bound to a specific attempt and worktree. CodeIntel can prepare a small initial context package before execution and provide further scoped evidence on demand. The attempt remains governed by existing execution and access controls. Revocation, cleanup, retention and access to historical evidence are explicit operator concerns. The product cannot bypass the Factory's authorization or secure execution boundary.

## 10. Non-functional product requirements

| Quality attribute | Expected behaviour |
|---|---|
| Security and confidentiality | Deny unauthorized ingestion and retrieval; do not expose secrets or other workspaces; no unapproved network, project execution or runtime evaluation. |
| Integrity and provenance | Bind claims to captured inputs and origin; verify evidence ranges; no mixed generations presented as consistent. |
| Freshness | Distinguish matched-at-check, changed-since-check and unknown; exact source must be re-read before modification. Strict review uses immutable revision evidence. |
| Reliability | Degrade honestly when a backend or compilation fails; recover or rebuild derived knowledge without corrupting valid evidence. |
| Usability | Minimal setup, actionable compatibility/failure diagnostics, clear retrieval reasons and targeted follow-ups. |
| Performance | Optimize actual useful evidence delivery; include refresh, source materialization and freshness checks in measured latency. |
| Resource efficiency | Bound storage, memory, CPU, query work and worker lifetime; scale by concurrent workspaces/agents, not target application customer traffic. |
| Portability and compatibility | Publish the qualified platform, framework, backend and agent-client matrix; support project-specific locked versions within declared coverage. |
| Maintainability | Reuse qualified existing capabilities before building replacements; keep central updates independent of application releases. |
| Auditability | Preserve enough authorized evidence to reproduce qualification and review findings; avoid unnecessary conversation, secret or customer-data retention. |

A read-only agent interface alone is not hostile-agent isolation. In a shared local developer identity, the trust assumption must be disclosed. Strong isolation requires actual enforced boundaries. These outcomes are mandatory where the relevant capability is claimed; their concrete mechanisms and detailed state machines remain technical authority.

## 11. Product stages and MVP definition

### 11.1 Qualification is not a product release

P0-A qualifies a bounded synthetic fixture against existing tool candidates. It may recommend reuse, extension or rejection and may finish with negative or partial results. It must not be interpreted as implementation approval or proof of agent productivity. P0-B is separately authorized and optional; if not run, defer it explicitly to P1.

### 11.2 Thin MVP (P1)

The first useful product increment is a standalone, scoped CLI and experimental read-only agent interface capable of serving compact, source-grounded evidence to actual agents. It is accepted only after its own detailed design and authorization, and after a useful pilot against a matched baseline.

| In the MVP | Not required in the MVP |
|---|---|
| Reusable installation and scoped use across two authorized repositories | Persistent multi-agent Factory control plane |
| Qualified generic backend and normalized evidence contracts | Full Ash extension catalogue or production compiled bridge |
| Basic source, symbol/reference navigation and source verification | Comprehensive Phoenix/LiveView graph |
| Compact task context and experimental read-only agent integration | Full approved-authority registry and automated PR packages |
| Explicit provenance, freshness, coverage, errors and security boundaries | Embeddings, quantization, shared overlays and distributed infrastructure |
| Measured early agent usage and matched comparisons | Dashboard, autonomous transformations or automatic merge approval |

The pilot must not label unavailable framework/authority features complete. Guidance and version-matched documentation can enter early experiments without requiring the entire authority platform. P1 proves usefulness; P2 establishes incremental Ash-specific value. It would be premature to declare a full Ash-aware product solely on P1 evidence.

### 11.3 Capability roadmap (aligned with SF-CI-SPEC-001 §16)

| Phase | Product milestone | Outcome required before considering next gate |
|---|---|---|
| P0-A | Backend qualification | Reproducible evidence and proposed reuse/extend/reject decision |
| P0-B | Optional early agent experiment | Exploratory evidence if separately authorized; otherwise defer to P1 |
| P1 | Thin usable MVP | Useful, scoped navigation and measured agent pilot |
| P2 | Ash action intelligence | Demonstrated incremental framework-specific evidence and honest gaps |
| P3 | Phoenix, authority and guidance | Improved contract compliance and mandatory-scope/verification coverage |
| P4 | Compiled enrichment | Additional effective framework coverage within authorized execution boundary |
| P5 | Factory integration | Concurrent attempt/worktree isolation, recovery and operational readiness |
| P6 | Review and refactoring intelligence | Revision-bound structural impact and measured reviewer benefit |
| P7 | Optional optimizations | Measurable incremental benefit over strongest applicable baseline; otherwise omit |

No dates, staffing, cost commitments or implementation authorization are implied. Every phase requires its own gate decision. Security/provenance apply from the first prototype, even though the full persistent service is deferred.

## 12. Success metrics and product validation

### 12.1 Primary outcome

**Cost per independently accepted task** = total attributable model, execution, verification, failed-attempt/rework, indexing and allocated operating/maintenance costs divided by the number of independently accepted tasks in the evaluated workload. Use a ratified cost-allocation method and report uncertainty. Zero accepted tasks is not a zero-cost success; report the denominator and no finite observed cost per acceptance.

Track first-pass acceptance, critical security/lifecycle violations, full-session tokens, discovery tokens/calls, time to relevant evidence, end-to-end completion time, rework, actual tool adoption, incorrect resolved relationships, missing mandatory evidence, useful recall and correct abstention. Measure smaller, intermediate and stronger models separately where applicable.

### 12.2 Proposed product targets — not achieved results

| Measure | Initial target | Technical gate reference |
|---|---|---|
| Supported exact lookup | 100% on curated fixtures | G1 |
| Resolved relationship precision | ≥98%; report recall and unresolved separately | G2 |
| Task-relevant evidence recall | ≥90% at agreed K (initial K=10) | G3 |
| Critical required evidence | No silent omissions in defined fixtures; explicit incomplete status | G4, G13 |
| Median discovery context | ≥50% reduction vs matched baseline | G5 |
| Discovery tool calls | ≥40% reduction vs matched baseline | G5 |
| First-pass implementation quality | Pass pre-ratified non-inferiority criterion | G6 |
| Warm exact lookup | p95 below 100 ms on agreed reference workload | G7 |
| Incremental static refresh | p95 below 1 s on agreed reference workload | G7 |
| Unauthorized disclosure/mixed generation/unsupported freshness | Zero observed in defined negative tests | G8, G9 |
| Full-session token use | ≥15% median reduction vs ratified baseline | G11 |
| Total cost per accepted task | ≥20% reduction vs ratified baseline, uncertainty reported | G12 |
| New critical authorization/lifecycle violations | Zero observed in the defined corpus | G13 |
| Compatibility and resource limits | Qualified matrix and operational bounds met | G10, G14 |

These targets are inherited from the architecture's proposed acceptance gates (§15A). They are not mandatory P0-A thresholds; the qualification assignment owns its own predeclared criteria. Ratify workloads, hardware, denominators, baselines, sample size, margins and analysis before confirmatory tests. No silent weakening after results are observed. Zero observed failures does not prove impossibility of failure.

### 12.3 Evidence of product value

Compare against conventional direct source search and a stronger guidance-only baseline (including relevant version-matched dependency guidance). Also compare with the best qualified existing structural tools before attributing gains to CodeIntel. Match tasks, revisions, models, instructions and comparable tool/execution budgets; randomize and repeat trials; use independently reviewed expectations and held-out tasks. Include simple tasks where the product adds little value, incomplete evidence, authorization, lifecycle, contention, persistence and infrastructure changes.

The architecture proposes a non-inferiority starting margin of five absolute percentage points in first-pass acceptance and a one-sided 95% lower confidence bound on the paired difference above -5 pp; this remains subject to pre-ratification, adequate task-clustered analysis and independent review. An inconclusive result is not a pass. Aggregate quality or savings cannot compensate for critical security/lifecycle failures. A narrow pilot does not establish general production efficacy.

## 13. Product acceptance scenarios and traceability

These scenarios describe observable product outcomes. Exact fixtures, protocol assertions, thresholds per phase and security mechanisms belong to the appropriate qualification or TDD. All scenarios remain unverified until evidence is produced.

| ID | Scenario and acceptance outcome | Requirement IDs | Earliest applicable phase |
|---|---|---|---|
| PA-01 | Register two authorized compatible repositories without altering their application dependencies; retrieve independently scoped evidence. | CI-R01, CI-R09 | P1 |
| PA-02 | Perform static discovery without starting/evaluating target code, requiring its database or external model access. | CI-R02, CI-R08 | P0-A qualification; P1 product |
| PA-03 | Locate a known supported symbol/arity and retrieve its exact independently verifiable source span; ambiguity remains explicit. | CI-R03, CI-R04 | P0-A/P1 |
| PA-04 | Discover task-relevant functionality with a bounded compact package; report gaps, truncation and follow-up rather than fabricate completeness. | CI-R03, CI-R06 | P1 |
| PA-05 | Edit/delete/rename source; obsolete evidence disappears from live results; broken source is labelled and historical evidence is not called current. | CI-R07, CI-R13 | P0-A/P1 |
| PA-06 | Retrieve supported Ash action evidence including applicable policy/change/lifecycle categories; dynamic or unsupported behaviour remains explicit. | CI-R03, CI-R05 | P2; effective enrichment P4 |
| PA-07 | Connect supported Phoenix/LiveView entry points and event handlers to relevant action evidence; dynamic event/scope ambiguity is disclosed. | CI-R03, CI-R05 | P3 |
| PA-08 | Resolve mandatory project/domain/resource/cross-cutting authority before optional ranking; conflicts, unknown scope and budget overflow remain incomplete. | CI-R06, CI-R12 | P3 |
| PA-09 | Distinguish declared versus compiled metadata and observed runtime evidence; no unauthorized execution or false claim of effective coverage. | CI-R03, CI-R04, CI-R08 | P4 |
| PA-10 | Deny synthetic unauthorized reads before ingestion, cross-worktree retrieval and unauthorized execution; verify cleanup. Extend to revoked/expired Factory access in P5. | CI-R04, CI-R08, CI-R11 | P0-A/P1; Factory P5 |
| PA-11 | Compare exact base/head evidence, return impacts and verification obligations without treating test association as proof or approving a merge. | CI-R03, CI-R04, CI-R10 | P6 |
| PA-12 | Demonstrate independently reviewed reuse decision without unnecessary replacement structural infrastructure. | CI-R14 | P0-A |
| PA-13 | Disable or remove CodeIntel; target application and ordinary development continue; authorized derived knowledge can be rebuilt. | CI-R07, CI-R09 | P1 and release |
| PA-14 | Demonstrate actual agent efficiency while meeting quality and critical safety criteria under a ratified comparison. | CI-R01–CI-R14 as applicable | P1 pilot; later confirmatory gates |

Phase references indicate earliest planned applicable evidence, not blanket acceptance at that phase. PA-10 and other security-related obligations must be enforced from the outset wherever applicable; later phases extend rather than introduce those obligations.

## 14. Product risks and exclusions from automatic acceptance

| Risk | Product response |
|---|---|
| Overengineering before proving utility | Qualify reuse; put a thin agent pilot ahead of full platform implementation. |
| High precision but low useful coverage | Measure recall, relevant evidence and correct abstention; disclose unsupported categories. |
| Smaller model over-trusts summaries | Provide precise source, uncertainty, explicit obligations and direct verification workflow. |
| Product saves tokens but increases failed changes | Measure acceptance and total cost; reject improvements that violate quality/security gates. |
| Incomplete authority or hidden conflicting requirements | Deterministic mandatory scope, explicit uncertainty and escalation; independent verification. |
| Stale or unauthorized code in responses | Scoped captured evidence, enforced pre-ingestion containment and honest freshness observations. |
| Generic framework support is mistaken for business knowledge | Require approved project sources and explicit mappings where needed; do not infer approval. |
| Unsupported framework/provider/client versions | Publish qualified support; degrade safely, report gaps, and avoid forced upgrades. |

## 15. Current status and outstanding product decisions

- Architecture reviewed and approved in principle in the supplied independent reviews. This new PRD itself is proposed and has not received that independent acceptance.
- P0-A remains conditional on the actual environment, authorized containment, frozen fixture expectations and execution envelope required by SF-CI-P0-001 v0.2.1. No P0 execution is evidenced here.
- P0-B, P1–P7, private target access, target compilation, model expenditure, production backend adoption and Factory deployment remain separately authorized; this document grants none of them.
- Exact support matrix, selected backend, tooling versions, performance, productivity gains and operating costs remain unverified. The product owner, final confirmatory metrics and actual pilot repositories require ratification.
- The current source specification contains deferred findings CI-F16–CI-F21. They remain attached to their respective phase gates; this PRD does not close them or expand P0 to address them.

## 16. Sources and revision record

| Source | Product material used |
|---|---|
| SF-CI-SPEC-001 v0.2.1, §01 | CI-R01–CI-R14, goals, stakeholders, non-goals and terminology |
| Same, §§02–05B | Reuse boundary, deployment/onboarding experience, source/framework/action coverage |
| Same, §§06–10 | Evidence identity, freshness, context profiles, agent experience, authority and review |
| Same, §§11–14 | Access, lifecycle, security, Factory and operations obligations |
| Same, §§15–16 | Validation design, G1–G14, quality/economic proposals and phase gates |
| Same, §§17–18 | Open decisions, limitations and independent-review dispositions |
| SF-CI-P0-001 v0.2.1, §§1–7 | Qualification-only scope, admission, fixture scoring, STOP conditions and gate independence |
| Prior product discussions and supplied independent feedback | Product positioning, agent roles, scope discipline and review intent |

The source documents were inspected for this extraction. No upstream dependency research, backend execution, private-repository audit or benchmark was performed in creating the PRD. Document identifiers, proposed governance lifecycle, use-case and acceptance IDs, structure and intended repository path are author-proposed organizational decisions for review. No source authority was modified.

| Revision | Change | Status |
|---|---|---|
| 0.1 | Standalone product requirements extracted from reviewed architecture and bounded qualification baseline; preserved requirement IDs and separated product/technical/execution authority. | Proposed |

**End of SF-CI-PRD-001.**
