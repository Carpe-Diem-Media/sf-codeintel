# ADR-002 | MCP stdio for the synthetic lexical increment

| Document control | Value |
|---|---|
| ADR ID | ADR-002 |
| Proposal revision | 0.1 |
| Status | Proposed. The trusted decision event controls eligibility. |
| Decision key | Track A MCP transport and protocol compatibility |
| Proposer | SFCI-17 documentation delegate |
| Decision owner | Lead Orchestrator under GOV §4.1 |
| Scope | One local session over a launcher-approved synthetic fixture root |
| Version applicability | Track A, MCP `2025-06-18`, proposed service `0.1.0` |
| Supersedes | None |
| Execution authorization | Separate bounded grant pending |

## 1. Context and constraints

SFCI-17 needs an authorized client to launch the actual Elixir service, negotiate MCP, list its tools and exercise source evidence and failure paths. A trusted launcher already belongs to the proposed local access model. The transport must keep that access model small, support bounded messages and process lifetime, and permit real subprocess testing on the exact hosted candidate.

Apply [SEQ v0.1](../governance/SF-CI-SEQ-001.md) under the [SFCI-16 activation](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/35b39857-d11f-43b4-88dd-20f7867c40cc#comment-7ecfb0dc-56a1-4f7d-b420-31896879f262), [GOV v0.4](../governance/SF-CI-GOV-001.md) §§4, 7–8, [ADR governance v0.1](SF-CI-ADR-001.md) §§3, 5–9 and [architecture v0.4](../architecture/SF-CI-SPEC-001.md) §§09, 11–14, 15A–17. The [SFCI-17 authoring approval](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/685e53a0-6e84-4285-9eb0-831ca53f746e#comment-f8fd49bc-ae14-45e9-a4fb-37eb9d5b6280) binds the original design with the addendum's precedence. The companion [TDD v0.1](../technical-design/P1/SF-CI-TDD-P1-LEX-001.md) owns the detailed contracts and tests. [ADR-001](ADR-001-backend-selection.md) stays Proposed. Structural ownership, Track B, P0 qualification and full P1 gates retain their existing authorities.

## 2. Alternatives

Evaluate against the same one-client, one-root, five-tool workload. Require local launcher control, pinned wire compatibility, bounded process and parsing costs, and reproducible real-service verification within approved dependencies.

| Option | Assessment |
|---|---|
| OTP standard I/O and `:json` | Proposed. One local process and a static tool list fit a small version-pinned adapter with no Mix dependencies. The project owns protocol validation and conformance tests. Actual pipe behavior and process limits require verification. |
| MCP SDK over stdio | Could supply reusable protocol handling. Requires a separate acquisition and compatibility decision, including dependency pins, transitive dependencies and licensing. There is no approved SDK dependency for this scope. |
| HTTP MCP | Introduces a listener and a separate authentication and network boundary outside the local launch scope. |
| Defer MCP and deliver CLI only | Keeps local diagnostics available. Leaves the real-client MCP milestone unmet. |

## 3. Evidence and limitations

The protocol defines newline-delimited stdio and the initialization, ping and tool contracts. OTP 28's source describes standard I/O counted reads and offers JSON decoder callbacks. These are specification and source evidence. Real-service compatibility, cleanup and permissions are pending. [MCP stdio](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports) · [MCP lifecycle](https://modelcontextprotocol.io/specification/2025-06-18/basic/lifecycle) · [MCP ping](https://modelcontextprotocol.io/specification/2025-06-18/basic/utilities/ping) · [MCP tools](https://modelcontextprotocol.io/specification/2025-06-18/server/tools) · [OTP file source](https://raw.githubusercontent.com/erlang/otp/OTP-28.0/lib/kernel/src/file.erl) · [OTP JSON source](https://raw.githubusercontent.com/erlang/otp/OTP-28.0/lib/stdlib/src/json.erl)

The design records report Elixir 1.19.3 and installed OTP 28.1.1 locally. The independent prospective review covered the written correction. Actual fixture custody, launcher behavior, local process controls, hosted toolchain pins and real product CI evidence remain open. [Binding addendum](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/685e53a0-6e84-4285-9eb0-831ca53f746e#comment-de78656a-bd25-4512-8ef4-07775bf7c08b)

## 4. Proposed decision

Use one dependency-free Elixir escript, OTP standard I/O and OTP `:json` for MCP `2025-06-18`. Use the companion TDD's bounded bytewise input framing, serial request lifecycle, negotiated version and static tool list. Limit compatibility to an authorized local subprocess client that can use the returned pinned revision. The client that cannot use it disconnects. The diagnostic CLI shares the same read-only source adapter.

The trusted launcher binds the approved absolute root and owns the child and pipes. Client arguments address only approved relative slots. The launch boundary depends on independently verified custody and launcher ownership, monotonic expiry bounded by grant expiry and immediate revocation with child reaping. Network endpoints, client-controlled root selection, persistence and structural backend selection are outside the decision.

## 5. Consequences and verification

The implementation owns compatibility with the pinned wire contract and bounded handling of stalled streams. Before acceptance, the Lead records actual custody and launcher feasibility evidence after exact independent review. Before dispatch, verify the actual local and hosted environment with approved toolchain, process controls and any explicitly authorized bootstrap artifacts. A separate bounded grant authorizes implementation and tests. The implementation must meet the companion TDD's real subprocess checks and exact PR head product CI. These results remain pending.

Reopen the decision for a new MCP revision, remote access or broader source trust. Revoking launch permission terminates use through the launcher. Reap the child and clean up disposable scratch. There is no persisted service state to migrate.

## 6. Independent review and decision history

Revision 0.1 is the initial proposal. Independent review of its exact bytes and an accountable decision event are pending. The trusted event records the immutable revision, prior and resulting status, independent review, authority, actor, time, rationale, scope and conditions. This proposal carries no qualification, implementation, integration, release or deployment authorization.
