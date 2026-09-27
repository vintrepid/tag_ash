defmodule TagAsh.SubjectRefTest do
  use ExUnit.Case, async: true

  alias TagAsh.SubjectRef

  test "builds and parses opaque stable references" do
    reference = SubjectRef.build(:reading_entry, "01a0e109-d8cb-71b9-9fa4-83f2c4756459")

    assert {:ok, {"reading_entry", "01a0e109-d8cb-71b9-9fa4-83f2c4756459"}} =
             SubjectRef.parse(reference)
  end

  test "rejects malformed references" do
    assert {:error, :invalid_subject_ref} = SubjectRef.parse("not a reference")
    assert_raise ArgumentError, fn -> SubjectRef.build("Bad Kind", "id") end
  end
end
