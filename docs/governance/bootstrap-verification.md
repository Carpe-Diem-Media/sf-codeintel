# Bootstrap verification

The seven attachments were copied byte for byte. The SHA-256 digests below identify the supplied bytes and the canonical copies. Exact-revision independent review and authorized adoption are pending.

## Imported revisions

- [SF-CI-GOV-001 v0.1](history/SF-CI-GOV-001-v0.1.md) `56ea641ab590ac5b0d124af432fd9a5dec4d0e44104a7396acdaa8c520da3b65`
- [SF-CI-PRD-001 v0.1](../product/SF-CI-PRD-001.md) `f5374a4de6e6c021334e4965c25bb0dfe4ddf5d7671bbd007412e5a497c56a30`
- [SF-CI-SPEC-001 v0.3](../architecture/SF-CI-SPEC-001.md) `5c7f7712b86638075c280fd236b9958c2973df7979a8b273809933e38341424e`
- [SF-CI-ADR-001 v0.1](../adr/SF-CI-ADR-001.md) `ebeb0d092ef7f134feb628df5c462a264d4246f7cf4cd846d3ecb9395ed4528f`
- [ADR-001-backend-selection v0.1](../adr/ADR-001-backend-selection.md) `708ff8f35bbe818476fd9153053413ae6fc86e592942f43c73e9e531f3d71417`
- [SF-CI-P0-001 v0.3](../qualification/SF-CI-P0-001.md) `b6021234fd7bb8d16d128a758c581a4abf288208e0f0a64f171a39f3ececec85`
- [SF-CI-TDD-001 v0.1](../technical-design/SF-CI-TDD-001.md) `ba2bdd1a242b92c2b9db9b1ab3599414ec6a41227ca005d96aa17147001bbd93`

## Archived predecessor revisions

The v0.2.1 predecessors are byte-for-byte copies of the supplied originals. Both SHA-256 digests match §11 of the [v0.1 governance register](history/SF-CI-GOV-001-v0.1.md#11-source-identity-and-revision-history).

- [Architecture specification v0.2.1](../architecture/history/SF-CodeIntel-Specification-v0.2.1.md) `eec236699730173e0612bd9bfbe6d100f417119c3efe3397de2ad24905b85ced`
- [P0 qualification assignment v0.2.1](../qualification/history/SF-CodeIntel-P0-Qualification-v0.2.1.md) `b35b92081956fffc7f50ef973afa9591da3e5aef291254af82f12f9db9c2a2ce`

## Open evidence

Independent review of the exact v0.2.1 amendments and authorized adoption of the proposed successor revisions remain pending under [governance §3](SF-CI-GOV-001.md#3-authority-register-and-adoption-status).

Canonical document paths follow the governance register. References to future qualification artifacts describe later deliverables. P0-A remains NOT ADMITTED / NOT RUN.

## Local checks

- `sha256sum -c` against the recorded digests matched all seven imports.
- A local Markdown link scan found no missing relative file targets. It checked file existence and did not validate section anchors or external references.
- `git diff --cached --check` flagged four Markdown hard breaks in the architecture attachment. The copy preserves those bytes.
