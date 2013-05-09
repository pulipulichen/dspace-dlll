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
<%!	
public class MetadataElement
{
	private String element;
	private ArrayList<String> qualifiers = new ArrayList<String>();
	
	public MetadataElement(String elementIn)
	{
		this.element = elementIn;
	}
	
	public void pushQualifier(String qualifier)
	{
		this.qualifiers.add(qualifier);
	}
	
	public boolean hasQualifier(String qualifier)
	{
		if (this.qualifiers == null)
			return false;
		
		return (this.qualifiers.indexOf(qualifier) != -1);
	}
	
	public String getElement()
	{
		return this.element;
	}
	
	public String[] getQualifiers()
	{
		if (this.qualifiers.size() == 0)
			return new String[0];
		else if (this.qualifiers.size() == 1)
		{
			if (this.qualifiers.get(0).equals(""))
				return new String[0];
			else
			{
				String[] output = new String[1];
				output[0] = this.qualifiers.get(0);
				return output;
			}
		}
		else
		{
			String[] output = new String[this.qualifiers.size()];
			for (int i = 0; i < this.qualifiers.size(); i++)
				output[i] = this.qualifiers.get(i);
			//return (String[]) this.qualifiers.toArray();
			return output;
		}
	}
}
		

public class MetadataElementCollection
{
	private MetadataField[] fields; 
	//MetadataElement[] elements;
	private ArrayList<MetadataElement> elements = new ArrayList<MetadataElement>();
	
	public MetadataElementCollection(MetadataField[] fieldsIn) throws IOException
	{
		if (fieldsIn != null || fieldsIn.length > 0)	
		{
			this.fields = fieldsIn;
			
			for (int i = 0; i < fieldsIn.length; i++)
			{
				String element = this.fields[i].getElement();
				if (element == null)
					continue;
				
				String qualifier = this.fields[i].getQualifier();
				
				int eIndex = indexOfElement(element);
				
				if (eIndex == -1)
				{
					pushElement(element);
					eIndex = indexOfElement(element);
				}
				
				if (eIndex != -1)
				{
					MetadataElement e = (MetadataElement) this.elements.get(eIndex);
					if (qualifier != null && e.hasQualifier(qualifier) == false)
						e.pushQualifier(qualifier);
					else if (qualifier == null && e.hasQualifier(qualifier) == false)
						e.pushQualifier("");
				}	
			}
			
		}
	}
	
	public int indexOfElement(String element)
	{
		int index = -1;
		if (this.elements == null)
			return index;
		
		for (int i = 0; i < this.elements.size(); i++)
		{
			MetadataElement e = (MetadataElement) this.elements.get(i);
			if (e.getElement().equals(element) == true)
			{
				index = i;
				break;
			}
		}
		
		return index;
	}
	
	public void pushElement(String element) throws IOException
	{
		if (element == null)
			return;
		
		MetadataElement e = new MetadataElement(element);
		
		this.elements.add(e);
		//this.elements.add(element);
	}
	
	public MetadataElement[] getElements()
	{
		/*
		String[] elementAry = new String[this.elements.size()];
		for (int i = 0; i < this.elements.size(); i++)
		{
			elementAry[i] = this.elements.eq(i).getElement();
		}
		return elementAry;
		*/
		MetadataElement[] elementAry = new MetadataElement[this.elements.size()];
		for (int i = 0; i < this.elements.size(); i++)
		{
			elementAry[i] = (MetadataElement) this.elements.get(i);
		}
		return elementAry;
	}
}
%>
<%
Context context = new Context();
MetadataSchema[] schemas = MetadataSchema.findAll(context);
try
{
	String callback = request.getParameter("callback");
	
	String metadataData = "";
	
	for (int s = 0; s < schemas.length; s++)
	{
		if (s > 0)
			metadataData = metadataData + "\n,";
		metadataData = metadataData + "\""+schemas[s].getName()+"\": {";
		
		int schemaID = schemas[s].getSchemaID();
		
		MetadataField[] fields = MetadataField.findAllInSchema(context, schemaID);
		MetadataElementCollection elementCollection = new MetadataElementCollection(fields);
		MetadataElement[] elements = elementCollection.getElements();
		//out.print(elements.length);
		for (int e = 0; e < elements.length; e++)
		{
			if (e > 0)
				metadataData = metadataData + "\n\t,";
			metadataData = metadataData + " \""+elements[e].getElement()+"\": [";
			
			String[] qualifiers = elements[e].getQualifiers();
			//out.print(qualifiers.length);
			for (int q = 0; q < qualifiers.length; q++)
			{
				if (q > 0)
					metadataData = metadataData + " ,";
				metadataData = metadataData + "\""+qualifiers[q]+"\"";
			}
			metadataData = metadataData + "]";
		}
		metadataData = metadataData + "}";
	}
	out.print(callback + "({metadataData: {"+metadataData+"}});");
} catch (Exception e) { 
	//out.print("error" + e);
	//e.printStackTrace();
}
%>
<%--
/*
	"dc": {
		"contributor": [
			"",
			"advisor",
			"author",
			"editor", 
			"illustrator"
		],
		"coverage": [
			"spatial",
			"temporal",
			"creator"
		],
		"type": []
	},
	"test": {
		"field1": [],
		"field2": []
	}
};	
*/ --%>