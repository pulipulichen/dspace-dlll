/*
 * ConfigEditServlet.java
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
import org.dspace.app.util.FileUtil;
import org.dspace.app.util.EscapeUnescape;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;

import java.io.File;

/**
 * Servlet for editing the front page news
 * 
 * @author gcarpent
 */
public class ConfigEditServlet extends DSpaceServlet
{
    //private static Logger log = Logger.getLogger(NewsEditServlet.class);
	
	private String configFilePath = (String) ConfigurationManager.getProperty("dspace.dir") + File.separator + "config" + File.separator + "dspace.cfg";
	
	
    protected void doDSGet(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
    	String config = FileUtil.read(configFilePath);
    	request.setAttribute("config", EscapeUnescape.escape(config));
    	
        //always go first to news-main.jsp
        JSPManager.showJSP(request, response, "/dspace-admin/config-edit.jsp");
    }

    protected void doDSPost(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        //Get submit button
        String button = (String) request.getParameter("submit_action");
        
        String config = (String) request.getParameter("config");
        
        if (button.equals("save"))
        {
        	FileUtil.copy(configFilePath, configFilePath + ".bak");
        	FileUtil.write(config, configFilePath, false);
        	request.setAttribute("message", "success");
        }
        
        //doDSGet(c, request, response);
        request.setAttribute("config", EscapeUnescape.escape(config));
        JSPManager.showJSP(request, response, "/dspace-admin/config-edit.jsp");
    }
}
