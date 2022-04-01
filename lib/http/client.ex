defmodule Http.Client do
  @moduledoc """
  This is a client implementation that picks a client specified in the configuration.

  Configure the current client in
  config :http_client, Http.Client,
    client: MyClient
  """

  alias Http.Config

  @behaviour Http.ClientApi

  @spec get(ClientApi.query_params(), ClientApi.headers(), ClientApi.url()) :: ClientApi.result()
  @doc """
  HTTP GET request.
  """
  @impl true
  def get(query_params, headers, url) do
    Config.get_client!().get(query_params, headers, url)
  end

  @spec post(ClientApi.body(), ClientApi.headers(), ClientApi.url()) :: ClientApi.result()
  @doc """
  HTTP POST request
  """
  @impl true
  def post(body, headers, url) do
    Config.get_client!().post(body, headers, url)
  end
end
