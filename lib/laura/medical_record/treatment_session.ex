defmodule Laura.MedicalRecord.TreatmentSession do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "treatment_sessions" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :treatment, Laura.MedicalRecord.Treatment
    belongs_to :patient, Laura.Accounts.Patient
    belongs_to :staff, Laura.Accounts.Staff

    # Datos de la sesión
    field :session_date, :naive_datetime
    field :session_type, :string
    field :session_number, :integer
    field :duration, :integer

    # Procedimientos realizados (JSON flexible)
    field :procedures_performed, :map, default: %{}
    field :medications_administered, :map, default: %{}
    field :equipment_used, :map, default: %{}

    # Evaluación de la sesión
    field :subjective_feedback, :string
    field :objective_measures, :map, default: %{}
    field :therapist_notes, :string
    field :patient_progress, :string

    # Estado
    field :status, :string, default: "completed"

    # Relaciones
    has_many :inventory_transactions, Laura.Inventory.InventoryTransaction

    timestamps(type: :naive_datetime)
  end

  def changeset(treatment_session, attrs) do
    treatment_session
    |> cast(attrs, [
      :health_brand_id, :treatment_id, :patient_id, :staff_id,
      :session_date, :session_type, :session_number, :duration,
      :procedures_performed, :medications_administered, :equipment_used,
      :subjective_feedback, :objective_measures, :therapist_notes, :patient_progress,
      :status
    ])
    |> validate_required([:health_brand_id, :treatment_id, :patient_id, :staff_id, :session_date, :session_type, :session_number, :duration])
    |> validate_inclusion(:status, ["scheduled", "in_progress", "completed", "cancelled"])
    |> validate_inclusion(:patient_progress, ["excellent", "good", "fair", "poor"])
  end
end
