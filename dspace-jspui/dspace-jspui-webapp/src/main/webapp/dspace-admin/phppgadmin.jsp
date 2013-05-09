<%-- 
	phppgadmin.jsp

//語系檔備份：
jsp.layout.navbar-admin.phppgadmin = \u7ba1\u7406\u8cc7\u6599\u5eab

jsp.dspace-admin.phppgadmin.title = \u7ba1\u7406\u8cc7\u6599\u5eab
jsp.dspace-admin.phppgadmin.heading = \u7ba1\u7406\u8cc7\u6599\u5eab
jsp.dspace-admin.phppgadmin.miss-config.heading = \u5c1a\u672a\u8a2d\u5b9a\u8cc7\u6599\u5eab\u7db2\u9801\u7ba1\u7406\u4ecb\u9762
jsp.dspace-admin.phppgadmin.miss-config.help1 = \u8acb\u8a2d\u5b9a\u60a8\u4f3a\u670d\u5668\u4e0a\u7684phpPgAdmin\uff0c\u4e26\u5728
jsp.dspace-admin.phppgadmin.miss-config.help2 = \u7576\u4e2d\u52a0\u5165\u300cphppgadmin.url = http://localhost/phppgadmin\u300d\u7684\u8a2d\u5b9a\uff0c\u5176\u4e2d\u300chttp://localhost/phppgadmin\u300d\u5fc5\u9808\u66ff\u63db\u6210\u60a8\u8cc7\u6599\u5eab\u7db2\u9801\u7ba1\u7406\u4ecb\u9762\u7684\u7db2\u5740\u3002
jsp.dspace-admin.phppgadmin.open = \u958b\u555f
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%
	//String configName = "phppgadmin.url";
	//String phppgadminURL = (String) ConfigurationManager.getProperty(configName);
	
	String phppgadminURL = (String) "http://"+request.getServerName()
		+ ":" + ConfigurationManager.getProperty("http.port", "50080")
		+ ConfigurationManager.getProperty("phppgadmin.url", "/phpPgAdmin");
%>

<%-- <dspace:layout titlekey="管理資料庫" --%>
<dspace:layout titlekey="jsp.dspace-admin.phppgadmin.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin">

<table width="95%">
    <tr>
      <td align="left">
        <%-- <h1>News Editor</h1> --%>
        <h1>
			<fmt:message key="jsp.dspace-admin.phppgadmin.heading"/>
			<%-- 管理資料庫 --%>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#vncserver" %>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

<table class="miscTable" align="center" width="80%">
            <tbody><tr>
    <th id="t3" class="evenRowOddCol" width="30%">
    	<label for="phppgadmin">
    		<fmt:message key="jsp.dspace-admin.phppgadmin.phppgadmin-label"/>
			<%-- phpPgAdmin資料庫管理系統 --%>
    	</lable>
    </th>
    <td headers="t3" class="evenRowEvenCol">
<%
if (phppgadminURL == null)
{
	%>
	<h2>
		<fmt:message key="jsp.dspace-admin.phppgadmin.miss-config.heading"/>
		<%-- 尚未設定資料庫網頁管理介面 --%>
	</h2>
	<div>
		<fmt:message key="jsp.dspace-admin.phppgadmin.miss-config.help1"/>
		<%-- 請設定您伺服器上的phpPgAdmin，並在 --%>
		<a href="<%= request.getContextPath() %>/dspace-admin/config-edit">
			<fmt:message key="jsp.layout.navbar-admin.config-edit"/>
			<%-- 編輯設定檔 --%>
		</a>
		<fmt:message key="jsp.dspace-admin.phppgadmin.miss-config.help2"/>
		<%-- 當中加入「phppgadmin.url = http://localhost/phppgadmin」的設定，其中「http://localhost/phppgadmin」必須替換成您資料庫網頁管理介面的網址。 --%>
		</div>
	<%
}
else
{
	%>
		<button type="button" onclick="window.open('<%= phppgadminURL %>', 'phppgadmin')">
			<fmt:message key="jsp.dspace-admin.phppgadmin.open"/>
			<%-- 開啟 --%>
		</button>
	<%
}
%>
	</td>
	<tr>
				<th id="t3" class="oddRowOddCol" width="30%">
					<label for="proxool">
						<fmt:message key="jsp.dspace-admin.phppgadmin.proxool-label"/>
						<%-- Proxool連線統計 --%>
					</label>
				</th>
		<td headers="t3" class="oddRowEvenCol">
		<button type="button" onclick="window.open('<%= request.getContextPath() %>/proxool-admin', 'proxool')">
			<fmt:message key="jsp.dspace-admin.phppgadmin.open"/>
			<%-- 開啟 --%>
		</button>
	</td>
	</tr>
	</table>
</dspace:layout>