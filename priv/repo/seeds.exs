# priv/repo/seeds.exs
alias Laura.{Repo, Accounts, Platform, Billing, Scheduling, MedicalRecord, Inventory, Messaging, Analytics, Security}
alias Laura.Accounts.{Staff, StaffRole, Patient}
alias Laura.Platform.{HealthBrand, MedicalConfig}
alias Laura.Scheduling.{Appointment, StaffAvailability}
alias Laura.MedicalRecord.{MedicalRecord, Treatment, TreatmentSession}
alias Laura.Inventory.{Inventory, InventoryTransaction}
alias Laura.Messaging.{Message, Conversation, MessageTemplate}
alias Laura.Billing.{Invoice, PaymentEvent}
alias Laura.Analytics.AnalyticsEvent
alias Laura.Security.{ApiKey, Webhook}

# Clean existing data (en orden correcto para constraints)
IO.puts "🧹 Cleaning database..."

Repo.delete_all(InventoryTransaction)
Repo.delete_all(Inventory)
Repo.delete_all(TreatmentSession)
Repo.delete_all(Treatment)
Repo.delete_all(MedicalRecord)
Repo.delete_all(Appointment)
Repo.delete_all(StaffAvailability)
Repo.delete_all(Invoice)
Repo.delete_all(PaymentEvent)
Repo.delete_all(Message)
Repo.delete_all(Conversation)
Repo.delete_all(MessageTemplate)
Repo.delete_all(Patient)
Repo.delete_all(Staff)
Repo.delete_all(MedicalConfig)
Repo.delete_all(HealthBrand)
Repo.delete_all(StaffRole)
Repo.delete_all(Billing.SubscriptionPlan)

IO.puts "🌱 Seeding database..."

# 1. Subscription Plans
Billing.seed_subscription_plans!()
IO.puts "✅ Subscription plans created"

# 2. Staff Roles
admin_role = Repo.insert!(%StaffRole{
  name: "admin",
  permissions: %{
    all: true,
    medical: true,
    billing: true,
    scheduling: true,
    inventory: true,
    messaging: true
  }
})

doctor_role = Repo.insert!(%StaffRole{
  name: "doctor",
  permissions: %{
    medical: true,
    scheduling: true,
    patient_management: true,
    messaging: true
  }
})

reception_role = Repo.insert!(%StaffRole{
  name: "reception",
  permissions: %{
    scheduling: true,
    patient_management: true,
    billing: true,
    messaging: true
  }
})

therapist_role = Repo.insert!(%StaffRole{
  name: "therapist",
  permissions: %{
    medical: true,
    scheduling: true,
    patient_management: true,
    inventory: true
  }
})

IO.puts "✅ Staff roles created"

# 3. Health Brands con diferentes planes
basic_plan = Billing.get_subscription_plan_by_code("basic")
professional_plan = Billing.get_subscription_plan_by_code("professional")

# Health Brand 1 - Clínica Demo (Básico)
{:ok, demo_brand} = Platform.create_health_brand(%{
  name: "Clínica Demo - Fisioterapia Avanzada",
  subdomain: "demo",
  subscription_plan_id: basic_plan.id
})

# Health Brand 2 - Otro tenant (Profesional)
{:ok, _otra_clinica} = Platform.create_health_brand(%{
  name: "Centro de Rehabilitación Integral",
  subdomain: "rehab",
  subscription_plan_id: professional_plan.id
})

IO.puts "✅ Health brands created"

# 4. Medical Configs para cada health brand
{:ok, _} = Platform.create_medical_config(%{
  health_brand_id: demo_brand.id,
  treatment_categories: %{
    "fisioterapia" => "Fisioterapia",
    "kinesiologia" => "Kinesiología",
    "rehabilitacion" => "Rehabilitación",
    "masajes" => "Masajes Terapéuticos",
    "osteopatia" => "Osteopatía"
  },
  procedure_templates: %{
    "evaluacion_inicial" => "Evaluación Inicial",
    "sesion_terapeutica" => "Sesión Terapéutica",
    "control_seguimiento" => "Control de Seguimiento",
    "terapia_manual" => "Terapia Manual"
  },
  medication_categories: %{
    "analgesicos" => "Analgésicos",
    "antiinflamatorios" => "Antiinflamatorios",
    "relajantes" => "Relajantes Musculares"
  },
  appointment_duration: 45,
  business_hours: %{
    "monday" => %{"start" => "08:00", "end" => "18:00"},
    "tuesday" => %{"start" => "08:00", "end" => "18:00"},
    "wednesday" => %{"start" => "08:00", "end" => "18:00"},
    "thursday" => %{"start" => "08:00", "end" => "18:00"},
    "friday" => %{"start" => "08:00", "end" => "17:00"}
  }
})

IO.puts "✅ Medical configs created"

# 5. Staff para cada health brand
# Staff para Clínica Demo
{:ok, _admin_staff} = Accounts.create_staff(%{
  email: "admin@demo.com",
  health_brand_id: demo_brand.id,
  staff_role_id: admin_role.id,
  confirmed_at: NaiveDateTime.utc_now(),
  is_active: true
})

{:ok, doctor_staff} = Accounts.create_staff(%{
  email: "dr.gonzalez@demo.com",
  health_brand_id: demo_brand.id,
  staff_role_id: doctor_role.id,
  confirmed_at: NaiveDateTime.utc_now(),
  is_active: true
})

{:ok, therapist_staff} = Accounts.create_staff(%{
  email: "terapeuta@demo.com",
  health_brand_id: demo_brand.id,
  staff_role_id: therapist_role.id,
  confirmed_at: NaiveDateTime.utc_now(),
  is_active: true
})

{:ok, _reception_staff} = Accounts.create_staff(%{
  email: "recepcion@demo.com",
  health_brand_id: demo_brand.id,
  staff_role_id: reception_role.id,
  confirmed_at: NaiveDateTime.utc_now(),
  is_active: true
})

IO.puts "✅ Staff accounts created"

# 6. Patients de ejemplo
patients = [
  %{
    health_brand_id: demo_brand.id,
    first_name: "Ana",
    last_name: "García",
    email: "ana.garcia@email.com",
    phone: "+5491154321000",
    birth_date: ~D[1985-03-15],
    gender: "femenino",
    address: "Av. Corrientes 1234",
    city: "Buenos Aires",
    emergency_contact_name: "Carlos García",
    emergency_contact_phone: "+5491154321001",
    blood_type: "A+",
    allergies: "Penicilina",
    medical_conditions: "Hipertensión controlada"
  },
  %{
    health_brand_id: demo_brand.id,
    first_name: "Luis",
    last_name: "Martínez",
    email: "luis.martinez@email.com",
    phone: "+5491154321002",
    birth_date: ~D[1978-07-22],
    gender: "masculino",
    address: "Calle Florida 567",
    city: "Buenos Aires",
    emergency_contact_name: "María Martínez",
    emergency_contact_phone: "+5491154321003",
    blood_type: "O+",
    allergies: "Ninguna",
    medical_conditions: "Lumbalgia crónica"
  },
  %{
    health_brand_id: demo_brand.id,
    first_name: "María",
    last_name: "López",
    email: "maria.lopez@email.com",
    phone: "+5491154321004",
    birth_date: ~D[1990-11-30],
    gender: "femenino",
    address: "Av. Santa Fe 2345",
    city: "Buenos Aires",
    emergency_contact_name: "Roberto López",
    emergency_contact_phone: "+5491154321005",
    blood_type: "B+",
    allergies: "Mariscos",
    medical_conditions: "Ninguna"
  }
]

Enum.each(patients, fn patient_attrs ->
  {:ok, _} = Accounts.create_patient(patient_attrs)
end)

IO.puts "✅ Patients created"

# 7. Staff Availability
availability_entries = [
  %{
    health_brand_id: demo_brand.id,
    staff_id: doctor_staff.id,
    availability_type: "regular",
    day_of_week: 1, # Lunes
    start_time: ~T[09:00:00],
    end_time: ~T[17:00:00],
    slot_duration: 45
  },
  %{
    health_brand_id: demo_brand.id,
    staff_id: doctor_staff.id,
    availability_type: "regular",
    day_of_week: 2, # Martes
    start_time: ~T[09:00:00],
    end_time: ~T[17:00:00],
    slot_duration: 45
  },
  %{
    health_brand_id: demo_brand.id,
    staff_id: therapist_staff.id,
    availability_type: "regular",
    day_of_week: 3, # Miércoles
    start_time: ~T[08:00:00],
    end_time: ~T[16:00:00],
    slot_duration: 60
  }
]

Enum.each(availability_entries, fn availability_attrs ->
  {:ok, _} = Scheduling.create_staff_availability(availability_attrs)
end)

IO.puts "✅ Staff availability created"

# 8. Appointments
patients = Accounts.list_patients(demo_brand.id)
[patient1, patient2, _patient3] = patients

appointments = [
  %{
    health_brand_id: demo_brand.id,
    patient_id: patient1.id,
    staff_id: doctor_staff.id,
    scheduled_for: NaiveDateTime.add(NaiveDateTime.utc_now(), 2 * 24 * 60 * 60), # En 2 días
    duration: 45,
    appointment_type: "evaluacion_inicial",
    status: "confirmed",
    reason_for_visit: "Dolor lumbar persistente"
  },
  %{
    health_brand_id: demo_brand.id,
    patient_id: patient2.id,
    staff_id: therapist_staff.id,
    scheduled_for: NaiveDateTime.add(NaiveDateTime.utc_now(), 3 * 24 * 60 * 60), # En 3 días
    duration: 60,
    appointment_type: "sesion_terapeutica",
    status: "scheduled",
    reason_for_visit: "Seguimiento tratamiento rehabilitación"
  }
]

Enum.each(appointments, fn appointment_attrs ->
  {:ok, _} = Scheduling.create_appointment(appointment_attrs)
end)

IO.puts "✅ Appointments created"

# 9. Medical Records
appointments = Scheduling.list_appointments(demo_brand.id)
[appointment1, _] = appointments

{:ok, medical_record1} = Laura.MedicalRecord.create_medical_record(%{
  health_brand_id: demo_brand.id,
  patient_id: patient1.id,
  appointment_id: appointment1.id,
  staff_id: doctor_staff.id,
  record_type: "consultation",
  vital_signs: %{
    "presion_arterial" => "120/80",
    "frecuencia_cardiaca" => 72,
    "temperatura" => 36.5
  },
  subjective: "Paciente refiere dolor lumbar de 3 meses de evolución, que empeora con la actividad física.",
  objective: "Limitación en la flexión lumbar, dolor a la palpación en L4-L5.",
  assessment: "Lumbalgia mecánica aguda.",
  plan: "Iniciar tratamiento de fisioterapia, ejercicios de fortalecimiento core."
})

IO.puts "✅ Medical records created"

# 10. Treatments
{:ok, treatment1} = Laura.MedicalRecord.create_treatment(%{
  health_brand_id: demo_brand.id,
  patient_id: patient1.id,
  medical_record_id: medical_record1.id,
  staff_id: therapist_staff.id,
  name: "Tratamiento de Fisioterapia para Lumbalgia",
  description: "Plan de 8 sesiones para mejorar dolor lumbar",
  treatment_plan: %{
    "sesiones_totales" => 8,
    "frecuencia" => "2 veces por semana",
    "objetivos" => ["Reducir dolor", "Mejorar movilidad", "Fortalecer musculatura"]
  },
  diagnosis_codes: %{"lumbalgia" => "M54.5"},
  start_date: Date.utc_today(),
  expected_sessions: 8
})

IO.puts "✅ Treatments created"

# 11. Treatment Sessions
{:ok, _} = Laura.MedicalRecord.create_treatment_session(%{
  health_brand_id: demo_brand.id,
  treatment_id: treatment1.id,
  patient_id: patient1.id,
  staff_id: therapist_staff.id,
  session_date: NaiveDateTime.utc_now(),
  session_type: "sesion_terapeutica",
  session_number: 1,
  duration: 60,
  procedures_performed: %{
    "terapia_manual" => "Movilizaciones vertebrales",
    "ejercicios" => "Estabilización lumbar"
  },
  subjective_feedback: "Paciente refiere mejoría del 30% en el dolor",
  patient_progress: "good"
})

IO.puts "✅ Treatment sessions created"

# 12. Inventory
inventory_items = [
  %{
    health_brand_id: demo_brand.id,
    name: "Ibuprofeno 400mg",
    description: "Analgésico y antiinflamatorio",
    category: "medicamentos",
    item_type: "medication",
    current_stock: 50,
    min_stock: 10,
    unit_cost: Decimal.new("0.50"),
    unit_price: Decimal.new("2.00"),
    medication_data: %{
      "presentacion" => "Tabletas",
      "dosis" => "400mg",
      "laboratorio" => "Bayer"
    }
  },
  %{
    health_brand_id: demo_brand.id,
    name: "Vendas Elásticas",
    description: "Vendas de 10cm x 4m",
    category: "insumos",
    item_type: "supply",
    current_stock: 25,
    min_stock: 5,
    unit_cost: Decimal.new("3.00"),
    unit_price: Decimal.new("8.00"),
    supply_data: %{
      "tamaño" => "10cm x 4m",
      "material" => "Algodón elástico"
    }
  }
]

Enum.each(inventory_items, fn item_attrs ->
  {:ok, _} = Laura.Inventory.create_inventory(item_attrs)
end)

IO.puts "✅ Inventory created"

# 13. Message Templates
templates = [
  %{
    health_brand_id: demo_brand.id,
    name: "Recordatorio de Cita",
    description: "Recordatorio automático de cita programada",
    template_type: "appointment_reminder",
    channel: "whatsapp",
    subject: "Recordatorio de tu cita médica",
    body: "Hola {{patient_name}}, te recordamos que tienes una cita el {{appointment_date}} a las {{appointment_time}}. Por favor confirmar asistencia.",
    variables: %{
      "patient_name" => "Nombre del paciente",
      "appointment_date" => "Fecha de la cita",
      "appointment_time" => "Hora de la cita"
    },
    is_auto_send: true,
    trigger_event: "appointment_scheduled"
  }
]

Enum.each(templates, fn template_attrs ->
  {:ok, _} = Laura.Messaging.create_message_template(template_attrs)
end)

IO.puts "✅ Message templates created"

# 14. Invoices
invoice_number = Billing.generate_invoice_number(demo_brand.id)

{:ok, _} = Laura.Billing.create_invoice(%{
  health_brand_id: demo_brand.id,
  patient_id: patient1.id,
  appointment_id: appointment1.id,
  invoice_number: invoice_number,
  invoice_date: Date.utc_today(),
  due_date: Date.add(Date.utc_today(), 30),
  status: "sent",
  subtotal: Decimal.new("1500.00"),
  tax_amount: Decimal.new("315.00"),
  total_amount: Decimal.new("1815.00"),
  balance_due: Decimal.new("1815.00"),
  line_items: %{
    "items" => [
      %{
        "description" => "Consulta de evaluación inicial",
        "quantity" => 1,
        "unit_price" => 1500.00,
        "amount" => 1500.00
      }
    ]
  }
})

IO.puts "✅ Invoices created"

# 15. Analytics Events
Analytics.track_event(
  demo_brand.id,
  "appointment",
  "appointment_scheduled",
  %{"appointment_type" => "evaluacion_inicial"},
  %{staff_id: doctor_staff.id, patient_id: patient1.id}
)

IO.puts "✅ Analytics events created"

IO.puts """
🎉 SEEDING COMPLETED!

🏥 HEALTH BRANDS:
   • Clínica Demo (demo.laura.ia3.art) - Plan Básico
   • Centro Rehabilitación (rehab.laura.ia3.art) - Plan Profesional

👨‍⚕️ STAFF ACCOUNTS (Clínica Demo):
   • Admin: admin@demo.com
   • Doctor: dr.gonzalez@demo.com
   • Terapeuta: terapeuta@demo.com
   • Recepción: recepcion@demo.com

👥 PATIENTS CREATED: 3 pacientes de ejemplo
📅 APPOINTMENTS: 2 citas programadas
📋 MEDICAL RECORDS: 1 historia clínica
💊 INVENTORY: 2 items en stock
💬 MESSAGING: 1 plantilla de recordatorio
🧾 BILLING: 1 factura generada

🔗 Access: http://localhost:4000/auth
   Usa cualquier email de staff para magic link
"""

IO.puts ""
IO.puts "🚀 ¡SISTEMA COMPLETO Y LISTO!"
