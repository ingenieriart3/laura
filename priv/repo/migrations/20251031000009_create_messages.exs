defmodule Laura.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false

      # Remitente y destinatario
      add :from_staff_id, :binary_id
      add :to_staff_id, :binary_id
      add :to_patient_id, :binary_id
      add :conversation_id, :binary_id

      # Contenido del mensaje
      add :message_type, :string, null: false # email, sms, whatsapp, internal, system
      add :subject, :string
      add :body, :text, null: false
      add :attachments, :map, default: %{} # {filename: "doc.pdf", url: "...", size: 1234}

      # Estado y entrega
      add :status, :string, default: "draft" # draft, sent, delivered, read, failed
      add :sent_at, :naive_datetime
      add :delivered_at, :naive_datetime
      add :read_at, :naive_datetime

      # Metadata para mensajes externos
      add :external_message_id, :string # ID de WhatsApp/Email provider
      add :delivery_status, :map, default: %{}
      add :error_message, :text

      # Para recordatorios automáticos
      add :is_reminder, :boolean, default: false
      add :reminder_template, :string
      add :appointment_id, :binary_id

      timestamps(type: :naive_datetime)
    end

    create index(:messages, [:health_brand_id])
    create index(:messages, [:from_staff_id])
    create index(:messages, [:to_staff_id])
    create index(:messages, [:to_patient_id])
    create index(:messages, [:conversation_id])
    create index(:messages, [:message_type])
    create index(:messages, [:status])
    create index(:messages, [:appointment_id])
    create index(:messages, [:external_message_id])
  end
end
