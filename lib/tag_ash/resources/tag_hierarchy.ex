defmodule TagAsh.Resources.TagHierarchy do
  @moduledoc "A directed parent-child relationship between tags."

  use Ash.Resource,
    otp_app: :tag_ash,
    domain: TagAsh.Domain,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tag_ash_tag_hierarchies"
    repo &TagAsh.Config.repo!/2
  end

  actions do
    defaults [:read, :destroy]

    create :link do
      accept [:parent_tag_id, :child_tag_id]
      upsert? true
      upsert_identity :unique_tag_hierarchy
    end
  end

  attributes do
    uuid_v7_primary_key :id
    timestamps()
  end

  relationships do
    belongs_to :parent_tag, TagAsh.Resources.Tag do
      allow_nil? false
      attribute_writable? true
    end

    belongs_to :child_tag, TagAsh.Resources.Tag do
      allow_nil? false
      attribute_writable? true
    end
  end

  identities do
    identity :unique_tag_hierarchy, [:parent_tag_id, :child_tag_id]
  end
end
