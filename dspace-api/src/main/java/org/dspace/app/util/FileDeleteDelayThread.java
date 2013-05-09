package org.dspace.app.util;

import java.lang.Thread;
import org.dspace.app.util.FileUtil;

public class FileDeleteDelayThread extends Thread
{
	private String filePath;
	private long delay = 60000;
	
	public void run()
	{
		try
		{
			Thread.currentThread().sleep(delay);
		}
		catch (Exception e) {}
		
		try
		{
			FileUtil.delete(this.filePath);
		}
		catch (Exception e) {}
	}
	
	public void setFile(String path)
	{
		this.filePath = path;
	}
	
	public void setDelay(Long d)
	{
		this.delay = d;
	}
	
	public static void delete(String path, long d) 
	{
		FileDeleteDelayThread t = new FileDeleteDelayThread();
		t.setFile(path);
		t.setDelay(d);
		t.start();
	}
	
	public static void delete(String path) 
	{
		FileDeleteDelayThread t = new FileDeleteDelayThread();
		t.setFile(path);
		t.start();
	}
}
