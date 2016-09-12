alias Experimental.{GenStage}

defmodule Consumer do
  @moduledoc false

  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, :ok, subscribe_to: [Broadcaster]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      IO.inspect {self(), event}
    end

    {:noreply, [], state}
  end
end
