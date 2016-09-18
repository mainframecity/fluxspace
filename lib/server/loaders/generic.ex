defmodule Fluxspace.Loaders.Generic do
  @moduledoc """
  Default loader for loading .fluxdef and .fluxdata files.
  """

  alias Fluxspace.EntityDefinition

  @doc """
  Loads a file.
  """
  def load(filepath), do: File.read(filepath)

  @doc """
  Converts to JSON.
  """
  def to_json(data), do: Poison.decode(data)

  @doc """
  Loads an .fluxdef file and creates an entity definition struct.
  """
  def load_definition(filepath) when is_bitstring(filepath) do
    with {:ok, data} <- load(filepath),
      {:ok, json} <- to_json(data) do

      load_definition(filepath, json)
    else
      _ -> :error
    end
  end

  def load_definition(filepath, json) when is_bitstring(filepath) and is_map(json) do
    %EntityDefinition{
      filepath: filepath,
      attributes: json["attributes"] || %{}
    }
  end
end
