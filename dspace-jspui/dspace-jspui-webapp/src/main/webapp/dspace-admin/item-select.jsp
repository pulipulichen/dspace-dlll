<%--
  - item-select.jsp
  -
  - Version: $Revision: 1947 $
  -
  - Date: $Date: 2007-05-18 08:50:29 -0500 (Fri, 18 May 2007) $
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
  - Form requesting a Handle or internal item ID for item editing
  -
  - Attributes:
  -     invalid.id  - if this attribute is present, display error msg
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="org.dspace.core.Context"   %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.browse.ItemCounter"%>
<%
	Context c = UIUtil.obtainContext(request);
	ItemCounter ic = new ItemCounter(c);	
%>
	
<dspace:layout titlekey="jsp.dspace-admin.item-select.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.dspace-admin.authorize-main.title"
               parentlink="/dspace-admin/authorize">
  
    <%-- <h1>Select an Item</h1> --%>  

<h1><fmt:message key="jsp.dspace-admin.item-select.heading"/></h1>
    
<%
    if (request.getAttribute("invalid.id") != null) { %>
    <%-- <p><strong>The ID you entered isn't a valid item ID.</strong>  If you're trying to
    edit a community or collection, you need to use the
    <a href="<%= request.getContextPath() %>/dspace-admin/edit-communities">communities/collections admin page.</a></p> --%>

    <p><fmt:message key="jsp.dspace-admin.item-select.text">
        <fmt:param><%= request.getContextPath() %>/dspace-admin/edit-communities</fmt:param>
    </fmt:message></p>
<%  } %>

    <%-- <p>Enter the Handle or internal item ID of the item you wish to select. --%>
    <div><fmt:message key="jsp.dspace-admin.item-select.enter"/>
      <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\") + \"#itempolicies\"%>"><fmt:message key="jsp.morehelp"/></dspace:popup></div>
    
    <form method="post" action="" name="itemselect">
    	<input type="hidden" name="authorize_admin" value="true" />
        <center>
            <table class="miscTable">
                <tr class="oddRowEvenCol">
                    <%-- <td class="submitFormLabel">Handle:</td> --%>
                    <td class="submitFormLabel oddRowEvenCol"><label for="thandle" style="font-size: 12pt;"><fmt:message key="jsp.dspace-admin.item-select.handle"/></label></td>
                    <td class="oddRowOddCol">
                            <input type="text" name="handle" id="thandle" value="<%= ConfigurationManager.getProperty("handle.prefix") %>/" style="width:95%">
        			</td>
        			<td class="oddRowEvenCol">
                            <%-- <input type="submit" name="submit_item_select" value="Find"> --%>
                            <input type="submit" name="submit_item_select" value="<fmt:message key="jsp.dspace-admin.item-select.find"/>" />
                    </td>
                </tr>
                <tr class="oddRowOddCol">
                    <%-- <td class="submitFormLabel">Internal ID:</td> --%>
                    <td class="submitFormLabel evenRowEvenCol"><label for="titem_id"><fmt:message key="jsp.dspace-admin.item-select.id"/></label></td>
                    <td class="evenRowOddCol">
                            <input type="text" name="item_id" id="item_id" style="width:95%">
        			</td>
        			<td class="evenRowEvenCol">
                            <%-- <input type="submit" name="submit_item_select" value="Find"> --%>
                            <input type="submit" name="submit_item_select" id="submit_item_select" value="<fmt:message key="jsp.dspace-admin.item-select.find"/>" />
                    </td>
                </tr>
        		<tr class="oddRowEvenCol">
                    <td class="submitFormLabel oddRowEvenCol">
        				<label for="tcollection_id">
        					<fmt:message key="jsp.dspace-admin.item-select.browse-heading"/>
        					<%-- 瀏覽合集中的文件: --%>
        				</label>
        			</td>
                    <td class="oddRowOddCol">
                            <select size="12" id="collection_id" style="width:95%">
        						<option selected="selected" value=""><fmt:message key="jsp.general.genericScope"/></option>
		                        <%  
									Collection[] collections = Collection.findAll(c);
									for (int i = 0; i < collections.length; i++) { 
										int count = ic.getCount(collections[i]);
										if (count == 0)
											continue;
										
										String name = collections[i].getMetadata("name");
		                            	if (name.equals(""))
		                            		name = LocaleSupport.getLocalizedMessage(pageContext, 
		            							"org.dspace.content.Collection.untitled");
		            				%>
		                            <option value="<%= collections[i].getID()%>">
		                                <%= name %> [<%= count %>]
		                            </option>
		                        <%  } %>	
        					</select>
        			</td>
        			<td class="oddRowEvenCol">
                            <%-- <input type="submit" name="submit_item_select" value="Find"> --%>
                            <input type="button" name="submit_item_select" value="<fmt:message key="jsp.dspace-admin.item-select.browse"/>"
                            	onclick="javascript:popup_window('<%= request.getContextPath() %>/tools/item-select-list?multiple=false&collection_id=' + document.getElementById('collection_id').value, 'item_popup');" />
                    </td>
                </tr>
            </table>
        </center>
    </form>
    							
</dspace:layout>
