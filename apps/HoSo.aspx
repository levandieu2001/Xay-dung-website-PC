<%@ Page Language="C#" MasterPageFile="~/BoCucChung.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    protected UserInfo CurrentUser = null;
    protected string AlertMessage = "";
    protected bool IsAlertSuccess = true;

    protected void Page_Load(object sender, EventArgs e)
    {
        CurrentUser = SecurityHelper.GetCurrentUser();
        if (CurrentUser == null)
        {
            Response.Redirect("DangNhap.aspx?returnUrl=HoSo.aspx");
            return;
        }

        if (IsPostBack)
        {
            string action = Request.Form["profileAction"];
            if (action == "update_info")
            {
                string fn = (Request.Form["FullName"] ?? "").Trim();
                string em = (Request.Form["Email"] ?? "").Trim();
                string ph = (Request.Form["Phone"] ?? "").Trim();
                string ad = (Request.Form["Address"] ?? "").Trim();

                string err;
                if (DbHelper.UpdateUserProfile(CurrentUser.UserId, fn, em, ph, ad, out err))
                {
                    CurrentUser = DbHelper.GetUserById(CurrentUser.UserId);
                    SecurityHelper.SetCurrentUser(CurrentUser);
                    IsAlertSuccess = true;
                    AlertMessage = "Cập nhật thông tin hồ sơ cá nhân thành công!";
                }
                else
                {
                    IsAlertSuccess = false;
                    AlertMessage = err;
                }
            }
            else if (action == "change_password")
            {
                string oldPw = Request.Form["OldPassword"] ?? "";
                string newPw = Request.Form["NewPassword"] ?? "";
                string confirmPw = Request.Form["ConfirmNewPassword"] ?? "";

                if (newPw != confirmPw)
                {
                    IsAlertSuccess = false;
                    AlertMessage = "Mật khẩu mới và xác nhận mật khẩu không khớp!";
                }
                else
                {
                    string err;
                    if (DbHelper.ChangePassword(CurrentUser.UserId, oldPw, newPw, out err))
                    {
                        CurrentUser = DbHelper.GetUserById(CurrentUser.UserId);
                        SecurityHelper.SetCurrentUser(CurrentUser);
                        IsAlertSuccess = true;
                        AlertMessage = "Đổi mật khẩu tài khoản thành công!";
                    }
                    else
                    {
                        IsAlertSuccess = false;
                        AlertMessage = err;
                    }
                }
            }
        }
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="pcm-page-card">
            <div class="breadcrumb">
                <a href="TrangChu.aspx"><i class="fa-solid fa-house"></i> Trang chủ</a> /
                <span>Quản lý hồ sơ cá nhân (UC15)</span>
            </div>

            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; margin-bottom:14px;">
                <h1 class="pcm-page-title" style="margin-bottom:0;">
                    <i class="fa-solid fa-id-card"></i> HỒ SƠ CÁ NHÂN &amp; BẢO MẬT TÀI KHOẢN (UC15)
                </h1>
                <div style="display:flex; gap:10px;">
                    <a href="DonHangCuaToi.aspx" class="btn-pcm btn-pcm-primary">
                        <i class="fa-solid fa-box-open"></i> Đơn hàng của tôi (UC08)
                    </a>
                    <a href="DangXuat.aspx" class="btn-pcm btn-pcm-danger">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất an toàn
                    </a>
                </div>
            </div>

            <% if (!string.IsNullOrEmpty(AlertMessage)) { %>
                <div class="pcm-alert <%= (IsAlertSuccess ? "pcm-alert-success" : "pcm-alert-error") %>">
                    <i class="fa-solid <%= (IsAlertSuccess ? "fa-circle-check" : "fa-triangle-exclamation") %>"></i>
                    <%= HttpUtility.HtmlEncode(AlertMessage) %>
                </div>
            <% } %>

            <input type="hidden" id="profileAction" name="profileAction" value="update_info" />

            <div style="display:flex; gap:30px; flex-wrap:wrap; margin-top:10px;">
                <!-- Cập nhật thông tin cá nhân -->
                <div style="flex:1.1; min-width:300px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; padding:20px;">
                    <h3 style="color:#3D52BF; font-size:17px; margin-bottom:16px; border-bottom:1px solid #e2e8f0; padding-bottom:10px;">
                        <i class="fa-solid fa-user-pen"></i> THÔNG TIN TÀI KHOẢN
                    </h3>

                    <div class="form-group">
                        <label>Tên đăng nhập &amp; Vai trò phân quyền</label>
                        <input type="text" class="form-control" disabled="disabled"
                               style="background:#e2e8f0; color:#475569; font-weight:700;"
                               value="<%= HttpUtility.HtmlAttributeEncode(CurrentUser.Username + " (" + SecurityHelper.GetRoleLabel(CurrentUser.Role) + ")") %>" />
                    </div>

                    <div class="form-group">
                        <label>Họ và tên <span style="color:red;">*</span></label>
                        <input type="text" name="FullName" class="form-control"
                               value="<%= HttpUtility.HtmlAttributeEncode(CurrentUser.FullName) %>" />
                    </div>

                    <div class="form-group">
                        <label>Địa chỉ Email <span style="color:red;">*</span></label>
                        <input type="text" name="Email" class="form-control"
                               value="<%= HttpUtility.HtmlAttributeEncode(CurrentUser.Email) %>" />
                    </div>

                    <div class="form-group">
                        <label>Số điện thoại <span style="color:red;">*</span></label>
                        <input type="text" name="Phone" class="form-control"
                               value="<%= HttpUtility.HtmlAttributeEncode(CurrentUser.Phone) %>" />
                    </div>

                    <div class="form-group">
                        <label>Địa chỉ giao hàng mặc định</label>
                        <input type="text" name="Address" class="form-control"
                               value="<%= HttpUtility.HtmlAttributeEncode(CurrentUser.Address) %>" />
                    </div>

                    <button type="submit" class="btn-pcm btn-pcm-primary" style="height:42px; padding:0 24px;"
                            onclick="document.getElementById('profileAction').value='update_info';">
                        <i class="fa-solid fa-floppy-disk"></i> LƯU THAY ĐỔI HỒ SƠ
                    </button>
                </div>

                <!-- Đổi mật khẩu -->
                <div style="flex:1; min-width:300px; background:#fff; border:1px solid #e2e8f0; border-radius:10px; padding:20px;">
                    <h3 style="color:#3D52BF; font-size:17px; margin-bottom:16px; border-bottom:1px solid #e2e8f0; padding-bottom:10px;">
                        <i class="fa-solid fa-key"></i> ĐỔI MẬT KHẨU BẢO MẬT
                    </h3>

                    <div class="form-group">
                        <label>Mật khẩu hiện tại <span style="color:red;">*</span></label>
                        <input type="password" name="OldPassword" class="form-control"
                               placeholder="Nhập mật khẩu đang sử dụng" />
                    </div>

                    <div class="form-group">
                        <label>Mật khẩu mới (tối thiểu 6 ký tự) <span style="color:red;">*</span></label>
                        <input type="password" name="NewPassword" class="form-control"
                               placeholder="Nhập mật khẩu mới" />
                    </div>

                    <div class="form-group">
                        <label>Xác nhận mật khẩu mới <span style="color:red;">*</span></label>
                        <input type="password" name="ConfirmNewPassword" class="form-control"
                               placeholder="Nhập lại mật khẩu mới" />
                    </div>

                    <button type="submit" class="btn-pcm btn-pcm-danger" style="height:42px; padding:0 24px;"
                            onclick="document.getElementById('profileAction').value='change_password';">
                        <i class="fa-solid fa-shield-halved"></i> CẬP NHẬT MẬT KHẨU
                    </button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
