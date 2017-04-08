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

  def do_command("help", client) do
    Client.send_message(client, @help)

    {:ok, client}
  end

  def do_command("say " <> message, client) do
    formatted_message = [
      "\n",
      client.player_uuid,
      " says: ",
      message,
      "\n"
    ]

    ClientGroup.broadcast_message(formatted_message)

    {:ok, client}
  end

  def do_command("logout", client) do
    ClientGroup.broadcast_message("#{client.player_uuid} logged out.\n")
    Client.close(client)

    {:ok, client}
  end

  def do_command(_, client) do
    Client.send_message(client, "I'm sorry, what?")

    {:error, client}
  end
end
