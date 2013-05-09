<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.storage.rdbms.SQLQuery" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.lang.Thread" %>
<%@ page import="org.dspace.app.util.FileUtil" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%!	
static class FilterMediaUtil
{	
	static public String getLink(HttpServletRequest request, String i, String parameter)
	{
		String link = request.getContextPath() 
			+ "/dspace-admin/filter-media"
			+ "?i=" + i;
		
		if (parameter != null)
			link = link + "&" + parameter;
		
		return link;
	}
	
	static public String getLink(HttpServletRequest request, Bitstream bs, String parameter)
	{
		if (bs == null)
			return null;
		else
			return getLink(request, Integer.toString(bs.getID()), parameter);
	}
	static public String getLink(HttpServletRequest request, Bitstream bs)
	{
		return getLink(request, bs, "f=true");
	}
	
	static public String getLink(HttpServletRequest request, Item item, String parameter)
	{
		if (item == null)
			return null;
		else
			return getLink(request, item.getHandle(), parameter);
	}
	static public String getLink(HttpServletRequest request, Item item)
	{
		return getLink(request, item, "f=true");
	}
}	
%>