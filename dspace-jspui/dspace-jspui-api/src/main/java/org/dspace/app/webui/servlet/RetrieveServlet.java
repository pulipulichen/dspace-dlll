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
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.core.Utils;
import org.dspace.core.ConfigurationManager;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;

import javax.imageio.ImageIO;

/**
 * Servlet for retrieving bitstreams. The bits are simply piped to the user.
 * <P>
 * <code>/retrieve/bitstream-id</code>
 * 
 * @author Robert Tansley
 * @version $Revision: 1189 $
 */
public class RetrieveServlet extends DSpaceServlet
{
    /** log4j category */
    private static Logger log = Logger.getLogger(RetrieveServlet.class);
    private InputStream resized;
    private int resizedSize;

    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        Bitstream bitstream = null;

        // Get the ID from the URL
        String idString = request.getPathInfo();

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
            
            
            // 20110604 by Pudding Chen
	        // Enable Counter
	        int download = 0;
			if (request.getParameter("download") != null)
				download = Integer.parseInt(request.getParameter("download"));
	        if(ConfigurationManager.getBooleanProperty("counter.enable") && download != 0)
	        {
            	bitstream.addCount();
            	context.commit();
            }
            
            //Get width & height
			int width = -1;
			if (request.getParameter("width") != null)
				width = Integer.parseInt(request.getParameter("width"));
			int height = -1;
			if (request.getParameter("height") != null)
				height = Integer.parseInt(request.getParameter("height"));
			
			InputStream is;
			if (bitstream.getFormat().getMIMEType().equals("image/jpeg") == false 
				|| (width == -1 && height == -1))
			{
	            // Set the response MIME type
	            response.setContentType(bitstream.getFormat().getMIMEType());

	            // Response length
	            response.setHeader("Content-Length", String.valueOf(bitstream
	                    .getSize()));

	            // Pipe the bits
	            is = bitstream.retrieve();
	        }
	        else
	        {
	        	try
	        	{
	        		resizeImage(bitstream.retrieve(), width, height);
	        		
	        		// Set the response MIME type
		            response.setContentType("image/jpeg");

		            // Response length
		            response.setHeader("Content-Length", String.valueOf(this.resizedSize));

		            // Pipe the bits
		            is = this.resized;
	        	}
	        	catch(Exception e) {
	        		// Set the response MIME type
		            response.setContentType(bitstream.getFormat().getMIMEType());

		            // Response length
		            response.setHeader("Content-Length", String.valueOf(bitstream
		                    .getSize()));

		            // Pipe the bits
		            is = bitstream.retrieve();
	        	}
	        }

            Utils.bufferedCopy(is, response.getOutputStream());
            is.close();
            response.getOutputStream().flush();
            
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
    
	public void resizeImage(InputStream source, int w, int h)
            throws Exception
    {
        // read in bitstream's image
        BufferedImage buf = ImageIO.read(source);

        // get config params
        float xmax = (float) w;
        float ymax = (float) h;

        // now get the image dimensions
        float xsize = (float) buf.getWidth(null);
        float ysize = (float) buf.getHeight(null);


        float x_scale_factor;
		if (xmax > 0)
    		x_scale_factor = xmax / xsize;
    	else
    		x_scale_factor = -1;
    	
    	float y_scale_factor;
    	if (ymax > 0)
    		y_scale_factor = ymax / ysize;
    	else
    		y_scale_factor = -1;
    	
    	if (x_scale_factor > 0 && x_scale_factor > y_scale_factor)
    	{
    		float scale_factor = x_scale_factor;
    		xsize = xsize * scale_factor;
	        ysize = ysize * scale_factor;
	    	
	    	if (ymax > 0 && ymax < ysize)
	    	{
		    	scale_factor = ymax / ysize;
		    	
		    	xsize = xsize * scale_factor;
		        ysize = ysize * scale_factor;
	        }
    	}
    	else if (y_scale_factor > 0)
    	{
    		float scale_factor = y_scale_factor;
    		xsize = xsize * scale_factor;
	        ysize = ysize * scale_factor;
	    	
	    	if (xmax > 0 && xmax < xsize)
	    	{
		    	scale_factor = xmax / xsize;
		    	
		    	xsize = xsize * scale_factor;
		        ysize = ysize * scale_factor;
	        }
    	}

        // create an image buffer for the thumbnail with the new xsize, ysize
        BufferedImage thumbnail = new BufferedImage((int) xsize, (int) ysize,
                BufferedImage.TYPE_INT_RGB);

        // now render the image into the thumbnail buffer
        Graphics2D g2d = thumbnail.createGraphics();
        g2d.drawImage(buf, 0, 0, (int) xsize, (int) ysize, null);

        // now create an input stream for the thumbnail buffer and return it
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        ImageIO.write(thumbnail, "jpeg", baos);

        // now get the array
        ByteArrayInputStream bais = new ByteArrayInputStream(baos.toByteArray());
		
		this.resizedSize = baos.size();
        this.resized = bais; // hope this gets written out before its garbage collected!
    }
}
