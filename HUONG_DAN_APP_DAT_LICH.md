# HEALTHCARE BOOKING - BẢN BỔ SUNG

Bản này giữ nguyên các file cũ và bổ sung một bộ app đặt lịch hoàn chỉnh hơn.

## 1. Cấu trúc chính

- `app/lib/booking_app/`: app bệnh nhân mới.
- `app/lib/screens/home_page.dart`: file dễ tìm, export trang chủ mới.
- `app/lib/main_booking.dart`: entry point chạy app bệnh nhân mới.
- `admin/lib/complete/`: giao diện quản trị bổ sung.
- `admin/lib/main_complete.dart`: entry point admin mới.
- `backend/src/complete/server_complete.js`: API server bổ sung, tái sử dụng toàn bộ route cũ và thêm API cho admin/bệnh nhân.

## 2. Dữ liệu động

Trang chủ gọi `/api/doctors` và `/api/specialties`, không chứa danh sách bác sĩ cố định.

Luồng dữ liệu:
MongoDB -> Node/Express -> API -> Flutter.

Nếu thêm/sửa bác sĩ hoặc chuyên khoa trong database/API, trang chủ sẽ tải lại dữ liệu mới.

## 3. Chạy backend

Từ thư mục `backend`:

`node src/complete/server_complete.js`

Backend dùng `.env` hiện có. Mặc định cổng 5000.

## 4. Chạy app bệnh nhân

Từ `app`:

`flutter pub get`

`flutter run -t lib/main_booking.dart -d chrome`

Chrome dùng `http://localhost:5000/api`.
Android Emulator dùng `http://10.0.2.2:5000/api`.

## 5. Chạy admin

Từ `admin`:

`flutter pub get`

`flutter run -t lib/main_complete.dart -d chrome`

Đăng nhập bằng tài khoản có `role: ADMIN` và `status: ACTIVE` trong MongoDB.

## 6. Lưu ý dữ liệu bác sĩ cũ

Backend Flutter mới có bộ parser tương thích với cả document bác sĩ kiểu cũ có `name/specialty/rating/patients` và document kiểu mới dùng `userId/specialtyId/price/bio`.

Đặt lịch cần `doctorId` và `patientId` hợp lệ. Với dữ liệu bác sĩ cũ không có `userId`, trang chủ vẫn có thể hiển thị; nếu muốn tài khoản bác sĩ đăng nhập/quản lý lịch, hãy tạo User role DOCTOR rồi tạo Doctor profile tương ứng qua admin/API.
