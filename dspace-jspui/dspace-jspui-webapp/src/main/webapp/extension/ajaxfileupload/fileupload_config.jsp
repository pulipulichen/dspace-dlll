<%--
	fileupload_config.jsp
	2009.05.29 布丁
	
	原本的檔案是用JavaScript來作的，可是一些參數必需要用手寫，比較不方便。是故現在改成以JSP的方式讀取參數。
--%>
<%@ page contentType="application/x-javascript; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.app.webui.util.SubmissionUtil" %>
<%
	int maxHeight = (int) ConfigurationManager
                .getIntProperty("thumbnail.maxheight");
	String langDelConfirm = LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.supervise-confirm-remove.heading");	//是否確定要刪除？
	if (langDelConfirm == null)
		langDelConfirm = "";
	String remove = LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.general.remove");	//移除
	
%>

var fileuploadConfig = {
	"inputName": "file", 
	"step": <%= SubmissionUtil.getFileUploadStep() %>,
	"page": 1,
	"url": {
		"upload": '?action=json',
		"remove": location.pathname,
		"upload_jsp": ""
	},
	"jsp": "/submit/choose-file.jsp",
	"maxHeight": <%= maxHeight %>,
	"imageFormat": ["jpg", "jpeg", "gif", "png", "image/png"],
	"langDelConfirm": "<%= langDelConfirm %>",
	"delData": function (bitstream_id, item_id) {
		return "submit_delete_bitstream_"+item_id+"_"+bitstream_id+"=<%= remove %>";
	}
};

function dspaceFileUploadConfig()
{
		var f = new Object;
		f.fileUploadStep = <%= SubmissionUtil.getFileUploadStep() %>;
		f.page = 1;
		f.jsp = "/submit/choose-file.jsp";
		f.maxHeight = <%= maxHeight %>;
		f.imageFormat = ["jpg", "jpeg", "gif", "png", "image/png"];
		f.langDelConfirm = "<%= langDelConfirm %>";
		return f;
}