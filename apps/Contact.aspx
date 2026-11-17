<%@ Page Language="C#" MasterPageFile="~/Site.Master" %>
<asp:Content ID="HeadContentPage" ContentPlaceHolderID="HeadContent" runat="server">
<link rel="stylesheet" href="./style.css">
</asp:Content>
<asp:Content ID="NavigationContentPage" ContentPlaceHolderID="NavigationContent" runat="server">
<nav>
        <div class="container">
            <ul>
                <li class="logo2"><a href="Home.aspx"><img src="./Image/logo2.png" alt=""></a></li>
                <li><input type="text" placeholder="Bạn tìm gì..."><i class="fa-solid fa-magnifying-glass"></i></li>
                <li><a href="Login.aspx"><button type="button"><i class="fa-solid fa-user"></i><span class="t1">Đăng nhập</span></button></a>
                </li>
                <li><a href="Cart.aspx"><button type="button"><i class="fa-solid fa-cart-shopping"></i><span class="t1">Giỏ
                            hàng</span></button></a>
                </li>
                <li><a href="Contact.aspx"></a> <button type="button" style="background: black; opacity: 0.6; border-radius: 20px;"><i
                            class="fa-solid fa-phone"></i><span class="t1">Liên hệ</span></button>
                </li>
                <li><a href="./About.aspx"> <button type="button"><i class="fa-solid fa-newspaper"></i><span class="t1">Giới
                                Thiệu</span></button>
                    </a></li>

            </ul>
        </div>
    </nav>

    <section class="menu-bar">
        <div class="container">
            <div class="menu-bar-content">
                <ul>
                    <li><a href="Home.aspx"><i class="fa-solid fa-receipt"></i>
                            <span>TRANG CHỦ</span>
                        </a></li>
                    <li><a href="Phones.aspx"><i class="fa-solid fa-mobile-screen-button"></i>
                            <span> Điện thoại </span>
                        </a></li>
                    <li><a href="Laptops.aspx"><i class="fa-solid fa-laptop"></i>Laptop</a></li>
                    <li><a href="Accessories.aspx"><i class="fa-solid fa-headphones"></i>
                            <span>Phụ kiện</span>
                        </a></li>
                    <li><a href="Watches.aspx"><i class="fa-solid fa-clock"></i>
                            <span>Đồng hồ</span>
                        </a></li>
                    <li><a href="MonitorsPrinters.aspx"><i class="fa-solid fa-desktop"></i>
                            <span>Màng hình, Máy in</span>
                        </a></li>

                </ul>
            </div>
        </div>
    </section>
</asp:Content>
<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">


    <div class="container contact-container">
        <div class="breadcrumb">
            <a href="Home.aspx">Trang chủ</a> / <span>Liên hệ</span>
        </div>

        <div class="contact-content">
            <div class="contact-info">
                <h2>THÔNG TIN LIÊN HỆ</h2>
                <div class="info-box">
                    <p><i class="fa-solid fa-location-dot"></i> <strong>Địa chỉ:</strong> 83-85 Thái Hà, Đống Đa, Hà Nội
                    </p>
                    <p><i class="fa-solid fa-phone"></i> <strong>Hotline:</strong> 036.625.8142</p>
                    <p><i class="fa-solid fa-envelope"></i> <strong>Email:</strong> cskh@pcmcomputer.vn</p>
                    <p><i class="fa-solid fa-clock"></i> <strong>Giờ làm việc:</strong> 8h00 - 21h00 (Hàng ngày)</p>
                </div>
            </div>

            <div class="contact-form">
                <h2>GỬI THÔNG TIN CHO CHÚNG TÔI</h2>
                <p>Vui lòng điền đầy đủ thông tin vào bảng dưới đây:</p>

                <div>
                    <table class="tbl-contact">
                        <tr>
                            <td>Họ và tên* :</td>
                            <td><input type="text" id="fullname" placeholder="Nhập họ tên của bạn"></td>
                        </tr>
                        <tr>
                            <td>SĐT :</td>
                            <td><input type="text" id="phone" placeholder="Nhập số điện thoại"></td>
                        </tr>
                        <tr>
                            <td>Email* :</td>
                            <td><input type="text" id="email" placeholder="Nhập email của bạn"></td>
                        </tr>
                        <tr>
                            <td>Tiêu đề :</td>
                            <td><input type="text" id="title" placeholder="Bạn cần hỗ trợ vấn đề gì?"></td>
                        </tr>
                        <tr>
                            <td>Nội dung* :</td>
                            <td><textarea id="content" rows="5" placeholder="Nội dung chi tiết..."></textarea></td>
                        </tr>
                        <tr>
                            <td></td>
                            <td>
                                <button type="submit" class="btn-send">GỬI LIÊN HỆ</button>
                                <button type="reset" class="btn-reset">NHẬP LẠI</button>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </div>

    
</asp:Content>
