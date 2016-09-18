defmodule Fluxspace.File do
  @moduledoc """
  Methods for writing/reading to and from Fluxspace data files.
  """

  @file_extension ".flux"
  @data_directory "data/"

  @doc """
  Ensures data_directory is created.
  """
  def start do
    File.mkdir_p(@data_directory)
  end

  @doc """
  Writes an Elixir data structure to a file.
  """
  def write(filename, data \\ []) do
    filepath = @data_directory <> filename <> @file_extension
    :file.write_file(filepath, :io_lib.fwrite("~p.\n", [data]))
  end

  @doc """
  Reads Elixir data structures from a file.
  """
  def read(filename) do
    filepath = @data_directory <> filename <> @file_extension
    :file.consult(filepath)
  end
end
