# Contexto del Proyecto Laura

## Estado Actual (2025-10-28)

- ✅ Base de datos y migraciones configuradas
- ✅ Modelos: HealthBrand, SubscriptionPlan, Staff, StaffRole, PaymentEvent
- ✅ Contextos: Platform, Accounts, Billing
- ✅ Seeds funcionando con planes de suscripción
- 🔄 Próximo paso: Autenticación con Magic Link

## Decisiones Técnicas

- Phoenix 1.8+ con LiveView
- PostgreSQL + Ecto
- MercadoPago para pagos (no Stripe)
- Multi-tenant por subdominios
- 30 días de trial gratis
- Rate limiting para registro

## Estructura DDD Implementada

- `lib/laura/platform/` - Tenancy y onboarding
- `lib/laura/accounts/` - Staff y autenticación
- `lib/laura/billing/` - Suscripciones y MercadoPago
- `lib/laura/security/` - Rate limiting

## Próximos Pasos Priorizados

1. Sistema de autenticación con magic link
2. Middleware de detección de tenants
3. LiveViews para onboarding
4. Portal público de agendamiento
