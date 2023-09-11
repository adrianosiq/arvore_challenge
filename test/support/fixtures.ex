defmodule ArvoreChallenge.Fixtures do
  @moduledoc false
  alias ArvoreChallenge.Repo

  def build(:entity) do
    %ArvoreChallenge.Partners.Entity{
      entity_type: :network,
      inep: nil,
      name: Faker.Pokemon.name(),
      parent_id: nil,
      access_key: random_string(32),
      secret_access_key: random_string(64)
    }
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.encode64(padding: false) |> binary_part(0, length)
  end

  def build(fixture_name, attributes) do
    fixture_name |> build() |> struct(attributes)
  end

  def insert!(fixture_name, attributes \\ %{}, opts \\ [])

  def insert!(fixture_name, attributes, opts) do
    preload = Keyword.get_values(opts, :preload)

    fixture_name
    |> build(attributes)
    |> Repo.insert!()
    |> Repo.preload(preload)
  end
end
