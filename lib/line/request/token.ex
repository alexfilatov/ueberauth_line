defmodule Line.Request.Token do
  defstruct [
    :code_verifier,
    grant_type: "",
    code: "",
    redirect_uri: "",
    client_id: "",
    client_secret: ""
  ]

  @enforce_keys [:grant_type, :code, :redirect_uri, :client_id, :client_secret]

  @type t :: module

  alias Http.RequestApi
  alias Line.Request.Token

  @behaviour RequestApi

  @spec serialize(t) :: map
  @doc """
  Serialize the Request into map
  """
  @impl true
  def serialize(%Token{} = token) do
    %{
      "grant_type" => token.grant_type,
      "code" => token.code,
      "redirect_uri" => token.redirect_uri,
      "client_id" => token.client_id,
      "client_secret" => token.client_secret
    }
    |> maybe_put_optional(token)
  end

  defp maybe_put_optional(request, %{code_verifier: code_verifier}) when is_nil(code_verifier),
    do: request

  defp maybe_put_optional(request, %{code_verifier: code_verifier}) do
    request
    |> Map.put("code_verifier", code_verifier)
  end
end
