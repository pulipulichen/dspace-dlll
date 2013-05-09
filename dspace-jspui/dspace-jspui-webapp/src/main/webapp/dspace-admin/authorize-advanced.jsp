<%--
  - authorize-advanced.jsp
  -
  - $Id: authorize-advanced.jsp 2218 2007-09-28 13:17:04Z jrutherford $
  -
  - Version: $Revision: 2218 $
  -
  - Date: $Date: 2007-09-28 08:17:04 -0500 (Fri, 28 Sep 2007) $
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
  - Advanced policy tool - a bit dangerous, but powerful
  -
  - Attributes:
  -  collections - Collection [] all DSpace collections
  -  groups      - Group      [] all DSpace groups for select box
  - Returns:
  -  submit_advanced_clear - erase all policies for set of objects
  -  submit_advanced_add   - add a policy to a set of objects
  -  collection_id         - ID of collection containing objects
  -  resource_type         - type, "bitstream" or "item"
  -  group_id              - group that policy relates to
  -  action_id             - action that policy allows
  -
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>


<%@ page import="java.util.List"     %>
<%@ page import="java.util.Iterator" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.content.Collection"       %>
<%@ page import="org.dspace.core.Constants"           %>
<%@ page import="org.dspace.eperson.Group"            %>
<%@ page import="org.dspace.core.Context"            %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="org.dspace.browse.ItemCounter"%>
	
<%
    Group      [] groups     = (Group      []) request.getAttribute("groups"     );
    Collection [] collections= (Collection []) request.getAttribute("collections");
    request.setAttribute("LanguageSwitch", "hide");
    Context context = UIUtil.obtainContext(request);
    ItemCounter ic = new ItemCounter(context);	
%>

<dspace:layout titlekey="jsp.dspace-admin.authorize-advanced.advanced"
               navbar="admin"
               locbar="link"
               parentlink="/dspace-admin/authorize"
               parenttitlekey="jsp.dspace-admin.authorize-main.title">

<h1><fmt:message key="jsp.dspace-admin.authorize-advanced.advanced"/></h1>

<%
	if (request.getAttribute("action") != null)
	{
		String key = "jsp.dspace-admin.authorize-advanced.action-note." + request.getAttribute("action");
		%>
		<div style="text-align:center;border:1px solid gray;padding:5px;">
			<fmt:message key="<%= key %>"/>
		</div>
		<%
	}	
%>

	<%-- <p>Allows you to do wildcard additions to and clearing
       of policies for types of content contained in a collection.
       Warning, dangerous - removing READ permissions from
       items will make them not viewable!  <dspace:popup page="/help/site-admin.html#advancedpolicies">More help...</dspace:popup></p> --%>
	<div><fmt:message key="jsp.dspace-admin.authorize-advanced.text"/> <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\") +\"#advancedpolicies\"%>"><fmt:message key="jsp.morehelp"/></dspace:popup></div>

	<script type="text/javascript">
	function checkAdvancedPolicyManagerForm(thisForm) {
		var collection_id = thisForm.collection_id.value;
		var group_id = thisForm.group_id.value;
		
		if (collection_id == "")
		{
			//alert("請選擇合集");
			alert("<fmt:message key="jsp.dspace-admin.authorize-advanced.collection-not-select"/>");
			
			thisForm.collection_id.focus();
			return false;
		}
		else if (group_id == "")
		{
			if (typeof(skipCheckGroup) == "undefined")
			{
				//alert("請選擇群組");
				alert("<fmt:message key="jsp.dspace-admin.authorize-advanced.group-not-select"/>");
				
				thisForm.group_id.focus();
				return false;
			}
		}
		return true;
	}
	
	function comfirnClear()
	{
		if (window.confirm("<fmt:message key="jsp.dspace-admin.authorize-advanced.confirm"/>"))
		{
			skipCheckGroup = true;
			return true;
		}
		else
			return false;
	}
	
	function changeType(type)
	{
		var action = jQuery("select#taction_id")
			.empty();
		if (type == "<%=Constants.ITEM%>")
			var options = jQuery("select#taction_item").children().clone();
		else if (type == "<%=Constants.BITSTREAM%>")
			var options = jQuery("select#taction_bitstream").children().clone();
		
		action.append(options);
	}
	</script>
    <form method="post" action="" onsubmit="return checkAdvancedPolicyManagerForm(this)">

    <table class="miscTable" align="center" summary="Advanced policy manager">
        <tr class="oddRowEvenCol">     
            <%-- <td>Collection:</td> --%>
            <th id="t1" class="oddRowEvenCol" valign="top" align="left"><label for ="tcollection">1. <fmt:message key="jsp.dspace-admin.authorize-advanced.col"/></label></th>
            <td headers="t1" class="oddRowOddCol" colspan="2">
                <select size="10" name="collection_id" id="tcollection" style="width: 100%;">
                    <%  for(int i = 0; i < collections.length; i++ ) { 
                    	int count = ic.getCount(collections[i]);
						if (count == 0)
							continue;
                    	
        				String name = collections[i].getMetadata("name");
        				if (name.equals(""))
        					name = LocaleSupport.getLocalizedMessage(pageContext, 
            							"org.dspace.content.Collection.untitled");
        			%>
                            <option value="<%= collections[i].getID() %>"> <%= name %> (<%= collections[i].getID() %>) [<%= count %>]
                            </option>
                        <%  } %>
                </select>
            </td>
        </tr>

        <tr class="evenRowEvenCol">
            <%-- <td>Content Type:</td> --%>
            <th class="evenRowEvenCol" id="t2" valign="top" align="left"><label for="tresource_type">2 .<fmt:message key="jsp.dspace-admin.authorize-advanced.type"/></label></th>
            <td class="evenRowOddCol" headers="t2" colspan="2">
            	<label for="resuorce_type_1"><input type="radio" name="resource_type" value="<%=Constants.ITEM%>" checked="checked" id="resuorce_type_1" onchange="javascript:changeType(this.value);" />
            		<fmt:message key="jsp.dspace-admin.authorize-advanced.type1"/></label>
            	<label for="resuorce_type_2"><input type="radio" name="resource_type" value="<%=Constants.BITSTREAM%>" id="resuorce_type_2" onchange="javascript:changeType(this.value);" />
            		<fmt:message key="jsp.dspace-admin.authorize-advanced.type2"/></label>
            </td>
        </tr>

        <tr class="oddRowEvenCol">
            <%-- <tr><td>Action:</td> --%>
            <th class="oddRowEvenCol" rowspan="2" id="t4" valign="top" align="left"><label for="taction_id">3. <fmt:message key="jsp.dspace-admin.authorize-advanced.action"/></label></th>
            <td class="evenRowEvenCol" headers="t4" valign="top">
            	<strong><fmt:message key="jsp.dspace-admin.authorize-advanced.add-heading"/></strong>
            </td>
            <td class="evenRowOddCol">
            	<ul>
            	<li>
            	<fmt:message key="jsp.dspace-admin.authorize-advanced.group"/>
            	<br />
            	<select size="10" name="group_id" id="tgroup_id" style="width:80%;">
                    <%  for(int i = 0; i < groups.length; i++ ) { %>
                            <option value="<%= groups[i].getID() %>"> <%= UIUtil.getGroupLocalizeName(context, pageContext, groups[i]) %>
                            </option>
                        <%  } %>
                </select>
                </li>
                <li>
                	<%-- 選擇權限: --%>
                	<fmt:message key="jsp.dspace-admin.authorize-advanced.policy"/>
            		<select name="action_id" id="taction_id">
                    <%  
                    	if (true)
                		{
	                    	int resourceRelevance = 1 << Constants.ITEM;
	                    	for( int i = 0; i < Constants.actionText.length; i++ ) 
	                    	{ 
	                    		if( (Constants.actionTypeRelevance[i] & resourceRelevance) > 0)
	                    		{
	                    	%>
	                        <option value="<%= i %>">
	                        	<%= UIUtil.getAuthorizeActionLocalizeMessage(pageContext,
	                        		Constants.actionText[i]) %>
	                        </option>
	                    	<% 	}
	                    		
	                    	} 
	            		}
	                %>
                	</select>
                	
                	<select id="taction_item" style="display:none">
                    <%  
                    	if (true)
                		{
	                    	int resourceRelevance = 1 << Constants.ITEM;
	                    	for( int i = 0; i < Constants.actionText.length; i++ ) 
	                    	{ 
	                    		if( (Constants.actionTypeRelevance[i] & resourceRelevance) > 0)
	                    		{
	                    	%>
	                        <option value="<%= i %>">
	                        	<%= UIUtil.getAuthorizeActionLocalizeMessage(pageContext,
	                        		Constants.actionText[i]) %>
	                        </option>
	                    	<% 	}
	                    		
	                    	} 
	            		}
	                %>
                	</select>
                	<select id="taction_bitstream" style="display:none">
                    <%  
                    	if (true)
                		{
	                    	int resourceRelevance = 1 << Constants.BITSTREAM;
	                    	for( int i = 0; i < Constants.actionText.length; i++ ) 
	                    	{ 
	                    		if( (Constants.actionTypeRelevance[i] & resourceRelevance) > 0)
	                    		{
	                    	%>
	                        <option value="<%= i %>">
	                        	<%= UIUtil.getAuthorizeActionLocalizeMessage(pageContext,
	                        		Constants.actionText[i]) %>
	                        </option>
	                    	<% 	}
	                    		
	                    	} 
	            		}
	                %>
                	</select>
                </li>
                </ul>
                <div style="text-align:center;margin:10px;">
                	<input type="submit" name="submit_advanced_add" value="<fmt:message key="jsp.tools.general.add"/>" />
                </div>	
            </td>
        </tr>
        <tr class="oddRowEvenCol">
        	<td class="oddRowOddCol" headers="t4">
        		<strong><fmt:message key="jsp.dspace-admin.authorize-advanced.clear-heading"/></strong>
        	</td>
        	<td class="evenRowEvenCol">
        		<fmt:message key="jsp.dspace-admin.authorize-advanced.warning"/>
        		<br /><fmt:message key="jsp.dspace-admin.authorize-advanced.warning2"/>
        		<div style="text-align:center;margin:10px;">
        		<input type="submit" name="submit_advanced_clear" value="<fmt:message key="jsp.dspace-admin.authorize-advanced.clear"/>" onclick="javascript:return comfirnClear();" /> 
        			</div>
        	</td>
        </tr>
              
    </table>
    
    <%--
    <center>
        <table width="70%">
            <tr>
                <td align="left">
                    <input type="submit" name="submit_advanced_add" value="<fmt:message key="jsp.dspace-admin.authorize-advanced.add"/>" />
                </td>
                <td align="right">
                    <input type="submit" name="submit_advanced_clear" value="<fmt:message key="jsp.dspace-admin.authorize-advanced.clear"/>" /> <br /><fmt:message key="jsp.dspace-admin.authorize-advanced.warning"/>
                </td>
            </tr>
        </table>
    </center>
    --%>
    <center>
        <table width="70%" align="center">
            <tr>
                <td align="center">
                    <input type="button" value="<fmt:message key="jsp.tools.general.return"/>" onclick="location.href='<%= request.getContextPath() %>/dspace-admin/authorize'" />
                </td>
            </tr>
        </table>
    </center>

    </form>
</dspace:layout>

