/*
 * MessagesEditServlet.java
 */
package org.dspace.app.webui.servlet.admin;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.jstl.fmt.LocaleSupport;

import org.apache.log4j.Logger;
import org.dspace.app.webui.servlet.DSpaceServlet;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.app.webui.util.VersionUtil;
import org.dspace.app.util.FileUtil;
import org.dspace.app.util.EscapeUnescape;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Constants;
import org.dspace.core.Context;

import java.lang.ArrayIndexOutOfBoundsException;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.FileReader;
import java.io.BufferedReader;
import java.util.ArrayList;

/**
 * Servlet for editing the front page news
 * 
 * @author gcarpent
 */
public class MessagesEditServlet extends DSpaceServlet
{
    private static Logger log = Logger.getLogger(NewsEditServlet.class);
	
	private String tomcatDir = (String) ConfigurationManager.getProperty("tomcat.dir");
	private String defaultLanguage = (String) ConfigurationManager.getProperty("default.locale", "en");
	
	
    protected void doDSGet(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
    	request = setDefaultLanguages(request);
    	
        //always go first to news-main.jsp
        JSPManager.showJSP(request, response, "/dspace-admin/messages-main.jsp");
    }

    protected void doDSPost(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        //Get submit button
        String button = request.getParameter("submit_action");

        String messages = "";
		
        //Are we editing the top news or the sidebar news?
        String position = request.getParameter("position");
        
        if (button.equals("submit_edit"))
        {
        	String filepath = tomcatDir + "/WEB-INF/classes/" + position;
		
			messages = FileUtil.read(filepath);

            //pass the position back to the JSP
            request.setAttribute("position", position);

            //pass the existing messages back to the JSP
            request.setAttribute("messages", EscapeUnescape.escape(messages));
        	
            //show news edit page
            JSPManager
                    .showJSP(request, response, "/dspace-admin/messages-edit.jsp");
        }
        else if (button.equals("submit_save"))
        {
            //get text string from form
            messages = (String) request.getParameter("messages");
            //字串先過濾
            	//messages = messages.replaceAll("&amp;", "&");
            	//messages = messages.replaceAll("&amp;amp;amp;amp;amp;nbsp;", "&nbsp;");
            	//messages = messages.replaceAll("&amp;amp;amp;", "&amp;");
            	

            //write the string out to file
            String targetPath = tomcatDir + "/WEB-INF/classes/" + position;
            
			FileUtil.writeForce(messages, targetPath);
			VersionUtil.create(targetPath, ".properties");
			
			String dspaceSourceDir = (String) ConfigurationManager.getProperty("dspace.source.dir");
            //\\Dspace-course\dspace-1.5.0-src-release\dspace\modules\jspui\src\main\resources
            String targetPath2 = dspaceSourceDir + "/dspace/modules/jspui/src/main/resources/" + position;
			
			FileUtil.writeForce(messages, targetPath2);
			
			request.setAttribute("submit_action", "saved");
			request.setAttribute("position", position);
			
			request = setDefaultLanguages(request);

            JSPManager
                    .showJSP(request, response, "/dspace-admin/messages-main.jsp");
        }
        else if (button.equals("submit_create"))
        {
        	String source = (String) request.getParameter("source");
			String filepath = tomcatDir + "/WEB-INF/classes/" + source;
			messages = FileUtil.read(filepath);

            //pass the position back to the JSP
            position = "Messages_" + position + ".properties";
            request.setAttribute("position", position);

            //pass the existing messages back to the JSP
            request.setAttribute("messages", EscapeUnescape.escape(messages));
        	
            //show news edit page
            JSPManager
                    .showJSP(request, response, "/dspace-admin/messages-edit.jsp");
        }
        else if (button.equals("submit_integrate"))
        {
        	String source = (String) request.getParameter("source");
        	String target = (String) request.getParameter("target");
			
			if (integrate(source, target) == true)
			{
				request.setAttribute("submit_action", "integrated-success");
				request.setAttribute("position", "");
				
				request = setDefaultLanguages(request);
				
				JSPManager
	                    .showJSP(request, response, "/dspace-admin/messages-main.jsp");
        	}
        	else
        	{
        		request.setAttribute("submit_action", "integrated-fail");
				request.setAttribute("position", "");
				
				request = setDefaultLanguages(request);
				
				JSPManager
	                    .showJSP(request, response, "/dspace-admin/messages-main.jsp");
        	}
        }
        else
        {
            //the user hit cancel, so return to the main news edit page
            request = setDefaultLanguages(request);
            
            request.setAttribute("submit_action", "cancel_edit");
            
            JSPManager
                    .showJSP(request, response, "/dspace-admin/messages-main.jsp");
        }

        c.complete();
    }
    
    private HttpServletRequest setDefaultLanguages(HttpServletRequest request) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
    	
		String[] list = FileUtil.listFiles(tomcatDir + "/WEB-INF/classes/");

		if (list == null)
		{
			list = new String[1];
			list[0] = "Messages.properties";
		}
		
		String[] messagesProperties = new String[(list.length)];
		String header = "Messages";
		String footer = ".properties";
		
		String defaultLanguageFilename = header + footer;
		if (!defaultLanguage.equals("en"))
			defaultLanguageFilename = header + "_" + defaultLanguage + footer;
		for (int i = 0; i < list.length; i ++)
		{
			if (list[i].length() > header.length()
				&& list[i].substring(0, header.length()).equals(header))
				messagesProperties[i] = list[i];
			else
				messagesProperties[i] = null;
		}
		
		request.setAttribute("defaultLanguage", defaultLanguage);
		request.setAttribute("defaultLanguageFilename", defaultLanguageFilename);
		request.setAttribute("messagesProperties", messagesProperties);
		
		return request;
    }
    
    private boolean integrate(String source, String target) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
    	//先取得source跟target的key與value
    	String path = tomcatDir + "/WEB-INF/classes/";
    	
    	String sourceText = FileUtil.read(path + source);
    	ArrayList<String> sourceKey = new ArrayList<String>();
    	ArrayList<String> sourceValue = new ArrayList<String>();
    	if (sourceText != null)
    	{
    		String[] lines = sourceText.split("\r\n");
    		for (int i = 0; i < lines.length; i++)
    		{
    			if (lines[i].trim().equals("")
    				|| lines[i].indexOf("=") == -1
    				|| lines[i].substring(0, 1).equals("#"))
    				continue;
    			
    			String[] pair = lines[i].split("=", 2);
    			String key = pair[0].trim();
    			String value = pair[1].trim();
    			
    			sourceKey.add(key);
    			sourceValue.add(value);
    		}
    	}
    	
    	ArrayList<String> targetKey = new ArrayList<String>();
    	//ArrayList<String> targetValue = new ArrayList<String>();
    	String targetText = FileUtil.read(path + target);
    	if (targetText != null)
    	{
    		String[] lines = targetText.split("\r\n");
    		for (int i = 0; i < lines.length; i++)
    		{
    			if (lines[i].trim().equals("")
    				|| lines[i].indexOf("=") == -1
    				|| lines[i].substring(0, 1).equals("#"))
    				continue;
    			
    			//String[] pair = lines[i].split("=", 2);
    			//String key = pair[0].trim();
    			//String value = pair[0].trim();
    			
    			String key = lines[i].substring(0, lines[i].indexOf("=")).trim();
    			targetKey.add(key);
    			//targetValue.add(value);
    		}
    	}
    	
    	//用source的key去找尋target是否有這個key
    	String msg = "\r\n";
    	for (int i = 0; i < sourceKey.size(); i++)
    	{
    		String key = sourceKey.get(i);
    		String value = sourceValue.get(i);
    		if (targetKey.indexOf(key) == -1)
    		{
    			msg = msg + key + " = " + value + "\r\n";
    		}
    	}
    	
    	//加入在target的最後
    	FileUtil.write(msg, path + target, true);
    	return true;
    }
}
