# P0 synthetic qualification corpus

This package fixes the synthetic source bytes, ground truth, capability
requirements, and eligible scoring cohorts for SFCI-4. P0-A remains
`NOT ADMITTED / NOT RUN`. Treat the Elixir, HEEx, SQL, and config files as
source text. R04 contains a syntactically valid unresolved local call.
The broken lifecycle variant is the sole syntactically malformed input.

## Source states and expectations

`manifest.json` records the allowlisted inputs, worktree labels, full
materialized path inventories, and mutation recipes. A later authorized
materialization starts with the present `fixture/` paths, with that prefix
removed. Apply only the named recipe operations, checking each precondition,
every resulting state, and the declared tracking status. Keep recipe inputs
and the synthetic canary outside the fixture root. The explicit path universe
includes absent `mix.lock`, rename and deletion tombstones, and the
allowlisted untracked input. Scope labels describe the fixture.

A source ID hashes the `resolved` object as compact UTF-8 JSON with sorted
object keys, ASCII strings without escape sequences, and no final newline.
Sort bindings by path prefix and paths by path, both in byte order. The
longest matching prefix determines scope. The empty prefix covers root
files. The source ID excludes the state label, before/after history,
worktree and commit identity, backend generations, and event records.
Both restoration recipes return to the G0 source ID. Recovery and capture
observations require independent event evidence.

`expectations.json` binds to the manifest digest. Each case lists its
assertions and points to the symbol and span records used as evidence.
Symbol keys are local identifiers. Compare their recorded qualified name,
arity, kind, language and binding for identity. Span offsets are zero-based,
half-open UTF-8 byte offsets. Lines and UTF-8 byte columns are one-based.
A `within` span narrows a selector to its enclosing bytes. A composite
selector also binds the module, callable, declaration and source site.
SFCI-5 must independently freeze pinned support and denominator membership
against the accepted corpus hashes before qualification output. Apply the
ratified §5A thresholds with the recorded coverage rules and report the
separate gates on their own evidence.

## Static checks

From the repository root, use the pinned authoring base and exact candidate.

```sh
corpus_base=2fd41db862ea03d7e6b9d3996bc00a004c56159e
corpus_head=$(git rev-parse HEAD)
git diff --check "$corpus_base" "$corpus_head"
git diff --name-status "$corpus_base" "$corpus_head"
git ls-tree -r "$corpus_head" -- benchmarks/corpus/p0
git diff "$corpus_base" "$corpus_head" -- benchmarks/corpus/p0
```

Compare the tree to the approved expanded allowlist. Every leaf must be a
regular non-executable blob. Read each exact blob with
`git cat-file blob <head>:<repo-relative-path>` and verify its bytes against
`SHA256SUMS`. After checking that the checkout matches that tree, run
`sha256sum -c SHA256SUMS` from this directory. Parse JSON with duplicate-key
rejection. Recompute each source ID, reconstruct every recipe and both
restorations, round-trip spans and selectors, and compare case, assertion,
and cohort membership to the approved plan.

Record the commit, corpus tree object, manifest and expectations digests,
checksum-file digest, exact verification commands and their outcomes.
Independent candidate review and the separate GOV §8 integration check
precede acceptance. The Lead Orchestrator records the integrated hashes
for SFCI-5.
