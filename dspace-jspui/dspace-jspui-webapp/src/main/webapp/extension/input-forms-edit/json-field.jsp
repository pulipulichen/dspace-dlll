<%@ page contentType="application/x-javascript; charset=utf-8" language="java" errorPage="" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="org.dspace.content.MetadataSchema" %>
<%@ page import="org.dspace.content.MetadataField" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.dspace.app.util.EscapeUnescape" %>
<%

Context context = UIUtil.obtainContext(request);
ArrayList<String> matchField = new ArrayList<String>();

String schema = request.getParameter("schema");
MetadataSchema[] matchSchema = new MetadataSchema[0];
if (schema != null && schema.equals("") == false)
{
	matchSchema = new MetadataSchema[1];
	matchSchema[0] = MetadataSchema.find(context, schema);
}
else
	matchSchema = MetadataSchema.findAll(context);

for (int i = 0; i < matchSchema.length; i++)
{
	String schemaName = matchSchema[i].getName();
	int schemaID = matchSchema[i].getSchemaID();
	
	MetadataField[] fields = MetadataField.findAllInSchema(context, schemaID);
	
	for (int f = 0; f < fields.length; f++)
	{
		String element = fields[f].getElement();
		String qualifier = fields[f].getQualifier();
		if (qualifier == null) qualifier = "";
		String note = fields[f].getScopeNote();
		if (note == null) note = "";
			note = EscapeUnescape.escape(note);
		
		String output = "[\"" + schemaName + "\","
			+ "\"" + element + "\","
			+ "\"" + qualifier + "\","
			+ "\"" + note + "\"]";
		matchField.add(output);
	}
}

String output = "";
for (int i = 0; i < matchField.size(); i++)
{
	if (i > 0)
		output = output + ",";
	String f = matchField.get(i);
	output = output + f;
}
output = "[" + output + "]";

String callback = request.getParameter("callback");
if (callback != null)
	output = callback + "("+output+");";

out.print(output);
%>
