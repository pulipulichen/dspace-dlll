<%@ page contentType="text/html;charset=UTF-8" %><%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" 
%><%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" 
%><%@ page import="org.dspace.app.webui.util.UIUtil"
 %><%@ page import="org.dspace.content.Collection"
 %><%@ page import="org.dspace.content.Community"
 %><%@ page import="org.dspace.content.DCValue"
 %><%@ page import="org.dspace.content.Item"
 %><%@ page import="org.dspace.core.ConfigurationManager"
 %><%@ page import="org.dspace.handle.HandleManager"
 %><%@ page import="org.dspace.license.CreativeCommons"
 %><%@ page import="java.io.File"
 %><%@ page import="java.util.Date"
 %><%@ page import="org.dspace.app.webui.util.ItemEditButton"
 %><%@ page import="javax.servlet.jsp.JspWriter"
 %><%@ page import="org.dspace.app.webui.components.RecentSubmissions"
 %><%@ page import="org.dspace.app.webui.components.RecentSubmissionsManager"
 %><%@ page import="org.dspace.app.util.XMLMetadata"
 %><%@ page import="java.net.URLDecoder"
 %><%@ page import="org.apache.commons.lang.StringEscapeUtils"
 %><%@ page import="org.dspace.app.webui.util.ItemEditButton"
 %><%@ page import="org.dspace.eperson.EPerson"
 %><%@ page import="org.dspace.eperson.Group"
 %><%@ page import="org.dspace.core.Context" 
 %><%@ page import="org.dspace.content.Item"
 %><%@ page import="org.dspace.handle.HandleManager"
 %><%@ page import="org.dspace.content.DSpaceObject"
 %><%@ page import="org.dspace.content.Bundle"
 %><%@ page import="org.dspace.content.Bitstream"
 %><%@ page import="org.dspace.content.BitstreamFormat"
 %><%@ page import="org.dspace.core.Context"
 %><%@ page import="java.io.InputStream"
 %><%@ page import="java.util.zip.ZipInputStream"
 %><%@ page import="java.util.zip.ZipEntry"
 %><%@ page import="org.dspace.core.Constants"
 %><%@ page import="java.io.File"
 %><%@ page import="java.sql.SQLException"
 %><%@ page import="java.io.IOException"
 %><%@ page import="java.awt.image.BufferedImage"
 %><%@ page import="java.io.InputStream"
 %><%@ page import="java.awt.Graphics2D"
 %><%@ page import="javax.imageio.ImageIO" 
 %><%@ page import="java.util.Hashtable" 
 %><%@ page import="java.io.UnsupportedEncodingException" 
 %><%@ page import="java.util.Arrays" 
 %><%@ page import="java.util.ArrayList" 
 %><%@ page import="org.dspace.app.webui.util.FilteredBitstreamGetter" 
%><%!
class BitstreamDisplayModel
{
	public Bitstream bitstream;
	public String width = "100%";
	public String height = "100%";
	public String mode = "SNAP";
	public String url;
	
	public String getRetrieveURI()
	{
		if (this.bitstream == null && this.url == null)
			return null;
		
		if (this.url == null)
		{
			String output = getBitstreamRetrieveURI(this.bitstream);
	        
	        if (mode.equals("SNAP"))
	        {
		        try
		        {
		        	int w = Integer.parseInt(width);
		        	int h = Integer.parseInt(height);
		        	output = output + "?width="+w+"&height="+h;
		        	//this.url = output;
		        }
		        catch (Exception e) { }
		    }
		    this.url = output;
		}
		return url;
	}
	
	public String getMode()
	{
		if (getRetrieveURI() == null || getRetrieveURI().equals("null"))
			return "NO_PREVIEW";
		else
			return mode;
	}
}	

	public String getBitstreamRetrieveURI(Bitstream bitstream)
	{
		if (bitstream == null)
			return null;
		
		int bitstreamID = bitstream.getID();
		String path = "/retrieve/" + bitstreamID + "/";
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
	
	public String getBitstreamPreviewURI(Bitstream bitstream)
	{
		if (bitstream == null)
			return null;
		else
		{
			String path = "/preview/" + bitstream.getID();
			return path;
		}
	}
	
	public String guessInnerMode(Bitstream bitstream) 
	{
		String[] ZoomifyFilterInputFormats = new String[0];
		String[] Video2FLVInputFormats = new String[0];
		String[] Doc2AlbumInputFormats = new String[0];
		String[] Audio2MP3InputFormats = new String[0];
		String[] IframeInputFormats = {
			"Text","HTML", "CSS", "ZIP"
		};
		
		String mode = null;
		
		String mime = bitstream.getMIMEType();
		String extension = null;
		String filename = bitstream.getName();
		if (filename.lastIndexOf(".") != -1)
			extension = filename.substring(filename.lastIndexOf(".")+1, filename.length());
		
		//先載入猜測時所需要得資料
		if (ZoomifyFilterInputFormats.length == 0)
			ZoomifyFilterInputFormats = loadMediaFilterInputFormats(ZoomifyFilterInputFormats, "ZoomifyFilter");
		if (Video2FLVInputFormats.length == 0)
			Video2FLVInputFormats = loadMediaFilterInputFormats(Video2FLVInputFormats, "Video2FLV");
		//if (Doc2SWFInputFormats.length == 0)
		//	Doc2SWFInputFormats = loadMediaFilterInputFormats(Doc2SWFInputFormats, "Doc2Text");	//Doc2Text才有包含Abode PDF
		if (Doc2AlbumInputFormats.length == 0)
			Doc2AlbumInputFormats = loadMediaFilterInputFormats(Doc2AlbumInputFormats, "Doc2Text");	//Doc2Text才有包含Abode PDF
		if (Audio2MP3InputFormats.length == 0)
			Audio2MP3InputFormats = loadMediaFilterInputFormats(Audio2MP3InputFormats, "Audio2MP3");
		
		//先取得bitstream的檔案敘述
		String bitstreamFormat = bitstream.getFormatDescription();

		mode = searchInputFormats(ZoomifyFilterInputFormats, bitstreamFormat, mode, "ZOOMIFY");
		mode = searchInputFormats(Video2FLVInputFormats, bitstreamFormat, mode, "VIDEO_PREVIEW");
		//mode = searchInputFormats(Doc2SWFInputFormats, bitstreamFormat, mode, "PDF2SWF_PREVIEW");
		mode = searchInputFormats(Doc2AlbumInputFormats, bitstreamFormat, mode, "DOC_PREVIEW");
		mode = searchInputFormats(Audio2MP3InputFormats, bitstreamFormat, mode, "AUDIO_PREVIEW");
		mode = searchInputFormats(IframeInputFormats, bitstreamFormat, mode, "IFRAME");
		
		if (mode == null)
			mode = "DETAIL";
		
		return mode;
	}
	
	public String[] loadMediaFilterInputFormats(String[] config, String filterName)
	{
		if (config.length == 0)
		{
			String inputFormats = ConfigurationManager.getProperty("filter.org.dspace.app.mediafilter."+filterName+".inputFormats", null);
			String inputFormatsArray[] = inputFormats.split(",");
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
	
	public boolean isSmallImage(Bitstream bitstream)
	{
		int smallImageWidth = 300;
		int smallImageHeight = 300;
		try
		{
			InputStream source = bitstream.retrieve();
			BufferedImage buf = ImageIO.read(source);
			float xsize = (float) buf.getWidth(null);
	        float ysize = (float) buf.getHeight(null);
	        
	        if (xsize < smallImageWidth && ysize < smallImageHeight)
	        	return true;
	        else
				return false;
		}
		catch (Exception e)
		{
			return false;
		}
	}
	
	private String parseZIPWebpage(HttpServletRequest request, Bitstream bitstream)
	{
		if (bitstream.getMIMEType() == null 
			|| bitstream.getMIMEType().equals("application/zip") == false)
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
					
					if (name == null
						|| name.indexOf(File.separator) != -1)
						continue;
					
					for (int i = 0; i < indexName.length; i++)
					{
						String n = name.substring(name.lastIndexOf(File.separator) + 1, name.length());
						if (indexName[i].equals(n))
						{
							indexPath = name;
							break;
						}
					}
					
					if (indexPath == null 
						&& indexPath2 == null
						&& name.lastIndexOf(".") > -1)
					{
						if (name.lastIndexOf(".") == -1)
							continue;
						
						String fileType = name.substring(name.lastIndexOf(".") + 1, name.length()).toLowerCase();
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
						String fileType = name.substring(name.lastIndexOf(".") + 1, name.length()).toLowerCase();
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
				String zipname = zipIndexPath.substring(zipIndexPath.lastIndexOf("/") + 1, zipIndexPath.length());
				
				for (int i = 0; i < indexName.length; i++)
				{
					if (indexName[i].equals(zipname))
					{
						zipIndexPath = zipIndexPath.substring(0, zipIndexPath.lastIndexOf("/") + 1);
						break;
					}
				}
			}
			
			
			if (zipIndexPath != null)
			{
				//幫他接上開頭吧……
				String assetstoreHTTP = "http://"+request.getServerName()
					+ ":" + ConfigurationManager.getProperty("http.port", "50080")
					+ ConfigurationManager.getProperty("assetstore.http.retrieve", "/assetstore");
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
				zipIndexPath = filepath + "/" + zipIndexPath;
			}
		}
		catch (Exception e) {
			//do nothing
			//zipIndexPath = "aaaaaaa" + e.getCause() + "|" + e.getMessage() + "|";
		}
		finally
		{
			return zipIndexPath;
		}
	}
	private Context getContext() throws SQLException
	{
		return new Context();
	}
	
	public Bitstream findSnapBitstream(Bitstream bitstream) throws SQLException
	{
		//Bitstream[] snaps = bitstream.getFilteredBitstream("SNAP");
		//Bitstream[] snaps = FilteredBitstreamGetter.findFilteredBitstream(getContext(), bitsteam, "SNAP");
		Bitstream[] snaps = getFilterBitstream(bitstream, "SNAP");
		if (snaps.length > 0)
			return snaps[0];
		else
			return null;
	}
	
	public BitstreamDisplayModel getFilteredBitstreamDisplay(HttpServletRequest request, Bitstream rawBitstream, String mode)
		throws SQLException
	{
		return getFilteredBitstreamDisplay(request, rawBitstream, mode, true);
	}
	public Bitstream[] getFilterBitstream(Bitstream bitstream, String bundleName) throws SQLException
	{
		return FilteredBitstreamGetter.findFilteredBitstream(getContext(), bitstream, bundleName);
	}
	
	public BitstreamDisplayModel getFilteredBitstreamDisplay(HttpServletRequest request, Bitstream rawBitstream, String mode, boolean callPreview)
		throws SQLException
	{
		if (mode == null)
			return null;
		
		BitstreamDisplayModel output = new BitstreamDisplayModel();
		
		output.mode = mode;
		if (mode.equals("IFRAME"))
		{
			output.bitstream = rawBitstream;
			String zipIndexPath = parseZIPWebpage(request, rawBitstream);
			if (zipIndexPath == null)
			{
				output.url = getBitstreamRetrieveURI(rawBitstream);
			}
			else
			{
				output.url = zipIndexPath;
			}
			
				output.width = "640px";
				output.height = "480px";
		}
		else if (mode.equals("ZOOMIFY"))
		{
			//先判斷大小
			Bitstream[] filtereds = new Bitstream[0];
			if (isSmallImage(rawBitstream) == false)
			{
				//Bitstream[] filtereds = rawBitstream.getFilteredBitstream(mode);
				filtereds = getFilterBitstream(rawBitstream, mode);
				if (filtereds.length > 0)
				{
					if (callPreview == false)
					{
						output.bitstream = filtereds[0];
						output.url = "/retrieve-zip/"+filtereds[0].getID();
						output.width = "640";
						output.height = "480";
					}
					else
					{
						if (hasPreview(rawBitstream, mode))
						{
							output.mode = "PREVIEW";
							output.url = getBitstreamPreviewURI(rawBitstream);
							
							if (isSmallImage(rawBitstream) == false)
							{
								output.width = "640";
								output.height = "480";
							}
							else
							{
								output.width = "300";
								output.height = "300";
							}
							output.url = output.url + "?width=" + output.width + "&height=" + output.height; 
						}
						else
						{
							output.mode = "NO_PREVIEW";
							output.url = getBitstreamRetrieveURI(rawBitstream);
						}
					}
				}
			}
			
			if (filtereds.length == 0)
			{
				mode = "SNAP";
				//Bitstream[] filtereds = rawBitstream.getFilteredBitstream(mode);
				filtereds = getFilterBitstream(rawBitstream, mode);
				if (filtereds.length > 0)
				{
					output.mode = mode;
					//output.url = getBitstreamRetrieveURI(filtereds[0]);
					output.bitstream = filtereds[0];
					output.width = "300";
					output.height = "300";
				}
			}
		}	//else if (mode.equals("ZOOMIFY"))
		else if (mode.equals("VIDEO_PREVIEW"))
		{
			output.width = "320";
			output.height = "240";
			Bitstream[] filtereds = getFilterBitstream(rawBitstream, mode);
			if (filtereds.length > 0)
			{
				if (callPreview == false)
				{
					output.mode = mode;
					output.bitstream = filtereds[0];
				}
				else
				{
					if (hasPreview(rawBitstream, mode))
					{
						output.mode = "PREVIEW";
						output.url = getBitstreamPreviewURI(rawBitstream);
					}
					else
					{
						output.mode = "NO_PREVIEW";
						output.url = getBitstreamRetrieveURI(rawBitstream);
					}
					output.width = "320";
					output.height = "240";
				}
			}
			else
			{
				output.mode = "SNAP";
				output.bitstream = findSnapBitstream(rawBitstream);
			}
		}	//else if (mode.equals("VIDEO_PREVIEW"))
		else if (mode.equals("AUDIO_PREVIEW"))
		{
			output.width = "320";
			output.height = "25";
			
			//Bitstream[] filtereds = rawBitstream.getFilteredBitstream(mode);
			Bitstream[] filtereds = getFilterBitstream(rawBitstream, mode);
			if (filtereds.length > 0)
			{
				if (callPreview == false)
				{
					output.mode = mode;
					output.bitstream = filtereds[0];
				}
				else
				{
					if (hasPreview(rawBitstream, mode))
					{
						output.mode = "PREVIEW";
						output.url = getBitstreamPreviewURI(rawBitstream);
					}
					else
					{
						output.mode = "NO_PREVIEW";
						output.url = getBitstreamRetrieveURI(rawBitstream);
					}
					output.width = "320";
					output.height = "25";
				}
			}
			else
			{
				output.mode = "SNAP";
				output.bitstream = null;
			}
		}
		else if (mode.equals("PDF2SWF_PREVIEW"))
		{
			output.width = "640";
			output.height = "480";
			Bitstream[] filtereds = getFilterBitstream(rawBitstream, mode);
			if (filtereds.length > 0)
			{
				if (callPreview == false)
				{
					output.mode = mode;
					output.bitstream = filtereds[0];
				}
				else
				{
					if (hasPreview(rawBitstream, mode))
					{
						output.mode = "PREVIEW";
						output.url = getBitstreamPreviewURI(rawBitstream);
					}
					else
					{
						output.mode = "NO_PREVIEW";
						output.url = getBitstreamRetrieveURI(rawBitstream);
					}
					output.width = "640";
					output.height = "480";
				}
			}
			else
			{
				mode = "DOC_PREVIEW";
				filtereds = getFilterBitstream(rawBitstream, mode);
				if (filtereds.length > 0)
				{
					if (callPreview == false)
					{
						output.mode = mode;
						output.bitstream = filtereds[0];
					}
					else
					{
						if (hasPreview(rawBitstream, mode))
						{
							output.mode = "PREVIEW";
							output.url = getBitstreamPreviewURI(rawBitstream);
						}
						else
						{
							output.mode = "NO_PREVIEW";
							output.url = getBitstreamRetrieveURI(rawBitstream);
						}
						output.width = "640";
						output.height = "480";
					}
				}
				else
				{
					output.mode = "SNAP";
					output.bitstream = findSnapBitstream(rawBitstream);
				}
			}
		}
		else if (mode.equals("DOC_PREVIEW"))
		{
			output.width = "640";
			output.height = "480";
			Bitstream[] filtereds = getFilterBitstream(rawBitstream, mode);
			if (filtereds.length > 0)
			{
				if (callPreview == false)
				{
					output.mode = mode;
					output.bitstream = filtereds[0];
				}
				else
				{
					if (hasPreview(rawBitstream, mode))
					{
						output.mode = "PREVIEW";
						output.url = getBitstreamPreviewURI(rawBitstream);
					}
					else
					{
						output.mode = "NO_PREVIEW";
						output.url = getBitstreamRetrieveURI(rawBitstream);
					}
					output.width = "640";
					output.height = "480";
				}
			}
			else
			{
				mode = "PDF2SWF_PREVIEW";
				filtereds = getFilterBitstream(rawBitstream, mode);
				if (filtereds.length > 0)
				{
					if (callPreview == false)
					{
						output.mode = mode;
						output.bitstream = filtereds[0];
					}
					else
					{
						if (hasPreview(rawBitstream, mode))
						{
							output.mode = "PREVIEW";
							output.url = getBitstreamPreviewURI(rawBitstream);
						}
						else
						{
							output.mode = "NO_PREVIEW";
							output.url = getBitstreamRetrieveURI(rawBitstream);
						}
						output.width = "640";
						output.height = "480";
					}
				}
				else
				{
					output.mode = "SNAP";
					output.bitstream = findSnapBitstream(rawBitstream);
				}
			}
		}
		
		if (output.mode == "SNAP" && output.bitstream != null)
		{
			output.width = "300";
			output.height = "300";
		}
		return output;
	}
	
	public boolean hasPreview(Bitstream rawBitstream, String mode) throws SQLException
	{
		Bitstream[] filtereds = getFilterBitstream(rawBitstream, mode);
		
		if (filtereds.length > 0)
			return true;
		else
		{
			filtereds = getFilterBitstream(rawBitstream, "SNAP");
			if (filtereds.length > 0)
				return true;
			else
				return false;
		}
	}
	
%><%

//取得參數
int bitstreamID;
boolean downloadable = true;
String error = null;

String bitstreamParameter = request.getParameter("bitstreamID");
String downloadableParameter = request.getParameter("downloadable");
String callback = request.getParameter("callback");

try
{
	bitstreamID = Integer.parseInt(bitstreamParameter);
}
catch (Exception e)
{
	error = "Lost bitstream ID";
	bitstreamID = -1;
}

if (downloadableParameter != null
	&& (downloadableParameter.toUpperCase().equals("FALSE")
		|| downloadableParameter.equals("0"))
	)
	downloadable = false;

if (error == null && bitstreamID != -1)
{
	//宣告一下最終要輸出的屬性
	String mainMode = "";
	
	//讀取原始的Bitstream
	Context context = UIUtil.obtainContext(request);
	if (context == null)
		context = new Context();
	Bitstream rawBitstream = Bitstream.find(context, bitstreamID);
	
	String mode = guessInnerMode(rawBitstream);
	out.print("//"+mode+"\n");
	BitstreamDisplayModel main = getFilteredBitstreamDisplay(request, rawBitstream, mode);
	
	//-----------------------------------
	//取得其他類型的資料
	//Hashtable buttons = new Hashtable();	//不知道該怎麼使用Hashtable達成我的目標
	ArrayList<String> buttonsName = new ArrayList<String>();
	ArrayList<String> buttonsURL = new ArrayList<String>();
	
	if (mode.equals("VIDEO_PREVIEW"))
	{
		//要去搜尋VIDEO_MOBILE的位置
		//Bitstream[] videoMobile = rawBitstream.getFilteredBitstream("VIDEO_MOBILE");
		Bitstream[] videoMobile = getFilterBitstream(rawBitstream, "VIDEO_MOBILE");
		
		if (videoMobile.length > 0)
		{
			String url = "/retrieve/" + videoMobile[0].getID() 
				+ "/" + UIUtil.encodeBitstreamName(videoMobile[0].getName(),
                        Constants.DEFAULT_ENCODING);
			//buttons.put("行動格式", videoMobile[0].getID);	//不採用Hashtable
			buttonsName.add("行動格式");
			buttonsURL.add(url);
		}
	}	//if (mode.equals("VIDEO_PREVIEW"))
	
	//-----------------------------------
	//輸出，組成output
	ArrayList<String> outputList = new ArrayList<String>();
	outputList.add("error: null");
	
	outputList.add("name: \"" + rawBitstream.getName() + "\"");
	
	if (downloadable == true)
	{
		String rawOutput = "raw: {name: \""+ "下載" +"\","
			+ " url: \""+getBitstreamRetrieveURI(rawBitstream)+"\", id: "+rawBitstream.getID()+"}";
		outputList.add(rawOutput);
	}
	
	if (main != null)
	{
		String mainOutput = "main: {"
			+ "url:\""+main.getRetrieveURI()+"\", "
			+ "mode: \""+main.getMode()+"\", "
			+ "width: \""+main.width+"\", "
			+ "height: \""+main.height+"\""
			+ "}";
			
		outputList.add(mainOutput);
	}
	
	if (buttonsName.size() > 0)
	{
		String btnOutput = "buttons: [";
		for (int i = 0; i < buttonsName.size(); i++)
		{
			if (i > 0)
				btnOutput = btnOutput + ",";
			
			//btnOutput = btnOutput + "\"" + buttonsName.get(i) + "\":"
			//	+ "\"" + buttonsURL.get(i) + "\"";
			btnOutput = btnOutput + "{name: \"" + buttonsName.get(i) + "\", "
				+ "url: \"" + buttonsURL.get(i) + "\"}";
		}
		btnOutput = btnOutput + "]";
		
		outputList.add(btnOutput);
	}
	
	String outputJSON = "";
	for (int i = 0; i < outputList.size(); i++)
	{
		if (i > 0)
			outputJSON = outputJSON + ",";
		outputJSON = outputJSON + outputList.get(i);
	}
	
	//加入callback並組成json
	if (callback != null)
	{
		out.print(callback+"({"+outputJSON+"});");
	}
	else
	{
		out.print("{"+outputJSON+"}");
	}
	
}	//if (error == null)
else
{
	if (callback != null)
	{
		out.print(callback + "({error:\""+error+"\"});");
	}
	else
	{
		out.print("{error:\""+error+"\"}");
	}
}
%>