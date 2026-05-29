-- PaketGO PostgreSQL/PostGIS schema for PostgREST.
-- This file is mounted by docker-compose and runs on first database initialization.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
        CREATE ROLE anon NOLOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
        CREATE ROLE authenticated NOLOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticator') THEN
        CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'authenticator_password';
    END IF;
END
$$;

GRANT anon, authenticated TO authenticator;
GRANT USAGE ON SCHEMA public TO anon, authenticated;

CREATE TABLE IF NOT EXISTS pg_tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pg_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES pg_tenants(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL CHECK (role IN ('superadmin', 'restaurant_admin', 'courier', 'customer')),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pg_courier_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES pg_users(id) ON DELETE CASCADE UNIQUE,
    tenant_id UUID REFERENCES pg_tenants(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    current_status VARCHAR(50) DEFAULT 'idle' CHECK (current_status IN ('idle', 'delivering', 'returning')),
    balance_tokens INT DEFAULT 100 CHECK (balance_tokens >= 0),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pg_regions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES pg_tenants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    area GEOMETRY(Polygon, 4326) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pg_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES pg_tenants(id) ON DELETE CASCADE,
    courier_id UUID REFERENCES pg_courier_profiles(id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'preparing', 'on_the_way', 'delivered', 'cancelled')),
    total_amount NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(50) CHECK (payment_method IN ('NFC', 'Cash', 'Online')),
    delivery_address TEXT NOT NULL,
    delivery_geo GEOMETRY(Point, 4326) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pg_live_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    courier_id UUID REFERENCES pg_courier_profiles(id) ON DELETE CASCADE UNIQUE,
    coordinates GEOMETRY(Point, 4326) NOT NULL,
    bearing NUMERIC(5,2) DEFAULT 0.0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_tenant_id ON pg_users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_courier_profiles_tenant_status ON pg_courier_profiles(tenant_id, current_status) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_regions_tenant_id ON pg_regions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_regions_area ON pg_regions USING GIST(area);
CREATE INDEX IF NOT EXISTS idx_orders_tenant_status ON pg_orders(tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_orders_courier_id ON pg_orders(courier_id);
CREATE INDEX IF NOT EXISTS idx_orders_delivery_geo ON pg_orders USING GIST(delivery_geo);
CREATE INDEX IF NOT EXISTS idx_live_locations_courier_id ON pg_live_locations(courier_id);
CREATE INDEX IF NOT EXISTS idx_live_locations_coords ON pg_live_locations USING GIST(coordinates);

ALTER TABLE pg_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE pg_live_locations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS restaurant_order_policy ON pg_orders;
CREATE POLICY restaurant_order_policy ON pg_orders
    FOR ALL
    TO authenticated
    USING (tenant_id = (current_setting('request.jwt.claims', true)::json->>'tenant_id')::uuid)
    WITH CHECK (tenant_id = (current_setting('request.jwt.claims', true)::json->>'tenant_id')::uuid);

DROP POLICY IF EXISTS courier_location_policy ON pg_live_locations;
CREATE POLICY courier_location_policy ON pg_live_locations
    FOR ALL
    TO authenticated
    USING (
        courier_id IN (
            SELECT id
            FROM pg_courier_profiles
            WHERE tenant_id = (current_setting('request.jwt.claims', true)::json->>'tenant_id')::uuid
        )
    )
    WITH CHECK (
        courier_id IN (
            SELECT id
            FROM pg_courier_profiles
            WHERE tenant_id = (current_setting('request.jwt.claims', true)::json->>'tenant_id')::uuid
        )
    );

CREATE OR REPLACE FUNCTION rpc_assign_auto_courier(p_order_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_claims JSON;
    v_claim_tenant_id UUID;
    v_order_geo GEOMETRY(Point, 4326);
    v_target_courier_id UUID;
    v_tenant_id UUID;
BEGIN
    v_claims := COALESCE(NULLIF(current_setting('request.jwt.claims', true), '')::json, '{}'::json);
    v_claim_tenant_id := NULLIF(v_claims->>'tenant_id', '')::uuid;

    SELECT delivery_geo, tenant_id
    INTO v_order_geo, v_tenant_id
    FROM pg_orders
    WHERE id = p_order_id
    FOR UPDATE;

    IF v_tenant_id IS NULL THEN
        RETURN json_build_object('status', 'error', 'message', 'Siparis bulunamadi.');
    END IF;

    IF v_claim_tenant_id IS NULL OR v_claim_tenant_id <> v_tenant_id THEN
        RAISE EXCEPTION 'Yetkisiz tenant erisimi.' USING ERRCODE = '42501';
    END IF;

    SELECT ll.courier_id
    INTO v_target_courier_id
    FROM pg_live_locations ll
    JOIN pg_courier_profiles cp ON ll.courier_id = cp.id
    WHERE cp.tenant_id = v_tenant_id
      AND cp.is_active = TRUE
      AND cp.current_status = 'idle'
      AND cp.balance_tokens > 0
    ORDER BY ll.coordinates <-> v_order_geo
    LIMIT 1
    FOR UPDATE OF cp SKIP LOCKED;

    IF v_target_courier_id IS NOT NULL THEN
        UPDATE pg_orders
        SET courier_id = v_target_courier_id,
            status = 'on_the_way',
            updated_at = NOW()
        WHERE id = p_order_id;

        UPDATE pg_courier_profiles
        SET current_status = 'delivering',
            updated_at = NOW()
        WHERE id = v_target_courier_id;

        RETURN json_build_object(
            'status', 'success',
            'message', 'Kurye otomatik atandi.',
            'courier_id', v_target_courier_id
        );
    END IF;

    RETURN json_build_object('status', 'error', 'message', 'Uygun kurye bulunamadi.');
END;
$$;

CREATE OR REPLACE FUNCTION rpc_process_nfc_payment(p_order_id UUID, p_transaction_token TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_claims JSON;
    v_claim_tenant_id UUID;
    v_tenant_id UUID;
    v_courier_id UUID;
BEGIN
    v_claims := COALESCE(NULLIF(current_setting('request.jwt.claims', true), '')::json, '{}'::json);
    v_claim_tenant_id := NULLIF(v_claims->>'tenant_id', '')::uuid;

    IF p_transaction_token IS NULL OR length(trim(p_transaction_token)) = 0 THEN
        RAISE EXCEPTION 'Islem basarisiz: NFC islem belirteci bos olamaz.';
    END IF;

    SELECT tenant_id, courier_id
    INTO v_tenant_id, v_courier_id
    FROM pg_orders
    WHERE id = p_order_id
    FOR UPDATE;

    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'Islem basarisiz: Siparis bulunamadi.';
    END IF;

    IF v_claim_tenant_id IS NULL OR v_claim_tenant_id <> v_tenant_id THEN
        RAISE EXCEPTION 'Yetkisiz tenant erisimi.' USING ERRCODE = '42501';
    END IF;

    IF v_courier_id IS NULL THEN
        RAISE EXCEPTION 'Islem basarisiz: Siparise atanmis kurye yok.';
    END IF;

    UPDATE pg_courier_profiles
    SET balance_tokens = balance_tokens - 1,
        current_status = 'returning',
        updated_at = NOW()
    WHERE tenant_id = v_tenant_id
      AND id = v_courier_id
      AND balance_tokens > 0;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Islem basarisiz: Yetersiz jeton bakiyesi.';
    END IF;

    UPDATE pg_orders
    SET status = 'delivered',
        payment_method = 'NFC',
        updated_at = NOW()
    WHERE id = p_order_id;

    RETURN json_build_object('status', 'success', 'message', 'NFC Odemesi alindi, jeton dusuldu.');
END;
$$;

GRANT SELECT, INSERT, UPDATE, DELETE ON pg_orders TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON pg_live_locations TO authenticated;
GRANT SELECT ON pg_courier_profiles TO authenticated;
GRANT EXECUTE ON FUNCTION rpc_assign_auto_courier(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION rpc_process_nfc_payment(UUID, TEXT) TO authenticated;
