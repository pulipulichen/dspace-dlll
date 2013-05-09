//Please Upload to [dspace-source]/dspace-api/src/main/java/org/dspace/app/util
package org.dspace.submit;

import org.xml.sax.SAXException;
import org.w3c.dom.*;
import javax.xml.parsers.*;
import org.apache.xerces.parsers.DOMParser;
import java.io.StringReader;
import org.xml.sax.InputSource;
import javax.xml.xpath.*;
import java.io.IOException;
import javax.servlet.ServletException;

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
				valueIntAry[i] = Integer.parseInt(valueAry[i]);
			return valueIntAry;
		}
		
		public int locateIntSingle(String titlePath)
			throws XPathExpressionException, ServletException
		{
			String value = locateSingle(titlePath);
			if (value == null)
				return -1;
			return Integer.parseInt(value);
		}
		
		public int locateIntSingle(String titlePath, int offset)
			throws XPathExpressionException, ServletException
		{
			String value = locateSingle(titlePath, offset);
			if (value == null)
				return -1;
			return Integer.parseInt(value);
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
    		}
			
			return valueAry;
		}
		
		public String titlePathToXPath(String titlePath)
		{
			String XPathExp = "/div[@class='xml-root']";
			
			String[] nodeTitle = titlePath.split("/");
			//"/div/DIV[@class='node'][DIV[@class='node-title']/text()='學生']/DIV[@class='input-values']/text()"
			
			for (int i = 0; i < nodeTitle.length; i++)
			{
				if (i < (nodeTitle.length-1))
				{
					XPathExp = XPathExp + "/DIV[@class='node'][DIV[@class='node-title']/text()='"+nodeTitle[i]+"']/DIV[@class='node-contents']";
				}
				else
				{
					XPathExp = XPathExp + "/DIV[@class='node'][DIV[@class='node-title']/text()='"+nodeTitle[i]+"']/DIV[@class='input-values']/text()";
				}
			}
			
			return XPathExp;
		}
		
		private String XMLReform(String XMLText)
		 {
			String output = "";
			
			String needleHead = "class=";
			String needleFoot = ">";
			Boolean needleFlag = true;	//true: head || false: Foot
			int needleIndex = 0;
			int needleIndexLast = 0;
			
			Boolean reformContinue = true;
			
			while(reformContinue == true)
			{
				if (needleFlag == true)
				{
					int i = XMLText.indexOf(needleHead, needleIndex);
					if (i != -1)
					{
											//取代字串
						output = output + XMLText.substring(needleIndexLast, i); 	//head
						output = output + needleHead;	//body
						if (!(XMLText.substring(i+needleHead.length(), i+needleHead.length()+1).equals("\"")))
						{
							output = output + "\"";	//body
						}
							
						needleFlag = false;
						needleIndex = i + needleHead.length();
						needleIndexLast = needleIndex;
					}
					else
					{
						reformContinue = false;
					}
				}
				else
				{
					int i = XMLText.indexOf(needleFoot, needleIndex);
					if (i != -1)
					{					
						//取代字串
						output = output + XMLText.substring(needleIndexLast, i); 	//head
						if (!(XMLText.substring(i-1, i).equals("\"")))
						{
							output = output + "\"";	//body
						}
						output = output + needleFoot;	//body
							
						needleFlag = true;
						needleIndex = i + needleFoot.length();
						needleIndexLast = needleIndex;
					}
					else
					{
						reformContinue = false;
					}
				}
			}
			
			if (reformContinue == false)
			{
				output = output + XMLText.substring(needleIndexLast, XMLText.length()); 
			}
			
			return output;
		}	//private String XMLreform(String xmlDoc)
	}
