<%@ page contentType="application/x-javascript; charset=utf-8" language="java" errorPage="" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.content.MetadataSchema" %>
<%@ page import="org.dspace.content.MetadataField" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.io.IOException" %>
<%@ page import="org.dspace.core.ConfigurationManager"%>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="org.dspace.authorize.AuthorizeManager" %>
<%

Context context = UIUtil.obtainContext(request);
boolean isAdmin = AuthorizeManager.isAdmin(context);

String state = "false";
if (isAdmin == true)
{
	state = "true";
	boolean updated = false;
	String schema = request.getParameter("schema");
	String element = request.getParameter("element");
	MetadataSchema metaSchema = null;
	if (schema != null && element != null)
	{
		String namespace = request.getParameter("namespace");
		if (namespace == null)
		{
			namespace = ConfigurationManager.getProperty("dspace.hostname");
			String needle = "http://";
			
			if (namespace.indexOf("http://") == -1)
				namespace = "http://" + namespace;
			if (namespace.substring(namespace.length()-1, namespace.length())
					.equals("/") == false)
				namespace = namespace + "/";
			namespace = namespace + schema;
		}
		
		MetadataSchema matchSchema = MetadataSchema.find(context, schema);
		if (matchSchema == null)	//如果是空的，則新增
		{
			MetadataSchema newMetadataSchema = new MetadataSchema(namespace, schema);
			newMetadataSchema.create(context);
			//context.complete();
			context.commit();
			metaSchema = newMetadataSchema;
			updated = true;
			state = "true";
		}
		else
			metaSchema = matchSchema;
		
	}
	if (metaSchema != null && element != null)
	{
		if (element != null)
		{
			int schemaID = metaSchema.getSchemaID();
			String qualifier = request.getParameter("qualifier");
			String note = request.getParameter("note");
			if (qualifier != null && qualifier.equals(""))
				qualifier = null;
			if (note == null)
				note = "";
			
			MetadataField matchField = MetadataField.findByElement(context, schemaID, element, qualifier);
			
			if (matchField == null)
			{
				MetadataField newField = new MetadataField(metaSchema, element, qualifier, note);
				newField.create(context);
				//context.complete();
				context.commit();
				updated = true;
				//state = "create_field";
				state = "true";
			}
		}	//if (element != null)
	}	//if (metaSchema != null)
}

//---------------------------------------------

String output = "{state: \""+state+"\"}";

String callback = request.getParameter("callback");
if (callback != null)
	output = callback + "("+output+");";

out.print(output);
%>