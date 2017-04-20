defmodule Fluxspace.Efuns.Fluxspace do
  alias Fluxspace.ScriptContext

  def context() do
    {:fluxspace, %{
      send_message: fn(state, [pid, message]) ->
        send(ScriptContext.decode_pid(pid), {:send_message, [message, "\r\n"]})
        {state, [true]}
      end
    }}
  end
end
