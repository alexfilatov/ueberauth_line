defmodule Line.Request.VerifyIdToken do
  defstruct [:nonce, :user_id, id_token: "", client_id: ""]

  @enforce_keys [:id_token, :client_id]
end
