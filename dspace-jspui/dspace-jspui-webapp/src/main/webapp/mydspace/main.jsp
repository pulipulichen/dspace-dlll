<%--
  - main.jsp
  -
  - Version: $Revision: 2968 $
  -
  - Date: $Date: 2008-06-24 14:08:28 -0700 (Tue, 24 Jun 2008) $
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
  - Main My DSpace page
  -
  -
  - Attributes:
  -    mydspace.user:    current user (EPerson)
  -    workspace.items:  WorkspaceItem[] array for this user
  -    workflow.items:   WorkflowItem[] array of submissions from this user in
  -                      workflow system
  -    workflow.owned:   WorkflowItem[] array of tasks owned
  -    workflow.pooled   WorkflowItem[] array of pooled tasks
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page  import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.app.webui.servlet.MyDSpaceServlet" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.DCDate" %>
<%@ page import="org.dspace.content.DCValue" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.content.SupervisedItem" %>
<%@ page import="org.dspace.content.WorkspaceItem" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.eperson.Group"   %>
<%@ page import="org.dspace.workflow.WorkflowItem" %>
<%@ page import="org.dspace.workflow.WorkflowManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%!
public String formatDate(Date submitDate)
{
	if (submitDate == null)
		return "";
	else
		return (submitDate.getYear()+1900) 
    						+ "-" + (submitDate.getMonth()+1) 
    						+ "-" + submitDate.getDate() 
    						+ " " + submitDate.getHours()  
    						+ ":" + submitDate.getMinutes();
}
%>
<%
    EPerson user = (EPerson) request.getAttribute("mydspace.user");

    WorkspaceItem[] workspaceItems =
        (WorkspaceItem[]) request.getAttribute("workspace.items");

    WorkflowItem[] workflowItems =
        (WorkflowItem[]) request.getAttribute("workflow.items");

    WorkflowItem[] owned =
        (WorkflowItem[]) request.getAttribute("workflow.owned");

    WorkflowItem[] pooled =
        (WorkflowItem[]) request.getAttribute("workflow.pooled");
	
    Group [] groupMemberships =
        (Group []) request.getAttribute("group.memberships");

    SupervisedItem[] supervisedItems =
        (SupervisedItem[]) request.getAttribute("supervised.items");
    
    List<String> exportsAvailable = (List<String>)request.getAttribute("export.archives");
    
    // Is the logged in user an admin
    Boolean displayMembership = (Boolean)request.getAttribute("display.groupmemberships");
    boolean displayGroupMembership = (displayMembership == null ? false : displayMembership.booleanValue());
%>

<dspace:layout titlekey="jsp.mydspace" nocache="true">

<table width="100%" border="0">
        <tr>
            <td align="left">
                <h1>
                    <fmt:message key="jsp.mydspace"/>: <%= user.getFullName() %>
                </h1>
            </td>
            <td align="right" class="standard">
                 <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") + \"#mydspace\"%>"><fmt:message key="jsp.help"/></dspace:popup>
            </td>
        </tr>
    </table>

    <form action="<%= request.getContextPath() %>/mydspace" method="post">
        <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
        <center>
            <table border="0" width="70%">
                <tr>
        			<%
        			String mydspaceBack = (String) session.getAttribute("mydspaceBack");
    				
    				if (mydspaceBack != null)
        			{
        				long nowTime = (new Date()).getTime();
	    				if (mydspaceBack.indexOf("?") == -1)
	    					mydspaceBack = mydspaceBack + "?time=" + nowTime;
	    				else
	    					mydspaceBack = mydspaceBack + "&time=" + nowTime;
        				%>
        				<td align="left">
                        	<%-- <input type="button" name="goback" value="回到之前的頁面" onclick="location.href='<%= mydspaceBack %>'" /> --%>
                        	<input type="button" name="goback" value="<fmt:message key="jsp.mydspace.main.back-to"/>" onclick="location.href='<%= mydspaceBack %>'" />
                        </td>
                        <td align="center">
                        	<input type="submit" name="submit_new" value="<fmt:message key="jsp.mydspace.main.start.button"/>" />
                    	</td>
        				<%
        			}
        			else
        			{
        				%>
        			<td align="left">
                        <input type="submit" name="submit_new" value="<fmt:message key="jsp.mydspace.main.start.button"/>" />
                    </td>
        				<%
        			}
        			%>
                    <td align="right">
                        <input type="submit" name="submit_own" value="<fmt:message key="jsp.mydspace.main.view.button"/>" />
                    </td>
                </tr>
            </table>
        </center>
    </form>

<%-- Task list:  Only display if the user has any tasks --%>
<%
    if (owned.length > 0)
    {
%>
    <h2><fmt:message key="jsp.mydspace.main.heading2"/></h2>

    <p class="submitFormHelp">
        <%-- Below are the current tasks that you have chosen to do. --%>
        <fmt:message key="jsp.mydspace.main.text1"/>
    </p>

    <table class="miscTable" align="center" summary="Table listing owned tasks">
        <tr>
            <th id="t1" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.task"/></th>
            <th id="t2" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.item"/></th>
            <th id="t3" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.subto"/></th>
            <th id="t4" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.subby"/></th>
        	<th id="t20" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.subdate"/></th>
            <th id="t5" class="oddRowEvenCol">&nbsp;</th>
        </tr>
<%
        // even or odd row:  Starts even since header row is odd (1).  Toggled
        // between "odd" and "even" so alternate rows are light and dark, for
        // easier reading.
        String row = "even";

        for (int i = 0; i < owned.length; i++)
        {
            DCValue[] titleArray =
                owned[i].getItem().getDC("title", null, Item.ANY);
            String title = (titleArray.length > 0 ? titleArray[0].value
                                                  : LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled") );
            Date submitDate =
                owned[i].getItem().getLastModified();
            EPerson submitter = owned[i].getItem().getSubmitter();
%>
        <tr>
                <td headers="t1" class="<%= row %>RowOddCol">
<%
            switch (owned[i].getState())
            {

            //There was once some code...
            case WorkflowManager.WFSTATE_STEP1: %><fmt:message key="jsp.mydspace.main.sub1"/><% break;
            case WorkflowManager.WFSTATE_STEP2: %><fmt:message key="jsp.mydspace.main.sub2"/><% break;
            case WorkflowManager.WFSTATE_STEP3: %><fmt:message key="jsp.mydspace.main.sub3"/><% break;
            }
%>
                </td>
                <td headers="t2" class="<%= row %>RowEvenCol"><%= Utils.addEntities(title, false) %></td>
                <td headers="t3" class="<%= row %>RowOddCol">
    				<a href="<%= request.getContextPath() + "/handle/" + owned[i].getCollection().getHandle() %>"><%= owned[i].getCollection().getMetadata("name") %></a>
    			</td>
                <td headers="t4" class="<%= row %>RowEvenCol"><a href="mailto:<%= submitter.getEmail() %>"><%= submitter.getFullName() %></a></td>
                <!-- <td headers="t5" class="<%= row %>RowOddCol"></td> -->
                <td headers="t20" class="<%= row %>RowOddCol"><%= formatDate(submitDate)  %></td>
                <td headers="t5" class="<%= row %>RowEvenCol">
                     <form action="<%= request.getContextPath() %>/mydspace" method="post">
                        <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                        <input type="hidden" name="workflow_id" value="<%= owned[i].getID() %>" />  
                        <input type="submit" name="submit_perform" value="<fmt:message key="jsp.mydspace.main.perform.button"/>" />  
                        <input type="submit" name="submit_return" value="<fmt:message key="jsp.mydspace.main.return.button"/>" />
                     </form> 
                </td>
        </tr>
<%
            row = (row.equals("even") ? "odd" : "even" );
        }
%>
    </table>
<%
    }

    // Pooled tasks - only show if there are any
    if (pooled.length > 0)
    {
%>
    <h2><fmt:message key="jsp.mydspace.main.heading3"/></h2>

    <p class="submitFormHelp">
        <%--Below are tasks in the task pool that have been assigned to you. --%>
        <fmt:message key="jsp.mydspace.main.text2"/>
    </p>

    <table class="miscTable" align="center" summary="Table listing the tasks in the pool">
        <tr>
            <th id="t6" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.task"/></th>
            <th id="t7" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.item"/></th>
            <th id="t8" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.subto"/></th>
            <th id="t9" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.subby"/></th>
        	<th id="t21" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.subdate"/></th>
        </tr>
<%
        // even or odd row:  Starts even since header row is odd (1).  Toggled
        // between "odd" and "even" so alternate rows are light and dark, for
        // easier reading.
        String row = "even";

        for (int i = 0; i < pooled.length; i++)
        {
            DCValue[] titleArray =
                pooled[i].getItem().getDC("title", null, Item.ANY);
            String title = (titleArray.length > 0 ? titleArray[0].value
                    : LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled") );
            Date submitDate =
                pooled[i].getItem().getLastModified();
            EPerson submitter = pooled[i].getItem().getSubmitter();
%>
        <tr>
                    <td headers="t6" class="<%= row %>RowOddCol">
<%
            switch (pooled[i].getState())
            {
            case WorkflowManager.WFSTATE_STEP1POOL: %><fmt:message key="jsp.mydspace.main.sub1"/><% break;
            case WorkflowManager.WFSTATE_STEP2POOL: %><fmt:message key="jsp.mydspace.main.sub2"/><% break;
            case WorkflowManager.WFSTATE_STEP3POOL: %><fmt:message key="jsp.mydspace.main.sub3"/><% break;
            }
%>
                    </td>
                    <td headers="t7" class="<%= row %>RowEvenCol"><%= Utils.addEntities(title, false) %></td>
                    <td headers="t8" class="<%= row %>RowOddCol">
    					<a href="<%= request.getContextPath() + "/handle/" + pooled[i].getCollection().getHandle() %>"><%= pooled[i].getCollection().getMetadata("name") %></a>
    				</td>
                    <td headers="t9" class="<%= row %>RowEvenCol"><a href="mailto:<%= submitter.getEmail() %>"><%= submitter.getFullName() %></a></td>
    				<td headers="t21" class="<%= row %>RowOddCol"><%= formatDate(submitDate)  %></td>
                    <td class="<%= row %>RowOddCol">
                        <form action="<%= request.getContextPath() %>/mydspace" method="post">
                            <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                            <input type="hidden" name="workflow_id" value="<%= pooled[i].getID() %>" />
                            <input type="submit" name="submit_claim" value="<fmt:message key="jsp.mydspace.main.take.button"/>" />
                        </form> 
                    </td>
        </tr>
<%
            row = (row.equals("even") ? "odd" : "even");
        }
%>
    </table>
<%
    }
%>



    <%--<p align="center"><a href="<%= request.getContextPath() %>/subscribe"><fmt:message key="jsp.mydspace.main.link"/></a></p>--%>

<%
    // Display workspace items (authoring or supervised), if any
    if (workspaceItems.length > 0 || supervisedItems.length > 0)
    {
        // even or odd row:  Starts even since header row is odd (1)
        String row = "even";
%>

    <h2><fmt:message key="jsp.mydspace.main.heading4"/></h2>

    <p><fmt:message key="jsp.mydspace.main.text4" /></p>

    <table class="miscTable" align="center" summary="Table listing unfinished submissions">
        <tr>
            <th class="oddRowOddCol">&nbsp;</th>
            <th id="t10" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.subby"/></th>
            <th id="t11" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.title"/></th>
            <th id="t12" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.elem2"/></th>
        	<th id="t22" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.subdate"/></th>
            <th id="t13" class="oddRowEvenCol">&nbsp;</th>
        </tr>
<%
        if (supervisedItems.length > 0 && workspaceItems.length > 0)
        {
%>
        <tr>
            <th colspan="5">
                <%-- Authoring --%>
                <fmt:message key="jsp.mydspace.main.authoring" />
            </th>
        </tr>
<%
        }

        for (int i = 0; i < workspaceItems.length; i++)
        {
            DCValue[] titleArray =
                workspaceItems[i].getItem().getDC("title", null, Item.ANY);
            String title = (titleArray.length > 0 ? titleArray[0].value
                    : LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled") );
            Date submitDate =
                workspaceItems[i].getItem().getLastModified();
            EPerson submitter = workspaceItems[i].getItem().getSubmitter();
%>
        <tr>
            <td class="<%= row %>RowOddCol">
                <form action="<%= request.getContextPath() %>/workspace" method="post">
                    <input type="hidden" name="workspace_id" value="<%= workspaceItems[i].getID() %>"/>
                    <input type="submit" name="submit_open" value="<fmt:message key="jsp.mydspace.general.open" />"/>
                </form>
            </td>
            <td headers="t10" class="<%= row %>RowEvenCol">
                <a href="mailto:<%= submitter.getEmail() %>"><%= submitter.getFullName() %></a>
            </td>
            <td headers="t11" class="<%= row %>RowOddCol"><%= Utils.addEntities(title, false) %></td>
            <td headers="t12" class="<%= row %>RowEvenCol">
    			<a href="<%= request.getContextPath() + "/handle/" + workspaceItems[i].getCollection().getHandle() %>"><%= workspaceItems[i].getCollection().getMetadata("name") %></a>
    		</td>
    		<td headers="t22" class="<%= row %>RowOddCol"><%= formatDate(submitDate)  %></td>
            <td headers="t13" class="<%= row %>RowEvenCol">
                <form action="<%= request.getContextPath() %>/mydspace" method="post">
                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>"/>
                    <input type="hidden" name="workspace_id" value="<%= workspaceItems[i].getID() %>"/>
                    <input type="submit" name="submit_delete" value="<fmt:message key="jsp.mydspace.general.remove" />"/>
                </form> 
            </td>
        </tr>
<%
            row = (row.equals("even") ? "odd" : "even" );
        }
%>

<%-- Start of the Supervisors workspace list --%>
<%
        if (supervisedItems.length > 0)
        {
%>
        <tr>
            <th colspan="5">
                <fmt:message key="jsp.mydspace.main.supervising" />
            </th>
        </tr>
<%
        }

        for (int i = 0; i < supervisedItems.length; i++)
        {
            DCValue[] titleArray =
                supervisedItems[i].getItem().getDC("title", null, Item.ANY);
            String title = (titleArray.length > 0 ? titleArray[0].value
                    : LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled") );
            Date submitDate =
                supervisedItems[i].getItem().getLastModified();
            EPerson submitter = supervisedItems[i].getItem().getSubmitter();
%>

        <tr>
            <td class="<%= row %>RowOddCol">
                <form action="<%= request.getContextPath() %>/workspace" method="post">
                    <input type="hidden" name="workspace_id" value="<%= supervisedItems[i].getID() %>"/>
                    <input type="submit" name="submit_open" value="<fmt:message key="jsp.mydspace.general.open" />"/>
                </form>
            </td>
            <td class="<%= row %>RowEvenCol">
                <a href="mailto:<%= submitter.getEmail() %>"><%= submitter.getFullName() %></a>
            </td>
            <td class="<%= row %>RowOddCol"><%= Utils.addEntities(title, false) %></td>
            <td class="<%= row %>RowEvenCol">
            	<a href="<%= request.getContextPath() + "/handle/" + supervisedItems[i].getCollection().getHandle() %>"><%= supervisedItems[i].getCollection().getMetadata("name") %></a>
            </td>
            <td class="<%= row %>RowOddCol"><%= formatDate(submitDate)  %></td>
            <td class="<%= row %>RowEvenCol">
                <form action="<%= request.getContextPath() %>/mydspace" method="post">
                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>"/>
                    <input type="hidden" name="workspace_id" value="<%= supervisedItems[i].getID() %>"/>
                    <input type="submit" name="submit_delete" value="<fmt:message key="jsp.mydspace.general.remove" />"/>
                </form>  
            </td>
        </tr>
<%
            row = (row.equals("even") ? "odd" : "even" );
        }
%>
    </table>
<%
    }
%>

<%
    // Display workflow items, if any
    if (workflowItems.length > 0)
    {
        // even or odd row:  Starts even since header row is odd (1)
        String row = "even";
%>
    <h2><fmt:message key="jsp.mydspace.main.heading5"/></h2>

    <table class="miscTable" align="center" summary="Table listing submissions in workflow process">
        <tr>
            <th id="t14" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.title"/></th>
        	<th id="t23" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.subdate"/></th>
            <th id="t15" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.elem2"/></th>
        </tr>
<%
        for (int i = 0; i < workflowItems.length; i++)
        {
            DCValue[] titleArray =
                workflowItems[i].getItem().getDC("title", null, Item.ANY);
            String title = (titleArray.length > 0 ? titleArray[0].value
                    : LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled") );
            Date submitDate =
                workflowItems[i].getItem().getLastModified();
%>
            <tr>
                <td headers="t14" class="<%= row %>RowEvenCol"><%= Utils.addEntities(title, false) %></td>
    			<td headers="t23" class="<%= row %>RowOddCol"><%= formatDate(submitDate)  %></td>
                <td headers="t15" class="<%= row %>RowEvenCol">
                   <form action="<%= request.getContextPath() %>/mydspace" method="post">
                       <a href="<%= request.getContextPath() + "/handle/" + workflowItems[i].getCollection().getHandle() %>"><%= workflowItems[i].getCollection().getMetadata("name") %></a>
                       <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                       <input type="hidden" name="workflow_id" value="<%= workflowItems[i].getID() %>" />
                   </form>   
                </td>
            </tr>
<%
      row = (row.equals("even") ? "odd" : "even" );
    }
%>
    </table>
<%
  }

  if(displayGroupMembership && groupMemberships.length>0)
  {
%>
    <h2><fmt:message key="jsp.mydspace.main.heading6"/></h2>
    <ul>
<%
    for(int i=0; i<groupMemberships.length; i++)
    {
%>
    <li><%=groupMemberships[i].getName()%></li> 
<%    
    }
%>
	</ul>
<%
  }
%>

<%--	<%if(exportsAvailable!=null && exportsAvailable.size()>0){ %>
	<h2><fmt:message key="jsp.mydspace.main.heading7"/></h2>
	<ol class="exportArchives">
		<%for(String fileName:exportsAvailable){%>
			<li><a href="<%=request.getContextPath()+"/exportdownload/"+fileName%>" title="<fmt:message key="jsp.mydspace.main.export.archive.title"><fmt:param><%= fileName %></fmt:param></fmt:message>"><%=fileName%></a></li> 
		<% } %>
	</ol>
	<%} %>--%>
</dspace:layout>
