-- PostgREST roles
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'web_anon') THEN
        CREATE ROLE web_anon NOLOGIN;
    END IF;
END
$$;

GRANT USAGE ON SCHEMA public TO web_anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO web_anon;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO web_anon;

-- Örnek kullanıcılar
INSERT INTO users (id, email, full_name, phone, role) VALUES
('a1111111-1111-1111-1111-111111111111', 'ferhat@paketgo.com', 'Ferhat Developer', '+90 532 000 0001', 'customer'),
('a2222222-2222-2222-2222-222222222222', 'emre@paketgo.com', 'Emre Aydın', '+90 532 111 2233', 'courier'),
('a3333333-3333-3333-3333-333333333333', 'burak@paketgo.com', 'Burak Çelik', '+90 533 444 5566', 'courier'),
('a4444444-4444-4444-4444-444444444444', 'admin@paketgo.com', 'Admin User', '+90 530 000 0000', 'admin')
ON CONFLICT (id) DO NOTHING;

-- Örnek kuryeler
INSERT INTO couriers (user_id, vehicle_type, is_available, current_latitude, current_longitude, rating, delivery_count) VALUES
('a2222222-2222-2222-2222-222222222222', 'motorcycle', true, 41.0082, 28.9784, 4.8, 342),
('a3333333-3333-3333-3333-333333333333', 'bicycle', true, 41.0122, 28.9760, 4.6, 156)
ON CONFLICT DO NOTHING;

-- Örnek paketler
INSERT INTO packages (id, tracking_number, sender_id, receiver_name, receiver_phone, sender_address, receiver_address, status, weight, size, description, estimated_delivery) VALUES
('b1111111-1111-1111-1111-111111111111', 'PGO-2024-000001', 'a1111111-1111-1111-1111-111111111111', 'Mehmet Kaya', '+90 533 111 2233', 'Kadıköy, İstanbul', 'Çankaya, Ankara', 'in_transit', 2.5, 'medium', 'Elektronik cihaz', NOW() + INTERVAL '1 day'),
('b2222222-2222-2222-2222-222222222222', 'PGO-2024-000002', 'a1111111-1111-1111-1111-111111111111', 'Fatma Şahin', '+90 535 222 3344', 'Beşiktaş, İstanbul', 'Bornova, İzmir', 'delivered', 1.2, 'small', 'Kıyafet paketi', NOW() - INTERVAL '2 days')
ON CONFLICT DO NOTHING;

-- Takip olayları
INSERT INTO tracking_events (package_id, status, description, location) VALUES
('b1111111-1111-1111-1111-111111111111', 'picked_up', 'Paket teslim alındı', 'Kadıköy Şube'),
('b1111111-1111-1111-1111-111111111111', 'in_transit', 'Transfer merkezine ulaştı', 'İstanbul Dağıtım Merkezi'),
('b1111111-1111-1111-1111-111111111111', 'in_transit', 'Ankara''ya yola çıktı', 'İstanbul Dağıtım Merkezi'),
('b2222222-2222-2222-2222-222222222222', 'picked_up', 'Paket teslim alındı', 'Beşiktaş Şube'),
('b2222222-2222-2222-2222-222222222222', 'delivered', 'Teslim edildi', 'Bornova, İzmir');

-- Örnek restoranlar
INSERT INTO restaurants (id, name, cuisine, rating, delivery_time, delivery_fee, min_order, is_open) VALUES
('c1111111-1111-1111-1111-111111111111', 'Kebapçı Mehmet Usta', 'Türk Mutfağı', 4.7, 25, 15.0, 80.0, true),
('c2222222-2222-2222-2222-222222222222', 'Pizza House', 'İtalyan', 4.5, 30, 10.0, 100.0, true),
('c3333333-3333-3333-3333-333333333333', 'Sushi Master', 'Japon', 4.8, 40, 20.0, 150.0, true),
('c4444444-4444-4444-4444-444444444444', 'Burger King', 'Fast Food', 4.3, 20, 5.0, 50.0, true),
('c5555555-5555-5555-5555-555555555555', 'Çiğ Köfteci Ali', 'Türk Mutfağı', 4.6, 15, 8.0, 40.0, false)
ON CONFLICT DO NOTHING;

-- Menü öğeleri
INSERT INTO menu_items (restaurant_id, name, price, category) VALUES
('c1111111-1111-1111-1111-111111111111', 'Adana Kebap', 180.0, 'Ana Yemek'),
('c1111111-1111-1111-1111-111111111111', 'Urfa Kebap', 170.0, 'Ana Yemek'),
('c1111111-1111-1111-1111-111111111111', 'Pide', 120.0, 'Ana Yemek'),
('c1111111-1111-1111-1111-111111111111', 'Lahmacun', 60.0, 'Ana Yemek'),
('c1111111-1111-1111-1111-111111111111', 'Ayran', 20.0, 'İçecek'),
('c2222222-2222-2222-2222-222222222222', 'Margarita Pizza', 150.0, 'Pizza'),
('c2222222-2222-2222-2222-222222222222', 'Pepperoni Pizza', 180.0, 'Pizza'),
('c2222222-2222-2222-2222-222222222222', 'Karışık Pizza', 200.0, 'Pizza'),
('c2222222-2222-2222-2222-222222222222', 'Cola', 30.0, 'İçecek'),
('c3333333-3333-3333-3333-333333333333', 'Salmon Sushi Set', 280.0, 'Sushi'),
('c3333333-3333-3333-3333-333333333333', 'California Roll', 200.0, 'Sushi'),
('c3333333-3333-3333-3333-333333333333', 'Miso Çorba', 60.0, 'Çorba'),
('c4444444-4444-4444-4444-444444444444', 'Whopper Menü', 160.0, 'Burger'),
('c4444444-4444-4444-4444-444444444444', 'Chicken Burger', 130.0, 'Burger'),
('c4444444-4444-4444-4444-444444444444', 'Patates Kızartması', 50.0, 'Yan Ürün'),
('c5555555-5555-5555-5555-555555555555', 'Çiğ Köfte Dürüm', 55.0, 'Ana Yemek'),
('c5555555-5555-5555-5555-555555555555', 'Çiğ Köfte Porsiyon', 70.0, 'Ana Yemek'),
('c5555555-5555-5555-5555-555555555555', 'Şalgam', 15.0, 'İçecek');
