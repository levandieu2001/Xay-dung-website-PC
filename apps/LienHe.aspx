<%@ Page Language="C#" MasterPageFile="~/BoCucChung.Master" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="PCMComputer" %>

<script runat="server">
    protected string FullName = "";
    protected string Phone = "";
    protected string Email = "";
    protected string TitleText = "";
    protected string ContentText = "";
    protected string AlertMessage = "";
    protected bool IsAlertSuccess = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            UserInfo u = SecurityHelper.GetCurrentUser();
            if (u != null)
            {
                FullName = u.FullName;
                Phone = u.Phone;
                Email = u.Email;
            }
        }
        else
        {
            FullName = (Request.Form["fullname"] ?? "").Trim();
            Phone = (Request.Form["phone"] ?? "").Trim();
            Email = (Request.Form["email"] ?? "").Trim();
            TitleText = (Request.Form["title"] ?? "").Trim();
            ContentText = (Request.Form["content"] ?? "").Trim();

            if (string.IsNullOrEmpty(FullName) || string.IsNullOrEmpty(Phone) ||
                string.IsNullOrEmpty(Email) || string.IsNullOrEmpty(ContentText))
            {
                IsAlertSuccess = false;
                AlertMessage = "Vui lòng nhập đầy đủ Họ và tên, Số điện thoại, Email và Nội dung cần hỗ trợ!";
            }
            else if (!Email.Contains("@") || !Email.Contains("."))
            {
                IsAlertSuccess = false;
                AlertMessage = "Email không đúng định dạng! (Ví dụ: abc@gmail.com)";
            }
            else
            {
                DbHelper.SaveContact(FullName, Phone, Email, TitleText, ContentText);
                IsAlertSuccess = true;
                AlertMessage = "Gửi thông tin liên hệ thành công! Yêu cầu của bạn đã được lưu vào hệ thống, nhân viên tư vấn sẽ liên hệ lại sớm nhất.";
                TitleText = "";
                ContentText = "";
            }
        }
    }
</script>

<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container contact-container">
        <div class="breadcrumb">
            <a href="TrangChu.aspx"><i class="fa-solid fa-house"></i> Trang chủ</a> / <span>Liên hệ &amp; Hỗ trợ tư vấn</span>
        </div>

        <% if (!string.IsNullOrEmpty(AlertMessage)) { %>
            <div class="pcm-alert <%= (IsAlertSuccess ? "pcm-alert-success" : "pcm-alert-error") %>">
                <i class="fa-solid <%= (IsAlertSuccess ? "fa-circle-check" : "fa-triangle-exclamation") %>"></i>
                <%= HttpUtility.HtmlEncode(AlertMessage) %>
            </div>
        <% } %>

        <div class="contact-content">
            <div class="contact-info">
                <h2>THÔNG TIN LIÊN HỆ</h2>
                <div class="info-box">
                    <p><i class="fa-solid fa-location-dot"></i> <strong>Địa chỉ cửa hàng 1:</strong> 83-85 Thái Hà, Đống Đa, Hà Nội</p>
                    <p><i class="fa-solid fa-location-dot"></i> <strong>Địa chỉ cửa hàng 2:</strong> 83A Cửu Long, Phường 15, Quận 10, TP.HCM</p>
                    <p><i class="fa-solid fa-phone"></i> <strong>Điện thoại tư vấn cấu hình:</strong> 036.625.8142 - 087.997.9997</p>
                    <p><i class="fa-solid fa-envelope"></i> <strong>Thư điện tử:</strong> cskh@pcmcomputer.vn</p>
                    <p><i class="fa-solid fa-clock"></i> <strong>Giờ làm việc:</strong> 8h00 - 21h00 (Hàng ngày)</p>
                </div>
            </div>

            <div class="contact-form">
                <h2>GỬI YÊU CẦU TƯ VẤN CẤU HÌNH &amp; HỖ TRỢ</h2>
                <p>Vui lòng điền đầy đủ thông tin vào bảng dưới đây:</p>

                <div>
                    <table class="tbl-contact">
                        <tr>
                            <td>Họ và tên* :</td>
                            <td><input type="text" id="fullname" name="fullname" value="<%= HttpUtility.HtmlAttributeEncode(FullName) %>" placeholder="Nhập họ tên của bạn"></td>
                        </tr>
                        <tr>
                            <td>SĐT* :</td>
                            <td><input type="text" id="phone" name="phone" value="<%= HttpUtility.HtmlAttributeEncode(Phone) %>" placeholder="Nhập số điện thoại (10 số)"></td>
                        </tr>
                        <tr>
                            <td>Email* :</td>
                            <td><input type="text" id="email" name="email" value="<%= HttpUtility.HtmlAttributeEncode(Email) %>" placeholder="Nhập email của bạn"></td>
                        </tr>
                        <tr>
                            <td>Tiêu đề :</td>
                            <td><input type="text" id="title" name="title" value="<%= HttpUtility.HtmlAttributeEncode(TitleText) %>" placeholder="Bạn cần tư vấn Laptop, PC hay bảo hành?"></td>
                        </tr>
                        <tr>
                            <td>Nội dung* :</td>
                            <td><textarea id="content" name="content" rows="5" placeholder="Nội dung chi tiết..."><%= HttpUtility.HtmlEncode(ContentText) %></textarea></td>
                        </tr>
                        <tr>
                            <td></td>
                            <td>
                                <button type="submit" class="btn-send">GỬI LIÊN HỆ</button>
                                <a href="LienHe.aspx" class="btn-reset" style="display:inline-block; text-decoration:none;">NHẬP LẠI</a>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
