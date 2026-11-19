<%@ Page Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    protected string FullName = "";
    protected string Username = "";
    protected string Email = "";
    protected string Phone = "";
    protected string Address = "";
    protected string ErrorMessage = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack)
        {
            FullName = (Request.Form["FullName"] ?? "").Trim();
            Username = (Request.Form["Username"] ?? "").Trim();
            Email = (Request.Form["Email"] ?? "").Trim();
            Phone = (Request.Form["Phone"] ?? "").Trim();
            Address = (Request.Form["Address"] ?? "").Trim();
            string pw = Request.Form["Password"] ?? "";
            string confirmPw = Request.Form["ConfirmPassword"] ?? "";

            if (pw != confirmPw)
            {
                ErrorMessage = "Mật khẩu xác nhận không khớp với mật khẩu đã nhập.";
                return;
            }

            string err;
            UserInfo newUser = DbHelper.RegisterCustomer(Username, pw, FullName, Email, Phone, Address, out err);
            if (newUser == null)
            {
                ErrorMessage = err;
            }
            else
            {
                SecurityHelper.SetCurrentUser(newUser);
                Response.Redirect("Home.aspx");
            }
        }
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="auth-box" style="max-width:580px;">
            <h1 class="pcm-page-title" style="display:block; text-align:center;">
                <i class="fa-solid fa-user-plus"></i> ĐĂNG KÝ TÀI KHOẢN KHÁCH HÀNG (UC01)
            </h1>

            <% if (!string.IsNullOrEmpty(ErrorMessage)) { %>
                <div class="pcm-alert pcm-alert-error">
                    <i class="fa-solid fa-triangle-exclamation"></i> <%= HttpUtility.HtmlEncode(ErrorMessage) %>
                </div>
            <% } %>

            <div class="form-group">
                <label>Họ và tên <span style="color:red;">*</span></label>
                <input type="text" name="FullName" class="form-control"
                       value="<%= HttpUtility.HtmlAttributeEncode(FullName) %>"
                       placeholder="Nhập họ và tên đầy đủ của bạn" />
            </div>

            <div style="display:flex; gap:14px; flex-wrap:wrap;">
                <div class="form-group" style="flex:1; min-width:220px;">
                    <label>Tên đăng nhập <span style="color:red;">*</span></label>
                    <input type="text" name="Username" class="form-control"
                           value="<%= HttpUtility.HtmlAttributeEncode(Username) %>"
                           placeholder="Ví dụ: nguyenvana" />
                </div>
                <div class="form-group" style="flex:1; min-width:220px;">
                    <label>Số điện thoại <span style="color:red;">*</span></label>
                    <input type="text" name="Phone" class="form-control"
                           value="<%= HttpUtility.HtmlAttributeEncode(Phone) %>"
                           placeholder="Nhập số điện thoại 10 số" />
                </div>
            </div>

            <div class="form-group">
                <label>Địa chỉ Email <span style="color:red;">*</span></label>
                <input type="text" name="Email" class="form-control"
                       value="<%= HttpUtility.HtmlAttributeEncode(Email) %>"
                       placeholder="Ví dụ: nguyenvana@gmail.com" />
            </div>

            <div class="form-group">
                <label>Địa chỉ nhận hàng mặc định <span style="color:red;">*</span></label>
                <input type="text" name="Address" class="form-control"
                       value="<%= HttpUtility.HtmlAttributeEncode(Address) %>"
                       placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố" />
            </div>

            <div style="display:flex; gap:14px; flex-wrap:wrap;">
                <div class="form-group" style="flex:1; min-width:220px;">
                    <label>Mật khẩu (tối thiểu 6 ký tự) <span style="color:red;">*</span></label>
                    <input type="password" name="Password" class="form-control"
                           placeholder="Nhập mật khẩu" />
                </div>
                <div class="form-group" style="flex:1; min-width:220px;">
                    <label>Nhập lại mật khẩu <span style="color:red;">*</span></label>
                    <input type="password" name="ConfirmPassword" class="form-control"
                           placeholder="Xác nhận lại mật khẩu" />
                </div>
            </div>

            <button type="submit" class="btn-pcm btn-pcm-danger" style="width:100%; height:44px; font-size:15px; margin-top:8px;">
                <i class="fa-solid fa-check-circle"></i> XÁC NHẬN ĐĂNG KÝ
            </button>

            <div style="text-align:center; margin-top:16px; font-size:14px; color:#475569;">
                Đã có tài khoản?
                <a href="Login.aspx" style="color:#3D52BF; font-weight:700; text-decoration:underline;">Đăng nhập ngay</a>
            </div>
        </div>
    </div>
</asp:Content>
