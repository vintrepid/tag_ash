defmodule TagAsh.VocabularyActionsTest do
  use ExUnit.Case, async: true
  alias TagAsh.Resources.{Label, ConceptRelation}
  @left "018f0000-0000-7000-8000-000000000001"
  @right "018f0000-0000-7000-8000-000000000002"

  test "the label factory applies the lexical rules to persisted action input" do
    changeset =
      Ash.Changeset.for_create(Label, :collect, %{
        tag_id: @left,
        language: "EN",
        value: " Cafe\u0301 ",
        kind: :alternative
      })

    assert changeset.valid?
    assert Ash.Changeset.get_attribute(changeset, :language) == "en"
    assert Ash.Changeset.get_attribute(changeset, :value) == "Café"

    invalid =
      Ash.Changeset.for_create(Label, :collect, %{
        tag_id: @left,
        language: "en_US",
        value: "Blues"
      })

    refute invalid.valid?
  end

  test "the relation factory canonicalizes reverse observations and refuses self-links" do
    changeset =
      Ash.Changeset.for_create(ConceptRelation, :collect, %{
        left_tag_id: @right,
        right_tag_id: @left,
        kind: :related
      })

    assert changeset.valid?
    assert Ash.Changeset.get_attribute(changeset, :left_tag_id) == @left
    assert Ash.Changeset.get_attribute(changeset, :right_tag_id) == @right

    invalid =
      Ash.Changeset.for_create(ConceptRelation, :collect, %{
        left_tag_id: @left,
        right_tag_id: @left,
        kind: :related
      })

    refute invalid.valid?
  end
end
