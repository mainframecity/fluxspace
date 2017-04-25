defmodule Fluxspace.ScriptContext do
  @moduledoc """
  Sets up a lua script's global context with all necessary efuns.
  """

  def new() do
    Lua.State.new()
  end

  def add_context(state) do
    efun_modules = [Fluxspace.Efuns.Fluxspace]

    Enum.reduce(efun_modules, state, fn(module, acc) ->
      {name, table} = module.context()
      Lua.set_global(acc, name, table)
    end)
  end

  def load_code(state, code) do
    Lua.exec!(state, code)
  end

  def function_exists?(state, function_name) when is_atom(function_name) do
    case Lua.get_global(state, function_name) do
      {_, nil} -> false
      {_, _function} -> true
    end
  end

  def call_function(state, function, arguments) when is_atom(function) and is_list(arguments) do
    Lua.call_function!(state, function, arguments)
  end

  def encode_pid(pid) do
    :erlang.term_to_binary(pid)
  end

  def decode_pid(pid) do
    :erlang.binary_to_term(pid)
  end

  def ls_r(path \\ "lib/scripts/") do
    cond do
      File.regular?(path) -> [path]
      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&ls_r/1)
        |> Enum.concat
      true -> []
    end
  end
end
