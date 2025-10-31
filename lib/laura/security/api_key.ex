defmodule Laura.Security.ApiKey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "api_keys" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :staff, Laura.Accounts.Staff

    # Información de la API Key
    field :name, :string
    field :key_prefix, :string
    field :key_hash, :string
    field :scopes, :map, default: %{}

    # Estado y seguridad
    field :is_active, :boolean, default: true
    field :last_used_at, :naive_datetime
    field :expires_at, :naive_datetime
    field :revoked_at, :naive_datetime

    # Límites y uso
    field :rate_limit, :integer, default: 1000
    field :usage_count, :integer, default: 0

    timestamps(type: :naive_datetime)
  end

  def changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [
      :health_brand_id, :staff_id, :name, :key_prefix, :key_hash, :scopes,
      :is_active, :last_used_at, :expires_at, :revoked_at, :rate_limit, :usage_count
    ])
    |> validate_required([:health_brand_id, :staff_id, :name, :key_prefix, :key_hash])
  end
end
