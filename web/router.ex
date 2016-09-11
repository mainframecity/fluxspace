defmodule Fluxspace.Router do
  use Fluxspace.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Fluxspace do
    pipe_through :api
  end
end
