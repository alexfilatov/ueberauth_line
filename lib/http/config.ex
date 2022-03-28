defmodule Http.Config do
  @moduledoc """
  Configuration for the HTTP Client API.
  """

  def get_client! do
    config = Application.get_env(:http_client, Http.Client, [])

    case config[:client] do
      nil -> raise "HTTP argument :client for :http_client is not configured"
      client -> client
    end
  end
end
