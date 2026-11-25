<%@ Page Language="C#" MasterPageFile="~/BoCucChung.Master" %>
<%@ Register Src="~/HienThiDanhMuc.ascx" TagPrefix="uc" TagName="CategoryView" %>
<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <uc:CategoryView ID="CatView" runat="server" DefaultCategorySlug="DienThoai.aspx" />
</asp:Content>
