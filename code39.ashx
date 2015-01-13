<%@ WebHandler Language="C#" Class="Barcodes.code93" %>
using System;
using System.Collections.Specialized;
using System.Web;
using System.Text;
 
namespace Barcodes
{
    public class code93 : IHttpHandler
    {

        private string code;
        private int strLength;
        private string encodedString;

        String alphabet39 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*";
        String[] coded39Char = 
		{
			/* 0 */ "000110100", 
			/* 1 */ "100100001", 
			/* 2 */ "001100001", 
			/* 3 */ "101100000",
			/* 4 */ "000110001", 
			/* 5 */ "100110000", 
			/* 6 */ "001110000", 
			/* 7 */ "000100101",
			/* 8 */ "100100100", 
			/* 9 */ "001100100", 
			/* A */ "100001001", 
			/* B */ "001001001",
			/* C */ "101001000", 
			/* D */ "000011001", 
			/* E */ "100011000", 
			/* F */ "001011000",
			/* G */ "000001101", 
			/* H */ "100001100", 
			/* I */ "001001100", 
			/* J */ "000011100",
			/* K */ "100000011", 
			/* L */ "001000011", 
			/* M */ "101000010", 
			/* N */ "000010011",
			/* O */ "100010010", 
			/* P */ "001010010", 
			/* Q */ "000000111", 
			/* R */ "100000110",
			/* S */ "001000110", 
			/* T */ "000010110", 
			/* U */ "110000001", 
			/* V */ "011000001",
			/* W */ "111000000", 
			/* X */ "010010001", 
			/* Y */ "110010000", 
			/* Z */ "011010000",
			/* - */ "010000101", 
			/* . */ "110000100", 
			/*' '*/ "011000100",
			/* $ */ "010101000",
			/* / */ "010100010", 
			/* + */ "010001010", 
			/* % */ "000101010", 
			/* * */ "010010100" 
		};
        
        
        
        public void ProcessRequest(HttpContext context)
        {
 
            int lableWidth = 600;
            int labelHeight = 280;
            int w = 4;
            int h = 200;
            int y = 30;
            int x = 40;
            
            context.Response.ContentType = "text/xml";

            code = context.Request["code"];
            if (code == null) { code = "CODE39"; }
            
            if(context.Request["save"] == "svg")
            {
                context.Response.AddHeader("Content-Disposition", "attachment;filename=" + code + ".svg");
            }
            code = code.ToUpper();
            EncodeBarcodeValue();

            //标签总宽度
            lableWidth = (code.Length + 2) * (6 * w + 3 * w * 2 + w) + x*2;
            
            StringBuilder strSvg = new StringBuilder("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n");
            strSvg.Append("<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n");
            strSvg.Append("<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" ");
            strSvg.AppendFormat("width=\"{0}\" height=\"{1}\" >",lableWidth,labelHeight);

            strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" stroke=\"black\" fill=\"none\" width=\"{2}\" height=\"{3}\"/>\n", 0, 0, lableWidth, labelHeight);

            bool bColor = true;
            foreach (char c1 in encodedString)
            {

                string c = string.Empty;;
                if(bColor)
                {
                    c = "000000";
                }
                else
                {
                    c = "ffffff";
                }
                if(c1 == '1')
                {
                    strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#{2}\" width=\"{3}\" height=\"{4}\"/>\n", x, y, c, w * 2, h);
                    x = x + w*2; // 每一步移动一个宽度
                }
                else
                {
                    strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#{2}\" width=\"{3}\" height=\"{4}\"/>\n", x, y, c, w, h);
                    x = x + w; // 每一步移动一个宽度
                }
                bColor = !bColor;
            }

            strSvg.AppendFormat("\t<text style=\"fill:#000000;font-size:24px\" x=\"{2}\" y=\"{1}\">*{0}*</text>", code, h + y + 24, lableWidth/2 - code.Length * 12);
            strSvg.Append("</svg>");
            context.Response.Write(strSvg.ToString());
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

 
        private void EncodeBarcodeValue()
        {
            try
            {
                String intercharacterGap = "0";
                String str = '*' + code.ToUpper() + '*';
                strLength = str.Length;
                encodedString = "";
                for (int i = 0; i < strLength; i++)
                {
                    if (i > 0)
                        encodedString += intercharacterGap;

                    encodedString += coded39Char[alphabet39.IndexOf(str[i])];
                }
            }
            catch
            {
                throw new Exception("编码失败");
            }

        }
    }
}
