<%@ Page Language="C#" MasterPageFile="~/BoCucChung.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    protected List<CartItem> CartItems = new List<CartItem>();
    protected decimal CartSubTotal = 0;
    protected string AlertMessage = "";
    protected bool IsAlertSuccess = true;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Xử lý Thêm vào giỏ hàng qua AJAX (không chuyển hướng trang để khách tiếp tục mua sắm)
        if (Request.QueryString["ajax"] == "1" || Request.Headers["X-Requested-With"] == "XMLHttpRequest")
        {
            Response.Clear();
            Response.ContentType = "application/json; charset=utf-8";
            int addId = 0;
            int qty = 1;
            int.TryParse(Request.QueryString["id"], out addId);
            int.TryParse(Request.QueryString["qty"], out qty);
            if (qty < 1) qty = 1;

            string msg = "";
            bool ok = false;
            if (addId > 0)
            {
                ok = SecurityHelper.AddToCart(addId, qty, out msg);
            }
            else
            {
                msg = "Mã sản phẩm không hợp lệ.";
            }
            int cartCount = SecurityHelper.GetCartCount();

            Response.Write(string.Format("{{\"success\":{0},\"message\":{1},\"cartCount\":{2}}}",
                ok ? "true" : "false",
                HttpUtility.JavaScriptStringEncode(msg, true),
                cartCount));
            Response.End();
            return;
        }

        if (!IsPostBack && Request.QueryString["action"] == "add")
        {
            int addId = 0;
            if (int.TryParse(Request.QueryString["id"], out addId) && addId > 0)
            {
                string msg;
                IsAlertSuccess = SecurityHelper.AddToCart(addId, 1, out msg);
                AlertMessage = msg;
            }
        }

        if (IsPostBack)
        {
            string cartAction = Request.Form["cartAction"];
            int targetId = 0;
            int.TryParse(Request.Form["targetProductId"], out targetId);

            if (cartAction == "update" && targetId > 0)
            {
                int newQty = 1;
                int.TryParse(Request.Form["qty_" + targetId], out newQty);
                string msg;
                IsAlertSuccess = SecurityHelper.UpdateCartQuantity(targetId, newQty, out msg);
                AlertMessage = msg;
            }
            else if (cartAction == "remove" && targetId > 0)
            {
                SecurityHelper.RemoveFromCart(targetId);
                IsAlertSuccess = true;
                AlertMessage = "Đã xóa sản phẩm khỏi giỏ hàng.";
            }
            else if (cartAction == "clear")
            {
                SecurityHelper.ClearCart();
                IsAlertSuccess = true;
                AlertMessage = "Đã làm trống toàn bộ giỏ hàng.";
            }
        }

        // Đồng bộ lại tồn kho thực tế mới nhất cho từng sản phẩm trong giỏ
        CartItems = SecurityHelper.GetCart();
        for (int i = 0; i < CartItems.Count; i++)
        {
            ProductInfo p = DbHelper.GetProductById(CartItems[i].ProductId);
            if (p != null)
            {
                CartItems[i].StockQuantity = p.StockQuantity;
                CartItems[i].UnitPrice = p.Price;
            }
        }
        CartSubTotal = SecurityHelper.GetCartSubTotal();
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="pcm-page-card">
            <div class="breadcrumb">
                <a href="TrangChu.aspx"><i class="fa-solid fa-house"></i> Trang chủ</a> /
                <span>Giỏ hàng của bạn</span>
            </div>

            <h1 class="pcm-page-title"><i class="fa-solid fa-cart-shopping"></i> GIỎ HÀNG CỦA BẠN (<%= SecurityHelper.GetCartCount() %> SẢN PHẨM)</h1>

            <% if (!string.IsNullOrEmpty(AlertMessage)) { %>
                <div class="pcm-alert <%= (IsAlertSuccess ? "pcm-alert-success" : "pcm-alert-warning") %>">
                    <i class="fa-solid <%= (IsAlertSuccess ? "fa-circle-check" : "fa-triangle-exclamation") %>"></i>
                    <%= HttpUtility.HtmlEncode(AlertMessage) %>
                </div>
            <% } %>

            <input type="hidden" id="cartAction" name="cartAction" value="" />
            <input type="hidden" id="targetProductId" name="targetProductId" value="0" />

            <% if (CartItems.Count == 0) { %>
                <div style="text-align:center; padding:50px 20px; background:#f8fafc; border-radius:10px; border:1px dashed #cbd5e1;">
                    <i class="fa-solid fa-cart-arrow-down" style="font-size:48px; color:#94a3b8; margin-bottom:14px;"></i>
                    <h3 style="color:#334155; margin-bottom:8px;">Giỏ hàng của bạn hiện đang trống</h3>
                    <p style="color:#64748b; font-size:14px; margin-bottom:18px;">Hãy chọn máy tính hoặc linh kiện yêu thích và thêm vào giỏ hàng để đặt mua nhé!</p>
                    <a href="SanPham.aspx" class="btn-pcm btn-pcm-primary" style="height:42px; padding:0 24px;">
                        <i class="fa-solid fa-bag-shopping"></i> TIẾP TỤC MUA SẮM
                    </a>
                </div>
            <% } else { %>
                <div style="overflow-x:auto;">
                    <table class="pcm-table">
                        <thead>
                            <tr>
                                <th style="width:90px;">Hình ảnh</th>
                                <th>Tên máy tính / Linh kiện</th>
                                <th style="width:140px;">Đơn giá</th>
                                <th style="width:150px;">Tồn kho hiện tại</th>
                                <th style="width:180px;">Số lượng mua</th>
                                <th style="width:150px;">Thành tiền</th>
                                <th style="width:80px; text-align:center;">Xóa</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < CartItems.Count; i++) {
                                   CartItem item = CartItems[i]; %>
                                <tr>
                                    <td>
                                        <a href="ChiTietSanPham.aspx?id=<%= item.ProductId %>">
                                            <img src="<%= HttpUtility.HtmlAttributeEncode(item.ImageUrl) %>" alt=""
                                                 style="width:70px; height:70px; object-fit:contain; border:1px solid #e2e8f0; border-radius:6px; padding:4px;" />
                                        </a>
                                    </td>
                                    <td>
                                        <div style="font-weight:700; margin-bottom:4px;">
                                            <a href="ChiTietSanPham.aspx?id=<%= item.ProductId %>" style="color:#1e293b;">
                                                <%= HttpUtility.HtmlEncode(item.ProductName) %>
                                            </a>
                                        </div>
                                        <div style="font-size:12px; color:#64748b;">Mã SP: <strong><%= HttpUtility.HtmlEncode(item.ProductCode) %></strong></div>
                                    </td>
                                    <td style="font-weight:700; color:#334155;">
                                        <%= SecurityHelper.FormatCurrency(item.UnitPrice) %>
                                    </td>
                                    <td>
                                        <span style="display:inline-block; background:#dcfce7; color:#166534; padding:4px 10px; border-radius:12px; font-size:12px; font-weight:700;">
                                            <i class="fa-solid fa-warehouse"></i> Kho còn: <%= item.StockQuantity %> SP
                                        </span>
                                    </td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <div class="pcm-qty-group">
                                                <button type="button" class="pcm-qty-btn" onclick="changeQty('qty_<%= item.ProductId %>', -1, 1, <%= item.StockQuantity %>);" title="Giảm số lượng">
                                                    <i class="fa-solid fa-minus" style="font-size:11px;"></i>
                                                </button>
                                                <input type="number" name="qty_<%= item.ProductId %>" id="qty_<%= item.ProductId %>"
                                                       value="<%= item.Quantity %>" min="1" max="<%= item.StockQuantity %>"
                                                       style="width:48px; height:34px; border:none; border-left:1px solid #e2e8f0; border-right:1px solid #e2e8f0; text-align:center; font-weight:700; font-size:14px; outline:none;" />
                                                <button type="button" class="pcm-qty-btn" onclick="changeQty('qty_<%= item.ProductId %>', 1, 1, <%= item.StockQuantity %>);" title="Tăng số lượng">
                                                    <i class="fa-solid fa-plus" style="font-size:11px;"></i>
                                                </button>
                                            </div>
                                            <button type="submit" class="btn-pcm btn-pcm-outline" style="height:34px; padding:0 10px; font-size:12px;"
                                                    onclick="submitCartAction('update', <%= item.ProductId %>);">
                                                Cập nhật
                                            </button>
                                        </div>
                                        <div style="font-size:11px; color:#64748b; margin-top:3px;">Tối đa: <%= item.StockQuantity %> SP</div>
                                    </td>
                                    <td style="font-weight:800; color:#CB1C21; font-size:15px;">
                                        <%= SecurityHelper.FormatCurrency(item.LineTotal) %>
                                    </td>
                                    <td style="text-align:center;">
                                        <button type="submit" class="btn-pcm btn-pcm-danger" style="height:34px; padding:0 10px;"
                                                title="Xóa sản phẩm khỏi giỏ"
                                                onclick="submitCartAction('remove', <%= item.ProductId %>);">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; margin-top:24px; padding-top:20px; border-top:2px solid #e2e8f0;">
                    <div style="display:flex; gap:10px; flex-wrap:wrap;">
                        <a href="SanPham.aspx" class="btn-pcm btn-pcm-outline">
                            <i class="fa-solid fa-arrow-left"></i> Tiếp tục chọn linh kiện
                        </a>
                        <button type="submit" class="btn-pcm btn-pcm-outline" style="color:#dc2626 !important; border-color:#dc2626;"
                                onclick="submitCartAction('clear', 0);">
                            <i class="fa-solid fa-broom"></i> Làm trống giỏ hàng
                        </button>
                    </div>

                    <div style="text-align:right;">
                        <div style="font-size:15px; color:#475569; margin-bottom:8px;">
                            Tạm tính (<%= SecurityHelper.GetCartCount() %> sản phẩm):
                            <strong style="font-size:24px; color:#CB1C21; margin-left:8px;"><%= SecurityHelper.FormatCurrency(CartSubTotal) %></strong>
                        </div>
                        <div style="font-size:12px; color:#64748b; margin-bottom:14px;">
                            (Bạn có thể áp dụng mã khuyến mãi <strong>PCM500K</strong>, <strong>GIAM5</strong> hoặc <strong>NEWUSER</strong> ở bước Thanh toán tiếp theo)
                        </div>
                        <a href="ThanhToan.aspx" class="btn-pcm btn-pcm-danger" style="height:46px; padding:0 30px; font-size:16px;">
                            <i class="fa-solid fa-credit-card"></i> TIẾN HÀNH ĐẶT HÀNG &raquo;
                        </a>
                    </div>
                </div>
            <% } %>
        </div>
    </div>

    <script type="text/javascript">
        function submitCartAction(action, prodId) {
            document.getElementById("cartAction").value = action;
            document.getElementById("targetProductId").value = prodId;
        }
    </script>
</asp:Content>
