defmodule Fluxspace.Menu do
  defmacro __using__(_opts) do
    quote do
      use GenServer

      def call(client) do
        GenServer.start_link(__MODULE__, client, [])
      end

      def init(state) do
        send(self(), :start)
        {:ok, state}
      end

      def handle_info(:start, client) do
        start(client)
        {:stop, :normal, client}
      end

      def start(_client), do: :ok

      defoverridable [start: 1]
    end
  end
end
