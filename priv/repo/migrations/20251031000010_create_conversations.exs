defmodule Laura.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, :binary_id, null: false

      # Participantes
      add :patient_id, :binary_id, null: false
      add :staff_ids, :map, default: %{} # {staff_id: true} para múltiples participantes

      # Metadata de la conversación
      add :title, :string
      add :conversation_type, :string, null: false # patient_staff, internal, broadcast
      add :last_message_at, :naive_datetime
      add :last_message_preview, :text

      # Estado
      add :is_archived, :boolean, default: false
      add :is_resolved, :boolean, default: false
      add :priority, :string, default: "normal" # low, normal, high, urgent

      # Etiquetas y categorización
      add :tags, :map, default: %{}
      add :category, :string

      timestamps(type: :naive_datetime)
    end

    create index(:conversations, [:health_brand_id])
    create index(:conversations, [:patient_id])
    create index(:conversations, [:conversation_type])
    create index(:conversations, [:last_message_at])
    create index(:conversations, [:is_archived])
    create index(:conversations, [:is_resolved])
    create index(:conversations, [:priority])
  end
end
