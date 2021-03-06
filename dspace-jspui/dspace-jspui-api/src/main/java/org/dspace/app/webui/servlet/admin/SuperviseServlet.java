/*
 * SuperviseServlet.java
 *
 * Version: $Revision: 1520 $
 *
 * Date: $Date: 2006-05-26 07:14:03 -0700 (Fri, 26 May 2006) $
 *
 * Copyright (c) 2002-2005, Hewlett-Packard Company and Massachusetts
 * Institute of Technology.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the Hewlett-Packard Company nor the name of the
 * Massachusetts Institute of Technology nor the names of their
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

package org.dspace.app.webui.servlet.admin;

import java.io.IOException;
import java.lang.StringBuffer;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import org.dspace.app.webui.util.JSPManager;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.SupervisedItem;
import org.dspace.content.WorkspaceItem;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.eperson.Group;
import org.dspace.eperson.Supervisor;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;

/**
 * Servlet to handle administration of the supervisory system
 *
 * @author Richard Jones
 * @version  $Revision: 1520 $
 */
public class SuperviseServlet extends org.dspace.app.webui.servlet.DSpaceServlet
{
    
     /** log4j category */
    private static Logger log = Logger.getLogger(SuperviseServlet.class);
    
    protected void doDSGet(Context c, 
        HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException, AuthorizeException
    {
        // pass all requests to the same place for simplicity
        doDSPost(c, request, response);
    }
    
    protected void doDSPost(Context c, 
        HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException, AuthorizeException
    {
        
        String button = UIUtil.getSubmitButton(request, "submit_base");
        
        //direct the request to the relevant set of methods
        if (button.equals("submit_add"))
        {
            showLinkPage(c, request, response);
        } 
        else if (button.equals("submit_view"))
        {
            showListPage(c, request, response);
        }
        else if (button.equals("submit_base"))
        {
            showMainPage(c, request, response);
        } 
        else if (button.equals("submit_link"))
        {
            // do form validation before anything else
            if (validateAddForm(c, request, response))
            {
                addSupervisionOrder(c, request, response);
                showMainPage(c, request, response);
            }
        }
        else if (button.equals("submit_remove"))
        {
            showConfirmRemovePage(c, request, response);
        }
        else if (button.equals("submit_doremove"))
        {
            removeSupervisionOrder(c, request, response);
            showMainPage(c, request, response);
        }
        else if (button.equals("submit_clean"))
        {
            cleanSupervisorDatabase(c, request, response);
            showMainPage(c, request, response);
        }
    }
    
    //**********************************************************************
    //****************** Methods for Page display **************************
    //**********************************************************************
    
    /**
     * Confirms the removal of a supervision order
     *
     * @param context the context of the request
     * @param request the servlet request
     * @param response the servlet response
     */
    private void showConfirmRemovePage(Context context, 
        HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException, AuthorizeException
    {
        // get the values from the request
        int wsItemID = UIUtil.getIntParameter(request,"siID");
        int groupID = UIUtil.getIntParameter(request,"gID");
        
        // get the workspace item and the group from the request values
        WorkspaceItem wsItem = WorkspaceItem.find(context, wsItemID);
        Group group = Group.find(context, groupID);
        
        // set the attributes for the JSP
        request.setAttribute("wsItem",wsItem);
        request.setAttribute("group", group);
        
        JSPManager.showJSP(request, response, "/dspace-admin/supervise-confirm-remove.jsp" );
        
    }
    
    /**
     * Displays the form to link groups to workspace items
     *
     * @param context the context of the request
     * @param request the servlet request
     * @param response the servlet response
     */
    private void showLinkPage(Context context, 
        HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException, AuthorizeException
    {
        // get all the groups
        Group[] groups = Group.findAll(context,1);
        
        // get all the workspace items
        WorkspaceItem[] wsItems = WorkspaceItem.findAll(context);
        
        // set the attributes for the JSP
        request.setAttribute("groups",groups);
        request.setAttribute("wsItems",wsItems);
        
        JSPManager.showJSP(request, response, "/dspace-admin/supervise-link.jsp" );
        
    }
    
    /**
     * Displays the options you have in the supervisor admin area
     *
     * @param context the context of the request
     * @param request the servlet request
     * @param response the servlet response
     */
    private void showMainPage(Context context, 
        HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException, AuthorizeException
    {
        JSPManager.showJSP(request, response, "/dspace-admin/supervise-main.jsp");
    }
    
    /**
     * Displays the list of current settings for supervisors
     *
     * @param context the context of the request
     * @param request the servlet request
     * @param response the servlet response
     */
    private void showListPage(Context context, 
        HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException, AuthorizeException
    {
        // get all the supervised items
        SupervisedItem[] si = SupervisedItem.getAll(context);
        
        // set the attributes for the JSP
        request.setAttribute("supervised",si);
        
        JSPManager.showJSP(request, response, "/dspace-admin/supervise-list.jsp" );
    }
    
    //**********************************************************************
    //*************** Methods for data manipulation ************************
    //**********************************************************************
    
    /**
     * Adds supervisory settings to the database
     *
     * @param context the context of the request
     * @param request the servlet request
     * @param response the servlet response
     */
    void addSupervisionOrder(Context context, 
        HttpServletRequest request, HttpServletResponse response)
    throws SQLException, AuthorizeException, ServletException, IOException
    {
        
        // get the values from the request
        int groupID = UIUtil.getIntParameter(request,"TargetGroup");
        int wsItemID = UIUtil.getIntParameter(request,"TargetWSItem");
        int policyType = UIUtil.getIntParameter(request, "PolicyType");
        
        Supervisor.add(context, groupID, wsItemID, policyType);
        
        log.info(LogManager.getHeader(context, 
            "Supervision Order Set", 
            "workspace_item_id="+wsItemID+",eperson_group_id="+groupID));
        
        context.complete();
    }
    
    /**
     * Maintains integrity of the supervisory database.  Should be more closely
     * integrated into the workspace code, perhaps
     *
     * @param context the context of the request
     * @param request the servlet request
     * @param response the servlet response
     */
    private void cleanSupervisorDatabase(Context context, 
        HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException, AuthorizeException
    {
        // ditch any supervision orders that are no longer relevant
        Supervisor.removeRedundant(context);
         
        context.complete();
    }
    
    
    /**
     * Remove the supervisory group and its policies from the database
     *
     * @param context the context of the request
     * @param request the servlet request
     * @param response the servlet response
     */
    void removeSupervisionOrder(Context context, 
        HttpServletRequest request, HttpServletResponse response)
        throws SQLException, AuthorizeException, ServletException, IOException
    {
        
        // get the values from the request
        int wsItemID = UIUtil.getIntParameter(request,"siID");
        int groupID = UIUtil.getIntParameter(request,"gID");
        
        Supervisor.remove(context, wsItemID, groupID);
        
        log.info(LogManager.getHeader(context, 
            "Supervision Order Removed", 
            "workspace_item_id="+wsItemID+",eperson_group_id="+groupID));
        
        context.complete();
    }
    
    /**
     * validate the submitted form to ensure that there is not a supervision
     * order for this already.
     *
     * @param context the context of the request
     * @param request the servlet request
     * @param response the servlet response
     */
    private boolean validateAddForm(Context context, 
        HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException, AuthorizeException
    {
        int groupID = UIUtil.getIntParameter(request,"TargetGroup");
        int wsItemID = UIUtil.getIntParameter(request,"TargetWSItem");
        
        boolean invalid = Supervisor.isOrder(context, wsItemID, groupID);
        
        if (invalid)
        {
            JSPManager.showJSP(request, response, 
                "/dspace-admin/supervise-duplicate.jsp");
            return false;
        } 
        else
        {
            return true;
        }
    }
   
}
