defmodule Fluxspace.Lib.Daemon do
  defmacro __using__(_) do
    quote do
      use Fluxspace.GenSync
    end
  end
end
