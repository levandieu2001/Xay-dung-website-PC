<%@ Page Language="C#" MasterPageFile="~/BoCucChung.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    protected UserInfo CurrentUser = null;
    protected List<CartItem> CartItems = new List<CartItem>();
    protected List<PromotionInfo> ActiveVouchers = new List<PromotionInfo>();

    protected string ReceiverName = "";
    protected string ReceiverPhone = "";
    protected string ShippingAddress = "";
    protected string OrderNote = "";
    protected string PaymentMethod = "COD - Thanh toán khi nhận hàng";
    protected string VoucherCodeInput = "";

    protected decimal SubTotal = 0;
    protected decimal DiscountAmount = 0;
    protected decimal FinalTotal = 0;

    protected string VoucherMessage = "";
    protected bool IsVoucherValid = false;

    protected string OrderAlertMessage = "";
    protected bool IsOrderSuccess = false;
    protected string CreatedOrderCode = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Hỗ trợ nút 'Đặt hàng' hoặc 'MUA GIÁ SỐC' trực tiếp từ danh sách sản phẩm (UC07 bước 1)
        if (!IsPostBack && !string.IsNullOrEmpty(Request.QueryString["buyId"]))
        {
            int buyId = 0;
            if (int.TryParse(Request.QueryString["buyId"], out buyId) && buyId > 0)
            {
                string addMsg;
                SecurityHelper.AddToCart(buyId, 1, out addMsg);
            }
        }

        // Bước 2 UC07: Kiểm tra trạng thái đăng nhập («include» UC02)
        CurrentUser = SecurityHelper.GetCurrentUser();
        if (CurrentUser == null)
        {
            Response.Redirect("DangNhap.aspx?returnUrl=ThanhToan.aspx");
            return;
        }

        CartItems = SecurityHelper.GetCart();
        SubTotal = SecurityHelper.GetCartSubTotal();
        ActiveVouchers = DbHelper.GetAllPromotions(true);

        OrderController controller = new OrderController();

        if (!IsPostBack)
        {
            // Thông điệp 2 -> 7 (biểu đồ tuần tự): Tải thông tin người nhận mặc định từ hồ sơ tài khoản
            UserInfo defaultProfile = controller.requestCheckout(CurrentUser.UserId, CartItems);
            if (defaultProfile != null)
            {
                ReceiverName = defaultProfile.FullName;
                ReceiverPhone = defaultProfile.Phone;
                ShippingAddress = defaultProfile.Address;
            }
        }
        else
        {
            ReceiverName = (Request.Form["ReceiverName"] ?? "").Trim();
            ReceiverPhone = (Request.Form["ReceiverPhone"] ?? "").Trim();
            ShippingAddress = (Request.Form["ShippingAddress"] ?? "").Trim();
            OrderNote = (Request.Form["OrderNote"] ?? "").Trim();
            PaymentMethod = (Request.Form["PaymentMethod"] ?? "COD - Thanh toán khi nhận hàng").Trim();
            VoucherCodeInput = (Request.Form["VoucherCodeInput"] ?? "").Trim().ToUpper();

            string action = Request.Form["checkoutAction"];

            // Kiểm tra mã giảm giá nếu khách hàng có nhập (UC16)
            if (!string.IsNullOrEmpty(VoucherCodeInput))
            {
                VoucherCheckResult vRes = DbHelper.ValidateVoucher(VoucherCodeInput, SubTotal);
                IsVoucherValid = vRes.IsValid;
                VoucherMessage = vRes.Message;
                if (vRes.IsValid)
                {
                    DiscountAmount = vRes.DiscountAmount;
                }
            }
            else if (action == "apply_voucher")
            {
                IsVoucherValid = false;
                VoucherMessage = "Vui lòng nhập mã khuyến mãi cần áp dụng.";
            }

            if (action == "submit_order")
            {
                // Nếu khách có nhập mã khuyến mãi nhưng mã không hợp lệ thì dừng lại báo lỗi trước
                if (!string.IsNullOrEmpty(VoucherCodeInput) && !IsVoucherValid)
                {
                    OrderAlertMessage = VoucherMessage + " (Vui lòng xóa hoặc nhập mã khuyến mãi hợp lệ trước khi đặt hàng)";
                }
                else
                {
                    OrderDTO dto = new OrderDTO();
                    dto.UserId = CurrentUser.UserId;
                    dto.Username = CurrentUser.Username;
                    dto.ReceiverName = ReceiverName;
                    dto.ReceiverPhone = ReceiverPhone;
                    dto.ShippingAddress = ShippingAddress;
                    dto.Note = OrderNote;
                    dto.PaymentMethod = PaymentMethod;
                    dto.VoucherCode = IsVoucherValid ? VoucherCodeInput : "";
                    dto.Items = CartItems;

                    // Thông điệp 9 -> 20 (biểu đồ tuần tự): Gửi đơn hàng qua OrderController -> OrderService
                    OrderResult res = controller.submitOrder(dto);
                    if (res.IsSuccess)
                    {
                        IsOrderSuccess = true;
                        CreatedOrderCode = res.OrderCode;
                        OrderAlertMessage = res.Message;
                        CartItems = new List<CartItem>();
                    }
                    else
                    {
                        IsOrderSuccess = false;
                        OrderAlertMessage = res.Message;
                    }
                }
            }
        }

        FinalTotal = SubTotal - DiscountAmount;
        if (FinalTotal < 0) FinalTotal = 0;
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="pcm-page-card">
            <div class="breadcrumb">
                <a href="TrangChu.aspx"><i class="fa-solid fa-house"></i> Trang chủ</a> /
                <a href="GioHang.aspx">Giỏ hàng</a> /
                <span>Đặt hàng &amp; Thanh toán</span>
            </div>

            <% if (IsOrderSuccess) { %>
                <!-- Màn hình Đặt hàng thành công (Thông điệp 18 - 21 biểu đồ tuần tự) -->
                <div style="text-align:center; padding:40px 20px; background:#f0fdf4; border:2px solid #86efac; border-radius:12px;">
                    <i class="fa-solid fa-circle-check" style="font-size:56px; color:#16a34a; margin-bottom:14px;"></i>
                    <h2 style="color:#166534; font-size:24px; margin-bottom:10px;">ĐẶT HÀNG TRỰC TUYẾN THÀNH CÔNG!</h2>
                    <p style="font-size:16px; color:#334155; margin-bottom:8px;">
                        Mã đơn hàng của bạn là: <strong style="color:#CB1C21; font-size:20px;"><%= HttpUtility.HtmlEncode(CreatedOrderCode) %></strong>
                    </p>
                    <p style="font-size:14px; color:#475569; margin-bottom:20px;">
                        Đơn hàng đã được lưu với trạng thái <strong>"Chờ xác nhận"</strong> và số lượng tồn kho đã được cập nhật. Nhân viên PCM Computer sẽ sớm liên hệ với bạn qua số điện thoại <strong><%= HttpUtility.HtmlEncode(ReceiverPhone) %></strong> để xác nhận giao hàng!
                    </p>
                    <div style="display:flex; justify-content:center; gap:14px; flex-wrap:wrap;">
                        <a href="DonHangCuaToi.aspx" class="btn-pcm btn-pcm-primary" style="height:44px; padding:0 24px;">
                            <i class="fa-solid fa-clipboard-list"></i> THEO DÕI ĐƠN HÀNG CỦA TÔI
                        </a>
                        <a href="SanPham.aspx" class="btn-pcm btn-pcm-outline" style="height:44px; padding:0 24px;">
                            <i class="fa-solid fa-bag-shopping"></i> TIẾP TỤC MUA SẮM
                        </a>
                    </div>
                </div>
            <% } else if (CartItems.Count == 0) { %>
                <div class="pcm-alert pcm-alert-warning" style="text-align:center; padding:30px;">
                    <h3>Giỏ hàng của bạn đang trống!</h3>
                    <p style="margin-top:10px;">Vui lòng chọn sản phẩm vào giỏ hàng trước khi tiến hành đặt hàng.</p>
                    <p style="margin-top:14px;"><a href="SanPham.aspx" class="btn-pcm btn-pcm-primary">Chọn sản phẩm ngay</a></p>
                </div>
            <% } else { %>
                <h1 class="pcm-page-title"><i class="fa-solid fa-truck-fast"></i> XÁC NHẬN THÔNG TIN ĐẶT HÀNG &amp; THANH TOÁN</h1>

                <% if (!string.IsNullOrEmpty(OrderAlertMessage)) { %>
                    <div class="pcm-alert pcm-alert-error">
                        <i class="fa-solid fa-triangle-exclamation"></i> <%= HttpUtility.HtmlEncode(OrderAlertMessage) %>
                    </div>
                <% } %>

                <input type="hidden" id="checkoutAction" name="checkoutAction" value="submit_order" />

                <div style="display:flex; gap:30px; flex-wrap:wrap;">
                    <!-- Cột trái: Thông tin người nhận hàng (UC07 bước 3 & 4) -->
                    <div style="flex:1.1; min-width:320px;">
                        <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; padding:20px;">
                            <h3 style="color:#3D52BF; font-size:17px; margin-bottom:16px; border-bottom:1px solid #e2e8f0; padding-bottom:10px;">
                                <i class="fa-solid fa-address-card"></i> 1. THÔNG TIN NGƯỜI NHẬN HÀNG
                            </h3>

                            <div class="form-group">
                                <label>Họ và tên người nhận <span style="color:red;">*</span></label>
                                <input type="text" name="ReceiverName" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(ReceiverName) %>"
                                       placeholder="Nhập họ tên người nhận hàng" />
                            </div>

                            <div class="form-group">
                                <label>Số điện thoại liên hệ <span style="color:red;">*</span></label>
                                <input type="text" name="ReceiverPhone" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(ReceiverPhone) %>"
                                       placeholder="Nhập số điện thoại nhận hàng (10 chữ số)" />
                            </div>

                            <div class="form-group">
                                <label>Địa chỉ giao hàng chi tiết <span style="color:red;">*</span></label>
                                <input type="text" name="ShippingAddress" class="form-control"
                                       value="<%= HttpUtility.HtmlAttributeEncode(ShippingAddress) %>"
                                       placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố" />
                            </div>

                            <div class="form-group">
                                <label>Phương thức thanh toán <span style="color:red;">*</span></label>
                                <select name="PaymentMethod" class="form-control">
                                    <option value="COD - Thanh toán khi nhận hàng">Thanh toán tiền mặt khi nhận hàng (COD - Kiểm tra hàng trước khi thanh toán)</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Ghi chú đơn hàng (Tùy chọn)</label>
                                <textarea name="OrderNote" rows="3" class="form-control"
                                          placeholder="Ví dụ: Giao trong giờ hành chính, cài sẵn Windows 11 và trình điều khiển..."><%= HttpUtility.HtmlEncode(OrderNote) %></textarea>
                            </div>
                        </div>
                    </div>

                    <!-- Cột phải: Danh sách linh kiện, Áp dụng mã khuyến mãi (UC16) & Tổng thanh toán -->
                    <div style="flex:1; min-width:320px;">
                        <div style="background:#fff; border:1px solid #e2e8f0; border-radius:10px; padding:20px;">
                            <h3 style="color:#3D52BF; font-size:17px; margin-bottom:16px; border-bottom:1px solid #e2e8f0; padding-bottom:10px;">
                                <i class="fa-solid fa-box"></i> 2. SẢN PHẨM ĐẶT MUA (<%= SecurityHelper.GetCartCount() %> SP)
                            </h3>

                            <div style="max-height:260px; overflow-y:auto; margin-bottom:16px;">
                                <% for (int i = 0; i < CartItems.Count; i++) {
                                       CartItem item = CartItems[i]; %>
                                    <div style="display:flex; justify-content:space-between; align-items:center; gap:10px; padding:10px 0; border-bottom:1px dashed #e2e8f0;">
                                        <img src="<%= HttpUtility.HtmlAttributeEncode(item.ImageUrl) %>" alt=""
                                             style="width:50px; height:50px; object-fit:contain; border:1px solid #eee; border-radius:4px;" />
                                        <div style="flex:1; font-size:13px;">
                                            <div style="font-weight:700; color:#1e293b;"><%= HttpUtility.HtmlEncode(item.ProductName) %></div>
                                            <div style="color:#64748b; margin-top:2px;">
                                                SL: <strong><%= item.Quantity %></strong> x <%= SecurityHelper.FormatCurrency(item.UnitPrice) %>
                                                <span style="color:#16a34a;">(Kho còn: <%= item.StockQuantity %>)</span>
                                            </div>
                                        </div>
                                        <div style="font-weight:700; color:#CB1C21; font-size:14px; white-space:nowrap;">
                                            <%= SecurityHelper.FormatCurrency(item.LineTotal) %>
                                        </div>
                                    </div>
                                <% } %>
                            </div>

                            <!-- Khung Áp dụng mã khuyến mãi (UC16) -->
                            <div style="background:#f8fafc; border:1px solid #cbd5e1; border-radius:8px; padding:14px; margin-bottom:16px;">
                                <label style="display:block; font-weight:700; font-size:13px; color:#3D52BF; margin-bottom:8px;">
                                    <i class="fa-solid fa-ticket"></i> MÃ GIẢM GIÁ / KHUYẾN MÃI (UC16):
                                </label>
                                <div style="display:flex; gap:8px;">
                                    <input type="text" id="VoucherCodeInput" name="VoucherCodeInput" class="form-control"
                                           value="<%= HttpUtility.HtmlAttributeEncode(VoucherCodeInput) %>"
                                           placeholder="Nhập mã giảm giá (VD: PCM500K, GIAM5, NEWUSER)" />
                                    <button type="submit" class="btn-pcm btn-pcm-primary" style="white-space:nowrap;"
                                            onclick="document.getElementById('checkoutAction').value='apply_voucher';">
                                        Áp dụng
                                    </button>
                                </div>

                                <% if (!string.IsNullOrEmpty(VoucherMessage)) { %>
                                    <div style="margin-top:8px; font-size:13px; font-weight:600; color:<%= (IsVoucherValid ? "#16a34a" : "#dc2626") %>;">
                                        <i class="fa-solid <%= (IsVoucherValid ? "fa-circle-check" : "fa-circle-xmark") %>"></i>
                                        <%= HttpUtility.HtmlEncode(VoucherMessage) %>
                                    </div>
                                <% } %>

                                <div style="margin-top:10px; font-size:12px; color:#475569;">
                                    <span>Chọn nhanh mã đang có: </span>
                                    <% for (int i = 0; i < ActiveVouchers.Count; i++) {
                                           PromotionInfo v = ActiveVouchers[i]; %>
                                        <a href="javascript:void(0);"
                                           onclick="document.getElementById('VoucherCodeInput').value='<%= v.VoucherCode %>'; document.getElementById('checkoutAction').value='apply_voucher'; document.getElementById('mainForm').submit();"
                                           style="display:inline-block; background:#e0e7ff; color:#3D52BF; font-weight:700; padding:2px 8px; border-radius:4px; margin:2px;">
                                            <%= HttpUtility.HtmlEncode(v.VoucherCode) %>
                                        </a>
                                    <% } %>
                                </div>
                            </div>

                            <!-- Bảng tính tổng tiền -->
                            <div style="border-top:2px solid #e2e8f0; padding-top:14px; font-size:14px; line-height:2;">
                                <div style="display:flex; justify-content:space-between;">
                                    <span>Tạm tính:</span>
                                    <strong><%= SecurityHelper.FormatCurrency(SubTotal) %></strong>
                                </div>
                                <div style="display:flex; justify-content:space-between; color:#16a34a;">
                                    <span>Giảm giá khuyến mãi:</span>
                                    <strong>- <%= SecurityHelper.FormatCurrency(DiscountAmount) %></strong>
                                </div>
                                <div style="display:flex; justify-content:space-between;">
                                    <span>Phí vận chuyển:</span>
                                    <strong style="color:#16a34a;">Miễn phí (0 đ)</strong>
                                </div>
                                <div style="display:flex; justify-content:space-between; font-size:18px; border-top:1px solid #e2e8f0; margin-top:8px; padding-top:8px;">
                                    <strong>TỔNG THANH TOÁN:</strong>
                                    <strong style="color:#CB1C21; font-size:22px;"><%= SecurityHelper.FormatCurrency(FinalTotal) %></strong>
                                </div>
                            </div>

                            <div style="margin-top:18px; display:flex; gap:10px;">
                                <a href="GioHang.aspx" class="btn-pcm btn-pcm-outline" style="height:46px;">
                                    &laquo; Quay lại giỏ
                                </a>
                                <button type="submit" class="btn-pcm btn-pcm-danger" style="flex:1; height:46px; font-size:16px;"
                                        onclick="document.getElementById('checkoutAction').value='submit_order';">
                                    <i class="fa-solid fa-check-double"></i> XÁC NHẬN ĐẶT HÀNG
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    </div>
</asp:Content>
