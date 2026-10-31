defmodule TagAsh.ResourceHooksTest do
  use ExUnit.Case, async: false

  defmodule HostChange do
    def change(changeset, [], context), do: Map.put(changeset, :hook_context, context)
  end

  test "host callback is optional and classification imposes no host workflow" do
    previous = Application.get_env(:tag_ash, :destroy_change)

    on_exit(fn ->
      if previous,
        do: Application.put_env(:tag_ash, :destroy_change, previous),
        else: Application.delete_env(:tag_ash, :destroy_change)
    end)

    Application.delete_env(:tag_ash, :destroy_change)
    assert TagAsh.ResourceHooks.Deletion.change(%{}, [], %{}) == %{}
    Application.put_env(:tag_ash, :destroy_change, HostChange)

    assert TagAsh.ResourceHooks.Deletion.change(%{}, [], %{actor: :operator}) == %{
             hook_context: %{actor: :operator}
           }
  end
end
