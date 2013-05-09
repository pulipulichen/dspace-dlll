package org.dspace.app.webui.util;
import javax.servlet.ServletException;
import javax.servlet.jsp.JspWriter;
import java.io.IOException;
import javax.servlet.http.HttpServletRequest;
import org.dspace.content.*;

public class ItemEditButton
{
	public static void print(JspWriter out, boolean admin_button, String innerTEXT, String schema, String element, String qualifier, String handle)
	{

		if(admin_button)
		{
			try
			{
				if(qualifier!=null)
					out.print("<button class=\"item-edit-button\" type=\"button\" onclick=\"goEditItem(\'"+schema+"\',\'"+element+"\',\'"+qualifier+"\')\" >"+innerTEXT+"</button>");
				else
					out.print("<button class=\"item-edit-button\" type=\"button\" onclick=\"goEditItem(\'"+schema+"\',\'"+element+"\')\" >"+innerTEXT+"</button>");
			}
			catch (Exception e) 
			{
				e.printStackTrace();
				return;
			}
		}
		else
			return;
	}
	
	 public static String getString(boolean admin_button, String innerTEXT, String schema, String element, String qualifier, String handle)
	{
		if(admin_button)
		{
			try
			{
				if(qualifier!=null)
					return "<button class=\"item-edit-button\" type=\"button\" onclick=\"goEditItem(\'"+schema+"\',\'"+element+"\',\'"+qualifier+"\')\" >"+innerTEXT+"</button>";
				else
					return "<button class=\"item-edit-button\" type=\"button\" onclick=\"goEditItem(\'"+schema+"\',\'"+element+"\')\" >"+innerTEXT+"</button>";
			}
			catch (Exception e) 
			{
				e.printStackTrace();
			}
		}
		
		return "";
	}
	
	public static String getString(HttpServletRequest request, boolean admin_button, String innerTEXT, String handle)
	{
		if(admin_button)
		{
			return "<button class=\"item-edit-button\" type=\"button\" onclick=\"location.href=\'"+request.getContextPath()+"/tools/edit-item?handle="+handle+"\'\" >"+innerTEXT+"</button>";
		}
		return "";
	}
	
	public static String getJavaScript()
	{
		String output = "<script type=\"text/javascript\">\n"
	+ "function goEditItem(schema, element, qualifier)\n"
	+ "{\n"
	+ "	\n"
	+ "	var href = location.href;\n"
	+ "	\n"
	+ "	var basePath = href.substring(0, href.indexOf(\"/handle/\"));\n"
	+ "		   \n"
	+ "	var search = location.search; //?tb=1,2,3,....\n"
	+ "	if (search == \"\")\n"
	+ "		var handle = href.substring(href.indexOf(\"/handle/\")+(\"/handle/\").length);\n"
	+ "	else\n"
	+ "		var handle = href.substring(href.indexOf(\"/handle/\")+(\"/handle/\").length,href.indexOf(\"?\"));\n"
	+ "	\n"
	+ "	var editItemPath = \"/tools/edit-item\";\n"
	+ "	if (search == \"\")\n"
	+ "		editItemPath = editItemPath + \"?\";\n"
	+ "	else\n"
	+ "		editItemPath = editItemPath + search + \"&\";\n"
	+ "	\n"
	+ "	if (typeof(qualifier) == \"undefined\")\n"
	+ "		location.href = basePath + editItemPath + \"handle=\"+handle+\"&fieldSchema=\"+schema+\"&fieldElement=\"+element;\n"
	+ "	else\n"
	+ "		location.href = basePath + editItemPath + \"handle=\"+handle+\"&fieldSchema=\"+schema+\"&fieldElement=\"+element+\"&fieldQualifier=\"+qualifier;\n"
	+ "}\n"
	+ "</script>\n";
		return output;
	}
	
	public static void printJavaScript(JspWriter out) throws IOException
	{
		String output = "<script type=\"text/javascript\">\n"
	+ "function goEditItem(schema, element, qualifier)\n"
	+ "{\n"
	+ "	\n"
	+ "	var href = location.href;\n"
	+ "	\n"
	+ "	var basePath = href.substring(0, href.indexOf(\"/handle/\"));\n"
	+ "		   \n"
	+ "	var search = location.search; //?tb=1,2,3,....\n"
	+ "	if (search == \"\")\n"
	+ "		var handle = href.substring(href.indexOf(\"/handle/\")+(\"/handle/\").length);\n"
	+ "	else\n"
	+ "		var handle = href.substring(href.indexOf(\"/handle/\")+(\"/handle/\").length,href.indexOf(\"?\"));\n"
	+ "	\n"
	+ "	var editItemPath = \"/tools/edit-item\";\n"
	+ "	if (search == \"\")\n"
	+ "		editItemPath = editItemPath + \"?\";\n"
	+ "	else\n"
	+ "		editItemPath = editItemPath + search + \"&\";\n"
	+ "	\n"
	+ "	if (typeof(qualifier) == \"undefined\")\n"
	+ "		location.href = basePath + editItemPath + \"handle=\"+handle+\"&fieldSchema=\"+schema+\"&fieldElement=\"+element;\n"
	+ "	else\n"
	+ "		location.href = basePath + editItemPath + \"handle=\"+handle+\"&fieldSchema=\"+schema+\"&fieldElement=\"+element+\"&fieldQualifier=\"+qualifier;\n"
	+ "}\n"
	+ "</script>\n";
		out.print(output);
	}
	
	public static String newItem(HttpServletRequest request, boolean admin_button, String innerTEXT, Collection collection)
	{
		if (admin_button == false)
			return "";
		return "<button class=\"item-add-button item-edit-button\" type=\"button\" onclick=\"location.href='"+request.getContextPath()+"/submit?collection="+collection.getID()+"'\">"+innerTEXT+"</button>";
	}
}