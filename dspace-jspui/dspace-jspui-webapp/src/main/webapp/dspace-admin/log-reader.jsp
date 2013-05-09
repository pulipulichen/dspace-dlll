<%-- 
	email-edit.jspadmin.config-edit = \u7de8\u8f2f\u8a2d\u5b9a\u6a94

--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.Constants" %>
	
<%@ page import="org.dspace.app.util.FileUtil" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.util.FileUtil" %>
<%@ page import="java.io.File" %>
<%@ page import="org.dspace.core.Utils" %>
	
<%
	String[] logFiles = (String[]) request.getAttribute("logFiles");
	String logName = (String) request.getAttribute("logName");
	String logText = (String) request.getAttribute("logText");
	int pages = (Integer) request.getAttribute("pages");
	int pageNow = (Integer) request.getAttribute("page");
	//int pageNow = UIUtil.getIntParameter(request, "page", -1);
	
%>

<%-- <dspace:layout title="記錄檔查閱" --%>
<dspace:layout titlekey="jsp.dspace-admin.log-reader.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin">
<style type="text/css">
</style>

<table width="95%">
    <tr>
      <td align="left">
        <h1>
			<fmt:message key="jsp.dspace-admin.log-reader.title"/>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#logreader" %>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>



<form action="" method="name" class="select-form">
	<div class="help">
	<label for="log"> 
			<fmt:message key="jsp.dspace-admin.log-reader.log-select"/>
			<%-- 請選擇要檢視的記錄檔: --%>
			<select id="log" name="log">
				<%
					for (int i = 0; i < logFiles.length; i++)
					{
						if (logFiles[i].equals(logName) == true)
							continue;
						
						%>
						<option value="<%= logFiles[i] %>"><%= logFiles[i] %></option>
						<%
					}
				%>
			</select>
	</label>
	<button type="submit">
		<%-- 開啟 --%>
		<fmt:message key="jsp.mydspace.general.open"/>
	</button>
	</div>
</form>

<form action="" method="name" class="select-form">
	<h2><%= logName %></h2>
	
	<div class="help">
	<label for="page"> 
			
			<input type="hidden" name="log" value="<%= logName %>" />
		<%
			if (pages > 0)
			{
				%>
			<select id="page" name="page">
				<%
					for (int i = pages; i > 0; i--)
					{
						String selected = "";
						if (i == pageNow)
							selected = "selected=\"selected\"";
						
						%>
						<option value="<%= i+"" %>" <%= selected %>><%= i+"" %><%-- 頁 --%><fmt:message key="jsp.dspace-admin.log-reader.page"/>
						</option>
						<%
					}
				%>
			</select>
				<%
			}
		%>
			
	</label>
	<%
			if (pages > 0)
			{
				%>
	<button type="submit">
		<fmt:message key="jsp.dspace-admin.log-reader.change-page"/>
		<%-- 換頁 --%>
	</button>
	<button type="button" onclick="location.reload();">
		<fmt:message key="jsp.dspace-admin.log-reader.reload"/>
	</button>
				<%
			}
	%>
	<button type="button" onclick="location.href='#bottom'">
		<%-- 移至頁尾 --%>
		<fmt:message key="jsp.dspace-admin.log-reader.go.bottom"/>
	</button>
	</div>
</form>
<pre style="font-size: small"><%
	if (logText == null || logText.equals(""))
	{
		%>
		<%-- <em>沒有此記錄檔，或是記錄檔中沒有資料</em> --%>
		<fmt:message key="jsp.dspace-admin.log-reader.null"/>
		<%
	}
	else
	{
		out.println(Utils.addEntities(logText));
	}
	%></pre>

<form action="" method="name" class="select-form">
	<div class="help">
	<label for="page2"> 
			
			<input type="hidden" name="log" value="<%= logName %>" />
		<%
			if (pages > 0)
			{
				%>
			<select id="page2" name="page">
				<%
					for (int i = pages; i > 0; i--)
					{
						String selected = "";
						if (i == pageNow)
							selected = "selected=\"selected\"";
						
						%>
						<option value="<%= i+"" %>" <%= selected %>><%= i+"" %><%-- 頁 --%><fmt:message key="jsp.dspace-admin.log-reader.page"/>
						</option>
						<%
					}
				%>
			</select>
				<%
			}
		%>
			
	</label>
	<%
			if (pages > 0)
			{
				%>
	<button type="submit">
		<fmt:message key="jsp.dspace-admin.log-reader.change-page"/>
		<%-- 換頁 --%>
	</button>
	<button type="button" onclick="location.reload();">
		<fmt:message key="jsp.dspace-admin.log-reader.reload"/>
	</button>
				<%
			}
	%>
	<button type="button" onclick="scrollTo(scrollX, 0)">
		<%-- 移至頁首 --%>
		<fmt:message key="jsp.dspace-admin.log-reader.go.top"/>
	</button>

	<a name="bottom" id="bottom"></a>
	</div>
</form>
</dspace:layout>