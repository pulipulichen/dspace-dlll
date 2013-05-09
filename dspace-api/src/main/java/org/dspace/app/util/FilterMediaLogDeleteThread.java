package org.dspace.app.util;

import java.lang.Thread;
import org.dspace.app.mediafilter.MediaFilterManager;
import org.apache.log4j.Logger;
import org.dspace.app.util.FileUtil;
import org.dspace.core.ConfigurationManager;

public class FilterMediaLogDeleteThread extends Thread
{
	private static Logger logger = Logger.getLogger(FilterMediaLogDeleteThread.class);
	
	private String log;
	private boolean isInstant = false;
	
	public void run()
	{
		if (isInstant == false)
		{
			try
			{
				Thread.currentThread().sleep(ConfigurationManager.getLongProperty("filter-media.delete-log-delay", 10000));
			}
			catch (Exception e) {}
		}
		
		try
		{
			FileUtil.delete(log);
		}
		catch (Exception e) {
			logger.warn("Delete log file error. LogFilePath: " + log);
			logger.warn("Error message: " + e.getMessage());
		};
	}
	public void setLog(String logIn)
	{
		this.log = logIn;
	}
	
	public void setInstant(boolean flag)
	{
		this.isInstant = flag;
	}
}
