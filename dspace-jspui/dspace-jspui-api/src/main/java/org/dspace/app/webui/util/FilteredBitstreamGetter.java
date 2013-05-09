/*
 * FilteredBitstreamGetter.java
 */
package org.dspace.app.webui.util;
import java.io.IOException;
import java.lang.InterruptedException;
import org.dspace.core.ConfigurationManager;
import java.lang.Runtime;
import java.lang.Process;
import org.dspace.core.Context;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.Item;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;
import java.sql.SQLException;
import java.util.ArrayList;
import org.dspace.storage.rdbms.DatabaseManager;
import java.util.List;
import org.apache.log4j.Logger;

public class FilteredBitstreamGetter
{
	private static Logger log = Logger.getLogger(FilteredBitstreamGetter.class);
	
	private Bitstream bitstream;
	private Context fContext;
	private Bundle filterBundle;
	private String filterBundleName;
	
	private FilteredBitstreamGetter()
	{
	}
	
	public void setContext(Context c)
	{
		this.fContext = c;
	}
	private Context getContext() throws SQLException
	{
		if (this.fContext == null)
		{
			this.fContext = new Context();
		}
		return this.fContext;
	}
	
	public void setBitstream(Bitstream bitstreamIn)
	{
		this.bitstream = bitstreamIn;
	}
	
	private Bitstream getBitstream()
	{
		return this.bitstream;
	}
	
	public void setFilterBundle(Bundle bundleIn)
	{
		this.filterBundle = bundleIn;
	}
	public Bundle getFilterBundle()
	{
		return this.filterBundle;
	}
	
	public void setFilterBundleName(String name)
	{
		this.filterBundleName = name;
	}
	
	private String getFilterBundleName()
	{
		if (this.filterBundleName != null)
			return this.filterBundleName;
		else if (this.filterBundle == null)
			return null;
		else
		{
			String name = this.filterBundle.getName();
			setFilterBundleName(name);
			return name;
		}
	}
	private int getFilterBundleID()
	{
		if (this.filterBundle == null)
			return -1;
		else
			return this.filterBundle.getID();
	}
	
	
	private int getID()
	{
		if (this.bitstream == null)
			return -1;
		else
			return this.bitstream.getID();
	}
	
	private String getName()
	{
		if (this.bitstream == null)
			return null;
		else
			return this.bitstream.getName();
	}
	
    public Bitstream[] getBitstreamByTableRowIterator(TableRowIterator tri) throws SQLException
    {
        List<Bitstream> bitstreams = new ArrayList<Bitstream>();
        try
        {
            while (tri.hasNext())
            {
                TableRow r = tri.next();

                // First check the cache
                Bitstream fromCache = (Bitstream) fContext.fromCache(Bitstream.class, r
                        .getIntColumn("bitstream_id"));

				if (fromCache != null
					&& fromCache.isDeleted() == true)
				{
					continue;
				}
                else if (fromCache != null)
                {
                    bitstreams.add(fromCache);
                }
                else
                {
                    bitstreams.add(Bitstream.find(fContext, r.getIntColumn("bitstream_id")));
                }
            }
        }
        finally
        {
            // close the TableRowIterator to free up resources
            if (tri != null)
                tri.close();
        }
        
        Bitstream[] bitstreamArray = new Bitstream[bitstreams.size()];
        bitstreamArray = (Bitstream[]) bitstreams.toArray(bitstreamArray);
        
        if (bitstreamArray.length == 0)
        {
        	bitstreamArray = getBitstreamByFilteredName();
        }
        
        return bitstreamArray;
    }
    
    private String getFilteredName()
    {
    	String bundleName = getFilterBundleName();
    	if (bundleName == null)
    		return null;
    	
    	String configFilterSuffix = "filter.bundle-suffix."+bundleName;
    	String suffix = ConfigurationManager.getProperty(configFilterSuffix, null);
    	
    	if (suffix == null)
    		return null;
    	
    	String filteredName = getName();
    	if (filteredName == null)
    		return null;
    	
    	filteredName = filteredName + suffix;
    	return filteredName;
    }
    
    public Bitstream[] getBitstreamByFilteredName() throws SQLException
    {
    	Bundle bundle = getFilterBundle();
    	String filteredName = getFilteredName();
    	//log.info("Filtered Name: " + filteredName);
    	if (bundle == null || filteredName == null)
    		return new Bitstream[0];
    	
    	Bitstream[] bitstreams = bundle.getBitstreams();
    	List<Bitstream> matchBitstreams = new ArrayList<Bitstream>();
    	for (int i = 0; i < bitstreams.length; i++)
    	{
    		if (bitstreams[i].isDeleted() == true)
    			continue;
    		
    		//log.info("Match Bitstream: " + bitstreams[i].getName() + " - " + filteredName);
    		if (bitstreams[i].getName().equals(filteredName))
    			matchBitstreams.add(bitstreams[i]);
    	}
    	//log.info("Match Bitstreams: " + matchBitstreams.size());
    	Bitstream[] bitstreamArray = new Bitstream[matchBitstreams.size()];
        bitstreamArray = (Bitstream[]) matchBitstreams.toArray(bitstreamArray);
        
        return bitstreamArray;
    }
    
    public Bitstream[] getFilteredBitstream(Bundle identifier) throws SQLException
    {
    	setFilterBundle(identifier);
    	return getFilteredBitstream();
    }
    
    public Bitstream[] getFilteredBitstream(String bundleName) throws SQLException
    {
    	setFilterBundleName(bundleName);
    	return getFilteredBitstream();
    }
    
    public Bitstream[] getFilteredBitstream() throws SQLException
    {
    	if (getBitstream() == null)
    	{
    		//沒東西！
    		return new Bitstream[0];
    	}
    	
    	// Get the bitstream table rows
        TableRowIterator tri = getTableRowIterator();
        
        Bitstream[] bitstreamArray = new Bitstream[0];
        if (tri != null)
        {
        	bitstreamArray = getBitstreamByTableRowIterator(tri);
        }
        
        //if (bitstreamArray.length == 0)
        //{
        //	bitstreamArray = getBitstreamByFilteredName();
        //}
        return bitstreamArray;
    }
    
    private TableRowIterator getTableRowIterator() throws SQLException
    {
    	TableRowIterator tri = null;
    	
    	if (DatabaseManager.hasColumnInfo("bitstream", "source_bitstream") == false)
    		return tri;
    	
    	if (getFilterBundle() != null)
    	{
    		int bitstreamID = getID();
    		if (bitstreamID != -1)
    		{
	    		int bundleID = getFilterBundle().getID();
		    	tri = DatabaseManager.queryTable(getContext(), "bitstream",
		                "SELECT bitstream.* FROM bitstream, bundle2bitstream WHERE " + 
		            	"bitstream.bitstream_id=bundle2bitstream.bitstream_id AND " +
		            	"bitstream.deleted = FALSE AND " +
		            	"bitstream.source_bitstream=? AND " +
		                "bundle2bitstream.bundle_id= ? ",
		                 bitstreamID , bundleID);
		        //log.info("FilteredBitstreamGetter: " + 
		        //	"SELECT bitstream.* FROM bitstream, bundle2bitstream WHERE " + 
		        //	"bitstream.bitstream_id=bundle2bitstream.bitstream_id AND " +
		        //	"bitstream.deleted = FALSE AND " +
		        //	"bitstream.source_bitstream=? AND " +
		        //	"bundle2bitstream.bundle_id= ? " + "|" + bitstreamID + "|" + bundleID);
		    }
        }
        else if (getFilterBundleName() != null)
        {
        	int bitstreamID = getID();
        	if (bitstreamID != -1)
        	{
	        	String name = getFilterBundleName();
	        	tri = DatabaseManager.queryTable(getContext(), "bitstream",
		                "SELECT bitstream.* FROM bitstream, bundle2bitstream, bundle WHERE " + 
		            	"bitstream.deleted = FALSE AND " +
		            	"bitstream.source_bitstream=? AND " +
		                "bitstream.bitstream_id=bundle2bitstream.bitstream_id AND " +
		            	"bundle.bundle_id=bundle2bitstream.bundle_id AND " +
		                "bundle.name= ? ",
		                 bitstreamID, name);
		        //log.info("FilteredBitstreamGetter: " + "SELECT bitstream.* FROM bitstream, bundle2bitstream, bundle WHERE " + 
		        //	"bitstream.deleted = FALSE AND " +
		        //	"bitstream.source_bitstream=? AND " +
		        //	"bitstream.bitstream_id=bundle2bitstream.bitstream_id AND " +
		        //	"bundle.bundle_id=bundle2bitstream.bundle_id AND " +
		        //	"bundle.name= ? " + "|" + bitstreamID + "|" + name);
		    }
        }
        else if (getID() != -1)	//不用管這麼多
        {
        	int sourceBitstreamID = getID();
        	tri = DatabaseManager.queryTable(getContext(), "bitstream",
	                "SELECT bitstream.* FROM bitstream WHERE " + 
	            	"bitstream.deleted = FALSE AND " +
	                "bitstream.source_bitstream= ? ",
	                 sourceBitstreamID);
	        //log.info("FilteredBitstreamGetter: " + "SELECT bitstream.* FROM bitstream WHERE " + 
	        //    	"bitstream.deleted = FALSE AND " +
	        //        "bitstream.source_bitstream= ? " + "|" + sourceBitstreamID);
        }
        else
        {
        	//log.info("FilteredBitstreamGetter: " + "null tri");
        }
        return tri;
    }
    
    static public Bitstream[] findFilteredBitstream(Context c, Bitstream bitstreamIn, Bundle bundleIn) throws SQLException
    {
    	return findFilteredBitstream(c, bitstreamIn, bundleIn, true);
    }
    static public Bitstream[] findFilteredBitstream(Context c, Bitstream bitstreamIn, Bundle bundleIn, boolean searchByName) throws SQLException
    {
    	FilteredBitstreamGetter fb = new FilteredBitstreamGetter();
    	fb.setContext(c);
    	fb.setBitstream(bitstreamIn);
    	fb.setFilterBundle(bundleIn);
    	Bitstream[] output = fb.getFilteredBitstream();
    	if (output.length == 0
    		&& searchByName == true)
    	{
    		//log.info("Search Filtered Name...");
        	output = fb.getBitstreamByFilteredName();
    	}
    	return output;
    }
    
    static public Bitstream[] findFilteredBitstream(Context c, Bitstream bitstreamIn, Bundle[] bundlesIn) throws SQLException
    {
    	ArrayList<Bitstream> output = new ArrayList<Bitstream>();
    	for (int i = 0; i < bundlesIn.length; i++)
    	{
	    	//FilteredBitstreamGetter fb = new FilteredBitstreamGetter();
	    	//fb.setContext(c);
	    	//fb.setBitstream(bitstreamIn);
	    	//fb.setFilterBundle(bundlesIn[i]);
	    	//Bitstream[] bitstreams = fb.getFilteredBitstream();
	    	Bitstream[] bitstreams = FilteredBitstreamGetter.findFilteredBitstream(c, bitstreamIn, bundlesIn[i], true);
	    	for (int j = 0; j < bitstreams.length; j++)
	    	{
	    		output.add(bitstreams[j]);
	    	}
    	}
    	Bitstream[] bitstreamArray = new Bitstream[output.size()];
    	return (Bitstream[]) output.toArray(bitstreamArray);
    }
    
    static public Bitstream[] findFilteredBitstream(Context c, Bitstream bitstreamIn, String bundleNameIn) throws SQLException
    {
    	FilteredBitstreamGetter fb = new FilteredBitstreamGetter();
    	fb.setContext(c);
    	fb.setBitstream(bitstreamIn);
    	fb.setFilterBundleName(bundleNameIn);
    	Bitstream[] bitstreamArray = fb.getFilteredBitstream();
    	
    	if (bitstreamArray.length == 0)
    	{
    		bitstreamArray = fb.getBitstreamByFilteredName();
    	}
    	
    	return bitstreamArray;
    }
}