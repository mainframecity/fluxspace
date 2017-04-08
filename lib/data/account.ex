defmodule Fluxspace.Structs.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :username, :string
    field :password, :string
    field :last_logged_in, Ecto.DateTime, autogenerate: true

    timestamps()
  end

  def changeset(account, params \\ %{}) do
    account
    |> cast(params, [:username, :password, :last_logged_in])
    |> validate_required([:username, :password])
    |> put_change(:password, hashed_password(params[:password]))
    |> unique_constraint(:username)
  end

  def hashed_password(unhashed_password) when is_binary(unhashed_password) do
    Comeonin.Bcrypt.hashpwsalt(unhashed_password)
  end

  def hashed_password(_), do: nil
end
