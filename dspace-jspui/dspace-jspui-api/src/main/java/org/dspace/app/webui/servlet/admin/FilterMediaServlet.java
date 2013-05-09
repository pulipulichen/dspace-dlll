/*
 * FilterMediaServlet.java
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
import org.dspace.app.util.FileUtil;
import org.dspace.app.util.EscapeUnescape;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Constants;
import org.dspace.core.Context;

import java.util.Date;
import java.util.ArrayList;
import org.dspace.app.util.FilterMediaThread;

public class FilterMediaServlet extends DSpaceServlet
{
    private static Logger log = Logger.getLogger(FilterMediaServlet.class);
	
	
    protected void doDSGet(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
    	if (request.getParameter("do_queue_manager") != null)
    	{
    		JSPManager.showJSP(request, response, "/dspace-admin/filter-media-queue.jsp");
    	}
    	else if (request.getParameter("log") != null)
    	{
    		String logID = request.getParameter("log");
    		String parameter = "";
    		String command = "debug mode ("+logID+")";
    		
    		request.setAttribute("logID", logID);
	    	request.setAttribute("parameter", parameter);
	    	request.setAttribute("command", command);
	    	
    		JSPManager.showJSP(request, response, "/dspace-admin/filter-media-display.jsp");
    	}
    	else
    	{
	        //always go first to filter-media-form.jsp
	        JSPManager.showJSP(request, response, "/dspace-admin/filter-media-form.jsp");
	    }
    }

    protected void doDSPost(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
    	
    	if (request.getParameter("do_filter_media") == null)
    	{
    		if (request.getParameter("do_queue_manager") == null)
    			JSPManager.showJSP(request, response, "/dspace-admin/filter-media-form.jsp");
    		else
    		{
    			if (request.getParameter("edit_queue") != null)
    			{
	    			String queue = request.getParameter("queue");
	    			if (queue != null)
	    			{
		    			String queueFilePath = ConfigurationManager.getProperty("log.dir","/dspace/log") + "/filter-media-queue.log";
		    			FileUtil.delete(queueFilePath);
		    			FileUtil.write(queue, queueFilePath, true);
		    		}
    			}
    			JSPManager.showJSP(request, response, "/dspace-admin/filter-media-queue.jsp");
    		}
    		return;
    	}
    	
    	//先接收參數吧
    	
    	String hasIdentifierValue = request.getParameter("identifier");
    	boolean hasIdentifier = false;
    	String identifier = request.getParameter("identifier_value");
    	if (hasIdentifierValue != null
    		&& hasIdentifierValue.equals("true") == true)
    	{
    		hasIdentifier = true;
    	}
    	if (identifier.equals("") == true)
    	{
    		identifier = null;
    	}
		boolean isForce = false;
		if (request.getParameter("force") != null)
		{
			if (request.getParameter("force").equals("true"))
				isForce = true;
			else
				isForce = false;
		}
		boolean noIndex = true;
		if (request.getParameter("noIndex") != null)
		{
			noIndex = ((String) request.getParameter("noIndex")).equals("true");
		}
		String plugin = request.getParameter("plugin_value");
    	if (plugin.equals("") == true)
    	{
    		plugin = null;
    	}
		int max2Process = 0;
		try
		{
			String hasMax2ProcessValue = request.getParameter("max2Process");
			if (hasMax2ProcessValue != null
				&& hasMax2ProcessValue.equals("true"))
			{
				if (request.getParameter("max2Process_value") != null)
					max2Process = Integer.parseInt(request.getParameter("max2Process_value"));
			}
		}
		catch (Exception e) {}
    	boolean alone = false;
		if (request.getParameter("alone") != null)
		{
			alone = ((String) request.getParameter("alone")).equals("true");
		}
    	
    	//設定logID
    	String logID = request.getParameter("log");
    	boolean hasLog = true;
    	if (logID == null)
    	{
	    	Date d = new Date();
	    	logID = Integer.toString(d.getYear() + 1900) + "-"
	    		+ Integer.toString(d.getMonth() + 1) + "-"
	    		+ Integer.toString(d.getDate()) + "_"
	    		+ Integer.toString(d.getHours()) + "-"
	    		+ Integer.toString(d.getMinutes()) + "-"
	    		+ Integer.toString(d.getSeconds());
	    	hasLog = false;
    	}
    	
    	//設定參數
    	String command = "filter-media";
    	
    	ArrayList<String> argvList = new ArrayList<String>();
    	ArrayList<String> paraList = new ArrayList<String>();
    	
    	argvList.add("-v");
    	command = command + " -v";
    	argvList.add("-l");
    	argvList.add(logID);
    	command = command + " -l "+logID;
    	
    	if (hasIdentifier == true
    		&& identifier != null)
    	{
    		argvList.add("-i");
    		argvList.add(identifier);
    		
    		command = command + " -i " + identifier;
    		paraList.add("i="+identifier);
    	}
    	
    	if (isForce == true)
    	{
    		argvList.add("-f");
    		command = command + " -f";
    		paraList.add("f=true");
    	}
    	else
    	{
    		paraList.add("f=false");
    	}
    	if (noIndex == true)
    	{
    		argvList.add("-n");
    		command = command + " -n";
    		paraList.add("n=true");
    	}
    	else
    	{
    		paraList.add("n=false");
    	}
    	if (plugin != null)
    	{
    		argvList.add("-p");
    		argvList.add(plugin);
    		command = command + " -p "+plugin;
    		paraList.add("p="+plugin);
    	}
    	if (max2Process > 0)
    	{
    		argvList.add("-m");
    		argvList.add(max2Process + "");
    		command = command + " -m " + max2Process;
    		paraList.add("m="+max2Process);
    	}
    	if (alone == true)
    	{
    		argvList.add("-a");
    		command = command + " -a";
    		paraList.add("a=true");
    	}
    	else
    	{
    		paraList.add("a=false");
    	}
    	
    	//結合ArrayList
    	String[] argv = new String[argvList.size()];
    	for (int i = 0; i < argv.length ; i++)
    		argv[i] = argvList.get(i);
    	String parameter = "";
    	for (int i = 0; i < paraList.size();i++)
    	{
    		if (parameter.equals("") == false)
    			parameter = parameter + "&";
    		parameter = parameter + paraList.get(i);
    	}
    	
    	//執行filter-media
    	if (hasLog == false)
    	{
	    	FilterMediaThread t = new FilterMediaThread();
			t.setArgv(argv);
			t.start(); 
    	}
    	
    	//command
    	request.setAttribute("logID", logID);
    	request.setAttribute("parameter", parameter);
    	request.setAttribute("command", command);
    	
    	JSPManager.showJSP(request, response, "/dspace-admin/filter-media-display.jsp");
    }
}
