<%--
  - internal.jsp
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
  - Page representing an internal server error
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>
	
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.StringWriter" %>
	
<%@ page import="org.dspace.core.ConfigurationManager" %>

<%@ page isErrorPage="true" %>

    <%-- <h1>Internal System Error</h1> --%>
    <h1><fmt:message key="jsp.error.internal.title"/></h1>
    <%-- <p>Oops!  The system has experienced an internal error.  This is our fault,
    please pardon our dust during these early stages of the DSpace system!</p> --%>
    <p><fmt:message key="jsp.error.internal.text1"/></p>
    <%-- <p>The system has logged this error.  Please try to do what you were doing
    again, and if the problem persists, please contact us so we can fix the
    problem.</p> --%>

<center>
  <form action="<%= request.getContextPath() %>/feedback" method="post" id="feedback_form">
  <p><a href="javascript:document.getElementById('feedback_form').submit();" ><fmt:message key="jsp.components.contact-info.details">
    <fmt:param><%= ConfigurationManager.getProperty("dspace.name") %></fmt:param>
  </fmt:message></a></p>
  <textarea name="internal" id="tinternal" style="display:none;"></textarea>
    <script type="text/javascript">
    document.getElementById("tinternal").value = "Some exception cause DSpace performance broken. Please check JSPTags.\n\nException URL:" + location.href;
    </script>
  </form>
</center>

<%--
  - 20110604 by Pudding Chen
  - Link to log report
  --%>
<center>
  <p>
    <%-- 如果您是管理者， --%>
    <fmt:message key="jsp.components.contact-info.details-log.1" />
    <a href="<%= request.getContextPath() %>/dspace-admin/log-reader">
    	<%-- 請查閱記錄檔以取得完整的錯誤訊息。 --%>
    	<fmt:message key="jsp.components.contact-info.details-log.2" />
    </a></p>
</center>

	<p align="center">
        <%-- <a href="<%= request.getContextPath() %>/">Go to the DSpace home page</a> --%>
        <a href="<%= request.getContextPath() %>/"><fmt:message key="jsp.general.gohome"/></a>
    </p>
