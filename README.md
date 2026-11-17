# PCM Computer — ASP.NET Web Forms

Dự án ASP.NET Web Site (C#), sử dụng .NET Framework 4.8 và Master Page.

## Chạy bằng Visual Studio

1. Cài Visual Studio với workload **ASP.NET and web development** và .NET Framework 4.8 targeting pack.
2. Mở `PCMComputer.sln` (hoặc File > Open > Web Site, chọn thư mục `apps`).
3. Chọn `Home.aspx` làm Start Page, sau đó chạy bằng IIS Express (Ctrl+F5).

## Chạy bằng IIS Express

Trong PowerShell:

```powershell
& 'C:\Program Files\IIS Express\iisexpress.exe' /path:D:\WEB\apps /port:5088 /systray:false
```

Mở http://localhost:5088/ hoặc http://localhost:5088/Home.aspx.
Web Forms cần IIS/ASP.NET trên .NET Framework; không chạy bằng Live Server hoặc `dotnet run`.

## Cấu trúc

- `apps/Site.Master`: khung trang, header, footer, server form; các ContentPlaceHolder cho CSS, menu và nội dung.
- `apps/Home.aspx`: trang chủ.
- `apps/About.aspx`: trang giới thiệu.
- `apps/Contact.aspx`: trang liên hệ.
- `apps/Default.aspx`: chuyển đến trang chủ.
- `apps/Web.config`: cấu hình .NET Framework 4.8 và UTF-8.

HTML, nội dung, CSS, ảnh và các khác biệt menu/CSS giữa các trang được giữ từ bản gốc. Các liên kết nội bộ trong bản Web Forms được đổi sang `.aspx`. CSS và tài nguyên ảnh không được sửa.

Master Page dùng một server form. Form liên hệ bên trong được đổi thành div để tránh form lồng nhau; ID trường nhập vẫn giữ nguyên. Các nút không gửi biểu mẫu được đặt `type="button"` để tránh postback ngoài ý muốn. JavaScript chỉ kiểm tra liên hệ khi có trường họ tên trên trang.

Không bổ sung backend, cơ sở dữ liệu, đăng nhập, giỏ hàng hay gửi liên hệ. Các tệp `.html` vẫn được giữ để đối chiếu bản gốc.

## Các trang trống

Các trang dưới đây dùng CSS và menu mặc định từ Site.Master, MainContent để trống hoàn toàn. Chỉ có liên kết điều hướng, không có xử lý nghiệp vụ, code-behind hoặc biểu mẫu mới.

- Products.aspx: danh sách sản phẩm.
- Phones.aspx: điện thoại.
- Laptops.aspx: laptop.
- Accessories.aspx: phụ kiện.
- Watches.aspx: đồng hồ.
- MonitorsPrinters.aspx: màn hình, máy in.
- Login.aspx: đăng nhập.
- Cart.aspx: giỏ hàng.
- GamingLaptops.aspx: laptop gaming, đồ họa.
- GamingPCs.aspx: PC gaming.
- Workstations.aspx: PC đồ họa, thiết kế, AI.
- OfficePCs.aspx: PC văn phòng.
- KeyboardsMice.aspx: bàn phím, chuột.
- Components.aspx: linh kiện máy tính.
- AudioVideo.aspx: loa, tai nghe, webcam, tivi.
- Cooling.aspx: tản nhiệt.
- NetworkingCameras.aspx: thiết bị mạng, camera.

Ba trang gốc được đổi tên thành Home.aspx, About.aspx, Contact.aspx. Các tệp HTML cũ chỉ giữ làm bản đối chiếu.
