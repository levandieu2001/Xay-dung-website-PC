<%@ Page Language="C#" MasterPageFile="~/Site.Master" %>
<%@ Register Src="~/CategoryView.ascx" TagPrefix="uc" TagName="CategoryView" %>
<asp:Content ID="MainContentPage" ContentPlaceHolderID="MainContent" runat="server">
    <uc:CategoryView ID="CatView" runat="server" DefaultCategorySlug="Components.aspx" />
</asp:Content>
