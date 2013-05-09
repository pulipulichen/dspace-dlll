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
import org.dspace.app.webui.util.BitstreamDisplay;
import org.dspace.app.webui.util.UIUtil;

import java.io.PrintWriter;

/**
 * Servlet for retrieving bitstreams & preview. The bits are simply piped to the user.
 * <P>
 * <code>/retrieve/bitstream-id</code>
 * 
 * @author Robert Tansley
 * @version $Revision: 1189 $
 */
public class BitstreamPreviewServlet extends DSpaceServlet
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

            // Set the response MIME type
            response.setContentType("text/html; charset="+Constants.DEFAULT_ENCODING);
            // Response length
            //response.setHeader("Content-Length", String.valueOf(bitstream
            //        .getSize()));

            // Pipe the bits
            //InputStream is = bitstream.retrieve();
            try 
            {
	            //BitstreamDisplay bd = new BitstreamDisplay(context, request.getContextPath() + "/retrieve/" + bitstream.getID());
	            //bd.setPreviewMode(true);
	            
	            //bd.setShowFileNotFound(true);
	            
	            request.setAttribute("bitstream", bitstream);
	            //request.setAttribute("bitstreamDisplay", bd);
	            
	            JSPManager.showJSP(request, response, "/bitstream-preview.jsp");
	            /*
	            String ohtml = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n"
					+ "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
					+ "<head>\n"
					+ "<meta http-equiv=\"Content-Type\" content=\"text/html; charset="+Constants.DEFAULT_ENCODING+"\" />\n"
	                + "<title>"+bitstream.getName()+"</title>\n"
					+ "</head>\n"
					+ "\n"
					+ "<body style=\"text-align:center;margin: 0 auto;padding: 0 auto;\">\n"
					+ bd.doPreview()
					+ "</body>\n"
					+ "</html>\n";
				
				PrintWriter out = response.getWriter();
				out.println(ohtml);
				out.flush();
				*/
	        }
	        catch (Exception e)
	        {
	        	String ohtml = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n"
					+ "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
					+ "<head>\n"
					+ "<meta http-equiv=\"Content-Type\" content=\"text/html; charset="+Constants.DEFAULT_ENCODING+"\" />\n"
	                + "<title>Error</title>\n"
					+ "</head>\n"
					+ "\n"
					+ "<body style=\"text-align:center;margin: 0 auto;padding: 0 auto;\">\n"
					+ "Error<br /><pre style=\"display:block;\">" + e.getMessage() + "</pre><br /><hr />"
					+ "<pre style=\"display:block;\">" + e.getStackTrace() + "</pre>"
					+ "</body>\n"
					+ "</html>\n";
				PrintWriter out = response.getWriter();
				out.println(ohtml);
				out.flush();
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
}
