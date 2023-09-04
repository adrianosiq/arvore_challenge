defmodule ArvoreChallenge.Repo do
  use Ecto.Repo,
    otp_app: :arvore_challenge,
    adapter: Ecto.Adapters.MyXQL
end
