defmodule Fluxspace.Structs.Inventory do
  @moduledoc """
  This struct represents an entity's inventory.
  """

  defstruct [
   :type,
   :max_space,
   :items
 ]
end
