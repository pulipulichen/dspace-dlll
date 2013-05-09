<%--
  - already-registered.jsp
  -
  - Version: $Revision: 1303 $
  -
  - Date: $Date: 2005-08-25 12:20:29 -0500 (Thu, 25 Aug 2005) $
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
  - Message informing user who's tried to register that they're registered
  - already
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>
	
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<dspace:layout titlekey="jsp.register.already-registered.title">
    
<%-- <h1>Already Registered</h1> --%>
<h1><fmt:message key="jsp.register.already-registered.title"/></h1>

    <%-- <p>Our records show that you've already registered with DSpace and have
    an active account with us.</p> --%>
	<p><fmt:message key="jsp.register.already-registered.info1"/></p>

    <%-- <p><strong>You can <a href="<%= request.getContextPath() %>/forgot"> set
    a new password if you've forgotten it</a>.</p> --%>
	<p><fmt:message key="jsp.register.already-registered.info2">
        <fmt:param><%= request.getContextPath() %>/forgot</fmt:param>
    </fmt:message></p>

    <%-- <p>If you're having trouble logging in, please contact us.</p> --%>
	<p><fmt:message key="jsp.register.already-registered.info4"/></p>
    
    <dspace:include page="/components/contact-info.jsp" />

</dspace:layout>