<%--
  - edit-item-form.jsp
  -
  - Version: $Revision: 2218 $
  -
  - Date: $Date: 2007-09-28 06:17:04 -0700 (Fri, 28 Sep 2007) $
  -
  - Copyright (c) 2002, Hewlett-Packard Company and Massachusetts
  - Institute of Technology.  All rights reserved.
  -
  - Redistribution and use in source and binary forms, with or without
  - modification, are permitted provided that the following conditions are
  - met:
  -
  - - Redistributions of source code must retain the above copyright
  - notice, this list of conditions and the following disclaimer.
  -
  - - Redistributions in binary form must reproduce the above copyright
  - notice, this list of conditions and the following disclaimer in the
  - documentation and/or other materials provided with the distribution.
  -
  - - Neither the name of the Hewlett-Packard Company nor the name of the
  - Massachusetts Institute of Technology nor the names of their
  - contributors may be used to endorse or promote products derived from
  - this software without specific prior written permission.
  -
  - THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  - ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  - LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  - A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  - HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  - INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  - BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
  - OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  - ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
  - TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
  - USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  - DAMAGE.
  --%>

<%--
  - Show form allowing edit of collection metadata
  -
  - Attributes:
  -    item        - item to edit
  -    collections - collections the item is in, if any
  -    handle      - item's Handle, if any (String)
  -    dc.types    - MetadataField[] - all metadata fields in the registry
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.util.Set" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.io.File" %>
<%@ page import="javax.xml.parsers.*" %>
<%@ page import="java.lang.Exception" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.ServletException" %>
<%@ page import="javax.xml.xpath.*" %>
<%@ page import="org.xml.sax.SAXException" %>
<%@ page import="org.w3c.dom.*" %>

<%@ page import="org.dspace.content.MetadataField" %>
<%@ page import="org.dspace.app.webui.servlet.admin.AuthorizeAdminServlet" %>
<%@ page import="org.dspace.app.webui.servlet.admin.EditItemServlet" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Bitstream" %>
<%@ page import="org.dspace.content.BitstreamFormat" %>
<%@ page import="org.dspace.content.Bundle" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.DCDate" %>
<%@ page import="org.dspace.content.DCValue" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.app.util.DCInput" %>
<%@ page import="org.dspace.app.util.DCInputsReader" %>
<%@ page import="org.dspace.app.util.DCInputSet" %>
<%@ page import="org.dspace.app.util.SubmissionConfigReader" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.app.util.SubmissionConfig" %>
<%@ page import="org.dspace.app.util.SubmissionStepConfig" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>
<%@ page import="org.dspace.app.webui.util.JSPManager" %>
<%!

public class EditItemForm
{
	public static final String DEFAULT_COLLECTION = "default";

    /** Prefix of the item submission definition XML file */
    static final String SUBMIT_DEF_FILE_PREFIX = "item-submission";
    
	static final String INPUT_DEF_FILE_PREFIX = "iuput-forms";
	
    /** Suffix of the item submission definition XML file */
    static final String SUBMIT_DEF_FILE_SUFFIX = ".xml";

	/** The fully qualified pathname of the directory containing the Item Submission Configuration file */
    private String configDir = ConfigurationManager.getProperty("dspace.dir")
            + File.separator + "config" + File.separator;
			
	String fileName = configDir + SUBMIT_DEF_FILE_PREFIX + SUBMIT_DEF_FILE_SUFFIX;
	
	String inputFormsName = configDir + INPUT_DEF_FILE_PREFIX + SUBMIT_DEF_FILE_SUFFIX;
	
	private Document itemSubmissionDoc;
	private String stepXPath = "/item-submission/submission-definitions/submission-process[@name='traditional']/step/heading/text()";
	private String inputFormsXPath = "/input-forms/form-definitions/form [@name='getcdb_good']/field/label/text()";
	private int describePos;
	
	//String collectionHandle = collections[i].getHandle();
	
	
		
	public EditItemForm() throws ServletException
	{
	   String uri = "file:" + new File(fileName).getAbsolutePath();
		try
        {
            DocumentBuilderFactory factory = DocumentBuilderFactory
                    .newInstance();
            factory.setValidating(false);
            factory.setIgnoringComments(true);
            factory.setIgnoringElementContentWhitespace(true);

            DocumentBuilder db = factory.newDocumentBuilder();
            Document doc = db.parse(uri);
			this.itemSubmissionDoc = doc;
            //doNodes(doc);
			
			String[] stepHeadings = locateXPath(stepXPath);
			
			for (int i = 0; i < stepHeadings.length; i++)
			{
				if (stepHeadings[i].equals("submit.progressbar.describe"))
				{
					this.describePos = i + 1;
					break;
				}
			}
        }
        catch (FactoryConfigurationError fe)
        {
            throw new ServletException (
                    "Cannot create Item Submission Configuration parser", fe);
        }
        catch (Exception e)
        {
            throw new ServletException(
                    "Error creating Item Submission Configuration: " + e);
        }
	}
	
	
	
	public String[] locateXPath(String Xpath)
		throws XPathExpressionException, ServletException
	{	
		Object result;
		try
		{
			XPathFactory factory = XPathFactory.newInstance();
			XPath xpath = factory.newXPath();
			XPathExpression expr = xpath.compile(Xpath);
			
			result = expr.evaluate(itemSubmissionDoc, XPathConstants.NODESET);
		}
		catch (Exception e)
		{
			throw new ServletException("Error create XPathExpression: "+e);
		}
		
		NodeList nodes = (NodeList) result;
		String[] valueAry = new String[nodes.getLength()];
		for (int i = 0; i < nodes.getLength(); i++) {
			valueAry[i] = nodes.item(i).getNodeValue();
		}
		
		return valueAry;
	}
	public String[] getPageHeadings(PageContext pageContext, String collectionHandle) throws ServletException
	{
		DCInputsReader dcInputsReader = new DCInputsReader();
		int pages = dcInputsReader.getNumberInputPages(collectionHandle);
		String[] pageHeadingAry = new String[pages];
		
		for(int i = 0 ; i < pages; i++)
		{
			String key = "jsp.submit.progressbar.describe"+ describePos +"."+ (i+1);
			pageHeadingAry[i] = LocaleSupport.getLocalizedMessage(pageContext, key);
		}
		return pageHeadingAry;
	}
	
	public String getFormName(String collectionHandle)
	{
		String formName = null;
		try
		{
			DCInputsReader dcInputsReader = new DCInputsReader();
			DCInputSet inputSet = dcInputsReader.getInputs(collectionHandle);
			formName = inputSet.getFormName();
		}
		catch (ServletException e) {}
		
		return formName;
	}
}

//------------------------------------------------------------------------
String contextPath = "";
	String doControlledVocabulary(String fieldName, PageContext pageContext, String vocabulary) 
    {
    	String link = "";
    	boolean enabled = ConfigurationManager.getBooleanProperty("webui.controlledvocabulary.enable");
    	boolean useWithCurrentField = vocabulary != null && ! "".equals(vocabulary);
    	
        if (enabled && useWithCurrentField) 
        {
        	link = "<br/>" + 
			"<a href='javascript:void(null);' onclick='javascript:popUp(\"" + 
				contextPath + "/controlledvocabulary/controlledvocabulary.jsp?ID=" + 
				fieldName + "&amp;vocabulary=" + vocabulary + "\")'>" +
					"<span class='controlledVocabularyLink'>" + 
						LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.controlledvocabulary") + 
					"</span>" + 
			"</a>";
		} 

		return link;
    }

	boolean hasVocabulary(String vocabulary)
	{
		boolean enabled = ConfigurationManager.getBooleanProperty("webui.controlledvocabulary.enable");
    	boolean useWithCurrentField = vocabulary != null && !"".equals(vocabulary);
    	boolean has = false;
    	
        if (enabled && useWithCurrentField) 
        {
        	has = true;
        }
        return has;
	}
void doOneBox(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary) 
      throws java.io.IOException 
{

      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      String val;

      if (fieldCount == 0)
         fieldCount = 1;

      for (int i = 0; i < fieldCount; i++) 
      {
	 if (i == 0) 
	    sb.append("<tr><td class=\"submitFormLabel\">")
	      .append(label)
	      .append("</td>");
	 else
	    sb.append("<tr><td>&nbsp;</td>");

         if (i < defaults.length)
           val = defaults[i].value.replaceAll("\"", "&quot;");
         else
           val = "";

         sb.append("<td colspan=\"2\"><input type=\"text\" name=\"")
           .append(fieldName);
         if (repeatable && i>0)
           sb.append("_").append(i);
         
         sb.append("\" size=\"30\" value=\"")
           .append(val +"\"")
           //.append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
	   	.append("   />")
	   //.append(doControlledVocabulary(fieldName + (repeatable?"_" + i:""), pageContext, vocabulary))
	   .append("</td>\n");
	   

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input type=\"submit\" name=\"submit_")
	      .append(fieldName)
	      .append("_remove_")
	      .append(i)
//	      .append("\" value=\"Remove This Entry\"/> </td></tr>");
	      .append("\" value=\"")
   	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove"))
   	      .append("\"/> </td></tr>");
	 } 
	 else if (repeatable && i == fieldCount - 1) 
	 {
	    // put a 'more' button next to the last space
	    sb.append("<td><input type=\"submit\" name=\"submit_")
	      .append(fieldName)
//	      .append("_add\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" value=\"")
	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.add"))
	      .append("\"/> </td></tr>");
	 } 
	 else 
	 {
	    // put a blank if nothing else
	    sb.append("<td>&nbsp;</td></tr>");
	 }
      }

      out.write(sb.toString());
    }
void doTextEditor(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary, String sBasePath) 
      throws java.io.IOException 
    {

      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      String val;

      if (fieldCount == 0)
         fieldCount = 1;

      for (int i = 0; i < fieldCount; i++) 
      {
	 if (i == 0) 
	    sb.append("<tr><td class=\"submitFormLabel\">")
	      .append(label)
	      .append("</td>");
	 else
	    sb.append("<tr><td>&nbsp;</td>");

         if (i < defaults.length)
           val = defaults[i].value;
         else
           val = "";

         sb.append("<td colspan=\"2\">");

         String textareaName = fieldName;
         if (repeatable && i>0)
         	 textareaName = textareaName + "_" + i;

         sb.append("<textarea name=\"")
           .append(fieldName);
         if (repeatable && i>0)
           sb.append("_").append(i);
         sb.append("\" rows=\"4\" cols=\"45\"")
           .append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
           .append("   >")
           .append(val)
	   .append("</textarea>")
	   .append(doControlledVocabulary(fieldName + (repeatable?"_" + i:""), pageContext, vocabulary));
	     

	     //FCKeditor ReplaceTextarea
	     
	     sb.append("<script type=\"text/javascript\">\n")
	       .append("	var oFCKeditor = new FCKeditor( \"")
           .append(fieldName);
         if (repeatable && i>0)
           sb.append("_").append(i);
	       sb.append("\" ) ;\n")
		   .append("	oFCKeditor.Config[\"ToolbarStartExpanded\"] = false ;\n")
	       .append("	oFCKeditor.BasePath	= \""+sBasePath+"\" ;\n")
	       .append("	oFCKeditor.ReplaceTextarea() ;\n")
	       .append("</script>\n");

	   sb.append("</td>\n");

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input type=\"submit\" name=\"submit_")
	      .append(fieldName)
	      .append("_remove_")
	      .append(i)
//	      .append("\" value=\"Remove This Entry\"/> </td></tr>");
	      .append("\" value=\"")
   	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove"))
   	      .append("\"/> </td></tr>");
	 } 
	 else if (repeatable && i == fieldCount - 1) 
	 {
	    // put a 'more' button next to the last space
	    sb.append("<td><input type=\"submit\" name=\"submit_")
	      .append(fieldName)
//	      .append("_add\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" value=\"")
	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.add"))
	      .append("\"/> </td></tr>");
	 } 
	 else 
	 {
	    // put a blank if nothing else
	    sb.append("<td>&nbsp;</td></tr>");
	 }
      }

      out.write(sb.toString());
    }	//void doTextEditor()
void doDropDown(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      List valueList, String label) 
      throws java.io.IOException 
    {
      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      StringBuffer sb = new StringBuffer();
      Iterator vals;
      String display, value;
      int j;

      sb.append("<tr><td class=\"submitFormLabel\">")
	.append(label)
	.append("</td>");

      sb.append("<td colspan=\"2\">")
        .append("<select name=\"")
	.append(fieldName)
	.append("\"");
      if (repeatable)
	sb.append(" size=\"6\"  multiple=\"multiple\"");
      sb.append("  >");

      for (int i = 0; i < valueList.size(); i += 2)
      {
         display = (String)valueList.get(i);
	 value = (String)valueList.get(i+1);
	 for (j = 0; j < defaults.length; j++) 
	 {
	     if (value.equals(defaults[j].value))
	         break;
         }
	 sb.append("<option ")
	   .append(j < defaults.length ? " selected=\"selected\" " : "")
	   .append("value=\"")
	   .append(value)
	   .append("\">")
	   .append(display)
	   .append("</option>");
      }

      sb.append("</select></td></tr>");
      out.write(sb.toString());
    }	
void doXMLMetadata(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary,
	  int workspaceItemID, ArrayList nonInternalBistreamsID, boolean hasMultipleFiles, String defaultValue, String basePath) 
      throws java.io.IOException 
    {

      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      String val;

      if (fieldCount == 0)
         fieldCount = 1;

      for (int i = 0; i < fieldCount; i++) 
      {
	 if (i == 0) 
	    sb.append("<tr><td class=\"submitFormLabel\">")
	      .append(label)
	      .append("</td>");
	 else
	    sb.append("<tr><td>&nbsp;</td>");

         if (i < defaults.length)
           val = defaults[i].value;
         else if (defaultValue != null)
           val = defaultValue;
		 else
		   val = "";
		 
         sb.append("<td colspan=\"2\">");

         String textareaName = fieldName;
         if (repeatable && i>0)
         	 textareaName = textareaName + "_" + i;

         sb.append("<textarea id=\""+textareaName+"\" name=\"")
           .append(fieldName);
         if (repeatable && i>0)
           sb.append("_").append(i);
         sb.append("\" rows=\"4\" cols=\"45\"")
           .append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
           .append("   >")
           .append(val)
	   .append("</textarea>")
	   .append(doControlledVocabulary(fieldName + (repeatable?"_" + i:""), pageContext, vocabulary));
	     

	     //XMLMetadata Form Creator
	     if (!val.equals(""))
		 {
			 sb.append("\n\n<script type=\"text/javascript\">\n")
			   .append("var xm = new XMLMetadata(\""+textareaName+"\");\n")
			   .append("xm.basePath = \""+basePath+"\";\n")
			   .append("xm.workspaceItemID = "+workspaceItemID+";\n")
			   .append("xm.fieldTitle = '"+label+"';\n");
			 if (hasMultipleFiles == false)
			 {
			 	sb.append("xm.hasMultipleFiles = false;\n");
				sb.append("xm.langNotHasMultipleFiles = \"Please check \'"+LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.initial-questions.elem3")+"\'!\";\n");
			 }
			 
			 if (nonInternalBistreamsID.size() != 0)
			 {
				 String nIBIDary = "[";
				 for (int b = 0; b < nonInternalBistreamsID.size(); b++)
				 {
					if (b > 0) 
						nIBIDary = nIBIDary + ",";
					nIBIDary = nIBIDary + nonInternalBistreamsID.get(b);
				 }
				 nIBIDary = nIBIDary + "]";
				 sb.append("xm.nonInternalBistreamsID = "+nIBIDary+";\n");
			 }
			 sb.append("xm.createRootForm();\n");
			 sb.append("</script>\n");
		  }

	   sb.append("</td>\n");

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input type=\"submit\" name=\"submit_")
	      .append(fieldName)
	      .append("_remove_")
	      .append(i)
//	      .append("\" value=\"Remove This Entry\"/> </td></tr>");
	      .append("\" value=\"")
   	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove"))
   	      .append("\"/> </td></tr>");
	 } 
	 else if (repeatable && i == fieldCount - 1) 
	 {
	    // put a 'more' button next to the last space
	    sb.append("<td><input type=\"submit\" name=\"submit_")
	      .append(fieldName)
//	      .append("_add\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" value=\"")
	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.add"))
	      .append("\"/> </td></tr>");
	 } 
	 else 
	 {
	    // put a blank if nothing else
	    sb.append("<td>&nbsp;</td></tr>");
	 }
      }

      out.write(sb.toString());
    }	//void doXMLMetadata()
%>
<%
    Item item = (Item) request.getAttribute("item");
    String handle = (String) request.getAttribute("handle");
    Collection[] collections = (Collection[]) request.getAttribute("collections");
    MetadataField[] dcTypes = (MetadataField[])  request.getAttribute("dc.types");
    HashMap metadataFields = (HashMap) request.getAttribute("metadataFields");
    request.setAttribute("LanguageSwitch", "hide");

    // Is anyone logged in?
    EPerson user = (EPerson) request.getAttribute("dspace.current.user");

    // Is the logged in user an admin
    Boolean admin = (Boolean)request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());
	EditItemForm editItemForm = new EditItemForm();
	DCInputsReader dcInputsReader = new DCInputsReader();
	
	String action = (String) UIUtil.getOriginalURL(request);
	if (action.indexOf("action=json") != -1)
	{
		 JSPManager.showJSP(request, response,
	                    "/tools/edititem-upload-file-json.jsp");
	}
%>



<dspace:layout titlekey="jsp.tools.edit-item-form.title"
               navbar="off"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin"
               nocache="true">

<tr>
<% 
        
		Context context = UIUtil.obtainContext(request);
		SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);
		HashMap progressBarInfo = (HashMap) subInfo.getProgressBarInfo();
		Set keys = progressBarInfo.keySet();
	    Iterator barIterator = keys.iterator();
		
		String stepAndPage = (String) barIterator.next();
		
		out.print("<table class=\"submitProgressTable\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\">");
		out.print("<tr>");
		for (int i = 0; i < collections.length; i++) 
		{ 
		 	String collectionHandle = collections[i].getHandle();
		 
		 	int pages = dcInputsReader.getNumberInputPages(collectionHandle);
			String[] pageHeadings = editItemForm.getPageHeadings(pageContext, collectionHandle);
		 	//String[] labelHeadings = getlabel.labelName();
		 	for(int j = 0; j<pages ; j++)
		 	{
		 		 if(j==2){
        			out.print("<td><input class=\"submitProgressButtonCurrent submitProgressButton\" id =\"progressbar_button_"+(j+1)+"\" type=\"button\"  value=\""+pageHeadings[j]+"\" /></td>");}
		 		 else{
				    out.println("<td><input class=\"submitProgressButtonDone submitProgressButton\" id =\"progressbar_button_"+(j+1)+"\" type=\"button\"  value=\""+ pageHeadings[j]+"\"/></td>");}
				 }
				out.print("</tr>");
				out.print("</table>");
				  for(int editPage=1 ; editPage<=pages ; editPage++)
				  {
					    if(editPage==3)
						{
							out.print("<div id=\"progressbar_div_"+editPage+"\" style=\"display:block;border: 1px solid #FFF;width: 90%;\" class=\"submitProgressDiv\">");
						}
						else 
						{
							out.print("<div id=\"progressbar_div_"+editPage+"\" style=\"display:none;border: 1px solid #FFF;width: 90%;\" class=\"submitProgressDiv\">");
						}
						out.print("<h1>"+editPage+"/" + pages + "</h1>");
						
						DCInputSet inputSet = dcInputsReader.getInputs(collectionHandle);
				  		DCInput[] inputs = inputSet.getPageRows((editPage - 1 ),false,false);
				  
				  		//out.print(inputs.length);
						out.print("<table width=\"100%\">");
				  		for (int z = 0; z < inputs.length; z++) 
     					{       
							String dcElement = inputs[z].getElement();
							String dcQualifier = inputs[z].getQualifier();
							String dcSchema = inputs[z].getSchema();
							//out.println(dcSchema+"."+dcElement+"."+dcQualifier);
							//out.print("<br />");
							
							String fieldName;
       						int fieldCountIncr;
						    boolean repeatable;
							String vocabulary;
							
							vocabulary = inputs[z].getVocabulary();
							
							if (dcQualifier != null && !dcQualifier.equals("*"))
							  fieldName = dcSchema + "_" + dcElement + '_' + dcQualifier;
						    else
							  fieldName = dcSchema + "_" + dcElement;
							  
							//print out hints, if not null
						    if(inputs[z].getHints() != null)
						    { 
							 	String hints = "<tr><td colspan=\"4\" class=\"submitFormHelp\">" +
												inputs[z].getHints() +
												"4545454</td></tr>";
				
								out.write(hints);
							 }
							 repeatable = inputs[z].getRepeatable();
       						fieldCountIncr = 0;
							
							String inputType = inputs[z].getInputType();
							String label = inputs[z].getLabel();
      						boolean closedVocabulary = inputs[z].isClosedVocabulary();		
							
							String defaultValue = inputs[z].getDefaultValue();
							
							ArrayList nonInternalBistreamsID = new ArrayList();
							boolean hasMultipleFiles = true;
							int workspaceItemID = item.getID();
							
							if (inputType.equals("name")) 
							{
							
							}
							
							else if (inputType.equals("texteditor")) 
						   {
							  doTextEditor(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
										  repeatable, fieldCountIncr, label, pageContext, vocabulary,
										  closedVocabulary, request.getContextPath() + "/extension/fckeditor/");
						   }
						   else if (inputType.equals("dropdown")) 
						   {
								doDropDown(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
										   repeatable, inputs[z].getPairs(), label);
						   } 
						   else if (inputType.equals("xmlmetadata")) 
						   {
							  doXMLMetadata(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
										  repeatable, fieldCountIncr, label, pageContext, vocabulary,
										  closedVocabulary, workspaceItemID, 
										  nonInternalBistreamsID, hasMultipleFiles, defaultValue, 
										  request.getContextPath());
						   } 
						   
							else
							{
								doOneBox(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	     			 				repeatable, fieldCountIncr, label, pageContext, vocabulary, 
	     			 				closedVocabulary);
								
							}
							
							
						%>
						<%-- HACK: Using this line to give the browser hints as to the widths of cells --%>
							   <tr>
								 <td width="20%">&nbsp;</td>
								 <td colspan="2" width="60%">&nbsp;</td>
								 <td width="20%">&nbsp;</td>
							   </tr>
						
						<% 
							
						}
						out.print("</table>");
						
						out.print("</div>");
				  }
				  
				  
			}
			out.print("<button type=\"button\" class=\"submitProgressPrev\">上一頁</button> ");
			out.print("<button type=\"button\" class=\"submitProgressNext\">下一頁</button>");
			
			
%>	
<script type="text/javascript">

function progressBar() {
	var pbObj = new Object;
	
	pbObj.init = function () {
		jQuery("input.submitProgressButton").click(function () {
			if (jQuery(this).hasClass("submitProgressButtonCurrent"))
				return;
			
			jQuery("input.submitProgressButton.submitProgressButtonCurrent")
				.removeClass("submitProgressButtonCurrent")
				.addClass("submitProgressButtonDone");
			jQuery(this).removeClass("submitProgressButtonDone")
				.addClass("submitProgressButtonCurrent");
			
			jQuery("div.submitProgressDiv").hide();
				
			var id = this.id.replace("progressbar_button_", "");
			var divID = "progressbar_div_" + id;
			
			jQuery("div.submitProgressDiv#"+divID).show();
		});
		
		jQuery("button.submitProgressNext").click(function () {
			var nowButton = jQuery("input.submitProgressButton.submitProgressButtonCurrent:first");
			var nextButton = nowButton.parents("td:first")
				.nextAll("td:first")
				.children("input:first");
			if (nextButton.length != 0)
				nextButton.click();
		});
		
		jQuery("button.submitProgressPrev").click(function () {
			var nowButton = jQuery("input.submitProgressButton.submitProgressButtonCurrent:first");
			var prevButton = nowButton.parents("td:first")
				.prevAll("td:first")
				.children("input:first");
			if (prevButton.length != 0)
				prevButton.click();
		});
	};
	return pbObj;
}
var pbObj = progressBar();
pbObj.init();

</script>
	
	
	
	<%--以下為原始程式碼--%>
	 <%-- <h1>Edit Item</h1> --%>
	<h1><fmt:message key="jsp.tools.edit-item-form.title"/></h1>
    
    <%-- <p><strong>PLEASE NOTE: These changes are not validated in any way.
    You are responsible for entering the data in the correct format.
    If you are not sure what the format is, please do NOT make changes.</strong></p> --%>
	<p><strong><fmt:message key="jsp.tools.edit-item-form.note"/></strong></p>
    
    <%-- <p><dspace:popup page="/help/collection-admin.html#editmetadata">More help...</dspace:popup></p>  --%>
	<div><dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.collection-admin\") + \"#editmetadata\"%>"><fmt:message key="jsp.morehelp"/></dspace:popup></div>  

    <center>
        <table width="70%" summary="Edit item table">
            <tr><%= item  %>
                <%-- <td class="submitFormLabel">Item&nbsp;internal&nbsp;ID:</td> --%>
				<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.itemID"/></td>
                <td class="standard"><%= item.getID() %></td>
                <td class="standard" width="100%" align="right" rowspan="5">
<%
    if (!item.isWithdrawn())
    {
%>
                    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                        <input type="hidden" name="action" value="<%= EditItemServlet.START_WITHDRAW %>" />
                        <%-- <input type="submit" name="submit" value="Withdraw..."> --%>
						<input type="submit" name="submit" value="<fmt:message key="jsp.tools.edit-item-form.withdraw-w-confirm.button"/>"/>
                    </form>
<%
    }
    else
    {
%>
                    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                        <input type="hidden" name="action" value="<%= EditItemServlet.REINSTATE %>" />
                        <%-- <input type="submit" name="submit" value="Reinstate"> --%>
						<input type="submit" name="submit" value="<fmt:message key="jsp.tools.edit-item-form.reinstate.button"/>"/>
                    </form>
<%
    }
%>

                    <br/>
                    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                        <input type="hidden" name="action" value="<%= EditItemServlet.START_DELETE %>" />
                        <%-- <input type="submit" name="submit" value="Delete (Expunge)..."> --%>
						<input type="submit" name="submit" value="<fmt:message key="jsp.tools.edit-item-form.delete-w-confirm.button"/>"/>
                    </form>
<%
  if (isAdmin)
  {
%>                     <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                        <input type="hidden" name="action" value="<%= EditItemServlet.START_MOVE_ITEM %>" />
						<input type="submit" name="submit" value="<fmt:message key="jsp.tools.edit-item-form.move-item.button"/>"/>
                    </form>
<%
  }
%>
                </td>
            </tr>
            <tr>
                <%-- <td class="submitFormLabel">Handle:</td> --%>
				<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.handle"/></td>
                <td class="standard"><%= (handle == null ? "None" : handle) %></td>
            </tr>
            <tr>
                <%-- <td class="submitFormLabel">Last modified:</td> --%>
				<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.modified"/></td>
                <td class="standard"><dspace:date date="<%= new DCDate(item.getLastModified()) %>" /></td>
            </tr>
            <tr>
                <%-- <td class="submitFormLabel">In Collections:</td> --%>
				<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.collections"/></td>
                <td class="standard">
<%  
        
		
        for (int i = 0; i < collections.length; i++) { 
        
		//String collectionHandle = collections[i].getHandle();
		//String[] pageHeadings = editItemForm.getPageHeadings(pageContext, collectionHandle);
		//out.print(pageHeadings[i]);
%>
                    <%= collections[i].getMetadata("name") %><br/>
<%  } %>
                </td>
            </tr>

            <tr>
                <%-- <td class="submitFormLabel">Item page:</td> --%>
				<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.itempage"/></td>
                <td class="standard">
<%  if (handle == null) { %>
                    <em><fmt:message key="jsp.tools.edit-item-form.na"/></em>
<%  } else {
    String url = ConfigurationManager.getProperty("dspace.url") + "/handle/" + handle; %>
                    <a target="_blank" href="<%= url %>"><%= url %></a>
<%  } %>
                </td>
            </tr>
<%-- ===========================================================
     Edit item's policies
     =========================================================== --%>
            <tr>
                <%-- <td class="submitFormLabel">Item's Authorizations:</td> --%>
				<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.item"/></td>
                <td>
                    <form method="post" action="<%= request.getContextPath() %>/dspace-admin/authorize">
                        <input type="hidden" name="handle" value="<%= ConfigurationManager.getProperty("handle.prefix") %>" />
                        <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                        <%-- <input type="submit" name="submit_item_select" value="Edit..."> --%>
						<input type="submit" name="submit_item_select" value="<fmt:message key="jsp.tools.general.edit"/>"/>
                    </form>
                </td>
            </tr>

        </table>
    </center>

<%


    if (item.isWithdrawn())
    {
%>
    <%-- <p align="center"><strong>This item was withdrawn from DSpace</strong></p> --%>
	<p align="center"><strong><fmt:message key="jsp.tools.edit-item-form.msg"/></strong></p>
<%
    }
%>
    <p>&nbsp;</p>


    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
        <table class="miscTable" summary="Edit item withdrawn table">
            <tr>
                <%-- <th class="oddRowOddCol"><strong>Element</strong></th>
                <th id="t1" class="oddRowEvenCol"><strong>Qualifier</strong></th>
                <th id="t2" class="oddRowOddCol"><strong>Value</strong></th>
                <th id="t3" class="oddRowEvenCol"><strong>Language</strong></th> --%>
                
                <th id="t0" class="oddRowOddCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem0"/></strong></th>
                <th id="t1" class="oddRowEvenCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem1"/></strong></th>
                <th id="t2" class="oddRowOddCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem2"/></strong></th>
                <th id="t3" class="oddRowEvenCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem3"/></strong></th>
                <th id="t4" class="oddRowOddCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem4"/></strong></th>
                <th id="t5" class="oddRowEvenCol">&nbsp;</th>
            </tr>
<%
    DCValue[] dcv = item.getMetadata(Item.ANY, Item.ANY, Item.ANY, Item.ANY);
    String row = "even";
    
    // Keep a count of the number of values of each element+qualifier
    // key is "element" or "element_qualifier" (String)
    // values are Integers - number of values that element/qualifier so far
    Map dcCounter = new HashMap();
%>


 
<%
    for (int i = 0; i < dcv.length; i++)
    {
        // Find out how many values with this element/qualifier we've found

        String key = dcv[i].schema + "_" + dcv[i].element +
            (dcv[i].qualifier == null ? "" : "_" + dcv[i].qualifier);

        Integer count = (Integer) dcCounter.get(key);
        if (count == null)
        {
            count = new Integer(0);
        }
        
        // Increment counter in map
        dcCounter.put(key, new Integer(count.intValue() + 1));

        // We will use two digits to represent the counter number in the parameter names.
        // This means a string sort can be used to put things in the correct order even
        // if there are >= 10 values for a particular element/qualifier.  Increase this to 
        // 3 digits if there are ever >= 100 for a single element/qualifer! :)
        String sequenceNumber = count.toString();
  
        while (sequenceNumber.length() < 2)
        {
            sequenceNumber = "0" + sequenceNumber;
        }
 %>
           
		    <tr>
                <td headers="t0" class="<%= row %>RowOddCol"><%=dcv[i].schema %></td>
                <td headers="t1" class="<%= row %>RowEvenCol"><%= dcv[i].element %>&nbsp;&nbsp;</td>
                <td headers="t2" class="<%= row %>RowOddCol"><%= (dcv[i].qualifier == null ? "" : dcv[i].qualifier) %></td>
                <td headers="t3" class="<%= row %>RowEvenCol">
                    <textarea name="value_<%= key %>_<%= sequenceNumber %>" rows="3" cols="50"><%= dcv[i].value %></textarea>
                </td>
                <td headers="t4" class="<%= row %>RowOddCol">
                    <input type="text" name="language_<%= key %>_<%= sequenceNumber %>" value="<%= (dcv[i].language == null ? "" : dcv[i].language) %>" size="5"/>
                </td>
                <td headers="t5" class="<%= row %>RowEvenCol">
                    <%-- <input type="submit" name="submit_remove_<%= key %>_<%= sequenceNumber %>" value="Remove" /> --%>
					<input type="submit" name="submit_remove_<%= key %>_<%= sequenceNumber %>" value="<fmt:message key="jsp.tools.general.remove"/>"/>
                </td>
            </tr>
<%      row = (row.equals("odd") ? "even" : "odd");
    } %>

            <tr><td>&nbsp;</td></tr>

            <tr>
     	
                <td headers="t1" colspan="3" class="<%= row %>RowEvenCol">
                    <select name="addfield_dctype">
<%  for (int i = 0; i < dcTypes.length; i++) 
    { 
    	Integer fieldID = new Integer(dcTypes[i].getFieldID());
    	String displayName = (String)metadataFields.get(fieldID);
%>
                        <option value="<%= fieldID.intValue() %>"><%= displayName %></option>
<%  } %>
                    </select>
                </td>
                <td headers="t3" class="<%= row %>RowOddCol">
                    <textarea name="addfield_value" rows="3" cols="50"></textarea>
                </td>
                <td headers="t4" class="<%= row %>RowEvenCol">
                    <input type="text" name="addfield_language" size="5"/>
                </td>
                <td headers="t5" class="<%= row %>RowOddCol">
                    <%-- <input type="submit" name="submit_addfield" value="Add"> --%>
					<input type="submit" name="submit_addfield" value="<fmt:message key="jsp.tools.general.add"/>"/>
                </td>
            </tr>
        </table>
        
        <p>&nbsp;</p>

        <%-- <h2>Bitstreams</h2> --%>
		<h2><fmt:message key="jsp.tools.edit-item-form.heading"/></h2>

        <%-- <p><strong>Note: Changes to the bitstreams will not be automatically reflected in the
        Dublin Core metadata above (e.g. <code>format.extent</code>, <code>format.mimetype</code>).
        You will need to update this by hand.</strong></p> --%>
		<p><strong><fmt:message key="jsp.tools.edit-item-form.note1"/></strong></p>

        <%-- <p>Also note that if the "user format description" field isn't empty, the format will
        always be set to "Unknown", so clear the user format description before changing the
        format field.</p> --%>
		<p><fmt:message key="jsp.tools.edit-item-form.note3"/></p>

        <table class="miscTable" summary="Bitstream data table">
            <tr>
	  <%-- <th class="oddRowEvenCol"><strong>Primary<br>Bitstream</strong></th>
                <th class="oddRowOddCol"><strong>Name</strong></th>
                <th class="oddRowEvenCol"><strong>Source</strong></th>
                <th class="oddRowOddCol"><strong>Description</strong></th>
                <th class="oddRowEvenCol"><strong>Format</strong></th>
                <th class="oddRowOddCol"><strong>User&nbsp;Format&nbsp;Description</strong></th> --%>
                
		        <th id="t11" class="oddRowEvenCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem5"/></strong></th>
                <th id="t12" class="oddRowOddCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem7"/></strong></th>
                <th id="t13" class="oddRowEvenCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem8"/></strong></th>
                <th id="t14" class="oddRowOddCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem9"/></strong></th>
                <th id="t15" class="oddRowEvenCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem10"/></strong></th>
                <th id="t16" class="oddRowOddCol"><strong><fmt:message key="jsp.tools.edit-item-form.elem11"/></strong></th>
                <th id="t17" class="oddRowEvenCol">&nbsp;</th>
            </tr>
<%
    Bundle[] bundles = item.getBundles();
    row = "even";

    for (int i = 0; i < bundles.length; i++)
    {
        Bitstream[] bitstreams = bundles[i].getBitstreams();
        for (int j = 0; j < bitstreams.length; j++)
        {
            // Parameter names will include the bundle and bitstream ID
            // e.g. "bitstream_14_18_desc" is the description of bitstream 18 in bundle 14
            String key = bundles[i].getID() + "_" + bitstreams[j].getID();
            BitstreamFormat bf = bitstreams[j].getFormat();
%>
            <tr>
		<% if (bundles[i].getName().equals("ORIGINAL"))
		   { %>
                     <td headers="t11" class="<%= row %>RowEvenCol" align="center">
                       <input type="radio" name="<%= bundles[i].getID() %>_primary_bitstream_id" value="<%= bitstreams[j].getID() %>"
                           <% if (bundles[i].getPrimaryBitstreamID() == bitstreams[j].getID()) { %>
                                  checked="<%="checked" %>"
                           <% } %> />
                   </td>
		<% } else { %>
		     <td headers="t11"> </td>
		<% } %>
                <td headers="t12" class="<%= row %>RowOddCol">
                    <input type="text" name="bitstream_name_<%= key %>" value="<%= (bitstreams[j].getName() == null ? "" : bitstreams[j].getName()) %>"/>
                </td>
                <td headers="t13" class="<%= row %>RowEvenCol">
                    <input type="text" name="bitstream_source_<%= key %>" value="<%= (bitstreams[j].getSource() == null ? "" : bitstreams[j].getSource()) %>"/>
                </td>
                <td headers="t14" class="<%= row %>RowOddCol">
                    <input type="text" name="bitstream_description_<%= key %>" value="<%= (bitstreams[j].getDescription() == null ? "" : bitstreams[j].getDescription()) %>"/>
                </td>
                <td headers="t15" class="<%= row %>RowEvenCol">
                    <input type="text" name="bitstream_format_id_<%= key %>" value="<%= bf.getID() %>" size="4"/> (<%= bf.getShortDescription() %>)
                </td>
                <td headers="t16" class="<%= row %>RowOddCol">
                    <input type="text" name="bitstream_user_format_description_<%= key %>" value="<%= (bitstreams[j].getUserFormatDescription() == null ? "" : bitstreams[j].getUserFormatDescription()) %>"/>
                </td>
                <td headers="t17" class="<%= row %>RowEvenCol">
                    <%-- <a target="_blank" href="<%= request.getContextPath() %>/retrieve/<%= bitstreams[j].getID() %>">View</a>&nbsp;<input type="submit" name="submit_delete_bitstream_<%= key %>" value="Remove"> --%>
					<a target="_blank" href="<%= request.getContextPath() %>/retrieve/<%= bitstreams[j].getID() %>"><fmt:message key="jsp.tools.general.view"/></a>&nbsp;<input type="submit" name="submit_delete_bitstream_<%= key %>" value="<fmt:message key="jsp.tools.general.remove"/>" />
                </td>
            </tr>
<%
            row = (row.equals("odd") ? "even" : "odd");
        }
    }
%>
        </table>

        <p>&nbsp;</p>

        <%-- <p align="center"><input type="submit" name="submit_addbitstream" value="Add Bitstream"></p> --%>
        <center>
            <table width="70%" align="center">
                <tr>
                  <td>
						<input type="submit" name="submit_addbitstream" value="<fmt:message key="jsp.tools.edit-item-form.addbit.button"/>"/>
		<%

			if (ConfigurationManager.getBooleanProperty("webui.submit.enable-cc"))
			{
				String s;
				Bundle[] ccBundle = item.getBundles("CC-LICENSE");
				s = ccBundle.length > 0 ? LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.edit-item-form.replacecc.button") : LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.edit-item-form.addcc.button");
		%>
                    <input type="submit" name="submit_addcc" value="<%= s %>" />
                    <input type="hidden" name="handle" value="<%= ConfigurationManager.getProperty("handle.prefix") %>"/>
                    <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
       <%
			}
%>
                  </td>
                </tr>
            </table>
        </center>

        <p>&nbsp;</p>

        <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
        <input type="hidden" name="action" value="<%= EditItemServlet.UPDATE_ITEM %>"/>
        <center>
            <table width="70%">
                <tr>
                    <td align="left">
                        <%-- <input type="submit" name="submit" value="Update" /> --%>
						<input type="submit" name="submit" value="<fmt:message key="jsp.tools.general.update"/>" />
                    </td>
                    <td align="right">

                        <%-- <input type="submit" name="submit_cancel" value="Cancel" /> --%>
						<input type="submit" name="submit_cancel" value="<fmt:message key="jsp.tools.general.cancel"/>" />
                    </td>
                </tr>
            </table>
        </center>
    </form>    
</dspace:layout>
