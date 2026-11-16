defmodule TagAsh.VocabularyIdentifierTest do
  use ExUnit.Case, async: true

  test "persisted UUID identifiers use the standard UUID URN namespace" do
    uuid = "018f0000-0000-7000-8000-00000000000a"
    assert TagAsh.Vocabulary.iri(String.upcase(uuid)) == "urn:uuid:" <> uuid
  end
end
