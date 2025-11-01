defmodule Laura.Billing.PaymentIntegration do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "payment_integrations" do
    belongs_to :health_brand, Laura.Platform.HealthBrand

    field :provider, :string
    field :access_token, :string
    field :public_key, :string
    field :is_active, :boolean, default: true
    field :webhook_url, :string
    field :metadata, :map, default: %{}

    timestamps(type: :naive_datetime)
  end

  def changeset(payment_integration, attrs) do
    payment_integration
    |> cast(attrs, [
      :health_brand_id,
      :provider,
      :access_token,
      :public_key,
      :is_active,
      :webhook_url,
      :metadata
    ])
    |> validate_required([:health_brand_id, :provider])
  end
end
