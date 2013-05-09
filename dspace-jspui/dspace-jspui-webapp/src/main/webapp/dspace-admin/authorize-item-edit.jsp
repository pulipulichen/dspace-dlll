<%--
  - authorize_item_edit.jsp
  -
  - $Id: authorize-item-edit.jsp 1947 2007-05-18 13:50:29Z cjuergen $
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
  - Show policies for an item, allowing you to modify, delete
  -  or add to them
  -
  - Attributes:
  -  item          - Item being modified
  -  item_policies - ResourcePolicy List of policies for the item
  -  bundles            - [] of Bundle objects
  -  bundle_policies    - Map of (ID, List of policies)
  -  bitstream_policies - Map of (ID, List of policies)
  -
  - Returns:
  -  submit value item_add_policy         to add a policy 
  -  submit value item_edit_policy        to edit policy for item, bundle, or bitstream
  -  submit value item_delete_policy      to delete policy for item, bundle, or bitstream
  -
  -  submit value bundle_add_policy       add policy
  -
  -  submit value bitstream_add_policy    to add a policy
  -
  -  policy_id - ID of policy to edit, delete
  -  item_id
  -  bitstream_id
  -  bundle_id
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List"     %>
<%@ page import="java.util.Map"      %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.dspace.authorize.ResourcePolicy" %>
<%@ page import="org.dspace.content.Item"             %>
<%@ page import="org.dspace.content.Bundle"           %>
<%@ page import="org.dspace.content.Bitstream"        %>
<%@ page import="org.dspace.core.Constants"           %>
<%@ page import="org.dspace.eperson.EPerson"          %>
<%@ page import="org.dspace.eperson.Group"            %>
<%@ page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page import="org.dspace.core.Context"   %>

<%
    // get item and list of policies
    Item item = (Item) request.getAttribute("item");
    List item_policies =
        (List) request.getAttribute("item_policies");

    // get bitstreams and corresponding policy lists
    Bundle [] bundles      = (Bundle [])request.getAttribute("bundles");
    Map bundle_policies    = (Map)request.getAttribute("bundle_policies"   );
    Map bitstream_policies = (Map)request.getAttribute("bitstream_policies");
    
    String parenttitlekey = "jsp.administer";
    String parentlink = "/dspace-admin";
    if (item != null)
    {
    	parenttitlekey = "jsp.tools.edit-item-form.title";
    	parentlink = "/tools/edit-item?item_id=" + item.getID();
    }
    
    if (request.getParameter("authorize_admin") != null)
    {
    	parenttitlekey = "jsp.dspace-admin.item-select.title";
    	parentlink = "/dspace-admin/authorize?submit_type=submit_item";
    }
    
    String itemTitle = item.getTitle();
    if (itemTitle.equals(""))
    	itemTitle = LocaleSupport.getLocalizedMessage(pageContext, 
							"jsp.tools.itemmap-main.itemlist.title-null");
    String itemURL = request.getContextPath() + "/handle/" + item.getHandle();
    Context context = UIUtil.obtainContext(request);
    
    boolean inAuthorizeAdmin = (request.getParameter("authorize_admin") != null);
%>

<dspace:layout titlekey="jsp.dspace-admin.authorize-item-edit.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="<%= parenttitlekey %>"
               parentlink="<%= parentlink %>"
               nocache="true">
  <table width="95%">
    <tr>
      <td align="left">
	<h1><fmt:message key="jsp.dspace-admin.authorize-item-edit.policies">
		<fmt:param><%= "<a href=\""+itemURL+"\" target=\"_blank\">" + itemTitle + "</a>" %></fmt:param>
        <fmt:param><%= "<a href=\""+itemURL+"\" target=\"_blank\">" + item.getHandle() + "</a>" %></fmt:param>
        <fmt:param><%= item.getID() %></fmt:param>
    </fmt:message></h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.site-admin\") + \"#itempolicies\"%>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

  <p><fmt:message key="jsp.dspace-admin.authorize-item-edit.text1"/></p>
  <p><fmt:message key="jsp.dspace-admin.authorize-item-edit.text2"/></p>

	<h2>
		<a name="authorize_item_content" id="authorize_item_content"></a>
		<fmt:message key="jsp.dspace-admin.authorize-item-edit.content"/>
	</h2>
	<%
	//請在這邊加入目錄
	%>
	<ul>
		<li><a href="#anchor_item_<%= item.getID() %>"><fmt:message key="jsp.dspace-admin.authorize-item-edit.item"/></a></li>
		<%
		for( int b = 0; b < bundles.length; b++ )
    	{
    		Bundle myBun = bundles[b];
    		%>
    	<li>
    		<a href="#anchor_bundle_<%= myBun.getID() %>">
	    		<fmt:message key="jsp.dspace-admin.authorize-item-edit.bundle">
		            <fmt:param><%=myBun.getName()%></fmt:param>
		            <fmt:param><%=myBun.getID()%></fmt:param>
		        </fmt:message>
	        </a>
	        <%
	        	
	        	
	        %>
    	</li>
    		<%
    	}	//for( int b = 0; b < bundles.length; b++ )
		%>
	</ul>
	
    	<p align="center">
            <table width="70%" align="center">
                <tr>
                    <td align="center">
            			<%
            			if (inAuthorizeAdmin)
        				{
        					%>
        				<form method="post" action="<%= request.getContextPath() %>/dspace-admin/authorize">
        					<input type="submit" name="submit_item" value="<fmt:message key="jsp.tools.general.return"/>"/>
        				</form>
        					
        					<%
        				}
        				else
        				{
        					%>
        				<form method="post" action="<%= request.getContextPath() %>/tools/edit-item">
            				<input type="hidden" name="item_id" value="<%= item.getID() %>" />
                        	<input type="submit" name="submit_cancel" value="<fmt:message key="jsp.tools.general.return"/>"/>
            			</form>
        					<%
        				}
        				%>
            			
                    </td>
                </tr>
            </table>
        </p>

	
	<div style="text-align:center">
		<hr width="95%" />
	</div>
		
	<script type="text/javascript">
	function goToTop()
	{
		location.href="#authorize_item_content";
	}
	</script>
		
  <h3><a id="anchor_item_<%= item.getID() %>" name="anchor_item_<%= item.getID() %>"></a><fmt:message key="jsp.dspace-admin.authorize-item-edit.item"/></h3>
    <table class="miscTable" align="center" summary="Item Policy Edit Form">
        <tr>
            <th class="oddRowOddCol"><strong><fmt:message key="jsp.general.id" /></strong></th>
            <th class="oddRowEvenCol"><strong><fmt:message key="jsp.dspace-admin.general.action"/></strong></th>
            <th class="oddRowOddCol"><strong><fmt:message key="jsp.dspace-admin.authorize-item-edit.eperson"/></strong></th>
            <th class="oddRowEvenCol"><strong><fmt:message key="jsp.dspace-admin.general.group"/></strong></th>
            <th class="oddRowOddCol">&nbsp;</th>
        </tr>
<%
    String row = "even";
    Iterator i = item_policies.iterator();

    while( i.hasNext() )
    {
        ResourcePolicy rp = (ResourcePolicy) i.next();
%>
        <tr>
            <td class="<%= row %>RowOddCol"><%= rp.getID() %></td>
            <td class="<%= row %>RowEvenCol" align="center">
                    <%//= rp.getActionText() %>
    				<%= UIUtil.getAuthorizeActionLocalizeMessage(pageContext, rp.getActionText()) %>
            </td>
            <td class="<%= row %>RowOddCol">
                    <%= (rp.getEPerson() == null ? "..." : rp.getEPerson().getEmail() ) %>  
            </td>
            <td class="<%= row %>RowEvenCol">
                    <%//= (rp.getGroup()   == null ? "..." : rp.getGroup().getName() ) %>  
    				<%= (rp.getGroup()   == null ? "..."
    					: UIUtil.getGroupLocalizeName(context, pageContext, rp.getGroup()) ) %> 
            </td>
            <td class="<%= row %>RowOddCol">
                 <form method="post" action="?"> 
    				 <%	if (inAuthorizeAdmin) out.print("<input type=\"hidden\" name=\"authorize_admin\" value=\"true\" />"); %>
                     <input type="hidden" name="policy_id" value="<%= rp.getID() %>" />
                     <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                     <input type="submit" name="submit_item_edit_policy" value="<fmt:message key="jsp.dspace-admin.general.edit"/>" />
                     <input type="submit" name="submit_item_delete_policy" value="<fmt:message key="jsp.dspace-admin.general.delete"/>" />
                </form>  
            </td>
        </tr>
<%
        row = (row.equals("odd") ? "even" : "odd");
    }
%>
    </table>

    	<p align="center">
            <table width="70%" align="center">
                <tr>
                    <td align="left">
            			<form method="post" action="?">
					      	  <%	if (inAuthorizeAdmin) out.print("<input type=\"hidden\" name=\"authorize_admin\" value=\"true\" />"); %>
					          <input type="hidden" name="item_id" value="<%=item.getID()%>" />
					          <input type="submit" name="submit_item_add_policy" value="<fmt:message key="jsp.dspace-admin.general.addpolicy"/>" />
					    </form>	
                    </td>
            		<td align="right">
            			<input type="button" value="<fmt:message key="jsp.dspace-admin.authorize-item-edit.go-to-top"/>" onclick="goToTop()" />
            		</td>
                </tr>
            </table>
        </p>

    
	<div style="text-align:center">
		<hr width="95%" />
	</div>
				
<%
    for( int b = 0; b < bundles.length; b++ )
    {
        Bundle myBun = bundles[b];
        List myPolicies = (List)bundle_policies.get(new Integer(myBun.getID()));

        // display add policy
        // display bundle header w/ID

%>                
        <h3><a id="anchor_bundle_<%= myBun.getID() %>" name="anchor_bundle_<%= myBun.getID() %>"></a><fmt:message key="jsp.dspace-admin.authorize-item-edit.bundle">
            <fmt:param><%=myBun.getName()%></fmt:param>
            <fmt:param><%=myBun.getID()%></fmt:param>
        </fmt:message></h3>

      
        
    <table class="miscTable" align="center" summary="Bundle Policy Edit Form">
        <tr>
            <th class="oddRowOddCol"><strong><fmt:message key="jsp.general.id" /></strong></th>
            <th class="oddRowEvenCol"><strong><fmt:message key="jsp.dspace-admin.general.action"/></strong></th>
            <th class="oddRowOddCol"><strong><fmt:message key="jsp.dspace-admin.general.eperson" /></strong></th>
            <th class="oddRowEvenCol"><strong><fmt:message key="jsp.dspace-admin.general.group"/></strong></th>
            <th class="oddRowOddCol">&nbsp;</th>
        </tr>

<%
    row = "even";
    i = myPolicies.iterator();

    while( i.hasNext() )
    {
        ResourcePolicy rp = (ResourcePolicy) i.next();
%>
        <tr>
            <td class="<%= row %>RowOddCol"><%= rp.getID() %></td>
            <td class="<%= row %>RowEvenCol" align="center">
                    <%//= rp.getActionText() %>
    				<%= UIUtil.getAuthorizeActionLocalizeMessage(pageContext, rp.getActionText()) %>
            </td>
            <td class="<%= row %>RowOddCol">
                    <%= (rp.getEPerson() == null ? "..." : rp.getEPerson().getEmail() ) %>  
            </td>
            <td class="<%= row %>RowEvenCol">
                    <%= (rp.getGroup()   == null ? "..." 
    						: UIUtil.getGroupLocalizeName(context, pageContext, rp.getGroup()) ) %>
            </td>
            <td class="<%= row %>RowOddCol">
                <form method="post" action="?">
    				<%	if (inAuthorizeAdmin) out.print("<input type=\"hidden\" name=\"authorize_admin\" value=\"true\" />"); %>
                    <input type="hidden" name="policy_id" value="<%= rp.getID() %>" />
                    <input type="hidden" name="item_id" value="<%= item.getID() %>" />
                    <input type="hidden" name="bundle_id" value="<%= myBun.getID() %>" />
                    <input type="submit" name="submit_item_edit_policy" value="<fmt:message key="jsp.dspace-admin.general.edit"/>" />
                    <input type="submit" name="submit_item_delete_policy" value="<fmt:message key="jsp.dspace-admin.general.delete"/>" />
                </form>
            </td>
         </tr>
<%
        row = (row.equals("odd") ? "even" : "odd");
    }
%>
    </table>
    
    	<p align="center">
            <table width="70%" align="center">
                <tr>
                    <td align="left">
				        <form method="post" action="?">
				            	<%	if (inAuthorizeAdmin) out.print("<input type=\"hidden\" name=\"authorize_admin\" value=\"true\" />"); %>
				                <input type="hidden" name="item_id" value="<%=item.getID()%>" />
				                <input type="hidden" name="bundle_id" value="<%=myBun.getID()%>" />
				                <input type="submit" name="submit_bundle_add_policy" value="<fmt:message key="jsp.dspace-admin.general.addpolicy"/>" />
				        </form>
                    </td>
            		<td align="right">
            			<input type="button" value="<fmt:message key="jsp.dspace-admin.authorize-item-edit.go-to-top"/>" onclick="goToTop()" />
            		</td>
                </tr>
            </table>
        </p>    

<%
        Bitstream [] bitstreams = myBun.getBitstreams();
                
        for( int s = 0; s < bitstreams.length; s++ )
        {
            Bitstream myBits = bitstreams[s];
            myPolicies  = (List)bitstream_policies.get(new Integer(myBits.getID()));

            // display bitstream header w/ID, filename
            // 'add policy'
            // display bitstream's policies
            
            String bitstreamName = myBits.getName();
            String bitstreamURL = request.getContextPath() + "/retrieve/" + myBits.getID() + "/" 
            	+ UIUtil.encodeBitstreamName(myBits.getName(),Constants.DEFAULT_ENCODING);
            String bitstreamLink = "<a href=\""+bitstreamURL+"\" target=\"_blank\">"
            	+ bitstreamName
            	+ "</a>";
%>                        
            <p><fmt:message key="jsp.dspace-admin.authorize-item-edit.bitstream">
    			<fmt:param><%= bitstreamLink %></fmt:param>
                <fmt:param><%= myBits.getID() %></fmt:param>
            </fmt:message></p>
            <table class="miscTable" align="center" summary="This table displays the bitstream data">
            <tr>
                <th class="oddRowOddCol"><strong><fmt:message key="jsp.general.id" /></strong></th>
                <th class="oddRowEvenCol"><strong><fmt:message key="jsp.dspace-admin.general.action"/></strong></th>
                <th class="oddRowOddCol"><strong><fmt:message key="jsp.dspace-admin.authorize-item-edit.eperson" /></strong></th>
                <th class="oddRowEvenCol"><strong><fmt:message key="jsp.dspace-admin.general.group"/></strong></th>
                <th class="oddRowOddCol">&nbsp;</th>
            </tr>
<%
    row = "even";
    i = myPolicies.iterator();

    while( i.hasNext() )
    {
        ResourcePolicy rp = (ResourcePolicy) i.next();
%>
        <tr>
            <td class="<%= row %>RowOddCol"><%= rp.getID() %></td>
            <td class="<%= row %>RowEvenCol" align="center">
                    <%= UIUtil.getAuthorizeActionLocalizeMessage(pageContext, rp.getActionText()) %>
            </td>
            <td class="<%= row %>RowOddCol">
                    <%= (rp.getEPerson() == null ? "..." : rp.getEPerson().getEmail() ) %>  
            </td>
            <td class="<%= row %>RowEvenCol">
                    <%= (rp.getGroup()   == null ? "..." 
    						: UIUtil.getGroupLocalizeName(context, pageContext, rp.getGroup()) ) %>  
            </td>
            <td class="<%= row %>RowOddCol">
                <form method="post" action="?">
    				<%	if (inAuthorizeAdmin) out.print("<input type=\"hidden\" name=\"authorize_admin\" value=\"true\" />"); %>
                    <input type="hidden" name="policy_id" value="<%= rp.getID()     %>" />
                    <input type="hidden" name="item_id" value="<%= item.getID()   %>" />
                    <input type="hidden" name="bitstream_id" value="<%= myBits.getID() %>" />
                    <input type="submit" name="submit_item_edit_policy" value="<fmt:message key="jsp.dspace-admin.general.edit"/>" />
                    <input type="submit" name="submit_item_delete_policy" value="<fmt:message key="jsp.dspace-admin.general.delete"/>" />
                 </form>  
            </td>
        </tr>
<%
                row = (row.equals("odd") ? "even" : "odd");
            }
%>
    </table>

    	<p align="center">
            <table width="70%" align="center">
                <tr>
                    <td align="left">
			            <form method="post" action="?">
			    				<%	if (inAuthorizeAdmin) out.print("<input type=\"hidden\" name=\"authorize_admin\" value=\"true\" />"); %>
			                    <input type="hidden" name="item_id"value="<%=item.getID()%>" />
			                    <input type="hidden" name="bitstream_id" value="<%=myBits.getID()%>" />
			                    <input type="submit" name="submit_bitstream_add_policy" value="<fmt:message key="jsp.dspace-admin.general.addpolicy"/>" />
			            </form>
                    </td>
            		<td align="right">
            			<input type="button" value="<fmt:message key="jsp.dspace-admin.authorize-item-edit.go-to-top"/>" onclick="goToTop()" />
            		</td>
                </tr>
            </table>
        </p>

<%

        }
        
        if (b < bundles.length - 1)
        {
        %>
    <div style="text-align:center">
		<hr width="95%" />
	</div>
        <%
        }	//if (b < bundles.length - 1)
    }
%>
</dspace:layout>
