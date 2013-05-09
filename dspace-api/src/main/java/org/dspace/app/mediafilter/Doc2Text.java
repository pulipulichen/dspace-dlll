/*
 * OOgPDFFilter.java
 *
 * [開啟soffice]
 * 必需要先安裝OpenOffice 2.0
 * 在本機端，以root執行以下指令
/usr/lib/openoffice.org2.0/program/soffice -headless -accept="socket,host=127.0.0.1,port=8100;urp;" -nofirststartwizard
 * [設定Filter]
 * 修改[dspace]/config/dspace.cfg
 * 找到「filter.plugins = 」，最後加入「, OOg Text Converter」
 * 找到「plugin.named.org.dspace.app.mediafilter.FormatFilter」，
 * 最後加入「 org.dspace.app.mediafilter.OOgTextFilter = OOg Text Converter」，如果要換行的話，開頭還要補上「/」
 * 在「filter.org.dspace.app.mediafilter.…」設定之後加入一行設定：
filter.org.dspace.app.mediafilter.OOgTextFilter.inputFormats = Microsoft Powerpoint
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
public class Doc2Text extends MediaFilter
{

    public String getFilteredName(String oldFilename)
    {
        return oldFilename + ".txt";
    }

    /**
     * @return String bundle name
     *
     */
    public String getBundleName()
    {
        return "TEXT";
    }

    /**
     * @return String bitstreamformat
     */
    public String getFormatString()
    {
        return "Text";
    }

    /**
     * @return String description
     */
    public String getDescription()
    {
        return "Extracted text";
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
    	String tempConverted = MediaFilterUtils.Doc2PDF(source, name, id);
    	String tempText = MediaFilterUtils.XpdfPDF2Text(tempConverted, id);
        InputStream bais = MediaFilterUtils.readFile(tempText);

        return bais;
    }
}
