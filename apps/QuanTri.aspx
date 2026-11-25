<%@ Page Language="C#" MasterPageFile="~/BoCucChung.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>
<%@ Import Namespace="PCMComputer" %>

<asp:Content ID="HeadContentAdmin" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</asp:Content>

<script runat="server">
    protected UserInfo CurrentUser = null;
    protected bool IsAuthorizedAdmin = false;
    protected string ActiveTab = "stats"; // stats | products | categories | orders | users | promotions
    protected string AlertMessage = "";
    protected string AlertCss = "pcm-alert-success";

    // Tab 1: Thống kê doanh thu & Biểu đồ (UC14)
    protected string StatsPeriod = "all"; // all | today | month | quarter | custom
    protected string StatsFromStr = "";
    protected string StatsToStr = "";
    protected RevenueStats StatsData = new RevenueStats();
    protected List<ProductInfo> TopSellingList = new List<ProductInfo>();
    protected List<ProductInfo> LowStockList = new List<ProductInfo>();
    protected List<OrderInfo> RecentOrdersList = new List<OrderInfo>();

    // Dữ liệu JSON cho Chart.js
    protected string TimelineLabelsJson = "[]";
    protected string TimelineRevenueJson = "[]";
    protected string TimelineOrdersJson = "[]";

    protected string StatusLabelsJson = "[]";
    protected string StatusCountsJson = "[]";
    protected string StatusColorsJson = "[]";

    protected string TopProdLabelsJson = "[]";
    protected string TopProdFullNamesJson = "[]";
    protected string TopProdSoldCountJson = "[]";
    protected string TopProdRevenueJson = "[]";

    protected string CatLabelsJson = "[]";
    protected string CatRevenueJson = "[]";
    protected string CatSoldJson = "[]";

    // Tab 2: Quản lý sản phẩm (UC09)
    protected List<ProductInfo> AllProducts = new List<ProductInfo>();
    protected ProductInfo EditProd = null;

    // Tab 3: Quản lý danh mục (UC10)
    protected List<CategoryInfo> AllCategories = new List<CategoryInfo>();
    protected CategoryInfo EditCat = null;

    // Tab 4: Quản lý đơn hàng (UC11)
    protected string OrderFilterStatus = "";
    protected List<OrderInfo> AllOrders = new List<OrderInfo>();

    // Tab 5: Quản lý tài khoản & phân quyền (UC12)
    protected List<UserInfo> AllUsers = new List<UserInfo>();

    // Tab 6: Quản lý khuyến mãi (UC13)
    protected List<PromotionInfo> AllPromotions = new List<PromotionInfo>();
    protected PromotionInfo EditPromo = null;

    protected void Page_Load(object sender, EventArgs e)
    {
        CurrentUser = SecurityHelper.GetCurrentUser();
        if (CurrentUser == null)
        {
            Response.Redirect("DangNhap.aspx?returnUrl=QuanTri.aspx");
            return;
        }

        IsAuthorizedAdmin = SecurityHelper.IsAdmin();
        if (!IsAuthorizedAdmin)
        {
            return;
        }

        if (!string.IsNullOrEmpty(Request.QueryString["tab"]))
            ActiveTab = Request.QueryString["tab"].Trim().ToLower();
        if (!string.IsNullOrEmpty(Request.Form["adminActiveTab"]))
            ActiveTab = Request.Form["adminActiveTab"].Trim().ToLower();

        if (IsPostBack)
        {
            string action = Request.Form["adminAction"];
            HandleAdminPostBack(action);
        }

        LoadAdminTabData();
    }

    private void HandleAdminPostBack(string action)
    {
        if (string.IsNullOrEmpty(action)) return;

        // 1. Lưu sản phẩm (Thêm mới / Chỉnh sửa - UC09)
        if (action == "save_product")
        {
            ActiveTab = "products";
            ProductInfo p = new ProductInfo();
            int pid = 0;
            int.TryParse(Request.Form["ProdId"], out pid);
            p.ProductId = pid;
            p.ProductCode = (Request.Form["ProdCode"] ?? "").Trim();
            p.ProductName = (Request.Form["ProdName"] ?? "").Trim();
            int catId = 1;
            int.TryParse(Request.Form["ProdCatId"], out catId);
            p.CategoryId = catId;
            p.Brand = (Request.Form["ProdBrand"] ?? "").Trim();
            decimal oldP = 0, price = 0;
            decimal.TryParse(Request.Form["ProdOldPrice"], out oldP);
            decimal.TryParse(Request.Form["ProdPrice"], out price);
            p.OldPrice = oldP;
            p.Price = price;
            int stock = 0, war = 24;
            int.TryParse(Request.Form["ProdStock"], out stock);
            int.TryParse(Request.Form["ProdWarranty"], out war);
            p.StockQuantity = stock;
            p.WarrantyMonths = war;
            p.ImageUrl = (Request.Form["ProdImage"] ?? "").Trim();
            p.Specifications = (Request.Form["ProdSpecs"] ?? "").Trim();
            p.Description = (Request.Form["ProdDesc"] ?? "").Trim();
            p.IsDeal = Request.Form["ProdIsDeal"] == "1";
            p.Status = (Request.Form["ProdStatus"] ?? "Đang kinh doanh").Trim();

            string err;
            if (DbHelper.AdminSaveProduct(p, out err))
            {
                AlertCss = "pcm-alert-success";
                AlertMessage = (pid > 0) ? "Đã cập nhật thông tin sản phẩm thành công!" : "Đã thêm sản phẩm mới vào hệ thống thành công!";
            }
            else
            {
                AlertCss = "pcm-alert-error";
                AlertMessage = err;
            }
        }
        // 2. Xóa sản phẩm (Kiểm tra ngoại lệ đã có trong hóa đơn -> Ngừng kinh doanh - UC09)
        else if (action == "delete_product")
        {
            ActiveTab = "products";
            int targetId = 0;
            int.TryParse(Request.Form["adminTargetId"], out targetId);
            if (targetId > 0)
            {
                string msg;
                bool softDeleted;
                DbHelper.AdminDeleteProduct(targetId, out msg, out softDeleted);
                AlertCss = softDeleted ? "pcm-alert-warning" : "pcm-alert-success";
                AlertMessage = msg;
            }
        }
        // 3. Lưu danh mục (UC10)
        else if (action == "save_category")
        {
            ActiveTab = "categories";
            CategoryInfo c = new CategoryInfo();
            int cid = 0;
            int.TryParse(Request.Form["CatId"], out cid);
            c.CategoryId = cid;
            c.CategoryName = (Request.Form["CatName"] ?? "").Trim();
            c.Slug = (Request.Form["CatSlug"] ?? "").Trim();
            c.PageUrl = (Request.Form["CatPageUrl"] ?? "SanPham.aspx").Trim();
            c.IconPath = (Request.Form["CatIcon"] ?? "./BieuTuong/linhkien.png").Trim();
            c.Description = (Request.Form["CatDesc"] ?? "").Trim();
            int ord = 1;
            int.TryParse(Request.Form["CatOrder"], out ord);
            c.DisplayOrder = ord;
            c.IsActive = Request.Form["CatActive"] != "0";

            string err;
            if (DbHelper.SaveCategory(c, out err))
            {
                AlertCss = "pcm-alert-success";
                AlertMessage = (cid > 0) ? "Cập nhật danh mục thành công!" : "Thêm danh mục sản phẩm mới thành công!";
            }
            else
            {
                AlertCss = "pcm-alert-error";
                AlertMessage = err;
            }
        }
        // 4. Xóa danh mục (Kiểm tra ngoại lệ còn chứa sản phẩm trực thuộc - UC10)
        else if (action == "delete_category")
        {
            ActiveTab = "categories";
            int targetId = 0;
            int.TryParse(Request.Form["adminTargetId"], out targetId);
            if (targetId > 0)
            {
                string err;
                if (DbHelper.DeleteCategory(targetId, out err))
                {
                    AlertCss = "pcm-alert-success";
                    AlertMessage = "Đã xóa danh mục sản phẩm thành công.";
                }
                else
                {
                    AlertCss = "pcm-alert-error";
                    AlertMessage = err;
                }
            }
        }
        // 5. Cập nhật trạng thái đơn hàng (UC11)
        else if (action == "update_order")
        {
            ActiveTab = "orders";
            int ordId = 0;
            int.TryParse(Request.Form["adminTargetId"], out ordId);
            string newSt = Request.Form["ordStatus_" + ordId] ?? "";
            string note = Request.Form["ordNote_" + ordId] ?? "";
            if (ordId > 0 && !string.IsNullOrEmpty(newSt))
            {
                string msg;
                bool ok = DbHelper.UpdateOrderStatus(ordId, newSt, CurrentUser.Username, note, false, out msg);
                AlertCss = ok ? "pcm-alert-success" : "pcm-alert-error";
                AlertMessage = msg;
            }
        }
        // 6. Tạo tài khoản nhân viên / người dùng mới (UC12)
        else if (action == "create_user")
        {
            ActiveTab = "users";
            string uName = Request.Form["NewUsername"] ?? "";
            string uPass = Request.Form["NewPassword"] ?? "";
            string uFull = Request.Form["NewFullName"] ?? "";
            string uEmail = Request.Form["NewEmail"] ?? "";
            string uPhone = Request.Form["NewPhone"] ?? "";
            string uAddr = Request.Form["NewAddress"] ?? "";
            string uRole = Request.Form["NewRole"] ?? "Staff";

            string err;
            if (DbHelper.AdminCreateUser(uName, uPass, uFull, uEmail, uPhone, uAddr, uRole, out err))
            {
                AlertCss = "pcm-alert-success";
                AlertMessage = "Tạo tài khoản mới (" + uName + " - Quyền: " + SecurityHelper.GetRoleLabel(uRole) + ") thành công!";
            }
            else
            {
                AlertCss = "pcm-alert-error";
                AlertMessage = err;
            }
        }
        // 7. Cập nhật phân quyền & Khóa/Mở khóa tài khoản (Kiểm tra ngoại lệ tự khóa Admin - UC12)
        else if (action == "update_user_role")
        {
            ActiveTab = "users";
            int targetUid = 0;
            int.TryParse(Request.Form["adminTargetId"], out targetUid);
            string newRole = Request.Form["userRole_" + targetUid] ?? "Customer";
            bool isLocked = Request.Form["userLock_" + targetUid] == "1";

            string err;
            if (DbHelper.AdminUpdateUserRoleAndLock(CurrentUser.UserId, targetUid, newRole, isLocked, out err))
            {
                AlertCss = "pcm-alert-success";
                AlertMessage = "Đã cập nhật phân quyền và trạng thái tài khoản thành công!";
            }
            else
            {
                AlertCss = "pcm-alert-error";
                AlertMessage = err;
            }
        }
        // 8. Lưu chương trình khuyến mãi / Mã giảm giá (Kiểm tra ngày và mức giảm - UC13)
        else if (action == "save_promotion")
        {
            ActiveTab = "promotions";
            PromotionInfo pr = new PromotionInfo();
            int prid = 0;
            int.TryParse(Request.Form["PromoId"], out prid);
            pr.PromotionId = prid;
            pr.PromotionName = (Request.Form["PromoName"] ?? "").Trim();
            pr.VoucherCode = (Request.Form["PromoCode"] ?? "").Trim().ToUpper();
            pr.DiscountType = (Request.Form["PromoType"] ?? "AMOUNT").Trim();
            decimal dVal = 0, minOrd = 0, maxDisc = 0;
            decimal.TryParse(Request.Form["PromoValue"], out dVal);
            decimal.TryParse(Request.Form["PromoMinOrder"], out minOrd);
            decimal.TryParse(Request.Form["PromoMaxDiscount"], out maxDisc);
            pr.DiscountValue = dVal;
            pr.MinOrderAmount = minOrd;
            pr.MaxDiscountAmount = maxDisc;
            int lim = 100;
            int.TryParse(Request.Form["PromoLimit"], out lim);
            pr.UsageLimit = lim;

            DateTime sDate = DateTime.Now.Date;
            DateTime eDate = DateTime.Now.Date.AddMonths(1);
            DateTime.TryParse(Request.Form["PromoStart"], out sDate);
            DateTime.TryParse(Request.Form["PromoEnd"], out eDate);
            pr.StartDate = sDate;
            pr.EndDate = eDate;
            pr.Description = (Request.Form["PromoDesc"] ?? "").Trim();
            pr.IsActive = Request.Form["PromoActive"] != "0";

            string err;
            if (DbHelper.SavePromotion(pr, out err))
            {
                AlertCss = "pcm-alert-success";
                AlertMessage = "Đã lưu chương trình khuyến mãi (" + pr.VoucherCode + ") thành công!";
            }
            else
            {
                AlertCss = "pcm-alert-error";
                AlertMessage = err;
            }
        }
    }

    private void LoadAdminTabData()
    {
        AllCategories = DbHelper.GetCategories(false);
        AllProducts = DbHelper.SearchProducts(null, "", "", "", "newest", true);
        OrderFilterStatus = (Request.QueryString["ost"] ?? "").Trim();
        AllOrders = DbHelper.GetAllOrders(OrderFilterStatus, "");
        AllUsers = DbHelper.GetAllUsers("", "");
        AllPromotions = DbHelper.GetAllPromotions(false);

        // Chế độ sửa Sản phẩm
        int editPid = 0;
        if (int.TryParse(Request.QueryString["editProd"], out editPid) && editPid > 0)
        {
            EditProd = DbHelper.GetProductById(editPid);
            ActiveTab = "products";
        }

        // Chế độ sửa Danh mục
        int editCid = 0;
        if (int.TryParse(Request.QueryString["editCat"], out editCid) && editCid > 0)
        {
            EditCat = DbHelper.GetCategoryById(editCid);
            ActiveTab = "categories";
        }

        // Chế độ sửa Khuyến mãi
        int editPrId = 0;
        if (int.TryParse(Request.QueryString["editPromo"], out editPrId) && editPrId > 0)
        {
            for (int i = 0; i < AllPromotions.Count; i++)
            {
                if (AllPromotions[i].PromotionId == editPrId)
                {
                    EditPromo = AllPromotions[i];
                    break;
                }
            }
            ActiveTab = "promotions";
        }

        // Thống kê doanh thu theo tiêu chí thời gian (UC14)
        StatsPeriod = string.IsNullOrEmpty(Request.QueryString["period"]) ? "all" : Request.QueryString["period"].Trim();
        DateTime? fromDate = null;
        DateTime? toDate = null;
        DateTime now = DateTime.Now;

        if (StatsPeriod == "today")
        {
            fromDate = now.Date;
            toDate = now.Date.AddDays(1).AddSeconds(-1);
        }
        else if (StatsPeriod == "month")
        {
            fromDate = new DateTime(now.Year, now.Month, 1);
            toDate = fromDate.Value.AddMonths(1).AddSeconds(-1);
        }
        else if (StatsPeriod == "quarter")
        {
            int qStartMonth = ((now.Month - 1) / 3) * 3 + 1;
            fromDate = new DateTime(now.Year, qStartMonth, 1);
            toDate = fromDate.Value.AddMonths(3).AddSeconds(-1);
        }
        else if (StatsPeriod == "custom")
        {
            StatsFromStr = Request.QueryString["from"] ?? "";
            StatsToStr = Request.QueryString["to"] ?? "";
            DateTime f, t;
            if (DateTime.TryParse(StatsFromStr, out f)) fromDate = f.Date;
            if (DateTime.TryParse(StatsToStr, out t)) toDate = t.Date.AddDays(1).AddSeconds(-1);
        }

        StatsData = DbHelper.GetRevenueStatistics(fromDate, toDate);
        TopSellingList = DbHelper.GetTopSellingProducts(6, null);
        LowStockList = DbHelper.GetLowStockProducts(5);
        RecentOrdersList = DbHelper.GetAllOrders("", "");
        if (RecentOrdersList.Count > 5)
            RecentOrdersList = RecentOrdersList.GetRange(0, 5);

        // Chuẩn bị dữ liệu cho các biểu đồ Chart.js (UC14)
        List<DailyRevenueItem> timeline = DbHelper.GetRevenueTimeline(fromDate, toDate);
        List<string> tLabels = new List<string>();
        List<decimal> tRev = new List<decimal>();
        List<int> tOrders = new List<int>();
        foreach (DailyRevenueItem item in timeline)
        {
            tLabels.Add(item.DateLabel);
            tRev.Add(item.Revenue);
            tOrders.Add(item.OrderCount);
        }
        if (tLabels.Count == 0)
        {
            tLabels.Add(DateTime.Now.ToString("dd/MM"));
            tRev.Add(0);
            tOrders.Add(0);
        }

        List<OrderStatusItem> statusDist = DbHelper.GetOrderStatusDistribution();
        List<string> sLabels = new List<string>();
        List<int> sCounts = new List<int>();
        List<string> sColors = new List<string>();
        foreach (OrderStatusItem item in statusDist)
        {
            sLabels.Add(item.StatusName);
            sCounts.Add(item.Count);
            sColors.Add(item.ColorHex);
        }

        List<string> tpLabels = new List<string>();
        List<string> tpFullNames = new List<string>();
        List<int> tpSold = new List<int>();
        List<decimal> tpRev = new List<decimal>();
        foreach (ProductInfo item in TopSellingList)
        {
            string shortTitle = item.ProductName;
            if (shortTitle.Length > 24) shortTitle = shortTitle.Substring(0, 22) + "...";
            tpLabels.Add(item.ProductCode + " (" + shortTitle + ")");
            tpFullNames.Add(item.ProductName);
            tpSold.Add(item.SoldCount);
            tpRev.Add(item.Price * item.SoldCount);
        }

        List<CategoryRevenueItem> catRev = DbHelper.GetCategoryRevenueBreakdown();
        List<string> cLabels = new List<string>();
        List<decimal> cRevenue = new List<decimal>();
        List<int> cSold = new List<int>();
        foreach (CategoryRevenueItem item in catRev)
        {
            string shortCat = item.CategoryName;
            if (shortCat.Length > 20) shortCat = shortCat.Substring(0, 18) + "...";
            cLabels.Add(shortCat);
            cRevenue.Add(item.TotalRevenue);
            cSold.Add(item.TotalSold);
        }

        JavaScriptSerializer js = new JavaScriptSerializer();
        TimelineLabelsJson = js.Serialize(tLabels);
        TimelineRevenueJson = js.Serialize(tRev);
        TimelineOrdersJson = js.Serialize(tOrders);

        StatusLabelsJson = js.Serialize(sLabels);
        StatusCountsJson = js.Serialize(sCounts);
        StatusColorsJson = js.Serialize(sColors);

        TopProdLabelsJson = js.Serialize(tpLabels);
        TopProdFullNamesJson = js.Serialize(tpFullNames);
        TopProdSoldCountJson = js.Serialize(tpSold);
        TopProdRevenueJson = js.Serialize(tpRev);

        CatLabelsJson = js.Serialize(cLabels);
        CatRevenueJson = js.Serialize(cRevenue);
        CatSoldJson = js.Serialize(cSold);
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="pcm-page-card">
            <% if (!IsAuthorizedAdmin) { %>
                <div class="pcm-alert pcm-alert-error" style="text-align:center; padding:35px;">
                    <i class="fa-solid fa-user-lock" style="font-size:40px; margin-bottom:10px;"></i>
                    <h3>Từ chối quyền truy cập Quản trị hệ thống!</h3>
                    <p style="margin-top:8px;">Chỉ tài khoản có vai trò <strong>Quản trị viên (Admin)</strong> mới được phép truy cập phân hệ này (NFR03).</p>
                    <p style="margin-top:14px;"><a href="TrangChu.aspx" class="btn-pcm btn-pcm-primary">Quay về trang chủ</a></p>
                </div>
            <% } else { %>
                <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; margin-bottom:16px;">
                    <div>
                        <h1 class="pcm-page-title" style="margin-bottom:4px;">
                            <i class="fa-solid fa-gauge-high"></i> PHÂN HỆ QUẢN TRỊ HỆ THỐNG - ADMIN DASHBOARD
                        </h1>
                        <p style="font-size:13px; color:#64748b;">
                            Quản trị viên: <strong><%= HttpUtility.HtmlEncode(CurrentUser.FullName) %></strong> (<%= HttpUtility.HtmlEncode(CurrentUser.Username) %>) &mdash; Toàn quyền quản lý Danh mục, Sản phẩm, Đơn hàng, Tài khoản, Khuyến mãi &amp; Thống kê doanh thu.
                        </p>
                    </div>
                    <div style="display:flex; gap:8px;">
                        <a href="NhanVien.aspx" class="btn-pcm btn-pcm-outline">
                            <i class="fa-solid fa-clipboard-check"></i> Giao diện Staff
                        </a>
                        <a href="TrangChu.aspx" class="btn-pcm btn-pcm-outline">
                            <i class="fa-solid fa-store"></i> Xem Trang Bán Hàng
                        </a>
                    </div>
                </div>

                <% if (!string.IsNullOrEmpty(AlertMessage)) { %>
                    <div class="pcm-alert <%= AlertCss %>">
                        <i class="fa-solid fa-bell"></i> <%= HttpUtility.HtmlEncode(AlertMessage) %>
                    </div>
                <% } %>

                <input type="hidden" id="adminActiveTab" name="adminActiveTab" value="<%= ActiveTab %>" />
                <input type="hidden" id="adminAction" name="adminAction" value="" />
                <input type="hidden" id="adminTargetId" name="adminTargetId" value="0" />

                <!-- 6 Tab chức năng Quản trị viên (UC09 -> UC14) -->
                <div class="portal-tabs">
                    <a href="QuanTri.aspx?tab=stats" class="portal-tab <%= (ActiveTab == "stats" ? "active" : "") %>">
                        <i class="fa-solid fa-chart-line"></i> 1. Thống Kê Doanh Thu (UC14)
                    </a>
                    <a href="QuanTri.aspx?tab=products" class="portal-tab <%= (ActiveTab == "products" ? "active" : "") %>">
                        <i class="fa-solid fa-laptop"></i> 2. Quản Lý Sản Phẩm (UC09) (<%= AllProducts.Count %>)
                    </a>
                    <a href="QuanTri.aspx?tab=categories" class="portal-tab <%= (ActiveTab == "categories" ? "active" : "") %>">
                        <i class="fa-solid fa-folder-tree"></i> 3. Quản Lý Danh Mục (UC10) (<%= AllCategories.Count %>)
                    </a>
                    <a href="QuanTri.aspx?tab=orders" class="portal-tab <%= (ActiveTab == "orders" ? "active" : "") %>">
                        <i class="fa-solid fa-receipt"></i> 4. Quản Lý Đơn Hàng (UC11) (<%= AllOrders.Count %>)
                    </a>
                    <a href="QuanTri.aspx?tab=users" class="portal-tab <%= (ActiveTab == "users" ? "active" : "") %>">
                        <i class="fa-solid fa-users-gear"></i> 5. Tài Khoản &amp; Phân Quyền (UC12) (<%= AllUsers.Count %>)
                    </a>
                    <a href="QuanTri.aspx?tab=promotions" class="portal-tab <%= (ActiveTab == "promotions" ? "active" : "") %>">
                        <i class="fa-solid fa-tags"></i> 6. Quản Lý Khuyến Mãi (UC13) (<%= AllPromotions.Count %>)
                    </a>
                </div>

                                <% if (ActiveTab == "stats") { %>
                    <!-- ==================== TAB 1: THỐNG KÊ DOANH THU & BIỂU ĐỒ TRỰC QUAN (UC14) ==================== -->
                    <div class="filter-bar" style="justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; margin-bottom:20px; background:#ffffff; border:1px solid #e2e8f0; border-radius:12px; padding:14px 18px;">
                        <div style="display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
                            <strong style="font-size:13px; color:#475569; text-transform:uppercase; letter-spacing:0.3px;">
                                <i class="fa-solid fa-calendar-check" style="color:#3D52BF; margin-right:4px;"></i> Kỳ thống kê:
                            </strong>
                            <div class="period-nav">
                                <a href="QuanTri.aspx?tab=stats&period=all" class="period-btn <%= (StatsPeriod == "all" ? "active" : "") %>">Toàn thời gian</a>
                                <a href="QuanTri.aspx?tab=stats&period=today" class="period-btn <%= (StatsPeriod == "today" ? "active" : "") %>">Hôm nay</a>
                                <a href="QuanTri.aspx?tab=stats&period=month" class="period-btn <%= (StatsPeriod == "month" ? "active" : "") %>">Tháng này</a>
                                <a href="QuanTri.aspx?tab=stats&period=quarter" class="period-btn <%= (StatsPeriod == "quarter" ? "active" : "") %>">Quý này</a>
                            </div>
                        </div>
                        <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
                            <span style="font-size:13px; color:#64748b; font-weight:600;">Từ:</span>
                            <input type="date" id="statsFrom" value="<%= HttpUtility.HtmlAttributeEncode(StatsFromStr) %>" class="filter-control" style="height:34px; min-width:130px; font-size:13px;" />
                            <span style="font-size:13px; color:#64748b; font-weight:600;">Đến:</span>
                            <input type="date" id="statsTo" value="<%= HttpUtility.HtmlAttributeEncode(StatsToStr) %>" class="filter-control" style="height:34px; min-width:130px; font-size:13px;" />
                            <button type="button" class="btn-pcm btn-pcm-primary" style="height:34px; padding:0 14px; font-size:13px;"
                                    onclick="window.location.href='QuanTri.aspx?tab=stats&period=custom&from='+document.getElementById('statsFrom').value+'&to='+document.getElementById('statsTo').value;">
                                <i class="fa-solid fa-filter"></i> Lọc ngày
                            </button>
                        </div>
                    </div>

                    <!-- 4 Thẻ KPI Chỉ Số Tài Chính & Vận Hành -->
                    <div class="kpi-grid">
                        <div class="kpi-card kpi-green">
                            <div class="kpi-info">
                                <h4>Doanh Thu Thực Tế</h4>
                                <div class="kpi-value" style="color:#10b981;"><%= SecurityHelper.FormatCurrency(StatsData.TotalRevenue) %></div>
                                <div class="kpi-sub">
                                    <i class="fa-solid fa-circle-check" style="color:#10b981;"></i> Tính từ <strong><%= StatsData.DeliveredOrders %></strong> đơn đã giao thành công
                                </div>
                            </div>
                            <div class="kpi-icon">
                                <i class="fa-solid fa-sack-dollar"></i>
                            </div>
                        </div>

                        <div class="kpi-card kpi-blue">
                            <div class="kpi-info">
                                <h4>Tổng Đơn Đặt Hàng</h4>
                                <div class="kpi-value" style="color:#2563eb;"><%= StatsData.TotalOrders %> <span style="font-size:16px; font-weight:600;">đơn</span></div>
                                <div class="kpi-sub">
                                    Đã giao: <strong><%= StatsData.DeliveredOrders %></strong> &bull; Đang giao: <strong><%= StatsData.ShippingOrders %></strong>
                                </div>
                            </div>
                            <div class="kpi-icon">
                                <i class="fa-solid fa-boxes-packing"></i>
                            </div>
                        </div>

                        <div class="kpi-card kpi-amber">
                            <div class="kpi-info">
                                <h4>Chờ Xử Lý / Đã Hủy</h4>
                                <div class="kpi-value">
                                    <span style="color:#d97706;"><%= StatsData.PendingOrders %></span>
                                    <span style="font-size:16px; color:#94a3b8; font-weight:400;">/</span>
                                    <span style="color:#ef4444;"><%= StatsData.CancelledOrders %></span>
                                </div>
                                <div class="kpi-sub">
                                    <%= StatsData.PendingOrders %> đơn chờ duyệt &bull; Đơn hủy tự hoàn kho
                                </div>
                            </div>
                            <div class="kpi-icon">
                                <i class="fa-solid fa-clock-rotate-left"></i>
                            </div>
                        </div>

                        <div class="kpi-card kpi-red">
                            <div class="kpi-info">
                                <h4>Cảnh Báo Tồn Kho</h4>
                                <div class="kpi-value" style="color:#ef4444;"><%= StatsData.LowStockCount %> <span style="font-size:16px; font-weight:600;">mã SP</span></div>
                                <div class="kpi-sub">
                                    Tồn kho &le; 5 linh kiện &bull; <a href="#lowStockSection" style="color:#ef4444; font-weight:700;">Xem chi tiết</a>
                                </div>
                            </div>
                            <div class="kpi-icon">
                                <i class="fa-solid fa-triangle-exclamation"></i>
                            </div>
                        </div>
                    </div>

                    <!-- Row 1: Biểu đồ Doanh thu/Đơn hàng & Phân bổ trạng thái -->
                    <div style="display:flex; gap:20px; flex-wrap:wrap; margin-bottom:24px;">
                        <!-- Biểu đồ kết hợp -->
                        <div class="chart-box" style="flex:1.6; min-width:340px; margin-bottom:0;">
                            <div class="chart-header">
                                <div class="chart-title">
                                    <i class="fa-solid fa-chart-line"></i> Xu Hướng Doanh Thu &amp; Số Lượng Đơn Hàng
                                </div>
                                <span class="chart-badge">Biểu đồ kết hợp (Line &amp; Bar)</span>
                            </div>
                            <div style="position:relative; height:300px; width:100%;">
                                <canvas id="chartRevenueTimeline"></canvas>
                            </div>
                        </div>

                        <!-- Biểu đồ vành khuyên -->
                        <div class="chart-box" style="flex:1; min-width:300px; margin-bottom:0;">
                            <div class="chart-header">
                                <div class="chart-title">
                                    <i class="fa-solid fa-chart-pie"></i> Cơ Cấu Trạng Thái Đơn Hàng
                                </div>
                                <span class="chart-badge">Doughnut</span>
                            </div>
                            <div style="position:relative; height:300px; width:100%; display:flex; align-items:center; justify-content:center;">
                                <canvas id="chartOrderStatus"></canvas>
                            </div>
                        </div>
                    </div>

                    <!-- Row 2: Top Sản phẩm bán chạy & Doanh thu theo danh mục -->
                    <div style="display:flex; gap:20px; flex-wrap:wrap; margin-bottom:24px;">
                        <!-- Biểu đồ thanh ngang -->
                        <div class="chart-box" style="flex:1; min-width:340px; margin-bottom:0;">
                            <div class="chart-header">
                                <div class="chart-title">
                                    <i class="fa-solid fa-ranking-star"></i> Top 6 Máy Tính &amp; Linh Kiện Bán Chạy Nhất
                                </div>
                                <span class="chart-badge">Số lượng đã bán</span>
                            </div>
                            <div style="position:relative; height:320px; width:100%;">
                                <canvas id="chartTopProducts"></canvas>
                            </div>
                        </div>

                        <!-- Biểu đồ cột theo danh mục -->
                        <div class="chart-box" style="flex:1; min-width:340px; margin-bottom:0;">
                            <div class="chart-header">
                                <div class="chart-title">
                                    <i class="fa-solid fa-layer-group"></i> Doanh Thu Theo Nhóm Danh Mục
                                </div>
                                <span class="chart-badge">Doanh thu VNĐ</span>
                            </div>
                            <div style="position:relative; height:320px; width:100%;">
                                <canvas id="chartCategoryRevenue"></canvas>
                            </div>
                        </div>
                    </div>

                    <!-- Row 3: Đơn hàng mới nhất & Bảng Cảnh báo tồn kho thấp -->
                    <div style="display:flex; gap:20px; flex-wrap:wrap;" id="lowStockSection">
                        <!-- Đơn hàng gần đây -->
                        <div class="chart-box" style="flex:1.2; min-width:340px;">
                            <div class="chart-header">
                                <div class="chart-title">
                                    <i class="fa-solid fa-clock"></i> Đơn Hàng Mới Nhất Trên Hệ Thống
                                </div>
                                <a href="QuanTri.aspx?tab=orders" class="btn-pcm btn-pcm-outline" style="height:28px; padding:0 10px; font-size:12px;">
                                    Quản lý tất cả (<%= AllOrders.Count %>) &rarr;
                                </a>
                            </div>
                            <div style="overflow-x:auto;">
                                <table class="pcm-table" style="font-size:13px;">
                                    <thead>
                                        <tr>
                                            <th>Mã Đơn</th>
                                            <th>Khách Hàng</th>
                                            <th>Thời Gian</th>
                                            <th>Tổng Tiền</th>
                                            <th>Trạng Thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (int i = 0; i < RecentOrdersList.Count; i++) {
                                               OrderInfo ro = RecentOrdersList[i]; %>
                                            <tr>
                                                <td><strong style="color:#3D52BF;"><%= HttpUtility.HtmlEncode(ro.OrderCode) %></strong></td>
                                                <td><%= HttpUtility.HtmlEncode(ro.ReceiverName) %></td>
                                                <td style="color:#64748b;"><%= ro.CreatedAt.ToString("dd/MM HH:mm") %></td>
                                                <td style="font-weight:700; color:#CB1C21;"><%= SecurityHelper.FormatCurrency(ro.TotalAmount) %></td>
                                                <td><%= UiHelper.RenderOrderStatusBadge(ro.OrderStatus) %></td>
                                            </tr>
                                        <% } %>
                                        <% if (RecentOrdersList.Count == 0) { %>
                                            <tr>
                                                <td colspan="5" style="text-align:center; color:#94a3b8; padding:18px;">Chưa có đơn hàng nào phát sinh.</td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Bảng cảnh báo tồn kho thấp -->
                        <div class="chart-box" style="flex:1; min-width:320px;">
                            <div class="chart-header">
                                <div class="chart-title" style="color:#ef4444;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> Cảnh Báo Tồn Kho Thấp (&le; 5 SP)
                                </div>
                                <span class="chart-badge" style="background:#fee2e2; color:#ef4444; font-weight:700;"><%= LowStockList.Count %> mã SP</span>
                            </div>
                            <div style="overflow-x:auto;">
                                <table class="pcm-table" style="font-size:13px;">
                                    <thead>
                                        <tr>
                                            <th>Mã SP</th>
                                            <th>Tên Sản Phẩm</th>
                                            <th>Tồn</th>
                                            <th>Xử Lý</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (int i = 0; i < LowStockList.Count; i++) {
                                               ProductInfo lp = LowStockList[i]; %>
                                            <tr>
                                                <td><strong><%= HttpUtility.HtmlEncode(lp.ProductCode) %></strong></td>
                                                <td style="max-width:180px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="<%= HttpUtility.HtmlAttributeEncode(lp.ProductName) %>">
                                                    <%= HttpUtility.HtmlEncode(lp.ProductName) %>
                                                </td>
                                                <td><strong style="color:#ef4444;"><%= lp.StockQuantity %> SP</strong></td>
                                                <td>
                                                    <a href="QuanTri.aspx?tab=products&editProd=<%= lp.ProductId %>" class="btn-pcm btn-pcm-outline" style="height:26px; padding:0 8px; font-size:11px; white-space:nowrap;">
                                                        <i class="fa-solid fa-plus"></i> Nhập kho
                                                    </a>
                                                </td>
                                            </tr>
                                        <% } %>
                                        <% if (LowStockList.Count == 0) { %>
                                            <tr>
                                                <td colspan="4" style="text-align:center; color:#10b981; padding:18px;">
                                                    <i class="fa-solid fa-circle-check"></i> Tất cả các sản phẩm đều đảm bảo mức tồn an toàn.
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Khởi tạo biểu đồ Chart.js trên trình duyệt -->
                    <script>
                        (function() {
                            function formatVND(val) {
                                if (val >= 1000000) {
                                    return (val / 1000000).toLocaleString('vi-VN', { maximumFractionDigits: 1 }) + ' triệu đ';
                                }
                                return Number(val).toLocaleString('vi-VN') + ' đ';
                            }

                            var timelineLabels = <%= TimelineLabelsJson %>;
                            var timelineRevenue = <%= TimelineRevenueJson %>;
                            var timelineOrders = <%= TimelineOrdersJson %>;

                            var statusLabels = <%= StatusLabelsJson %>;
                            var statusCounts = <%= StatusCountsJson %>;
                            var statusColors = <%= StatusColorsJson %>;

                            var topProdLabels = <%= TopProdLabelsJson %>;
                            var topProdFullNames = <%= TopProdFullNamesJson %>;
                            var topProdSold = <%= TopProdSoldCountJson %>;
                            var topProdRevenue = <%= TopProdRevenueJson %>;

                            var catLabels = <%= CatLabelsJson %>;
                            var catRevenue = <%= CatRevenueJson %>;
                            var catSold = <%= CatSoldJson %>;

                            // 1. Biểu đồ theo thời gian: cột cho số đơn, đường cho doanh thu
                            var ctxTimeline = document.getElementById('chartRevenueTimeline');
                            if (ctxTimeline && typeof Chart !== 'undefined') {
                                var gradient = ctxTimeline.getContext('2d').createLinearGradient(0, 0, 0, 300);
                                gradient.addColorStop(0, 'rgba(59, 130, 246, 0.35)');
                                gradient.addColorStop(1, 'rgba(59, 130, 246, 0.00)');

                                new Chart(ctxTimeline, {
                                    type: 'bar',
                                    data: {
                                        labels: timelineLabels,
                                        datasets: [
                                            {
                                                type: 'line',
                                                label: 'Doanh thu (VNĐ)',
                                                data: timelineRevenue,
                                                borderColor: '#2563eb',
                                                backgroundColor: gradient,
                                                fill: true,
                                                tension: 0.35,
                                                borderWidth: 3,
                                                pointRadius: 5,
                                                pointHoverRadius: 7,
                                                pointBackgroundColor: '#ffffff',
                                                pointBorderColor: '#2563eb',
                                                pointBorderWidth: 2,
                                                yAxisID: 'yRevenue',
                                                order: 1
                                            },
                                            {
                                                type: 'bar',
                                                label: 'Số đơn hàng',
                                                data: timelineOrders,
                                                backgroundColor: 'rgba(203, 28, 33, 0.75)',
                                                hoverBackgroundColor: '#CB1C21',
                                                borderRadius: 6,
                                                maxBarThickness: 32,
                                                yAxisID: 'yOrders',
                                                order: 2
                                            }
                                        ]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        interaction: {
                                            mode: 'index',
                                            intersect: false
                                        },
                                        plugins: {
                                            legend: {
                                                position: 'top',
                                                labels: { boxWidth: 14, font: { family: 'Arial', size: 12, weight: '600' } }
                                            },
                                            tooltip: {
                                                callbacks: {
                                                    label: function(context) {
                                                        if (context.dataset.yAxisID === 'yRevenue') {
                                                            return ' Doanh thu: ' + formatVND(context.parsed.y);
                                                        } else {
                                                            return ' Số đơn hàng: ' + context.parsed.y + ' đơn';
                                                        }
                                                    }
                                                }
                                            }
                                        },
                                        scales: {
                                            x: {
                                                grid: { display: false },
                                                ticks: { font: { size: 11, weight: '600' } }
                                            },
                                            yRevenue: {
                                                type: 'linear',
                                                display: true,
                                                position: 'left',
                                                grid: { color: '#f1f5f9' },
                                                ticks: {
                                                    callback: function(val) { return formatVND(val); },
                                                    font: { size: 11 }
                                                }
                                            },
                                            yOrders: {
                                                type: 'linear',
                                                display: true,
                                                position: 'right',
                                                grid: { drawOnChartArea: false },
                                                ticks: {
                                                    stepSize: 1,
                                                    precision: 0,
                                                    font: { size: 11 }
                                                }
                                            }
                                        }
                                    }
                                });
                            }

                            // 2. Biểu đồ vành khuyên theo trạng thái đơn hàng
                            var ctxStatus = document.getElementById('chartOrderStatus');
                            if (ctxStatus && typeof Chart !== 'undefined') {
                                new Chart(ctxStatus, {
                                    type: 'doughnut',
                                    data: {
                                        labels: statusLabels,
                                        datasets: [{
                                            data: statusCounts,
                                            backgroundColor: statusColors,
                                            borderWidth: 2,
                                            borderColor: '#ffffff',
                                            hoverOffset: 6
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {
                                                position: 'bottom',
                                                labels: {
                                                    boxWidth: 12,
                                                    padding: 12,
                                                    font: { size: 11, weight: '600' }
                                                }
                                            },
                                            tooltip: {
                                                callbacks: {
                                                    label: function(context) {
                                                        var total = 0;
                                                        context.dataset.data.forEach(function(n) { total += n; });
                                                        var pct = total > 0 ? Math.round((context.parsed / total) * 100) : 0;
                                                        return ' ' + context.label + ': ' + context.parsed + ' đơn (' + pct + '%)';
                                                    }
                                                }
                                            }
                                        },
                                        cutout: '62%'
                                    }
                                });
                            }

                            // 3. Biểu đồ thanh ngang cho sản phẩm bán chạy
                            var ctxTopProd = document.getElementById('chartTopProducts');
                            if (ctxTopProd && typeof Chart !== 'undefined') {
                                new Chart(ctxTopProd, {
                                    type: 'bar',
                                    data: {
                                        labels: topProdLabels,
                                        datasets: [{
                                            label: 'Số lượng đã bán (SP)',
                                            data: topProdSold,
                                            backgroundColor: [
                                                '#3b82f6', '#10b981', '#f59e0b', '#ec4899', '#8b5cf6', '#06b6d4'
                                            ],
                                            borderRadius: 6,
                                            maxBarThickness: 24
                                        }]
                                    },
                                    options: {
                                        indexAxis: 'y',
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: { display: false },
                                            tooltip: {
                                                callbacks: {
                                                    title: function(items) {
                                                        if (items.length > 0) {
                                                            var idx = items[0].dataIndex;
                                                            return topProdFullNames[idx] || items[0].label;
                                                        }
                                                        return '';
                                                    },
                                                    label: function(context) {
                                                        var idx = context.dataIndex;
                                                        var sold = context.parsed.x;
                                                        var rev = topProdRevenue[idx] || 0;
                                                        return [
                                                            ' Đã bán: ' + sold + ' sản phẩm',
                                                            ' Doanh số ước tính: ' + formatVND(rev)
                                                        ];
                                                    }
                                                }
                                            }
                                        },
                                        scales: {
                                            x: {
                                                grid: { color: '#f1f5f9' },
                                                ticks: { precision: 0, font: { size: 11 } }
                                            },
                                            y: {
                                                grid: { display: false },
                                                ticks: { font: { size: 11, weight: '600' } }
                                            }
                                        }
                                    }
                                });
                            }

                            // 4. Biểu đồ cột doanh thu theo danh mục
                            var ctxCat = document.getElementById('chartCategoryRevenue');
                            if (ctxCat && typeof Chart !== 'undefined') {
                                new Chart(ctxCat, {
                                    type: 'bar',
                                    data: {
                                        labels: catLabels,
                                        datasets: [{
                                            label: 'Doanh thu (VNĐ)',
                                            data: catRevenue,
                                            backgroundColor: '#3D52BF',
                                            hoverBackgroundColor: '#CB1C21',
                                            borderRadius: 6,
                                            maxBarThickness: 40
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: { display: false },
                                            tooltip: {
                                                callbacks: {
                                                    label: function(context) {
                                                        var idx = context.dataIndex;
                                                        return [
                                                            ' Doanh thu: ' + formatVND(context.parsed.y),
                                                            ' Đã bán: ' + (catSold[idx] || 0) + ' SP'
                                                        ];
                                                    }
                                                }
                                            }
                                        },
                                        scales: {
                                            x: {
                                                grid: { display: false },
                                                ticks: { font: { size: 11, weight: '600' } }
                                            },
                                            y: {
                                                grid: { color: '#f1f5f9' },
                                                ticks: {
                                                    callback: function(val) { return formatVND(val); },
                                                    font: { size: 11 }
                                                }
                                            }
                                        }
                                    }
                                });
                            }
                        })();
                    </script>

                <% } else if (ActiveTab == "products") { %>
                    <!-- ==================== TAB 2: QUẢN LÝ SẢN PHẨM (UC09 - ADMIN) ==================== -->
                    <div style="background:#f8fafc; border:1px solid #cbd5e1; border-radius:10px; padding:20px; margin-bottom:24px;">
                        <h3 style="color:#3D52BF; font-size:17px; margin-bottom:14px;">
                            <i class="fa-solid fa-circle-plus"></i>
                            <%= (EditProd != null ? ("CHỈNH SỬA SẢN PHẨM: " + HttpUtility.HtmlEncode(EditProd.ProductCode)) : "THÊM MÁY TÍNH / LINH KIỆN MỚI (UC09)") %>
                        </h3>

                        <input type="hidden" name="ProdId" value="<%= (EditProd != null ? EditProd.ProductId : 0) %>" />

                        <div style="display:flex; gap:14px; flex-wrap:wrap;">
                            <div class="form-group" style="width:160px;">
                                <label>Mã SP <span style="color:red;">*</span></label>
                                <input type="text" name="ProdCode" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditProd != null ? EditProd.ProductCode : "") %>"
                                       placeholder="VD: NBAS2026" />
                            </div>
                            <div class="form-group" style="flex:1; min-width:260px;">
                                <label>Tên máy tính / Linh kiện <span style="color:red;">*</span></label>
                                <input type="text" name="ProdName" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditProd != null ? EditProd.ProductName : "") %>"
                                       placeholder="Nhập tên đầy đủ kèm cấu hình tóm tắt" />
                            </div>
                            <div class="form-group" style="width:230px;">
                                <label>Danh mục <span style="color:red;">*</span></label>
                                <select name="ProdCatId" class="form-control">
                                    <% for (int i = 0; i < AllCategories.Count; i++) {
                                           CategoryInfo c = AllCategories[i]; %>
                                        <option value="<%= c.CategoryId %>" <%= (EditProd != null && EditProd.CategoryId == c.CategoryId ? "selected='selected'" : "") %>>
                                            <%= HttpUtility.HtmlEncode(c.CategoryName) %>
                                        </option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="form-group" style="width:150px;">
                                <label>Hãng SX <span style="color:red;">*</span></label>
                                <input type="text" name="ProdBrand" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditProd != null ? EditProd.Brand : "ASUS") %>" />
                            </div>
                        </div>

                        <div style="display:flex; gap:14px; flex-wrap:wrap;">
                            <div class="form-group" style="flex:1; min-width:150px;">
                                <label>Giá niêm yết (VNĐ)</label>
                                <input type="number" name="ProdOldPrice" class="form-control"
                                       value="<%= (EditProd != null ? EditProd.OldPrice : 0) %>" />
                            </div>
                            <div class="form-group" style="flex:1; min-width:150px;">
                                <label>Giá bán KM (VNĐ) <span style="color:red;">*</span></label>
                                <input type="number" name="ProdPrice" class="form-control"
                                       value="<%= (EditProd != null ? EditProd.Price : 0) %>" />
                            </div>
                            <div class="form-group" style="width:130px;">
                                <label>Tồn kho <span style="color:red;">*</span></label>
                                <input type="number" name="ProdStock" class="form-control" min="0"
                                       value="<%= (EditProd != null ? EditProd.StockQuantity : 10) %>" />
                            </div>
                            <div class="form-group" style="width:140px;">
                                <label>Bảo hành (Tháng)</label>
                                <input type="number" name="ProdWarranty" class="form-control" min="1"
                                       value="<%= (EditProd != null ? EditProd.WarrantyMonths : 24) %>" />
                            </div>
                            <div class="form-group" style="flex:1; min-width:200px;">
                                <label>Đường dẫn hình ảnh</label>
                                <input type="text" name="ProdImage" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditProd != null ? EditProd.ImageUrl : "./anh pc/lap_asus.jpg") %>" />
                            </div>
                            <div class="form-group" style="width:150px;">
                                <label>Flash Deal</label>
                                <select name="ProdIsDeal" class="form-control">
                                    <option value="0" <%= (EditProd != null && !EditProd.IsDeal ? "selected='selected'" : "") %>>Bình thường</option>
                                    <option value="1" <%= (EditProd != null && EditProd.IsDeal ? "selected='selected'" : "") %>>Deal Giá Sốc</option>
                                </select>
                            </div>
                            <div class="form-group" style="width:170px;">
                                <label>Trạng thái KD</label>
                                <select name="ProdStatus" class="form-control">
                                    <option value="Đang kinh doanh" <%= (EditProd != null && EditProd.Status == "Đang kinh doanh" ? "selected='selected'" : "") %>>Đang kinh doanh</option>
                                    <option value="Ngừng kinh doanh" <%= (EditProd != null && EditProd.Status == "Ngừng kinh doanh" ? "selected='selected'" : "") %>>Ngừng kinh doanh</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Thông số kỹ thuật chi tiết (Phân tách từng dòng bằng dấu | )</label>
                            <textarea name="ProdSpecs" rows="2" class="form-control"
                                      placeholder="CPU: Intel Core i7 | RAM: 16GB DDR5 | SSD: 512GB NVMe | VGA: RTX 4060 8GB"><%= HttpUtility.HtmlEncode(EditProd != null ? EditProd.Specifications : "") %></textarea>
                        </div>

                        <div class="form-group">
                            <label>Mô tả chi tiết sản phẩm</label>
                            <textarea name="ProdDesc" rows="2" class="form-control"><%= HttpUtility.HtmlEncode(EditProd != null ? EditProd.Description : "") %></textarea>
                        </div>

                        <div style="display:flex; gap:10px;">
                            <button type="submit" class="btn-pcm btn-pcm-primary"
                                    onclick="document.getElementById('adminAction').value='save_product';">
                                <i class="fa-solid fa-floppy-disk"></i> <%= (EditProd != null ? "LƯU CẬP NHẬT SẢN PHẨM" : "THÊM SẢN PHẨM MỚI") %>
                            </button>
                            <% if (EditProd != null) { %>
                                <a href="QuanTri.aspx?tab=products" class="btn-pcm btn-pcm-outline">Hủy chỉnh sửa</a>
                            <% } %>
                        </div>
                    </div>

                    <div style="width:100%; overflow:hidden;">
                        <table class="pcm-table" style="width:100%; table-layout:fixed;">
                            <thead>
                                <tr>
                                    <th style="width:4%;">ID</th>
                                    <th style="width:6%;">Hình</th>
                                    <th style="width:9%;">Mã SP</th>
                                    <th style="width:28%;">Tên Sản Phẩm</th>
                                    <th style="width:11%;">Danh Mục</th>
                                    <th style="width:11%;">Giá Bán</th>
                                    <th style="width:7%;">Tồn Kho</th>
                                    <th style="width:7%;">Đã Bán</th>
                                    <th style="width:8%;">Trạng Thái</th>
                                    <th style="width:9%; text-align:center;">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (int i = 0; i < AllProducts.Count; i++) {
                                       ProductInfo p = AllProducts[i]; %>
                                    <tr>
                                        <td><%= p.ProductId %></td>
                                        <td><img src="<%= HttpUtility.HtmlAttributeEncode(p.ImageUrl) %>" alt="" style="width:44px;height:44px;object-fit:contain;" /></td>
                                        <td><strong><%= HttpUtility.HtmlEncode(p.ProductCode) %></strong></td>
                                        <td style="font-weight:600;"><%= HttpUtility.HtmlEncode(p.ProductName) %></td>
                                        <td><%= HttpUtility.HtmlEncode(p.CategoryName) %></td>
                                        <td style="font-weight:700; color:#CB1C21; white-space:nowrap;"><%= SecurityHelper.FormatCurrency(p.Price) %></td>
                                        <td><strong><%= p.StockQuantity %></strong></td>
                                        <td><%= p.SoldCount %></td>
                                        <td>
                                            <% if (p.Status == "Đang kinh doanh") { %>
                                                <span style="background:#dcfce7;color:#166534;padding:3px 8px;border-radius:10px;font-size:12px;font-weight:700;">Đang KD</span>
                                            <% } else { %>
                                                <span style="background:#fee2e2;color:#991b1b;padding:3px 8px;border-radius:10px;font-size:12px;font-weight:700;">Ngừng KD</span>
                                            <% } %>
                                        </td>
                                        <td style="text-align:center; white-space:nowrap;">
                                            <a href="QuanTri.aspx?tab=products&editProd=<%= p.ProductId %>" class="btn-pcm btn-pcm-outline" style="height:30px; padding:0 10px; font-size:12px;">
                                                <i class="fa-solid fa-pen"></i> Sửa
                                            </a>
                                            <button type="submit" class="btn-pcm btn-pcm-danger" style="height:30px; padding:0 10px; font-size:12px;"
                                                    onclick="if(confirm('Xác nhận xóa sản phẩm <%= p.ProductCode %>? (Lưu ý UC09: Nếu sản phẩm đã phát sinh trong đơn hàng, hệ thống sẽ chuyển sang trạng thái Ngừng kinh doanh)')){document.getElementById('adminAction').value='delete_product';document.getElementById('adminTargetId').value='<%= p.ProductId %>';return true;}return false;">
                                                <i class="fa-solid fa-trash"></i> Xóa
                                            </button>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                <% } else if (ActiveTab == "categories") { %>
                    <!-- ==================== TAB 3: QUẢN LÝ DANH MỤC (UC10 - ADMIN) ==================== -->
                    <div style="background:#f8fafc; border:1px solid #cbd5e1; border-radius:10px; padding:20px; margin-bottom:24px;">
                        <h3 style="color:#3D52BF; font-size:17px; margin-bottom:14px;">
                            <i class="fa-solid fa-folder-plus"></i>
                            <%= (EditCat != null ? ("CHỈNH SỬA DANH MỤC: " + HttpUtility.HtmlEncode(EditCat.CategoryName)) : "THÊM DANH MỤC SẢN PHẨM MỚI (UC10)") %>
                        </h3>

                        <input type="hidden" name="CatId" value="<%= (EditCat != null ? EditCat.CategoryId : 0) %>" />

                        <div style="display:flex; gap:14px; flex-wrap:wrap;">
                            <div class="form-group" style="flex:1; min-width:220px;">
                                <label>Tên danh mục <span style="color:red;">*</span></label>
                                <input type="text" name="CatName" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditCat != null ? EditCat.CategoryName : "") %>"
                                       placeholder="VD: Linh Kiện Tản Nhiệt Custom" />
                            </div>
                            <div class="form-group" style="width:180px;">
                                <label>Slug (Mã định danh) <span style="color:red;">*</span></label>
                                <input type="text" name="CatSlug" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditCat != null ? EditCat.Slug : "") %>"
                                       placeholder="VD: custom-cooling" />
                            </div>
                            <div class="form-group" style="width:180px;">
                                <label>Trang liên kết</label>
                                <input type="text" name="CatPageUrl" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditCat != null ? EditCat.PageUrl : "SanPham.aspx") %>" />
                            </div>
                            <div class="form-group" style="width:180px;">
                                <label>Icon danh mục</label>
                                <input type="text" name="CatIcon" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditCat != null ? EditCat.IconPath : "./BieuTuong/linhkien.png") %>" />
                            </div>
                            <div class="form-group" style="width:110px;">
                                <label>Thứ tự</label>
                                <input type="number" name="CatOrder" class="form-control"
                                       value="<%= (EditCat != null ? EditCat.DisplayOrder : 15) %>" />
                            </div>
                            <div class="form-group" style="width:140px;">
                                <label>Hiển thị</label>
                                <select name="CatActive" class="form-control">
                                    <option value="1" <%= (EditCat == null || EditCat.IsActive ? "selected='selected'" : "") %>>Hiển thị</option>
                                    <option value="0" <%= (EditCat != null && !EditCat.IsActive ? "selected='selected'" : "") %>>Ẩn</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Mô tả danh mục</label>
                            <input type="text" name="CatDesc" class="form-control"
                                   value="<%= HttpUtility.HtmlAttributeEncode(EditCat != null ? EditCat.Description : "") %>" />
                        </div>

                        <div style="display:flex; gap:10px;">
                            <button type="submit" class="btn-pcm btn-pcm-primary"
                                    onclick="document.getElementById('adminAction').value='save_category';">
                                <i class="fa-solid fa-floppy-disk"></i> LƯU DANH MỤC
                            </button>
                            <% if (EditCat != null) { %>
                                <a href="QuanTri.aspx?tab=categories" class="btn-pcm btn-pcm-outline">Hủy</a>
                            <% } %>
                        </div>
                    </div>

                    <table class="pcm-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Icon</th>
                                <th>Tên danh mục</th>
                                <th>Slug</th>
                                <th>Mô tả</th>
                                <th>Số sản phẩm</th>
                                <th>Trạng thái</th>
                                <th style="text-align:center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < AllCategories.Count; i++) {
                                   CategoryInfo c = AllCategories[i]; %>
                                <tr>
                                    <td><%= c.CategoryId %></td>
                                    <td><img src="<%= HttpUtility.HtmlAttributeEncode(c.IconPath) %>" alt="" style="width:28px;height:28px;object-fit:contain;" /></td>
                                    <td><strong><%= HttpUtility.HtmlEncode(c.CategoryName) %></strong></td>
                                    <td><code><%= HttpUtility.HtmlEncode(c.Slug) %></code></td>
                                    <td style="font-size:13px; color:#475569;"><%= HttpUtility.HtmlEncode(c.Description) %></td>
                                    <td><strong><%= c.ProductCount %> SP</strong></td>
                                    <td><%= (c.IsActive ? "<span style='color:#16a34a;font-weight:700;'>Hiển thị</span>" : "<span style='color:#94a3b8;'>Đang ẩn</span>") %></td>
                                    <td style="text-align:center; white-space:nowrap;">
                                        <a href="QuanTri.aspx?tab=categories&editCat=<%= c.CategoryId %>" class="btn-pcm btn-pcm-outline" style="height:30px; padding:0 10px; font-size:12px;">
                                            <i class="fa-solid fa-pen"></i> Sửa
                                        </a>
                                        <button type="submit" class="btn-pcm btn-pcm-danger" style="height:30px; padding:0 10px; font-size:12px;"
                                                onclick="if(confirm('Xác nhận xóa danh mục <%= HttpUtility.JavaScriptStringEncode(c.CategoryName) %>?')){document.getElementById('adminAction').value='delete_category';document.getElementById('adminTargetId').value='<%= c.CategoryId %>';return true;}return false;">
                                            <i class="fa-solid fa-trash"></i> Xóa
                                        </button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>

                <% } else if (ActiveTab == "orders") { %>
                    <!-- ==================== TAB 4: QUẢN LÝ ĐƠN HÀNG (UC11 - ADMIN) ==================== -->
                    <div class="filter-bar" style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; padding:12px 16px; margin-bottom:18px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
                        <div style="display:flex; gap:6px; flex-wrap:wrap; align-items:center;">
                            <strong style="font-size:13px; color:#475569; margin-right:4px;"><i class="fa-solid fa-filter"></i> Lọc trạng thái:</strong>
                            <a href="QuanTri.aspx?tab=orders" class="btn-pcm <%= (OrderFilterStatus == "" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:32px; font-size:12px;">Tất cả (<%= AllOrders.Count %>)</a>
                            <a href="QuanTri.aspx?tab=orders&ost=<%= HttpUtility.UrlEncode("Chờ xác nhận") %>" class="btn-pcm <%= (OrderFilterStatus == "Chờ xác nhận" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:32px; font-size:12px;">Chờ xác nhận</a>
                            <a href="QuanTri.aspx?tab=orders&ost=<%= HttpUtility.UrlEncode("Đang chờ vận chuyển") %>" class="btn-pcm <%= (OrderFilterStatus == "Đang chờ vận chuyển" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:32px; font-size:12px;">Đang chờ VC</a>
                            <a href="QuanTri.aspx?tab=orders&ost=<%= HttpUtility.UrlEncode("Đang giao") %>" class="btn-pcm <%= (OrderFilterStatus == "Đang giao" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:32px; font-size:12px;">Đang giao</a>
                            <a href="QuanTri.aspx?tab=orders&ost=<%= HttpUtility.UrlEncode("Đã giao") %>" class="btn-pcm <%= (OrderFilterStatus == "Đã giao" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:32px; font-size:12px;">Đã giao</a>
                            <a href="QuanTri.aspx?tab=orders&ost=<%= HttpUtility.UrlEncode("Đã hủy") %>" class="btn-pcm <%= (OrderFilterStatus == "Đã hủy" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:32px; font-size:12px;">Đã hủy</a>
                        </div>
                        <div style="font-size:13px; color:#64748b;">
                            Tổng: <strong><%= AllOrders.Count %></strong> đơn đặt hàng
                        </div>
                    </div>

                    <div style="width:100%; overflow:hidden; border-radius:10px;">
                        <table class="order-table" style="width:100%; table-layout:fixed;">
                            <thead>
                                <tr>
                                    <th style="width:14%;">Thông Tin Đơn</th>
                                    <th style="width:18%;">Khách Hàng</th>
                                    <th style="width:27%;">Sản Phẩm Trong Đơn</th>
                                    <th style="width:11%;">Tổng Tiền</th>
                                    <th style="width:15%;">Trạng Thái</th>
                                    <th style="width:15%;">Cập Nhật</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (int i = 0; i < AllOrders.Count; i++) {
                                       OrderInfo o = AllOrders[i]; %>
                                    <tr>
                                        <td>
                                            <span class="order-code-tag"><%= HttpUtility.HtmlEncode(o.OrderCode) %></span>
                                            <div style="font-size:11px; color:#64748b; margin-top:4px;">
                                                <i class="fa-regular fa-clock" style="color:#3D52BF; font-size:10px;"></i> <%= o.CreatedAt.ToString("dd/MM/yyyy") %>
                                                <span style="color:#94a3b8;"><%= o.CreatedAt.ToString("HH:mm") %></span>
                                            </div>
                                            <div class="order-id-sub">Đơn #<%= o.OrderId %></div>
                                        </td>
                                        <td>
                                            <div style="font-weight:700; font-size:12px; color:#0f172a; margin-bottom:2px;">
                                                <i class="fa-solid fa-user" style="color:#3D52BF; font-size:10px; margin-right:4px;"></i><%= HttpUtility.HtmlEncode(o.ReceiverName) %>
                                            </div>
                                            <div style="font-size:11px; color:#0284c7; font-weight:700; margin-bottom:2px;">
                                                <i class="fa-solid fa-phone" style="font-size:9px; margin-right:4px;"></i><%= HttpUtility.HtmlEncode(o.ReceiverPhone) %>
                                            </div>
                                            <div style="font-size:11px; color:#64748b; line-height:1.3;" title="<%= HttpUtility.HtmlAttributeEncode(o.ShippingAddress) %>">
                                                <i class="fa-solid fa-location-dot" style="font-size:9px; margin-right:4px;"></i><%= HttpUtility.HtmlEncode(o.ShippingAddress) %>
                                            </div>
                                        </td>
                                        <td>
                                            <%= UiHelper.RenderOrderItemsList(o.Details) %>
                                        </td>
                                        <td>
                                            <div style="font-weight:800; font-size:14px; color:#CB1C21; white-space:nowrap;"><%= SecurityHelper.FormatCurrency(o.TotalAmount) %></div>
                                            <% if (o.DiscountAmount > 0) { %>
                                                <div style="font-size:10px; color:#16a34a; font-weight:600;"><i class="fa-solid fa-tag"></i> Giảm: <%= SecurityHelper.FormatCurrency(o.DiscountAmount) %></div>
                                            <% } %>
                                            <div style="font-size:10px; color:#64748b;"><%= o.Details.Count %> linh kiện</div>
                                        </td>
                                        <td>
                                            <%= UiHelper.RenderOrderStatusBadge(o.OrderStatus) %>
                                        </td>
                                        <td>
                                            <% if (o.OrderStatus == "Đã giao" || o.OrderStatus == "Đã hủy") { %>
                                                <span style="font-size:11px; color:#94a3b8; font-weight:600; display:inline-flex; align-items:center; gap:4px; padding:4px 0;">
                                                    <i class="fa-solid fa-lock" style="font-size:10px;"></i> Đã hoàn tất
                                                </span>
                                            <% } else { %>
                                                <div style="display:flex; flex-direction:column; gap:4px; width:100%;">
                                                    <select name="ordStatus_<%= o.OrderId %>" class="pcm-form-control" style="width:100%; height:28px; font-size:11px; padding:0 4px;">
                                                        <option value="Chờ xác nhận" <%= (o.OrderStatus == "Chờ xác nhận" ? "selected='selected'" : "") %>>Chờ xác nhận</option>
                                                        <option value="Đang chờ vận chuyển" <%= (o.OrderStatus == "Đang chờ vận chuyển" ? "selected='selected'" : "") %>>Chờ vận chuyển</option>
                                                        <option value="Đang vận chuyển" <%= (o.OrderStatus == "Đang vận chuyển" ? "selected='selected'" : "") %>>Đang vận chuyển</option>
                                                        <option value="Đang giao" <%= (o.OrderStatus == "Đang giao" ? "selected='selected'" : "") %>>Đang giao</option>
                                                        <option value="Đã giao">Đã giao</option>
                                                        <% if (o.OrderStatus == "Chờ xác nhận" || o.OrderStatus == "Đang chờ vận chuyển") { %>
                                                            <option value="Đã hủy">Đã hủy (Hoàn kho)</option>
                                                        <% } %>
                                                    </select>
                                                    <button type="submit" class="btn-pcm btn-pcm-primary" style="width:100%; height:26px; font-size:11px; font-weight:700; padding:0;"
                                                            onclick="document.getElementById('adminAction').value='update_order';document.getElementById('adminTargetId').value='<%= o.OrderId %>';">
                                                        <i class="fa-solid fa-floppy-disk"></i> Lưu
                                                    </button>
                                                </div>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                                <% if (AllOrders.Count == 0) { %>
                                    <tr>
                                        <td colspan="6" style="text-align:center; padding:30px; color:#94a3b8;">
                                            <i class="fa-solid fa-inbox" style="font-size:24px; margin-bottom:8px;"></i>
                                            <div>Không có đơn hàng nào phù hợp với bộ lọc.</div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                
                <% } else if (ActiveTab == "users") { %>
                    <!-- ==================== TAB 5: QUẢN LÝ TÀI KHOẢN & PHÂN QUYỀN (UC12) ==================== -->
                    <div style="background:#f8fafc; border:1px solid #cbd5e1; border-radius:10px; padding:20px; margin-bottom:24px;">
                        <h3 style="color:#3D52BF; font-size:17px; margin-bottom:14px;">
                            <i class="fa-solid fa-user-plus"></i> TẠO TÀI KHOẢN NHÂN VIÊN / NGƯỜI DÙNG MỚI (UC12)
                        </h3>
                        <div style="display:flex; gap:12px; flex-wrap:wrap;">
                            <div class="form-group" style="width:160px;">
                                <label>Tên đăng nhập *</label>
                                <input type="text" name="NewUsername" class="form-control" placeholder="VD: staff3" />
                            </div>
                            <div class="form-group" style="width:150px;">
                                <label>Mật khẩu *</label>
                                <input type="password" name="NewPassword" class="form-control" placeholder="Tối thiểu 6 ký tự" />
                            </div>
                            <div class="form-group" style="flex:1; min-width:180px;">
                                <label>Họ và tên *</label>
                                <input type="text" name="NewFullName" class="form-control" placeholder="Họ tên nhân viên" />
                            </div>
                            <div class="form-group" style="width:200px;">
                                <label>Email *</label>
                                <input type="text" name="NewEmail" class="form-control" placeholder="staff3@pcmcomputer.vn" />
                            </div>
                            <div class="form-group" style="width:140px;">
                                <label>Số điện thoại *</label>
                                <input type="text" name="NewPhone" class="form-control" placeholder="09xxxxxxxx" />
                            </div>
                            <div class="form-group" style="width:150px;">
                                <label>Vai trò *</label>
                                <select name="NewRole" class="form-control">
                                    <option value="Staff">Staff (Nhân viên)</option>
                                    <option value="Admin">Admin (Quản trị)</option>
                                    <option value="Customer">Customer (Khách)</option>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="btn-pcm btn-pcm-primary"
                                onclick="document.getElementById('adminAction').value='create_user';">
                            <i class="fa-solid fa-user-check"></i> TẠO TÀI KHOẢN
                        </button>
                    </div>

                    <table class="pcm-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tên đăng nhập</th>
                                <th>Họ và tên</th>
                                <th>Email &amp; SĐT</th>
                                <th>Vai trò hiện tại</th>
                                <th>Trạng thái</th>
                                <th style="width:320px;">Phân quyền &amp; Khóa / Mở khóa (UC12)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < AllUsers.Count; i++) {
                                   UserInfo u = AllUsers[i]; %>
                                <tr>
                                    <td><%= u.UserId %></td>
                                    <td><strong><%= HttpUtility.HtmlEncode(u.Username) %></strong></td>
                                    <td><%= HttpUtility.HtmlEncode(u.FullName) %></td>
                                    <td style="font-size:13px;">
                                        <%= HttpUtility.HtmlEncode(u.Email) %><br />
                                        <span style="color:#64748b;"><%= HttpUtility.HtmlEncode(u.Phone) %></span>
                                    </td>
                                    <td>
                                        <span style="font-weight:700; color:<%= (u.Role == "Admin" ? "#CB1C21" : (u.Role == "Staff" ? "#0f766e" : "#3D52BF")) %>;">
                                            <%= HttpUtility.HtmlEncode(SecurityHelper.GetRoleLabel(u.Role)) %>
                                        </span>
                                    </td>
                                    <td>
                                        <% if (u.IsLocked) { %>
                                            <span style="background:#fee2e2;color:#991b1b;padding:3px 10px;border-radius:10px;font-size:12px;font-weight:700;">Đã khóa</span>
                                        <% } else { %>
                                            <span style="background:#dcfce7;color:#166534;padding:3px 10px;border-radius:10px;font-size:12px;font-weight:700;">Hoạt động</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div style="display:flex; gap:6px; align-items:center;">
                                            <select name="userRole_<%= u.UserId %>" class="filter-control" style="height:32px; font-size:12px; min-width:110px;">
                                                <option value="Admin" <%= (u.Role == "Admin" ? "selected='selected'" : "") %>>Quản trị viên</option>
                                                <option value="Staff" <%= (u.Role == "Staff" ? "selected='selected'" : "") %>>Nhân viên</option>
                                                <option value="Customer" <%= (u.Role == "Customer" ? "selected='selected'" : "") %>>Khách hàng</option>
                                            </select>
                                            <select name="userLock_<%= u.UserId %>" class="filter-control" style="height:32px; font-size:12px; min-width:110px;">
                                                <option value="0" <%= (!u.IsLocked ? "selected='selected'" : "") %>>Hoạt động</option>
                                                <option value="1" <%= (u.IsLocked ? "selected='selected'" : "") %>>Khóa TK</option>
                                            </select>
                                            <button type="submit" class="btn-pcm btn-pcm-primary" style="height:32px; padding:0 12px; font-size:12px;"
                                                    onclick="document.getElementById('adminAction').value='update_user_role';document.getElementById('adminTargetId').value='<%= u.UserId %>';">
                                                Lưu
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>

                <% } else if (ActiveTab == "promotions") { %>
                    <!-- ==================== TAB 6: QUẢN LÝ KHUYẾN MÃI (UC13) ==================== -->
                    <div style="background:#f8fafc; border:1px solid #cbd5e1; border-radius:10px; padding:20px; margin-bottom:24px;">
                        <h3 style="color:#3D52BF; font-size:17px; margin-bottom:14px;">
                            <i class="fa-solid fa-ticket"></i>
                            <%= (EditPromo != null ? ("CHỈNH SỬA MÃ KHUYẾN MÃI: " + HttpUtility.HtmlEncode(EditPromo.VoucherCode)) : "THÊM CHƯƠNG TRÌNH KHUYẾN MÃI / MÃ GIẢM GIÁ (UC13)") %>
                        </h3>

                        <input type="hidden" name="PromoId" value="<%= (EditPromo != null ? EditPromo.PromotionId : 0) %>" />

                        <div style="display:flex; gap:12px; flex-wrap:wrap;">
                            <div class="form-group" style="flex:1; min-width:220px;">
                                <label>Tên chương trình khuyến mãi *</label>
                                <input type="text" name="PromoName" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditPromo != null ? EditPromo.PromotionName : "") %>"
                                       placeholder="VD: Đại tiệc Build PC Giảm 1 Triệu" />
                            </div>
                            <div class="form-group" style="width:150px;">
                                <label>Mã giảm giá *</label>
                                <input type="text" name="PromoCode" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditPromo != null ? EditPromo.VoucherCode : "") %>"
                                       placeholder="VD: BUILDPC1M" />
                            </div>
                            <div class="form-group" style="width:160px;">
                                <label>Loại giảm giá *</label>
                                <select name="PromoType" class="form-control">
                                    <option value="AMOUNT" <%= (EditPromo != null && EditPromo.DiscountType == "AMOUNT" ? "selected='selected'" : "") %>>Số tiền (VNĐ)</option>
                                    <option value="PERCENT" <%= (EditPromo != null && EditPromo.DiscountType == "PERCENT" ? "selected='selected'" : "") %>>Phần trăm (%)</option>
                                </select>
                            </div>
                            <div class="form-group" style="width:150px;">
                                <label>Mức giảm *</label>
                                <input type="number" name="PromoValue" class="form-control"
                                       value="<%= (EditPromo != null ? EditPromo.DiscountValue : 500000) %>" />
                            </div>
                            <div class="form-group" style="width:160px;">
                                <label>Đơn tối thiểu (VNĐ)</label>
                                <input type="number" name="PromoMinOrder" class="form-control"
                                       value="<%= (EditPromo != null ? EditPromo.MinOrderAmount : 5000000) %>" />
                            </div>
                        </div>

                        <div style="display:flex; gap:12px; flex-wrap:wrap;">
                            <div class="form-group" style="width:160px;">
                                <label>Giảm tối đa (VNĐ)</label>
                                <input type="number" name="PromoMaxDiscount" class="form-control"
                                       value="<%= (EditPromo != null ? EditPromo.MaxDiscountAmount : 1000000) %>" />
                            </div>
                            <div class="form-group" style="width:130px;">
                                <label>Số lượt tối đa</label>
                                <input type="number" name="PromoLimit" class="form-control"
                                       value="<%= (EditPromo != null ? EditPromo.UsageLimit : 100) %>" />
                            </div>
                            <div class="form-group" style="width:160px;">
                                <label>Ngày bắt đầu *</label>
                                <input type="date" name="PromoStart" class="form-control"
                                       value="<%= (EditPromo != null ? EditPromo.StartDate.ToString("yyyy-MM-dd") : DateTime.Now.ToString("yyyy-MM-dd")) %>" />
                            </div>
                            <div class="form-group" style="width:160px;">
                                <label>Ngày kết thúc *</label>
                                <input type="date" name="PromoEnd" class="form-control"
                                       value="<%= (EditPromo != null ? EditPromo.EndDate.ToString("yyyy-MM-dd") : DateTime.Now.AddMonths(3).ToString("yyyy-MM-dd")) %>" />
                            </div>
                            <div class="form-group" style="width:150px;">
                                <label>Trạng thái</label>
                                <select name="PromoActive" class="form-control">
                                    <option value="1" <%= (EditPromo == null || EditPromo.IsActive ? "selected='selected'" : "") %>>Đang áp dụng</option>
                                    <option value="0" <%= (EditPromo != null && !EditPromo.IsActive ? "selected='selected'" : "") %>>Ngừng áp dụng</option>
                                </select>
                            </div>
                            <div class="form-group" style="flex:1; min-width:200px;">
                                <label>Điều kiện / Mô tả</label>
                                <input type="text" name="PromoDesc" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(EditPromo != null ? EditPromo.Description : "") %>" />
                            </div>
                        </div>

                        <div style="display:flex; gap:10px;">
                            <button type="submit" class="btn-pcm btn-pcm-primary"
                                    onclick="document.getElementById('adminAction').value='save_promotion';">
                                <i class="fa-solid fa-floppy-disk"></i> LƯU CHƯƠNG TRÌNH KHUYẾN MÃI
                            </button>
                            <% if (EditPromo != null) { %>
                                <a href="QuanTri.aspx?tab=promotions" class="btn-pcm btn-pcm-outline">Hủy</a>
                            <% } %>
                        </div>
                    </div>

                    <table class="pcm-table">
                        <thead>
                            <tr>
                                <th>Mã giảm giá</th>
                                <th>Tên chương trình</th>
                                <th>Mức giảm</th>
                                <th>Đơn tối thiểu</th>
                                <th>Thời hạn áp dụng</th>
                                <th>Đã dùng / Tổng lượt</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < AllPromotions.Count; i++) {
                                   PromotionInfo pr = AllPromotions[i];
                                   bool isExpired = DateTime.Now > pr.EndDate; %>
                                <tr>
                                    <td><strong style="color:#CB1C21; font-size:15px;"><%= HttpUtility.HtmlEncode(pr.VoucherCode) %></strong></td>
                                    <td>
                                        <strong><%= HttpUtility.HtmlEncode(pr.PromotionName) %></strong>
                                        <div style="font-size:12px; color:#64748b;"><%= HttpUtility.HtmlEncode(pr.Description) %></div>
                                    </td>
                                    <td style="font-weight:700; color:#3D52BF;">
                                        <%= (pr.DiscountType == "PERCENT" ? (pr.DiscountValue + "%") : SecurityHelper.FormatCurrency(pr.DiscountValue)) %>
                                    </td>
                                    <td><%= SecurityHelper.FormatCurrency(pr.MinOrderAmount) %></td>
                                    <td style="font-size:13px;">
                                        <%= pr.StartDate.ToString("dd/MM/yyyy") %> &rarr; <%= pr.EndDate.ToString("dd/MM/yyyy") %>
                                    </td>
                                    <td><strong><%= pr.UsedCount %> / <%= pr.UsageLimit %></strong></td>
                                    <td>
                                        <% if (!pr.IsActive) { %>
                                            <span style="background:#e2e8f0;color:#475569;padding:3px 8px;border-radius:10px;font-size:12px;">Đã tắt</span>
                                        <% } else if (isExpired) { %>
                                            <span style="background:#fee2e2;color:#991b1b;padding:3px 8px;border-radius:10px;font-size:12px;font-weight:700;">Đã hết hạn</span>
                                        <% } else { %>
                                            <span style="background:#dcfce7;color:#166534;padding:3px 8px;border-radius:10px;font-size:12px;font-weight:700;">Đang hiệu lực</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <a href="QuanTri.aspx?tab=promotions&editPromo=<%= pr.PromotionId %>" class="btn-pcm btn-pcm-outline" style="height:30px; padding:0 10px; font-size:12px;">
                                            <i class="fa-solid fa-pen"></i> Sửa
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            <% } %>
        </div>
    </div>
</asp:Content>
