-- PaketGO Database Schema
-- PostgreSQL + PostgREST

-- Kullanıcılar
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    role VARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'courier', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Adresler
CREATE TABLE IF NOT EXISTS addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    full_address TEXT NOT NULL,
    city VARCHAR(100),
    district VARCHAR(100),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Paketler / Kargolar
CREATE TABLE IF NOT EXISTS packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tracking_number VARCHAR(50) UNIQUE NOT NULL,
    sender_id UUID REFERENCES users(id),
    receiver_name VARCHAR(255) NOT NULL,
    receiver_phone VARCHAR(20),
    sender_address TEXT NOT NULL,
    receiver_address TEXT NOT NULL,
    status VARCHAR(30) DEFAULT 'pending' 
        CHECK (status IN ('pending', 'picked_up', 'in_transit', 'out_for_delivery', 'delivered', 'cancelled')),
    weight DOUBLE PRECISION,
    size VARCHAR(20) DEFAULT 'medium' CHECK (size IN ('small', 'medium', 'large')),
    description TEXT,
    estimated_delivery TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    courier_id UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Paket takip olayları
CREATE TABLE IF NOT EXISTS tracking_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    package_id UUID REFERENCES packages(id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Kuryeler
CREATE TABLE IF NOT EXISTS couriers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    vehicle_type VARCHAR(20) DEFAULT 'motorcycle' 
        CHECK (vehicle_type IN ('motorcycle', 'bicycle', 'car', 'van')),
    is_available BOOLEAN DEFAULT TRUE,
    current_latitude DOUBLE PRECISION,
    current_longitude DOUBLE PRECISION,
    rating DOUBLE PRECISION DEFAULT 5.0,
    delivery_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Restoranlar
CREATE TABLE IF NOT EXISTS restaurants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    image_url TEXT,
    cuisine VARCHAR(100),
    rating DOUBLE PRECISION DEFAULT 0,
    delivery_time INTEGER DEFAULT 30,
    delivery_fee DOUBLE PRECISION DEFAULT 0,
    min_order DOUBLE PRECISION DEFAULT 0,
    is_open BOOLEAN DEFAULT TRUE,
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Menü öğeleri
CREATE TABLE IF NOT EXISTS menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DOUBLE PRECISION NOT NULL,
    image_url TEXT,
    category VARCHAR(100),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Yemek siparişleri
CREATE TABLE IF NOT EXISTS food_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    restaurant_id UUID REFERENCES restaurants(id),
    status VARCHAR(30) DEFAULT 'pending'
        CHECK (status IN ('pending', 'preparing', 'on_the_way', 'delivered', 'cancelled')),
    total_price DOUBLE PRECISION NOT NULL,
    delivery_address TEXT NOT NULL,
    delivery_fee DOUBLE PRECISION DEFAULT 0,
    estimated_minutes INTEGER DEFAULT 30,
    courier_id UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sipariş kalemleri
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES food_orders(id) ON DELETE CASCADE,
    menu_item_id UUID REFERENCES menu_items(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    price DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexler
CREATE INDEX IF NOT EXISTS idx_packages_tracking ON packages(tracking_number);
CREATE INDEX IF NOT EXISTS idx_packages_sender ON packages(sender_id);
CREATE INDEX IF NOT EXISTS idx_packages_status ON packages(status);
CREATE INDEX IF NOT EXISTS idx_tracking_events_package ON tracking_events(package_id);
CREATE INDEX IF NOT EXISTS idx_couriers_available ON couriers(is_available);
CREATE INDEX IF NOT EXISTS idx_menu_items_restaurant ON menu_items(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_food_orders_user ON food_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);

-- Takip numarası oluşturucu fonksiyon
CREATE OR REPLACE FUNCTION generate_tracking_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.tracking_number := 'PGO-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(nextval('tracking_seq')::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE IF NOT EXISTS tracking_seq START 1;

CREATE OR REPLACE TRIGGER set_tracking_number
    BEFORE INSERT ON packages
    FOR EACH ROW
    WHEN (NEW.tracking_number IS NULL)
    EXECUTE FUNCTION generate_tracking_number();
