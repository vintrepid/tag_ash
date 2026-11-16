defmodule TagAsh.Resources.Label do
  @moduledoc "A preferred, alternative or hidden lexical label on a stable concept. Host applications own authorization."
  use TagAsh.Resource, otp_app: :tag_ash, domain: TagAsh.Domain, data_layer: AshPostgres.DataLayer

  postgres do
    table "tag_ash_labels"
    repo &TagAsh.Config.repo!/2

    references do
      reference :tag, on_delete: :delete
    end
  end

  actions do
    defaults [:read]

    read :for_tag do
      argument :tag_id, :uuid, allow_nil?: false
      filter expr(tag_id == ^arg(:tag_id))
      prepare build(sort: [language: :asc, kind: :asc, value: :asc])
    end

    create :collect do
      accept [:tag_id, :language, :value, :kind]
      upsert? true
      upsert_identity :lexical_label
      upsert_fields []
      change &__MODULE__.normalize/2
    end

    update :set_kind do
      accept [:kind]
      require_atomic? false
      change &__MODULE__.normalize/2
    end

    destroy :destroy do
      primary? true
      require_atomic? false
      atomic_upgrade? false
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :language, :string,
      default: "und",
      allow_nil?: false,
      public?: true,
      constraints: [max_length: 63]

    attribute :value, :string, allow_nil?: false, public?: true, constraints: [max_length: 512]

    attribute :kind, :atom,
      default: :alternative,
      allow_nil?: false,
      public?: true,
      constraints: [one_of: [:preferred, :alternative, :hidden]]

    timestamps()
  end

  relationships do
    belongs_to :tag, TagAsh.Resources.Tag, allow_nil?: false, attribute_writable?: true
  end

  identities do
    identity :lexical_label, [:tag_id, :language, :value]
    identity :preferred_language, [:tag_id, :language], where: expr(kind == :preferred)
  end

  @doc false
  def normalize(changeset, _) do
    get = &Ash.Changeset.get_attribute(changeset, &1)

    case TagAsh.Vocabulary.label(get.(:language), get.(:value), get.(:kind)) do
      {:ok, attrs} ->
        Ash.Changeset.change_attributes(changeset, attrs)

      {:error, reason} ->
        Ash.Changeset.add_error(changeset,
          field: :value,
          message: "Invalid vocabulary label: #{reason}"
        )
    end
  end
end
