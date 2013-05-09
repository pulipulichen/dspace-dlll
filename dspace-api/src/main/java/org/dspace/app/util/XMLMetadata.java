/* ****************************************
 * ==== Install XMLMetadata ====
 * 
 * 1. Please Upload to [dspace-source]/dspace-api/src/main/java/org/dspace/app/util
 * 2. Rebuild your DSpace.
 * 
 * ==== How to use XMLMetadata in JSP ====
 * 
 * 1. Insert import code first.
 * 
 * 	<%@ page import="org.dspace.app.util.XMLMetadata" %>
 * 
 * 2. Get your XMLMetadata in database. Follow will write in JSP section (<%  %>).
 * 
 * 	String xmlText = rs.getString();
 * 
 * 3. Create XMLMetadata object and set value up.
 * 	
 * 	XMLMetadata xmlObj = new XMLMetadata();
 * 	xmlObj.setXMLdoc(xmlText);
 * 
 * 4. Declare the path you want. The path will be composed by node's title and use "/" to split every node Title.
 * 	
 * 	String path = "教師/人名/姓";
 * 
 * 4. Get node value where you want.
 * 		
 * 	String[] valueAry = xmlObj.locate(path);
 * 	int[] valueIntAry = xmlObj.locateInt(path);
 * 
 * You can only get one result:
 * 
 * 	String valueSingle = xmlObj.locateSingle(path);
 * 	int valueIntSingle = xmlObj.locateIntSingle(path);
 * 
 * Or assign offset to which result you want:
 * 
 * 	int offset = 1;	
 * 	String valueSingle = xmlObj.locateSingle(path, offset);
 * 	int valueIntSingle = xmlObj.locateIntSingle(path, offset);
 * 
 * That's all!
 * ******************************************
*/

package org.dspace.app.util;

import org.xml.sax.SAXException;
import org.w3c.dom.*;
import javax.xml.parsers.*;
import org.apache.xerces.parsers.DOMParser;
import java.io.StringReader;
import org.xml.sax.InputSource;
import javax.xml.xpath.*;
import java.io.IOException;
import javax.servlet.ServletException;
import org.dspace.app.util.EscapeUnescape;
import org.dspace.app.util.Util;

	public class XMLMetadata
	{
		public XMLMetadata()
		{
		}
		
		private String XMLText;
		private Document XMLDoc;
		
		public void setXMLText(String XMLText)
			throws ParserConfigurationException, SAXException, 
          	IOException, ServletException
		{
			XMLText = XMLReform(XMLText);
			XMLText = XMLInputValuesEncode(XMLText);
			XMLText = XMLInputDefaultValueEncode(XMLText);
			this.XMLText = XMLReform(XMLText);
			
			try
    		{
				DOMParser parser = new DOMParser();
				parser.parse(new InputSource(new java.io.StringReader(XMLReform(XMLText)))); // xml is a string containing xml
				this.XMLDoc = parser.getDocument();
			}
			catch (Exception e)
			{
				throw new ServletException("Error parsing XML document: "+e);
			}
			
		}
		
		public String getXMLText()
		{
			return XMLText;
		}
		
		public String[] locate(String titlePath)
			throws XPathExpressionException, ServletException
		{
			String XPath = titlePathToXPath(titlePath);
			String[] valueAry = locateXPath(XPath);
				
			return valueAry;
		}
		
		public int locateCountNode(String titlePath)
			throws XPathExpressionException, ServletException
		{
			String XPath = titlePathToXPath(titlePath);
			String[] valueAry = locateXPath(XPath);
				
			return valueAry.length;
		}
		
		public String locateSingle(String titlePath)
			throws XPathExpressionException, ServletException
		{
			String[] valueAry = locate(titlePath);
			
			if (valueAry.length > 0)
				return valueAry[0];
			else
				return null;
		}
		
		public String locateSingle(String titlePath, int offset)
			throws XPathExpressionException, ServletException
		{
			String[] valueAry = locate(titlePath);
			
			if (valueAry.length > offset)
				return valueAry[offset];
			else
				return null;
		}
		
		public int[] locateInt(String titlePath)
			throws XPathExpressionException, ServletException
		{
			String XPath = titlePathToXPath(titlePath);
			String[] valueAry = locateXPath(XPath);
			
			int[] valueIntAry = new int[valueAry.length];
			//String[] valueAry = new String[nodes.getLength()];
			//int a = Integer.parseInt(item_id); 
			for (int i = 0; i < valueAry.length; i++)
				valueIntAry[i] = Integer.parseInt(valueAry[i].trim());
			return valueIntAry;
		}
		
		public int locateIntSingle(String titlePath)
			throws XPathExpressionException, ServletException
		{
			String value = locateSingle(titlePath);
			if (value == null)
				return -1;
			return Integer.parseInt(value.trim());
		}
		
		public int locateIntSingle(String titlePath, int offset)
			throws XPathExpressionException, ServletException
		{
			String value = locateSingle(titlePath, offset);
			if (value == null)
				return -1;
			return Integer.parseInt(value.trim());
		}
		
		public String[] locateXPath(String Xpath)
			throws XPathExpressionException, ServletException
		{	
			Object result;
			try
    		{
    			XPathFactory factory = XPathFactory.newInstance();
    			XPath xpath = factory.newXPath();
    			XPathExpression expr = xpath.compile(Xpath);
    			
    			result = expr.evaluate(XMLDoc, XPathConstants.NODESET);
    		}
    		catch (Exception e)
			{
				throw new ServletException("Error create XPathExpression: "+e);
			}
			
			NodeList nodes = (NodeList) result;
			String[] valueAry = new String[nodes.getLength()];
    		for (int i = 0; i < nodes.getLength(); i++) {
        		valueAry[i] = nodes.item(i).getNodeValue();
        		try
        		{
        			valueAry[i] = EscapeUnescape.unescape(valueAry[i]);
        			valueAry[i] = EscapeUnescape.unescape(valueAry[i]);
        		}
        		catch (Exception e) { }
    		}
			
			return valueAry;
		}
		
		public String titlePathToXPath(String titlePath)
		{
			String XPathExp = "/div[@class='xml-root' or @class='xml-root edited']";
			
			String[] nodeTitle = titlePath.split("/");
			//"/div/DIV[@class='node'][DIV[@class='node-title']/text()='學生']/DIV[@class='input-values']/text()"
			
			for (int i = 0; i < nodeTitle.length; i++)
			{
				String nodeTitleName = nodeTitle[i];
				String nodeTitleIndex = "";
				
				if (nodeTitleName.lastIndexOf("[") != -1 
					&& nodeTitleName.lastIndexOf("]") == nodeTitleName.length()-1)
				{
					//String nodeIndex = nodeTitleName.substring(nodeTitleName.lastIndexOf("[")+1, nodeTitleName.length()-1);
					String nodeIndex = Util.substring(nodeTitleName, nodeTitleName.lastIndexOf("[")+1, nodeTitleName.length()-1);
					int index = Integer.parseInt(nodeIndex.trim());
					index++;
					nodeTitleIndex = "["+index+"]";
					
					//nodeTitleName = nodeTitleName.substring(0, nodeTitleName.lastIndexOf("["));
					nodeTitleName = Util.substring(nodeTitleName, 0, nodeTitleName.lastIndexOf("["));
				}
				
				
				if (nodeTitleName.equals(""))
				{
					XPathExp = XPathExp + "/DIV[@class='node']/DIV[@class='node-contents']" + nodeTitleIndex;
				}
				else if (i < (nodeTitle.length-1))
				{
					XPathExp = XPathExp + "/DIV[@class='node'][DIV[@class='node-title']/text()='"+nodeTitleName+"']/DIV[@class='node-contents']" + nodeTitleIndex;
				}
				else
				{
					XPathExp = XPathExp + "/DIV[@class='node'][DIV[@class='node-title']/text()='"+nodeTitleName+"']/DIV[@class='input-values']"+nodeTitleIndex+"/text() | "+XPathExp + "/DIV[@class='node'][DIV[@class='node-title']/text()='"+nodeTitleName+"']/DIV[@class='node-contents']"+nodeTitleIndex+"/text()";
				}
			}
			
			return XPathExp;
		}
		
		static public String XMLReform(String inputText)
		 {
			String output = "";

			int needleLast = 0;
			
			while(inputText.indexOf("=", needleLast) != -1)
			{
				int needle = inputText.indexOf("=", needleLast);
				
				//Add before to output
				output = output 
					//+ inputText.substring(needleLast, needle+1);
					+ Util.substring(inputText, needleLast, needle+1);
				
				//觀察是否在標籤內
				if (inputText.indexOf("<", needle) < inputText.indexOf(">", needle)
					&& inputText.indexOf("<", needle) != -1)
				{
					needleLast = needle+1;
					continue;
				}
				
				
				//check next char is " ?
				//String nextChar = inputText.substring(needle+1, needle+2);
				String nextChar = Util.substring(inputText, needle+1, needle+2);
				
				if (!(nextChar.equals("\"")))
				{
					output = output + "\"";
					
					int needleFooter;
					//we have to know who is first between " " or ">"
					
					int needleFooter1 = inputText.indexOf(" ", needle+1);	//for " "
					int needleFooter2 = inputText.indexOf(">", needle+1);	//for ">"
					
					if (needleFooter1 < needleFooter2 && needleFooter1 != -1)
						needleFooter = needleFooter1;
					else if (needleFooter2 != -1)
						needleFooter = needleFooter2;
					else
						needleFooter = needleFooter1;
					
					if (inputText.length() > needle)
					{
						if (inputText.length() > needleFooter)
							output = output 
								//+ inputText.substring(needle+1, needleFooter);
								+ Util.substring(inputText, needle+1, needleFooter);
						else
							output = output 
								//+ inputText.substring(needle+1, inuptText.length());
								+ Util.substring(inputText, needle+1);
					}
					
					
					output = output + "\"";
					
					needleLast = needleFooter;
					
					//needleLast = needle + 1;
				}
				else	//next char isn't ".
				{
					needleLast = needle+1;
				}
			}
		
			output = output 
				//+ inputText.substring(needleLast, inputText.length()); 			
				+ Util.substring(inputText, needleLast);
			
			
			//<DIV class="node"><DIV
			
			output = output.replace("<div class=\"node\"><div class=\"node-type\">", "<DIV class=\"node\"><DIV class=\"node-type\">");
			output = output.replace("</div><div class=\"node", "</DIV><DIV class=\"node");
			output = output.replace("</div><div class=\"input", "</DIV><DIV class=\"input");
			output = output.replace("</div></div><DIV class=\"node\">", "</DIV></DIV><DIV class=\"node\">");
			output = output.replace("</div></div><DIV class=\"node\">", "</DIV></DIV><DIV class=\"node\">");
			output = output.replace("</div><DIV class=\"node\">", "</DIV><DIV class=\"node\">");
			output = output.replace("</div></div></div></div>\r\n</div>", "</DIV></DIV></DIV></DIV>\r\n</div>");
			output = output.replace("</div></div></div></div>\n\r</div>", "</DIV></DIV></DIV></DIV>\n\r</div>");
			output = output.replace("</div></div></div></div></div>", "</DIV></DIV></DIV></DIV></div>");
			output = output.replace("</div></div></div></div>\n</div>", "</DIV></DIV></DIV></DIV>\n</div>");
			output = output.replace("</div><select", "</DIV><select");
			output = output.replace("</select><div", "</select><DIV");
			output = output.replace("</div><SELECT", "</DIV><SELECT");
			output = output.replace("</div></div></DIV>", "</DIV></DIV></DIV>");
						
			output = output.replace("selected ", "selected=\"true\" ");
			output = output.replace("selected>", "selected=\"true\">");
			
			return output;
		}	//private String XMLreform(String xmlDoc)
	
	
		public String XMLInputDefaultValueEncode(String inputText)
		{
			String output = "";
			int needleLast = 0;
			
			String needleHead = "<DIV class=\"input-default-value\">";
			String needleFoot = "</DIV>";
			
			while (inputText.indexOf(needleHead, needleLast) != -1)
			{
				int needle = inputText.indexOf(needleHead, needleLast) + needleHead.length();
				
					
				//Add before to output
				output = output 
					//+ inputText.substring(needleLast, needle);
					+ Util.substring(inputText, needleLast, needle);
				
				int needleFootIndex = inputText.indexOf(needleFoot, needle);
				
				//output = output + "[["+needleFootIndex+"]]\n";
				
				if (needleFootIndex != -1)
				{
					//String inputValue = inputText.substring(needle, needleFootIndex);
					String inputValue = Util.substring(inputText, needle, needleFootIndex);
					inputValue = inputValue.replace("<", "&lt;");
					inputValue = inputValue.replace(">", "&gt;");
                                        inputValue = inputValue.replace("&", "&amp;");
					output = output + inputValue;
				}
				
				needleLast = needleFootIndex;
				
				//needleLast = needle + 1;
			}
			
			output = output 
				//+ inputText.substring(needleLast, inputText.length());
				+ Util.substring(inputText, needleLast);
			
			return output;
		}
		
		public String XMLInputValuesEncode(String inputText)
		{
			String output = "";
			int needleLast = 0;
			
			String needleHead = "<DIV class=\"input-values\">";
			String needleFoot = "</DIV>";
			
			while (inputText.indexOf(needleHead, needleLast) != -1)
			{
				int needle = inputText.indexOf(needleHead, needleLast) + needleHead.length();
				
					
				//Add before to output
				output = output 
					// + inputText.substring(needleLast, needle);
					+ Util.substring(inputText, needleLast, needle);
				
				int needleFootIndex = inputText.indexOf(needleFoot, needle);
				
				//output = output + "[["+needleFootIndex+"]]\n";
				
				if (needleFootIndex != -1)
				{
					//String inputValue = inputText.substring(needle, needleFootIndex);
					String inputValue = Util.substring(inputText, needle, needleFootIndex);
					inputValue = inputValue.replace("<", "&lt;");
					inputValue = inputValue.replace(">", "&gt;");
                                        inputValue = inputValue.replace("&", "&amp;");
					output = output + inputValue;
				}
				
				needleLast = needleFootIndex;
				
				//needleLast = needle + 1;
			}
			
			output = output 
				+ Util.substring(inputText, needleLast);
				//+ inputText.substring(needleLast, inputText.length());
			
			return output;
		}
	}
