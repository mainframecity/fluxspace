defmodule Fluxspace.Entrypoints.Websocket.Server do
  def start_link(_state, _args) do
    dispatch_config = build_dispatch_config()

    :cowboy.start_http(:http, 100, [{:port, 4050}], [{:env, [{:dispatch, dispatch_config}]}])
  end

  def build_dispatch_config() do
    :cowboy_router.compile([
      {
        :_,
        [
          {"/", Fluxspace.Entrypoints.Websocket.Client, []}
        ]
      }
    ])
  end
end
