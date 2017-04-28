defmodule Fluxspace.Efuns.Fluxspace do
  alias Fluxspace.ScriptContext
  alias Fluxspace.Lib.Attributes

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
      broadcast_message: fn(state, [encoded_room_pid, message]) ->
        room_pid = ScriptContext.decode_pid(encoded_room_pid)
        Attributes.Inventory.notify_except(room_pid, self(), {:send_message, [message, "\r\n"]})
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
      end,

      is_player: fn(state, [encoded_pid]) ->
        pid = ScriptContext.decode_pid(encoded_pid)
        is_player = Fluxspace.Lib.Player.is_player?(pid)

        {state, [is_player]}
      end,

			add_determiner: fn(state, [noun]) ->
        determined_noun = Fluxspace.Determiners.determine(noun)

        {state, [determined_noun]}
      end,

      get_name: fn(state, [encoded_pid]) ->
        pid = ScriptContext.decode_pid(encoded_pid)
        name = Attributes.Appearance.get_name(pid)
        {state, [name]}
      end,

      get_long_description: fn(state, [encoded_pid]) ->
        pid = ScriptContext.decode_pid(encoded_pid)
        description = Attributes.Appearance.get_long_description(pid)
        {state, [description]}
      end,

      kill: fn(state, [encoded_pid]) ->
        pid = ScriptContext.decode_pid(encoded_pid)
        send(pid, :kill)
        {state, [true]}
      end
    }}
  end
end
