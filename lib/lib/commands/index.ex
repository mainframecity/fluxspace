defmodule Fluxspace.Commands.Index do
  @help """
  ------------------------------
  Welcome to Fluxspace.

  help - Display this message.
  say <message> - Say a message.
  ------------------------------

  """

  def do_command("help", client) do
    send_message(client, @help)

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

    broadcast_message(formatted_message)

    {:ok, client}
  end

  def do_command(_, client) do
    send_message(client, "I'm sorry, what?")

    {:error, client}
  end

  def send_message(client, message) do
    Fluxspace.Entrypoints.ClientGroup.send_message(client, message)
  end

  def broadcast_message(message) do
    Fluxspace.Entrypoints.ClientGroup.broadcast_message(message)
  end
end
