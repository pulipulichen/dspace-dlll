/*
 * BrowseUtil.java
 */
package org.dspace.app.webui.util;

import javax.servlet.http.HttpServletRequest;
import org.dspace.browse.BrowseInfo;
import org.dspace.sort.SortOption;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.DCValue;
import org.dspace.browse.BrowseIndex;
import org.dspace.core.ConfigurationManager;
import java.net.URLEncoder;
import org.dspace.app.util.EscapeUnescape;

public class BrowseUtil
{
	private String contextPath = "";
	private String linkBase = "";
	private BrowseInfo browseInfo;
	private BrowseIndex browseIndex;
	private SortOption sortOption;
	private Community community;
	private Collection collection;
	private String scope = "";
	private String type = "";
	private String value = "";
	private String sharedLink = "";
	private String urlFragment = "browse";
	private String[] fdcQuery = new String[0];
	private String[] fcQuery = new String[0];
	private String fdcQueryLink = "";
	private String fcQueryLink = "";
	private HttpServletRequest request;
	
	public BrowseUtil(HttpServletRequest requestIn, BrowseInfo bi)
	{
		this.request = requestIn;
		this.contextPath = request.getContextPath();
		if (request.getAttribute("browseWithdrawn") != null)
		{
	        this.urlFragment = "dspace-admin/withdrawn";
	    }
		
		// First, get the browse info object
		BrowseIndex bix = bi.getBrowseIndex();
		SortOption so = bi.getSortOption();
		
		// values used by the header
		String scope = "";
		String type = "";
		String value = "";
		
		Community community = null;
		Collection collection = null;
		if (bi.inCommunity())
		{
			community = (Community) bi.getBrowseContainer();
		}
		if (bi.inCollection())
		{
			collection = (Collection) bi.getBrowseContainer();
		}
		
		if (community != null)
		{
			scope = "\"" + community.getMetadata("name") + "\"";
		}
		if (collection != null)
		{
			scope = "\"" + collection.getMetadata("name") + "\"";
		}
		
		type = bix.getName();
		
		if (bi.hasValue())
		{
			value = "\"" + bi.getValue() + "\"";
		}
		
		String linkBaseIn = request.getContextPath() + "/";
		if (collection != null)
		{
			linkBaseIn = linkBaseIn + "handle/" + collection.getHandle() + "/";
		}
		if (community != null)
		{
			linkBaseIn = linkBaseIn + "handle/" + community.getHandle() + "/";
		}
		
		this.linkBase = linkBaseIn;
		
		this.browseInfo = bi;
		this.browseIndex = bix;
		this.sortOption = so;
		
		this.community = community;
		this.collection = collection;
		
		this.scope = scope;
		this.type = type;
		this.value = value;
		
		setSharedLink();
		setFilterDCValueQuery();
		setFilterConnectorQuery();
	}
	public String getScope()
	{
		return this.scope;
	}
	public String getType()
	{
		return this.type;
	}
	public String getValue()
	{
		return this.value;
	}
	public String getLinkBase()
	{
		return this.linkBase;
	}
	
	public String getDirection()
	{
		return (browseInfo.isAscending() ? "ASC" : "DESC");
	}
	
	public String getValueString()
	{
		String valueString = "";
		if (browseInfo.hasValue())
		{
			valueString = "&amp;value=" + URLEncoder.encode(browseInfo.getValue());
		}
		return valueString;
	}
	
	public void setSharedLink()
	{
		String direction = getDirection();
		String valueString = getValueString();
		String sharedLink = linkBase + urlFragment + "?";

	    if (browseIndex.getName() != null)
	        sharedLink += "type=" + URLEncoder.encode(browseIndex.getName());

	    sharedLink += "&amp;sort_by=" + URLEncoder.encode(Integer.toString(sortOption.getNumber())) +
					  "&amp;order=" + URLEncoder.encode(direction) +
					  "&amp;rpp=" + URLEncoder.encode(Integer.toString(browseInfo.getResultsPerPage())) +
					  "&amp;etal=" + URLEncoder.encode(Integer.toString(browseInfo.getEtAl())) +
					  valueString;
		
		String sortType = browseInfo.getSortType();
		if (sortType != null)
			sharedLink += "&amp;sort_type=" + URLEncoder.encode(sortType);
		
		sharedLink += getFilterDCValueQueryLink() 
			+ getFilterConnectorQueryLink();
		this.sharedLink = sharedLink;
	}
	
	public String getSharedLink()
	{
		return this.sharedLink;
	}
	
	public String getNextLink()
	{
		String next = this.sharedLink;
		if (browseInfo.hasNextPage())
	    {
	        next = next + "&amp;offset=" + browseInfo.getNextOffset();
	    }
	    //next = next + getFilterDCValueQueryLink();
	    return next;
	}
	public String getLastLink()
	{
		String last = this.sharedLink;
	    last = last + "&amp;offset=" + browseInfo.getLastOffset();
	    return last;
	}
	public String getPrevLink()
	{
		String prev = this.sharedLink;
		if (browseInfo.hasPrevPage())
	    {
	        prev = prev + "&amp;offset=" + browseInfo.getPrevOffset();
	    }
	    //prev = prev + getFilterDCValueQueryLink();
	    return prev;
	}
	public String getFirstLink()
	{
		String first = this.sharedLink;
		first = first + "&amp;offset=" + "0";
		return first;
	}
	public void setFilterDCValueQuery()
	{
		if (browseInfo.hasFilterDCValue())
	    {
	    	DCValue[] filterDCValue = browseInfo.getFilterDCValue();
	    	String[] filterOperator = browseInfo.getFilterOperator();
	    	String[] fdcQuery = new String[filterDCValue.length];
	    	for (int i = 0; i < filterDCValue.length; i++)
	    	{
	    		DCValue dc = filterDCValue[i];
	    		String value = dc.value;
	    		if (value.substring(0, 1).equals("%"))
	    			value = "%" + value.substring(1, value.length());
	    		if (value.substring(value.length() -1, value.length()).equals("%"))
	    			value = value.substring(0, value.length() - 1 ) + "%";
	    		
	    		value = EscapeUnescape.escape(value);
	    		//value = EscapeUnescape.escape(value);
	    		//value = EscapeUnescape.escape(value);
	    		
	    		String op = filterOperator[i];
	    		String fdc_query = dc.schema + "."
	    			+ dc.element;
	    		if (dc.qualifier != null)
	    			fdc_query = fdc_query + "." + dc.qualifier;
	    		fdc_query = fdc_query 	
	    			+ op + value;
	    		
	    		fdcQuery[i] = fdc_query;
	    	}
	    	 this.fdcQuery = fdcQuery;
	    	 setFilterDCValueQueryLink();
	    	 setFilterConnectorQueryLink();
	    }
	    else
	    	this.fdcQuery = new String[0];
	}
	
	public void setFilterConnectorQuery()
	{
		if (browseInfo.hasFilterConnector())
	    {
	    	String[] filterConnector = browseInfo.getFilterConnector();
	    	String[] fcQuery = new String[(filterConnector.length)];
	    	for (int i = 0; i < filterConnector.length; i++)
	    	{
	    		String conn = filterConnector[i];
	    		fcQuery[i] = conn;
	    	}
	    	 this.fcQuery = fcQuery;
	    	 setFilterConnectorQueryLink();
	    }
	    else
	    	this.fcQuery = new String[0];
	}
	
	public void setFilterDCValueQueryLink()
	{
		String link = "";
		for (int i = 0; i < fdcQuery.length;i++)
		{
			link = link + "&amp;fdc["+i+"]=" 
	    			+ EscapeUnescape.escape(fdcQuery[i]);
		}
		this.fdcQueryLink = link;
	}
	
	public void setFilterConnectorQueryLink()
	{
		String link = "";
		for (int i = 0; i < fcQuery.length;i++)
		{
			link = link + "&amp;fc["+i+"]=" 
	    			+ fcQuery[i];
		}
		this.fcQueryLink = link;
	}
	
	
	public String getFilterDCValueQueryLink()
	{
		return this.fdcQueryLink;
	}
	
	public String[] getFilterDCValueQuery()
	{
		return this.fdcQuery;
	}
	
	public String getFilterConnectorQueryLink()
	{
		return this.fcQueryLink;
	}
	
	public String[] getFilterConnectorQuery()
	{
		return this.fcQuery;
	}
	
	public String getFormAction()
	{
		// prepare a url for use by form actions
		String formaction = contextPath + "/";
		if (collection != null)
		{
			formaction = formaction + "handle/" + collection.getHandle() + "/";
		}
		if (community != null)
		{
			formaction = formaction + "handle/" + community.getHandle() + "/";
		}
		formaction = formaction + urlFragment;
		return formaction;
	}
	public String getSortedBy()
	{
		return sortOption.getName();
	}
	
	public String getASCSelected()
	{
		return (browseInfo.isAscending() ? "selected=\"selected\"" : "");
	}
	public String getDESCSelected()
	{
		return (browseInfo.isAscending() ? "" : "selected=\"selected\"");
	}
	
	public String getTypeKey()
	{
		String typeKey;

		if (browseIndex.isMetadataIndex())
			typeKey = "browse.type.metadata." + browseIndex.getName();
		else if (browseInfo.getSortOption() != null)
			typeKey = "browse.type.item." + browseInfo.getSortOption().getName();
		else
			typeKey = "browse.type.item." + browseIndex.getSortOption().getName();
		
		return typeKey;
	}
	
	public String[] getPagesLink()
	{
		int total = browseInfo.getTotal();
		int per = browseInfo.getResultsPerPage();
		int pagesLength = (int) ((total) / per);
	    if ((total) % per != 0)
	    	pagesLength++;
	    
	    String[] pages = new String[pagesLength];
	    for (int i = 0; i < pages.length; i++)
	    {
	    	int offset = per * i;
	    	
	    	pages[i] = sharedLink + "&amp;offset=" + offset;
	    }
	    return pages;
	}
	public int getCurrentPageIndex()
	{
		//int total = browseInfo.getTotal();
		int per = browseInfo.getResultsPerPage();
		int offset = browseInfo.getOffset();
		return (int) (offset / per);
	}
	public String getPagesList()
	{
		String list = "";
		String[] pages = getPagesLink();
		int currentPageIndex = getCurrentPageIndex();
		for (int i = 0; i < pages.length; i++)
		{
			if (i != currentPageIndex)
			{
				list += " <a href=\""+pages[i]+"\">"+(i+1)+"</a> ";
			}
			else
			{
				list += " "+(i+1)+" ";
			}
		}
		return list;
	}
	
	public String getPagesList(int range)
	{
		String list = "";
		String[] pages = getPagesLink();
		int currentPageIndex = getCurrentPageIndex();
		
		String before = "...";
		int min = currentPageIndex - range;
		if (min < 0)
		{
			before = "";
			min = 0;
		}
		String after = "...";
		int max = currentPageIndex + range;
		if (max > pages.length - 1)
		{
			after = "";
			max = pages.length - 1;
		}
		
		for (int i = min; i < max + 1; i++)
		{
			if (i != currentPageIndex)
			{
				list += " <a href=\""+pages[i]+"\">"+(i+1)+"</a> ";
			}
			else
			{
				list += " "+(i+1)+" ";
			}
		}
		list = before + list + after;
		return list;
	}
}	//BrowseInfo	