# priv/repo/seeds.exs
alias Laura.{Repo, Accounts, Platform, Billing}

# Clean existing data
Repo.delete_all(Accounts.Staff)
Repo.delete_all(Platform.HealthBrand)
Repo.delete_all(Accounts.StaffRole)
Repo.delete_all(Billing.SubscriptionPlan)
Repo.delete_all(Billing.PaymentEvent)

IO.puts "🌱 Seeding database..."

# Create subscription plans
Billing.seed_subscription_plans!()
IO.puts "✅ Subscription plans created"

# Create staff roles
admin_role = Repo.insert!(%Accounts.StaffRole{
  name: "admin",
  permissions: %{all: true}
})

doctor_role = Repo.insert!(%Accounts.StaffRole{
  name: "doctor",
  permissions: %{medical: true, scheduling: true}
})

reception_role = Repo.insert!(%Accounts.StaffRole{
  name: "reception",
  permissions: %{scheduling: true, patient_management: true}
})

IO.puts "✅ Staff roles created"

# Create demo health brand with trial
basic_plan = Billing.get_subscription_plan_by_code("basic")

{:ok, demo_brand} = Platform.create_health_brand(%{
  name: "Clínica Demo",
  subdomain: "demo",
  subscription_plan_id: basic_plan.id
})

IO.puts "✅ Demo health brand created (30-day trial active)"

# Create admin staff for demo
{:ok, admin_staff} = Accounts.create_staff(%{
  email: "ingenieriart3@gmail.com",
  health_brand_id: demo_brand.id,
  staff_role_id: admin_role.id,
  confirmed_at: NaiveDateTime.utc_now(),
  is_active: true
})

# Create doctor staff
{:ok, doctor_staff} = Accounts.create_staff(%{
  email: "sana.medintegrativa@gmail.com",
  health_brand_id: demo_brand.id,
  staff_role_id: doctor_role.id,
  confirmed_at: NaiveDateTime.utc_now(),
  is_active: true
})

IO.puts "✅ Staff accounts created"

IO.puts """
🎉 SEEDING COMPLETED!

📧 Demo Accounts:
   Admin: admin@demo.com
   Doctor: doctor@demo.com

🏥 Health Brand:
   Name: #{demo_brand.name}
   Subdomain: #{demo_brand.subdomain}
   Trial ends: #{NaiveDateTime.to_string(demo_brand.trial_ends_at)}

🔗 Magic Links will be printed in console when requested.

🌐 Access: http://localhost:4000/auth
"""
