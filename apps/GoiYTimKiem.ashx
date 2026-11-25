<%@ WebHandler Language="C#" Class="SearchSuggest" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using PCMComputer;

public class SearchSuggest : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        context.Response.ContentEncoding = Encoding.UTF8;

        string query = context.Request.QueryString["q"];
        if (string.IsNullOrWhiteSpace(query))
        {
            context.Response.Write("{\"total\":0,\"keyword\":\"\",\"results\":[]}");
            return;
        }

        query = query.Trim();
        string kwLower = query.ToLower();
        string kwWildcard = "%" + query + "%";
        string kwStart = query + "%";

        List<string> items = new List<string>();
        int totalMatches = 0;

        using (SqlConnection conn = DbHelper.GetConnection())
        {
            conn.Open();

            string filterClause = "";
            bool isIntent = true;

            if (kwLower == "vga" || kwLower == "card man hinh" || kwLower == "card màn hình" || kwLower == "card do hoa" || kwLower == "card đồ họa" || kwLower == "gpu")
            {
                filterClause = " AND (p.TEN_SAN_PHAM LIKE N'%VGA%' OR p.MA_SAN_PHAM LIKE N'%VGA%' OR (p.ID_DANHMUC = 6 AND (p.TEN_SAN_PHAM LIKE N'%GeForce%' OR p.TEN_SAN_PHAM LIKE N'%RTX%' OR p.TEN_SAN_PHAM LIKE N'%GTX%' OR p.TEN_SAN_PHAM LIKE N'%Radeon%')))";
            }
            else if (kwLower == "pc" || kwLower == "máy tính bàn" || kwLower == "may tinh ban" || kwLower == "pc gaming" || kwLower == "pc do hoa" || kwLower == "pc đồ họa")
            {
                filterClause = " AND (p.ID_DANHMUC IN (3, 4, 5) OR p.TEN_SAN_PHAM LIKE N'PC %' OR p.TEN_SAN_PHAM LIKE N'% PC %' OR p.TEN_SAN_PHAM LIKE N'Bộ Mini PC%')";
            }
            else if (kwLower == "laptop" || kwLower == "máy tính xách tay" || kwLower == "may tinh xach tay" || kwLower == "notebook")
            {
                filterClause = " AND (p.ID_DANHMUC IN (1, 2) OR p.TEN_SAN_PHAM LIKE N'%Laptop%')";
            }
            else if (kwLower == "ram")
            {
                filterClause = " AND (p.ID_DANHMUC = 6 AND (p.TEN_SAN_PHAM LIKE N'%RAM%' OR p.TEN_SAN_PHAM LIKE N'%Bộ nhớ trong%'))";
            }
            else if (kwLower == "cpu" || kwLower == "chip" || kwLower == "vi xử lý" || kwLower == "vi xu ly")
            {
                filterClause = " AND (p.ID_DANHMUC = 6 AND (p.TEN_SAN_PHAM LIKE N'%CPU%' OR p.TEN_SAN_PHAM LIKE N'%Core i%' OR p.TEN_SAN_PHAM LIKE N'%Ryzen%'))";
            }
            else if (kwLower == "ssd" || kwLower == "ổ cứng" || kwLower == "o cung")
            {
                filterClause = " AND (p.ID_DANHMUC = 6 AND (p.TEN_SAN_PHAM LIKE N'%SSD%' OR p.TEN_SAN_PHAM LIKE N'%Ổ Cứng%'))";
            }
            else if (kwLower == "main" || kwLower == "mainboard" || kwLower == "bo mạch chủ" || kwLower == "bo mach chu")
            {
                filterClause = " AND (p.ID_DANHMUC = 6 AND (p.TEN_SAN_PHAM LIKE N'%Mainboard%' OR p.TEN_SAN_PHAM LIKE N'%Bo Mạch Chủ%'))";
            }
            else if (kwLower == "màn hình" || kwLower == "man hinh" || kwLower == "monitor")
            {
                filterClause = " AND (p.ID_DANHMUC = 7 AND p.TEN_SAN_PHAM LIKE N'%Màn Hình%')";
            }
            else if (kwLower == "máy in" || kwLower == "may in" || kwLower == "printer")
            {
                filterClause = " AND (p.ID_DANHMUC = 7 AND p.TEN_SAN_PHAM LIKE N'%Máy In%')";
            }
            else if (kwLower == "chuột" || kwLower == "chuot" || kwLower == "mouse")
            {
                filterClause = " AND (p.ID_DANHMUC = 8 AND (p.TEN_SAN_PHAM LIKE N'%Chuột%' OR p.TEN_SAN_PHAM LIKE N'%Mouse%'))";
            }
            else if (kwLower == "bàn phím" || kwLower == "ban phim" || kwLower == "keyboard")
            {
                filterClause = " AND (p.ID_DANHMUC = 8 AND (p.TEN_SAN_PHAM LIKE N'%Bàn Phím%' OR p.TEN_SAN_PHAM LIKE N'%Keyboard%'))";
            }
            else if (kwLower == "tai nghe" || kwLower == "headphone" || kwLower == "headset")
            {
                filterClause = " AND (p.ID_DANHMUC = 10 AND (p.TEN_SAN_PHAM LIKE N'%Tai Nghe%' OR p.TEN_SAN_PHAM LIKE N'%Headset%'))";
            }
            else if (kwLower == "loa" || kwLower == "speaker")
            {
                filterClause = " AND (p.ID_DANHMUC = 10 AND (p.TEN_SAN_PHAM LIKE N'%Loa %' OR p.TEN_SAN_PHAM LIKE N'%Speaker%'))";
            }
            else if (kwLower == "webcam" || kwLower == "camera" || kwLower == "cam")
            {
                filterClause = " AND ((p.ID_DANHMUC = 10 AND p.TEN_SAN_PHAM LIKE N'%Webcam%') OR (p.ID_DANHMUC = 12 AND p.TEN_SAN_PHAM LIKE N'%Camera%'))";
            }
            else if (kwLower == "tản nhiệt" || kwLower == "tan nhiet" || kwLower == "cooler" || kwLower == "aio")
            {
                filterClause = " AND (p.ID_DANHMUC = 11)";
            }
            else if (kwLower == "đồng hồ" || kwLower == "dong ho" || kwLower == "watch" || kwLower == "smartwatch")
            {
                filterClause = " AND (p.ID_DANHMUC = 14)";
            }
            else
            {
                isIntent = false;
                filterClause = " AND (p.TEN_SAN_PHAM LIKE @kw OR p.MA_SAN_PHAM LIKE @kw OR p.THUONG_HIEU LIKE @kw OR c.TEN_DANH_MUC LIKE @kw OR p.THONG_SO_KY_THUAT LIKE @kw)";
            }

            // Count total matches
            string countSql = @"SELECT COUNT(*) FROM dbo.SANPHAM p
                               INNER JOIN dbo.DANHMUC c ON p.ID_DANHMUC = c.ID_DANHMUC
                               WHERE p.TRANG_THAI = N'Đang kinh doanh'" + filterClause;
            using (SqlCommand countCmd = new SqlCommand(countSql, conn))
            {
                if (!isIntent)
                {
                    countCmd.Parameters.AddWithValue("@kw", kwWildcard);
                }
                totalMatches = Convert.ToInt32(countCmd.ExecuteScalar());
            }

            // Fetch top 6 items
            string sql = @"SELECT TOP 6 
                              p.ID_SANPHAM, p.MA_SAN_PHAM, p.TEN_SAN_PHAM, p.THUONG_HIEU, p.GIA_BAN, p.GIA_CU, p.DUONG_DAN_ANH, c.TEN_DANH_MUC
                           FROM dbo.SANPHAM p
                           INNER JOIN dbo.DANHMUC c ON p.ID_DANHMUC = c.ID_DANHMUC
                           WHERE p.TRANG_THAI = N'Đang kinh doanh'" + filterClause;

            if (!isIntent)
            {
                sql += @" ORDER BY 
                           (CASE 
                             WHEN p.TEN_SAN_PHAM LIKE @kwStart THEN 100
                             WHEN p.TEN_SAN_PHAM LIKE @kw THEN 80
                             WHEN p.THUONG_HIEU LIKE @kw THEN 60
                             WHEN c.TEN_DANH_MUC LIKE @kw THEN 50
                             WHEN p.MA_SAN_PHAM LIKE @kw THEN 40
                             ELSE 20 
                           END) DESC,
                           p.SO_LUONG_DA_BAN DESC, p.ID_SANPHAM DESC";
            }
            else
            {
                sql += " ORDER BY p.SO_LUONG_DA_BAN DESC, p.ID_SANPHAM DESC";
            }

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (!isIntent)
                {
                    cmd.Parameters.AddWithValue("@kw", kwWildcard);
                    cmd.Parameters.AddWithValue("@kwStart", kwStart);
                }

                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        int id = Convert.ToInt32(r["ID_SANPHAM"]);
                        string code = r["MA_SAN_PHAM"].ToString();
                        string name = r["TEN_SAN_PHAM"].ToString();
                        string brand = r["THUONG_HIEU"].ToString();
                        decimal price = Convert.ToDecimal(r["GIA_BAN"]);
                        decimal oldPrice = Convert.ToDecimal(r["GIA_CU"]);
                        string imageUrl = DbHelper.LocalizeAssetPath(r["DUONG_DAN_ANH"].ToString());
                        string category = r["TEN_DANH_MUC"].ToString();

                        string itemJson = string.Format(
                            "{{\"id\":{0},\"code\":{1},\"name\":{2},\"brand\":{3},\"price\":{4},\"oldPrice\":{5},\"priceFormatted\":{6},\"oldPriceFormatted\":{7},\"imageUrl\":{8},\"category\":{9}}}",
                            id,
                            EscapeJson(code),
                            EscapeJson(name),
                            EscapeJson(brand),
                            Convert.ToInt64(price),
                            Convert.ToInt64(oldPrice),
                            EscapeJson(price.ToString("#,##0") + " đ"),
                            EscapeJson(oldPrice > price ? oldPrice.ToString("#,##0") + " đ" : ""),
                            EscapeJson(imageUrl),
                            EscapeJson(category)
                        );
                        items.Add(itemJson);
                    }
                }
            }
        }

        string jsonResult = string.Format(
            "{{\"total\":{0},\"keyword\":{1},\"results\":[{2}]}}",
            totalMatches,
            EscapeJson(query),
            string.Join(",", items.ToArray())
        );

        context.Response.Write(jsonResult);
    }

    private static string EscapeJson(string s)
    {
        if (s == null) return "\"\"";
        StringBuilder sb = new StringBuilder("\"");
        foreach (char c in s)
        {
            switch (c)
            {
                case '\\': sb.Append("\\\\"); break;
                case '\"': sb.Append("\\\""); break;
                case '\b': sb.Append("\\b"); break;
                case '\f': sb.Append("\\f"); break;
                case '\n': sb.Append("\\n"); break;
                case '\r': sb.Append("\\r"); break;
                case '\t': sb.Append("\\t"); break;
                default:
                    if (c < ' ')
                        sb.AppendFormat("\\u{0:x4}", (int)c);
                    else
                        sb.Append(c);
                    break;
            }
        }
        sb.Append("\"");
        return sb.ToString();
    }

    public bool IsReusable
    {
        get { return true; }
    }
}
