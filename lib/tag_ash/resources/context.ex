defmodule TagAsh.Resources.Context do
  @moduledoc "A named tag vocabulary with an optional cardinality constraint."

  use Ash.Resource,
    otp_app: :tag_ash,
    domain: TagAsh.Domain,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tag_ash_contexts"
    repo &TagAsh.Config.repo!/2
  end

  actions do
    defaults [:read, :destroy]

    read :by_key do
      argument :owner_ref, :string, allow_nil?: false
      argument :key, :string, allow_nil?: false
      get? true
      filter expr(owner_ref == ^arg(:owner_ref) and key == ^arg(:key))
    end

    create :upsert do
      accept [:owner_ref, :key, :name, :description, :cardinality, :metadata]
      upsert? true
      upsert_identity :unique_owner_key
      upsert_fields [:name, :description, :cardinality, :metadata]
    end
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :owner_ref, :string, allow_nil?: false, public?: true
    attribute :key, :string, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, public?: true

    attribute :cardinality, :atom,
      allow_nil?: false,
      default: :many,
      public?: true,
      constraints: [one_of: [:one, :many]]

    attribute :metadata, :map, allow_nil?: false, default: %{}, public?: true
    timestamps()
  end

  relationships do
    has_many :tags, TagAsh.Resources.Tag
  end

  identities do
    identity :unique_owner_key, [:owner_ref, :key]
  end
end
