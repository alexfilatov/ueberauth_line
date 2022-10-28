defmodule LineLogin.ClientAdapter do
  @moduledoc """
  This is the HttpPoison implementation for the Lucid Modules Http.
  """

  alias LmHttp.ClientAdapter
  alias LmHttp.Method

  @behaviour LmHttp.ClientAdapter

  @allowed_methods Method.get_all()

  @spec request(ClientAdapter.serialized_request()) :: ClientAdapter.result()
  @doc """
  Returns response converted to the result
  """
  @impl true
  def request(%{method: method})
      when method not in @allowed_methods,
      do: {:error, "invalid HTTP method"}

  def request(%{method: :get, endpoint: url, headers: headers}) do
    HTTPoison.get(get_url(url), headers)
    |> handle_result
  end

  def request(%{method: method, endpoint: url, headers: headers, body: payload}) do
    HTTPoison.request(method, get_url(url), {:form, payload}, headers)
    |> handle_result
  end

  defp get_url(endpoint) when is_binary(endpoint) do
    Application.get_env(:ueberauth_line, :api_base_url, "https://api.line.me") <> endpoint
  end

  defp handle_result(
         {:ok, %HTTPoison.Response{body: body, headers: headers, status_code: status_code}}
       ) do
    %{status: status_code, body: deserialize_body(body), headers: headers}
  end

  defp handle_result({:ok, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  defp deserialize_body(body) when is_binary(body), do: Jason.decode!(body)
  defp deserialize_body(body), do: body

  #  TODO: handle other types
  #  {:ok,
  #    HTTPoison.Response.t()
  #    | HTTPoison.AsyncResponse.t()
  #    | HTTPoison.MaybeRedirect.t()}
  #  | {:error, HTTPoison.Error.t()}

  #  defp handle_result(result) do
  #    case result do
  #      {:ok, status, headers, ref} ->
  #        %{status: status, body: process_body(ref), headers: headers}
  #
  #      {:error, reason} ->
  #        {:error, reason}
  #    end
  #  end
end
