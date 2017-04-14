defmodule Fluxspace.Menus.Login do
  alias Fluxspace.Entrypoints.{Client, ClientGroup}
  alias Fluxspace.Structs.Account
  alias Fluxspace.Services.AccountService

  use Fluxspace.Menu

  def start(client) do
    Client.send_message(client, "Welcome to Fluxspace!\n")

    if returning_player?(client) do
      returning_player(client)
    else
      new_player(client)
    end
  end

  def returning_player?(client) do
    Client.send_message(client, "Are you a returning player? (y/n): ")

    case Client.register_callback(client) do
      "y" -> true
      "n" -> false
      _ -> returning_player?(client)
    end
  end

  def returning_player(client) do
    Client.send_message(client, "Welcome back!\n")

    Client.send_message(client, "Please enter your username: ")
    username = Client.register_callback(client)

    Client.send_message(client, "Please enter your password: ")
    password = Client.register_callback(client)

    case AccountService.verify_password_for_username(username, password) do
      {:ok, _account} ->
        Client.send_message(client, "You're logged in!\n")
        ClientGroup.broadcast_message("#{username} logged in.\n")
        Fluxspace.Commands.Index.do_command("help", client)
      :error ->
        Client.send_message(client, "Wrong username or password.\n")
        Client.stop_all(client)
    end
  end

  def new_player(client) do
    Client.send_message(client, "Great! Let's get you started with a new account.\n")

    username = new_player_username(client)
    password = new_player_password(client)

    Client.send_message(client, "Creating account with username: `#{username}`\n")

    case AccountService.create_account(%Account{}, %{username: username, password: password}) do
      {:ok, _account} ->
        Client.send_message(client, "Account created successfully!\n")
        Client.send_message(client, "Taking you to login screen..\n")
        returning_player(client)
      _ ->
        Client.send_message(client, "Unexpected error occured while creating your account. Please try again later.\n")
        Client.stop_all(client)
    end
  end

  def new_player_username(client) do
    Client.send_message(client, "Please enter your desired username: ")
    desired_username = Client.register_callback(client)

    with {:valid_username, true} <- {:valid_username, String.valid?(desired_username)},
      nil <- AccountService.get_account_by_username(desired_username) do
      desired_username
    else
      {:valid_username, false} ->
        Client.send_message(client, "Invalid username was entered.\n")
        new_player_username(client)
      _ ->
        Client.send_message(client, "Looks like there's already someone with that username..\n")
        new_player_username(client)
    end
  end

  def new_player_password(client) do
    Client.send_message(client, "Enter in your desired password: ")
    password = Client.register_callback(client)

    with {:valid_password, true} <- {:valid_password, String.valid?(password)},
      Client.send_message(client, "Confirm your password: "),
      confirmed_password = Client.register_callback(client),
      {:valid_password, true} <- {:valid_password, String.valid?(confirmed_password)},
      true <- password == confirmed_password do
      password
    else
      {:valid_password, false} ->
        Client.send_message(client, "Invalid password was entered.\n")
        new_player_password(client)
      _ ->
        Client.send_message(client, "Passwords did not match.\n")
        new_player_password(client)
    end
  end
end
