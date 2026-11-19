<%@ Page Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    protected UserInfo CurrentUser = null;
    protected List<OrderInfo> UserOrders = new List<OrderInfo>();
    protected OrderInfo SelectedOrderDetail = null;
    protected string AlertMessage = "";
    protected bool IsAlertSuccess = true;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Tiền điều kiện UC08: Khách hàng đã đăng nhập vào hệ thống (UC02)
        CurrentUser = SecurityHelper.GetCurrentUser();
        if (CurrentUser == null)
        {
            Response.Redirect("Login.aspx?returnUrl=MyOrders.aspx");
            return;
        }

        if (IsPostBack)
        {
            string action = Request.Form["orderAction"];
            int targetOrderId = 0;
            int.TryParse(Request.Form["targetOrderId"], out targetOrderId);

            if (action == "cancel" && targetOrderId > 0)
            {
                OrderInfo ord = DbHelper.GetOrderById(targetOrderId);
                if (ord != null && ord.UserId == CurrentUser.UserId)
                {
                    string msg;
                    IsAlertSuccess = DbHelper.UpdateOrderStatus(targetOrderId, "Đã hủy", CurrentUser.Username, "Khách hàng yêu cầu hủy đơn trực tuyến", true, out msg);
                    AlertMessage = msg;
                }
            }
        }

        int viewId = 0;
        if (!string.IsNullOrEmpty(Request.QueryString["viewId"]))
        {
            int.TryParse(Request.QueryString["viewId"], out viewId);
        }

        if (viewId > 0)
        {
            OrderInfo detail = DbHelper.GetOrderById(viewId);
            if (detail != null && (detail.UserId == CurrentUser.UserId || SecurityHelper.IsStaffOrAdmin()))
            {
                SelectedOrderDetail = detail;
            }
        }

        UserOrders = DbHelper.GetOrdersByUser(CurrentUser.UserId);
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="pcm-page-card">
            <div class="breadcrumb">
                <a href="Home.aspx"><i class="fa-solid fa-house"></i> Trang chủ</a> /
                <a href="Profile.aspx">Tài khoản</a> /
                <span>Đơn hàng của tôi (UC08)</span>
            </div>

            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; margin-bottom:14px;">
                <h1 class="pcm-page-title" style="margin-bottom:0;">
                    <i class="fa-solid fa-clipboard-list"></i> LỊCH SỬ MUA HÀNG &amp; THEO DÕI ĐƠN HÀNG (UC08)
                </h1>
                <a href="Products.aspx" class="btn-pcm btn-pcm-outline">
                    <i class="fa-solid fa-bag-shopping"></i> Đặt thêm đơn mới
                </a>
            </div>

            <% if (!string.IsNullOrEmpty(AlertMessage)) { %>
                <div class="pcm-alert <%= (IsAlertSuccess ? "pcm-alert-success" : "pcm-alert-error") %>">
                    <i class="fa-solid <%= (IsAlertSuccess ? "fa-circle-check" : "fa-triangle-exclamation") %>"></i>
                    <%= HttpUtility.HtmlEncode(AlertMessage) %>
                </div>
            <% } %>

            <input type="hidden" id="orderAction" name="orderAction" value="" />
            <input type="hidden" id="targetOrderId" name="targetOrderId" value="0" />

            <% if (SelectedOrderDetail != null) { %>
                <!-- Khung xem chi tiết một đơn hàng và tiến độ xử lý -->
                <div style="background:#f8fafc; border:2px solid #3D52BF; border-radius:10px; padding:20px; margin-bottom:25px;">
                    <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; border-bottom:1px solid #cbd5e1; padding-bottom:12px; margin-bottom:14px;">
                        <div>
                            <h3 style="color:#3D52BF; font-size:18px;">
                                CHI TIẾT ĐƠN HÀNG: <span style="color:#CB1C21;"><%= HttpUtility.HtmlEncode(SelectedOrderDetail.OrderCode) %></span>
                            </h3>
                            <div style="font-size:13px; color:#64748b; margin-top:4px;">
                                Ngày đặt: <%= SelectedOrderDetail.CreatedAt.ToString("dd/MM/yyyy HH:mm") %> |
                                Thanh toán: <strong><%= HttpUtility.HtmlEncode(SelectedOrderDetail.PaymentMethod) %></strong>
                            </div>
                        </div>
                        <div style="display:flex; align-items:center; gap:10px;">
                            <%= UiHelper.RenderOrderStatusBadge(SelectedOrderDetail.OrderStatus) %>
                            <a href="MyOrders.aspx" class="btn-pcm btn-pcm-outline" style="height:32px; font-size:12px;">Đóng chi tiết</a>
                        </div>
                    </div>

                    <div style="display:flex; gap:20px; flex-wrap:wrap; margin-bottom:16px; font-size:14px;">
                        <div style="flex:1; min-width:250px;">
                            <p><strong>Người nhận:</strong> <%= HttpUtility.HtmlEncode(SelectedOrderDetail.ReceiverName) %> (<%= HttpUtility.HtmlEncode(SelectedOrderDetail.ReceiverPhone) %>)</p>
                            <p style="margin-top:4px;"><strong>Địa chỉ giao hàng:</strong> <%= HttpUtility.HtmlEncode(SelectedOrderDetail.ShippingAddress) %></p>
                            <% if (!string.IsNullOrEmpty(SelectedOrderDetail.Note)) { %>
                                <p style="margin-top:4px;"><strong>Ghi chú:</strong> <%= HttpUtility.HtmlEncode(SelectedOrderDetail.Note) %></p>
                            <% } %>
                        </div>
                        <div style="min-width:240px; text-align:right;">
                            <p>Tạm tính: <strong><%= SecurityHelper.FormatCurrency(SelectedOrderDetail.SubTotal) %></strong></p>
                            <% if (SelectedOrderDetail.DiscountAmount > 0) { %>
                                <p style="color:#16a34a;">Giảm giá (<%= HttpUtility.HtmlEncode(SelectedOrderDetail.VoucherCode) %>): <strong>- <%= SecurityHelper.FormatCurrency(SelectedOrderDetail.DiscountAmount) %></strong></p>
                            <% } %>
                            <p style="font-size:17px; margin-top:4px;">Tổng thanh toán: <strong style="color:#CB1C21;"><%= SecurityHelper.FormatCurrency(SelectedOrderDetail.TotalAmount) %></strong></p>
                        </div>
                    </div>

                    <table class="pcm-table" style="margin-bottom:16px;">
                        <thead>
                            <tr>
                                <th>Mã SP</th>
                                <th>Tên máy tính / Linh kiện</th>
                                <th>Đơn giá</th>
                                <th>Số lượng</th>
                                <th>Thành tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < SelectedOrderDetail.Details.Count; i++) {
                                   OrderDetailInfo d = SelectedOrderDetail.Details[i]; %>
                                <tr>
                                    <td><strong><%= HttpUtility.HtmlEncode(d.ProductCode) %></strong></td>
                                    <td>
                                        <a href="ProductDetail.aspx?id=<%= d.ProductId %>" style="color:#3D52BF; font-weight:600;">
                                            <%= HttpUtility.HtmlEncode(d.ProductName) %>
                                        </a>
                                    </td>
                                    <td><%= SecurityHelper.FormatCurrency(d.UnitPrice) %></td>
                                    <td><strong><%= d.Quantity %></strong></td>
                                    <td style="font-weight:700; color:#CB1C21;"><%= SecurityHelper.FormatCurrency(d.LineTotal) %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>

                    <% if (SelectedOrderDetail.History.Count > 0) { %>
                        <div style="font-size:13px;">
                            <strong><i class="fa-solid fa-clock-rotate-left"></i> Lịch sử tiến độ đơn hàng:</strong>
                            <ul style="margin-top:6px; padding-left:18px; list-style:disc; color:#475569; line-height:1.7;">
                                <% for (int i = 0; i < SelectedOrderDetail.History.Count; i++) {
                                       OrderHistoryInfo h = SelectedOrderDetail.History[i]; %>
                                    <li>
                                        <strong>[<%= h.UpdatedAt.ToString("dd/MM/yyyy HH:mm") %>]</strong>
                                        Trạng thái: <strong><%= HttpUtility.HtmlEncode(h.Status) %></strong> &mdash;
                                        <%= HttpUtility.HtmlEncode(h.Note) %>
                                    </li>
                                <% } %>
                            </ul>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <% if (UserOrders.Count == 0) { %>
                <div style="text-align:center; padding:45px 20px; background:#f8fafc; border-radius:10px; border:1px dashed #cbd5e1;">
                    <i class="fa-solid fa-box-open" style="font-size:44px; color:#94a3b8; margin-bottom:12px;"></i>
                    <h3>Bạn chưa có đơn đặt hàng nào</h3>
                    <p style="color:#64748b; margin:8px 0 16px 0;">Hãy khám phá các dòng Laptop, PC Gaming và linh kiện chính hãng tại PCM Computer!</p>
                    <a href="Products.aspx" class="btn-pcm btn-pcm-primary">Mua sắm ngay</a>
                </div>
            <% } else { %>
                <div style="width:100%; overflow:hidden; border-radius:10px;">
                    <table class="order-table" style="width:100%; table-layout:fixed;">
                        <thead>
                            <tr>
                                <th style="width:16%;">Thông Tin Đơn</th>
                                <th style="width:32%;">Sản Phẩm Đã Đặt</th>
                                <th style="width:20%;">Người Nhận &amp; Địa Chỉ</th>
                                <th style="width:11%;">Tổng Tiền</th>
                                <th style="width:11%;">Trạng Thái</th>
                                <th style="width:10%; text-align:center;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < UserOrders.Count; i++) {
                                   OrderInfo o = UserOrders[i];
                                   bool canCancel = (o.OrderStatus == "Chờ xác nhận" || o.OrderStatus == "Đang chờ vận chuyển"); %>
                                <tr>
                                    <td>
                                        <strong style="color:#3D52BF; font-size:12px; font-family:'Consolas',monospace;"><%= HttpUtility.HtmlEncode(o.OrderCode) %></strong>
                                        <div style="font-size:11px; color:#64748b; margin-top:3px;">
                                            <i class="fa-regular fa-clock" style="color:#3D52BF; font-size:10px;"></i> <%= o.CreatedAt.ToString("dd/MM/yyyy HH:mm") %>
                                        </div>
                                    </td>
                                    <td>
                                        <%= UiHelper.RenderOrderItemsList(o.Details) %>
                                    </td>
                                    <td style="font-size:11px;">
                                        <div style="font-weight:700; color:#0f172a;"><i class="fa-solid fa-user" style="color:#3D52BF; font-size:10px; margin-right:3px;"></i><%= HttpUtility.HtmlEncode(o.ReceiverName) %></div>
                                        <div style="color:#0369a1; font-weight:700; margin:2px 0;"><i class="fa-solid fa-phone" style="font-size:9px; margin-right:3px;"></i><%= HttpUtility.HtmlEncode(o.ReceiverPhone) %></div>
                                        <div style="color:#64748b; line-height:1.3;"><i class="fa-solid fa-location-dot" style="font-size:9px; margin-right:3px;"></i><%= HttpUtility.HtmlEncode(o.ShippingAddress) %></div>
                                    </td>
                                    <td style="white-space:nowrap;">
                                        <strong style="color:#CB1C21; font-size:14px;"><%= SecurityHelper.FormatCurrency(o.TotalAmount) %></strong>
                                        <% if (o.DiscountAmount > 0) { %>
                                            <div style="font-size:10px; color:#16a34a; font-weight:600;">Đã giảm: <%= SecurityHelper.FormatCurrency(o.DiscountAmount) %></div>
                                        <% } %>
                                    </td>
                                    <td><%= UiHelper.RenderOrderStatusBadge(o.OrderStatus) %></td>
                                    <td style="text-align:center;">
                                        <a href="MyOrders.aspx?viewId=<%= o.OrderId %>" class="btn-pcm btn-pcm-outline" style="height:26px; padding:0 8px; font-size:11px; display:inline-flex; align-items:center; gap:3px;">
                                            <i class="fa-solid fa-eye"></i> Chi tiết
                                        </a>
                                        <% if (canCancel) { %>
                                            <div style="margin-top:4px;">
                                                <button type="submit" class="btn-pcm btn-pcm-danger" style="height:24px; padding:0 6px; font-size:10px;"
                                                        onclick="if(confirm('Bạn có chắc chắn muốn hủy đơn hàng <%= o.OrderCode %>? Hệ thống sẽ tự động hoàn trả số lượng tồn kho.')){document.getElementById('orderAction').value='cancel';document.getElementById('targetOrderId').value='<%= o.OrderId %>';return true;}return false;">
                                                    <i class="fa-solid fa-ban"></i> Hủy
                                                </button>
                                            </div>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>
</asp:Content>
