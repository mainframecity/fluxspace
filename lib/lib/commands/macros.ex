defmodule Fluxspace.Commands.Macros do
  defmacro __using__(_) do
    quote do
      import Fluxspace.Commands.Macros, only: [commands: 1, command: 2]

      Module.register_attribute(__MODULE__, :commands, accumulate: true)
    end
  end

  defmacro commands([do: block]) do
    quote do
      Module.register_attribute(__MODULE__, :commands, accumulate: true)

      try do
        import Fluxspace.Commands.Macros
        unquote(block)
      after
        :ok
      end

      commands = @commands |> Enum.reverse()

      def perform(string, client, player_pid) do
        first_matching_command =
          Enum.find_value(Enum.reverse(@commands), fn({regex, _func} = value) ->
            case Regex.named_captures(regex, string) do
              nil -> false
              captures -> {value, captures}
            end
          end)

        if first_matching_command do
          {{_, func}, captures} = first_matching_command
          func.(string, captures, client, player_pid)
        end
      end

    end
  end

  defmacro command(regex, function) do
    quote do
      Fluxspace.Commands.Macros.__command__(__MODULE__, unquote(regex), unquote(function))
    end
  end

  def __command__(module, regex, function) do
    Module.put_attribute(module, :commands, {Regex.compile!(regex), function})
  end
end
