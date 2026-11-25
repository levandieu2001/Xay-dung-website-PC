<%@ Page Language="C#" MasterPageFile="~/BoCucChung.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    protected ProductInfo CurrentProduct = null;
    protected List<ProductInfo> RelatedProducts = new List<ProductInfo>();
    protected string AlertMessage = "";
    protected bool IsAlertSuccess = true;

    protected void Page_Load(object sender, EventArgs e)
    {
        int prodId = 0;
        if (!string.IsNullOrEmpty(Request.QueryString["id"]))
        {
            int.TryParse(Request.QueryString["id"], out prodId);
        }

        if (prodId > 0)
        {
            CurrentProduct = DbHelper.GetProductById(prodId);
        }

        if (CurrentProduct == null)
        {
            return;
        }

        if (IsPostBack)
        {
            string action = Request.Form["detailAction"];
            int qty = 1;
            int.TryParse(Request.Form["buyQty"], out qty);
            if (qty <= 0) qty = 1;

            if (action == "add_cart")
            {
                string msg;
                IsAlertSuccess = SecurityHelper.AddToCart(CurrentProduct.ProductId, qty, out msg);
                AlertMessage = msg;
            }
            else if (action == "buy_now")
            {
                string msg;
                if (SecurityHelper.AddToCart(CurrentProduct.ProductId, qty, out msg))
                {
                    Response.Redirect("ThanhToan.aspx");
                    return;
                }
                else
                {
                    IsAlertSuccess = false;
                    AlertMessage = msg;
                }
            }
        }

        RelatedProducts = DbHelper.GetRelatedProducts(CurrentProduct.CategoryId, CurrentProduct.ProductId, 5);
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="pcm-page-card">
            <% if (CurrentProduct == null) { %>
                <div class="pcm-alert pcm-alert-error" style="text-align:center; padding:30px;">
                    <h3>Không tìm thấy sản phẩm yêu cầu!</h3>
                    <p style="margin-top:10px;"><a href="SanPham.aspx" class="btn-pcm btn-pcm-primary">Quay lại danh sách sản phẩm</a></p>
                </div>
            <% } else { %>
                <div class="breadcrumb">
                    <a href="TrangChu.aspx"><i class="fa-solid fa-house"></i> Trang chủ</a> /
                    <a href="SanPham.aspx?catId=<%= CurrentProduct.CategoryId %>"><%= HttpUtility.HtmlEncode(CurrentProduct.CategoryName) %></a> /
                    <span><%= HttpUtility.HtmlEncode(CurrentProduct.ProductName) %></span>
                </div>

                <% if (!string.IsNullOrEmpty(AlertMessage)) { %>
                    <div class="pcm-alert <%= (IsAlertSuccess ? "pcm-alert-success" : "pcm-alert-error") %>">
                        <i class="fa-solid <%= (IsAlertSuccess ? "fa-circle-check" : "fa-triangle-exclamation") %>"></i>
                        <%= HttpUtility.HtmlEncode(AlertMessage) %>
                        <% if (IsAlertSuccess) { %>
                            &nbsp;&mdash;&nbsp;<a href="GioHang.aspx" style="font-weight:bold; text-decoration:underline; color:#166534;">Xem giỏ hàng ngay &raquo;</a>
                        <% } %>
                    </div>
                <% } %>

                <div class="detail-grid">
                    <div class="detail-left">
                        <img src="<%= HttpUtility.HtmlAttributeEncode(CurrentProduct.ImageUrl) %>"
                             alt="<%= HttpUtility.HtmlAttributeEncode(CurrentProduct.ProductName) %>" />
                    </div>

                    <div class="detail-right">
                        <h1 class="detail-title"><%= HttpUtility.HtmlEncode(CurrentProduct.ProductName) %></h1>

                        <div class="detail-meta">
                            <span><i class="fa-solid fa-barcode"></i> Mã SP: <strong><%= HttpUtility.HtmlEncode(CurrentProduct.ProductCode) %></strong></span>
                            <span><i class="fa-solid fa-building"></i> Hãng SX: <strong><%= HttpUtility.HtmlEncode(CurrentProduct.Brand) %></strong></span>
                            <span><i class="fa-solid fa-shield-halved"></i> Bảo hành: <strong><%= CurrentProduct.WarrantyMonths %> tháng chính hãng</strong></span>
                            <span>
                                <i class="fa-solid fa-boxes-stacked"></i> Tình trạng kho:
                                <% if (CurrentProduct.StockQuantity > 0 && CurrentProduct.Status == "Đang kinh doanh") { %>
                                    <strong style="color:#16a34a;">Còn hàng (<%= CurrentProduct.StockQuantity %> sản phẩm)</strong>
                                <% } else { %>
                                    <strong style="color:#dc2626;">Tạm hết hàng (0 sản phẩm)</strong>
                                <% } %>
                            </span>
                        </div>

                        <div class="detail-price-box">
                            <div>
                                <div style="font-size:13px; color:#64748b; margin-bottom:4px;">Giá khuyến mãi trực tuyến:</div>
                                <span class="detail-price-new"><%= SecurityHelper.FormatCurrency(CurrentProduct.Price) %></span>
                            </div>
                            <% if (CurrentProduct.OldPrice > CurrentProduct.Price) { %>
                                <div>
                                    <div style="font-size:12px; color:#94a3b8;">Giá niêm yết:</div>
                                    <span class="detail-price-old"><%= SecurityHelper.FormatCurrency(CurrentProduct.OldPrice) %></span>
                                </div>
                                <span class="discount-badge" style="font-size:14px; padding:4px 10px;">
                                    Tiết kiệm <%= CurrentProduct.DiscountPercent %>% (<%= SecurityHelper.FormatCurrency(CurrentProduct.OldPrice - CurrentProduct.Price) %>)
                                </span>
                            <% } %>
                        </div>

                        <div style="background:#f8fafc; border:1px dashed #3D52BF; border-radius:8px; padding:14px; margin-bottom:18px;">
                            <div style="font-weight:700; color:#3D52BF; margin-bottom:8px;">
                                <i class="fa-solid fa-gift" style="color:#CB1C21;"></i> ƯU ĐÃI &amp; MÃ KHUYẾN MÃI KHI ĐẶT HÀNG:
                            </div>
                            <ul style="font-size:13px; color:#334155; line-height:1.8; list-style:disc; padding-left:20px;">
                                <li>Nhập mã <strong style="color:#CB1C21;">PCM500K</strong> giảm ngay <strong>500.000 đ</strong> cho đơn hàng từ 10.000.000 đ.</li>
                                <li>Nhập mã <strong style="color:#CB1C21;">GIAM5</strong> giảm ngay <strong>5%</strong> (tối đa 1.500.000 đ) cho đơn từ 5.000.000 đ.</li>
                                <li>Nhập mã <strong style="color:#CB1C21;">NEWUSER</strong> giảm ngay <strong>200.000 đ</strong> cho đơn từ 1.000.000 đ.</li>
                                <li>Miễn phí giao hàng toàn quốc &amp; hỗ trợ thanh toán khi nhận hàng (COD).</li>
                            </ul>
                        </div>

                        <% if (CurrentProduct.StockQuantity > 0 && CurrentProduct.Status == "Đang kinh doanh") { %>
                            <div style="display:flex; align-items:center; gap:14px; flex-wrap:wrap; margin-top:20px;">
                                <div style="display:flex; align-items:center; gap:10px;">
                                    <label for="buyQty" style="font-weight:700; font-size:14px;">Số lượng:</label>
                                    <div class="pcm-qty-group">
                                        <button type="button" class="pcm-qty-btn" onclick="changeQty('buyQty', -1, 1, <%= CurrentProduct.StockQuantity %>);" title="Giảm số lượng">
                                            <i class="fa-solid fa-minus" style="font-size:12px;"></i>
                                        </button>
                                        <input type="number" id="buyQty" name="buyQty" value="1" min="1" max="<%= CurrentProduct.StockQuantity %>"
                                               style="width:52px; height:36px; border:none; border-left:1px solid #e2e8f0; border-right:1px solid #e2e8f0; text-align:center; font-weight:700; font-size:15px; outline:none;" />
                                        <button type="button" class="pcm-qty-btn" onclick="changeQty('buyQty', 1, 1, <%= CurrentProduct.StockQuantity %>);" title="Tăng số lượng">
                                            <i class="fa-solid fa-plus" style="font-size:12px;"></i>
                                        </button>
                                    </div>
                                    <span style="font-size:12px; color:#64748b;">(Tối đa <%= CurrentProduct.StockQuantity %> SP)</span>
                                </div>

                                <input type="hidden" id="detailAction" name="detailAction" value="" />
                                <button type="button" class="btn-pcm btn-pcm-primary" style="height:46px; padding:0 24px; font-size:15px;"
                                        onclick="var q=parseInt(document.getElementById('buyQty').value)||1; addToCartAjax(<%= CurrentProduct.ProductId %>, q, event);">
                                    <i class="fa-solid fa-cart-plus"></i> THÊM VÀO GIỎ HÀNG
                                </button>
                                <button type="submit" class="btn-pcm btn-pcm-danger" style="height:46px; padding:0 28px; font-size:15px;"
                                        onclick="document.getElementById('detailAction').value='buy_now';">
                                    <i class="fa-solid fa-bolt"></i> ĐẶT MUA NGAY (COD)
                                </button>
                            </div>
                        <% } else { %>
                            <!-- Ngoại lệ UC05: Số lượng tồn kho bằng 0 -> Hiển thị Tạm hết hàng & vô hiệu hóa nút thêm vào giỏ hàng -->
                            <div style="margin-top:20px; display:flex; gap:12px; align-items:center;">
                                <button type="button" class="btn-pcm" disabled="disabled"
                                        style="height:46px; padding:0 28px; background:#cbd5e1; color:#64748b; cursor:not-allowed;">
                                    <i class="fa-solid fa-ban"></i> TẠM HẾT HÀNG
                                </button>
                                <span style="font-size:14px; color:#dc2626; font-weight:600;">
                                    Sản phẩm hiện đang tạm hết hàng trong kho. Vui lòng quay lại sau hoặc liên hệ hotline 036.625.8142.
                                </span>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Bảng thông số kỹ thuật chi tiết & Mô tả sản phẩm (UC05) -->
                <div style="display:flex; gap:30px; flex-wrap:wrap; margin-top:35px; border-top:2px solid #e2e8f0; padding-top:25px;">
                    <div style="flex:1.2; min-width:320px;">
                        <h2 class="pcm-page-title" style="font-size:18px;">
                            <i class="fa-solid fa-microchip"></i> BẢNG THÔNG SỐ KỸ THUẬT CHI TIẾT
                        </h2>
                        <%= UiHelper.RenderSpecsTable(CurrentProduct.Specifications) %>
                    </div>

                    <div style="flex:1; min-width:300px;">
                        <h2 class="pcm-page-title" style="font-size:18px;">
                            <i class="fa-solid fa-file-lines"></i> ĐÁNH GIÁ &amp; MÔ TẢ SẢN PHẨM
                        </h2>
                        <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; padding:18px; line-height:1.7; font-size:14px; color:#334155;">
                            <p style="margin-bottom:12px;"><%= HttpUtility.HtmlEncode(CurrentProduct.Description) %></p>
                            <p><strong>Cam kết từ PCM Computer:</strong></p>
                            <ul style="list-style:check; padding-left:20px; margin-top:6px;">
                                <li><i class="fa-solid fa-check" style="color:#16a34a;"></i> Hàng chính hãng mới 100%, đầy đủ hộp và phụ kiện từ nhà sản xuất.</li>
                                <li><i class="fa-solid fa-check" style="color:#16a34a;"></i> Bảo hành chính hãng <strong><%= CurrentProduct.WarrantyMonths %> tháng</strong> tại toàn bộ cửa hàng PCM Computer.</li>
                                <li><i class="fa-solid fa-check" style="color:#16a34a;"></i> Hỗ trợ đổi mới trong 15 ngày đầu nếu phát sinh lỗi phần cứng từ nhà sản xuất.</li>
                                <li><i class="fa-solid fa-check" style="color:#16a34a;"></i> Miễn phí cài đặt hệ điều hành, phần mềm văn phòng và vệ sinh máy trọn đời.</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Sản phẩm cùng danh mục -->
                <% if (RelatedProducts.Count > 0) { %>
                    <div style="margin-top:35px; border-top:2px solid #e2e8f0; padding-top:25px;">
                        <h2 class="pcm-page-title" style="font-size:18px;">
                            <i class="fa-solid fa-laptop-code"></i> SẢN PHẨM CÙNG DANH MỤC
                        </h2>
                        <div class="list-product-sell">
                            <% for (int i = 0; i < RelatedProducts.Count; i++) { %>
                                <%= UiHelper.RenderProductCard(RelatedProducts[i]) %>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </div>
</asp:Content>
