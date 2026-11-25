using System;
using System.Collections.Generic;
using System.Text;
using System.Web;

namespace PCMComputer
{
    public static class UiHelper
    {
        public static string RenderProductCard(ProductInfo p)
        {
            if (p == null) return "";
            StringBuilder sb = new StringBuilder();
            string detailUrl = "ChiTietSanPham.aspx?id=" + p.ProductId;
            string addCartUrl = "GioHang.aspx?action=add&id=" + p.ProductId;
            string buyNowUrl = "ThanhToan.aspx?buyId=" + p.ProductId;

            sb.Append("<div class='item-sell'>");
            sb.AppendFormat("<div class='item-img'><a href='{0}'><img src='{1}' alt='{2}' /></a></div>",
                            detailUrl, HttpUtility.HtmlEncode(p.ImageUrl), HttpUtility.HtmlEncode(p.ProductName));

            sb.Append("<div class='item-info'>");
            sb.AppendFormat("<div class='item-name'><a href='{0}' title='{1}'>{1}</a></div>",
                            detailUrl, HttpUtility.HtmlEncode(p.ProductName));
            sb.Append("<div class='item-rate'>");
            sb.Append("<i class='fa-solid fa-star' style='color:#fdd835;'></i>");
            sb.Append("<i class='fa-solid fa-star' style='color:#fdd835;'></i>");
            sb.Append("<i class='fa-solid fa-star' style='color:#fdd835;'></i>");
            sb.Append("<i class='fa-solid fa-star' style='color:#fdd835;'></i>");
            sb.Append("<i class='fa-solid fa-star' style='color:#fdd835;'></i>");
            sb.AppendFormat("<span>(Đã bán {0})</span>", p.SoldCount);
            sb.Append("</div>");

            sb.AppendFormat("<div class='item-code'>Mã SP: <b>{0}</b> | Hãng: <b>{1}</b></div>",
                            HttpUtility.HtmlEncode(p.ProductCode), HttpUtility.HtmlEncode(p.Brand));

            sb.Append("<div class='item-price'>");
            if (p.OldPrice > p.Price)
            {
                sb.AppendFormat("<span class='old-price'>{0}</span>", SecurityHelper.FormatCurrency(p.OldPrice));
            }
            else
            {
                sb.Append("<span class='old-price'></span>");
            }

            sb.Append("<div class='current-price-box'>");
            sb.AppendFormat("<span class='new-price'>{0}</span>", SecurityHelper.FormatCurrency(p.Price));
            if (p.DiscountPercent > 0)
            {
                sb.AppendFormat("<span class='discount-badge'>-{0}%</span>", p.DiscountPercent);
            }
            sb.Append("</div></div>");

            sb.AppendFormat("<div class='item-promo'><p><i class='fa-solid fa-shield-halved'></i> BH: {0} tháng | Kho: <b>{1}</b> SP</p></div>",
                            p.WarrantyMonths, p.StockQuantity);
            sb.Append("</div>"); // end item-info

            sb.Append("<div class='item-action'>");
            sb.Append("<div class='action-left'>");
            sb.AppendFormat("<a href='{0}'><i class='fa-solid fa-circle-info'></i> Chi tiết</a>", detailUrl);
            if (p.StockQuantity > 0)
            {
                sb.AppendFormat("<span class='status'><i class='fa-solid fa-check'></i> Còn hàng ({0})</span>", p.StockQuantity);
            }
            else
            {
                sb.Append("<span class='status' style='color:#CB1C21;'><i class='fa-solid fa-circle-xmark'></i> Tạm hết hàng</span>");
            }
            sb.Append("</div>");

            sb.Append("<div class='action-right' style='display:flex; gap:6px; align-items:center;'>");
            if (p.StockQuantity > 0)
            {
                sb.AppendFormat("<a href='{0}' class='btn-quick-buy' title='Đặt mua ngay' style='background:#CB1C21;color:#fff;padding:6px 10px;border-radius:4px;font-size:12px;font-weight:bold;'>Đặt hàng</a>", buyNowUrl);
                sb.AppendFormat("<button type='button' onclick='addToCartAjax({0}, 1, event);' class='btn-quick-cart' title='Thêm vào giỏ hàng' style='background:#eef1ff;color:#3D52BF;border:none;padding:6px 10px;border-radius:4px;font-size:16px;cursor:pointer;'><i class='fa-solid fa-cart-plus'></i></button>", p.ProductId);
            }
            else
            {
                sb.Append("<span style='background:#ccc;color:#666;padding:6px 10px;border-radius:4px;font-size:12px;'>Hết hàng</span>");
            }
            sb.Append("</div>");
            sb.Append("</div>"); // end item-action

            sb.Append("</div>");
            return sb.ToString();
        }

        public static string RenderDealCard(ProductInfo p)
        {
            if (p == null) return "";
            StringBuilder sb = new StringBuilder();
            string detailUrl = "ChiTietSanPham.aspx?id=" + p.ProductId;
            string buyUrl = p.StockQuantity > 0 ? ("ThanhToan.aspx?buyId=" + p.ProductId) : detailUrl;

            sb.Append("<div class='box-content1'><div class='full-box'>");
            sb.AppendFormat("<div class='box-top-cnt'><a href='{0}'><img src='{1}' alt='{2}' /></a></div>",
                            detailUrl, HttpUtility.HtmlEncode(p.ImageUrl), HttpUtility.HtmlEncode(p.ProductName));
            sb.Append("<div class='box-bottom-cnt'>");
            sb.AppendFormat("<div class='text-content'><p><a href='{0}'>{1}</a></p></div>",
                            detailUrl, HttpUtility.HtmlEncode(p.ProductName));
            sb.Append("<div class='rice-deal'><div class='rice-top'>");
            sb.AppendFormat("<a href='{0}'><span>{1}</span>", detailUrl, SecurityHelper.FormatCurrency(p.Price));
            if (p.DiscountPercent > 0)
            {
                sb.AppendFormat("<span class='discount'>-{0}%</span>", p.DiscountPercent);
            }
            sb.Append("</a></div>");
            if (p.OldPrice > p.Price)
            {
                sb.AppendFormat("<span class='rice-discount'>{0}</span>", SecurityHelper.FormatCurrency(p.OldPrice));
            }
            sb.Append("</div>");

            sb.Append("<div class='deal-count'>");
            if (p.StockQuantity > 0)
                sb.AppendFormat("<span>Còn lại {0} sản phẩm</span>", p.StockQuantity);
            else
                sb.Append("<span>Tạm hết hàng</span>");
            sb.Append("<span class='img-deal'><img src='./BieuTuong/icon_order_status_deal.png' alt='' /></span>");
            sb.Append("</div>");

            sb.AppendFormat("<a href='{0}'><div class='buy-deal'><span>{1}</span></div></a>",
                            buyUrl, p.StockQuantity > 0 ? "MUA GIÁ SỐC" : "XEM CHI TIẾT");

            sb.Append("</div></div></div>");
            return sb.ToString();
        }

        public static string RenderOrderStatusBadge(string status)
        {
            string bg = "#64748b";
            string icon = "fa-circle-info";
            if (status == "Chờ xác nhận") { bg = "#f59e0b"; icon = "fa-clock"; }
            else if (status == "Đang chờ vận chuyển") { bg = "#0284c7"; icon = "fa-boxes-packing"; }
            else if (status == "Đang vận chuyển" || status == "Đang giao") { bg = "#2563eb"; icon = "fa-truck-fast"; }
            else if (status == "Đã giao") { bg = "#10b981"; icon = "fa-circle-check"; }
            else if (status == "Đã hủy") { bg = "#ef4444"; icon = "fa-circle-xmark"; }

            return string.Format("<span class='order-badge' style='background:{0};'><i class='fa-solid {1}' style='font-size:10px;'></i> {2}</span>",
                                 bg, icon, HttpUtility.HtmlEncode(status));
        }

        public static string FormatShortProductName(string raw, int maxWords = 5)
        {
            if (string.IsNullOrWhiteSpace(raw)) return "";
            string clean = raw;
            int pIdx = raw.IndexOf('(');
            if (pIdx > 0)
            {
                clean = raw.Substring(0, pIdx).Trim();
            }
            string[] words = clean.Split(new char[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length <= maxWords)
            {
                return clean + "...";
            }
            return string.Join(" ", words, 0, maxWords) + "...";
        }

        public static string RenderOrderItemsList(List<OrderDetailInfo> details)
        {
            if (details == null || details.Count == 0)
                return "<span style='color:#94a3b8; font-style:italic;'>Không có chi tiết sản phẩm</span>";

            StringBuilder sb = new StringBuilder();
            sb.Append("<div class='order-prod-list'>");
            for (int i = 0; i < details.Count; i++)
            {
                OrderDetailInfo d = details[i];
                string raw = d.ProductName ?? "";
                string shortName = FormatShortProductName(raw, 5);
                string detailHref = d.ProductId > 0 ? ("ChiTietSanPham.aspx?id=" + d.ProductId) : "#";
                string pcode = !string.IsNullOrEmpty(d.ProductCode) ? ("[" + HttpUtility.HtmlEncode(d.ProductCode) + "] ") : "";

                sb.AppendFormat("<div class='order-prod-row' title='Click xem chi tiết: {0}'>", HttpUtility.HtmlAttributeEncode(raw));
                sb.AppendFormat("<span class='order-qty-pill'>{0}x</span>", d.Quantity);
                sb.Append("<div class='order-prod-text'>");
                sb.AppendFormat("<a href='{0}' class='order-prod-title-link' target='_blank' title='Click xem chi tiết: {1}'>{2}{3}</a>",
                                detailHref,
                                HttpUtility.HtmlAttributeEncode(raw),
                                pcode,
                                HttpUtility.HtmlEncode(shortName));
                sb.Append("</div>");
                sb.AppendFormat("<span class='order-prod-price'>{0}</span>", SecurityHelper.FormatCurrency(d.LineTotal));
                sb.Append("</div>");
            }
            sb.Append("</div>");
            return sb.ToString();
        }

        public static string RenderSpecsTable(string specsRaw)
        {
            if (string.IsNullOrWhiteSpace(specsRaw))
                return "<p>Đang cập nhật thông số kỹ thuật.</p>";

            string[] rows = specsRaw.Split(new char[] { '|', '\n' }, StringSplitOptions.RemoveEmptyEntries);
            StringBuilder sb = new StringBuilder();
            sb.Append("<table class='specs-table'>");
            for (int i = 0; i < rows.Length; i++)
            {
                string line = rows[i].Trim();
                if (string.IsNullOrEmpty(line)) continue;
                int colonIdx = line.IndexOf(':');
                if (colonIdx > 0)
                {
                    string key = line.Substring(0, colonIdx).Trim();
                    string val = line.Substring(colonIdx + 1).Trim();
                    sb.AppendFormat("<tr><th>{0}</th><td>{1}</td></tr>",
                                    HttpUtility.HtmlEncode(key), HttpUtility.HtmlEncode(val));
                }
                else
                {
                    sb.AppendFormat("<tr><td colspan='2'>{0}</td></tr>", HttpUtility.HtmlEncode(line));
                }
            }
            sb.Append("</table>");
            return sb.ToString();
        }
    }
}
