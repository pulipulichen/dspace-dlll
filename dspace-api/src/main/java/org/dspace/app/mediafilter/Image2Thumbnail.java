/*
 * ImageMagickFilter.java
 *
 * 請把這個檔案上傳到[dspace-source]/dspace-api/src/main/java/org/dspace/app/mediafilter當中
 *
 * [安裝ImageMagick]
 * yum install imagemagick -y
 * 
 * [設定FFmpegVideoFilter]
 * 修改[dspace]/config/dspace.cfg
 * 找到「filter.plugins = 」，最後加入「, ImageMagick Converter」
 * 找到「plugin.named.org.dspace.app.mediafilter.FormatFilter」，
 最後加入「 org.dspace.app.mediafilter.ImageMagickFilter = ImageMagick Converter」，如果要換行的話，開頭還要補上「/」
 * 在「filter.org.dspace.app.mediafilter.…」設定之後加入一行設定：
filter.org.dspace.app.mediafilter.ImageMagickFilter.inputFormats = TIFF
 * 最後加入以下設定
 filter.exec.imagemagick = convert
 *
 * 別忘了重新編譯DSpace Source，祝您使用愉快
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
public class Image2Thumbnail extends MediaFilter
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
        String tempConverted = MediaFilterUtils.Image2Thumbnail(source, id);
		
		InputStream bais = MediaFilterUtils.readFile(tempConverted, false);
        return bais;
    }
}
