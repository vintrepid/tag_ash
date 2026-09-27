defmodule TagAsh.Resources.Tag do
  @moduledoc "One reusable label in a tag context."

  use Ash.Resource,
    otp_app: :tag_ash,
    domain: TagAsh.Domain,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tag_ash_tags"
    repo &TagAsh.Config.repo!/2

    references do
      reference :context, on_delete: :delete
    end
  end

  actions do
    defaults [:read, :destroy]

    read :for_context do
      argument :context_id, :uuid, allow_nil?: false
      filter expr(context_id == ^arg(:context_id))
      prepare build(sort: [name: :asc], limit: 1_000)
    end

    read :by_slug do
      argument :context_id, :uuid, allow_nil?: false
      argument :slug, :string, allow_nil?: false
      get? true
      filter expr(context_id == ^arg(:context_id) and slug == ^arg(:slug))
    end

    create :upsert do
      accept [:context_id, :name, :slug, :description, :color, :metadata]
      upsert? true
      upsert_identity :unique_context_slug
      upsert_fields [:name, :description, :color, :metadata]
    end
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :slug, :string, allow_nil?: false, public?: true
    attribute :description, :string, public?: true
    attribute :color, :string, public?: true
    attribute :metadata, :map, allow_nil?: false, default: %{}, public?: true
    timestamps()
  end

  relationships do
    belongs_to :context, TagAsh.Resources.Context do
      allow_nil? false
      attribute_writable? true
    end

    has_many :assignments, TagAsh.Resources.SubjectTag
    has_many :parent_links, TagAsh.Resources.TagHierarchy, destination_attribute: :child_tag_id
    has_many :child_links, TagAsh.Resources.TagHierarchy, destination_attribute: :parent_tag_id
  end

  identities do
    identity :unique_context_slug, [:context_id, :slug]
  end
end
