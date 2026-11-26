# SF CodeIntel
## Technical Architecture Specification

**Document ID:** SF-CI-SPEC-001  
**Revision:** 0.4 (proposed correction to the standalone technical architecture)\
**Date:** 26 November 2026\
**Status:** Proposed. Exact-revision independent review and joint adoption with PRD v0.1 are pending. The inherited v0.2.1 architecture was approved in principle. P0-A remains conditional on execution admission. Implementation, backend adoption and release require separate decisions.\
**Scope:** System architecture, technical invariants, component boundaries, technology qualification strategy and technical delivery gates for reusable Elixir, Phoenix and Ash code intelligence.
**Intended repository path:** `docs/architecture/SF-CI-SPEC-001.md`
**Product reference:** SF-CI-PRD-001 v0.1 upon joint activation with this architecture v0.4. See §01.
**Qualification reference:** SF-CI-P0-001 v0.2.1 was the separation source and remains the qualification baseline until the separate compatible P0 v0.3 decision takes effect. Verify activation through [GOV §3.3](../governance/SF-CI-GOV-001.md#33-coordinated-adoption-procedure).

### Design intent
Build one independently versioned development tool that indexes each authorized repository and worktree, understands framework-specific behaviour, and returns a compact, source-grounded evidence package to an agent. Reduce exploration cost without reducing engineering or review quality.

**Index broadly. Retrieve selectively. Verify precisely. Execute securely.**

### Decision summary
- Reuse existing language tooling first; qualify Dexter and Dexterity as a candidate structural kernel; evaluate Expert/ElixirLS when gaps or selection risk justify it.
- Use Sourceror for precise source extraction and public Ash/Spark/Phoenix APIs for effective compiled metadata.
- Prototype a thin standalone CLI and read-only MCP/context workflow early, then progressively enrich and integrate a factory-governed persistent service; never add a production runtime dependency to target applications.
- Make exact/lexical/graph retrieval the baseline; embeddings are optional and must earn their place through benchmarks.
- Bind every query to an authorized workspace and a consistent evidence generation. Distinguish immutable snapshot integrity from point-in-time live freshness. Resolve mandatory approved authority before ranking; disclose gaps.

### Revision 0.2 scope
Incorporates independent review findings CI-F01–F13. Long-term requirements remain the destination, not the first implementation. Only bounded P0 qualification is recommended for initial authorization; later phases require separate gate decisions. See the accompanying P0 task and the disposition register in section 18.

### Revision 0.2.1 scope
Narrow amendment following the second independent review: correct P0/P0-B sequencing (CI-F14), require a ratified execution envelope and predeclared qualification criteria (CI-F15), and record deferred CI-F16–F21 in section 18. No change to the approved long-term architecture. The companion SF-CI-P0-001 Revision 0.2.1 governs qualification admission; P0-B and P1+ remain separately authorized.

### Revision 0.3 scope
Separates product authority from technical architecture without changing the inherited technical design. Replaces the duplicated product requirement table with traceability to SF-CI-PRD-001, clarifies the ownership of qualification and release criteria, and adds a revision/adoption record. Preserves the technical sections, numbering, proposed contracts, open decisions and review history from v0.2.1. No phase is authorized by this revision.

### Reading guide
01 Authority, scope and traceability · 02 System architecture · 03 Technology and qualification · 04 Deployment and setup · 05 Extraction and adapters · 06 Knowledge model · 07 Storage and snapshots · 08 Retrieval and context · 09 Agent interfaces · 10 Authority and review · 11 Lifecycle · 12 Security · 13 Factory integration · 14 Operations · 15 Validation · 16 Delivery roadmap · 17 Decisions and sources · 18 Independent review disposition.

## 01 | Technical authority, scope and traceability
### Purpose and authority boundaries
This document defines **how SF CodeIntel is architected**, the technical invariants that implementations must preserve, the responsibilities of its components, and the strategy for qualifying, integrating and verifying them. It is a system-level specification, not a finalized detailed design for every subsystem. Candidate technologies, examples and proposed interfaces are not accepted dependency selections or implemented contracts.

| Artifact | Governing scope | Boundary |
|---|---|---|
| SF-CI-PRD-001 — Product Requirements Specification | Product outcomes, users, capabilities, product scope and product acceptance | Does not select implementation technologies or grant execution |
| SF-CI-SPEC-001 — this architecture | System structure, technical invariants, component ownership, security boundaries, technical validation strategy and phase dependencies | Does not redefine product intent or independently authorize a phase |
| Accepted ADRs | Specific technical decisions and rationale within the applicable architecture | Cannot waive product obligations or technical/security invariants |
| Phase-specific TDDs and technical contracts | Exact types, interfaces, schemas, errors, state transitions, tests and operational design | Must implement the applicable accepted architecture; do not authorize work outside the phase |
| SF-CI-P0-001 and subsequent bounded assignments | Execution scope, admission, resource limits, deliverables, phase-specific qualification criteria and STOP conditions | Cannot waive security constraints, accept a backend for production or authorize another phase |
| Verification evidence and independent review | Observed results, exact revisions, test/CI/benchmark evidence, findings and gate recommendations | Does not silently amend requirements, contracts or execution grants |

Authority is scoped rather than a global precedence order. Where an applicable product requirement, architecture invariant, accepted ADR, TDD or execution assignment conflicts, stop the affected decision, record exact document IDs/revisions and clauses, and obtain an accepted amendment from the responsible authority. Do not choose an interpretation merely because a document is newer, a search result ranks higher, or an agent prefers it. Execution must satisfy all applicable constraints; missing authorization denies the operation. Architecture or product approval is not merge, release or execution approval.

### Adoption and transition from the combined specification
Keep the combined SF-CI-SPEC-001 v0.2.1 baseline applicable until joint adoption of SF-CI-PRD-001 v0.1 and SF-CI-SPEC-001 v0.4 takes effect. Record the exact revisions, effective scope and explicit supersession of the combined baseline in that joint decision. SF-CI-P0-001 v0.2.1 governs until the separate compatible decision for P0 v0.3 takes effect. Verify both decisions and their activation conditions through [GOV §3.3](../governance/SF-CI-GOV-001.md#33-coordinated-adoption-procedure). Subsequent accepted document revisions must retain explicit compatibility or resolve conflicts through reviewed amendments.

Use the document governance lifecycle in SF-CI-PRD-001 §1.3 for these authority revisions (proposed, accepted, rejected, withdrawn, superseded, revoked; see its guards, side effects and terminal semantics). This is documentation governance, not authorization to implement a document workflow engine. Preserve accepted revisions and review evidence; edits create new proposed revisions. Technical domain lifecycles remain governed by §§11–11B of this document.

### Product requirement traceability
The original `CI-R01`–`CI-R14` identifiers are retained. Their product-level wording, user experience and observable acceptance scenarios (`PA-*`) belong to SF-CI-PRD-001 §§7–13 upon coordinated acceptance. The following matrix is a navigation aid into the technical design, not another normative definition of the requirements. Technical controls remain binding within their applicable accepted scope, and qualification evidence must distinguish unsupported, unresolved and failed cases.

| Product ID | Primary technical realization | Principal validation references |
|---|---|---|
| CI-R01 | §§02–05A, 07, 13: reusable core, compatible project-specific workers and scoped workspaces | PA-01; G10; P1/P4/P5 |
| CI-R02 | §§04–05A, 12: static source-only path, separate authorized execution bridge | PA-02; Q0; P0-A/P1 |
| CI-R03 | §§05–06, 08–09: evidence origin, target resolution, coverage and diagnostics | PA-03/04/06/07/09/11; G2–G4 |
| CI-R04 | §§06–07, 09, 11–13: manifests, ranges, hashes, grants and provenance | PA-03/09/10/11; G1, G8, G9 |
| CI-R05 | §§05B, 08, 10: action-centred framework extraction and evidence profiles | PA-06/07; G3, G4; P2–P4 |
| CI-R06 | §§08–09A, 10–11B: budgets, continuation, mandatory evidence and incomplete responses | PA-04/08; G4, G5, G11, G13 |
| CI-R07 | §§07, 11A, 14: incremental invalidation, atomic publication and static degradation | PA-05/13; G7–G9 |
| CI-R08 | §§04A, 05A, 09, 12–13: read-only agent tools and separate execution authority | PA-02/09/10; Q0; G8 |
| CI-R09 | §§04, 14, 15A: standalone packaging, optional tooling, rebuild and removal | PA-01/13; G10 |
| CI-R10 | §§09–10, 15A, 16A: immutable review revision, CI and authority verification | PA-11; P6; release evidence |
| CI-R11 | §§03, 05, 12–13: pre-ingestion confinement, worker isolation and safe artifacts | PA-10; Q0; G8, G14 |
| CI-R12 | §§08, 10, 11B: deterministic mandatory scope, conflicts, authority revisions and incomplete delivery | PA-08; G4, G13; P3 |
| CI-R13 | §§07, 09–10: snapshot integrity distinct from observed live freshness | PA-05; G8, G9 |
| CI-R14 | §§02–03, 16: single structural owner, qualification and reuse gate | PA-12; Q0; P0-A |

PA-14 (agent efficiency and quality) spans the applicable product requirements; §§08A, 15–15A and 16 establish the technical measurement and phased evaluation strategy. Gate IDs and phase references are traceability links, not automatic claims of coverage or acceptance. The qualification task owns its predeclared P0 criteria; full-product gates are not implied P0 requirements.

### Technical scope boundaries
Retain the inherited engineering constraints: no custom language server, autonomous modifications, production evaluation, cross-project graph, cloud model dependency, vector database, distributed scheduler, GPU, or comprehensive dynamic call-graph proof in the initial release. No claim of complete semantic coverage. Full semantic support for other languages is a future adapter opportunity. Authorized SQL, migrations, HEEx, JavaScript, configuration, CI, infrastructure and operational docs remain discoverable as basic lexical/source evidence from the outset where relevant. Product capability and MVP boundaries are defined in the PRD; §16 describes their technical sequencing rather than broadening them.

### Terminology
Repository = stable registered identity; workspace = authorized checkout/worktree; manifest = exact input inventory and content digests; snapshot = immutable published index generation; evidence = source or structured observation with provenance; authority = approved requirement with scope and revision; context package = bounded response linked to a snapshot. These technical definitions are retained from v0.2.1.

## 02 | System architecture and boundaries
### Logical architecture
```text
Authorized repository / worktree
    |-- static reader --> language backend (Dexter candidate)
    |-- source reader --> Sourceror + DSL adapters
    |-- isolated build --> compiled metadata bridge (optional)
    |-- approved docs --> authority + UsageRules adapters
    v
Normalization + evidence validation
    v
Canonical snapshot: symbols / edges / spans / coverage / FTS
    |-- exact + lexical retrieval
    |-- typed graph traversal (Dexterity candidate)
    |-- optional semantic retrieval (later)
    v
Context compiler --> CLI / scoped MCP / Factory gateway
```
The index is not the source of truth for implementation or authorization. It stores observations tied to source and approved artifacts. Source and framework claims coexist rather than overwriting one another. The graph is logical; SQLite is the default candidate store, not a graph database requirement.

### Component ownership
| Component | Responsibility and boundary |
|---|---|
| Workspace manager | Identity, allowed roots, manifest capture, access binding, freshness and retention. |
| Language backend | Generic definitions/references; no final authority on framework meaning. |
| Extractors | Static DSL nodes, isolated compiled metadata, version-specific compatibility. |
| Knowledge kernel | Normalization, typed edges, provenance, coverage and atomic generations. |
| Retrieval/context | Intent routing, ranking, evidence profiles, budgeting and continuation. |
| Interface adapters | CLI, MCP and factory calls; no duplicate retrieval implementation. |
| Authority registry | Approved source identity, scope, precedence and contradictions. |
| Operations | Resource bounds, telemetry, health, upgrade, rollback and reconciliation. |

### Structural ownership and reuse gate
Dexterity is a candidate structural kernel for generic graph traversal, ranking, repository maps, export and impact analysis. Prefer a thin adapter over a second complete structural engine. The canonical evidence contract is independent of physical storage: generic data may be referenced or imported from a qualified version-bound backend rather than copied wholesale. CodeIntel owns evidence normalization, authorization, framework/authority enrichment and response composition. P0 MUST recommend one owner for generic indexing, graph invalidation and generation identity; document unavoidable duplication, cost, and reconciliation. If the backend cannot export or query a stable generation, either isolate a frozen copy for extraction or report unsupported; do not claim snapshot consistency from a live backend.

### Dependency direction
Interfaces depend on application services; services depend on contracts for storage, extraction, authorization and execution. Adapters implement those contracts. The canonical evidence format MUST NOT depend on Dexter's database schema or Nx tensor internals. The factory owns execution authorization, not CodeIntel. For standalone operation under a shared developer OS identity, registered roots and application checks are a convenience boundary, not strong hostile-agent isolation. Strong isolation claims require distinct identities and OS-enforced access controls even locally.

## 03 | Technology stack and qualification
| Technology | Role / decision |
|---|---|
| Elixir / OTP | Core CLI, parsing workers, retrieval and supervision. Select supported runtime and pin release build. |
| Sourceror | Proposed foundational source-range and AST navigation library. Native parser remains a viable fallback; no cross-module resolution guarantee. |
| Dexter (Go) | First candidate for static symbol and reference indexing. Prefer supported CLI/LSP/export contracts; inspect daemon/cache isolation. [R1] |
| Dexterity (Elixir) | Candidate graph/ranking/repo-map reuse; verify compatibility, token bounds and immutable export. [R2] |
| Expert | Strategic alternative for generic language intelligence and generated-code coverage. [R3] |
| ElixirLS / ElixirSense | Comparison and possible compiler/environment enrichment; not a mandatory second server. |
| Ash / Spark / Phoenix | Public version-matched introspection for effective DSL metadata. [R4–R6] |
| SQLite / Exqlite / FTS5 | Proposed canonical local store and lexical index. Validate driver, FTS availability, migrations and concurrency. |
| UsageRules | Dependency-specific rules/docs; retrieve selectively, not all at startup. [R7] |
| MCP + CLI | Read-only agent interface and deterministic automation; select compatible transport library after qualification. |
| Nx / Bumblebee | Optional local embedding experiments after baseline. Igniter, Tidewave, AshAI and Spitfire are later or conditional tools. |

### Qualification protocol (Q0)
The following is the architecture-level qualification strategy. The applicable accepted SF-CI-P0-001 assignment owns actual admission, fixture counts, permitted operations, ceilings, pass criteria and STOP conditions. Q0 does not grant access or enlarge that envelope; any additional evaluation requires separate authorization.

Pin commits/releases and record licenses, supported runtimes, binary hashes, SBOM, build procedure, platform and API versions. Start with ripgrep/direct reads, Dexter and Dexterity at pinned revisions. Evaluate Expert and ElixirLS in a separate bounded comparison if a material compiler-intelligence gap or selection risk remains. Include alias/import resolution, multi-clause/default-arity functions, generated interfaces, invalid source, file deletion, worktree switches and concurrency. Verify each against manually reviewed expected evidence. Inspect process startup, all reads/writes (including dependencies, caches, symlinks, ancestor paths and standard library), network activity, daemon/socket lifetime, formatting/rename/reindex and macro resolution execution paths, schema coupling, memory and generation consistency. Use an authorized disposable fixture with OS-enforced confinement for adversarial tests; no target evaluation without separate authorization. Do not adopt a direct internal SQLite read unless no stable export works; if unavoidable, wrap in a version-specific adapter and test compatibility.

**Decision rule:** choose the smallest qualified backend combination that meets correctness, isolation and latency gates. Dexterity is not assumed to support Ash semantics or factory authority; prefer wrapping or contributing a bounded extension before replacement. A minimal client/context experiment (P0-B) may run only after backend isolation and basic correctness pass and separate authorization is obtained; otherwise explicitly defer it to P1. UsageRules and guidance-only baselines are included when the agent experiment is authorized. Record PASS/PARTIAL/FAIL/NOT RUN and unresolved blockers; never select a backend on upstream claims alone. Do not bundle all candidates. Published performance claims are not acceptance results.

## 04 | Packaging, install and project onboarding
### Distribution model
Maintain a separate `sf-codeintel` Git repository and release artifacts for supported OS/architecture combinations. Build an OTP release with a thin CLI launcher (or equivalent self-contained packaging), pinned backend executables and a manifest of tool versions/hashes. Ship the compiled-extraction bridge as a separate versioned artifact. Development and factory release profiles use the same core library. Do not install CodeIntel into target application production releases or require `mix.exs` edits for static mode.

### Proposed user workflow (commands are not implemented)
```bash
# Install a verified release via the future documented installer.
# Register a repository from a trusted developer shell.
sf-codeintel register /opt/projects/newyou --name newyou
sf-codeintel index --project newyou --mode static
sf-codeintel status --project newyou
sf-codeintel search --project newyou 'password reset'
sf-codeintel doctor --project newyou
# Explicitly request compiled enrichment, if authorized.
sf-codeintel index --project newyou --mode compiled
# Configure an agent only after showing/reviewing the changes.
sf-codeintel setup-agent --project newyou --agent codex
```
Registration detects Git roots, app/umbrella layout, `.ex`, `.exs`, `.heex`, `mix.lock`, configuration, migrations, tests and approved docs. Static discovery MUST parse, not evaluate, `mix.exs` or lock files; ambiguous dependency detection produces a diagnostic. No automatic `mix deps.get`, startup, network fetch or code execution. Re-registering the same authorized root is idempotent; a name is a display alias, not an authorization identifier.

### Deployment paths (proposed)
| Local development | Factory host |
|---|---|
| XDG config/state/cache roots; per-user process | Dedicated non-privileged service account; protected `/var/lib/sf-codeintel` |
| OS user authorizes repository roots | Factory issues attempt-scoped grants and workspace bindings |
| CLI and stdio MCP | Scoped stdio proxy or authenticated internal gateway |
| Per-worktree index | Separate worktree snapshots; shared immutable bases only later |

Install upgrades require checksum verification, schema compatibility checks, rollback procedure and a fresh `doctor`. `setup-agent` must preview changes, preserve existing agent settings, and never silently register broad filesystem access.

## 04A | Project configuration and agent setup
### Optional repository configuration
```toml
# .codeintel.toml (proposed schema; not a security policy)
[project]
name = "newyou"
auto_detect_frameworks = true

[index]
include = ["lib", "apps", "test", "config", "docs", "priv/repo/migrations", "assets", ".github/workflows"]
# Root deployment files and approved operational artifacts are discovered separately.
exclude = ["_build", "deps", "node_modules", ".git", ".env*"]

[authority]
paths = ["AGENTS.md", "docs/adr", "docs/specifications", "docs/security"]

[retrieval]
default_token_budget = 2500
maximum_graph_depth = 2

[features]
compiled_introspection = false
embeddings = false
```
Defaults cover root `mix.exs`, `mix.lock` and toolchain manifests independently of include globs. Configuration may narrow selection or request features, but never expand server policy, authorize compilation, follow escaping symlinks, or designate its own documents as approved. The effective config is the intersection of trusted deployment policy, workspace grant and validated project preferences. Unknown keys or invalid paths produce actionable diagnostics. Project-owned settings are untrusted inputs.

### Agent registration examples (future launcher)
```toml
# Codex configuration example; trusted workspace binding required.
[mcp_servers.codeintel]
command = "sf-codeintel"
args = ["mcp"]
```
```bash
# Claude Code example (confirm supported client syntax at setup time).
claude mcp add --transport stdio --scope user codeintel -- sf-codeintel mcp
```
The launcher discovers a registered local root only when operating under the developer's identity. Factory launchers instead receive an authenticated, attempt-bound grant from trusted orchestration; the model cannot choose the root. For Cursor/OpenCode, generate and validate their current documented client configuration at release qualification. MCP setup never embeds provider secrets or exposes indexing/execute/rename tools.

## 05 | Source extraction and language backend
### Static pipeline
1. Enumerate authorized files from a pinned manifest. Exclude ignored/sensitive paths according to centrally enforced policy. Enforce file, byte, recursion and time limits; normalize relative paths.
2. Use the qualified backend for generic indexing and selectively parse files with Sourceror when precise source ranges or DSL semantics require it; avoid a second full repository parse without evidence of need. Collect modules, function clauses, arities, macros, delegates, types/specs, behaviours, protocol implementations, docs, aliases/imports, captures, guards, errors and calls. Index test names and meaningful literals.
3. Import generic definitions and references from the selected backend. Normalize scopes, arities and positions. Do not interpret a textual remote call as a resolved target without appropriate resolution evidence.
4. Extract framework DSL nodes using source context and zipper navigation. Preserve declared entity spans and generation origins. Use a tolerant parser only if qualified; mark recovered spans partial.
5. Emit a normalized extraction batch with manifest ID, extractor and backend versions, coverage and structured diagnostics; validate before import.

### Parser safety
Untrusted parsing can intern atoms without evaluating code. Ordinary BEAM process recycling does not reclaim the VM atom table. Use bounded disposable OS processes/separate BEAM instances for untrusted parsing, with memory, CPU, atom count/limit, nesting, file size and output limits; qualify parser atom options for compatibility rather than assuming they are safe drop-in settings. Kill/reap the process tree on timeout and verify cleanup. The trusted kernel never imports target AST terms containing arbitrary newly interned atoms.

### Backend contract (conceptual Elixir behaviour)
```elixir
# Implementations may use an external executable or a library.
@callback capabilities() :: map()
@callback refresh(binding :: map(), manifest :: map()) :: result()
@callback export(binding :: map(), generation :: binary()) :: result()
@callback definitions(binding :: map(), query :: map()) :: result()
@callback references(binding :: map(), query :: map()) :: result()
@callback status(binding :: map()) :: result()
```
Use typed structs and explicit tagged errors in production; `result()` is a placeholder for the final type contract. Export includes versioned symbols, edges, origin spans, diagnostics, coverage and observed generation. The adapter must report unsupported export, stale backend, timeout, invalid artifact or partial result explicitly. Only the kernel may publish canonical snapshots. Reject mixed generations.

### Resolution and precision
Track source-level references separately from compiler-observed calls. Static alias/import resolution must respect lexical scope. Dynamic `apply/3`, behaviours selected by config, protocol dispatch and generated functions remain candidate/dynamic/unresolved where warranted. A backend without exact ranges may still contribute navigation hints, not fabricated evidence. Use compiler tracers and Mix Xref only when authorized and relevant; file-level xref edges are not a complete function call graph.

## 05A | Compiled enrichment and version compatibility
### Bridge design
The central service never loads target applications into its own BEAM. A short-lived worker uses the target's pinned Elixir/OTP, dependency lock, compile environment and build artifacts. Resolve a supported bridge for that combination. A factory worker is launched only through the approved execution boundary; local developers must explicitly authorize project code execution. Dependency acquisition is a separate governed step. Prefer existing matching artifacts; any compilation is untrusted project code execution.

```text
Request -> authorize -> freeze input manifest -> isolated worker
  -> compile/load matching modules (no app.start by default)
  -> versioned JSON/NDJSON artifact -> validate -> enrich snapshot
```
Do not claim zero side effects merely because supervisors are not started: Mix config, macros, compiler tasks and on-load hooks can execute. No production DB, customer data, provider credentials or unrestricted egress. Terminate worker and verify cleanup before accepting output. Disallow arbitrary serialized terms, atom creation from inputs, executable values and unbounded output. Normalize structs, atoms and expressions into bounded inert data; redact secrets and sensitive values. Artifact includes Mix environment AND target, lock digest, actual dependency source identities (including path/Git dependencies and local modifications), Elixir/OTP, framework versions, relevant configuration fingerprint, manifest digest, BEAM/build artifact identity, adapter/schema versions and coverage. Trusted launcher binds these inputs and run identity independently; worker self-reported metadata cannot establish provenance. Validate bounded worker output and mark it as a project-environment observation, not proof that a malicious project told the truth. A trusted process must not load target modules to verify them.

### Public API examples (validate for each supported release)
```elixir
Ash.Domain.Info.resources(domain)
Ash.Resource.Info.actions(resource)
Ash.Resource.Info.relationships(resource)
Ash.Resource.Info.action_inputs(resource, action_name)
Ash.Resource.Info.action_changes(resource, action_name)
Ash.Policy.Info.policies(domain, resource)
Phoenix.Router.routes(router)
```
Discover domains from declared and safely extracted configuration; do not assume a single OTP application or hardcoded `:my_app`. Use current compatible Ash 3.x for new development, but respect the inspected project's lockfile. Documentation versions observed differ; no exact latest release is asserted here. Test each supported version and extension combination, and record the matrix at release time.

### Degradation
If build fails, metadata is incompatible or a macro is unresolvable, publish a validated static-only snapshot (if policy permits) with explicit missing compiled coverage. Never reuse old compiled facts as current without matching inputs. Historical facts may be retrieved only with explicit historical scope. Runtime observations are a separate optional evidence source, not a requirement of indexing.

## 05B | Framework adapter coverage
| Adapter | Required declared/effective entities (where supported) |
|---|---|
| Elixir / ExUnit | Modules, definitions, clauses, imports, calls, specs, behaviours, test cases and explicit references. |
| Spark / Ash | Domains, resources, extension configuration, actions/types/inputs, code interfaces, attributes, relationships, identities, calculations, aggregates, data layer, multitenancy. |
| Ash policies | Resource/domain policies, action conditions, bypasses, field policies, authorizers, applicable checks; never infer actor authorization outcomes. |
| Ash changes/validations | Local and applicable global changes, validations, preparations, module targets, notifiers and known effects. |
| AshStateMachine | States, initial states, declared transitions, actions, guard references and side effects; terminal states only if supported by explicit authority or verified semantics. |
| AshAuthentication | Strategies, generated actions, senders, token resources and relevant configuration references; no secret values. |
| AshPostgres | Resource/table mapping, identities, migration references, relevant constraints; declared schema is not proof of deployed DB schema. |
| Phoenix / LiveView | Routes, scope/host, pipelines, plugs, controller target, live sessions, mounts, component/event bindings, verified route references. |
| Oban / AshOban | Workers, queues, triggers, retries and schedules; dynamic config remains unresolved. |

Adapters declare ID, version, supported framework constraints, required inputs, emitted node/edge types, coverage categories and diagnostic codes. Static and compiled batches preserve their independent evidence. Link generated actions/interfaces to DSL origins instead of inventing function locations. Link relationships from resource to relationship to destination, not from every action to every related resource.

### Action-centred evidence contract
The primary framework navigation unit is an Ash action. Each category has a result and origin (declared, effective compiled, inferred or observed), or explicit unsupported/unresolved/not applicable status. Preserve ordering and applicable conditions where known.

| Category | Required evidence where supported |
|---|---|
| Contract | Action type, accepted attributes, arguments/defaults/types, returns, generated interface argument mapping and options |
| Scope | Actor, tenant and scope propagation from entry point; explicit bypass/override candidates |
| Authorization | Resource/domain authorizers, conditions, field policies, bypasses; no runtime outcome inference |
| Changes/validations | Local/global origin, ordering, applicability, atomic compatibility and preparation/query modifications |
| Atomicity/transactions | Declared atomic requirements, optimistic locking, hooks, transaction boundaries and external effects; unresolved when dynamic |
| Data/relationships | Management modes and destination actions, identities, migration intent, indexes, data layer, calculations and aggregates |
| Lifecycle | Initial states, transitions, guards, effects, explicit terminals, rejected paths and verification obligations |
| Entry points/effects | Generated interfaces, callers, jobs, notifications, PubSub and external dependencies |

Phoenix/LiveView: connect route/pipeline to live session, on_mount, mount, actor/tenant scope, HEEx event/target, handler, domain interface and action. Index components/assigns, verified navigation, JavaScript hooks, stream update paths and PubSub topic candidates progressively. Dynamic event targets, topic construction and runtime scope are unresolved unless independently supported. A router pipeline alone does not establish LiveView authorization.

P2 delivers a narrow static Ash action slice first, with an explicitly authorized compiled experiment if needed. Broader Phoenix/authority coverage follows P3; production compiled bridge P4. Each extension has its own coverage qualification.

### Lifecycle intelligence example (fictional)
`Invoice.approve` links to declared transition `submitted -> approved`, policy, action-specific validation, global audit change and tests. If a custom change checks settlement state, store the guard's source and implementation reference; do not state that it always succeeds. A missing outgoing transition is a terminal-state candidate, not proof. Runtime traces can enrich a specific execution but must retain run identity and observed conditions. A test executing a function does not prove which caller invoked it or guarantee coverage of all cases.

### Scope priorities
P1: Elixir, ExUnit, source ranges and early MCP/context. P2: Ash action/policy/lifecycle slice. P3: Phoenix, LiveView, authority and dependency guidance. P4: qualified compiled enrichment. Extensions are separate qualification units; unsupported adapters remain discoverable in status rather than silently claiming completeness.

## 06 | Canonical knowledge and evidence model
### Entity and relationship vocabulary
Nodes: repository, application, file, module, function, clause, macro, behaviour, type, domain, resource, action, code interface, policy, validation, change, relationship, state, transition, route, pipeline, LiveView, test, worker, migration, requirement and external symbol.

| Edge | Meaning |
|---|---|
| defines / contains | Declaration ownership and structure |
| calls / delegates_to / implements | Static or observed language-level dependency |
| declares_action / invokes_action | Resource action and code interface binding |
| governed_by / applies_change / validates_with | Relevant policy, change or validation (with applicability) |
| has_relationship / targets_resource | Declared Ash relationship, not action execution |
| dispatches_to / passes_through | Web route target and pipeline |
| transitions_from / transitions_to / guarded_by | Lifecycle declaration and guard references |
| enqueues / emits_event | Declared, inferred or observed side effect; origin and resolution required |
| references_test_target / associated_test | Source reference or explicit/structural association; neither proves execution |
| verifies_requirement | Reviewed intended verification mapping, not proof of passing |
| observed_execution / passed_in_run | Bounded runtime/test observation with run, revision and environment identity |
| constrained_by / historically_cochanges_with | Approved authority and weaker historical correlation |

### Identity and provenance
Opaque symbol identity includes repository, application/module scope, compilation context where relevant, language/entity kind, qualified name and callable arity; display name is not identity. Distinguish duplicate modules across umbrella/test contexts, generated exports/default arities, conditional definitions and external dependency source versions. Clauses and generated declaration origins retain separate locations. Renames are candidate cross-revision mappings, not automatic identity equality. Snapshot membership separates versions of the same symbol. Route identities include router, method, pattern and scope/disambiguator. Never rely on line number alone. External targets use typed stubs or explicit unresolved references.

```json
{
  "edge_type": "invokes_action",
  "from": "elixir:function:MyApp.Accounts:reset/2",
  "to": "ash:action:MyApp.Accounts.User:reset",
  "resolution": "resolved",
  "origin": "compiled_declaration",
  "evidence_id": "E42",
  "snapshot_id": "S17"
}
```
Evidence records include extractor/version, repository-relative path, file digest, source byte range and line/column convention, origin, observation environment and optional generation origin. Use UTF-8 byte offsets internally and define conversions for LSP UTF-16 positions. Verify excerpt hash against the pinned source. Separate origin (declared/compiled/runtime/inferred) from target resolution (resolved/candidate/dynamic/unresolved/external). No fabricated source spans or confidence percentages. Store contradictions without silently resolving them.

## 07 | Persistence, snapshot identity and refresh
### Logical storage schema (SQLite candidate)
| Table | Key / important constraints |
|---|---|
| repositories, workspaces | Opaque IDs; trusted root binding; access scope |
| index_builds, snapshots | Build ID, generation, manifest, state, schema version |
| files | Snapshot + relative path unique; digest, size, coverage |
| symbols, locations | Snapshot + stable symbol key unique; one-to-many spans |
| edges, edge_evidence | Typed source/target IDs; direction indexes; provenance |
| documents, documents_fts | Snapshot-scoped text and metadata; exact + FTS lookup |
| authorities, diagnostics, coverage | Scope, approval, category status, reason codes |
| embeddings (later) | Snapshot + entity + model/representation version; vector dimension |

Use foreign keys, bounded inserts, indexes on both directions and type, transactional imports and migrations. FTS indexes identifiers in original and split form, paths, descriptions and permitted source. Avoid storing unrestricted raw content; immutable source blobs may be retained only under policy or excerpts read from verified matching manifests. Do not expose backend DBs directly to agents. Keep caches outside target `priv/`, releases and Git.

### Snapshot identity
Manifest covers tracked and relevant untracked worktree files, deletions, dependency lock, config, runtime/toolchain, extractor/backend versions and extraction policy. Commit SHA alone is insufficient. For a consistent generation, extract from an immutable materialization of exact manifest bytes, including permitted untracked files and dependency inputs; bind backend generation/export to that materialization. For strict review use exact immutable Git objects or an immutable checkout. A live file-by-file capture is a coherent manifest of captured bytes, not necessarily an atomic view of the entire live tree. Hash checks before/after extraction alone do not establish snapshot consistency (including ABA writes); if consistency cannot be established, do not publish a complete snapshot. Hash a canonical manifest serialization. Separate base commit, working manifest and build environment.

### Freshness observation contract
Snapshot integrity is separate from worktree freshness. For live queries report `matched_at_check`, `changed_since_check`, or `unknown`, with manifest ID, check timestamp, method, checked scope and observed generation when available. A partial scope check cannot establish whole-worktree freshness. No claim of current-at-delivery or current-at-use is possible with concurrent writes. Re-read current source and verify the expected range/hash before editing; if different, refresh and reassess. For strict review, bind to immutable candidate/base objects and exact CI revision, not a mutable checkout. Watchers are advisory; reconciliation and verified reads are mandatory. Authorization and integrity checks remain fail-closed.

### Refresh and atomic publication
Watchers schedule debounced updates; missed events are repaired by reconciliation and freshness checks. On rename/delete, remove old nodes/edges and invalidate incoming references. Macro, config, lock or toolchain changes may invalidate wider compiled coverage. Use a single writer per workspace and generation fencing; publish validated candidate and active pointer atomically in a transaction. Readers pin one generation for the entire request. Validate counts, references, spans, source digests and coverage before promotion. Failed candidates never replace the active generation. Previous snapshots can be valid but stale, so label or reject according to query policy. Recovery cleans abandoned staging artifacts and reconciles publish commits with build records.

## 08 | Retrieval, ranking and context compilation
### Query execution algorithm
1. Authenticate grant, derive workspace, pin authorized snapshot and check freshness. Bound input length, query count and work. Validate requested intent and budget.
2. Extract identifiers and classify intent (explicit caller intent preferred; deterministic rules first). Exact identifiers and errors use exact/lexical lookup; unknown feature discovery uses FTS/BM25 and optional vectors; dependency questions use typed edges.
3. Discover candidates within the authorized snapshot. Traverse permitted edge types and directions based on intent. Apply depth, fan-out, visited-set, maximum node, maximum work and time limits. Preserve reasons and unresolved targets. Ranking may order investigation. Preserve every potentially applicable target for scope resolution. If a discovery cutoff or traversal limit leaves any potentially applicable scope unresolved, report authority coverage as incomplete.
4. Resolve mandatory approved authority deterministically under §10 using the trusted registry, scope and inheritance rules. Complete this resolution before optional relevance ranking can exclude any applicable requirement. Record the applicable requirements, scope exclusions with reasons, and unresolved scope. Report incomplete authority coverage whenever the mandatory set cannot be established.
5. Rank and filter optional evidence by scope and resolution. Fuse ranked optional candidates, prioritize exact matches, and downrank generic hubs and historical correlation. Preserve ranking reasons. Reciprocal Rank Fusion is a candidate for heterogeneous ranks. Compare it against simpler rules. Populate minimum evidence profiles and deduplicate identical ranges. Preserve mandatory references and unresolved scope through rendering. Apply step 6 if mandatory evidence exceeds the budget.
6. Render a compact package; count full serialized output including metadata and continuation. Use a qualified tokenizer when available; otherwise conservative estimate and clearly report method. If mandatory evidence exceeds budget, deliver explicit incomplete status with continuation or budget error; never silently omit it.
7. Re-check grant and snapshot validity before delivery. Include evidence IDs, exact references, coverage, truncation, freshness, ranking reasons and suggested next reads. No hidden LLM call is needed for deterministic retrieval.

For CI-F16, the P3 design must cover a low-ranked applicable target, a bounded discovery or traversal that leaves potentially applicable scope unresolved, and mandatory evidence that exceeds the output budget.

### Minimum evidence profiles
| Intent | Required attempted categories |
|---|---|
| Discovery | Candidate symbols, location, purpose, relevant docs |
| Action implementation | Action, contract, policies, changes, validations, transitions, callers, side effects, requirements, tests |
| Authorization | Entry points, pipelines/hooks, authorizers, policies/checks, alternate callers, relevant negative tests |
| Lifecycle change | States/transitions, guards, action, effects, authority, terminal-state and invalid-transition tests |
| Refactor | Exact target, callers/callees, interface, dynamic gaps, tests |
| Review | Diff scope, base/head evidence, impacted contracts, authority, CI references and gaps |

A profile is an attempted retrieval obligation, not a claim that every category exists. Each category returns found, verified-not-applicable (with evidence), unresolved, unsupported, stale or truncated. Compact orientation (300–600 tokens), implementation (2,000–5,000), review (4,000–10,000) are initial tuning targets, not guaranteed completeness.

## 08A | Semantic retrieval and context efficiency
### Semantic representation (optional, after baseline)
Store exact identity independently from any vector. Evaluate names/paths, identifier splitting plus docs, behavioural fingerprints and selected source chunks. Include meaningful arguments, calls, error atoms, policy and transition names where relevant; do not attach every resource relationship to every action. Do not embed secret values. Prefer deterministic extraction over LLM-generated summaries; label any future summaries as derived evidence.

| Representation | Role |
|---|---|
| Exact identity | Reliable known-symbol lookup |
| Short signature | Feature discovery; inexpensive metadata |
| Behavioural fingerprint | Query vocabulary absent from names |
| Full source | On-demand verification; lexical fallback |

Benchmark local Bumblebee/Nx embeddings (e.g. 384-dimensional model) with normalized float32 exact search first. Record model, tokenizer, normalization, dimensions, representation version and input digest. Regenerate only changed fingerprints. A 5,000 x 384 float32 matrix is 7.68 MB raw; uint8 is 1.92 MB, excluding overhead. No storage pressure is established. Quantization is optional: per-dimension scales must be accounted for in distance, integer arithmetic widened, calibration maintained, and recall tested. Binary search needs an appropriate metric and optional rescoring. Never use random vectors as semantic evidence.

### Context savings mechanisms
Return signatures and source spans before full bodies; include only relevant code ranges. Merge duplicate evidence from lexical, graph and semantic channels. Use compact relative paths and stable evidence IDs. Optional continuation/delta packages reference an explicit manifest of still-visible evidence: a previous delivery does not prove the model retains it after context compaction. Invalidate IDs on source change or grant revocation. Do not retain conversation transcripts by default.

### Model-facing rendering and accounting
Machine format retains full versioned evidence and provenance. Agent format may use concise text, evidence IDs and a shared manifest, without removing required facts or uncertainty. Do not send both representations to the model by default. Benchmark compact text versus JSON in actual clients. Count schemas, client-added wrappers/rendering, repeated responses, input/output/reasoning tokens when available, cache billing and full session totals; identify unavailable metrics rather than invent them. Measure five progressive profiles: orientation (300–600 tokens), discovery (500–1,500), implementation (2,000–5,000), source verification (variable), review (4,000–10,000+). These are starting budgets, not hard guarantees. A deterministic behavioural fingerprint is useful for lexical search and context even without embeddings.

### Fail-open vs fail-closed
Optional vector backend failure falls back to deterministic retrieval with a diagnostic. An unavailable backend can permit scoped direct source search. Authorization, integrity and workspace mismatch fail closed; no unscoped fallback. A known changed source reference cannot be reported as matched at the latest check. The system reports exactly why a result is incomplete.

## 09 | CLI and MCP interface contracts
### CLI commands (proposed)
| Command | Contract |
|---|---|
| register / deregister | Trusted operator creates/revokes repository binding; explicit destructive confirmation for removal |
| index / refresh | Idempotent request for scoped static or authorized compiled build |
| status / doctor | Freshness, health, versions, coverage, backend and compatibility |
| search / inspect / trace | Read-only discovery, evidence lookup and typed graph traversal |
| impact / context | Bounded impact and task-specific evidence package |
| setup-agent / mcp | Preview client config and serve authorized read-only tools |

Machine mode `--json` emits stable versioned responses to stdout; logs go to stderr. Exit codes proposed: 0 success, 2 invalid request, 3 authorization denied, 4 unavailable/stale under strict policy, 5 partial when caller requires complete, 6 internal error. Document exact codes with fixtures. No secrets in arguments or logs. Read-only tools never trigger unapproved compilation.

### Initial MCP tools
| Tool | Inputs (in addition to budget where relevant) |
|---|---|
| codeintel_context | query, intent, optional targets, max_tokens, continuation; includes discovery |
| codeintel_inspect | symbol/evidence ID or bounded batch, detail, optional source range |
| codeintel_trace | seed ID, direction, edge types, depth |
| codeintel_impact | changed symbol IDs or validated diff reference |
| codeintel_status | optional coverage category; no arbitrary root selector |

Expose context/inspect/status first in the pilot; add trace/impact when qualified. CLI retains separate search. Agent profiles (planner, implementer, refactor, test, debug, security reviewer, final reviewer) select evidence needs, not permissions. Use MCP stdio initially; implement protocol initialization, version negotiation, cancellation, structured errors and output validation against the qualified library/client matrix. Keep tool schemas compact. The factory proxy provides identity, workspace and permissions out of band. Tool inputs cannot specify executables, arbitrary roots, credentials, grant authority or unrestricted paths. Limit tools to read-only operations even if upstream Dexter MCP exposes mutation or reindex methods. Direct CLI and MCP share application services and validation.

### Structured response contract
Separate delivery outcome, source freshness, coverage and truncation. Return safe, actionable error codes (e.g. ACCESS_DENIED, SNAPSHOT_STALE, BACKEND_UNAVAILABLE, EVIDENCE_NOT_FOUND, BUDGET_EXCEEDED, PARTIAL_COVERAGE). Errors must not leak other workspace existence or sensitive paths. Continuations bind the grant, snapshot, query digest and expiry; enforce limits and reauthorization.

## 09A | Example request, response and agent workflow
### Example: profile suspension (fictional NewYou-style task)
```json
{
  "query": "Prevent suspended users from updating profiles",
  "intent": "authorization",
  "max_tokens": 2500
}
```
```json
{
  "schema_version": "1",
  "status": "partial",
  "snapshot_id": "S17",
  "freshness": {"state": "matched_at_check", "checked_at": "<timestamp>", "scope": "manifest", "method": "<verification-method>"},
  "coverage": {"policies": "partial", "routes": "supported"},
  "evidence": [{
    "id": "E01", "kind": "ash_action",
    "symbol": "MyApp.Profiles.Profile.update",
    "path": "lib/my_app/profiles/profile.ex",
    "lines": [82, 103], "source_hash": "<sha256>",
    "origin": "source_declared", "resolution": "resolved",
    "reason": "Direct action match"
  }],
  "missing": [{"category": "authorization",
    "reason": "Runtime-configured check requires inspection"}],
  "truncated": false,
  "budget": {"limit": 2500, "method": "qualified_tokenizer"}
}
```
Illustrative abbreviated payload only. Production adds workspace-bound identity, manifest and extractor versions, explicit category outcomes, measured token count and continuation when relevant. Fictional symbols/paths must not be interpreted as actual project facts.

### Agent instructions (reusable AGENTS.md / skill template)
Use CodeIntel for unfamiliar or cross-cutting discovery. Prefer exact lookup when the identifier is known. Inspect actual source before editing. For Ash changes, check effective policies, transitions, inputs, validations, effects and tests. Treat stale/partial/unresolved evidence as incomplete; use bounded direct search if needed. After editing, refresh affected knowledge and run required verification. For review, independently inspect exact diff, CI and all applicable approved authorities. Never treat index output as an authorization grant or merge decision.

### Local usage
Agent receives task -> context package -> targeted `inspect`/`trace` -> normal edits -> incremental static refresh -> approved compile/test -> independent review. For a known one-line change, direct source read may be more efficient. The service should reduce unnecessary exploration, not force every task through expensive graph traversal.

## 10 | Architecture authority and independent review
### Authority registry
Ingest accepted ADRs, specifications, security contracts, lifecycle models and scoped agent guidance from approved locations. Approval, provenance and precedence are established by trusted project governance, not by repository text alone. Track document ID, revision/hash, owner, acceptance state, scope, effective version, supersession and exact requirement spans. Associate version-matched dependency guidance via UsageRules; guidance does not override project policy. Historical discussions and comments are contextual only. Unreviewed links are inferred, not binding.

```yaml
# Proposed metadata for an approved requirement (illustrative)
id: BILLING-INVOICE-LIFECYCLE-001
status: accepted
scope: billing.invoice
applies_to:
  resources: [MyApp.Billing.Invoice]
  actions: [approve, reject, cancel]
verification:
  - test/my_app/billing/invoice_lifecycle_test.exs
```
The claimed `status` in a file is not sufficient for acceptance. Validate against trusted registry/approved revision. Normative requirements, implementation, tests and runtime observations remain separate. Report conflicts with exact references; do not silently reconcile or assert violation merely because a graph edge is missing.

### Mandatory scope resolution
Trusted approved authority registry is the input, not search results. Resolve project-wide, domain, resource, action, cross-cutting security/tenancy, deployment and feature scope using deterministic inheritance and explicit applicability rules. Record registry revision, applicable requirement IDs, excluded-by-scope reasons and missing/unclassified authority. Unreviewed inferred links may suggest investigation, not satisfy mandatory scope. Conflicting accepted requirements require escalation; never choose silently by relevance. If the set cannot be established, report authority coverage incomplete. If mandatory evidence cannot fit, return explicit incomplete status, required continuation and remaining IDs or a budget error. The reviewer must independently verify every applicable approved authority; pagination does not imply completion. UsageRules guidance is version-matched and supplementary, not project approval.

### PR impact workflow
Pin base/head commit and relevant merge base, fetch exact diff and independent CI evidence through authorized tooling. Compare structural snapshots for actions, contracts, policies, field visibility, lifecycle, jobs, routes, migrations and dependency changes. Traverse reverse references and identify applicable tests and authorities for both old and new states. Include deleted/renamed entities and unresolved dynamic paths. Provide an investigation report: confirmed change, potential impact, missing evidence and next verification steps.

Impact results distinguish confirmed dependency/change, potential impact, unresolved impact, and verified unaffected within a stated verification scope. Absence of a graph reference does not establish unaffected. Identify verification obligations (including negative authorization, concurrency, lifecycle and idempotency cases) separately from associated tests and actual CI evidence.

**Review gate:** the reviewer independently verifies exact PR diff, CI checks against the exact candidate revision, relevant source and every applicable approved authority before merge recommendation. Index summaries and model-generated impact scores are not substitutes. No automated merge approval, branch protection bypass, or assertions of test sufficiency from association alone.

## 11 | Domain lifecycles: registrations and access
These state machines are proposed normative contracts. Terminal state is irreversible for that record; retries or reauthorization create a new record. All transitions have authorized actor, guard, durable outcome and audit event. Use transactions or a recoverable outbox for external effects, with idempotency keys. Reject invalid transitions and compare-and-set the expected state/version.

| Repository transition | Guard | Side effect |
|---|---|---|
| requested -> registered | Trusted owner, canonical allowed root, unique ID | Persist registration and policy binding |
| requested -> rejected | Invalid or unauthorized request | Audit safe rejection; no access |
| registered -> suspended | Operator or integrity policy | Block new grants; revoke active grants |
| suspended -> registered | Explicit reapproval and health checks | Permit fresh grants only |
| registered/suspended -> deregistered | Authorized operator | Revoke bindings; schedule retention cleanup |

Repository terminals: rejected, deregistered. New registration gets new identity unless deliberate restore policy is specified.

| Workspace transition | Guard | Side effect |
|---|---|---|
| requested -> authorized | Repository registered; scope and identity validated | Record grant reference and allowed manifest/worktree |
| authorized -> active | Workspace exists; trusted binding confirmed | Enable bounded queries |
| requested/authorized -> rejected | Invalid grant/root or activation failure | Record safe diagnostics; no queries |
| active -> released | Attempt completed or developer release | Disable queries; schedule cleanup |
| authorized/active -> revoked | Expiry, policy or explicit revocation | Deny new and in-flight delivery; fence refresh |

Workspace terminals: rejected, released, revoked. Access grant is issued only for authorized identity/scope, then active, and ends as expired/revoked/released. Expiry is checked at request admission and response delivery; never rely only on periodic cleanup. Rotation issues a new grant. Revocation cannot retract content already delivered to a model, but prevents future retrieval and invalidates handles.

### Factory-specific invariant
Attempt identity and worktree binding are separate from persistent repository registration. A new attempt must receive fresh authority. No inherited broad daemon credentials or previous worker identity. Every request is scoped even if the backend cache is shared. A local developer mode uses registered roots and OS identity; it does not confer factory authority.

## 11A | Domain lifecycles: builds and snapshots
| Index build transition | Guard | Side effect |
|---|---|---|
| queued -> extracting | Valid binding, lease/fence acquired | Capture input manifest and limits |
| extracting -> assembling | Required extractor work complete or permitted degradation | Normalize batches; record coverage |
| assembling -> validating | Candidate assembled | Validate references, hashes and schema |
| validating -> publishing | Validation/coverage policy passes | Stage immutable generation |
| publishing -> succeeded | Atomic pointer commit with current fence | Commit active snapshot and audit outcome |
| nonterminal -> failed | Fatal error, lease loss or failed validation; no commit | Record diagnostics; preserve valid generation |
| cancellable -> cancelled | Authorized cancellation before publish commit | Fence worker, clean staging |

Terminals: succeeded, failed, cancelled. A publish commit is the linearization point; cancel and publish serialize. A crash after commit reconciles as succeeded, not failed. Retry creates new build ID and fence. A superseded builder cannot publish or clear the successor's ownership. Lease timeout does not prove worker exited; terminate/reconcile before reusing execution resources.

| Snapshot transition | Guard | Side effect |
|---|---|---|
| staged -> available | Build validated and atomic publish commits | Eligible for scoped readers |
| available -> superseded | New valid generation published | Historical only unless policy allows |
| superseded -> retired | Retention and reader leases permit | Remove query eligibility; schedule purge |
| staged/available/superseded -> revoked | Integrity/security failure or access policy | Remove eligibility; invalidate handles |

Snapshot terminals: retired, revoked. Physical deletion is separate: retained -> purge_pending -> purged, with failed purge retryable under a new cleanup attempt. Guard purge by retention, legal hold if applicable and live reader lease; revocation stops new access immediately regardless of purge. Active pointer cannot reference revoked data. Freshness (matched_at_check/changed_since_check/unknown), coverage, integrity and authorization are independent properties, not lifecycle states.

### Concurrency and recovery
Single workspace publisher with generation compare-and-set; immutable readers pin a snapshot. On restart reconcile staging, lease and active pointer; verify integrity before serving. A failed build must never relabel old evidence as matched at a new verification point without independently checking it. Explicit historical queries require authorization and identify historical manifest. Snapshot identifiers are opaque, not bearer credentials.

## 11B | Domain lifecycles: extraction and context delivery
| Compiled extraction transition | Guard | Side effect |
|---|---|---|
| requested -> authorized | Matching supported toolchain, execution policy | Issue bounded execution spec |
| authorized -> running | Isolated worker admitted | Capture run ID; begin extraction |
| running -> validating | Process terminal; output captured; cleanup status known | Validate artifact and provenance |
| validating -> completed | Artifact valid; required cleanup confirmed | Make metadata eligible for build import |
| nonterminal -> failed | Denial, timeout, invalid artifact or cleanup failure | Quarantine output; audit failure |
| cancellable -> cancelled | Cancellation authorized; worker termination reconciled | Revoke execution; discard output |

Terminal states: completed, failed, cancelled. A cancellation request is not itself terminal while execution remains alive; track termination requested and cleanup separately. Never accept a semantic result as proof the worker exited. Unresolved cleanup is an operational incident and blocks reuse of affected execution resources.

| Context request transition | Guard | Side effect |
|---|---|---|
| requested -> resolving | Active grant, valid parameters, snapshot pinned | Acquire bounded read lease |
| resolving -> assembling | Candidates selected within work limits | Rank/deduplicate; evaluate evidence profile |
| assembling -> delivered | Budget and final authorization/integrity checks pass | Emit evidence package, record safe audit metadata |
| nonterminal -> failed | Integrity/authorization/budget policy failure | Return typed error; release lease |
| nonterminal -> cancelled | Caller cancellation before delivery | Stop traversal; release lease |

Terminals: delivered, failed, cancelled. Delivered may be partial, with explicit coverage and continuation. Delivery means server emitted a response, not that model consumed it; retries must remain safe. Historical package records retain manifest and evidence identifiers, not necessarily full source. Replays must reauthorize and not reproduce revoked content. A continuation is issued -> consumed/expired/revoked (or reusable within explicit bounded policy); expiry and grant scope are checked on each use.

### Authority record lifecycle
Proposed -> accepted -> superseded/withdrawn; proposed -> rejected. Only trusted approval may promote, with revision and scope validation. Supersede requires accepted replacement; withdrawal removes normative eligibility without deleting historical evidence. Rejected, superseded and withdrawn are terminal for that revision. Indexing a file cannot perform an approval transition.

## 12 | Security and trust model
### Threats and controls
| Threat | Required control |
|---|---|
| Cross-repo/worktree leakage | Server-derived scope, per-workspace stores or enforced partitions, negative authorization tests |
| Arbitrary filesystem paths, symlinks, races | Canonical root checks, safe traversal/open, no escaping links, verify opened file identity and hashes |
| Malicious source/parser DoS | Bounded isolated workers, no eval, limits on files/bytes/depth/time/atoms |
| Build-time code execution | Explicit authorization via sf-exec; isolated toolchain, no production secrets/DB, restricted egress, verified cleanup |
| Prompt injection in repo/docs | Treat content as untrusted evidence, preserve delimiters and provenance; trusted policy not sourced from arbitrary files |
| Secret leakage | Policy allowlists/deny rules, content scanning/redaction, sensitive-value handling, no raw credentials in indexes/logs |
| Corrupted/malicious artifacts | Bounded inert schema, validation, hashes, protected writes, quarantine; no untrusted ETF decoding |
| Tool abuse | Read-only gateway allowlist, validated arguments, quotas, timeouts, cancellation, no arbitrary commands |
| Stale or mixed evidence | Immutable manifest, fenced publication, recheck freshness and coverage, fail closed on integrity |
| Local daemon bypass | Protected backend endpoints/storage; agent cannot call unrestricted backend or impersonate service |
| Revoked access | Final delivery recheck, invalidate handles/caches, policy-driven retention/purge |

### Backend containment and local trust
Enforce allowed inputs before the backend reads or stores them. In Factory mode, use an OS-enforced read boundary, scoped source/dependency mounts, protected index and IPC ownership, distinct service/agent identities, controlled environment, bounded process tree and denied-by-default egress. Include ancestors, symlinks, dependency/stdlib paths, daemon caches, temporary directories and inherited descriptors in qualification. Only expose allowlisted reader operations; formatting, rename, reindex and code evaluation are not reader tools. Output filtering is defense in depth, not isolation. Same-UID unrestricted agents can bypass a local daemon ACL; document local trust assumptions and do not claim Factory-grade isolation there. Test access revocation and cancellation during streaming: a final check cannot retract already delivered bytes; terminate remaining delivery and record the boundary. Prefer bounded nonstreaming responses for the first release.

### Trust boundaries
CodeIntel is a privileged reader only of the minimum authorized repository content. Its parser workers and compiled workers are separate from the trusted kernel. Agent identity is not derived from caller-supplied root, UID string or project slug. Use OS-mediated credentials or factory-signed scoped grants verified by trusted gateway; bind grant to attempt, repository, workspace, audience, expiry and permissions. Do not expose raw backend DBs, sockets or mutation tools to agents. For remote transport (later), require authenticated encrypted channels, network policy and replay protection.

Local embeddings keep embedding inputs local; retrieved source sent to an external model can still leave the host. Apply provider/data policy separately. Sensitive annotations such as Ash `sensitive?: true` are useful metadata, not comprehensive secret detection. Audit identifiers and reason codes, not raw prompts/source by default. Security policy and approval records are outside repository-controlled authority. No production runtime evaluation in V1.

## 13 | Software Factory integration and multi-agent usage
### Integration boundary
```text
External task -> Software Factory admission -> Job / Attempt
                   |                       |
                   | workspace grant       | sf-security / sf-exec
                   v                       v
           CodeIntel service          isolated agent runtime
                   | scoped MCP proxy      |
                   +-----------------------+
                   | authorized compile request only
                   v
           isolated metadata extraction worker
```
Factory owns job admission, credentials, network policy, attempt identity, worktree and execution. CodeIntel owns indexed observations and retrieval only. Persistent control-plane services may outlive attempts; compiled workers and agent identities remain ephemeral. No new execution path bypasses sf-security or sf-exec. The architecture is consistent with the prior Factory/Paperclip/T3 discussion; actual integration contracts require repo-level verification.

### End-to-end flow
1. Factory resolves work item, authorizes target repository and prepares isolated worktree. Issues short-lived CodeIntel grant and passes trusted workspace binding to proxy.
2. CodeIntel checks or builds the static snapshot. Optional compiled enrichment is a separate admitted operation. If not ready, return explicit partial/preflight status; do not block unrelated coding solely because optional enrichment is unavailable.
3. Factory requests initial task context with bounded budget and attaches evidence manifest to the attempt prompt. Agent can request further context via MCP.
4. Agent edits within authorized worktree. Changes trigger incremental refresh and invalidate incompatible compiled observations. Agent invokes normal build/tests through execution boundary.
5. Reviewer receives exact PR revision/diff, CI and scoped impact package; independently verifies evidence. Attempt ends -> release/revoke grant and cleanup workspace according to policy.

### Multiple worktrees
Initial deployment uses separate indexes or immutable generations per authorized workspace; no blind shared mutable database. Same repository may have differing uncommitted source, deleted files and dependency versions. Future optimization: shared immutable base snapshots plus isolated overlays/tombstones, only after benchmarks establish need and negative isolation tests pass. Authorization applies to base and overlay. Do not assume agent A can see agent B's changes or a different PR's snapshot. A reviewer explicitly receives base/head grants; both must be authorized.

## 14 | Operations, telemetry and resource management
### Runtime model
CLI proof of concept can run on demand. Persistent deployment uses OTP supervision for registry, build coordinator, bounded extraction pools, query services and reconciliation. An Ash control plane may model Repository, Workspace, AccessGrant, IndexBuild and Snapshot, if it fits existing factory authority; high-volume symbols/edges/ranking remain ordinary Elixir/SQLite. Do not duplicate Factory ownership records as independent authority. Process failure is distinct from durable domain state.

| Operational area | Requirement |
|---|---|
| Health | `doctor` reports runtime/tool versions, DB integrity, backend, FTS, workspace status, bridge compatibility, MCP round-trip |
| Bounds | Operator-configurable worker concurrency, file/input/output bytes, query depth/fan-out, CPU/memory/time, disk quotas |
| Backpressure | Per-workspace queue caps, coalesce changes, reject excessive requests with retryable status |
| Recovery | Reconcile watchers, lease/fence, active pointer and staging; retain previous valid snapshot |
| Retention | Per-workspace policy, reader leases, purge on revocation/deregistration as authorized; no indefinite cache assumption |
| Upgrade | Pin schema/tool versions, migration tests, rebuild incompatible indexes, rollback binary and index pointer when compatible |
| Backup | Registry/approved authority metadata per operator policy; rebuild derived indexes; encrypted backups if retained |
| Network | No external model/API necessary for baseline; separate approved dependency acquisition and optional embeddings |

### Capacity, caches and retention
Measure 1/5/20/50/100 active worktrees progressively, with hardware and workload fixed; do not require higher tiers for local pilot. Track total disk amplification including backend DBs, WAL, caches, copied sources and staging; bound retention and clean abandoned artifacts. SQLite WAL is a candidate for concurrent readers and one writer per database; long readers and checkpoints need bounds. Separate stores initially; overlays only if measured duplication warrants. Cache keys bind workspace, snapshot, authority revision, security/extraction policy and retrieval config. Never cache authorization as a substitute for current grant verification. Invalidation precedes serving incompatible metadata; use conservative broader invalidation for macros/shared DSL, config, dependencies and domain policies. Proposed additional p95 targets: lexical <150 ms, typical action context <500 ms, complex impact <2 s; separately measure cold indexing and compiled enrichment.

### Telemetry contract (proposed names)
`[:sf_codeintel, :build, :stop]`, `[:sf_codeintel, :query, :stop]`, `[:sf_codeintel, :snapshot, :publish]`, `[:sf_codeintel, :access, :denied]`, `[:sf_codeintel, :coverage, :degraded]`. Include duration, counts, output token estimate/method, cache hit, status, diagnostic code, backend/adapter version and safe correlation IDs. Aggregate p50/p95, freshness lag, build failure, unresolved edges, budget truncation, disk growth and agent tool adoption. Never log source, tokens/credentials or prompt text by default. Limit cardinality and protect audit access.

### Runbook essentials
Stale index -> reconcile and refresh; invalid snapshot -> revoke and rebuild; backend incompatible -> disable adapter and report coverage; disk quota -> stop new builds, retire eligible snapshots; suspected leak -> revoke grants, quarantine data, preserve permitted audit evidence, investigate and rotate affected credentials. Do not silently broaden permissions to restore service.

## 15 | Test and benchmark design
This section governs technical validation methodology. Product outcomes and acceptance scenarios are owned by SF-CI-PRD-001 §§12–13 upon coordinated acceptance. P0-A is governed by the separately ratified qualification envelope and frozen expectations; later benchmark designs do not authorize P0-B, external model calls, target compilation or private repository access.

### Qualification fixtures
Construct a small synthetic umbrella/standalone fixture with source representing Ash/Phoenix conventions. P0-A is limited to the single authorized synthetic repository and does not execute or compile its target code. A later separately authorized exercise may test a representative project (NewYou candidate, not yet inspected). Ground truth must be independently reviewed, including necessary evidence not present in historical diffs. Include exact symbol, alias/import scope, clauses/default arities, macro-generated interfaces, dynamic calls, global changes, domain/resource policy, lifecycle guards, routes/live sessions, background jobs, tests, migration links, broken syntax, failed compile, deleted files and worktree changes.

| Experiment | Configuration |
|---|---|
| A | Agent + ripgrep/direct file reads (strong baseline) |
| B | A + improved agent guidance and UsageRules |
| C | B + Dexter (or qualified alternative; Expert/ElixirLS separate comparison) |
| D | C + Dexterity or equivalent structural kernel |
| E | D + thin context/MCP |
| F | E + Ash/Phoenix enrichment |
| G | F + deterministic approved authority |
| H | G + optional semantic retrieval (later) |

Compare same revisions, tasks, model versions, instructions, available editing/testing tools and comparable budgets; randomize runs and repeat to account for nondeterministic agents. Hold out tasks to avoid tuning to the test set. Record hardware, warm/cold state, dependency cache, provider token accounting and cost. Measure full task quality by blinded/independent review, not merely search clicks. Evaluate smaller and stronger models separately. Include indexing and maintenance costs in total economics.

### Suggested initial sample and metrics
Start with 30–50 curated fixtures for qualification; expand to approximately 180 independently labelled discovery, policy, lifecycle, test, impact and stale-index tasks. Measure precision/recall@K, MRR, resolved edge precision/recall, mandatory evidence coverage, exact lookup latency, refresh latency, indexing time and memory, discovery tokens/tool calls, end-to-end completion time, first-pass acceptance and total cost per successful task. Count MCP schema and repeated tool results in context cost; provider caching may change billed cost. Treat test observations as bounded evidence, not proof of universal correctness.

### Quality and economics protocol
Before collecting confirmatory results, ratify primary acceptance metric, non-inferiority margin, paired analysis, confidence level, sample size/power and stop rules. Proposed starting margin: no more than 5 percentage points absolute reduction in first-pass acceptance, with a one-sided 95% lower confidence bound on paired acceptance difference above -5 pp. Use task-clustered analysis for repeated model trials; choose enough independent tasks from pilot variance, not an arbitrary trial count. Inconclusive evidence means no confirmatory pass. Separate security/lifecycle hard failures from aggregate quality; no new critical violations in the corpus. Keep held-out tasks untouched for final evaluation. Include simple tasks where CodeIntel is unnecessary, abstention, database integrity, contention and infra/config tasks. Score actual full-session token use, tool adoption, rework, reviewer time and total cost per accepted task (including indexing, failed attempts and operations). Compare against guidance-only as well as best existing-tool baseline; identical guidance within each matched comparison.

### Security/chaos tests
Attempt cross-worktree queries, symlink escape, stale continuations, revoked grants, malicious config, secret literals, oversized files/artifacts, worker timeout, concurrent cancellation/publication, daemon crash and partial writes. Verify no app supervisors start by default and isolated compiled execution cannot reach production resources. Assert cleanup and recovery invariants with fault injection.

## 15A | Proposed acceptance gates and release checks
Targets below are inherited engineering proposals for defined fixtures/reference hardware, not measured results. They are the technical gate references (G1–G14) linked by the PRD, not a second independent product target catalogue. Ratify applicable thresholds, workloads and analysis before the relevant benchmark execution; reconcile any product-target amendment through the responsible authority. P0-A qualification has separate criteria in SF-CI-P0-001; these confirmatory gates must not be imposed wholesale on P0. A failed security gate blocks deployment regardless of performance gain.

| Gate | Target / pass evidence |
|---|---|
| G1 Exact supported definitions | 100% on curated fixtures, including arity and spans |
| G2 Resolved graph precision | >=98% against independently labelled edges; report recall and unresolved separately |
| G3 Task evidence recall | >=90% at agreed K (initial K=10); critical evidence evaluated separately |
| G4 Critical profiles | No omitted required security/lifecycle evidence on defined fixtures; report incomplete when unresolved |
| G5 Discovery efficiency | >=50% median discovery-context reduction and >=40% discovery tool-call reduction versus matched baseline |
| G6 Quality | Pre-ratified non-inferiority test passes, with independently reviewed held-out tasks; inconclusive is not pass |
| G7 Latency | Warm exact lookup p95 <100 ms; incremental static refresh p95 <1 s on agreed reference workload |
| G8 Isolation/freshness | Zero observed unauthorized disclosure, mixed generations, or unsupported freshness claims in negative tests; explicitly test concurrent writes |
| G9 Recovery | No invalid/mixed snapshot publication under cancellation, crash and lease-loss tests |
| G10 Compatibility | Supported client/tool/framework matrix, license/SBOM, install/uninstall and rebuild tests pass |
| G11 Session efficiency | Proposed >=15% median full-session token reduction vs ratified baseline |
| G12 Economics | Proposed >=20% lower total cost per independently accepted task, uncertainty reported |
| G13 Critical quality | No new critical authorization/lifecycle violations in defined corpus; unresolved mandatory authority disclosed |
| G14 Operations | Bounded CPU, memory, disk, worker lifetime and cleanup on reference workload |

### Release evidence package
Each release should include exact source revision, locked dependencies and backend versions, CI output, fixture corpus revision, benchmark reports and raw measurements, security test evidence, known coverage gaps, supported compatibility matrix, migration/rollback runbook and independent review of the actual PR diff and applicable authorities. Do not report benchmark targets as achieved. Re-run regression gates when extractor/backend/schema changes can affect correctness.

### Cost example (illustrative, not a promise)
A conventional discovery pass that reads 12 files x 1,600 tokens consumes 19,200 tokens. A context package of 2,200 plus 4,000 targeted source tokens consumes 6,200: about 68% less discovery context. This excludes tool schemas, history, reasoning, generation, provider caching and indexing. Cost per successful task = total model, execution, indexing and allocated operating cost / accepted tasks. A smaller context with more failed PRs is not a success.

## 16 | Implementation roadmap and work packages
Technical sequencing and exit dependencies are defined here. Product capability progression is described in SF-CI-PRD-001 §11; an applicable accepted phase-specific design supplies exact implementation contracts. Neither a roadmap entry nor a satisfied exit gate automatically grants permission to start the next phase.

| Phase | Deliverable | Exit gate |
|---|---|---|
| P0 Qualification | P0-A: pinned Dexter/Dexterity, strong baseline, disposable fixtures, security/interface audit and predeclared qualification under a ratified execution envelope. P0-B: optional bounded real-agent experiment, separately authorized | Backend reuse decision supported by reproducible qualification evidence. P0-B agent experiment completed if separately authorized; otherwise explicitly deferred to P1. No agent productivity or token-saving claims without measured evidence; no platform build |
| P1 Thin MVP | Scoped CLI, normalized evidence, basic source verification, compact context, experimental read-only MCP; two repositories | Agent pilot demonstrates useful retrieval, isolation and measured improvement; no full persistent service |
| P2 Ash action intelligence | Selective Sourceror extraction, action contracts, policies, changes, validations, lifecycle; authorized compiled experiment if needed | Framework-specific incremental value and honest coverage |
| P3 Phoenix and authority | Routes/live events, early UsageRules expanded, mandatory scope resolution and test associations | Contract compliance, mandatory authority and framework coverage fixtures |
| P4 Compiled enrichment | Version-matched isolated bridge, trusted fingerprints, cleanup and static fallback | Additional effective coverage and execution isolation |
| P5 Factory integration | Grants, persistent supervision, refresh, fencing, retention, observability | Concurrency/security/recovery tests and operational runbook |
| P6 Review intelligence | Immutable base/head comparison, verification obligations and independent review packages | Exact diff/CI binding, measured reviewer benefit |
| P7 Optional optimizations | Embeddings, overlays, caches only for measured gaps | Incremental benefit versus strongest baseline; otherwise omit |

### Work sequencing
Authorize only bounded P0-A initially, after the actual environment, budgets, confinement and fixture expectations are independently ratified. Qualify existing tools before writing a platform; P0-B is optional and requires separate authorization after backend access and correctness are established. If not authorized, explicitly defer it to P1; its absence does not prevent P0-A completion. Do not build an entire MCP platform in P0. P1 tests real agents before comprehensive framework infrastructure. UsageRules enters baseline experiments immediately; full authority registry P3. Security, provenance, scope and source verification are foundational from the first prototype, not deferred to P5. Later persistent lifecycle resources apply when the associated durable transitions exist; ordinary local read requests do not require a workflow database. Phase exits are scoped; confirmatory release gates apply only after their applicable features and sufficient evaluation are available.

### Backlog boundaries
Future: shared immutable base/overlay store, runtime observations via authorized Tidewave/AshAI, Igniter-backed separate CodeOps, optional quantization, other language adapters, distributed deployment. Do not introduce without measured need and explicit approval. Record unrelated discoveries as separate issues rather than derail active work. No dates, staffing or cost commitments are assumed by this draft.

## 16A | Repository layout and implementation ownership
```text
sf-codeintel/
  lib/sf_codeintel/
    application.ex
    backends/            # Dexter / Expert adapters, contract
    extraction/          # Parser, bridge, normalization
    adapters/            # Ash, Spark, Phoenix, ExUnit, extensions
    knowledge/           # Symbols, edges, provenance, coverage
    storage/             # SQLite schema, FTS, migrations
    workspace/           # Registry, manifests, bindings
    snapshots/           # Builds, fences, publication, retention
    retrieval/           # Exact, lexical, graph, optional vectors
    context/             # Profiles, ranking, budgets, continuations
    authority/           # Approval registry, rules, requirements
    impact/              # Base/head structural comparison
    security/            # Scoped authorization and safe paths
    interfaces/          # CLI, MCP, factory gateway
    telemetry/           # Events, diagnostics, health
  bridge/                # Versioned isolated metadata extractor
  config/                # Tool-owned configuration, not target secrets
  test/                  # Unit, contract, integration, adversarial
  test/fixtures/         # Plain Elixir, umbrella, Ash/Phoenix
  benchmarks/            # Ground truth, runners, reports
  docs/                  # ADRs, contracts, operator setup/runbook
  mix.exs
  mix.lock
```
This layout is proposed, not a mandate to scaffold empty modules. Introduce directories only as work requires them. Keep pure extraction and ranking independent of transport and persistence. Define explicit contracts for backends, extractors, artifact codec, storage, grant verifier and execution broker. Use descriptive code labels/comments and typed structs; avoid ambiguous catch-all maps in production interfaces. Unit tests validate parsers/ranking; contract tests validate candidate integrations; integration tests exercise full lifecycle and agent transport; adversarial tests protect boundaries.

### CI pipeline
The pipeline below describes the eventual engineering/release checks, not a requirement to scaffold a production project or run target compilation during P0. Apply only the checks within the authorized phase and report non-applicable checks explicitly.

Format/lint -> compile with warnings policy -> unit/fixture tests -> backend contract tests (pinned) -> integration and security tests -> benchmark smoke -> packaging/SBOM -> release evidence. Full benchmark suites may be scheduled separately, but release decisions require current relevant results. No merge recommendation without independent exact diff, CI and approved authority verification. Use ADRs for irreversible choices: backend selection, schema/protocol, transport, execution boundary, storage/retention and semantic adoption.

## 17 | Decisions, open questions and source register
### Decisions proposed for ratification
| ID | Decision / qualification |
|---|---|
| D01 | Standalone reusable tool, no production application dependency. |
| D02 | Deterministic baseline, typed evidence graph, SQLite candidate, read-only agent surface. |
| D03 | Dexter/Dexterity lead candidates, Expert/ElixirLS alternatives; actual choice after P0. Sourceror preferred for custom DSL extraction. |
| D04 | Current compatible Ash for new code; inspected projects use lockfile versions and explicit adapter compatibility. |
| D05 | Static and compiled facts separate; compiled extraction explicitly authorized, isolated and not `app.start` by default. |
| D06 | Factory governs execution/access; persistent service cannot bypass sf-security/sf-exec. |
| D07 | Embeddings, quantization, distributed store and transformations deferred. |

### Open questions / blockers before implementation approval
Confirm supported OS/CPU and target toolchain matrix; choose first real repo and obtain authorized checkout; inspect exact Factory APIs and authority documents; qualify Dexter/Dexterity exports, licensing, security, graph and token-budget behaviour; select MCP and SQLite libraries; decide retention, grant transport and benchmark hardware. Verify framework APIs and dependency versions at pinned releases. No external tool was installed or executed, no actual repo was audited, and no performance claim was reproduced for this specification. Configuration, interfaces, state machines, schema and thresholds are proposed design choices, not approved or deployed functionality.

### Primary references (inherited public documentation register; checks dated 25 Nov 2026 in v0.2.1, not repeated for v0.3)
[R1] Dexter — https://github.com/remoteoss/dexter (source index, MCP/daemon; checked)
[R2] Dexterity — https://github.com/nshkrdotcom/dexterity (repo map/graph candidate; checked)
[R3] Expert — https://github.com/expert-lsp/expert (official LSP; checked)
[R4] Ash Resource Info — https://ash.hexdocs.pm/Ash.Resource.Info.html (action metadata; checked)
[R5] Ash Policy Info — https://ash.hexdocs.pm/Ash.Policy.Info.html (policies; checked)
[R6] Spark / Phoenix — https://hexdocs.pm/spark/ and https://hexdocs.pm/phoenix/Phoenix.Router.html (qualification references)
[R7] UsageRules — https://github.com/ash-project/usage_rules (checked)
[R8] Sourceror — https://hexdocs.pm/sourceror/ ; https://github.com/doorgan/sourceror
[R9] ElixirLS — https://github.com/elixir-lsp/elixir-ls ; Igniter — https://github.com/ash-project/igniter
[R10] MCP — https://modelcontextprotocol.io/ ; Aider repo map — https://aider.chat/docs/repomap.html

Internal basis: prior SF CodeIntel architecture discussions and supplied Software Factory boundary notes (Paperclip/T3). These are design context, not verification of current repository implementation. All examples are illustrative unless explicitly identified otherwise.


## 18 | Independent review disposition
Historical disposition inherited from v0.2.1: all findings are accepted in principle; implementation closure remains unverified. The previous revisions resolved specification ambiguities, not runtime defects. Revision 0.3 preserves these findings and their verification deadlines; it does not close them or independently approve any execution.

| Finding | Revision 0.2 disposition | Verification owner / phase |
|---|---|---|
| CI-F01 Critical | OS boundary before ingestion, local trust caveat (03,12) | P0 containment; P5 Factory adversarial tests |
| CI-F02 Critical | Immutable manifest capture, observed freshness not perpetual current (07,09) | P0/P1 consistent generation and concurrent edits |
| CI-F03 Critical | Mandatory deterministic authority scope before ranking (08,10) | P3 scope, conflict, overflow, independent review |
| CI-F04 High | Dexterity structural kernel reuse gate (02,03) | P0 ADR and export/invalidation qualification |
| CI-F05 High | Trusted launcher provenance and environment fingerprint (05A) | P4 bridge and artifact forgery tests |
| CI-F06 High | Disposable parser VM and process-tree cleanup (05,12) | P0/P1 parser limits; P4 workers |
| CI-F07 High | Test association vs observed verification (06,10) | P2/P3 typed evidence; P6 review |
| CI-F08 High | Machine vs model rendering and actual client accounting (08A) | P0/P1 measured sessions |
| CI-F09 High | Ratified non-inferiority and economic gates (15,15A) | Pilot then confirmatory held-out benchmark |
| CI-F10 High | Early thin context/MCP experiment (16) | P0/P1 |
| CI-F11 Medium | Scoped identity and generated/conditional symbols (06) | P1 fixtures |
| CI-F12 Medium | Storage amplification, capacity, cleanup (14) | P1 basic quotas; P5 load and recovery |
| CI-F13 Medium | Basic non-Elixir evidence without new language engines (01,05) | P1 scoped discovery |

### Remaining ratification decisions
No backend, dependency release, security mechanism, benchmark threshold or Factory API is approved by this revision. Ratify the P0 scope and separately authorize access to any real repository. Decide whether to permit the optional real-agent experiment, its provider/data policy and budget. Ratify confirmatory quality tolerances and economics before measuring held-out results. Production readiness requires phase-specific implementation evidence, not document approval alone. Independent review feedback is the source for this revision; upstream versions and current tool internals have not been reverified in this revision.


### Second independent review — narrow admission amendments

| Finding | Disposition | Verification / deadline |
|---|---|---|
| CI-F14 Medium | Section 16 now makes P0-B optional, separately authorized and explicitly deferrable to P1. | Wording corrected; independent amendment review before P0-A dispatch. |
| CI-F15 High | Companion qualification assignment now specifies a proposed bounded execution envelope, admission record, predeclared correctness/security criteria and stop rules. | Design amendment complete; actual host, containment, thresholds and authorization remain outstanding before qualification. |
| CI-F16 | Deferred: candidate discovery must not silently eliminate a target before mandatory authority scope resolution; uncertain scope remains incomplete. | P3 |
| CI-F17 | Deferred: bind authority revision to context and define withdrawal/delivery ordering. | P3 |
| CI-F18 | Deferred: qualify useful coverage, recall and excessive abstention. P0 supported-reference recall is a narrow initial check, not a full product gate. | P1/P2 |
| CI-F19 | Deferred: define delivery/revocation linearization, buffered responses and successful-request lease release. | P5 |
| CI-F20 | Measure frozen input materialization and freshness-check overhead separately and in end-to-end latency; defer further optimization. | P0/P1 |
| CI-F21 | Deferred: ratify comparable workloads, cost allocation and economic gate methodology. | Confirmatory benchmark |

The supplied second review approves the architecture and P0-A in principle subject to admission. It does not authorize private repository access, target compilation, external model expenditure, P0-B, P1–P7, production backend adoption, or Factory deployment. These deferred items are recorded for their respective gates, not new P0 implementation scope. No tools were qualified and no repository was modified by this document amendment.

## 19 | Authority separation and revision record

### v0.3 separation sources
| Source document | Exact revision | Role in the v0.3 separation |
|---|---|---|
| SF-CI-SPEC-001 | 0.2.1 | Reviewed technical baseline; §§02–18 retained with narrowly scoped editorial additions and qualification/authority cross-references |
| SF-CI-PRD-001 | 0.1 (proposed) | Product authority candidate; requirement IDs, product acceptance scenarios, scope and document governance |
| SF-CI-P0-001 | 0.2.1 | Existing qualification assignment, execution envelope and admission constraints; unchanged |

These SHA-256 values identify the v0.3 separation sources. Acceptance requires a trusted decision.

```text
eec236699730173e0612bd9bfbe6d100f417119c3efe3397de2ad24905b85ced  SF-CodeIntel-Specification-v0.2.1.md
f5374a4de6e6c021334e4965c25bb0dfe4ddf5d7671bbd007412e5a497c56a30  SF-CI-PRD-001-v0.1.md
b35b92081956fffc7f50ef973afa9591da3e5aef291254af82f12f9db9c2a2ce  SF-CodeIntel-P0-Qualification-v0.2.1.md
```

### Revision history
| Revision | Change | Status |
|---|---|---|
| 0.1 | Original combined architecture and product baseline | Historical |
| 0.2 | First independent-review dispositions CI-F01–CI-F13 | Historical |
| 0.2.1 | Narrow P0 admission and sequencing amendments; CI-F14–CI-F21 dispositions | Existing reviewed baseline, conditional P0-A admission |
| [0.3](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/78e246a135da2ca65eaab87bd283af3d92f93e7f/docs/architecture/SF-CI-SPEC-001.md) | Scoped authority split, product traceability, coordinated adoption guard, and qualification and technical validation cross-references | Predecessor separation proposal |
| 0.4 | Corrects mandatory authority resolution before optional evidence ranking and updates adoption routing | Proposed corrective successor. Verify effective status through [GOV §3.3](../governance/SF-CI-GOV-001.md#33-coordinated-adoption-procedure) |

### Acceptance and outstanding work
- Independently review exact PRD v0.1 and architecture v0.4 against the combined v0.2.1 baseline and architecture v0.3 predecessor, including the PRD requirement and acceptance mapping. Jointly adopt and activate the pair under [GOV §3.3](../governance/SF-CI-GOV-001.md#33-coordinated-adoption-procedure) before relying on the separated authorities.
- Use the separately accepted compatible qualification revision after its activation under [GOV §3.3](../governance/SF-CI-GOV-001.md#33-coordinated-adoption-procedure). Preserve the admission restrictions. P0-A execution requires authorization of the actual environment and frozen expectations. P0-B and P1+ require separate execution grants.
- Do not select a backend, finalize schema/library choices or create a binding P1 TDD before the necessary qualification and decision evidence. ADR-001 must remain proposed until accepted by an authorized review.
- The reference register and implementation contracts are inherited, not reverified against upstream revisions in this document split. No code, upstream tooling, benchmark, private repository or Factory API was executed or audited for this amendment. No external authority has been accepted or changed by writing this document.

**End of SF-CI-SPEC-001.**
