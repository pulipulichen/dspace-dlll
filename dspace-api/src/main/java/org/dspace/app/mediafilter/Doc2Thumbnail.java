/*
 * Doc2Thumbnail.java
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
public class Doc2Thumbnail extends MediaFilter
{

    public String getFilteredName(String oldFilename)
    {
        return oldFilename + ".jpg";
    }

    /**
     * @return String bundle name
     *
     */
    public String getBundleName()
    {
        return "THUMBNAIL";
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
        return "Generated Thumbnail";
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
    	String tempJPEG;
    	if (type.equals("pdf") == true)
    		tempJPEG = MediaFilterUtils.XpdfPDF2JPEG(tempPDF, id);
    	else
    		tempJPEG = MediaFilterUtils.ImageMagickPDF2JPEG(tempPDF, id);
    	
    	String tempThumb = MediaFilterUtils.Image2Thumbnail(tempJPEG, id);
		
		InputStream bais = MediaFilterUtils.readFile(tempThumb);
        return bais;

    }
}
