defmodule TagAsh.Config do
  @moduledoc "Runtime configuration supplied by the host application."

  @doc "The Ecto repository used by TagAsh resources."
  @spec repo!() :: module()
  def repo! do
    Application.get_env(:tag_ash, :repo) ||
      raise """
      TagAsh requires a host repository:

          config :tag_ash, repo: MyApp.Repo
      """
  end

  @doc false
  @spec repo!(module(), map()) :: module()
  def repo!(_resource, _context), do: repo!()
end
