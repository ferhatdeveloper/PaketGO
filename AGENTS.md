# AGENTS.md

## Cursor Cloud specific instructions

PaketGO, Flutter tabanlı bir kargo/paket takip, kurye çağırma ve yemek sipariş uygulamasıdır.

### Servisler

| Servis | Komut | Port |
|--------|-------|------|
| Flutter Web (dev) | `flutter run -d chrome` veya `flutter run -d web-server --web-port=8080` | 8080 |
| PostgREST API | `cd backend && docker-compose up -d` | 3000 |
| PostgreSQL | Docker Compose ile otomatik başlar | 5432 |

### Sık kullanılan komutlar

- **Lint:** `flutter analyze`
- **Test:** `flutter test`
- **Build (web):** `flutter build web`
- **Build (APK):** `flutter build apk`
- **Bağımlılıklar:** `flutter pub get`

### Önemli notlar

- Flutter SDK `/home/ubuntu/flutter` altında kurulu. PATH'e eklenmiş olmalı.
- Uygulama mock data ile çalışabilir (PostgREST bağlantısı olmadan). `MockDataService` sınıfı demo veriler sağlar.
- Backend'i ayağa kaldırmadan önce Docker'ın çalıştığından emin olun.
- Web build output'u `build/web/` altında oluşur. Statik sunucuyla test için: `cd build/web && python3 -m http.server 8080`
