<%--
  - form.jsp
  -
  - Version: $Revision: 1604 $
  -
  - Date: $Date: 2006-09-11 12:41:14 -0500 (Mon, 11 Sep 2006) $
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
  - Feedback form JSP
  -
  - Attributes:
  -    feedback.problem  - if present, report that all fields weren't filled out
  -    authenticated.email - email of authenticated user, if any
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    boolean problem = (request.getParameter("feedback.problem") != null);
    String email = request.getParameter("email");

    if (email == null || email.equals(""))
    {
        email = (String) request.getAttribute("authenticated.email");
    }

    if (email == null)
    {
        email = "";
    }

	
    String internal = request.getParameter("internal");
    
    String feedback = request.getParameter("feedback");
    if (feedback == null)
    {
    	if (internal == null) {
        java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); 
        java.util.Date currentTime = new java.util.Date();//得到当前系统时间 
        String str_date1 = formatter.format(currentTime); //将日期时间格式化 

        String referer = request.getHeader("REFERER");
        if (referer == null) {
          referer = "";
        }

        feedback = "姓名：\n組別：\n\n網址："+referer+"\n發生時間："+str_date1+"\n\n問題類型：\n※ 請選擇以下編號\n1. 網頁顯示不完整：之前修改了設定檔\n2. 網頁顯示不完整：新增遞交作業時發生錯誤\n3. 網頁顯示不完整：其他原因\n4. 網站無法連線\n5. 上傳文件但是卻沒有轉檔成功（請先到 管理工具/多媒體轉檔 中嘗試手動轉檔）\n6. 其他問題\n\n問題敘述：\n※ 請仔細敘述您的問題，以便讓我們能夠掌握問題、快速解決。\n";
    }
        	
        else
        {
        	feedback = LocaleSupport.getLocalizedMessage(pageContext, "jsp.error.internal.title")
        		+ "\n\n======================================\n\n" + internal;;
        }
    }

    String fromPage = request.getParameter("fromPage");
    if (fromPage == null)
    {
		fromPage = "";
    }
    
    boolean invalid_email = (request.getAttribute("feedback.invalid.email") != null);
    boolean invalid_feedback = (request.getAttribute("feedback.invalid.feedback") != null);
%>

<dspace:layout titlekey="jsp.feedback.form.title">
    <%-- <h1>Feedback Form</h1> --%>
    <h1><fmt:message key="jsp.feedback.form.title"/></h1>

    <%-- <p>Thanks for taking the time to share your feedback about the
    DSpace system. Your comments are appreciated!</p> --%>
    <p><fmt:message key="jsp.feedback.form.text1"/></p>

<%
    if (problem)
    {
%>
        <%-- <p><strong>Please fill out all of the information below.</strong></p> --%>
        <p><strong><fmt:message key="jsp.feedback.form.text2"/></strong></p>
<%
    }
%>
    <form action="<%= request.getContextPath() %>/feedback" method="post">
        <center>
            <table>
    			
    					<%
    					if (invalid_email)
						{
							%>
				<tr>
					<td colspan="2" align="center">
							<span class="submitFormWarn"><fmt:message key="jsp.feedback.form.email.invalid"/></span>
					</td>
				</tr>
							<%
						}
    					%>
                <tr>
                    <td class="submitFormLabel"><label for="temail"><fmt:message key="jsp.feedback.form.email"/></label></td>
                    <td>
    					<input type="text" name="email" id="temail" size="50" value="<%=StringEscapeUtils.escapeHtml(email)%>" />
    				</td>
                </tr>
    					<%
    					if (invalid_feedback)
						{
							%>
				<tr>
					<td colspan="2" align="center">
							<span class="submitFormWarn"><fmt:message key="jsp.feedback.form.feedback.invalid"/></span>
					</td>
				</tr>
							<%
						}
    					%>
                <tr>
                    <td class="submitFormLabel"><label for="tfeedback"><fmt:message key="jsp.feedback.form.comment"/></label></td>
                    <td>
    					<textarea name="feedback" id="tfeedback" rows="30" cols="50"><%=StringEscapeUtils.escapeHtml(feedback)%></textarea>
    				</td>
                </tr>
                <tr>
                    <td colspan="2" align="center">
                    <input type="submit" name="submit" value="<fmt:message key="jsp.feedback.form.send"/>" />
                    </td>
                </tr>
            </table>
        </center>
    </form>

</dspace:layout>
