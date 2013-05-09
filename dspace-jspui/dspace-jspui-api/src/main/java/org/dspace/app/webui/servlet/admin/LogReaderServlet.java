/*
 * LogReaderServlet.java
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
import org.dspace.app.webui.util.UIUtil;
import org.dspace.app.util.EscapeUnescape;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import java.util.ArrayList;
import java.io.File;

/**
 * Servlet for editing the front page news
 * 
 * @author gcarpent
 */
public class LogReaderServlet extends DSpaceServlet
{
    //private static Logger log = Logger.getLogger(NewsEditServlet.class);
	
	private String logDirPath = (String) ConfigurationManager.getProperty("log.dir");
	private String[] allFiles = new String[0];
	private String[] logFiles = new String[0];
	private int offset = 0;
	private long pagelen = ConfigurationManager.getLongProperty("log-reader.length", 25000);
	
    protected void doDSGet(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
    	String needle = "dspace.log";
    	
    	String targetLog = (String) request.getParameter("log");
    	if (targetLog == null)
    		targetLog = needle;
    	
    	int page = UIUtil.getIntParameter(request, "page", -1);
    	
    	if (logFiles.length == 0)
    	{
    		allFiles = FileUtil.list(logDirPath);
    		ArrayList<String> matchLog = new ArrayList<String>();
    		for (int i = 0; i < allFiles.length; i++)
    		{
    			if (allFiles[i].startsWith(needle))
    			{
    				matchLog.add(allFiles[i]);
    			}
    		}	
    		
    		logFiles = new String[matchLog.size()];
    		for (int i = 0; i < matchLog.size(); i++)
    		{
    			logFiles[i] = matchLog.get(i);
    		}
    	}
    	/*
    	File logFile = new File(logDirPath
    		+ File.separator
    		+ targetLog);
    	
    	long logLen = logFile.length();
    	*/
    	String logFilePath = logDirPath
    		+ File.separator
    		+ targetLog;
    	long logLen = FileUtil.readLength(logFilePath);
    	
    	int pages = (int) (Math.ceil((double) (logLen / pagelen)));
    	String logText = "";
    	if (page == -1)
    	{
    		page = pages;
    	}
    	
    	long start = (page - 1)*pagelen;
    	if (start < 0)
    		start = 0;
    	long end = (page)*pagelen; 
    	logText = FileUtil.read(logFilePath
	    		, start
	    		, end);
	    
	    //修正前後
	    if (logText.length() > 1)
	    {
		    while (logText.substring(0, 1).equals("\n") == false && start > -1)
		    {
		    	start--;
		    	String a = FileUtil.read(logFilePath
		    		, start, (start + 1) );
		    	logText = a + logText;
		    }
		    
		    //修正前後
		    while (logText.substring(logText.length()-1, logText.length()).equals("\n") == false && end > logText.length())
		    {
		    	end++;
		    	String a = FileUtil.read(logFilePath
		    		, (end-1), end );
		    	logText = logText + a;
		    }
		}
    	
    	if (logText == null)
    		logText = "";
    	
    	request.setAttribute("logFiles", logFiles);
    	request.setAttribute("logName", targetLog);
    	request.setAttribute("logText", logText);
    	request.setAttribute("pages", pages);
    	request.setAttribute("page", page);
    	
        //always go first to log-reader.jsp
        JSPManager.showJSP(request, response, "/dspace-admin/log-reader.jsp");
    }

    protected void doDSPost(Context c, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        doDSGet(c, request, response);
    }
}
