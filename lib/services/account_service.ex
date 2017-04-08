defmodule Fluxspace.Services.AccountService do
  import Ecto.Query

  alias Fluxspace.Structs.Account

  @spec create_account(Account.t, map()) :: {:ok, Account.t} | {:error, Ecto.Changeset.t}
  def create_account(%Account{} = account, params) do
    Account.changeset(account, params)
    |> Fluxspace.Repo.insert
  end

  @spec get_account_by_username(String.t) :: Account.t | nil
  def get_account_by_username(username) do
    Fluxspace.Repo.one(
      from account in Account,
      where: account.username == ^username
    )
  end

  @spec verify_password_for_username(String.t, String.t) :: {:ok, Account.t} | :error
  def verify_password_for_username(username, password) do
    case get_account_by_username(username) do
      nil -> :error
      account -> verify_password_for_account(account, password)
    end
  end

  @spec verify_password_for_account(Account.t, String.t) :: {:ok, Account.t} | :error
  def verify_password_for_account(account, password) do
    case Comeonin.Bcrypt.checkpw(password, account.password) do
      true -> {:ok, account}
      _ -> :error
    end
  end
end
