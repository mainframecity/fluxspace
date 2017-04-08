defmodule Fluxspace.Entrypoints.Dummy do
  def send_message(_client, _message) do
    :ok
  end
end
