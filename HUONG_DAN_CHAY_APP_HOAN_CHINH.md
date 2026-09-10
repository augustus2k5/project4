# HUONG DAN CHAY - HEALTHCARE BOOKING

## 1. Backend
Mở PowerShell:
```powershell
cd D:\download\project4-main\backend
npm install
npm start
```
`npm start` hiện chạy `src/complete/server_complete.js`.

Kiểm tra trình duyệt:
http://localhost:5000/api/health

Kết quả:
{"ok":true,"service":"healthcare-booking-api"}

## 2. Flutter patient app
Mở PowerShell khác:
```powershell
cd D:\download\project4-main\app
flutter pub get
flutter analyze
flutter run -t lib/main_booking.dart -d chrome
```

Web API dùng:
http://localhost:5000/api

Android Emulator dùng:
http://10.0.2.2:5000/api

## 3. Nếu chạy trên điện thoại thật
Thay baseUrl trong:
app/lib/booking_app/services/api_service.dart
bằng IP LAN của máy tính, ví dụ:
http://192.168.1.10:5000/api

Đồng thời cho phép Node.js qua Windows Firewall.

## 4. Dữ liệu thật
Trang chủ gọi:
GET /api/doctors
GET /api/specialties

Đặt lịch gọi:
POST /api/appointments

Lịch của bệnh nhân:
GET /api/appointments/patient/:patientId

Không có danh sách bác sĩ cố định trong Flutter.

## 5. File quan trọng
Trang chủ:
app/lib/booking_app/screens/home_page.dart

Chi tiết bác sĩ:
app/lib/booking_app/screens/doctor_detail_page.dart

Đặt lịch:
app/lib/booking_app/screens/booking_page.dart

Lịch hẹn:
app/lib/booking_app/screens/appointments_page.dart

API:
app/lib/booking_app/services/api_service.dart

Ứng dụng:
app/lib/main_booking.dart

## 6. Ghi chú
Thư mục app/flutter_application_1 là project Flutter cũ được giữ nguyên.
Parent analyzer đã loại trừ thư mục này để không làm nhiễu kết quả `flutter analyze`.
