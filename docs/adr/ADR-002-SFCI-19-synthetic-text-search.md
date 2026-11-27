# ADR-002 supplement. SFCI-19 synthetic text search

**Proposed v0.1** · [SFCI-19](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/4d229902-9c98-46a7-aa74-6131b8775364) · Track A

## Context

The [accepted predecessor ADR-002](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/adr/ADR-002-synthetic-lexical-mcp-stdio.md) at `63eaf5563df6c01d8f171b9782b6c2cac320ee51` is blob `0473f65ac3f63eb518bed7ec8a96c4151be6edec`, SHA-256 `9d1429f2c8f70567a16dcabf024a773ecb1d33890972a0f0c0330128a0355edc`. Its [activation](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/685e53a0-6e84-4285-9eb0-831ca53f746e#comment-2386c1e9-a9b2-4f64-abd4-c5bc71366fce) covered the SFCI-17 five-tool workload. This supplement asks whether the same transport and containment can support a sixth advertised tool, `search_text`.

Proposer: SFCI-19 documentation delegate. The Lead Orchestrator owns accountable disposition under [GOV §§4, 7–8](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/governance/SF-CI-GOV-001.md) and [ADR governance](https://github.com/Carpe-Diem-Media/sf-codeintel/blob/63eaf5563df6c01d8f171b9782b6c2cac320ee51/docs/adr/SF-CI-ADR-001.md), after independent review of these exact bytes. The [SFCI-18 activation](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/a2315b0a-de1b-4622-b601-c91d143c8851#comment-2bf7c15f-5216-45d0-9121-094368f3165e) supplies only the limited sequencing exception.

## Alternatives and proposed decision

Retaining five tools and deferring search preserves the accepted workload, but leaves literal locating and span construction to the client. Extend ADR-002 for SFCI-19 only so a client can locate literal bytes in five approved synthetic slots and retrieve them with the existing digest-guarded read.

Keep one authorized client, one approved synthetic root and one launcher-owned child, using the same Elixir escript, OTP stdio and `:json`, dependency set and MCP `2025-06-18`. Affirmatively extend the accepted inventory to six only within the [successor TDD](../technical-design/P1/SF-CI-TDD-P1-LEX-002.md#2-wire-contract) bounds. Preserve the historical applicability of ADR-002. Backend selection, real repository access, broader protocol support and full P1 remain separately governed.

## Evidence and limitations

Design review must verify the exact inventory delta, unchanged legacy descriptors and schemas, bounded observation, independent guarded read, framing and pre-write authority, plus sufficient launcher and custody feasibility for the stated safety and compatibility claims. Custody and launcher feasibility evidence is unresolved and blocks acceptance where those claims depend on it. The [TDD verification and dispatch gates](../technical-design/P1/SF-CI-TDD-P1-LEX-002.md#6-acceptance-dispatch-and-change-control) require separate operator, actual environment and custody verification and fresh bounded local and hosted grants before implementation execution.

Later real-client and exact-head evidence must cover discovery, digest-guarded reads, stale and current spans, the legacy contracts, expiry/revocation and cleanup. Record evidence and limits against the exact candidate. This proposal grants no execution and records no observed results.

## Reopening criteria and history

Reopen for protocol or transport change, wider source trust, materially different resource or containment requirements, or evidence that the sixth tool cannot preserve the inherited boundaries. The Lead owns any renewed exact disposition after independent review.

Proposed v0.1 records the bounded scope extension for review under the [documentation authoring release](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/4d229902-9c98-46a7-aa74-6131b8775364#comment-bd1e6c1a-a5fe-43b5-b6a7-b215e91ab7ca). Independent review and accountable disposition of this revision are pending.
