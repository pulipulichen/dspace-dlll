<%--
  - list-dctypes.jsp
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
  - Display list of DC types
  -
  - Attributes:
  -
  -   formats - the DC formats in the system (MetadataValue[])
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.lang.String" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.content.MetadataField" %>
<%@ page import="org.dspace.content.MetadataSchema" %>


<%
    MetadataField[] types =
        (MetadataField[]) request.getAttribute("types");
    MetadataSchema schema =
        (MetadataSchema) request.getAttribute("schema");
    MetadataSchema[] schemas =
        (MetadataSchema[]) request.getAttribute("schemas");
%>

<dspace:layout titlekey="jsp.dspace-admin.list-metadata-fields.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.dspace-admin.list-metadata-schemas.title"
               parentlink="/dspace-admin/metadata-schema-registry">

  <table width="95%">
    <tr>
      <td align="left">
      	<h1>
  				<form method="post" action="<%= request.getContextPath() + "/dspace-admin/metadata-schema-registry" %>">
                    <input type="hidden" name="dc_schema_id" value="<%= schema.getSchemaID() %>"/>
      		<fmt:message key="jsp.dspace-admin.list-metadata-fields.title"/>
      	<%
  			if (types.length == 0)
  			{
  				%>
                    <input type="submit" name="submit_delete" value="<fmt:message key="jsp.dspace-admin.general.delete-w-confirm"/>"/>
  				<%
  			}
      	%>
                </form>        	
        </h1>
      </td>
      <td align="right" class="standard">
              <a href="<%=request.getContextPath()%>/dspace-admin/metadata-schema-registry">
                <fmt:message key="jsp.dspace-admin.list-metadata-fields.schemas"/>
              </a> |
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\") + \"#dublincore\"%>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

<%
String error = (String)request.getAttribute("error");
if (error!=null) {
%>
    <p align="center">
    <font color="red"><%=error%></font>
    </p>
<% } %>

    <p align="center">
        <fmt:message key="jsp.dspace-admin.list-metadata-fields.note"/>
    </p>
	<style type="text/css">
	table.metadata-field table { width:100% }
	table.metadata-field table td .text { width: 95%; }
	table.metadata-field table td.id { width:40px; }
	table.metadata-field table td.element,
	table.metadata-field table td.qualifier { width:20%; }
	table.metadata-field table td.scope { width:30%; }
	table.metadata-field table td.update,
	table.metadata-field table td.delete { width:80px; }
	</style>
        <table width="90%" class="miscTable metadata-field" align="center" summary="Dublic Core Type Registry data table">
           <tr>
              <th class="oddRowOddCol">
            	<table>
                     <tr>
                		<td class="oddRowOddCol id" align="center">
            				<fmt:message key="jsp.general.id" /> 
            			</td>
                         <td class="oddRowEvenCol element" align="center">
                             <fmt:message key="jsp.dspace-admin.list-metadata-fields.element"/> 
                         </td>
                         <td class="oddRowOddCol qualifier" align="center">
                             <fmt:message key="jsp.dspace-admin.list-metadata-fields.qualifier"/> 
                         </td>
                         <td class="oddRowEvenCol scope" width="40%" align="center">
                             <fmt:message key="jsp.dspace-admin.list-metadata-fields.scope"/>
                         </td>
                         <td class="oddRowOddCol update" align="center">
                            &nbsp;
                         </td>
                         <td class="oddRowEvenCol delete" align="center">
                            &nbsp;
                         </td>
                     </tr>
                 </table>
              </th>
           </tr>
           
<%
    String row = "even";
    for (int i = 0; i < types.length; i++)
    {
%>
      <tr>
         <td>
             <form method="post" action="">
                 <table width="100%">
                     <tr>
                <td class="<%= row %>RowOddCol id" align="center"><%= types[i].getFieldID() %></td>
                         <td class="<%= row %>RowEvenCol element" align="center">
                             <input class="text" type="text" name="element" value="<%= types[i].getElement() %>" />
                         </td>
                         <td class="<%= row %>RowOddCol qualifier" align="center">
                             <input class="text" type="text" name="qualifier" value="<%= (types[i].getQualifier() == null ? "" : types[i].getQualifier()) %>"  />
                         </td>
                         <td class="<%= row %>RowEvenCol scope" align="center">
                             <textarea class="text" name="scope_note" rows="3"  style="width:90%;" ><%= (types[i].getScopeNote() == null ? "" : types[i].getScopeNote()) %></textarea>
                         </td>
                         <td class="<%= row %>RowOddCol update" align="center">
                            <input type="hidden" name="dc_type_id" value="<%= types[i].getFieldID() %>"/>
                            <input type="submit" name="submit_update" value="<fmt:message key="jsp.dspace-admin.general.update"/>"/>
                         </td>
                         <td class="<%= row %>RowEvenCol delete" align="center">
                            <input type="hidden" name="dc_type_id" value="<%= types[i].getFieldID() %>"/>
                            <input type="submit" name="submit_delete" value="<fmt:message key="jsp.dspace-admin.general.delete-w-confirm"/>"/>
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
        <input type="hidden" name="dc_schema_id" value="<%= schema.getSchemaID() %>"/>
        <table align="center" width="650">
              <tr><td colspan="2"><h2><fmt:message key="jsp.dspace-admin.list-metadata-fields.addfield"/></h2></td></tr>
              <tr>
                      <td colspan="2"><p><fmt:message key="jsp.dspace-admin.list-metadata-fields.addfieldnote"/><br/><br/>
                      </p></td>
              </tr>
              <tr>
                      <td><p><fmt:message key="jsp.dspace-admin.list-metadata-fields.element"/>:</p></td>
                      <td><input type="text" name="element"/></td>
              </tr>
              <tr>
                      <td><p><fmt:message key="jsp.dspace-admin.list-metadata-fields.qualifier"/>:</p></td>
                      <td><input type="text" name="qualifier"/></td>
              </tr>
              <tr>
                      <td valign="top"><p><fmt:message key="jsp.dspace-admin.list-metadata-fields.scope"/>:</p></td>
                      <td><textarea name="scope_note" rows="3" cols="40"></textarea></td>
              </tr>
            <tr><td></td><td><input type="submit" name="submit_add" value="<fmt:message key="jsp.dspace-admin.general.addnew"/>"/></td></tr>
        </table>
      </form>


    <form method="post" action="">
      <table align="center" width="650">
              <tr><td colspan="2"><h2><fmt:message key="jsp.dspace-admin.list-metadata-fields.move"/></h2></td></tr>
<% if (schemas.length > 1) { %>
        <tr><td colspan="2"><p>
        <fmt:message key="jsp.dspace-admin.list-metadata-fields.movenote"/></p>
      </td></tr>
      <tr>
         <td valign="top"><p><fmt:message key="jsp.dspace-admin.list-metadata-fields.element"/>:</p></td><td>
      <select name="dc_field_id" multiple="multiple" size="5">
<%
    for (int i = 0; i < types.length; i++)
    {
      String qualifier = (types[i].getQualifier() == null ? "" : "."+types[i].getQualifier());
%>     <option value="<%= types[i].getFieldID() %>"><%= types[i].getElement()+qualifier %></option>
<%  }
%>
      </select></td></tr>
      <tr><td><p><fmt:message key="jsp.dspace-admin.list-metadata-fields.schema"/>: </p></td><td>
      <select name="dc_dest_schema_id">
<%
    for (int i = 0; i < schemas.length; i++)
    {
              if (schemas[i].getSchemaID() != schema.getSchemaID())
              {
%>      <option value="<%= schemas[i].getSchemaID() %>"><%= schemas[i].getNamespace() %></option>
<%            }
    }
%>
      </select></td></tr>
        <tr><td></td><td><p><input type="submit" name="submit_move" value="<fmt:message key="jsp.dspace-admin.list-metadata-fields.movesubmit"/>"/></p></td></tr>
<% } else { %>
        <tr><td colspan="2">
              <p><fmt:message key="jsp.dspace-admin.list-metadata-fields.moveformnote"/><br/><br/>
              </p>
      </td></tr>
<% } %>
      </table>
   </form>

</dspace:layout>
