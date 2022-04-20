import Config

config :ueberauth,
       Ueberauth,
       providers: [
         line:
           {Ueberauth.Strategy.Line,
            [
              default_scope: "profile openid email"
            ]}
       ]

config :ueberauth,
       Ueberauth.Strategy.Line.OAuth,
       client_id: "randomClientId1234",
       client_secret: "testClientSecret",
       token_url: "token_url"
