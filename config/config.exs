import Config

config :ueberauth_line, Http.Client, client: Http.ClientHackney

config :ueberauth,
       Ueberauth,
       providers: [
         line:
           {Ueberauth.Strategy.Line,
            [
              default_scope: "profile%20email"
            ]}
       ]

config :ueberauth,
       Ueberauth.Strategy.Line.OAuth,
       client_id: "randomClientId1234",
       client_secret: "testClientSecret",
       token_url: "token_url"
