/*
 * RetrieveAssetstoreServlet.java
 */
package org.dspace.app.webui.servlet;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipEntry;
import java.io.ByteArrayOutputStream;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.BitstreamFormat;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.core.Utils;
import java.io.RandomAccessFile;
import java.net.URLEncoder;
import javax.mail.internet.MimeUtility;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.io.OutputStream;

/**
 * Servlet for retrieving bitstreams. The bits are simply piped to the user.
 * <P>
 * <code>/retrieve/bitstream-id</code>
 * 
 * @author Robert Tansley
 * @version $Revision: 1189 $
 */
public class RetrieveAssetstoreServlet extends DSpaceServlet
{
    /** log4j category */
    private static Logger log = Logger.getLogger(RetrieveServlet.class);

    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        Bitstream bitstream = null;

        // Get the ID from the URL
        String idString = request.getPathInfo();
		String pathString = "";

        if (idString != null)
        {
            // Remove leading slash
            if (idString.startsWith("/"))
            {
                idString = idString.substring(1);
            }

            // If there's a second slash, remove it and anything after it,
            // it might be a filename
            int slashIndex = idString.indexOf('/');

            if (slashIndex != -1)
            {
				if (slashIndex != idString.length() - 1 && (slashIndex + 1) < idString.length())
				{
					pathString = idString.substring(slashIndex + 1, idString.length());	
				}
				
                idString = idString.substring(0, slashIndex);
            }

            // Find the corresponding bitstream
            try
            {
                int id = Integer.parseInt(idString);
                bitstream = Bitstream.find(context, id);
            }
            catch (NumberFormatException nfe)
            {
                // Invalid ID - this will be dealt with below
            }
        }

        // Did we get a bitstream?
        if (bitstream != null)
        {
            log.info(LogManager.getHeader(context, "view_bitstream",
                    "bitstream_id=" + bitstream.getID()));
						
			//先取得bitstream的內部路徑
			
			
			if (!pathString.equals(""))
			{
				try 
				{
					/*
					ZipInputStream zipis = new ZipInputStream(is);
					
					String name = "";
					ZipEntry entry = null;
					boolean flag = false;
					while ((entry = zipis.getNextEntry()) != null)
					{
						name = entry.getName();
						if (name.equals(pathString))
						{
							flag = true;
							break;
						}
					}
					if (flag == false)
					{
						return;
					}
					
					bytesRangeDownload(name, zipis, entry.getSize()
						, request, response);
					*/
				}
				catch (Exception e)
				{
					e.printStackTrace();
				}
			}
			else
			{
				InputStream is = bitstream.retrieve();
				
				// Set the response MIME type
				response.setContentType(bitstream.getFormat().getMIMEType());
	
				// Response length
				response.setHeader("Content-Length", String.valueOf(bitstream
						.getSize()));
		
	
				Utils.bufferedCopy(is, response.getOutputStream());
				is.close();
				response.getOutputStream().flush();
			}

        }
        else
        {
            // No bitstream - we got an invalid ID
            log.info(LogManager.getHeader(context, "view_bitstream",
                    "invalid_bitstream_id=" + idString));

            JSPManager.showInvalidIDError(request, response, idString,
                    Constants.BITSTREAM);
        }
    }
    
    public void bytesRangeDownload(String fileName, InputStream in, long fileLength, HttpServletRequest request,
	            HttpServletResponse response) throws IOException
	{	
		String agent = request.getHeader("USER-AGENT");

			if (null != agent && -1 != agent.indexOf("MSIE")) 
			{
				fileName = URLEncoder.encode(fileName, "UTF8");
			} 
			else if (null != agent && -1 != agent.indexOf("Mozilla")) 
			{
				fileName = MimeUtility.encodeText(fileName, "UTF8", "B");
			} 
		//fileName = URLEncoder.encode(fileName, "UTF8");
		
	    OutputStream outs = null;
	    try
	    {
	        // 获取要下载视频的文件片段
	        String sRange = request.getHeader("range");
	        long startPos = 0;
	        final Pattern pattern = Pattern.compile("(?i)bytes\\=(\\d+)(?:\\-(\\d+))?");
	        if (sRange!=null && !"".equals(sRange.trim()))
	      {
	            Matcher mr = pattern.matcher(sRange);
	            if (mr.find())
	            {
	            startPos = Long.parseLong(mr.group(1), 10);
	            }
	            response.setStatus(206);
	        }
	        else
	        {
	            response.setStatus(200);
	        }

	        //in = new FileInputStream(file);
	        outs = response.getOutputStream();
	        byte[] buf = new byte[1024];

	        // 设置响应头
	        response.addHeader("Content-Range", "bytes "+startPos+"-"+(fileLength)+"/"+fileLength);
	        response.addHeader("Content-Length", ""+fileLength);
	        //response.setCharacterEncoding(Constants.DEFAULT_ENCODING);
	        //response.setContentType("application/octet-stream; charset="+Constants.DEFAULT_ENCODING);
	        //response.setHeader("Content-Disposition", "attachment; filename=" + fileName);
	        in.skip(startPos);

	        // 推送数据到客户端
	        int length = in.read(buf);
	        while (length>0)
	        {
	            outs.write(buf, 0, length);
	            outs.flush();
	            length = in.read(buf);
	        }
	    }
	    catch(IOException e)
	    {
	        // if ("org.apache.catalina.connector.ClientAbortException".equals(e.getClass().getName()))
	            // System.out.println("客户端断开");
	        //outs = response.getOutputStream();
	        //outs.print(e);
	        throw e;
	    }
	    finally
	    {
	        if (in != null)
	        {
	        	in.close();
	        }
	        if (outs != null)
	        {
	        	outs.close();
	        }
	    }
	}
}
