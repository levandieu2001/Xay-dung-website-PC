# PCM Computer — Hệ Thống Website Bán Máy Tính và Linh Kiện (ASP.NET Web Forms + SQL Server)

Dự án ASP.NET Web Forms (C# / .NET Framework 4.8) kết nối Cơ sở dữ liệu **SQL Server (`.\SQLEXPRESS` - `PCMComputerDB`)**, được xây dựng đầy đủ theo tài liệu đặc tả **`Website-Laptop-Linh-Kien.docx`** (16 Yêu cầu chức năng `FR01` – `FR16`, 16 ca sử dụng `UC01` – `UC16`, 8 Yêu cầu phi chức năng `NFR01` – `NFR08`, Biểu đồ hoạt động và Biểu đồ tuần tự).

Xem nhật ký chi tiết quá trình xây dựng và kiểm thử tại: **[`QUA_TRINH_THUC_HIEN.md`](file:///d:/WEB/QUA_TRINH_THUC_HIEN.md)**.

---

## 1. Tài khoản mẫu để đăng nhập & kiểm thử các phân hệ

| Phân hệ / Vai trò | Tên đăng nhập | Mật khẩu | Trang điều hướng | Ghi chú |
| :--- | :--- | :--- | :--- | :--- |
| **Quản trị viên** | `admin` | `123456` | `QuanTri.aspx` | Toàn quyền quản lý hệ thống & thống kê doanh thu (`UC09` – `UC14`) |
| **nhân viên** | `staff` | `123456` | `NhanVien.aspx` | Xử lý đơn hàng (`UC11`) & kiểm tra tồn kho, cập nhật mô tả sản phẩm (`UC09`) |
| **Khách hàng** | `khachhang` | `123456` | `TrangChu.aspx` | Mua sắm, giỏ hàng, áp mã khuyến mãi, đặt hàng COD, theo dõi & hủy đơn |
| **Tài khoản bị khóa** | `userlocked` | `123456` | *(Từ chối)* | Dùng để kiểm thử luồng ngoại lệ tài khoản bị khóa (`UC02`) |

### Mã giảm giá / Khuyến mãi mẫu (`UC13`, `UC16`)
- **`PCM500K`**: Giảm trực tiếp **500.000 đ** cho đơn hàng từ 10.000.000 đ.
- **`GIAM5`**: Giảm **5%** (tối đa 1.500.000 đ) cho đơn hàng từ 5.000.000 đ.
- **`NEWUSER`**: Giảm trực tiếp **200.000 đ** cho đơn hàng từ 1.000.000 đ.
- **`HETHAN`**: Mã đã hết hạn (dùng để kiểm thử luồng ngoại lệ `UC16`).

---

## 2. Khởi tạo Cơ sở dữ liệu SQL Server

- Cài mới bằng [csdl_PCMComputer.sql](csdl_PCMComputer.sql) trong SQL Server Management Studio. Tệp này sẽ xóa cơ sở dữ liệu `PCMComputerDB` hiện có trước khi tạo lại.
- Nếu đã có dữ liệu từ phiên bản dùng tên bảng tiếng Anh, chạy [csdl_doi_ten_bang.sql](csdl_doi_ten_bang.sql) để đổi tên bảng và giữ dữ liệu.

---

## 3. Chạy ứng dụng bằng IIS Express

Trong PowerShell:

```powershell
& 'C:\Program Files\IIS Express\iisexpress.exe' /path:D:\WEB\apps /port:5088 /systray:false
```

Sau đó mở trình duyệt tại:
- Trang chủ bán hàng: `http://localhost:5088/TrangChu.aspx`
- Trang danh sách & lọc sản phẩm: `http://localhost:5088/SanPham.aspx`
- Trang đăng nhập (có nút chọn nhanh tài khoản mẫu): `http://localhost:5088/DangNhap.aspx`
- Trang nghiệp vụ nhân viên: `http://localhost:5088/NhanVien.aspx`
- Trang quản trị hệ thống: `http://localhost:5088/QuanTri.aspx`
