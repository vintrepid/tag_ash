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
