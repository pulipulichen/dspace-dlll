<%--
  - navbar-admin.jsp
  -
  - Version: $Revision: 2508 $
  -
  - Date: $Date: 2008-01-10 08:03:36 -0600 (Thu, 10 Jan 2008) $
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
  - Navigation bar for admin pages
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.LinkedList" %>
<%@ page import="java.util.List" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="org.dspace.sort.SortOption" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.eperson.EPerson" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    // Get the current page, minus query string
    String currentPage = UIUtil.getOriginalURL(request);    
    int c = currentPage.indexOf( '?' );
    if( c > -1 )
    {
        currentPage = currentPage.substring(0, c);
    }
%>

<%-- HACK: width, border, cellspacing, cellpadding: for non-CSS compliant Netscape, Mozilla browsers --%>

<%
	// Is anyone logged in?
	Context context = UIUtil.obtainContext(request);
    EPerson user = context.getCurrentUser();
	
	// E-mail may have to be truncated
    String navbarEmail = null;

    if (user != null)
    {
        navbarEmail = user.getEmail();
        if (navbarEmail.length() > 18)
        {
            navbarEmail = navbarEmail.substring(0, 17) + "...";
        }
    }
    
    if (user != null)
    {
%>
  <p class="loggedIn"><fmt:message key="jsp.layout.navbar-default.loggedin">
      <fmt:param><%= navbarEmail %></fmt:param>
  </fmt:message>
    (<a href="<%= request.getContextPath() %>/logout"><fmt:message key="jsp.layout.navbar-default.logout"/></a>)</p>
<%
    }
%>

<table width="100%" border="0" cellspacing="2" cellpadding="2">
  <tr>
    <td nowrap="nowrap" colspan="2" class="navigationBarSublabel"><fmt:message key="jsp.dspace-admin.index.heading"/></td>
  </tr>

  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/tools/edit-communities") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/tools/edit-communities"><fmt:message key="jsp.layout.navbar-admin.communities-collections"/></a>
    </td>
  </tr>
  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/edit-epeople") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/edit-epeople"><fmt:message key="jsp.layout.navbar-admin.epeople"/></a>
    </td>
  </tr>

  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/tools/group-edit") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/tools/group-edit"><fmt:message key="jsp.layout.navbar-admin.groups"/></a>
    </td>
  </tr>
  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/tools/edit-item") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/tools/edit-item"><fmt:message key="jsp.layout.navbar-admin.items"/></a>
    </td>
  </tr>
  
  	  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/filter-media") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/filter-media">
      	<fmt:message key="jsp.layout.navbar-admin.filter-media"/>
      	<%-- 多媒體轉檔 --%>
     </a>
    </td>
  </tr>
  	  
  	  
  	<%
  		BrowseInfo binfo = (BrowseInfo) request.getAttribute("browse.info");
  	%>
	<tr class="navigationBarItem">
   		<td>
     			<img alt="" src="<%= request.getContextPath() %>/image/<%= ( binfo != null ? "arrow-highlight" : "arrow" ) %>.gif" width="16" height="16"/>
   		</td>
   		<td nowrap="nowrap" class="navigationBarItem">
     			<a href="<%= request.getContextPath() %>/dspace-admin/withdrawn"><fmt:message key="jsp.layout.navbar-admin.withdrawn"/></a>
   		</td>
	</tr>
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/metadata-schema-registry") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/metadata-schema-registry"><fmt:message key="jsp.layout.navbar-admin.metadataregistry"/></a>
    </td>
  </tr>
  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/format-registry") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/format-registry"><fmt:message key="jsp.layout.navbar-admin.formatregistry"/></a>
    </td>
  </tr>
  
   <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/workflow") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/workflow"><fmt:message key="jsp.layout.navbar-admin.workflow"/></a>
    </td>
  </tr>
  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/authorize") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/authorize"><fmt:message key="jsp.layout.navbar-admin.authorization"/></a>
    </td>
  </tr>
  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/news-edit") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/news-edit"><fmt:message key="jsp.layout.navbar-admin.editnews"/></a>
    </td>
  </tr>

  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/license-edit") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/license-edit"><fmt:message key="jsp.layout.navbar-admin.editlicense"/></a>
    </td>
  </tr>

  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/supervise") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/supervise"><fmt:message key="jsp.layout.navbar-admin.supervisors"/></a>
    </td>
  </tr>
  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/statistics") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/statistics"><fmt:message key="jsp.layout.navbar-admin.statistics"/></a>
    </td>
  </tr>
  	  
  <tr>
     <td colspan="2">&nbsp;</td>
  </tr>
  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/config-edit") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/config-edit"><fmt:message key="jsp.layout.navbar-admin.config-edit"/></a>
    </td>
  </tr> 
  	  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/email-edit") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/email-edit"><fmt:message key="jsp.layout.navbar-admin.email-edit"/></a>
    </td>
  </tr> 
  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/messages-edit") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/messages-edit"><fmt:message key="jsp.layout.navbar-admin.edit-messages"/></a>
    </td>
  </tr>
  	  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/input-forms-edit") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/input-forms-edit"><fmt:message key="jsp.layout.navbar-admin.edit-input-forms"/></a>
    </td>
  </tr>
  	  
  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/log-reader") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/log-reader">
      	<%-- 記錄檔查閱 --%>
      	<fmt:message key="jsp.layout.navbar-admin.log-reader"/>
      </a>
    </td>
  </tr>

  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/tomcat-restart") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/tomcat-restart"><fmt:message key="jsp.layout.navbar-admin.tomcat-restart"/></a>
    </td>
  </tr>  

  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/phppgadmin") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/phppgadmin"><fmt:message key="jsp.layout.navbar-admin.phppgadmin"/></a>
    </td>
  </tr>  

  <tr class="navigationBarItem">
    <td>
      <img alt="" src="<%= request.getContextPath() %>/image/<%= (currentPage.endsWith("/dspace-admin/vnc-server") ? "arrow-highlight" : "arrow") %>.gif" width="16" height="16"/>
    </td>
    <td nowrap="nowrap" class="navigationBarItem">
      <a href="<%= request.getContextPath() %>/dspace-admin/vnc-server"><fmt:message key="jsp.layout.navbar-admin.vnc-server"/></a>
    </td>
  </tr>  
  
  <tr>
     <td colspan="2">&nbsp;</td>
  </tr>

<%
	// get the browse indices
	//BrowseInfo binfo = (BrowseInfo) request.getAttribute("browse.info");
	/*
%>
	<tr class="navigationBarItem">
   		<td>
     			<img alt="" src="<%= request.getContextPath() %>/image/<%= ( binfo != null ? "arrow-highlight" : "arrow" ) %>.gif" width="16" height="16"/>
   		</td>
   		<td nowrap="nowrap" class="navigationBarItem">
     			<a href="<%= request.getContextPath() %>/dspace-admin/withdrawn"><fmt:message key="jsp.layout.navbar-admin.withdrawn"/></a>
   		</td>
	</tr>

  <tr>
     <td colspan="2">&nbsp;</td>
  </tr>
<%
	*/
%>

  
  <tr class="navigationBarItem">
     <td>
         <img alt="" src="<%= request.getContextPath() %>/image/arrow.gif" width="16" height="16"/>
     </td>
     <td nowrap="nowrap" class="navigationBarItem">
         <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\")%>"><fmt:message key="jsp.layout.navbar-admin.help"/></dspace:popup>
     </td>
 </tr>

 <tr class="navigationBarItem">
     <td>
         <img alt="" src="<%= request.getContextPath() %>/image/arrow.gif" width="16" height="16"/>
     </td>
     <td nowrap="nowrap" class="navigationBarItem">
         <a href="<%= request.getContextPath() %>/logout"><fmt:message key="jsp.layout.navbar-admin.logout"/></a>
     </td>
 </tr>
</table>
