<%--
  - list-formats.jsp
  -
  - Version: $Revision: 1947 $
  -
  - Date: $Date: 2007-05-18 08:50:29 -0500 (Fri, 18 May 2007) $
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
  - Display list of bitstream formats
  -
  - Attributes:
  -
  -   formats - the bitstream formats in the system (BitstreamFormat[])
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.content.BitstreamFormat" %>
<%@ page import="org.dspace.core.Context"%>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>



<%
    BitstreamFormat[] formats =
        (BitstreamFormat[]) request.getAttribute("formats");
%>

<dspace:layout titlekey="jsp.dspace-admin.list-formats.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin">

    <h1><fmt:message key="jsp.dspace-admin.list-formats.title"/></h1>

    <p><fmt:message key="jsp.dspace-admin.list-formats.text1"/></p>
    <p><fmt:message key="jsp.dspace-admin.list-formats.text2"/></p>

    &nbsp;&nbsp;<dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\") + \"#bitstream\"%>"><fmt:message key="jsp.help"/></dspace:popup>

<style type="text/css">
table.format-registry form table { width: 100%; }
table.format-registry form table td { text-align:center; }
table.format-registry form table td input.text { width: 95%; }

table.format-registry form table td.id { width: 35px; text-align:center; }
table.format-registry form table td.mime,
table.format-registry form table td.extensions { width: 13%; }
table.format-registry form table td.name { width: 12%; }
table.format-registry form table td.description { width: 16%; }
table.format-registry form table td.support { width: 10%; }
table.format-registry form table td.update,
table.format-registry form table td.delete { width: 10%; }
table.format-registry form table td.internal { width: 10%; }
</style>

<%
    Context context = UIUtil.obtainContext(request);

%>

        <table class="miscTable format-registry" align="center" summary="Bitstream Format Registry data table" width="95%">
            <tr>
                <th class="oddRowOddCol">
            <form method="post" action="">
            		<table>
                       <tr>
                          <td class="oddRowOddCol id"><fmt:message key="jsp.general.id" /></td>
                          <td class="oddRowEvenCol mime">
                              <fmt:message key="jsp.dspace-admin.list-formats.mime"/>
                          </td>
                          <td class="oddRowOddCol name">
            				  <fmt:message key="jsp.dspace-admin.list-formats.name"/>	
                          </td>
                          <td class="oddRowEvenCol description">
                              <fmt:message key="jsp.dspace-admin.list-formats.description"/>
                          </td>
                          <td class="oddRowOddCol support">
                              <fmt:message key="jsp.dspace-admin.list-formats.support"/>
                          </td>
                          <td class="oddRowEvenCol internal" align="center">
                              <fmt:message key="jsp.dspace-admin.list-formats.internal"/>
                          </td>
                          <td class="oddRowOddCol extensions">
                              <fmt:message key="jsp.dspace-admin.list-formats.extensions"/>
                          </td>
                          <td class="oddRowEvenCol update">
                              &nbsp;
                          </td>
                          <td class="oddRowOddCol delete">
                          	&nbsp;
                         </td>
                    </tr>    
                  </table> 
            </form>
                 </th>
            </tr>
<%

    String row = "even";
    for (int i = 0; i < formats.length; i++)
    {
        String[] extensions = formats[i].getExtensions();
        String extValue = "";

        for (int j = 0 ; j < extensions.length; j++)
        {
            if (j > 0)
            {
                extValue = extValue + ", ";
            }
            extValue = extValue + extensions[j];
        }
%>
             <tr>
                 <td>
                  <form method="post" action="">
                    <table>
                       <tr>
                          <td class="<%= row %>RowOddCol id"><%= formats[i].getID() %></td>
                          <td class="<%= row %>RowEvenCol mime">
                              <input class="text" type="text" name="mimetype" value="<%= formats[i].getMIMEType() %>"/>
                          </td>
                          <td class="<%= row %>RowOddCol name">
                    <%
                      if (BitstreamFormat.findUnknown(context).getID() == formats[i].getID()) {
                    %>
                      <i><%= formats[i].getShortDescription() %></i>
                    <% } else { %>
                              <input class="text" type="text" name="short_description" value="<%= formats[i].getShortDescription() %>" size="10"/>
                    <% } %>
                          </td>
                          <td class="<%= row %>RowEvenCol description">
                              <input class="text" type="text" name="description" value="<%= formats[i].getDescription() %>" size="20"/>
                          </td>
                          <td class="<%= row %>RowOddCol support">
                              <select name="support_level">
                                  <option value="0" <%= formats[i].getSupportLevel() == 0 ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.dspace-admin.list-formats.unknown"/></option>
	    	                  <option value="1" <%= formats[i].getSupportLevel() == 1 ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.dspace-admin.list-formats.known"/></option>
                                  <option value="2" <%= formats[i].getSupportLevel() == 2 ? "selected=\"selected\"" : "" %>><fmt:message key="jsp.dspace-admin.list-formats.supported"/></option>
                              </select>
                          </td>
                          <td class="<%= row %>RowEvenCol internal" align="center">
                          	  <fmt:message key="jsp.dspace-admin.list-formats.internal-hint" />
                              <input type="checkbox" name="internal" value="true"<%= formats[i].isInternal() ? " checked=\"checked\"" : "" %>/>
                          </td>
                          <td class="<%= row %>RowOddCol extensions">
                              <input class="text" type="text" name="extensions" value="<%= extValue %>" size="10"/>
                          </td>
                          <td class="<%= row %>RowEvenCol update">
                              <input type="hidden" name="format_id" value="<%= formats[i].getID() %>" />
                              <input type="submit" name="submit_update" value="<fmt:message key="jsp.dspace-admin.general.update"/>"/>
                          </td>
                          <td class="<%= row %>RowOddCol delete">
                    <%
                      if (BitstreamFormat.findUnknown(context).getID() != formats[i].getID()) {
                    %>
                             <input type="submit" name="submit_delete" value="<fmt:message key="jsp.dspace-admin.general.delete-w-confirm"/>" />
                     <% 
                      } 
                    %>
                         </td>
                    </tr>    
                  </table> 
                 </form>
             </td>
        </tr>
<%
        row = (row.equals("odd") ? "even" : "odd");
    }
%>

  </table>

  <form method="post" action="">
    <p align="center">
            <input type="submit" name="submit_add" value="<fmt:message key="jsp.dspace-admin.general.addnew"/>" />
    </p>
  </form>
</dspace:layout>
