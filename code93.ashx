<%@ WebHandler Language="C#" Class="Barcodes.code93" %>
using System;
using System.Collections.Specialized;
using System.Web;
using System.Text;
 
namespace Barcodes
{
    public class code93 : IHttpHandler
    {
        private NameValueCollection code0 = new NameValueCollection(49);
        private NameValueCollection code1 = new NameValueCollection(49);
        private string code;
        private int strLength;
        private string encodedString;
        
        public void ProcessRequest(HttpContext context)
        {
            initCode();
            int lableWidth = 600;
            int labelHeight = 280;
            int w = 4;
            int h = 200;
            int y = 30;
            int x = 40;
            
            context.Response.ContentType = "text/xml";

            code = context.Request["code"];
            if (code == null) { code = "CODE93"; }
            
            if(context.Request["save"] == "svg")
            {
                context.Response.AddHeader("Content-Disposition", "attachment;filename=" + code + ".svg");
            }
            code = code.ToUpper();
            EncodeBarcodeValue();

            //标签总宽度
            lableWidth = encodedString.Length * w + x * 2;
            
            StringBuilder strSvg = new StringBuilder("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n");
            strSvg.Append("<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n");
            strSvg.Append("<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" ");
            strSvg.AppendFormat("width=\"{0}\" height=\"{1}\" >",lableWidth,labelHeight);

            strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" stroke=\"black\" fill=\"none\" width=\"{2}\" height=\"{3}\"/>\n", 0, 0, lableWidth, labelHeight);
            foreach (char c1 in encodedString)
            {
                
                if(c1 == '1')
                {
                    strSvg.AppendFormat("\t<rect x=\"{0}\" y=\"{1}\" fill=\"#000000\" width=\"{2}\" height=\"{3}\"/>\n", x, y, w, h);
                }
 
                x = x + w; // 每一步移动一个宽度
            }

            strSvg.AppendFormat("\t<text style=\"fill:#000000;font-size:24px\" x=\"{2}\" y=\"{1}\">{0}</text>", code, h + y + 24, lableWidth/2 - code.Length * 12);
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


        private void initCode()
        {
            code0["0"] = "100010100";
            code0["1"] = "101001000";
            code0["2"] = "101000100";
            code0["3"] = "101000010";
            code0["4"] = "100101000";
            code0["5"] = "100100100";
            code0["6"] = "100100010";
            code0["7"] = "101010000";
            code0["8"] = "100010010";
            code0["9"] = "100001010";
            code0["A"] = "110101000";
            code0["B"] = "110100100";
            code0["C"] = "110100010";
            code0["D"] = "110010100";
            code0["E"] = "110010010";
            code0["F"] = "110001010";
            code0["G"] = "101101000";
            code0["H"] = "101100100";
            code0["I"] = "101100010";
            code0["J"] = "100110100";
            code0["K"] = "100011010";
            code0["L"] = "101011000";
            code0["M"] = "101001100";
            code0["N"] = "101000110";
            code0["O"] = "100101100";
            code0["P"] = "100010110";
            code0["Q"] = "110110100";
            code0["R"] = "110110010";
            code0["S"] = "110101100";
            code0["T"] = "110100110";
            code0["U"] = "110010110";
            code0["V"] = "110011010";
            code0["W"] = "101101100";
            code0["X"] = "101100110";
            code0["Y"] = "100110110";
            code0["Z"] = "100111010";
            code0["-"] = "100101110";
            code0["."] = "111010100";
            code0[" "] = "111010010";
            code0["$"] = "111001010";
            code0["/"] = "101101110";
            code0["+"] = "101101110";
            code0["%"] = "110101110";
            code0["SHIFT1"] = "100100110";
            code0["SHIFT2"] = "111011010";
            code0["SHIFT3"] = "111010110";
            code0["SHIFT4"] = "100110010";
            code0["START"] = "101011110";
            code0["STOP"] = "1010111101";

            code1["0"] = "0";
            code1["1"] = "1";
            code1["2"] = "2";
            code1["3"] = "3";
            code1["4"] = "4";
            code1["5"] = "5";
            code1["6"] = "6";
            code1["7"] = "7";
            code1["8"] = "8";
            code1["9"] = "9";
            code1["A"] = "10";
            code1["B"] = "11";
            code1["C"] = "12";
            code1["D"] = "13";
            code1["E"] = "14";
            code1["F"] = "15";
            code1["G"] = "16";
            code1["H"] = "17";
            code1["I"] = "18";
            code1["J"] = "19";
            code1["K"] = "20";
            code1["L"] = "21";
            code1["M"] = "22";
            code1["N"] = "23";
            code1["O"] = "24";
            code1["P"] = "25";
            code1["Q"] = "26";
            code1["R"] = "27";
            code1["S"] = "28";
            code1["T"] = "29";
            code1["U"] = "30";
            code1["V"] = "31";
            code1["W"] = "32";
            code1["X"] = "33";
            code1["Y"] = "34";
            code1["Z"] = "35";
            code1["-"] = "36";
            code1["."] = "37";
            code1[" "] = "38";
            code1["$"] = "39";
            code1["/"] = "40";
            code1["+"] = "41";
            code1["%"] = "42";
            code1["SHIFT1"] = "43";
            code1["SHIFT2"] = "44";
            code1["SHIFT3"] = "45";
            code1["SHIFT4"] = "46";
            code1["START"] = "47";
            code1["STOP"] = "48";
        }
        public void EncodeBarcodeValue()
        {
            try
            {
                String str = code.ToUpper();
                strLength = str.Length;
                encodedString = code0["START"];
                for (int i = 0; i < strLength; i++)
                {
                    encodedString += code0[str[i].ToString()];
                }
                encodedString += GetCheckC_KValue();
                encodedString += code0["STOP"];
            }
            catch
            {
                throw new Exception("条码的值错误请检查!");
            }
        }
 
        private string GetCheckC_KValue()
        {
            int sum = 0, cValue = 0;
            int codeLength = code.Length;
            for (int i = 1; i <= code.Length; i++)
            {
                sum += int.Parse(code1[code[i - 1].ToString()]) * codeLength;
                codeLength--;
            }
            cValue = sum % 47;
            GetCheckKValue(cValue);
            return code0[cValue] + GetCheckKValue(cValue);
        }
        private string GetCheckKValue(int cvlaue)
        {
            int sum = 0, kValue = 0;
            int codeLength = code.Length + 1;
            for (int i = 1; i <= code.Length; i++)
            {
                sum += int.Parse(code1[code[i - 1].ToString()]) * codeLength;
                codeLength--;
            }
            kValue = (sum + cvlaue) % 47;
            return code0[kValue];
        }
    }
}
