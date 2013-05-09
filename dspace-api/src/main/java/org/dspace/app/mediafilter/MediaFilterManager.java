/*
 * MediaFilterManager.java
 *
 * Version: $Revision: 2824 $
 *
 * Date: $Date: 2008-03-12 16:45:01 -0500 (Wed, 12 Mar 2008) $
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

package org.dspace.app.mediafilter;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.MissingArgumentException;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.PosixParser;

import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.Bitstream;
import org.dspace.content.BitstreamFormat;
import org.dspace.content.Bundle;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.DCDate;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.ItemIterator;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.PluginManager;
import org.dspace.core.SelfNamedPlugin;
import org.dspace.handle.HandleManager;
import org.dspace.search.DSIndexer;
import java.util.Date;
import org.dspace.storage.rdbms.DatabaseManager;

import java.io.IOException;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.lang.StackTraceElement;
import java.util.Timer;
import java.lang.Thread;
import org.dspace.app.util.FileUtil;
import org.apache.log4j.Category;
import org.apache.log4j.Logger;
import org.apache.log4j.helpers.OptionConverter;
import java.net.ConnectException;
import org.dspace.app.mediafilter.MediaFilterUtils;
import java.io.FileNotFoundException;
import java.sql.SQLException;

import java.io.EOFException;
import java.io.File;
import java.lang.Process;
import java.lang.Runtime;

import org.dspace.app.util.FilterMediaLogDeleteThread;
import org.dspace.app.util.FilterMediaLock;

/**
 * MediaFilterManager is the class that invokes the media/format filters over the
 * repository's content. a few command line flags affect the operation of the
 * MFM: -v verbose outputs all extracted text to STDOUT; -f force forces all
 * bitstreams to be processed, even if they have been before; -n noindex does not
 * recreate index after processing bitstreams; -i [identifier] limits processing 
 * scope to a community, collection or item; and -m [max] limits processing to a
 * maximum number of items.
 */
public class MediaFilterManager
{
	//logger
	private static Logger log = Logger.getLogger(MediaFilterManager.class);
	
	//key (in dspace.cfg) which lists all enabled filters by name
    public static String MEDIA_FILTER_PLUGINS_KEY = "filter.plugins";
	
    //prefix (in dspace.cfg) for all filter properties
    public static String FILTER_PREFIX = "filter";
    
    //suffix (in dspace.cfg) for input formats supported by each filter
    public static String INPUT_FORMATS_SUFFIX = "inputFormats";
    
    public static boolean updateIndex = true; // default to updating index

    public static boolean isVerbose = false; // default to not verbose

    public static boolean isForce = false; // default to not forced
    
    public static boolean doLog = false; // default to not log
    
    public static boolean isAlone = false; // default to do queue
    
    public static String identifier = null; // object scope limiter
    
    public static int max2Process = Integer.MAX_VALUE;  // maximum number items to process
    
    public static int processed = 0;   // number items processed
    
    private static Item currentItem = null;   // current item being processed
    
    private static FormatFilter[] filterClasses = null;
    
    private static Map filterFormats = new HashMap();
    
    private static List skipList = null; //list of identifiers to skip during processing
    
    //separator in filterFormats Map between a filter class name and a plugin name,
    //for MediaFilters which extend SelfNamedPlugin (\034 is "file separator" char)
    public static String FILTER_PLUGIN_SEPARATOR = "\034";
    
    //底下是布丁後來加入的參數
    private static String queueFilePath = ConfigurationManager.getProperty("log.dir","/dspace/log") + "/filter-media-queue.log";
    private static String logFilePath = null;
    private static int openofficeRestartedCounter = 0;
    private static boolean openofficeIsRestarted = false;
    private static int openofficeRestartedMax = ConfigurationManager.getIntProperty("filter-media.openoffice-restart-max", 10);    
    private static int queueRetryCount = 0;
    private static int queueRetryMax = ConfigurationManager.getIntProperty("filter-media.queue-retry-max", 3);
    private static String[] processArgv = new String[0];
    private static Context lastContext = null;
    private static boolean filterMediaUseProxool = ConfigurationManager.getBooleanProperty("filter-media.use-proxool", false);
    private static int databaseReconnectCounter = 0;
    private static int databaseReconnectMax = ConfigurationManager.getIntProperty("filter-media.reconnect-max", 3);
    private static int databaseReconnectDelay = ConfigurationManager.getIntProperty("filter-media.reconnect-delay", 10000);
    private static long filterMediaDelay = ConfigurationManager.getLongProperty("filter-media.deley", 1000);
    private static long deleteLogDelay = ConfigurationManager.getLongProperty("filter-media.delete-log-delay", 10000);
    
    private static boolean defaultUseAlone = ConfigurationManager.getBooleanProperty("filter-media.default-use-alone", false);
    private static boolean useSourceBitstream = ConfigurationManager.getBooleanProperty("filter-media.use-source-bitstream", true);
    
    public static void main(String[] argv) throws Exception
    {
    	if (defaultUseAlone == true && hasOption(argv, "-a") == false)
    	{
    		String[] newArgv = new String[(argv.length + 1)];
    		for (int i = 0; i < argv.length; i++)
    			newArgv[i] = argv[i];
    		newArgv[(argv.length)] = "-a";
    		argv = newArgv;
    	}
    	
    	if (hasOption(argv, "-h") || hasOption(argv, "-a"))
    	{
    		processAlone(argv);
    	}
    	else if (hasQueue() == false)
    	{
			pushQueue(argv);
    		try
    		{
    			processQueue();
    		}
    		catch (Exception e) {
    			popQueue();
    			throw e;
    		}
    	}
    	else if (hasQueue() == true && hasOption(argv, "-c") == false)
    	{
    		pushQueue(argv);
    		
    		System.out.println("[QUEUE] Add filter-media mission to queue. Now "+countQueue()+" mission in queue.");
    		
			logQueue(argv);
			
			if (isDsrun(argv))
			{
				System.exit(0);
			}
    	}
    	else if (hasQueue() == true && hasOption(argv, "-c") == true)
    	{
    		try
    		{
    			if (FilterMediaLock.isLock() == false)
    				processQueue();
    			else
    			{
    				System.out.println("[QUEUE] filter-media mission still processing. Now "+countQueue()+" mission in queue.");
    			}
    		}
    		catch (Exception e) {
    			popQueue();
    			throw e;
    		}
    	}
    }
    
    public static void processAlone(String[] argv) throws Exception
    {
    	boolean result = false;
    	boolean success = false;
    	for (int i = 0; i < databaseReconnectMax && success == false; i++)
    	{
	    	try
	    	{
    			result = process(argv);
    			success = true;
	    	}
	    	catch (Exception e)
	    	{
	    		//如果資料庫錯誤的話，則顯示錯誤訊息，然後重連
	    		String msg = "Connnection error. Wait for "+(ConfigurationManager.getLongProperty("filter-media.reconnect-delay", 10000) /1000/60)+" minute.";
	    		System.out.println(msg);
	    		e.printStackTrace();
	    		writeLogln(msg);
	    		writeLogln(getStackTrace(e));
	    		
	    		try
				{
					Thread.currentThread().sleep(ConfigurationManager.getLongProperty("filter-media.delete-log-delay", 10000));
				}
				catch (Exception threade) {}
				
				msg = "\nTry reconnect in "+(i+1)+"...\n";
	    		System.out.println(msg);
	    		writeLogln(msg);
	    	}
	    }
		deleteLog();
		System.out.println("Filter-media complete (alone mode)");
		writeLog("Filter-media complete (alone mode)");
		
		if (isDsrun(argv) == false && defaultUseAlone == true)
			MediaFilterRecycle.clean();
		
		if (isDsrun(argv))
		{
			MediaFilterRecycle.clean();
    		
    		if (result == true)
    			System.exit(0);
    		else
    			System.exit(1);
    	}
    	else
    	{
    		System.out.println("process not exit");
			writeLog("process not exit");
    	}
    }
    
    public static void processQueue() throws Exception
    {
    	//處始化參數
    	//get argv[] from queue
    	boolean result = false;
	    boolean delay = false;
	    boolean isContinue = false;
	    String[] argv = new String[0];
	    
	    //開始執行
    	if (hasQueue() == true)
    	{
    		//讀取參數
	    	argv = readQueue();

	    	FilterMediaLock.lock(argv);
	    	boolean success = false;
	    	for (int i = 0; i < databaseReconnectMax && success == false; i++)
	    	{
		    	try
		    	{
		    		result = process(argv);
		    		success = true;
		    	}
		    	catch (EOFException e)
		    	{
		    		//如果資料庫錯誤的話，則顯示錯誤訊息，然後重連
		    		String msg = "Connnection error. Wait for "+(ConfigurationManager.getLongProperty("filter-media.reconnection-delay", 10000) /1000/60)+" minute.";
		    		System.out.println(msg);
		    		e.printStackTrace();
		    		writeLogln(msg);
		    		writeLogln(getStackTrace(e));
		    		
		    		try
					{
						Thread.currentThread().sleep(ConfigurationManager.getLongProperty("filter-media.delete-log-delay", 10000));
					}
					catch (Exception threade) {}
					
					msg = "\nTry reconnect in "+(i+1)+"...\n";
		    		System.out.println(msg);
		    		writeLogln(msg);
		    	}
		    	catch (SQLException e)
		    	{
		    		//如果資料庫錯誤的話，則顯示錯誤訊息，然後重連
		    		String msg = "Connnection error. Wait for "+(ConfigurationManager.getLongProperty("filter-media.reconnection-delay", 10000) /1000/60)+" minute.";
		    		System.out.println(msg);
		    		e.printStackTrace();
		    		writeLogln(msg);
		    		writeLogln(getStackTrace(e));
		    		
		    		try
					{
						Thread.currentThread().sleep(ConfigurationManager.getLongProperty("filter-media.delete-log-delay", 10000));
					}
					catch (Exception threade) {}
					
					msg = "\nTry reconnect in "+(i+1)+"...\n";
		    		System.out.println(msg);
		    		writeLogln(msg);
		    	}
		    }
	    	popQueue();
   			FilterMediaLock.unlock();

	    }
	    
	    //下一個之前，看看是不是有要繼續做下去的打算
    	if (hasQueue() == true)
    	{
    		String[] nextArgv = readQueue();
    		isContinue = queueIsContinue(argv, nextArgv);
    		if (isContinue == true)
    		{
	    		println("Continue next queue...\n");
	    	}
		}
		
		//如果結果並不好，則把此任務列到排程最後面
    	if (result == false && isContinue == false)
    	{
    		if (queueRetryMax != -1
    			&& queueRetryCount < queueRetryMax)
    		{
    			pushQueue(argv);
    			queueRetryCount++;
    			
    			System.out.println("[QUEUE] Filter error. Wait for retry.");
				writeLogln("[QUEUE] Filter error. Wait for retry.");
    		}
    		else
    		{
    			System.out.println("[QUEUE] Filter error. Out of retry max("+queueRetryMax+").");
				writeLogln("[QUEUE] Filter error. Out of retry max("+queueRetryMax+").");
				deleteLog();
    		}
    	}
    	
    	//準備結束這個工作
    	if (isContinue == false)
		{
            // update search index?
            if (hasOption(argv, "-n") == false)
            {
                print("Updating search index...");
                DSIndexer.updateIndex(lastContext);
                println("over.");
            }
			
    		//System.out.print("\nPrepare complete connect...");
			//writeLog("\nPrepare complete connect...");
			
			lastContext = closeContext(lastContext);
		    //System.out.println("ok");
			//writeLogln("ok");
			
			deleteLog();
			System.out.println("Filter-media complete");
			writeLog("Filter-media complete");
			
    		//System.out.println("Filter-media complete");
    		//writeLog("Filter-media complete");
	    	
		}
    	
    	//開始下一個工作
		if (hasQueue() == true)
		{
			//Thread.currentThread().sleep(ConfigurationManager.getLongProperty("filter-media.deley", 10000));
			
			Thread nextQueue = new Thread() {
				public void run()
				{
					try
					{
						MediaFilterManager.processQueue();
					}
					catch (Exception e) {}
				}
			};
			nextQueue.start();
			/*
			if (isDsrun(argv))
				processQueue();
			else
			{
				String dspaceDir = ConfigurationManager.getProperty("dspace.dir", "/dspace");
				String path = dspaceDir + File.separator +"bin"+File.separator+"filter-media";
				String cmd = path + " -c";
				Process p = Runtime.getRuntime().exec(cmd);	//不停留在這個畫面，只能從Log檔上看到結果
				System.exit(0);
				//MediaFilterUtils.doProcess(cmd);	//能從畫面上看到結果，但是Java機器會因此爆掉
			}
			*/
    	}
    	else if (hasQueue() == false)
    	{
    		MediaFilterRecycle.clean();
    		
    		if (isDsrun(argv))
    		{
	    		//if (result == true)
	    			System.exit(0);
	    		//else
	    		//	System.exit(1);
	    	}
    	}
    }
    
    public static boolean process(String[] argv) throws Exception
    {
    	boolean result = true;
    	
        // set headless for non-gui workstations
        System.setProperty("java.awt.headless", "true");

        // create an options object and populate it
        CommandLineParser parser = new PosixParser();

        int status = 0;

        Options options = new Options();
        
        options.addOption("v", "verbose", false,
                "print all extracted text and other details to STDOUT");
        options.addOption("f", "force", false,
                "force all bitstreams to be processed");
        options.addOption("n", "noindex", false,
                "do NOT update the search index after filtering bitstreams");
        options.addOption("i", "identifier", true,
        		"ONLY process bitstreams belonging to identifier or bitstream ID");
        options.addOption("m", "maximum", true,
				"process no more than maximum items");
        options.addOption("l", "log", true,
				"write temp log file");
		options.addOption("d", "dsrun", false,
                "call by dsrun");
        options.addOption("c", "continue", false,
                "continue prev mission");
        options.addOption("a", "alone", false,
                "prcoess without queue");
        options.addOption("h", "help", false, "help");

        //create a "plugin" option (to specify specific MediaFilter plugins to run)
        OptionBuilder.withLongOpt("plugins");
        OptionBuilder.withValueSeparator(',');
        OptionBuilder.withDescription(
                       "ONLY run the specified Media Filter plugin(s)\n" +
                       "listed from '" + MEDIA_FILTER_PLUGINS_KEY + "' in dspace.cfg.\n" + 
                       "Separate multiple with a comma (,)\n" +
                       "(e.g. MediaFilterManager -p \n\"Word Text Extractor\",\"PDF Text Extractor\")");                
        Option pluginOption = OptionBuilder.create('p');
        pluginOption.setArgs(Option.UNLIMITED_VALUES); //unlimited number of args
        options.addOption(pluginOption);	
        
         //create a "skip" option (to specify communities/collections/items to skip)
        OptionBuilder.withLongOpt("skip");
        OptionBuilder.withValueSeparator(',');
        OptionBuilder.withDescription(
                "SKIP the bitstreams belonging to identifier\n" + 
                "Separate multiple identifiers with a comma (,)\n" +
                "(e.g. MediaFilterManager -s \n 123456789/34,123456789/323)");                
        Option skipOption = OptionBuilder.create('s');
        skipOption.setArgs(Option.UNLIMITED_VALUES); //unlimited number of args
        options.addOption(skipOption);    
        
        CommandLine line = null;
        try
        {
            line = parser.parse(options, argv);
        }
        catch(MissingArgumentException e)
        {
            System.out.println("ERROR: " + e.getMessage());
            HelpFormatter myhelp = new HelpFormatter();
            myhelp.printHelp("MediaFilterManager\n", options);
            //if (isDsrun(argv))
            //	System.exit(1);
            //else
            	return true;
        }          

        if (line.hasOption('h'))
        {
            HelpFormatter myhelp = new HelpFormatter();
            myhelp.printHelp("MediaFilterManager\n", options);
            //if (isDsrun(argv))
			//	System.exit(0);
			//else
				return true;
        }

        if (line.hasOption('v'))
        {
            isVerbose = true;
        }
        else
        {
        	isVerbose = false;
        }

        if (line.hasOption('n'))
        {
            updateIndex = false;
        }
        else
        {
        	updateIndex = true;
        }

        if (line.hasOption('f'))
        {
            isForce = true;
        }
        else
        {
        	isForce = false;
        }
        
        if (line.hasOption('i'))
        {
        	identifier = line.getOptionValue('i');
        }
        else
        {
        	identifier = null;
        }
        
        logFilePath = null;
        if (line.hasOption('l'))
        {
        	if (line.getOptionValue('l') != null)
        	{
        		setupLog(line.getOptionValue('l'));
			}
        }
        else
        	logFilePath = null;
        
        if (line.hasOption('m'))
        {
        	max2Process = Integer.parseInt(line.getOptionValue('m'));
        	if (max2Process <= 1)
        	{
        		System.out.println("Invalid maximum value '" + 
        				     		line.getOptionValue('m') + "' - ignoring");
        		writeLogln("Invalid maximum value '" + 
        				     		line.getOptionValue('m') + "' - ignoring");
        		max2Process = Integer.MAX_VALUE;
        	}
        }
        else
        	max2Process = Integer.MAX_VALUE;
        
        if (line.hasOption('a'))
        {
            isAlone = true;
        }
        else
        {
        	isAlone = false;
        }

        String filterNames[] = null;
        if(line.hasOption('p'))
        {
            //specified which media filter plugins we are using
            filterNames = line.getOptionValues('p');
        
            if(filterNames==null || filterNames.length==0)
            {   //display error, since no plugins specified
                System.err.println("\nERROR: -p (-plugin) option requires at least one plugin to be specified.\n" +
                                          "(e.g. MediaFilterManager -p \"Word Text Extractor\",\"PDF Text Extractor\")\n");
                writeLogln("\nERROR: -p (-plugin) option requires at least one plugin to be specified.\n" +
                                          "(e.g. MediaFilterManager -p \"Word Text Extractor\",\"PDF Text Extractor\")\n");
                HelpFormatter myhelp = new HelpFormatter();
                myhelp.printHelp("MediaFilterManager\n", options);
                //deleteLog(true);
                //if (isDsrun(argv))
				//	System.exit(1);
				//else
					return true;
             }
        }
        else
        { 
            //retrieve list of all enabled media filter plugins!
            String enabledPlugins = ConfigurationManager.getProperty(MEDIA_FILTER_PLUGINS_KEY);
            filterNames = enabledPlugins.split(",\\s*");
        }
        
        //initialize an array of our enabled filters
        List filterList = new ArrayList();
                
        //set up each filter
        for(int i=0; i< filterNames.length; i++)
        {
            //get filter of this name & add to list of filters
            FormatFilter filter = (FormatFilter) PluginManager.getNamedPlugin(FormatFilter.class, filterNames[i]);
            if(filter==null)
            {   
                System.err.println("\nERROR: Unknown MediaFilter specified (either from command-line or in dspace.cfg): '" + filterNames[i] + "'");
                writeLogln("\nERROR: Unknown MediaFilter specified (either from command-line or in dspace.cfg): '" + filterNames[i] + "'");
                //deleteLog(true);
                //if (isDsrun(argv))
				//	System.exit(1);
				//else
					return true;
            }
            else
            {   
                filterList.add(filter);
                       
                String filterClassName = filter.getClass().getName();
                           
                String pluginName = null;
                           
                //If this filter is a SelfNamedPlugin,
                //then the input formats it accepts may differ for
                //each "named" plugin that it defines.
                //So, we have to look for every key that fits the
                //following format: filter.<class-name>.<plugin-name>.inputFormats
                if( SelfNamedPlugin.class.isAssignableFrom(filter.getClass()) )
                {
                    //Get the plugin instance name for this class
                    pluginName = ((SelfNamedPlugin) filter).getPluginInstanceName();
                }
            
                
                //Retrieve our list of supported formats from dspace.cfg
                //For SelfNamedPlugins, format of key is:  
                //  filter.<class-name>.<plugin-name>.inputFormats
                //For other MediaFilters, format of key is: 
                //  filter.<class-name>.inputFormats
                String formats = ConfigurationManager.getProperty(
                    FILTER_PREFIX + "." + filterClassName + 
                    (pluginName!=null ? "." + pluginName : "") +
                    "." + INPUT_FORMATS_SUFFIX);
            
                //add to internal map of filters to supported formats	
                if (formats != null)
                {
                    //For SelfNamedPlugins, map key is:  
                    //  <class-name><separator><plugin-name>
                    //For other MediaFilters, map key is just:
                    //  <class-name>
                    filterFormats.put(filterClassName + 
        	            (pluginName!=null ? FILTER_PLUGIN_SEPARATOR + pluginName : ""),
        	            Arrays.asList(formats.split(",[\\s]*")));
                }
            }//end if filter!=null
        }//end for
        
        //If verbose, print out loaded mediafilter info
        if(isVerbose && line.hasOption('c') == false)
        {   
            System.out.println("The following MediaFilters are enabled: ");
            writeLogln("The following MediaFilters are enabled: ");
            java.util.Iterator i = filterFormats.keySet().iterator();
            while(i.hasNext())
            {
                String filterName = (String) i.next();
                System.out.println("Full Filter Name: " + filterName);
                writeLogln("Full Filter Name: " + filterName);
                String pluginName = null;
                if(filterName.contains(FILTER_PLUGIN_SEPARATOR))
                {
                    String[] fields = filterName.split(FILTER_PLUGIN_SEPARATOR);
                    filterName=fields[0];
                    pluginName=fields[1];
                }
                 
                System.out.println(filterName +
                        (pluginName!=null? " (Plugin: " + pluginName + ")": ""));
                writeLogln(filterName +
                        (pluginName!=null? " (Plugin: " + pluginName + ")": ""));
             }
        }
              
        //store our filter list into an internal array
        filterClasses = (FormatFilter[]) filterList.toArray(new FormatFilter[filterList.size()]);
        
        
        //Retrieve list of identifiers to skip (if any)
        String skipIds[] = null;
        if(line.hasOption('s'))
        {
            //specified which identifiers to skip when processing
            skipIds = line.getOptionValues('s');
            
            if(skipIds==null || skipIds.length==0)
            {   //display error, since no identifiers specified to skip
                System.err.println("\nERROR: -s (-skip) option requires at least one identifier to SKIP.\n" +
                                    "Make sure to separate multiple identifiers with a comma!\n" +
                                    "(e.g. MediaFilterManager -s 123456789/34,123456789/323)\n");
                writeLogln("\nERROR: -s (-skip) option requires at least one identifier to SKIP.\n" +
                                    "Make sure to separate multiple identifiers with a comma!\n" +
                                    "(e.g. MediaFilterManager -s 123456789/34,123456789/323)\n");
                HelpFormatter myhelp = new HelpFormatter();
                myhelp.printHelp("MediaFilterManager\n", options);
                //deleteLog(true);
                //if (isDsrun(argv))
				//	System.exit(0);
				//else
					return true;
            }
            
            //save to a global skip list
            skipList = Arrays.asList(skipIds);
        }
        
        Context c = null;

        try
        {
        	if (lastContext != null)
        		c = lastContext;
        	else
        	{
            	c = new Context(filterMediaUseProxool);
            	lastContext = c;
            }
            c = validContextDBConnection(c);

            // have to be super-user to do the filtering
            c.setIgnoreAuthorization(true);
            
            //save argv
    		if (argv.length - 2 > -1)
    		{
    			if (hasOption(argv, "-i") == true)
    				processArgv = new String[(argv.length -2)];
    			else
    				processArgv = new String[(argv.length)];
    			int p = 0;
    			for (int a = 0; a < argv.length; a++)
    			{
    				if (argv[a].equals("-i") == true)
    				{
    					a++;
    					continue;
    				}
    				else
    				{
        				processArgv[p] = argv[a];
        				p++;
    				}
    			}
    		}
    		else
    			processArgv = new String[0];

            // now apply the filters
            if (identifier == null)
            {
            	applyFiltersAllItems(c);
            	result = false;
            }
            else  // restrict application scope to identifier
            {
            	/*
            	DSpaceObject dso = HandleManager.resolveToObject(c, identifier);
            	Bitstream b = Bitstream.find(c, Integer.parseInt(identifier));
            	if (dso != null)
            	{
            		switch (dso.getType())
	            	{
	            		case Constants.COMMUNITY:
	            						applyFiltersCommunity(c, (Community)dso);
	            						break;					
	            		case Constants.COLLECTION:
	            						applyFiltersCollection(c, (Collection)dso);
	            						break;						
	            		case Constants.ITEM:
	            						applyFiltersItem(c, (Item)dso);
	            						break;
	            	}
            	}
            	else if (b != null)
            	{
            		Bundle[] bundles = b.getBundles();
            		if (bundles.length > 0)
            		{
	            		Item[] items = bundles[0].getItems();
	            		if (items.length > 0)
	            		{
	            			Item myItem = items[0];
	            			filterBitstream(c, myItem, b);
	            		}
	            	}
            	}
            	else
            	{
            		throw new IllegalArgumentException("Cannot resolve "
                                + identifier + " to a DSpace object");
            	}
            	*/
            	DSpaceObject dso = null;
            	try
            	{
            		dso = HandleManager.resolveToObject(c, identifier);
            	}
            	catch (Exception dsoe) { }
            	
            	if (dso == null)
            	{
            		//if (true)
            		//	throw new EOFException("test");
            		
            		Bitstream b = Bitstream.find(c, Integer.parseInt(identifier));
            		boolean hasFilter = false;
            		if (b != null)
            		{
            			Bundle[] bundles = b.getBundles();
	            		if (bundles.length > 0)
	            		{
		            		Item[] items = bundles[0].getItems();
		            		if (items.length > 0)
		            		{
		            			Item myItem = items[0];
		            			//System.out.println("Filter by bitstream ID:" + identifier);
		            			//writeLogln("Filter by bitstream ID:" + identifier);
		            			println("Filter by bitstream " + b.getName() + " ("+b.getID()+")");
		            			boolean filterBitstreamResult = filterBitstream(c, myItem, b);
		            			//if (filterBitstreamR)
		            			//	sleep();
		            			//System.out.println("over");
		            			//writeLogln("over");
		            			hasFilter = true;
		            		}
		            	}
		            	result = true;
            		}
            		else	//if (hasFilter == false)
            		{
            			//throw new IllegalArgumentException("Cannot resolve "
                        //        + identifier + " to a DSpace object");
                        System.out.println("Cannot resolve "
                                + identifier + " to a DSpace object");
                        writeLog("Cannot resolve "
                                + identifier + " to a DSpace object");
                        result = false;
                    }
            	}
            	else
            	{
            		switch (dso.getType())
	            	{
	            		case Constants.COMMUNITY:
	            						applyFiltersCommunity(c, (Community)dso);
	            						break;					
	            		case Constants.COLLECTION:
	            						applyFiltersCollection(c, (Collection)dso);
	            						break;						
	            		case Constants.ITEM:
	            						applyFiltersItem(c, (Item)dso);
	            						break;
	            	}
	            	result = false;
            	}
            }
          
            // update search index?
            //if (updateIndex)
            //{
            //    System.out.println("Updating search index:");
            //    writeLogln("Updating search index:");
            //    DSIndexer.updateIndex(c);
            //}
            //move to queue finish
            
           	//System.out.print("\nPrepare complete connect...");
			//writeLog("\nPrepare complete connect...");
            //c.complete();
            //c = null;
            //System.out.println("ok");
			//writeLogln("ok");
			
            //result = true;
            //deleteLog();
        }
        catch (Exception e)
        {
            status = 1;
            System.out.println("Error: " + e.getMessage() );
            writeLogln("Error:" + e.toString());
            e.printStackTrace();
            StackTraceElement[] stack = e.getStackTrace();
	    	for (int s = 0; s < stack.length; s++)
	    	{
	    		String msg = stack[s].toString();
	    		if (msg.indexOf("at ") == 0)
	    			msg = "\t" + msg;
	    		writeLogln(msg);
	    	}
            //deleteLog(true);
            //Restart Mediafilter
            //MediaFilterManager.main(argv);
            throw e;
        }
        finally
        {
        	
            if (c != null)
            {
                //c.abort();
                //deleteLog(true);
            }
        }
        
        //if (isDsrun(argv))
		//	System.exit(status);
		//else
		//	return false;
		return result;
    }

    public static void applyFiltersAllItems(Context c) throws Exception
    {
        if(skipList!=null)
        {    
            //if a skip-list exists, we need to filter community-by-community
            //so we can respect what is in the skip-list
            Community[] topLevelCommunities = Community.findAllTop(c);
          
            for(int i=0; i<topLevelCommunities.length; i++)
                applyFiltersCommunity(c, topLevelCommunities[i]);
        }
        else 
        {
            //otherwise, just find every item and process
            ItemIterator i = Item.findAll(c);
            while (i.hasNext() && processed < max2Process)
            {
            	applyFiltersItem(c, i.next());
            }
        }
    }
    
    public static void applyFiltersCommunity(Context c, Community community)
                                             throws Exception
    {   //only apply filters if community not in skip-list
        if(!inSkipList(community.getHandle()))
        {    
           	Community[] subcommunities = community.getSubcommunities();
           	for (int i = 0; i < subcommunities.length; i++)
           	{
           		applyFiltersCommunity(c, subcommunities[i]);
           	}
           	
           	Collection[] collections = community.getCollections();
           	for (int j = 0; j < collections.length; j++)
           	{
           		applyFiltersCollection(c, collections[j]);
           	}
        }
    }
        
    public static void applyFiltersCollection(Context c, Collection collection)
                                              throws Exception
    {
        //only apply filters if collection not in skip-list
        if(!inSkipList(collection.getHandle()))
        {
            ItemIterator i = collection.getItems();
            while (i.hasNext() && processed < max2Process)
            {
            	applyFiltersItem(c, i.next());
            }
        }
    }
       
    public static void applyFiltersItem(Context c, Item item) throws Exception
    {
        //only apply filters if item not in skip-list
        if(!inSkipList(item.getHandle()))
        {
    	  //cache this item in MediaFilterManager
    	  //so it can be accessed by MediaFilters as necessary
    	  currentItem = item;
    	
          if (filterItem(c, item))
          {
        	  // commit changes after each filtered item
        	  c.commit();
              // increment processed count
              ++processed;
          }
          // clear item objects from context cache and internal cache
          item.decache();
          currentItem = null;
        }  
    }

    /**
     * iterate through the item's bitstreams in the ORIGINAL bundle, applying
     * filters if possible
     * 
     * @return true if any bitstreams processed, 
     *         false if none
     */
    public static boolean filterItem(Context c, Item myItem) throws Exception
    {
        // get 'original' bundles
        Bundle[] myBundles = myItem.getBundles("ORIGINAL");
        boolean done = false;
        int filterCounter = 0;
        
        String argvs = "";
        for (int i = 0; i < processArgv.length; i++)
        {
        	argvs = argvs + "\t" + processArgv[i];
        }
        argvs = argvs + "\t" + "-c";
        
        for (int i = 0; i < myBundles.length; i++)
        {
        	// now look at all of the bitstreams
            Bitstream[] myBitstreams = myBundles[i].getBitstreams();
            
            for (int k = 0; k < myBitstreams.length; k++)
            {
            	/*
            	done = filterBitstream(c, myItem, myBitstreams[k]);
            	filterCounter++;
            	
            	//if (filterCounter % 5 == 4)
            	System.out.println("Connect commit");
            	writeLogln("Connect commit");
            	c.commit();
            	*/
            	if (isAlone == false)
            	{
	            	int bitstreamID = myBitstreams[k].getID();
	            	System.out.println("[QUEUE] Add bitstream " + bitstreamID);
	            	writeLogln("[QUEUE] Add bitstream " + bitstreamID);
	            	pushQueue(argvs + "\t-i\t" + bitstreamID, 1);
	            }
	            else
	            {
	            	done = filterBitstream(c, myItem, myBitstreams[k]);
	            }
            }
        }
        return done;
    }

    /**
     * Attempt to filter a bitstream
     * 
     * An exception will be thrown if the media filter class cannot be
     * instantiated, exceptions from filtering will be logged to STDOUT and
     * swallowed.
     * 
     * @return true if bitstream processed, 
     *         false if no applicable filter or already processed
     */
    public static boolean filterBitstream(Context c, Item myItem,
            Bitstream myBitstream) throws Exception
    {
    	boolean filtered = false;
    	int itemID = myItem.getID();
    	int bitstreamID = myBitstream.getID();
    	
    	// iterate through filter classes. A single format may be actioned
    	// by more than one filter
    	
		databaseReconnectCounter = 0;
        openofficeRestartedCounter = 0;
    	for (int i = 0; i < filterClasses.length; i++)
    	{
    		//if (i > 0)
    		//{
    			//Process delay
    			//Thread.currentThread().sleep(ConfigurationManager.getLongProperty("filter-media.deley", 10000));
    		//}
    		
    		//List fmts = (List)filterFormats.get(filterClasses[i].getClass().getName());
    	    String pluginName = null;
    	               
    	    //if this filter class is a SelfNamedPlugin,
    	    //its list of supported formats is different for
    	    //differently named "plugin"
    	    if( SelfNamedPlugin.class.isAssignableFrom(filterClasses[i].getClass()) )
    	    {
    	        //get plugin instance name for this media filter
    	        pluginName = ((SelfNamedPlugin)filterClasses[i]).getPluginInstanceName();
    	    }
    	               
    	    //Get list of supported formats for the filter (and possibly named plugin)
    	    //For SelfNamedPlugins, map key is:  
    	    //  <class-name><separator><plugin-name>
    	    //For other MediaFilters, map key is just:
    	    //  <class-name>
    	    List fmts = (List)filterFormats.get(filterClasses[i].getClass().getName() + 
    	                       (pluginName!=null ? FILTER_PLUGIN_SEPARATOR + pluginName : ""));
    	    
    	    if (fmts == null)
    	    {
    	    	throw new IOException("Configuration \""+filterClasses[i].getClass().getName() + 
    	                       (pluginName!=null ? FILTER_PLUGIN_SEPARATOR + pluginName : "")+"\" is not set inputFormats.");
    	    }
    	    if (fmts.contains(myBitstream.getFormatDescription()))
    		{
            	try
            	{
            		/*
            		if (c.getDBConnection() == null || c.getDBConnection().isClosed())
            		{
            			c = resetContext(c, false);
            			myItem = Item.find(c, itemID);
            			myBitstream = Bitstream.find(c, bitstreamID);
            		}
            		*/
            		
		            // only update item if bitstream not skipped
		            boolean result = processBitstream(c, myItem, myBitstream, filterClasses[i]);
		            if (result)
            	    {
            	    	System.out.print("Update myItem...");
            	    	writeLog("Update myItem...");
            	    	
            	    	boolean success = false;
            	    	for (int d = 0; d < databaseReconnectMax && success == false; d++)
            	    	{
	            	    	try
	            	    	{
			           			myItem.update(false); // Make sure new bitstream has a sequence
			                                 		// number
			                    c.commit();
			                    success = true;
			                }
			                catch (SQLException e)
			                {
			                	if (d == databaseReconnectMax - 1)
			                	{
			                		String msg = "error!";
			                		System.out.print(msg);
	            	    			writeLog(msg);
	            	    			printFilterBitstreamError(myItem, myBitstream, null, e);
	            	    			throw e;
			                	}
			                 	else
			                 	{
				                	String msg = "reconnect("+(d+1)+")...";
				                	System.out.print(msg);
	            	    			writeLog(msg);
	            	    			c = resetContext(c, true);
	            	    		}
			                }
			            }	//for (int d = 0; d < databaseReconnectMax && success == false; d++)
			            
	                    System.out.println("over!");
	                	writeLogln("over!");
		                
		           		filtered = true;
		           		
		           		sleep();
		            }	//if (result)
            	}
            	catch (SQLException e)
            	{
            		if (databaseReconnectMax == -1 
            			|| openofficeRestartedCounter < databaseReconnectMax)
            		{
            			databaseReconnectCounter++;
						System.out.println("\nTry to reconnect database in "+(databaseReconnectCounter+1)+" \n");
						writeLogln("\nTry to reconnect database in "+(databaseReconnectCounter+1)+" \n");
            			
            			printFilterBitstreamError(myItem, myBitstream, pluginName, e);
            			c = resetContext(c, true);
            			myItem = Item.find(c, itemID);
            			myBitstream = Bitstream.find(c, bitstreamID);
            			
            			i--;
            		}
            		else
            		{
            			printFilterBitstreamError(myItem, myBitstream, pluginName, e);
            		}
            	}
            	catch (NullPointerException e)
            	{
            		if (databaseReconnectMax == -1 
            			|| openofficeRestartedCounter < databaseReconnectMax)
            		{
            			databaseReconnectCounter++;
						System.out.println("\nTry to reconnect database in "+(databaseReconnectCounter+1)+" \n");
						writeLogln("\nTry to reconnect database in "+(databaseReconnectCounter+1)+" \n");
            			
            			printFilterBitstreamError(myItem, myBitstream, pluginName, e);
            			c = resetContext(c, true);
            			myItem = Item.find(c, itemID);
            			myBitstream = Bitstream.find(c, bitstreamID);
            			
            			i--;
            		}
            		else
            		{
            			if (databaseReconnectMax > -1)
            				println("Out of retry number("+databaseReconnectMax+"). Skip this filter.");
            			printFilterBitstreamError(myItem, myBitstream, pluginName, e);
            		}
            	}
            	/*
            	catch (ConnectException e)
            	{
            		//if it is JOCConnectException, try to restart OpenOffice
            		if (openofficeRestartedMax == -1 
            			|| openofficeRestartedCounter < openofficeRestartedMax)
            		{
            			printFilterBitstreamError(myItem, myBitstream, pluginName, e);
            			restartOpenOffice();
            			i--;
            		}
            		else
            		{
            			printFilterBitstreamError(myItem, myBitstream, pluginName, e);
            		}
            	}
            	*/
            	catch (FileNotFoundException e)
            	{
            		if (filterClasses[i] != null
            			&& filterClasses[i].getClass() != null)
            		{
	            		String n = filterClasses[i].getClass().getName();
	            		System.out.println("ClassName: "+n);
	            		if ((n.equals("org.dspace.app.mediafilter.Doc2Snap")
	            				|| n.equals("org.dspace.app.mediafilter.Doc2Thumbnail")
	            				|| n.equals("org.dspace.app.mediafilter.Doc2Text")
	            				|| n.equals("org.dspace.app.mediafilter.Doc2SWF"))
	            			&& (openofficeRestartedMax == -1 || openofficeRestartedCounter < openofficeRestartedMax))
	            		{
	            			printFilterBitstreamError(myItem, myBitstream, pluginName, e);
	            			//try to restart openoffice
	            			restartOpenOffice();
	            			i--;
	            		}
	            		else
	            		{
	            			
            				printFilterBitstreamError(myItem, myBitstream, pluginName, e);
            			}
            		}
            		else
            			printFilterBitstreamError(myItem, myBitstream, pluginName, e);
            	}
                catch (Exception e)
                {
                	printFilterBitstreamError(myItem, myBitstream, pluginName, e);
                }
    		}
    	}
        return filtered;
    }
    
    public static Context closeContext(Context c) throws Exception
    {
    	System.out.print("Try to close context...");
    	writeLog("Try to close context...");
    	if (c == null)
    		return c;
    	
    	try
    	{
    		c.complete();
    		c = null;
    	}
    	catch (Exception e)
    	{
    	}
    	finally
    	{
	    	if (c != null)
	    	{
	    		try
	    		{
	    			c.abort();
	    		}
	    		catch (Exception e) { }
	    		c = null;
	    	}
	    }
	    System.out.println("over.");
    	writeLogln("over.");
	    return c;
    }
    
    public static Context resetContext(Context c) throws Exception
    {
    	return resetContext(c, true);
    }
    public static Context resetContext(Context c, boolean doDelay) throws Exception
    {
    	c = closeContext(c);
    	
    	if (doDelay)
    	{
	    	System.out.println("Wait for "+(databaseReconnectDelay/1000)+" seconds...");
	    	writeLogln("Wait for "+(databaseReconnectDelay/1000)+" seconds...");
	    	Thread.currentThread().sleep(databaseReconnectDelay);
    	}
    	
    	System.out.print("Try to rebuild context...");
    	writeLog("Try to rebuild context...");
		c = new Context(filterMediaUseProxool);
		c.setIgnoreAuthorization(true);
		lastContext = c;
		System.out.println("over.");
    	writeLogln("over.");
		return c;
    }
    
    public static Context validContextDBConnection(Context c) throws Exception
    {
    	if (c.isValid() == false
    		|| c.getDBConnection() == null
    		|| c.getDBConnection().isClosed())
    	{
    		c = resetContext(c);
    	}
    	return c;
    }
    
    
    public static void restartOpenOffice() throws Exception
    {
    	openofficeRestartedCounter++;
		System.out.println("\nTry to restart OpenOffice at "+openofficeRestartedCounter+" \n");
		writeLogln("\nTry to restart OpenOffice at "+openofficeRestartedCounter+" \n");
		//String restartCommand = ConfigurationManager.getProperty("filter-media.openoffice-restart", "/home/dspace/openoffice_restart.sh")
		
		//MediaFilterUtils.doProcess(restartCommand);
		
		
		Thread restartThread = new Thread() {
			public void run()
			{
				try
				{
					Process p = Runtime.getRuntime().exec(ConfigurationManager.getProperty("filter-media.openoffice-restart", "/home/dspace/openoffice_restart.sh"));
				}
				catch (Exception e) {}
			}
		};
		restartThread.start();
		
		Thread.currentThread().sleep(10000);
		
		System.out.println("\n");
    }
    
    public static void printFilterBitstreamError(Item myItem, Bitstream myBitstream, String pluginName, Exception e) throws Exception
    {
    	String handle = myItem.getHandle();
    	
    	String name = myBitstream.getName();
    	long size = myBitstream.getSize();
    	String checksum = myBitstream.getChecksum() + " ("+myBitstream.getChecksumAlgorithm()+")";
    	int assetstore = myBitstream.getStoreNumber();

    	// Printout helpfull information to find the errored bistream.
    	System.out.println("ERROR filtering, skipping bitstream:\n");
    	System.out.println("\tPlugin Name: " + pluginName);
    	System.out.println("\tItem Handle: "+ handle);
    	writeLogln("ERROR filtering, skipping bitstream:\n");
    	writeLogln("\tPlugin Name: " + pluginName);
    	writeLogln("\tItem Handle: "+ handle);
    	
    	try
    	{
    		Bundle[] bundles = myBitstream.getBundles();
	    	for (Bundle bundle : bundles)
	    	{
	    		System.out.println("\tBundle Name: " + bundle.getName());
	    		writeLogln("\tBundle Name: " + bundle.getName());
	    	}
	    }
	    catch (Exception sqle) { }
    	System.out.println("\tFile Size: " + size);
    	System.out.println("\tFile Name: " + name);
    	System.out.println("\tBitstream ID: " + myBitstream.getID());
    	System.out.println("\tChecksum: " + checksum);
    	System.out.println("\tAsset Store: " + assetstore);
    	System.out.println("\tException Cause: " + e.getCause());
    	//System.out.println(e);
        e.printStackTrace();
        
        writeLogln("\tFile Size: " + size);
    	writeLogln("\tFile Name: " + name);
    	writeLogln("\tBitstream ID: " + myBitstream.getID());
    	writeLogln("\tChecksum: " + checksum);
    	writeLogln("\tAsset Store: " + assetstore);
    	writeLogln("\tException Cause: " + e.getCause());
    	writeLogln(e.toString());
    	StackTraceElement[] stack = e.getStackTrace();
    	for (int s = 0; s < stack.length; s++)
    	{
    		String msg = stack[s].toString();
    		if (msg.indexOf("at ") == 0)
    			msg = "\t" + msg;
    		writeLogln(msg);
    	}
    }
    
    /**
     * processBitstream is a utility class that calls the virtual methods
     * from the current MediaFilter class.
     * It scans the bitstreams in an item, and decides if a bitstream has 
     * already been filtered, and if not or if overWrite is set, invokes the 
     * filter.
     * 
     * @param c
     *            context
     * @param item
     *            item containing bitstream to process
     * @param source
     *            source bitstream to process
     * @param formatFilter
     *            FormatFilter to perform filtering
     * 
     * @return true if new rendition is created, false if rendition already
     *         exists and overWrite is not set
     */
    public static boolean processBitstream(Context c, Item item, Bitstream source, FormatFilter formatFilter)
            throws Exception
    {
    	int itemID = item.getID();
        int bitstreamID = source.getID();
    	
        //do pre-processing of this bitstream, and if it fails, skip this bitstream!
    	if(!formatFilter.preProcessBitstream(c, item, source))
        	return false;
        
    	boolean overWrite = MediaFilterManager.isForce;
        
        // get bitstream filename, calculate destination filename
        String newName = formatFilter.getFilteredName(source.getName());

        Bitstream existingBitstream = null; // is there an existing rendition?
        Bundle targetBundle = null; // bundle we're modifying

        Bundle[] bundles = item.getBundles(formatFilter.getBundleName());

        // check if destination bitstream exists
        if (bundles.length > 0)
        {
            // only finds the last match (FIXME?)
            for (int i = 0; i < bundles.length; i++)
            {
                Bitstream[] bitstreams = bundles[i].getBitstreams();

                for (int j = 0; j < bitstreams.length; j++)
                {
                    if (bitstreams[j].getName().equals(newName))
                    {
                    	if (useSourceBitstream == false)
                    	{
                    		targetBundle = bundles[i];
	                        existingBitstream = bitstreams[j];
                    	}
                    	else if (bitstreams[j].getSourceBitstreamID() == source.getID())
                    	{
	                        targetBundle = bundles[i];
	                        existingBitstream = bitstreams[j];
	                    }
                    }
                    //if (bitstreams[j].getName().equals(newName))
                }
            }
        }

        // if exists and overwrite = false, exit
        if (!overWrite && (existingBitstream != null))
        {
            System.out.println("SKIPPED: bitstream " + source.getID()
                    + " because '" + newName + "' already exists");
			writeLogln("SKIPPED: bitstream " + source.getID()
                    + " because '" + newName + "' already exists");
            return false;
        }
        
        boolean success = false;
		for (int i = 0; i < databaseReconnectMax && success == false; i++)
		{
			println("Prepare to filter " + source.getName() + " ("+source.getID()+")");
			InputStream destStream = formatFilter.getDestinationStream(source.retrieve(), source.getName(), source.getID());
			try
			{
		        if (destStream == null)
		        {
		            System.out.println("SKIPPED: bitstream " + source.getID()
		                    + " because of filtering error");
					writeLogln("SKIPPED: bitstream " + source.getID()
		                    + " because of filtering error");
		            return false;
		        }
		        
		        // create new bundle if needed
		        if (bundles.length < 1)
		        {
		            targetBundle = item.createBundle(formatFilter.getBundleName());
		        }
		        else
		        {
		            // take the first match
		            targetBundle = bundles[0];
		        }

		        Bitstream b = targetBundle.createBitstream(destStream);
		        
		        // Now set the format and name of the bitstream
		        b.setName(newName);
		        b.setSource("Written by FormatFilter " + formatFilter.getClass().getName() +
		        			" on " + DCDate.getCurrent() + " (GMT)."); 
		        b.setDescription(formatFilter.getDescription());

		        // Find the proper format
		        BitstreamFormat bf = BitstreamFormat.findByShortDescription(c,
		                formatFilter.getFormatString());
		        b.setFormat(bf);
		        b.setSourceBitstream(source.getID());
		        b.update();
		        
		        //Inherit policies from the source bitstream
		        //(first remove any existing policies)
		        AuthorizeManager.removeAllPolicies(c, b);
		        AuthorizeManager.inheritPolicies(c, source, b);

		        // fixme - set date?
		        // we are overwriting, so remove old bitstream
		        if (existingBitstream != null)
		        {
		            targetBundle.removeBitstream(existingBitstream);
		        }

		        System.out.println("FILTERED: bitstream " + source.getID()
		                + " and created '" + newName + "'("+b.getID()+")");
				writeLogln("FILTERED: bitstream " + source.getID()
		                + " and created '" + newName + "'("+b.getID()+")");
		        
		        //do post-processing of the generated bitstream
		        formatFilter.postProcessBitstream(c, item, b);
		        
		        success = true;
		    }
		    catch (Exception e)
		    {
		    	if (i >= databaseReconnectMax - 1)
		    	{
		    		String msg = "Database connect error. Out of retry number("+databaseReconnectMax+")";
	    			println(msg);
	    			printFilterBitstreamError(item, source, null, e);
	    			throw e;
		    	}
		    	else
		    	{
					printFilterBitstreamError(item, source, null, e);
		    		
		    		String msg = "\nDatabase connect error. Retry in " + (i+1) + "...\n";
			    	System.out.println(msg);
					writeLogln(msg);
					c = resetContext(c, true);
					
					item = Item.find(c, itemID);
					bundles = item.getBundles(formatFilter.getBundleName());
					source = Bitstream.find(c, bitstreamID);
					
				}
		    }	//catch (Exception e)
        }	//for (int i = 0; i < databaseReconnectMax && success == false; i++)
        return true;
    }
    
    /**
     * Return the item that is currently being processed/filtered
     * by the MediaFilterManager
     * <p>
     * This allows FormatFilters to retrieve the Item object
     * in case they need access to item-level information for their format
     * transformations/conversions.
     * 
     * @return current Item being processed by MediaFilterManager
     */
    public static Item getCurrentItem()
    {
        return currentItem;
    }
    
    /**
     * Check whether or not to skip processing the given identifier
     * 
     * @param identifier
     *            identifier (handle) of a community, collection or item
     *            
     * @return true if this community, collection or item should be skipped
     *          during processing.  Otherwise, return false.
     */
    public static boolean inSkipList(String identifier)
    {
        if(skipList!=null && skipList.contains(identifier))
        {
            System.out.println("SKIP-LIST: skipped bitstreams within identifier " + identifier);
            writeLogln("SKIP-LIST: skipped bitstreams within identifier " + identifier);
            return true;
        }    
        else
            return false;
    }
    
    public static void writeLogln(String msg)
    {
    	if (logFilePath == null)
    		return;
    	try
    	{
	    	//logFilePath
	    	//BufferedWriter fout = new BufferedWriter(new FileWriter(logFilePath, true));
	    	//fout.write(msg);
	    	//fout.newLine();
	    	//fout.close();
	    	msg = msg + "\n";
	    	FileUtil.write(msg, logFilePath, true);
	    }
	    catch (Exception e) { }
    }
    public static void writeLog(String msg)
    {
    	if (logFilePath == null)
    		return;
    	try
    	{
	    	//logFilePath
	    	//BufferedWriter fout = new BufferedWriter(new FileWriter(logFilePath, true));
	    	//fout.write(msg);
	    	//fout.close();
	    	
	    	FileUtil.write(msg, logFilePath, true);
	    }
	    catch (Exception e) { }
    }
	
	public static void deleteLog() throws Exception
	{
		deleteLog(false);
	}
    public static void deleteLog(boolean instant) throws Exception
    {
    	if (logFilePath == null)
    		return;
    	
    	FilterMediaLogDeleteThread t = new FilterMediaLogDeleteThread();
    	t.setLog(logFilePath);
		if (instant == true)
		{
			println("Delete log: "+logFilePath+" now.");
			t.setInstant(true);
		}
		else
		{
			println("Delete log: "+logFilePath+" in "+(deleteLogDelay/1000)+" seconds.");
		}
		t.start();
    }
    
    public static String getLogID(String[] argv) throws Exception
    {
    	String logID = null;
		int logFlag = -1;
		for (int i = 0; i < argv.length; i++)
		{
			if (argv[i] != null
				&& argv[i].equals("-l"))
				logFlag = i;
		}
		if (logFlag != -1 && argv.length > logFlag + 1)
		{
			logID = argv[(logFlag+1)];

		}
		return logID;
    }
    
    public static boolean setupLog(String[] argv) throws Exception
    {
		String logID = getLogID(argv);
		if (logID != null)
		{
			setupLog(logID);
			return true;
		}
		return false;
    }
    
    public static boolean setupLog(String id) throws Exception
    {
    	if (id == null)
    		return false;
    	logFilePath = ConfigurationManager.getProperty("log.dir","/dspace/log")
	        		+ "/filter-media-log-"
	        		+ id
	        		+ ".log";
	        	//log.info("logFilePath: " + logFilePath);
	    //FileUtil.delete(logFilePath);
	    return true;
    }
    
    public static void logQueue(String[] argv) throws Exception
    {
    	String logID = getLogID(argv);
    	if (logID != null)
    	{
    		String path = ConfigurationManager.getProperty("log.dir","/dspace/log")
	        		+ "/filter-media-log-"
	        		+ logID
	        		+ ".log";
    		String msg = "[QUEUE] Please wait filter-media queue.";
    		try
	    	{
		    	BufferedWriter fout = new BufferedWriter(new FileWriter(path, true));
		    	fout.write(msg);
		    	fout.newLine();
		    	fout.close();
		    }
		    catch (IOException e) { }
    	}
    }
    
    public static void pushQueue(String[] argv) throws Exception
	{
		pushQueue(argv, -1);
	}
    public static void pushQueue(String[] argv, int pos) throws Exception
    {
    	String argvs = "";
    	for (int i = 0; i < argv.length; i++)
    	{
    		if (i > 0)
    			argvs = argvs + "\t";
    		argvs = argvs + argv[i];
    	}
    	pushQueue(argvs, pos);
    }
    public static void pushQueue(String argvs) throws Exception
	{
		pushQueue(argvs, -1);
	}
    public static void pushQueue(String argvs, int pos) throws Exception
    {
    	argvs = "filter-media\t" + argvs;
    	if (pos == -1)
    	{
    		argvs = argvs + "\n";
    		FileUtil.write(argvs, queueFilePath, true);
    	}
    	else
    	{
    		String queue = FileUtil.read(queueFilePath).trim();
    		if (queue != null)
    		{
	    		String[] temp = queue.split("\n");
	    		String output = "";
	    		for (int i = 0; i < temp.length; i++)
	    		{
	    			if (i > 0)
	    				output = output + "\n";
	    			
	    			if (i == pos)
	    				output = output + argvs + "\n";
	    			output = output + temp[i];
	    		}
	    		if (pos >= temp.length)
	    			output = output + "\n" + argvs + "\n";
	    		FileUtil.delete(queueFilePath);
	    		FileUtil.write(output, queueFilePath, false);
    		}
    		else
    		{
    			argvs = argvs + "\n";
    			FileUtil.write(argvs, queueFilePath, true);
    		}
    	}
    }
    
    public static String[] readQueue() throws Exception
    {
    	String queue = FileUtil.read(queueFilePath).trim();
    	
    	String[] error = {null};
    	if (queue == null || queue.trim().equals(""))
    		return error;
    	
    	queue = queue.trim();
    	
    	int ln = queue.indexOf("\n");
    	String argvs = queue;
    	if (ln > -1)
    		argvs = queue.substring(0, ln);
    	argvs = argvs.trim();
    	
    	String needle = "filter-media\t";
    	if (argvs.length() >= needle.length()
    		&& argvs.substring(0, needle.length()).equals(needle))
    	{
    		if (argvs.indexOf("\t") != -1)
    			argvs = argvs.substring(argvs.indexOf("\t") + 1, argvs.length());
    		else
    			return error;
    	}
    	else
    		return error;
    	
    	String[] argv = argvs.split("\t");
    	return argv;
    }
    
    public static boolean hasQueue() throws Exception
    {
    	String queue = FileUtil.read(queueFilePath);
    	if (queue == null || queue.trim().equals(""))
    		return false;
    	
    	queue = queue.trim();
    	
    	String needle = "filter-media\t";
    	if (queue.indexOf(needle) != -1 &&
    		queue.substring(0, needle.length()).equals(needle))
    		return true;
    	else
    		return false;
    }
    
    public static void popQueue() throws Exception
    {
    	String queue = FileUtil.read(queueFilePath);
    	if (queue == null || queue.trim().equals(""))
    		return;
    	
    	int ln = queue.indexOf("\n");
    	if (ln > -1)
    	{
    		queue = queue.substring(ln + 1, queue.length());
    		FileUtil.write(queue, queueFilePath, false);
    	}
    }
    
    public static int countQueue() throws Exception
    {
    	String queue = FileUtil.read(queueFilePath);
    	if (queue == null)
    		return 0;
    	else
    		return queue.split("\n").length;
    }
    
    public static int findQueue(String id) throws Exception
    {
    	int pos = -1;
    	String queue = FileUtil.read(queueFilePath);
    	
    	if (queue == null)
    		return pos;
    	
    	String[] argvs = queue.split("\n");
    	for (int i = 0; i < argvs.length; i++)
    	{
    		if (argvs[i] != null && argvs[i].indexOf("-l\t"+id) != -1)
    		{
    			pos = i;
    			break;
    		}
    	}
    	return pos;
    }
    
    public static boolean hasOption(String[] argv, String option)
    {
    	boolean result = false;
    	for (int i = 0; i < argv.length; i++)
    	{
    		if (argv[i].equals(option))
    		{
    			result = true;
    			break;
    		}
    	}
    	return result;
    }
    public static boolean isDsrun(String[] argv)
    {
    	return hasOption(argv, "-d");
    }
    
    public static String getStackTrace(Exception e) throws Exception
    {
    	String output = "";
    	StackTraceElement[] stack = e.getStackTrace();
    	
    	for (int s = 0; s < stack.length; s++)
    	{
    		String msg = stack[s].toString();
    		if (msg.indexOf("at ") == 0)
    			msg = "\t" + msg;
    		output = output + msg + "\n";
    	}
    	return output;
    }
    
    public static void print(String msg) throws Exception
    {
    	System.out.print(msg);
    	writeLog(msg);
    }
    public static void println(String msg) throws Exception
    {
    	System.out.println(msg);
    	writeLogln(msg);
    }
    
    public static boolean queueIsContinue(String[] argv, String[] nextArgv) throws Exception
    {
    	if (hasQueue() == false)
    		return false;
    	return hasOption(nextArgv, "-c");
    }
    
    public static void sleep() throws Exception
    {
    	sleep(filterMediaDelay);
    }
    public static void sleep(long delay) throws Exception
    {
    	println("\nWait for "+(delay/1000)+" seconds...\n");
    	Thread.currentThread().sleep(delay);
    }
}