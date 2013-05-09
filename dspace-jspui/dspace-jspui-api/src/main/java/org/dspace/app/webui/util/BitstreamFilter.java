/*
 * BitstreamFilter.java
 */
package org.dspace.app.webui.util;
import java.io.IOException;
import java.lang.InterruptedException;
import org.dspace.core.ConfigurationManager;
import java.lang.Runtime;
import java.lang.Process;

public class BitstreamFilter 
{
	private BitstreamFilter()
	{
	}
	
	static public void filterByHandle(String handle) throws IOException,InterruptedException
	{
		String dispaceDir = ConfigurationManager.getProperty("dspace.dir");
		String cmd = dispaceDir + "/bin/filter-media -n -i "+handle;
		Process p = Runtime.getRuntime().exec(cmd);
		p.waitFor();
		
		return;
	}
	
	static public void filterByHandleWithPath(String handle, String filterPath) throws IOException,InterruptedException
	{
		String cmd = filterPath+" -n -i "+handle;
		Process p = Runtime.getRuntime().exec(cmd);
		p.waitFor();
		
		return;
	}
}