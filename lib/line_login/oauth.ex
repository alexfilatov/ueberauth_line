defmodule LineLogin.OAuth do
  alias LineLogin.Request.Authorize

  def get_authorize_url(
        host \\ "https://access.line.me",
        %Authorize{} = request
      )
      when is_binary(host) do
    %{endpoint: endpoint, body: params} = Authorize.serialize(request)
    query = join_params(params)

    "#{host}#{endpoint}?#{query}"
  end

  defp join_params(params) do
    params
    |> Enum.map_join("&", fn {k, v} -> "#{k}=#{v}" end)
  end
end
