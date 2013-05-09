<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.io.IOException" %>
<%!
public class InputForm
{
	private String formName;
	private ArrayList<String> collectionHandles = new ArrayList<String>();
	private ArrayList<String> collectionNames = new ArrayList<String>();
	
	public InputForm()
	{
		//do nothing
	}
	
	public void setFormName(String f)
	{
		this.formName = f;
	}
	
	public void addCollecitonHandle(String handle)
	{
		this.collectionHandles.add(handle);
	}
	
	public void addCollecitonName(String name)
	{
		this.collectionNames.add(name);
	}
	
	public String getFormName()
	{
		return this.formName;
	}
	
	public String getCollectionHandle(int index)
	{
		if (index < this.collectionHandles.size())
			return this.collectionHandles.get(index);
		else
			return null;
	}
	
	public String getCollectionName(int index)
	{
		if (index < this.collectionNames.size())
			return this.collectionNames.get(index);
		else
			return null;
	}
	
	public int getCollectionNumber()
	{
		return this.collectionNames.size();
	}
}
%>
<%!
public class EditItemFormUtil {
	private String contextPath = "";
	
	public EditItemFormUtil () { }
	
	public String init(String basePath)
	{
		String output = 
			"<script type=\"text/javascript\" src=\""+basePath+"/extension/ajaxfileupload/fileupload_config.jsp\"></script>" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/ajaxfileupload/ajaxfileupload.js\"></script>" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/ajaxfileupload/fileupload.js\"></script>" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/ajaxfileupload/fileupload_xmlmetadata.js\"></script>" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/xmlmetadata/xmlmetadata-lang.jsp\"></script>" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/xmlmetadata/xmlmetadata-core.js\"></script>" + "\n"
			+ "<link rel=\"stylesheet\" href=\""+basePath+"/extension/xmlmetadata/xmlmetadata-style.css\" type=\"text/css\" media=\"screen\">" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/xmlmetadata/ui.datepicker.js\"></script>" + "\n"
			+ "<link rel=\"stylesheet\" href=\""+basePath+"/extension/xmlmetadata/flora.datepicker.css\" type=\"text/css\" media=\"screen\">" + "\n"
			+ "	" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/taiwan-address/jquery-plugin-taiwain-address.js\"></script>" + "\n"
			+ "	" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/progress-bar/jcarousellite.js\"></script>" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/progress-bar/jquery.easing.js\"></script>" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/progress-bar/progress-bar.js\"></script>" + "\n"
			+ "	" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/bitstream-display/jquery-ui/js/jquery-ui-1.7.1.custom.min.js\"></script>" + "\n"
			+ "<link rel=\"stylesheet\" href=\""+basePath+"/extension/bitstream-display/jquery-ui/css/smoothness/jquery-ui-1.7.1.custom.css\" type=\"text/css\" media=\"screen\">" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/input-type-item/jquery-plugin-input-type-item.jsp\"></script>" + "\n"
			+ "<link rel=\"stylesheet\" href=\""+basePath+"/extension/edit-item-form/edit-item-form.css\" type=\"text/css\" media=\"screen\">" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/edit-item-form/edit-item-form-js.jsp\"></script>" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/input-type-item/jquery-plugin-inputTypeItem-edit-item-form.js\"></script>" + "\n"
			+ "<script type=\"text/javascript\" src=\""+basePath+"/extension/fckeditor/FCKeditor-dialog.jsp\"></script>" + "\n"
			+ "	" + "\n";
		return output;
	}
	
	public String doControlledVocabulary(String fieldName, PageContext pageContext, String vocabulary) 
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
    
    public String getAddID(String schema, String element, String qualifier)
    {
    	 String addID = schema + "." + element;
		 if (qualifier != null) addID = addID + "." + qualifier;
		 
		 return addID;
    }
    
    public String getMetadataID(String header, String schema, String element, String qualifier, int index)
    {
    	String metadataID = header + schema + "_" + element;
		 if (qualifier != null) 
		 	metadataID = metadataID + "_" + qualifier;
		 
		 if (index < 10)
		 	metadataID = metadataID + "_0" + index;
		 else
		 	metadataID = metadataID + "_" + index;
		 
		 return metadataID;
    }

	public boolean hasVocabulary(String vocabulary)
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
	public String doPersonalName(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext) 
      throws java.io.IOException 
    {
		StringBuffer output = new StringBuffer();

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
			 .append("<td class=\"submitFormDateLabel\">")
//             .append("Last name<br>e.g. <strong>Smith</strong></td>")
			 .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.lastname"))
			 .append("</td>")
             //.append("<td class=\"submitFormDateLabel\" width=\"5%\">")
			 .append("<td class=\"submitFormDateLabel\">")
//             .append("First name(s) + \"Jr\"<br> e.g. <strong>Donald Jr</strong></td>")
			 .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.firstname"))
			 .append("</td>")
             //.append("<td width=\"40%\">&nbsp;</td>")
			 .append("<td>&nbsp;</td>")
             .append("</tr>");
      //out.write(headers.toString());
	  output.append(headers.toString());

	  int index = 0;
      for (int i = 0; i < fieldCount; i++) 
      {
		 first.setLength(0);
		 first.append(fieldName).append("_first");
		 if (repeatable &&  i>0)
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
			
			String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
			String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
			String editItemFormAddID = getAddID(schema, element, qualifier);
				
			if (i < defaults.length)
				dpn = new org.dspace.content.DCPersonName(defaults[i].value);
			else
				dpn = new org.dspace.content.DCPersonName();
		 
			 sb.append("<td><input type=\"text\" class=\"input-type-name input-type-name-last\" onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"")
			   .append(last.toString())
			   .append("\" size=\"10\" value=\"")
			   .append(dpn.getLastName().replaceAll("\"", "&quot;")) // Encode "
			   .append("\"  /></td>\n<td><input type=\"text\" class=\"input-type-name input-type-name-first\" onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"")
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
			sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
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
			sb.append("<td><input type=\"submit\" class=\"add-morer\" onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
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
		 index++;
      }

      //out.write(sb.toString());
	  output.append(sb.toString());;
	  return output.toString();
    }//doPersonalName End
    
	public String doDate(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, HttpServletRequest request) 
      throws java.io.IOException 
    {
		StringBuffer output = new StringBuffer();

      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      org.dspace.content.DCDate dateIssued;

      if (fieldCount == 0)
         fieldCount = 1;

	  int index = 0;
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
			
			String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
			String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
			String editItemFormAddID = getAddID(schema, element, qualifier);
			index++;
			 
	         sb.append("<td colspan=\"2\" nowrap=\"nowrap\" class=\"submitFormDateLabel input-type-date\">")
	         	//日
	         	.append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.day"))
					.append("<input type=\"text\" class=\"input-type-date input-type-date-day\" onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"")
				    .append(fieldName)
				    .append("_day");
	         if (repeatable && i>0)
	            sb.append("_").append(i);
	         sb.append("\" size=\"2\" maxlength=\"2\" value=\"")
	            .append((dateIssued.getDay() > 0 ? 
		         String.valueOf(dateIssued.getDay()) : "" ))
		    .append("\"  /> ")
				//.append("Month:<select name=\"")
	         	.append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.month"))
	            .append("<select class=\"input-type-date input-type-date-month\" onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"")
		    	.append(fieldName)
		    	.append("_month");
	         if (repeatable && i>0)
	            sb.append('_').append(i);
	         sb.append("\"  ><option value=\"-1\"")
	            .append((dateIssued.getMonth() == -1 ? " selected=\"selected\"" : ""))
				//.append(">(No month)</option>");
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
					.append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.year"))
					.append(" <input type=\"text\" class=\"input-type-date input-type-date-year\" onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"")
				    .append(fieldName)
				    .append("_year");
	         if (repeatable && i>0)
	            sb.append("_").append(i);
	         sb.append("\" size=\"4\" maxlength=\"4\" value=\"")
	            .append((dateIssued.getYear() > 0 ? 
		         String.valueOf(dateIssued.getYear()) : "" ))
		    .append("\"  />")
			 .append("<textarea class=\"javascript\" style=\"display:none\"> \n setFormDatePicker(); \n </textarea>" + "\n")
		    .append(" </td>\n");
	    
		 if (repeatable && i < defaults.length) 
		 {
		    // put a remove button next to filled in values
		    sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
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
		    sb.append("<td><input type=\"submit\" class=\"add-morer\" onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
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

      //out.write(sb.toString());
	  output.append(sb.toString());
	  return output.toString();
    }//doDATE End
    
	public String doSeriesNumber(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext) 
      throws java.io.IOException 
    {
		StringBuffer output = new StringBuffer();
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
      //out.write(headers.toString());
	  output.append(headers.toString());
      
      
      if (fieldCount == 0)
         fieldCount = 1;

	  int index = 0;
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

		String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
		String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
		String editItemFormAddID = getAddID(schema, element, qualifier);
		index++;
		 
         sb.append("<td><input type=\"text\" class=\"input-type-series input-type-series-series\" onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"")
           .append(fieldName)
	   .append("_series");
         if (repeatable && i>0)
           sb.append("_").append(i);

         sb.append("\" size=\"23\" value=\"")
           .append(sn.getSeries().replaceAll("\"", "&quot;"))
	   .append("\"  /></td>\n<td><input type=\"text\" class=\"input-type-series input-type-series-number\" onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"")
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
	    sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
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
	    sb.append("<td><input type=\"submit\" onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
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

      //out.write(sb.toString());
	  output.append(sb.toString());
	  return output.toString();
    }//doSeriesNumber End
	

    public String doTextArea(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary) 
      throws java.io.IOException 
    {
		StringBuffer output = new StringBuffer();
      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      String val;

      if (fieldCount == 0)
         fieldCount = 1;
      
	  int index = 0;
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

			String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
			String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
			String editItemFormAddID = getAddID(schema, element, qualifier);
			index++;
				
	         sb.append("<td colspan=\"2\"><textarea onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"")
	           .append(fieldName);
	         if (repeatable && i>0)
	         {
		           sb.append("_").append(i);
		     }
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
			    sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
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
			    sb.append("<td><input type=\"submit\" class=\"add-morer\"  onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
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

      //out.write(sb.toString());
	  output.append(sb.toString());
	  return output.toString();
    }	//doTextArea End
    
	public String doOneBox(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary) 
      throws java.io.IOException 
	{
		StringBuffer output = new StringBuffer();
      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      String val;

      if (fieldCount == 0)
         fieldCount = 1;

	  int index = 0;
      for (int i = 0; i < fieldCount; i++) 
      {
	 if (i == 0) 
	    sb.append("<tr><td class=\"submitFormLabel\" width=\"35%\">")
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
         

		String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
		String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
		String editItemFormAddID = getAddID(schema, element, qualifier);
		index++;
		 
         sb.append("\" style=\"width: 80%;\" value=\"")
           .append(val +"\"")
           //.append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
	   	   .append(" onchange=\"editItemFormSync(\'"+editItemFormID+"\', this);\" />")
	   //.append(doControlledVocabulary(fieldName + (repeatable?"_" + i:""), pageContext, vocabulary))
	   .append("</td>\n");
	  
	 String fieldNameFull = fieldName;
	 if (repeatable && i>0)
           fieldNameFull = fieldNameFull + "_" + i;
	 
     
	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
	      .append(fieldName)
	      .append("_remove_")
	      .append(i)
//	      .append("\" value=\"Remove This Entry\"/> </td></tr>");
	      .append("\" value=\"")
   	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove"))
   	      .append("\"/> </td></tr>");
	 } 
	 else if (repeatable && i == fieldCount - 1) 
	 //else if (true)
	 {
	    // put a 'more' button next to the last space
	    sb.append("<td><input type=\"button\" class=\"add-more\" onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
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

     	//out.write(sb.toString());
		output.append(sb.toString());
		return output.toString();
    }//doOneBox End
    
    public String doTaiwanAddress(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary) 
      throws java.io.IOException 
	{
		StringBuffer output = new StringBuffer();
      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      String val;

      if (fieldCount == 0)
         fieldCount = 1;

	  int index = 0;
      for (int i = 0; i < fieldCount; i++) 
      {
	 if (i == 0) 
	    sb.append("<tr><td class=\"submitFormLabel\" width=\"35%\">")
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
         

		String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
		String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
		String editItemFormAddID = getAddID(schema, element, qualifier);
		index++;
		 
         sb.append("\" size=\"80\" value=\"")
           .append(val +"\"")
           //.append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
	   	.append("  onchange=\"editItemFormSync('"+editItemFormID+"', this)\" class=\"doTaiwanAddress\" />")
	   //.append(doControlledVocabulary(fieldName + (repeatable?"_" + i:""), pageContext, vocabulary))
	   .append("<textarea class=\"javascript\" style=\"display:none\">" + "\n")
		.append("jQuery(document).ready(function () {" + "\n")
		.append("jQuery(\"input[name=\'")
		.append(fieldName);
		if (repeatable && i>0)
           sb.append("_").append(i);
		sb.append("\']\").taiwanAddress();" + "\n")
		.append("});" + "\n")
	   .append("</textarea>")
	   .append("</td>\n");
	  
	 String fieldNameFull = fieldName;
	 if (repeatable && i>0)
           fieldNameFull = fieldNameFull + "_" + i;
	 
     
	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
	      .append(fieldName)
	      .append("_remove_")
	      .append(i)
//	      .append("\" value=\"Remove This Entry\"/> </td></tr>");
	      .append("\" value=\"")
   	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove"))
   	      .append("\"/> </td></tr>");
	 } 
	 else if (repeatable && i == fieldCount - 1) 
	 //else if (true)
	 {
	    // put a 'more' button next to the last space
	    sb.append("<td><input type=\"button\" class=\"add-more\" onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
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

     	//out.write(sb.toString());
		output.append(sb.toString());
		return output.toString();
    }//doTaiwanAddress End
    
	public String doTwoBox(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary) 
      throws java.io.IOException 
    {
		StringBuffer output = new StringBuffer();
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
         //out.write(headers.toString());
		 output.append(headers.toString());
      }

      if (fieldCount == 0)
         fieldCount = 1;
      
	  int index = 0;
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

		String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
		String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
		String editItemFormAddID = getAddID(schema, element, qualifier);
		index++;

			
	    if (i < defaults.length)
	    {
			sb.append("<td align=\"left\"><input type=\"text\" onchange=\"editItemFormSync('"+editItemFormID+"', this);\" name=\"")
            	.append(fieldParam)
				.append("\" size=\"15\" value=\"")
				.append(defaults[i].value.replaceAll("\"", "&quot;"))
				.append("\"")
				.append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
				.append("   />&nbsp;<input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
				.append(fieldName)
				.append("_remove_")
				.append(i)
				.append("\" value=\"")
				.append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove2"))
				.append("\"/>")
				.append(doControlledVocabulary(fieldName + "_" + i, pageContext, vocabulary))
				.append("</td>\n");
		}
		else 
		{
			sb.append("<td align=\"left\"><input type=\"text\" onchange=\"editItemFormSync('"+editItemFormID+"', this);\" name=\"")
				.append(fieldParam)
				.append("\" size=\"15\"")
				.append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
				.append("/>")
				.append(doControlledVocabulary(fieldName + "_" + i, pageContext, vocabulary))
				.append("</td>\n");             
		}
		
		
		i++;
		
		editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
		editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
		index++;
		
	 	//param is field name and index (e.g. myfield_2) 
	 	//還有第二部份喔！
	 	fieldParam = fieldName + "_" + i;
	 	if (i < defaults.length)
	 	{
			sb.append("<td align=\"left\"><input type=\"text\" onchange=\"editItemFormSync('"+editItemFormID+"', this);\" name=\"")
				.append(fieldParam)
				.append("\" size=\"15\" value=\"")
				.append(defaults[i].value.replaceAll("\"", "&quot;"))
				.append("\"")
				.append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
				.append("  />&nbsp;<input align=\"top\" type=\"submit\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
				.append(fieldName)
				.append("_remove_")
				.append(i)
				.append("\" value=\"")
				.append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove2"))
				.append("\"/>")
				.append(doControlledVocabulary(fieldName + "_" + i, pageContext, vocabulary))
				.append("</td>\n");
			sb.append("</tr>");
		}
		else 
		{
			sb.append("<td align=\"left\"><input type=\"text\" onchange=\"editItemFormSync('"+editItemFormID+"', this);\" name=\"")
				.append(fieldParam)
				//.append("\" size=\"15\"/></td>");
				.append("\" size=\"15\"")
				.append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
				.append("/>")
				.append(doControlledVocabulary(fieldName + "_" + i, pageContext, vocabulary))
             	.append("</td>\n");
             	
             if (i+1 >= fieldCount) 
	   		{
	    		sb.append("<td><input type=\"submit\" onclick=\"editItemSubmit(\'"+editItemFormAddID+"\')\" name=\"submit_")
	       			.append(fieldName)
	       			.append("_add\" value=\"")
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

      //out.write(sb.toString());
	  output.append(sb.toString());
	  return output.toString();
    }//doTwoBox End
    
	public String doQualdropValue(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element,String qualifier, DCInputSet inputs, boolean repeatable,
      int fieldCountIncr, List qualMap, String label, PageContext pageContext) 
      throws java.io.IOException 
    {
		StringBuffer output = new StringBuffer();
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

	  int index = 0;
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
			
		String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
		String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
		String editItemFormAddID = getAddID(schema, element, qualifier);
		index++;
		
	 // do the dropdown box
	 sb.append("<td colspan=\"2\"><select onchange=\"editItemFormSync('"+editItemFormID+"', this)\" class=\"input-type-qualdrop_value input-type-qualdrop_value-qualifier\" name=\"")
           .append(fieldName)
	   .append("_qualifier");
         if (repeatable && j>0) 
           sb.append("_").append(j);
         sb.append("\"  >");
         for (int i = 0; i < qualMap.size(); i+=2)
         {
	   q = (String)qualMap.get(i);
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
         sb.append("</select>&nbsp;<input type=\"text\" onchange=\"editItemFormSync('"+editItemFormID+"', this)\" class=\"input-type-qualdrop_value input-type-qualdrop_value-value\" name=\"")
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
	    sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
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
	    sb.append("<td><input type=\"submit\" class=\"add-more\" onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
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

      //out.write(sb.toString());
	  output.append(sb.toString());
	  return output.toString();
    }//doQualdropValue End
    
	public String doTextEditor(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary, String sBasePath) 
      throws java.io.IOException 
    {
		StringBuffer output = new StringBuffer();

      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      String val;
	  

      if (fieldCount == 0)
         fieldCount = 1;
      
		if (repeatable == false
  	  		&& fieldCount > 1)
      	  fieldCount = 1;

	int index = 0;
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
         
		String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
		String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
		String editItemFormAddID = getAddID(schema, element, qualifier);
		index++;
			
         sb.append("<textarea onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"")
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
		 sb.append("<textarea class=\"javascript\" style=\"display:none\">\n")
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
		   //.append("	oFCKeditor.Config[\"EditorAreaStyles\"]	= \"body {background-color:#626262;color:white;}\" ;\n")
		   .append("	oFCKeditor.Config[\"ToolbarStartExpanded\"] = false;\n")
	       .append("	oFCKeditor.ReplaceTextarea() ;\n")
		   */
		   .append("});\n")
	       .append("</textarea>\n");
		 

	   sb.append("</td>\n");

	 if (repeatable && i < defaults.length) 
	 //if (true)
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
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
	    sb.append("<td><input type=\"submit\" class=\"add-more\" onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
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

      //out.write(sb.toString());
	  output.append(sb.toString());
	  return output.toString();
    }	//void doTextEditor()
    
	public String doDropDown(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      List valueList, String label) 
      throws java.io.IOException 
    {
		StringBuffer output = new StringBuffer();
      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      StringBuffer sb = new StringBuffer();
      Iterator vals;
      String display, value;
      int j;
      String editItemFormID = getMetadataID("value_", schema, element, qualifier, 0);
	  
	  sb.append("<tr><td class=\"submitFormLabel\">")
	.append(label)
	.append("</td>");

      sb.append("<td colspan=\"3\">")
        .append("<select class=\"input-type-dropdown\" onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"")
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
      //out.write(sb.toString());
	  output.append(sb.toString());
	  return output.toString();
    }//doDropDown End
    
	public String doList(javax.servlet.jsp.JspWriter out, Item item,
            String fieldName, String schema, String element, String qualifier, boolean repeatable,
            List valueList, String label) 
            throws java.io.IOException 
          {
		  	StringBuffer output = new StringBuffer();
        	DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
        	int valueCount = valueList.size();
        	
            StringBuffer sb = new StringBuffer();
            String display, value;
            int j;
			String editItemFormID = getMetadataID("value_", schema, element, qualifier, 0);

            int numColumns = 1;
            //if more than 3 display+value pairs, display in 2 columns to save space
            if(valueCount > 6)
                numColumns = 2;

            //print out the field label
            sb.append("<tr><td class=\"submitFormLabel\">")
        	  .append(label)
        	  .append("</td>");
            
            sb.append("<td colspan=\"2\" valign=\"top\"><table><tr>");
            
            if(numColumns > 1)
                sb.append("<td valign=\"top\">");
            else
                sb.append("<td valign=\"top\" colspan=\"2\">");
            
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
      	 	   
      	 	   sb.append("\" class=\"input-type-list\" onchange=\"editItemFormSync('"+editItemFormID+"', this)\" name=\"" )
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
            
            sb.append("</td></tr></table>");

            sb.append("</td></tr>");
            
            //out.write(sb.toString());
			output.append(sb.toString());
	 		return output.toString();
     }//doList End
     
	public String doXMLMetadata(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary,
	  int workspaceItemID, ArrayList nonInternalBistreamsID, boolean hasMultipleFiles, 
	  String defaultValue, String basePath) 
      throws java.io.IOException 
    {
		StringBuffer output = new StringBuffer();
      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      String val;

      if (fieldCount == 0)
         fieldCount = 1;

	  int index = 0;
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
		 
		String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
		String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
		String editItemFormAddID = getAddID(schema, element, qualifier);
		index++;
			
         sb.append("<textarea style=\"display:none;\" class=\"xmlmetadata-source\" id=\""+textareaName+"\" onchange=\"editItemFormSync('"+editItemFormID+"', this);\" name=\"")
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
			 sb.append("\n\n<textarea class=\"javascript\" style=\"display:none\">\n")
			   .append("jQuery(document).ready(function () {\n")
			   .append("	var xm = new XMLMetadata(\""+textareaName+"\");\n")
			   .append("	xm.basePath = '"+basePath+"';\n")
			   .append("	xm.setFCKeditorPath('"+basePath+"/extension/fckeditor/');\n")
			   //.append("	xm.setFCKeditorStyle(\"body {background-color:#626262;color:white;}\");\n")
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
			 sb.append("</textarea>\n");
		  }

	   sb.append("</td>\n");

	 //if (repeatable && i < defaults.length) 
	 if (true)
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
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
	    sb.append("<td><input type=\"submit\" class=\"add-more\" onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
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

      //out.write(sb.toString());
	  output.append(sb.toString());
	  return output.toString();
}	//doXMLMetadata End

    public String doFileUpload(javax.servlet.jsp.JspWriter out, Item item,
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
      
      if (repeatable == false
      	  && fieldCount > 1)
      	  fieldCount = 1;
      
	  int index = 0;
      for (int i = 0; i < fieldCount; i++) 
      {
      	  String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
      	  String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
		  String editItemFormAddID = getAddID(schema, element, qualifier);
		  
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
					
					if (nonInternalBistreamsID.indexOf(id) == -1)
						continue;
				  }
			  }
			     
		         String inputName = fieldName;
		         if (repeatable && i>0)
		           inputName = inputName + "_" + i;


					 sb.append("<td colspan=\"2\">");

				if (hasMultipleFiles == true)
				{
				sb.append("\n<input type=\"text\" onchange=\"editItemFormSync('"+editItemFormID+"', this);\" id=\""+editItemFormID+"\" name=\""+inputName+"\" value=\""+val+"\" style=\"display:none\"   />\n")
					.append("	<input type=\"file\" onchange=\"jQuery(this).nextAll('button.fileupload-do:first').click();\" />\n")
					.append("	<span></span>\n")
					.append("	<button class=\"fileupload-do\" onclick=\"return ajaxFileUpload(this, "+workspaceItemID+", '"+label+"');\" type=\"button\">Upload</button>\n");
					
					 if (!val.equals(""))
					 {
					sb.append("	<script type=\"text/javascript\">")
						.append("jQuery(document).ready(function () {")
						.append("	ajaxFileUploadExist(\""+editItemFormID+"\");")
						.append("});")
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
			    sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
			      .append(fieldName)
			      .append("_remove_")
			      .append(i)
		//	      .append("\" value=\"Remove This Entry\"/> </td></tr>");
			      .append("\" value=\"")
		   	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove"))
		   	      .append("\" style=\"display:none\" ")
				  .append("/>")
				  .append("<button align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\">"+LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove")+"</button>")
				  .append(" </td></tr>");
			 } 
			 else if (repeatable && i == fieldCount - 1) 
			 {
			    // put a 'more' button next to the last space
			    sb.append("<td><input type=\"button\" class=\"add-more\" onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
			      .append(fieldName)
		//	      .append("_add\" value=\"Add More\"/> </td></tr>");
			      .append("_add\" value=\"")
			      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.add"))
			      .append("\"/> </td></tr>");
			 } 
			 else 
			 {
			    // put a blank if nothing else
			    sb.append("<td>")
					.append("	<button class=\"fileupload-cancel\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" style=\"display:none\" type=\"button\">"+LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove")+"</button>\n")
					.append("&nbsp;</td></tr>");
			 }
	 	index++;
      }	//for end

      //out.write(sb.toString());
      return sb.toString();
    }	//end of doFileUpload
    
	public String doItem(javax.servlet.jsp.JspWriter out, Item item,
      String fieldName, String schema, String element, String qualifier, boolean repeatable,
      int fieldCountIncr, String label, PageContext pageContext, String vocabulary, boolean closedVocabulary, String collectionID) 
      throws java.io.IOException 
	{
		StringBuffer output = new StringBuffer();
      DCValue[] defaults = item.getMetadata(schema, element, qualifier, Item.ANY);
      int fieldCount = defaults.length + fieldCountIncr;
      StringBuffer sb = new StringBuffer();
      String val;

      if (fieldCount == 0)
         fieldCount = 1;

	  int index = 0;
      for (int i = 0; i < fieldCount; i++) 
      {
	 if (i == 0) 
	    sb.append("<tr><td class=\"submitFormLabel\" width=\"35%\">")
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
         

		String editItemFormID = getMetadataID("value_", schema, element, qualifier, index);
		String editItemFormRemoveID = getMetadataID("submit_remove_", schema, element, qualifier, index);
		String editItemFormAddID = getAddID(schema, element, qualifier);
		index++;
		 
         sb.append("\" size=\"80\" value=\"")
           .append(val +"\"")
           //.append(hasVocabulary(vocabulary)&&closedVocabulary?" readonly=\"readonly\" ":"")
	   	.append("  onchange=\"editItemFormSync('"+editItemFormID+"', this)\" class=\"doItem\" />")
	   //.append(doControlledVocabulary(fieldName + (repeatable?"_" + i:""), pageContext, vocabulary))
	   .append("<textarea class=\"javascript\" style=\"display:none\">" + "\n")
		.append("jQuery(document).ready(function () {" + "\n")
		.append("jQuery(\"input[name=\'")
		.append(fieldName);
		if (repeatable && i>0)
           sb.append("_").append(i);
		sb.append("\']\").doItem("+collectionID+");" + "\n")
		.append("});" + "\n")
	   .append("</textarea>")
	   .append("</td>\n");
	  
	 String fieldNameFull = fieldName;
	 if (repeatable && i>0)
           fieldNameFull = fieldNameFull + "_" + i;
	 
     
	 if (repeatable && i < defaults.length) 
	 {
	    // put a remove button next to filled in values
	    sb.append("<td><input align=\"top\" type=\"button\" class=\"edit-item-remove-button\" onclick=\"editItemRemove('"+editItemFormRemoveID+"')\" name=\"submit_")
	      .append(fieldName)
	      .append("_remove_")
	      .append(i)
//	      .append("\" value=\"Remove This Entry\"/> </td></tr>");
	      .append("\" value=\"")
   	      .append(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.remove"))
   	      .append("\"/> </td></tr>");
	 } 
	 else if (repeatable && i == fieldCount - 1) 
	 //else if (true)
	 {
	    // put a 'more' button next to the last space
	    sb.append("<td><input type=\"button\" class=\"add-more\" onclick=\"editItemAdd('"+editItemFormAddID+"')\" name=\"submit_")
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

     	//out.write(sb.toString());
		output.append(sb.toString());
		return output.toString();
    }	//doItem
    
    public String doInput(javax.servlet.jsp.JspWriter out, Item item, HttpServletRequest request, PageContext pageContext, 
    	DCInput input, DCInputSet inputSet, ArrayList nonInternalBistreamsID)
    	throws IOException
    {
    	String dcElement = input.getElement();
		String dcQualifier = input.getQualifier();
		String dcSchema = input.getSchema();
		
		String fieldName;
		int fieldCountIncr;
		boolean repeatable;
		String vocabulary;
		
		vocabulary = input.getVocabulary();
		
		if (dcQualifier != null && !dcQualifier.equals("*"))
		  fieldName = dcSchema + "_" + dcElement + '_' + dcQualifier;
		else
		  fieldName = dcSchema + "_" + dcElement;
		  
		 repeatable = input.getRepeatable();
		fieldCountIncr = 0;
		if (repeatable == true)
			fieldCountIncr = 1;
		
		String inputType = input.getInputType();
		String label = input.getLabel();
		boolean closedVocabulary = input.isClosedVocabulary();		
		
		String defaultValue = input.getDefaultValue();
		
		boolean hasMultipleFiles = true;
		int workspaceItemID = item.getID();
		
		if (inputType.equals("name")) 
		{
			return doPersonalName(out, item, fieldName, dcSchema, dcElement, dcQualifier,
						  repeatable, fieldCountIncr, label, pageContext);
		}
		else if (inputType.equals("date")) 
		{
			return doDate(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
				  repeatable, fieldCountIncr, label, pageContext, request);
		} 
		else if (inputType.equals("series")) 
		{
			return doSeriesNumber(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
						  repeatable, fieldCountIncr, label, pageContext);
		} 
		else if (inputType.equals("qualdrop_value")) 
		{
			return doQualdropValue(out, item, fieldName, dcSchema, dcElement, dcQualifier,  inputSet, repeatable,
						   fieldCountIncr, input.getPairs(), label, pageContext);
		} 
		else if (inputType.equals("textarea")) 
		{
			return doTextArea(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
					  repeatable, fieldCountIncr, label, pageContext, vocabulary,
					  closedVocabulary);
		}
		else if (inputType.equals("texteditor")) 
		{
			return doTextEditor(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
						repeatable, fieldCountIncr, label, pageContext, vocabulary,
						closedVocabulary, request.getContextPath() + "/extension/fckeditor/");
		}
		else if (inputType.equals("fileupload"))
       {
	   		return doFileUpload(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
	     			 repeatable, fieldCountIncr, label, pageContext, vocabulary, 
	     			 closedVocabulary, workspaceItemID, nonInternalBistreamsID, 
					 hasMultipleFiles);
       } 
		else if (inputType.equals("twobox")) 
		{
			return doTwoBox(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
					 repeatable, fieldCountIncr, label, pageContext, vocabulary, 
					 closedVocabulary);
		}
		else if (inputType.equals("list")) 
		{
			return doList(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
				  repeatable, input.getPairs(), label);
		}
		else if (inputType.equals("dropdown")) 
		{
			return doDropDown(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
					   repeatable, input.getPairs(), label);
		} 
		else if (inputType.equals("xmlmetadata")) 
		{
			return doXMLMetadata(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
					  repeatable, fieldCountIncr, label, pageContext, vocabulary,
					  closedVocabulary, workspaceItemID, 
					  nonInternalBistreamsID, hasMultipleFiles, defaultValue, 
					  request.getContextPath());
		} 
		else if (inputType.equals("taiwanaddress")) 
		{
			return doTaiwanAddress(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
				repeatable, fieldCountIncr, label, pageContext, vocabulary, 
				closedVocabulary);	
		}
		else if (inputType.equals("item")) 
		{
			return doItem(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
				repeatable, fieldCountIncr, label, pageContext, vocabulary, 
				closedVocabulary, defaultValue);	
		}
		else
		{
			return doOneBox(out, item, fieldName, dcSchema, dcElement, dcQualifier, 
				repeatable, fieldCountIncr, label, pageContext, vocabulary, 
				closedVocabulary);	
		}
    
    }	//end of public String doInput()
    
}	//end of EditItemFormUtil
%>