defmodule TagAsh.ResourceHooks do
  @moduledoc "Optional host-owned deletion enforcement; classification does not own host workflow policy. Configure :tag_ash, :destroy_change with an Ash.Resource.Change module."
  use Spark.Dsl.Fragment, of: Ash.Resource

  changes do
    change(TagAsh.ResourceHooks.Deletion, on: [:destroy])
  end
end

defmodule TagAsh.ResourceHooks.Deletion do
  @moduledoc false
  use Ash.Resource.Change
  @impl true
  def change(changeset, _options, context) do
    case Application.get_env(:tag_ash, :destroy_change) do
      nil -> changeset
      change -> change.change(changeset, [], context)
    end
  end
end
