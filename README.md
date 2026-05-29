# PaketGO

Cok kiracili otomatik paket servis ve kurye takip sistemi. Proje Flutter mobil uygulamasi, PostgREST API katmani ve PostgreSQL/PostGIS veritabani semasini tek repoda toplar.

## Bilesenler

- `db/migrations/001_init_paketgo.sql`: Tenant, kullanici, kurye profili, bolge, siparis ve canli konum tablolarini; PostGIS indekslerini; RLS politikalarini ve RPC fonksiyonlarini kurar.
- `docker-compose.yml`: Yerel PostgreSQL/PostGIS ve PostgREST servislerini ayaga kaldirir.
- `db/seeds/001_demo_data.sql`: Yerel deneme icin sabit tenant, kurye, siparis ve konum verisi ekler.
- `scripts/make_jwt.py`: PostgREST RLS testleri icin HS256 JWT uretir.
- `lib/services/paketgo_location_service.dart`: Kurye konumunu PostgREST `pg_live_locations` endpointine upsert eder.
- `lib/screens/nfc_payment_screen.dart`: NFC kart okuma akisindan sonra `rpc_process_nfc_payment` fonksiyonunu cagirir.
- `lib/services/paketgo_api_client.dart`: PostgREST RPC cagrilari icin ortak HTTP istemcisidir.

## Yerel API'yi baslatma

```bash
cp .env.example .env
# .env icindeki PGRST_JWT_SECRET degerini en az 32 karakterlik guvenli bir degerle degistirin.
docker compose up -d
```

PostgREST varsayilan olarak `http://localhost:3000` adresinde calisir.

> Not: `db/migrations` klasoru Docker entrypoint olarak baglidir. SQL dosyasi sadece PostgreSQL volume ilk kez olusturulurken otomatik calisir. Semayi bastan kurmak icin `docker compose down -v` ardindan yeniden `docker compose up -d` calistirin.

Demo verisini yuklemek icin:

```bash
psql "postgres://paketgo_admin:paketgo_admin_password@localhost:5432/paketgo" -f db/seeds/001_demo_data.sql
```

## Flutter uygulamasini calistirma

Flutter SDK kurulu bir ortamda:

```bash
flutter pub get
flutter run --dart-define=PAKETGO_POSTGREST_URL=http://localhost:3000
```

Mobil cihaz/emulator PostgREST'e makineniz uzerinden erisecekse `localhost` yerine uygun LAN IP veya Android emulator icin `http://10.0.2.2:3000` kullanin.

## JWT beklentisi

RLS politikalarinin tenant filtreleri icin JWT claimlerinde asagidaki alan bulunmalidir:

```json
{
  "role": "authenticated",
  "tenant_id": "<tenant-uuid>"
}
```

PostgREST `authenticated` rolune gecerek `pg_orders`, `pg_live_locations` ve RPC fonksiyonlarini tenant bazli calistirir.

Yerel demo tenant icin token uretmek:

```bash
PGRST_JWT_SECRET=replace-with-at-least-32-characters scripts/make_jwt.py
```

Demo siparisini en yakin kuryeye atamak:

```bash
TOKEN="$(PGRST_JWT_SECRET=replace-with-at-least-32-characters scripts/make_jwt.py)"
curl -s http://localhost:3000/rpc/rpc_assign_auto_courier \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"p_order_id":"00000000-0000-0000-0000-000000000201"}'
```

## PostgREST endpointleri

- Canli konum upsert: `POST /pg_live_locations?on_conflict=courier_id`
- Otomatik kurye atama: `POST /rpc/rpc_assign_auto_courier`
- NFC odeme tamamlama: `POST /rpc/rpc_process_nfc_payment`

## Android/iOS izinleri

Flutter platform klasorleri olusturulduktan sonra asagidaki izinleri ekleyin:

- Android: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, gerekiyorsa `ACCESS_BACKGROUND_LOCATION`, `NFC`
- iOS: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`, NFC entitlement ve `NFCReaderUsageDescription`

Bu repoda ortamda Flutter CLI bulunmadigi icin platform klasorleri uretilmedi; Flutter SDK kurulu bir makinede `flutter create .` ile Android/iOS sarmallari eklenebilir.
