using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace PCMComputer
{
    /// <summary>
    /// Lớp dịch vụ nghiệp vụ đặt hàng (:OrderService) theo đúng Biểu đồ tuần tự (Mục 3.7 - UC07)
    /// </summary>
    public class OrderService
    {
        // Thông điệp 3 -> 6: Truy vấn thông tin hồ sơ mặc định của người dùng từ CSDL
        public UserInfo getUserDefaultInfo(int userId)
        {
            return selectUserById(userId);
        }

        public UserInfo selectUserById(int userId)
        {
            return DbHelper.GetUserById(userId);
        }

        // Thông điệp 11 -> 12: Kiểm tra tồn kho thực tế và tính hợp lệ của mã khuyến mãi
        public bool checkStockAndVoucher(SqlConnection conn, SqlTransaction tran, List<CartItem> items, string voucherCode,
                                         out decimal subTotal, out decimal discountAmount, out string validVoucherCode, out string errorCode, out string errorMsg)
        {
            subTotal = 0;
            discountAmount = 0;
            validVoucherCode = null;
            errorCode = "";
            errorMsg = "";

            if (items == null || items.Count == 0)
            {
                errorCode = "EMPTY_CART";
                errorMsg = "Giỏ hàng của bạn đang trống. Vui lòng chọn sản phẩm trước khi đặt hàng.";
                return false;
            }

            for (int i = 0; i < items.Count; i++)
            {
                CartItem item = items[i];
                string sql = "SELECT TEN_SAN_PHAM, GIA_BAN, SO_LUONG_TON, TRANG_THAI FROM dbo.SANPHAM WITH (UPDLOCK) WHERE ID_SANPHAM = @pid";
                using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
                {
                    cmd.Parameters.AddWithValue("@pid", item.ProductId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            errorCode = "OUT_OF_STOCK";
                            errorMsg = "Sản phẩm '" + item.ProductName + "' không còn tồn tại trên hệ thống.";
                            return false;
                        }

                        string prodName = Convert.ToString(r["TEN_SAN_PHAM"]);
                        decimal actualPrice = Convert.ToDecimal(r["GIA_BAN"]);
                        int actualStock = Convert.ToInt32(r["SO_LUONG_TON"]);
                        string status = Convert.ToString(r["TRANG_THAI"]);

                        if (status == "Ngừng kinh doanh" || actualStock < item.Quantity)
                        {
                            errorCode = "OUT_OF_STOCK";
                            errorMsg = string.Format("Mã lỗi OUT_OF_STOCK: Sản phẩm '{0}' hiện chỉ còn {1} sản phẩm trong kho (bạn đang đặt {2}). Vui lòng điều chỉnh lại giỏ hàng!", prodName, actualStock, item.Quantity);
                            return false;
                        }

                        item.UnitPrice = actualPrice;
                        subTotal += actualPrice * item.Quantity;
                    }
                }
            }

            if (!string.IsNullOrWhiteSpace(voucherCode))
            {
                VoucherCheckResult vRes = DbHelper.ValidateVoucher(voucherCode.Trim(), subTotal);
                if (!vRes.IsValid)
                {
                    errorCode = "INVALID_VOUCHER";
                    errorMsg = vRes.Message;
                    return false;
                }
                discountAmount = vRes.DiscountAmount;
                validVoucherCode = vRes.Promotion.VoucherCode;
            }

            return true;
        }

        // Thông điệp 10 -> 20: Xử lý tạo đơn hàng trực tuyến (UC07)
        public OrderResult processCreateOrder(OrderDTO orderDTO)
        {
            OrderResult res = new OrderResult();
            res.IsSuccess = false;

            if (orderDTO == null || orderDTO.UserId <= 0)
            {
                res.ResultCode = "UNAUTHORIZED";
                res.Message = "Vui lòng đăng nhập tài khoản trước khi đặt hàng.";
                return res;
            }

            if (string.IsNullOrWhiteSpace(orderDTO.ReceiverName) ||
                string.IsNullOrWhiteSpace(orderDTO.ReceiverPhone) ||
                string.IsNullOrWhiteSpace(orderDTO.ShippingAddress))
            {
                res.ResultCode = "INVALID_INPUT";
                res.Message = "Vui lòng nhập đầy đủ Họ tên người nhận, Số điện thoại và Địa chỉ giao hàng!";
                return res;
            }

            using (SqlConnection conn = DbHelper.GetConnection())
            {
                conn.Open();
                SqlTransaction tran = conn.BeginTransaction();
                try
                {
                    decimal subTotal;
                    decimal discountAmount;
                    string validVoucherCode;
                    string errCode;
                    string errMsg;

                    // Bước 11-12: Kiểm tra tồn kho và mã khuyến mãi
                    if (!checkStockAndVoucher(conn, tran, orderDTO.Items, orderDTO.VoucherCode,
                                              out subTotal, out discountAmount, out validVoucherCode, out errCode, out errMsg))
                    {
                        tran.Rollback();
                        res.ResultCode = errCode;
                        res.Message = errMsg;
                        return res;
                    }

                    decimal totalAmount = subTotal - discountAmount;
                    if (totalAmount < 0) totalAmount = 0;

                    string orderCode = "DH" + DateTime.Now.ToString("yyyyMMddHHmmss");

                    // Bước 13a: insertOrder()
                    int newOrderId = insertOrder(conn, tran, orderCode, orderDTO, subTotal, validVoucherCode, discountAmount, totalAmount);

                    // Bước 13b & 14: insertOrderDetails() & updateProductStock(-qty)
                    for (int i = 0; i < orderDTO.Items.Count; i++)
                    {
                        CartItem item = orderDTO.Items[i];
                        insertOrderDetails(conn, tran, newOrderId, item);
                        updateProductStock(conn, tran, item.ProductId, item.Quantity);
                    }

                    // Cập nhật lượt dùng mã khuyến mãi nếu có (UC16)
                    if (!string.IsNullOrEmpty(validVoucherCode))
                    {
                        string vSql = "UPDATE dbo.KHUYENMAI SET SO_LUOT_DA_DUNG = SO_LUOT_DA_DUNG + 1 WHERE MA_GIAM_GIA = @vcode";
                        using (SqlCommand vCmd = new SqlCommand(vSql, conn, tran))
                        {
                            vCmd.Parameters.AddWithValue("@vcode", validVoucherCode);
                            vCmd.ExecuteNonQuery();
                        }
                    }

                    // Ghi lịch sử khởi tạo đơn hàng
                    string histSql = "INSERT INTO dbo.LICHSUTRANGTHAIDONHANG (ID_DONHANG, TRANG_THAI, GHI_CHU, NGUOI_CAP_NHAT) VALUES (@oid, N'Chờ xác nhận', N'Khách hàng đặt hàng trực tuyến thành công', @by)";
                    using (SqlCommand hCmd = new SqlCommand(histSql, conn, tran))
                    {
                        hCmd.Parameters.AddWithValue("@oid", newOrderId);
                        hCmd.Parameters.AddWithValue("@by", string.IsNullOrEmpty(orderDTO.Username) ? "customer" : orderDTO.Username);
                        hCmd.ExecuteNonQuery();
                    }

                    tran.Commit();

                    // Bước 15: clearCart(userId)
                    clearCart(orderDTO.UserId);

                    res.IsSuccess = true;
                    res.ResultCode = "SUCCESS";
                    res.OrderId = newOrderId;
                    res.OrderCode = orderCode;
                    res.Message = "Đặt hàng thành công! Mã đơn hàng của bạn là: " + orderCode;
                    return res;
                }
                catch (Exception ex)
                {
                    tran.Rollback();
                    res.ResultCode = "ERROR";
                    res.Message = "Có lỗi xảy ra trong quá trình tạo đơn hàng: " + ex.Message;
                    return res;
                }
            }
        }

        private int insertOrder(SqlConnection conn, SqlTransaction tran, string orderCode, OrderDTO dto,
                                decimal subTotal, string voucherCode, decimal discountAmount, decimal totalAmount)
        {
            string sql = @"INSERT INTO dbo.DONHANG (
                               MA_DON_HANG, ID_TAIKHOAN, TEN_NGUOI_NHAN, DIEN_THOAI_NGUOI_NHAN, DIA_CHI_GIAO_HANG, GHI_CHU,
                               PHUONG_THUC_THANH_TOAN, TAM_TINH, MA_GIAM_GIA, SO_TIEN_GIAM, TONG_TIEN, TRANG_THAI_DON_HANG
                           ) VALUES (
                               @code, @uid, @rname, @rphone, @addr, @note,
                               @pay, @sub, @vcode, @disc, @tot, N'Chờ xác nhận'
                           );
                           SELECT SCOPE_IDENTITY();";
            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
            {
                cmd.Parameters.AddWithValue("@code", orderCode);
                cmd.Parameters.AddWithValue("@uid", dto.UserId);
                cmd.Parameters.AddWithValue("@rname", dto.ReceiverName.Trim());
                cmd.Parameters.AddWithValue("@rphone", dto.ReceiverPhone.Trim());
                cmd.Parameters.AddWithValue("@addr", dto.ShippingAddress.Trim());
                cmd.Parameters.AddWithValue("@note", (dto.Note ?? "").Trim());
                cmd.Parameters.AddWithValue("@pay", string.IsNullOrWhiteSpace(dto.PaymentMethod) ? "COD - Thanh toán khi nhận hàng" : dto.PaymentMethod);
                cmd.Parameters.AddWithValue("@sub", subTotal);
                if (string.IsNullOrEmpty(voucherCode))
                    cmd.Parameters.AddWithValue("@vcode", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@vcode", voucherCode);
                cmd.Parameters.AddWithValue("@disc", discountAmount);
                cmd.Parameters.AddWithValue("@tot", totalAmount);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private void insertOrderDetails(SqlConnection conn, SqlTransaction tran, int orderId, CartItem item)
        {
            string sql = @"INSERT INTO dbo.CHITIETDONHANG (
                               ID_DONHANG, ID_SANPHAM, MA_SAN_PHAM, TEN_SAN_PHAM, DUONG_DAN_ANH, DON_GIA, SO_LUONG, THANH_TIEN
                           ) VALUES (
                               @oid, @pid, @pcode, @pname, @img, @price, @qty, @total
                           )";
            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
            {
                cmd.Parameters.AddWithValue("@oid", orderId);
                cmd.Parameters.AddWithValue("@pid", item.ProductId);
                cmd.Parameters.AddWithValue("@pcode", item.ProductCode);
                cmd.Parameters.AddWithValue("@pname", item.ProductName);
                cmd.Parameters.AddWithValue("@img", item.ImageUrl ?? "");
                cmd.Parameters.AddWithValue("@price", item.UnitPrice);
                cmd.Parameters.AddWithValue("@qty", item.Quantity);
                cmd.Parameters.AddWithValue("@total", item.LineTotal);
                cmd.ExecuteNonQuery();
            }
        }

        private void updateProductStock(SqlConnection conn, SqlTransaction tran, int productId, int quantityToDeduct)
        {
            string sql = @"UPDATE dbo.SANPHAM
                           SET SO_LUONG_TON = SO_LUONG_TON - @qty,
                               SO_LUONG_DA_BAN = SO_LUONG_DA_BAN + @qty
                           WHERE ID_SANPHAM = @pid";
            using (SqlCommand cmd = new SqlCommand(sql, conn, tran))
            {
                cmd.Parameters.AddWithValue("@qty", quantityToDeduct);
                cmd.Parameters.AddWithValue("@pid", productId);
                cmd.ExecuteNonQuery();
            }
        }

        public void clearCart(int userId)
        {
            SecurityHelper.ClearCart();
        }
    }
}
