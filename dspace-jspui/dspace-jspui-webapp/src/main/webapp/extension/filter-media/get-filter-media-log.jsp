<%@ page contentType="application/x-javascript; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.storage.rdbms.SQLQuery" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.lang.Thread" %>
<%@ page import="org.dspace.app.util.FileUtil" %>
<%@ page import="org.dspace.app.util.EscapeUnescape" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.app.mediafilter.MediaFilterManager" %>
<%
	String logID = request.getParameter("logID");
	String status = "log";
	String logFilePath = null;
	boolean isQueue = false;
	if (logID != null)
	{
		logFilePath = ConfigurationManager.getProperty("log.dir","/dspace/log")
	        		+ "/filter-media-log-"
	        		+ logID
	        		+ ".log";
	}
	else
		status = "lost_parameter";
	
	String logContent = null;
	int logLines = 0;
	
	if (logFilePath != null)
	{
		try
		{
			logContent = FileUtil.read(logFilePath);
			
			//計算行數，並且重新整合
			String[] lines = logContent.trim().split("\r\n");
			logLines = lines.length;
			
			//取得開頭
			int start = 0;
			String startLine = request.getParameter("start");
			try
			{
				if (startLine != null)
					start = Integer.parseInt(startLine);
				if (start > 0)
					start--;
			}
			catch (Exception e) { }
			
			//重新整合
			if (start != 0)
			{
				logContent = "";
				for (int i = start; i < lines.length; i++)
				{
					if (i > 0)
						logContent = logContent + "\r\n";
					logContent = logContent + lines[i];
				}
			}
			
			//脫逸斷行
			if (logContent != null)
			{
				//取得最後一行
				lines = logContent.trim().split("\r\n");
				String needle = "[QUEUE]";
				if (lines.length > 0)
				{
					String lastLine = lines[(lines.length-1)].trim();
					if (lastLine.length() >= needle.length()
						&& lastLine.substring(0, needle.length()).equals(needle))
						isQueue = true;
				}
				
				if (isQueue == true)
				{
					int queuePos = MediaFilterManager.findQueue(logID);
					if (queuePos > 0)
					{
						//索取現在的佇列狀況
						logContent = logContent + "\r\n"
							+ "Queue in " + (MediaFilterManager.findQueue(logID) + 1) + "/" + MediaFilterManager.countQueue();
						status = "queue";
					}
					else if (queuePos == 0)
					{
						logContent = logContent + "\r\n"
							+ "Start filter-media...";
					}
					else
					{
						status = "out_of_queue";
					}
				}
				
				logContent = logContent.replaceAll("\r\n", "\\\\n");
				//logContent = logContent.replaceAll("\t", "\\\\t");
				
			}
			
		}
		catch (Exception e)	{ }
	}
	if (logFilePath != null && logContent == null)
		status = "no_file";
	
	//輸出
	String output = "{";
	output = output 
		+ "status: \""+status+"\"";
	if (logContent != null)
	{
		logContent = EscapeUnescape.escape(logContent);
		output = output 
			+ ", content: \""+logContent+"\"";
	}
	output = output + ", lines: "+logLines+"}";
	
	String callback = request.getParameter("callback");
	if (callback != null)
	{
		output = callback+"("+output+");";
	}
	
	out.print(output);
%>