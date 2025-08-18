# Play Store Release Build Kılavuzu

## Ön Gereksinimler

1. **Flutter SDK**: En son kararlı sürüm
2. **Android SDK**: API Level 34
3. **Java JDK**: Version 11 veya üzeri

## 1. Keystore Oluşturma

### Windows PowerShell:
```powershell
# Keystore dosyası oluştur
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Örnek bilgiler:
# Şifre: [güvenli şifre]
# İsim: [Adınız Soyadınız]
# Organizasyon: MC Medya
# Şehir: [Şehriniz]
# Ülke: TR
```

### Keystore bilgilerini kaydet:
```powershell
# key.properties dosyası oluştur
Copy-Item "android\key.properties.template" "android\key.properties"
```

`android\key.properties` dosyasını düzenleyin:
```properties
storePassword=YOUR_ACTUAL_STORE_PASSWORD
keyPassword=YOUR_ACTUAL_KEY_PASSWORD
keyAlias=upload
storeFile=C:/Users/YourUsername/upload-keystore.jks
```

## 2. Dependencies Güncelleme

```powershell
flutter pub get
flutter pub upgrade
```

## 3. Release Build Oluşturma

### APK için:
```powershell
flutter build apk --release
```

### App Bundle için (Önerilen):
```powershell
flutter build appbundle --release
```

### Build dosyaları:
- APK: `build\app\outputs\flutter-apk\app-release.apk`
- AAB: `build\app\outputs\bundle\release\app-release.aab`

## 4. Build Doğrulama

```powershell
# APK boyutunu kontrol et
flutter build apk --analyze-size

# App Bundle boyutunu kontrol et
flutter build appbundle --analyze-size
```

## 5. Test Etme

```powershell
# Release modunda test et
flutter run --release

# Debug bilgilerini kaldır
flutter clean
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

## Play Store Yükleme Kontrol Listesi

### ✅ Gerekli Dosyalar:
- [ ] `app-release.aab` (App Bundle)
- [ ] App ikonları (tüm boyutlar)
- [ ] Store listing görselleri
- [ ] Gizlilik politikası
- [ ] Release notes

### ✅ Store Listing:
- [ ] App adı: "Deprem Takip"
- [ ] Kısa açıklama (80 karakter)
- [ ] Uzun açıklama
- [ ] Anahtar kelimeler
- [ ] Kategori: Haberler ve Dergiler / Araçlar
- [ ] Yaş sınırı: 3+

### ✅ Grafikler:
- [ ] App ikonu (512x512)
- [ ] Öne çıkarılan grafik (1024x500)
- [ ] Telefon ekran görüntüleri (2-8 adet)
- [ ] Tablet ekran görüntüleri (opsiyonel)

### ✅ Store Politikaları:
- [ ] Gizlilik politikası URL'si
- [ ] İçerik derecelendirmesi
- [ ] Target audience seçimi
- [ ] Veri güvenliği formu

## Önemli Notlar

1. **key.properties dosyasını asla commit etmeyin!**
2. **Keystore dosyasının yedeğini alın**
3. **İlk release sonrası version code'u artırın**
4. **Release notes'u her güncelleme için hazırlayın**

## Sürüm Güncelleme

Sonraki sürümler için `pubspec.yaml` dosyasında version'ı güncelleyin:
```yaml
version: 1.1.0+2  # version_name+version_code
```
