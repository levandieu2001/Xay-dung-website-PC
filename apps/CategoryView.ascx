<%@ Control Language="C#" ClassName="CategoryViewControl" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    public string DefaultCategorySlug { get; set; }

    protected CategoryInfo ActiveCategory = null;
    protected List<CategoryInfo> AllCategories = new List<CategoryInfo>();
    protected List<string> AllBrands = new List<string>();
    protected List<ProductInfo> FilteredProducts = new List<ProductInfo>();
    protected List<ProductInfo> PagedProducts = new List<ProductInfo>();
    protected List<ProductInfo> SuggestedProducts = new List<ProductInfo>();

    protected int SelectedCatId = 0;
    protected string Keyword = "";
    protected string SelectedBrand = "";
    protected string SelectedPrice = "";
    protected string SelectedSort = "popular";
    protected int CurrentPage = 1;
    protected int PageSize = 10;
    protected int TotalPages = 1;
    protected bool HasSearchOrFilter = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        AllCategories = DbHelper.GetCategories(true);
        AllBrands = DbHelper.GetAllBrands();

        // Xác định danh mục từ QueryString hoặc DefaultCategorySlug của trang
        if (!string.IsNullOrEmpty(Request.QueryString["catId"]))
        {
            int.TryParse(Request.QueryString["catId"], out SelectedCatId);
        }
        else if (!string.IsNullOrEmpty(DefaultCategorySlug))
        {
            CategoryInfo bySlug = DbHelper.GetCategoryByPageUrl(DefaultCategorySlug);
            if (bySlug != null)
            {
                SelectedCatId = bySlug.CategoryId;
            }
        }

        if (SelectedCatId > 0)
        {
            ActiveCategory = DbHelper.GetCategoryById(SelectedCatId);
        }

        Keyword = (Request.QueryString["q"] ?? "").Trim();
        SelectedBrand = (Request.QueryString["brand"] ?? "").Trim();
        SelectedPrice = (Request.QueryString["price"] ?? "").Trim();
        SelectedSort = string.IsNullOrEmpty(Request.QueryString["sort"]) ? "popular" : Request.QueryString["sort"].Trim();

        if (!string.IsNullOrEmpty(Request.QueryString["page"]))
        {
            int.TryParse(Request.QueryString["page"], out CurrentPage);
            if (CurrentPage < 1) CurrentPage = 1;
        }

        HasSearchOrFilter = !string.IsNullOrEmpty(Keyword) || !string.IsNullOrEmpty(SelectedBrand) || !string.IsNullOrEmpty(SelectedPrice);

        int? catFilter = SelectedCatId > 0 ? (int?)SelectedCatId : null;
        FilteredProducts = DbHelper.SearchProducts(catFilter, Keyword, SelectedBrand, SelectedPrice, SelectedSort, false);

        if (FilteredProducts.Count == 0 && HasSearchOrFilter)
        {
            // Ngoại lệ UC04: Không tìm thấy sản phẩm khớp từ khóa -> gợi ý sản phẩm nổi bật
            SuggestedProducts = DbHelper.GetTopSellingProducts(5, null);
        }

        TotalPages = (int)Math.Ceiling((double)FilteredProducts.Count / PageSize);
        if (TotalPages < 1) TotalPages = 1;
        if (CurrentPage > TotalPages) CurrentPage = TotalPages;

        int startIdx = (CurrentPage - 1) * PageSize;
        for (int i = startIdx; i < FilteredProducts.Count && i < startIdx + PageSize; i++)
        {
            PagedProducts.Add(FilteredProducts[i]);
        }
    }

    protected string BuildFilterUrl(int pageNum)
    {
        string basePage = Request.Url.AbsolutePath;
        List<string> qs = new List<string>();
        if (!string.IsNullOrEmpty(Request.QueryString["catId"]))
            qs.Add("catId=" + SelectedCatId);
        if (!string.IsNullOrEmpty(Keyword))
            qs.Add("q=" + HttpUtility.UrlEncode(Keyword));
        if (!string.IsNullOrEmpty(SelectedBrand))
            qs.Add("brand=" + HttpUtility.UrlEncode(SelectedBrand));
        if (!string.IsNullOrEmpty(SelectedPrice))
            qs.Add("price=" + HttpUtility.UrlEncode(SelectedPrice));
        if (!string.IsNullOrEmpty(SelectedSort) && SelectedSort != "popular")
            qs.Add("sort=" + HttpUtility.UrlEncode(SelectedSort));
        if (pageNum > 1)
            qs.Add("page=" + pageNum);

        return qs.Count > 0 ? (basePage + "?" + string.Join("&", qs.ToArray())) : basePage;
    }
</script>

<div class="container">
    <div class="pcm-page-card">
        <div class="breadcrumb">
            <a href="Home.aspx"><i class="fa-solid fa-house"></i> Trang chủ</a> /
            <% if (ActiveCategory != null) { %>
                <a href="Products.aspx">Danh mục sản phẩm</a> /
                <span><%= HttpUtility.HtmlEncode(ActiveCategory.CategoryName) %></span>
            <% } else { %>
                <span>Tất cả máy tính &amp; linh kiện</span>
            <% } %>
        </div>

        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; margin-bottom:10px;">
            <div>
                <h1 class="pcm-page-title" style="margin-bottom:6px;">
                    <% if (ActiveCategory != null) { %>
                        <%= HttpUtility.HtmlEncode(ActiveCategory.CategoryName) %>
                    <% } else if (!string.IsNullOrEmpty(Keyword)) { %>
                        KẾT QUẢ TÌM KIẾM: "<%= HttpUtility.HtmlEncode(Keyword) %>"
                    <% } else { %>
                        DANH SÁCH MÁY TÍNH &amp; LINH KIỆN
                    <% } %>
                </h1>
                <% if (ActiveCategory != null && !string.IsNullOrEmpty(ActiveCategory.Description)) { %>
                    <p style="color:#64748b; font-size:14px; margin-bottom:10px;"><%= HttpUtility.HtmlEncode(ActiveCategory.Description) %></p>
                <% } %>
            </div>
            <div style="font-size:14px; color:#334155; font-weight:600;">
                Tìm thấy <span style="color:#CB1C21; font-size:16px; font-weight:800;"><%= FilteredProducts.Count %></span> sản phẩm
            </div>
        </div>

        <!-- Thanh phân loại nhanh theo Tag (Quick Category Filters) -->
        <div class="quick-filter-pills" style="display:flex; gap:8px; overflow-x:auto; padding-bottom:10px; margin-bottom:12px; scrollbar-width:thin;">
            <a href="Products.aspx" class="quick-pill <%= (string.IsNullOrEmpty(Keyword) && SelectedCatId == 0 ? "active" : "") %>">
                <i class="fa-solid fa-border-all"></i> Tất cả
            </a>
            <a href="Products.aspx?q=Laptop" class="quick-pill <%= (string.Equals(Keyword, "Laptop", StringComparison.OrdinalIgnoreCase) ? "active" : "") %>">
                <i class="fa-solid fa-laptop"></i> Laptop
            </a>
            <a href="Products.aspx?q=PC" class="quick-pill <%= (string.Equals(Keyword, "PC", StringComparison.OrdinalIgnoreCase) ? "active" : "") %>">
                <i class="fa-solid fa-desktop"></i> PC Máy tính
            </a>
            <a href="Products.aspx?q=VGA" class="quick-pill <%= (string.Equals(Keyword, "VGA", StringComparison.OrdinalIgnoreCase) ? "active" : "") %>">
                <i class="fa-solid fa-microchip"></i> Card VGA
            </a>
            <a href="Products.aspx?catId=7" class="quick-pill <%= (SelectedCatId == 7 ? "active" : "") %>">
                <i class="fa-solid fa-display"></i> Màn hình &amp; Máy in
            </a>
            <a href="Products.aspx?catId=8" class="quick-pill <%= (SelectedCatId == 8 ? "active" : "") %>">
                <i class="fa-solid fa-keyboard"></i> Chuột &amp; Bàn phím
            </a>
            <a href="Products.aspx?catId=6" class="quick-pill <%= (SelectedCatId == 6 ? "active" : "") %>">
                <i class="fa-solid fa-memory"></i> RAM / CPU / SSD
            </a>
            <a href="Products.aspx?catId=10" class="quick-pill <%= (SelectedCatId == 10 ? "active" : "") %>">
                <i class="fa-solid fa-headphones"></i> Loa &amp; Tai nghe
            </a>
            <a href="Products.aspx?catId=11" class="quick-pill <%= (SelectedCatId == 11 ? "active" : "") %>">
                <i class="fa-solid fa-snowflake"></i> Tản nhiệt
            </a>
            <a href="Products.aspx?catId=12" class="quick-pill <%= (SelectedCatId == 12 ? "active" : "") %>">
                <i class="fa-solid fa-wifi"></i> Mạng &amp; Camera
            </a>
            <a href="Products.aspx?catId=13" class="quick-pill <%= (SelectedCatId == 13 ? "active" : "") %>">
                <i class="fa-solid fa-gamepad"></i> Console &amp; Game
            </a>
            <a href="Products.aspx?catId=14" class="quick-pill <%= (SelectedCatId == 14 ? "active" : "") %>">
                <i class="fa-solid fa-clock"></i> Smartwatch
            </a>
        </div>

        <!-- Bộ lọc & Tìm kiếm sản phẩm (UC03, UC04) -->
        <div class="filter-bar">
            <div class="filter-group" style="flex:1; min-width:200px;">
                <label>Từ khóa (Tên, Mã SP, Cấu hình)</label>
                <input type="text" id="fltKeyword" class="filter-control"
                       value="<%= HttpUtility.HtmlAttributeEncode(Keyword) %>"
                       placeholder="VD: VGA, PC, Laptop, RTX 4060..."
                       onkeydown="if(event.key==='Enter'){event.preventDefault();applyProductFilter();}" />
            </div>

            <div class="filter-group">
                <label>Danh mục</label>
                <select id="fltCategory" class="filter-control" onchange="applyProductFilter();">
                    <option value="0">-- Tất cả danh mục --</option>
                    <% for (int i = 0; i < AllCategories.Count; i++) {
                           CategoryInfo c = AllCategories[i]; %>
                        <option value="<%= c.CategoryId %>" <%= (c.CategoryId == SelectedCatId ? "selected='selected'" : "") %>>
                            <%= HttpUtility.HtmlEncode(c.CategoryName) %> (<%= c.ProductCount %>)
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="filter-group">
                <label>Hãng sản xuất</label>
                <select id="fltBrand" class="filter-control" onchange="applyProductFilter();">
                    <option value="">-- Tất cả hãng --</option>
                    <% for (int i = 0; i < AllBrands.Count; i++) {
                           string b = AllBrands[i]; %>
                        <option value="<%= HttpUtility.HtmlAttributeEncode(b) %>" <%= (string.Equals(b, SelectedBrand, StringComparison.OrdinalIgnoreCase) ? "selected='selected'" : "") %>>
                            <%= HttpUtility.HtmlEncode(b) %>
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="filter-group">
                <label>Khoảng giá</label>
                <select id="fltPrice" class="filter-control" onchange="applyProductFilter();">
                    <option value="" <%= (SelectedPrice == "" ? "selected='selected'" : "") %>>-- Mọi mức giá --</option>
                    <option value="under10" <%= (SelectedPrice == "under10" ? "selected='selected'" : "") %>>Dưới 10 triệu</option>
                    <option value="10to20" <%= (SelectedPrice == "10to20" ? "selected='selected'" : "") %>>Từ 10 - 20 triệu</option>
                    <option value="20to30" <%= (SelectedPrice == "20to30" ? "selected='selected'" : "") %>>Từ 20 - 30 triệu</option>
                    <option value="over30" <%= (SelectedPrice == "over30" ? "selected='selected'" : "") %>>Trên 30 triệu</option>
                </select>
            </div>

            <div class="filter-group">
                <label>Sắp xếp theo</label>
                <select id="fltSort" class="filter-control" onchange="applyProductFilter();">
                    <option value="popular" <%= (SelectedSort == "popular" ? "selected='selected'" : "") %>>Bán chạy nhất</option>
                    <option value="newest" <%= (SelectedSort == "newest" ? "selected='selected'" : "") %>>Mới nhất</option>
                    <option value="price_asc" <%= (SelectedSort == "price_asc" ? "selected='selected'" : "") %>>Giá tăng dần</option>
                    <option value="price_desc" <%= (SelectedSort == "price_desc" ? "selected='selected'" : "") %>>Giá giảm dần</option>
                </select>
            </div>

            <div class="filter-group" style="flex-direction:row; gap:8px;">
                <button type="button" class="btn-pcm btn-pcm-primary" onclick="applyProductFilter();">
                    <i class="fa-solid fa-filter"></i> Lọc / Tìm kiếm
                </button>
                <a href="Products.aspx" class="btn-pcm btn-pcm-outline" title="Xóa bộ lọc">
                    <i class="fa-solid fa-rotate-left"></i> Đặt lại
                </a>
            </div>
        </div>

        <% if (HasSearchOrFilter) { %>
            <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:14px; font-size:13px; color:#475569;">
                <span style="font-weight:700;"><i class="fa-solid fa-filter-circle-dollar"></i> Đang lọc:</span>
                <% if (!string.IsNullOrEmpty(Keyword)) { %>
                    <span class="active-filter-badge">
                        Từ khóa: <strong><%= HttpUtility.HtmlEncode(Keyword) %></strong>
                        <a href="javascript:void(0);" onclick="document.getElementById('fltKeyword').value='';applyProductFilter();"><i class="fa-solid fa-xmark"></i></a>
                    </span>
                <% } %>
                <% if (SelectedCatId > 0 && ActiveCategory != null) { %>
                    <span class="active-filter-badge">
                        Danh mục: <strong><%= HttpUtility.HtmlEncode(ActiveCategory.CategoryName) %></strong>
                        <a href="javascript:void(0);" onclick="document.getElementById('fltCategory').value='0';applyProductFilter();"><i class="fa-solid fa-xmark"></i></a>
                    </span>
                <% } %>
                <% if (!string.IsNullOrEmpty(SelectedBrand)) { %>
                    <span class="active-filter-badge">
                        Hãng: <strong><%= HttpUtility.HtmlEncode(SelectedBrand) %></strong>
                        <a href="javascript:void(0);" onclick="document.getElementById('fltBrand').value='';applyProductFilter();"><i class="fa-solid fa-xmark"></i></a>
                    </span>
                <% } %>
                <% if (!string.IsNullOrEmpty(SelectedPrice)) { %>
                    <span class="active-filter-badge">
                        Khoảng giá: <strong><%= HttpUtility.HtmlEncode(SelectedPrice == "under10" ? "< 10 triệu" : SelectedPrice == "10to20" ? "10 - 20 triệu" : SelectedPrice == "20to30" ? "20 - 30 triệu" : "> 30 triệu") %></strong>
                        <a href="javascript:void(0);" onclick="document.getElementById('fltPrice').value='';applyProductFilter();"><i class="fa-solid fa-xmark"></i></a>
                    </span>
                <% } %>
                <a href="Products.aspx" style="color:#CB1C21; font-weight:700; text-decoration:none; margin-left:6px;">Xóa tất cả bộ lọc</a>
            </div>
        <% } %>

        <!-- Danh sách sản phẩm hiển thị dạng lưới (UC03, UC04) -->
        <% if (PagedProducts.Count > 0) { %>
            <div class="list-product-sell">
                <% for (int i = 0; i < PagedProducts.Count; i++) { %>
                    <%= UiHelper.RenderProductCard(PagedProducts[i]) %>
                <% } %>
            </div>

            <% if (TotalPages > 1) { %>
                <div class="pcm-pagination">
                    <% for (int p = 1; p <= TotalPages; p++) {
                           if (p == CurrentPage) { %>
                        <span class="active"><%= p %></span>
                    <%     } else { %>
                        <a href="<%= BuildFilterUrl(p) %>"><%= p %></a>
                    <%     }
                       } %>
                </div>
            <% } %>
        <% } else if (HasSearchOrFilter) { %>
            <!-- Ngoại lệ UC04: Không tìm thấy sản phẩm phù hợp -> Hiển thị thông báo & gợi ý sản phẩm nổi bật -->
            <div class="pcm-alert pcm-alert-warning" style="text-align:center; padding:24px;">
                <i class="fa-solid fa-magnifying-glass-minus" style="font-size:28px; display:block; margin-bottom:8px; color:#d97706;"></i>
                <strong style="font-size:16px;">Không tìm thấy sản phẩm phù hợp với điều kiện tìm kiếm của bạn!</strong>
                <p style="margin-top:6px;">Vui lòng thử lại với từ khóa khác hoặc tham khảo các sản phẩm nổi bật dưới đây:</p>
            </div>

            <% if (SuggestedProducts.Count > 0) { %>
                <h3 style="color:#3D52BF; font-size:18px; margin:20px 0 12px 0; text-transform:uppercase;">
                    <i class="fa-solid fa-bolt"></i> Gợi ý sản phẩm nổi bật
                </h3>
                <div class="list-product-sell">
                    <% for (int i = 0; i < SuggestedProducts.Count; i++) { %>
                        <%= UiHelper.RenderProductCard(SuggestedProducts[i]) %>
                    <% } %>
                </div>
            <% } %>
        <% } else { %>
            <!-- Ngoại lệ UC03: Danh mục hiện chưa có sản phẩm nào -->
            <div class="pcm-alert pcm-alert-info" style="text-align:center; padding:30px;">
                <i class="fa-solid fa-box-open" style="font-size:32px; display:block; margin-bottom:10px;"></i>
                <strong style="font-size:16px;">Chưa có sản phẩm trong danh mục này.</strong>
                <p style="margin-top:8px;"><a href="Products.aspx" class="btn-pcm btn-pcm-primary">Xem tất cả sản phẩm</a></p>
            </div>
        <% } %>
    </div>
</div>

<script type="text/javascript">
    function applyProductFilter() {
        var kw = document.getElementById("fltKeyword").value.trim();
        var cat = document.getElementById("fltCategory").value;
        var brand = document.getElementById("fltBrand").value;
        var price = document.getElementById("fltPrice").value;
        var sort = document.getElementById("fltSort").value;

        var params = [];
        if (cat && cat !== "0") params.push("catId=" + encodeURIComponent(cat));
        if (kw) params.push("q=" + encodeURIComponent(kw));
        if (brand) params.push("brand=" + encodeURIComponent(brand));
        if (price) params.push("price=" + encodeURIComponent(price));
        if (sort && sort !== "popular") params.push("sort=" + encodeURIComponent(sort));

        window.location.href = "Products.aspx" + (params.length > 0 ? ("?" + params.join("&")) : "");
    }
</script>
