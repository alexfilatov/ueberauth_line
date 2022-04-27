defmodule LineLogin.Crypto.StringGenerator do
  @moduledoc """
  String generator for cryptographic purposes.
  """

  @doc """
  Generate cryptographically random string. Url safe.
  """
  @spec generate_string(integer) :: binary
  def generate_string(length) when length > 0 do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end
end
