using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace PCMComputer
{
    public static class DbHelper
    {
        public static string ConnectionString
        {
            get
            {
                ConnectionStringSettings cs = ConfigurationManager.ConnectionStrings["PCMComputerDB"];
                if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString))
                    return cs.ConnectionString;
                return @"Server=.\SQLEXPRESS;Database=PCMComputerDB;Integrated Security=True;MultipleActiveResultSets=True";
            }
        }

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(ConnectionString);
        }

        // ====================================================================
        // 1. TÀI KHOẢN VÀ XÁC THỰC (UC01, UC02, UC12, UC15)
        // ====================================================================
        public static UserInfo AuthenticateUser(string usernameOrEmail, string password, out string errorMsg)
        {
            errorMsg = "";
            if (string.IsNullOrWhiteSpace(usernameOrEmail) || string.IsNullOrWhiteSpace(password))
            {
                errorMsg = "Vui lòng nhập đầy đủ Tên đăng nhập/Email và Mật khẩu.";
                return null;
            }

            string hashed = SecurityHelper.HashPassword(password.Trim());
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT UserId, Username, PasswordHash, FullName, Email, Phone, Address, Role, IsLocked, CreatedAt
                               FROM dbo.TAIKHOAN
                               WHERE (Username = @u OR Email = @u)";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@u", usernameOrEmail.Trim());
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            errorMsg = "Thông tin đăng nhập không chính xác.";
                            return null;
                        }

                        UserInfo user = MapUser(r);
                        bool matchHash = string.Equals(user.PasswordHash, hashed, StringComparison.OrdinalIgnoreCase);
                        bool matchPlain = string.Equals(user.PasswordHash, password.Trim(), StringComparison.Ordinal);
                        if (!matchHash && !matchPlain)
                        {
                            errorMsg = "Thông tin đăng nhập không chính xác.";
                            return null;
                        }

                        if (user.IsLocked)
                        {
                            errorMsg = "Tài khoản của bạn đã bị Quản trị viên khóa. Vui lòng liên hệ quản trị viên để được hỗ trợ.";
                            return null;
                        }

                        return user;
                    }
                }
            }
        }

        public static UserInfo RegisterCustomer(string username, string password, string fullName, string email, string phone, string address, out string errorMsg)
        {
            errorMsg = "";
            if (string.IsNullOrWhiteSpace(fullName) || string.IsNullOrWhiteSpace(username) ||
                string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(phone) || string.IsNullOrWhiteSpace(password))
            {
                errorMsg = "Vui lòng nhập đầy đủ các trường thông tin bắt buộc.";
                return null;
            }

            if (password.Trim().Length < 6)
            {
                errorMsg = "Mật khẩu phải có độ dài tối thiểu từ 6 ký tự trở lên.";
                return null;
            }

            if (!email.Contains("@") || !email.Contains("."))
            {
                errorMsg = "Định dạng Email không hợp lệ (Ví dụ: khachhang@gmail.com).";
                return null;
            }

            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string checkSql = "SELECT COUNT(*) FROM dbo.TAIKHOAN WHERE Username = @u OR Email = @e OR Phone = @p";
                using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@u", username.Trim());
                    checkCmd.Parameters.AddWithValue("@e", email.Trim());
                    checkCmd.Parameters.AddWithValue("@p", phone.Trim());
                    int count = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (count > 0)
                    {
                        errorMsg = "Tài khoản đã được sử dụng (Tên đăng nhập, Email hoặc Số điện thoại đã tồn tại).";
                        return null;
                    }
                }

                string hash = SecurityHelper.HashPassword(password.Trim());
                string insertSql = @"INSERT INTO dbo.TAIKHOAN (Username, PasswordHash, FullName, Email, Phone, Address, Role, IsLocked)
                                     VALUES (@u, @pw, @fn, @e, @ph, @ad, 'Customer', 0);
                                     SELECT SCOPE_IDENTITY();";
                using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                {
                    cmd.Parameters.AddWithValue("@u", username.Trim());
                    cmd.Parameters.AddWithValue("@pw", hash);
                    cmd.Parameters.AddWithValue("@fn", fullName.Trim());
                    cmd.Parameters.AddWithValue("@e", email.Trim());
                    cmd.Parameters.AddWithValue("@ph", phone.Trim());
                    cmd.Parameters.AddWithValue("@ad", (object)(address ?? "").Trim());
                    int newId = Convert.ToInt32(cmd.ExecuteScalar());
                    return GetUserById(newId);
                }
            }
        }

        public static UserInfo GetUserById(int userId)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = "SELECT UserId, Username, PasswordHash, FullName, Email, Phone, Address, Role, IsLocked, CreatedAt FROM dbo.TAIKHOAN WHERE UserId = @id";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", userId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                            return MapUser(r);
                    }
                }
            }
            return null;
        }

        public static bool UpdateUserProfile(int userId, string fullName, string email, string phone, string address, out string errorMsg)
        {
            errorMsg = "";
            if (string.IsNullOrWhiteSpace(fullName) || string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(phone))
            {
                errorMsg = "Họ tên, Email và Số điện thoại không được để trống.";
                return false;
            }

            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string checkSql = "SELECT COUNT(*) FROM dbo.TAIKHOAN WHERE Email = @e AND UserId <> @id";
                using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@e", email.Trim());
                    checkCmd.Parameters.AddWithValue("@id", userId);
                    if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                    {
                        errorMsg = "Email này đã được sử dụng bởi một tài khoản khác.";
                        return false;
                    }
                }

                string sql = "UPDATE dbo.TAIKHOAN SET FullName = @fn, Email = @e, Phone = @ph, Address = @ad WHERE UserId = @id";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@fn", fullName.Trim());
                    cmd.Parameters.AddWithValue("@e", email.Trim());
                    cmd.Parameters.AddWithValue("@ph", phone.Trim());
                    cmd.Parameters.AddWithValue("@ad", (address ?? "").Trim());
                    cmd.Parameters.AddWithValue("@id", userId);
                    cmd.ExecuteNonQuery();
                }
            }
            return true;
        }

        public static bool ChangePassword(int userId, string oldPassword, string newPassword, out string errorMsg)
        {
            errorMsg = "";
            if (string.IsNullOrWhiteSpace(oldPassword) || string.IsNullOrWhiteSpace(newPassword))
            {
                errorMsg = "Vui lòng nhập mật khẩu hiện tại và mật khẩu mới.";
                return false;
            }

            if (newPassword.Trim().Length < 6)
            {
                errorMsg = "Mật khẩu mới phải có độ dài tối thiểu 6 ký tự.";
                return false;
            }

            UserInfo u = GetUserById(userId);
            if (u == null)
            {
                errorMsg = "Không tìm thấy tài khoản người dùng.";
                return false;
            }

            string oldHash = SecurityHelper.HashPassword(oldPassword.Trim());
            if (!string.Equals(u.PasswordHash, oldHash, StringComparison.OrdinalIgnoreCase))
            {
                errorMsg = "Mật khẩu hiện tại không chính xác.";
                return false;
            }

            string newHash = SecurityHelper.HashPassword(newPassword.Trim());
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("UPDATE dbo.TAIKHOAN SET PasswordHash = @pw WHERE UserId = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@pw", newHash);
                    cmd.Parameters.AddWithValue("@id", userId);
                    cmd.ExecuteNonQuery();
                }
            }
            return true;
        }

        public static List<UserInfo> GetAllUsers(string roleFilter, string keyword)
        {
            List<UserInfo> list = new List<UserInfo>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT UserId, Username, PasswordHash, FullName, Email, Phone, Address, Role, IsLocked, CreatedAt
                               FROM dbo.TAIKHOAN WHERE 1=1";
                if (!string.IsNullOrWhiteSpace(roleFilter))
                    sql += " AND Role = @role";
                if (!string.IsNullOrWhiteSpace(keyword))
                    sql += " AND (Username LIKE @kw OR FullName LIKE @kw OR Email LIKE @kw OR Phone LIKE @kw)";
                sql += " ORDER BY CASE Role WHEN 'Admin' THEN 1 WHEN 'Staff' THEN 2 ELSE 3 END, UserId ASC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(roleFilter))
                        cmd.Parameters.AddWithValue("@role", roleFilter.Trim());
                    if (!string.IsNullOrWhiteSpace(keyword))
                        cmd.Parameters.AddWithValue("@kw", "%" + keyword.Trim() + "%");

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            list.Add(MapUser(r));
                        }
                    }
                }
            }
            return list;
        }

        public static bool AdminCreateUser(string username, string password, string fullName, string email, string phone, string address, string role, out string errorMsg)
        {
            errorMsg = "";
            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password) ||
                string.IsNullOrWhiteSpace(fullName) || string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(phone))
            {
                errorMsg = "Vui lòng nhập đầy đủ Tên đăng nhập, Mật khẩu, Họ tên, Email và Số điện thoại.";
                return false;
            }

            if (password.Trim().Length < 6)
            {
                errorMsg = "Mật khẩu phải từ 6 ký tự trở lên.";
                return false;
            }

            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM dbo.TAIKHOAN WHERE Username = @u OR Email = @e", conn))
                {
                    chk.Parameters.AddWithValue("@u", username.Trim());
                    chk.Parameters.AddWithValue("@e", email.Trim());
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                    {
                        errorMsg = "Tên đăng nhập hoặc Email đã tồn tại trong hệ thống.";
                        return false;
                    }
                }

                string validRole = (role == "Admin" || role == "Staff") ? role : "Customer";
                string sql = @"INSERT INTO dbo.TAIKHOAN (Username, PasswordHash, FullName, Email, Phone, Address, Role, IsLocked)
                               VALUES (@u, @pw, @fn, @e, @ph, @ad, @r, 0)";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@u", username.Trim());
                    cmd.Parameters.AddWithValue("@pw", SecurityHelper.HashPassword(password.Trim()));
                    cmd.Parameters.AddWithValue("@fn", fullName.Trim());
                    cmd.Parameters.AddWithValue("@e", email.Trim());
                    cmd.Parameters.AddWithValue("@ph", phone.Trim());
                    cmd.Parameters.AddWithValue("@ad", (address ?? "").Trim());
                    cmd.Parameters.AddWithValue("@r", validRole);
                    cmd.ExecuteNonQuery();
                }
            }
            return true;
        }

        public static bool AdminUpdateUserRoleAndLock(int currentAdminId, int targetUserId, string newRole, bool isLocked, out string errorMsg)
        {
            errorMsg = "";
            // Ngoại lệ UC12: Không cho phép Admin tự khóa hoặc tự hạ quyền tài khoản của chính mình
            if (currentAdminId == targetUserId)
            {
                if (isLocked || !string.Equals(newRole, "Admin", StringComparison.OrdinalIgnoreCase))
                {
                    errorMsg = "Không thể tự khóa hoặc hạ quyền chính tài khoản Quản trị viên đang đăng nhập hiện tại!";
                    return false;
                }
            }

            string validRole = (newRole == "Admin" || newRole == "Staff") ? newRole : "Customer";
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("UPDATE dbo.TAIKHOAN SET Role = @r, IsLocked = @l WHERE UserId = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@r", validRole);
                    cmd.Parameters.AddWithValue("@l", isLocked);
                    cmd.Parameters.AddWithValue("@id", targetUserId);
                    cmd.ExecuteNonQuery();
                }
            }
            return true;
        }

        private static UserInfo MapUser(SqlDataReader r)
        {
            UserInfo u = new UserInfo();
            u.UserId = Convert.ToInt32(r["UserId"]);
            u.Username = Convert.ToString(r["Username"]);
            u.PasswordHash = Convert.ToString(r["PasswordHash"]);
            u.FullName = Convert.ToString(r["FullName"]);
            u.Email = Convert.ToString(r["Email"]);
            u.Phone = Convert.ToString(r["Phone"]);
            u.Address = r["Address"] != DBNull.Value ? Convert.ToString(r["Address"]) : "";
            u.Role = Convert.ToString(r["Role"]);
            u.IsLocked = Convert.ToBoolean(r["IsLocked"]);
            u.CreatedAt = Convert.ToDateTime(r["CreatedAt"]);
            return u;
        }

        // ====================================================================
        // 2. DANH MỤC (UC03, UC10)
        // ====================================================================
        public static List<CategoryInfo> GetCategories(bool activeOnly)
        {
            List<CategoryInfo> list = new List<CategoryInfo>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT c.CategoryId, c.CategoryName, c.Slug, c.PageUrl, c.IconPath, c.Description, c.DisplayOrder, c.IsActive,
                                      (SELECT COUNT(*) FROM dbo.SANPHAM p WHERE p.CategoryId = c.CategoryId AND p.Status = N'Đang kinh doanh') AS ProductCount
                               FROM dbo.DANHMUC c";
                if (activeOnly)
                    sql += " WHERE c.IsActive = 1";
                sql += " ORDER BY c.DisplayOrder ASC, c.CategoryId ASC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            list.Add(MapCategory(r));
                        }
                    }
                }
            }
            return list;
        }

        public static CategoryInfo GetCategoryById(int categoryId)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT c.CategoryId, c.CategoryName, c.Slug, c.PageUrl, c.IconPath, c.Description, c.DisplayOrder, c.IsActive,
                                      (SELECT COUNT(*) FROM dbo.SANPHAM p WHERE p.CategoryId = c.CategoryId) AS ProductCount
                               FROM dbo.DANHMUC c WHERE c.CategoryId = @id";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", categoryId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read()) return MapCategory(r);
                    }
                }
            }
            return null;
        }

        public static CategoryInfo GetCategoryByPageUrl(string pageUrl)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT TOP 1 c.CategoryId, c.CategoryName, c.Slug, c.PageUrl, c.IconPath, c.Description, c.DisplayOrder, c.IsActive,
                                      (SELECT COUNT(*) FROM dbo.SANPHAM p WHERE p.CategoryId = c.CategoryId) AS ProductCount
                               FROM dbo.DANHMUC c WHERE c.PageUrl = @url OR c.Slug = @url";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@url", pageUrl);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read()) return MapCategory(r);
                    }
                }
            }
            return null;
        }

        public static bool SaveCategory(CategoryInfo cat, out string errorMsg)
        {
            errorMsg = "";
            if (cat == null || string.IsNullOrWhiteSpace(cat.CategoryName))
            {
                errorMsg = "Tên danh mục không được để trống.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(cat.Slug))
            {
                cat.Slug = "cat-" + DateTime.Now.Ticks.ToString();
            }

            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                // Kiểm tra trùng tên danh mục (UC10)
                string checkSql = "SELECT COUNT(*) FROM dbo.DANHMUC WHERE (CategoryName = @name OR Slug = @slug) AND CategoryId <> @id";
                using (SqlCommand chk = new SqlCommand(checkSql, conn))
                {
                    chk.Parameters.AddWithValue("@name", cat.CategoryName.Trim());
                    chk.Parameters.AddWithValue("@slug", cat.Slug.Trim());
                    chk.Parameters.AddWithValue("@id", cat.CategoryId);
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                    {
                        errorMsg = "Tên danh mục hoặc Mã đường dẫn (Slug) đã tồn tại trong hệ thống!";
                        return false;
                    }
                }

                if (cat.CategoryId <= 0)
                {
                    string ins = @"INSERT INTO dbo.DANHMUC (CategoryName, Slug, PageUrl, IconPath, Description, DisplayOrder, IsActive)
                                   VALUES (@name, @slug, @url, @icon, @desc, @ord, @act)";
                    using (SqlCommand cmd = new SqlCommand(ins, conn))
                    {
                        cmd.Parameters.AddWithValue("@name", cat.CategoryName.Trim());
                        cmd.Parameters.AddWithValue("@slug", cat.Slug.Trim());
                        cmd.Parameters.AddWithValue("@url", string.IsNullOrWhiteSpace(cat.PageUrl) ? "SanPham.aspx" : cat.PageUrl.Trim());
                        cmd.Parameters.AddWithValue("@icon", string.IsNullOrWhiteSpace(cat.IconPath) ? "./BieuTuong/linhkien.png" : cat.IconPath.Trim());
                        cmd.Parameters.AddWithValue("@desc", (cat.Description ?? "").Trim());
                        cmd.Parameters.AddWithValue("@ord", cat.DisplayOrder > 0 ? cat.DisplayOrder : 10);
                        cmd.Parameters.AddWithValue("@act", cat.IsActive);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    string upd = @"UPDATE dbo.DANHMUC
                                   SET CategoryName = @name, Slug = @slug, PageUrl = @url, IconPath = @icon,
                                       Description = @desc, DisplayOrder = @ord, IsActive = @act
                                   WHERE CategoryId = @id";
                    using (SqlCommand cmd = new SqlCommand(upd, conn))
                    {
                        cmd.Parameters.AddWithValue("@name", cat.CategoryName.Trim());
                        cmd.Parameters.AddWithValue("@slug", cat.Slug.Trim());
                        cmd.Parameters.AddWithValue("@url", string.IsNullOrWhiteSpace(cat.PageUrl) ? "SanPham.aspx" : cat.PageUrl.Trim());
                        cmd.Parameters.AddWithValue("@icon", string.IsNullOrWhiteSpace(cat.IconPath) ? "./BieuTuong/linhkien.png" : cat.IconPath.Trim());
                        cmd.Parameters.AddWithValue("@desc", (cat.Description ?? "").Trim());
                        cmd.Parameters.AddWithValue("@ord", cat.DisplayOrder);
                        cmd.Parameters.AddWithValue("@act", cat.IsActive);
                        cmd.Parameters.AddWithValue("@id", cat.CategoryId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            return true;
        }

        public static bool DeleteCategory(int categoryId, out string errorMsg)
        {
            errorMsg = "";
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                // Ngoại lệ UC10: Nếu danh mục đang chứa sản phẩm trực thuộc, ngăn thao tác xóa
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM dbo.SANPHAM WHERE CategoryId = @id", conn))
                {
                    chk.Parameters.AddWithValue("@id", categoryId);
                    int prodCount = Convert.ToInt32(chk.ExecuteScalar());
                    if (prodCount > 0)
                    {
                        errorMsg = string.Format("Không thể xóa danh mục này vì đang chứa {0} sản phẩm trực thuộc! Vui lòng chuyển hoặc xóa các sản phẩm trước.", prodCount);
                        return false;
                    }
                }

                using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.DANHMUC WHERE CategoryId = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", categoryId);
                    cmd.ExecuteNonQuery();
                }
            }
            return true;
        }

        // Quy đổi đường dẫn đã lưu trong cơ sở dữ liệu trước khi đổi tên tệp.
        private static readonly Dictionary<string, string> LegacyCategoryPages =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "GamingLaptops.aspx", "MayTinhXachTayChoiGame.aspx" },
            { "Laptops.aspx", "MayTinhXachTay.aspx" },
            { "GamingPCs.aspx", "MayTinhChoiGame.aspx" },
            { "Workstations.aspx", "MayTram.aspx" },
            { "OfficePCs.aspx", "MayTinhVanPhong.aspx" },
            { "Components.aspx", "LinhKien.aspx" },
            { "MonitorsPrinters.aspx", "ManHinhMayIn.aspx" },
            { "KeyboardsMice.aspx", "BanPhimChuot.aspx" },
            { "Accessories.aspx", "PhuKien.aspx" },
            { "AudioVideo.aspx", "AmThanhHinhAnh.aspx" },
            { "Cooling.aspx", "TanNhiet.aspx" },
            { "NetworkingCameras.aspx", "ThietBiMangCamera.aspx" },
            { "Phones.aspx", "DienThoai.aspx" },
            { "Watches.aspx", "DongHoThongMinh.aspx" },
            { "Products.aspx", "SanPham.aspx" },
        };

        private static string LocalizeCategoryPage(string url)
        {
            if (string.IsNullOrEmpty(url)) return url;

            int suffixIndex = url.IndexOfAny(new[] { '?', '#' });
            string path = suffixIndex < 0 ? url : url.Substring(0, suffixIndex);
            int nameStart = path.StartsWith("./", StringComparison.Ordinal) ? 2
                : path.StartsWith("~/", StringComparison.Ordinal) ? 2
                : path.StartsWith("/", StringComparison.Ordinal) && !path.StartsWith("//", StringComparison.Ordinal) ? 1
                : 0;
            string newName;
            return LegacyCategoryPages.TryGetValue(path.Substring(nameStart), out newName)
                ? path.Substring(0, nameStart) + newName + (suffixIndex < 0 ? "" : url.Substring(suffixIndex))
                : url;
        }

        public static string LocalizeAssetPath(string url)
        {
            if (string.IsNullOrEmpty(url)) return url;

            int folderStart = url.StartsWith("./", StringComparison.Ordinal) ? 2
                : url.StartsWith("~/", StringComparison.Ordinal) ? 2
                : url.StartsWith("/", StringComparison.Ordinal) && !url.StartsWith("//", StringComparison.Ordinal) ? 1
                : 0;
            int folderEnd = url.IndexOf('/', folderStart);
            if (folderEnd < 0) return url;

            string folder = url.Substring(folderStart, folderEnd - folderStart);
            if (folder.Equals("Icon", StringComparison.OrdinalIgnoreCase))
                return url.Substring(0, folderStart) + "BieuTuong" + url.Substring(folderEnd);
            if (folder.Equals("Image", StringComparison.OrdinalIgnoreCase))
                return url.Substring(0, folderStart) + "HinhAnh" + url.Substring(folderEnd);
            return url;
        }

        private static CategoryInfo MapCategory(SqlDataReader r)
        {
            CategoryInfo c = new CategoryInfo();
            c.CategoryId = Convert.ToInt32(r["CategoryId"]);
            c.CategoryName = Convert.ToString(r["CategoryName"]);
            c.Slug = Convert.ToString(r["Slug"]);
            c.PageUrl = r["PageUrl"] != DBNull.Value ? LocalizeCategoryPage(Convert.ToString(r["PageUrl"])) : "SanPham.aspx";
            c.IconPath = r["IconPath"] != DBNull.Value ? LocalizeAssetPath(Convert.ToString(r["IconPath"])) : "./BieuTuong/linhkien.png";
            c.Description = r["Description"] != DBNull.Value ? Convert.ToString(r["Description"]) : "";
            c.DisplayOrder = Convert.ToInt32(r["DisplayOrder"]);
            c.IsActive = Convert.ToBoolean(r["IsActive"]);
            c.ProductCount = r["ProductCount"] != DBNull.Value ? Convert.ToInt32(r["ProductCount"]) : 0;
            return c;
        }

        // ====================================================================
        // 3. SẢN PHẨM (UC03, UC04, UC05, UC09)
        // ====================================================================
        public static List<ProductInfo> GetDealProducts(int top)
        {
            List<ProductInfo> list = new List<ProductInfo>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = string.Format(@"SELECT TOP {0} p.*, c.CategoryName
                               FROM dbo.SANPHAM p
                               INNER JOIN dbo.DANHMUC c ON p.CategoryId = c.CategoryId
                               WHERE p.Status = N'Đang kinh doanh' AND p.IsDeal = 1
                               ORDER BY p.ProductId ASC", top);
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read()) list.Add(MapProduct(r));
                    }
                }
            }
            return list;
        }

        public static List<ProductInfo> GetTopSellingProducts(int top, int? categoryId)
        {
            List<ProductInfo> list = new List<ProductInfo>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = string.Format(@"SELECT TOP {0} p.*, c.CategoryName
                               FROM dbo.SANPHAM p
                               INNER JOIN dbo.DANHMUC c ON p.CategoryId = c.CategoryId
                               WHERE p.Status = N'Đang kinh doanh'", top);
                if (categoryId.HasValue && categoryId.Value > 0)
                    sql += " AND p.CategoryId = @catId";
                sql += " ORDER BY p.SoldCount DESC, p.ProductId ASC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (categoryId.HasValue && categoryId.Value > 0)
                        cmd.Parameters.AddWithValue("@catId", categoryId.Value);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read()) list.Add(MapProduct(r));
                    }
                }
            }
            return list;
        }

        public static List<ProductInfo> SearchProducts(int? categoryId, string keyword, string brand, string priceRange, string sortBy, bool includeInactive)
        {
            List<ProductInfo> list = new List<ProductInfo>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT p.*, c.CategoryName
                               FROM dbo.SANPHAM p
                               INNER JOIN dbo.DANHMUC c ON p.CategoryId = c.CategoryId
                               WHERE 1=1";

                if (!includeInactive)
                    sql += " AND p.Status = N'Đang kinh doanh'";

                if (categoryId.HasValue && categoryId.Value > 0)
                    sql += " AND p.CategoryId = @catId";

                string kwLower = (keyword ?? "").Trim().ToLower();
                bool isIntent = false;

                if (!string.IsNullOrWhiteSpace(kwLower))
                {
                    if (kwLower == "vga" || kwLower == "card man hinh" || kwLower == "card màn hình" || kwLower == "card do hoa" || kwLower == "card đồ họa" || kwLower == "gpu")
                    {
                        isIntent = true;
                        sql += " AND (p.ProductName LIKE N'%VGA%' OR p.ProductCode LIKE N'%VGA%' OR (p.CategoryId = 6 AND (p.ProductName LIKE N'%GeForce%' OR p.ProductName LIKE N'%RTX%' OR p.ProductName LIKE N'%GTX%' OR p.ProductName LIKE N'%Radeon%')))";
                    }
                    else if (kwLower == "pc" || kwLower == "máy tính bàn" || kwLower == "may tinh ban" || kwLower == "pc gaming" || kwLower == "pc do hoa" || kwLower == "pc đồ họa")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId IN (3, 4, 5) OR p.ProductName LIKE N'PC %' OR p.ProductName LIKE N'% PC %' OR p.ProductName LIKE N'Bộ Mini PC%')";
                    }
                    else if (kwLower == "laptop" || kwLower == "máy tính xách tay" || kwLower == "may tinh xach tay" || kwLower == "notebook")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId IN (1, 2) OR p.ProductName LIKE N'%Laptop%')";
                    }
                    else if (kwLower == "ram")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 6 AND (p.ProductName LIKE N'%RAM%' OR p.ProductName LIKE N'%Bộ nhớ trong%'))";
                    }
                    else if (kwLower == "cpu" || kwLower == "chip" || kwLower == "vi xử lý" || kwLower == "vi xu ly")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 6 AND (p.ProductName LIKE N'%CPU%' OR p.ProductName LIKE N'%Core i%' OR p.ProductName LIKE N'%Ryzen%'))";
                    }
                    else if (kwLower == "ssd" || kwLower == "ổ cứng" || kwLower == "o cung")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 6 AND (p.ProductName LIKE N'%SSD%' OR p.ProductName LIKE N'%Ổ Cứng%'))";
                    }
                    else if (kwLower == "main" || kwLower == "mainboard" || kwLower == "bo mạch chủ" || kwLower == "bo mach chu")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 6 AND (p.ProductName LIKE N'%Mainboard%' OR p.ProductName LIKE N'%Bo Mạch Chủ%'))";
                    }
                    else if (kwLower == "màn hình" || kwLower == "man hinh" || kwLower == "monitor")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 7 AND p.ProductName LIKE N'%Màn Hình%')";
                    }
                    else if (kwLower == "máy in" || kwLower == "may in" || kwLower == "printer")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 7 AND p.ProductName LIKE N'%Máy In%')";
                    }
                    else if (kwLower == "chuột" || kwLower == "chuot" || kwLower == "mouse")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 8 AND (p.ProductName LIKE N'%Chuột%' OR p.ProductName LIKE N'%Mouse%'))";
                    }
                    else if (kwLower == "bàn phím" || kwLower == "ban phim" || kwLower == "keyboard")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 8 AND (p.ProductName LIKE N'%Bàn Phím%' OR p.ProductName LIKE N'%Keyboard%'))";
                    }
                    else if (kwLower == "tai nghe" || kwLower == "headphone" || kwLower == "headset")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 10 AND (p.ProductName LIKE N'%Tai Nghe%' OR p.ProductName LIKE N'%Headset%'))";
                    }
                    else if (kwLower == "loa" || kwLower == "speaker")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 10 AND (p.ProductName LIKE N'%Loa %' OR p.ProductName LIKE N'%Speaker%'))";
                    }
                    else if (kwLower == "webcam" || kwLower == "camera" || kwLower == "cam")
                    {
                        isIntent = true;
                        sql += " AND ((p.CategoryId = 10 AND p.ProductName LIKE N'%Webcam%') OR (p.CategoryId = 12 AND p.ProductName LIKE N'%Camera%'))";
                    }
                    else if (kwLower == "tản nhiệt" || kwLower == "tan nhiet" || kwLower == "cooler" || kwLower == "aio")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 11)";
                    }
                    else if (kwLower == "đồng hồ" || kwLower == "dong ho" || kwLower == "watch" || kwLower == "smartwatch")
                    {
                        isIntent = true;
                        sql += " AND (p.CategoryId = 14)";
                    }
                    else
                    {
                        sql += " AND (p.ProductName LIKE @kw OR p.ProductCode LIKE @kw OR p.Brand LIKE @kw OR p.Specifications LIKE @kw OR c.CategoryName LIKE @kw)";
                    }
                }

                if (!string.IsNullOrWhiteSpace(brand))
                    sql += " AND p.Brand = @brand";

                if (!string.IsNullOrWhiteSpace(priceRange))
                {
                    if (priceRange == "under10")
                        sql += " AND p.Price < 10000000";
                    else if (priceRange == "10to20")
                        sql += " AND p.Price >= 10000000 AND p.Price <= 20000000";
                    else if (priceRange == "20to30")
                        sql += " AND p.Price > 20000000 AND p.Price <= 30000000";
                    else if (priceRange == "over30")
                        sql += " AND p.Price > 30000000";
                }

                if (sortBy == "price_asc")
                    sql += " ORDER BY p.Price ASC";
                else if (sortBy == "price_desc")
                    sql += " ORDER BY p.Price DESC";
                else if (sortBy == "newest")
                    sql += " ORDER BY p.CreatedAt DESC, p.ProductId DESC";
                else
                {
                    if (!string.IsNullOrWhiteSpace(kwLower) && !isIntent)
                    {
                        sql += @" ORDER BY 
                            (CASE 
                                WHEN p.ProductName LIKE @kwStart THEN 100
                                WHEN p.ProductName LIKE @kw THEN 80
                                WHEN p.Brand LIKE @kw THEN 60
                                WHEN c.CategoryName LIKE @kw THEN 50
                                WHEN p.ProductCode LIKE @kw THEN 40
                                ELSE 20
                             END) DESC, p.SoldCount DESC, p.ProductId ASC";
                    }
                    else
                    {
                        sql += " ORDER BY p.SoldCount DESC, p.ProductId ASC";
                    }
                }

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (categoryId.HasValue && categoryId.Value > 0)
                        cmd.Parameters.AddWithValue("@catId", categoryId.Value);
                    if (!string.IsNullOrWhiteSpace(keyword) && !isIntent)
                    {
                        cmd.Parameters.AddWithValue("@kw", "%" + keyword.Trim() + "%");
                        cmd.Parameters.AddWithValue("@kwStart", keyword.Trim() + "%");
                    }
                    if (!string.IsNullOrWhiteSpace(brand))
                        cmd.Parameters.AddWithValue("@brand", brand.Trim());

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read()) list.Add(MapProduct(r));
                    }
                }
            }
            return list;
        }

        public static List<string> GetAllBrands()
        {
            List<string> brands = new List<string>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT DISTINCT Brand FROM dbo.SANPHAM WHERE Status = N'Đang kinh doanh' ORDER BY Brand ASC", conn))
                {
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            brands.Add(Convert.ToString(r["Brand"]));
                        }
                    }
                }
            }
            return brands;
        }

        public static ProductInfo GetProductById(int productId)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT p.*, c.CategoryName
                               FROM dbo.SANPHAM p
                               INNER JOIN dbo.DANHMUC c ON p.CategoryId = c.CategoryId
                               WHERE p.ProductId = @id";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", productId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read()) return MapProduct(r);
                    }
                }
            }
            return null;
        }

        public static List<ProductInfo> GetRelatedProducts(int categoryId, int excludeProductId, int top)
        {
            List<ProductInfo> list = new List<ProductInfo>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = string.Format(@"SELECT TOP {0} p.*, c.CategoryName
                               FROM dbo.SANPHAM p
                               INNER JOIN dbo.DANHMUC c ON p.CategoryId = c.CategoryId
                               WHERE p.CategoryId = @catId AND p.ProductId <> @exId AND p.Status = N'Đang kinh doanh'
                               ORDER BY p.SoldCount DESC", top);
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@catId", categoryId);
                    cmd.Parameters.AddWithValue("@exId", excludeProductId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read()) list.Add(MapProduct(r));
                    }
                }
            }
            return list;
        }

        public static bool AdminSaveProduct(ProductInfo p, out string errorMsg)
        {
            errorMsg = "";
            if (p == null || string.IsNullOrWhiteSpace(p.ProductCode) || string.IsNullOrWhiteSpace(p.ProductName))
            {
                errorMsg = "Mã sản phẩm và Tên sản phẩm không được để trống.";
                return false;
            }

            if (p.Price < 0 || p.StockQuantity < 0)
            {
                errorMsg = "Giá bán và Số lượng tồn kho không được nhỏ hơn 0.";
                return false;
            }

            if (p.OldPrice < p.Price)
                p.OldPrice = p.Price;

            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM dbo.SANPHAM WHERE ProductCode = @code AND ProductId <> @id", conn))
                {
                    chk.Parameters.AddWithValue("@code", p.ProductCode.Trim());
                    chk.Parameters.AddWithValue("@id", p.ProductId);
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                    {
                        errorMsg = "Mã sản phẩm '" + p.ProductCode + "' đã tồn tại trên hệ thống!";
                        return false;
                    }
                }

                if (p.ProductId <= 0)
                {
                    string ins = @"INSERT INTO dbo.SANPHAM (
                                       ProductCode, ProductName, CategoryId, Brand, OldPrice, Price, StockQuantity,
                                       WarrantyMonths, ImageUrl, Specifications, Description, PromoCount, IsDeal, Status
                                   ) VALUES (
                                       @code, @name, @cat, @brand, @oldP, @price, @stock,
                                       @war, @img, @spec, @desc, @promo, @deal, @status
                                   )";
                    using (SqlCommand cmd = new SqlCommand(ins, conn))
                    {
                        cmd.Parameters.AddWithValue("@code", p.ProductCode.Trim());
                        cmd.Parameters.AddWithValue("@name", p.ProductName.Trim());
                        cmd.Parameters.AddWithValue("@cat", p.CategoryId);
                        cmd.Parameters.AddWithValue("@brand", string.IsNullOrWhiteSpace(p.Brand) ? "PCM" : p.Brand.Trim());
                        cmd.Parameters.AddWithValue("@oldP", p.OldPrice);
                        cmd.Parameters.AddWithValue("@price", p.Price);
                        cmd.Parameters.AddWithValue("@stock", p.StockQuantity);
                        cmd.Parameters.AddWithValue("@war", p.WarrantyMonths > 0 ? p.WarrantyMonths : 24);
                        cmd.Parameters.AddWithValue("@img", string.IsNullOrWhiteSpace(p.ImageUrl) ? "./anh pc/pc1.png" : p.ImageUrl.Trim());
                        cmd.Parameters.AddWithValue("@spec", (p.Specifications ?? "").Trim());
                        cmd.Parameters.AddWithValue("@desc", (p.Description ?? "").Trim());
                        cmd.Parameters.AddWithValue("@promo", p.PromoCount > 0 ? p.PromoCount : 2);
                        cmd.Parameters.AddWithValue("@deal", p.IsDeal);
                        cmd.Parameters.AddWithValue("@status", string.IsNullOrWhiteSpace(p.Status) ? "Đang kinh doanh" : p.Status);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    string upd = @"UPDATE dbo.SANPHAM
                                   SET ProductCode = @code, ProductName = @name, CategoryId = @cat, Brand = @brand,
                                       OldPrice = @oldP, Price = @price, StockQuantity = @stock, WarrantyMonths = @war,
                                       ImageUrl = @img, Specifications = @spec, Description = @desc, IsDeal = @deal, Status = @status
                                   WHERE ProductId = @id";
                    using (SqlCommand cmd = new SqlCommand(upd, conn))
                    {
                        cmd.Parameters.AddWithValue("@code", p.ProductCode.Trim());
                        cmd.Parameters.AddWithValue("@name", p.ProductName.Trim());
                        cmd.Parameters.AddWithValue("@cat", p.CategoryId);
                        cmd.Parameters.AddWithValue("@brand", string.IsNullOrWhiteSpace(p.Brand) ? "PCM" : p.Brand.Trim());
                        cmd.Parameters.AddWithValue("@oldP", p.OldPrice);
                        cmd.Parameters.AddWithValue("@price", p.Price);
                        cmd.Parameters.AddWithValue("@stock", p.StockQuantity);
                        cmd.Parameters.AddWithValue("@war", p.WarrantyMonths > 0 ? p.WarrantyMonths : 24);
                        cmd.Parameters.AddWithValue("@img", string.IsNullOrWhiteSpace(p.ImageUrl) ? "./anh pc/pc1.png" : p.ImageUrl.Trim());
                        cmd.Parameters.AddWithValue("@spec", (p.Specifications ?? "").Trim());
                        cmd.Parameters.AddWithValue("@desc", (p.Description ?? "").Trim());
                        cmd.Parameters.AddWithValue("@deal", p.IsDeal);
                        cmd.Parameters.AddWithValue("@status", string.IsNullOrWhiteSpace(p.Status) ? "Đang kinh doanh" : p.Status);
                        cmd.Parameters.AddWithValue("@id", p.ProductId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            return true;
        }

        public static bool StaffUpdateProduct(int productId, decimal price, int stockQuantity, int warrantyMonths, string specifications, string description, out string errorMsg)
        {
            errorMsg = "";
            if (price < 0 || stockQuantity < 0)
            {
                errorMsg = "Giá bán và Số lượng tồn kho không hợp lệ.";
                return false;
            }

            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"UPDATE dbo.SANPHAM
                               SET Price = @price, StockQuantity = @stock, WarrantyMonths = @war,
                                   Specifications = @spec, Description = @desc
                               WHERE ProductId = @id";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@price", price);
                    cmd.Parameters.AddWithValue("@stock", stockQuantity);
                    cmd.Parameters.AddWithValue("@war", warrantyMonths > 0 ? warrantyMonths : 24);
                    cmd.Parameters.AddWithValue("@spec", (specifications ?? "").Trim());
                    cmd.Parameters.AddWithValue("@desc", (description ?? "").Trim());
                    cmd.Parameters.AddWithValue("@id", productId);
                    cmd.ExecuteNonQuery();
                }
            }
            return true;
        }

        public static bool AdminDeleteProduct(int productId, out string message, out bool softDeleted)
        {
            message = "";
            softDeleted = false;
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                // Ngoại lệ UC09: Nếu sản phẩm đã từng phát sinh trong hóa đơn bán hàng (OrderDetails),
                // chuyển sang trạng thái 'Ngừng kinh doanh' thay vì xóa cứng để bảo toàn lịch sử đơn hàng.
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM dbo.CHITIETDONHANG WHERE ProductId = @id", conn))
                {
                    chk.Parameters.AddWithValue("@id", productId);
                    int orderRefCount = Convert.ToInt32(chk.ExecuteScalar());
                    if (orderRefCount > 0)
                    {
                        using (SqlCommand softCmd = new SqlCommand("UPDATE dbo.SANPHAM SET Status = N'Ngừng kinh doanh' WHERE ProductId = @id", conn))
                        {
                            softCmd.Parameters.AddWithValue("@id", productId);
                            softCmd.ExecuteNonQuery();
                        }
                        softDeleted = true;
                        message = "Cảnh báo: Sản phẩm này đã từng phát sinh trong hóa đơn bán hàng. Hệ thống đã chuyển sang trạng thái 'Ngừng kinh doanh' thay vì xóa cứng để bảo toàn lịch sử đơn hàng!";
                        return true;
                    }
                }

                using (SqlCommand delCmd = new SqlCommand("DELETE FROM dbo.SANPHAM WHERE ProductId = @id", conn))
                {
                    delCmd.Parameters.AddWithValue("@id", productId);
                    delCmd.ExecuteNonQuery();
                }
                message = "Đã xóa hoàn toàn sản phẩm khỏi hệ thống.";
                return true;
            }
        }

        private static ProductInfo MapProduct(SqlDataReader r)
        {
            ProductInfo p = new ProductInfo();
            p.ProductId = Convert.ToInt32(r["ProductId"]);
            p.ProductCode = Convert.ToString(r["ProductCode"]);
            p.ProductName = Convert.ToString(r["ProductName"]);
            p.CategoryId = Convert.ToInt32(r["CategoryId"]);
            p.CategoryName = r["CategoryName"] != DBNull.Value ? Convert.ToString(r["CategoryName"]) : "";
            p.Brand = Convert.ToString(r["Brand"]);
            p.OldPrice = Convert.ToDecimal(r["OldPrice"]);
            p.Price = Convert.ToDecimal(r["Price"]);
            p.StockQuantity = Convert.ToInt32(r["StockQuantity"]);
            p.WarrantyMonths = Convert.ToInt32(r["WarrantyMonths"]);
            p.ImageUrl = LocalizeAssetPath(Convert.ToString(r["ImageUrl"]));
            p.Specifications = r["Specifications"] != DBNull.Value ? Convert.ToString(r["Specifications"]) : "";
            p.Description = r["Description"] != DBNull.Value ? Convert.ToString(r["Description"]) : "";
            p.PromoCount = Convert.ToInt32(r["PromoCount"]);
            p.IsDeal = Convert.ToBoolean(r["IsDeal"]);
            p.SoldCount = Convert.ToInt32(r["SoldCount"]);
            p.Status = Convert.ToString(r["Status"]);
            p.CreatedAt = Convert.ToDateTime(r["CreatedAt"]);
            return p;
        }

        // ====================================================================
        // 4. KHUYẾN MÃI VÀ MÃ GIẢM GIÁ (UC13, UC16)
        // ====================================================================
        public static List<PromotionInfo> GetAllPromotions(bool activeOnly)
        {
            List<PromotionInfo> list = new List<PromotionInfo>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = "SELECT * FROM dbo.KHUYENMAI";
                if (activeOnly)
                    sql += " WHERE IsActive = 1 AND EndDate >= GETDATE()";
                sql += " ORDER BY PromotionId DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read()) list.Add(MapPromotion(r));
                    }
                }
            }
            return list;
        }

        public static VoucherCheckResult ValidateVoucher(string voucherCode, decimal orderSubTotal)
        {
            VoucherCheckResult res = new VoucherCheckResult();
            res.IsValid = false;
            res.DiscountAmount = 0;

            if (string.IsNullOrWhiteSpace(voucherCode))
            {
                res.Message = "Vui lòng nhập mã giảm giá.";
                return res;
            }

            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = "SELECT TOP 1 * FROM dbo.KHUYENMAI WHERE VoucherCode = @code";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@code", voucherCode.Trim().ToUpper());
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            res.Message = "Mã khuyến mãi không tồn tại trên hệ thống.";
                            return res;
                        }

                        PromotionInfo promo = MapPromotion(r);
                        if (!promo.IsActive)
                        {
                            res.Message = "Mã khuyến mãi này đã ngừng áp dụng.";
                            return res;
                        }

                        DateTime now = DateTime.Now;
                        if (now < promo.StartDate)
                        {
                            res.Message = string.Format("Mã khuyến mãi chưa tới thời gian áp dụng (Bắt đầu từ {0:dd/MM/yyyy}).", promo.StartDate);
                            return res;
                        }

                        if (now > promo.EndDate)
                        {
                            res.Message = string.Format("Mã khuyến mãi '{0}' đã hết hạn sử dụng từ ngày {1:dd/MM/yyyy}.", promo.VoucherCode, promo.EndDate);
                            return res;
                        }

                        if (promo.UsedCount >= promo.UsageLimit)
                        {
                            res.Message = "Mã khuyến mãi đã hết lượt sử dụng.";
                            return res;
                        }

                        if (orderSubTotal < promo.MinOrderAmount)
                        {
                            res.Message = string.Format("Đơn hàng chưa đạt giá trị tối thiểu {0} để áp dụng mã này.", SecurityHelper.FormatCurrency(promo.MinOrderAmount));
                            return res;
                        }

                        decimal discount = 0;
                        if (promo.DiscountType == "PERCENT")
                        {
                            discount = Math.Round((orderSubTotal * promo.DiscountValue) / 100M);
                            if (promo.MaxDiscountAmount > 0 && discount > promo.MaxDiscountAmount)
                                discount = promo.MaxDiscountAmount;
                        }
                        else
                        {
                            discount = promo.DiscountValue;
                        }

                        if (discount > orderSubTotal)
                            discount = orderSubTotal;

                        res.IsValid = true;
                        res.DiscountAmount = discount;
                        res.Promotion = promo;
                        res.Message = string.Format("Áp dụng mã '{0}' thành công! Bạn được giảm {1}.", promo.VoucherCode, SecurityHelper.FormatCurrency(discount));
                        return res;
                    }
                }
            }
        }

        public static bool SavePromotion(PromotionInfo promo, out string errorMsg)
        {
            errorMsg = "";
            if (promo == null || string.IsNullOrWhiteSpace(promo.PromotionName) || string.IsNullOrWhiteSpace(promo.VoucherCode))
            {
                errorMsg = "Tên chương trình và Mã giảm giá không được để trống.";
                return false;
            }

            // Ngoại lệ UC13: Kiểm tra ngày kết thúc >= ngày bắt đầu và mức giảm hợp lệ
            if (promo.EndDate < promo.StartDate)
            {
                errorMsg = "Ngày kết thúc không được nhỏ hơn ngày bắt đầu!";
                return false;
            }

            if (promo.DiscountValue <= 0)
            {
                errorMsg = "Mức giảm giá phải lớn hơn 0!";
                return false;
            }

            if (promo.DiscountType == "PERCENT" && promo.DiscountValue > 100)
            {
                errorMsg = "Mức giảm theo phần trăm (%) không được vượt quá 100%!";
                return false;
            }

            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM dbo.KHUYENMAI WHERE VoucherCode = @code AND PromotionId <> @id", conn))
                {
                    chk.Parameters.AddWithValue("@code", promo.VoucherCode.Trim().ToUpper());
                    chk.Parameters.AddWithValue("@id", promo.PromotionId);
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                    {
                        errorMsg = "Mã giảm giá '" + promo.VoucherCode.ToUpper() + "' đã tồn tại!";
                        return false;
                    }
                }

                if (promo.PromotionId <= 0)
                {
                    string ins = @"INSERT INTO dbo.KHUYENMAI (
                                       PromotionName, VoucherCode, DiscountType, DiscountValue, MinOrderAmount,
                                       MaxDiscountAmount, UsageLimit, UsedCount, StartDate, EndDate, Description, IsActive
                                   ) VALUES (
                                       @name, @code, @type, @val, @min, @max, @limit, 0, @start, @end, @desc, @act
                                   )";
                    using (SqlCommand cmd = new SqlCommand(ins, conn))
                    {
                        cmd.Parameters.AddWithValue("@name", promo.PromotionName.Trim());
                        cmd.Parameters.AddWithValue("@code", promo.VoucherCode.Trim().ToUpper());
                        cmd.Parameters.AddWithValue("@type", promo.DiscountType);
                        cmd.Parameters.AddWithValue("@val", promo.DiscountValue);
                        cmd.Parameters.AddWithValue("@min", promo.MinOrderAmount);
                        cmd.Parameters.AddWithValue("@max", promo.MaxDiscountAmount);
                        cmd.Parameters.AddWithValue("@limit", promo.UsageLimit > 0 ? promo.UsageLimit : 100);
                        cmd.Parameters.AddWithValue("@start", promo.StartDate);
                        cmd.Parameters.AddWithValue("@end", promo.EndDate);
                        cmd.Parameters.AddWithValue("@desc", (promo.Description ?? "").Trim());
                        cmd.Parameters.AddWithValue("@act", promo.IsActive);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    string upd = @"UPDATE dbo.KHUYENMAI
                                   SET PromotionName = @name, VoucherCode = @code, DiscountType = @type, DiscountValue = @val,
                                       MinOrderAmount = @min, MaxDiscountAmount = @max, UsageLimit = @limit,
                                       StartDate = @start, EndDate = @end, Description = @desc, IsActive = @act
                                   WHERE PromotionId = @id";
                    using (SqlCommand cmd = new SqlCommand(upd, conn))
                    {
                        cmd.Parameters.AddWithValue("@name", promo.PromotionName.Trim());
                        cmd.Parameters.AddWithValue("@code", promo.VoucherCode.Trim().ToUpper());
                        cmd.Parameters.AddWithValue("@type", promo.DiscountType);
                        cmd.Parameters.AddWithValue("@val", promo.DiscountValue);
                        cmd.Parameters.AddWithValue("@min", promo.MinOrderAmount);
                        cmd.Parameters.AddWithValue("@max", promo.MaxDiscountAmount);
                        cmd.Parameters.AddWithValue("@limit", promo.UsageLimit > 0 ? promo.UsageLimit : 100);
                        cmd.Parameters.AddWithValue("@start", promo.StartDate);
                        cmd.Parameters.AddWithValue("@end", promo.EndDate);
                        cmd.Parameters.AddWithValue("@desc", (promo.Description ?? "").Trim());
                        cmd.Parameters.AddWithValue("@act", promo.IsActive);
                        cmd.Parameters.AddWithValue("@id", promo.PromotionId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            return true;
        }

        private static PromotionInfo MapPromotion(SqlDataReader r)
        {
            PromotionInfo p = new PromotionInfo();
            p.PromotionId = Convert.ToInt32(r["PromotionId"]);
            p.PromotionName = Convert.ToString(r["PromotionName"]);
            p.VoucherCode = Convert.ToString(r["VoucherCode"]);
            p.DiscountType = Convert.ToString(r["DiscountType"]);
            p.DiscountValue = Convert.ToDecimal(r["DiscountValue"]);
            p.MinOrderAmount = Convert.ToDecimal(r["MinOrderAmount"]);
            p.MaxDiscountAmount = Convert.ToDecimal(r["MaxDiscountAmount"]);
            p.UsageLimit = Convert.ToInt32(r["UsageLimit"]);
            p.UsedCount = Convert.ToInt32(r["UsedCount"]);
            p.StartDate = Convert.ToDateTime(r["StartDate"]);
            p.EndDate = Convert.ToDateTime(r["EndDate"]);
            p.Description = r["Description"] != DBNull.Value ? Convert.ToString(r["Description"]) : "";
            p.IsActive = Convert.ToBoolean(r["IsActive"]);
            return p;
        }

        // ====================================================================
        // 5. ĐƠN HÀNG VÀ THỐNG KÊ DOANH THU (UC07, UC08, UC11, UC14)
        // ====================================================================
        public static List<OrderInfo> GetOrdersByUser(int userId)
        {
            List<OrderInfo> list = new List<OrderInfo>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT o.*, u.Username AS CustomerUsername
                               FROM dbo.DONHANG o
                               INNER JOIN dbo.TAIKHOAN u ON o.UserId = u.UserId
                               WHERE o.UserId = @uid
                               ORDER BY o.OrderId DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            OrderInfo ord = MapOrder(r);
                            list.Add(ord);
                        }
                    }
                }

                for (int i = 0; i < list.Count; i++)
                {
                    list[i].Details = GetOrderDetails(conn, list[i].OrderId);
                }
            }
            return list;
        }

        public static List<OrderInfo> GetAllOrders(string statusFilter, string keyword)
        {
            List<OrderInfo> list = new List<OrderInfo>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT o.*, u.Username AS CustomerUsername
                               FROM dbo.DONHANG o
                               INNER JOIN dbo.TAIKHOAN u ON o.UserId = u.UserId
                               WHERE 1=1";
                if (!string.IsNullOrWhiteSpace(statusFilter))
                    sql += " AND o.OrderStatus = @st";
                if (!string.IsNullOrWhiteSpace(keyword))
                    sql += " AND (o.OrderCode LIKE @kw OR o.ReceiverName LIKE @kw OR o.ReceiverPhone LIKE @kw OR u.Username LIKE @kw)";
                sql += " ORDER BY o.OrderId DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(statusFilter))
                        cmd.Parameters.AddWithValue("@st", statusFilter.Trim());
                    if (!string.IsNullOrWhiteSpace(keyword))
                        cmd.Parameters.AddWithValue("@kw", "%" + keyword.Trim() + "%");

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            list.Add(MapOrder(r));
                        }
                    }
                }

                for (int i = 0; i < list.Count; i++)
                {
                    list[i].Details = GetOrderDetails(conn, list[i].OrderId);
                }
            }
            return list;
        }

        public static OrderInfo GetOrderById(int orderId)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT o.*, u.Username AS CustomerUsername
                               FROM dbo.DONHANG o
                               INNER JOIN dbo.TAIKHOAN u ON o.UserId = u.UserId
                               WHERE o.OrderId = @id";
                OrderInfo ord = null;
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", orderId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read()) ord = MapOrder(r);
                    }
                }

                if (ord != null)
                {
                    ord.Details = GetOrderDetails(conn, ord.OrderId);
                    ord.History = GetOrderHistory(conn, ord.OrderId);
                }
                return ord;
            }
        }

        private static List<OrderDetailInfo> GetOrderDetails(SqlConnection conn, int orderId)
        {
            List<OrderDetailInfo> details = new List<OrderDetailInfo>();
            string sql = "SELECT * FROM dbo.CHITIETDONHANG WHERE OrderId = @oid ORDER BY OrderDetailId ASC";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@oid", orderId);
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        OrderDetailInfo d = new OrderDetailInfo();
                        d.OrderDetailId = Convert.ToInt32(r["OrderDetailId"]);
                        d.OrderId = Convert.ToInt32(r["OrderId"]);
                        d.ProductId = Convert.ToInt32(r["ProductId"]);
                        d.ProductCode = Convert.ToString(r["ProductCode"]);
                        d.ProductName = Convert.ToString(r["ProductName"]);
                        d.ImageUrl = r["ImageUrl"] != DBNull.Value ? LocalizeAssetPath(Convert.ToString(r["ImageUrl"])) : "./anh pc/pc1.png";
                        d.UnitPrice = Convert.ToDecimal(r["UnitPrice"]);
                        d.Quantity = Convert.ToInt32(r["Quantity"]);
                        d.LineTotal = Convert.ToDecimal(r["LineTotal"]);
                        details.Add(d);
                    }
                }
            }
            return details;
        }

        private static List<OrderHistoryInfo> GetOrderHistory(SqlConnection conn, int orderId)
        {
            List<OrderHistoryInfo> list = new List<OrderHistoryInfo>();
            string sql = "SELECT * FROM dbo.LICHSUTRANGTHAIDONHANG WHERE OrderId = @oid ORDER BY HistoryId DESC";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@oid", orderId);
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        OrderHistoryInfo h = new OrderHistoryInfo();
                        h.HistoryId = Convert.ToInt32(r["HistoryId"]);
                        h.OrderId = Convert.ToInt32(r["OrderId"]);
                        h.Status = Convert.ToString(r["Status"]);
                        h.Note = r["Note"] != DBNull.Value ? Convert.ToString(r["Note"]) : "";
                        h.UpdatedBy = r["UpdatedBy"] != DBNull.Value ? Convert.ToString(r["UpdatedBy"]) : "";
                        h.UpdatedAt = Convert.ToDateTime(r["UpdatedAt"]);
                        list.Add(h);
                    }
                }
            }
            return list;
        }

        public static bool UpdateOrderStatus(int orderId, string newStatus, string updatedBy, string note, bool isCustomerAction, out string message)
        {
            message = "";
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                SqlTransaction tran = conn.BeginTransaction();
                try
                {
                    string currentStatus = "";
                    using (SqlCommand getCmd = new SqlCommand("SELECT OrderStatus FROM dbo.DONHANG WHERE OrderId = @id", conn, tran))
                    {
                        getCmd.Parameters.AddWithValue("@id", orderId);
                        object val = getCmd.ExecuteScalar();
                        if (val == null)
                        {
                            tran.Rollback();
                            message = "Không tìm thấy đơn hàng.";
                            return false;
                        }
                        currentStatus = Convert.ToString(val);
                    }

                    if (currentStatus == "Đã hủy")
                    {
                        tran.Rollback();
                        message = "Đơn hàng này đã bị hủy trước đó, không thể cập nhật trạng thái.";
                        return false;
                    }

                    if (currentStatus == "Đã giao" && newStatus != "Đã giao")
                    {
                        tran.Rollback();
                        message = "Đơn hàng đã giao thành công, không thể thay đổi trạng thái.";
                        return false;
                    }

                    // Ngoại lệ UC08 & UC11: Chỉ cho phép hủy đơn khi ở trạng thái Chờ xác nhận hoặc Đang chờ vận chuyển
                    if (newStatus == "Đã hủy")
                    {
                        if (isCustomerAction && currentStatus != "Chờ xác nhận" && currentStatus != "Đang chờ vận chuyển")
                        {
                            tran.Rollback();
                            message = "Đơn hàng đã được bàn giao vận chuyển nên không thể hủy trực tiếp!";
                            return false;
                        }
                        if (!isCustomerAction && currentStatus != "Chờ xác nhận" && currentStatus != "Đang chờ vận chuyển")
                        {
                            tran.Rollback();
                            message = "Theo quy định (UC11), chỉ có thể hủy đơn khi đang ở trạng thái 'Chờ xác nhận' hoặc 'Đang chờ vận chuyển'!";
                            return false;
                        }

                        // Tự động hoàn trả số lượng tồn kho cho tất cả sản phẩm trong đơn
                        List<OrderDetailInfo> items = new List<OrderDetailInfo>();
                        using (SqlCommand dCmd = new SqlCommand("SELECT ProductId, Quantity FROM dbo.CHITIETDONHANG WHERE OrderId = @id", conn, tran))
                        {
                            dCmd.Parameters.AddWithValue("@id", orderId);
                            using (SqlDataReader r = dCmd.ExecuteReader())
                            {
                                while (r.Read())
                                {
                                    OrderDetailInfo di = new OrderDetailInfo();
                                    di.ProductId = Convert.ToInt32(r["ProductId"]);
                                    di.Quantity = Convert.ToInt32(r["Quantity"]);
                                    items.Add(di);
                                }
                            }
                        }

                        for (int i = 0; i < items.Count; i++)
                        {
                            string restoreSql = @"UPDATE dbo.SANPHAM
                                                  SET StockQuantity = StockQuantity + @qty,
                                                      SoldCount = CASE WHEN SoldCount >= @qty THEN SoldCount - @qty ELSE 0 END
                                                  WHERE ProductId = @pid";
                            using (SqlCommand rCmd = new SqlCommand(restoreSql, conn, tran))
                            {
                                rCmd.Parameters.AddWithValue("@qty", items[i].Quantity);
                                rCmd.Parameters.AddWithValue("@pid", items[i].ProductId);
                                rCmd.ExecuteNonQuery();
                            }
                        }
                    }

                    using (SqlCommand updCmd = new SqlCommand("UPDATE dbo.DONHANG SET OrderStatus = @st, UpdatedAt = GETDATE() WHERE OrderId = @id", conn, tran))
                    {
                        updCmd.Parameters.AddWithValue("@st", newStatus);
                        updCmd.Parameters.AddWithValue("@id", orderId);
                        updCmd.ExecuteNonQuery();
                    }

                    using (SqlCommand histCmd = new SqlCommand("INSERT INTO dbo.LICHSUTRANGTHAIDONHANG (OrderId, Status, Note, UpdatedBy) VALUES (@id, @st, @note, @by)", conn, tran))
                    {
                        histCmd.Parameters.AddWithValue("@id", orderId);
                        histCmd.Parameters.AddWithValue("@st", newStatus);
                        histCmd.Parameters.AddWithValue("@note", string.IsNullOrWhiteSpace(note) ? ("Cập nhật trạng thái sang " + newStatus) : note.Trim());
                        histCmd.Parameters.AddWithValue("@by", string.IsNullOrWhiteSpace(updatedBy) ? "system" : updatedBy);
                        histCmd.ExecuteNonQuery();
                    }

                    tran.Commit();
                    if (newStatus == "Đã hủy")
                        message = "Đã hủy đơn hàng và tự động hoàn trả số lượng tồn kho cho các sản phẩm trong đơn!";
                    else
                        message = "Cập nhật trạng thái đơn hàng sang '" + newStatus + "' thành công!";
                    return true;
                }
                catch (Exception ex)
                {
                    tran.Rollback();
                    message = "Lỗi khi cập nhật đơn hàng: " + ex.Message;
                    return false;
                }
            }
        }

        public static RevenueStats GetRevenueStatistics(DateTime? fromDate, DateTime? toDate)
        {
            RevenueStats stats = new RevenueStats();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string dateFilter = "";
                if (fromDate.HasValue)
                    dateFilter += " AND CreatedAt >= @from";
                if (toDate.HasValue)
                    dateFilter += " AND CreatedAt <= @to";

                // Doanh thu thực tế tính từ các đơn hàng có trạng thái 'Đã giao' (UC14)
                string sql = string.Format(@"
                    SELECT
                        ISNULL(SUM(CASE WHEN OrderStatus = N'Đã giao' THEN TotalAmount ELSE 0 END), 0) AS TotalRevenue,
                        COUNT(*) AS TotalOrders,
                        ISNULL(SUM(CASE WHEN OrderStatus = N'Đã giao' THEN 1 ELSE 0 END), 0) AS DeliveredOrders,
                        ISNULL(SUM(CASE WHEN OrderStatus IN (N'Chờ xác nhận', N'Đang chờ vận chuyển') THEN 1 ELSE 0 END), 0) AS PendingOrders,
                        ISNULL(SUM(CASE WHEN OrderStatus IN (N'Đang vận chuyển', N'Đang giao') THEN 1 ELSE 0 END), 0) AS ShippingOrders,
                        ISNULL(SUM(CASE WHEN OrderStatus = N'Đã hủy' THEN 1 ELSE 0 END), 0) AS CancelledOrders
                    FROM dbo.DONHANG
                    WHERE 1=1 {0}", dateFilter);

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (fromDate.HasValue) cmd.Parameters.AddWithValue("@from", fromDate.Value);
                    if (toDate.HasValue) cmd.Parameters.AddWithValue("@to", toDate.Value);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            stats.TotalRevenue = Convert.ToDecimal(r["TotalRevenue"]);
                            stats.TotalOrders = Convert.ToInt32(r["TotalOrders"]);
                            stats.DeliveredOrders = Convert.ToInt32(r["DeliveredOrders"]);
                            stats.PendingOrders = Convert.ToInt32(r["PendingOrders"]);
                            stats.ShippingOrders = Convert.ToInt32(r["ShippingOrders"]);
                            stats.CancelledOrders = Convert.ToInt32(r["CancelledOrders"]);
                        }
                    }
                }

                using (SqlCommand lowCmd = new SqlCommand("SELECT COUNT(*) FROM dbo.SANPHAM WHERE Status = N'Đang kinh doanh' AND StockQuantity <= 5", conn))
                {
                    stats.LowStockCount = Convert.ToInt32(lowCmd.ExecuteScalar());
                }
            }
            return stats;
        }

        public static List<ProductInfo> GetLowStockProducts(int threshold)
        {
            List<ProductInfo> list = new List<ProductInfo>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"SELECT p.*, c.CategoryName
                               FROM dbo.SANPHAM p
                               INNER JOIN dbo.DANHMUC c ON p.CategoryId = c.CategoryId
                               WHERE p.Status = N'Đang kinh doanh' AND p.StockQuantity <= @th
                               ORDER BY p.StockQuantity ASC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@th", threshold);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read()) list.Add(MapProduct(r));
                    }
                }
            }
            return list;
        }

        public static List<DailyRevenueItem> GetRevenueTimeline(DateTime? fromDate, DateTime? toDate)
        {
            List<DailyRevenueItem> list = new List<DailyRevenueItem>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT 
                        CONVERT(VARCHAR(10), CreatedAt, 120) AS DayDate,
                        ISNULL(SUM(CASE WHEN OrderStatus = N'Đã giao' THEN TotalAmount ELSE 0 END), 0) AS Revenue,
                        COUNT(*) AS OrderCount
                    FROM dbo.DONHANG
                    WHERE 1=1";
                if (fromDate.HasValue) sql += " AND CreatedAt >= @from";
                if (toDate.HasValue) sql += " AND CreatedAt <= @to";
                sql += @" GROUP BY CONVERT(VARCHAR(10), CreatedAt, 120)
                          ORDER BY DayDate ASC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (fromDate.HasValue) cmd.Parameters.AddWithValue("@from", fromDate.Value);
                    if (toDate.HasValue) cmd.Parameters.AddWithValue("@to", toDate.Value);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            DailyRevenueItem item = new DailyRevenueItem();
                            string dStr = Convert.ToString(r["DayDate"]);
                            DateTime dt;
                            if (DateTime.TryParse(dStr, out dt))
                                item.DateLabel = dt.ToString("dd/MM");
                            else
                                item.DateLabel = dStr;
                            item.Revenue = Convert.ToDecimal(r["Revenue"]);
                            item.OrderCount = Convert.ToInt32(r["OrderCount"]);
                            list.Add(item);
                        }
                    }
                }
            }
            return list;
        }

        public static List<CategoryRevenueItem> GetCategoryRevenueBreakdown()
        {
            List<CategoryRevenueItem> list = new List<CategoryRevenueItem>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT 
                        c.CategoryName,
                        ISNULL(SUM(od.LineTotal), 0) AS TotalRevenue,
                        ISNULL(SUM(od.Quantity), 0) AS TotalSold
                    FROM dbo.DANHMUC c
                    LEFT JOIN dbo.SANPHAM p ON c.CategoryId = p.CategoryId
                    LEFT JOIN dbo.CHITIETDONHANG od ON p.ProductId = od.ProductId
                    GROUP BY c.CategoryName
                    HAVING ISNULL(SUM(od.Quantity), 0) > 0 OR c.CategoryName IN (N'Laptop Gaming - Đồ Họa', N'PC Gaming - Học Tập', N'Linh Kiện Máy Tính', N'Màn Hình, Máy In', N'Laptop - Máy Tính Xách Tay')
                    ORDER BY TotalRevenue DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            CategoryRevenueItem item = new CategoryRevenueItem();
                            item.CategoryName = Convert.ToString(r["CategoryName"]);
                            item.TotalRevenue = Convert.ToDecimal(r["TotalRevenue"]);
                            item.TotalSold = Convert.ToInt32(r["TotalSold"]);
                            list.Add(item);
                        }
                    }
                }
            }
            return list;
        }

        public static List<OrderStatusItem> GetOrderStatusDistribution()
        {
            List<OrderStatusItem> list = new List<OrderStatusItem>();
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT 
                        OrderStatus,
                        COUNT(*) AS Cnt,
                        ISNULL(SUM(TotalAmount), 0) AS TotalAmt
                    FROM dbo.DONHANG
                    GROUP BY OrderStatus
                    ORDER BY Cnt DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            OrderStatusItem item = new OrderStatusItem();
                            item.StatusName = Convert.ToString(r["OrderStatus"]);
                            item.Count = Convert.ToInt32(r["Cnt"]);
                            item.TotalAmount = Convert.ToDecimal(r["TotalAmt"]);
                            if (item.StatusName == "Đã giao") item.ColorHex = "#10b981";
                            else if (item.StatusName == "Đang giao" || item.StatusName == "Đang vận chuyển") item.ColorHex = "#3b82f6";
                            else if (item.StatusName == "Đang chờ vận chuyển") item.ColorHex = "#06b6d4";
                            else if (item.StatusName == "Chờ xác nhận") item.ColorHex = "#f59e0b";
                            else if (item.StatusName == "Đã hủy") item.ColorHex = "#ef4444";
                            else item.ColorHex = "#6b7280";
                            list.Add(item);
                        }
                    }
                }
            }
            return list;
        }

        public static void SaveContact(string fullName, string phone, string email, string title, string content)
        {
            using (SqlConnection conn = GetConnection())
            {
                conn.Open();
                string sql = @"INSERT INTO dbo.LIENHE (FullName, Phone, Email, Title, Content)
                               VALUES (@fn, @ph, @em, @ti, @co)";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@fn", (fullName ?? "").Trim());
                    cmd.Parameters.AddWithValue("@ph", (phone ?? "").Trim());
                    cmd.Parameters.AddWithValue("@em", (email ?? "").Trim());
                    cmd.Parameters.AddWithValue("@ti", (title ?? "").Trim());
                    cmd.Parameters.AddWithValue("@co", (content ?? "").Trim());
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private static OrderInfo MapOrder(SqlDataReader r)
        {
            OrderInfo o = new OrderInfo();
            o.OrderId = Convert.ToInt32(r["OrderId"]);
            o.OrderCode = Convert.ToString(r["OrderCode"]);
            o.UserId = Convert.ToInt32(r["UserId"]);
            o.CustomerUsername = r["CustomerUsername"] != DBNull.Value ? Convert.ToString(r["CustomerUsername"]) : "";
            o.ReceiverName = Convert.ToString(r["ReceiverName"]);
            o.ReceiverPhone = Convert.ToString(r["ReceiverPhone"]);
            o.ShippingAddress = Convert.ToString(r["ShippingAddress"]);
            o.Note = r["Note"] != DBNull.Value ? Convert.ToString(r["Note"]) : "";
            o.PaymentMethod = Convert.ToString(r["PaymentMethod"]);
            o.SubTotal = Convert.ToDecimal(r["SubTotal"]);
            o.VoucherCode = r["VoucherCode"] != DBNull.Value ? Convert.ToString(r["VoucherCode"]) : "";
            o.DiscountAmount = Convert.ToDecimal(r["DiscountAmount"]);
            o.TotalAmount = Convert.ToDecimal(r["TotalAmount"]);
            o.OrderStatus = Convert.ToString(r["OrderStatus"]);
            o.CreatedAt = Convert.ToDateTime(r["CreatedAt"]);
            o.UpdatedAt = Convert.ToDateTime(r["UpdatedAt"]);
            return o;
        }
    }
}
