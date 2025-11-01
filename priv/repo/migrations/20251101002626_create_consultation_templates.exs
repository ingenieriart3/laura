defmodule Laura.Repo.Migrations.CreateConsultationTemplates do
  use Ecto.Migration

  def change do
    create table(:consultation_templates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :health_brand_id, references(:health_brands, type: :binary_id, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :specialty, :string  # "general", "physiotherapy", "psychology"
      add :template_type, :string, null: false  # "initial", "follow_up", "specialized"
      add :template_structure, :map, null: false  # JSON structure of the template
      add :required_fields, :map, default: %{}
      add :is_active, :boolean, default: true, null: false

      timestamps(type: :naive_datetime)
    end

    create index(:consultation_templates, [:health_brand_id])
    create index(:consultation_templates, [:specialty])
    create index(:consultation_templates, [:template_type])
    create index(:consultation_templates, [:is_active])
  end
end
