/*
 * AdvancedSearchServlet.java
 *
 * Version: $Revision: 1189 $
 *
 * Date: $Date: 2005-04-20 07:23:44 -0700 (Wed, 20 Apr 2005) $
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
package org.dspace.app.webui.servlet;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Community;
import org.dspace.core.Context;
import org.dspace.core.ConfigurationManager;

import java.util.ArrayList;

/**
 * Servlet for constructing the advanced search form
 * 
 * @author gam
 * @version $Revision: 1189 $
 */
public class AdvancedSearchServlet extends DSpaceServlet
{
    /** Logger */
    private static Logger log = Logger.getLogger(SubscribeServlet.class);

    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        // just build a list of top-level communities and pass along to the jsp
        Community[] communities = Community.findAllTop(context);
        
        

        request.setAttribute("communities", communities);
        
        String[] searchIndexes = new String[0];
        
        String indexesString = ConfigurationManager.getProperty("search.advanced.field.options",
        	"ANY, author, title, keyword, abstract, series, sponsor, identifier, language");
        
        if (indexesString != null)
        {
        	String[] indexes = indexesString.split(",");
        	ArrayList<String> list = new ArrayList<String>();
        	for (int i = 0; i < indexes.length; i++)
        	{
        		String index = indexes[i].trim();
        		if (index.equals("") == false)
        			list.add(index);
        	}
        	
        	searchIndexes = new String[list.size()];
        	for (int i = 0; i < searchIndexes.length; i++)
        	{
        		searchIndexes[i] = list.get(i);
        	}
        }
        request.setAttribute("searchIndexes", searchIndexes);

        JSPManager.showJSP(request, response, "/search/advanced.jsp");
    }
}
