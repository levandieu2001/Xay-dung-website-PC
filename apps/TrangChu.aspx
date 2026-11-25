<%@ Page Language="C#" MasterPageFile="~/BoCucChung.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    protected List<CategoryInfo> SidebarCategories = new List<CategoryInfo>();
    protected List<ProductInfo> DealProducts = new List<ProductInfo>();
    protected List<ProductInfo> BestSellingProducts = new List<ProductInfo>();
    protected int SelectedTabCatId = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        List<CategoryInfo> allCats = DbHelper.GetCategories(true);
        for (int i = 0; i < allCats.Count && i < 12; i++)
        {
            SidebarCategories.Add(allCats[i]);
        }

        DealProducts = DbHelper.GetDealProducts(16);

        if (!string.IsNullOrEmpty(Request.QueryString["tabCat"]))
        {
            int.TryParse(Request.QueryString["tabCat"], out SelectedTabCatId);
        }

        int? catFilter = SelectedTabCatId > 0 ? (int?)SelectedTabCatId : null;
        BestSellingProducts = DbHelper.GetTopSellingProducts(10, catFilter);
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="main-content">
        <div class="container">
            <div class="left">
                <% for (int i = 0; i < SidebarCategories.Count; i++) {
                       CategoryInfo c = SidebarCategories[i];
                       string link = !string.IsNullOrEmpty(c.PageUrl) ? c.PageUrl : ("SanPham.aspx?catId=" + c.CategoryId); %>
                    <ul>
                        <li><a href="<%= link %>"><img src="<%= HttpUtility.HtmlAttributeEncode(c.IconPath) %>" alt=""></a></li>
                        <li><a href="<%= link %>"><%= HttpUtility.HtmlEncode(c.CategoryName) %></a></li>
                    </ul>
                <% } %>
            </div>

            <div class="mid">
                <div class="mid-top1">
                    <div class="img-all">
                        <img src="./HinhAnh/sale.jpg" alt="" class="active">
                        <img src="./HinhAnh/sale2.jpg" alt="">
                        <img src="./HinhAnh/sale3.jpg" alt="">
                        <img src="./HinhAnh/sale4.jpg" alt="">
                        <img src="./HinhAnh/sale5.jpg" alt="">
                        <img src="./HinhAnh/sale6.jpg" alt="">
                        <img src="./HinhAnh/sale7.jpg" alt="">
                        <img src="./HinhAnh/sale8.jpg" alt="">
                        <img src="./HinhAnh/sale9.jpg" alt="">
                        <img src="./HinhAnh/sale10.jpg" alt="">
                    </div>
                </div>
                <div class="mid-top2">
                    <div class="dots">
                        <span class="dot active"></span>
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
                        <a href="MayTinhXachTayChoiGame.aspx"><img src="./HinhAnh/a1.png" alt="Laptop Gaming"></a>
                        <a href="MayTinhChoiGame.aspx"><img src="./HinhAnh/a2.png" alt="PC Gaming"></a>
                        <a href="LinhKien.aspx"><img src="./HinhAnh/a3.png" alt="Linh kiện máy tính"></a>
                    </div>
                </div>
            </div>

            <div class="right">
                <div class="img-gift">
                    <a href="SanPham.aspx"><img src="./HinhAnh/gift1.png" alt=""></a>
                    <a href="SanPham.aspx"><img src="./HinhAnh/gift2.png" alt=""></a>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <div class="home-deal">
            <div class="home-top">
                <img src="./HinhAnh/home-deal-bg-2023.png" alt="">
                <span><img src="./HinhAnh/clock2.gif" alt=""></span>
                <p class="text-deal">SALE SẬP SÀN DEAL NGẬP TRÀN</p>
            </div>
            <div class="home-bottom">
                <div class="home-btm-left">
                    <div class="box-left">
                        <div class="b1">
                            <div class="date-deal">FLASH DEAL</div>
                            <span>Đang diễn ra</span>
                        </div>
                    </div>
                </div>
                <div class="home-btm-right">
                    <div class="box-right">
                        <div class="date-deal">Mã giảm: PCM500K | GIAM5</div>
                        <span></span>
                    </div>
                </div>
            </div>
            <div class="main-content-home" id="dealSliderContainer">
                <button type="button" class="click-left-silde" id="dealPrevBtn" aria-label="Xem sản phẩm trước">
                    <i class="fa-solid fa-chevron-left"></i>
                </button>

                <div class="deal-slider-viewport" id="dealViewport">
                    <div class="product-track" id="dealTrack">
                        <% for (int i = 0; i < DealProducts.Count; i++) { %>
                            <%= UiHelper.RenderDealCard(DealProducts[i]) %>
                        <% } %>
                    </div>
                </div>

                <button type="button" class="click-right-silde" id="dealNextBtn" aria-label="Xem sản phẩm kế tiếp">
                    <i class="fa-solid fa-chevron-right"></i>
                </button>
            </div>
        </div>

        <div class="box-sell">
            <div class="title-container">
                <div class="title-left"><span>SẢN PHẨM BÁN CHẠY</span></div>
                <div class="home-box"></div>
                <div class="title-right">
                    <div class="title-right-item">
                        <a href="TrangChu.aspx" style="<%= (SelectedTabCatId == 0 ? "color:#3D52BF;font-weight:bold;text-decoration:underline;" : "") %>">TẤT CẢ</a>
                        <a href="TrangChu.aspx?tabCat=3" style="<%= (SelectedTabCatId == 3 ? "color:#3D52BF;font-weight:bold;text-decoration:underline;" : "") %>">PC GAMING</a>
                        <a href="TrangChu.aspx?tabCat=1" style="<%= (SelectedTabCatId == 1 ? "color:#3D52BF;font-weight:bold;text-decoration:underline;" : "") %>">LAPTOP GAMING</a>
                        <a href="TrangChu.aspx?tabCat=2" style="<%= (SelectedTabCatId == 2 ? "color:#3D52BF;font-weight:bold;text-decoration:underline;" : "") %>">LAPTOP VĂN PHÒNG</a>
                        <a href="TrangChu.aspx?tabCat=6" style="<%= (SelectedTabCatId == 6 ? "color:#3D52BF;font-weight:bold;text-decoration:underline;" : "") %>">LINH KIỆN PC</a>
                        <a href="TrangChu.aspx?tabCat=7" style="<%= (SelectedTabCatId == 7 ? "color:#3D52BF;font-weight:bold;text-decoration:underline;" : "") %>">MÀN HÌNH MÁY TÍNH</a>
                    </div>
                </div>
            </div>

            <div class="main-content-title">
                <div class="list-product-sell">
                    <% for (int i = 0; i < BestSellingProducts.Count; i++) { %>
                        <%= UiHelper.RenderProductCard(BestSellingProducts[i]) %>
                    <% } %>
                </div>
                <div style="text-align:center; margin-top:20px;">
                    <a href="SanPham.aspx" class="btn-pcm btn-pcm-primary" style="padding:0 28px; height:42px;">
                        <i class="fa-solid fa-grid-2"></i> XEM TẤT CẢ SẢN PHẨM &amp; BỘ LỌC CẤU HÌNH
                    </a>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
