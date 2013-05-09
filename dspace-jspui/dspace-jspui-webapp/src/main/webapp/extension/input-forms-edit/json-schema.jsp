<%@ page contentType="application/x-javascript; charset=utf-8" language="java" errorPage="" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="org.dspace.content.MetadataSchema" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="java.util.ArrayList" %>
<%
	ArrayList<String> matchSchemas = new ArrayList<String>();
	
	Context context = UIUtil.obtainContext(request);
	MetadataSchema[] allSchemas = MetadataSchema.findAll(context);		
	for (int i = 0; i < allSchemas.length; i++)
	{
		String shortID = allSchemas[i].getName();
		String namespace = allSchemas[i].getNamespace();
		String o = "[\"" + shortID + "\", \"" + namespace + "\"]";
			matchSchemas.add(o);
	}
	
	String output = "";		
	for (int i = 0; i < matchSchemas.size(); i++)
	{
		//out.println(matchSchemas.get(i));
		if (i > 0)
			output = output + ",";
		output = output + matchSchemas.get(i);
	}
	
	output = "[" + output + "]";
	
	String callback = request.getParameter("callback");
	if (callback != null)
		output = callback + "("+output+");";
	
	out.print(output);
%>
