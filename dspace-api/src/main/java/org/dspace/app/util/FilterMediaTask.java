package org.dspace.app.util;

import org.dspace.content.Bitstream;
import java.util.Timer;
import java.util.TimerTask;
import org.dspace.core.ConfigurationManager;
import java.lang.Runtime;
import java.lang.Process;
import java.io.File;
import org.dspace.app.mediafilter.MediaFilterUtils;
import java.io.IOException;
import java.io.InputStream;
import java.lang.Thread;
import java.lang.IllegalThreadStateException;
import org.dspace.app.mediafilter.MediaFilterManager;

public class FilterMediaTask extends TimerTask 
{
	private String handle;
	private Boolean doWait;
	private Boolean doIndex;
	
	public void setup(String handleIn, Boolean doWaitIn, Boolean doIndexIn)
	{
		this.handle = handleIn;
		this.doWait = doWaitIn;
		this.doIndex = doIndexIn;
	}
	
	public void run() 
	{
		
		try
		{
			/*
			String dspaceDir = ConfigurationManager.getProperty("dspace.dir");
			String path = dspaceDir + File.separator +"bin"+File.separator+"filter-media";
			File mediaFilter = new File(path);
			if (mediaFilter.isFile() == false)
			{
				path = path + ".exe";
				mediaFilter = new File(path);
				if (mediaFilter.isFile() == false)
				{
					//throw new IOException("Cannot find filter-media!");
					System.out.println("Cannot find filter-media!");
				}
			}
			
			String cmdIndex = " -n";
			if (doIndex)
				cmdIndex = "";
			
			//String id = handle;
			//if (handle.indexOf("/") != -1)
			//	id = handle.substring(handle.indexOf("/")+1, handle.length());
			
			String cmd = path+cmdIndex+" -i " + handle;
			//cmd = cmd + " > /tmp/ffmpeg/filter_log_"+id+".txt";
			
			Process p = Runtime.getRuntime().exec(cmd);
			
			if (doWait)
			{
				//p.waitFor();
				doWaitFor(p, false);
			}
			*/
			
			String[] argv = new String[0];
			
			if (this.doIndex == false)
			{
				argv = new String[2];
				argv[0] = "-i";
				argv[1] = handle;
			}
			else
			{
				argv = new String[3];
				argv[0] = "-i";
				argv[1] = handle;
				argv[2] = "-n";
			}
			MediaFilterManager.main(argv);
		}
		catch (Exception ex) {
			//throw new IOException("Media-filter error, item handle or bitstream id: "+ handle + ", with DSpace Dir: " + dspaceDir);
			System.out.println("Media-filter error, item handle or bitstream id: "+ handle);
		}
	}	//public void run() 
    
    public int doWaitFor(Process p)
	{
		return doWaitFor(p, false);
	}
	
	public int doWaitFor(Process p, boolean showMsg)	
	{
	    int exitValue = -1; // returned to caller when p is finished
	    try {

	        InputStream in = p.getInputStream();
	        InputStream err = p.getErrorStream();
	        boolean finished = false; // Set to true when p is finished

	        while(!finished) {
	            try {
	                while( in.available() > 0) {
	                    // Print the output of our system call
	                    Character c = new Character( (char) in.read());
	                    if (showMsg == true)
	                    	System.out.print( c);
	                }
	                
	                while( err.available() > 0) {
	                    // Print the output of our system call
	                    Character c = new Character( (char) err.read());
	                    
	                    if (showMsg == true)
	                    	System.out.print( c);
	                }
	                
	                

	                // Ask the process for its exitValue. If the process
	                // is not finished, an IllegalThreadStateException
	                // is thrown. If it is finished, we fall through and
	                // the variable finished is set to true.
	                exitValue = p.exitValue();
	                finished = true;
	            }
	            catch (IllegalThreadStateException e) {
	                // Process is not finished yet;
	                // Sleep a little to save on CPU cycles
	                Thread.currentThread().sleep(500);
	            }
	        }
	    }
	    catch (Exception e) {
	        // unexpected exception! print it out for debugging...
	        if (showMsg == true)
	        {
	        	System.err.println( "doWaitFor();: unexpected exception - " +
	        		e.getMessage());
	        }
	    }

	    // return completion status to caller
	    return exitValue;
	}
}
