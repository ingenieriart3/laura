defmodule Laura.Accounts.Patient do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "patients" do
    # Relaciones
    belongs_to :health_brand, Laura.Platform.HealthBrand

    # Datos personales
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :phone, :string
    field :birth_date, :date
    field :gender, :string
    field :national_id, :string

    # Dirección
    field :address, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string

    # Contacto de emergencia
    field :emergency_contact_name, :string
    field :emergency_contact_phone, :string
    field :emergency_contact_relation, :string

    # Información médica base
    field :blood_type, :string
    field :allergies, :string
    field :current_medications, :string
    field :medical_conditions, :string

    # Metadata
    field :is_active, :boolean, default: true
    field :notes, :string

    # Relaciones has_many
    has_many :appointments, Laura.Scheduling.Appointment
    has_many :medical_records, Laura.MedicalRecord.MedicalRecord
    has_many :treatments, Laura.MedicalRecord.Treatment
    has_many :invoices, Laura.Billing.Invoice
    has_many :conversations, Laura.Messaging.Conversation

    timestamps(type: :naive_datetime)
  end

  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [
      :health_brand_id, :first_name, :last_name, :email, :phone, :birth_date,
      :gender, :national_id, :address, :city, :state, :zip_code,
      :emergency_contact_name, :emergency_contact_phone, :emergency_contact_relation,
      :blood_type, :allergies, :current_medications, :medical_conditions,
      :is_active, :notes
    ])
    |> validate_required([:health_brand_id, :first_name, :last_name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "debe tener un formato válido")
    |> unique_constraint([:national_id, :health_brand_id])
  end
end
