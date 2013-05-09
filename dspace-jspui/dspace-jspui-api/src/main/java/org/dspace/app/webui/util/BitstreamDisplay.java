/*
 * BitstreamDisplay.java
 */
package org.dspace.app.webui.util;

import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.content.Item;
import org.dspace.handle.HandleManager;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Bundle;
import org.dspace.content.Bitstream;
import org.dspace.content.BitstreamFormat;
import org.dspace.core.Context;
import java.io.InputStream;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipEntry;
import org.dspace.core.Constants;
import java.io.File;
import java.sql.SQLException;
import java.io.IOException;
import java.awt.image.BufferedImage;
import java.io.InputStream;
import java.awt.Graphics2D;
import javax.imageio.ImageIO;

public class BitstreamDisplay {
	
	private String basePath = ConfigurationManager
                .getProperty("dspace.url");
    private String assetstoreHTTP = ConfigurationManager.getProperty("assetstore.http.retrieve");
	private String internalPath;

	private String originalPath = "";
	private Item item = null;
	private Context context = null;
	private Bitstream bitstream = null;
	private Bitstream internalBitstream;
	private Bitstream thumbnailBitstream = null;
	private Bitstream snapBitstream = null;
	private Bitstream mobileBitstream = null;
	private String displayType;
	private String tagAClass = "bitstream_display_a";
	private String tagContentClass = "bitstream_display_content";
	private String tagContentIDPrefix = "bitstream_display_content_id_";
	private String zipIndexPath = "	";
	private String mime;
	private String extensionPath = "/extension/bitstream-display";
	private boolean loadedThickBox = false;
	private boolean loadedJQueryUI = false;
	private String error = "";
	private boolean showFileNotFound = false;
	private boolean allowDownload = true;
	private boolean isDialog = false;

	public String log = "";

	public BitstreamDisplay (Item itemIn, String path) throws IOException, SQLException
	{
		this.item = itemIn;
		setBitstreamByItem(path); 
		process();
	}
	
	public BitstreamDisplay (String path) throws IOException, SQLException
	{
		this.context = new Context();
		setBitstreamByID(path); 
		process();
	}
	
	public BitstreamDisplay (Context contextIn, String path) throws IOException
	{
		this.context = contextIn;
		setBitstreamByID(path); 
		process();
	}
	
	private void process() throws IOException
	{
		if (this.bitstream == null || this.originalPath == "")
			return;
			//throw new IOException("No Bitstream!");
		
		setType();
		
		/*
		if (this.displayType.equals("video")
			|| this.displayType.equals("audio")
			|| this.displayType.equals("image")
			|| this.displayType.equals("pdf"))
		{
			setInternalBitstream();
			setThumbnailBitstream();
		}
		*/
		setInternalBitstream();
		setThumbnailBitstream();
		if (getDisplayType().equals("video"))
			setMobileBitstream();
	}
	
	private void writeLog(String l)
	{
		this.log = this.log + "| " + l + "\n";
	}
	
	public String getLog()
	{
		return this.log;
	}
	
	private void setBitstreamByItem (String idString) throws IOException, SQLException
	{
		this.originalPath = idString;
    	Bitstream bitstream = null;
		
		String type = "";
		String sequenceText = "";
        int bitstreamID = -1;
        int sequenceID = -1;
        String log = "";
        
        if (idString.lastIndexOf("bitstream/") != -1)
        {
        	String handle = this.item.getHandle();
        	String sqID = idString.substring(idString.lastIndexOf(handle) + handle.length() + 1
        		, idString.length());
        
	        if (sqID.indexOf("/") != -1)
	        	sqID = sqID.substring(0, sqID.indexOf("/"));
	        
	        sequenceID = Integer.parseInt(sqID);
        }
        else
        {
        	String btID = idString.substring(idString.lastIndexOf("retrieve/") + 9
        		, idString.length());
        
	        if (btID.indexOf("/") != -1)
	        	btID = btID.substring(0, btID.indexOf("/"));
	        
	        bitstreamID = Integer.parseInt(btID);
	        
        }
		//--------------------------------------------------
		
		boolean found = false;
		Bundle[] bundles = this.item.getBundles("ORIGINAL");

		for (int i = 0; (i < bundles.length) && !found; i++)
		{
			Bitstream[] bitstreams = bundles[i].getBitstreams();
			for (int k = 0; (k < bitstreams.length) && !found; k++)
			{
				if ( (sequenceID != -1 && sequenceID == bitstreams[k].getSequenceID())
					|| (bitstreamID != -1 && bitstreamID == bitstreams[k].getID()) )
				{
					bitstream = bitstreams[k];
					found = true;
					break;
				}
			}
			if (found == true) break;
		}
		
		if (bitstream != null)
		{
			this.basePath = basePath;
			this.bitstream = bitstream;
		}
		else
		{
			//throw new IOException("Set bitstream error.");
			return;
		}
	}
	
	private void setBitstreamByID(String idString) throws IOException
	{
		this.originalPath = idString;
    	Bitstream bitstream = null;
		
        String log = "";
        
        String btID = idString.substring(idString.lastIndexOf("retrieve/") + 9
        	, idString.length());
        
        if (btID.indexOf("/") != -1)
        	btID = btID.substring(0, btID.indexOf("/"));
        
        int bitstreamID = Integer.parseInt(btID);
        
		//------------------------------------------------------
		//retrieve type
		
			try	{ 
				//要先找到item才行
				Item item = null;
				if (bitstreamID != -1)
				{
					bitstream = Bitstream.find(this.context, bitstreamID);
					this.bitstream = bitstream;
					Bundle[] bundles = bitstream.getBundles();
					Item[] items = bundles[0].getItems();
					item = items[0];
					this.item = item;
				}
				else
					throw new IOException("Bitstream ID Error(-1).");
			} catch (Exception e) 	{ 
				throw new IOException("Bitstream not found.");
			}
		
		if (bitstream != null)
			this.bitstream = bitstream;
		else
			throw new IOException("Set bitstream error.");
		
	}	//private void setBitstreamByID(String idString) throws IOException

	public String getDisplayType()
	{
		return this.displayType;
	}
	
	public String getError()
	{
		return this.error;
	}
	
	public void setType() throws IOException
	{
		if (this.bitstream == null)
			throw new IOException("Bistream not set.");
		
		BitstreamFormat bf = this.bitstream.getFormat();
		
		String mime = bf.getMIMEType();
		String type = "download";
		if (mime.equals("image/jpeg")
			|| mime.equals("image/gif")
			|| mime.equals("image/png")
			|| mime.equals("image/tiff")
			|| mime.equals("image/x-ms-bmp")
			|| mime.equals("image/bmp"))
		{
			//type = "image";
			type = detectImageType();
		}
		else if (mime.equals("video/x-msvideo")
			|| mime.equals("video/quicktime")
			|| mime.equals("video/x-flv")
			|| mime.equals("video/x-ms-wmv")
			|| mime.equals("video/mp4")
			|| mime.equals("video/mp4v-es")
			|| mime.equals("video/mpeg")
			|| mime.equals("video/3gpp")
			|| mime.equals("application/vnd.rn-realmedia")
			|| mime.equals("application/vnd.rn-realmedia-vbr"))
			type = "video";
		else if (mime.equals("text/plain")
			|| mime.equals("text/xml")
			|| mime.equals("text/css")
			|| mime.equals("text/html"))
			type = "iframe";
		else if (mime.equals("application/pdf")
			|| mime.equals("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
			|| mime.equals("application/vnd.openxmlformats-officedocument.presentationml.presentation")
			|| mime.equals("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
			|| mime.equals("application/msword")
			|| mime.equals("application/vnd.ms-powerpoint")
			|| mime.equals("application/vnd.ms-excel")
			|| mime.equals("application/vnd.sun.xml.impress")
			|| mime.equals("text/richtext")
			|| mime.equals("application/vnd.oasis.opendocument.presentation")
			|| mime.equals("application/vnd.oasis.opendocument.spreadsheet")
			|| mime.equals("application/vnd.sun.xml.calc")
			|| mime.equals("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
			|| mime.equals("text/csv")
			|| mime.equals("text/tab-separated-values"))
			type = "pdf";
		else if (mime.equals("audio/x-wav")
			|| mime.equals("audio/mpeg")
			|| mime.equals("audio/x-pn-realaudio")
			|| mime.equals("audio/x-mpeg")
			|| mime.equals("application/ogg")
			|| mime.equals("audio/ogg")
			|| mime.equals("audio/flac")
			|| mime.equals("audio/x-ms-wma")
			|| mime.equals("audio/mp4a-latm")
			|| mime.equals("audio/x-aac"))
			type = "audio";
		else if (mime.equals("application/zip"))
		{
			type = detectZIPType();
		}
		else
			type = "download";
		this.displayType = type;

	}	//setType() end
	
	private String detectZIPType()
	{
		//&#748;dO_index.html index.htm default.html default.html
		String type = "";
		
		//if (true)
		//	return "webpage";
		
		String[] indexName = new String[4];
		indexName[0] = "index.html";
		indexName[1] = "index.htm";
		indexName[2] = "default.html";
		indexName[3] = "default.htm";
		
		String[] htmlName = {"html", "htm"};
		
		try 
		{
			InputStream is = bitstream.retrieve();
			
			String indexPath = null;
			String indexPath2 = null;
			int dirCount = 0;
			String dirPath = null;
			ZipInputStream zipis = new ZipInputStream(is);
			String name = "";
			ZipEntry entry = null;
			boolean flag = false;
			boolean hasHTML = false;
			while ((entry = zipis.getNextEntry()) != null)
			{
				if (entry.isDirectory())
				{
					dirCount++;
					if (dirPath == null)
						dirPath = entry.getName();
				}
				else
				{
					name = entry.getName();
					
					if (name.indexOf(File.separator) != -1)
						continue;
					
					for (int i = 0; i < indexName.length; i++)
					{
						if (indexName[i].equals(name))
						{
							indexPath = name;
							break;
						}
					}
					
					if (indexPath == null 
						&& indexPath2 == null
						&& name.lastIndexOf(".") > -1)
					{
						String fileType = name.substring(name.lastIndexOf(".") + 1, name.length());
						for (int i = 0; i < htmlName.length; i++)
						{
							if (htmlName[i].equals(fileType))
							{
								indexPath2 = name;
								break;
							}
						}
					}
					writeLog(name+","+indexPath);
				}
				
				if (indexPath != null)
					break;
			}
			
			if (indexPath == null && dirCount > 0)
			{
				InputStream is2 = bitstream.retrieve();
				ZipInputStream zipis2 = new ZipInputStream(is2);
				while ((entry = zipis2.getNextEntry()) != null)
				{
					name = entry.getName();
					
					for (int i = 0; i < indexName.length; i++)
					{
						String dirIndexName = dirPath + indexName[i];
						if (dirIndexName.equals(name))
						{
							indexPath = name;
							break;
						}
					}
					
					if (indexPath == null 
						&& indexPath2 == null
						&& name.lastIndexOf(".") > -1)
					{
						String fileType = name.substring(name.lastIndexOf(".") + 1, name.length());
						for (int i = 0; i < htmlName.length; i++)
						{
							if (htmlName[i].equals(fileType))
							{
								indexPath2 = name;
								break;
							}
						}
					}
					
					if (indexPath != null)
						break;
				}
			}
			
			if (indexPath != null)
			{
				this.zipIndexPath = indexPath;
				type = "webpage";
			}
			else if (indexPath2 != null)
			{
				this.zipIndexPath = indexPath2;
				type = "webpage";
			}
			else
			{
				type = "download";
			}
			
		}
		catch (Exception e) {
			type = "download";
		}
		
		if (this.zipIndexPath.lastIndexOf("/") > -1)
		{
			String name = this.zipIndexPath.substring(this.zipIndexPath.lastIndexOf("/") + 1, this.zipIndexPath.length());
			
			for (int i = 0; i < indexName.length; i++)
			{
				if (indexName[i].equals(name))
				{
					this.zipIndexPath = this.zipIndexPath.substring(0, this.zipIndexPath.lastIndexOf("/") + 1);
					break;
				}
			}
		}
		return type;
	}
	
	public String detectImageType()
	{
		try
		{
			InputStream source = this.bitstream.retrieve();
			BufferedImage buf = ImageIO.read(source);
			float xsize = (float) buf.getWidth(null);
	        float ysize = (float) buf.getHeight(null);
	        
	        writeLog("size:"+xsize+"x"+ysize);
	        if (xsize < 300 && ysize < 300)
	        	return "smallimage";
	        else
				return "image";
		}
		catch (Exception e)
		{
			writeLog(e.getMessage());
			return "image";
		}
	}
	
	public void setInternalBitstream()
	{
		String internalBundleName;
		String internalFileName;
		
		if (this.displayType.equals("image"))
		{
			internalBundleName = "ZOOMIFY";
			internalFileName = ".zip";
		}
		else if (this.displayType.equals("video"))
		{
			internalBundleName = "VIDEO_PREVIEW";
			internalFileName = ".flv";
		}
		else if (this.displayType.equals("audio"))
		{
			internalBundleName = "AUDIO_PREVIEW";
			internalFileName = ".mp3";
		}
		else if (this.displayType.equals("pdf"))
		{
			internalBundleName = "PDF2SWF_PREVIEW";
			internalFileName = ".swf";
		}
		else
		{
			//this.displayType = "download";
			this.internalBitstream = this.bitstream;
			return;
		}
		
		try 
		{
			Bundle[] internals = this.item.getBundles(internalBundleName);
			String iName = this.bitstream.getName() + internalFileName;
			Bitstream ib = internals[0].getBitstreamByName(iName);
			this.internalBitstream = ib;
			if (this.internalBitstream == null)
			{
				//this.displayType = "snap";
				/*
				if (this.displayType.equals("pdf"))
				{
					//this.displayType = "iframe";
					//this.internalBitstream = this.bitstream;
					
				}
				else
				{
					//this.displayType = "download";
					//this.internalBitstream = this.bitstream;
				}
				*/
			}
		}
		catch (Exception e)
		{
			/*
			this.displayType = "download";
			this.internalBitstream = this.bitstream;
			*/
			//this.displayType = "snap";
		}
	}
	
	public void setThumbnailBitstream()
	{
		String thumbnailBundleName = "THUMBNAIL";
		String thumbnailFileName = ".jpg";
		
		String snapBundleName = "SNAP";
		String snapFileName = "_snap.jpg";
		
		try 
		{
			if (thumbnailBundleName.equals("") == false)
			{
				Bundle[] thumbnails = this.item.getBundles(thumbnailBundleName);
				String tName = this.bitstream.getName() + thumbnailFileName;
				Bitstream tb = thumbnails[0].getBitstreamByName(tName);
				this.thumbnailBitstream = tb;
			}
			if (snapBundleName.equals("") == false)
			{
				Bundle[] thumbnails = this.item.getBundles(snapBundleName);
				String tName = this.bitstream.getName() + snapFileName;
				Bitstream tb = thumbnails[0].getBitstreamByName(tName);
				this.snapBitstream = tb;
			}
		}
		catch (Exception e)	{ }
	}
	
	public void setMobileBitstream()
	{
		String mobileBundleName = "VIDEO_MOBILE";
		String mobileFileName = ".mp4";
		
		try 
		{
			if (mobileBundleName.equals("") == false)
			{
				Bundle[] mobiles = this.item.getBundles(mobileBundleName);
				String tName = this.bitstream.getName() + mobileFileName;
				Bitstream tb = mobiles[0].getBitstreamByName(tName);
				this.mobileBitstream = tb;
			}
		}
		catch (Exception e)	{ }
	}
	
	public void setShowFileNotFound(boolean flag)
	{
		this.showFileNotFound = flag;
	}
	
	public void setAllowDownload(boolean flag)
	{
		this.allowDownload = flag;
	}
	
	public String fileNotFound()
	{
		if (this.showFileNotFound == true)
		{
			String t = this.displayType;
			if (t.equals("iframe")
				|| t.equals("webpage")
				|| t.equals("download"))
				return "This file has no preview.";
			else
				return "Preview now proceeding. Please wait.";
		}
		else
			return this.bitstream.getName();
	}
	
	public Bitstream getBitstream()
	{
		return this.bitstream;
	}
	
	public String getName()
	{
		if (this.bitstream == null)
			return "";
		else
			return this.bitstream.getName();
	}
	
	public String getMIMEType()
	{
		if (this.bitstream == null)
			return "";
		else
			return this.bitstream.getMIMEType();
	}
	
	public String getFormatDescription() 
	{
		if (this.bitstream == null)
			return "";
		else
		{
			String format = this.bitstream.getFormatDescription();
			if (format.equals("Unknown"))
			{
				String name = getName();
				if (name.lastIndexOf(".") > -1)
				{
					String filetype = name.substring(name.lastIndexOf(".") + 1, name.length());
					format = filetype;
				}
				format = format.toUpperCase();
			}
			
			return format;
		}
	}
	
	public String getSize()
	{
		if (this.bitstream == null)
			return "";
		else
			return this.bitstream.getSize() + "";
	}
	
	public String getFormatSize()
	{
		if (this.bitstream == null)
			return "";
		else
		{
			long size = this.bitstream.getSize();
			return UIUtil.formatFileSize(size);
		}
	}
	

	public String getRetrievePath(int id)
	{
		return this.basePath + "/retrieve/" + id;
	}
	
	public String getImage(String src, int w, int h)
	{
		String width = "width=" + w;
		if (w == -1)
			width = "";
		String height = "height=" + h;
		if (h == -1)
			height = "";
		
		String get = "?" + width + "&" + height;
		if (width.equals("") == true && height.equals("") == true)
			get = "";
		else if (width.equals("") == false && height.equals("") == true)
			get = "?" + width;
		else if (width.equals("") == true && height.equals("") == false)
			get = "?" + height;
		
		//return "<img width=\""+width+"\" height=\""+height+"\" border=\"0\" src=\""+getThumbnailPath()+"\" />";
		return "<img border=\"0\" src=\""+src+get+"\" />";
	}
	
	public String getThumbnailImage(int w, int h)
	{
		if (this.thumbnailBitstream == null)
			return fileNotFound();
		
		return getImage(getThumbnailPath() ,w, h);
	}
	
	public String getThumbnailImage()
	{
		if (this.thumbnailBitstream == null)
			return fileNotFound();
		return getImage(getThumbnailPath(), -1, -1);
	}
	
	public String getThumbnailImage(String alt)
	{
		if (this.thumbnailBitstream == null)
			return alt;
		return getImage(getThumbnailPath(), -1, -1);
	}
	
	public String getThumbnailPath ()
	{
		if (this.thumbnailBitstream == null)
			return fileNotFound();
		else
			return getRetrievePath(this.thumbnailBitstream.getID());
	}
	
	public boolean hasThumbnail()
	{
		return (this.thumbnailBitstream != null && this.thumbnailBitstream != this.bitstream);
	}
	
	public boolean hasSnap()
	{
		return (this.snapBitstream != null	&& this.snapBitstream != this.bitstream);
	}
	
	public boolean hasInternal()
	{
		return (this.internalBitstream != null && this.internalBitstream != this.bitstream);
	}
	
	public String getSnapImage(int w, int h)
	{
		if (this.snapBitstream == null)
			return fileNotFound();
		
		return getImage(getSnapPath(), w, h);
	}
	
	public String getSnapImage()
	{
		if (this.snapBitstream == null)
			return fileNotFound();
		
		return getImage(getSnapPath(), -1, -1);
	}
	
	public String getSnapPath ()
	{
		if (this.snapBitstream == null)
			return fileNotFound();
		else
			return getRetrievePath(this.snapBitstream.getID());
	}
	
	
	public String doThumbnail()
	{
		return getThumbnailImage();
	}
	
	public String doThumbnail(int w, int h)
	{
		return getThumbnailImage(w, h);
	}
	
	public String doSnap()
	{
		return getSnapImage();
	}
	
	public String doSnap(int w, int h)
	{
		return getSnapImage(w, h);
	}
	
	public String getRetrieveZIPPath(int id)
	{
		return this.basePath + "/retrieve-zip/" + id;
	}
	
	public String getRetrieveAssetstorePath(int id)
	{
		//return this.basePath + "/retrieve-zip/" + id;
		String iid = this.bitstream.getInternalID();
		if (assetstoreHTTP.endsWith("/"))
			assetstoreHTTP = assetstoreHTTP.substring(0, assetstoreHTTP.length() - 1);
		String sp = "/";
		String filepath = assetstoreHTTP
					+ sp
					+ iid.substring(0, 2)
					+ sp
					+ iid.substring(2, 4)
					+ sp
					+ iid.substring(4, 6)
					+ sp
					+ iid + "_dir";
		return filepath;
	}
	
	private String tagA(String innerTEXT, String href)
	{
		if (this.allowDownload == true)
			return "<a href=\""+href+"\" class=\""+this.tagAClass+"\">"+innerTEXT+"</a>";
		else
			return "<a title=\"Cannot download\">" + innerTEXT + "</a>";
	}
	private String thickBoxA(String innerTEXT, String href, boolean allowDownload)
	{
		String title = this.bitstream.getName();
		if (allowDownload == true)
		{
			title = title + "(<a href=\'"+this.originalPath+"\'>download</a>)";
		}
		return "<a href=\""+href+"\" class=\"thickbox "+this.tagAClass+"\" title=\""+title+"\">"+innerTEXT+"</a>";
	}
	
	public int getWidthByDisplayType()
	{
		int w = 800;
		if (this.displayType.equals("video") || this.displayType.equals("audio"))
			w = 320;
		else if ( this.isDialog == false
			&& (this.displayType.equals("iframe") || this.displayType.equals("webpage")) )
			w = -1;
		else if (this.displayType.equals("smallimage"))
			w = 300;
		return w;
	}
	
	public int getHeightByDisplayType()
	{
		int h = 600;
		if (this.displayType.equals("video"))
			h = 240;
		else if (this.displayType.equals("audio"))
			h = 20;
		else if ( this.isDialog == false
			&& (this.displayType.equals("iframe") || this.displayType.equals("webpage")) )
			h = -1;
		else if (this.displayType.equals("smallimage"))
			h = 300;
		return h;
	}
	
	public String doVideoPlayer()
	{
		if (this.internalBitstream == null)
			return fileNotFound();
		int w = getWidthByDisplayType();
		int h = getHeightByDisplayType();
		String internalPath = getRetrievePath(this.internalBitstream.getID());
		return doVideoPlayer(internalPath, w, h, false);
	}
	
	public String doVideoPlayer(int w, int h)
	{
		if (this.internalBitstream == null)
			return fileNotFound();
		String internalPath = getRetrievePath(this.internalBitstream.getID());
		return doVideoPlayer(internalPath, w, h, false);
	}
	
	public String doVideoPlayer(String internalPath, int w, int h, boolean autoplay)
	{
		String autoplayFlag = "0";
		if (autoplay == true)
			autoplayFlag = "1";
		
		String width = "" + w;
		if (w == -1)
			width = "100%";
		String height = "" + h;
		if (h == -1)
			height = "100%";
		
		String ohtml = "<object class=\"playerpreview\" \n"
				+ "		type=\"application/x-shockwave-flash\" data=\""+this.basePath+this.extensionPath+"/player_flv_maxi.swf\" \n"
				+ "		style=\"font-size: 0;line-height: 0;\" \n"
				+ "		width=\""+w+"\" height=\""+h+"\"> \n"
				+ "	<param name=\"movie\" value=\""+this.basePath+this.extensionPath+"/player_flv_maxi.swf\" /> \n"
				+ "	<param name=\"allowFullScreen\" value=\"true\" /> \n"
				+ "	<param name=\"FlashVars\" \n"
				+ "		value=\"flv="+internalPath+"&width="+w+"&height="+h+"&autoplay="+autoplayFlag+"&autoload=1&showstop=1&showvolume=1&showtime=1&showfullscreen=1&bgcolor1=FFFFFF&bgcolor2=FFFFFF&playercolor=666666\" /> \n"
				+ "	<param name=\"wmode\" value=\"transparent\"> \n"
				+ "</object> \n";
		return ohtml;
	}
	
	public String doImageViewer()
	{
		if (this.internalBitstream == null)
			return fileNotFound();
		int w = getWidthByDisplayType();
		int h = getHeightByDisplayType();
		int id = this.internalBitstream.getID();
		String internalPath = getRetrieveZIPPath(id);
		return doImageViewer("preview", internalPath, w, h);
	}
	
	public String doImageViewer(int w, int h)
	{
		if (this.internalBitstream == null)
			return fileNotFound();
		int id = this.internalBitstream.getID();
		String internalPath = getRetrieveZIPPath(id);
		return doImageViewer("preview", internalPath, w, h);
	}
	
	public String doImageViewer(String contentID, String internalPath, int w, int h)
	{
		h = h - 10;
		String viewerPath = this.basePath + this.extensionPath+"/zoomifyViewer.swf";
		String ohtml = "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0\" \n"
					+ "	style=\"font-size: 0;line-height: 0;border:1px solid #CCCCCC;\" \n"
					+ "	width=\""+w+"\" height=\""+h+"\" id=\""+contentID+"_zoomify\"> \n"
        			+ "		<param name=\"FlashVars\" value=\"zoomifyImagePath="+internalPath+"/&zoomifyNavigatorVisible=true\"> \n"
		        	+ "		<param name=\"BGCOLOR\" value=\"#FFFFFF\"> \n"
        			+ "		<param name=\"MENU\" value=\"true\"> \n"
					+ "		<param name=\"SRC\" value=\""+viewerPath+"\"> \n"
					+ "		<param name=\"wmode\" value=\"transparent\">\n"
					+ "		<embed flashvars=\"zoomifyImagePath="+internalPath+"/&zoomifyNavigatorVisible=true\" \n"
                	+ "			src=\""+viewerPath+"\" bgcolor=\"#FFFFFF\" menu=\"true\" pluginspage=\"http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash\" \n"
            		+ "			style=\"font-size: 0;line-height: 0;border:1px solid #CCCCCC;\" \n"
            		+ "			wmode=\"transparent\"\n"
                	+ "			width=\""+w+"\" height=\""+h+"\" name=\""+contentID+"_zoomify\"></embed> \n"
    				+ "</object> \n";
		return ohtml;
	}
	
	public String doSwfPicture()
	{
		if (this.bitstream == null)
			return fileNotFound();
		int w = getWidthByDisplayType();
		int h = getHeightByDisplayType();
		return doSwfPicture(w, h);
	}
	
	public String doSwfPicture(int w, int h)
	{
		return doSwfPicture(getRetrievePath(this.bitstream.getID()), w, h);
	}
	
	public String doSwfPicture(String path, int w, int h)
	{
		String ohtml = "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0\" width=\""+w+"\" height=\""+h+"\"><param name=\"movie\" value=\""+this.basePath+"/extension/bitstream-display/swfoto.swf?image="+path+"\"><embed src=\""+this.basePath+"/extension/bitstream-display/swfoto.swf?image="+path+"\" width=\""+w+"\" height=\""+h+"\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" type=\"application/x-shockwave-flash\"></embed></object>";
		return ohtml;
	}
	
	public String doIframe (int w, int h)
	{
		if (this.originalPath == null)
			return fileNotFound();
		String internalPath = this.originalPath;
		if (this.displayType.equals("webpage"))
		{
			int id = this.bitstream.getID();
			internalPath = getRetrieveZIPPath(id) + "/" + this.zipIndexPath;
		}
		return doIframe(internalPath, w, h);
	}
	
	public String doIframe (String internalPath, int w, int h)
	{
		String width = "" + w + "px";
		if (w == -1)
			width = "100%";
		String height = "" + h + "px";
		if (h == -1)
			height = "600px";
		
		String ohtml = "<iframe src=\""+internalPath+"\" "
			+" style=\"width:"+width+";height:"+height+";\"></iframe>";
		return ohtml;
	}
	
	public String doAudioPlayer ()
	{
		if (this.internalBitstream == null)
			return fileNotFound();
		int w = getWidthByDisplayType();
		int h = getHeightByDisplayType();
		String internalPath = getRetrievePath(this.internalBitstream.getID());
		return doAudioPlayer(internalPath, w, h, false);
	}
	
	public String doAudioPlayer(int w, int h)
	{
		if (this.internalBitstream == null)
			return fileNotFound();
		String internalPath = getRetrievePath(this.internalBitstream.getID());
		return doAudioPlayer(internalPath, w, h, false);
	}
	
	public String doAudioPlayer (String internalPath, int w, int h, boolean autoplay)
	{
		String autoplayFlag = "false";
		if (autoplay == true)
			autoplayFlag = "true";
		
		String width = "" + w;
		if (w == -1)
			width = "100%";
		String height = "" + h;
		if (h == -1)
			height = "100%";
		
		String playerPath = this.basePath + this.extensionPath+"/xspf_player_slim.swf";
		
		String ohtml = "<object type=\"application/x-shockwave-flash\" \n"
					+ "	data=\""+playerPath+"?&song_url="+internalPath+"&autoPlay="+autoplayFlag+"\""
					+ "	style=\"font-size: 0;line-height: 0;\" \n"
					+ "	width=\""+width+"\" height=\""+height+"\">"
					+ "		<param name=\"movie\" "
					+ "			value=\""+playerPath+"?&song_url="+internalPath+"&autoPlay="+autoplay+"\" />"
					+ "		<param name=\"wmode\" value=\"transparent\">\n"
					+ "</object>";
		return ohtml;
	}
	
	public String doPDF2SWF ()
	{
		if (this.internalBitstream == null)
			return fileNotFound();
		int w = getWidthByDisplayType();
		int h = getHeightByDisplayType();
		String internalPath = getRetrievePath(this.internalBitstream.getID());
		return doPDF2SWF (internalPath, w, h);
	}
	
	public String doPDF2SWF (int w, int h)
	{
		if (this.internalBitstream == null)
			return fileNotFound();
		String internalPath = getRetrievePath(this.internalBitstream.getID());
		return doPDF2SWF (internalPath, w, h);
	}
	
	public String doPDF2SWF (String internalPath, int w, int h)
	{
		w = w - 10;
		h = h - 10;
		
		String width = "" + w;
		if (w < 0)
			width = "100%";
		String height = "" + h;
		if (h < 0)
			height = "100%";
		String ohtml = "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" \n"
					+ "	width=\""+width+"\" \n"
					+ "	height=\""+height+"\" \n"
					+ "	codebase=\"http://active.macromedia.com/flash5/cabs/swflash.cab#version=8,0,0,0\"> \n"
					+ "	<param name=\"MOVIE\" value=\""+internalPath+"\"> \n"
					+ "	<param name=\"PLAY\" value=\"true\"> \n"
					+ "	<param name=\"LOOP\" value=\"true\"> \n"
					+ "	<param name=\"QUALITY\" value=\"high\"> \n"
					+ "	<embed src=\""+internalPath+"\" width=\""+width+"\" height=\""+height+"\" \n"
					+ "		play=\"true\" align=\"center\" loop=\"true\" quality=\"high\" \n"
					+ "		type=\"application/x-shockwave-flash\" \n"
					+ "		style=\"font-size: 0;line-height: 0;\" \n"
					+ "		pluginspage=\"http://www.macromedia.com/go/getflashplayer\"> \n"
					+ "	</embed> \n"
					+ "</object> \n";
		return ohtml;
	}
	
	public String doThickBox(String innerTEXT)
	{
		int iframeWidth = getWidthByDisplayType();
		int iframeHeight = getHeightByDisplayType();

		boolean allowDownload = this.allowDownload;
		
		return doThickBox(innerTEXT, iframeWidth, iframeHeight, allowDownload);
	}
	
	public String doThickBox(String innerTEXT, boolean allowDownload)
	{
		int iframeWidth = getWidthByDisplayType();
		int iframeHeight = getHeightByDisplayType();
		return doThickBox(innerTEXT, iframeWidth, iframeHeight, allowDownload);
	}
	
	public String doThickBox(String innerTEXT, int iframeWidth, int iframeHeight)
	{
		boolean allowDownload = this.allowDownload;
		return doThickBox(innerTEXT, iframeWidth, iframeHeight, allowDownload);
	}
	
	public String doThickBox(String innerTEXT, int iframeWidth, int iframeHeight, boolean allowDownload)
	{
		if (this.bitstream == null)
			return "";
		
		String ohtml = "";
		String contentID = this.tagContentIDPrefix + this.bitstream.getID();
		
		if (this.displayType.equals("download"))
		{
			return tagA(innerTEXT, this.originalPath);
		}
		
		if (this.displayType.equals("video"))
		{						
			String internalPath = getRetrievePath(this.internalBitstream.getID());
			String tagAHref = "#TB_inline?height="+iframeHeight+"&amp;width="+(iframeWidth+10)+"&amp;inlineId="+contentID;
			ohtml = thickBoxA(innerTEXT, tagAHref, allowDownload);
			if (loadedThickBox == false)
			{
				ohtml = ohtml + "<div class=\""+this.tagContentClass+"\" style=\"display:none\" id=\""+contentID+"\">";
				ohtml = ohtml + doVideoPlayer(internalPath, iframeWidth, iframeHeight, true);
				ohtml = ohtml + "</div>";
			}
		}
		else if (this.displayType.equals("image"))
		{
			int id = this.internalBitstream.getID();
			String internalPath = getRetrieveZIPPath(id);
			
			String tagAHref = "#TB_inline?height="+iframeHeight+"&amp;width="+(iframeWidth+10)+"&amp;inlineId="+contentID;
			ohtml = thickBoxA(innerTEXT, tagAHref, allowDownload);
			if (loadedThickBox == false)
			{
				ohtml = ohtml + "<div class=\""+this.tagContentClass+"\" style=\"display:none\" id=\""+contentID+"\">";
				ohtml = ohtml + doImageViewer(contentID, internalPath, iframeWidth, iframeHeight);
				ohtml = ohtml + "</div>";
			}
		}
		else if (this.displayType.equals("iframe"))
		{
			String internalPath = this.originalPath;
			String tagAHref = "#TB_inline?height="+iframeHeight+"&amp;width="+(iframeWidth+10)+"&amp;inlineId="+contentID;
			ohtml = thickBoxA(innerTEXT, tagAHref, allowDownload);
			if (loadedThickBox == false)
			{
				ohtml = ohtml + "<div class=\""+this.tagContentClass+"\" style=\"display:none\" id=\""+contentID+"\">";
			
				ohtml = ohtml + doIframe(internalPath, iframeWidth, iframeHeight);
	
				ohtml = ohtml + "</div>";
			}
		}
		else if (this.displayType.equals("pdf"))
		{
			String internalPath = getRetrievePath(this.internalBitstream.getID());
			String tagAHref = "#TB_inline?height="+iframeHeight+"&amp;width="+(iframeWidth+10)+"&amp;inlineId="+contentID;
			ohtml = thickBoxA(innerTEXT, tagAHref, allowDownload);
			if (loadedThickBox == false)
			{
				ohtml = ohtml + "<div class=\""+this.tagContentClass+"\" style=\"display:none\" id=\""+contentID+"\">";
			
				ohtml = ohtml + doIframe(internalPath, iframeWidth, iframeHeight);
	
				ohtml = ohtml + "</div>";
			}
		}
		else if (this.displayType.equals("webpage"))
		{
			int id = this.internalBitstream.getID();
			String internalPath = getRetrieveZIPPath(id)
				+ "/" + this.zipIndexPath;
			String tagAHref = "#TB_inline?height="+iframeHeight+"&amp;width="+(iframeWidth+10)+"&amp;inlineId="+contentID;
			ohtml = thickBoxA(innerTEXT, tagAHref, allowDownload);
			if (loadedThickBox == false)
			{
				ohtml = ohtml + "<div class=\""+this.tagContentClass+"\" style=\"display:none\" id=\""+contentID+"\">";
			
				ohtml = ohtml + doIframe(internalPath, iframeWidth, iframeHeight);
	
				ohtml = ohtml + "</div>";
			}
		}
		else if (this.displayType.equals("audio"))
		{
			int id = this.internalBitstream.getID();
			//String internalPath = getRetrieveZIPPath(id)
			//	+ "/" + this.zipIndexPath;
			String internalPath = getRetrievePath(this.internalBitstream.getID());
			iframeHeight = 1200;
			iframeWidth = 1600;
			String tagAHref = "#TB_inline?height="+iframeHeight+"&amp;width="+(iframeWidth+10)+"&amp;inlineId="+contentID;
			ohtml = thickBoxA(innerTEXT, tagAHref, allowDownload);
			if (loadedThickBox == false)
			{
				ohtml = ohtml + "<div class=\""+this.tagContentClass+"\" style=\"display:none\" id=\""+contentID+"\">";
			
				ohtml = ohtml + doAudioPlayer(internalPath, iframeWidth, iframeHeight, true);
			}
			ohtml = ohtml + "</div>";
		}
		this.loadedThickBox = true;
		return ohtml;

	}	//public String doThickBox(String innerTEXT, int iframeWidth, int iframeHeight, boolean allowDownload)
	
	private String dialogTagA(String innerTEXT, String contentID)
	{
		return "<a onclick=\"return openDialog(\'"+contentID+"\');\" href=\"#\" class=\""+this.tagAClass+" "+contentID+"_a\" >"+innerTEXT+"</a>";
	}
	
	public String doDialog()
	{
		this.isDialog = true;
		String innerTEXT = doThumbnail();
		return doDialog(innerTEXT);
	}
	
	public String doDialog(String innerTEXT)
	{
		this.isDialog = true;
		boolean allowDownload = this.allowDownload;
		
		return doDialog(innerTEXT, allowDownload);
	}
	
	public String doDialog(String innerTEXT, boolean allowDownload)
	{
		this.isDialog = true;
		int iframeWidth = getWidthByDisplayType();
		int iframeHeight = getHeightByDisplayType();
		return doDialog(innerTEXT, iframeWidth, iframeHeight, allowDownload);
	}
	
	public String doDialog(String innerTEXT, int iframeWidth, int iframeHeight)
	{
		boolean allowDownload = this.allowDownload;
		return doDialog(innerTEXT, iframeWidth, iframeHeight, allowDownload);
	}
	
	public String doDialog(String innerTEXT, int iframeWidth, int iframeHeight, boolean allowDownload)
	{
		if (this.bitstream == null
			&& (this.displayType.equals("webpages") == false && this.displayType.equals("iframe") == false && this.internalBitstream == null))
			return "";
		
		if (this.displayType.equals("download")
			|| (this.displayType.equals("webpage") == false && !hasSnap() && !hasInternal()))
		{
			return tagA(innerTEXT, this.originalPath);
		}
		
		
		
		String ohtml = "";
		String contentID = this.tagContentIDPrefix + this.bitstream.getID();
		
		ohtml = dialogTagA(innerTEXT, contentID);
		
		if (this.loadedJQueryUI == true)
			return ohtml;
		
		ohtml = ohtml + dialogContentHeader(contentID);
		
		if (this.displayType.equals("video"))
		{
			if (hasInternal() == true)
			{
				String internalPath = "";
				if (this.internalBitstream != null)
					internalPath = getRetrievePath(this.internalBitstream.getID());
				
				ohtml = ohtml + doVideoPlayer(internalPath, iframeWidth, iframeHeight, true);
			}
			else
			{
				ohtml = ohtml + getSnapImage(iframeWidth, iframeHeight);
			}
			
			ohtml = ohtml + dialogContentFooter();
			
			if (this.internalBitstream == null)
				ohtml = ohtml + this.bitstream.getID();
			
			if (allowDownload && this.mobileBitstream != null)
				iframeWidth = iframeWidth + 40;
			
			ohtml = ohtml + dialogConfig(contentID, iframeWidth, (iframeHeight+20), "false", allowDownload);
		}
		else if (this.displayType.equals("image"))
		{
			if (hasInternal() == true)
			{
				int id = this.internalBitstream.getID();
				String internalPath = getRetrieveZIPPath(id);
				
				ohtml = ohtml + doImageViewer(contentID, internalPath, iframeWidth, iframeHeight);
			}
			else
			{
				ohtml = ohtml + "?" + doSnap(iframeWidth, iframeHeight);
			}
			ohtml = ohtml + dialogContentFooter();
			ohtml = ohtml + dialogConfig(contentID, (iframeWidth+10), (iframeHeight+10), "false", allowDownload);
		}
		else if (this.displayType.equals("webpage"))
		{
			int id = this.bitstream.getID();
			//String internalPath = getRetrieveZIPPath(id) + "/" + this.zipIndexPath;
			String internalPath = getRetrieveAssetstorePath(id) + "/" + this.zipIndexPath;
			//iframeHeight = 974;
			//iframeWidth = 1280;
			ohtml = ohtml + doIframe(internalPath, iframeWidth, iframeHeight);
			ohtml = ohtml + dialogContentFooter();
			ohtml = ohtml + dialogConfig(contentID, iframeWidth, (iframeHeight+25), "false", allowDownload);
		}
		else if (this.displayType.equals("audio"))
		{
			if (hasInternal() == true)
			{
				String internalPath = getRetrievePath(this.internalBitstream.getID());
				ohtml = ohtml + doAudioPlayer(internalPath, iframeWidth, iframeHeight, true);
			}
			else
			{
				ohtml = ohtml + "This File Cannot Preview";
			}
			ohtml = ohtml + dialogContentFooter();
			ohtml = ohtml + dialogConfig(contentID, iframeWidth, (iframeHeight+5), "false", allowDownload);
		}
		else if (this.displayType.equals("pdf"))
		{
			if (hasInternal() == true)
			{
				String internalPath = getRetrievePath(this.internalBitstream.getID());
				//ohtml = ohtml + doIframe(internalPath, iframeWidth, iframeHeight);
				ohtml = ohtml + doPDF2SWF(internalPath, iframeWidth, iframeHeight);
			}
			else
			{
				ohtml = ohtml + getSnapImage(iframeWidth, iframeHeight);
			}
			ohtml = ohtml + dialogContentFooter();
			ohtml = ohtml + dialogConfig(contentID, iframeWidth, iframeHeight, "false", allowDownload);
		}
		else if (this.displayType.equals("smallimage"))
		{
			ohtml = ohtml + doSwfPicture(getRetrievePath(this.bitstream.getID()), iframeWidth, iframeHeight);
			ohtml = ohtml + dialogContentFooter();
			ohtml = ohtml + dialogConfig(contentID, iframeWidth, iframeHeight, "false", allowDownload);
		}
		else	// if (this.displayType.equals("iframe"))
		{
			String internalPath = this.originalPath;
			ohtml = ohtml + doIframe(internalPath, iframeWidth, iframeHeight);
			ohtml = ohtml + dialogContentFooter();
			ohtml = ohtml + dialogConfig(contentID, iframeWidth, iframeHeight + 25, "false", allowDownload);
		}
		
		this.loadedJQueryUI = true;

		return ohtml;
	}	//public String doDialog(String innerTEXT, int iframeWidth, int iframeHeight, boolean allowDownload)
	
	public String linkDownload(String innerTEXT)
	{
		return tagA(innerTEXT, this.originalPath);
	}
	
	public String dialogContentHeader(String contentID)
	{
		
		String ohtml = "\n<div style=\"display:none;overflow: hidden;\" class=\""+this.tagContentClass+" "+contentID+"\"";

		String title = this.bitstream.getName();
		ohtml = ohtml + " title=\""+title+"\" ";
			
		//ohtml = ohtml + " id=\">\n";
		ohtml = ohtml +">\n";
		ohtml = ohtml + "<textarea class=\"html\" style=\"display:none;\">";
		return ohtml;
	}
	
	public String dialogContentFooter()
	{
		String ohtml = "</textarea>\n</div>\n";
		return ohtml;
	}
	
	public String dialogConfig(String contentID, int width, int height, String resizable, boolean allowDownload)
	{
		String mobileConfig = "";
		if (this.mobileBitstream != null)
			mobileConfig = ", \""+getRetrievePath(this.mobileBitstream.getID()) + "/" + this.mobileBitstream.getName() +"\"";
		
		String ohtml = "\n<script type=\"text/javascript\">\n"
			// + "jQuery(document).ready(function () {\n"
			 + "	setDialog(\""+contentID+"\", \""+width+"\", \""+height+"\", \""+resizable+"\", \""+allowDownload+"\", \""+this.originalPath+"\""+mobileConfig+"); \n"
			// + "});\n"
			 + "</script>\n";
		return ohtml;
	}
	
	public String doPreview()
	{
		int w = getWidthByDisplayType();
		int h = getHeightByDisplayType();
		return doPreview(w, h);
	}
	
	public String doPreview(int w, int h)
	{
		if (this.displayType.equals("audio"))
			return doAudioPlayer(w, h);
		else if (this.displayType.equals("image"))
			return doImageViewer(w, h);
		else if (this.displayType.equals("video"))
			return doVideoPlayer(w, h);
		else if (this.displayType.equals("pdf"))
			return doPDF2SWF(w, h);
		else if (this.displayType.equals("iframe") || this.displayType.equals("webpage"))
			return doIframe(w, h);
		else if (this.displayType.equals("smallimage"))
			return doSwfPicture(w, h);
		else
			return fileNotFound();
	}
	
	public String doLink()
	{
		String link = doThumbnail();	//this.bitstream.getName();
		if (this.allowDownload == true)
		{
			String p = getRetrievePath(this.bitstream.getID()) + "/" + this.bitstream.getName();
			return "<a href=\""+p+"\">"+link+"</a>";
		}
		else
			return link;
	}
	
	public String doLink(String link)
	{
		if (this.allowDownload == true)
		{
			String p = getRetrievePath(this.bitstream.getID()) + "/" + this.bitstream.getName();
			return "<a href=\""+p+"\">"+link+"</a>";
		}
		else
			return link;
	}
	
	public String getState()
	{
		String output = this.displayType+":";
		
		
		if (this.bitstream != null)
		{
			output = output + "[" + this.bitstream.getID() + "]";
		}
		if (this.hasInternal())
			output = output + "i";
		if (this.hasThumbnail())
			output = output + "t";
		if (this.hasSnap())
			output = output + "s";
		if (allowDownload == true)
			output = output + ":d";
		return output;
	}
	
	public String doDialogWithFilename()
	{
		return doDialogWithFilename(true);
	}
	
	public String doDialogWithFilename(boolean needThumbnail)
	{
		String output = "";
		if (needThumbnail == true && hasThumbnail())
			output = doThumbnail(80, 80) + "<br />";
		output = output + getFormatFilename();
		
		output = doDialog(output);
		writeLog(getState());
		output = output;
		
		return output;
		
	}
	
	public String getFormatFilename()
	{
		if (this.bitstream == null)
			return "no file";
		else
		{
			Bitstream bs = this.bitstream;
			return bs.getName()
				+ " ("+getFormatDescription()+", "+getFormatSize()+")";
		}
	}
	
}	//public class BitstreamDisplay