--
-- PostgreSQL database dump
--

\restrict mz4hu0v38flUFQrETERaAFhFae4kS8WnssBzbu4UIpMrd3uvV5jnW3HFFvmMAgY

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: analytics_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analytics_events (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    event_type character varying(255) NOT NULL,
    event_name character varying(255) NOT NULL,
    event_data jsonb DEFAULT '{}'::jsonb,
    staff_id uuid,
    patient_id uuid,
    appointment_id uuid,
    invoice_id uuid,
    session_id character varying(255),
    ip_address character varying(255),
    user_agent text,
    url_path character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_keys (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    key_prefix character varying(255) NOT NULL,
    key_hash character varying(255) NOT NULL,
    scopes jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    revoked_at timestamp(0) without time zone,
    rate_limit integer DEFAULT 1000,
    usage_count integer DEFAULT 0,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: appointment_status_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointment_status_logs (
    id uuid NOT NULL,
    appointment_id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    from_status character varying(255),
    to_status character varying(255) NOT NULL,
    changed_by_staff_id uuid,
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: appointments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointments (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    scheduled_for timestamp(0) without time zone NOT NULL,
    duration integer NOT NULL,
    appointment_type character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'scheduled'::character varying,
    reason_for_visit text,
    notes text,
    reminder_sent_at timestamp(0) without time zone,
    confirmation_sent_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: billing_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_items (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    item_type character varying(255) NOT NULL,
    standard_price numeric(10,2) NOT NULL,
    category character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: check_in_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.check_in_logs (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    appointment_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    check_in_time timestamp(0) without time zone,
    check_out_time timestamp(0) without time zone,
    initial_status character varying(255),
    final_status character varying(255),
    checked_in_by_staff_id uuid,
    checked_out_by_staff_id uuid,
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: consultation_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consultation_templates (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    specialty character varying(255),
    template_type character varying(255) NOT NULL,
    template_structure jsonb NOT NULL,
    required_fields jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversations (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    staff_ids jsonb DEFAULT '{}'::jsonb,
    title character varying(255),
    conversation_type character varying(255) NOT NULL,
    last_message_at timestamp(0) without time zone,
    last_message_preview text,
    is_archived boolean DEFAULT false,
    is_resolved boolean DEFAULT false,
    priority character varying(255) DEFAULT 'normal'::character varying,
    tags jsonb DEFAULT '{}'::jsonb,
    category character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: diagnostic_catalogs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.diagnostic_catalogs (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    code character varying(255) NOT NULL,
    description text NOT NULL,
    category character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: health_brands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.health_brands (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    subdomain character varying(255) NOT NULL,
    subscription_plan_id uuid,
    subscription_status character varying(255) DEFAULT 'trial'::character varying,
    trial_ends_at timestamp(0) without time zone,
    trial_activated_at timestamp(0) without time zone,
    current_period_end timestamp(0) without time zone,
    reminders_used_current_month integer DEFAULT 0,
    mp_customer_id character varying(255),
    mp_subscription_id character varying(255),
    mp_preapproval_id character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: insurance_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.insurance_providers (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    contact_info jsonb DEFAULT '{}'::jsonb,
    coverage_details jsonb DEFAULT '{}'::jsonb,
    authorization_required boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(255) NOT NULL,
    item_type character varying(255) NOT NULL,
    current_stock integer DEFAULT 0,
    min_stock integer DEFAULT 0,
    max_stock integer,
    unit_cost numeric(10,2),
    unit_price numeric(10,2),
    medication_data jsonb DEFAULT '{}'::jsonb,
    supply_data jsonb DEFAULT '{}'::jsonb,
    equipment_data jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true,
    reorder_needed boolean DEFAULT false,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: inventory_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_transactions (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    inventory_id uuid NOT NULL,
    treatment_session_id uuid,
    staff_id uuid NOT NULL,
    transaction_type character varying(255) NOT NULL,
    quantity integer NOT NULL,
    unit_cost numeric(10,2),
    total_cost numeric(10,2),
    reference_number character varying(255),
    supplier_info jsonb DEFAULT '{}'::jsonb,
    notes text,
    transaction_date timestamp(0) without time zone NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    appointment_id uuid,
    invoice_number character varying(255) NOT NULL,
    invoice_date date NOT NULL,
    due_date date,
    status character varying(255) DEFAULT 'draft'::character varying,
    subtotal numeric(10,2) NOT NULL,
    tax_amount numeric(10,2) DEFAULT 0.0,
    total_amount numeric(10,2) NOT NULL,
    amount_paid numeric(10,2) DEFAULT 0.0,
    balance_due numeric(10,2),
    line_items jsonb DEFAULT '{}'::jsonb,
    payment_method character varying(255),
    paid_at timestamp(0) without time zone,
    payment_reference character varying(255),
    cae_number character varying(255),
    cae_due_date date,
    afip_data jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: medical_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medical_configs (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    treatment_categories jsonb DEFAULT '{}'::jsonb,
    procedure_templates jsonb DEFAULT '{}'::jsonb,
    medication_categories jsonb DEFAULT '{}'::jsonb,
    diagnosis_codes jsonb DEFAULT '{}'::jsonb,
    session_types jsonb DEFAULT '{}'::jsonb,
    appointment_duration integer DEFAULT 30,
    business_hours jsonb DEFAULT '{}'::jsonb,
    reminder_settings jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: medical_record_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medical_record_attachments (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    medical_record_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    filename character varying(255) NOT NULL,
    file_type character varying(255) NOT NULL,
    file_size integer,
    description text,
    s3_key character varying(255),
    is_archived boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: medical_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medical_records (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    appointment_id uuid,
    staff_id uuid NOT NULL,
    vital_signs jsonb DEFAULT '{}'::jsonb,
    subjective text,
    objective text,
    assessment text,
    plan text,
    record_type character varying(255) NOT NULL,
    is_confidential boolean DEFAULT false,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: medication_catalogs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medication_catalogs (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    generic_name character varying(255),
    description text,
    presentation character varying(255),
    standard_dosage character varying(255),
    contraindications text,
    interactions text,
    is_active boolean DEFAULT true NOT NULL,
    medication_data jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: message_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message_templates (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    template_type character varying(255) NOT NULL,
    channel character varying(255) NOT NULL,
    subject character varying(255),
    body text NOT NULL,
    variables jsonb DEFAULT '{}'::jsonb,
    is_auto_send boolean DEFAULT false,
    trigger_event character varying(255),
    send_delay_hours integer DEFAULT 0,
    is_active boolean DEFAULT true,
    requires_approval boolean DEFAULT false,
    approved_by_staff_id uuid,
    approved_at timestamp(0) without time zone,
    usage_count integer DEFAULT 0,
    last_used_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    from_staff_id uuid,
    to_staff_id uuid,
    to_patient_id uuid,
    conversation_id uuid,
    message_type character varying(255) NOT NULL,
    subject character varying(255),
    body text NOT NULL,
    attachments jsonb DEFAULT '{}'::jsonb,
    status character varying(255) DEFAULT 'draft'::character varying,
    sent_at timestamp(0) without time zone,
    delivered_at timestamp(0) without time zone,
    read_at timestamp(0) without time zone,
    external_message_id character varying(255),
    delivery_status jsonb DEFAULT '{}'::jsonb,
    error_message text,
    is_reminder boolean DEFAULT false,
    reminder_template character varying(255),
    appointment_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: patient_insurances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_insurances (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    insurance_provider_id uuid NOT NULL,
    policy_number character varying(255) NOT NULL,
    policy_holder_name character varying(255),
    coverage_limits jsonb DEFAULT '{}'::jsonb,
    copayment_amount numeric(10,2),
    is_primary boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: patients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patients (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255),
    phone character varying(255),
    birth_date date,
    gender character varying(255),
    national_id character varying(255),
    address text,
    city character varying(255),
    state character varying(255),
    zip_code character varying(255),
    emergency_contact_name character varying(255),
    emergency_contact_phone character varying(255),
    emergency_contact_relation character varying(255),
    blood_type character varying(255),
    allergies text,
    current_medications text,
    medical_conditions text,
    is_active boolean DEFAULT true,
    notes text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: payment_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_events (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    event_type character varying(255) NOT NULL,
    amount numeric(10,2),
    currency character varying(255) DEFAULT 'ARS'::character varying,
    status character varying(255) NOT NULL,
    mp_payment_id character varying(255),
    mp_merchant_order_id character varying(255),
    mp_preference_id character varying(255),
    mp_notification_url character varying(255),
    metadata jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: payment_integrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_integrations (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    provider character varying(255) NOT NULL,
    access_token text,
    public_key character varying(255),
    is_active boolean DEFAULT false NOT NULL,
    webhook_url character varying(255),
    metadata jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id uuid NOT NULL,
    staff_role_id uuid NOT NULL,
    module character varying(255) NOT NULL,
    action character varying(255) NOT NULL,
    scope character varying(255) DEFAULT 'own'::character varying NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: prescriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prescriptions (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    medical_record_id uuid,
    patient_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    medication_catalog_id uuid,
    medication_name character varying(255),
    medication_description text,
    dosage character varying(255) NOT NULL,
    frequency character varying(255) NOT NULL,
    duration character varying(255) NOT NULL,
    instructions text,
    status character varying(255) DEFAULT 'prescribed'::character varying NOT NULL,
    prescribed_at timestamp(0) without time zone NOT NULL,
    dispensed_at timestamp(0) without time zone,
    completed_at timestamp(0) without time zone,
    metadata jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: staff_availability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_availability (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    availability_type character varying(255) NOT NULL,
    day_of_week integer,
    specific_date date,
    start_time time(0) without time zone NOT NULL,
    end_time time(0) without time zone NOT NULL,
    slot_duration integer DEFAULT 30,
    appointment_types jsonb DEFAULT '{}'::jsonb,
    max_patients_per_slot integer DEFAULT 1,
    is_active boolean DEFAULT true,
    is_time_off boolean DEFAULT false,
    time_off_reason character varying(255),
    recurring boolean DEFAULT false,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: staff_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_invitations (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    invited_by_staff_id uuid NOT NULL,
    email character varying(255) NOT NULL,
    staff_role_id uuid NOT NULL,
    token character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    expires_at timestamp(0) without time zone NOT NULL,
    accepted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: staff_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_roles (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    permissions jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: staffs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staffs (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    health_brand_id uuid NOT NULL,
    staff_role_id uuid NOT NULL,
    magic_link_token character varying(255),
    magic_link_sent_at timestamp(0) without time zone,
    magic_link_expires_at timestamp(0) without time zone,
    magic_link_attempts integer DEFAULT 0,
    last_magic_link_ip character varying(255),
    confirmed_at timestamp(0) without time zone,
    is_active boolean DEFAULT true,
    last_login_at timestamp(0) without time zone,
    login_count integer DEFAULT 0,
    reset_token character varying(255),
    reset_sent_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: subscription_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_plans (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    billing_cycle character varying(255) DEFAULT 'monthly'::character varying NOT NULL,
    reminders_included integer DEFAULT 0 NOT NULL,
    patients_limit integer,
    staff_limit integer,
    storage_limit_mb integer,
    features jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true NOT NULL,
    is_public boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0,
    stripe_price_id character varying(255),
    stripe_product_id character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: treatment_protocols; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.treatment_protocols (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    diagnostic_catalog_id uuid,
    name character varying(255) NOT NULL,
    description text,
    expected_sessions integer,
    session_duration integer,
    frequency character varying(255),
    protocol_steps jsonb DEFAULT '{}'::jsonb,
    medication_recommendations jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: treatment_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.treatment_sessions (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    treatment_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    session_date timestamp(0) without time zone NOT NULL,
    session_type character varying(255) NOT NULL,
    session_number integer NOT NULL,
    duration integer NOT NULL,
    procedures_performed jsonb DEFAULT '{}'::jsonb,
    medications_administered jsonb DEFAULT '{}'::jsonb,
    equipment_used jsonb DEFAULT '{}'::jsonb,
    subjective_feedback text,
    objective_measures jsonb DEFAULT '{}'::jsonb,
    therapist_notes text,
    patient_progress character varying(255),
    status character varying(255) DEFAULT 'completed'::character varying,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: treatments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.treatments (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    medical_record_id uuid,
    staff_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    treatment_plan jsonb DEFAULT '{}'::jsonb,
    diagnosis_codes jsonb DEFAULT '{}'::jsonb,
    status character varying(255) DEFAULT 'active'::character varying,
    start_date date NOT NULL,
    end_date date,
    expected_sessions integer,
    completed_sessions integer DEFAULT 0,
    is_template boolean DEFAULT false,
    template_data jsonb DEFAULT '{}'::jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks (
    id uuid NOT NULL,
    health_brand_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    url character varying(255) NOT NULL,
    secret_key character varying(255) NOT NULL,
    events jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true,
    retry_count integer DEFAULT 3,
    timeout_ms integer DEFAULT 5000,
    last_triggered_at timestamp(0) without time zone,
    success_count integer DEFAULT 0,
    failure_count integer DEFAULT 0,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: analytics_events analytics_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_pkey PRIMARY KEY (id);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: appointment_status_logs appointment_status_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_status_logs
    ADD CONSTRAINT appointment_status_logs_pkey PRIMARY KEY (id);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: billing_items billing_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_items
    ADD CONSTRAINT billing_items_pkey PRIMARY KEY (id);


--
-- Name: check_in_logs check_in_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_in_logs
    ADD CONSTRAINT check_in_logs_pkey PRIMARY KEY (id);


--
-- Name: consultation_templates consultation_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consultation_templates
    ADD CONSTRAINT consultation_templates_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: diagnostic_catalogs diagnostic_catalogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnostic_catalogs
    ADD CONSTRAINT diagnostic_catalogs_pkey PRIMARY KEY (id);


--
-- Name: health_brands health_brands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.health_brands
    ADD CONSTRAINT health_brands_pkey PRIMARY KEY (id);


--
-- Name: insurance_providers insurance_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insurance_providers
    ADD CONSTRAINT insurance_providers_pkey PRIMARY KEY (id);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (id);


--
-- Name: inventory_transactions inventory_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: medical_configs medical_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_configs
    ADD CONSTRAINT medical_configs_pkey PRIMARY KEY (id);


--
-- Name: medical_record_attachments medical_record_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_record_attachments
    ADD CONSTRAINT medical_record_attachments_pkey PRIMARY KEY (id);


--
-- Name: medical_records medical_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_records
    ADD CONSTRAINT medical_records_pkey PRIMARY KEY (id);


--
-- Name: medication_catalogs medication_catalogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medication_catalogs
    ADD CONSTRAINT medication_catalogs_pkey PRIMARY KEY (id);


--
-- Name: message_templates message_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_templates
    ADD CONSTRAINT message_templates_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: patient_insurances patient_insurances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_insurances
    ADD CONSTRAINT patient_insurances_pkey PRIMARY KEY (id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: payment_events payment_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_events
    ADD CONSTRAINT payment_events_pkey PRIMARY KEY (id);


--
-- Name: payment_integrations payment_integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_integrations
    ADD CONSTRAINT payment_integrations_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: prescriptions prescriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: staff_availability staff_availability_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_availability
    ADD CONSTRAINT staff_availability_pkey PRIMARY KEY (id);


--
-- Name: staff_invitations staff_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_invitations
    ADD CONSTRAINT staff_invitations_pkey PRIMARY KEY (id);


--
-- Name: staff_roles staff_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_roles
    ADD CONSTRAINT staff_roles_pkey PRIMARY KEY (id);


--
-- Name: staffs staffs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT staffs_pkey PRIMARY KEY (id);


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (id);


--
-- Name: treatment_protocols treatment_protocols_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatment_protocols
    ADD CONSTRAINT treatment_protocols_pkey PRIMARY KEY (id);


--
-- Name: treatment_sessions treatment_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatment_sessions
    ADD CONSTRAINT treatment_sessions_pkey PRIMARY KEY (id);


--
-- Name: treatments treatments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatments
    ADD CONSTRAINT treatments_pkey PRIMARY KEY (id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: analytics_events_event_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX analytics_events_event_name_index ON public.analytics_events USING btree (event_name);


--
-- Name: analytics_events_event_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX analytics_events_event_type_index ON public.analytics_events USING btree (event_type);


--
-- Name: analytics_events_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX analytics_events_health_brand_id_index ON public.analytics_events USING btree (health_brand_id);


--
-- Name: analytics_events_inserted_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX analytics_events_inserted_at_index ON public.analytics_events USING btree (inserted_at);


--
-- Name: analytics_events_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX analytics_events_patient_id_index ON public.analytics_events USING btree (patient_id);


--
-- Name: analytics_events_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX analytics_events_staff_id_index ON public.analytics_events USING btree (staff_id);


--
-- Name: api_keys_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX api_keys_health_brand_id_index ON public.api_keys USING btree (health_brand_id);


--
-- Name: api_keys_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX api_keys_is_active_index ON public.api_keys USING btree (is_active);


--
-- Name: api_keys_key_hash_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX api_keys_key_hash_index ON public.api_keys USING btree (key_hash);


--
-- Name: api_keys_key_prefix_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX api_keys_key_prefix_index ON public.api_keys USING btree (key_prefix);


--
-- Name: api_keys_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX api_keys_staff_id_index ON public.api_keys USING btree (staff_id);


--
-- Name: appointment_status_logs_appointment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appointment_status_logs_appointment_id_index ON public.appointment_status_logs USING btree (appointment_id);


--
-- Name: appointment_status_logs_changed_by_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appointment_status_logs_changed_by_staff_id_index ON public.appointment_status_logs USING btree (changed_by_staff_id);


--
-- Name: appointment_status_logs_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appointment_status_logs_health_brand_id_index ON public.appointment_status_logs USING btree (health_brand_id);


--
-- Name: appointment_status_logs_inserted_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appointment_status_logs_inserted_at_index ON public.appointment_status_logs USING btree (inserted_at);


--
-- Name: appointment_status_logs_to_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appointment_status_logs_to_status_index ON public.appointment_status_logs USING btree (to_status);


--
-- Name: appointments_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appointments_health_brand_id_index ON public.appointments USING btree (health_brand_id);


--
-- Name: appointments_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appointments_patient_id_index ON public.appointments USING btree (patient_id);


--
-- Name: appointments_scheduled_for_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appointments_scheduled_for_index ON public.appointments USING btree (scheduled_for);


--
-- Name: appointments_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appointments_staff_id_index ON public.appointments USING btree (staff_id);


--
-- Name: appointments_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX appointments_status_index ON public.appointments USING btree (status);


--
-- Name: billing_items_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX billing_items_health_brand_id_index ON public.billing_items USING btree (health_brand_id);


--
-- Name: billing_items_health_brand_id_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX billing_items_health_brand_id_name_index ON public.billing_items USING btree (health_brand_id, name);


--
-- Name: billing_items_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX billing_items_is_active_index ON public.billing_items USING btree (is_active);


--
-- Name: billing_items_item_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX billing_items_item_type_index ON public.billing_items USING btree (item_type);


--
-- Name: check_in_logs_appointment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_in_logs_appointment_id_index ON public.check_in_logs USING btree (appointment_id);


--
-- Name: check_in_logs_check_in_time_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_in_logs_check_in_time_index ON public.check_in_logs USING btree (check_in_time);


--
-- Name: check_in_logs_checked_in_by_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_in_logs_checked_in_by_staff_id_index ON public.check_in_logs USING btree (checked_in_by_staff_id);


--
-- Name: check_in_logs_checked_out_by_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_in_logs_checked_out_by_staff_id_index ON public.check_in_logs USING btree (checked_out_by_staff_id);


--
-- Name: check_in_logs_final_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_in_logs_final_status_index ON public.check_in_logs USING btree (final_status);


--
-- Name: check_in_logs_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_in_logs_health_brand_id_index ON public.check_in_logs USING btree (health_brand_id);


--
-- Name: check_in_logs_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX check_in_logs_patient_id_index ON public.check_in_logs USING btree (patient_id);


--
-- Name: consultation_templates_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX consultation_templates_health_brand_id_index ON public.consultation_templates USING btree (health_brand_id);


--
-- Name: consultation_templates_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX consultation_templates_is_active_index ON public.consultation_templates USING btree (is_active);


--
-- Name: consultation_templates_specialty_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX consultation_templates_specialty_index ON public.consultation_templates USING btree (specialty);


--
-- Name: consultation_templates_template_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX consultation_templates_template_type_index ON public.consultation_templates USING btree (template_type);


--
-- Name: conversations_conversation_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conversations_conversation_type_index ON public.conversations USING btree (conversation_type);


--
-- Name: conversations_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conversations_health_brand_id_index ON public.conversations USING btree (health_brand_id);


--
-- Name: conversations_is_archived_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conversations_is_archived_index ON public.conversations USING btree (is_archived);


--
-- Name: conversations_is_resolved_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conversations_is_resolved_index ON public.conversations USING btree (is_resolved);


--
-- Name: conversations_last_message_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conversations_last_message_at_index ON public.conversations USING btree (last_message_at);


--
-- Name: conversations_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conversations_patient_id_index ON public.conversations USING btree (patient_id);


--
-- Name: conversations_priority_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conversations_priority_index ON public.conversations USING btree (priority);


--
-- Name: diagnostic_catalogs_category_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX diagnostic_catalogs_category_index ON public.diagnostic_catalogs USING btree (category);


--
-- Name: diagnostic_catalogs_health_brand_id_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX diagnostic_catalogs_health_brand_id_code_index ON public.diagnostic_catalogs USING btree (health_brand_id, code);


--
-- Name: diagnostic_catalogs_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX diagnostic_catalogs_health_brand_id_index ON public.diagnostic_catalogs USING btree (health_brand_id);


--
-- Name: diagnostic_catalogs_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX diagnostic_catalogs_is_active_index ON public.diagnostic_catalogs USING btree (is_active);


--
-- Name: health_brands_mp_customer_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX health_brands_mp_customer_id_index ON public.health_brands USING btree (mp_customer_id);


--
-- Name: health_brands_subdomain_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX health_brands_subdomain_index ON public.health_brands USING btree (subdomain);


--
-- Name: health_brands_subscription_plan_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX health_brands_subscription_plan_id_index ON public.health_brands USING btree (subscription_plan_id);


--
-- Name: insurance_providers_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX insurance_providers_health_brand_id_index ON public.insurance_providers USING btree (health_brand_id);


--
-- Name: insurance_providers_health_brand_id_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX insurance_providers_health_brand_id_name_index ON public.insurance_providers USING btree (health_brand_id, name);


--
-- Name: insurance_providers_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX insurance_providers_is_active_index ON public.insurance_providers USING btree (is_active);


--
-- Name: inventory_category_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_category_index ON public.inventory USING btree (category);


--
-- Name: inventory_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_health_brand_id_index ON public.inventory USING btree (health_brand_id);


--
-- Name: inventory_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_is_active_index ON public.inventory USING btree (is_active);


--
-- Name: inventory_item_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_item_type_index ON public.inventory USING btree (item_type);


--
-- Name: inventory_transactions_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_transactions_health_brand_id_index ON public.inventory_transactions USING btree (health_brand_id);


--
-- Name: inventory_transactions_inventory_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_transactions_inventory_id_index ON public.inventory_transactions USING btree (inventory_id);


--
-- Name: inventory_transactions_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_transactions_staff_id_index ON public.inventory_transactions USING btree (staff_id);


--
-- Name: inventory_transactions_transaction_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_transactions_transaction_date_index ON public.inventory_transactions USING btree (transaction_date);


--
-- Name: inventory_transactions_transaction_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_transactions_transaction_type_index ON public.inventory_transactions USING btree (transaction_type);


--
-- Name: inventory_transactions_treatment_session_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventory_transactions_treatment_session_id_index ON public.inventory_transactions USING btree (treatment_session_id);


--
-- Name: invoices_appointment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoices_appointment_id_index ON public.invoices USING btree (appointment_id);


--
-- Name: invoices_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoices_health_brand_id_index ON public.invoices USING btree (health_brand_id);


--
-- Name: invoices_health_brand_id_invoice_number_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invoices_health_brand_id_invoice_number_index ON public.invoices USING btree (health_brand_id, invoice_number);


--
-- Name: invoices_invoice_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoices_invoice_date_index ON public.invoices USING btree (invoice_date);


--
-- Name: invoices_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoices_patient_id_index ON public.invoices USING btree (patient_id);


--
-- Name: invoices_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX invoices_status_index ON public.invoices USING btree (status);


--
-- Name: medical_configs_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX medical_configs_health_brand_id_index ON public.medical_configs USING btree (health_brand_id);


--
-- Name: medical_record_attachments_file_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_record_attachments_file_type_index ON public.medical_record_attachments USING btree (file_type);


--
-- Name: medical_record_attachments_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_record_attachments_health_brand_id_index ON public.medical_record_attachments USING btree (health_brand_id);


--
-- Name: medical_record_attachments_is_archived_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_record_attachments_is_archived_index ON public.medical_record_attachments USING btree (is_archived);


--
-- Name: medical_record_attachments_medical_record_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_record_attachments_medical_record_id_index ON public.medical_record_attachments USING btree (medical_record_id);


--
-- Name: medical_record_attachments_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_record_attachments_patient_id_index ON public.medical_record_attachments USING btree (patient_id);


--
-- Name: medical_record_attachments_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_record_attachments_staff_id_index ON public.medical_record_attachments USING btree (staff_id);


--
-- Name: medical_records_appointment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_records_appointment_id_index ON public.medical_records USING btree (appointment_id);


--
-- Name: medical_records_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_records_health_brand_id_index ON public.medical_records USING btree (health_brand_id);


--
-- Name: medical_records_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_records_patient_id_index ON public.medical_records USING btree (patient_id);


--
-- Name: medical_records_record_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_records_record_type_index ON public.medical_records USING btree (record_type);


--
-- Name: medical_records_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medical_records_staff_id_index ON public.medical_records USING btree (staff_id);


--
-- Name: medication_catalogs_generic_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medication_catalogs_generic_name_index ON public.medication_catalogs USING btree (generic_name);


--
-- Name: medication_catalogs_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medication_catalogs_health_brand_id_index ON public.medication_catalogs USING btree (health_brand_id);


--
-- Name: medication_catalogs_health_brand_id_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX medication_catalogs_health_brand_id_name_index ON public.medication_catalogs USING btree (health_brand_id, name);


--
-- Name: medication_catalogs_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX medication_catalogs_is_active_index ON public.medication_catalogs USING btree (is_active);


--
-- Name: message_templates_channel_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX message_templates_channel_index ON public.message_templates USING btree (channel);


--
-- Name: message_templates_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX message_templates_health_brand_id_index ON public.message_templates USING btree (health_brand_id);


--
-- Name: message_templates_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX message_templates_is_active_index ON public.message_templates USING btree (is_active);


--
-- Name: message_templates_template_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX message_templates_template_type_index ON public.message_templates USING btree (template_type);


--
-- Name: message_templates_trigger_event_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX message_templates_trigger_event_index ON public.message_templates USING btree (trigger_event);


--
-- Name: messages_appointment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_appointment_id_index ON public.messages USING btree (appointment_id);


--
-- Name: messages_conversation_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_conversation_id_index ON public.messages USING btree (conversation_id);


--
-- Name: messages_external_message_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_external_message_id_index ON public.messages USING btree (external_message_id);


--
-- Name: messages_from_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_from_staff_id_index ON public.messages USING btree (from_staff_id);


--
-- Name: messages_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_health_brand_id_index ON public.messages USING btree (health_brand_id);


--
-- Name: messages_message_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_message_type_index ON public.messages USING btree (message_type);


--
-- Name: messages_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_status_index ON public.messages USING btree (status);


--
-- Name: messages_to_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_to_patient_id_index ON public.messages USING btree (to_patient_id);


--
-- Name: messages_to_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_to_staff_id_index ON public.messages USING btree (to_staff_id);


--
-- Name: patient_insurances_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patient_insurances_health_brand_id_index ON public.patient_insurances USING btree (health_brand_id);


--
-- Name: patient_insurances_insurance_provider_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patient_insurances_insurance_provider_id_index ON public.patient_insurances USING btree (insurance_provider_id);


--
-- Name: patient_insurances_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patient_insurances_is_active_index ON public.patient_insurances USING btree (is_active);


--
-- Name: patient_insurances_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patient_insurances_patient_id_index ON public.patient_insurances USING btree (patient_id);


--
-- Name: patient_insurances_patient_id_insurance_provider_id_policy_numb; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX patient_insurances_patient_id_insurance_provider_id_policy_numb ON public.patient_insurances USING btree (patient_id, insurance_provider_id, policy_number);


--
-- Name: patients_email_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patients_email_health_brand_id_index ON public.patients USING btree (email, health_brand_id);


--
-- Name: patients_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patients_health_brand_id_index ON public.patients USING btree (health_brand_id);


--
-- Name: patients_national_id_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX patients_national_id_health_brand_id_index ON public.patients USING btree (national_id, health_brand_id);


--
-- Name: patients_phone_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patients_phone_health_brand_id_index ON public.patients USING btree (phone, health_brand_id);


--
-- Name: payment_events_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_events_health_brand_id_index ON public.payment_events USING btree (health_brand_id);


--
-- Name: payment_events_mp_merchant_order_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_events_mp_merchant_order_id_index ON public.payment_events USING btree (mp_merchant_order_id);


--
-- Name: payment_events_mp_payment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_events_mp_payment_id_index ON public.payment_events USING btree (mp_payment_id);


--
-- Name: payment_integrations_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_integrations_health_brand_id_index ON public.payment_integrations USING btree (health_brand_id);


--
-- Name: payment_integrations_health_brand_id_provider_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX payment_integrations_health_brand_id_provider_index ON public.payment_integrations USING btree (health_brand_id, provider);


--
-- Name: payment_integrations_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payment_integrations_is_active_index ON public.payment_integrations USING btree (is_active);


--
-- Name: permissions_staff_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_staff_role_id_index ON public.permissions USING btree (staff_role_id);


--
-- Name: permissions_staff_role_id_module_action_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX permissions_staff_role_id_module_action_index ON public.permissions USING btree (staff_role_id, module, action);


--
-- Name: prescriptions_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prescriptions_health_brand_id_index ON public.prescriptions USING btree (health_brand_id);


--
-- Name: prescriptions_medical_record_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prescriptions_medical_record_id_index ON public.prescriptions USING btree (medical_record_id);


--
-- Name: prescriptions_medication_catalog_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prescriptions_medication_catalog_id_index ON public.prescriptions USING btree (medication_catalog_id);


--
-- Name: prescriptions_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prescriptions_patient_id_index ON public.prescriptions USING btree (patient_id);


--
-- Name: prescriptions_prescribed_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prescriptions_prescribed_at_index ON public.prescriptions USING btree (prescribed_at);


--
-- Name: prescriptions_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prescriptions_staff_id_index ON public.prescriptions USING btree (staff_id);


--
-- Name: prescriptions_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prescriptions_status_index ON public.prescriptions USING btree (status);


--
-- Name: staff_availability_availability_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_availability_availability_type_index ON public.staff_availability USING btree (availability_type);


--
-- Name: staff_availability_day_of_week_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_availability_day_of_week_index ON public.staff_availability USING btree (day_of_week);


--
-- Name: staff_availability_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_availability_health_brand_id_index ON public.staff_availability USING btree (health_brand_id);


--
-- Name: staff_availability_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_availability_is_active_index ON public.staff_availability USING btree (is_active);


--
-- Name: staff_availability_specific_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_availability_specific_date_index ON public.staff_availability USING btree (specific_date);


--
-- Name: staff_availability_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_availability_staff_id_index ON public.staff_availability USING btree (staff_id);


--
-- Name: staff_invitations_email_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_invitations_email_health_brand_id_index ON public.staff_invitations USING btree (email, health_brand_id);


--
-- Name: staff_invitations_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_invitations_expires_at_index ON public.staff_invitations USING btree (expires_at);


--
-- Name: staff_invitations_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_invitations_health_brand_id_index ON public.staff_invitations USING btree (health_brand_id);


--
-- Name: staff_invitations_invited_by_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_invitations_invited_by_staff_id_index ON public.staff_invitations USING btree (invited_by_staff_id);


--
-- Name: staff_invitations_staff_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_invitations_staff_role_id_index ON public.staff_invitations USING btree (staff_role_id);


--
-- Name: staff_invitations_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staff_invitations_status_index ON public.staff_invitations USING btree (status);


--
-- Name: staff_invitations_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX staff_invitations_token_index ON public.staff_invitations USING btree (token);


--
-- Name: staff_roles_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX staff_roles_name_index ON public.staff_roles USING btree (name);


--
-- Name: staffs_email_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX staffs_email_health_brand_id_index ON public.staffs USING btree (email, health_brand_id);


--
-- Name: staffs_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staffs_health_brand_id_index ON public.staffs USING btree (health_brand_id);


--
-- Name: staffs_magic_link_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staffs_magic_link_token_index ON public.staffs USING btree (magic_link_token);


--
-- Name: staffs_staff_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX staffs_staff_role_id_index ON public.staffs USING btree (staff_role_id);


--
-- Name: subscription_plans_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX subscription_plans_code_index ON public.subscription_plans USING btree (code);


--
-- Name: subscription_plans_is_active_is_public_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscription_plans_is_active_is_public_index ON public.subscription_plans USING btree (is_active, is_public);


--
-- Name: subscription_plans_sort_order_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subscription_plans_sort_order_index ON public.subscription_plans USING btree (sort_order);


--
-- Name: treatment_protocols_diagnostic_catalog_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatment_protocols_diagnostic_catalog_id_index ON public.treatment_protocols USING btree (diagnostic_catalog_id);


--
-- Name: treatment_protocols_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatment_protocols_health_brand_id_index ON public.treatment_protocols USING btree (health_brand_id);


--
-- Name: treatment_protocols_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatment_protocols_is_active_index ON public.treatment_protocols USING btree (is_active);


--
-- Name: treatment_sessions_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatment_sessions_health_brand_id_index ON public.treatment_sessions USING btree (health_brand_id);


--
-- Name: treatment_sessions_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatment_sessions_patient_id_index ON public.treatment_sessions USING btree (patient_id);


--
-- Name: treatment_sessions_session_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatment_sessions_session_date_index ON public.treatment_sessions USING btree (session_date);


--
-- Name: treatment_sessions_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatment_sessions_staff_id_index ON public.treatment_sessions USING btree (staff_id);


--
-- Name: treatment_sessions_treatment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatment_sessions_treatment_id_index ON public.treatment_sessions USING btree (treatment_id);


--
-- Name: treatments_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatments_health_brand_id_index ON public.treatments USING btree (health_brand_id);


--
-- Name: treatments_medical_record_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatments_medical_record_id_index ON public.treatments USING btree (medical_record_id);


--
-- Name: treatments_patient_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatments_patient_id_index ON public.treatments USING btree (patient_id);


--
-- Name: treatments_staff_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatments_staff_id_index ON public.treatments USING btree (staff_id);


--
-- Name: treatments_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX treatments_status_index ON public.treatments USING btree (status);


--
-- Name: webhooks_health_brand_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX webhooks_health_brand_id_index ON public.webhooks USING btree (health_brand_id);


--
-- Name: webhooks_is_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX webhooks_is_active_index ON public.webhooks USING btree (is_active);


--
-- Name: webhooks_last_triggered_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX webhooks_last_triggered_at_index ON public.webhooks USING btree (last_triggered_at);


--
-- Name: appointment_status_logs appointment_status_logs_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_status_logs
    ADD CONSTRAINT appointment_status_logs_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id) ON DELETE CASCADE;


--
-- Name: appointment_status_logs appointment_status_logs_changed_by_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_status_logs
    ADD CONSTRAINT appointment_status_logs_changed_by_staff_id_fkey FOREIGN KEY (changed_by_staff_id) REFERENCES public.staffs(id) ON DELETE SET NULL;


--
-- Name: appointment_status_logs appointment_status_logs_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_status_logs
    ADD CONSTRAINT appointment_status_logs_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: billing_items billing_items_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_items
    ADD CONSTRAINT billing_items_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: check_in_logs check_in_logs_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_in_logs
    ADD CONSTRAINT check_in_logs_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id) ON DELETE CASCADE;


--
-- Name: check_in_logs check_in_logs_checked_in_by_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_in_logs
    ADD CONSTRAINT check_in_logs_checked_in_by_staff_id_fkey FOREIGN KEY (checked_in_by_staff_id) REFERENCES public.staffs(id) ON DELETE SET NULL;


--
-- Name: check_in_logs check_in_logs_checked_out_by_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_in_logs
    ADD CONSTRAINT check_in_logs_checked_out_by_staff_id_fkey FOREIGN KEY (checked_out_by_staff_id) REFERENCES public.staffs(id) ON DELETE SET NULL;


--
-- Name: check_in_logs check_in_logs_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_in_logs
    ADD CONSTRAINT check_in_logs_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: check_in_logs check_in_logs_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.check_in_logs
    ADD CONSTRAINT check_in_logs_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: consultation_templates consultation_templates_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consultation_templates
    ADD CONSTRAINT consultation_templates_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: diagnostic_catalogs diagnostic_catalogs_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.diagnostic_catalogs
    ADD CONSTRAINT diagnostic_catalogs_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: insurance_providers insurance_providers_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insurance_providers
    ADD CONSTRAINT insurance_providers_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: medical_record_attachments medical_record_attachments_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_record_attachments
    ADD CONSTRAINT medical_record_attachments_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: medical_record_attachments medical_record_attachments_medical_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_record_attachments
    ADD CONSTRAINT medical_record_attachments_medical_record_id_fkey FOREIGN KEY (medical_record_id) REFERENCES public.medical_records(id) ON DELETE CASCADE;


--
-- Name: medical_record_attachments medical_record_attachments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_record_attachments
    ADD CONSTRAINT medical_record_attachments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: medical_record_attachments medical_record_attachments_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_record_attachments
    ADD CONSTRAINT medical_record_attachments_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staffs(id) ON DELETE SET NULL;


--
-- Name: medication_catalogs medication_catalogs_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medication_catalogs
    ADD CONSTRAINT medication_catalogs_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: patient_insurances patient_insurances_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_insurances
    ADD CONSTRAINT patient_insurances_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: patient_insurances patient_insurances_insurance_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_insurances
    ADD CONSTRAINT patient_insurances_insurance_provider_id_fkey FOREIGN KEY (insurance_provider_id) REFERENCES public.insurance_providers(id) ON DELETE SET NULL;


--
-- Name: patient_insurances patient_insurances_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_insurances
    ADD CONSTRAINT patient_insurances_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: payment_integrations payment_integrations_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_integrations
    ADD CONSTRAINT payment_integrations_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: permissions permissions_staff_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_staff_role_id_fkey FOREIGN KEY (staff_role_id) REFERENCES public.staff_roles(id) ON DELETE CASCADE;


--
-- Name: prescriptions prescriptions_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: prescriptions prescriptions_medical_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_medical_record_id_fkey FOREIGN KEY (medical_record_id) REFERENCES public.medical_records(id) ON DELETE CASCADE;


--
-- Name: prescriptions prescriptions_medication_catalog_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_medication_catalog_id_fkey FOREIGN KEY (medication_catalog_id) REFERENCES public.medication_catalogs(id) ON DELETE SET NULL;


--
-- Name: prescriptions prescriptions_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: prescriptions prescriptions_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prescriptions
    ADD CONSTRAINT prescriptions_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staffs(id) ON DELETE SET NULL;


--
-- Name: staff_invitations staff_invitations_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_invitations
    ADD CONSTRAINT staff_invitations_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- Name: staff_invitations staff_invitations_invited_by_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_invitations
    ADD CONSTRAINT staff_invitations_invited_by_staff_id_fkey FOREIGN KEY (invited_by_staff_id) REFERENCES public.staffs(id) ON DELETE SET NULL;


--
-- Name: staff_invitations staff_invitations_staff_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_invitations
    ADD CONSTRAINT staff_invitations_staff_role_id_fkey FOREIGN KEY (staff_role_id) REFERENCES public.staff_roles(id) ON DELETE SET NULL;


--
-- Name: treatment_protocols treatment_protocols_diagnostic_catalog_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatment_protocols
    ADD CONSTRAINT treatment_protocols_diagnostic_catalog_id_fkey FOREIGN KEY (diagnostic_catalog_id) REFERENCES public.diagnostic_catalogs(id) ON DELETE SET NULL;


--
-- Name: treatment_protocols treatment_protocols_health_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treatment_protocols
    ADD CONSTRAINT treatment_protocols_health_brand_id_fkey FOREIGN KEY (health_brand_id) REFERENCES public.health_brands(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict mz4hu0v38flUFQrETERaAFhFae4kS8WnssBzbu4UIpMrd3uvV5jnW3HFFvmMAgY

INSERT INTO public."schema_migrations" (version) VALUES (20251030163201);
INSERT INTO public."schema_migrations" (version) VALUES (20251030163219);
INSERT INTO public."schema_migrations" (version) VALUES (20251030163235);
INSERT INTO public."schema_migrations" (version) VALUES (20251030163252);
INSERT INTO public."schema_migrations" (version) VALUES (20251030163308);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000001);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000002);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000003);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000004);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000005);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000006);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000007);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000008);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000009);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000010);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000011);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000012);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000013);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000014);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000015);
INSERT INTO public."schema_migrations" (version) VALUES (20251031000016);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002324);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002354);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002452);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002523);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002607);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002626);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002640);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002655);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002711);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002729);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002743);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002801);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002825);
INSERT INTO public."schema_migrations" (version) VALUES (20251101002841);
