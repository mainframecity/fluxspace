defmodule Fluxspace.Entrypoints.Websocket.Server do
  @port 4050

  def start_link(_state, _args) do
    dispatch_config = build_dispatch_config()

    IO.puts("Started Websocket server on #{@port}")

    :cowboy.start_http(:http, 100, [{:port, @port}], [{:env, [{:dispatch, dispatch_config}]}])
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
