package org.dspace.app.util;

import java.lang.Thread;
import org.dspace.app.mediafilter.MediaFilterManager;

public class FilterMediaThread extends Thread
{
	private String[] argv;
	public void run()
	{
		try
		{
			MediaFilterManager.main(argv);
		}
		catch (Exception e) {}
	}
	public void setArgv(String[] argvIn)
	{
		this.argv = argvIn;
	}
}
