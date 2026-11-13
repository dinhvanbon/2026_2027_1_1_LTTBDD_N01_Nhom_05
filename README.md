# 🎮 LIFE RPG

## Hệ thống quản lý nhiệm vụ trẻ em ứng dụng Gamification
### Môn học: Lập trình cho thiết bị di động (CSE702027-1-1-26(N01))
### Học kỳ I (2026 - 2027)
### Giảng viên hướng dẫn: Thầy Nguyễn Xuân Quế

---

# 👤 Sinh viên thực hiện

* **Họ và tên:** Đinh Văn Bốn
* **Mã sinh viên:** 22010067
* **Lớp:** CSE702027-1-1-26(N01)
* **Nhóm:** Nhóm 05

---
# 📚 Mục lục

* [1. Giới thiệu chung dự án](#1-giới-thiệu-dự-án)
* [2. Bài toán thực tế](#2-bài-toán-thực-tế)
* [3. Mục tiêu dự án](#3-mục-tiêu-dự-án)
* [4. Đối tượng sử dụng](#4-đối-tượng-sử-dụng)

  * [4.1 Phụ huynh](#phụ-huynh)
  * [4.2 Trẻ em](#trẻ-em)
* [5. Chức năng hệ thống](#5-chức-năng-hệ-thống)

  * [5.1 Xác thực người dùng](#51-xác-thực-người-dùng)

    * [Đăng ký](#đăng-ký)
    * [Đăng nhập](#đăng-nhập)
    * [Đăng xuất](#đăng-xuất)
  * [5.2 Quản lý trẻ em](#52-quản-lý-trẻ-em)
  * [5.3 Quản lý nhiệm vụ](#53-quản-lý-nhiệm-vụ)

    * [Tạo nhiệm vụ](#tạo-nhiệm-vụ)
    * [Chỉnh sửa nhiệm vụ](#chỉnh-sửa-nhiệm-vụ)
    * [Xóa nhiệm vụ](#xóa-nhiệm-vụ)
  * [5.4 Giao nhiệm vụ](#54-giao-nhiệm-vụ)
  * [5.5 Hoàn thành nhiệm vụ](#55-hoàn-thành-nhiệm-vụ)
  * [5.6 Xác nhận nhiệm vụ](#56-xác-nhận-nhiệm-vụ)
  * [5.7 Hệ thống Level](#57-hệ-thống-level)
  * [5.8 Hệ thống Achievement](#58-hệ-thống-achievement)
  * [5.9 Hệ thống Reward](#59-hệ-thống-reward)
  * [5.10 Activity Log](#510-activity-log)
* [6. Mô hình dữ liệu](#6-mô-hình-dữ-liệu)

  * [User](#user)
  * [Parent](#parent)
  * [Child](#child)
  * [Task](#task)
  * [Reward](#reward)
  * [Achievement](#achievement)
  * [ActivityLog](#activitylog)
  * [Sơ đồ Class Diagram](#sơ-đồ-class-diagram)
* [7. Sơ Đồ Kiến trúc hệ thống](#7-kiến-trúc-hệ-thống)
* [8. Công nghệ sử dụng](#8-công-nghệ-sử-dụng)

  * [Frontend](#frontend)
  * [Backend Services](#backend-services)
  * [State Management](#state-management)
  * [Development Tools](#development-tools)
* [9. Cấu trúc thư mục](#9-cấu-trúc-thư-mục)
* [10. Hướng dẫn cài đặt](#10-hướng-dẫn-cài-đặt)

  * [Clone dự án](#clone-dự-án)
  * [Cài package](#cài-package)
  * [Cấu hình Firebase](#cấu-hình-firebase)
  * [Chạy ứng dụng](#chạy-ứng-dụng)
  * [Chạy trên Web](#chạy-trên-web)
* [11. Kết quả đạt được](#11-kết-quả-đạt-được)
* [12. Hướng phát triển tương lai](#12-hướng-phát-triển-tương-lai)
* [13. Sinh viên thực hiện](#13-sinh-viên-thực-hiện)

  * [Demo](#video-demo)





# 1. Giới thiệu dự án

Life RPG là một ứng dụng hỗ trợ phụ huynh quản lý nhiệm vụ, thói quen và quá trình phát triển của trẻ em thông qua cơ chế Gamification (trò chơi hóa).

Thay vì yêu cầu trẻ thực hiện các công việc hàng ngày theo phương pháp truyền thống, hệ thống chuyển đổi các nhiệm vụ thành những thử thách mang tính trò chơi. Khi hoàn thành nhiệm vụ, trẻ sẽ nhận được điểm kinh nghiệm (EXP), tăng cấp độ (Level), mở khóa thành tựu (Achievement) và nhận các phần thưởng (Reward) do phụ huynh thiết lập.

Dự án được xây dựng nhằm tạo động lực cho trẻ em hình thành thói quen tích cực, nâng cao tính tự giác và giúp phụ huynh theo dõi quá trình phát triển của con một cách trực quan, hiệu quả.

---

# 2. Bài toán thực tế

Trong thực tế, nhiều phụ huynh gặp khó khăn trong việc:

* Quản lý công việc hàng ngày của con.
* Theo dõi quá trình hoàn thành nhiệm vụ.
* Tạo động lực cho trẻ học tập và sinh hoạt tích cực.
* Hình thành thói quen tốt cho trẻ trong thời gian dài.
* Kiểm soát thời gian sử dụng thiết bị điện tử.

Trong khi đó, trẻ em thường có xu hướng thích các trò chơi điện tử vì có hệ thống điểm thưởng, cấp độ và thành tích.

Life RPG tận dụng chính cơ chế đó để biến các hoạt động đời thường thành một trò chơi phát triển bản thân.

---

# 3. Mục tiêu dự án

Mục tiêu chính của hệ thống:

* Tăng tính tự giác cho trẻ em.
* Khuyến khích hoàn thành nhiệm vụ hàng ngày.
* Hình thành các thói quen tốt.
* Hỗ trợ phụ huynh quản lý con hiệu quả hơn.
* Xây dựng môi trường giáo dục tích cực.
* Áp dụng mô hình Gamification trong quản lý gia đình.

---

# 4. Đối tượng sử dụng

## Phụ huynh

* Tạo tài khoản.
* Quản lý thông tin trẻ em.
* Giao nhiệm vụ.
* Thiết lập phần thưởng.
* Theo dõi tiến độ hoàn thành.
* Đánh giá kết quả thực hiện.

## Trẻ em

* Thực hiện nhiệm vụ.
* Nhận điểm thưởng.
* Tăng cấp độ.
* Mở khóa thành tựu.
* Theo dõi quá trình phát triển cá nhân.

---

# 5. Chức năng hệ thống

## 5.1 Xác thực người dùng

### Đăng ký

* Nhập Email.
* Nhập mật khẩu.
* Phân quyền theo vai trò.
* Xác thực tài khoản.

### Đăng nhập
* Đăng nhập bằng Email và Password.

### Đăng xuất

* Hủy phiên làm việc.
* Quay về màn hình đăng nhập.

---

## 5.2 Quản lý trẻ em

Phụ huynh có thể:

* Thêm trẻ em mới.
* Chỉnh sửa thông tin.
* Xóa hồ sơ trẻ em.
* Theo dõi Level và EXP.

Thông tin lưu trữ:

* Họ tên
* Tuổi
* Ảnh đại diện
* Level
* Tổng EXP
* Ngày tham gia

---

## 5.3 Quản lý nhiệm vụ

### Tạo nhiệm vụ

Thông tin nhiệm vụ:

* Tên nhiệm vụ
* Mô tả
* Độ khó
* EXP nhận được
* Hạn hoàn thành

### Chỉnh sửa nhiệm vụ

* Cập nhật nội dung.
* Điều chỉnh điểm thưởng.

### Xóa nhiệm vụ

* Xóa khỏi danh sách.

---

## 5.4 Giao nhiệm vụ

Phụ huynh lựa chọn:

* Trẻ em nhận nhiệm vụ.
* Ngày bắt đầu.
* Ngày kết thúc.

Sau khi giao, nhiệm vụ sẽ xuất hiện trên tài khoản của trẻ.

---

## 5.5 Hoàn thành nhiệm vụ

Trẻ em:

* Chọn nhiệm vụ.
* Đánh dấu hoàn thành.
* Gửi yêu cầu xác nhận.

Trạng thái:

* Pending
* Submitted
* Approved
* Rejected

---

## 5.6 Xác nhận nhiệm vụ

Phụ huynh:

* Xem yêu cầu hoàn thành.
* Đồng ý hoặc từ chối.

Nếu đồng ý:

* Cộng EXP.
* Cập nhật Level.
* Ghi nhận lịch sử.

---

## 5.7 Hệ thống Level

Mỗi trẻ có:

* Level hiện tại.
* Tổng EXP.
* EXP cần để lên cấp.

Ví dụ:

Level 1 → 100 EXP

Level 2 → 250 EXP

Level 3 → 500 EXP

Level 4 → 1000 EXP

...

---

## 5.8 Hệ thống Achievement

Các thành tựu tiêu biểu:

* Hoàn thành nhiệm vụ đầu tiên.
* Chuỗi 7 ngày liên tiếp.
* Đạt Level 5.
* Hoàn thành 100 nhiệm vụ.
* Đạt 1000 EXP.

---

## 5.9 Hệ thống Reward

Phụ huynh tạo:

* Kẹo
* Đồ chơi
* Chuyến đi chơi
* Thời gian xem TV
* Tiền thưởng

Trẻ sử dụng điểm tích lũy để đổi phần thưởng.

---

## 5.10 Activity Log

Ghi nhận toàn bộ hoạt động:

* Đăng nhập.
* Nhận nhiệm vụ.
* Hoàn thành nhiệm vụ.
* Nhận EXP.
* Lên Level.
* Đổi thưởng.

---

# 6. Mô hình dữ liệu

## User

* userId
* email
* password
* role

## Parent

* parentId
* fullName
* avatar

## Child

* childId
* fullName
* age
* level
* totalExp

## Task

* taskId
* title
* description
* expReward
* deadline
* status

## Reward

* rewardId
* rewardName
* pointRequired

## Achievement

* achievementId
* title
* description

## ActivityLog

* logId
* action
* createdAt

## Sơ đồ Class Diagram
![class diagram](<class diagram.png>)

---

# 7. Kiến trúc hệ thống

![sdkt](sodokt.png)

---

# 8. Công nghệ sử dụng

## Frontend

* Flutter
* Dart
* Material Design

## Backend Services

* Firebase Authentication
* Cloud Firestore
* Firebase Cloud Functions

## State Management

* Provider

## Development Tools

* Android Studio
* VS Code
* Git
* GitHub

---

# 9. Cấu trúc thư mục

```text
lib/
├── core/
│   ├── constants/
│   ├── themes/
│   └── utils/
│
├── models/
│   ├── user.dart
│   ├── child.dart
│   ├── task.dart
│   ├── reward.dart
│   └── achievement.dart
│
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── notification_service.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── child_provider.dart
│   └── task_provider.dart
│
├── screens/
│   ├── auth/
│   ├── parent/
│   ├── child/
│   └── shared/
│
├── widgets/
│
├── routes/
│
├── app.dart
│
└── main.dart
```

---

# 10. Hướng dẫn cài đặt

## Clone dự án

```bash
git clone https://github.com/dinhvanbon/2026_2027_1_1_LTTBDD_N01_Nhom_05.git
```

## Cài package

```bash
flutter pub get
```

## Cấu hình Firebase

Tải và thêm:

* google-services.json
* GoogleService-Info.plist

Khởi tạo:

```bash
flutterfire configure
```

## Chạy ứng dụng

```bash
flutter run
```

## Chạy trên Web

```bash
Parent chạy
flutter run -d web-server --web-port 8081
```
children
flutter run -d web-server --web-port 8082

---

# 11. Kết quả đạt được

* Xây dựng hệ thống quản lý nhiệm vụ trẻ em hoàn chỉnh.
* Áp dụng thành công mô hình Gamification.
* Quản lý EXP, Level và Achievement.
* Đồng bộ dữ liệu thời gian thực với Firebase.
* Giao diện thân thiện với người dùng.

---

# 12. Hướng phát triển tương lai

* Thông báo Push Notification.
* AI gợi ý nhiệm vụ.
* Bảng xếp hạng gia đình.
* Nhiệm vụ theo tuần/tháng.
* Đồng bộ đa thiết bị.
* Hỗ trợ nhiều phụ huynh trên cùng một tài khoản trẻ em.

---

# 13. Sinh viên thực hiện

* **Họ và tên:** Đinh Văn Bốn
* **Mã sinh viên:** 22010067
* **Lớp:** CSE702027-1-1-26(N01)
* **Nhóm:** Nhóm 05
* **Giảng viên hướng dẫn:** Thầy Nguyễn Xuân Quế
