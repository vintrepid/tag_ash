defmodule TagAsh.ResourceHooksTest do
  use ExUnit.Case, async: true
  test "classification resources adopt the native Ash RI change" do
    for resource <- Ash.Domain.Info.resources(TagAsh.Domain) do
      changes = Ash.Resource.Info.changes(resource) |> Enum.map(&elem(&1.change, 0))
      assert AshRi.DeletionGuard in changes
    end
  end
end
