import Config

config :ueberauth_line, api_base_url: "http://localhost:8081"

config :ueberauth,
       Ueberauth.Strategy.Line.OAuth,
       client_id: "client_id_valid",
       client_secret: "client_secret_valid",
       token_url: "token_url"
