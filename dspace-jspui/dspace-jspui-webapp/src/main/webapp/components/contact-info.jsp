<%--
  - contact-info.jsp
  -
  - Version: $Revision: 1597 $
  -
  - Date: $Date: 2006-09-07 03:04:59 -0500 (Thu, 07 Sep 2006) $
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
  - Contact information for the DSpace site.
  --%>
  
  <%@ page contentType="text/html;charset=UTF-8" %>
  
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page import="org.dspace.core.ConfigurationManager" %>
<center>
  <p><a href="<%= request.getContextPath() %>/feedback"><fmt:message key="jsp.components.contact-info.details">
    <fmt:param><%= ConfigurationManager.getProperty("dspace.name") %></fmt:param>
  </fmt:message></a></p>
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