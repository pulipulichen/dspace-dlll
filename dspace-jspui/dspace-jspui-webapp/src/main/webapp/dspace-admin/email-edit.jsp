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
<%
	String[] emails = (String[]) request.getAttribute("emailName");
	String name = (String) request.getAttribute("name");
	String text = (String) request.getAttribute("text");
	
	boolean saved = (request.getAttribute("saved") != null);
%>

<%-- <dspace:layout titlekey="電子郵件設定" --%>
<dspace:layout titlekey="jsp.dspace-admin.email-edit.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin">
<style type="text/css">
form.email-select-form,
form.email-edit-form {
	text-align:center;
}
form.email-edit-form textarea.email-text {
	width: 85%;
	height: 15em;
	display: block;
}
</style>

<table width="95%">
    <tr>
      <td align="left">
        <h1>
			<fmt:message key="jsp.dspace-admin.email-edit.heading"/>
			<%-- 電子郵件設定 --%>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#editemail" %>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

<form action="" method="post" class="email-select-form">
	<label for="name"> 
		<%-- 請選擇要編輯的電子郵件: --%>
		<fmt:message key="jsp.dspace-admin.email-edit.select-load-heading"/>
		<select name="name">
			<%
				for (int i = 0; i < emails.length; i++)
				{
					String key = "jsp.dspace-admin.email-edit.emails." + emails[i];
					String selected = "";
					if (emails[i].equals(name) == true)
						selected = " selected=\"selected\"";
					
					%>
					<option value="<%= emails[i] %>"<%= selected %>><fmt:message key="<%= key %>"/></option>
					<%
				}
			%>
		</select>
	</label>
	<input type="hidden" name="submit_action" value="load" />
	<button type="submit">
		<%-- 開啟 --%>
		<fmt:message key="jsp.dspace-admin.general.open"/>
	</button>
</form>

<%
	if (name != null && text != null)	
	{
		String key = "jsp.dspace-admin.email-edit.emails." + name;
		%>
		<hr width="85%" />
	<h2><fmt:message key="<%= key %>"/></h2>
<%
	if (saved)
	{
		%>
		<div class="dspace-admin-alert">
			
			<%-- {0} 已經儲存 --%>
			<fmt:message key="jsp.dspace-admin.email-edit.saved">
				<fmt:param><fmt:message key="<%= key %>"/></fmt:param>
			</fmt:message>
		</div>
		<%
	}	
%>

<script type="text/javascript">
function submitAlert()
{
	//if (window.confirm("此動作不能復原，您確定要繼續？"))
	if (window.confirm("<fmt:message key="jsp.dspace-admin.email-edit.submit-alert" />"))
		return true;
	else
		return false;
}
</script>
		
<form action="" method="post" class="email-edit-form" onsubmit="return submitAlert();">
	<input type="hidden" name="name" value="<%= name %>" />
	<input type="hidden" name="submit_action" value="save" />
	
	<center>
		<textarea class="email-text" name="text"><%= text %></textarea>
	</center>

	
	    <center>
        <table width="70%">
            <tr>
                <td align="left">        				
					<button type="submit">
						<%-- 儲存 --%>
						<fmt:message key="jsp.dspace-admin.general.update"/>
					</button>
                </td>
                <td align="right">
                    <input type="button" name="submit_cancel_policy" value="<fmt:message key="jsp.dspace-admin.general.cancel"/>" 
            			onclick="location.href='<%= request.getContextPath() %>/dspace-admin/email-edit'" />
                </td>
            </tr>
        </table>
    </center>  
	
</form>
		<%
	}
%>
</dspace:layout>