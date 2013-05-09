<%--
  - header-home.jsp
  -
  - Version: $Revision: 2250 $
  -
  - Date: $Date: 2007-10-11 10:55:37 -0500 (Thu, 11 Oct 2007) $
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
  - HTML header for main home page
  --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.List"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="org.dspace.app.webui.util.JSPManager" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>

<%
    String title = (String) request.getAttribute("dspace.layout.title");
    String navbar = (String) request.getAttribute("dspace.layout.navbar");
    boolean locbar = ((Boolean) request.getAttribute("dspace.layout.locbar")).booleanValue();

    String siteName = ConfigurationManager.getProperty("dspace.name");
    String feedRef = (String)request.getAttribute("dspace.layout.feedref");
    List parts = (List)request.getAttribute("dspace.layout.linkparts");
    String extraHeadData = (String)request.getAttribute("dspace.layout.head");
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title><%= siteName %>: <%= title %></title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="Generator" content="DSpace" />
        <link rel="stylesheet" href="<%= request.getContextPath() %>/styles.css.jsp" type="text/css" />
        <link rel="stylesheet" href="<%= request.getContextPath() %>/print.css" media="print" type="text/css" />
        <link rel="shortcut icon" href="<%= request.getContextPath() %>/favicon.ico" type="image/x-icon"/>
<%
    if (!"NONE".equals(feedRef))
    {
        for (int i = 0; i < parts.size(); i+= 3)
        {
%>
        <link rel="alternate" type="application/<%= (String)parts.get(i) %>" title="<%= (String)parts.get(i+1) %>" href="<%= request.getContextPath() %>/feed/<%= (String)parts.get(i+2) %>/<%= feedRef %>"/>
<%
        }
    }

    if (extraHeadData != null)
	{ %>
<%= extraHeadData %>
<%
	}
%>
       
    <script type="text/javascript" src="<%= request.getContextPath() %>/extension/jquery.js"></script>
    <script type="text/javascript" src="<%= request.getContextPath() %>/utils.js"></script>
    
    <script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-type-item/jquery-plugin-inputTypeItem-progressbar.js"></script>

	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/bitstream-display/jquery-ui/js/jquery-ui-1.7.1.custom.min.js"></script>
	<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/bitstream-display/jquery-ui/css/smoothness/jquery-ui-1.7.1.custom.css" type="text/css" />
	
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/fckeditor/fckeditor.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/fckeditor/fckeditor_display_toggle.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/ajaxfileupload/fileupload_config.jsp"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/ajaxfileupload/ajaxfileupload.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/ajaxfileupload/fileupload.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/ajaxfileupload/fileupload_xmlmetadata.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/xmlmetadata/xmlmetadata-lang.jsp"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/xmlmetadata/xmlmetadata-core.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/xmlmetadata/ui.datepicker.js"></script>
	<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/xmlmetadata/xmlmetadata-style.css" type="text/css" media="screen">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/xmlmetadata/flora.datepicker.css" type="text/css" media="screen">
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/taiwan-address/jquery-plugin-taiwain-address.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-type-item/jquery-plugin-input-type-item.jsp"></script>

	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/bitstream-display/jquery-ui/js/jquery-ui-1.7.1.custom.min.js"></script>
	<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/bitstream-display/jquery-ui/css/smoothness/jquery-ui-1.7.1.custom.css" type="text/css" />
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-type-item/jquery-plugin-inputTypeItem-edit-item-form.js"></script>
	
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/progress-bar/jcarousellite.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/progress-bar/jquery.easing.js"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/progress-bar/progress-bar.js"></script>
		
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/fckeditor/FCKeditor-dialog.jsp"></script>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/bitstream-display/bitstream-display-js.jsp"></script>
    
    <script src="<%= request.getContextPath() %>/extension/fckeditor/jquery-fckeditor-plugin/jquery.FCKEditor.js" type="text/javascript" language="javascript"></script>
    
    <script type="text/javascript" src="<%= request.getContextPath() %>/extension/utils.jsp"></script>
    
    </head>

    <%-- HACK: leftmargin, topmargin: for non-CSS compliant Microsoft IE browser --%>
    <%-- HACK: marginwidth, marginheight: for non-CSS compliant Netscape browser --%>
    <body>

        <%-- DSpace top-of-page banner --%>
        <%-- HACK: width, border, cellspacing, cellpadding: for non-CSS compliant Netscape, Mozilla browsers --%>
        <table class="pageBanner" width="98%" border="0" cellpadding="0" cellspacing="0" align="center" style="width: 98%;">

            <%-- DSpace logo --%>
            <tr>
                <td width="90%">
                    <a href="<%= request.getContextPath() %>/report" style="float:right;padding: 5px;margin:5px;"><fmt:message key="jsp.dspace-admin.email-edit.emails.report"/></a>
                    <a href="<%= request.getContextPath() %>/"><img src="<%= request.getContextPath() %>/image/dspace-blue.gif" alt="<fmt:message key="jsp.layout.header-default.alt"/>" border="0"/></a>
                </td>
                <td class="tagLine" <%--width="99%"--%>> <%-- Make as wide as possible. cellpadding repeated for broken NS 4.x --%>
                    <%-- <a class="tagLineText" target="_blank" href="http://www.dspace.org/"><fmt:message key="jsp.layout.header-default.about"/></a> --%>
                </td>
                <td nowrap="nowrap" valign="middle">
                </td>
            </tr>
            <tr class="stripe"> <%-- Blue stripe --%>
                <td colspan="3">&nbsp;</td>
            </tr>
        </table>

        <%-- Localization --%>
<%--  <c:if test="${param.locale != null}">--%>
<%--   <fmt:setLocale value="${param.locale}" scope="session" /> --%>
<%-- </c:if> --%>
<%--        <fmt:setBundle basename="Messages" scope="session"/> --%>

        <%-- Page contents --%>

        <%-- HACK: width, border, cellspacing, cellpadding: for non-CSS compliant Netscape, Mozilla browsers --%>
        <table class="centralPane" width="98%" border="0" cellpadding="3" cellspacing="1" align="center">

            <%-- HACK: valign: for non-CSS compliant Netscape browser --%>
            <tr valign="top">

            <%-- Navigation bar --%>
<%
    if (!navbar.equals("off"))
    {
%>
            <td class="navigationBar">
                <dspace:include page="<%= navbar %>" />
            </td>
<%
    }
%>
            <%-- Page Content --%>

            <%-- HACK: width specified here for non-CSS compliant Netscape 4.x --%>
            <%-- HACK: Width shouldn't really be 100%, but omitting this means --%>
            <%--       navigation bar gets far too wide on certain pages --%>
            <td class="pageContents" width="100%">

                <%-- Location bar --%>
<%
    if (locbar)
    {
%>
                <dspace:include page="/layout/location-bar.jsp" />
<%
    }
%>
