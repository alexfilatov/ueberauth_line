defmodule Ueberauth.Strategy.LineLogin.OAuth do
  @moduledoc """
  OAuth2 for Line.

  Add `client_id` and `client_secret` to your configuration:

  config :ueberauth, Ueberauth.Strategy.Line.OAuth,
    client_id: System.get_env("LINE_APP_ID"),
    client_secret: System.get_env("LINE_APP_SECRET")

  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://access.line.me",
    authorize_url: "https://access.line.me/oauth2/v2.1/authorize",
    token_url: "https://api.line.me/oauth2/v2.1/token"
  ]

  @doc """
  Construct a client for requests to Line.

  This will be setup automatically for you in `Ueberauth.Strategy.Line`.
  These options are only useful for usage outside the normal callback phase
  of Ueberauth.
  """
  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.Line.OAuth)

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    OAuth2.Client.new(opts)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth.
  No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.get_token!(params)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
    |> put_param(:client_secret, client.client_secret)
  end
end
