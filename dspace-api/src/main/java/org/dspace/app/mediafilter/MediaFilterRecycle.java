package org.dspace.app.mediafilter;

import org.dspace.app.util.FileUtil;
import org.dspace.core.ConfigurationManager;
import java.io.FileNotFoundException;
import org.dspace.app.util.FileDeleteDelayThread;
import org.dspace.app.mediafilter.MediaFilterUtils;

public class MediaFilterRecycle
{
	static public long deleteTime = ConfigurationManager.getLongProperty("filter.recycle.delete-time", 3600000);
	static public String filenameStamp = ConfigurationManager.getProperty("filter.recycle.filename-stamp", ".recycle");
	
	static public String rename(String fileIn) 
	{
		return fileIn + filenameStamp;
	}
	
	static public void push(String filePath)
	{
		try
		{
			if (FileUtil.exists(filePath) == false)
				return;
			
			String recycleFilePath = rename(filePath);
			
			FileUtil.rename(filePath, recycleFilePath);
			
			FileDeleteDelayThread.delete(recycleFilePath, deleteTime);
		}
		catch (Exception e) { }
	}
	
	static public boolean get(String filePath)
	{
		String recycleFilePath = rename(filePath);
		
		try
		{
			if (FileUtil.exists(recycleFilePath) == true)
			{
				System.out.println("[RECYCLE] Get recycle file:" + filePath);
				FileUtil.rename(recycleFilePath, filePath);
				return true;
			}
			else if (FileUtil.exists(filePath) == true)
			{
				System.out.println("[RECYCLE] Get recycle file:" + filePath);
				return true;
			}
			else
			{
				System.out.println("[RECYCLE] Not found recycle file:" + filePath);
				return false;
			}
		}
		catch (Exception e) {
			System.out.println("[RECYCLE] Exception occured:" + filePath);
			return false;
		}
	}
	
	static public boolean exists(String filePath)
	{
		String recycleFilePath = rename(filePath);
		
		try
		{
			
    	
    		System.out.print("[RECYCLE] " + recycleFilePath + " exists? ");
			if (FileUtil.exists(recycleFilePath) == true)
			{
				System.out.println("yes");
				return true;
			}
			else
			{
				System.out.println("no");
				return false;
			}
		}
		catch (Exception e) {
			return false;
		}
	}
	
	static public void clean() throws FileNotFoundException
	{
		String dir = getTempDir();
		
		String[] list = new String[0];
		list = FileUtil.listFiles(dir);
		
		System.out.println("[RECYCLE] There are " + list.length + " file(s) in " + dir);
		for (int i = 0; i < list.length; i++)
		{
			String f = list[i];
			if (f.length() > filenameStamp.length()
				&& f.substring(f.length()-filenameStamp.length(), f.length()).equals(filenameStamp))
			{
				try
				{
					System.out.println("[RECYCLE] Delete " + dir + f);
					FileUtil.delete(dir + f);
				}
				catch (Exception e) { }
			}
		}
	}
	
	
	static private String getTempDir()
	{
		String d = "";
		try
		{
			d = MediaFilterUtils.getTempDir();
		}
		catch(Exception e) 
		{
			d = ConfigurationManager.getProperty("filter.tempfile.config", "/dpsace/tmp/");
		}
		return d;
	}
	
}