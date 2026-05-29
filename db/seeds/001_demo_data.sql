-- Optional demo data for local development.
-- Run manually after docker compose up:
-- psql "$DATABASE_URL" -f db/seeds/001_demo_data.sql

INSERT INTO pg_tenants (id, name, is_active)
VALUES ('00000000-0000-0000-0000-000000000001', 'PaketGO Demo Restoran', TRUE)
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    is_active = EXCLUDED.is_active;

INSERT INTO pg_users (id, tenant_id, role, name, phone)
VALUES
    (
        '00000000-0000-0000-0000-000000000011',
        '00000000-0000-0000-0000-000000000001',
        'restaurant_admin',
        'Demo Restoran Yoneticisi',
        '+905551110001'
    ),
    (
        '00000000-0000-0000-0000-000000000012',
        '00000000-0000-0000-0000-000000000001',
        'courier',
        'Demo Kurye',
        '+905551110002'
    )
ON CONFLICT (id) DO UPDATE
SET tenant_id = EXCLUDED.tenant_id,
    role = EXCLUDED.role,
    name = EXCLUDED.name,
    phone = EXCLUDED.phone;

INSERT INTO pg_courier_profiles (id, user_id, tenant_id, is_active, current_status, balance_tokens)
VALUES (
    '00000000-0000-0000-0000-000000000101',
    '00000000-0000-0000-0000-000000000012',
    '00000000-0000-0000-0000-000000000001',
    TRUE,
    'idle',
    100
)
ON CONFLICT (id) DO UPDATE
SET user_id = EXCLUDED.user_id,
    tenant_id = EXCLUDED.tenant_id,
    is_active = EXCLUDED.is_active,
    current_status = EXCLUDED.current_status,
    balance_tokens = EXCLUDED.balance_tokens,
    updated_at = NOW();

INSERT INTO pg_orders (id, tenant_id, status, total_amount, payment_method, delivery_address, delivery_geo)
VALUES (
    '00000000-0000-0000-0000-000000000201',
    '00000000-0000-0000-0000-000000000001',
    'pending',
    249.90,
    'Online',
    'Demo Mahallesi, PaketGO Sokak No:1, Istanbul',
    'SRID=4326;POINT(29.0000 41.0000)'
)
ON CONFLICT (id) DO UPDATE
SET tenant_id = EXCLUDED.tenant_id,
    status = EXCLUDED.status,
    total_amount = EXCLUDED.total_amount,
    payment_method = EXCLUDED.payment_method,
    delivery_address = EXCLUDED.delivery_address,
    delivery_geo = EXCLUDED.delivery_geo,
    courier_id = NULL,
    updated_at = NOW();

INSERT INTO pg_live_locations (id, courier_id, coordinates, bearing)
VALUES (
    '00000000-0000-0000-0000-000000000301',
    '00000000-0000-0000-0000-000000000101',
    'SRID=4326;POINT(29.0100 41.0100)',
    0.0
)
ON CONFLICT (courier_id) DO UPDATE
SET coordinates = EXCLUDED.coordinates,
    bearing = EXCLUDED.bearing,
    updated_at = NOW();
