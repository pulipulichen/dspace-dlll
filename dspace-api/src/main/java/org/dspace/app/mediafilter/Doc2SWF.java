/*
 * Doc2SWF.java
 */
package org.dspace.app.mediafilter;

import java.io.InputStream;
import java.net.ConnectException;
import org.apache.log4j.Logger;
import org.dspace.app.mediafilter.MediaFilterUtils;

/*
 *		
 * to do: helpful error messages - can't find mediafilter.cfg - can't
 * instantiate filter - bitstream format doesn't exist
 *
 */
public class Doc2SWF extends MediaFilter
{

    public String getFilteredName(String oldFilename)
    {
        return oldFilename + ".swf";
    }

    /**
     * @return String bundle name
     *
     */
    public String getBundleName()
    {
        return "PDF2SWF_PREVIEW";
    }

    /**
     * @return String bitstreamformat
     */
    public String getFormatString()
    {
        return "SWF";
    }

    /**
     * @return String description
     */
    public String getDescription()
    {
        return "Generated Preview";
    }

    /**
     * @param source
     *            source input stream
     *
     * @return InputStream the resulting input stream
     */
    public InputStream getDestinationStream(InputStream source, String name, int id)
            throws Exception
    {
    	String tempPDF = MediaFilterUtils.Doc2PDF(source, name, id);
    	String type = MediaFilterUtils.getFileType(name);
    	
    	String tempSWF;
    	if (type.equals("pdf"))
    	{
    		tempSWF = MediaFilterUtils.PDF2JPEG2SWF(tempPDF, id);
    	}
    	else
    	{
    		try
    		{
    			tempSWF = MediaFilterUtils.PDF2JPEG2SWF(tempPDF, id, type);
    			
    		}
    		catch (Exception e)
    		{
    			System.out.println("Error: " + e.getMessage());
    			
    			tempSWF = MediaFilterUtils.PDF2SWF(tempPDF, id);
    		}
    	}
    	/*
    	String tempSWF;
    	try
    	{
    		tempSWF = MediaFilterUtils.PDF2JPEG2SWF(tempPDF, id);
    	}
    	catch (Exception e)
    	{
    		tempSWF = MediaFilterUtils.PDF2SWF(tempPDF, id);
    	}
		*/
		InputStream bais = MediaFilterUtils.readFile(tempSWF);
        return bais;

    }
}
