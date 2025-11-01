# # lib/laura/medical_record/consultation_template.ex
# defmodule Laura.MedicalRecord.ConsultationTemplate do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "consultation_templates" do
#     belongs_to :health_brand, Laura.Platform.HealthBrand

#     field :name, :string
#     field :specialty, :string
#     field :template_type, :string
#     field :template_structure, :map, default: %{}
#     field :required_fields, :map, default: %{}
#     field :is_active, :boolean, default: true

#     timestamps(type: :naive_datetime)
#   end

#   def changeset(consultation_template, attrs) do
#     consultation_template
#     |> cast(attrs, [
#       :health_brand_id,
#       :name,
#       :specialty,
#       :template_type,
#       :template_structure,
#       :required_fields,
#       :is_active
#     ])
#     |> validate_required([:health_brand_id, :name, :template_type])
#     |> validate_inclusion(:template_type, ["initial", "follow_up", "procedure", "emergency"])
#   end
# end
defmodule Laura.MedicalRecord.ConsultationTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "consultation_templates" do
    belongs_to :health_brand, Laura.Platform.HealthBrand

    field :name, :string
    field :specialty, :string
    field :template_type, :string
    field :template_structure, :map, default: %{}
    field :required_fields, :map, default: %{}
    field :is_active, :boolean, default: true

    timestamps(type: :naive_datetime)
  end

  def changeset(consultation_template, attrs) do
    consultation_template
    |> cast(attrs, [
      :health_brand_id,
      :name,
      :specialty,
      :template_type,
      :template_structure,
      :required_fields,
      :is_active
    ])
    |> validate_required([:health_brand_id, :name, :template_type])
  end
end
