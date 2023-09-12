defmodule ArvoreChallengeWeb.Context do
  @moduledoc false

  @behaviour Plug

  import Plug.Conn

  alias ArvoreChallenge.Authorizations.Guardian
  alias ArvoreChallenge.Partners.Entity

  @spec init(Keyword.t()) :: Keyword.t()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, entity} <- authorize(token) do
      %{current_entity: entity}
    else
      _ -> %{}
    end
  end

  defp authorize(token) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} -> return_current_entity(claims)
      {:error, reason} -> {:error, reason}
    end
  end

  defp return_current_entity(claims) do
    case Guardian.resource_from_claims(claims) do
      {:ok, %Entity{} = entity} -> {:ok, entity}
      {:error, reason} -> {:error, reason}
    end
  end
end
