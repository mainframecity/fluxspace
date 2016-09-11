defmodule Fluxspace.Endpoint do
  use Phoenix.Endpoint, otp_app: :fluxspace

  socket "/socket", Fluxspace.UserSocket

  plug Plug.Static,
    at: "/", from: :fluxspace, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_fluxspace_key",
    signing_salt: "DBHSJnYb"

  plug Fluxspace.Router
end
