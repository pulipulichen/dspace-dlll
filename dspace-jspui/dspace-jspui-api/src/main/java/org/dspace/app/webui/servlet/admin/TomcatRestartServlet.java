/*
 * TomcatRestartServlet.java
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

import java.io.File;
import java.io.PrintWriter;

import java.lang.Runtime;
import java.lang.Process;
import java.lang.InterruptedException;

/**
 * Servlet for editing the front page news
 * 
 * @author gcarpent
 */
public class TomcatRestartServlet extends DSpaceServlet
{
    //private static Logger log = Logger.getLogger(NewsEditServlet.class);
	
    protected void doDSGet(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
    	String action = (String) request.getParameter("action");
    	
    	if (action == null)
    	{
        	JSPManager.showJSP(request, response, "/dspace-admin/tomcat-restart.jsp");
        }
        else if (action.equals("do"))
        {
        	boolean isLinux = File.separator.equals("/");
			
			String webapps = (String) ConfigurationManager.getProperty("tomcat.dir");
			if (webapps.indexOf("webapps") == -1)
				throw new IOException("tomcat.dir set incorrectly. Please check your [dspace]/config/dspace.cfg ");
			String tomcatDir = webapps.substring(0, webapps.indexOf("webapps") - 1);
			String tomcatBin = tomcatDir + File.separator + "bin" + File.separator;
			String subFileName = ".sh";
			if (isLinux == false)
				subFileName = ".bat";
			
			String tomcatShutdown = tomcatBin + "shutdown" + subFileName;
			String tomcatStartup = tomcatBin + "startup" + subFileName;
			
			try
			{
				Process p = Runtime.getRuntime().exec(tomcatShutdown);
				p.waitFor();
				p = Runtime.getRuntime().exec(tomcatStartup);
				p.waitFor();
				
				String output = "{success: true}";
				String callback = (String) request.getParameter("callback");
				
				if (callback != null)
					output = callback + "("+output+");";
				
	        	PrintWriter out = response.getWriter();
	        	out.print(output);
	        }
	        catch (InterruptedException e)
	        {
	        	throw new IOException("Runtime error: " + e.getMessage());
	        }
        }
        else
        	throw new IOException("Action error.");
    }
}
