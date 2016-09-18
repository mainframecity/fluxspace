defmodule Fluxspace.Lib.Daemon do
  defmacro __using__(_) do
    quote do
      use GenServer

      def start_link(_state, opts \\ []) do
        GenServer.start_link(__MODULE__, %{}, opts)
      end
    end
  end
end
