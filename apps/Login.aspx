<%@ Page Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    protected string UsernameInput = "";
    protected string ErrorMessage = "";
    protected string SuccessMessage = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && Request.QueryString["registered"] == "1")
        {
            SuccessMessage = "Đăng ký tài khoản thành công! Vui lòng đăng nhập để bắt đầu mua sắm.";
        }

        if (IsPostBack)
        {
            UsernameInput = (Request.Form["Username"] ?? "").Trim();
            string password = Request.Form["Password"] ?? "";

            string err;
            UserInfo user = DbHelper.AuthenticateUser(UsernameInput, password, out err);
            if (user == null)
            {
                ErrorMessage = err;
            }
            else
            {
                SecurityHelper.SetCurrentUser(user);

                string returnUrl = Request.QueryString["returnUrl"];
                if (!string.IsNullOrEmpty(returnUrl) && !returnUrl.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect(returnUrl);
                    return;
                }

                // Bước 5 UC02: Điều hướng đúng theo vai trò (Role) của tài khoản
                if (string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("Admin.aspx");
                }
                else if (string.Equals(user.Role, "Staff", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("Staff.aspx");
                }
                else
                {
                    Response.Redirect("Home.aspx");
                }
            }
        }
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="auth-box">
            <h1 class="pcm-page-title" style="display:block; text-align:center;">
                <i class="fa-solid fa-right-to-bracket"></i> ĐĂNG NHẬP HỆ THỐNG (UC02)
            </h1>

            <% if (!string.IsNullOrEmpty(SuccessMessage)) { %>
                <div class="pcm-alert pcm-alert-success">
                    <i class="fa-solid fa-circle-check"></i> <%= HttpUtility.HtmlEncode(SuccessMessage) %>
                </div>
            <% } %>

            <% if (!string.IsNullOrEmpty(ErrorMessage)) { %>
                <div class="pcm-alert pcm-alert-error">
                    <i class="fa-solid fa-triangle-exclamation"></i> <%= HttpUtility.HtmlEncode(ErrorMessage) %>
                </div>
            <% } %>

            <div class="form-group">
                <label for="Username">Tên đăng nhập hoặc Email <span style="color:red;">*</span></label>
                <input type="text" id="Username" name="Username" class="form-control"
                       value="<%= HttpUtility.HtmlAttributeEncode(UsernameInput) %>"
                       placeholder="Nhập tên đăng nhập hoặc email của bạn" />
            </div>

            <div class="form-group">
                <label for="Password">Mật khẩu <span style="color:red;">*</span></label>
                <input type="password" id="Password" name="Password" class="form-control"
                       placeholder="Nhập mật khẩu" />
            </div>

            <button type="submit" class="btn-pcm btn-pcm-primary" style="width:100%; height:44px; font-size:15px; margin-top:8px;">
                <i class="fa-solid fa-unlock-keyhole"></i> ĐĂNG NHẬP
            </button>

            <div style="text-align:center; margin-top:16px; font-size:14px; color:#475569;">
                Bạn chưa có tài khoản khách hàng?
                <a href="Register.aspx" style="color:#CB1C21; font-weight:700; text-decoration:underline;">Đăng ký tài khoản mới (UC01)</a>
            </div>

            <div style="margin-top:24px; padding:14px; background:#f8fafc; border:1px dashed #94a3b8; border-radius:8px; font-size:13px;">
                <div style="font-weight:700; color:#3D52BF; margin-bottom:8px;">
                    <i class="fa-solid fa-key"></i> Tài khoản mẫu kiểm thử các phân hệ (Mật khẩu: 123456):
                </div>
                <div style="display:flex; flex-wrap:wrap; gap:6px;">
                    <button type="button" class="btn-pcm btn-pcm-outline" style="height:30px; padding:0 10px; font-size:12px;"
                            onclick="fillDemoLogin('admin','123456');">
                        Admin (admin)
                    </button>
                    <button type="button" class="btn-pcm btn-pcm-outline" style="height:30px; padding:0 10px; font-size:12px;"
                            onclick="fillDemoLogin('staff','123456');">
                        Nhân viên (staff)
                    </button>
                    <button type="button" class="btn-pcm btn-pcm-outline" style="height:30px; padding:0 10px; font-size:12px;"
                            onclick="fillDemoLogin('khachhang','123456');">
                        Khách hàng (khachhang)
                    </button>
                    <button type="button" class="btn-pcm btn-pcm-outline" style="height:30px; padding:0 10px; font-size:12px; color:#dc2626 !important; border-color:#dc2626;"
                            onclick="fillDemoLogin('userlocked','123456');">
                        TK bị khóa (userlocked)
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function fillDemoLogin(user, pass) {
            document.getElementById("Username").value = user;
            document.getElementById("Password").value = pass;
            document.getElementById("mainForm").submit();
        }
    </script>
</asp:Content>
