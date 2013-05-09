<%-- 
	vnc-server.jsp

//語系檔備份：
jsp.layout.navbar-admin.vnc-server = \u64cd\u4f5c\u4f3a\u670d\u5668

jsp.dspace-admin.vnc-server.title = \u64cd\u4f5c\u4f3a\u670d\u5668
jsp.dspace-admin.vnc-server.heading = \u64cd\u4f5c\u4f3a\u670d\u5668
jsp.dspace-admin.vnc-server.miss-config.heading = \u5c1a\u672a\u8a2d\u5b9a\u9060\u7aef\u4f3a\u670d\u5668
jsp.dspace-admin.vnc-server.miss-config.help1 = \u8acb\u8a2d\u5b9a\u60a8\u4f3a\u670d\u5668\u4e0a\u7684VNC\uff0c\u4e26\u5728
jsp.dspace-admin.vnc-server.miss-config.help2 = \u7576\u4e2d\u52a0\u5165\u300cvnc.port = 5801\u300d\u7684\u8a2d\u5b9a\uff0c5801\u5fc5\u9808\u66ff\u63db\u6210\u60a8\u4f3a\u670d\u5668VNC\u7684\u9023\u63a5\u57e0\u3002
jsp.dspace-admin.vnc-server.reload = \u91cd\u65b0\u8b80\u53d6
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%
	String vncPort = (String) ConfigurationManager.getProperty("vnc.port");
	
%>

<%-- <dspace:layout titlekey="操作伺服器" --%>
<dspace:layout titlekey="jsp.dspace-admin.vnc-server.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin">

<table width="95%">
    <tr>
      <td align="left">
        <%-- <h1>News Editor</h1> --%>
        <h1>
			<fmt:message key="jsp.dspace-admin.vnc-server.heading"/>
			<%-- 操作伺服器 --%>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#vncserver" %>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

<%
if (vncPort == null)
{
	%>
	<h2>
		<fmt:message key="jsp.dspace-admin.vnc-server.miss-config.heading"/>
		<%-- 尚未設定遠端伺服器 --%>
	</h2>
	<div>
		<fmt:message key="jsp.dspace-admin.vnc-server.miss-config.help1"/>
		<%-- 請設定您伺服器上的VNC，並在 --%>
		<a href="<%= request.getContextPath() %>/dspace-admin/config-edit">
			<fmt:message key="jsp.layout.navbar-admin.config-edit"/>
			<%-- 編輯設定檔 --%>
		</a>
		<fmt:message key="jsp.dspace-admin.vnc-server.miss-config.help2"/>
		<%-- 當中加入「vnc.port = 5801」的設定，5801必須替換成您伺服器VNC的連接埠。 --%>
		</div>
	<%
}
else
{
	%>
	<iframe id="vncServer" width="450" height="300" border="0" style="border-width: 0;"></iframe>
	<div style="width:300px;text-align:center;">
		<button type="button" id="vncServerReload">
			<fmt:message key="jsp.dspace-admin.vnc-server.reload"/>
			<%-- 重新讀取 --%>
		</button>
	</div>
	<script type="text/javascript">
		var vncPort = "<%= vncPort %>";
		var vncServer = location.host;
		if (vncServer.indexOf(":") != -1)
			vncServer = vncServer.substring(0, vncServer.indexOf(":"));
		var vncURL = "http://" + vncServer + ":" + vncPort + "/";
		document.getElementById("vncServer").src = vncURL;
		
		document.getElementById("vncServerReload").onclick = function () {
			document.getElementById("vncServer").src = vncURL;
		};
	</script>
	<%
}
%>

</dspace:layout>