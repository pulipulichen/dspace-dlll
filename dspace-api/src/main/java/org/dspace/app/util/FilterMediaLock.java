package org.dspace.app.util;

import org.dspace.core.ConfigurationManager;
import org.dspace.app.util.FileUtil;
import java.util.Date;

public class FilterMediaLock
{
	public static void lock(String[] argv) throws Exception
	{
		String m = "";
		for (int i = 0; i < argv.length; i++)
		{
			if (i > 0)
				m = m + " ";
			m = m + argv[i];
		}
		
		lock(m);
	}
	
	public static void lock(String msg) throws Exception
	{
		Date d = new Date();
	    String m = "(" + Integer.toString(d.getYear()+1900) + "-"
	    		+ Integer.toString(d.getMonth() + 1) + "-"
	    		+ Integer.toString(d.getDate()) + " "
	    		+ Integer.toString(d.getHours()) + ":"
	    		+ Integer.toString(d.getMinutes()) + ":"
	    		+ Integer.toString(d.getSeconds()) + ")";
	   	m = m + msg;
	   	
	   	FileUtil.write(m, getLogPath(), false);
	   	System.out.println("[LOCK] " + m + " in " + getLogPath() + "\n");
	}
	
	public static void unlock()
	{
		try
		{
			FileUtil.delete(getLogPath());
			System.out.println("[LOCK] Delete lock: " + getLogPath() + "\n");
		}
		catch (Exception e) {}
	}
	
	public static boolean isLock()
	{
		try
		{
			return FileUtil.exists(getLogPath());
		}
		catch (Exception e) 
		{
			return false;
		}
	}
	
	private static String getLogPath()
	{
		return ConfigurationManager.getProperty("log.dir","/dspace/log") + "/filter-media.lock";
	}
}
