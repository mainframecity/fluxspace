defmodule Fluxspace.File do
  @moduledoc """
  Methods for writing to .fluxdata files.
  """

  # @file_extension ".flux"
  @data_directory "data/"

  @doc """
  Ensures data_directory is created.
  """
  def start do
    File.mkdir_p(@data_directory)
  end
end
