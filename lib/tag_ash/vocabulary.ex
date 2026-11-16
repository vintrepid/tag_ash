defmodule TagAsh.Vocabulary do
  @moduledoc "Language-aware vocabulary rules and pure SKOS JSON-LD interchange. Names never establish concept identity."
  @kinds [:preferred, :alternative, :hidden]
  @predicates [:related, :close_match, :exact_match]
  @properties %{
    preferred: "skos:prefLabel",
    alternative: "skos:altLabel",
    hidden: "skos:hiddenLabel"
  }
  @relations %{
    related: "skos:related",
    close_match: "skos:closeMatch",
    exact_match: "skos:exactMatch"
  }

  @spec label(term(), term(), term()) :: {:ok, map()} | {:error, atom()}
  def label(language, value, kind) when is_binary(language) and is_binary(value) do
    language = String.downcase(String.trim(language))
    value = value |> String.trim() |> String.normalize(:nfc)

    cond do
      kind not in @kinds ->
        {:error, :invalid_kind}

      value == "" ->
        {:error, :empty_label}

      String.length(value) > 512 ->
        {:error, :label_too_long}

      byte_size(language) > 63 or
          not Regex.match?(~r/\A[a-z]{1,8}(?:-[a-z0-9]{1,8})*\z/, language) ->
        {:error, :invalid_language}

      true ->
        {:ok, %{language: language, value: value, kind: kind}}
    end
  end

  def label(_, _, _), do: {:error, :invalid_label}

  @spec matches([map()], String.t(), String.t()) :: [String.t()]
  def matches(labels, text, language) do
    language = String.downcase(String.trim(language))
    key = match_key(text)

    labels
    |> Enum.filter(&(String.downcase(&1.language) == language and match_key(&1.value) == key))
    |> Enum.map(& &1.tag_id)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec relation(term(), term(), term()) :: {:ok, map()} | {:error, atom()}
  def relation(left, right, kind) do
    cond do
      kind not in @predicates ->
        {:error, :invalid_predicate}

      not is_binary(left) or not is_binary(right) or left == "" or right == "" ->
        {:error, :invalid_endpoint}

      left == right ->
        {:error, :self_relation}

      true ->
        [left, right] = Enum.sort([left, right])
        {:ok, %{left_tag_id: left, right_tag_id: right, kind: kind}}
    end
  end

  @spec iri(String.t()) :: String.t()
  def iri(id), do: "urn:tag-ash:" <> URI.encode(id, &URI.char_unreserved?/1)

  @doc "Export only the already-authorized instances supplied by the host. This function never fetches resources."
  @spec export(map(), [map()], [map()], [map()], [map()]) :: map()
  def export(context, tags, labels, hierarchy, relations) do
    (
      validate_graph!(labels, hierarchy, relations)

      scheme = %{
        "@id" => iri(context.id),
        "@type" => "skos:ConceptScheme",
        "rdfs:label" => context.name
      }
    )

    concepts =
      Enum.map(tags, fn tag ->
        term_labels = Enum.filter(labels, &(&1.tag_id == tag.id))

        lexical =
          Enum.group_by(
            term_labels,
            &Map.fetch!(@properties, &1.kind),
            &%{"@value" => &1.value, "@language" => &1.language}
          )

        node =
          %{
            "rdfs:label" => tag.name,
            "@id" => iri(tag.id),
            "@type" => "skos:Concept",
            "skos:inScheme" => %{"@id" => iri(tag.context_id)}
          }
          |> Map.merge(lexical)
          |> Map.put("skos:definition", tag.description)
          |> Map.put(
            "skos:broader",
            for(
              link <- hierarchy,
              link.child_tag_id == tag.id,
              do: %{"@id" => iri(link.parent_tag_id)}
            )
          )
          |> Map.put(
            "skos:narrower",
            for(
              link <- hierarchy,
              link.parent_tag_id == tag.id,
              do: %{"@id" => iri(link.child_tag_id)}
            )
          )

        Enum.reduce(relations, node, fn edge, acc ->
          other =
            cond do
              edge.left_tag_id == tag.id -> edge.right_tag_id
              edge.right_tag_id == tag.id -> edge.left_tag_id
              true -> nil
            end

          if other,
            do:
              Map.update(
                acc,
                Map.fetch!(@relations, edge.kind),
                [%{"@id" => iri(other)}],
                &Enum.uniq([%{"@id" => iri(other)} | &1])
              ),
            else: acc
        end)
        |> Map.reject(fn {_key, value} -> value in [nil, []] end)
      end)

    %{
      "@context" => %{
        "skos" => "http://www.w3.org/2004/02/skos/core#",
        "rdfs" => "http://www.w3.org/2000/01/rdf-schema#"
      },
      "@graph" => [scheme | concepts]
    }
  end

  defp validate_graph!(labels, hierarchy, relations) do
    labels
    |> Enum.group_by(&{&1.tag_id, &1.language})
    |> Enum.each(fn {_key, entries} ->
      preferred = Enum.count(entries, &(&1.kind == :preferred))
      lexical = Enum.group_by(entries, & &1.value, & &1.kind)

      if preferred > 1 or Enum.any?(lexical, fn {_, kinds} -> length(Enum.uniq(kinds)) > 1 end),
        do: raise(ArgumentError, "Conflicting lexical labels in a concept language")
    end)

    parents = Enum.group_by(hierarchy, & &1.child_tag_id, & &1.parent_tag_id)

    Enum.each(relations, fn edge ->
      if edge.kind == :related and
           (reachable?(parents, edge.left_tag_id, edge.right_tag_id, MapSet.new()) or
              reachable?(parents, edge.right_tag_id, edge.left_tag_id, MapSet.new())),
         do: raise(ArgumentError, "Related concepts also have a broader/narrower path")
    end)
  end

  defp reachable?(parents, source, target, seen) do
    cond do
      source == target ->
        true

      MapSet.member?(seen, source) ->
        false

      true ->
        Enum.any?(
          Map.get(parents, source, []),
          &reachable?(parents, &1, target, MapSet.put(seen, source))
        )
    end
  end

  defp match_key(value), do: value |> String.trim() |> String.normalize(:nfc) |> String.downcase()
end
