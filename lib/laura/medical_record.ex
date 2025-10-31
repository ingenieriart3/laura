# # lib/laura/medical_record.ex
# defmodule Laura.MedicalRecord do
#   def child_spec(_opts) do
#     %{
#       id: __MODULE__,
#       start: {__MODULE__, :start_link, []},
#       type: :worker,
#       restart: :permanent,
#       shutdown: 500
#     }
#   end

#   def start_link, do: :ignore
# end

defmodule Laura.MedicalRecord do
  import Ecto.Query, warn: false
  alias Laura.Repo
  alias Laura.MedicalRecord.{MedicalRecord, Treatment, TreatmentSession}

  # Medical Records
  def list_medical_records(health_brand_id, patient_id \\ nil) do
    query = from mr in MedicalRecord,
            where: mr.health_brand_id == ^health_brand_id,
            order_by: [desc: mr.inserted_at],
            preload: [:patient, :staff, :appointment]

    query = if patient_id, do: where(query, [mr], mr.patient_id == ^patient_id), else: query

    Repo.all(query)
  end

  def get_medical_record!(id), do: Repo.get!(MedicalRecord, id)

  def create_medical_record(attrs \\ %{}) do
    %MedicalRecord{}
    |> MedicalRecord.changeset(attrs)
    |> Repo.insert()
  end

  def update_medical_record(%MedicalRecord{} = medical_record, attrs) do
    medical_record
    |> MedicalRecord.changeset(attrs)
    |> Repo.update()
  end

  # Treatments
  def list_treatments(health_brand_id, patient_id \\ nil) do
    query = from t in Treatment,
            where: t.health_brand_id == ^health_brand_id,
            order_by: [desc: t.start_date],
            preload: [:patient, :staff, :medical_record]

    query = if patient_id, do: where(query, [t], t.patient_id == ^patient_id), else: query

    Repo.all(query)
  end

  def get_treatment!(id), do: Repo.get!(Treatment, id)

  def create_treatment(attrs \\ %{}) do
    %Treatment{}
    |> Treatment.changeset(attrs)
    |> Repo.insert()
  end

  def update_treatment(%Treatment{} = treatment, attrs) do
    treatment
    |> Treatment.changeset(attrs)
    |> Repo.update()
  end

  def complete_treatment(%Treatment{} = treatment) do
    treatment
    |> Treatment.changeset(%{
      status: "completed",
      end_date: Date.utc_today(),
      completed_sessions: treatment.expected_sessions || treatment.completed_sessions
    })
    |> Repo.update()
  end

  # Treatment Sessions
  def list_treatment_sessions(health_brand_id, treatment_id \\ nil) do
    query = from ts in TreatmentSession,
            where: ts.health_brand_id == ^health_brand_id,
            order_by: [desc: ts.session_date],
            preload: [:patient, :staff, :treatment]

    query = if treatment_id, do: where(query, [ts], ts.treatment_id == ^treatment_id), else: query

    Repo.all(query)
  end

  def get_treatment_session!(id), do: Repo.get!(TreatmentSession, id)

  def create_treatment_session(attrs \\ %{}) do
    %TreatmentSession{}
    |> TreatmentSession.changeset(attrs)
    |> Repo.insert()
  end

  def update_treatment_session(%TreatmentSession{} = treatment_session, attrs) do
    treatment_session
    |> TreatmentSession.changeset(attrs)
    |> Repo.update()
  end

  # Business logic
  def get_patient_timeline(health_brand_id, patient_id) do
    records = list_medical_records(health_brand_id, patient_id)
    treatments = list_treatments(health_brand_id, patient_id)
    sessions = list_treatment_sessions(health_brand_id)

    # Combinar y ordenar por fecha
    timeline =
      (Enum.map(records, &Map.put(&1, :type, :medical_record)) ++
       Enum.map(treatments, &Map.put(&1, :type, :treatment)) ++
       Enum.map(sessions, &Map.put(&1, :type, :treatment_session)))
      |> Enum.sort_by(fn
        %{inserted_at: inserted_at} -> inserted_at
        %{session_date: session_date} -> session_date
        %{start_date: start_date} -> NaiveDateTime.new(start_date, ~T[00:00:00])
      end, {:desc, NaiveDateTime})

    timeline
  end
end
