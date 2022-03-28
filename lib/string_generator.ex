defmodule StringGenerator do
  def generate_string(length) when length > 0 do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64(padding: false)
    |> binary_part(0, length)
  end
end
