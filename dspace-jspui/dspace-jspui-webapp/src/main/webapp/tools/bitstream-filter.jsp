<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.content.Bitstream" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="java.lang.Runtime" %>
<%@ page import="java.lang.Process" %>

<%
String msg = "";
boolean complete = true;
String dispaceDir = ConfigurationManager.getProperty("dspace.dir");

Item item = (Item) request.getAttribute("item");
String handle = (String) request.getAttribute("handle");	
try
{
	String cmd = dispaceDir + "/bin/filter-media -n -i " + handle;
	Process p = Runtime.getRuntime().exec(cmd);
	p.waitFor();
	
	msg = "Media Filter Complete!";
}
catch (Exception e) {
	msg = "Media Filter Fail. Please check your " + dispaceDir + "/bin/filter-media can work.";
	complete = false;
}
finally
{
%><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	
	<script type="text/javascript">
	function reloadOpener()
	{
		if (window.confirm("是否要重新整理編輯頁面？(如果您編輯的資料尚未儲存，請按否)"))
		{
			var path = "<%= request.getContextPath() + "/tools/edit-item?handle=" + handle %>";
			window.opener.location.href = path;
		}
	}
	</script>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><%= msg %></title>
	</head>
	<%
	if (complete == true)
		out.print("<body style=\"text-align:center;vertical-align:middle;\" onunload=\"reloadOpener()\">");
	else
		out.print("<body style=\"text-align:center;vertical-align:middle;\">");
	%>
	<p><%= msg %></p>
	
	<input type="button"  value="Close" onclick="window.close()" />
	
	
	</body>
	</html>
	<%
}
%>