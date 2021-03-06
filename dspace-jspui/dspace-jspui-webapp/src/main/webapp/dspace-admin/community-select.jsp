<%--
  - community_select.jsp
  -
  - $Id: community-select.jsp 2218 2007-09-28 13:17:04Z jrutherford $
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
  - Display list of communities, with continue and cancel buttons
  -  post method invoked with community_select or community_select_cancel
  -     (community_id contains ID of selected community)
  -
  - Attributes:
  -   communities - a Community [] containing all communities in the system
  - Returns:
  -   submit set to community_select, user has selected a community
  -   submit set to community_select_cancel, return user to main page
  -   community_id - set if user has selected one

  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.content.Community" %>

<%
    Community [] communities =
        (Community[]) request.getAttribute("communities");
        
    request.setAttribute("LanguageSwitch", "hide");
%>

<dspace:layout titlekey="jsp.dspace-admin.community-select.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.dspace-admin.authorize-main.title"
               parentlink="/dspace-admin/authorize">

    <%-- <h1>communities:</h1> --%>
    <h1><fmt:message key="jsp.dspace-admin.community-select.com"/></h1>
	
	<script type="text/javascript">
	function checkSelect(thisForm)
	{
		if (thisForm.community_id.value == "")
		{
			//window.alert("請在上面列表中選擇要編輯權限的社群");
			window.alert("<fmt:message key="jsp.dspace-admin.community-select.notice-select"/>");
			
			thisForm.community_id.focus();
			return false;
		}
		return true;
	}
	</script>
	
    <form method="post" action="?" onsubmit="return checkSelect(this)">
	<input type="hidden" name="authorize_admin" value="true" />
    <table class="miscTable" align="center" summary="Community selection table">
        <tr>
            <td>
                    <select size="12" name="community_id">
                        <%  for (int i = 0; i < communities.length; i++) { %>
                            <option value="<%= communities[i].getID()%>">
                                <%//= communities[i].getMetadata("name")%>
                                <%
                                	String name = communities[i].getMetadata("name");
                            		if (name.equals(""))
                            		name = LocaleSupport.getLocalizedMessage(pageContext, 
            							"org.dspace.content.Community.untitled");
            						out.print(name + " (" + communities[i].getID() + ")");
                                %>
                            </option>
                        <%  } %>
                    </select>
            </td>
        </tr>
    </table>

    <center>
        <table width="70%">
            <tr>
                <td align="left">
                    <%-- <input type="submit" name="submit_community_select" value="Edit Policies"> --%>
                    <input type="submit" name="submit_community_select" value="<fmt:message key="jsp.dspace-admin.general.editpolicy"/>" />
                </td>
                <td align="right">
                    <%-- <input type="submit" name="submit_community_select_cancel" value="Cancel"> --%>
                    <%-- <input type="submit" name="submit_community_select_cancel" value="<fmt:message key="jsp.dspace-admin.general.return"/>" /> --%>
        			<input type="button" name="submit_community_select_cancel" value="<fmt:message key="jsp.dspace-admin.general.return"/>" 
        				onclick="location.href='<%= request.getContextPath() %>/dspace-admin/authorize'" />
                </td>
            </tr>
        </table>
    </center>        

    </form>
</dspace:layout>
