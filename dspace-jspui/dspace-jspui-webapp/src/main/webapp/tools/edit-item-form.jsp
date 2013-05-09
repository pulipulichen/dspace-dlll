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
  -f
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
<%@ page import="org.dspace.app.webui.util.SubmissionUtil" %>
<%@ page import="org.dspace.content.Bitstream" %>
<%@ page import="org.dspace.content.BitstreamFormat" %>
<%@ page import="org.dspace.content.Bundle" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.DCDate" %>
<%@ page import="org.dspace.content.DCValue" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.core.Constants" %>
<%@ page import="org.dspace.core.I18nUtil" %>
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
<%@ page import="java.util.ArrayList" %>
<%@ page import="javax.xml.xpath.*" %>
<%@ page import="javax.xml.parsers.*" %>
<%@ page import="java.net.URLEncoder" %>

<%@ page import="org.dspace.authorize.AuthorizeManager" %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>

<%@ include file="../extension/edit-item-form/util.jsp" %>
<%@ include file="../extension/filter-media/filter-media-util.jsp" %>

<%
	Context context = UIUtil.obtainContext(request);
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
	
	DCInputsReader dcInputsReader = new DCInputsReader();
	
	String action = (String) UIUtil.getOriginalURL(request);
	if (action.indexOf("action=json") != -1)
	{
		 JSPManager.showJSP(request, response,
	                    "/tools/upload-bitstream-json.jsp");
	}
	else if (action.indexOf("action=filter") != -1)
	{
		 JSPManager.showJSP(request, response,
	                    "/tools/bitstream-filter.jsp");
	}
	else if (action.indexOf("action=fckeditor_fileupload") != -1)
	{
		 JSPManager.showJSP(request, response,
	                    "/tools/upload-bitstream-fckeditor.jsp");
	}
	
	EditItemFormUtil editUtil = new EditItemFormUtil();
	
	//如果不想顯示進階編輯頁面，則把他改成false
	boolean showOriginalField = ConfigurationManager.getBooleanProperty("edit-tools.show-orginal-field", true);
	
		Bitstream[] nonInternalBitstreams = item.getNonInternalBitstreams();
		ArrayList nonInternalBistreamsID = new ArrayList();	//new Int(bitstreams);
		for (int i = 0; i < nonInternalBitstreams.length; i++)
			nonInternalBistreamsID.add(nonInternalBitstreams[i].getID());
	
	String community_id = request.getParameter("community_id");
	String collection_id = request.getParameter("collection_id");
	//boolean edit_collection = (community_id != null && collection_id != null);
	
	/*
	if (collections.length == 0 && collection_id != null)
	{
		try
		{
			Collection collection = Collection.find(context, Integer.parseInt(collection_id));
			
			if (collection != null)
			{
				Collection[] colls = new Collection[1];
				colls[0] = collection;
				
				collections = colls;
			}
		}
		catch (Exception e) {}
	}
	if (collections.length == 0 && item != null)
	{
		collections = item.getCollections();
	}
	*/
	boolean collectionDefaultItem = (item.getOwningCollection() != null && collections.length == 0);
	
	String parenttitle = item.getTitle();
	String parentlink = "/handle/" + item.getHandle();
	if (collectionDefaultItem)
	{
		parenttitle = LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.edit-collection.title");
		parentlink = "/tools/edit-communities?collection_id="+collection_id+"&community_id="+community_id;
	}
	
%>

<dspace:layout titlekey="jsp.tools.edit-item-form.title"
               navbar="admin"
               locbar="link"
               parenttitle="<%= parenttitle %>"
               parentlink="<%= parentlink %>"
               nocache="true">

<script type="text/javascript" src="<%= request.getContextPath() %>/extension/ajaxfileupload/fileupload_config.jsp"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/metadata-util.jsp"></script>

<%= editUtil.init(request.getContextPath()) %>
<script type="text/javascript">
doBackToItem("<%=handle %>");
</script>

<%-- 
  -- 為了應付文件對應(item-mapper)功能，必須要在此輸出多個collection的選擇器。(天啊，好複雜！！)
  -- --%>
<%
		ArrayList<InputForm> inputForms = new ArrayList<InputForm>();
		for (int i = 0; i < collections.length; i++)
		{
			String formName = SubmissionUtil.getFormName(collections[i].getHandle());
			int match = -1;
			for (int j = 0; j < inputForms.size(); j++)
			{
				if (inputForms.get(j).getFormName().equals(formName))
				{
					match = j;
					break;
				}
			}
			if (match == -1)
			{
				InputForm inputForm = new InputForm();
				inputForm.setFormName(formName);
				inputForm.addCollecitonHandle(collections[i].getHandle());
				inputForm.addCollecitonName(collections[i].getName());
				
				inputForms.add(inputForm);
			}
			else
			{
				InputForm inputForm = inputForms.get(match);
				inputForm.addCollecitonHandle(collections[i].getHandle());
				inputForm.addCollecitonName(collections[i].getName());
			}
		}
		
		if (collectionDefaultItem == true)
		{
			Collection ownCollection = item.getOwningCollection();
			InputForm inputForm = new InputForm();
			inputForm.addCollecitonHandle(ownCollection.getHandle());
			inputForm.addCollecitonName(ownCollection.getName());
			
			inputForms.add(inputForm);
		}
		else if (collections.length == 0)
		{
			InputForm inputForm = new InputForm();
			
			inputForms.add(inputForm);
		}
		
		//--------------------------------------------------
		//選擇編輯遞交表單
	
			if (inputForms.size() < 2)
			{
				out.print("<div class=\"colleciton-select-div\" style=\"display:none;\">");
				//out.print("<div class=\"colleciton-select-div\">");
			}
			else
				out.print("<div class=\"colleciton-select-div\">");
		 %>
			<fmt:message key="jsp.tools.edit-item-form.now-editing-form-name1"/>
			<%-- 您現在正在編輯 --%>
			<select id="collection_select" onclick="collectionSelect(this.value);">
			<%
			for (int i = 0; i < inputForms.size(); i++)
			{
				out.print("<option value=\"collection_id_"+i+"\">"+inputForms.get(i).getFormName()+"</option>");
				//out.print("<option value=\"collection_id_"+i+"2\">"+formNames.get(i)+"2</option>");
			}
			%>
			</select>
			<fmt:message key="jsp.tools.edit-item-form.now-editing-form-name2"/>
			<%-- 遞交程序 --%>
		</div>
	<%

		//for (int i = 0;  < ciollections.length; i++) 
		for (int i = 0; i < inputForms.size(); i++) 
		{ 
		 	//String collectionHandle = collections[i].getHandle();
		 	String collectionHandle = inputForms.get(i).getCollectionHandle(0);
		 
		 	int pages = dcInputsReader.getNumberInputPages(collectionHandle);
			String[] pageLabels = SubmissionUtil.getPageLabels(pageContext, collectionHandle);
			String[] pageHints = SubmissionUtil.getPageHints(collectionHandle);
			
%>

<div id="collection_id_<%= i %>" class="collection-root" <%
	if (i > 0)	out.print("style=\"display:none;\"");
%>>
<table width="800" style="margin: 0 auto;" height="50">
	<tr>
		<th width="10%" class="prev-th" style="display:none;"><button type="button" class="prev-<%=i %>">&lt;&lt;</button></th>
		<td>
			<div style="position:absolute;top:-10000;margin:0;visibility:hidden;" class="progressBarContainer-<%=i %>">
				<div class="progressBar-<%=i %>" id="submitProgressTable" style="margin:0;">
					<ul>
						<li>
							<input class="submitProgressButtonCurrent submitProgressButtonDone submitProgressButton" 
								id="progressbar_button_<%=i%>_0" type="button"  
								value="<fmt:message key="jsp.tools.edit-item-form.index"/>"/>
						</li>
<%
			
			if (true)
			{
				for(int j = 0; j < pages ; j++)
				{
						out.println("<li><input class=\"submitProgressButtonDone submitProgressButton\" id=\"progressbar_button_"+i+"_"+(j+1)+"\" type=\"button\"  value=\""+ pageLabels[j]+"\"/></li>\n");
				}
				
				if(showOriginalField == true)
				{
%>
					<li><input class="submitProgressButtonDone submitProgressButton" id="progressbar_button_<%=i %>_metadata" type="button"  value="<fmt:message key="jsp.tools.edit-item-form.edit-metadata-title"/>"/></li>
					<li><input class="submitProgressButtonDone submitProgressButton" id="progressbar_button_<%=i %>_bitstream" type="button"  value="<fmt:message key="jsp.tools.edit-item-form.edit-bitstream-title"/>"/></li>
<%
				}	
			}
%>
				</ul>
			</div>
			</div>
		</td>
		<th width="10%" class="next-th" style="display:none;"><button type="button" class="next-<%=i %>">&gt;&gt;</button></th>
	</tr>
</table>

<%
	int progressBarPages = pages;
	if (showOriginalField == true)
		progressBarPages = progressBarPages + 2;
	if (i == 0)
	{
		%>
		<script type="text/javascript">
		jQuery(document).ready(function() {
			progressBar("<%= i %>", <%= progressBarPages %>);
		});
		</script>
		<%
	}
	else
	{
		%>
		<textarea class="progress-init-javascript">
		jQuery(document).ready(function() {
			progressBar("<%= i %>", <%= progressBarPages %>);
		});
		</textarea>
		<%
	}
%>


<%
				int editPage = 0;
				for(editPage = 0; editPage <= pages ; editPage++)
				  {						
					    if (editPage == 0)
						{
							out.print("<div id=\"progressbar_div_"+i+"_"+editPage+"\" style=\"display:block ;width: 90%;\" class=\"submitProgressDiv\">");
%>							
    
    <%-- <p><strong>PLEASE NOTE: These changes are not validated in any way.
    You are responsible for entering the data in the correct format.
    If you are not sure what the format is, please do NOT make changes.</strong></p> --%>
	<%-- <p><strong><fmt:message key="jsp.tools.edit-item-form.note"/></strong></p> --%>
    
    <%-- <p><dspace:popup page="/help/collection-admin.html#editmetadata">More help...</dspace:popup></p>  --%>
	
	<%-- <div><dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.collection-admin\") + \"#editmetadata\"%>"><fmt:message key="jsp.morehelp"/></dspace:popup></div> --%>

    <center>
        <table width="90%" summary="Edit item table">
        	<%
        		String itemTitle = item.getTitle();
    			if (itemTitle != null)
    			{
    				%>
		            <tr>
		            	<td class="submitFormLabel" style="min-width: 100px" ondblclick="jQuery('form.edit-metadata div').show();"><fmt:message key="jsp.tools.edit-item-form.itemTitle"/></td>
		                <td class="standard" align="left">
		        			<%
		    					itemTitle = itemTitle.replaceAll("\\<.*?\\>", "");
		    					if (itemTitle.length() > 20)
		    						itemTitle = itemTitle.substring(0, 20) + "...";
		    					
		    					out.print(itemTitle);
		        			%>
		        		</td>
		            </tr>
    				<%
    			}
        	%>
            <tr>
                <%-- <td class="submitFormLabel">Item&nbsp;internal&nbsp;ID:</td> --%>
				<td class="submitFormLabel" style="min-width: 100px" ondblclick="jQuery('form.edit-metadata div').show();"><fmt:message key="jsp.tools.edit-item-form.itemID"/></td>
                <td class="standard" align="left" id="itemIDSign"><%= item.getID() %></td>
            </tr>
           	<%
           		if (handle != null)
           		{
           			%>
            <tr>
                <%-- <td class="submitFormLabel">Handle:</td> --%>
				<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.handle"/></td>
                <td class="standard" align="left"><%= (handle == null ? LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.edit-item-form.handle-null") : handle) %></td>
            </tr>
           			<%
           		}
           	%>
            <tr>
                <%-- <td class="submitFormLabel">Last modified:</td> --%>
				<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.modified"/></td>
                <td class="standard" align="left"><dspace:date date="<%= new DCDate(item.getLastModified()) %>" /></td>
            </tr>
            <tr>
                <%-- <td class="submitFormLabel">In Collections:</td> --%>
				<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.collections"/></td>
                <td class="standard" align="left">

                    <%-- = collections[i].getMetadata("name") --%>
                    <%
                    if (collections.length > 0)
                    {
	                    for (int c = 0; c < inputForms.get(i).getCollectionNumber(); c++)
	                    {
	                    	if (c > 0)
	                    		out.print("<br />");
	                    	String name = inputForms.get(i).getCollectionName(c);
	                    	out.print(name);
	                    }
	                }
	                else if (collectionDefaultItem == true)
	                {
	                	Collection ownCollection = item.getOwningCollection();
	                	%>
	                	<a href="<%= request.getContextPath() %>/handle/<%= ownCollection.getHandle() %>"><%= ownCollection.getName() %></a>
	                	<%
	                }
	                else
	                {
	                	%>
	                	<fmt:message key="jsp.tools.edit-item-form.collections-null"/>
	                	<%
	                }
                    %>

                </td>
            </tr>
            <%
            if (collectionDefaultItem == false)
            {
            	%>
            <tr>
				<td class="submitFormLabel" style="min-width: 100px" >
					<%--點閱次數:--%>
					<fmt:message key="jsp.tools.edit-item-form.count"/>
				</td>
                <td class="standard" align="left" id="itemIDSign"><%= item.getCount() %></td>
            </tr>
            <tr>
                <%-- <td class="submitFormLabel">Item page:</td> --%>
				<td class="submitFormLabel" ondblclick="location.href='<%= request.getContextPath() +"/tools/edit-item?handle=" + handle %>'">
					<fmt:message key="jsp.tools.edit-item-form.itempage"/>
				</td>
                <td class="standard" align="left">
<%  if (handle == null) { %>
                    <em><fmt:message key="jsp.tools.edit-item-form.item-page-null"/></em>
<%  } else {
    //String url = ConfigurationManager.getProperty("dspace.url") + "/handle/" + handle; 
	String url = "http://"
    	+ request.getServerName() 
    	+ ":" + request.getServerPort() 
    	+ request.getContextPath() 
    	+ "/handle/" + handle; 
    
    	%>
                    <a target="_blank" href="<%= url %>"><%= url %></a>
<%  } %>
                </td>
            </tr>	
            
            <tr>
            		<td class="submitFormLabel"><fmt:message key="jsp.admintools"/><%-- 文件管理 --%></td>
            		<td class="standard" align="left" valign="top">
<%
	if (collections.length > 0)
	{
		
	    if (!item.isWithdrawn())
	    {
	    	if (showOriginalField)
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
	    }
	    else
	    {
	    	if (showOriginalField)
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
	    }
	}	//if (collections.length > 0)
%>
                    <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
                        <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                        <input type="hidden" name="action" value="<%= EditItemServlet.START_DELETE %>" />
                        <%-- <input type="submit" name="submit" value="Delete (Expunge)..."> --%>
						<input type="submit" name="submit" value="<fmt:message key="jsp.tools.edit-item-form.delete-w-confirm.button"/>"/>
                    </form>
<%
  if (isAdmin && collections.length > 0)
  {
  	  if (showOriginalField)
  	  {
		%>                  <form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
		                        <input type="hidden" name="item_id" value="<%= item.getID() %>" />
		                        <input type="hidden" name="action" value="<%= EditItemServlet.START_MOVE_ITEM %>" />
								<input type="submit" name="submit" value="<fmt:message key="jsp.tools.edit-item-form.move-item.button"/>"/>
		                    </form>
		<%
		}
  }
%>
                </td>
           	</tr>
<%-- ===========================================================
     Edit item's policies
     =========================================================== --%>
<%
				if (collectionDefaultItem == false)
				{
					%>
			            <tr>
			                <%-- <td class="submitFormLabel">Item's Authorizations:</td> --%>
							<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.item-policies"/></td>
			                <td align="left">
			                    <form method="post" action="<%= request.getContextPath() %>/dspace-admin/authorize">
			                        <input type="hidden" name="handle" value="<%= ConfigurationManager.getProperty("handle.prefix") %>" />
			                        <input type="hidden" name="item_id" value="<%= item.getID() %>" />
			                        <%-- <input type="submit" name="submit_item_select" value="Edit..."> --%>
									<input type="submit" name="submit_item_select" value="<fmt:message key="jsp.tools.general.edit"/>"/>
			                    </form>
			                </td>
			            </tr>
			        <%
				}
            }	//if (collectionDefaultItem == false)
            %>
							<%
								boolean isMember = AuthorizeManager.isAdmin(UIUtil.obtainContext(request));
								if (isMember)
								{
									//產生預覽檔案按鈕
									String filterMediaLink = FilterMediaUtil.getLink(request, item);
									if (filterMediaLink.equals("") == false)
									{
										%>
										<%--<input type="button" value="多媒體轉檔" onclick="window.open('<%= filterMediaLink %>','_blank')" />--%>
					<tr>
						<td class="submitFormLabel"><fmt:message key="jsp.tools.edit-item-form.filter-media"/></td>
						<td>
										<input type="button" value="<fmt:message key="jsp.mydspace.general.open"/>" onclick="window.open('<%= filterMediaLink %>','_blank')" />
						</td>
					</tr>
										<%
									}
								}
							%>
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
							
<%	
						}
						else 
						{
						StringBuffer pageContent = new StringBuffer();
							out.print("<div id=\"progressbar_div_"+i+"_"+editPage+"\" style=\"display:none ;width: 90%;\" class=\"submitProgressDiv\">");

							pageContent.append("<h1>"+LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.heading")+" "+editPage+" / " + pages);
							if (!pageLabels[editPage-1].equals(LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.progressbar.describe")))
								pageContent.append(" : " + pageLabels[editPage-1]);
							pageContent.append("</h1>");

							//figure out which help page to display
							     if (editPage <= 1) 
							     {
							     	 pageContent.append("<div style=\"padding-left: 10px;\">"
							     	 	+ LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.info1")
							     	 	//+ "<a href=\"#\" onClick=\"var popupwin = window.open(\'"
							     	 	// + request.getContextPath()
							     	 	// + LocaleSupport.getLocalizedMessage(pageContext, "help.index")
							     	 	// +"#describe2\',\'dspacepopup\',\'height=600,width=550,resizable,scrollbars\');popupwin.focus();return false;\">"
							     	 	// 	+ LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.help")
							     	 	//+"</a>"
							     	    //+ "<dspace:popup page=\""+LocaleSupport.getLocalizedMessage(pageContext, "help.index") + "#describe2\">"+LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.help") + "</dspace:popup>"
							     	 	+ "</div>");
							     } 
							     else 
							     {
							     	 pageContent.append("<div>"
							     	 	+ LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.info2")
							     	 	+ "<a href=\"#\" onClick=\"var popupwin = window.open(\'"
							     	 	 + request.getContextPath()
							     	 	 + LocaleSupport.getLocalizedMessage(pageContext, "help.index")
							     	 	 +"#describe3\',\'dspacepopup\',\'height=600,width=550,resizable,scrollbars\');popupwin.focus();return false;\">"
							     	 	 	+ LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.help")
							     	 	+"</a>"
							     	 	+ "</div>");
							     }

							if (pageHints[editPage-1] != null && !pageHints[editPage-1].equals(""))
								pageContent.append("<p>"+ pageHints[editPage-1] +"</p>");

						
							DCInputSet inputSet = dcInputsReader.getInputs(collectionHandle);
							DCInput[] inputs = inputSet.getPageRows((editPage-1 ),true,true);
							
							pageContent.append("<table width=\"100%\"><tbody>");
							for (int z = 0; z < inputs.length; z++) 
							{       
								//print out hints, if not null
								if(inputs[z].getHints() != null)
								{ 
									String hints = "<tr><td colspan=\"4\" class=\"submitFormHelp\">" +
													inputs[z].getHints() +
													"</td></tr>";
									pageContent.append(hints);
								 }
								
								pageContent.append(editUtil.doInput(out, item, request, pageContext,
									inputs[z], inputSet, nonInternalBistreamsID));	
								/*
								%>
								<%-- HACK: Using this line to give the browser hints as to the widths of cells --%>
									   <tr>
										 <td width="10%">&nbsp;</td>
										 <td colspan="2" width="80%">&nbsp;</td>
										 <td width="10%">&nbsp;</td>
									   </tr>
								
								<% 
								*/
								pageContent.append("<tr>\n"
									+ "<td width=\"10%\">&nbsp;</td>\n"
									+ "<td colspan=\"2\" width=\"80%\">&nbsp;</td>\n"
									+ "<td width=\"10%\">&nbsp;</td>\n"
									+ "</tr>\n");
							}
							pageContent.append("</tbody></table></form>");
							String pC = pageContent.toString();
							out.write(pC);
						}
						out.print("</div>");
				  }	
			out.print("</div>");
		}	// 	for (int i = 0;  < ciollections.length; i++) 
%>

<div style="display:block">
    <form class="edit-metadata" method="post" action="<%= request.getContextPath() %>/tools/edit-item?action=<%= EditItemServlet.UPDATE_ITEM %>" id="editMetadataForm" >
	   <div id ="progressbar_div_metadata" style="display:none ;width: 90%;" class="submitProgressDiv">
        <h1><fmt:message key="jsp.tools.edit-item-form.title"/></h1>
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
					<%-- <input type="button" onclick="this.style.border='1px solid red'" name="submit_remove_<%= key %>_<%= sequenceNumber %>" value="<fmt:message key="jsp.tools.general.remove"/>"/>--%>
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
					<input type="submit" name="submit_addfield" value="<fmt:message key="jsp.tools.general.add"/>" />
                </td>
            </tr>
        </table>
        
        <p>&nbsp;</p>
		</div>

		<div id ="progressbar_div_bitstream" style="display:none ;width: 90%;"  class="submitProgressDiv"> 
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
                
		        <th id="t11" class="oddRowEvenCol" style="min-width: 60px;">
		        		<%-- <strong><fmt:message key="jsp.tools.edit-item-form.elem5"/></strong> --%>
		        		<span title="primary bitstream"><fmt:message key="jsp.tools.edit-item-form.elem5"/></span>
		        </th>
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
	
	//取得所有格式
	BitstreamFormat[] bitstreamFormats = BitstreamFormat.findAll(context);
	
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
                <%--
                <td headers="t15" class="<%= row %>RowEvenCol">
                    <input type="text" name="bitstream_format_id_<%= key %>" value="<%= bf.getID() %>" size="4" 
                    	class="bitstream_format_id"
                    	onchange="BitstreamTable.chackFormat(this)"/> 
                    (<%= bf.getShortDescription() %>)
                </td>
                --%>
                <td headers="t15" class="<%= row %>RowEvenCol">
                	<select  name="bitstream_format_id_<%= key %>" value="<%= bf.getID() %>"
                		class="bitstream_format_id"
                    	onchange="BitstreamTable.chackFormat(this)">
                    	<%
                    	for (int f = 0; f < bitstreamFormats.length; f++)
                		{
                			int bfs_id = bitstreamFormats[f].getID();
                			String bfs_desc = bitstreamFormats[f].getShortDescription();
                			if (bfs_desc.toLowerCase().equals("unknown"))
                				bfs_desc = "(" + LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.list-formats.unknown") + ")";
                			
                			String selected = "";
                			if (bf.getID() == bfs_id)
                				selected = "selected=\"selected\"";
                			
                			out.println("<option value=\""+bfs_id+"\" "+selected+">"+bfs_desc+"</option>");
                		}
                    	%>
                    </select>
                </td>
                <td headers="t16" class="<%= row %>RowOddCol">
                    <input type="text" name="bitstream_user_format_description_<%= key %>" 
                    	onchange="BitstreamTable.chackUserFormatDescription(this)"
                    	class="bitstream_user_format_description"
                    	value="<%= (bitstreams[j].getUserFormatDescription() == null ? "" : bitstreams[j].getUserFormatDescription()) %>"/>
                </td>
                <td headers="t17" class="<%= row %>RowEvenCol">
                    <%-- <a target="_blank" href="<%= request.getContextPath() %>/retrieve/<%= bitstreams[j].getID() %>">View</a>&nbsp;<input type="submit" name="submit_delete_bitstream_<%= key %>" value="Remove"> --%>
					<a target="_blank" href="<%= request.getContextPath() %>/retrieve/<%= bitstreams[j].getID() %>/<%= UIUtil.encodeBitstreamName(bitstreams[j].getName(),
                                    Constants.DEFAULT_ENCODING) %>"><fmt:message key="jsp.tools.general.view"/></a>&nbsp;<input type="submit" name="submit_delete_bitstream_<%= key %>" value="<fmt:message key="jsp.tools.general.remove"/>" />
                </td>
            </tr>
<%
            row = (row.equals("odd") ? "even" : "odd");
        }
    }
%>
        </table>
		<script type="text/javascript">
		BitstreamTable = {
			chackFormat: function (thisObj)
			{
				var id = jQuery.trim(thisObj.value);
				if (id != 1 && id != "")
				{
					var userFormatInput = jQuery(thisObj).parents("tr:first").find(".bitstream_user_format_description:first");
					var userFormat = userFormatInput.val();
					userFormat = jQuery.trim(userFormat);
					
					if (userFormat != "")
					{
						//if (window.confirm('如果您要設定 "格式"，則必須先清空 "自訂格式"。\n請問是否要清空 "自訂格式"？否則將還原 "格式" 到 "未知"。'))
						if (window.confirm('<fmt:message key="jsp.tools.edit-item-form.bitstream-table.check-format1"/>' 
								+ "\n"
								+ '<fmt:message key="jsp.tools.edit-item-form.bitstream-table.check-format2"/>'))
							userFormatInput.val("");
						else
							thisObj.value = 1;
					}
				}
			},
			chackUserFormatDescription: function (thisObj)
			{
				var desc = jQuery.trim(thisObj.value);
				if (id != "")
				{
					var idInput = jQuery(thisObj).parents("tr:first").find(".bitstream_format_id:first");
					var id = jQuery.trim(idInput.val());
					
					if (id != "1")
					{
						//if (window.confirm('如果您要設定 "自訂格式"，則必須將 "格式" 設為 "未知"。\n請問是否要將 "格式" 設定為 "未知"？否則將清空 "自訂格式"。'))
						if (window.confirm('<fmt:message key="jsp.tools.edit-item-form.bitstream-table.check-user-format-description1"/>'
								+ "\n"
								+ '<fmt:message key="jsp.tools.edit-item-form.bitstream-table.check-user-format-description2"/>'))
							idInput.val("1");
						else
							thisObj.value = "";
					}
				}
			}
		};
		</script>
		
        <p>&nbsp;</p>
		
        <%-- <p align="center"><input type="submit" name="submit_addbitstream" value="Add Bitstream"></p> --%>
        <center>
            <table width="70%" align="center">
                <tr>
                  <td align="center">
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
		</div>
</div>

        <p>&nbsp;</p>
        	
		<div style="text-align:center;width: 90%;">
			<button type="button" class="submitProgressPrev"><fmt:message key="jsp.submit.general.previous"/></button>
			<button type="button" class="submitProgressNext"><fmt:message key="jsp.submit.general.next"/></button>
		</div>
	
        <input type="hidden" name="item_id" value="<%= item.getID() %>"/>
        <%--<input type="hidden" name="action2" value="<%= EditItemServlet.UPDATE_ITEM %>"/>--%>


    
	    <%
	    if (collectionDefaultItem == true)
	    {
	    	%>
	    	<input type="hidden" name="submit_collection_default_item" value="true" />
	    	<input type="hidden" name="collection_id" value="<%= collection_id %>" />
	    	<input type="hidden" name="community_id" value="<%= community_id %>" />
	    	<div style="text-align:center;width: 90%;">
<fmt:message key="jsp.tools.edit-item-form.save-note"/>
<%-- 請注意: 編輯完成之後，請按頁面下方的 "更新" 或 "更新並回到文件" 才會儲存變更後的資料。 --%>

	            <table width="70%" align="center">
	                <tr>
	                    <td align="left">
							<input type="submit" name="submit" id="update_button" value="<fmt:message key="jsp.tools.general.save"/>" />
	                    </td>
						
	                    <td align="right">
	                        <input type="button" name="submit_cancel" value="<fmt:message key="jsp.tools.general.return"/>" onclick="javascript:location.href='<%= request.getContextPath() + parentlink  %>'" /> 
	                    </td>
	                </tr>
	            </table>
	        </div>
	        <%
	    }
	    else
	    {
	    	%>
	        <div style="text-align:center;width: 90%;">
<fmt:message key="jsp.tools.edit-item-form.save-note"/>
<%-- 請注意: 編輯完成之後，請按頁面下方的 "更新" 或 "更新並回到文件" 才會儲存變更後的資料。 --%>

	            <table width="70%" align="center">
	                <tr>
	                    <td align="left">
	                        <%-- <input type="submit" name="submit" value="Update" /> --%>
							<input type="submit" name="submit" id="update_button" value="<fmt:message key="jsp.tools.general.update"/>" />
							<input type="submit" name="submit" value="<fmt:message key="jsp.tools.edit-item-form.update-and-back"/>" onclick="checkBackToItem(this);" />
						</td>
	                    <td align="right">
							<input type="button" name="submit_cancel" value="<fmt:message key="jsp.tools.edit-item-form.cancel-and-back"/>" onclick="location.href='<%= request.getContextPath() + "/handle/" + item.getHandle() %>'" /> 
	                        <input type="submit" name="submit_cancel" value="<fmt:message key="jsp.tools.general.cancel"/>" /> 
							<%--<input type="button"  onclick ="locationSearch()" value="<fmt:message key="jsp.tools.general.cancel"/>" />--%>
	                    </td>
	                </tr>
	            </table>
	        </div>
        	<%
    	}
    	%>
    </form>
</dspace:layout>
