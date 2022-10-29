# UeberauthLine [![Hex pm](https://img.shields.io/hexpm/v/ueberauth_line.svg?style=flat)](https://hex.pm/packages/ueberauth_line) [![hex.pm downloads](https://img.shields.io/hexpm/dt/ueberauth_line.svg?style=flat)](https://hex.pm/packages/ueberauth_line) ![CI Build](https://github.com/alexfilatov/ueberauth_line/actions/workflows/elixir.yml/badge.svg)

**An Uberauth strategy for LINE OAuth2 authentication.**

Inspired by [Ueberauth for Facebook](https://github.com/ueberauth/ueberauth_facebook)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `ueberauth_line` to your list of dependencies in `mix.exs`:

```elixir
    def deps do
      [{:ueberauth_line, "~> 0.1.2"}]
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


## Side notes
This library uses Erlang `:crypto.strong_rand_bytes` for nonce and state generation. Make sure that `RAND_bytes` method from OpenSSL is available.

## Testing
A Cowboy Mock server is available for testing purposes.
Many thanks to Sophie DeBenedetto for the great tutorial on [server mocking in Elixir](https://medium.com/flatiron-labs/rolling-your-own-mock-server-for-testing-in-elixir-2cdb5ccdd1a0).
