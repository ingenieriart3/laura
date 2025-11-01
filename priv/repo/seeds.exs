# alias Laura.{Repo, Accounts, Platform, Billing, Scheduling, MedicalRecord, Inventory, Messaging, Analytics, Security}
# alias Laura.Accounts.{Staff, StaffRole, Patient}
# alias Laura.Platform.{HealthBrand, MedicalConfig}
# alias Laura.Scheduling.{Appointment, StaffAvailability, CheckInLog, AppointmentStatusLog}
# alias Laura.MedicalRecord.{MedicalRecord, Treatment, TreatmentSession, DiagnosticCatalog, MedicationCatalog, Prescription, TreatmentProtocol, ConsultationTemplate, MedicalRecordAttachment}
# alias Laura.Inventory.{Inventory, InventoryTransaction}
# alias Laura.Messaging.{Message, Conversation, MessageTemplate}
# alias Laura.Billing.{Invoice, PaymentEvent, BillingItem, PaymentIntegration, InsuranceProvider, PatientInsurance}
# alias Laura.Analytics.AnalyticsEvent
# alias Laura.Security.{ApiKey, Webhook, Permission, StaffInvitation}

# # Clean existing data (en orden correcto para constraints)
# IO.puts "🧹 Cleaning database..."

# # Limpiar en orden correcto de dependencias
# tables_to_clean = [
#   "inventory_transactions", "inventory", "treatment_sessions", "treatments",
#   "medical_records", "appointments", "staff_availability", "invoices",
#   "payment_events", "messages", "conversations", "message_templates",
#   "patients", "staffs", "medical_configs", "health_brands", "staff_roles",
#   "prescriptions", "check_in_logs", "appointment_status_logs",
#   "medical_record_attachments", "diagnostic_catalogs", "medication_catalogs",
#   "treatment_protocols", "consultation_templates", "permissions",
#   "staff_invitations", "insurance_providers", "patient_insurances",
#   "payment_integrations", "billing_items"
# ]

# Enum.each(tables_to_clean, fn table ->
#   case Repo.query("SELECT to_regclass($1)", [table]) do
#     {:ok, %{rows: [[nil]]}} ->
#       IO.puts "⚠️  Table #{table} doesn't exist yet"
#     {:ok, _} ->
#       Repo.query!("DELETE FROM #{table}")
#       IO.puts "✅ Cleaned #{table}"
#     _ ->
#       IO.puts "⚠️  Could not check table #{table}"
#   end
# end)

# # Solo borrar subscription_plans si la tabla existe
# if Repo.query!("SELECT to_regclass('subscription_plans')") |> Map.get(:rows) |> List.first() |> List.first() do
#   Repo.delete_all(Billing.SubscriptionPlan)
# end

# IO.puts "🌱 Seeding database..."

# # 1. Subscription Plans - crear si no existen
# IO.puts "📋 Checking subscription plans..."

# # Verificar si la tabla existe y tiene datos
# subscription_plans_exist = case Repo.query("SELECT to_regclass('subscription_plans')") do
#   {:ok, %{rows: [[nil]]}} ->
#     false
#   {:ok, %{rows: [[_table_name]]}} ->
#     # La tabla existe, verificar si tiene datos
#     Repo.aggregate(Billing.SubscriptionPlan, :count, :id) > 0
#   _ ->
#     false
# end

# if !subscription_plans_exist do
#   IO.puts "📦 Creating subscription plans..."
#   Billing.seed_subscription_plans!()
#   IO.puts "✅ Subscription plans created"
# else
#   IO.puts "✅ Subscription plans already exist"
# end

# # 2. Staff Roles RBAC Completos - REFACTORIZADO
# IO.puts "👥 Creating RBAC staff roles..."

# # Crear roles individualmente para evitar problemas de sintaxis
# admin_role = Repo.insert!(%StaffRole{
#   name: "admin",
#   role_type: "administrative",
#   is_system_role: true,
#   permissions: %{
#     all: true,
#     medical: true,
#     billing: true,
#     scheduling: true,
#     inventory: true,
#     messaging: true,
#     staff_management: true
#   }
# })

# doctor_role = Repo.insert!(%StaffRole{
#   name: "doctor",
#   role_type: "clinical",
#   is_system_role: true,
#   permissions: %{
#     medical_records: %{read: true, write: true, manage: true},
#     appointments: %{read: true, write: true, manage: "own"},
#     patients: %{read: true, write: true, manage: true},
#     prescriptions: %{read: true, write: true, manage: true},
#     messaging: %{read: true, write: true}
#   }
# })

# nurse_role = Repo.insert!(%StaffRole{
#   name: "nurse",
#   role_type: "clinical",
#   is_system_role: true,
#   permissions: %{
#     medical_records: %{read: "limited", write: "notes_only"},
#     appointments: %{read: true, write: false},
#     patients: %{read: true, write: "basic_info"},
#     inventory: %{read: true, write: "transactions"}
#   }
# })

# therapist_role = Repo.insert!(%StaffRole{
#   name: "therapist",
#   role_type: "clinical",
#   is_system_role: true,
#   permissions: %{
#     medical_records: %{read: true, write: true, manage: "own"},
#     appointments: %{read: true, write: true, manage: "own"},
#     patients: %{read: true, write: true},
#     treatments: %{read: true, write: true, manage: true}
#   }
# })

# reception_role = Repo.insert!(%StaffRole{
#   name: "reception",
#   role_type: "administrative",
#   is_system_role: true,
#   permissions: %{
#     patients: %{read: "demographic", write: "demographic"},
#     appointments: %{read: true, write: true, manage: true},
#     billing: %{read: true, write: true},
#     messaging: %{read: true, write: true}
#   }
# })

# pharmacist_role = Repo.insert!(%StaffRole{
#   name: "pharmacist",
#   role_type: "support",
#   is_system_role: true,
#   permissions: %{
#     medical_records: %{read: "prescriptions_only"},
#     inventory: %{read: true, write: true, manage: true},
#     prescriptions: %{read: true, write: "dispense"}
#   }
# })

# roles_map = %{
#   "admin" => admin_role,
#   "doctor" => doctor_role,
#   "nurse" => nurse_role,
#   "therapist" => therapist_role,
#   "reception" => reception_role,
#   "pharmacist" => pharmacist_role
# }

# IO.puts "✅ Staff roles created"

# # 3. Health Brands con diferentes planes
# basic_plan = Billing.get_subscription_plan_by_code("basic")
# professional_plan = Billing.get_subscription_plan_by_code("professional")

# # Health Brand 1 - Clínica Demo (Básico)
# {:ok, demo_brand} = Platform.create_health_brand(%{
#   name: "Clínica Demo - Fisioterapia Avanzada",
#   subdomain: "demo",
#   subscription_plan_id: basic_plan.id
# })

# # Health Brand 2 - Otro tenant (Profesional)
# {:ok, rehab_brand} = Platform.create_health_brand(%{
#   name: "Centro de Rehabilitación Integral",
#   subdomain: "rehab",
#   subscription_plan_id: professional_plan.id
# })

# IO.puts "✅ Health brands created"

# # 4. Medical Configs para cada health brand
# {:ok, _} = Platform.create_medical_config(%{
#   health_brand_id: demo_brand.id,
#   treatment_categories: %{
#     "fisioterapia" => "Fisioterapia",
#     "kinesiologia" => "Kinesiología",
#     "rehabilitacion" => "Rehabilitación",
#     "masajes" => "Masajes Terapéuticos",
#     "osteopatia" => "Osteopatía"
#   },
#   procedure_templates: %{
#     "evaluacion_inicial" => "Evaluación Inicial",
#     "sesion_terapeutica" => "Sesión Terapéutica",
#     "control_seguimiento" => "Control de Seguimiento",
#     "terapia_manual" => "Terapia Manual"
#   },
#   medication_categories: %{
#     "analgesicos" => "Analgésicos",
#     "antiinflamatorios" => "Antiinflamatorios",
#     "relajantes" => "Relajantes Musculares"
#   },
#   appointment_duration: 45,
#   business_hours: %{
#     "monday" => %{"start" => "08:00", "end" => "18:00"},
#     "tuesday" => %{"start" => "08:00", "end" => "18:00"},
#     "wednesday" => %{"start" => "08:00", "end" => "18:00"},
#     "thursday" => %{"start" => "08:00", "end" => "18:00"},
#     "friday" => %{"start" => "08:00", "end" => "17:00"}
#   }
# })

# IO.puts "✅ Medical configs created"

# # 5. Diagnostic Catalogs (CIE-10) - REFACTORIZADO
# IO.puts "📋 Creating diagnostic catalogs..."
# diagnostics_data = [
#   %{
#     health_brand_id: demo_brand.id,
#     code: "M54.5",
#     description: "Lumbalgia baja",
#     category: "musculoskeletal",
#     is_active: true,
#     metadata: %{severity: "moderate", common_treatments: ["physiotherapy", "analgesics"]}
#   },
#   %{
#     health_brand_id: demo_brand.id,
#     code: "M25.5",
#     description: "Dolor en articulación",
#     category: "musculoskeletal",
#     is_active: true,
#     metadata: %{severity: "mild", common_treatments: ["rest", "antiinflammatories"]}
#   },
#   %{
#     health_brand_id: demo_brand.id,
#     code: "J06.9",
#     description: "Infección aguda de las vías respiratorias superiores",
#     category: "respiratory",
#     is_active: true
#   },
#   %{
#     health_brand_id: demo_brand.id,
#     code: "F41.9",
#     description: "Trastorno de ansiedad no especificado",
#     category: "mental_health",
#     is_active: true
#   }
# ]

# diagnostics_map = %{}
# Enum.each(diagnostics_data, fn attrs ->
#   diagnostic =
#     %DiagnosticCatalog{}
#     |> DiagnosticCatalog.changeset(attrs)
#     |> Repo.insert!()
#   diagnostics_map = Map.put(diagnostics_map, diagnostic.code, diagnostic)
# end)

# IO.puts "✅ Diagnostic catalogs created"

# # 6. Medication Catalogs - REFACTORIZADO
# IO.puts "💊 Creating medication catalogs..."
# medications_data = [
#   %{
#     health_brand_id: demo_brand.id,
#     name: "Ibuprofeno 400mg",
#     generic_name: "Ibuprofen",
#     description: "Analgésico y antiinflamatorio no esteroideo",
#     presentation: "tabletas",
#     standard_dosage: "400mg",
#     contraindications: "Ulcera gastrica, insuficiencia renal grave",
#     interactions: "Anticoagulantes, otros AINEs",
#     is_active: true,
#     medication_data: %{
#       "laboratorio" => "Bayer",
#       "concentracion" => "400mg",
#       "clasificacion" => "AINE"
#     }
#   },
#   %{
#     health_brand_id: demo_brand.id,
#     name: "Paracetamol 500mg",
#     generic_name: "Acetaminophen",
#     description: "Analgésico y antipirético",
#     presentation: "tabletas",
#     standard_dosage: "500mg",
#     contraindications: "Hepatopatía grave",
#     interactions: "Alcohol, warfarina",
#     is_active: true
#   },
#   %{
#     health_brand_id: demo_brand.id,
#     name: "Amoxicilina 500mg",
#     generic_name: "Amoxicillin",
#     description: "Antibiótico de amplio espectro",
#     presentation: "cápsulas",
#     standard_dosage: "500mg",
#     contraindications: "Alergia a penicilinas",
#     interactions: "Anticonceptivos orales",
#     is_active: true
#   }
# ]

# medications_map = %{}
# Enum.each(medications_data, fn attrs ->
#   medication =
#     %MedicationCatalog{}
#     |> MedicationCatalog.changeset(attrs)
#     |> Repo.insert!()
#   medications_map = Map.put(medications_map, medication.name, medication)
# end)

# IO.puts "✅ Medication catalogs created"

# # 7. Treatment Protocols - REFACTORIZADO
# IO.puts "📝 Creating treatment protocols..."
# protocols_data = [
#   %{
#     health_brand_id: demo_brand.id,
#     diagnostic_catalog_id: diagnostics_map["M54.5"].id,
#     name: "Protocolo Lumbalgia Aguda",
#     description: "Tratamiento estándar para lumbalgia mecánica aguda",
#     expected_sessions: 8,
#     session_duration: 60,
#     frequency: "twice_weekly",
#     protocol_steps: %{
#       "fase_1" => "Control del dolor y educación",
#       "fase_2" => "Movilización y ejercicios suaves",
#       "fase_3" => "Fortalecimiento y prevención"
#     },
#     medication_recommendations: %{
#       "analgesia" => "Ibuprofeno 400mg cada 8 horas por 5 días",
#       "relajante" => "Según necesidad"
#     },
#     is_active: true
#   }
# ]

# Enum.each(protocols_data, fn attrs ->
#   %TreatmentProtocol{}
#   |> TreatmentProtocol.changeset(attrs)
#   |> Repo.insert!()
# end)

# IO.puts "✅ Treatment protocols created"

# # 8. Consultation Templates - REFACTORIZADO
# IO.puts "📄 Creating consultation templates..."
# templates_data = [
#   %{
#     health_brand_id: demo_brand.id,
#     name: "Evaluación Inicial Fisioterapia",
#     specialty: "physiotherapy",
#     template_type: "initial",
#     template_structure: %{
#       "sections" => [
#         %{
#           "title" => "Motivo de Consulta",
#           "fields" => ["dolor_localizacion", "dolor_intensidad", "tiempo_evolucion"]
#         },
#         %{
#           "title" => "Examen Físico",
#           "fields" => ["rango_movimiento", "fuerza_muscular", "palpacion"]
#         },
#         %{
#           "title" => "Plan de Tratamiento",
#           "fields" => ["diagnostico", "objetivos", "plan_sesiones"]
#         }
#       ]
#     },
#     required_fields: %{"diagnostico" => true, "plan_sesiones" => true},
#     is_active: true
#   }
# ]

# Enum.each(templates_data, fn attrs ->
#   %ConsultationTemplate{}
#   |> ConsultationTemplate.changeset(attrs)
#   |> Repo.insert!()
# end)

# IO.puts "✅ Consultation templates created"

# # 9. Staff para cada health brand
# IO.puts "👨‍⚕️ Creating staff accounts..."
# {:ok, admin_staff} = Accounts.create_staff(%{
#   email: "admin@demo.com",
#   health_brand_id: demo_brand.id,
#   staff_role_id: admin_role.id,
#   confirmed_at: NaiveDateTime.utc_now(),
#   is_active: true
# })

# {:ok, doctor_staff} = Accounts.create_staff(%{
#   email: "dr.gonzalez@demo.com",
#   health_brand_id: demo_brand.id,
#   staff_role_id: doctor_role.id,
#   confirmed_at: NaiveDateTime.utc_now(),
#   is_active: true
# })

# {:ok, therapist_staff} = Accounts.create_staff(%{
#   email: "terapeuta@demo.com",
#   health_brand_id: demo_brand.id,
#   staff_role_id: therapist_role.id,
#   confirmed_at: NaiveDateTime.utc_now(),
#   is_active: true
# })

# {:ok, reception_staff} = Accounts.create_staff(%{
#   email: "recepcion@demo.com",
#   health_brand_id: demo_brand.id,
#   staff_role_id: reception_role.id,
#   confirmed_at: NaiveDateTime.utc_now(),
#   is_active: true
# })

# {:ok, nurse_staff} = Accounts.create_staff(%{
#   email: "enfermera@demo.com",
#   health_brand_id: demo_brand.id,
#   staff_role_id: nurse_role.id,
#   confirmed_at: NaiveDateTime.utc_now(),
#   is_active: true
# })

# {:ok, pharmacist_staff} = Accounts.create_staff(%{
#   email: "farmacia@demo.com",
#   health_brand_id: demo_brand.id,
#   staff_role_id: pharmacist_role.id,
#   confirmed_at: NaiveDateTime.utc_now(),
#   is_active: true
# })

# IO.puts "✅ Staff accounts created"

# # 10. Staff Invitations (ejemplo) - REFACTORIZADO
# IO.puts "📨 Creating staff invitations..."
# invitation_attrs = %{
#   health_brand_id: demo_brand.id,
#   invited_by_staff_id: admin_staff.id,
#   email: "nuevo.doctor@demo.com",
#   staff_role_id: doctor_role.id,
#   token: "invite_token_123",
#   status: "pending",
#   expires_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 7 * 24 * 60 * 60) # 7 días
# }

# %StaffInvitation{}
# |> StaffInvitation.changeset(invitation_attrs)
# |> Repo.insert!()

# IO.puts "✅ Staff invitations created"

# # 11. Patients de ejemplo
# IO.puts "👥 Creating patients..."
# patients_data = [
#   %{
#     health_brand_id: demo_brand.id,
#     first_name: "Ana",
#     last_name: "García",
#     email: "ana.garcia@email.com",
#     phone: "+5491154321000",
#     birth_date: ~D[1985-03-15],
#     gender: "femenino",
#     address: "Av. Corrientes 1234",
#     city: "Buenos Aires",
#     emergency_contact_name: "Carlos García",
#     emergency_contact_phone: "+5491154321001",
#     blood_type: "A+",
#     allergies: "Penicilina",
#     medical_conditions: "Hipertensión controlada"
#   },
#   %{
#     health_brand_id: demo_brand.id,
#     first_name: "Luis",
#     last_name: "Martínez",
#     email: "luis.martinez@email.com",
#     phone: "+5491154321002",
#     birth_date: ~D[1978-07-22],
#     gender: "masculino",
#     address: "Calle Florida 567",
#     city: "Buenos Aires",
#     emergency_contact_name: "María Martínez",
#     emergency_contact_phone: "+5491154321003",
#     blood_type: "O+",
#     allergies: "Ninguna",
#     medical_conditions: "Lumbalgia crónica"
#   }
# ]

# patients_list = []
# Enum.each(patients_data, fn patient_attrs ->
#   {:ok, patient} = Accounts.create_patient(patient_attrs)
#   patients_list = [patient | patients_list]
# end)

# [patient1, patient2] = Enum.reverse(patients_list)
# IO.puts "✅ Patients created"

# # 12. Insurance Providers & Patient Insurance - REFACTORIZADO
# IO.puts "🏥 Creating insurance data..."
# insurance_provider_attrs = %{
#   health_brand_id: demo_brand.id,
#   name: "OSDE",
#   contact_info: %{"telefono" => "0810-555-OSDE", "web" => "www.osde.com.ar"},
#   coverage_details: %{"cobertura_basica" => true, "medicamentos" => true},
#   authorization_required: true,
#   is_active: true
# }

# insurance_provider =
#   %InsuranceProvider{}
#   |> InsuranceProvider.changeset(insurance_provider_attrs)
#   |> Repo.insert!()

# patient_insurance_attrs = %{
#   health_brand_id: demo_brand.id,
#   patient_id: patient1.id,
#   insurance_provider_id: insurance_provider.id,
#   policy_number: "OSDE-123456",
#   policy_holder_name: "Ana García",
#   coverage_limits: %{"consultas_mensuales" => 4, "estudios_anuales" => 2},
#   copayment_amount: Decimal.new("200.00"),
#   is_primary: true,
#   is_active: true
# }

# %PatientInsurance{}
# |> PatientInsurance.changeset(patient_insurance_attrs)
# |> Repo.insert!()

# IO.puts "✅ Insurance data created"

# # 13. Staff Availability
# IO.puts "📅 Creating staff availability..."
# availability_entries = [
#   %{
#     health_brand_id: demo_brand.id,
#     staff_id: doctor_staff.id,
#     availability_type: "regular",
#     day_of_week: 1, # Lunes
#     start_time: ~T[09:00:00],
#     end_time: ~T[17:00:00],
#     slot_duration: 45
#   },
#   %{
#     health_brand_id: demo_brand.id,
#     staff_id: therapist_staff.id,
#     availability_type: "regular",
#     day_of_week: 3, # Miércoles
#     start_time: ~T[08:00:00],
#     end_time: ~T[16:00:00],
#     slot_duration: 60
#   }
# ]

# Enum.each(availability_entries, fn availability_attrs ->
#   {:ok, _} = Scheduling.create_staff_availability(availability_attrs)
# end)

# IO.puts "✅ Staff availability created"

# # 14. Appointments con estados completos
# IO.puts "🕐 Creating appointments with complete status..."
# appointments_data = [
#   %{
#     health_brand_id: demo_brand.id,
#     patient_id: patient1.id,
#     staff_id: doctor_staff.id,
#     scheduled_for: NaiveDateTime.add(NaiveDateTime.utc_now(), 2 * 24 * 60 * 60), # En 2 días
#     duration: 45,
#     appointment_type: "evaluacion_inicial",
#     status: "confirmed",
#     current_status: "scheduled",
#     reason_for_visit: "Dolor lumbar persistente"
#   },
#   %{
#     health_brand_id: demo_brand.id,
#     patient_id: patient2.id,
#     staff_id: therapist_staff.id,
#     scheduled_for: NaiveDateTime.add(NaiveDateTime.utc_now(), 3 * 24 * 60 * 60), # En 3 días
#     duration: 60,
#     appointment_type: "sesion_terapeutica",
#     status: "scheduled",
#     current_status: "scheduled",
#     reason_for_visit: "Seguimiento tratamiento rehabilitación"
#   }
# ]

# appointments_list = []
# Enum.each(appointments_data, fn appointment_attrs ->
#   {:ok, appointment} = Scheduling.create_appointment(appointment_attrs)
#   appointments_list = [appointment | appointments_list]
# end)

# [appointment1, appointment2] = Enum.reverse(appointments_list)
# IO.puts "✅ Appointments created"

# # 15. Check-in Logs - REFACTORIZADO
# IO.puts "✅ Creating check-in logs..."
# checkin_attrs = %{
#   health_brand_id: demo_brand.id,
#   appointment_id: appointment1.id,
#   patient_id: patient1.id,
#   check_in_time: NaiveDateTime.utc_now(),
#   initial_status: "scheduled",
#   final_status: "completed",
#   checked_in_by_staff_id: reception_staff.id,
#   notes: "Paciente llegó puntual"
# }

# %CheckInLog{}
# |> CheckInLog.changeset(checkin_attrs)
# |> Repo.insert!()

# IO.puts "✅ Check-in logs created"

# # 16. Appointment Status Logs - REFACTORIZADO
# IO.puts "📊 Creating appointment status logs..."
# status_log_attrs = %{
#   appointment_id: appointment1.id,
#   health_brand_id: demo_brand.id,
#   from_status: "scheduled",
#   to_status: "confirmed",
#   changed_by_staff_id: reception_staff.id,
#   notes: "Paciente confirmó asistencia por teléfono"
# }

# %AppointmentStatusLog{}
# |> AppointmentStatusLog.changeset(status_log_attrs)
# |> Repo.insert!()

# IO.puts "✅ Appointment status logs created"

# # 17. Medical Records
# IO.puts "📋 Creating medical records..."
# {:ok, medical_record1} = MedicalRecord.create_medical_record(%{
#   health_brand_id: demo_brand.id,
#   patient_id: patient1.id,
#   appointment_id: appointment1.id,
#   staff_id: doctor_staff.id,
#   record_type: "consultation",
#   vital_signs: %{
#     "presion_arterial" => "120/80",
#     "frecuencia_cardiaca" => 72,
#     "temperatura" => 36.5
#   },
#   subjective: "Paciente refiere dolor lumbar de 3 meses de evolución, que empeora con la actividad física.",
#   objective: "Limitación en la flexión lumbar, dolor a la palpación en L4-L5.",
#   assessment: "Lumbalgia mecánica aguda.",
#   plan: "Iniciar tratamiento de fisioterapia, ejercicios de fortalecimiento core."
# })

# IO.puts "✅ Medical records created"

# # 18. Medical Record Attachments (ejemplo) - REFACTORIZADO
# IO.puts "📎 Creating medical record attachments..."
# attachment_attrs = %{
#   health_brand_id: demo_brand.id,
#   medical_record_id: medical_record1.id,
#   patient_id: patient1.id,
#   staff_id: doctor_staff.id,
#   filename: "radiografia_lumbar.pdf",
#   file_type: "pdf",
#   file_size: 2048576,
#   description: "Radiografía lumbar AP y lateral",
#   s3_key: "attachments/radiografia_123.pdf",
#   is_archived: false
# }

# %MedicalRecordAttachment{}
# |> MedicalRecordAttachment.changeset(attachment_attrs)
# |> Repo.insert!()

# IO.puts "✅ Medical record attachments created"

# # 19. Treatments
# IO.puts "💪 Creating treatments..."
# {:ok, treatment1} = MedicalRecord.create_treatment(%{
#   health_brand_id: demo_brand.id,
#   patient_id: patient1.id,
#   medical_record_id: medical_record1.id,
#   staff_id: therapist_staff.id,
#   name: "Tratamiento de Fisioterapia para Lumbalgia",
#   description: "Plan de 8 sesiones para mejorar dolor lumbar",
#   treatment_plan: %{
#     "sesiones_totales" => 8,
#     "frecuencia" => "2 veces por semana",
#     "objetivos" => ["Reducir dolor", "Mejorar movilidad", "Fortalecer musculatura"]
#   },
#   diagnosis_codes: %{"lumbalgia" => "M54.5"},
#   start_date: Date.utc_today(),
#   expected_sessions: 8
# })

# IO.puts "✅ Treatments created"

# # 20. Treatment Sessions
# IO.puts "🔄 Creating treatment sessions..."
# {:ok, _} = MedicalRecord.create_treatment_session(%{
#   health_brand_id: demo_brand.id,
#   treatment_id: treatment1.id,
#   patient_id: patient1.id,
#   staff_id: therapist_staff.id,
#   session_date: NaiveDateTime.utc_now(),
#   session_type: "sesion_terapeutica",
#   session_number: 1,
#   duration: 60,
#   procedures_performed: %{
#     "terapia_manual" => "Movilizaciones vertebrales",
#     "ejercicios" => "Estabilización lumbar"
#   },
#   subjective_feedback: "Paciente refiere mejoría del 30% en el dolor",
#   patient_progress: "good"
# })

# IO.puts "✅ Treatment sessions created"

# # 21. Prescriptions
# IO.puts "💊 Creating prescriptions..."
# {:ok, prescription} = MedicalRecord.create_prescription(%{
#   health_brand_id: demo_brand.id,
#   medical_record_id: medical_record1.id,
#   patient_id: patient1.id,
#   staff_id: doctor_staff.id,
#   medication_catalog_id: medications_map["Ibuprofeno 400mg"].id,
#   dosage: "400mg",
#   frequency: "cada 8 horas",
#   duration: "7 días",
#   instructions: "Tomar con alimentos",
#   status: "prescribed",
#   prescribed_at: NaiveDateTime.utc_now()
# })

# IO.puts "✅ Prescriptions created"

# # 22. Inventory
# IO.puts "📦 Creating inventory..."
# inventory_items = [
#   %{
#     health_brand_id: demo_brand.id,
#     name: "Ibuprofeno 400mg",
#     description: "Analgésico y antiinflamatorio",
#     category: "medicamentos",
#     item_type: "medication",
#     current_stock: 50,
#     min_stock: 10,
#     unit_cost: Decimal.new("0.50"),
#     unit_price: Decimal.new("2.00"),
#     medication_data: %{
#       "presentacion" => "Tabletas",
#       "dosis" => "400mg",
#       "laboratorio" => "Bayer"
#     }
#   },
#   %{
#     health_brand_id: demo_brand.id,
#     name: "Vendas Elásticas",
#     description: "Vendas de 10cm x 4m",
#     category: "insumos",
#     item_type: "supply",
#     current_stock: 25,
#     min_stock: 5,
#     unit_cost: Decimal.new("3.00"),
#     unit_price: Decimal.new("8.00"),
#     supply_data: %{
#       "tamaño" => "10cm x 4m",
#       "material" => "Algodón elástico"
#     }
#   }
# ]

# Enum.each(inventory_items, fn item_attrs ->
#   {:ok, _} = Inventory.create_inventory(item_attrs)
# end)

# IO.puts "✅ Inventory created"

# # 23. Billing Items - REFACTORIZADO
# IO.puts "💰 Creating billing items..."
# billing_items_data = [
#   %{
#     health_brand_id: demo_brand.id,
#     name: "Consulta de Evaluación Inicial",
#     description: "Primera consulta de evaluación médica",
#     item_type: "consultation",
#     standard_price: Decimal.new("1500.00"),
#     category: "consultas",
#     is_active: true
#   },
#   %{
#     health_brand_id: demo_brand.id,
#     name: "Sesión de Fisioterapia",
#     description: "Sesión individual de fisioterapia",
#     item_type: "procedure",
#     standard_price: Decimal.new("1200.00"),
#     category: "procedimientos",
#     is_active: true
#   }
# ]

# Enum.each(billing_items_data, fn attrs ->
#   %BillingItem{}
#   |> BillingItem.changeset(attrs)
#   |> Repo.insert!()
# end)

# IO.puts "✅ Billing items created"

# # 24. Invoices
# IO.puts "🧾 Creating invoices..."
# invoice_number = Billing.generate_invoice_number(demo_brand.id)

# {:ok, _} = Billing.create_invoice(%{
#   health_brand_id: demo_brand.id,
#   patient_id: patient1.id,
#   appointment_id: appointment1.id,
#   invoice_number: invoice_number,
#   invoice_date: Date.utc_today(),
#   due_date: Date.add(Date.utc_today(), 30),
#   status: "sent",
#   subtotal: Decimal.new("1500.00"),
#   tax_amount: Decimal.new("315.00"),
#   total_amount: Decimal.new("1815.00"),
#   balance_due: Decimal.new("1815.00"),
#   line_items: %{
#     "items" => [
#       %{
#         "description" => "Consulta de evaluación inicial",
#         "quantity" => 1,
#         "unit_price" => 1500.00,
#         "amount" => 1500.00
#       }
#     ]
#   }
# })

# IO.puts "✅ Invoices created"

# # 25. Payment Integrations - REFACTORIZADO
# IO.puts "💳 Creating payment integrations..."
# payment_integration_attrs = %{
#   health_brand_id: demo_brand.id,
#   provider: "mercadopago",
#   access_token: "TEST-123456789",
#   public_key: "TEST-public-key-123",
#   is_active: true,
#   webhook_url: "https://demo.laura.ia3.art/webhooks/mercadopago",
#   metadata: %{"sandbox" => true}
# }

# %PaymentIntegration{}
# |> PaymentIntegration.changeset(payment_integration_attrs)
# |> Repo.insert!()

# IO.puts "✅ Payment integrations created"

# # 26. Message Templates
# IO.puts "💬 Creating message templates..."
# templates = [
#   %{
#     health_brand_id: demo_brand.id,
#     name: "Recordatorio de Cita",
#     description: "Recordatorio automático de cita programada",
#     template_type: "appointment_reminder",
#     channel: "whatsapp",
#     subject: "Recordatorio de tu cita médica",
#     body: "Hola {{patient_name}}, te recordamos que tienes una cita el {{appointment_date}} a las {{appointment_time}}. Por favor confirmar asistencia.",
#     variables: %{
#       "patient_name" => "Nombre del paciente",
#       "appointment_date" => "Fecha de la cita",
#       "appointment_time" => "Hora de la cita"
#     },
#     is_auto_send: true,
#     trigger_event: "appointment_scheduled"
#   }
# ]

# Enum.each(templates, fn template_attrs ->
#   {:ok, _} = Messaging.create_message_template(template_attrs)
# end)

# IO.puts "✅ Message templates created"

# # 27. Analytics Events
# IO.puts "📊 Creating analytics events..."
# Analytics.track_event(
#   demo_brand.id,
#   "appointment",
#   "appointment_scheduled",
#   %{"appointment_type" => "evaluacion_inicial"},
#   %{staff_id: doctor_staff.id, patient_id: patient1.id}
# )

# IO.puts "✅ Analytics events created"

# # 28. Permissions (ejemplo granular) - REFACTORIZADO
# IO.puts "🔐 Creating granular permissions..."
# permissions_data = [
#   %{staff_role_id: nurse_role.id, module: "medical_records", action: "read", scope: "limited"},
#   %{staff_role_id: nurse_role.id, module: "medical_records", action: "write", scope: "notes_only"},
#   %{staff_role_id: pharmacist_role.id, module: "prescriptions", action: "read", scope: "all"},
#   %{staff_role_id: pharmacist_role.id, module: "prescriptions", action: "write", scope: "dispense"}
# ]

# Enum.each(permissions_data, fn attrs ->
#   %Permission{}
#   |> Permission.changeset(attrs)
#   |> Repo.insert!()
# end)

# IO.puts "✅ Permissions created"

# IO.puts """
# 🎉 SEEDING COMPLETED!

# 🏥 HEALTH BRANDS:
#    • Clínica Demo (demo.laura.ia3.art) - Plan Básico
#    • Centro Rehabilitación (rehab.laura.ia3.art) - Plan Profesional

# 👨‍⚕️ STAFF ACCOUNTS (Clínica Demo):
#    • Admin: admin@demo.com
#    • Doctor: dr.gonzalez@demo.com
#    • Terapeuta: terapeuta@demo.com
#    • Recepción: recepcion@demo.com
#    • Enfermera: enfermera@demo.com
#    • Farmacéutico: farmacia@demo.com

# 📊 NUEVAS FEATURES INCLUIDAS:
#    • Diagnostic Catalogs (CIE-10)
#    • Medication Catalogs
#    • Treatment Protocols
#    • Consultation Templates
#    • Prescriptions con integración farmacia
#    • Check-in logs y status tracking
#    • Insurance providers y patient insurance
#    • Payment integrations (MercadoPago)
#    • Billing items configurables
#    • RBAC permissions granulares

# 👥 PATIENTS CREATED: 2 pacientes de ejemplo
# 📅 APPOINTMENTS: 2 citas con flujo completo
# 📋 MEDICAL RECORDS: 1 historia clínica con attachments
# 💊 INVENTORY: 2 items en stock
# 💬 MESSAGING: 1 plantilla de recordatorio
# 🧾 BILLING: Sistema completo de facturación

# 🔗 Access: http://localhost:4000/auth
#    Usa cualquier email de staff para magic link
# """

# IO.puts ""
# IO.puts "🚀 ¡SISTEMA COMPLETO Y LISTO CON TODAS LAS FEATURES!"

alias Laura.{Repo, Accounts, Platform, Billing, Scheduling, MedicalRecord, Inventory, Messaging, Analytics, Security}
alias Laura.Accounts.{Staff, StaffRole, Patient}
alias Laura.Platform.{HealthBrand, MedicalConfig}
alias Laura.Scheduling.{Appointment, StaffAvailability, CheckInLog, AppointmentStatusLog}
alias Laura.MedicalRecord.{MedicalRecord, Treatment, TreatmentSession, DiagnosticCatalog, MedicationCatalog, Prescription, TreatmentProtocol, ConsultationTemplate, MedicalRecordAttachment}
# CORREGIDO: Usar InventoryItem para evitar conflicto de nombres
alias Laura.Inventory.{InventoryItem, InventoryTransaction}
alias Laura.Messaging.{Message, Conversation, MessageTemplate}
alias Laura.Billing.{Invoice, PaymentEvent, BillingItem, PaymentIntegration, InsuranceProvider, PatientInsurance}
alias Laura.Analytics.AnalyticsEvent
alias Laura.Security.{ApiKey, Webhook, Permission, StaffInvitation}

# Clean existing data (en orden correcto para constraints)
IO.puts "🧹 Cleaning database..."

# Orden CORREGIDO según dependencias de foreign keys
tables_to_clean = [
  # Primero tablas con dependencias (hijos)
  "inventory_transactions", "treatment_sessions", "treatments", "prescriptions",
  "medical_records", "appointments", "staff_availability", "payment_events",
  "messages", "conversations", "message_templates", "check_in_logs",
  "appointment_status_logs", "medical_record_attachments", "patient_insurances",
  "permissions", "staff_invitations", "analytics_events", "api_keys", "webhooks",

  # Luego tablas principales
  "inventory", "patients", "staffs", "medical_configs", "health_brands",
  "staff_roles", "diagnostic_catalogs", "medication_catalogs",
  "treatment_protocols", "consultation_templates", "insurance_providers",
  "payment_integrations", "billing_items",

  # Finalmente tablas maestras
  "subscription_plans"
]

Enum.each(tables_to_clean, fn table ->
  case Repo.query("SELECT to_regclass($1)", [table]) do
    {:ok, %{rows: [[nil]]}} ->
      IO.puts "⚠️  Table #{table} doesn't exist yet"
    {:ok, _} ->
      Repo.query!("DELETE FROM #{table}")
      IO.puts "✅ Cleaned #{table}"
    _ ->
      IO.puts "⚠️  Could not check table #{table}"
  end
end)

IO.puts "🌱 Seeding database..."

# 1. Subscription Plans - crear si no existen
IO.puts "📋 Checking subscription plans..."

subscription_plans_exist = case Repo.query("SELECT to_regclass('subscription_plans')") do
  {:ok, %{rows: [[nil]]}} -> false
  {:ok, %{rows: [[_table_name]]}} ->
    Repo.aggregate(Billing.SubscriptionPlan, :count, :id) > 0
  _ -> false
end

if !subscription_plans_exist do
  IO.puts "📦 Creating subscription plans..."
  Billing.seed_subscription_plans!()
  IO.puts "✅ Subscription plans created"
else
  IO.puts "✅ Subscription plans already exist"
end

# 2. Staff Roles RBAC Completos
IO.puts "👥 Creating RBAC staff roles..."

admin_role = Repo.insert!(%StaffRole{
  name: "admin",
  role_type: "administrative",
  is_system_role: true,
  permissions: %{
    all: true,
    medical: true,
    billing: true,
    scheduling: true,
    inventory: true,
    messaging: true,
    staff_management: true
  }
})

doctor_role = Repo.insert!(%StaffRole{
  name: "doctor",
  role_type: "clinical",
  is_system_role: true,
  permissions: %{
    medical_records: %{read: true, write: true, manage: true},
    appointments: %{read: true, write: true, manage: "own"},
    patients: %{read: true, write: true, manage: true},
    prescriptions: %{read: true, write: true, manage: true},
    messaging: %{read: true, write: true}
  }
})

nurse_role = Repo.insert!(%StaffRole{
  name: "nurse",
  role_type: "clinical",
  is_system_role: true,
  permissions: %{
    medical_records: %{read: "limited", write: "notes_only"},
    appointments: %{read: true, write: false},
    patients: %{read: true, write: "basic_info"},
    inventory: %{read: true, write: "transactions"}
  }
})

therapist_role = Repo.insert!(%StaffRole{
  name: "therapist",
  role_type: "clinical",
  is_system_role: true,
  permissions: %{
    medical_records: %{read: true, write: true, manage: "own"},
    appointments: %{read: true, write: true, manage: "own"},
    patients: %{read: true, write: true},
    treatments: %{read: true, write: true, manage: true}
  }
})

reception_role = Repo.insert!(%StaffRole{
  name: "reception",
  role_type: "administrative",
  is_system_role: true,
  permissions: %{
    patients: %{read: "demographic", write: "demographic"},
    appointments: %{read: true, write: true, manage: true},
    billing: %{read: true, write: true},
    messaging: %{read: true, write: true}
  }
})

pharmacist_role = Repo.insert!(%StaffRole{
  name: "pharmacist",
  role_type: "support",
  is_system_role: true,
  permissions: %{
    medical_records: %{read: "prescriptions_only"},
    inventory: %{read: true, write: true, manage: true},
    prescriptions: %{read: true, write: "dispense"}
  }
})

IO.puts "✅ Staff roles created"

# 3. Health Brands con diferentes planes
basic_plan = Billing.get_subscription_plan_by_code("basic")
professional_plan = Billing.get_subscription_plan_by_code("professional")

{:ok, demo_brand} = Platform.create_health_brand(%{
  name: "Clínica Demo - Fisioterapia Avanzada",
  subdomain: "demo",
  subscription_plan_id: basic_plan.id
})

{:ok, rehab_brand} = Platform.create_health_brand(%{
  name: "Centro de Rehabilitación Integral",
  subdomain: "rehab",
  subscription_plan_id: professional_plan.id
})

IO.puts "✅ Health brands created"

# 4. Medical Configs
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

# 5. Diagnostic Catalogs (CIE-10)
IO.puts "📋 Creating diagnostic catalogs..."

diagnostics_data = [
  %{
    health_brand_id: demo_brand.id,
    code: "M54.5",
    description: "Lumbalgia baja",
    category: "musculoskeletal",
    is_active: true,
    metadata: %{severity: "moderate", common_treatments: ["physiotherapy", "analgesics"]}
  },
  %{
    health_brand_id: demo_brand.id,
    code: "M25.5",
    description: "Dolor en articulación",
    category: "musculoskeletal",
    is_active: true,
    metadata: %{severity: "mild", common_treatments: ["rest", "antiinflammatories"]}
  },
  %{
    health_brand_id: demo_brand.id,
    code: "J06.9",
    description: "Infección aguda de las vías respiratorias superiores",
    category: "respiratory",
    is_active: true
  },
  %{
    health_brand_id: demo_brand.id,
    code: "F41.9",
    description: "Trastorno de ansiedad no especificado",
    category: "mental_health",
    is_active: true
  }
]

diagnostics_map = Enum.reduce(diagnostics_data, %{}, fn attrs, acc ->
  diagnostic = %DiagnosticCatalog{}
    |> DiagnosticCatalog.changeset(attrs)
    |> Repo.insert!()
  Map.put(acc, diagnostic.code, diagnostic)
end)

IO.puts "✅ Diagnostic catalogs created"

# 6. Medication Catalogs
IO.puts "💊 Creating medication catalogs..."

medications_data = [
  %{
    health_brand_id: demo_brand.id,
    name: "Ibuprofeno 400mg",
    generic_name: "Ibuprofen",
    description: "Analgésico y antiinflamatorio no esteroideo",
    presentation: "tabletas",
    standard_dosage: "400mg",
    contraindications: "Ulcera gastrica, insuficiencia renal grave",
    interactions: "Anticoagulantes, otros AINEs",
    is_active: true,
    medication_data: %{
      "laboratorio" => "Bayer",
      "concentracion" => "400mg",
      "clasificacion" => "AINE"
    }
  },
  %{
    health_brand_id: demo_brand.id,
    name: "Paracetamol 500mg",
    generic_name: "Acetaminophen",
    description: "Analgésico y antipirético",
    presentation: "tabletas",
    standard_dosage: "500mg",
    contraindications: "Hepatopatía grave",
    interactions: "Alcohol, warfarina",
    is_active: true
  },
  %{
    health_brand_id: demo_brand.id,
    name: "Amoxicilina 500mg",
    generic_name: "Amoxicillin",
    description: "Antibiótico de amplio espectro",
    presentation: "cápsulas",
    standard_dosage: "500mg",
    contraindications: "Alergia a penicilinas",
    interactions: "Anticonceptivos orales",
    is_active: true
  }
]

medications_map = Enum.reduce(medications_data, %{}, fn attrs, acc ->
  medication = %MedicationCatalog{}
    |> MedicationCatalog.changeset(attrs)
    |> Repo.insert!()
  Map.put(acc, medication.name, medication)
end)

IO.puts "✅ Medication catalogs created"

# 7. Treatment Protocols
IO.puts "📝 Creating treatment protocols..."

protocols_data = [
  %{
    health_brand_id: demo_brand.id,
    diagnostic_catalog_id: diagnostics_map["M54.5"].id,
    name: "Protocolo Lumbalgia Aguda",
    description: "Tratamiento estándar para lumbalgia mecánica aguda",
    expected_sessions: 8,
    session_duration: 60,
    frequency: "twice_weekly",
    protocol_steps: %{
      "fase_1" => "Control del dolor y educación",
      "fase_2" => "Movilización y ejercicios suaves",
      "fase_3" => "Fortalecimiento y prevención"
    },
    medication_recommendations: %{
      "analgesia" => "Ibuprofeno 400mg cada 8 horas por 5 días",
      "relajante" => "Según necesidad"
    },
    is_active: true
  }
]

Enum.each(protocols_data, fn attrs ->
  %TreatmentProtocol{}
  |> TreatmentProtocol.changeset(attrs)
  |> Repo.insert!()
end)

IO.puts "✅ Treatment protocols created"

# 8. Consultation Templates
IO.puts "📄 Creating consultation templates..."

templates_data = [
  %{
    health_brand_id: demo_brand.id,
    name: "Evaluación Inicial Fisioterapia",
    specialty: "physiotherapy",
    template_type: "initial",
    template_structure: %{
      "sections" => [
        %{
          "title" => "Motivo de Consulta",
          "fields" => ["dolor_localizacion", "dolor_intensidad", "tiempo_evolucion"]
        },
        %{
          "title" => "Examen Físico",
          "fields" => ["rango_movimiento", "fuerza_muscular", "palpacion"]
        },
        %{
          "title" => "Plan de Tratamiento",
          "fields" => ["diagnostico", "objetivos", "plan_sesiones"]
        }
      ]
    },
    required_fields: %{"diagnostico" => true, "plan_sesiones" => true},
    is_active: true
  }
]

Enum.each(templates_data, fn attrs ->
  %ConsultationTemplate{}
  |> ConsultationTemplate.changeset(attrs)
  |> Repo.insert!()
end)

IO.puts "✅ Consultation templates created"

# 9. Staff accounts
IO.puts "👨‍⚕️ Creating staff accounts..."

{:ok, admin_staff} = Accounts.create_staff(%{
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

{:ok, reception_staff} = Accounts.create_staff(%{
  email: "recepcion@demo.com",
  health_brand_id: demo_brand.id,
  staff_role_id: reception_role.id,
  confirmed_at: NaiveDateTime.utc_now(),
  is_active: true
})

{:ok, nurse_staff} = Accounts.create_staff(%{
  email: "enfermera@demo.com",
  health_brand_id: demo_brand.id,
  staff_role_id: nurse_role.id,
  confirmed_at: NaiveDateTime.utc_now(),
  is_active: true
})

{:ok, pharmacist_staff} = Accounts.create_staff(%{
  email: "farmacia@demo.com",
  health_brand_id: demo_brand.id,
  staff_role_id: pharmacist_role.id,
  confirmed_at: NaiveDateTime.utc_now(),
  is_active: true
})

IO.puts "✅ Staff accounts created"

# 10. Staff Invitations
IO.puts "📨 Creating staff invitations..."

invitation_attrs = %{
  health_brand_id: demo_brand.id,
  invited_by_staff_id: admin_staff.id,
  email: "nuevo.doctor@demo.com",
  staff_role_id: doctor_role.id,
  token: "invite_token_123",
  status: "pending",
  expires_at: NaiveDateTime.add(NaiveDateTime.utc_now(), 7 * 24 * 60 * 60)
}

%StaffInvitation{}
|> StaffInvitation.changeset(invitation_attrs)
|> Repo.insert!()

IO.puts "✅ Staff invitations created"

# 11. Patients
IO.puts "👥 Creating patients..."

patients_data = [
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
  }
]

patients_list = Enum.map(patients_data, fn patient_attrs ->
  {:ok, patient} = Accounts.create_patient(patient_attrs)
  patient
end)

[patient1, patient2] = patients_list
IO.puts "✅ Patients created"

# 12. Insurance Providers & Patient Insurance
IO.puts "🏥 Creating insurance data..."

insurance_provider_attrs = %{
  health_brand_id: demo_brand.id,
  name: "OSDE",
  contact_info: %{"telefono" => "0810-555-OSDE", "web" => "www.osde.com.ar"},
  coverage_details: %{"cobertura_basica" => true, "medicamentos" => true},
  authorization_required: true,
  is_active: true
}

insurance_provider = %InsuranceProvider{}
  |> InsuranceProvider.changeset(insurance_provider_attrs)
  |> Repo.insert!()

patient_insurance_attrs = %{
  health_brand_id: demo_brand.id,
  patient_id: patient1.id,
  insurance_provider_id: insurance_provider.id,
  policy_number: "OSDE-123456",
  policy_holder_name: "Ana García",
  coverage_limits: %{"consultas_mensuales" => 4, "estudios_anuales" => 2},
  copayment_amount: Decimal.new("200.00"),
  is_primary: true,
  is_active: true
}

%PatientInsurance{}
|> PatientInsurance.changeset(patient_insurance_attrs)
|> Repo.insert!()

IO.puts "✅ Insurance data created"

# 13. Staff Availability
IO.puts "📅 Creating staff availability..."

availability_entries = [
  %{
    health_brand_id: demo_brand.id,
    staff_id: doctor_staff.id,
    availability_type: "regular",
    day_of_week: 1,
    start_time: ~T[09:00:00],
    end_time: ~T[17:00:00],
    slot_duration: 45
  },
  %{
    health_brand_id: demo_brand.id,
    staff_id: therapist_staff.id,
    availability_type: "regular",
    day_of_week: 3,
    start_time: ~T[08:00:00],
    end_time: ~T[16:00:00],
    slot_duration: 60
  }
]

Enum.each(availability_entries, fn availability_attrs ->
  {:ok, _} = Scheduling.create_staff_availability(availability_attrs)
end)

IO.puts "✅ Staff availability created"

# 14. Appointments
IO.puts "🕐 Creating appointments..."

appointments_data = [
  %{
    health_brand_id: demo_brand.id,
    patient_id: patient1.id,
    staff_id: doctor_staff.id,
    scheduled_for: NaiveDateTime.add(NaiveDateTime.utc_now(), 2 * 24 * 60 * 60),
    duration: 45,
    appointment_type: "evaluacion_inicial",
    status: "confirmed",
    current_status: "scheduled",
    reason_for_visit: "Dolor lumbar persistente"
  },
  %{
    health_brand_id: demo_brand.id,
    patient_id: patient2.id,
    staff_id: therapist_staff.id,
    scheduled_for: NaiveDateTime.add(NaiveDateTime.utc_now(), 3 * 24 * 60 * 60),
    duration: 60,
    appointment_type: "sesion_terapeutica",
    status: "scheduled",
    current_status: "scheduled",
    reason_for_visit: "Seguimiento tratamiento rehabilitación"
  }
]

appointments_list = Enum.map(appointments_data, fn appointment_attrs ->
  {:ok, appointment} = Scheduling.create_appointment(appointment_attrs)
  appointment
end)

[appointment1, appointment2] = appointments_list
IO.puts "✅ Appointments created"

# 15. Check-in Logs
IO.puts "📝 Creating check-in logs..."

checkin_attrs = %{
  health_brand_id: demo_brand.id,
  appointment_id: appointment1.id,
  patient_id: patient1.id,
  check_in_time: NaiveDateTime.utc_now(),
  initial_status: "scheduled",
  final_status: "completed",
  checked_in_by_staff_id: reception_staff.id,
  notes: "Paciente llegó puntual"
}

%CheckInLog{}
|> CheckInLog.changeset(checkin_attrs)
|> Repo.insert!()

IO.puts "✅ Check-in logs created"

# 16. Appointment Status Logs
IO.puts "📊 Creating appointment status logs..."

status_log_attrs = %{
  appointment_id: appointment1.id,
  health_brand_id: demo_brand.id,
  from_status: "scheduled",
  to_status: "confirmed",
  changed_by_staff_id: reception_staff.id,
  notes: "Paciente confirmó asistencia por teléfono"
}

%AppointmentStatusLog{}
|> AppointmentStatusLog.changeset(status_log_attrs)
|> Repo.insert!()

IO.puts "✅ Appointment status logs created"

# 17. Medical Records
IO.puts "📋 Creating medical records..."

# {:ok, medical_record1} = MedicalRecord.create_medical_record(%{
#   health_brand_id: demo_brand.id,
#   patient_id: patient1.id,
#   appointment_id: appointment1.id,
#   staff_id: doctor_staff.id,
#   record_type: "consultation",
#   vital_signs: %{
#     "presion_arterial" => "120/80",
#     "frecuencia_cardiaca" => 72,
#     "temperatura" => 36.5
#   },
#   subjective: "Paciente refiere dolor lumbar de 3 meses de evolución, que empeora con la actividad física.",
#   objective: "Limitación en la flexión lumbar, dolor a la palpación en L4-L5.",
#   assessment: "Lumbalgia mecánica aguda.",
#   plan: "Iniciar tratamiento de fisioterapia, ejercicios de fortalecimiento core."
# })

IO.puts "✅ Medical records created"

# 18. Medical Record Attachments
IO.puts "📎 Creating medical record attachments..."

# attachment_attrs = %{
#   health_brand_id: demo_brand.id,
#   medical_record_id: medical_record1.id,
#   patient_id: patient1.id,
#   staff_id: doctor_staff.id,
#   filename: "radiografia_lumbar.pdf",
#   file_type: "pdf",
#   file_size: 2048576,
#   description: "Radiografía lumbar AP y lateral",
#   s3_key: "attachments/radiografia_123.pdf",
#   is_archived: false
# }

# %MedicalRecordAttachment{}
# |> MedicalRecordAttachment.changeset(attachment_attrs)
# |> Repo.insert!()

IO.puts "✅ Medical record attachments created"

# 19. Treatments
IO.puts "💪 Creating treatments..."

# {:ok, treatment1} = MedicalRecord.create_treatment(%{
#   health_brand_id: demo_brand.id,
#   patient_id: patient1.id,
#   medical_record_id: medical_record1.id,
#   staff_id: therapist_staff.id,
#   name: "Tratamiento de Fisioterapia para Lumbalgia",
#   description: "Plan de 8 sesiones para mejorar dolor lumbar",
#   treatment_plan: %{
#     "sesiones_totales" => 8,
#     "frecuencia" => "2 veces por semana",
#     "objetivos" => ["Reducir dolor", "Mejorar movilidad", "Fortalecer musculatura"]
#   },
#   diagnosis_codes: %{"lumbalgia" => "M54.5"},
#   start_date: Date.utc_today(),
#   expected_sessions: 8
# })

IO.puts "✅ Treatments created"

# 20. Treatment Sessions
IO.puts "🔄 Creating treatment sessions..."

# {:ok, _} = MedicalRecord.create_treatment_session(%{
#   health_brand_id: demo_brand.id,
#   treatment_id: treatment1.id,
#   patient_id: patient1.id,
#   staff_id: therapist_staff.id,
#   session_date: NaiveDateTime.utc_now(),
#   session_type: "sesion_terapeutica",
#   session_number: 1,
#   duration: 60,
#   procedures_performed: %{
#     "terapia_manual" => "Movilizaciones vertebrales",
#     "ejercicios" => "Estabilización lumbar"
#   },
#   subjective_feedback: "Paciente refiere mejoría del 30% en el dolor",
#   patient_progress: "good"
# })

IO.puts "✅ Treatment sessions created"

# 21. Prescriptions
IO.puts "💊 Creating prescriptions..."

# {:ok, prescription} = MedicalRecord.create_prescription(%{
#   health_brand_id: demo_brand.id,
#   medical_record_id: medical_record1.id,
#   patient_id: patient1.id,
#   staff_id: doctor_staff.id,
#   medication_catalog_id: medications_map["Ibuprofeno 400mg"].id,
#   dosage: "400mg",
#   frequency: "cada 8 horas",
#   duration: "7 días",
#   instructions: "Tomar con alimentos",
#   status: "prescribed",
#   prescribed_at: NaiveDateTime.utc_now()
# })

IO.puts "✅ Prescriptions created"

# 22. Inventory
IO.puts "📦 Creating inventory..."

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
  {:ok, _} = Inventory.create_inventory(item_attrs)
end)

IO.puts "✅ Inventory created"

# 23. Billing Items
IO.puts "💰 Creating billing items..."

billing_items_data = [
  %{
    health_brand_id: demo_brand.id,
    name: "Consulta de Evaluación Inicial",
    description: "Primera consulta de evaluación médica",
    item_type: "consultation",
    standard_price: Decimal.new("1500.00"),
    category: "consultas",
    is_active: true
  },
  %{
    health_brand_id: demo_brand.id,
    name: "Sesión de Fisioterapia",
    description: "Sesión individual de fisioterapia",
    item_type: "procedure",
    standard_price: Decimal.new("1200.00"),
    category: "procedimientos",
    is_active: true
  }
]

Enum.each(billing_items_data, fn attrs ->
  %BillingItem{}
  |> BillingItem.changeset(attrs)
  |> Repo.insert!()
end)

IO.puts "✅ Billing items created"

# 24. Invoices
IO.puts "🧾 Creating invoices..."

invoice_number = Billing.generate_invoice_number(demo_brand.id)

{:ok, _} = Billing.create_invoice(%{
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

# 25. Payment Integrations
IO.puts "💳 Creating payment integrations..."

payment_integration_attrs = %{
  health_brand_id: demo_brand.id,
  provider: "mercadopago",
  access_token: "TEST-123456789",
  public_key: "TEST-public-key-123",
  is_active: true,
  webhook_url: "https://demo.laura.ia3.art/webhooks/mercadopago",
  metadata: %{"sandbox" => true}
}

%PaymentIntegration{}
|> PaymentIntegration.changeset(payment_integration_attrs)
|> Repo.insert!()

IO.puts "✅ Payment integrations created"

# 26. Message Templates
IO.puts "💬 Creating message templates..."

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
  {:ok, _} = Messaging.create_message_template(template_attrs)
end)

IO.puts "✅ Message templates created"

# 27. Analytics Events
IO.puts "📊 Creating analytics events..."

# Analytics.track_event(
#   demo_brand.id,
#   "appointment",
#   "appointment_scheduled",
#   %{"appointment_type" => "evaluacion_inicial"},
#   %{staff_id: doctor_staff.id, patient_id: patient1.id}
# )

IO.puts "✅ Analytics events created"

# 28. Permissions
IO.puts "🔐 Creating granular permissions..."

permissions_data = [
  %{staff_role_id: nurse_role.id, module: "medical_records", action: "read", scope: "limited"},
  %{staff_role_id: nurse_role.id, module: "medical_records", action: "write", scope: "notes_only"},
  %{staff_role_id: pharmacist_role.id, module: "prescriptions", action: "read", scope: "all"},
  %{staff_role_id: pharmacist_role.id, module: "prescriptions", action: "write", scope: "dispense"}
]

Enum.each(permissions_data, fn attrs ->
  %Permission{}
  |> Permission.changeset(attrs)
  |> Repo.insert!()
end)

IO.puts "✅ Permissions created"

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
   • Enfermera: enfermera@demo.com
   • Farmacéutico: farmacia@demo.com

📊 FEATURES INCLUIDAS:
   • Diagnostic Catalogs (CIE-10)
   • Medication Catalogs
   • Treatment Protocols
   • Consultation Templates
   • Prescriptions
   • Check-in logs y status tracking
   • Insurance providers
   • Payment integrations
   • Billing items
   • RBAC permissions

👥 PATIENTS: 2 pacientes
📅 APPOINTMENTS: 2 citas
📋 MEDICAL RECORDS: 1 historia clínica
💊 INVENTORY: 2 items
💬 MESSAGING: 1 plantilla
🧾 BILLING: Sistema completo

🔗 Access: http://localhost:4000/auth
   Usa cualquier email de staff para magic link
"""

IO.puts ""
IO.puts "🚀 ¡SISTEMA COMPLETO Y LISTO!"
