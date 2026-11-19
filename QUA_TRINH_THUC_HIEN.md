# NHẬT KÝ QUÁ TRÌNH THỰC HIỆN DỰ ÁN: WEBSITE BÁN MÁY TÍNH VÀ LINH KIỆN (PCM COMPUTER)

Tài liệu này ghi nhận chi tiết toàn bộ quá trình phân tích, thiết kế, xây dựng và kiểm thử hệ thống **PCM Computer** dựa trên tài liệu đặc tả [`Website-Laptop-Linh-Kien.docx`](file:///d:/WEB/Website-Laptop-Linh-Kien.docx).

---

## Tổng quan yêu cầu từ tài liệu đặc tả `Website-Laptop-Linh-Kien.docx`

- **3 Phân hệ & 3 Tác nhân (Actors)**:
  1. **Website bán hàng — Khách hàng (Customer)**: Xem danh mục (`UC03`), tìm kiếm & lọc theo hãng/mức giá (`UC04`), xem chi tiết thông số kỹ thuật (`UC05`), quản lý giỏ hàng (`UC06`), áp dụng mã khuyến mãi (`UC16`), đặt hàng trực tuyến COD (`UC07`), theo dõi & hủy đơn hàng (`UC08`), đăng ký (`UC01`), đăng nhập (`UC02`), đăng xuất & quản lý hồ sơ (`UC15`).
  2. **Trang nghiệp vụ bán hàng — Nhân viên (Staff)**: Tiếp nhận & xử lý đơn hàng (`UC11`), lọc đơn theo trạng thái, cập nhật tiến độ giao hàng (tự động hoàn trả số lượng tồn kho khi đơn bị hủy), kiểm tra số lượng tồn kho và cập nhật thông tin cơ bản của sản phẩm (`UC09 - Staff`).
  3. **Trang quản trị hệ thống — Quản trị viên (Admin)**: Quản lý danh mục (`UC10` - chặn xóa nếu còn sản phẩm trực thuộc), quản lý sản phẩm toàn quyền (`UC09 - Admin` - chuyển sang `'Ngừng kinh doanh'` thay vì xóa cứng nếu sản phẩm đã phát sinh trong đơn hàng), quản lý đơn hàng (`UC11`), quản lý tài khoản & phân quyền (`UC12` - chặn Admin tự khóa/hạ quyền chính mình), quản lý khuyến mãi/voucher (`UC13` - kiểm tra ngày kết thúc >= ngày bắt đầu và mức giảm hợp lệ), thống kê doanh thu theo thời gian từ đơn `'Đã giao'` & cảnh báo tồn kho (`UC14`).
- **Đầy đủ 16 Yêu cầu chức năng (`FR01` – `FR16`) & 16 Use Case (`UC01` – `UC16`)**.
- **Đầy đủ 8 Yêu cầu phi chức năng (`NFR01` – `NFR08`)**: Mã hóa mật khẩu SHA-256, phân quyền chặt chẽ, toàn vẹn dữ liệu khóa chính/khóa ngoại & không cho đặt vượt tồn kho, giao diện trực quan & tương thích trình duyệt.
- **Tuân thủ Biểu đồ hoạt động (Mục 3.6) & Biểu đồ tuần tự Đặt hàng `UC07` (Mục 3.7)**: Kiến trúc lớp `:CheckoutView` -> `:OrderController` -> `:OrderService` -> `:Database`.

---

## Phần 1: Thiết kế & Khởi tạo Cơ sở dữ liệu SQL Server (`PCMComputerDB`) — [ĐÃ HOÀN THÀNH & TEST PASS]

### 1.1. Công việc đã thực hiện
- Kết nối trực tiếp tới SQL Server Express (`.\SQLEXPRESS`) đang chạy trên máy.
- Xây dựng kịch bản SQL [`Database_PCMComputer.sql`](file:///d:/WEB/Database_PCMComputer.sql) khởi tạo CSDL **`PCMComputerDB`** gồm 8 bảng chuẩn hóa với đầy đủ khóa chính (`PRIMARY KEY`), khóa ngoại (`FOREIGN KEY`), và ràng buộc kiểm tra dữ liệu (`CHECK CONSTRAINT`):
  1. `dbo.Users`: Lưu tài khoản người dùng với mật khẩu băm SHA-256 (`PasswordHash`), phân quyền `Role` (`Admin`, `Staff`, `Customer`), trạng thái khóa `IsLocked`.
  2. `dbo.Categories`: Lưu 14 danh mục máy tính, laptop, PC gaming, workstation, linh kiện, màn hình, phụ kiện khớp với hệ thống menu của website.
  3. `dbo.Products`: Lưu 27 sản phẩm máy tính và linh kiện có đầy đủ mã SP (`ProductCode`), hãng (`Brand`), giá niêm yết (`OldPrice`), giá bán (`Price`), tồn kho (`StockQuantity >= 0`), bảo hành (`WarrantyMonths`), bảng thông số kỹ thuật (`Specifications`), trạng thái (`Đang kinh doanh` / `Ngừng kinh doanh`).
  4. `dbo.Promotions`: Lưu chương trình khuyến mãi & mã giảm giá (`VoucherCode`), loại giảm (`PERCENT` hoặc `AMOUNT`), đơn tối thiểu (`MinOrderAmount`), giới hạn lượt dùng (`UsageLimit`, `UsedCount`), ngày bắt đầu/kết thúc (`EndDate >= StartDate`).
  5. `dbo.Orders`: Lưu đơn đặt hàng trực tuyến với mã đơn (`OrderCode`), thông tin người nhận, phương thức thanh toán (`COD`), mã voucher, tiền giảm, tổng thanh toán và trạng thái (`Chờ xác nhận`, `Đang chờ vận chuyển`, `Đang vận chuyển`, `Đang giao`, `Đã giao`, `Đã hủy`).
  6. `dbo.OrderDetails`: Lưu chi tiết từng linh kiện/máy tính trong đơn hàng.
  7. `dbo.OrderStatusHistory`: Lưu vết lịch sử cập nhật trạng thái đơn hàng của Khách hàng / Nhân viên / Quản trị viên.
  8. `dbo.Contacts`: Lưu thông tin liên hệ & yêu cầu hỗ trợ từ khách hàng.

### 1.2. Kết quả kiểm thử CSDL trên `.\SQLEXPRESS`
- Thực thi toàn bộ các batch SQL thành công (Exit code `0`, không có lỗi cú pháp hay ràng buộc).
- Dữ liệu mẫu khởi tạo thành công:
  - `Users`: 6 tài khoản (`admin/123456`, `staff/123456`, `staff2/123456`, `khachhang/123456`, `minhanh/123456`, `userlocked/123456` - tài khoản bị khóa để test ngoại lệ `UC02`).
  - `Categories`: 14 danh mục.
  - `Products`: 27 sản phẩm máy tính & linh kiện kèm thông số kỹ thuật chi tiết.
  - `Promotions`: 4 mã khuyến mãi (`PCM500K`, `GIAM5`, `NEWUSER`, và mã `HETHAN` để test ngoại lệ `UC16`).
  - `Orders`: 4 đơn hàng mẫu ở các trạng thái khác nhau (`Đã giao`, `Đang giao`, `Chờ xác nhận`).

---

## Phần 2: Xây dựng tầng Backend / Business Logic (`App_Code`) & Cấu hình `Web.config` — [ĐÃ HOÀN THÀNH & TEST PASS]

### 2.1. Công việc đã thực hiện
- Cập nhật [`apps/Web.config`](file:///d:/WEB/apps/Web.config): Cấu hình chuỗi kết nối `PCMComputerDB` tới `Server=.\SQLEXPRESS;Database=PCMComputerDB;Integrated Security=True`, thiết lập UTF-8 (`vi-VN`), `SessionState` và `ClientIDMode="Static"`.
- Xây dựng hệ thống lớp nghiệp vụ trong `apps/App_Code`:
  - [`Models.cs`](file:///d:/WEB/apps/App_Code/Models.cs): Định nghĩa đầy đủ các thực thể và DTO (`UserInfo`, `CategoryInfo`, `ProductInfo`, `CartItem`, `PromotionInfo`, `VoucherCheckResult`, `OrderDTO`, `OrderResult`, `OrderInfo`, `OrderDetailInfo`, `OrderHistoryInfo`, `RevenueStats`).
  - [`SecurityHelper.cs`](file:///d:/WEB/apps/App_Code/SecurityHelper.cs): Mã hóa mật khẩu SHA-256 (`NFR03`), quản lý phiên đăng nhập & phân quyền (`Admin`, `Staff`, `Customer`), quản lý giỏ hàng trong `Session` có kiểm tra số lượng tồn kho thực tế (`UC06`, `NFR04`).
  - [`DbHelper.cs`](file:///d:/WEB/apps/App_Code/DbHelper.cs): Tầng truy xuất CSDL SQL Server cho toàn bộ 16 Use Case, cài đặt đầy đủ các luồng ngoại lệ.
  - [`OrderService.cs`](file:///d:/WEB/apps/App_Code/OrderService.cs) & [`OrderController.cs`](file:///d:/WEB/apps/App_Code/OrderController.cs): Cài đặt chính xác theo **Biểu đồ tuần tự Đặt hàng trực tuyến (`UC07` - Mục 3.7)** với các phương thức `requestCheckout()`, `getUserDefaultInfo()`, `selectUserById()`, `submitOrder()`, `processCreateOrder()`, `checkStockAndVoucher()`, `insertOrder()`, `insertOrderDetails()`, `updateProductStock()`, `clearCart()` trong Transaction SQL.
  - [`UiHelper.cs`](file:///d:/WEB/apps/App_Code/UiHelper.cs): Hiển thị thẻ sản phẩm, thẻ deal giá sốc, bảng thông số kỹ thuật và huy hiệu trạng thái đơn hàng thống nhất.
- Nâng cấp [`apps/Site.Master`](file:///d:/WEB/apps/Site.Master) & [`apps/main.js`](file:///d:/WEB/apps/main.js): Tích hợp thanh tìm kiếm toàn cục, hiển thị thông tin tài khoản theo phân quyền (`Admin`, `Staff`, `Customer`), số lượng giỏ hàng theo thời gian thực.

---

## Phần 3: Xây dựng Phân hệ Website Bán Hàng cho Khách hàng (`UC01` – `UC08`, `UC15`, `UC16`) — [ĐÃ HOÀN THÀNH & TEST PASS]

### 3.1. Các trang đã xây dựng và nâng cấp
- [`apps/Home.aspx`](file:///d:/WEB/apps/Home.aspx): Trang chủ hiển thị danh mục bên trái từ CSDL, khu vực Flash Sale "SALE SẬP SÀN DEAL NGẬP TRÀN" và "TOP SẢN PHẨM BÁN CHẠY" lấy dữ liệu động từ SQL Server, hỗ trợ lọc nhanh theo tab danh mục, thêm vào giỏ hàng hoặc đặt mua ngay.
- [`apps/CategoryView.ascx`](file:///d:/WEB/apps/CategoryView.ascx), [`apps/Products.aspx`](file:///d:/WEB/apps/Products.aspx) và toàn bộ 14 trang danh mục ([`GamingLaptops.aspx`](file:///d:/WEB/apps/GamingLaptops.aspx), [`Laptops.aspx`](file:///d:/WEB/apps/Laptops.aspx), [`GamingPCs.aspx`](file:///d:/WEB/apps/GamingPCs.aspx), [`Workstations.aspx`](file:///d:/WEB/apps/Workstations.aspx), [`OfficePCs.aspx`](file:///d:/WEB/apps/OfficePCs.aspx), [`Components.aspx`](file:///d:/WEB/apps/Components.aspx), [`MonitorsPrinters.aspx`](file:///d:/WEB/apps/MonitorsPrinters.aspx), [`KeyboardsMice.aspx`](file:///d:/WEB/apps/KeyboardsMice.aspx), [`Accessories.aspx`](file:///d:/WEB/apps/Accessories.aspx), [`AudioVideo.aspx`](file:///d:/WEB/apps/AudioVideo.aspx), [`Cooling.aspx`](file:///d:/WEB/apps/Cooling.aspx), [`NetworkingCameras.aspx`](file:///d:/WEB/apps/NetworkingCameras.aspx), [`Phones.aspx`](file:///d:/WEB/apps/Phones.aspx), [`Watches.aspx`](file:///d:/WEB/apps/Watches.aspx)):
  - Xem danh sách sản phẩm theo danh mục có phân trang và sắp xếp (`UC03`).
  - Tìm kiếm theo từ khóa tên/mã/cấu hình, lọc theo Hãng sản xuất, lọc theo Khoảng giá (`UC04`).
  - Xử lý ngoại lệ `UC03` (hiển thị `'Chưa có sản phẩm trong danh mục này'`) và ngoại lệ `UC04` (hiển thị `'Không tìm thấy sản phẩm phù hợp'` kèm danh sách **Gợi ý sản phẩm nổi bật**).
- [`apps/ProductDetail.aspx`](file:///d:/WEB/apps/ProductDetail.aspx): Xem chi tiết sản phẩm (`UC05`) gồm hình ảnh, mã SP, hãng, giá niêm yết, giá khuyến mãi, thời hạn bảo hành, số lượng tồn kho, bảng thông số kỹ thuật chi tiết, mô tả sản phẩm và sản phẩm cùng danh mục. Nếu tồn kho = 0 thì hiển thị `'Tạm hết hàng'` và khóa nút thêm vào giỏ hàng.
- [`apps/Cart.aspx`](file:///d:/WEB/apps/Cart.aspx): Quản lý giỏ hàng (`UC06`), hiển thị số lượng tồn kho ngay tại từng sản phẩm, tăng/giảm số lượng có kiểm tra giới hạn tồn kho, xóa sản phẩm, tự động tính lại thành tiền từng dòng và tổng tiền giỏ hàng.
- [`apps/Checkout.aspx`](file:///d:/WEB/apps/Checkout.aspx): Đặt hàng trực tuyến (`UC07`) và Áp dụng mã khuyến mãi (`UC16`). Bắt buộc đăng nhập (`«include» UC02`), tự động điền thông tin người nhận từ hồ sơ, kiểm tra tính hợp lệ mã giảm giá (`PCM500K`, `GIAM5`, `NEWUSER`, `HETHAN`), thực thi tạo đơn hàng qua `OrderController` -> `OrderService` với Transaction trừ tồn kho.
- [`apps/Login.aspx`](file:///d:/WEB/apps/Login.aspx) & [`apps/Register.aspx`](file:///d:/WEB/apps/Register.aspx): Đăng nhập (`UC02` - có nút chọn nhanh tài khoản mẫu Admin/Staff/Customer/TK bị khóa) và Đăng ký tài khoản mới (`UC01`).
- [`apps/Profile.aspx`](file:///d:/WEB/apps/Profile.aspx) & [`apps/Logout.aspx`](file:///d:/WEB/apps/Logout.aspx): Cập nhật thông tin cá nhân, đổi mật khẩu và đăng xuất an toàn (`UC15`).
- [`apps/MyOrders.aspx`](file:///d:/WEB/apps/MyOrders.aspx): Theo dõi lịch sử đơn hàng, xem chi tiết sản phẩm & tiến độ đơn hàng, hủy đơn khi đang ở trạng thái `'Chờ xác nhận'` / `'Đang chờ vận chuyển'` kèm tự động hoàn trả số lượng tồn kho (`UC08`).
- [`apps/About.aspx`](file:///d:/WEB/apps/About.aspx) & [`apps/Contact.aspx`](file:///d:/WEB/apps/Contact.aspx): Đồng bộ thanh điều hướng động từ `Site.Master` và lưu yêu cầu liên hệ vào bảng `dbo.Contacts`.

---

## Phần 4: Xây dựng Phân hệ Nghiệp vụ Bán Hàng cho Nhân viên (`Staff.aspx` — `UC09`, `UC11`) — [ĐÃ HOÀN THÀNH & TEST PASS]

- Xây dựng trang [`apps/Staff.aspx`](file:///d:/WEB/apps/Staff.aspx) với kiểm tra phân quyền `Staff` / `Admin`:
  1. **Tab Tiếp nhận & Xử lý đơn hàng (`UC11`)**: Lọc đơn hàng theo trạng thái (`Chờ xác nhận`, `Đang chờ vận chuyển`, `Đang vận chuyển`, `Đang giao`, `Đã giao`, `Đã hủy`), xem chi tiết linh kiện và thông tin khách hàng, xác nhận và cập nhật trạng thái đơn hàng. Khi đơn bị hủy (chỉ cho phép hủy khi ở trạng thái chờ xác nhận / đang chờ vận chuyển), tự động hoàn trả số lượng tồn kho của các sản phẩm trong đơn.
  2. **Tab Kiểm tra tồn kho & Cập nhật sản phẩm (`UC09 - Staff`)**: Đối chiếu tồn kho thực tế, cảnh báo mã sắp hết hàng, cập nhật giá bán, số lượng tồn kho, thời hạn bảo hành, bảng thông số kỹ thuật và mô tả sản phẩm (không có quyền xóa sản phẩm đúng theo phân quyền Staff).

---

## Phần 5: Xây dựng Phân hệ Quản trị Hệ thống cho Quản trị viên (`Admin.aspx` — `UC09` đến `UC14`) — [ĐÃ HOÀN THÀNH & TEST PASS]

- Xây dựng trang [`apps/Admin.aspx`](file:///d:/WEB/apps/Admin.aspx) với kiểm tra phân quyền chỉ `Admin` mới được truy cập:
  1. **Tab Thống kê doanh thu (`UC14`)**: Lọc theo Toàn thời gian, Hôm nay, Tháng này, Quý này hoặc Khoảng ngày tùy chọn (`Từ ngày` - `Đến ngày`). Tính tổng doanh thu thực tế từ các đơn `'Đã giao'` (nếu chưa có đơn hoàn thành hiển thị `0 đ`), thống kê số lượng đơn theo trạng thái, biểu đồ Top máy tính & linh kiện bán chạy nhất và bảng Cảnh báo tồn kho thấp (`<= 5 SP`).
  2. **Tab Quản lý sản phẩm (`UC09 - Admin`)**: Thêm sản phẩm mới, chỉnh sửa toàn bộ thông tin/cấu hình/hình ảnh/tồn kho, xóa sản phẩm. Khi xóa sản phẩm đã từng phát sinh trong hóa đơn bán hàng (`OrderDetails`), hệ thống tự động cảnh báo và chuyển sang trạng thái `'Ngừng kinh doanh'` thay vì xóa cứng để bảo toàn lịch sử đơn hàng.
  3. **Tab Quản lý danh mục (`UC10`)**: Thêm, sửa, xóa danh mục máy tính & linh kiện. Kiểm tra trùng tên danh mục; ngăn thao tác xóa và hiển thị thông báo nếu danh mục đang chứa sản phẩm trực thuộc.
  4. **Tab Quản lý đơn hàng (`UC11`)**: Toàn quyền kiểm soát và cập nhật trạng thái đơn hàng.
  5. **Tab Quản lý tài khoản & Phân quyền (`UC12`)**: Tạo tài khoản nhân viên mới, cập nhật vai trò (`Admin`, `Staff`, `Customer`), khóa/mở khóa tài khoản. Ngăn không cho Quản trị viên tự khóa hoặc tự hạ quyền chính tài khoản Admin đang đăng nhập.
  6. **Tab Quản lý khuyến mãi (`UC13`)**: Thêm mới, chỉnh sửa chương trình khuyến mãi / mã giảm giá (`PERCENT` hoặc `AMOUNT`), kiểm tra ngày kết thúc >= ngày bắt đầu và mức giảm hợp lệ (`0 < % <= 100`).

---

## Phần 6: Kiểm thử Biên dịch (`aspnet_compiler.exe`) & Kiểm thử Trực tiếp trên Trình duyệt — [ĐÃ BIÊN DỊCH PASS 100%]

- Chạy công cụ biên dịch toàn bộ ứng dụng ASP.NET Web Forms (`aspnet_compiler.exe -v / -p "d:\WEB\apps" -errorstack`):
  - **Kết quả**: `Command exited with code 0` — Toàn bộ các lớp C# trong `App_Code`, `Site.Master`, `CategoryView.ascx` và tất cả 25 trang `.aspx` biên dịch thành công 100%, không có bất kỳ lỗi biên dịch nào.

### 6.1. Kết quả kiểm thử End-to-End trên Trình duyệt (`http://localhost:5088/`)
1. **Trang chủ [`Home.aspx`](file:///d:/WEB/apps/Home.aspx) (`HTTP 200`)**:
   - Hiển thị đầy đủ danh mục máy tính & linh kiện bên trái từ SQL Server.
   - Khu vực **SALE SẬP SÀN DEAL NGẬP TRÀN** và **TOP SẢN PHẨM BÁN CHẠY** tải dữ liệu thực tế từ bảng `dbo.Products` (mã SP, hãng, giá niêm yết, giá khuyến mãi, % giảm, bảo hành, tồn kho).
2. **Trang chi tiết sản phẩm [`ProductDetail.aspx`](file:///d:/WEB/apps/ProductDetail.aspx) (`HTTP 200`)**:
   - Kiểm tra sản phẩm `Laptop Gigabyte AORUS 16X 9KG-43VNC54SH` (`NBGI0099`): Hiển thị giá `31.990.000 đ`, bảo hành `24 tháng chính hãng`, tồn kho `Còn hàng (8 sản phẩm)`, bảng thông số kỹ thuật chi tiết 8 dòng (`CPU`, `VGA`, `RAM`, `Ổ cứng`, `Màn hình`, `Pin`, `Trọng lượng`, `HĐH`).
3. **Trang danh sách & Tìm kiếm sản phẩm [`Products.aspx`](file:///d:/WEB/apps/Products.aspx) (`HTTP 200`)**:
   - Hiển thị toàn bộ 27 sản phẩm.
   - Tìm kiếm từ khóa `'RTX 4060'` trả về chính xác `6 sản phẩm`.
   - Lọc theo danh mục `'Linh Kiện Máy Tính'` trả về chính xác `4 sản phẩm`.
4. **Trang Đăng nhập [`Login.aspx`](file:///d:/WEB/apps/Login.aspx) & Trang Quản trị viên [`Admin.aspx`](file:///d:/WEB/apps/Admin.aspx) (`HTTP 200`)**:
   - Đăng nhập tài khoản `admin / 123456` điều hướng chính xác vào `Admin.aspx`.
   - Kiểm tra toàn bộ 6 Tab quản trị đều hoạt động mượt mà (`HTTP 200`):
     - **Tab 1 — Thống kê doanh thu (`UC14`)**: Doanh thu thực tế từ đơn `'Đã giao'` đạt `56.389.000 đ` (2 đơn hoàn thành), tổng `4 đơn`, cảnh báo tồn kho thấp `6 mã SP`, biểu đồ Top sản phẩm bán chạy.
     - **Tab 2 — Quản lý sản phẩm (`UC09`)**: Hiển thị 27 sản phẩm kèm biểu mẫu Thêm/Sửa/Xóa (có kiểm tra chuyển sang `'Ngừng kinh doanh'` nếu sản phẩm đã phát sinh trong đơn hàng).
     - **Tab 3 — Quản lý danh mục (`UC10`)**: Hiển thị 14 danh mục kèm số lượng sản phẩm và kiểm tra chặn xóa danh mục đang chứa sản phẩm.
     - **Tab 4 — Quản lý đơn hàng (`UC11`)**: Hiển thị 4 đơn hàng (`DH20261101` – `DH20261104`) kèm bộ lọc trạng thái.
     - **Tab 5 — Tài khoản & Phân quyền (`UC12`)**: Hiển thị 6 tài khoản kèm chức năng tạo nhân viên mới, đổi quyền và khóa/mở khóa (chặn tự khóa Admin đang đăng nhập).
     - **Tab 6 — Quản lý khuyến mãi (`UC13`)**: Hiển thị 4 mã khuyến mãi (`PCM500K`, `GIAM5`, `NEWUSER`, `HETHAN`).
5. **Trang Nghiệp vụ Nhân viên [`Staff.aspx`](file:///d:/WEB/apps/Staff.aspx) (`HTTP 200`)**:
   - **Tab 1 — Tiếp nhận & Xử lý đơn hàng (`UC11`)**: Lọc và cập nhật trạng thái đơn hàng, tự động hoàn trả tồn kho khi đơn bị hủy.
   - **Tab 2 — Kiểm tra tồn kho & Cập nhật sản phẩm (`UC09 - Staff`)**: Hiển thị cảnh báo tồn kho và cho phép nhân viên cập nhật thông tin mô tả, thông số kỹ thuật và đối chiếu số lượng tồn kho.
