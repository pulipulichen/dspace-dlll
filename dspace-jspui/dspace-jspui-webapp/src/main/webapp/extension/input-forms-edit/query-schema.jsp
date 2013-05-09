<%@ page contentType="application/x-javascript; charset=utf-8" language="java" errorPage="" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="org.dspace.content.MetadataSchema" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="java.util.ArrayList" %>
<%
	String q = request.getParameter("q");
	if (q != null)
	{
		Context context = UIUtil.obtainContext(request);
		MetadataSchema[] allSchemas = MetadataSchema.findAll(context);
		
		ArrayList<String> matchSchemas = new ArrayList<String>();
		for (int i = 0; i < allSchemas.length; i++)
		{
			String shortID = allSchemas[i].getName();
			if (shortID.indexOf(q) != -1)
				matchSchemas.add(shortID);
		}
		
		for (int i = 0; i < matchSchemas.size(); i++)
		{
			out.println(matchSchemas.get(i));
		}
	}
%>
