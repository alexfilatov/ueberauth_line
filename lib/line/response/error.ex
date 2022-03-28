defmodule Line.Response.Error do
  defstruct error: "", error_description: ""

  @type t :: module

  @behaviour Http.ResponseApi

  @spec deserialize(map) :: t
  @impl true

  def deserialize(%{"error" => error, "error_description" => error_description}) do
    %__MODULE__{
      error: error,
      error_description: error_description
    }
  end
end
