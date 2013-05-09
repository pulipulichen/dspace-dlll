<%--
  - edit-metadata.jsp
  -
  - Version: $Revision: 2703 $
  -
  - Date: $Date: 2008-02-20 16:46:41 -0600 (Wed, 20 Feb 2008) $
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
  - Edit metadata form
  -
  - Attributes to pass in to this page:
  -    submission.info   - the SubmissionInfo object
  -    submission.inputs - the DCInputSet
  -    submission.page   - the step in submission
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.net.URLEncoder" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="javax.servlet.jsp.tagext.TagSupport" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.ServletException" %>

<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.jsptag.PopupTag" %>
<%@ page import="org.dspace.app.util.DCInput" %>
<%@ page import="org.dspace.app.util.DCInputSet" %>
<%@ page import="org.dspace.app.webui.util.SubmissionUtil" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.submit.AbstractProcessingStep" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.JSPManager" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.DCDate" %>
<%@ page import="org.dspace.content.DCLanguage" %>
<%@ page import="org.dspace.content.DCPersonName" %>
<%@ page import="org.dspace.content.DCSeriesNumber" %>
<%@ page import="org.dspace.content.DCValue" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.content.Bitstream" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    request.setAttribute("LanguageSwitch", "hide");
%>
<%!
    // required by Controlled Vocabulary  add-on
	String contextPath;

    // This method is resposible for showing a link next to an input box 
    // that pops up a window that to display a controlled vocabulary. 
    // It should be called from the doOneBox and doTwoBox methods. 
    // It must be extended to work with doTextArea.
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


    void doPersonalName(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext) 
      throws java.io.IOException 
    {

      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer headers = new StringBuffer();
      StringBuffer sb = new StringBuffer();
      org.dspace.content.DCPersonName dpn;
      StringBuffer name = new StringBuffer();
      StringBuffer first = new StringBuffer(); 
      StringBuffer last = new StringBuffer();
      
      if (fieldCount == 0)
         fieldCount = 1;

      //Width hints used here to affect whole table 
      headers.append("<tr><td>&nbsp;</td>")	//.append("<tr><td width=\"40%\">&nbsp;</td>")
             //.append("<td class=\"submitFormDateLabel\" width=\"5%\">")
//			 .append("<td class=\"submitFormDateLabel\">")
//             .append("&nbsp;</td>")
//             .append("Last name<br>e.g. <strong>Smith</strong></td>")
			.append("<td class=\"submitFormDateLabel\">")
			 .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.lastname"))
			 .append("</td>")
             //.append("<td class=\"submitFormDateLabel\" width=\"5%\">")
			 .append("<td class=\"submitFormDateLabel\">")
//             .append("</td>")
//             .append("First name(s) + \"Jr\"<br> e.g. <strong>Donald Jr</strong></td>")
//			.append("<td class=\"submitFormDateLabel\">")
			 .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.firstname"))
			 .append("</td>")
             //.append("<td width=\"40%\">&nbsp;</td>")
			 .append("<td>&nbsp;</td>")
             .append("</tr>");
      out.write(headers.toString());


      for (int i = 0; i < fieldCount; i++) 
      {
	 first.setLength(0);
	 first.append(fieldName).append("_first");
	 if (repeatable && i>0)
	    first.append('_').append(i);

	 last.setLength(0);
	 last.append(fieldName).append("_last");
	 if (repeatable && i>0)
	    last.append('_').append(i);
	    
	 if (i == 0) 
	    sb.append("<tr><td class=\"submitFormLabel\">")
	      .append(label)
	      .append("</td>");
	 else
	    sb.append("<tr><td>&nbsp;</td>");

         if (i < defaults.length)
	    dpn = new org.dspace.content.DCPersonName(defaults[i].value);
	 else
	    dpn = new org.dspace.content.DCPersonName();
	 
         sb.append("<td align=\"center\"><input type=\"text\" name=\"")
           .append(last.toString())
           .append("\" style=\"width:90%;\" value=\"")
           .append(dpn.getLastName().replaceAll("\"", "&quot;")) // Encode "
	   	   .append("\"  /></td>\n<td><input type=\"text\" name=\"")
	   	   .append(first.toString())
           .append("\" size=\"50\" value=\"")
           .append(dpn.getFirstNames()).append("\"  /></td>\n");

	 if (repeatable && i < defaults.length) 
	 {
	    name.setLength(0);
	    name.append(dpn.getLastName())
	        .append(' ')
	        .append(dpn.getFirstNames());
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_" )
	      .append(fieldName)
	      .append("_remove_")
	      .append(i)
//	      .append("\" value=\"Remove This Entry\"/> </td></tr>")
		  .append("\" value=\"")
		  .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove"))
		  .append("\"/> </td></tr>");
	 } 
	 else if (repeatable && i == fieldCount - 1) 
	 {
	    // put a 'more' button next to the last space
	    sb.append("<td><input type=\"submit\" name=\"submit_")
	      .append(fieldName)
// 	      .append("_add\" value=\"Add More\"/> </td></tr>");
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

    void doDate(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, HttpServletRequest request) 
      throws java.io.IOException 
    {

      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      org.dspace.content.DCDate dateIssued;

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
            dateIssued = new org.dspace.content.DCDate(defaults[i].value);
         else
            dateIssued = new org.dspace.content.DCDate("");
    
         sb.append("<td colspan=\"2\" nowrap=\"nowrap\" class=\"submitFormDateLabel input-type-date\">")
		 //日
			.append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.day"))
			.append("<input type=\"text\" class=\"input-type-date input-type-date-day\" name=\"")
			.append(fieldName)
			.append("_day");
		 if (repeatable && i>0)
			sb.append("_").append(i);
		 sb.append("\" size=\"2\" maxlength=\"2\" value=\"")
			.append((dateIssued.getDay() > 0 ? 
			 String.valueOf(dateIssued.getDay()) : "" ))
		    .append("\"  /> ")
//          .append("Month:<select name=\"")
         	.append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.month"))
            .append("<select class=\"input-type-date input-type-date-month\" name=\"")
	    .append(fieldName)
	    .append("_month");
         if (repeatable && i>0)
            sb.append('_').append(i);
         sb.append("\"  ><option value=\"-1\"")
            .append((dateIssued.getMonth() == -1 ? " selected=\"selected\"" : ""))
//	    .append(">(No month)</option>");
	    .append(">")
	    .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.no_month"))
	    .append("</option>");
	    
         for (int j = 1; j < 13; j++) 
	 {
            sb.append("<option value=\"")
	      .append(j)
	      .append((dateIssued.getMonth() == j ? "\" selected=\"selected\"" : "\"" ))
	      .append(">")
	      .append(org.dspace.content.DCDate.getMonthName(j,I18nUtil.getSupportedLocale(request.getLocale())))
	      .append("</option>");
         }
    
         sb.append("</select>")
/*            .append("Day:<input type=text name=\"")
		.append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.day"))
		.append("<input type=\"text\" name=\"")
	    .append(fieldName)
	    .append("_day");
         if (repeatable && i>0)
            sb.append("_").append(i);
         sb.append("\" size=\"2\" maxlength=\"2\" value=\"")
            .append((dateIssued.getDay() > 0 ? 
	             String.valueOf(dateIssued.getDay()) : "" ))
//	    .append("\"/>Year:<input type=text name=\"")
		.append("\"  />")*/
		.append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.year"))
		.append("<input type=\"text\" class=\"input-type-date input-type-date-year\" name=\"")
	    .append(fieldName)
	    .append("_year");
         if (repeatable && i>0)
            sb.append("_").append(i);
         sb.append("\" size=\"4\" maxlength=\"4\" value=\"")
            .append((dateIssued.getYear() > 0 ? 
	         String.valueOf(dateIssued.getYear()) : "" ))
	    .append("\"  /></td>\n");
    
	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_")
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
	      .append("_add\" class=\"add-more\" value=\"")
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

    void doSeriesNumber(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext) 
      throws java.io.IOException 
    {

      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      org.dspace.content.DCSeriesNumber sn;
      StringBuffer headers = new StringBuffer();

      //Width hints used here to affect whole table 
      headers.append("<tr><td>&nbsp;</td>")	//.append("<tr><td width=\"40%\">&nbsp;</td>")
          //.append("<td class=\"submitFormDateLabel\" width=\"5%\">")
		  .append("<td class=\"submitFormDateLabel\">")
//          .append("Series Name</td>")
			 .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.seriesname"))
          .append("</td>")
          //.append("<td class=\"submitFormDateLabel\" width=\"5%\">")
		  .append("<td class=\"submitFormDateLabel\">")
//          .append("Report or Paper No.</td>")
			 .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.paperno"))
          .append("</td>")
          //.append("<td width=\"40%\">&nbsp;</td>")
		  .append("<td>&nbsp;</td>")
          .append("</tr>");
      out.write(headers.toString());
      
      
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
           sn = new org.dspace.content.DCSeriesNumber(defaults[i].value);
         else
           sn = new org.dspace.content.DCSeriesNumber();

         sb.append("<td><input type=\"text\" name=\"")
           .append(fieldName)
	   .append("_series");
         if (repeatable && i>0)
           sb.append("_").append(i);

         sb.append("\" size=\"23\" value=\"")
           .append(sn.getSeries().replaceAll("\"", "&quot;"))
	   .append("\"  /></td>\n<td align=\"center\"><input type=\"text\" name=\"")
	   .append(fieldName)
	   .append("_number");
         if (repeatable && i>0)
           sb.append("_").append(i);
         sb.append("\" size=\"23\" value=\"")
           .append(sn.getNumber().replaceAll("\"", "&quot;"))
	   .append("\"  /></td>\n");

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_")
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
//	      .append("_add\" class=\"add-more\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" class=\"add-more\" value=\"")
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

    void doTextArea(javax.servlet.jsp.JspWriter out, Item item,
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
           val = defaults[i].value;
         else
           val = "";

         sb.append("<td colspan=\"2\"><textarea name=\"")
           .append(fieldName);
         if (repeatable && i>0)
           sb.append("_").append(i);
         sb.append("\" rows=\"4\" cols=\"60\" size=\"60\"")
           .append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
           .append("   >")
           .append(val)
	   .append("</textarea>")
	   .append(doControlledVocabulary(fieldName + (repeatable?"_" + i:""), pageContext, vocabulary))
	   .append("</td>\n");

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_")
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
//	      .append("_add\" class=\"add-more\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" class=\"add-more\" value=\"")
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
    }	//void doTextArea()

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
           .append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
	   	.append("   />")
	   .append(doControlledVocabulary(fieldName + (repeatable?"_" + i:""), pageContext, vocabulary))
	   .append("</td>\n");
	   

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_")
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
//	      .append("_add\" class=\"add-more\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" class=\"add-more\" value=\"")
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

    void doTwoBox(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary) 
      throws java.io.IOException 
    {
      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      StringBuffer headers = new StringBuffer();

      String fieldParam = "";
      
      if (element.equals("relation") && qualifier.equals("ispartofseries"))
      {
         //Width hints used here to affect whole table 
         headers//.append("<tr><td width=\"40%\">&nbsp;</td>")
		 	 .append("<tr><td>&nbsp;</td>")
             //.append("<td class=\"submitFormDateLabel\" width=\"5%\">")
			 .append("<td class=\"submitFormDateLabel\">")
//             .append("Series Name</td>")
			 .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.seriesname"))
             .append("</td>")
             //.append("<td class=\"submitFormDateLabel\" width=\"5%\">")
			 .append("<td class=\"submitFormDateLabel\">")
//             .append("Report or Paper No.</td>")
			 .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.paperno"))
             .append("</td>")
             //.append("<td width=\"40%\">&nbsp;</td>")
			 .append("<td>&nbsp;</td>")
             .append("</tr>");
         out.write(headers.toString());
      }

      if (fieldCount == 0)
         fieldCount = 1;

      for (int i = 0; i < fieldCount; i++) 
      {
	 if (i == 0)
	 {	 
	    //param is just the field name
	    fieldParam = fieldName;
	     
	    sb.append("<tr><td class=\"submitFormLabel\">")
	      .append(label)
	      .append("</td>");
	 }
	 else
	 {  
		//param is field name and index (e.g. myfield_2) 
	    fieldParam = fieldName + "_" + i;
	    sb.append("<tr><td>&nbsp;</td>");
	 }
         if (i < defaults.length)
           sb.append("<td align=\"left\"><input type=\"text\" name=\"")
             .append(fieldParam)
             .append("\" size=\"15\" value=\"")
             .append(defaults[i].value.replaceAll("\"", "&quot;"))
             .append("\"")
       	     .append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
             .append("   />&nbsp;<input align=\"top\" type=\"submit\" name=\"submit_")
	     .append(fieldName)
	     .append("_remove_")
	     .append(i)
	     .append("\" value=\"")
	     .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove2"))
	     .append("\"/>")
         .append(doControlledVocabulary(fieldName + "_" + i, pageContext, vocabulary))
	     .append("</td>\n");
         else 
	 {
           sb.append("<td align=\"left\"><input type=\"text\" name=\"")
             .append(fieldParam)
             .append("\" size=\"15\"")
             .append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
             .append("/>")
             .append(doControlledVocabulary(fieldName + "_" + i, pageContext, vocabulary))
             .append("</td>\n");             
	 }
	 i++;
	 //param is field name and index (e.g. myfield_2) 
	 fieldParam = fieldName + "_" + i;
	 if (i < defaults.length)
           sb.append("<td align=\"left\"><input type=\"text\" name=\"")
             .append(fieldParam)
             .append("\" size=\"15\" value=\"")
             .append(defaults[i].value.replaceAll("\"", "&quot;"))
	         .append("\"")
	         .append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
	         .append("  />&nbsp;<input align=\"top\" type=\"submit\" name=\"submit_")
	     .append(fieldName)
	     .append("_remove_")
	     .append(i)
	     .append("\" value=\"")
	     .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove2"))
	     .append("\"/>")
         .append(doControlledVocabulary(fieldName + "_" + i, pageContext, vocabulary))
	     .append("</td></tr>\n");
	 else 
	 {
           sb.append("<td align=\"left\"><input type=\"text\" name=\"")
             .append(fieldParam)
             //.append("\" size=\"15\"/></td>");
             .append("\" size=\"15\"")
             .append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
             .append("/>")
             .append(doControlledVocabulary(fieldName + "_" + i, pageContext, vocabulary))
             .append("</td>\n");             

	   if (i+1 >= fieldCount) 
	   {
	     sb.append("<td><input type=\"submit\" name=\"submit_")
	       .append(fieldName)
	       .append("_add\" class=\"add-more\" value=\"")
	       .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.add"))
	       .append("\"/></td>\n");
	   } 
	   else 
	   {
	     sb.append("</td>");
	   }
	   sb.append("<td>&nbsp;</td></tr>");
	 }
      }

      out.write(sb.toString());
    }
    
    

    void doQualdropValue(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, DCInputSet inputs, boolean repeatable,
      int fieldCountIncr, List qualMap, String label, PageContext pageContext) 
      throws java.io.IOException 
    {
		DCValue[] unfiltered = item.getMetadata(schema, element, Item.ANY, Item.ANY);
		// filter out both unqualified and qualified values occuring elsewhere in inputs
		ArrayList filtered = new ArrayList();
		for (int i = 0; i < unfiltered.length; i++)
		{
		    String unfilteredFieldName = unfiltered[i].element;
		    if(unfiltered[i].qualifier != null && unfiltered[i].qualifier.length()>0)
		        unfilteredFieldName += "." + unfiltered[i].qualifier;
			
			if ( ! inputs.isFieldPresent(unfilteredFieldName) )
			{
				filtered.add( unfiltered[i] );
			} 
		}
		DCValue[] defaults = (DCValue[])filtered.toArray(new DCValue[0]);
      //DCValue[] defaults = item.getMetadata(element, Item.ANY, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      String   q, v, currentQual, currentVal;

      if (fieldCount == 0)
         fieldCount = 1;

      for (int j = 0; j < fieldCount; j++) 
      {

         if (j < defaults.length) 
	 {
            currentQual = defaults[j].qualifier;
            if(currentQual==null) currentQual="";
            currentVal = defaults[j].value;
         }
	 else 
	 {
	    currentQual = "";
	    currentVal = "";
	 }

	 if (j == 0) 
	    sb.append("<tr><td class=\"submitFormLabel\">")
              .append(label)
	      .append("</td>");
	 else
            sb.append("<tr><td>&nbsp;</td>");

	 // do the dropdown box
	 sb.append("<td colspan=\"2\"><select name=\"")
           .append(fieldName)
	   .append("_qualifier");
         if (repeatable && j>0) 
           sb.append("_").append(j);
         sb.append("\"  >");
         for (int i = 0; i < qualMap.size(); i+=2)
         {
	   q = (String)qualMap.get(i);
	   if (q == null)
	   	   q = "";
	   v = (String)qualMap.get(i+1);
           sb.append("<option")
	     .append((v.equals(currentQual) ? " selected=\"selected\" ": "" ))
	     .append(" value=\"")
	     .append(v)
	     .append("\">")
	     .append(q)
	     .append("</option>");
         }
      
	 // do the input box
         sb.append("</select>&nbsp;<input type=\"text\" name=\"")
           .append(fieldName)
	   .append("_value");
         if (repeatable && j>0)
           sb.append("_").append(j);
         sb.append("\" size=\"34\" value=\"")
           .append(currentVal.replaceAll("\"", "&quot;"))
	   .append("\"  /></td>\n");

	 if (repeatable && j < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_")
	      .append(fieldName)
	      .append("_remove_")
	      .append(j)
//	      .append("\" value=\"Remove This Entry\"/> </td></tr>");
	      .append("\" value=\"")
   	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove"))
   	      .append("\"/> </td></tr>");
	 } 
	 else if (repeatable && j == fieldCount - 1) 
	 {
	    // put a 'more' button next to the last space
	    sb.append("<td><input type=\"submit\" name=\"submit_")
	      .append(fieldName)
//	      .append("_add\" class=\"add-more\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" class=\"add-more\" value=\"")
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
         if (display == null)
         	 display = "";
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
    
    
    /** Display Checkboxes or Radio buttons, depending on if repeatable! **/
    void doList(javax.servlet.jsp.JspWriter out, Item item,
            String fieldName, String schema, String element, String qualifier, boolean repeatable,
            List valueList, String label) 
            throws java.io.IOException 
          {
        	DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
        	int valueCount = valueList.size();
        	
            StringBuffer sb = new StringBuffer();
            String display, value;
            int j;

            int numColumns = 1;
            //if more than 3 display+value pairs, display in 2 columns to save space
            if(valueCount > 6)
                numColumns = 2;

            //print out the field label
            sb.append("<tr><td class=\"submitFormLabel\">")
        	  .append(label)
        	  .append("</td>");
            
            if(numColumns > 1)
                sb.append("<td valign=\"top\" width=\"30%\">");
            else
                sb.append("<td valign=\"top\" colspan=\"3\">");
            
            //flag that lets us know when we are in Column2
            boolean inColumn2 = false;
            
            //loop through all values
            for (int i = 0; i < valueList.size(); i += 2)
            {              
			   //get display value and actual value
               display = (String)valueList.get(i);
      	 	   value = (String)valueList.get(i+1);
   	 
      	 	   //check if this value has been selected previously
      	 	   for (j = 0; j < defaults.length; j++) 
      	 	   {
      	     		if (value.equals(defaults[j].value))
      	         	break;
               }
 	   
				// print input field
  	 	       sb.append("<input type=\"");
      	 	   
      	 	   //if repeatable, print a Checkbox, otherwise print Radio buttons
      	 	   if(repeatable)
      	 	      sb.append("checkbox"); 
      	 	   else
      	 	      sb.append("radio");
      	 	   
      	 	   sb.append("\" name=\"")
      	 	     .append(fieldName)
      	 	     .append("\"")
      	 	     .append(j < defaults.length ? " checked=\"checked\" " : "")
      	 	     .append(" value=\"")
	   			 .append(value)
	   			 .append("\">");    
      	 	   
      	 	   //print display name immediately after input
      	 	   sb.append("&nbsp;")
      	 	     .append(display)
      	 	     .append("<br/>");
      	 	   
			   // if we are writing values in two columns, 
			   // then start column 2 after half of the values
       	 	   if((numColumns == 2) && (i+2 >= (valueList.size()/2)) && !inColumn2) 
       	 	   {
       	 	      	//end first column, start second column
       	 	     	sb.append("</td>");
       	 	     	sb.append("<td colspan=\"2\" valign=\"top\">");
       	 	     	inColumn2 = true;
       	 	   }
      	 	   
            }//end for each value

            sb.append("</td></tr>");
            
            out.write(sb.toString());
          }//end doList

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
           .append("jQuery(document).ready(function () {\n")
		   .append("	jQuery(\"textarea[name=\'")
		   .append(fieldName);
         if (repeatable && i>0)
         	sb.append("_").append(i);
		   sb.append("\']\").doFCKeditorDialog();\n")
		   /*
	       .append("	var oFCKeditor = new FCKeditor( \"")
           .append(fieldName);
         if (repeatable && i>0)
           sb.append("_").append(i);
	       sb.append("\" ) ;\n")
		   .append("	oFCKeditor.BasePath	= \""+sBasePath+"\" ;\n")
		   .append("	oFCKeditor.Config[\"ToolbarStartExpanded\"] = false ;\n")
	       .append("	oFCKeditor.ReplaceTextarea() ;\n")
		   */
		   .append("});\n")
	       .append("</script>\n");

	   sb.append("</td>\n");

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_")
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
//	      .append("_add\" class=\"add-more\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" class=\"add-more\" value=\"")
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

    void doFileUpload(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary,
	  int workspaceItemID, ArrayList nonInternalBistreamsID, boolean hasMultipleFiles)
      throws java.io.IOException 
    {

      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
	  fieldCountIncr = 1;
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
      
	  if (!val.equals(""))
	  {
		  String[] tempID = val.split("/");
		  if (tempID.length > 2)
		  {
		  	//String id = tempID[(tempID.length - 2)];
			int id = Integer.parseInt(tempID[(tempID.length - 2)]);
			
			int index = nonInternalBistreamsID.indexOf(id);
			if (index == -1)	continue;
		  }
	  }
	     
         String inputName = fieldName;
         if (repeatable && i>0)
           inputName = inputName + "_" + i;


			 sb.append("<td colspan=\"2\">");

		if (hasMultipleFiles == true)
		{
		sb.append("\n<input type=\"text\" id=\""+inputName+"\" name=\""+inputName+"\" value=\""+val+"\" style=\"display:none\"   />\n")
			.append("	<input type=\"file\" onchange=\"jQuery(this).nextAll('button.fileupload-do:first').click()\" />\n")
			//.append("	<input type=\"file\" onchange=\"jQuery(this)\" />\n")
			.append("	<span></span>\n")
			.append("	<button style=\"display:none;\" class=\"fileupload-do\" onclick=\"return ajaxFileUpload(this, "+workspaceItemID+", '"+label+"');\" type=\"button\">Upload</button>\n");
			
			 if (!val.equals(""))
			 {
			sb.append("	<script type=\"text/javascript\">")
				.append("	ajaxFileUploadExist(\""+inputName+"\");")
				.append("</script>");
			 }
		}	//if (hasMultipleFiles == true)
		else
		{
			sb.append("Please check \""+LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.initial-questions.elem3")+"\"! \n");
		}
			 sb.append("</td>\n");
	   

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_")
	      .append(fieldName)
	      .append("_remove_")
	      .append(i)
//	      .append("\" value=\"Remove This Entry\"/> </td></tr>");
	      .append("\" value=\"")
   	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove"))
   	      .append("\" style=\"display:none\" ")
		  .append("/>")
		  .append("<button align=\"top\" type=\"button\" onclick=\"ajaxFileUploadRemove(this, "+workspaceItemID+")\">"+LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove")+"</button>")
		  .append(" </td></tr>");
	 } 
	 else if (repeatable && i == fieldCount - 1) 
	 {
	    // put a 'more' button next to the last space
	    sb.append("<td><input type=\"submit\" name=\"submit_")
	      .append(fieldName)
//	      .append("_add\" class=\"add-more\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" class=\"add-more\" value=\"")
	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.add"))
	      .append("\"/> </td></tr>");
	 } 
	 else 
	 {
	    // put a blank if nothing else
	    sb.append("<td>")
			.append("	<button class=\"fileupload-cancel\" onclick=\"return ajaxFileUploadCancel(this, "+workspaceItemID+")\" style=\"display:none\" type=\"button\">"+LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove")+"</button>\n")
			.append("&nbsp;</td></tr>");
	 }
      }

      out.write(sb.toString());
    }	//end of doFileUpload

    void doXMLMetadata(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary,
	  int workspaceItemID, ArrayList nonInternalBistreamsID, boolean hasMultipleFiles, String defaultValue,String basePath) 
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
		 {
           val = defaults[i].value;
		   if (val.trim().equals("") && defaultValue != null)
		   	val = defaultValue;
		 }
         else if (defaultValue != null)
           val = defaultValue;
		 else
		   val = "";
		 
         sb.append("<td colspan=\"2\">");

         String textareaName = fieldName;
         if (repeatable && i>0)
         	 textareaName = textareaName + "_" + i;

         sb.append("<textarea id=\""+textareaName+"\" class=\"xmlmetadata-source\" name=\"")
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
			   .append("jQuery(document).ready(function () {\n")
			   .append("	var xm = new XMLMetadata(\""+textareaName+"\");\n")
			   .append("	xm.basePath = '"+basePath+"';\n")
			   .append("	xm.setFCKeditorPath('"+basePath+"/extension/fckeditor/');\n")
			   .append("	xm.workspaceItemID = "+workspaceItemID+";\n")
			   .append("	xm.fieldTitle = '"+label+"';\n");
			 if (hasMultipleFiles == false)
			 {
			 	sb.append("	xm.hasMultipleFiles = false;\n");
				sb.append("	xm.langNotHasMultipleFiles = \"Please check \'"+LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.initial-questions.elem3")+"\'!\";\n");
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
				 sb.append("	xm.nonInternalBistreamsID = "+nIBIDary+";\n");
			 }
			 sb.append("	xm.createRootForm();\n");
			 sb.append("})\n");
			 sb.append("</script>\n");
		  }

	   sb.append("</td>\n");

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_")
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
//	      .append("_add\" class=\"add-more\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" class=\"add-more\" value=\"")
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
	    void doTaiwanAddress(javax.servlet.jsp.JspWriter out, Item item,
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
         
         sb.append("\" size=\"50\" value=\"")
           .append(val +"\"")
           .append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
	   	.append("   />")
	   .append(doControlledVocabulary(fieldName + (repeatable?"_" + i:""), pageContext, vocabulary))
	   .append("<script type=\"text/javascript\">" + "\n")
		.append("jQuery(document).ready(function () {" + "\n")
		.append("jQuery(\"input[name=\'")
		.append(fieldName);
		if (repeatable && i>0)
           sb.append("_").append(i);
		sb.append("\']\").taiwanAddress();" + "\n")
		.append("});" + "\n")
	   .append("</script>")
	   .append("</td>\n");
	   

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_")
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
//	      .append("_add\" class=\"add-more\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" class=\"add-more\" value=\"")
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
    }//End 
	void doItem(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary, String collectionID) 
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
         
         sb.append("\" size=\"50\" value=\"")
           .append(val +"\"")
           .append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
	   	.append(" class=\"input-type-item\"  />")
	   .append(doControlledVocabulary(fieldName + (repeatable?"_" + i:""), pageContext, vocabulary))
	   .append("<script type=\"text/javascript\">" + "\n")
		.append("jQuery(document).ready(function () {" + "\n")
		.append("	jQuery(\"input[name=\'")
		.append(fieldName);
		if (repeatable && i>0)
           sb.append("_").append(i);
		sb.append("\']\").doItem(\""+collectionID+"\");" + "\n")
		.append("});" + "\n")
	   .append("</script>")
	   .append("</td>\n");
	   

	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"submit\" name=\"submit_")
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
//	      .append("_add\" class=\"add-more\" value=\"Add More\"/> </td></tr>");
	      .append("_add\" class=\"add-more\" value=\"")
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
    }//End doItem
%>

<%
    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);

    SubmissionInfo si = SubmissionController.getSubmissionInfo(context, request);

    Item item = si.getSubmissionItem().getItem();

    final int halfWidth = 23;
    final int fullWidth = 50;
    final int twothirdsWidth = 34;

    DCInputSet inputSet = 
    	(DCInputSet) request.getAttribute("submission.inputs");

    Integer pageNumStr =
        (Integer) request.getAttribute("submission.page");
    int pageNum = pageNumStr.intValue();
    
    // for later use, determine whether we are in submit or workflow mode
    String scope = si.isInWorkflow() ? "workflow" : "submit";
%>

<dspace:layout locbar="off" titlekey="jsp.submit.edit-metadata.title" navbar="off" nocache="true">

<%
	contextPath = request.getContextPath();
%>



 <%--<form action="<%= request.getContextPath() %>/submit#<%= si.getJumpToField()%>" method="post" name="edit_metadata" onkeydown="return disableEnterKey(event);" id="edit-metadata-form">--%>
  <form action="" method="post" name="edit_metadata" onkeydown="return disableEnterKey(event);" id="edit-metadata-form">
	<jsp:include page="/submit/progressbar.jsp"></jsp:include>


<script type="text/javascript" src="<%= request.getContextPath() %>//extension/metadata-util.jsp"></script>
<script type="text/javascript">


setFormDatePicker();
setSaveButton();
setSubmissionController();
</script>
<%	//get Labels and Hints
		String collectionHandle = si.getSubmissionItem().getCollection().getHandle();
		String pageLabels[] = SubmissionUtil.getPageLabels(pageContext, collectionHandle, "jsp.submit.edit-metadata.heading");
		String pageHints[] = SubmissionUtil.getPageHints(collectionHandle);
		int pageTotal = SubmissionUtil.getNumberInputPages(collectionHandle);


		out.print("<h1>Page " + pageNum + "/ " + pageTotal + " : " + pageLabels[pageNum-1] + "</h1>");
		if (pageHints[pageNum-1].equals("") == false)
		{
			out.print("<p>" + pageHints[pageNum-1] + "</p>");
		}

%>

     <%-- HACK: a <center> tag seems to be the only way to convince certain --%>
     <%--       browsers to center the table. --%>
     
     <table border="0" width="100%"><center>
<%
	 int pageIdx = pageNum - 1; 
     DCInput[] inputs = inputSet.getPageRows(pageIdx, si.getSubmissionItem().hasMultipleTitles(),
                                                si.getSubmissionItem().isPublishedBefore() );
     for (int z = 0; z < inputs.length; z++) 
     {
       // ignore inputs invisible in this scope
       if (!inputs[z].isVisible(scope))
       {
           continue;
       }
       String dcElement = inputs[z].getElement();
       String dcQualifier = inputs[z].getQualifier();
       String dcSchema = inputs[z].getSchema();
       
       String fieldName;
       int fieldCountIncr;
       boolean repeatable;
       String vocabulary;

       vocabulary = inputs[z].getVocabulary();
       
       
       if (dcQualifier != null && !dcQualifier.equals("*"))
          fieldName = dcSchema + "_" + dcElement + '_' + dcQualifier;
       else
          fieldName = dcSchema + "_" + dcElement;


       if ((si.getMissingFields() != null) && (si.getMissingFields().contains(fieldName)))
       {
    	   if(inputs[z].getWarning() != null)
    	   {
    		   if(si.getJumpToField()==null || si.getJumpToField().length()==0)
    		   		si.setJumpToField(fieldName);

    		   String req = "<tr><td colspan=\"4\" class=\"submitFormWarn\">" +
    		   					inputs[z].getWarning() +
    		   					"<a name=\""+fieldName+"\"></a></td></tr>";	   		
    		   out.write(req);
       		}
       }
       else
       {
			//print out hints, if not null
    	   if(inputs[z].getHints() != null)
    	   { 
    		 	String hints = "<tr><td colspan=\"4\" class=\"submitFormHelp\">" +
    						 	inputs[z].getHints() +
    						 	"</td></tr>";

              	out.write(hints);
       		}
       }

       repeatable = inputs[z].getRepeatable();
       fieldCountIncr = 0;
       if (repeatable) 
       { 
         fieldCountIncr = 1;
         if (si.getMoreBoxesFor() != null && si.getMoreBoxesFor().equals(fieldName)) 
	     {
           fieldCountIncr = 2;
         }
       }

       String inputType = inputs[z].getInputType();
       String label = inputs[z].getLabel();
       boolean closedVocabulary = inputs[z].isClosedVocabulary();

	   //For fileupload
	   int workspaceItemID = si.getSubmissionItem().getID();
	   Bitstream[] bitstreams = si.getSubmissionItem().getItem().getNonInternalBitstreams();
	   ArrayList nonInternalBistreamsID = new ArrayList();	//new Int(bitstreams);
	   for (int i = 0; i < bitstreams.length; i++)
	   		nonInternalBistreamsID.add(bitstreams[i].getID());
	   boolean hasMultipleFiles = si.getSubmissionItem().hasMultipleFiles();
	   
	   //For XMLMetadata & other
	   String defaultValue = inputs[z].getDefaultValue();
	   
       if (inputType.equals("name")) 
       {
           doPersonalName(out, item, fieldName, dcSchema, dcElement, dcQualifier,
	     				  repeatable, fieldCountIncr, label, pageContext);
       } 
       else if (inputType.equals("date")) 
       {
           doDate(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	     		  repeatable, fieldCountIncr, label, pageContext, request);
       } 
       else if (inputType.equals("series")) 
       {
           doSeriesNumber(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	                      repeatable, fieldCountIncr, label, pageContext);
       } 
       else if (inputType.equals("qualdrop_value")) 
       {
           doQualdropValue(out, item, fieldName, dcSchema, dcElement, inputSet, repeatable,
                           fieldCountIncr, inputs[z].getPairs(), label, pageContext);
       } 
       else if (inputType.equals("textarea")) 
       {
	   	   doTextArea(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	     			  repeatable, fieldCountIncr, label, pageContext, vocabulary,
	     			  closedVocabulary);
       } 
       else if (inputType.equals("dropdown")) 
       {
	   		doDropDown(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	     			   repeatable, inputs[z].getPairs(), label);
       } 
       else if (inputType.equals("twobox")) 
       {
	   		doTwoBox(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	     			 repeatable, fieldCountIncr, label, pageContext, vocabulary, 
	     			 closedVocabulary);
       }
       else if (inputType.equals("list")) 
       {
          doList(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
           		repeatable, inputs[z].getPairs(), label);
       }
	   else if (inputType.equals("texteditor")) 
       {
	   	  doTextEditor(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	      			  repeatable, fieldCountIncr, label, pageContext, vocabulary,
	     			  closedVocabulary, request.getContextPath() + "/extension/fckeditor/");
       }
	   else if (inputType.equals("fileupload"))
       {
	   		doFileUpload(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	     			 repeatable, fieldCountIncr, label, pageContext, vocabulary, 
	     			 closedVocabulary, workspaceItemID, nonInternalBistreamsID, 
					 hasMultipleFiles);
       } 
	   else if (inputType.equals("xmlmetadata")) 
       {
	   	  doXMLMetadata(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	      			  repeatable, fieldCountIncr, label, pageContext, vocabulary,
	     			  closedVocabulary, workspaceItemID, 
					  nonInternalBistreamsID, hasMultipleFiles, defaultValue ,request.getContextPath());
       }
	   else if (inputType.equals("taiwanaddress")) 
	   {
		  doTaiwanAddress(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
							repeatable, fieldCountIncr, label, pageContext, vocabulary, 
							closedVocabulary);	
	   } 
	   else if (inputType.equals("item")) 
       {
		  doItem(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
							repeatable, fieldCountIncr, label, pageContext, vocabulary, 
							closedVocabulary, defaultValue);	
	   }
       else 
       {
	   		doOneBox(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	     			 repeatable, fieldCountIncr, label, pageContext, vocabulary, 
	     			 closedVocabulary);
       }
       
       if (hasVocabulary(vocabulary))
       {
%>

		<tr>
			<td>&nbsp;</td>
			<td colspan="3" class="submitFormHelpControlledVocabularies">
				<dspace:popup page="/help/index.html#controlledvocabulary"><fmt:message key="jsp.controlledvocabulary.controlledvocabulary.help-link"/></dspace:popup>
			</td>
		</tr>

<%
		}
%>
<%-- HACK: Using this line to give the browser hints as to the widths of cells --%>
       <tr>
         <td width="20%">&nbsp;</td>
         <td colspan="2" width="60%">&nbsp;</td>
         <td width="20%">&nbsp;</td>
       </tr>

<% 
     } // end of 'for rows'
%>
           </center> </table>
        
        
<%-- HACK:  Need a space - is there a nicer way to do this than <BR> or a --%>
<%--        blank <P>? --%>
        <p>&nbsp;</p>

<%-- Hidden fields needed for SubmissionController servlet to know which item to deal with --%>
        <%= SubmissionController.getSubmissionParameters(context, request) %>
    	<input type="hidden" id="fileupload_step" value="<%= SubmissionUtil.getFileUploadStep() %>" />
        <center>
    	<%-- <p>填寫或修改資料後請按下「儲存」，如欲儲存並前往下一步驟建立檔案資料，請按」下一步」。</p> --%>
   		<p>
   			<fmt:message key="jsp.submit.edit-metadata.save-hint">
                <fmt:param><fmt:message key="jsp.dspace-admin.general.save-temp"/></fmt:param>
    			<fmt:param><fmt:message key="jsp.submit.edit-metadata.next"/></fmt:param>
            </fmt:message>
   		</p>
            <table border="0" width="80%">
				<tr>
                    <td width="100%">
    					<input type="button" id="edit_metadata_save" style="width:80px;" value="<fmt:message key="jsp.dspace-admin.general.save-temp"/>" />
    					<span id="edit_metadata_save_message"></span>
    				</td>
                <%  //if not first page & step, show "Previous" button
					if(!(SubmissionController.isFirstStep(request, si) && pageNum<=1))
					{ %>
                    <td>
						<input type="submit" class="submitProgressPrev" name="<%=AbstractProcessingStep.PREVIOUS_BUTTON%>" value="<fmt:message key="jsp.submit.edit-metadata.previous"/>" />
                    </td>
				<%  } %>
                    <td>
                        <input type="submit" id="submitProgressNext" class="submitProgressNext" name="<%=AbstractProcessingStep.NEXT_BUTTON%>" value="<fmt:message key="jsp.submit.edit-metadata.next"/>"/>
                    </td>
                    <td>&nbsp;&nbsp;&nbsp;</td>
                    <td align="right">
                        <input type="submit"  class="cancel" name="<%=AbstractProcessingStep.CANCEL_BUTTON%>" value="<fmt:message key="jsp.submit.edit-metadata.cancelsave"/>"/>
                    </td>
                </tr>
            </table>
        </center>
    </form>
</dspace:layout>
