defmodule Fluxspace.Efuns.Fluxspace do
  alias Fluxspace.ScriptContext

  def context() do
    {:fluxspace, %{
      send_message: fn(state, [pid, message]) ->
        send(ScriptContext.decode_pid(pid), {:send_message, [message, "\r\n"]})
        {state, [true]}
      end,
      add_command: fn(state, [command_name, regex, function_name]) ->
        send(self(), {:add_command, command_name, regex, function_name})
        {state, [true]}
      end
    }}
  end
end
