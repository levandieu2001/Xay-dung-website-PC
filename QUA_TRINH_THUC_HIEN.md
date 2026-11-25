# NHẬT KÝ QUÁ TRÌNH THỰC HIỆN DỰ ÁN: WEBSITE BÁN MÁY TÍNH VÀ LINH KIỆN (PCM COMPUTER)

Tài liệu này ghi nhận chi tiết toàn bộ quá trình phân tích, thiết kế, xây dựng và kiểm thử hệ thống **PCM Computer** dựa trên tài liệu đặc tả [`Website-Laptop-Linh-Kien.docx`](file:///d:/WEB/Website-Laptop-Linh-Kien.docx).

---

## Tổng quan yêu cầu từ tài liệu đặc tả `Website-Laptop-Linh-Kien.docx`

- **3 Phân hệ & 3 Tác nhân (Actors)**:
  1. **Website bán hàng — Khách hàng**: Xem danh mục (`UC03`), tìm kiếm & lọc theo hãng/mức giá (`UC04`), xem chi tiết thông số kỹ thuật (`UC05`), quản lý giỏ hàng (`UC06`), áp dụng mã khuyến mãi (`UC16`), đặt hàng trực tuyến COD (`UC07`), theo dõi & hủy đơn hàng (`UC08`), đăng ký (`UC01`), đăng nhập (`UC02`), đăng xuất & quản lý hồ sơ (`UC15`).
  2. **Trang nghiệp vụ bán hàng — nhân viên**: Tiếp nhận & xử lý đơn hàng (`UC11`), lọc đơn theo trạng thái, cập nhật tiến độ giao hàng (tự động hoàn trả số lượng tồn kho khi đơn bị hủy), kiểm tra số lượng tồn kho và cập nhật thông tin cơ bản của sản phẩm (`UC09 - Staff`).
  3. **Trang quản trị hệ thống — Quản trị viên**: Quản lý danh mục (`UC10` - chặn xóa nếu còn sản phẩm trực thuộc), quản lý sản phẩm toàn quyền (`UC09 - Admin` - chuyển sang `'Ngừng kinh doanh'` thay vì xóa cứng nếu sản phẩm đã phát sinh trong đơn hàng), quản lý đơn hàng (`UC11`), quản lý tài khoản & phân quyền (`UC12` - chặn Admin tự khóa/hạ quyền chính mình), quản lý khuyến mãi và mã giảm giá (`UC13` - kiểm tra ngày kết thúc >= ngày bắt đầu và mức giảm hợp lệ), thống kê doanh thu theo thời gian từ đơn `'Đã giao'` & cảnh báo tồn kho (`UC14`).
- **Đầy đủ 16 Yêu cầu chức năng (`FR01` – `FR16`) & 16 ca sử dụng (`UC01` – `UC16`)**.
- **Đầy đủ 8 Yêu cầu phi chức năng (`NFR01` – `NFR08`)**: Băm mật khẩu bằng SHA-256, phân quyền chặt chẽ, toàn vẹn dữ liệu khóa chính/khóa ngoại & không cho đặt vượt tồn kho, giao diện trực quan & tương thích trình duyệt.
- **Tuân thủ Biểu đồ hoạt động (Mục 3.6) & Biểu đồ tuần tự Đặt hàng `UC07` (Mục 3.7)**: Kiến trúc lớp `:CheckoutView` -> `:OrderController` -> `:OrderService` -> `:Database`.

---

## Phần 1: Thiết kế & Khởi tạo Cơ sở dữ liệu SQL Server (`PCMComputerDB`) — [ĐÃ HOÀN THÀNH & KIỂM THỬ ĐẠT]

### 1.1. Công việc đã thực hiện
- Kết nối trực tiếp tới SQL Server Express (`.\SQLEXPRESS`) đang chạy trên máy.
- Xây dựng kịch bản SQL [`csdl_PCMComputer.sql`](file:///d:/WEB/csdl_PCMComputer.sql) khởi tạo CSDL **`PCMComputerDB`** gồm 8 bảng chuẩn hóa với đầy đủ khóa chính (`PRIMARY KEY`), khóa ngoại (`FOREIGN KEY`), và ràng buộc kiểm tra dữ liệu (`CHECK CONSTRAINT`):
  1. `dbo.TAIKHOAN`: Lưu tài khoản người dùng với mật khẩu băm SHA-256 (`PasswordHash`), phân quyền `Role` (`Admin`, `Staff`, `Customer`), trạng thái khóa `IsLocked`.
  2. `dbo.DANHMUC`: Lưu 14 danh mục máy tính, laptop, PC gaming, workstation, linh kiện, màn hình, phụ kiện khớp với hệ thống menu của website.
  3. `dbo.SANPHAM`: Lưu 27 sản phẩm máy tính và linh kiện có đầy đủ mã SP (`ProductCode`), hãng (`Brand`), giá niêm yết (`OldPrice`), giá bán (`Price`), tồn kho (`StockQuantity >= 0`), bảo hành (`WarrantyMonths`), bảng thông số kỹ thuật (`Specifications`), trạng thái (`Đang kinh doanh` / `Ngừng kinh doanh`).
  4. `dbo.KHUYENMAI`: Lưu chương trình khuyến mãi & mã giảm giá (`VoucherCode`), loại giảm (`PERCENT` hoặc `AMOUNT`), đơn tối thiểu (`MinOrderAmount`), giới hạn lượt dùng (`UsageLimit`, `UsedCount`), ngày bắt đầu/kết thúc (`EndDate >= StartDate`).
  5. `dbo.DONHANG`: Lưu đơn đặt hàng trực tuyến với mã đơn (`OrderCode`), thông tin người nhận, phương thức thanh toán (`COD`), mã voucher, tiền giảm, tổng thanh toán và trạng thái (`Chờ xác nhận`, `Đang chờ vận chuyển`, `Đang vận chuyển`, `Đang giao`, `Đã giao`, `Đã hủy`).
  6. `dbo.CHITIETDONHANG`: Lưu chi tiết từng linh kiện/máy tính trong đơn hàng.
  7. `dbo.LICHSUTRANGTHAIDONHANG`: Lưu vết lịch sử cập nhật trạng thái đơn hàng của Khách hàng / Nhân viên / Quản trị viên.
  8. `dbo.LIENHE`: Lưu thông tin liên hệ & yêu cầu hỗ trợ từ khách hàng.

### 1.2. Kết quả kiểm thử CSDL trên `.\SQLEXPRESS`
- Thực thi toàn bộ các batch SQL thành công (Exit code `0`, không có lỗi cú pháp hay ràng buộc).
- Dữ liệu mẫu khởi tạo thành công:
  - `Users`: 6 tài khoản (`admin/123456`, `staff/123456`, `staff2/123456`, `khachhang/123456`, `minhanh/123456`, `userlocked/123456` - tài khoản bị khóa để test ngoại lệ `UC02`).
  - `Categories`: 14 danh mục.
  - `Products`: 27 sản phẩm máy tính & linh kiện kèm thông số kỹ thuật chi tiết.
  - `Promotions`: 4 mã khuyến mãi (`PCM500K`, `GIAM5`, `NEWUSER`, và mã `HETHAN` để test ngoại lệ `UC16`).
  - `Orders`: 4 đơn hàng mẫu ở các trạng thái khác nhau (`Đã giao`, `Đang giao`, `Chờ xác nhận`).

---

## Phần 2: Xây dựng tầng Backend / Business Logic (`App_Code`) & Cấu hình `Web.config` — [ĐÃ HOÀN THÀNH & KIỂM THỬ ĐẠT]

### 2.1. Công việc đã thực hiện
- Cập nhật [`apps/Web.config`](file:///d:/WEB/apps/Web.config): Cấu hình chuỗi kết nối `PCMComputerDB` tới `Server=.\SQLEXPRESS;Database=PCMComputerDB;Integrated Security=True`, thiết lập UTF-8 (`vi-VN`), `SessionState` và `ClientIDMode="Static"`.
- Xây dựng hệ thống lớp nghiệp vụ trong `apps/App_Code`:
  - [`MoHinhDuLieu.cs`](file:///d:/WEB/apps/App_Code/MoHinhDuLieu.cs): Định nghĩa đầy đủ các thực thể và DTO (`UserInfo`, `CategoryInfo`, `ProductInfo`, `CartItem`, `PromotionInfo`, `VoucherCheckResult`, `OrderDTO`, `OrderResult`, `OrderInfo`, `OrderDetailInfo`, `OrderHistoryInfo`, `RevenueStats`).
  - [`BaoMatVaPhien.cs`](file:///d:/WEB/apps/App_Code/BaoMatVaPhien.cs): Băm mật khẩu bằng SHA-256 (`NFR03`), quản lý phiên đăng nhập & phân quyền (`Admin`, `Staff`, `Customer`), quản lý giỏ hàng trong `Session` có kiểm tra số lượng tồn kho thực tế (`UC06`, `NFR04`).
  - [`TruyCapCoSoDuLieu.cs`](file:///d:/WEB/apps/App_Code/TruyCapCoSoDuLieu.cs): Tầng truy xuất CSDL SQL Server cho toàn bộ 16 ca sử dụng, cài đặt đầy đủ các luồng ngoại lệ.
  - [`XuLyDonHang.cs`](file:///d:/WEB/apps/App_Code/XuLyDonHang.cs) & [`DieuKhienDatHang.cs`](file:///d:/WEB/apps/App_Code/DieuKhienDatHang.cs): Cài đặt chính xác theo **Biểu đồ tuần tự Đặt hàng trực tuyến (`UC07` - Mục 3.7)** với các phương thức `requestCheckout()`, `getUserDefaultInfo()`, `selectUserById()`, `submitOrder()`, `processCreateOrder()`, `checkStockAndVoucher()`, `insertOrder()`, `insertOrderDetails()`, `updateProductStock()`, `clearCart()` trong Transaction SQL.
  - [`HoTroHienThi.cs`](file:///d:/WEB/apps/App_Code/HoTroHienThi.cs): Hiển thị thẻ sản phẩm, thẻ deal giá sốc, bảng thông số kỹ thuật và huy hiệu trạng thái đơn hàng thống nhất.
- Nâng cấp [`apps/BoCucChung.Master`](file:///d:/WEB/apps/BoCucChung.Master) & [`apps/chuc-nang-chung.js`](file:///d:/WEB/apps/chuc-nang-chung.js): Tích hợp thanh tìm kiếm toàn cục, hiển thị thông tin tài khoản theo phân quyền (`Admin`, `Staff`, `Customer`), số lượng giỏ hàng theo thời gian thực.

---

## Phần 3: Xây dựng Phân hệ Website Bán Hàng cho Khách hàng (`UC01` – `UC08`, `UC15`, `UC16`) — [ĐÃ HOÀN THÀNH & KIỂM THỬ ĐẠT]

### 3.1. Các trang đã xây dựng và nâng cấp
- [`apps/TrangChu.aspx`](file:///d:/WEB/apps/TrangChu.aspx): Trang chủ hiển thị danh mục bên trái từ CSDL, khu vực Flash Sale "SALE SẬP SÀN DEAL NGẬP TRÀN" và "TOP SẢN PHẨM BÁN CHẠY" lấy dữ liệu động từ SQL Server, hỗ trợ lọc nhanh theo tab danh mục, thêm vào giỏ hàng hoặc đặt mua ngay.
- [`apps/HienThiDanhMuc.ascx`](file:///d:/WEB/apps/HienThiDanhMuc.ascx), [`apps/SanPham.aspx`](file:///d:/WEB/apps/SanPham.aspx) và toàn bộ 14 trang danh mục ([`MayTinhXachTayChoiGame.aspx`](file:///d:/WEB/apps/MayTinhXachTayChoiGame.aspx), [`MayTinhXachTay.aspx`](file:///d:/WEB/apps/MayTinhXachTay.aspx), [`MayTinhChoiGame.aspx`](file:///d:/WEB/apps/MayTinhChoiGame.aspx), [`MayTram.aspx`](file:///d:/WEB/apps/MayTram.aspx), [`MayTinhVanPhong.aspx`](file:///d:/WEB/apps/MayTinhVanPhong.aspx), [`LinhKien.aspx`](file:///d:/WEB/apps/LinhKien.aspx), [`ManHinhMayIn.aspx`](file:///d:/WEB/apps/ManHinhMayIn.aspx), [`BanPhimChuot.aspx`](file:///d:/WEB/apps/BanPhimChuot.aspx), [`PhuKien.aspx`](file:///d:/WEB/apps/PhuKien.aspx), [`AmThanhHinhAnh.aspx`](file:///d:/WEB/apps/AmThanhHinhAnh.aspx), [`TanNhiet.aspx`](file:///d:/WEB/apps/TanNhiet.aspx), [`ThietBiMangCamera.aspx`](file:///d:/WEB/apps/ThietBiMangCamera.aspx), [`DienThoai.aspx`](file:///d:/WEB/apps/DienThoai.aspx), [`DongHoThongMinh.aspx`](file:///d:/WEB/apps/DongHoThongMinh.aspx)):
  - Xem danh sách sản phẩm theo danh mục có phân trang và sắp xếp (`UC03`).
  - Tìm kiếm theo từ khóa tên/mã/cấu hình, lọc theo Hãng sản xuất, lọc theo Khoảng giá (`UC04`).
  - Xử lý ngoại lệ `UC03` (hiển thị `'Chưa có sản phẩm trong danh mục này'`) và ngoại lệ `UC04` (hiển thị `'Không tìm thấy sản phẩm phù hợp'` kèm danh sách **Gợi ý sản phẩm nổi bật**).
- [`apps/ChiTietSanPham.aspx`](file:///d:/WEB/apps/ChiTietSanPham.aspx): Xem chi tiết sản phẩm (`UC05`) gồm hình ảnh, mã SP, hãng, giá niêm yết, giá khuyến mãi, thời hạn bảo hành, số lượng tồn kho, bảng thông số kỹ thuật chi tiết, mô tả sản phẩm và sản phẩm cùng danh mục. Nếu tồn kho = 0 thì hiển thị `'Tạm hết hàng'` và khóa nút thêm vào giỏ hàng.
- [`apps/GioHang.aspx`](file:///d:/WEB/apps/GioHang.aspx): Quản lý giỏ hàng (`UC06`), hiển thị số lượng tồn kho ngay tại từng sản phẩm, tăng/giảm số lượng có kiểm tra giới hạn tồn kho, xóa sản phẩm, tự động tính lại thành tiền từng dòng và tổng tiền giỏ hàng.
- [`apps/ThanhToan.aspx`](file:///d:/WEB/apps/ThanhToan.aspx): Đặt hàng trực tuyến (`UC07`) và Áp dụng mã khuyến mãi (`UC16`). Bắt buộc đăng nhập (`«include» UC02`), tự động điền thông tin người nhận từ hồ sơ, kiểm tra tính hợp lệ mã giảm giá (`PCM500K`, `GIAM5`, `NEWUSER`, `HETHAN`), thực thi tạo đơn hàng qua `OrderController` -> `OrderService` với Transaction trừ tồn kho.
- [`apps/DangNhap.aspx`](file:///d:/WEB/apps/DangNhap.aspx) & [`apps/DangKy.aspx`](file:///d:/WEB/apps/DangKy.aspx): Đăng nhập (`UC02` - có nút chọn nhanh tài khoản mẫu quản trị viên, nhân viên, khách hàng và tài khoản bị khóa) và Đăng ký tài khoản mới (`UC01`).
- [`apps/HoSo.aspx`](file:///d:/WEB/apps/HoSo.aspx) & [`apps/DangXuat.aspx`](file:///d:/WEB/apps/DangXuat.aspx): Cập nhật thông tin cá nhân, đổi mật khẩu và đăng xuất an toàn (`UC15`).
- [`apps/DonHangCuaToi.aspx`](file:///d:/WEB/apps/DonHangCuaToi.aspx): Theo dõi lịch sử đơn hàng, xem chi tiết sản phẩm & tiến độ đơn hàng, hủy đơn khi đang ở trạng thái `'Chờ xác nhận'` / `'Đang chờ vận chuyển'` kèm tự động hoàn trả số lượng tồn kho (`UC08`).
- [`apps/GioiThieu.aspx`](file:///d:/WEB/apps/GioiThieu.aspx) & [`apps/LienHe.aspx`](file:///d:/WEB/apps/LienHe.aspx): Đồng bộ thanh điều hướng động từ `BoCucChung.Master` và lưu yêu cầu liên hệ vào bảng `dbo.LIENHE`.

---

## Phần 4: Xây dựng Phân hệ Nghiệp vụ Bán Hàng cho Nhân viên (`NhanVien.aspx` — `UC09`, `UC11`) — [ĐÃ HOÀN THÀNH & KIỂM THỬ ĐẠT]

- Xây dựng trang [`apps/NhanVien.aspx`](file:///d:/WEB/apps/NhanVien.aspx) với kiểm tra phân quyền `Staff` / `Admin`:
  1. **Thẻ Tiếp nhận & Xử lý đơn hàng (`UC11`)**: Lọc đơn hàng theo trạng thái (`Chờ xác nhận`, `Đang chờ vận chuyển`, `Đang vận chuyển`, `Đang giao`, `Đã giao`, `Đã hủy`), xem chi tiết linh kiện và thông tin khách hàng, xác nhận và cập nhật trạng thái đơn hàng. Khi đơn bị hủy (chỉ cho phép hủy khi ở trạng thái chờ xác nhận / đang chờ vận chuyển), tự động hoàn trả số lượng tồn kho của các sản phẩm trong đơn.
  2. **Thẻ Kiểm tra tồn kho & Cập nhật sản phẩm (`UC09 - Staff`)**: Đối chiếu tồn kho thực tế, cảnh báo mã sắp hết hàng, cập nhật giá bán, số lượng tồn kho, thời hạn bảo hành, bảng thông số kỹ thuật và mô tả sản phẩm (không có quyền xóa sản phẩm đúng theo phân quyền Staff).

---

## Phần 5: Xây dựng Phân hệ Quản trị Hệ thống cho Quản trị viên (`QuanTri.aspx` — `UC09` đến `UC14`) — [ĐÃ HOÀN THÀNH & KIỂM THỬ ĐẠT]

- Xây dựng trang [`apps/QuanTri.aspx`](file:///d:/WEB/apps/QuanTri.aspx) với kiểm tra phân quyền chỉ `Admin` mới được truy cập:
  1. **Thẻ Thống kê doanh thu (`UC14`)**: Lọc theo Toàn thời gian, Hôm nay, Tháng này, Quý này hoặc Khoảng ngày tùy chọn (`Từ ngày` - `Đến ngày`). Tính tổng doanh thu thực tế từ các đơn `'Đã giao'` (nếu chưa có đơn hoàn thành hiển thị `0 đ`), thống kê số lượng đơn theo trạng thái, biểu đồ Top máy tính & linh kiện bán chạy nhất và bảng Cảnh báo tồn kho thấp (`<= 5 SP`).
  2. **Thẻ Quản lý sản phẩm (`UC09 - Admin`)**: Thêm sản phẩm mới, chỉnh sửa toàn bộ thông tin/cấu hình/hình ảnh/tồn kho, xóa sản phẩm. Khi xóa sản phẩm đã từng phát sinh trong hóa đơn bán hàng (`dbo.CHITIETDONHANG`), hệ thống tự động cảnh báo và chuyển sang trạng thái `'Ngừng kinh doanh'` thay vì xóa cứng để bảo toàn lịch sử đơn hàng.
  3. **Thẻ Quản lý danh mục (`UC10`)**: Thêm, sửa, xóa danh mục máy tính & linh kiện. Kiểm tra trùng tên danh mục; ngăn thao tác xóa và hiển thị thông báo nếu danh mục đang chứa sản phẩm trực thuộc.
  4. **Thẻ Quản lý đơn hàng (`UC11`)**: Toàn quyền kiểm soát và cập nhật trạng thái đơn hàng.
  5. **Thẻ Quản lý tài khoản & Phân quyền (`UC12`)**: Tạo tài khoản nhân viên mới, cập nhật vai trò (`Admin`, `Staff`, `Customer`), khóa/mở khóa tài khoản. Ngăn không cho Quản trị viên tự khóa hoặc tự hạ quyền chính tài khoản Admin đang đăng nhập.
  6. **Thẻ Quản lý khuyến mãi (`UC13`)**: Thêm mới, chỉnh sửa chương trình khuyến mãi / mã giảm giá (`PERCENT` hoặc `AMOUNT`), kiểm tra ngày kết thúc >= ngày bắt đầu và mức giảm hợp lệ (`0 < % <= 100`).

---

## Phần 6: Kiểm thử Biên dịch (`aspnet_compiler.exe`) & Kiểm thử Trực tiếp trên Trình duyệt — [ĐÃ BIÊN DỊCH PASS 100%]

- Chạy công cụ biên dịch toàn bộ ứng dụng ASP.NET Web Forms (`aspnet_compiler.exe -v / -p "d:\WEB\apps" -errorstack`):
  - **Kết quả**: `Command exited with code 0` — Toàn bộ các lớp C# trong `App_Code`, `BoCucChung.Master`, `HienThiDanhMuc.ascx` và tất cả 25 trang `.aspx` biên dịch thành công 100%, không có bất kỳ lỗi biên dịch nào.

### 6.1. Kết quả kiểm thử End-to-End trên Trình duyệt (`http://localhost:5088/`)
1. **Trang chủ [`TrangChu.aspx`](file:///d:/WEB/apps/TrangChu.aspx) (`HTTP 200`)**:
   - Hiển thị đầy đủ danh mục máy tính & linh kiện bên trái từ SQL Server.
   - Khu vực **SALE SẬP SÀN DEAL NGẬP TRÀN** và **TOP SẢN PHẨM BÁN CHẠY** tải dữ liệu thực tế từ bảng `dbo.SANPHAM` (mã SP, hãng, giá niêm yết, giá khuyến mãi, % giảm, bảo hành, tồn kho).
2. **Trang chi tiết sản phẩm [`ChiTietSanPham.aspx`](file:///d:/WEB/apps/ChiTietSanPham.aspx) (`HTTP 200`)**:
   - Kiểm tra sản phẩm `Laptop Gigabyte AORUS 16X 9KG-43VNC54SH` (`NBGI0099`): Hiển thị giá `31.990.000 đ`, bảo hành `24 tháng chính hãng`, tồn kho `Còn hàng (8 sản phẩm)`, bảng thông số kỹ thuật chi tiết 8 dòng (`CPU`, `VGA`, `RAM`, `Ổ cứng`, `Màn hình`, `Pin`, `Trọng lượng`, `HĐH`).
3. **Trang danh sách & Tìm kiếm sản phẩm [`SanPham.aspx`](file:///d:/WEB/apps/SanPham.aspx) (`HTTP 200`)**:
   - Hiển thị toàn bộ 27 sản phẩm.
   - Tìm kiếm từ khóa `'RTX 4060'` trả về chính xác `6 sản phẩm`.
   - Lọc theo danh mục `'Linh Kiện Máy Tính'` trả về chính xác `4 sản phẩm`.
4. **Trang Đăng nhập [`DangNhap.aspx`](file:///d:/WEB/apps/DangNhap.aspx) & Trang Quản trị viên [`QuanTri.aspx`](file:///d:/WEB/apps/QuanTri.aspx) (`HTTP 200`)**:
   - Đăng nhập tài khoản `admin / 123456` điều hướng chính xác vào `QuanTri.aspx`.
   - Kiểm tra toàn bộ 6 Thẻ quản trị đều hoạt động mượt mà (`HTTP 200`):
     - **Thẻ 1 — Thống kê doanh thu (`UC14`)**: Doanh thu thực tế từ đơn `'Đã giao'` đạt `56.389.000 đ` (2 đơn hoàn thành), tổng `4 đơn`, cảnh báo tồn kho thấp `6 mã SP`, biểu đồ Top sản phẩm bán chạy.
     - **Thẻ 2 — Quản lý sản phẩm (`UC09`)**: Hiển thị 27 sản phẩm kèm biểu mẫu Thêm/Sửa/Xóa (có kiểm tra chuyển sang `'Ngừng kinh doanh'` nếu sản phẩm đã phát sinh trong đơn hàng).
     - **Thẻ 3 — Quản lý danh mục (`UC10`)**: Hiển thị 14 danh mục kèm số lượng sản phẩm và kiểm tra chặn xóa danh mục đang chứa sản phẩm.
     - **Thẻ 4 — Quản lý đơn hàng (`UC11`)**: Hiển thị 4 đơn hàng (`DH20261101` – `DH20261104`) kèm bộ lọc trạng thái.
     - **Thẻ 5 — Tài khoản & Phân quyền (`UC12`)**: Hiển thị 6 tài khoản kèm chức năng tạo nhân viên mới, đổi quyền và khóa/mở khóa (chặn tự khóa Admin đang đăng nhập).
     - **Thẻ 6 — Quản lý khuyến mãi (`UC13`)**: Hiển thị 4 mã khuyến mãi (`PCM500K`, `GIAM5`, `NEWUSER`, `HETHAN`).
5. **Trang Nghiệp vụ Nhân viên [`NhanVien.aspx`](file:///d:/WEB/apps/NhanVien.aspx) (`HTTP 200`)**:
   - **Thẻ 1 — Tiếp nhận & Xử lý đơn hàng (`UC11`)**: Lọc và cập nhật trạng thái đơn hàng, tự động hoàn trả tồn kho khi đơn bị hủy.
   - **Thẻ 2 — Kiểm tra tồn kho & Cập nhật sản phẩm (`UC09 - Staff`)**: Hiển thị cảnh báo tồn kho và cho phép nhân viên cập nhật thông tin mô tả, thông số kỹ thuật và đối chiếu số lượng tồn kho.
