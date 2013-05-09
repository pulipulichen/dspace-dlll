/*
 * InputFormsEditServlet.java
 * 這應該是由UTF8碼組成沒錯吧？
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
public class InputFormsEditServlet extends DSpaceServlet
{
    //private static Logger log = Logger.getLogger(NewsEditServlet.class);
	
	private String inputFormsFilePath = (String) ConfigurationManager.getProperty("dspace.dir") + File.separator + "config" + File.separator + "input-forms.xml";
	
	
    protected void doDSGet(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
	request.setCharacterEncoding("utf-8");
    	String inputFormsXML = FileUtil.read(inputFormsFilePath);
    	//String inputFormsXML = "test";
    	request.setAttribute("inputFormsXML", EscapeUnescape.escape(inputFormsXML));
    	//request = setDefaultLanguages(request);
    	
        //always go first to news-main.jsp
        JSPManager.showJSP(request, response, "/dspace-admin/input-forms-edit.jsp");
    }

    protected void doDSPost(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
	request.setCharacterEncoding("utf-8");
        //Get submit button
        String button = (String) request.getParameter("submit_action");
        
        String inputFormsXML = (String) request.getParameter("inputFormsXML");
        
        if (button.equals("save"))
        {
        	FileUtil.copy(inputFormsFilePath, inputFormsFilePath + ".bak");
        	FileUtil.write(inputFormsXML, inputFormsFilePath, false);
        	request.setAttribute("message", "success");
        }
        
        //doDSGet(c, request, response);
        request.setAttribute("inputFormsXML", EscapeUnescape.escape(inputFormsXML));
        JSPManager.showJSP(request, response, "/dspace-admin/input-forms-edit.jsp");
    }
}
