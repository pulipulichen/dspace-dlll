<%--
  - complete.jsp
  -
  - Version: $Revision: 2218 $
  -
  - Date: $Date: 2007-09-28 06:17:04 -0700 (Fri, 28 Sep 2007) $
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
  - Submission complete message
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.content.InProgressSubmission" %>
<%@ page import="org.dspace.content.Collection"%>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.workflow.WorkflowItem" %>
<%@ page import="org.dspace.content.DCValue" %>
<%@ page import="java.lang.Exception" %>
<%@ page import="org.dspace.storage.rdbms.SQLQuery" %>
<%@ page import="java.sql.*" %>
	
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    request.setAttribute("LanguageSwitch", "hide");

    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);

	//get submission information object
    SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);
    
    String handle = "";
    String title = "";
    String errorlog = "";
   
	    if (subInfo != null && subInfo.getSubmissionItem() != null)
	    {
	    	
	    	Item item = subInfo.getSubmissionItem().getItem();
	    	
	    	if (item != null)
	    	{
	    		title = item.getID() + "";
	    		String sql = "SELECT handle.handle FROM item, handle WHERE item.item_id = handle.resource_id AND handle.resource_type_id = 2 AND item.item_id = "+title+" LIMIT 1";
	    		SQLQuery sq = new SQLQuery(new Context());
	    		ResultSet rs = sq.query(sql);
	    		if (rs.next())
	    			handle = rs.getString("handle");
	    		
	    		//String sql2 = "SELECT metadata FROM item, handle WHERE item.item_id = handle.resource_id AND handle.resource_type_id = 2 AND item.item_id = "+title+" LIMIT 1";
	    		/*
	    		DCValue[] titles = item.getDC("title", null, Item.ANY);
	    		
	    		if (titles.length > 0)
	    			title = titles[0];
	    		
	    		else
	    			title = "遞交完成的資料";
	    		*/
	    		/*
	    		handle = item.getHandle();
	    		*/
	    	}
	    }

	//get collection
    Collection collection = subInfo.getSubmissionItem().getCollection();
	
	//Item item = subInfo.getSubmissionConfig();
%>

<dspace:layout locbar="off" navbar="off" titlekey="jsp.submit.complete.title">

    <jsp:include page="/submit/progressbar.jsp"/>

    <%-- <h1>Submit: Submission Complete!</h1> --%>
	<h1><fmt:message key="jsp.submit.complete.heading"/></h1>
    <!-- <%= title %> -->
    <%-- FIXME    Probably should say something specific to workflow --%>
    <%-- <p>Your submission will now go through the workflow process designated for 
    the collection to which you are submitting.    You will receive e-mail
    notification as soon as your submission has become a part of the collection,
    or if for some reason there is a problem with your submission. You can also
    check on the status of your submission by going to the My DSpace page.</p> --%>
	
	
	<%
	if (handle.equals("") == false)
	{
		%>
	<p>
		<a href="<%= request.getContextPath() %>/handle/<%= handle %>">
			<%-- 到剛遞交完成的資料 --%>
			<fmt:message key="jsp.submit.complete.back-to-item"/>
		</a>
	</p>
		<%
	}
	else
	{
		//<p>您的遞交建檔需要由管理員檢查認可之後才能讓一般使用者瀏覽，您亦可到課程建檔區檢視目前遞交建檔的狀態。</p>
		%>
		<p><fmt:message key="jsp.submit.complete.info"/></p> 
		<%
	}
	%>
	
		
	<p>
		<a href="<%= request.getContextPath() %>/handle/<%= collection.getHandle() %>">
			<fmt:message key="jsp.general.goto"/>
			<%-- 到 --%>
			<%= collection.getMetadata("name") %></a>
	</p>
	
    <p>
		<a href="<%= request.getContextPath() %>/mydspace"><fmt:message key="jsp.submit.complete.link"/></a>
	</p>
	
	<p>
		<a href="<%= request.getContextPath() %>">
			<%-- 到 首頁 --%>
			<fmt:message key="jsp.submit.complete.back-to-homepage"/>
		</a>
	</p>
	
	<%--
    <p>
		<a href="<%= request.getContextPath() %>/community-list"><fmt:message key="jsp.community-list.title"/></a>
	</p>
	--%>
     
    <form action="<%= request.getContextPath() %>/submit" method="POST" onkeydown="return disableEnterKey(event);" style="text-align:center;">
		<%-- <input type="button" value="查看該筆資料" onclick="location.href='<%= request.getContextPath() + "/handle/" + handle %>'" /> --%>
        <input type="hidden" name="collection" value="<%= collection.getID() %>">
	    <%-- <input type="submit" name="submit" value="再遞交一筆資料"> --%>
	    <input type="submit" name="submit" value="<fmt:message key="jsp.submit.complete.submit-again"/>">
		<input id="submission_complete" type="hidden" />
		<%-- <input type="button" value="建立其他資料" onclick="location.href='<%= request.getContextPath() %>/submit'" /> --%>
		<input type="button" value="<fmt:message key="jsp.submit.complete.submit-select"/>" onclick="location.href='<%= request.getContextPath() %>/submit'" />
    </form>
	
<script type="text/javascript">
</script>

</dspace:layout>
