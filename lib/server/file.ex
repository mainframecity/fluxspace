defmodule Fluxspace.File do
  @moduledoc """
  Methods for writing to .fluxdata files.
  """

  alias Fluxspace.Entity
  alias Fluxspace.EntityInstance

  @file_extension ".flux"
  @data_directory "data/"

  @doc """
  Ensures data_directory is created.
  """
  def start do
    File.mkdir_p(@data_directory)
  end

  @doc """
  Serializes an entity.
  """
  def serialize(entity_pid) do
    entity = Entity.get_state(entity_pid)

    %EntityInstance{
      uuid: entity.state.uuid,
      attributes: entity.state.attributes
    } |> Poison.encode!
  end
end
