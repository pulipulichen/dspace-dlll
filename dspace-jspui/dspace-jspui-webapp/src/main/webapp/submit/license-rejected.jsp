<%--
  - license-rejected.jsp
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
  - License rejected page
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.dspace.content.Collection"%>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.handle.HandleManager" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
	
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<% 
	request.setAttribute("LanguageSwitch", "hide"); 
	Collection collection = (Collection) request.getAttribute("collection"); 
%>

<dspace:layout titlekey="jsp.submit.license-rejected.title" locbar="off" navbar="off">

    <%-- <h1>Submit: License Rejected</h1> --%>
	<h1><fmt:message key="jsp.submit.license-rejected.heading"/></h1>
    
    <%-- <p>You have chosen not to grant the license to distribute your submission
    via the DSpace system.  Your submission has not been deleted and can be
    accessed from the My DSpace page.</p> --%>
	<p><fmt:message key="jsp.submit.license-rejected.info1"/></p>
    
    <%-- <p>If you wish to contact us to discuss the license, please use one
    of the methods below:</p> --%>
	<p><fmt:message key="jsp.submit.license-rejected.info2"/></p>

    <dspace:include page="/components/contact-info.jsp" />

    <%
	if (collection != null)
	{
		Context c = UIUtil.obtainContext(request);
		String name = collection.getName();
		String handle = collection.getHandle();
		String url = HandleManager.resolveToURL(c, handle);
		%>
	<p><a href="<%= url %>"><fmt:message key="jsp.general.goto"/> <%= name %></a></p>
		<%
	}
	
	%>
    
    <%-- <p><a href="<%= request.getContextPath() %>/mydspace">Go to My DSpace</a></p> --%>
	<p><a href="<%= request.getContextPath() %>/mydspace"><fmt:message key="jsp.mydspace.general.goto-mydspace"/></a></p>

</dspace:layout>
