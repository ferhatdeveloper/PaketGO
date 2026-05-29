# PaketGO 📦

Hızlı & Güvenli Teslimat Platformu - Flutter + PostgREST

## Özellikler

- 📦 **Kargo Takip** - Paketlerinizi gerçek zamanlı takip edin
- 🏍️ **Kurye Çağırma** - Anında kurye çağırın
- 📮 **Paket Gönderimi** - Kolayca paket gönderin
- 🍕 **Yemek Siparişi** - Restoranlardan yemek sipariş edin

## Teknoloji

- **Frontend:** Flutter 3.24+
- **Backend:** PostgREST + PostgreSQL 16
- **Veritabanı:** PostgreSQL

## Başlangıç

### Gereksinimler

- Flutter SDK 3.24+
- Docker & Docker Compose (backend için)

### Flutter Uygulaması

```bash
# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır (web)
flutter run -d chrome

# Uygulamayı çalıştır (linux desktop)
flutter run -d linux
```

### Backend (PostgREST + PostgreSQL)

```bash
cd backend
docker-compose up -d
```

API `http://localhost:3000` adresinde çalışır.

### Test

```bash
flutter test
flutter analyze
```

## Proje Yapısı

```
lib/
├── main.dart              # Uygulama giriş noktası
├── theme/                 # Tema ve stiller
├── models/                # Veri modelleri
├── screens/               # Uygulama ekranları
├── services/              # API ve veri servisleri
├── widgets/               # Tekrar kullanılabilir widget'lar
├── providers/             # State management
└── utils/                 # Yardımcı fonksiyonlar

backend/
├── schema.sql             # Veritabanı şeması
├── seed.sql               # Örnek veriler
├── postgrest.conf         # PostgREST yapılandırması
└── docker-compose.yml     # Docker servisleri
```

## Lisans

MIT
