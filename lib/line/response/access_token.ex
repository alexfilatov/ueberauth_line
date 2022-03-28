defmodule Line.Response.AccessToken do
  defstruct access_token: "",
            expires_in: 0,
            id_token: "",
            refresh_token: "",
            scope: "",
            token_type: ""

  @type t :: module

  @behaviour Http.ResponseApi

  @spec deserialize(map) :: t
  @impl true
  def deserialize(%{
        "access_token" => access_token,
        "expires_in" => expires_in,
        "id_token" => id_token,
        "refresh_token" => refresh_token,
        "scope" => scope,
        "token_type" => token_type
      }) do
    %__MODULE__{
      access_token: access_token,
      expires_in: expires_in,
      id_token: id_token,
      refresh_token: refresh_token,
      scope: scope,
      token_type: token_type
    }
  end
end
