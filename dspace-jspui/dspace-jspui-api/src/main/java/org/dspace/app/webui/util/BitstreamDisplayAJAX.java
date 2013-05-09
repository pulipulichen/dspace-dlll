/*
 * BitstreamDisplayAJAX.java
 */
package org.dspace.app.webui.util;

import javax.servlet.http.HttpServletRequest;
import org.dspace.app.webui.util.UIUtil; 
import org.dspace.content.Collection; 
import org.dspace.content.Community; 
import org.dspace.content.DCValue; 
import org.dspace.content.Item; 
import org.dspace.core.ConfigurationManager; 
import org.dspace.handle.HandleManager; 
import org.dspace.license.CreativeCommons; 
import java.io.File; 
import java.util.Date; 
import org.dspace.app.webui.util.ItemEditButton; 
import javax.servlet.jsp.JspWriter; 
import org.dspace.app.webui.components.RecentSubmissions; 
import org.dspace.app.webui.components.RecentSubmissionsManager; 
import org.dspace.app.util.XMLMetadata; 
import java.net.URLDecoder; 
import org.apache.commons.lang.StringEscapeUtils; 
import org.dspace.app.webui.util.ItemEditButton; 
import org.dspace.eperson.EPerson; 
import org.dspace.eperson.Group; 
import org.dspace.core.Context; 
import org.dspace.core.ConfigurationManager; 
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
import java.io.UnsupportedEncodingException; 
import java.util.Arrays; 
import org.dspace.app.webui.util.FilteredBitstreamGetter;
import javax.servlet.http.HttpServletRequest;
public class BitstreamDisplayAJAX
{
	//private Logger log = Logger.getLogger(BitstreamDisplayAJAX.class);
	
	private String contextPath;
	private Bitstream rawBitstream;
	private int rawBitstreamID = -1;
	private Item mainItem;
	private String innerTEXT;
	private String innerMode = "DETAIL";
	private boolean downloadable = true;
	private boolean useDialog = false;
	private Context bContext;
	private boolean callPreview = false;
	
	private String width;
	private String height;
	
	private static final String classnameLink = "bitstream-display-link";
	private static final String classnameDialog = "bitstream-display-dialog";
	
	private String[] ZoomifyFilterInputFormats = new String[0];
	private String[] Video2FLVInputFormats = new String[0];
	private String[] Doc2AlbumInputFormats = new String[0];
	private String[] Audio2MP3InputFormats = new String[0];
	private String[] IframeInputFormats = new String[0];
	
	private HttpServletRequest request;
		
	//private ArrayList<String> MediaFilterInputFormats = new ArrayList<String>();	//不需要
	
	public BitstreamDisplayAJAX(HttpServletRequest requestIn, String bitstreamURI) throws SQLException
	{
		this.request = requestIn;
		parseBitstreamRetrieveID(bitstreamURI);
	}
	public BitstreamDisplayAJAX(HttpServletRequest requestIn, Item itemIn, String bitstreamURI) throws SQLException
	{
		this.request = requestIn;
		parseBitstreamRetrieveID(bitstreamURI);
		setItem(itemIn);
	}
	public BitstreamDisplayAJAX(HttpServletRequest requestIn, Context c, String bitstreamURI) throws SQLException
	{
		this.request = requestIn;
		parseBitstreamRetrieveID(bitstreamURI);
		bContext = c;
	}
	public BitstreamDisplayAJAX(HttpServletRequest requestIn, String bitstreamURI, Context c, Item itemIn) throws SQLException
	{
		this.request = requestIn;
		bContext = c;
		parseBitstreamRetrieveID(bitstreamURI);
		setItem(itemIn);
	}
	public BitstreamDisplayAJAX(HttpServletRequest requestIn, String bitstreamURI, HttpServletRequest request, Item itemIn) throws SQLException
	{
		this.request = requestIn;
		bContext = UIUtil.obtainContext(request);
		parseBitstreamRetrieveID(bitstreamURI);
		setItem(itemIn);
	}
	
	//---------------------------------------------
	
	public void setItem(Item itemIn)
	{
		this.mainItem = itemIn;
	}
	
	public void setInnerTEXT(String innerIn)
	{
		this.innerTEXT = innerIn;
	}
	
	public void setInnerMode(String modeIn)
	{
		this.innerMode = modeIn.toUpperCase();
	}
	
	public void setDownloadable(boolean flag)
	{
		this.downloadable = flag;
	}
	
	public void setAllowDownload(boolean flag)
	{
		this.downloadable = flag;
	}
	
	public void setUseDialog(boolean flag)
	{
		this.useDialog = flag;
	}
	public void setPermission(boolean downloadableFlag, boolean useDialogFlag)
	{
		this.downloadable = downloadableFlag;
		this.useDialog = useDialogFlag;
	}
	
	public void setWidth(String widthIn)
	{
		this.width = widthIn;
	}
	
	public String getWidth()
	{
		return getWidth(null);
	}
	
	public String getWidth(String defaultValue)
	{
		if (width == null)
			this.width = defaultValue;
		return width;
	}
	
	public void setHeight(String heightIn)
	{
		this.height = heightIn;
	}
	
	public String getHeight()
	{
		return getHeight(null);
	}
	
	public String getHeight(String defaultValue)
	{
		if (height == null)
			this.height = defaultValue;
		return height;
	}
	
	public void setCallPreview(boolean flag)
	{
		this.callPreview = flag;
	}
	
	private boolean videoAutoplayFlag = true;
	private boolean videoAutoloadFlag = true;
	private boolean videoShowstopFlag = true;
	private boolean videoShowvolumeFlag = true;
	private boolean videoShowtimeFlag = true;
	private boolean videoShowfullscreenFlag = true;
	private String videoBgcolor1 = "FFFFFF";
	private String videoBgcolor2 = "FFFFFF";
	private String videoPlayercolor = "666666";
	
	public void setVideoPlayerConfig(String field, boolean value)
	{
		field = field.toLowerCase();
		if (field.equals("autoplay"))
			this.videoAutoplayFlag = value;
		else if (field.equals("autoload"))
			this.videoAutoloadFlag = value;
		else if (field.equals("showstop"))
			this.videoShowstopFlag = value;
		else if (field.equals("showvolume"))
			this.videoShowvolumeFlag = value;
		else if (field.equals("showtime"))
			this.videoShowtimeFlag = value;
		else if (field.equals("showfullscreen"))
			this.videoShowfullscreenFlag = value;
	}
	
	public void setVideoPlayerConfig(String field, String value)
	{
		field = field.toLowerCase();
		if (field.equals("bgcolor1"))
			this.videoBgcolor1 = value;
		else if (field.equals("bgcolor2"))
			this.videoBgcolor2 = value;
		else if (field.equals("playercolor"))
			this.videoPlayercolor = value;
	}
	
	public String getVideoConfig(String field)
	{
		field = field.toLowerCase();
		String output = null;
		if (field.equals("bgcolor1"))
			output = this.videoBgcolor1;
		else if (field.equals("bgcolor2"))
			output = this.videoBgcolor2;
		else if (field.equals("playercolor"))
			output = this.videoPlayercolor;
		else if (field.equals("autoplay"))
		{
			if (this.videoAutoplayFlag == true)
				output = "1";
			else
				output = "0";
		}
		else if (field.equals("autoload"))
		{
			if (this.videoAutoloadFlag == true)
				output = "1";
			else
				output = "0";
		}
		else if (field.equals("showstop"))
		{
			if (this.videoShowstopFlag == true)
				output = "1";
			else
				output = "0";
		}
		else if (field.equals("showvolume"))
		{
			if (this.videoShowvolumeFlag == true)
				output = "1";
			else
				output = "0";
		}
		else if (field.equals("showtime"))
		{
			if (this.videoShowtimeFlag == true)
				output = "1";
			else
				output = "0";
		}
		else if (field.equals("showfullscreen"))
		{
			if (this.videoShowfullscreenFlag == true)
				output = "1";
			else
				output = "0";
		}
		
		return output;
	}
	
	private boolean audioAutoplay = true;
	public void setAudioConfig(String field, boolean value)
	{
		field = field.toLowerCase();
		if (field.equals("autoplay"))
		{
			this.audioAutoplay = value;
		}
	}
	public String getAudioConfig(String field)
	{
		String output = null;
		field = field.toLowerCase();
		if (field.equals("autoplay"))
		{
			if (this.audioAutoplay)
				output = "true";
			else
				output = "false";
		}
		return output;
	}
	
	private final int smallImageWidth = 300;
	private final int smallImageHeight = 300;
	public boolean isSmallImage(Bitstream bitstream)
	{
		try
		{
			InputStream source = bitstream.retrieve();
			BufferedImage buf = ImageIO.read(source);
			int xsize = 0;
			int ysize = 0;
	        try
	        {
	        	xsize = buf.getWidth();
	        	ysize = buf.getHeight();
	        }
	        catch (Exception e)
	        {
	        }
	        if (xsize < smallImageWidth && ysize < smallImageHeight)
	        	return true;
	        else
				return false;
		}
		catch (Exception e)
		{
			return true;
		}
	}
	
	private String parseZIPWebpage(Bitstream bitstream)
	{
		if (bitstream.getMIMEType().equals("application/zip") == false)
			return null;
		
		//&#748;dO_index.html index.htm default.html default.html
		String zipIndexPath = null;
		
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
				zipIndexPath = indexPath;
			}
			else if (indexPath2 != null)
			{
				zipIndexPath = indexPath2;
			}
			
			if (zipIndexPath.lastIndexOf("/") > -1)
			{
				String zipName = zipIndexPath.substring(zipIndexPath.lastIndexOf("/") + 1, zipIndexPath.length());
				
				for (int i = 0; i < indexName.length; i++)
				{
					if (indexName[i].equals(zipName))
					{
						zipIndexPath = zipIndexPath.substring(0, zipIndexPath.lastIndexOf("/") + 1);
						break;
					}
				}
			}
		}
		catch (Exception e) {
			//do nothing
		}
		finally
		{
			return zipIndexPath;
		}
	}
	
	public String getRetrievePath(Bitstream bitstream)
	{
		return getRetrievePath(bitstream, true);
	}
	
	public String getRetrievePath(Bitstream bitstream, boolean includeFilename)
	{
		int bitstreamID = bitstream.getID();
		String path = this.contextPath + "retrieve/" + bitstreamID;
		
		if (includeFilename == true)
		{
			path = path + "/";
			String name = bitstream.getName();
			try
			{
				path = path + UIUtil.encodeBitstreamName(name,
	                        Constants.DEFAULT_ENCODING);
			}
			catch (UnsupportedEncodingException e)
			{
				String extension = "";
				if (name.lastIndexOf(".") != -1)
				{
					extension = name.substring(name.lastIndexOf(".") + 1 , name.length());
				}
				path = path + bitstream.getID() + extension;
			}
			finally
			{
				return path;
			}
		}
		else
		{
			return path;
		}
	}
	
	public String getRetrievePathZIP(Bitstream bitstream)
	{
		if (bitstream == null)
			return null;
		int bitstreamID = bitstream.getID();
		String path = this.contextPath + "retrieve-zip/" + bitstreamID 
			+ "/";
		return path;
	}
	
	private String assetstoreHTTPPath;
	
	private String getAssetstoreHTTP()
	{
		if (assetstoreHTTPPath == null)
		{
			this.assetstoreHTTPPath = "http://"+request.getServerName()
				+ ":" + ConfigurationManager.getProperty("http.port", "50080")
				+ ConfigurationManager.getProperty("assetstore.http.retrieve", "/assetstore");
		}
		
		return this.assetstoreHTTPPath;
	}
	
	public String getRetrieveAssetstorePath(Bitstream bitstream)
	{
		String assetstoreHTTP = getAssetstoreHTTP();
		if (assetstoreHTTP == null)
			return null;
		
		String iid = bitstream.getInternalID();
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
	
	public String getRetrieveZIPPath(Bitstream bitstream)
	{
		return this.contextPath + "/retrieve-zip/" + bitstream.getID();
	}
	
	public String getPlayerPath(String player)
	{
		return this.contextPath + "extension/bitstream-display/" + player;
	}
	
	public String callPreview(Bitstream bitstream, String width, String height)
	{
		if (width == null)
			width = "100%";
		if (height == null)
			height = "100%";
		
		String src = getPreviewPath(bitstream);
		return "<iframe src=\""+src+"?width="+width+"&height="+height+"\" width=\""+width+"\" height=\""+height+"\" style=\"background-color:transparent;\" frameborder=\"0\"></iframe>";
	}
	
	public String getPreviewPath(Bitstream bitstream)
	{
		return this.contextPath + "/preview/" + bitstream.getID();
	}
	
	//----------------------------------------------
	
	public Context getContext() throws SQLException
	{
		if (this.bContext == null)
		{
			this.bContext = new Context();
		}
		return bContext;
	}
	
	public Context getContext(HttpServletRequest request) throws SQLException
	{
		if (this.bContext == null)
		{
			this.bContext = UIUtil.obtainContext(request);
			if (this.bContext == null)
				this.bContext = new Context();
		}
		return bContext;	
	}	
	
	public Item getItemByRawBitstream() throws SQLException
	{
		//延遲實體化，獨體模式
		if (this.mainItem == null)
		{
			Bitstream bs = getRawBitstream();
			Bundle[] bundles = bs.getBundles();
			if (bundles.length > 0)
			{
				Item[] items = bundles[0].getItems();
				if (items.length > 0)
					this.mainItem = items[0];
			}
		}
		return mainItem;
	}
	
	public Bitstream getRawBitstream() throws SQLException
	{
		//延遲實體化
		if (rawBitstream == null && rawBitstreamID != -1)
		{
			Item item = this.mainItem;
			if (item != null)
			{
				Bundle[] bundles = item.getBundles("ORIGINAL");
				for (int i = 0; i < bundles.length; i++)
				{
					this.rawBitstream = bundles[i].getBitstreamByID(rawBitstreamID);
					if (rawBitstream != null)
					{
						break;
					}
				}
			}
			else	//if (item == null)
			{
				Context c = getContext();
				this.rawBitstream = Bitstream.find(c, rawBitstreamID);
			}
		}
		return rawBitstream;
	}
	
	public Bitstream getBitstream() throws SQLException
	{
		return getRawBitstream();
	}
	
	public String getFormatSize(Bitstream bitstream)
	{
		if (bitstream == null)
			return "";
		else
		{
			long size = bitstream.getSize();
			return UIUtil.formatFileSize(size);
		}
	}
	
	//--------------------------------------
	
	public String getInnerDetail() throws SQLException
	{
		Bitstream bs = getRawBitstream();
		return bs.getName()
				+ " ("+bs.getFormatDescription()+", "+ getFormatSize(bs) +")";
	}
	
	public String getInner() throws SQLException
	{
		return getInner(true);
	}
	
	public String getInner(boolean showDetail) throws SQLException
	{
		//log.info("getInner()1: "+innerMode);
		
		if (innerTEXT == null && innerMode.equals("DETAIL"))
		{
			this.innerTEXT = getInnerDetail();
		}
		if (innerTEXT == null && innerMode != null)
		{
			if (innerMode.equals("FILENAME"))
			{
				Bitstream bs = getRawBitstream();
				this.innerTEXT = bs.getName();
			}
			else if (innerMode.equals("IFRAME"))
			{
				this.innerTEXT = getBitstreamDisplay(getRawBitstream(), innerMode);
			}
			else if (this.callPreview == true)
			{
				this.innerTEXT = getBitstreamDisplay(getRawBitstream(), "PREVIEW");
			}
			else if (innerMode.equals("SNAP")
				|| innerMode.equals("THUMBNAIL")
				|| innerMode.equals("PDF2SWF_PREVIEW")
				|| innerMode.equals("DOC_PREVIEW")
				|| innerMode.equals("VIDEO_PREVIEW")
				|| innerMode.equals("VIDEO_MOBILE")
				|| innerMode.equals("AUDIO_PREVIEW")
				|| innerMode.equals("ZOOMIFY"))
			{
				//log.info("getInner()2: "+innerMode);
				Item item = getItemByRawBitstream();
				if (item != null)
				{
					//log.info("getInner()3: "+innerMode);
					Bitstream bs = getRawBitstream();
					Bundle[] identifier = item.getBundles(this.innerMode);
					//log.info("getInner()4: "+innerMode);
					Bitstream[] filtereds = new Bitstream[0];
					boolean smallImage = false;
					
					if (innerMode.equals("ZOOMIFY") == false)
					{
						filtereds = FilteredBitstreamGetter.findFilteredBitstream(getContext(), bs, identifier);
					}
					else	//if (innerMode.equals("ZOOMIFY") == true)
					{
						//if (isSmallImage(bs) == false)
						//	filtereds = FilteredBitstreamGetter.findFilteredBitstream(getContext(), bs, identifier);
						//else
						//{
						//	Bundle[] snapIdentifier = item.getBundles("SNAP");
						//	filtereds = FilteredBitstreamGetter.findFilteredBitstream(getContext(), bs, snapIdentifier);
						//}
						if (isSmallImage(bs) == true)
							smallImage = true;
						filtereds = FilteredBitstreamGetter.findFilteredBitstream(getContext(), bs, identifier);
					}
					
					if (filtereds.length == 0)
					{
						if (innerMode.equals("DOC_PREVIEW") == true)
						{
							innerMode = "PDF2SWF_PREVIEW";
							Bundle[] altIdentifier = item.getBundles(innerMode);
							filtereds = FilteredBitstreamGetter.findFilteredBitstream(getContext(), bs, altIdentifier);
						}
						else if (innerMode.equals("PDF2SWF_PREVIEW") == true)
						{
							innerMode = "DOC_PREVIEW";
							Bundle[] altIdentifier = item.getBundles(innerMode);
							filtereds = FilteredBitstreamGetter.findFilteredBitstream(getContext(), bs, altIdentifier);
						}
					}
					
					if (filtereds.length > 0)
					{
						//log.info("getInner()5: "+innerMode);
						this.innerTEXT = getBitstreamDisplay(filtereds[0], innerMode, smallImage);
					}
					else
					{
						Bundle[] snapIdentifier = item.getBundles("SNAP");
						for (int i = 0; i < snapIdentifier.length; i++)
						{
							Bitstream[] snapFiltereds = FilteredBitstreamGetter.findFilteredBitstream(getContext(), bs, snapIdentifier[i]);
							if (snapFiltereds.length > 0)
							{
								this.innerTEXT = getBitstreamDisplay(snapFiltereds[0], "SMALLIMAGE");
								break;
							}
						}	//for (int i = 0; i < snapIdentifier.length; i++)
					}
					
					//if (identifier.length > 0)
					//{
					//}
				}
			}
		}
		
		if (innerTEXT == null
			&& showDetail)
			this.innerTEXT = getInnerDetail();
		
		return innerTEXT;
	}
	
	public String getBitstreamDisplay(Bitstream bitstream, String mode)
	{
		return getBitstreamDisplay(bitstream, mode, true);
	}
	
	public String getBitstreamDisplay(Bitstream bitstream, String mode, boolean smallImage)
	{
		String output = "";
		if (mode.equals("SNAP")
			|| mode.equals("THUMBNAIL"))
		{
			String w = getWidth();
			String h = getHeight();
			if (innerMode.equals("THUMBNAIL"))
			{
				w = getWidth(ConfigurationManager.getProperty("webui.browse.thumbnail.maxwidth", "80") + "px");
				h = getHeight(ConfigurationManager.getProperty("webui.browse.thumbnail.maxheight", "80") + "px");
			}
			
			String styleW = null;
			String styleH = null;
			if (w != null)
				styleW = "width: "+w+";";
			if (h != null)
				styleH = "height: "+h+";";
			
			String style = "";
			if (styleW != null || styleH != null)
			{
				style = "style=\""+styleW+styleH+"\" ";
			}
			
			String src = getRetrievePath(bitstream);
			String size = "";
			if (w != null && w.equals("null") == false)
			{
				if (w.substring(w.length()-2, w.length()).equals("px"))
					w = w.substring(0, w.length()-2);
				size = "width="+w;
			}
			if (h != null && h.equals("null") == false)
			{
				if (h.substring(h.length()-2, h.length()).equals("px"))
					h = h.substring(0, h.length()-2);
				
				if (size.equals("") == false)
					size = size + "&";
				size = size + "height="+h;
			}
			
			if (size.equals("") == false)
				src = src + "?" + size + "&"+getWidth()+"="+getHeight();
			
			output = "<img src=\""+src+"\" border=\"0\" />";
		}	//if (innerMode.equals("SNAP")
		else if (mode.equals("PDF2SWF_PREVIEW"))
		{
			String w = getWidth("640");
			String h = getHeight("480");
			
			if (this.callPreview == false)
			{
				String path = getRetrievePath(bitstream);
				if (path != null)
				{
					output = "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" \n"
							+ "	width=\""+w+"\" \n"
							+ "	height=\""+h+"\" \n"
							+ "	codebase=\"http://active.macromedia.com/flash5/cabs/swflash.cab#version=8,0,0,0\"> \n"
							+ "	<param name=\"MOVIE\" value=\""+path+"\"> \n"
							+ "	<param name=\"PLAY\" value=\"true\"> \n"
							+ "	<param name=\"LOOP\" value=\"true\"> \n"
							+ "	<param name=\"QUALITY\" value=\"high\"> \n"
							+ "	<embed src=\""+path+"\" width=\""+w+"\" height=\""+h+"\" \n"
							+ "		play=\"true\" align=\"center\" loop=\"true\" quality=\"high\" \n"
							+ "		type=\"application/x-shockwave-flash\" \n"
							+ "		style=\"font-size: 0;line-height: 0;\" \n"
							+ "		pluginspage=\"http://www.macromedia.com/go/getflashplayer\"> \n"
							+ "	</embed> \n"
							+ "</object> \n";
				}
				else
					output = null;
			}
			else
			{
				output = callPreview(bitstream, w, h);
			}
		}	//else if (innerMode.equals("PDF2SWF_PREVIEW"))
		else if (mode.equals("DOC_PREVIEW"))
		{
			String w = getWidth("640");
			String h = getHeight("480");
			
			if (this.callPreview == false)
			{
				String path = getRetrievePath(bitstream);
				if (path != null)
				{
					output = "<div class=\"zoomify-album-container id"+bitstream.getID()+"\"></div>\n"
						+ "<script type=\"text/javascript\">\n"
						+ "ZoomifyAlbum.setup();\n"
						+ "</script>";
				}
				else
					output = null;
			}
			else
			{
				output = callPreview(bitstream, w, h);
			}
		}	//else if (innerMode.equals("PDF2SWF_PREVIEW"))
		else if (mode.equals("VIDEO_PREVIEW")
			|| mode.equals("VIDEO_MOBILE"))
		{
			String w = getWidth("320");
			String h = getHeight("240");
			
			if (this.callPreview == false)
			{
				String internalPath = getRetrievePath(bitstream, false);
				if (internalPath != null)
				{
					String player = getPlayerPath("player_flv_maxi.swf");
					
					output = "<object class=\"playerpreview\" \n"
						+ "		type=\"application/x-shockwave-flash\" data=\""+player+"\" \n"
						+ "		style=\"font-size: 0;line-height: 0;\" \n"
						+ "		width=\""+w+"\" height=\""+h+"\"> \n"
						+ "	<param name=\"movie\" value=\""+player+"\" /> \n"
						+ "	<param name=\"allowFullScreen\" value=\"true\" /> \n"
						+ "	<param name=\"FlashVars\" \n"
						+ "		value=\"flv="+internalPath+"&width="+w+"&height="+h
						+ "&autoplay=" + getVideoConfig("autoplay")
						+ "&autoload=" + getVideoConfig("autoload")
						+ "&showstop=" + getVideoConfig("showstop")
						+ "&showvolume=" + getVideoConfig("showvolume")
						+ "&showtime=" + getVideoConfig("showfullscreen")
						+ "&showfullscreen=" + getVideoConfig("showfullscreen") 
						+ "&bgcolor1=" + getVideoConfig("bgcolor1")
						+ "&bgcolor2=" + getVideoConfig("bgcolor2") 
						+ "&playercolor=" + getVideoConfig("playercolor") 
						+ "\" /> \n"
						//+ "	<param name=\"wmode\" value=\"transparent\"> \n"
						+ "</object> \n";
				}
				else
					output = null;
			}
			else
			{
				output = callPreview(bitstream, w, h);
			}
		}
		else if (mode.equals("AUDIO_PREVIEW"))
		{
			String w = getWidth("320");
			String h = getHeight("15");
			
			if (this.callPreview == false)
			{
				String internalPath = getRetrievePath(bitstream);
				if (internalPath != null)
				{
					String playerPath = getPlayerPath("xspf_player_slim.swf");
					
					output = "<object type=\"application/x-shockwave-flash\" \n"
							+ "	data=\""+playerPath+"?&song_url="+internalPath+"&autoplay="+getAudioConfig("autoplay")+"\""
							+ "	style=\"font-size: 0;line-height: 0;\" \n"
							+ "	width=\""+w+"\" height=\""+h+"\">"
							+ "		<param name=\"movie\" "
							+ "			value=\""+playerPath+"?&song_url="+internalPath+"&autoplay="+getAudioConfig("autoplay")+"\" />"
							//+ "		<param name=\"wmode\" value=\"transparent\">\n"
							+ "</object>";
				}
				else
					output = null;
			}
			else
			{
				output = callPreview(bitstream, w, h);
			}
		}
		else if (mode.equals("ZOOMIFY"))
		{
				String w = getWidth("640");
				String h = getHeight("480");
				try
				{
					int intH = Integer.parseInt(h);
					intH = intH - 10;
					h = intH + "";
				}
				catch (Exception e) { }
				
				if (this.callPreview == false)
				{
					String internalPath = getRetrievePathZIP(bitstream);
					if (internalPath != null)
					{
						String contentID = "bitstream_" + bitstream.getID();
						String viewerPath = getPlayerPath("zoomifyViewer.swf");
						
						String navigatorVisible = "true";
						if (smallImage == true)
							navigatorVisible = "false";
						
						output = "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0\" \n"
								+ "	style=\"font-size: 0;line-height: 0;border:1px solid #CCCCCC;\" \n"
								+ "	width=\""+w+"\" height=\""+h+"\" id=\""+contentID+"_zoomify\"> \n"
			        			+ "		<param name=\"FlashVars\" value=\"zoomifyImagePath="+internalPath+"/&zoomifyNavigatorVisible=true\"> \n"
					        	+ "		<param name=\"BGCOLOR\" value=\"#FFFFFF\"> \n"
			        			+ "		<param name=\"MENU\" value=\"true\"> \n"
								+ "		<param name=\"SRC\" value=\""+viewerPath+"\"> \n"
								//+ "		<param name=\"wmode\" value=\"transparent\">\n"
								+ "		<embed flashvars=\"zoomifyImagePath="+internalPath+"/&zoomifyNavigatorVisible="+navigatorVisible+"\" \n"
			                	+ "			src=\""+viewerPath+"\" bgcolor=\"#FFFFFF\" menu=\"true\" pluginspage=\"http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash\" \n"
			            		+ "			style=\"font-size: 0;line-height: 0;border:1px solid #CCCCCC;\" \n"
			            		//+ "			wmode=\"transparent\"\n"
			                	+ "			width=\""+w+"\" height=\""+h+"\" name=\""+contentID+"_zoomify\"></embed> \n"
			    				+ "</object> \n";
			    	}
			    	else
			    	{
			    		output = null;
			    	}
		    	}
		    	else
				{
					output = callPreview(bitstream, w, h);
				}
		}
		else if (mode.equals("SMALLIMAGE"))
		{
			String w = getWidth("300");
			String h = getHeight("300");
			
			String internalPath = getRetrievePath(bitstream, false);
				internalPath = internalPath + "?width=" + w + "&height=" + h;
			String viewerPath = getPlayerPath("swfoto.swf");
			
			//output = "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0\"" 
			//	+ " width=\""+w+"\" height=\""+h+"\">" 
			//	+ "<param name=\"movie\" value=\"" + viewerPath + "?image="+internalPath+"\">" 
			//	+ "<embed src=\"" + viewerPath + "?image="+internalPath+"\" width=\""+w+"\" height=\""+h+"\" "
			//	+ "pluginspage=\"http://www.macromedia.com/go/getflashplayer\" type=\"application/x-shockwave-flash\">"
			//	+ "</embed></object>";
			output = "<div style=\"width: "+w+"px; height: "+h+"px;background-image:url("+internalPath+");background-repeat:no-repeat;\"></div>";
		}
		else if (mode.equals("IFRAME"))
		{
			String internalPath = getRetrievePath(bitstream);
			
			String zipIndexPath = parseZIPWebpage(bitstream);
			if (zipIndexPath != null)
			{
				String assetstore = getRetrieveAssetstorePath(bitstream);
				if (assetstore != null)
					internalPath = assetstore + "/" + zipIndexPath;
				else
					internalPath = getRetrieveZIPPath(bitstream) + "/" + zipIndexPath;
			}
			else
			{
				
			}
			
			String w = getWidth("100%");
			String h = getHeight("600px");
			
			output = "<iframe src=\""+internalPath+"\" "
				+" style=\"width:"+w+";height:"+h+";\" frameborder=\"0\" class=\"bitstream-preview-iframe\"></iframe>";
		}
		return output;
	}
	
	public String getLink(String inner) throws SQLException
	{
		String output = null;
		
		if (inner == null || inner.equals(""))
			return null;
		else if (this.useDialog == true)
		{
			Bitstream bitstream = getRawBitstream();
			int bitstreamID = bitstream.getID();
			String onclick = "bitstreamDisplayDialog("+bitstreamID+", "+this.downloadable+");";
			output = "<span style=\"cursor:pointer;\" onclick=\""+onclick+"\" class=\""+classnameDialog+"\">"+inner+"</span>";
		}
		else
		{
			if (this.downloadable == true)
			{
				Bitstream bitstream = getRawBitstream();
				String link = getRetrievePath(bitstream);
				output = "<a href=\""+link+"\" class=\""+classnameLink+"\">"+inner+"</a>";
			}
			else
			{
				output = inner;
			}
		}
		return output;
	}
	
	//---------------------------------------------
	
	public String toString()
	{
		String output = null;
		try
		{
			String innerString = getInner();
			output = getLink(innerString);
		}
		catch (SQLException e) {
			try
			{
				output = getInner();
			}
			finally
			{
				return output;
			}
		}
		finally
		{
			return output;
		}
	}
	
	//---------------------------------------------
	
	public void parseBitstreamRetrieveID(String idString)
	{
		if (idString.lastIndexOf("retrieve/") == -1)
			return;
		
		String btID = idString.substring(idString.lastIndexOf("retrieve/") + 9
        		, idString.length());
        
        if (btID.indexOf("/") != -1)
        	btID = btID.substring(0, btID.indexOf("/"));
        
        try
        {
         	this.rawBitstreamID = Integer.parseInt(btID);
        }
        catch (Exception e) { }
        
        this.contextPath = idString.substring(0,
        	idString.lastIndexOf("retrieve/"));
	}
	
	public String guessInnerMode(Bitstream bitstream) 
	{
		String mode = null;
		
		String mime = bitstream.getMIMEType();
		
		//暫時用不到副檔名來猜測
		//String extension = null;
		//String filename = bitstream.getName();
		//if (filename.lastIndexOf(".") != -1)
		//	extension = filename.substring(filename.lastIndexOf(".")+1, filename.length());
		
		//先載入猜測時所需要得Filter設定資料
		if (ZoomifyFilterInputFormats.length == 0)
			ZoomifyFilterInputFormats = loadMediaFilterInputFormats(ZoomifyFilterInputFormats, "ZoomifyFilter");
		if (Video2FLVInputFormats.length == 0)
			Video2FLVInputFormats = loadMediaFilterInputFormats(Video2FLVInputFormats, "Video2FLV");
		if (Doc2AlbumInputFormats.length == 0)
			Doc2AlbumInputFormats = loadMediaFilterInputFormats(Doc2AlbumInputFormats, "Doc2Text");	//Doc2Text才有包含Abode PDF
		if (Audio2MP3InputFormats.length == 0)
			Audio2MP3InputFormats = loadMediaFilterInputFormats(Audio2MP3InputFormats, "Audio2MP3");
		if (IframeInputFormats.length == 0)
			IframeInputFormats = loadMediaFilterInputFormats(IframeInputFormats, "Iframe");
		
		
		//先取得bitstream的檔案敘述
		String bitstreamFormat = bitstream.getFormatDescription();

		mode = searchInputFormats(IframeInputFormats, bitstreamFormat, mode, "IFRAME");
		mode = searchInputFormats(ZoomifyFilterInputFormats, bitstreamFormat, mode, "ZOOMIFY");
		mode = searchInputFormats(Video2FLVInputFormats, bitstreamFormat, mode, "VIDEO_PREVIEW");
		mode = searchInputFormats(Doc2AlbumInputFormats, bitstreamFormat, mode, "DOC_PREVIEW");
		mode = searchInputFormats(Audio2MP3InputFormats, bitstreamFormat, mode, "AUDIO_PREVIEW");
		
		if (mode == null)
			mode = "DETAIL";
		
		return mode;
	}
	
	public String[] loadMediaFilterInputFormats(String[] config, String filterName)
	{
		if (config.length == 0)
		{
			String inputFormats = ConfigurationManager.getProperty("filter.org.dspace.app.mediafilter."+filterName+".inputFormats", "null");
			String[] inputFormatsArray = inputFormats.split(",");
			config = new String[inputFormatsArray.length];
			for (int i = 0; i < inputFormatsArray.length; i++)
				config[i] = inputFormatsArray[i].trim();
		}
		return config;
	}
	
	public String searchInputFormats(String[] formats, String needle, String mode, String matchMode)
	{
		if (mode == null)
		{
			//int isMatch = Arrays.binarySearch(formats, needle);
			int isMatch = -1;
			for (int i = 0; i < formats.length; i++)
			{
				if (formats[i].equals(needle))
				{
					isMatch = i;
					break;
				}
			}
			
			if (isMatch == -1)
				return null;
			else
				return matchMode;
		}
		else
			return mode;
	}
	
	//---------------------------------------------
	//facade
	
	public String doPreview(String width, String height) throws SQLException
	{
		//if (width != null)
			setWidth(width);
		//if (height != null)
			setHeight(height);
		
		this.innerMode = guessInnerMode(getRawBitstream());
		this.innerTEXT = null;
		return getInner();
	}
	
	public String doPreview() throws SQLException
	{
		return doPreview(null, null);
	}
	
	public String doSnap(String width, String height) throws SQLException
	{
		//if (width != null)
			setWidth(width);
		//if (height != null)
			setHeight(height);
		
		this.innerMode = "SNAP";
		this.innerTEXT = null;
		return getInner();
	}
	
	public String doSnap() throws SQLException
	{
		return doSnap(null, null);
	}
	
	public String getSnapImage(int w, int h) throws SQLException
	{
		return doSnap(w + "", h + "");
	}
	
	public String doThumbnail(String width, String height, boolean showDetail) throws SQLException
	{
		//if (width != null)
			setWidth(width);
		//if (height != null)
			setHeight(height);
		
		this.innerMode = "THUMBNAIL";
		this.innerTEXT = null;
		String output = getInner(showDetail);
		if (output == null)
			output = "";
		
		return output;
	}
	
	public boolean hasThumbnail() throws SQLException
	{
		String output = doThumbnail(false);
		if (output == null || output.trim().equals("") == true)
			return false;
		else
			return true;
	}
	
	public String doThumbnail(boolean showDetail) throws SQLException
	{
		return doThumbnail(null, null, showDetail);
	}
	
	public String doThumbnail() throws SQLException
	{
		return doThumbnail(null, null, true);
	}
	
	public String doDialog(String text) throws SQLException
	{
		this.innerTEXT = text;
		setUseDialog(true);
		return toString();
	}
	
	public String doDialogWithFilename() throws SQLException
	{
		return doDialogWithFilename(true);
	}
	
	public String doDialogWithFilename(Boolean needThumbnail) throws SQLException
	{
		String text = getFormatFilename();
		if (needThumbnail == true && hasThumbnail())
			text = doThumbnail() + "<br />" + text;
		
		String output = doDialog(text);
		return output;
	}
	
	public String getFormatFilename() throws SQLException
	{
		Bitstream bs = getRawBitstream();
		if (bs == null)
			return "no file";
		else
		{
			return bs.getName()
				+ " ("+bs.getFormatDescription()+", "+getFormatSize()+")";
		}
	}
	
	public String getFormatSize() throws SQLException
	{
		Bitstream bs = getRawBitstream();
		if (bs == null)
			return "";
		else
		{
			long size = bs.getSize();
			return UIUtil.formatFileSize(size);
		}
	}
}
