# TagAsh Agent Rules

1. TagAsh owns generic, hierarchical, many-to-many classification for Ash applications.
2. Hosts own authorization, presentation, and behavioral domain placement such as project, research, or reading-room membership.
3. Classification never grants access and never silently changes a subject's workflow state.
4. Keep subject references stable and application-independent; never depend on a host resource module.
5. Persisted workflows use typed Ash actions. Never use raw SQL or direct repository access.
6. Change resources first and let each host generate its own AshPostgres migrations.
7. Examples and tests use synthetic data only.
