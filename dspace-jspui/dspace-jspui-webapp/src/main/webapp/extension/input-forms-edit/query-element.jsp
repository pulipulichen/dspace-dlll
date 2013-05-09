<%@ page contentType="application/x-javascript; charset=utf-8" language="java" errorPage="" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="org.dspace.content.MetadataSchema" %>
<%@ page import="org.dspace.content.MetadataField" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="java.util.ArrayList" %>
<%
	String q = request.getParameter("q");
	if (q != null)
	{
		Context context = UIUtil.obtainContext(request);
		/*
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
		*/
		
		ArrayList<String> matchElements = new ArrayList<String>();
		
		String schema = request.getParameter("schema");
		MetadataSchema matchSchema = null;
		if (schema != null && schema.equals("") == false)
		{
			matchSchema = MetadataSchema.find(context, schema);
		}
		
		MetadataField[] fields = new MetadataField[0];
		if (matchSchema != null)
		{
			int schemaID = matchSchema.getSchemaID();
			fields = MetadataField.findAllInSchema(context, schemaID);
		}
		else
		{
			fields = MetadataField.findAll(context);
		}
		
		for (int i = 0; i < fields.length; i++)
		{
			String element = fields[i].getElement();
			if (element.indexOf(q) != -1
				&& matchElements.indexOf(element) == -1)
				matchElements.add(element);
		}
		
		for (int i = 0; i < matchElements.size(); i++)
		{
			out.println(matchElements.get(i));
		}
	}
%>
