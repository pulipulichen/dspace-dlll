<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--@ page import="org.dspace.app.webui.util.BitstreamDisplay" --%>
<%@ page import="org.dspace.content.Bitstream" %>
<%@ page import="org.dspace.core.Constants" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="org.dspace.authorize.AuthorizeManager" %>
<%@ include file="/extension/bitstream-display/bitstream-display-ajax.jsp" %>
<%@ include file="/extension/filter-media/filter-media-util.jsp" %>
<%
Bitstream bitstream = (Bitstream) request.getAttribute("bitstream");
//BitstreamDisplay bd = (BitstreamDisplay) request.getAttribute("bitstreamDisplay");
Context context = new Context();
//Context context = UIUtil.obtainContext(request);

String path = request.getContextPath() + "/retrieve/" + bitstream.getID();
try
{
	path = path + "/" + UIUtil.encodeBitstreamName(bitstream.getName(),
		                        Constants.DEFAULT_ENCODING);
}
catch (Exception e) { }
 

BitstreamDisplayAJAX bd = null;
try
{
	bd = new BitstreamDisplayAJAX(request, context, path);
}
catch (java.lang.NullPointerException e)
{
	out.print(e);
	out.print(e.getMessage());
	e.printStackTrace();
}
catch (Exception e) 
{
	e.printStackTrace();
}

String w = request.getParameter("width");
String h = request.getParameter("height");

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="shortcut icon" href="<%= request.getContextPath() %>/favicon.ico" type="image/x-icon"/>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/jquery.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/bitstream-display/jquery-ui/js/jquery-ui-1.7.1.custom.min.js"></script>
<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/bitstream-display/jquery-ui/css/smoothness/jquery-ui-1.7.1.custom.css" type="text/css" />
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/bitstream-display/bitstream-display-js.jsp"></script>
<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/bitstream-display/bitstream-display.css.jsp" type="text/css" />
	
<meta http-equiv="Content-Type" content="text/html; charset=<%= Constants.DEFAULT_ENCODING %>" />
<title><%= bitstream.getName() %></title>
<script type="text/javascript">
jQuery(document).ready(function () {
	if (jQuery("iframe.bitstream-preview-iframe").length > 0)
	{
		var resizeIframe = function () {
			var w = window.innerWidth;
			var h = window.innerHeight;
			var iframe = jQuery("iframe.bitstream-preview-iframe");
			if (typeof(w) != "undefined" && w != 0)
				iframe.width(w);
			if (typeof(h) != "undefined" && h != 0)
				iframe.height(h);
		};
		
		resizeIframe();
		window.onresize = resizeIframe;
	}
});
</script>
</head>
<body style="text-align:center;margin: 0 auto;padding: 0 auto;">
<%
if (bd != null)
	out.print(bd.doPreview(w, h));
else
	out.print(path);
%>

<%
boolean isMember = AuthorizeManager.isAdmin(UIUtil.obtainContext(request));

if (isMember && w == null & h == null)
{
		//產生預覽檔案按鈕，但現在已經用不著了
		String filterMediaLink = FilterMediaUtil.getLink(request, bitstream);
		if (filterMediaLink.equals("") == false)
		{
			%>
			<div style="text-align:center;"><input type="button" value="<fmt:message key="jsp.tools.edit-item-form.filter-media"/><%-- 多媒體轉檔 --%>" 
				style="margin-top: 20px;" onclick="window.open('<%= filterMediaLink %>','_blank')" /></div>
			<%
		}
}
%>
</body>
</html>