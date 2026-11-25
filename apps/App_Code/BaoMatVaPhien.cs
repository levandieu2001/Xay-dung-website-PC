using System;
using System.Collections.Generic;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace PCMComputer
{
    public static class SecurityHelper
    {
        private const string SESSION_USER_KEY = "PCM_CURRENT_USER";
        private const string SESSION_CART_KEY = "PCM_SHOPPING_CART";

        public static string HashPassword(string password)
        {
            if (string.IsNullOrEmpty(password))
                return string.Empty;

            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(password);
                byte[] hash = sha.ComputeHash(bytes);
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < hash.Length; i++)
                {
                    sb.Append(hash[i].ToString("x2"));
                }
                return sb.ToString();
            }
        }

        public static UserInfo GetCurrentUser()
        {
            if (HttpContext.Current == null || HttpContext.Current.Session == null)
                return null;
            return HttpContext.Current.Session[SESSION_USER_KEY] as UserInfo;
        }

        public static void SetCurrentUser(UserInfo user)
        {
            if (HttpContext.Current != null && HttpContext.Current.Session != null)
            {
                HttpContext.Current.Session[SESSION_USER_KEY] = user;
            }
        }

        public static void Logout()
        {
            if (HttpContext.Current != null && HttpContext.Current.Session != null)
            {
                HttpContext.Current.Session.Remove(SESSION_USER_KEY);
            }
        }

        public static bool IsLoggedIn()
        {
            return GetCurrentUser() != null;
        }

        public static bool IsAdmin()
        {
            UserInfo u = GetCurrentUser();
            return u != null && string.Equals(u.Role, "Admin", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsStaffOrAdmin()
        {
            UserInfo u = GetCurrentUser();
            if (u == null) return false;
            return string.Equals(u.Role, "Admin", StringComparison.OrdinalIgnoreCase)
                || string.Equals(u.Role, "Staff", StringComparison.OrdinalIgnoreCase);
        }

        public static List<CartItem> GetCart()
        {
            if (HttpContext.Current == null || HttpContext.Current.Session == null)
                return new List<CartItem>();

            List<CartItem> cart = HttpContext.Current.Session[SESSION_CART_KEY] as List<CartItem>;
            if (cart == null)
            {
                cart = new List<CartItem>();
                HttpContext.Current.Session[SESSION_CART_KEY] = cart;
            }
            return cart;
        }

        public static bool AddToCart(int productId, int quantityToAdd, out string message)
        {
            message = "";
            if (quantityToAdd <= 0) quantityToAdd = 1;

            ProductInfo prod = DbHelper.GetProductById(productId);
            if (prod == null || prod.Status == "Ngừng kinh doanh")
            {
                message = "Sản phẩm không tồn tại hoặc đã ngừng kinh doanh.";
                return false;
            }

            if (prod.StockQuantity <= 0)
            {
                message = "Sản phẩm '" + prod.ProductName + "' hiện đang tạm hết hàng.";
                return false;
            }

            List<CartItem> cart = GetCart();
            CartItem existing = null;
            for (int i = 0; i < cart.Count; i++)
            {
                if (cart[i].ProductId == productId)
                {
                    existing = cart[i];
                    break;
                }
            }

            int newQty = quantityToAdd + (existing != null ? existing.Quantity : 0);
            if (newQty > prod.StockQuantity)
            {
                message = string.Format("Số lượng vượt quá tồn kho! Sản phẩm '{0}' hiện chỉ còn {1} sản phẩm trong kho.", prod.ProductName, prod.StockQuantity);
                return false;
            }

            if (existing != null)
            {
                existing.Quantity = newQty;
                existing.UnitPrice = prod.Price;
                existing.StockQuantity = prod.StockQuantity;
            }
            else
            {
                CartItem item = new CartItem();
                item.ProductId = prod.ProductId;
                item.ProductCode = prod.ProductCode;
                item.ProductName = prod.ProductName;
                item.ImageUrl = prod.ImageUrl;
                item.UnitPrice = prod.Price;
                item.Quantity = quantityToAdd;
                item.StockQuantity = prod.StockQuantity;
                cart.Add(item);
            }

            message = "Đã thêm '" + prod.ProductName + "' vào giỏ hàng!";
            return true;
        }

        public static bool UpdateCartQuantity(int productId, int newQty, out string message)
        {
            message = "";
            List<CartItem> cart = GetCart();
            CartItem target = null;
            for (int i = 0; i < cart.Count; i++)
            {
                if (cart[i].ProductId == productId)
                {
                    target = cart[i];
                    break;
                }
            }

            if (target == null)
            {
                message = "Không tìm thấy sản phẩm trong giỏ hàng.";
                return false;
            }

            if (newQty <= 0)
            {
                cart.Remove(target);
                message = "Đã xóa sản phẩm khỏi giỏ hàng.";
                return true;
            }

            ProductInfo prod = DbHelper.GetProductById(productId);
            int maxStock = prod != null ? prod.StockQuantity : target.StockQuantity;
            target.StockQuantity = maxStock;

            if (newQty > maxStock)
            {
                target.Quantity = maxStock > 0 ? maxStock : 1;
                message = string.Format("Bạn chỉ có thể đặt tối đa {0} sản phẩm theo số lượng hiện có trong kho!", maxStock);
                return false;
            }

            target.Quantity = newQty;
            if (prod != null) target.UnitPrice = prod.Price;
            message = "Đã cập nhật số lượng sản phẩm.";
            return true;
        }

        public static void RemoveFromCart(int productId)
        {
            List<CartItem> cart = GetCart();
            for (int i = cart.Count - 1; i >= 0; i--)
            {
                if (cart[i].ProductId == productId)
                {
                    cart.RemoveAt(i);
                }
            }
        }

        public static void ClearCart()
        {
            if (HttpContext.Current != null && HttpContext.Current.Session != null)
            {
                HttpContext.Current.Session[SESSION_CART_KEY] = new List<CartItem>();
            }
        }

        public static int GetCartCount()
        {
            List<CartItem> cart = GetCart();
            int total = 0;
            for (int i = 0; i < cart.Count; i++)
            {
                total += cart[i].Quantity;
            }
            return total;
        }

        public static decimal GetCartSubTotal()
        {
            List<CartItem> cart = GetCart();
            decimal sum = 0;
            for (int i = 0; i < cart.Count; i++)
            {
                sum += cart[i].LineTotal;
            }
            return sum;
        }

        public static string GetRoleLabel(string role)
        {
            switch (role)
            {
                case "Admin": return "Quản trị viên";
                case "Staff": return "Nhân viên";
                case "Customer": return "Khách hàng";
                default: return role;
            }
        }

        public static string FormatCurrency(decimal amount)
        {
            CultureInfo vi = new CultureInfo("vi-VN");
            return string.Format(vi, "{0:N0} đ", amount);
        }
    }
}
