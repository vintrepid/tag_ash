defmodule TagAsh.Resources.SubjectTag do
  @moduledoc "A many-to-many assignment between a host subject and a tag."

  use TagAsh.Resource,
    otp_app: :tag_ash,
    domain: TagAsh.Domain,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tag_ash_subject_tags"
    repo &TagAsh.Config.repo!/2

    references do
      reference :tag, on_delete: :delete
    end
  end

  actions do
    defaults [:read]

    destroy :destroy do
      primary? true
      require_atomic? false
      atomic_upgrade? false
    end

    read :for_subject do
      argument :subject_ref, :string, allow_nil?: false
      filter expr(subject_ref == ^arg(:subject_ref))
      prepare build(sort: [inserted_at: :asc], limit: 1_000)
    end

    create :attach do
      accept [:subject_ref, :tag_id, :metadata]
      upsert? true
      upsert_identity :unique_subject_tag
      upsert_fields [:metadata]
    end
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :subject_ref, :string, allow_nil?: false, public?: true
    attribute :metadata, :map, allow_nil?: false, default: %{}, public?: true
    timestamps()
  end

  relationships do
    belongs_to :tag, TagAsh.Resources.Tag do
      allow_nil? false
      attribute_writable? true
    end
  end

  identities do
    identity :unique_subject_tag, [:subject_ref, :tag_id]
  end
end
