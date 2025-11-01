# # lib/laura/security/staff_invitation.ex
# defmodule Laura.Security.StaffInvitation do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "staff_invitations" do
#     belongs_to :health_brand, Laura.Platform.HealthBrand
#     belongs_to :invited_by_staff, Laura.Accounts.Staff
#     belongs_to :staff_role, Laura.Accounts.StaffRole

#     field :email, :string
#     field :token, :string
#     field :status, :string, default: "pending"
#     field :expires_at, :naive_datetime
#     field :accepted_at, :naive_datetime

#     timestamps(type: :naive_datetime)
#   end

#   def changeset(staff_invitation, attrs) do
#     staff_invitation
#     |> cast(attrs, [
#       :health_brand_id,
#       :invited_by_staff_id,
#       :staff_role_id,
#       :email,
#       :token,
#       :status,
#       :expires_at,
#       :accepted_at
#     ])
#     |> validate_required([:health_brand_id, :invited_by_staff_id, :email, :token, :expires_at])
#     |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
#     |> validate_inclusion(:status, ["pending", "accepted", "expired", "cancelled"])
#     |> unique_constraint([:health_brand_id, :email], name: :staff_invitations_health_brand_id_email_index)
#     |> unique_constraint(:token)
#   end
# end

defmodule Laura.Security.StaffInvitation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "staff_invitations" do
    belongs_to :health_brand, Laura.Platform.HealthBrand
    belongs_to :invited_by_staff, Laura.Accounts.Staff
    belongs_to :staff_role, Laura.Accounts.StaffRole

    field :email, :string
    field :token, :string
    field :status, :string, default: "pending"
    field :expires_at, :naive_datetime
    field :accepted_at, :naive_datetime

    timestamps(type: :naive_datetime)
  end

  def changeset(staff_invitation, attrs) do
    staff_invitation
    |> cast(attrs, [
      :health_brand_id,
      :invited_by_staff_id,
      :staff_role_id,
      :email,
      :token,
      :status,
      :expires_at,
      :accepted_at
    ])
    |> validate_required([:health_brand_id, :invited_by_staff_id, :email, :token, :expires_at])
  end
end
