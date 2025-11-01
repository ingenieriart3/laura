defmodule Laura.Billing.PatientInsurance do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "patient_insurances" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :patient, Laura.Accounts.Patient
    belongs_to :insurance_provider, Laura.Billing.InsuranceProvider

    field :policy_number, :string
    field :policy_holder_name, :string
    field :coverage_limits, :map, default: %{}
    field :copayment_amount, :decimal
    field :is_primary, :boolean, default: false
    field :is_active, :boolean, default: true

    timestamps(type: :naive_datetime)
  end

  def changeset(patient_insurance, attrs) do
    patient_insurance
    |> cast(attrs, [
      :health_brand_id,
      :patient_id,
      :insurance_provider_id,
      :policy_number,
      :policy_holder_name,
      :coverage_limits,
      :copayment_amount,
      :is_primary,
      :is_active
    ])
    |> validate_required([:health_brand_id, :patient_id, :insurance_provider_id, :policy_number])
  end
end
