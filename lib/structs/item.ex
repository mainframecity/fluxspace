defmodule Fluxspace.Structs.Item do
  @moduledoc """
  This struct represents a physical item.
  """

  defstruct [:id,
   :uuid,
   :name,
   :weight,
   :value
 ]
end
