defmodule TagAsh.Resources.ConceptRelation do
  @moduledoc "An explicit symmetric vocabulary relation. These links never merge entities or confer access."
  use TagAsh.Resource, otp_app: :tag_ash, domain: TagAsh.Domain, data_layer: AshPostgres.DataLayer

  postgres do
    table "tag_ash_concept_relations"
    repo &TagAsh.Config.repo!/2

    references do
      reference :left_tag, on_delete: :delete
      reference :right_tag, on_delete: :delete
    end
  end

  actions do
    defaults [:read]

    read :for_tag do
      argument :tag_id, :uuid, allow_nil?: false
      filter expr(left_tag_id == ^arg(:tag_id) or right_tag_id == ^arg(:tag_id))
    end

    create :collect do
      accept [:left_tag_id, :right_tag_id, :kind]
      upsert? true
      upsert_identity :symmetric_relation
      upsert_fields []

      change fn changeset, _ ->
        get = &Ash.Changeset.get_attribute(changeset, &1)

        case TagAsh.Vocabulary.relation(get.(:left_tag_id), get.(:right_tag_id), get.(:kind)) do
          {:ok, attrs} ->
            Ash.Changeset.change_attributes(changeset, attrs)

          {:error, reason} ->
            Ash.Changeset.add_error(changeset,
              field: :kind,
              message: "Invalid vocabulary relation: #{reason}"
            )
        end
      end
    end

    destroy :destroy do
      primary? true
      require_atomic? false
      atomic_upgrade? false
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :kind, :atom,
      allow_nil?: false,
      public?: true,
      constraints: [one_of: [:related, :close_match, :exact_match]]

    timestamps()
  end

  relationships do
    belongs_to :left_tag, TagAsh.Resources.Tag, allow_nil?: false, attribute_writable?: true
    belongs_to :right_tag, TagAsh.Resources.Tag, allow_nil?: false, attribute_writable?: true
  end

  identities do
    identity :symmetric_relation, [:left_tag_id, :right_tag_id, :kind]
  end
end
