defmodule LineLogin.Crypto.CodeChallenge do
  @moduledoc """
  Code challenge generation for PKCE compliant requests.
  """

  alias LineLogin.Crypto.StringGenerator

  @code_verifier_length 64

  @doc """
  Generate code verifier for PKCE compliant request.
  Available character types: A random string consisting of half-width alphanumeric characters (a-z, A-Z, 0-9) and symbols (-._~)
  Character count: 43-128 characters
  """
  def generate_code_verifier do
    StringGenerator.generate_string(@code_verifier_length)
  end

  @doc """
  Get code challenge from previously generated code verifier.
  """
  def get_code_challenge(code) when is_binary(code) do
    %{
      code_challenge: generate_code_challenge(code),
      code_challenge_method: :S256
    }
  end

  defp generate_code_challenge(code) do
    :crypto.hash(:sha256, code)
    |> Base.url_encode64(padding: false)
  end
end
