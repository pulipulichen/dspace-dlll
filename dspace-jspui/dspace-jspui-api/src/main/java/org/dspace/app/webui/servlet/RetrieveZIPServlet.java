/*
 * RetrieveServlet.java
 *
 * Version: $Revision: 1189 $
 *
 * Date: $Date: 2005-04-20 09:23:44 -0500 (Wed, 20 Apr 2005) $
 *
 * Copyright (c) 2002-2005, Hewlett-Packard Company and Massachusetts
 * Institute of Technology.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the Hewlett-Packard Company nor the name of the
 * Massachusetts Institute of Technology nor the names of their
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
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
public class RetrieveZIPServlet extends DSpaceServlet
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
						
			InputStream is = bitstream.retrieve();
			if (!pathString.equals(""))
			{
				try 
				{
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
					
					/*
					ByteArrayOutputStream bout = new ByteArrayOutputStream();  
					byte[] temp = new byte[1024];  
					byte[] buf = null;  
					int length = 0;  
					
					while ((length = zipis.read(temp, 0, 1024)) != -1)   {
						bout.write(temp, 0, length);  
					} 
					
					buf = bout.toByteArray();  
					bout.close();
					*/
					/*
					response.setHeader("Content-Length", String
									.valueOf(entry.getSize())); 

					OutputStream toClient = response.getOutputStream();   //得到向客户端输出二进制数据的对象 
					
					toClient.write(buf);   //输出数据
					toClient.close(); 
					toClient.flush();
					*/
					
					bytesRangeDownload(name, zipis, entry.getSize()
						, request, response);
				}
				catch (Exception e)
				{
					e.printStackTrace();
				}
			}
			else
			{
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
