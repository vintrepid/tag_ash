defmodule TagAsh.Resource do
  @moduledoc "Adopts native AshRi lifecycle enforcement consistently across classification resources."
  defmacro __using__(options) do
    options =
      Keyword.update(options, :extensions, [AshRi], &[AshRi | &1])

    quote do
      use Ash.Resource, unquote(options)
    end
  end
end
