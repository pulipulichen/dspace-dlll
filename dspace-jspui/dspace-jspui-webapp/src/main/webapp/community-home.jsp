<%--
  - community-home.jsp
  -
  - Version: $Revision: 2397 $
  -
  - Date: $Date: 2007-11-28 11:53:16 -0600 (Wed, 28 Nov 2007) $
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
  - Community home JSP
  -
  - Attributes required:
  -    community             - Community to render home page for
  -    collections           - array of Collections in this community
  -    subcommunities        - array of Sub-communities in this community
  -    last.submitted.titles - String[] of titles of recently submitted items
  -    last.submitted.urls   - String[] of URLs of recently submitted items
  -    admin_button - Boolean, show admin 'edit' button
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="org.dspace.app.webui.components.RecentSubmissions" %>

<%@ page import="org.dspace.app.webui.servlet.admin.EditCommunitiesServlet" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.*" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.browse.BrowseInfo" %>

<%
    // Retrieve attributes
    Community community = (Community) request.getAttribute( "community" );
    Collection[] collections =
        (Collection[]) request.getAttribute("collections");
    Community[] subcommunities =
        (Community[]) request.getAttribute("subcommunities");
    
    RecentSubmissions rs = (RecentSubmissions) request.getAttribute("recently.submitted");
    
    Boolean editor_b = (Boolean)request.getAttribute("editor_button");
    boolean editor_button = (editor_b == null ? false : editor_b.booleanValue());
    Boolean add_b = (Boolean)request.getAttribute("add_button");
    boolean add_button = (add_b == null ? false : add_b.booleanValue());
    Boolean remove_b = (Boolean)request.getAttribute("remove_button");
    boolean remove_button = (remove_b == null ? false : remove_b.booleanValue());

	// get the browse indices
    BrowseIndex[] bis = BrowseIndex.getBrowseIndices();

    // Put the metadata values into guaranteed non-null variables
    String name = community.getMetadata("name");
    String intro = community.getMetadata("introductory_text");
    String copyright = community.getMetadata("copyright_text");
    String sidebar = community.getMetadata("side_bar_text");
    Bitstream logo = community.getLogo();
    
    boolean feedEnabled = ConfigurationManager.getBooleanProperty("webui.feed.enable");
    String feedData = "NONE";
    if (feedEnabled)
    {
        feedData = "comm:" + ConfigurationManager.getProperty("webui.feed.formats");
    }
    
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
%>

<dspace:layout locbar="commLink" title="<%= name %>" feedData="<%= feedData %>">

  <table border="0" cellpadding="5" width="100%">
    <tr>
      <td width="100%">
        <h1><%= name %>
        <%
            if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
            {
            	/*
%>
                : [<%= ic.getCount(community) %>]
<%
				*/
%>
				<fmt:message key="jsp.collection-home.heading-strengths">
    				<fmt:param><%= ic.getCount(community) %></fmt:param>
    			</fmt:message>
<%
            }
%>
        </h1>
		<h3><fmt:message key="jsp.community-home.heading1"/></h3>
      </td>
      <td valign="top">
<%  if (logo != null) { %>
        <img alt="Logo" src="<%= request.getContextPath() %>/retrieve/<%= logo.getID() %>" /> 
<% } %></td>
    </tr>
  </table>


  <%-- Search/Browse --%>
  
    <table class="miscTable" align="center" summary="This table allows you to search through all communities held in the repository">
    	<tr>
              <td align="center" class="standard" valign="middle">
        <%
        if (bis.length > 0)
    	{
    		%>
    	<table><tbody><tr>
    		<%
    	}
        %>
                <%-- <small><fmt:message key="jsp.general.orbrowse"/>&nbsp;</small> --%>
   				<%-- Insert the dynamic list of browse options --%>
<%
	for (int i = 0; i < bis.length; i++)
	{
		String key = "browse.menu." + bis[i].getName();
%>
	<td>
	<form method="get" action="<%= request.getContextPath() %>/handle/<%= community.getHandle() %>/browse">
		<input type="hidden" name="type" value="<%= bis[i].getName() %>"/>
		<%-- <input type="hidden" name="community" value="<%= community.getHandle() %>" /> --%>
		<input type="submit" name="submit_browse" value="<fmt:message key="<%= key %>"/>"/>
	</form>
	</td>
<%	
	}
%>
		<%
        if (bis.length > 0)
    	{
    		%>
    	</tr></tbody></table>
    		<%
    	}
        %>

			  </td>
            </tr>
      <tr>
        <td class="evenRowEvenCol" colspan="2">
        <form method="get" action="">
          <table width="100%">
            <tr>
              <td class="standard" align="center">
                <small><label for="tlocation"><strong><fmt:message key="jsp.general.location"/></strong></label></small>&nbsp;<select name="location" id="tlocation">
				 <option value="/"><fmt:message key="jsp.general.genericScope"/></option>
                 <option selected="selected" value="<%= community.getHandle() %>"><%= name %></option>
<%
    for (int i = 0; i < collections.length; i++)
    {
%>    
                  <option value="<%= collections[i].getHandle() %>"><%= collections[i].getMetadata("name") %></option>
<%
    }
%>
<%
    for (int j = 0; j < subcommunities.length; j++)
    {
%>    
                  <option value="<%= subcommunities[j].getHandle() %>"><%= subcommunities[j].getMetadata("name") %></option>
<%
    }
%>
                </select>
              </td>
              <td class="standard" align="center">
                <small><label for="tquery"><strong><fmt:message key="jsp.general.searchfor"/>&nbsp;</strong></label></small><input type="text" name="query" id="tquery" />&nbsp;<input type="submit" name="submit_search" value="<fmt:message key="jsp.general.go"/>" /> 
			  </td>
            </tr>
            </table>
            </form>
            </td>
            </tr>
          </table>
    
  <%= intro %>

<%
    if (collections.length != 0)
    {
%>

        <%-- <h2>Collections in this community</h2> --%>
		<h2><fmt:message key="jsp.community-home.heading2"/></h2>  
        <ul class="collectionListItem">
<%
        for (int i = 0; i < collections.length; i++)
        {
%>
    <li>
    	<div>
    		<div>
	      <a href="<%= request.getContextPath() %>/handle/<%= collections[i].getHandle() %>" class="collection-title">
	      <% 
			String coll = collections[i].getMetadata("name").trim();
			if (coll.equals(""))
				out.print(LocaleSupport.getLocalizedMessage(pageContext, "org.dspace.content.Collection.untitled"));	
			else
				out.print(coll);
	
			%></a>
<%
            if(ConfigurationManager.getBooleanProperty("webui.strengths.show"))
            {
%>
                <span class="collection-strengths">[<%= ic.getCount(collections[i]) %>]</span>
<%
            }
%>
		</div>
	    <% if (remove_button) { %>
	      <form method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
	          <input type="hidden" name="parent_community_id" value="<%= community.getID() %>" />
	          <input type="hidden" name="community_id" value="<%= community.getID() %>" />
	          <input type="hidden" name="collection_id" value="<%= collections[i].getID() %>" />
	          <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_DELETE_COLLECTION%>" />
	          <input type="image" src="<%= request.getContextPath() %>/image/remove.gif" />
	      </form>
	    <% } else
	       {
	       	%>
	       	<div>&nbsp;</div>
	       	<%
	       } %>
	  <%
	  		String short_description = collections[i].getMetadata("short_description").trim();
	  		if (short_description.equals("") == false)
	  		{
	  			%>
	  <p class="collectionDescription"><%= short_description %></p>
	  			<%
	  		}
	  %>
      </div>
    </li>
<%
        }
%>
  </ul>
<%
    }
%>

<%
    if (subcommunities.length != 0)
    {
%>
        <%--<h2>Sub-communities within this community</h2>--%>
		<h2><fmt:message key="jsp.community-home.heading3"/></h2>
   
        <ul class="collectionListItem">
<%
        for (int j = 0; j < subcommunities.length; j++)
        {
%>
            <li>
			    <div>
					 <div>
	                <a href="<%= request.getContextPath() %>/handle/<%= subcommunities[j].getHandle() %>" class="collection-title">
	                <%
						String subcomm = subcommunities[j].getMetadata("name").trim();
						if (subcomm.equals(""))
							out.print(LocaleSupport.getLocalizedMessage(pageContext, "org.dspace.content.Community.untitled"));
						else
							out.print(subcomm);
					%></a>
<%
                if (ConfigurationManager.getBooleanProperty("webui.strengths.show"))
                {
%>
                    <span class="collection-strengths">[<%= ic.getCount(subcommunities[j]) %>]</span>
<%
                }
%>
			    </div>
	    		<% if (remove_button) { %>
	                <form method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
			          <input type="hidden" name="parent_community_id" value="<%= community.getID() %>" />
			          <input type="hidden" name="community_id" value="<%= subcommunities[j].getID() %>" />
			          <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_DELETE_COMMUNITY%>" />
	                  <input type="image" src="<%= request.getContextPath() %>/image/remove.gif" />
	                </form>
	    <% } else
	       {
	       	%>
	       	<div>&nbsp;</div>
	       	<%
	       } %>
	  <%
	  		String short_description = subcommunities[j].getMetadata("short_description").trim();
	  		if (short_description.equals("") == false)
	  		{
	  			%>
	  <p class="collectionDescription"><%= short_description %></p>
	  			<%
	  		}
	  %>
	  			</div>
            </li>
<%
        }
%>
        </ul>
<%
    }
%>

<%
	if (rs != null && rs.getRecentSubmissions().length > 0)
	{
		%>
	<h2><fmt:message key="jsp.community-home.recentsub"/></h2>
		<%
		if (request.getAttribute("recently.submitted.browse-info") != null)
		{
			BrowseInfo bi = (BrowseInfo) request.getAttribute("recently.submitted.browse-info");
			String rsbname = ConfigurationManager.getProperty("recent.submissions.sort-option");
		%>
		
		<dspace:browselist browseInfo="<%= bi %>" />
		    <%
        if (bis.length > 0)
    	{
    		%>
    	<table align="center" class="recentBrowseListTable"><tbody><tr>
    		<%
    	}
        %>
                <%-- <small><fmt:message key="jsp.general.orbrowse"/>&nbsp;</small> --%>
   				<%-- Insert the dynamic list of browse options --%>
<%
	for (int i = 0; i < bis.length; i++)
	{
		String key = "browse.menu." + bis[i].getName();
%>
	<td>
	<form method="get" action="<%= request.getContextPath() %>/handle/<%= community.getHandle() %>/browse">
		<input type="hidden" name="type" value="<%= bis[i].getName() %>"/>
		<%-- <input type="hidden" name="community" value="<%= community.getHandle() %>" /> --%>
		<input type="submit" name="submit_browse" value="<fmt:message key="<%= key %>"/>"/>
	</form>
	</td>
<%	
	}
%>
		<%
        if (bis.length > 0)
    	{
    		%>
    	</tr></tbody></table>
    		<%
    	}
        %>
		<%
		}
	}
%>
  <p class="copyrightText"><%= copyright %></p>

  <dspace:sidebar>
    <% if(editor_button || add_button)  // edit button(s)
    { %>
    <table class="miscTable" align="center">
	  <tr>
	    <td class="evenRowEvenCol" colspan="2">
	      <table>
            <tr>
              <th id="t1" class="standard">
                 <%--<strong>Admin Tools</strong>--%>
				 <strong><fmt:message key="jsp.admintools"/></strong>
              </th>
            </tr>
            <tr>
              <td headers="t1" class="standard" align="center">
             <% if(editor_button) { %>
	            <form method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
		          <input type="hidden" name="community_id" value="<%= community.getID() %>" />
		          <input type="hidden" name="action" value="<%=EditCommunitiesServlet.START_EDIT_COMMUNITY%>" />
                  <%--<input type="submit" value="Edit..." />--%>
                  <input type="submit" value="<fmt:message key="jsp.general.edit.button"/>" />
                </form>
             <% } %>
             <% if(add_button) { %>

				<form method="post" action="<%=request.getContextPath()%>/tools/collection-wizard">
		     		<input type="hidden" name="community_id" value="<%= community.getID() %>" />
                    <input type="submit" value="<fmt:message key="jsp.community-home.create1.button"/>" />
                </form>
                
                <form method="post" action="<%=request.getContextPath()%>/tools/edit-communities">
                    <input type="hidden" name="action" value="<%= EditCommunitiesServlet.START_CREATE_COMMUNITY%>" />
                    <input type="hidden" name="parent_community_id" value="<%= community.getID() %>" />
                    <%--<input type="submit" name="submit" value="Create Sub-community" />--%>
                    <input type="submit" name="submit" value="<fmt:message key="jsp.community-home.create2.button"/>" />
                 </form>
             <% } %>
              </td>
            </tr>
            <tr>
              <td headers="t1" class="standard" align="center">
                 <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\")%>"><fmt:message key="jsp.adminhelp"/></dspace:popup>
              </td>
            </tr>
	  </table>
	</td>
      </tr>
    </table>
    <% } %>
    
    <%-- Recently Submitted items --%>
<%
	if (rs != null && rs.getRecentSubmissions().length > 0)
	{
		%>
	<h3><fmt:message key="jsp.community-home.recentsub"/></h3>
		<%
		Item[] items = rs.getRecentSubmissions();
		for (int i = 0; i < items.length; i++)
		{
			DCValue[] dcv = items[i].getMetadata("dc", "title", null, Item.ANY);
			String displayTitle = "Untitled";
			if (dcv != null)
			{
				if (dcv.length > 0)
				{
					displayTitle = dcv[0].value;
				}
			}
			%><p class="recentItem"><a href="<%= request.getContextPath() %>/handle/<%= items[i].getHandle() %>"><%= displayTitle %></a></p><%
		}
		%>
		    <p>&nbsp;</p>   
		<%
	}

    if(feedEnabled)
    {
%>
    <center>
    <h4><fmt:message key="jsp.community-home.feeds"/></h4>
<%
    	String[] fmts = feedData.substring(5).split(",");
    	String icon = null;
    	int width = 0;
    	for (int j = 0; j < fmts.length; j++)
    	{
    		if ("rss_1.0".equals(fmts[j]))
    		{
    		   icon = "rss1.gif";
    		   width = 80;
    		}
    		else if ("rss_2.0".equals(fmts[j]))
    		{
    		   icon = "rss2.gif";
    		   width = 80;
    		}
    		else
    	    {
    	       icon = "rss.gif";
    	       width = 36;
    	    }
%>
    <a href="<%= request.getContextPath() %>/feed/<%= fmts[j] %>/<%= community.getHandle() %>"><img src="<%= request.getContextPath() %>/image/<%= icon %>" alt="RSS Feed" width="<%= width %>" height="15" vspace="3" border="0" /></a>
<%
    	}
%>
    </center>
<%
    }
%>

    <%
    	if (sidebar.trim().equals("") == false)
    	{
    		out.print( "<p>&nbsp;</p>" );
    	   	out.print( sidebar.trim() );
    	}
    	
    %>

  </dspace:sidebar>


</dspace:layout>

