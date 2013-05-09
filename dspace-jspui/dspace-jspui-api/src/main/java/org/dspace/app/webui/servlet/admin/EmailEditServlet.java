/*
 * EmailEditServlet.java
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
public class EmailEditServlet extends DSpaceServlet
{
    //private static Logger log = Logger.getLogger(NewsEditServlet.class);
	
	private String configFilePath = (String) ConfigurationManager.getProperty("dspace.dir") + File.separator + "config" + File.separator + "dspace.cfg";
	
	
    protected void doDSGet(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
    	String filePath = (String) ConfigurationManager.getProperty("dspace.dir", "/dspace")
			+ "/config/emails";
		String[] emails = FileUtil.list(filePath);
		request.setAttribute("emailName", emails);
    	
        //always go first to news-main.jsp
        JSPManager.showJSP(request, response, "/dspace-admin/email-edit.jsp");
    }

    protected void doDSPost(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        String filePath = (String) ConfigurationManager.getProperty("dspace.dir", "/dspace")
			+ "/config/emails";
		String[] emails = FileUtil.list(filePath);
		request.setAttribute("emailName", emails);
		
		String name = (String) request.getParameter("name");
		String text = (String) request.getParameter("text");
		String submit_action = request.getParameter("submit_action");
			if (submit_action == null) submit_action = "";
		
		if (submit_action.equals("load")
			&& name != null
			&& name.equals("") == false)
		{
			String file = filePath + "/" + name;
			text = FileUtil.read(file);
			
			if (text != null)
			{
				request.setAttribute("name", name);
				request.setAttribute("text", text);
			}
		}
		else if (submit_action.equals("save")
			&& name != null
			&& name.equals("") == false
			&& text != null
			&& text.trim().equals("") == false)
		{
			String file = filePath + "/" + name;
			FileUtil.write(text, file, false);
			
			request.setAttribute("name", name);
			request.setAttribute("text", text);
			
			boolean saved = true;
			request.setAttribute("saved", saved);
		}
        
        //doDSGet(c, request, response);
        JSPManager.showJSP(request, response, "/dspace-admin/email-edit.jsp");
    }
}
