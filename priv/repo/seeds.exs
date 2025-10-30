# # Script for populating the database. You can run it as:
# #
# #     mix run priv/repo/seeds.exs
# #
# # Inside the script, you can read and write to any of your
# # repositories directly:
# #
# #     Laura.Repo.insert!(%Laura.SomeSchema{})
# #
# # We recommend using the bang functions (`insert!`, `update!`
# # and so on) as they will fail if something goes wrong.

# # priv/repo/seeds.exs
# alias Laura.{Repo, Billing, Accounts}

# # Crear roles de staff
# admin_role = Repo.insert!(%Accounts.StaffRole{
#   name: "admin",
#   permissions: %{all: true}
# })

# doctor_role = Repo.insert!(%Accounts.StaffRole{
#   name: "doctor",
#   permissions: %{medical: true, scheduling: true}
# })

# receptionist_role = Repo.insert!(%Accounts.StaffRole{
#   name: "receptionist",
#   permissions: %{scheduling: true, patients: true}
# })

# # Crear planes de suscripción
# Billing.seed_subscription_plans!()

# IO.puts "✅ Database seeded successfully!"

# priv/repo/seeds.exs - ACTUALIZAR
alias Laura.{Repo, Billing, Accounts, Platform}

# Crear roles
admin_role = Repo.insert!(%Accounts.StaffRole{
  name: "admin",
  permissions: %{all: true}
})

doctor_role = Repo.insert!(%Accounts.StaffRole{
  name: "doctor",
  permissions: %{medical: true, scheduling: true}
})

# Crear planes
Billing.seed_subscription_plans!()

# Crear health brand demo
{:ok, demo_brand} = Platform.create_health_brand(%{
  name: "Clínica Demo",
  subdomain: "demo",
  subscription_plan_id: Billing.get_subscription_plan_by_code("basic").id
})

IO.puts "✅ Database seeded successfully!"
