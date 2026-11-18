defmodule TagAsh.VocabularyTest do
  use ExUnit.Case, async: true
  alias TagAsh.Vocabulary

  test "language and Unicode normalize without collapsing concept identity" do
    assert {:ok, %{language: "pt-br", value: "Café", kind: :alternative}} =
             Vocabulary.label("PT-BR", " Cafe\u0301 ", :alternative)

    labels = [
      %{tag_id: "one", language: "en", value: "Rock", kind: :preferred},
      %{tag_id: "two", language: "en", value: "rock", kind: :hidden},
      %{tag_id: "three", language: "fr", value: "rock", kind: :alternative}
    ]

    assert Vocabulary.matches(labels, " ROCK ", "EN") == ["one", "two"]
    assert Vocabulary.matches(labels, "rock", "fr") == ["three"]
  end

  test "empty labels and malformed language tags cannot enter the vocabulary" do
    assert {:error, :empty_label} = Vocabulary.label("en", "  ", :preferred)
    assert {:error, :invalid_language} = Vocabulary.label("en_US", "Blues", :preferred)
    assert {:error, :invalid_kind} = Vocabulary.label("en", "Blues", :artist)
  end

  test "symmetric vocabulary relations replay with a stable pair, without entity predicates" do
    for kind <- [:related, :close_match, :exact_match] do
      assert Vocabulary.relation("b", "a", kind) == Vocabulary.relation("a", "b", kind)
    end

    assert {:error, :self_relation} = Vocabulary.relation("a", "a", :related)
    assert {:error, :invalid_predicate} = Vocabulary.relation("a", "b", :influenced_by)
  end

  test "SKOS export preserves concept identifiers, language labels and directed hierarchy" do
    context = %{id: "scheme", name: "Genres", description: nil}

    tags = [
      %{id: "rock", context_id: "scheme", name: "Rock", description: nil},
      %{id: "folk", context_id: "scheme", name: "Folk rock", description: "A style"}
    ]

    labels = [
      %{tag_id: "folk", language: "en", value: "Folk-rock", kind: :preferred},
      %{tag_id: "folk", language: "en", value: "folkrock", kind: :alternative}
    ]

    links = [%{parent_tag_id: "rock", child_tag_id: "folk"}]
    relations = [%{left_tag_id: "folk", right_tag_id: "other", kind: :close_match}]
    graph = Vocabulary.export(context, tags, labels, links, relations)["@graph"]
    folk = Enum.find(graph, &(&1["@id"] == Vocabulary.iri("folk")))
    assert folk["skos:broader"] == [%{"@id" => Vocabulary.iri("rock")}]
    assert folk["skos:closeMatch"] == [%{"@id" => Vocabulary.iri("other")}]
    assert %{"@value" => "folkrock", "@language" => "en"} in folk["skos:altLabel"]

    renamed =
      Vocabulary.export(context, [%{hd(tags) | name: "A new label"}], [], [], [])["@graph"]

    assert Enum.any?(renamed, &(&1["@id"] == Vocabulary.iri("rock")))
  end
end
