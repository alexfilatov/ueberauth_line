defmodule LineLogin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, args) do
    children =
      case args do
        [env: :prod] ->
          []

        [env: :test] ->
          [{Plug.Cowboy, scheme: :http, plug: LineLogin.MockServer, options: [port: 8081]}]

        [env: :dev] ->
          []

        [_] ->
          []
      end

    opts = [strategy: :one_for_one, name: GithubClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
