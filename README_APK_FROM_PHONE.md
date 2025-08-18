# Tạo file APK từ điện thoại (không cần máy tính)

Mục tiêu: Dùng **GitHub Actions** build APK và tải về ngay trên điện thoại.

## Chuẩn bị
- Bạn cần có tài khoản GitHub (đăng nhập trên điện thoại).
- Bạn đã có thư mục `mobile/` (Flutter app) từ gói demo trước.
- Sửa `mobile/lib/services/api_client.dart` dòng `baseUrl` → URL backend của bạn (nếu chưa có, tạm để `http://10.0.2.2:8000`).

## Các bước (làm hoàn toàn trên điện thoại)
1. Vào GitHub → tạo **repository mới** (Public hoặc Private đều được), tên ví dụ `snp-chatbot`.
2. Ấn **Add file → Upload files**:
   - Tải **toàn bộ thư mục `mobile/`** của bạn lên repo (giữ đúng cấu trúc).
   - Tải thêm thư mục `/.github/workflows/` và file `flutter-android.yml` trong đó (file này chính là workflow).
3. Sau khi upload xong, quay lại trang repo → vào tab **Actions**.
4. Chọn workflow **“Build Android APK”** → bấm **Run workflow** (hoặc chờ tự chạy nếu bạn đã push vào `main`).
5. Khi chạy xong, vào **Actions → Job → Artifacts** và tải file **`SNP-Chatbot-APK`** (bên trong có `.apk`).
6. Mở `.apk` trên điện thoại để cài đặt (cho phép “Install unknown apps” nếu máy yêu cầu).

> Ghi chú:
> - Đây là **debug/release unsigned APK** dùng để thử nghiệm nội bộ. Khi phát hành chính thức, bạn cần **ký APK** bằng keystore công ty.
> - Nếu cần, có thể chỉnh workflow để build `--debug` cho nhanh, hoặc tạo **.aab** cho Play Store.

## Sửa URL Backend
Mở file: `mobile/lib/services/api_client.dart` → sửa:
```dart
static const baseUrl = 'http://<IP hoặc domain backend của bạn>:8000';
```
- Nếu dùng **Android emulator**: `http://10.0.2.2:8000`
- Nếu dùng **backend public**: dán hẳn domain, ví dụ `https://your-backend.example.com`

## Trợ giúp
Nếu bạn gửi cho mình **URL backend** (public), mình có thể sửa sẵn `baseUrl` và re-upload để bạn chỉ việc build và tải APK.
