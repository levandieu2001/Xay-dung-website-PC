<%@ Page Language="C#" %>
<%@ Import Namespace="PCMComputer" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.Logout();
        Response.Redirect("TrangChu.aspx");
    }
</script>
