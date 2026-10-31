defmodule TagAsh.Resource do
  @moduledoc "Adopts optional host lifecycle hooks consistently across classification resources."
  defmacro __using__(options) do
    options =
      Keyword.update(options, :fragments, [TagAsh.ResourceHooks], &[TagAsh.ResourceHooks | &1])

    quote do
      use Ash.Resource, unquote(options)
    end
  end
end
