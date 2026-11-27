# SF-CI-SEQ-001 | SFCI-18 sequencing supplement

Revision 0.1. Proposed and inactive. Verify the [SFCI-18 applicability entry](sfci-2-baseline-adoption.md#sfci-18-conditional-sequencing-applicability) before applying this supplement.

## Authority and predecessor

The authoring baseline is `9067928cb47c03e6c2613dc3f408c23ec400767e`. [SF-CI-SEQ-001 v0.1](SF-CI-SEQ-001.md) remains the authority for the original SFCI-16 increment delivered in SFCI-17. Its blob is `682e46612942c4cec01a03a8a4e13e8be8a03a3c` and its SHA-256 is `73d130cdf681872dd73ae5e4246d6085dd700008f4d2bbecc3bc9a3cf7f963f9`.

The owner strategy message `turn-item:message:f41d610e-ebb3-4ea3-b32e-ef1071447a5c` supplies drafting direction under the standing Lead mandate in GOV §4.1. The Lead released the independently approved plan and binding addendum for documentation authoring only. Adoption requires a separate trusted owner decision covering both timing changes below. That decision is pending. GOV §5 keeps adoption, technical acceptance and execution permission separate. [Owner strategy thread](t3-thread://v2/fdfd1f03-53cf-41e7-8d37-6f5313c72d55/827e7f14-c680-43c4-b7af-fd7991d7fe52) · [Authoring release](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/a2315b0a-de1b-4622-b601-c91d143c8851#comment-0ebb92f7-bdd2-42f7-a4ab-a41d1e48360a) · [Binding addendum](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/a2315b0a-de1b-4622-b601-c91d143c8851#comment-85a28254-fa63-455e-9b54-5a64509f0726)

## Timing after activation

Only SFCI-19 may proceed to bounded design before applicable P0 exit and acceptance of a viable backend. A later bounded implementation may also precede those two gates once the separate implementation prerequisites below are met. SFCI-19 depends on SFCI-18 and remains a child of SFCI-10. The exception does not extend to its parent or neighboring issues. The following references identify the authorities at the authoring baseline. [SFCI-19](https://app.plane.so/symphony-development/projects/cf209680-d677-4875-9245-ed7b235654dd/issues/4d229902-9c98-46a7-aa74-6131b8775364)

- Apply the two timing changes to the `AGENTS.md` phase-gate paragraph, GOV §§6.1 and 6.3 and §7's P1 design row, and SFCI-2 D5 and D7. Apply GOV §§3.3–3.4, 4.1–4.2, 7.1–7.2 and 8 in full. [GOV](SF-CI-GOV-001.md) · [SFCI-2 dispositions](sfci-2-baseline-adoption.md)
- Apply the same timing to SPEC §03's MCP + CLI row and §16's phase table and Work sequencing. Retain SPEC §17 slice-specific verification, including supported OS/CPU, exact toolchain, MCP transport and actual dependencies, approved synthetic root, retention, grant transport and development and CI hardware. Q0, §18 and foundational security, scope, provenance and source verification still apply. [SPEC](../architecture/SF-CI-SPEC-001.md)
- Apply the timing to TDD §§1.3, 2.3, 7, 7.1 and 10.2. Retain the other §2.3 prerequisites and §6 design review, acceptance and change control. [TDD standard](../technical-design/SF-CI-TDD-001.md)
- ADR-001 remains Proposed. Its §§3.1, 5.1–5.2 and 7, including the selected-qualified-interface row and final Next gate, govern backend selection and backend-dependent P1 design. Apply ADR governance §§2, 3, 5.2 and 8.1, including review of any material transport or compatibility decision. [Backend ADR](../adr/ADR-001-backend-selection.md) · [ADR governance](../adr/SF-CI-ADR-001.md)
- PRD §§11.2–11.3, 13 and 15 and SPEC §16 retain full P1 outcomes and exit criteria and later-phase prerequisites. SFCI-19 does not satisfy qualification, structural ownership, full P1 exit or later-phase entry. [PRD](../product/SF-CI-PRD-001.md)

## SFCI-19 design boundary

Design one MCP literal search capability, `search_text`, over the existing synthetic slots. Reuse captured bytes and manifest revalidation. Each match supplies its slot, zero-based half-open byte offsets and the full-file SHA-256 for the existing digest-guarded `read_source`. The merged lexical query and guarded read contracts, together with PRD CI-R02, CI-R04, CI-R06, CI-R08 and CI-R13, support this selection. The existing lexical TDD v0.1 §2 and its five-tool MCP contract remain the predecessor. The separately reviewed successor design must define matching semantics, limits, protocol assertions and an exact implementation allowlist before changing the advertised tools. Carry forward scope, freshness, byte-span, grant and denial controls. [Lexical TDD](../technical-design/P1/SF-CI-TDD-P1-LEX-001.md) · [Merged service contract](../../README.md)

Before implementation, require independent review and accountable acceptance of the exact design and any applicable ADR, verified development and CI environments, and a fresh bounded grant covering both local development and hosted CI. Require exact-head verification through the real MCP service under that later grant. PR #13's local and hosted allowance supplies no dispatch permission. This supplement grants no execution, provisioning, upstream acquisition, private or real repository access, backend integration, qualification or structural ownership decision.

## Track B qualification hold

Apply [SEQ v0.1 Track B](SF-CI-SEQ-001.md#track-b-preserve-the-qualification-hold) in full, including its exact hold, custody, resource accounting, deadlines and STOP evidence. SFCI-5 remains Blocked, P0-A remains `NOT ADMITTED / NOT RUN`, and the qualification clock remains `NOT STARTED`. P0 v0.5 §§0.3, 1, 1A, 3, 5A, 6, 7 and 8.3 retain their full requirements. P0-B requires its own grant and applicable prerequisites. If the applicable P0 gate proceeds without P0-B, the accountable authority must explicitly defer it to P1 and record `NOT RUN`. [P0 qualification](../qualification/SF-CI-P0-001.md)
