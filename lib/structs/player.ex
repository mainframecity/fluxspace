defmodule Fluxspace.Structs.Player do
  @moduledoc """
  This struct represents a player.
  """

  defstruct [
    :id,
    :uuid,
    :name,
    :access_token
  ]
end
