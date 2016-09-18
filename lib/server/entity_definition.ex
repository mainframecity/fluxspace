defmodule Fluxspace.EntityDefinition do
  require Logger

  alias Fluxspace.Entity
  alias Fluxspace.EntityDefinition

  defstruct [
    filepath: "",
    type: "",
    attributes: %{}
  ]

  def to_entity(%EntityDefinition{} = definition) do
    {:ok, uuid, pid} = Entity.start

    Enum.each(definition.attributes, fn({key, value}) ->
      case to_module(key) do
        :error -> Logger.warn("Couldn't find attribute: #{key}")
        module ->
          struct = struct(module)
          attribute =
            Enum.reduce Map.to_list(struct), struct, fn {key, _}, acc ->
              case Map.fetch(value, Atom.to_string(key)) do
                {:ok, value} -> %{acc | key => value}
                :error -> acc
              end
            end

          pid |> module.register(attribute)
      end
    end)

    {:ok, uuid, pid}
  end

  defp to_module(module_name) do
    qualified_module_name = "Elixir.Fluxspace.Lib.Attributes." <> module_name

    try do
      String.to_existing_atom(qualified_module_name)
    catch
      _ -> :error
    end
  end
end
