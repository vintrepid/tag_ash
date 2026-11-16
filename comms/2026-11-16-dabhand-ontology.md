# Dabhand TagAsh ontology vocabulary claim

Owner: Dabhand agent. Canonical checkout/Users/vince/dev/tag_ash, branch
feature/tag-ash/ontology-vocabulary-20261115, base41773a38049c22b902d4c9390d8cb9abbf67a07f.
Current main was refreshed from the old clean checkout; consumer pins stay fixed.

Claim: generic multilingual alternative labels, typed vocabulary relations,
existing hierarchy validation and vocabulary interchange/tests. Reuse Context as
a scheme, Tag as a concept and TagHierarchy as broader/narrower. No second
concept/scheme hierarchy or host-specific artist/song classes in the library.
Host applications retain authorization and their evidence-bearing entity models.
No shared Maestro Tool edit, migration, deployment or other app branch switch.
Dabhand's existing image52fe062a is already live; its release hooks are monitored
separately. Publish/verify the library before any consumer pin adoption.

Implemented first slice: Label resources with normalized language/NFC lexical
forms, preferred/alternative/hidden kinds, unique preferred-language and lexical
identities; ConceptRelation resources with canonical symmetric related,
close-match/exact-match pairs. Context/Tag/TagHierarchy remain the existing
scheme/concept/hierarchy. Pure Vocabulary matching preserves homonym ambiguity;
SKOS JSON-LD export retains stable URNs and checks supplied-graph lexical and
related/hierarchy conflicts. Legacy names remain rdfs:label without inventing
language. No entity merges or host access grants.

Complete standalone gate uses the configured synthetic test host:
MIX_ENV=test mix do format --check-formatted + compile --force --warnings-as-errors + test
Passed12 tests, session35885 exit0, /private/tmp/tag-ash-vocabulary-final-gate.log.
An initial dev-mode strict compile correctly rejected missing host Repo config;
no warnings or checks were disabled. Locked dependencies restored with deps.get;
no dependency-version changes. Host migration/database/authorization verification
is still pending; consumer pins have not changed during Dabhand’s active rollout.
No claim of an OWL reasoner or serialized validation of all persisted graph edits.
