/*
 * VersionUtil.java
 */
package org.dspace.app.webui.util;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Date;
import java.util.ArrayList;
import java.util.Arrays;
import org.apache.log4j.Logger;
import javax.servlet.ServletException;

import org.dspace.app.util.FileUtil;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.core.ConfigurationManager;

public class VersionUtil
{
    /** log4j category */
    public static Logger log = Logger.getLogger(VersionUtil.class);
    
    private static int maxVersions = ConfigurationManager.getIntProperty("version-util.max-versions", 5);
    
    public static void create(String sourceFile) throws ServletException, IOException
    {
    	create(sourceFile, "");
    }
    
    public static void create(String sourceFile, String footer) throws ServletException, IOException
    {
    	//String targetFile = sourceFile + "." + UIUtil.getDateID();
    	String targetFile = addID(sourceFile, footer, UIUtil.getDateID());
    	FileUtil.copy(sourceFile, targetFile);
    	
    	long[] exceeds = getExceed(sourceFile, footer);
    	deleteExceed(sourceFile, footer, exceeds);
    }
    
    public static boolean retrace(String sourceFile, int steps) throws ServletException, IOException
    {
    	return retrace(sourceFile, "", steps);
    }
    
    public static boolean retrace(String sourceFile, String footer, int steps) throws ServletException, IOException
    {
    	if (steps >= maxVersions)
    		return false;
    	
    	long[] ids = list(sourceFile, footer);
    	if (steps >= ids.length)
    		return false;
    	
    	long retraceID = ids[(ids.length - steps)];
    	String sf = addID(sourceFile, footer, retraceID);
    	String tf = sourceFile;
    	FileUtil.copy(sf, tf);
    	
    	return true;
    }
    
    public static long[] list(String sourceFile, String footer) throws ServletException, IOException
    {
    	if (sourceFile.lastIndexOf(File.separator + "") == -1)
    		return new long[0];
    	
    	ArrayList<String> versions = new ArrayList<String>();
    	String dir = sourceFile.substring(0, sourceFile.lastIndexOf(File.separator));
    	String[] files = FileUtil.list(dir);
    	
    	String header = sourceFile;
    	if (footer.equals("") == false
    		&& sourceFile.endsWith(footer))
    		header = sourceFile.substring(0, sourceFile.length() - footer.length());
    	
    	for (int i = 0; i < files.length; i++)
    	{
    		String f = dir + File.separator + files[i];
    		if (f.startsWith(header)
    			&& f.endsWith(footer))
    			versions.add(f);
    	}
    	
    	ArrayList<Long> ids = new ArrayList<Long>();
		for (int i = 0; i < versions.size(); i++)
		{
			String f = versions.get(i);
			if (f.lastIndexOf(".") == -1)
				continue;
			
			/*
			String idString = f.substring(f.lastIndexOf(".")+1, f.length());
			try
			{
				int id = Integer.parseInt(idString);
				ids.add(id);
			}
			catch (Exception e) { }
			*/
			long id = getID(f, footer);
			
			if (id != -1)
				ids.add(id);
		}
		
		//int[] versionIDs = (int[]) ids.toArray();
		long[] versionIDs = new long[ids.size()];
		for (int i = 0; i < ids.size(); i++)
			versionIDs[i] = ids.get(i);
    	Arrays.sort(versionIDs);
    	return versionIDs;
    }
    
    public static long[] getExceed(String sourceFile, String footer) throws ServletException, IOException
    {
    	long[] ids = list(sourceFile, footer);
    	
    	if (ids.length <= maxVersions)
    		return new long[0];
    	
    	long[] exceeds = new long[(ids.length - maxVersions)];
    	for (int i = 0; i < exceeds.length; i++)
    	{
    		exceeds[i] = ids[i];
    	}
    	
    	return exceeds;
    }
    
    public static void deleteExceed(String sourceFile, String footer, long[] exceedVersions) throws ServletException, IOException
    {
    	for (int i = 0 ; i < exceedVersions.length; i++)
    	{
    		//String f = sourceFile + "." + exceedVersions[i];
    		String f = addID(sourceFile, footer, exceedVersions[i]);
    		FileUtil.delete(f);
    	}
    }
    
    public static String addID(String file, String footer, long id)
    {
    	if (footer.equals("") || file.endsWith(footer) == false)
    		return file + "." + id;
    	
    	String header = file.substring(0, file.length() - footer.length());
    	
    	return header + "." + id + footer;
    }
    
    public static long getID(String file, String footer)
    {
    	if (footer.equals("") || file.endsWith(footer) == true)
    		file = file.substring(0, file.length() - footer.length());
    	
    	if (file.lastIndexOf(".") == -1)
    		return -1;
    	
    	String idString = file.substring(file.lastIndexOf(".") + 1, file.length());
    	
    	long id = -1;
    	try
    	{
    		id = Long.parseLong(idString);
    	}
    	catch (Exception e) {}
    	
    	return id;
    }
}
