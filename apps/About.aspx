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
                <li><a href="./Contact.aspx"> <button type="button"><i class="fa-solid fa-phone"></i><span class="t1">Liên
                                hệ</span></button>
                    </a></li>
                <li><a href="About.aspx"></a> <button type="button"
                        style="background: black; opacity: 0.6; border-radius: 20px;"><i
                            class="fa-solid fa-newspaper"></i><span class="t1">Giới
                            Thiệu</span></button>
                </li>

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


    <div class="container about-container">
        <div class="breadcrumb">
            <a href="Home.aspx">Trang chủ</a> / <span>Giới thiệu</span>
        </div>

        <div class="about-content">
            <div class="about-left">
                <h1>VỀ CHÚNG TÔI - PCM COMPUTER</h1>
                <p class="highlight-text">Uy tín tạo dựng niềm tin - Chất lượng khẳng định thương hiệu.</p>
                <p>Thành lập từ năm 2015, PCM Computer đã trở thành một trong những đơn vị hàng đầu trong lĩnh vực cung
                    cấp linh kiện máy tính, Laptop gaming, PC đồ họa và các giải pháp công nghệ cao tại Việt Nam.</p>
                <p>Với đội ngũ kỹ thuật viên giàu kinh nghiệm và niềm đam mê công nghệ cháy bỏng, chúng tôi cam kết mang
                    đến cho khách hàng những sản phẩm chính hãng với mức giá cạnh tranh nhất thị trường.</p>

                <div class="about-features">
                    <div class="feature-item">
                        <i class="fa-solid fa-medal"></i>
                        <span>Sản phẩm chính hãng 100%</span>
                    </div>
                    <div class="feature-item">
                        <i class="fa-solid fa-truck-fast"></i>
                        <span>Giao hàng toàn quốc</span>
                    </div>
                    <div class="feature-item">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                        <span>Bảo hành tận nơi</span>
                    </div>
                </div>
            </div>
            <div class="about-right">
                <img src="./anh pc/pc8.jpg" alt="Showroom PCM">
            </div>
        </div>

        <div class="mission-vision">
            <div class="mv-box">
                <div class="icon-box"><i class="fa-solid fa-eye"></i></div>
                <h3>TẦM NHÌN</h3>
                <p>Trở thành hệ thống bán lẻ máy tính và thiết bị công nghệ số 1 tại Việt Nam, mang công nghệ đến gần
                    hơn với mọi người.</p>
            </div>
            <div class="mv-box">
                <div class="icon-box"><i class="fa-solid fa-bullseye"></i></div>
                <h3>SỨ MỆNH</h3>
                <p>Cung cấp giải pháp tối ưu nhất cho khách hàng. Không chỉ bán sản phẩm, chúng tôi bán sự hài lòng và
                    trải nghiệm tuyệt vời.</p>
            </div>
            <div class="mv-box">
                <div class="icon-box"><i class="fa-solid fa-heart"></i></div>
                <h3>GIÁ TRỊ CỐT LÕI</h3>
                <p>Tận tâm - Trung thực - Trách nhiệm. Khách hàng là trung tâm của mọi hoạt động phát triển.</p>
            </div>
        </div>
    </div>

    
</asp:Content>
