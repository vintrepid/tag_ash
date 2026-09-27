defmodule TagAsh.SubjectRef do
  @moduledoc "Stable opaque references to host-owned subjects."

  @kind_pattern ~r/^[a-z][a-z0-9_]*$/

  @spec build(atom() | String.t(), String.t()) :: String.t()
  def build(kind, id) when is_binary(id) do
    kind = to_string(kind)

    if Regex.match?(@kind_pattern, kind) and id != "" do
      kind <> ":" <> Base.url_encode64(id, padding: false)
    else
      raise ArgumentError, "subject kind and identifier must be non-empty and stable"
    end
  end

  @spec parse(String.t()) :: {:ok, {String.t(), String.t()}} | {:error, :invalid_subject_ref}
  def parse(reference) when is_binary(reference) do
    with [kind, encoded] <- String.split(reference, ":", parts: 2),
         true <- Regex.match?(@kind_pattern, kind),
         {:ok, id} <- Base.url_decode64(encoded, padding: false),
         true <- id != "" do
      {:ok, {kind, id}}
    else
      _ -> {:error, :invalid_subject_ref}
    end
  end

  def parse(_reference), do: {:error, :invalid_subject_ref}
end
