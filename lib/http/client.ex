defmodule Http.Client do
  @moduledoc """
  This is a client implementation that picks a client specified in the configuration.

  Configure the current client in
  config :http_client, Http.Client,
    client: MyClient
  """

  alias Http.Config

  @behaviour Http.ClientApi

  #  TODO: test this construct in plain elixir config

  @doc """
  HTTP GET request.
  """
  @impl true
  def get(headers, url) do
    Config.get_client!().get(headers, url)
  end

  @doc """

  HTTP POST request
  """
  @impl true
  def post(body, headers, url) do
    Config.get_client!().post(body, headers, url)
  end
end
