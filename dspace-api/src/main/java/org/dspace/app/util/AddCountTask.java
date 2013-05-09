package org.dspace.app.util;

import org.dspace.content.Bitstream;
import org.dspace.content.Item;
import java.lang.IllegalThreadStateException;
import java.util.TimerTask;

public class AddCountTask extends TimerTask 
{
	private Item item;
	private Bitstream bitstream;
	
	public void setObject(Item itemIn)
	{
		this.item = itemIn;
	}
	
	public void setObject(Bitstream bsIn)
	{
		this.bitstream = bsIn;
	}
	
	public void run() 
	{
		try
		{
			if (item != null)
			{
				item.addCount();
			}
			if (bitstream != null)
			{
				bitstream.addCount();
			}
		}
		catch (Exception e)
		{
			
		}
	}
}