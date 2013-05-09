/*
 * VNCServerServlet.java
 */
package org.dspace.app.webui.servlet.admin;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//import org.apache.log4j.Logger;
import org.dspace.app.webui.servlet.DSpaceServlet;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;

/**
 * Servlet for editing the front page news
 * 
 * @author gcarpent
 */
public class VNCServerServlet extends DSpaceServlet
{
    //private static Logger log = Logger.getLogger(NewsEditServlet.class);
	
    protected void doDSGet(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
    	JSPManager.showJSP(request, response, "/dspace-admin/vnc-server.jsp");
    }
}
