/*
 * JPEG2SWFFilter.java
 * 要先裝imagemagick跟swftools！
 */
package org.dspace.app.mediafilter;

import java.io.InputStream;
import java.net.ConnectException;
import org.apache.log4j.Logger;
import org.dspace.app.mediafilter.MediaFilterUtils;

/**
 * Filter image bitstreams, scaling the image to be within the bounds of
 * thumbnail.maxwidth, thumbnail.maxheight, the size we want our thumbnail to be
 * no bigger than. Creates only JPEGs.
 */
public class Image2Snap extends MediaFilter
{
    public String getFilteredName(String oldFilename)
    {
        return oldFilename + "_snap.jpg";
    }

    /**
     * @return String bundle name
     *  
     */
    public String getBundleName()
    {
        return "SNAP";
    }

    /**
     * @return String bitstreamformat
     */
    public String getFormatString()
    {
        return "JPEG";
    }

    /**
     * @return String description
     */
    public String getDescription()
    {
        return "Snap";
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
        String tempConvertedJPEG = MediaFilterUtils.Image2JPEG(source, name, id);

		InputStream bais = MediaFilterUtils.readFile(tempConvertedJPEG, false);
        return bais;
    }
}
