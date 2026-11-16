# TagAsh

TagAsh supplies reusable, hierarchical, many-to-many tags for Ash applications.
It is the shared successor to the tag models first built in Circle and later
copied into Maestro.

TagAsh deliberately separates classification from behavior. A tag can describe
a subject, and a context can constrain tags to one or many selections, but host
resources still own routing, authorization, workflow, and presentation. For
example, Dabhand uses an explicit placement resource for Reading Room, Research,
and Project membership while TagAsh supplies topics and hierarchical labels.

Configure the host repository and register the domain:

```elixir
config :tag_ash,
  repo: MyApp.Repo,
  ash_domains: [TagAsh.Domain]
```

Then run the host application's normal Ash code generation:

```sh
mix ash.codegen add_tag_ash
```

The resources use the `tag_ash_` table prefix and UUIDv7 identities. Subjects
are referenced by stable opaque strings, so TagAsh does not depend on host
resource modules or primary-key types.

### Referential integrity

All classification resources adopt the native `AshRi` resource extension.
Configure `:ash_ri, :adapter` with the host's RI metadata/schema boundary.
AshRi owns destroy hooks and review planning; TagAsh declares no host workflow.
Hosts retain authorization, policy persistence, confirmation UI and reporting.

### Vocabulary and ontology foundations

A `Context` is a vocabulary scheme, a `Tag` is a stable concept, and existing
`TagHierarchy` links express broader/narrower relationships. Labels are separate
`Label` resources with a language and preferred, alternative, or hidden kind.
Collecting a label preserves its identity; changing its kind uses `:set_kind`.
Database identities prevent two preferred labels in the same concept/language
and prevent a lexical form from occupying different kinds simultaneously.
Language tags are normalized and checked for subtag syntax; this does not claim
to validate every IANA registry entry. Legacy tag names remain plain labels and
do not invent a preferred language.

`ConceptRelation` records explicitly asserted related, close-match, or exact-match
vocabulary links. Symmetric endpoint ordering makes reverse collection idempotent.
These are vocabulary predicates, not artist identity merges, musical influence,
class inheritance, or host authorization. Hosts retain entity assertions, evidence,
review, behavioral workflows, and any stronger hierarchy profile.

`TagAsh.Vocabulary.export/5` converts already-authorized contexts, tags, labels,
hierarchy links and concept relations to SKOS JSON-LD. It never fetches private
host resources. IDs survive renaming; alternate labels do not merge homonyms.
Export rejects conflicting preferred/alternative/hidden labels and related links
that also have a broader path in the supplied graph. This is not an OWL reasoner
or a concurrency-safe validator for every persisted graph mutation: hosts must
serialize their vocabulary edits and validate the complete relevant graph.
After adopting this library revision, generate and review the host migration for
`tag_ash_labels` and `tag_ash_concept_relations` before using these resources.

### Library verification

The library intentionally requires a host repository. Its tests provide a
synthetic host, so strict standalone verification uses the test environment:

```sh
MIX_ENV=test mix do format --check-formatted + compile --force --warnings-as-errors + test
```

Hosts additionally verify their own generated migrations, database constraints,
and authorization boundary. Library unit checks do not replace those checks.
