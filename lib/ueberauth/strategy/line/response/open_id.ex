defmodule Ueberauth.Strategy.Line.Response.OpenId do
  defstruct [
    :nonce,
    :name,
    :picture,
    :email,
    iss: "",
    sub: "",
    aud: "",
    exp: 0,
    iat: 0,
    amr: []
  ]
end
