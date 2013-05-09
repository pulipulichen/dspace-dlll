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


public class UnzipTask extends TimerTask 
{
	private Bitstream bitstream;
	
	public void setBitstream(Bitstream bitstreamIn)
	{
		this.bitstream = bitstreamIn;
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
	
	public void run() 
	{
		//以下帶入自動解壓縮的功能
        if (ConfigurationManager.getBooleanProperty("upload.unzip.enable", false)
			&& bitstream.getFormat().getMIMEType().equals("application/zip"))
        {
			String sp = File.separator;
        	String assetstore = ConfigurationManager.getProperty("assetstore.dir");
			if (assetstore.endsWith(sp))
				assetstore = assetstore.substring(0, assetstore.length()-1);
        	String iid = bitstream.getInternalID();
			if (assetstore != null && !assetstore.equals("")
				&& iid != null && !iid.equals(""))
			{
				String filepath = assetstore
					+ sp
					+ iid.substring(0, 2)
					+ sp
					+ iid.substring(2, 4)
					+ sp
					+ iid.substring(4, 6)
					+ sp
					+ iid;
				
				String suffix = ConfigurationManager.getProperty("upload.unzip.dir-suffix", "_dir");
				String unzipDir = filepath + suffix;
				//確認是否已經解壓縮
				String cmd = "unzip -qq -o "+filepath+" -d "+ unzipDir;
				String cmdChmod = "chmod 755 -R "+ unzipDir;
				File f = new File(unzipDir);
				if (f.isDirectory() == false)
				{
					try
					{
						Process p = Runtime.getRuntime().exec(cmd);
						p.waitFor();
						//doWaitFor(p, false);
						
						p = Runtime.getRuntime().exec(cmdChmod);
						//doWaitFor(p, false);
					}
					catch (Exception e)
					{
						//throw new SQLException("Cannot unzip file.");
					}	
				}
			}
        }
	}
    
}
