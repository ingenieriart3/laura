defmodule Laura.Repo.Migrations.CreateMessageTemplates do
  use Ecto.Migration

  def change do
    create table(:message_templates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false

      # Configuración de la plantilla
      add :name, :string, null: false
      add :description, :text
      add :template_type, :string, null: false # appointment_reminder, follow_up, marketing, internal
      add :channel, :string, null: false # whatsapp, email, sms, all

      # Contenido de la plantilla
      add :subject, :string
      add :body, :text, null: false
      add :variables, :map, default: %{} # {patient_name: "Nombre del paciente", appointment_date: "Fecha del turno"}

      # Configuración de automatización
      add :is_auto_send, :boolean, default: false
      add :trigger_event, :string # appointment_scheduled, appointment_reminder, follow_up
      add :send_delay_hours, :integer, default: 0

      # Aprobación y estado
      add :is_active, :boolean, default: true
      add :requires_approval, :boolean, default: false
      add :approved_by_staff_id, :binary_id
      add :approved_at, :naive_datetime

      # Estadísticas
      add :usage_count, :integer, default: 0
      add :last_used_at, :naive_datetime

      timestamps(type: :naive_datetime)
    end

    create index(:message_templates, [:health_brand_id])
    create index(:message_templates, [:template_type])
    create index(:message_templates, [:channel])
    create index(:message_templates, [:is_active])
    create index(:message_templates, [:trigger_event])
  end
end
