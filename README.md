# UeberauthLine

**An Uberauth strategy for LINE OAuth2 authentication.

Inspired by [Ueberauth for Facebook](https://github.com/ueberauth/ueberauth_facebook)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `ueberauth_line` to your list of dependencies in `mix.exs`:

```elixir
    def deps do
      [{:ueberauth_line, "~> 0.1.1"}]
    end
```

  2. Ensure `ueberauth_line` is started before your application:

```elixir
    def application do
      [applications: [:ueberauth_line]]
    end
```

  3. Add Line to your Überauth configuration:

```elixir
    config :ueberauth, Ueberauth,
      providers: [
        line: {Ueberauth.Strategy.Line, []}
      ]
```
  4.  Update your provider configuration:

```elixir
    config :ueberauth, Ueberauth.Strategy.Line.OAuth,
      client_id: System.get_env("LINE_CLIENT_ID"),
      client_secret: System.get_env("LINE_CLIENT_SECRET")
```

  5.  Include the Überauth plug in your controller:

```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
```

  6.  Create the request and callback routes if you haven't already:

```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
```

## Set up LINE Channel

  Follow instructions here https://developers.line.me/line-login/overview

