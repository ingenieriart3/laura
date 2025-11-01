defmodule Laura.Billing.InsuranceProvider do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "insurance_providers" do
    belongs_to :health_brand, Laura.Platform.HealthBrand

    field :name, :string
    field :contact_info, :map, default: %{}
    field :coverage_details, :map, default: %{}
    field :authorization_required, :boolean, default: false
    field :is_active, :boolean, default: true

    timestamps(type: :naive_datetime)
  end

  def changeset(insurance_provider, attrs) do
    insurance_provider
    |> cast(attrs, [
      :health_brand_id,
      :name,
      :contact_info,
      :coverage_details,
      :authorization_required,
      :is_active
    ])
    |> validate_required([:health_brand_id, :name])
  end
end
