/*
	SubmissionUtil.java
	2009.05.31.Pudding
	2009.05.27.kihiko

*/


package org.dspace.app.webui.util;
import java.io.File;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;
import java.lang.Exception;
import org.xml.sax.SAXException;
import org.w3c.dom.*;
import org.dspace.content.DCValue;
import org.dspace.app.util.DCInput;
import org.dspace.app.util.DCInputSet;
import org.dspace.content.Item;
import org.dspace.core.I18nUtil;
import org.dspace.core.ConfigurationManager;
import org.dspace.app.util.SubmissionInfo;
import org.dspace.app.util.SubmissionConfig;
import org.dspace.app.util.SubmissionStepConfig;
import org.dspace.app.util.DCInputsReader;
import javax.servlet.jsp.jstl.fmt.LocaleSupport;
import javax.servlet.jsp.PageContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.xml.xpath.*;
import javax.xml.parsers.*;
import javax.servlet.jsp.PageContext;
import org.dspace.app.util.DCInputsReader;

public class SubmissionUtil
{
	/** Prefix of the item submission definition XML file */
    static final String SUBMIT_DEF_FILE_PREFIX = "item-submission";
    
	static final String INPUT_DEF_FILE_PREFIX = "input-forms";
	
    /** Suffix of the item submission definition XML file */
    static final String SUBMIT_DEF_FILE_SUFFIX = ".xml";

	/** The fully qualified pathname of the directory containing the Item Submission Configuration file */
    private static String configDir = ConfigurationManager.getProperty("dspace.dir")
            + File.separator + "config" + File.separator;
			
	private static String itemSubmissionPath = configDir + SUBMIT_DEF_FILE_PREFIX + SUBMIT_DEF_FILE_SUFFIX;
	
	private static String inputFormsPath = configDir + INPUT_DEF_FILE_PREFIX + SUBMIT_DEF_FILE_SUFFIX;
		
	public static String[] locateXPath(Document doc, String Xpath)
		throws XPathExpressionException, ServletException
	{	
		Object result;
		try
		{
			XPathFactory factory = XPathFactory.newInstance();
			XPath xpath = factory.newXPath();
			XPathExpression expr = xpath.compile(Xpath);
			
			result = expr.evaluate(doc, XPathConstants.NODESET);
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
	
	public static Document getXMLDocument(String uri) throws ServletException
	{
		try
        {
            DocumentBuilderFactory factory = DocumentBuilderFactory
                    .newInstance();
            factory.setValidating(false);
            factory.setIgnoringComments(true);
            factory.setIgnoringElementContentWhitespace(true);

            DocumentBuilder db = factory.newDocumentBuilder();
            Document doc = db.parse(uri);
			return doc;
        }
        catch (FactoryConfigurationError fe)
        {
            throw new ServletException (
                    "Cannot create Item Submission Configuration parser", fe);
        }
        catch (Exception e)
        {
            throw new ServletException(
                    "Error creating Item Submission Configuration: " + e);
        }
	}
	
	public static Document loadItemSubmission() throws ServletException
	{
		String uri = "file:" + new File(itemSubmissionPath).getAbsolutePath();
	   	return getXMLDocument(uri);
	}
	
	public static Document loadInputForms() throws ServletException
	{
		String uri = "file:" + new File(inputFormsPath).getAbsolutePath();
		return getXMLDocument(uri);
	}
	public static int getFileUploadStep() throws ServletException, XPathExpressionException
	{
		Document doc = loadItemSubmission();
	   	
		String processingXPath = "/item-submission/submission-definitions/submission-process[@name='traditional']/step/processing-class/text()";
        String[] stepProcessing = locateXPath(doc, processingXPath);
		
		for (int i = 0; i < stepProcessing.length; i++)
		{
			if (stepProcessing[i].equals("org.dspace.submit.step.UploadStep"))
			{
				return i+1;
			}
		}
		return 3;
	}
	
	public static String getFormName(String collectionHandle) throws ServletException
	{
		try
		{
			String formName = "traditional";
			DCInputsReader dcInputsReader = new DCInputsReader();
			DCInputSet inputSet = dcInputsReader.getInputs(collectionHandle);
			formName = inputSet.getFormName();
			return formName;
		}
		catch (ServletException e) 
		{
			throw new ServletException(
                    "Error get form name from input-types.xml: " + e);
		}
	
	}
	
	public static String[] getPageLabels(PageContext pageContext, String collectionHandle) throws ServletException ,XPathExpressionException
	{
		return getPageLabels(pageContext, collectionHandle, "jsp.submit.progressbar.describe");
	}
	
	public static String[] getPageLabels(PageContext pageContext, String collectionHandle, String key) throws ServletException ,XPathExpressionException
	{
		String formName = getFormName(collectionHandle);
		
		String labelXPath = "/input-forms/form-definitions/form[@name='"+formName+"']/page/@label";
		String numberXPath = "/input-forms/form-definitions/form[@name='"+formName+"']/page[@label!=\'\']/@number";
		
		Document doc = loadInputForms();
		String[] pageLabels = locateXPath(doc,labelXPath);
		String[] pageNumbers = locateXPath(doc,numberXPath);
		
		int pages = getNumberInputPages(collectionHandle);
		String[] labels = new String[pages];
		
		for (int p = 0; p < pages; p++)
		{
			//String key = "jsp.submit.edit-metadata.title";
			labels[p] = LocaleSupport.getLocalizedMessage(pageContext, key);
		}
		
		for(int p = 0; p < pageNumbers.length ; p++)
		{
			int number = Integer.parseInt(pageNumbers[p]) - 1;
			String label = pageLabels[p];
			labels[number] = label;
		}
		
		return labels;
	}
	public static String[] getPageHints(String collectionHandle) throws ServletException ,XPathExpressionException
	{
		String formName = getFormName(collectionHandle);
		
		String hintXPath = "/input-forms/form-definitions/form[@name='"+formName+"']/page/@hint";
		String numberXPath = "/input-forms/form-definitions/form[@name='"+formName+"']/page[@hint!=\'\']/@number";
		
		Document doc = loadInputForms();
		String[] pageHints = locateXPath(doc,hintXPath);
		String[] pageNumbers = locateXPath(doc,numberXPath);
		
		int pages = getNumberInputPages(collectionHandle);
		String[] hints = new String[pages];
		
		for (int p = 0; p < pages; p++)
		{
			hints[p] = "";
		}
		
		for(int p = 0; p < pageNumbers.length; p++)
		{
			int number = Integer.parseInt(pageNumbers[p]) - 1;
			String hint = pageHints[p];
			hints[number] = hint;
		}
		
		return hints;
	}
	
	public static int getNumberInputPages(String collectionHandle) throws ServletException
	{
		DCInputsReader dcInputsReader = new DCInputsReader();
		return dcInputsReader.getNumberInputPages(collectionHandle);
	}
}