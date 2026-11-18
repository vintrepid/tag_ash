defmodule TagAsh.VocabularyIntegrityTest do
  use ExUnit.Case, async: true
  alias TagAsh.Vocabulary

  test "related cannot be exported as an ancestor, including transitive paths" do
    hierarchy = [
      %{child_tag_id: "child", parent_tag_id: "middle"},
      %{child_tag_id: "middle", parent_tag_id: "parent"}
    ]

    for {a, b} <- [{"child", "parent"}, {"parent", "child"}] do
      assert_raise ArgumentError, ~r/broader/, fn ->
        Vocabulary.export(scheme(), [], [], hierarchy, [
          %{left_tag_id: a, right_tag_id: b, kind: :related}
        ])
      end
    end

    assert %{"@graph" => [_]} =
             Vocabulary.export(scheme(), [], [], hierarchy, [
               %{left_tag_id: "child", right_tag_id: "peer", kind: :related}
             ])
  end

  test "preferred labels are unique per language and lexical kinds cannot overlap" do
    base = %{tag_id: "a", language: "en", value: "One", kind: :preferred}

    for extra <- [%{base | value: "Two"}, %{base | kind: :hidden}] do
      assert_raise ArgumentError, ~r/lexical/, fn ->
        Vocabulary.export(scheme(), [], [base, extra], [], [])
      end
    end

    assert %{"@graph" => [_]} =
             Vocabulary.export(scheme(), [], [base, %{base | language: "fr"}], [], [])
  end

  test "legacy names do not invent a preferred-language label or conflict with an explicit alias" do
    tag = %{id: "a", context_id: "scheme", name: "Blues", description: nil}
    labels = [%{tag_id: "a", language: "und", value: "Blues", kind: :alternative}]
    [_, concept] = Vocabulary.export(scheme(), [tag], labels, [], [])["@graph"]
    assert concept["rdfs:label"] == "Blues"
    assert concept["skos:prefLabel"] == nil
    assert concept["skos:altLabel"] == [%{"@language" => "und", "@value" => "Blues"}]
  end

  defp scheme, do: %{id: "scheme", name: "Vocabulary"}
end
