import Config

config :ueberauth_line, api_base_url: "https://api.line.me"

config :ueberauth,
       Ueberauth,
       providers: [
         line:
           {Ueberauth.Strategy.Line,
            [
              default_scope: "profile openid email"
            ]}
       ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
