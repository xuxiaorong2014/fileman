<%@ WebHandler Language="C#" Class="upc_a" %>

using System;
using System.Web;
using System.Text;
public class upc_a : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/xml";

        string code = "812967020676";
        
        
        
        string inputdes = "UD0000 - Rambler Satchel - Grey";

        if (context.Request["save"] == "svg")
        {
            context.Response.AddHeader("Content-Disposition", "attachment;filename=" + code + ".svg");
        }

        char[] inputchar = code.ToCharArray();
        string [] lCode = {"0001101","0011001","0010011","0111101","0100011","0110001","0101111","0111011","0110111","0001011"};
        string [] rCode = { "1110010", "1100110", "1101100", "1000010", "1011100", "1001110", "1010000", "1000100", "1001000", "1110100" };

        int lableWidth = 380;
        int labelHeight = 280;
        int w = 3;
        int h = 210;
        int y = 34;
        int x = 40;


        StringBuilder strSvg = new StringBuilder("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n");
        strSvg.Append("<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n");
        strSvg.Append("<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" ");
        strSvg.AppendFormat("width=\"{0}\" height=\"{1}\" >", lableWidth, labelHeight);
        strSvg.AppendFormat("\t<text style=\"fill:#000000;font-size:24px;text-anchor:middle\" font-family=\"'Arial'\" x=\"{2}\" y=\"{1}\">{0}</text>", inputdes, 24, 190);
        strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" stroke=\"black\" fill=\"none\" width=\"{2}\" height=\"{3}\"/>\n", 0, 0, lableWidth, labelHeight);
        strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#000000\" width=\"{2}\" height=\"{3}\"/>\n", x, y, w, h + 15 );
        x = x + w *2;
        strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#000000\" width=\"{2}\" height=\"{3}\"/>\n", x, y, w, h + 15);
        x = x + w;
        string outputstr = "";
        for(int i = 0;i<6;i++)
        {
            int idx = Convert.ToInt32( inputchar[i].ToString());
            outputstr += lCode[idx];
        }
        foreach (char c1 in outputstr)
        {
            if (c1 == '1')
            {
                strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#000000\" width=\"{2}\" height=\"{3}\"/>\n", x, y, w, h);
            }
            x = x + w; // 每一步移动一个宽度
        }
        x = x + w;
        strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#000000\" width=\"{2}\" height=\"{3}\"/>\n", x, y, w, h + 10);
        x = x + w*2;
        strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#000000\" width=\"{2}\" height=\"{3}\"/>\n", x, y, w, h + 10);
        x = x + w*2;
        outputstr = "";
        for(int i = 6;i<12;i++)
        {
            int idx = Convert.ToInt32(inputchar[i].ToString());
            outputstr += rCode[idx];
        }
        foreach (char c1 in outputstr)
        {
            if (c1 == '1')
            {
                strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#000000\" width=\"{2}\" height=\"{3}\"/>\n", x, y, w, h);
            }
            x = x + w; // 每一步移动一个宽度
        }

        strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#000000\" width=\"{2}\" height=\"{3}\"/>\n", x, y, w, h + 10);
        x = x + w;
        x = x + w;
        strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#000000\" width=\"{2}\" height=\"{3}\"/>\n", x, y, w, h + 10);
        strSvg.AppendFormat("\t<text font-size=\"24px\" font-family=\"'Arial'\" x=\"{2}\" y=\"{1}\">{0}</text>", inputchar[0], h + y + 30, 20);
        strSvg.AppendFormat("\t<text font-size=\"24px\" font-family=\"'Arial'\"  textLength=\"100\" x=\"{2}\" y=\"{1}\">{0}</text>", code.Substring(1, 5), h + y + 30, 60);
        strSvg.AppendFormat("\t<text font-size=\"24px\" font-family=\"'Arial'\"  textLength=\"100\" x=\"{2}\" y=\"{1}\">{0}</text>", code.Substring(6, 5), h + y + 30, 200);
        strSvg.AppendFormat("\t<text font-size=\"24px\" font-family=\"'Arial'\" x=\"{2}\" y=\"{1}\">{0}</text>", inputchar[11], h + y + 30, 326);
        strSvg.Append("</svg>");
        context.Response.Write(strSvg.ToString());

    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}
