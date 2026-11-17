<%@ Page Language="C#" MasterPageFile="~/Site.Master" %>
<asp:Content ID="HeadContentPage" ContentPlaceHolderID="HeadContent" runat="server">
<link rel="stylesheet" href="./reset.css">
<link rel="stylesheet" href="./style.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css"
        integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw=="
        crossorigin="anonymous" referrerpolicy="no-referrer" />
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
                    <li><a href="Products.aspx"><i class="fa-solid fa-receipt"></i>
                            <span>DANH SÁCH SẢN PHẨM</span>
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


    <div class="main-content">
        <div class="container">
            <div class="left">
                <ul>
                    <li><a href="GamingLaptops.aspx"> <img src="./Icon/cat.png" alt=""></a></li>
                    <li><a href="GamingLaptops.aspx">Laptop Gaming - Đồ Họa</a></li>
                </ul>
                <ul>
                    <li><a href="Laptops.aspx"> <img src="./Icon/laptop.png" alt=""></a></li>
                    <li><a href="Laptops.aspx">Laptop - Máy Tính Xách Tay</a></li>
                </ul>
                <ul>
                    <li><a href="Accessories.aspx"> <img src="./Icon/phukien.png" alt=""></a></li>
                    <li><a href="Accessories.aspx">Phụ Kiện Laptop,PC,Khác</a></li>
                </ul>
                <ul>
                    <li><a href="GamingPCs.aspx"> <img src="./Icon/pcgaming.png" alt=""></a></li>
                    <li><a href="GamingPCs.aspx">PC Gaming - Học Tập</a></li>
                </ul>
                <ul>
                    <li><a href="Workstations.aspx"> <img src="./Icon/pcdohoa.png" alt=""></a></li>
                    <li><a href="Workstations.aspx">PC Đồ Họa, Thiết Kế, AI</a></li>
                </ul>
                <ul>
                    <li><a href="OfficePCs.aspx"> <img src="./Icon/pcvanphong.png" alt=""></a></li>
                    <li><a href="OfficePCs.aspx">PC Văn Phòng - Làm Việc</a></li>
                </ul>
                <ul>
                    <li><a href="KeyboardsMice.aspx"> <img src="./Icon/banphimchuot.png" alt=""></a></li>
                    <li><a href="KeyboardsMice.aspx">Bàn Phím, Chuột - Gaming</a></li>
                </ul>
                <ul>
                    <li><a href="Components.aspx"> <img src="./Icon/linhkien.png" alt=""></a></li>
                    <li><a href="Components.aspx">Linh Kiện Máy Tính</a></li>
                </ul>
                <ul>
                    <li><a href="MonitorsPrinters.aspx"> <img src="./Icon/manghinh.png" alt=""></a></li>
                    <li><a href="MonitorsPrinters.aspx">Màn Hình Máy Tính</a></li>
                </ul>
                <ul>
                    <li><a href="AudioVideo.aspx"> <img src="./Icon/loa.png" alt=""></a></li>
                    <li><a href="AudioVideo.aspx">Loa, Tai Nghe, Webcam, Tivi</a></li>
                </ul>
                <ul>
                    <li><a href="Cooling.aspx"> <img src="./Icon/tannhiet.png" alt=""></a></li>
                    <li><a href="Cooling.aspx">Cooling, Tản Nhiệt</a></li>
                </ul>
                <ul>
                    <li><a href="NetworkingCameras.aspx"> <img src="./Icon/Thietbimang.png" alt=""></a></li>
                    <li><a href="NetworkingCameras.aspx">Thiết Bị Mạng, Camera</a></li>
                </ul>
            </div>
            <div class="mid">
                <div class="mid-top1">
                    <div class="img-all">
                        <img src="./Image/sale.jpg" alt="" class="active">
                        <img src="./Image/sale2.jpg" alt="">
                        <img src="./Image/sale3.jpg" alt="">
                        <img src="./Image/sale4.jpg" alt="">
                        <img src="./Image/sale5.jpg" alt="">
                        <img src="./Image/sale6.jpg" alt="">
                        <img src="./Image/sale7.jpg" alt="">
                        <img src="./Image/sale8.jpg" alt="">
                        <img src="./Image/sale9.jpg" alt="">
                        <img src="./Image/sale10.jpg" alt="">
                    </div>
                </div>
                <div class="mid-top2">
                    <div class="dots">
                        <span class="dot"></span>
                        <span class="dot"></span>
                        <span class="dot"></span>
                        <span class="dot"></span>
                        <span class="dot"></span>
                        <span class="dot"></span>
                        <span class="dot"></span>
                        <span class="dot"></span>
                        <span class="dot"></span>
                        <span class="dot"></span>
                    </div>
                </div>
                <div class="mid-bottom">
                    <div class="content-mid-bottom">
                        <a href="#"><img src="./Image/a1.png" alt=""></a>
                        <a href="#"><img src="./Image/a2.png" alt=""></a>
                        <a href="#"><img src="./Image/a3.png" alt=""></a>
                    </div>
                </div>
            </div>
            <div class="right">
                <div class="img-gift">
                    <img src="./Image/gift1.png" alt="">
                    <img src="./Image/gift2.png" alt="">
                </div>
            </div>
        </div>


    </div>
    </div>
    <div class="container">
        <div class="home-deal">

            <div class="home-top">
                <img src="./Image/home-deal-bg-2023.png" alt="">
                <span> <img src="./Image/clock2.gif" alt=""></span>
                <p class="text-deal">SALE SẬP SÀN DEAL NGẬP TRÀN</p>

            </div>
            <div class="home-bottom">
                <div class="home-btm-left">
                    <div class="box-left">
                        <div class="b1">
                            <div class="date-deal">17/12</div>
                            <span>Đang diễn ra</span>
                        </div>
                    </div>
                </div>
                <div class="home-btm-right">
                    <div class="box-right">
                        <div class="date-deal">Kết thúc sau</div>
                        <span></span>
                    </div>
                </div>

            </div>
            <div class="main-content-home">
                <div class="box-content1">
                    <div class="full-box">
                        <div class="box-top-cnt">
                            <a href="#"><img src="./anh pc/lap1.jpg" alt=""></a>
                        </div>
                        <div class="box-bottom-cnt">
                            <div class="text-content">
                                <p><a href="#">Laptop Gigabyte AORUS 16X 9KG-43VNC54SH (Intel Core i7-13650HX | RTX 4060
                                        | 16 inch
                                        WQXGA | 16GB | 1TB | Win 11 | Xám)</a></p>
                            </div>
                            <div class="rice-deal">
                                <div class="rice-top">
                                    <a href="#">
                                        <span>31.990.000đ</span>
                                        <span class="discount">-2%</span>
                                    </a>
                                </div>
                                <span class="rice-discount">32.390.000đ</span>
                            </div>
                            <div class="deal-count">
                                <span>Còn lại 2 sản phẩm</span>
                                <span class="img-deal"> <img src="./Icon/icon_order_status_deal.png" alt=""></span>
                            </div>


                            <a href="#">
                                <div class="buy-deal">
                                    <span>MUA GIÁ SỐC</span>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
                <div class="box-content1">
                    <div class="full-box">
                        <div class="box-top-cnt">
                            <a href="#"><img src="./anh pc/lap_acer.jpg" alt=""></a>
                        </div>
                        <div class="box-bottom-cnt">
                            <div class="text-content">
                                <p><a href="#">Laptop Gigabyte AORUS 16X 9KG-43VNC54SH (Intel Core i7-13650HX | RTX 4060
                                        | 16 inch
                                        WQXGA | 16GB | 1TB | Win 11 | Xám)</a></p>
                            </div>
                            <div class="rice-deal">
                                <div class="rice-top">
                                    <a href="#">
                                        <span>16.990.000đ</span>
                                        <span class="discount">-2%</span>
                                    </a>
                                </div>
                                <span class="rice-discount">18.990.000đ</span>
                            </div>
                            <div class="deal-count">
                                <span>Còn lại 2 sản phẩm</span>
                                <span class="img-deal"> <img src="./Icon/icon_order_status_deal.png" alt=""></span>
                            </div>


                            <a href="#">
                                <div class="buy-deal">
                                    <span>MUA GIÁ SỐC</span>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="box-content1">
                    <div class="full-box">
                        <div class="box-top-cnt">
                            <a href="#"><img src="./anh pc/lap3.jpg" alt=""></a>
                        </div>
                        <div class="box-bottom-cnt">
                            <div class="text-content">
                                <p><a href="#">Laptop Gigabyte AORUS 16X 9KG-43VNC54SH (Intel Core i7-13650HX | RTX 4060
                                        | 16 inch
                                        WQXGA | 16GB | 1TB | Win 11 | Xám)</a></p>
                            </div>
                            <div class="rice-deal">
                                <div class="rice-top">
                                    <a href="#">
                                        <span>24.990.000đ</span>
                                        <span class="discount">-2%</span>
                                    </a>
                                </div>
                                <span class="rice-discount">26.560.000đ</span>
                            </div>
                            <div class="deal-count">
                                <span>Còn lại 2 sản phẩm</span>
                                <span class="img-deal"> <img src="./Icon/icon_order_status_deal.png" alt=""></span>
                            </div>


                            <a href="#">
                                <div class="buy-deal">
                                    <span>MUA GIÁ SỐC</span>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="box-content1">
                    <div class="full-box">
                        <div class="box-top-cnt">
                            <a href="#"><img src="./anh pc/lap4.jpg" alt=""></a>
                        </div>
                        <div class="box-bottom-cnt">
                            <div class="text-content">
                                <p><a href="#">Laptop Gigabyte AORUS 16X 9KG-43VNC54SH (Intel Core i7-13650HX | RTX 4060
                                        | 16 inch
                                        WQXGA | 16GB | 1TB | Win 11 | Xám)</a></p>
                            </div>
                            <div class="rice-deal">
                                <div class="rice-top">
                                    <a href="#">
                                        <span>32.990.000đ</span>
                                        <span class="discount">-2%</span>
                                    </a>
                                </div>
                                <span class="rice-discount">34.990.000đ</span>
                            </div>
                            <div class="deal-count">
                                <span>Còn lại 2 sản phẩm</span>
                                <span class="img-deal"> <img src="./Icon/icon_order_status_deal.png" alt=""></span>
                            </div>


                            <a href="#">
                                <div class="buy-deal">
                                    <span>MUA GIÁ SỐC</span>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="box-content1">
                    <div class="full-box">
                        <div class="box-top-cnt">
                            <a href="#"><img src="./anh pc/lap5.jpg" alt=""></a>
                        </div>
                        <div class="box-bottom-cnt">
                            <div class="text-content">
                                <p><a href="#">Laptop Gigabyte AORUS 16X 9KG-43VNC54SH (Intel Core i7-13650HX | RTX 4060
                                        | 16 inch
                                        WQXGA | 16GB | 1TB | Win 11 | Xám)</a></p>
                            </div>
                            <div class="rice-deal">
                                <div class="rice-top">
                                    <a href="#">
                                        <span>59.990.000đ</span>
                                        <span class="discount">-2%</span>
                                    </a>
                                </div>
                                <span class="rice-discount">60.990.000đ</span>
                            </div>
                            <div class="deal-count">
                                <span>Còn lại 2 sản phẩm</span>
                                <span class="img-deal"> <img src="./Icon/icon_order_status_deal.png" alt=""></span>
                            </div>


                            <a href="#">
                                <div class="buy-deal">
                                    <span>MUA GIÁ SỐC</span>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>


                <div class="click-left-silde" id="prevBtn">
                    <div class="click-left-sildes">
                        <span><a href="#"><i class="fa fa-angle-left"></i></a></span>
                    </div>
                </div>
                <div class="click-right-silde" id="nextBtn">
                    <div class="click-right-sildes">
                        <span><a href="#"><i class="fa-solid fa-angle-right"></i></a></span>
                    </div>
                </div>
            </div>

        </div>
        <div class="box-sell">
            <div class="title-container">
                <div class="title-left"><span>TOP SẢN PHẨM BÁN CHẠY</span></div>
                <div class="home-box"></div>
                <div class="title-right">
                    <div class="title-right-item">
                        <a href="#">PC GAMING</a>
                        <a href="#">LAPTOP GAMING</a>
                        <a href="#">MACBOOK APPLE</a>
                        <a href="#">MÁY IN CANON</a>
                        <a href="#">MÀN HÌNH MÁY TÍNH</a>
                        <a href="#">MÀN HÌNH GAMING</a>
                    </div>
                </div>
            </div>

            <div class="main-content-title">
                <div class="list-product-sell">
                    <div class="item-sell">
                        <div class="item-img">
                            <a href="#"><img src="./anh pc/vga.jpg" alt="VGA"></a>
                        </div>
                        <div class="item-info">
                            <div class="item-name"><a href="#">VGA Gigabyte GeForce RTX 3060 WINDFORCE OC 12GB</a></div>
                            <div class="item-rate">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i>
                                <span>(0)</span>
                            </div>
                            <div class="item-code">Mã SP: VGGI0324</div>
                            <div class="item-price">
                                <span class="old-price">8.999.000 đ</span>
                                <div class="current-price-box">
                                    <span class="new-price">7.999.000 đ</span>
                                    <span class="discount-badge">-12%</span>
                                </div>
                            </div>
                            <div class="item-promo">
                                <p>2 khuyến mãi</p>
                            </div>
                        </div>
                        <div class="item-action">
                            <div class="action-left">
                                <a href="#"><i class="fa-solid fa-circle-plus"></i> So sánh</a>
                                <span class="status"><i class="fa-solid fa-check"></i> Còn hàng</span>
                            </div>
                            <div class="action-right"><button type="button"><i class="fa-solid fa-cart-shopping"></i></button></div>
                        </div>
                    </div>

                    <div class="item-sell">
                        <div class="item-img">
                            <a href="#"><img src="./anh pc/pc1.png" alt="CPU"></a>
                        </div>
                        <div class="item-info">
                            <div class="item-name"><a href="#"> PC ULTRA GAMING AI - PCAP TITAN ( I7 12400F - RTX 5060
                                    Ti 16GB - 32GB RAM - 500GB SSD) </a>
                            </div>
                            <div class="item-rate">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i>
                                <span>(0)</span>
                            </div>
                            <div class="item-code">Mã SP: PCI0212</div>
                            <div class="item-price">
                                <span class="old-price">35.999.000 đ</span>
                                <div class="current-price-box">
                                    <span class="new-price" style="color: #CB1C21; font-weight: bold;">Liên hệ</span>
                                </div>
                            </div>
                            <div class="item-promo">
                                <p>1 khuyến mãi</p>
                            </div>
                        </div>
                        <div class="item-action">
                            <div class="action-left">
                                <a href="#"><i class="fa-solid fa-circle-plus"></i> So sánh</a>
                                <span class="status" style="color: #CB1C21;"><i class="fa-solid fa-phone"></i> Đặt
                                    hàng</span>
                            </div>
                            <div class="action-right"><button type="button"><i class="fa-solid fa-cart-shopping"></i></button></div>
                        </div>
                    </div>

                    <div class="item-sell">
                        <div class="item-img">
                            <a href="#"><img src="./anh pc/lap_giga.jpg" alt="Laptop"></a>
                        </div>
                        <div class="item-info">
                            <div class="item-name"><a href="#">Laptop Gigabyte Gaming A16 CMHH2VN893SH</a></div>
                            <div class="item-rate">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i>
                                <span>(0)</span>
                            </div>
                            <div class="item-code">Mã SP: NBGI0049</div>
                            <div class="item-price">
                                <span class="old-price">28.990.000 đ</span>
                                <div class="current-price-box">
                                    <span class="new-price">22.490.000 đ</span>
                                    <span class="discount-badge">-23%</span>
                                </div>
                            </div>
                            <div class="item-promo">
                                <p>3 khuyến mãi</p>
                            </div>
                        </div>
                        <div class="item-action">
                            <div class="action-left">
                                <a href="#"><i class="fa-solid fa-circle-plus"></i> So sánh</a>
                                <span class="status"><i class="fa-solid fa-check"></i> Còn hàng</span>
                            </div>
                            <div class="action-right"><button type="button"><i class="fa-solid fa-cart-shopping"></i></button></div>
                        </div>
                    </div>

                    <div class="item-sell">
                        <div class="item-img">
                            <a href="#"><img src="./anh pc/lap_asus.jpg" alt="Laptop Asus"></a>
                        </div>
                        <div class="item-info">
                            <div class="item-name"><a href="#">Laptop ASUS Gaming V16 V3607VM-RP044W</a></div>
                            <div class="item-rate">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i>
                                <span>(0)</span>
                            </div>
                            <div class="item-code">Mã SP: NBAS1483</div>
                            <div class="item-price">
                                <span class="old-price">37.300.000 đ</span>
                                <div class="current-price-box">
                                    <span class="new-price">32.990.000 đ</span>
                                    <span class="discount-badge">-12%</span>
                                </div>
                            </div>
                            <div class="item-promo">
                                <p>4 khuyến mãi</p>
                            </div>
                        </div>
                        <div class="item-action">
                            <div class="action-left">
                                <a href="#"><i class="fa-solid fa-circle-plus"></i> So sánh</a>
                                <span class="status"><i class="fa-solid fa-check"></i> Còn hàng</span>
                            </div>
                            <div class="action-right"><button type="button"><i class="fa-solid fa-cart-shopping"></i></button></div>
                        </div>
                    </div>

                    <div class="item-sell">
                        <div class="item-img">
                            <a href="#"><img src="./anh pc/minipc.jpg" alt="Mini PC"></a>
                        </div>
                        <div class="item-info">
                            <div class="item-name"><a href="#">Bộ Mini PC ASUS NUC13 PRO Tall NUC13ANHH5</a></div>
                            <div class="item-rate">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i>
                                <span>(0)</span>
                            </div>
                            <div class="item-code">Mã SP: PCIT0122</div>
                            <div class="item-price">
                                <span class="old-price"></span>
                                <div class="current-price-box">
                                    <span class="new-price">9.989.000 đ</span>
                                </div>
                            </div>
                            <div class="item-promo">
                                <p>1 khuyến mãi</p>
                            </div>
                        </div>
                        <div class="item-action">
                            <div class="action-left">
                                <a href="#"><i class="fa-solid fa-circle-plus"></i> So sánh</a>
                                <span class="status"><i class="fa-solid fa-check"></i> Còn hàng</span>
                            </div>
                            <div class="action-right"><button type="button"><i class="fa-solid fa-cart-shopping"></i></button></div>
                        </div>
                    </div>

                    <div class="item-sell">
                        <div class="item-img">
                            <a href="#"><img src="./anh pc/rog_ally.jpg" alt="ROG Ally"></a>
                        </div>
                        <div class="item-info">
                            <div class="item-name"><a href="#">Máy chơi game ASUS ROG Xbox Ally RC71L-NH002W</a></div>
                            <div class="item-rate">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i>
                                <span>(0)</span>
                            </div>
                            <div class="item-code">Mã SP: NBAS1535</div>
                            <div class="item-price">
                                <span class="old-price">14.990.000 đ</span>
                                <div class="current-price-box">
                                    <span class="new-price">13.490.000 đ</span>
                                    <span class="discount-badge">-11%</span>
                                </div>
                            </div>
                            <div class="item-promo">
                                <p>1 khuyến mãi</p>
                            </div>
                        </div>
                        <div class="item-action">
                            <div class="action-left">
                                <a href="#"><i class="fa-solid fa-circle-plus"></i> So sánh</a>
                                <span class="status"><i class="fa-solid fa-check"></i> Còn hàng</span>
                            </div>
                            <div class="action-right"><button type="button"><i class="fa-solid fa-cart-shopping"></i></button></div>
                        </div>
                    </div>

                    <div class="item-sell">
                        <div class="item-img">
                            <a href="#"><img src="./anh pc/monitor_ss.jpg" alt="Màn hình Samsung"></a>
                        </div>
                        <div class="item-info">
                            <div class="item-name"><a href="#">Màn Hình Đồ Họa SAMSUNG ViewFinity S8 LS27B800</a></div>
                            <div class="item-rate">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i>
                                <span>(0)</span>
                            </div>
                            <div class="item-code">Mã SP: MOSS0148</div>
                            <div class="item-price">
                                <span class="old-price">8.589.000 đ</span>
                                <div class="current-price-box">
                                    <span class="new-price">7.689.000 đ</span>
                                    <span class="discount-badge">-11%</span>
                                </div>
                            </div>
                            <div class="item-promo">
                                <p>4 khuyến mãi</p>
                            </div>
                        </div>
                        <div class="item-action">
                            <div class="action-left">
                                <a href="#"><i class="fa-solid fa-circle-plus"></i> So sánh</a>
                                <span class="status"><i class="fa-solid fa-check"></i> Còn hàng</span>
                            </div>
                            <div class="action-right"><button type="button"><i class="fa-solid fa-cart-shopping"></i></button></div>
                        </div>
                    </div>

                    <div class="item-sell">
                        <div class="item-img">
                            <a href="#"><img src="./anh pc/lap_acer.jpg" alt="Laptop Acer"></a>
                        </div>
                        <div class="item-info">
                            <div class="item-name"><a href="#">Laptop Acer Aspire 5 A514-56P-55K5 NX.KHRSV.003</a></div>
                            <div class="item-rate">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i>
                                <span>(0)</span>
                            </div>
                            <div class="item-code">Mã SP: NBAC0403</div>
                            <div class="item-price">
                                <span class="old-price">16.990.000 đ</span>
                                <div class="current-price-box">
                                    <span class="new-price">12.990.000 đ</span>
                                    <span class="discount-badge">-24%</span>
                                </div>
                            </div>
                            <div class="item-promo">
                                <p>2 khuyến mãi</p>
                            </div>
                        </div>
                        <div class="item-action">
                            <div class="action-left">
                                <a href="#"><i class="fa-solid fa-circle-plus"></i> So sánh</a>
                                <span class="status"><i class="fa-solid fa-check"></i> Còn hàng</span>
                            </div>
                            <div class="action-right"><button type="button"><i class="fa-solid fa-cart-shopping"></i></button></div>
                        </div>
                    </div>

                    <div class="item-sell">
                        <div class="item-img">
                            <a href="#"><img src="./anh pc/pc8.jpg" alt="PC Gaming"></a>
                        </div>
                        <div class="item-info">
                            <div class="item-name"><a href="#">PC ULTRA GAMING AI - PCAP TITAN (I5 12400F - RTX
                                    4060)</a></div>
                            <div class="item-rate">
                                <i class="fa-solid fa-star" style="color: #fdd835;"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                <span>(1)</span>
                            </div>
                            <div class="item-code">Mã SP: PCAPT0199</div>
                            <div class="item-price">
                                <span class="old-price">28.000.000 đ</span>
                                <div class="current-price-box">
                                    <span class="new-price">25.399.000 đ</span>
                                    <span class="discount-badge">-10%</span>
                                </div>
                            </div>
                            <div class="item-promo">
                                <p>3 khuyến mãi</p>
                            </div>
                        </div>
                        <div class="item-action">
                            <div class="action-left">
                                <a href="#"><i class="fa-solid fa-circle-plus"></i> So sánh</a>
                                <span class="status" style="color: #CB1C21;"><i class="fa-solid fa-phone"></i> Đặt
                                    hàng</span>
                            </div>
                            <div class="action-right"><button type="button"><i class="fa-solid fa-cart-shopping"></i></button></div>
                        </div>
                    </div>

                    <div class="item-sell">
                        <div class="item-img">
                            <a href="#"><img src="./anh pc/man1.jpg" alt="Samsung Odyssey"></a>
                        </div>
                        <div class="item-info">
                            <div class="item-name"><a href="#">Màn hình Gaming SAMSUNG Odyssey OLED G9 G93SC</a></div>
                            <div class="item-rate">
                                <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i
                                    class="fa-solid fa-star"></i>
                                <span>(0)</span>
                            </div>
                            <div class="item-code">Mã SP: MOSS0185</div>
                            <div class="item-price">
                                <span class="old-price">39.989.000 đ</span>
                                <div class="current-price-box">
                                    <span class="new-price">28.449.000 đ</span>
                                    <span class="discount-badge">-29%</span>
                                </div>
                            </div>
                            <div class="item-promo">
                                <p>4 khuyến mãi</p>
                            </div>
                        </div>
                        <div class="item-action">
                            <div class="action-left">
                                <a href="#"><i class="fa-solid fa-circle-plus"></i> So sánh</a>
                                <span class="status"><i class="fa-solid fa-check"></i> Còn hàng</span>
                            </div>
                            <div class="action-right"><button type="button"><i class="fa-solid fa-cart-shopping"></i></button></div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div class="container">
    </div>

    
</asp:Content>
