defmodule Fluxspace.Efuns.Fluxspace do
  alias Fluxspace.ScriptContext

  def context() do
    {:fluxspace, %{
      inspect: fn(state, [thing]) ->
        case thing do
          {:table, tref} ->
            Enum.reduce(:luerl.decode(tref, state.luerl), %{}, fn {k, v}, map ->
              Map.put(map, k, v)
            end)
            |> IO.inspect()
          decoded_thing ->
            IO.inspect(decoded_thing)
        end
        {state, [true]}
      end,
      send_message: fn(state, [pid, message]) ->
        send(ScriptContext.decode_pid(pid), {:send_message, [message, "\r\n"]})
        {state, [true]}
      end,
      broadcast_message: fn(state, [room_pid, message]) ->
        Fluxspace.Lib.Attributes.Inventory.notify_except(room_pid, self(), {:send_message, message})
        {state, [true]}
      end,
      add_command: fn(state, [command_name, regex, function_name]) ->
        send(self(), {:add_command, command_name, regex, function_name})
        {state, [true]}
      end,
      get_entities: fn(state, [encoded_room_pid]) ->
        if !is_nil(encoded_room_pid) do
          room_pid = ScriptContext.decode_pid(encoded_room_pid)
          entities = Fluxspace.Lib.Room.get_entities(room_pid)
          filtered_entities = Enum.reject(entities, &(&1 == self()))
          {encoded_entities, new_state} =
            Enum.map(filtered_entities, &ScriptContext.encode_pid/1)
            |> :luerl.encode(state.luerl)

          new_wrapped_state = Lua.State.wrap(new_state)
          {new_wrapped_state, [Lua.Table.wrap(encoded_entities, new_wrapped_state)]}
        else
          {state, [[]]}
        end
      end
    }}
  end
end
