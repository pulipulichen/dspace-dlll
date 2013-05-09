<%--
  - group_edit.jsp
  -
  - $Id: group-edit.jsp 2218 2007-09-28 13:17:04Z jrutherford $
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
  - Show contents of a group (name, epeople)
  -
  - Attributes:
  -   group - group to be edited
  -
  - Returns:
  -   cancel - if user wants to cancel
  -   add_eperson - go to group_eperson_select.jsp to choose eperson
  -   change_name - alter name & redisplay
  -   eperson_remove - remove eperson & redisplay
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.eperson.Group"   %>
<%@ page import="org.dspace.core.Context"   %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%
    Group group = (Group) request.getAttribute("group");
    EPerson [] epeople = (EPerson []) request.getAttribute("members");
    
	Group   [] groups  = (Group   []) request.getAttribute("membergroups");
	request.setAttribute("LanguageSwitch", "hide");
	
	String community_id = request.getParameter("community_id");
	String collection_id = request.getParameter("collection_id");
	
	String parenttitlekey = "jsp.tools.group-list.title";
	String parentlink = "/tools/group-edit";
	if (community_id != null && collection_id != null)
	{
		parenttitlekey = "jsp.tools.edit-collection.title";
		parentlink = "/tools/edit-communities?collection_id="+collection_id+"&community_id="+community_id;
	}
	
	Context context = UIUtil.obtainContext(request);
%>

<dspace:layout titlekey="jsp.tools.group-edit.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="<%= parenttitlekey %>"
               parentlink="<%= parentlink %>"
               nocache="true">

  <table width="95%">
    <tr>
      <td align="left">
	<h1><fmt:message key="jsp.tools.group-edit.title"/> : <% //=group.getName() %> 
	  		<%= UIUtil.getGroupLocalizeName(context, pageContext, group) %>
	  	<fmt:message key="jsp.tools.group-edit.title-id">
	        <fmt:param><%= group.getID() %></fmt:param>
	    </fmt:message></h1>
      </td>
      <td align="right" class="standard">
	<dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.collection-admin\") +\"#groupeditor\"%>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

  <center>
    <form name="epersongroup" method="post" action="">
		<p>
	  		<label for="tgroup_name"><fmt:message key="jsp.tools.group-edit.name"/></label>
	  		<%= UIUtil.isSpecialGroup(context, group)  %>
	  		<%
	  			if (UIUtil.isSpecialGroup(context, group) == false)
				{
					%>
	  		<input name="group_name" id="tgroup_name" value="<%=group.getName()%>"/>
					<%
				}
				else
				{
					%>
			<input type="hidden" name="group_name" id="tgroup_name" value="<%=group.getName()%>" <%-- disabled="disabled" --%> />
			<%= UIUtil.getGroupLocalizeName(context, pageContext, group) %>
			<fmt:message key="jsp.tools.group-edit.deny-modify"/>
					<%
				}
	  		%>

	  	</p>
   	    <h3><fmt:message key="jsp.tools.group-edit.heading"/></h3>

        <input type="hidden" name="group_id" value="<%=group.getID()%>" />
        <table class="group-edit">
          <tr>
            <td align="center" class="select-list"><strong><fmt:message key="jsp.tools.group-edit.eperson"/></strong><br/>
              <dspace:selecteperson multiple="true" selected="<%= epeople %>"/> 
            </td>
            <td align="center" class="select-list"><strong><fmt:message key="jsp.tools.group-edit.group"/></strong><br/>
              <dspace:selectgroup multiple="true" selected="<%= groups  %>"/>
            </td>
		  </tr>
        </table>

        <br/>
        	
        <%
        if (community_id != null && collection_id != null)
        {
        	%>
        	<table width="70%">
        		<tr>
        			<td align="left">
        			<p><input type="submit" name="submit_group_update" value="<fmt:message key="jsp.tools.group-edit.update.button"/>" onclick="javascript:finishEPerson();finishGroups();"/></p>
        			</td>
        			<td align="right">
        			<p><input type="button" value="<fmt:message key="jsp.dspace-admin.general.return"/>" onclick="javascript:location.href='<%= request.getContextPath() %>/tools/edit-communities?collection_id=<%= collection_id %>&community_id=<%= community_id %>'"/></p>
        			</td>
        		</tr>
        	</table>
        	<input type="hidden" name="community_id" value="<%= community_id %>" />
        	<input type="hidden" name="collection_id" value="<%= collection_id %>" />
        	<%
        }
        else
        {
        	%>
        	<p><input type="submit" name="submit_group_update" value="<fmt:message key="jsp.tools.group-edit.update.button"/>" onclick="javascript:finishEPerson();finishGroups();"/></p>
        	<%
        }
        %>
        
   </form>
  </center>
</dspace:layout>
