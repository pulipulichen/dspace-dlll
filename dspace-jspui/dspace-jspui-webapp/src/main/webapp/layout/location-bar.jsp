<%--
  - location-bar.jsp
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
  - Location bar component
  -
  - This component displays the "breadcrumb" style navigation aid at the top
  - of most screens.
  -
  - Uses request attributes set in org.dspace.app.webui.jsptag.Layout, and
  - hence must only be used as part of the execution of that tag.  Plus,
  - dspace.layout.locbar should be verified to be true before this is included.
  -
  -  dspace.layout.parenttitles - List of titles of parent pages
  -  dspace.layout.parentlinks  - List of URLs of parent pages, empty string
  -                               for non-links
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>
  
<%@ page import="java.util.List" %>

<p class="locationBar">
<%
    List parentTitles = (List) request.getAttribute("dspace.layout.parenttitles");
    List parentLinks = (List) request.getAttribute("dspace.layout.parentlinks");

    for (int i = 0; i < parentTitles.size(); i++)
    {
        String s = (String) parentTitles.get(i);
        String u = (String) parentLinks.get(i);

        // New line for each breadcrumb (no <br> needed for first)
        if (i > 0)
        {
%><br/><%
        }

        if (u.equals(""))
        {
%>
<%= s %>&nbsp;&gt;
<%
        }
        else
        {
%>
<a href="<%= request.getContextPath() %><%= u %>"><%= s %></a>&nbsp;&gt;
<%
        }
}
%>
</p>
