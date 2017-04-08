defmodule Fluxspace.Menus.Login do
  alias Fluxspace.Entrypoints.Client
  alias Fluxspace.Services.AccountService

  use Fluxspace.Menu

  def start(client) do
    Client.send_message(client, "Welcome to Fluxspace!\n")
    Client.send_message(client, "Please enter your username: ")

    username = Client.register_callback(client)

    Client.send_message(client, "Please enter your password: ")

    password = Client.register_callback(client)

    case AccountService.verify_password_for_username(username, password) do
      {:ok, _account} ->
        Client.send_message(client, "You're logged in!\n")
      :error ->
        Client.send_message(client, "Wrong username or password.\n")
        Client.close(client)
    end
  end
end
