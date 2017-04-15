defmodule Fluxspace.Commands.Index do
  alias Fluxspace.Entrypoints.{Client, ClientGroup}

  @help """
  ------------------------------
  Welcome to Fluxspace.

  help - Display this message.
  say <message> - Say a message.
  logout - Logs you out.
  ------------------------------

  """

  def do_command("help", client, _player_pid) do
    Client.send_message(client, @help)

    {:ok, client}
  end

  def do_command("say " <> message, client, player_pid) do
    name = Fluxspace.Lib.Attributes.Appearance.get_name(player_pid)

    formatted_message = [
      "\n",
      name,
      " says: ",
      message,
      "\n"
    ]

    ClientGroup.broadcast_message(formatted_message)

    {:ok, client}
  end

  def do_command("logout", client, _) do
    ClientGroup.broadcast_message("Someone logged out.\n")
    Client.stop_all(client)

    {:ok, client}
  end

  def do_command(_, client, _) do
    Client.send_message(client, "I'm sorry, what?")

    {:error, client}
  end
end
