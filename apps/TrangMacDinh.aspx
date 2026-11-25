<%@ Page Language="C#" %>
<script runat="server">
    protected void Page_Load(object sender, System.EventArgs e)
    {
        Response.Redirect("TrangChu.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }
</script>
