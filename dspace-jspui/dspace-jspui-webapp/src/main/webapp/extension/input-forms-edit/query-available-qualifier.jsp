<%@ page contentType="application/x-javascript; charset=utf-8" language="java" errorPage="" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="org.dspace.content.MetadataSchema" %>
<%@ page import="org.dspace.content.MetadataField" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="java.util.ArrayList" %>
<%
	String q = request.getParameter("q");
	ArrayList<String> output = new ArrayList<String>();
	Context context = UIUtil.obtainContext(request);
	
	String schema = request.getParameter("schema");
	String element = request.getParameter("element");
	if (element != null && element.equals("") == true)
		element = null;
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
		String qualifier = fields[i].getQualifier();
		if (qualifier == null)
			continue;
		
		String e = fields[i].getElement();
		if (e != null
			&& e.equals(element))
			output.add(qualifier);
	}
	
	String o = "";
	for (int i = 0; i < output.size(); i++)
	{	
		if (i > 0)
			o = o + ",";
		o = o + "\"" + output.get(i) + "\"";
	}
	o = "[" + o + "]";
	String callback = request.getParameter("callback");
	if (callback != null)
		o = callback + "(" + o + ");";	
	out.print(o);
%>
