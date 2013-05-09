/*
 * Doc2Album.java
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
public class Doc2Album extends MediaFilter
{

    public String getFilteredName(String oldFilename)
    {
        return oldFilename + ".zip";
    }

    /**
     * @return String bundle name
     *
     */
    public String getBundleName()
    {
        return "DOC_PREVIEW";
    }

    /**
     * @return String bitstreamformat
     */
    public String getFormatString()
    {
        return "ZIP";
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
    	
    	String tempZIP;
    	tempZIP = MediaFilterUtils.PDF2ALBUM(tempPDF, id);
    	
		InputStream bais = MediaFilterUtils.readFile(tempZIP);
        return bais;

    }
}
