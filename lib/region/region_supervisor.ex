defmodule Fluxspace.RegionSupervisor do
  @moduledoc """
  Supervisor that manages all the Region instances.
  """

  use Supervisor
  require Logger

  def start_link do
    case Supervisor.start_link(__MODULE__, []) do
      {:ok, pid} ->
        Logger.info "Running #{inspect __MODULE__}"
        {:ok, pid}
      {:error, _} = error ->
        error
    end
  end

  def init([]) do
    children = []

    supervise(children, strategy: :one_for_one)
  end
end
