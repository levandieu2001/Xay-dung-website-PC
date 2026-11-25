<%@ Page Language="C#" MasterPageFile="~/BoCucChung.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    protected UserInfo CurrentUser = null;
    protected bool IsAuthorized = false;
    protected string ActiveTab = "orders"; // orders | inventory
    protected string AlertMessage = "";
    protected bool IsAlertSuccess = true;

    // Dữ liệu Tab Quản lý đơn hàng (UC11)
    protected string OrderStatusFilter = "";
    protected string OrderKeyword = "";
    protected List<OrderInfo> OrdersList = new List<OrderInfo>();
    protected OrderInfo SelectedOrder = null;

    // Dữ liệu Tab Kiểm tra tồn kho & Cập nhật sản phẩm (UC09 - Staff)
    protected int ProdCatFilter = 0;
    protected string ProdKeyword = "";
    protected List<CategoryInfo> Categories = new List<CategoryInfo>();
    protected List<ProductInfo> ProductsList = new List<ProductInfo>();
    protected ProductInfo EditingProduct = null;

    protected void Page_Load(object sender, EventArgs e)
    {
        CurrentUser = SecurityHelper.GetCurrentUser();
        if (CurrentUser == null)
        {
            Response.Redirect("DangNhap.aspx?returnUrl=NhanVien.aspx");
            return;
        }

        IsAuthorized = SecurityHelper.IsStaffOrAdmin();
        if (!IsAuthorized)
        {
            return;
        }

        if (!string.IsNullOrEmpty(Request.QueryString["tab"]))
        {
            ActiveTab = Request.QueryString["tab"].Trim().ToLower();
        }
        if (!string.IsNullOrEmpty(Request.Form["activeTabInput"]))
        {
            ActiveTab = Request.Form["activeTabInput"].Trim().ToLower();
        }

        if (IsPostBack)
        {
            string staffAction = Request.Form["staffAction"];

            // Xử lý cập nhật trạng thái đơn hàng (UC11)
            if (staffAction == "update_order_status")
            {
                int ordId = 0;
                int.TryParse(Request.Form["targetOrderId"], out ordId);
                string newSt = Request.Form["newStatus_" + ordId] ?? "";
                string note = Request.Form["statusNote_" + ordId] ?? "";
                if (ordId > 0 && !string.IsNullOrEmpty(newSt))
                {
                    string msg;
                    IsAlertSuccess = DbHelper.UpdateOrderStatus(ordId, newSt, CurrentUser.Username, note, false, out msg);
                    AlertMessage = msg;
                }
                ActiveTab = "orders";
            }
            // Xử lý cập nhật thông tin mô tả & đối chiếu tồn kho sản phẩm (UC09 - Staff)
            else if (staffAction == "save_staff_product")
            {
                int pid = 0;
                int.TryParse(Request.Form["EditProductId"], out pid);
                decimal price = 0;
                decimal.TryParse(Request.Form["EditPrice"], out price);
                int stock = 0;
                int.TryParse(Request.Form["EditStock"], out stock);
                int war = 24;
                int.TryParse(Request.Form["EditWarranty"], out war);
                string specs = Request.Form["EditSpecs"] ?? "";
                string desc = Request.Form["EditDesc"] ?? "";

                string err;
                if (DbHelper.StaffUpdateProduct(pid, price, stock, war, specs, desc, out err))
                {
                    IsAlertSuccess = true;
                    AlertMessage = "Nhân viên đã cập nhật thông tin và đối chiếu số lượng tồn kho sản phẩm thành công!";
                }
                else
                {
                    IsAlertSuccess = false;
                    AlertMessage = err;
                }
                ActiveTab = "inventory";
            }
        }

        // Tải dữ liệu theo Tab
        OrderStatusFilter = (Request.QueryString["st"] ?? "").Trim();
        OrderKeyword = (Request.QueryString["qOrd"] ?? "").Trim();
        OrdersList = DbHelper.GetAllOrders(OrderStatusFilter, OrderKeyword);

        int viewOrdId = 0;
        if (int.TryParse(Request.QueryString["viewOrder"], out viewOrdId) && viewOrdId > 0)
        {
            SelectedOrder = DbHelper.GetOrderById(viewOrdId);
        }

        Categories = DbHelper.GetCategories(false);
        if (!string.IsNullOrEmpty(Request.QueryString["pCat"]))
            int.TryParse(Request.QueryString["pCat"], out ProdCatFilter);
        ProdKeyword = (Request.QueryString["pKw"] ?? "").Trim();

        int? catNullable = ProdCatFilter > 0 ? (int?)ProdCatFilter : null;
        ProductsList = DbHelper.SearchProducts(catNullable, ProdKeyword, "", "", "newest", true);

        int editPid = 0;
        if (int.TryParse(Request.QueryString["editProd"], out editPid) && editPid > 0)
        {
            EditingProduct = DbHelper.GetProductById(editPid);
            ActiveTab = "inventory";
        }
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="pcm-page-card">
            <% if (!IsAuthorized) { %>
                <div class="pcm-alert pcm-alert-error" style="text-align:center; padding:30px;">
                    <i class="fa-solid fa-lock" style="font-size:36px; margin-bottom:10px;"></i>
                    <h3>Từ chối truy cập!</h3>
                    <p style="margin-top:8px;">Trang Nghiệp vụ bán hàng chỉ dành cho <strong>Nhân viên (Staff)</strong> và <strong>Quản trị viên (Admin)</strong>.</p>
                    <p style="margin-top:14px;"><a href="TrangChu.aspx" class="btn-pcm btn-pcm-primary">Về trang chủ</a></p>
                </div>
            <% } else { %>
                <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; margin-bottom:16px;">
                    <div>
                        <h1 class="pcm-page-title" style="margin-bottom:4px;">
                            <i class="fa-solid fa-headset"></i> PHÂN HỆ NGHIỆP VỤ BÁN HÀNG - NHÂN VIÊN (STAFF)
                        </h1>
                        <p style="font-size:13px; color:#64748b;">
                            Xin chào <strong><%= HttpUtility.HtmlEncode(CurrentUser.FullName) %></strong> (Vai trò: <strong><%= CurrentUser.Role %></strong>) &mdash; Tiếp nhận xử lý đơn hàng (UC11) &amp; Kiểm tra tồn kho, cập nhật thông tin sản phẩm (UC09).
                        </p>
                    </div>
                    <div style="display:flex; gap:8px;">
                        <% if (CurrentUser.Role == "Admin") { %>
                            <a href="QuanTri.aspx" class="btn-pcm btn-pcm-danger">
                                <i class="fa-solid fa-user-shield"></i> Sang Trang Quản Trị Admin
                            </a>
                        <% } %>
                        <a href="HoSo.aspx" class="btn-pcm btn-pcm-outline">
                            <i class="fa-solid fa-user-gear"></i> Hồ sơ cá nhân
                        </a>
                    </div>
                </div>

                <% if (!string.IsNullOrEmpty(AlertMessage)) { %>
                    <div class="pcm-alert <%= (IsAlertSuccess ? "pcm-alert-success" : "pcm-alert-error") %>">
                        <i class="fa-solid <%= (IsAlertSuccess ? "fa-circle-check" : "fa-triangle-exclamation") %>"></i>
                        <%= HttpUtility.HtmlEncode(AlertMessage) %>
                    </div>
                <% } %>

                <input type="hidden" id="activeTabInput" name="activeTabInput" value="<%= ActiveTab %>" />
                <input type="hidden" id="staffAction" name="staffAction" value="" />
                <input type="hidden" id="targetOrderId" name="targetOrderId" value="0" />

                <!-- Thanh chuyển Tab nghiệp vụ Staff -->
                <div class="portal-tabs">
                    <a href="NhanVien.aspx?tab=orders" class="portal-tab <%= (ActiveTab == "orders" ? "active" : "") %>">
                        <i class="fa-solid fa-truck-ramp-box"></i> 1. Tiếp Nhận &amp; Xử Lý Đơn Hàng (UC11) (<%= OrdersList.Count %>)
                    </a>
                    <a href="NhanVien.aspx?tab=inventory" class="portal-tab <%= (ActiveTab == "inventory" ? "active" : "") %>">
                        <i class="fa-solid fa-boxes-stacked"></i> 2. Kiểm Tra Tồn Kho &amp; Cập Nhật Sản Phẩm (UC09 - Staff)
                    </a>
                </div>

                <% if (ActiveTab == "orders") { %>
                    <!-- ==================== TAB 1: QUẢN LÝ ĐƠN HÀNG (UC11) ==================== -->
                    <div class="filter-bar">
                        <div class="filter-group">
                            <label>Lọc theo trạng thái đơn hàng</label>
                            <div style="display:flex; gap:6px; flex-wrap:wrap;">
                                <a href="NhanVien.aspx?tab=orders" class="btn-pcm <%= (OrderStatusFilter == "" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:34px; font-size:12px;">Tất cả</a>
                                <a href="NhanVien.aspx?tab=orders&st=<%= HttpUtility.UrlEncode("Chờ xác nhận") %>" class="btn-pcm <%= (OrderStatusFilter == "Chờ xác nhận" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:34px; font-size:12px;">Chờ xác nhận</a>
                                <a href="NhanVien.aspx?tab=orders&st=<%= HttpUtility.UrlEncode("Đang chờ vận chuyển") %>" class="btn-pcm <%= (OrderStatusFilter == "Đang chờ vận chuyển" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:34px; font-size:12px;">Đang chờ vận chuyển</a>
                                <a href="NhanVien.aspx?tab=orders&st=<%= HttpUtility.UrlEncode("Đang vận chuyển") %>" class="btn-pcm <%= (OrderStatusFilter == "Đang vận chuyển" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:34px; font-size:12px;">Đang vận chuyển</a>
                                <a href="NhanVien.aspx?tab=orders&st=<%= HttpUtility.UrlEncode("Đang giao") %>" class="btn-pcm <%= (OrderStatusFilter == "Đang giao" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:34px; font-size:12px;">Đang giao</a>
                                <a href="NhanVien.aspx?tab=orders&st=<%= HttpUtility.UrlEncode("Đã giao") %>" class="btn-pcm <%= (OrderStatusFilter == "Đã giao" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:34px; font-size:12px;">Đã giao</a>
                                <a href="NhanVien.aspx?tab=orders&st=<%= HttpUtility.UrlEncode("Đã hủy") %>" class="btn-pcm <%= (OrderStatusFilter == "Đã hủy" ? "btn-pcm-primary" : "btn-pcm-outline") %>" style="height:34px; font-size:12px;">Đã hủy</a>
                            </div>
                        </div>
                    </div>

                    <% if (SelectedOrder != null) { %>
                        <div style="background:#f8fafc; border:2px solid #3D52BF; border-radius:10px; padding:18px; margin-bottom:20px;">
                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                <h3 style="color:#3D52BF;">Chi tiết đơn hàng: <%= HttpUtility.HtmlEncode(SelectedOrder.OrderCode) %></h3>
                                <a href="NhanVien.aspx?tab=orders" class="btn-pcm btn-pcm-outline" style="height:32px; font-size:12px;">Đóng</a>
                            </div>
                            <p style="font-size:14px; margin:8px 0;">
                                <strong>Khách hàng:</strong> <%= HttpUtility.HtmlEncode(SelectedOrder.ReceiverName) %> |
                                <strong>SĐT:</strong> <%= HttpUtility.HtmlEncode(SelectedOrder.ReceiverPhone) %> |
                                <strong>Địa chỉ:</strong> <%= HttpUtility.HtmlEncode(SelectedOrder.ShippingAddress) %>
                            </p>
                            <table class="pcm-table" style="margin-top:10px;">
                                <thead>
                                    <tr>
                                        <th>Mã SP</th>
                                        <th>Tên sản phẩm</th>
                                        <th>Đơn giá</th>
                                        <th>Số lượng</th>
                                        <th>Thành tiền</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (int i = 0; i < SelectedOrder.Details.Count; i++) {
                                           OrderDetailInfo d = SelectedOrder.Details[i]; %>
                                        <tr>
                                            <td><strong><%= HttpUtility.HtmlEncode(d.ProductCode) %></strong></td>
                                            <td><%= HttpUtility.HtmlEncode(d.ProductName) %></td>
                                            <td><%= SecurityHelper.FormatCurrency(d.UnitPrice) %></td>
                                            <td><strong><%= d.Quantity %></strong></td>
                                            <td style="font-weight:700; color:#CB1C21;"><%= SecurityHelper.FormatCurrency(d.LineTotal) %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>

                    <div style="width:100%; overflow:hidden; border-radius:10px;">
                        <table class="order-table" style="width:100%; table-layout:fixed;">
                            <thead>
                                <tr>
                                    <th style="width:14%;">Thông Tin Đơn</th>
                                    <th style="width:18%;">Khách Hàng</th>
                                    <th style="width:26%;">Linh Kiện Đặt Mua</th>
                                    <th style="width:11%;">Tổng Thu COD</th>
                                    <th style="width:15%;">Trạng Thái</th>
                                    <th style="width:16%;">Xác Nhận &amp; Cập Nhật</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (int i = 0; i < OrdersList.Count; i++) {
                                       OrderInfo o = OrdersList[i]; %>
                                    <tr>
                                        <td>
                                            <span class="order-code-tag"><%= HttpUtility.HtmlEncode(o.OrderCode) %></span>
                                            <div style="font-size:11px; color:#64748b; margin-top:4px;">
                                                <i class="fa-regular fa-clock" style="color:#3D52BF; font-size:10px;"></i> <%= o.CreatedAt.ToString("dd/MM/yyyy") %>
                                                <span style="color:#94a3b8;"><%= o.CreatedAt.ToString("HH:mm") %></span>
                                            </div>
                                            <div style="margin-top:5px;">
                                                <a href="NhanVien.aspx?tab=orders&viewOrder=<%= o.OrderId %>" class="btn-pcm btn-pcm-outline" style="height:24px; padding:0 8px; font-size:11px; text-decoration:none; display:inline-flex; align-items:center; gap:4px;">
                                                    <i class="fa-solid fa-eye"></i> Chi tiết
                                                </a>
                                            </div>
                                        </td>
                                        <td>
                                            <div style="font-weight:700; font-size:12px; color:#0f172a; margin-bottom:2px;">
                                                <i class="fa-solid fa-user" style="color:#3D52BF; font-size:10px; margin-right:4px;"></i><%= HttpUtility.HtmlEncode(o.ReceiverName) %>
                                            </div>
                                            <div style="font-size:11px; color:#0369a1; font-weight:700; margin-bottom:2px;">
                                                <i class="fa-solid fa-phone" style="font-size:9px; margin-right:4px;"></i><%= HttpUtility.HtmlEncode(o.ReceiverPhone) %>
                                            </div>
                                            <div style="font-size:11px; color:#64748b; line-height:1.3;" title="<%= HttpUtility.HtmlAttributeEncode(o.ShippingAddress) %>">
                                                <i class="fa-solid fa-location-dot" style="font-size:9px; margin-right:4px;"></i><%= HttpUtility.HtmlEncode(o.ShippingAddress) %>
                                            </div>
                                            <% if (!string.IsNullOrEmpty(o.Note)) { %>
                                                <div style="margin-top:4px; display:inline-block; background:#fffbeb; color:#b45309; border:1px solid #fef3c7; border-radius:4px; padding:1px 6px; font-size:10px; font-weight:600;">
                                                    <i class="fa-regular fa-note-sticky"></i> <%= HttpUtility.HtmlEncode(o.Note) %>
                                                </div>
                                            <% } %>
                                        </td>
                                        <td>
                                            <%= UiHelper.RenderOrderItemsList(o.Details) %>
                                        </td>
                                        <td>
                                            <div style="font-weight:800; font-size:14px; color:#CB1C21; white-space:nowrap;">
                                                <%= SecurityHelper.FormatCurrency(o.TotalAmount) %>
                                            </div>
                                            <div style="font-size:10px; color:#64748b; margin-top:2px;">(Thu COD tận nơi)</div>
                                            <% if (o.DiscountAmount > 0) { %>
                                                <div style="font-size:10px; color:#16a34a; font-weight:600;">Giảm: <%= SecurityHelper.FormatCurrency(o.DiscountAmount) %></div>
                                            <% } %>
                                        </td>
                                        <td>
                                            <%= UiHelper.RenderOrderStatusBadge(o.OrderStatus) %>
                                        </td>
                                        <td>
                                            <% if (o.OrderStatus == "Đã giao" || o.OrderStatus == "Đã hủy") { %>
                                                <span style="font-size:11px; color:#94a3b8; font-weight:600; display:inline-flex; align-items:center; gap:4px; padding:4px 0;">
                                                    <i class="fa-solid fa-lock" style="font-size:10px;"></i> Đã kết thúc xử lý
                                                </span>
                                            <% } else { %>
                                                <div style="display:flex; flex-direction:column; gap:4px; width:100%;">
                                                    <select name="newStatus_<%= o.OrderId %>" class="pcm-form-control" style="width:100%; height:28px; font-size:11px; padding:0 4px;">
                                                        <option value="Chờ xác nhận" <%= (o.OrderStatus == "Chờ xác nhận" ? "selected='selected'" : "") %>>Chờ xác nhận</option>
                                                        <option value="Đang chờ vận chuyển" <%= (o.OrderStatus == "Đang chờ vận chuyển" ? "selected='selected'" : "") %>>Đang chờ vận chuyển</option>
                                                        <option value="Đang vận chuyển" <%= (o.OrderStatus == "Đang vận chuyển" ? "selected='selected'" : "") %>>Đang vận chuyển</option>
                                                        <option value="Đang giao" <%= (o.OrderStatus == "Đang giao" ? "selected='selected'" : "") %>>Đang giao</option>
                                                        <option value="Đã giao">Đã giao (Hoàn tất)</option>
                                                        <% if (o.OrderStatus == "Chờ xác nhận" || o.OrderStatus == "Đang chờ vận chuyển") { %>
                                                            <option value="Đã hủy">Đã hủy (Hoàn kho)</option>
                                                        <% } %>
                                                    </select>
                                                    <div style="display:flex; gap:4px; width:100%;">
                                                        <input type="text" name="statusNote_<%= o.OrderId %>" class="pcm-form-control"
                                                               style="height:26px; font-size:11px; flex:1; min-width:0; padding:0 6px;"
                                                               placeholder="Ghi chú..." />
                                                        <button type="submit" class="btn-pcm btn-pcm-primary" style="height:26px; padding:0 10px; font-size:11px; font-weight:700; white-space:nowrap; flex-shrink:0;"
                                                                onclick="document.getElementById('staffAction').value='update_order_status';document.getElementById('targetOrderId').value='<%= o.OrderId %>';">
                                                            Lưu
                                                        </button>
                                                    </div>
                                                </div>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } else { %>
                    <!-- ==================== TAB 2: KIỂM TRA TỒN KHO & CẬP NHẬT SẢN PHẨM (UC09 - STAFF) ==================== -->
                    <% if (EditingProduct != null) { %>
                        <div style="background:#f8fafc; border:2px solid #0f766e; border-radius:10px; padding:20px; margin-bottom:24px;">
                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px;">
                                <h3 style="color:#0f766e; font-size:17px;">
                                    <i class="fa-solid fa-pen-to-square"></i> CẬP NHẬT THÔNG TIN &amp; ĐỐI CHIẾU TỒN KHO:
                                    [<%= HttpUtility.HtmlEncode(EditingProduct.ProductCode) %>] <%= HttpUtility.HtmlEncode(EditingProduct.ProductName) %>
                                </h3>
                                <a href="NhanVien.aspx?tab=inventory" class="btn-pcm btn-pcm-outline" style="height:32px; font-size:12px;">Đóng</a>
                            </div>

                            <input type="hidden" name="EditProductId" value="<%= EditingProduct.ProductId %>" />

                            <div style="display:flex; gap:16px; flex-wrap:wrap;">
                                <div class="form-group" style="flex:1; min-width:180px;">
                                    <label>Giá bán hiện tại (VNĐ)</label>
                                    <input type="number" name="EditPrice" class="form-control" value="<%= EditingProduct.Price %>" />
                                </div>
                                <div class="form-group" style="flex:1; min-width:180px;">
                                    <label>Số lượng tồn kho thực tế</label>
                                    <input type="number" name="EditStock" class="form-control" value="<%= EditingProduct.StockQuantity %>" min="0" />
                                </div>
                                <div class="form-group" style="flex:1; min-width:180px;">
                                    <label>Thời hạn bảo hành (Tháng)</label>
                                    <input type="number" name="EditWarranty" class="form-control" value="<%= EditingProduct.WarrantyMonths %>" min="1" />
                                </div>
                            </div>

                            <div class="form-group">
                                <label>Thông số kỹ thuật chi tiết (Phân tách bằng dấu |)</label>
                                <textarea name="EditSpecs" rows="3" class="form-control"><%= HttpUtility.HtmlEncode(EditingProduct.Specifications) %></textarea>
                            </div>

                            <div class="form-group">
                                <label>Mô tả tư vấn sản phẩm</label>
                                <textarea name="EditDesc" rows="3" class="form-control"><%= HttpUtility.HtmlEncode(EditingProduct.Description) %></textarea>
                            </div>

                            <button type="submit" class="btn-pcm btn-pcm-success" style="height:40px; padding:0 24px;"
                                    onclick="document.getElementById('staffAction').value='save_staff_product';">
                                <i class="fa-solid fa-floppy-disk"></i> LƯU CẬP NHẬT TỒN KHO &amp; MÔ TẢ
                            </button>
                        </div>
                    <% } %>

                    <!-- Thanh Tìm Kiếm & Bộ Lọc Tồn Kho Sản Phẩm (UC09) -->
                    <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; padding:12px 16px; margin-bottom:16px;">
                        <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                            <div style="flex:1; min-width:240px; position:relative;">
                                <input type="text" id="invSearchKw" name="pKw" value="<%= HttpUtility.HtmlAttributeEncode(ProdKeyword) %>"
                                       placeholder="Tìm kiếm máy tính, linh kiện, mã SP (VD: RTX, ASUS, COPS0005...)"
                                       class="pcm-form-control" style="height:36px; font-size:12px; width:100%; padding-left:32px;"
                                       onkeydown="if(event.key==='Enter'){event.preventDefault();doStaffSearch();}" />
                                <i class="fa-solid fa-magnifying-glass" style="position:absolute; left:10px; top:50%; transform:translateY(-50%); color:#94a3b8; font-size:13px;"></i>
                            </div>
                            <div style="width:200px;">
                                <select id="invCatSelect" name="pCat" class="pcm-form-control" style="height:36px; font-size:12px; width:100%;" onchange="doStaffSearch();">
                                    <option value="0">-- Tất cả danh mục --</option>
                                    <% for (int cIdx = 0; cIdx < Categories.Count; cIdx++) {
                                           CategoryInfo cat = Categories[cIdx]; %>
                                        <option value="<%= cat.CategoryId %>" <%= (ProdCatFilter == cat.CategoryId ? "selected='selected'" : "") %>><%= HttpUtility.HtmlEncode(cat.CategoryName) %></option>
                                    <% } %>
                                </select>
                            </div>
                            <button type="button" class="btn-pcm btn-pcm-primary" style="height:36px; padding:0 16px; font-size:12px; gap:6px;" onclick="doStaffSearch();">
                                <i class="fa-solid fa-filter"></i> Lọc / Tìm kiếm
                            </button>
                            <% if (!string.IsNullOrEmpty(ProdKeyword) || ProdCatFilter > 0) { %>
                                <a href="NhanVien.aspx?tab=inventory" class="btn-pcm btn-pcm-outline" style="height:36px; padding:0 12px; font-size:12px; gap:4px; text-decoration:none;">
                                    <i class="fa-solid fa-rotate-left"></i> Đặt lại
                                </a>
                            <% } %>
                            <div style="margin-left:auto; font-size:12px; color:#64748b; white-space:nowrap;">
                                Tìm thấy: <strong style="color:#3D52BF; font-size:14px;"><%= ProductsList.Count %></strong> sản phẩm
                            </div>
                        </div>
                    </div>

                    <script>
                        function doStaffSearch() {
                            var kw = document.getElementById('invSearchKw').value.trim();
                            var cat = document.getElementById('invCatSelect').value;
                            var url = 'NhanVien.aspx?tab=inventory';
                            if (kw.length > 0) url += '&pKw=' + encodeURIComponent(kw);
                            if (cat && cat !== '0') url += '&pCat=' + encodeURIComponent(cat);
                            window.location.href = url;
                        }
                    </script>

                    <div style="width:100%; overflow:hidden; border-radius:10px;">
                        <table class="pcm-table" style="width:100%; table-layout:fixed;">
                            <thead>
                                <tr>
                                    <th style="width:5%; text-align:center;">Hình</th>
                                    <th style="width:9%;">Mã SP</th>
                                    <th style="width:28%;">Tên Sản Phẩm</th>
                                    <th style="width:12%;">Danh Mục</th>
                                    <th style="width:11%;">Giá Bán</th>
                                    <th style="width:8%;">Bảo Hành</th>
                                    <th style="width:10%;">Tồn Kho</th>
                                    <th style="width:8%;">Trạng Thái</th>
                                    <th style="width:9%; text-align:center;">Nghiệp Vụ</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (int i = 0; i < ProductsList.Count; i++) {
                                       ProductInfo p = ProductsList[i]; %>
                                    <tr>
                                        <td style="text-align:center;">
                                            <img src="<%= HttpUtility.HtmlAttributeEncode(p.ImageUrl) %>" alt=""
                                                 style="width:40px; height:40px; object-fit:contain; border:1px solid #e2e8f0; border-radius:4px; padding:2px; background:#fff;" />
                                        </td>
                                        <td>
                                            <strong style="color:#3D52BF; font-size:12px; font-family:'Consolas',monospace;"><%= HttpUtility.HtmlEncode(p.ProductCode) %></strong>
                                        </td>
                                        <td>
                                            <a href="ChiTietSanPham.aspx?id=<%= p.ProductId %>" target="_blank" style="font-weight:600; color:#1e293b; font-size:12px; line-height:1.3; display:block;" title="<%= HttpUtility.HtmlAttributeEncode(p.ProductName) %>">
                                                <%= HttpUtility.HtmlEncode(UiHelper.FormatShortProductName(p.ProductName, 6)) %>
                                            </a>
                                        </td>
                                        <td style="font-size:12px; color:#475569;"><%= HttpUtility.HtmlEncode(p.CategoryName) %></td>
                                        <td style="font-weight:700; color:#CB1C21; font-size:12px;"><%= SecurityHelper.FormatCurrency(p.Price) %></td>
                                        <td style="font-size:12px;"><%= p.WarrantyMonths %> tháng</td>
                                        <td>
                                            <% if (p.StockQuantity <= 5) { %>
                                                <span style="background:#fee2e2; color:#991b1b; padding:2px 8px; border-radius:10px; font-weight:700; font-size:11px; white-space:nowrap; display:inline-block;">
                                                    <i class="fa-solid fa-triangle-exclamation"></i> <%= p.StockQuantity %> SP
                                                </span>
                                            <% } else { %>
                                                <span style="background:#dcfce7; color:#166534; padding:2px 8px; border-radius:10px; font-weight:700; font-size:11px; white-space:nowrap; display:inline-block;">
                                                    Còn: <%= p.StockQuantity %> SP
                                                </span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <% if (p.Status == "Đang kinh doanh") { %>
                                                <span style="background:#eff6ff; color:#1d4ed8; padding:2px 6px; border-radius:4px; font-size:11px; font-weight:600; white-space:nowrap;">Đang bán</span>
                                            <% } else { %>
                                                <span style="background:#f1f5f9; color:#64748b; padding:2px 6px; border-radius:4px; font-size:11px; font-weight:600; white-space:nowrap;">Ngừng bán</span>
                                            <% } %>
                                        </td>
                                        <td style="text-align:center;">
                                            <a href="NhanVien.aspx?tab=inventory&editProd=<%= p.ProductId %>" class="btn-pcm btn-pcm-primary" style="height:28px; padding:0 8px; font-size:11px; font-weight:700; white-space:nowrap; display:inline-flex; align-items:center; gap:4px; text-decoration:none;">
                                                <i class="fa-solid fa-pen-to-square"></i> Cập nhật
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                                <% if (ProductsList.Count == 0) { %>
                                    <tr>
                                        <td colspan="9" style="text-align:center; padding:35px 20px; color:#94a3b8;">
                                            <i class="fa-solid fa-box-open" style="font-size:32px; margin-bottom:8px;"></i>
                                            <div>Không tìm thấy sản phẩm nào phù hợp với từ khóa hoặc danh mục đã chọn.</div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div></div>
                <% } %>
            <% } %>
        </div>
    </div>
</asp:Content>
