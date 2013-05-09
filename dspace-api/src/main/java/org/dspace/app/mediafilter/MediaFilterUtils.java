package org.dspace.app.mediafilter;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.lang.Runtime;
import java.lang.Process;
import java.io.File;

import org.apache.log4j.Logger;
import org.pdfbox.pdfparser.PDFParser;
import org.pdfbox.pdmodel.PDDocument;
import org.pdfbox.pdmodel.PDPage;
import org.pdfbox.pdmodel.common.PDStream;
import org.pdfbox.util.PDFTextStripper;

import com.artofsolving.jodconverter.DocumentConverter;
import com.artofsolving.jodconverter.openoffice.connection.OpenOfficeConnection;
import com.artofsolving.jodconverter.openoffice.connection.SocketOpenOfficeConnection;
import com.artofsolving.jodconverter.openoffice.converter.OpenOfficeDocumentConverter;
import com.sun.star.lang.XEventListener;
import com.artofsolving.jodconverter.DefaultDocumentFormatRegistry;
import java.net.ConnectException;

import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.CharArrayWriter;
import java.util.List;
import java.util.Iterator;

import java.util.zip.ZipOutputStream;
import java.util.zip.ZipEntry;
import java.io.BufferedInputStream;

import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.Writer;
import java.io.OutputStreamWriter;

import java.lang.InterruptedException;

import org.dspace.core.ConfigurationManager;

import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.lang.StringBuilder;
import java.io.BufferedReader;
import java.lang.ProcessBuilder;
import java.lang.Thread;
import java.util.Arrays;
import java.lang.IllegalThreadStateException;

import java.util.Timer;
import org.dspace.app.util.FilterMediaTask;
import org.dspace.app.util.FileUtil;

import javax.imageio.ImageIO; 
import java.awt.image.BufferedImage; 
import java.lang.Math.*;

public class MediaFilterUtils
{
	static public String getTempDir() throws FileNotFoundException
	{
		String tempfile = ConfigurationManager.getProperty("filter.tempfile.config");
		if (tempfile == null)
			tempfile = "/tmp/";
		
		if (tempfile.substring(tempfile.length()-1, tempfile.length()).equals(File.separator) == false)
			tempfile = tempfile + File.separator;
			
		File f = new File(tempfile);
		if (f.isDirectory() == false)
			throw new FileNotFoundException("Tempfile is not a directory.");
		return tempfile;
	}
	
	static public String writeFile(InputStream source, int id) throws IOException
	{
		return writeFile(source, "tmp", id);
	}
	
	static public String writeFile(InputStream source, String fileType, int id) throws IOException
	{
		if (fileType.toLowerCase().equals("htm"))
			fileType = "html";
		
		String tempfile = getTempDir();
		if (fileType.equals("") == false)
			fileType = "." + fileType;
		String filepath = tempfile+"dspaceSource"+id+fileType;
		
		if (MediaFilterRecycle.get(filepath))
			return filepath;
		
		/*
		File f = new File(filepath);
		if (f.isFile() == true)
		{
			System.out.println("File exist.");
			return filepath;
		}
		*/
		
		System.out.println("Writing file:" + filepath);
		
		boolean isNullFile = true;
		
		FileOutputStream fout = new FileOutputStream(filepath); 
		byte[] byt= null;
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        int b=0;      
        b = source.read();
        while( b != -1)
        {
            baos.write(b);
            if (baos.size() > 1024*1024*10)
            {
            	System.out.println("Writing...");
            	fout.write(baos.toByteArray());
            	isNullFile = false;
            	baos = new ByteArrayOutputStream();
            }
            b = source.read();
        }
        if (baos.size() > 0)
        {
	        byt = baos.toByteArray();
			fout.write(byt);
			isNullFile = false;
		}
		
		if (isNullFile == true)
		{
			fout.flush();
			fout.close();
			deleteFile(filepath, true);
			throw new IOException("File: " + filepath + " is null. Please check assetstore's file instance.");
		}
		
		fout.flush();
		fout.close();
		
		return filepath;
	}
	
	static public InputStream readFile(String path) throws FileNotFoundException {
		return readFile(path, false);
	}

	static public InputStream readFile(String path, boolean delete) throws FileNotFoundException
    {
    	System.out.println("Reading file:" + path);
    	InputStream source = new FileInputStream(path);
    	if (delete == true) {
    		deleteFile(path);	
    	}
    	return source;
    }
	
	static public void deleteFile(String path)
	{
		deleteFile(path, false);
	}
	
	static public void deleteFile(String path, boolean now)
	{
		try
		{
			System.out.println("\tDelete file:" +path);
			
			if (now == true)
			{
				File f = new File(path);
				if (f.isFile() == true) {
					//f.delete();
					MediaFilterRecycle.push(path);
				}
			}
			else
				MediaFilterRecycle.push(path);
		} catch (Exception e) {
			System.out.println("\tDelete file fail:" + path);
		}
	}
	
	static public void mkdir(String path)
	{
		File f = new File(path);
		try
		{
			if (f.isFile())
			{
				System.out.println("\tMake directory path is a file: " + path);
				return;
			}
			
			if (f.isDirectory())
				return;
			
			if (f.mkdir())
				System.out.println("\tMake directory path: " + path);
		}
		catch (Exception e)
		{
			System.out.println("\tMake directory fail: " + path);
		}
	}
	
	static public void deleteDir(String path)
	{
		try
		{
			File p = new File(path);
			deleteDirectory(p);
			System.out.println("\tDelete directory: " +path);
		} catch (Exception e) {
			System.out.println("\tDelete directory fail:" + path);
		}
	}
	
	static public boolean deleteDirectory(File path) throws FileNotFoundException
	{
		if( path.exists() ) {
	      File[] files = path.listFiles();
	      for(int i=0; i<files.length; i++) {
	         if(files[i].isDirectory()) {
	           deleteDirectory(files[i]);
	         }
	         else {
	           files[i].delete();
	         }
	      }
	    }
	    return( path.delete() );
	}
	
	static public void isFile(String path) throws FileNotFoundException
	{
		File f = new File(path);
		if (f.isFile() == false)
		{
			if (f.isDirectory() == false)
			{
				throw new FileNotFoundException("File not found: "+path);
			}
		}
	}
	
	static public String diffFile(String input, String output)
	{
		if (input.equals(output))
		{
			int pt = output.lastIndexOf(".");
			output = output.substring(0, pt) + "_out" + output.substring(pt, output.length());
			System.out.println("\tFile name differ. \n\tinput:  " + input + "\n\toutput: " + output);
		}
		return output;
	}
	
	static public String getFileType(String input)
	{
		int pt = input.lastIndexOf(".");
		if (pt == -1)
			return input.toLowerCase();
		else
			return (input.substring(pt+1, input.length())).toLowerCase();
	}
	
	static void doProcess(String cmd) throws IOException
	{
		doProcess(cmd, -1);
	}
	
	static void doProcess(String cmd, long timeout) throws IOException
	{
		System.out.println("\n [doProcess] "+cmd);
		String[] env = new String[0];
		File working_directory; 
		try
		{
			working_directory = new File(getTempDir());
		}
		catch (Exception e) {
			working_directory = new File("/dspace/tmp/");
		}
		Process p = Runtime.getRuntime().exec(cmd, env, working_directory);
		
		doWaitFor(p, false, timeout);
	}
	
	public static int doWaitFor(Process p) throws IOException
	{
		return doWaitFor(p, false, -1);
	}
	
	public static int doWaitFor(Process p, boolean showMsg, long timeout) throws IOException
	{
	    int exitValue = -1; // returned to caller when p is finished
	    long count = 0;
	    try {

	        InputStream in = p.getInputStream();
	        InputStream err = p.getErrorStream();
	        boolean finished = false; // Set to true when p is finished

	        while(!finished) {
	            try {
	                while( in.available() > 0) {
	                    // Print the output of our system call
	                    Character c = new Character( (char) in.read());
	                    if (showMsg == true)
	                    	System.out.print(c);
	                    
	                    if (timeout != -1)
		            	{
			            	count = count + 1;
			            	if (count >= timeout)
			            	{
			            		System.out.println("\nThis process is out of time ("+timeout+") and will be destroy.");
			            		p.destroy();
			            		throw new IOException("Process timeout ("+timeout+")");
			            	}
			            	Thread.currentThread().sleep(1);
		            	}
	                }
	                
	                while( err.available() > 0) {
	                    // Print the output of our system call
	                    Character c = new Character( (char) err.read());
	                    
	                    if (showMsg == true)
	                    	System.out.print(c);
	                    
	                    if (timeout != -1)
		            	{
			            	count = count + 1;
			            	if (count >= timeout)
			            	{
			            		System.out.println("\nThis process is out of time ("+timeout+") and will be destroy.");
			            		p.destroy();
			            		throw new IOException("Process timeout ("+timeout+")");
			            	}
	                    	Thread.currentThread().sleep(1);
		            	}
	                }

	                // Ask the process for its exitValue. If the process
	                // is not finished, an IllegalThreadStateException
	                // is thrown. If it is finished, we fall through and
	                // the variable finished is set to true.
	                exitValue = p.exitValue();
	                finished = true;
	            }
	            catch (IllegalThreadStateException e) {
	            	if (timeout != -1)
	            	{
		            	count = count + 500;
		            	if (count >= timeout)
		            	{
		            		System.out.println("\nThis process is out of time ("+timeout+") and will be destroy.");
		            		p.destroy();
		            		throw new IOException("Process timeout("+timeout+"): " + e.getMessage());
		            	}
	            	}
	                // Process is not finished yet;
	                // Sleep a little to save on CPU cycles
	                Thread.currentThread().sleep(500);
	            }
	        }
	    }
	    catch (IOException e)
	    {
	    	throw e;
	    }
	    catch (Exception e) {
	        // unexpected exception! print it out for debugging...
	        if (showMsg == true)
	        {
	        	System.err.println( "doWaitFor();: unexpected exception - " +
	        		e.getMessage());
	        }
	    }

	    // return completion status to caller
	    return exitValue;
	}
	
	static private String getPDFtoHTMLfile(String input) throws Exception
	{
		String html = getTempDir();
		if (input.lastIndexOf(File.separator) != -1)
			html = html + input.substring(input.lastIndexOf(File.separator) + 1, input.length());
		if (html.lastIndexOf(".") != -1)
			html = html.substring(0, html.lastIndexOf(".")) + ".html";
		return html;
	}
	static private void deletePDFtoHTMLfile(String input) throws Exception
	{
		String html = getPDFtoHTMLfile(input);
		deleteFile(html);
	}
	
	//-------------------------------------------------------------------
	
	static public InputStream Audio2MP3(InputStream source, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		String[] types = new String[7];
		types[0] = "mp3";
		types[1] = "aac";
		types[2] = "flac";
		types[3] = "ogg";
		types[4] = "wma";
		types[5] = "wav";
		types[6] = "m4a";
		return Audio2MP3(source, types, id);
	}
	
	static public InputStream Audio2MP3(InputStream source, String name, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		String type = getFileType(name);
		String[] types = new String[1];
		types[0] = type;
		return Audio2MP3(source, types, id);
	}
	
	static public InputStream Audio2MP3(InputStream source, String[] types, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		String output = "";
		for (int i = 0; i < types.length; i++)
		{
			String converted = writeFile(source, types[i], id);
			try {
				output = FFmpegAudio2MP3(converted, id);
    		}
    		catch (Exception e) {
    			deleteFile(converted);
    		}
    		
    		if (output.equals("") == false)
    			break;
		}
		
		if (output.equals("") == false)
			return readFile(output);
		else
		{
			throw new InterruptedException("FFmpeg Audio Convert Fail!");
			//return null;
		}
	}
	
	static public String FFmpegAudio2MP3(InputStream source, int id) throws IOException, InterruptedException, FileNotFoundException
	{
		String converted =  writeFile(source, "", id);
		return FFmpegAudio2MP3(converted, id);
	}
	
	static public String FFmpegAudio2MP3(String input, int id) throws IOException, InterruptedException, FileNotFoundException
	{
		System.out.println("Start FFmpegAudio2MP3...");
		isFile(input);
		
		String tempfile = getTempDir();
		String output = tempfile+"dspaceConverted"+id+"-FFmpegAudio2MP3.mp3";
		
		output = diffFile(input, output);
		
		deleteFile(output);
		
		if (MediaFilterRecycle.get(output) == false)
		{
			String ffmpeg = ConfigurationManager.getProperty("filter.exec.ffmpeg");
			if (ffmpeg == null)
				ffmpeg = "ffmpeg";
			String FFmpegConfig = ConfigurationManager.getProperty("filter.FFmpegAudioFilter.config");
			if (FFmpegConfig == null)
				FFmpegConfig = "-ar 22050 -y";
			String cmd = ffmpeg+" -i "+input+" "+FFmpegConfig+" "+output;
			
			doProcess(cmd);
			
			isFile(output);
		}
		deleteFile(input);
		
		return output;
	}
	
	static public String FFmepgVideo2Image(InputStream source, int id) throws Exception, FileNotFoundException
	{
		System.out.println("[FFmepgVideo2Image] Start FFmepgVideo2Image write file...");
		String convert = writeFile(source, id);
		return FFmepgVideo2Image(convert, id);
	}

	static public String FFmepgVideo2Image(InputStream source, String type, int id) throws Exception, FileNotFoundException
	{
		System.out.println("[FFmepgVideo2Image] Start FFmepgVideo2Image write file...");
		String convert = writeFile(source, type, id);
		return FFmepgVideo2Image(convert, id);
	}
	
	static public String FFmepgVideo2Image(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("[FFmepgVideo2Image] Start FFmepgVideo2Image...");
    	isFile(input);
    	
    	String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-FFmepgVideo2Image.jpg";
    	
		System.out.println("[FFmepgVideo2Image] input file: " + input);
		System.out.println("[FFmepgVideo2Image] output file: " + output);

    	output = diffFile(input, output);
    	
    	if (MediaFilterRecycle.get(output) == false) {
			
			deleteFile(output);

			String ffmpeg = ConfigurationManager.getProperty("filter.exec.ffmpeg");
	    	if (ffmpeg == null)
				ffmpeg = "ffmpeg";
			String FFmpegImageConfig = ConfigurationManager.getProperty("filter.FFmpegImgFilter.config");
			if (FFmpegImageConfig == null)
				FFmpegImageConfig = "-y -f image2 -ss 8 -t 0.001 -s 320x240";
			//String FFmpegImageConfig = "-y -f image2 -ss 8 -t 0.001 -s 320x240";
			String cmd = ffmpeg+" -i "+input+" "+FFmpegImageConfig+" "+output;
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			//
			System.out.println("[FFmepgVideo2Image] process cmd: " + cmd);
			doProcess(cmd);
			
			System.out.println("[FFmepgVideo2Image] process completed, output: " + output);

			//isFile(output);

			File f = new File(output);
			if (f.isFile() == false)
			{
				System.out.println("[FFmepgVideo2Image] output not found.");

				String FFmpegImageConfigPart1 = ConfigurationManager.getProperty("filter.FFmpegImgFilter.config.part1");
				String FFmpegImageConfigPart2 = ConfigurationManager.getProperty("filter.FFmpegImgFilter.config.part2");
				int FFmpegImageConfigSS = ConfigurationManager.getIntProperty("filter.FFmpegImgFilter.config.ss");
				if (FFmpegImageConfigPart1 == null) {
					FFmpegImageConfigPart1 = "-y -f image2 -ss";
					FFmpegImageConfigPart2 = "-t 0.001 -s 320x240";
					FFmpegImageConfigSS = 8;
				}
				
				//Integer.toString(FFmpegImageConfigSS)
				
				while (f.isFile() == false && FFmpegImageConfigSS > -1) {
					FFmpegImageConfig = FFmpegImageConfigPart1 + " " + Integer.toString(FFmpegImageConfigSS) + " " + FFmpegImageConfigPart2;
					cmd = ffmpeg+" -i "+input+" "+FFmpegImageConfig+" "+output;

					System.out.println("[FFmepgVideo2Image] process cmd: " + cmd);
					doProcess(cmd);
					System.out.println("[FFmepgVideo2Image] process completed");

					FFmpegImageConfigSS--;

					f = new File(output);
				}
				
				System.out.println("[FFmepgVideo2Image] output not found.");
				if (f.isFile() == false) {
					isFile(output);
				}
			}
		}
		deleteFile(input);
		
		return output;
    }
	
	static public InputStream Video2FLV(InputStream source, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		String[] types = new String[9];
		types[0] = "mp4";
		types[1] = "mpg";
		types[2] = "avi";
		types[3] = "flv";
		types[4] = "wmv";
		types[5] = "rm";
		types[6] = "rmvb";
		types[7] = "3gp";
		types[8] = "mov";
		return Video2FLV(source, types, id);
	}
	
	static public InputStream Video2FLV(InputStream source, String name, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		String type = getFileType(name);
		String[] types = new String[1];
		types[0] = type;
		return Video2FLV(source, types, id);
	}
	
	static public InputStream Video2FLV(InputStream source, String[] types, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		System.out.println("[Video2FLV] Start Video2FLV...");
		String output = "";
		System.out.println("[Video2FLV] types.length:" + types.length);
		for (int i = 0; i < types.length; i++)
		{
			String t = types[i];
			System.out.println("[Video2FLV] types["+i+"]:" + t);
			if (t.equals("")) {
				continue;
			}

			String converted = writeFile(source, t, id);
			
			System.out.println("[Video2FLV] file:" + converted);

			try {
				if (t.equals("rm") 
					|| t.equals("rmvb")
					|| t.equals("3gp")
					|| t.equals("mov")) {
					output = MEncoderVideo2FLV(converted, id);
				}	
				else {
					output = FFmpegVideo2FLV(converted, id);
				}
    		}
    		catch (Exception e) {
    			deleteFile(converted);
    		}

    		System.out.println("[Video2FLV] convert completed, output is: " + output);
    		
    		if (output.equals("") == false) {
    			break;
    		}
    			
		}
		
		if (output.equals("") == false) {
			System.out.println("[Video2FLV] completed, output is: " + output);
			return readFile(output);
		}
		else {
			throw new InterruptedException("Video Convert Fail!");
			//return null;
		}
	}

	static public String Video2FLVString(InputStream source, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		String[] types = new String[9];
		types[0] = "mp4";
		types[1] = "mpg";
		types[2] = "avi";
		types[3] = "flv";
		types[4] = "wmv";
		types[5] = "rm";
		types[6] = "rmvb";
		types[7] = "3gp";
		types[8] = "mov";
		return Video2FLVString(source, types, id);
	}
	
	static public String Video2FLVString(InputStream source, String name, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		String type = getFileType(name);
		String[] types = new String[1];
		types[0] = type;
		return Video2FLVString(source, types, id);
	}
	
	static public String Video2FLVString(InputStream source, String[] types, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		System.out.println("[Video2FLV] Start Video2FLV...");
		String output = "";
		System.out.println("[Video2FLV] types.length:" + types.length);
		for (int i = 0; i < types.length; i++)
		{
			String t = types[i];
			System.out.println("[Video2FLV] types["+i+"]:" + t);
			if (t.equals("")) {
				continue;
			}

			String converted = writeFile(source, t, id);
			
			System.out.println("[Video2FLV] file:" + converted);

			try {
				if (t.equals("rm") 
					|| t.equals("rmvb")
					|| t.equals("3gp")
					|| t.equals("mov")) {
					output = MEncoderVideo2FLV(converted, id);
				}	
				else {
					output = FFmpegVideo2FLV(converted, id);
				}
    		}
    		catch (Exception e) {
    			deleteFile(converted);
    		}

    		System.out.println("[Video2FLV] convert completed, output is: " + output);
    		
    		if (output.equals("") == false) {
    			break;
    		}
    			
		}
		
		if (output.equals("") == false) {
			System.out.println("[Video2FLV] completed, output is: " + output);
			return output;
		}
		else {
			throw new InterruptedException("Video Convert Fail!");
			//return null;
		}
	}
	
	static public InputStream Video2MP4(InputStream source, String name, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		String type = getFileType(name);
		String[] types = new String[1];
		types[0] = type;
		return Video2MP4(source, types, id);
	}
	
	static public InputStream Video2MP4(InputStream source, String[] types, int id)  throws IOException, InterruptedException, FileNotFoundException
	{
		String output = "";
		for (int i = 0; i < types.length; i++)
		{
			String t = types[i];
			String converted = writeFile(source, t, id);
			
			try {
				if (t.equals("rm") 
					|| t.equals("rmvb")
					|| t.equals("3gp")
					|| t.equals("mov")
					|| t.equals("mpg")
					|| t.equals("mpeg"))
					output = MEncoderVideo2MP4(converted, id);
				else
					output = FFmpegVideo2MP4(converted, id);
				
    		}
    		catch (Exception e) {
    			deleteFile(converted);
    		}
    		
    		if (output.equals("") == false)
    			break;
		}
		
		if (output.equals("") == false)
			return readFile(output);
		else
		{
			throw new InterruptedException("Video Convert Fail!");
			//return null;
		}
	}
    
    static public String FFmpegVideo2FLV(InputStream source, int id) throws Exception, FileNotFoundException
	{
		String convert = writeFile(source, "", id);
		return FFmpegVideo2FLV(convert, id);
	}
	
	static public String FFmpegVideo2FLV(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("Start FFmpegVideo2FLV...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-FFmpegVideo2FLV.flv";
    	
    	output = diffFile(input, output);
    	
    	deleteFile(output);
    	
    	if (MediaFilterRecycle.get(output) == false)
		{
	    	//String cmd = "ffmpeg -i "+tempSource+" -ar 22050 -ab 56 -f flv -y -s 320x240 "+tempConverted;
			String ffmpeg = ConfigurationManager.getProperty("filter.exec.ffmpeg");
			if (ffmpeg == null)
				ffmpeg = "ffmpeg";
			String FFmpegConfig = ConfigurationManager.getProperty("filter.FFmpegVideoFilter.config.no-size");
			if (FFmpegConfig == null)
				FFmpegConfig = " -acodec libfaac -ac 2 -ar 22050 -ab 56 -f flv -y -pass 1 -passlogfile log-file";	// -s 320x240
			
			int FFmpegConfigWidth = ConfigurationManager.getIntProperty("filter.FFmpegVideoFilter.config.width");
			if (FFmpegConfigWidth == -1)
				FFmpegConfigWidth = 320;
			int FFmpegConfigHeight = ConfigurationManager.getIntProperty("filter.FFmpegVideoFilter.config.height");
			if (FFmpegConfigHeight == -1)
				FFmpegConfigHeight = 240;
			String FFmpegConfigResize = FFmpegGetResize(input, id, FFmpegConfigWidth, FFmpegConfigHeight);
			//String FFmpegConfig = "-ar 22050 -ab 56 -f flv -y -s 320x240";
			
			String cmd = ffmpeg+" -i "+input+" "+FFmpegConfig+" "+FFmpegConfigResize+" "+output;
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			
System.out.print("[FFmpegVideo2FLV] ");
System.out.println(cmd);

			doProcess(cmd);

System.out.println("[FFmpegVideo2FLV] cmd completed, check file");
			
			isFile(output);

System.out.println("[FFmpegVideo2FLV] file checked");
		}
		else {
			System.out.print("MediaFilterRecycle.get: ");
			System.out.print(output);
		}

		deleteFile(input);
		
		return output;
    }
    
    static public String FFmpegGetResize(String input, int id, int width, int height) throws Exception, FileNotFoundException
    {
    	System.out.println("\t	Start FFmpegFFmpegGetResize...");
    	
    	isFile(input);
    	
    	String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-FFmpegGetResize.jpg";
    	output = diffFile(input, output);
    	deleteFile(output);
    	
    	if (MediaFilterRecycle.get(output) == false)
		{
	    	String FFmpegImgConfig = ConfigurationManager.getProperty("filter.FFmpegImgFilter.config.no-size");
			if (FFmpegImgConfig == null)
				FFmpegImgConfig = " -y -f image2 -ss 6 -t 0.001";
			
			String ffmpeg = ConfigurationManager.getProperty("filter.exec.ffmpeg");
			if (ffmpeg == null)
				ffmpeg = "ffmpeg";
			String cmd = ffmpeg+" -i "+input+" "+FFmpegImgConfig+" "+output;
			doProcess(cmd);
			
			//isFile(output);

			File f = new File(output);
			if (f.isFile() == false)
			{
				String FFmpegImageConfigPart1 = ConfigurationManager.getProperty("filter.FFmpegImgFilter.config.no-size.part1");
				String FFmpegImageConfigPart2 = ConfigurationManager.getProperty("filter.FFmpegImgFilter.config.no-size.part2");
				int FFmpegImageConfigSS = ConfigurationManager.getIntProperty("filter.FFmpegImgFilter.config.no-size.ss");
				if (FFmpegImageConfigPart1 == null) {
					FFmpegImageConfigPart1 = "-y -f image2 -ss";
					FFmpegImageConfigPart2 = "-t 0.001 -s";
					FFmpegImageConfigSS = 6;
				}
				
				//Integer.toString(FFmpegImageConfigSS)
				
				while (f.isFile() == false && FFmpegImageConfigSS > -1) {
					String FFmpegImageConfig = FFmpegImageConfigPart1 + " " + Integer.toString(FFmpegImageConfigSS) + FFmpegImageConfigPart2;
					cmd = ffmpeg+" -i "+input+" "+FFmpegImageConfig+" "+output;
					FFmpegImageConfigSS--;

					f = new File(output);
				}
				
				if (f.isFile() == false) {
					isFile(output);
				}
			}
		}
		
		//偵測Output
		InputStream source = new FileInputStream(output);
		BufferedImage buf = ImageIO.read(source);
		int xsize = (int) buf.getWidth(null);
        int ysize = (int) buf.getHeight(null);
        
        double rate = (double) width / xsize;
        int rH = (int) (Math.ceil((double) ysize * rate));	//213.333
        if (rH % 2 == 1)
        	rH = rH + 1;
        
        int paddingTotal = (int) height - rH;
        if (paddingTotal < 0)
        	paddingTotal = paddingTotal * -1;
        
        if (paddingTotal / 2 % 2 == 1)
        {
        	rH = rH - 2;
        	paddingTotal = paddingTotal + 2;
        }
        
        int paddingTop = 0;
        try
        {
        	//out.print((int) (Math.ceil(paddingTotal / 2)));
        	paddingTop = paddingTotal / 2;
        }
        catch (java.lang.NumberFormatException e) {}
        int paddingBottom = 0;
        try
        {
        	paddingBottom = height - (int) (rH + paddingTop);
        }
        catch (java.lang.NumberFormatException e) {}
        
		int resizeHeight = height;
		try
		{
			resizeHeight = (int) rH;
		}
		catch (java.lang.NumberFormatException  e) {}
		String resize = "-s "+width+"x"+resizeHeight;
		
		if (paddingBottom > 0)
			resize = "-padbottom "+paddingBottom + " " + resize;
		if (paddingTop > 0)
			resize = "-padtop "+paddingTop + " " + resize;
		
		if (paddingBottom > 0 || paddingTop > 0)
			resize = resize + " -padcolor 000000";
		
		deleteFile(output);
		
		return resize;
    }
    
    static public String FFmpegVideo2MP4(InputStream source, int id) throws Exception, FileNotFoundException
	{
		String convert = writeFile(source, "", id);
		return FFmpegVideo2MP4(convert, id);
	}
	
	static public String FFmpegVideo2MP4(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("Start FFmpegVideo2MP4...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-FFmpegVideo2MP4.mp4";
    	
    	output = diffFile(input, output);
    	
    	deleteFile(output);
    	
    	if (MediaFilterRecycle.get(output) == false)
		{
	    	//String cmd = "ffmpeg -i "+tempSource+" -ar 22050 -ab 56 -f flv -y -s 320x240 "+tempConverted;
			String ffmpeg = ConfigurationManager.getProperty("filter.exec.ffmpeg");
			if (ffmpeg == null)
				ffmpeg = "ffmpeg";
			String FFmpegConfig = ConfigurationManager.getProperty("filter.FFmpegVideoFilterMP4.config.no-size");
			if (FFmpegConfig == null)
				FFmpegConfig = " -acodec libfaac -ac 2 -ar 22050 -ab 56 -f mp4 -y -pass 1 -passlogfile log-file";
			int FFmpegConfigWidth = ConfigurationManager.getIntProperty("filter.FFmpegVideoFilter.config.width");
			if (FFmpegConfigWidth == -1)
				FFmpegConfigWidth = 320;
			int FFmpegConfigHeight = ConfigurationManager.getIntProperty("filter.FFmpegVideoFilter.config.height");
			if (FFmpegConfigHeight == -1)
				FFmpegConfigHeight = 240;
			String FFmpegConfigResize = FFmpegGetResize(input, id, FFmpegConfigWidth, FFmpegConfigHeight);
			
			String cmd = ffmpeg+" -i "+input+" "+FFmpegConfig+" "+FFmpegConfigResize+" "+output;
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			doProcess(cmd);
			
			isFile(output);
		}
		deleteFile(input);
		
		return output;
    }
    
    static public String Image2JPEG(InputStream source, String name, int id) throws Exception, FileNotFoundException
    {
    	String type = getFileType(name);
    	String converted = writeFile(source, type, id);
    	return Image2JPEG(converted, id);
    }
    
    static public String Image2JPEG(InputStream source, int id) throws Exception, FileNotFoundException
    {
    	String converted = writeFile(source, "", id);
    	return Image2JPEG(converted, id);
    }
    
    static public String Image2JPEG(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("Start Image2JPEG...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-Image2JPEG.jpg";
    	
    	output = diffFile(input, output);
    	
    	deleteFile(output);
    	
    	if (MediaFilterRecycle.get(output) == false)
		{
	    	String convert = ConfigurationManager.getProperty("filter.exec.imagemagick");
	    	if (convert == null)
	    		convert = "convert";
	    	
	    	String cmd = convert+" "+input+"[0] "+output;
	        doProcess(cmd);
	        
	        isFile(output);
    	}
		deleteFile(input);
        
        return output;
    }
    
    static public String Image2Thumbnail(InputStream source, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("[Image2Thumbnail] Start Image2Thumbnail write file...");
    	String convert = writeFile(source, "", id);
    	return Image2Thumbnail(convert, id);
    }
    
    static public String Image2Thumbnail(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("[Image2Thumbnail] Start Image2Thumbnail...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-Image2Thumbnail.jpg";
		
		output = diffFile(input, output);
		
		deleteFile(output);
		
		if (MediaFilterRecycle.get(output) == false)
		{
	    	String imagemagick = ConfigurationManager.getProperty("filter.exec.imagemagick");
	    	if (imagemagick == null)
	    		imagemagick = "convert";
			int w = ConfigurationManager
	                .getIntProperty("thumbnail.maxwidth");
	        int h = ConfigurationManager
	                .getIntProperty("thumbnail.maxheight");
	        
	        if (w == 0)
	        	w = 320;
	        if (h == 0)
	        	h = 240;
	        
			String config = "-resize "+w+"x"+h;
			String cmd = imagemagick+" "+input+"[0] "+config+" "+output;
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			doProcess(cmd);
			
			isFile(output);
		}
		deleteFile(input);
		
		return output;
    }
    
    static public String ImageResize(InputStream source, int id, int width, int height) throws Exception, FileNotFoundException
    {
    	String convert = writeFile(source, "", id);
    	return ImageResize(convert, id, width, height);
    }
    
    static public String ImageResize(String input, int id, int width, int height) throws Exception, FileNotFoundException
    {
    	System.out.println("Start ImageResize...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-ImageResize.jpg";
		
		output = diffFile(input, output);
		
		deleteFile(output);
		
		if (MediaFilterRecycle.get(output) == false)
		{
	    	String imagemagick = ConfigurationManager.getProperty("filter.exec.imagemagick");
	    	if (imagemagick == null)
	    		imagemagick = "convert";
			int w = width;
	        int h = height;
	        
	        if (w == 0)
	        	w = 320;
	        if (h == 0)
	        	h = 240;
	        
			String config = "-resize "+w+"x"+h;
			String cmd = imagemagick+" "+input+"[0] "+config+" "+output;
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			doProcess(cmd);
			
			isFile(output);
		}
		deleteFile(input);
		
		return output;
    }
    
    static public String Image2ZoomifyImage(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("Start Image2ZoomifyImage...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-Image2ZoomifyImage.jpg";
		
		output = diffFile(input, output);
		
		deleteFile(output);
		
		if (MediaFilterRecycle.get(output) == false)
		{
	    	String imagemagick = ConfigurationManager.getProperty("filter.exec.imagemagick");
	    	if (imagemagick == null)
	    		imagemagick = "convert";
			int w = 300;
	        int h = 300;
	        
			String config = "-resize "+w+"x"+h;
			String cmd = imagemagick+" "+input+"[0] "+config+" "+output;
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			doProcess(cmd);
			
			isFile(output);
		}
		deleteFile(input);
		
		return output;
    }
    
    static public String XpdfPDF2JPEG(InputStream source, int id) throws Exception, FileNotFoundException
    {
    	String converted = writeFile(source, "pdf", id);
		return XpdfPDF2JPEG(converted, id, true);
    }
    
    static public String XpdfPDF2JPEG(String input, int id) throws Exception, FileNotFoundException
    {
    	return XpdfPDF2JPEG(input, id, true);
    }
    
    static public String XpdfPDF2JPEG(String input, int id, boolean doDelete) throws Exception, FileNotFoundException
    {
    	System.out.println("Start XpdfPDF2JPEG...");
    	isFile(input);
    	
    	String outputHTML = getPDFtoHTMLfile(input);
    	String outputPNG = input.substring(0, input.lastIndexOf(".")) + "001.png";
    	
    	deleteFile(outputHTML);
    	deleteFile(outputPNG);
    	
    	if (MediaFilterRecycle.get(outputPNG) == false)
		{
	    	String pdftohtml = ConfigurationManager.getProperty("filter.exec.xpdf-pdftohtml");
			if (pdftohtml == null)
				pdftohtml = "pdftohtml";
			
			//pdftohtml 20081219\ 數位圖書館讀者閱讀標註知識萃取之研究與應用.pdf -f 1 -l 1 -c -noframes
			String pdfToHtmlConfig = ConfigurationManager.getProperty("filter.exec.xpdf-pdftohtml.config"
					, "-c -noframes -nodrm");
			String cmd = pdftohtml + " " + input + " -f 1 -l 1 "+ pdfToHtmlConfig;
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			doProcess(cmd);
			
			isFile(outputPNG);
		}
		
		if (doDelete == true)
			deleteFile(input);
		deleteFile(outputHTML);
		
		String output = ImageMagickImage2JPEG(outputPNG, id, true);
		
		return output;
    }
    
    static public String ImageMagickPDF2JPEG(InputStream source, int id) throws Exception, FileNotFoundException
    {
    	String converted = writeFile(source, "pdf", id);
    	return ImageMagickPDF2JPEG(converted, id);
    }
    
    static public String ImageMagickPDF2JPEG(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("Start ImageMagickPDF2JPEG...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-ImageMagickPDF2JPEG.jpg";
    	
    	output = diffFile(input, output);
    	
    	deleteFile(output);
    	
    	if (MediaFilterRecycle.get(output) == false)
		{
	    	String imagemagick = ConfigurationManager.getProperty("filter.exec.imagemagick");
	    	if (imagemagick == null)
	    		imagemagick = "convert";
			String config = "-trim ";
			
			String cmd = imagemagick+" "+input+"[0] "+config+" "+output;
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			doProcess(cmd);
			
			try
			{
				isFile(output);
			}
			catch (Exception e)
			{
				deleteFile(input, true);
				throw e;
			}
		}
		deleteFile(input);
		
		return output;
    }
    
    static public String ImageMagickImage2JPEG(String input, int id) throws Exception, FileNotFoundException
    {
    	return ImageMagickImage2JPEG(input, id, false);
    }
    
    static public String ImageMagickImage2JPEG(String input, int id, boolean detectLain) throws Exception, FileNotFoundException
    {
    	System.out.println("Start ImageMagickImage2JPEG...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-ImageMagickImage2JPEG.jpg";
    	
    	output = diffFile(input, output);
    	
    	deleteFile(output);
    	
    	if (MediaFilterRecycle.get(output) == false)
		{
	    	String imagemagick = ConfigurationManager.getProperty("filter.exec.imagemagick");
	    	if (imagemagick == null)
	    		imagemagick = "convert";
			
			String imagemagickConfig = ConfigurationManager.getProperty("filter.ImageMagick.PDF2JPEG.config");
	    	if (imagemagickConfig == null)
	    		imagemagickConfig = "-verbose -colorspace RGB -interlace none -density 120 -quality 100";
			
			if (detectLain == true
				&& isImageLain(input) == true)
			{
				imagemagickConfig = imagemagickConfig + " -rotate 90 -trim";
			}
			
			String cmd = imagemagick+" "+input+"[0] "+imagemagickConfig+" "+output;
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			doProcess(cmd);
			
			isFile(output);
		}
		deleteFile(input);
		
		return output;
    }
    
    static public String JPEG2SWF(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("Start JPEG2SWF...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-JPEG2SWF.swf";
    	
    	output = diffFile(input, output);
    	
    	deleteFile(output);
    	
    	if (MediaFilterRecycle.get(output) == false)
		{
	        String jpeg2swf = ConfigurationManager.getProperty("filter.exec.jpeg2swf");
	        if (jpeg2swf == null)
	        	jpeg2swf = "jpeg2swf";
	        
	        String cmd = jpeg2swf+" "+input+" -o "+output;
	        //Process p = Runtime.getRuntime().exec(cmd);
	        //p.waitFor();
	        doProcess(cmd);
	        
	        isFile(output);
	    }
		deleteFile(input);
        
        return output;
    }
    
    static public String Doc2PDF(InputStream source, String name, int id) throws ConnectException, IOException, FileNotFoundException
    {
    	String type = getFileType(name);
    	if (type.equals("pdf") == true)
    		return writeFile(source, type, id);
    	else if (type.equals("docx")
    		|| type.equals("pptx")
    		|| type.equals("xlsx"))
    	{
    		return ODFConverter(source, type, id);
    	}
    	else
    	{
    		return JODConvert(source, type, id);
    	}
    }
    
    static public String JODConvert(InputStream source, int id) throws ConnectException, IOException, FileNotFoundException
    {
    	String[] types = new String[13];
    	types[0] = "ppt";
    	types[1] = "doc";
    	types[2] = "xls";
    	types[3] = "odt";
    	types[4] = "ods";
    	types[5] = "odp";
    	types[6] = "sxw";
    	types[7] = "sxi";
    	types[8] = "sxc";
    	types[9] = "tsv";
    	types[10] = "csv";
    	types[11] = "rtf";
    	types[12] = "txt";
    	return JODConvert(source, types, id);
    }
    
    static public String[] getPPTtypes()
    {
    	String[] types = new String[3];
    	types[0] = "ppt";
    	types[1] = "odp";
    	types[2] = "sxi";
    	return types;
    }
    
    static public String JODConvert(InputStream source, String[] types, int id) throws ConnectException, IOException, FileNotFoundException
    {
    	String output = "";
    	for (int i = 0; i < types.length; i++)
    	{
    		String converted = writeFile(source, types[i], id);
    		try {
    			output = JODConvert(converted, id);
    		}
    		catch (Exception e) {
    			deleteFile(converted);
    		}
    		
    		if (output.equals("") == false)
    			break;
    	}
    	
    	if (output.equals("") == false)
    	{
    		return output;
    	}
    	else
    	{
			throw new ConnectException("JODConvert Fail!");
			//return null;
		}
    }
    
    static public String JODConvert(InputStream source, String fileType, int id) throws ConnectException, IOException, FileNotFoundException
    {
    	String converted = writeFile(source, fileType, id);
    	return JODConvert(converted, id);
    }
    
    static public String JODConvert(String input, int id) throws ConnectException, IOException, FileNotFoundException
	{
		System.out.println("Start JODConvert...");
    	isFile(input);
    	
    	int counter = 0;
	    boolean restarted = false;
	    boolean passed = false; 
	    int restartedMax = ConfigurationManager.getIntProperty("filter-media.openoffice-restart-max", 10);
	    int restartDelay = ConfigurationManager.getIntProperty("filter-media.openoffice-restart-delay", 30000);
    	
    	int sofficePort = ConfigurationManager.getIntProperty("filter.JODConvert.sofficePort", 8100);
		int sofficePort2 = ConfigurationManager.getIntProperty("filter.JODConvert.sofficePort2");
    	
		String tempfile = getTempDir();
		String output = tempfile+"dspaceConverted"+id+"-JODConvert.pdf";
		
		output = diffFile(input, output);
		
		deleteFile(output);
		
		if (MediaFilterRecycle.get(output) == false)
		{
			
			for (counter = 0; counter < restartedMax; counter++)
			{
		        //DocumentFormat stw = new DocumentFormat("OpenOffice.org 1.0 Template", DocumentFamily.TEXT, "application/vnd.sun.xml.writer", "stw");
		        //DefaultDocumentFormatRegistry formatReg = new DefaultDocumentFormatRegistry();
		        //DocumentFormat pdf = formatReg.getFormatByFileExtension("pdf");
		        System.out.println("input: " + input);
		        System.out.println("output: " + output);
		        File inputFile = new File(input);
		        File outputFile = new File(output);
		        System.out.println("\nTry to connect OpenOffice at port " + sofficePort);
		        OpenOfficeConnection connection = new SocketOpenOfficeConnection(sofficePort);
		        
		        String checkImage;
		        try {
		            connection.connect();
		            DocumentConverter converter = new OpenOfficeDocumentConverter(connection);
		            //converter.convert(inputFile, stw, outputFile, pdf);
		            converter.convert(inputFile, outputFile);
		            isFile(output);
		            
		            //作圖片的檢測
		            System.out.println("Check pdf is available...");
		            try
		            {
		            	checkImage = ImageMagickPDF2JPEG(output, id);
		            	isFile(checkImage);
		            	deleteFile(checkImage, true);
		            	System.out.println("PDF is ok!");
		            }
		            catch (Exception checkException) {
		            	System.out.println("Cannot pass ImageMagick, try Xpdf");
		            	checkImage = XpdfPDF2JPEG(output, id);
		            	isFile(checkImage);
		            	deleteFile(checkImage, true);
		            	System.out.println("PDF is ok!");
		            }
		            
		            MediaFilterRecycle.get(output);
		            passed = true;
		            break;
		        } catch(Exception e) {
		        	System.out.println("\nConntion in "+sofficePort+" error, prepare disconnction...\n");
		        	try
		            { 
		            	if(connection != null) 
		            	{
		            		connection.disconnect(); 
		            		connection = null;
		            	}
		            } catch (Exception connectionException) { } 
		        	
		        	if (sofficePort2 != -1)
		        	{
		        		OpenOfficeConnection connection2 = new SocketOpenOfficeConnection(sofficePort2);
		        		try
		        		{
		        			System.out.println("\nTry to connect OpenOffice at port " + sofficePort2);
		        			
		        			connection2.connect();
				            DocumentConverter converter2 = new OpenOfficeDocumentConverter(connection2);
				            converter2.convert(inputFile, outputFile);
				            isFile(output);
				            
				            //作圖片的檢測
				            System.out.println("Check pdf is available...");
				            try
				            {
				            	checkImage = ImageMagickPDF2JPEG(output, id);
				            	isFile(checkImage);
				            	deleteFile(checkImage, true);
				            	System.out.println("PDF is ok!");
				            }
				            catch (Exception checkException) {
				            	System.out.println("Cannot pass ImageMagick, try Xpdf");
				            	checkImage = XpdfPDF2JPEG(output, id);
				            	isFile(checkImage);
				            	deleteFile(checkImage, true);
				            	System.out.println("PDF is ok!");
				            }
				            
				            MediaFilterRecycle.get(output);
				            passed = true;
				            break;
		        		}
		        		catch (Exception e2)
		        		{
		        			//e.printStackTrace();
		            		//throw new ConnectException("OpenOffice connect error. Input file: "+input+"; Output file: "+output);
		            		try
				            { 
				            	if(connection2 != null) 
				            	{
				            		connection2.disconnect(); 
				            		connection2 = null;
				            	}
				            } catch (Exception connectionException) { } 
		        		}
		        	}
		        	else
		        	{
		        		//e.printStackTrace();
		            	//throw new ConnectException("OpenOffice connect error. Input file: "+input+"; Output file: "+output);
		            }
		        } 
		        /*
		        connection.connect();
		        DocumentConverter converter = new OpenOfficeDocumentConverter(connection);
		        converter.convert(inputFile, outputFile);
		        if(connection != null) {connection.disconnect(); connection = null;}
		        */
		        
		        //嘗試重新啟動OpenOffice
		        System.out.println("\nConntion in "+sofficePort+" error. Try to restart OpenOffice at "+counter+" \n");
		        
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
				try
				{
					System.out.println("Wait for "+(restartDelay/1000)+" sec...");
					Thread.currentThread().sleep(restartDelay);
				}
				catch (Exception e) { }
				
				System.out.println("\n");
		        
			}	//for (counter = 0; counter < restartedMax; counter++)
			if (passed == false)
			{
				throw new ConnectException("OpenOffice connect error. Input file: "+input+"; Output file: "+output);
			}
	    }
		deleteFile(input);
        
        return output;
    }
    
    static public String ODFConverter(InputStream source, String fileType, int id) 
    	throws ConnectException, IOException, FileNotFoundException
    {
    	String converted = writeFile(source, fileType, id);
    	return ODFConverter(converted, fileType, id);
    }
    
    static public String ODFConverter(String input, String inputType, int id) 
    	throws ConnectException, IOException, FileNotFoundException
	{
		System.out.println("Start ODFConverter...");
    	isFile(input);
    	
    	String outputType = "odt";
    	if (inputType.equals("xlsx"))
    		outputType = "ods";
    	else if (inputType.equals("pptx"))
    		outputType = "odp";
    	
		String tempfile = getTempDir();
		String output = input.substring(0, input.lastIndexOf(".") + 1) + outputType; 
		//String output = tempfile+"dspaceConverted"+id+outputType;
		
		output = diffFile(input, output);
		
		deleteFile(output);
		
		if (MediaFilterRecycle.get(output) == false)
		{
	        String odfconverter = ConfigurationManager.getProperty("filter.exec.odfconverter");
	        if (odfconverter == null)
	        	odfconverter = "OdfConverter";
	        
	        String cmd = odfconverter + " /f /i "+input;
	        doProcess(cmd);
	        
	        isFile(output);
	    }
		deleteFile(input);
        
        //return output;
        return JODConvert(output, id);
    }
    
    static public String MEncoderVideo2FLV(InputStream source, int id) throws Exception, FileNotFoundException
    {
    	String converted = writeFile(source, "", id);
    	return MEncoderVideo2FLV(converted, id);
    }
    
    static public String MEncoderVideo2FLV(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("Start MEncoderVideo2FLV...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-MEncoderVideo2FLV.flv";
		
		output = diffFile(input, output);
		
		deleteFile(output);
    	
    	if (MediaFilterRecycle.get(output) == false)
		{
	    	String mencoder = ConfigurationManager.getProperty("filter.exec.mencoder");
	    	if (mencoder == null)
	    		mencoder = "mencoder";
			String MEncoderConfig = ConfigurationManager.getProperty("filter.MEncoderFilter.config");
			if (MEncoderConfig == null)
				//MEncoderConfig = "-vf scale=320:240 -ffourcc FLV1 -of lavf -lavfopts i_certify_that_my_video_stream_does_not_use_b_frames -ovc lavc -lavcopts vcodec=flv:vbitrate=200 -srate 22050 -oac lavc -lavcopts acodec=mp3:abitrate=56";
				MEncoderConfig = "-forceidx -of lavf -lavfopts format=flv -oac mp3lame -lameopts abr:br=56 -srate 22050 -ovc lavc -lavcopts aglobal=1:vglobal=1:vcodec=flv:vbitrate=600:acodec=libfaac:abitrate=128 -vf dsize=320:240:0,scale=0:0,expand=320:240,harddup -ofps 25 -srate 22050";
			String cmd = mencoder+" "+input+" -o "+output + " "+MEncoderConfig;
			//System.out.println(cmd);
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			doProcess(cmd);
			
			isFile(output);
		}
		deleteFile(input);
		
		return output;
    }
    
    static public String MEncoderVideo2MP4(InputStream source, int id) throws Exception, FileNotFoundException
    {
    	String converted = writeFile(source, "", id);
    	return MEncoderVideo2MP4(converted, id);
    }
    
    static public String MEncoderVideo2MP4(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("Start MEncoderVideo2MP4...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-MEncoderVideo2MP4.mp4";
		
		output = diffFile(input, output);
		
		deleteFile(output);
    	
    	if (MediaFilterRecycle.get(output) == false)
		{
	    	String mencoder = ConfigurationManager.getProperty("filter.exec.mencoder");
	    	if (mencoder == null)
	    		mencoder = "mencoder";
			String MEncoderConfig = ConfigurationManager.getProperty("filter.MEncoderFilterMP4.config");
			if (MEncoderConfig == null)
				MEncoderConfig = "-of lavf -lavfopts format=mp4 -oac lavc -ovc lavc -lavcopts aglobal=1:vglobal=1:vcodec=mpeg4:vbitrate=600:acodec=libfaac:abitrate=128 -af lavcresample=24000 -vf dsize=320:240:0,scale=0:0,expand=320:240,harddup -ofps 25 -srate 22050 -quiet";
			String cmd = mencoder +" "+input+" -o "+output + " "+MEncoderConfig;
			//System.out.println(cmd);
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			doProcess(cmd);
			
			isFile(output);
		}
		deleteFile(input);
		
		return output;
    }
    
    static public String ZoomifyImage2SWF(InputStream source, int id) throws Exception, FileNotFoundException
    {
    	String converted = writeFile(source, "jpg", id);
    	return ZoomifyImage2SWF(converted, id);
    }
    
    static public String ZoomifyImage2SWF(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("[ZoomifyImage2SWF] Start ZoomifyImage2SWF...");
    	
		if (isSmallImage(input) == true)
		{
			System.out.println("Input image size smaller than 300*300: " + input);
			input = Image2ZoomifyImage(input, id);
		}
    	
    	isFile(input);
    	
    	String outputDir = input.substring(0, input.lastIndexOf("."));
    	deleteDir(outputDir);
    	
    	String ZoomifyImagePath = ConfigurationManager.getProperty("filter.exec.zoomifyImage");
    	if (ZoomifyImagePath == null)
    		ZoomifyImagePath = "/opt/ZoomifyImage/ZoomifyFileProcessor.py";
		String python = ConfigurationManager.getProperty("filter.exec.python");
		if (python == null)
			python = "python";
		String cmd = python+" "+ZoomifyImagePath+" "+input;
		
		System.out.println("[ZoomifyImage2SWF] cmd: " + cmd);
		System.out.println("[ZoomifyImage2SWF] wait 3 sec...");
		Thread.currentThread().sleep(3);
		doProcess(cmd);
		
		isFile(outputDir);
		deleteFile(input);
		
		return outputDir;
    }
    
    static public String makeZip(String inputDir, int id)
         throws IOException, FileNotFoundException
   {
   	   System.out.println("Start makeZip...");
   	   
    	isFile(inputDir);
    	
		String tempfile = getTempDir();
   	   String output = tempfile+"dspaceConverted"+id+"-makeZip.zip";
    	
    	output = diffFile(inputDir, output);
    	
       deleteFile(output);
   	   
		if (MediaFilterRecycle.get(output) == false)
		{
			File srcFile = new File(inputDir);
			File targetZip = new File(output);

			ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(targetZip));
			String dir="";
			recurseFiles(srcFile,zos,dir);
			zos.close();

			isFile(output);
		}
		deleteDir(inputDir);
      
      return output;
    }
    
	static private ZipOutputStream recurseFiles(File file, ZipOutputStream zos, String dir)
      throws IOException, FileNotFoundException
   {
	   //目錄
      if (file.isDirectory()) {
    	  //System.out.println("找到資料夾:"+file.getName());
    	  dir += file.getName()+File.separator;
         String[] fileNames = file.list();
         if (fileNames != null) {        	 
            for (int i=0; i < fileNames.length ; i++)  {            	
               zos = recurseFiles(new File(file, fileNames[i]), zos,dir);
            }
         }
      }
      //Otherwise, a file so add it as an entry to the Zip file.
      else {
    	  //System.out.println("壓縮檔案:"+file.getName());
    	  
         byte[] buf = new byte[1024];
         int len;
 
         //Create a new Zip entry with the file's name.
         dir = dir.substring(dir.indexOf(File.separator)+1);
         ZipEntry zipEntry = new ZipEntry(dir+file.getName());
         //Create a buffered input stream out of the file
         //we're trying to add into the Zip archive.
         FileInputStream fin = new FileInputStream(file);
         BufferedInputStream in = new BufferedInputStream(fin);
         zos.putNextEntry(zipEntry);
         //Read bytes from the file and write into the Zip archive.
 
         while ((len = in.read(buf)) >= 0) {
            zos.write(buf, 0, len);
         }
 
         //Close the input stream.
         in.close();
 
         //Close this entry in the Zip stream.
         zos.closeEntry();
      }
	  return zos;
   }
   
	static public boolean isSmallImage(String sourceImage) throws FileNotFoundException, IOException
	{
		InputStream source = new FileInputStream(sourceImage);
		BufferedImage buf = ImageIO.read(source);
		try
		{
			float xsize = (float) buf.getWidth(null);
	                float ysize = (float) buf.getHeight(null);

	                int smallX = 300;
	                int smallY = 300;

	                if (xsize < smallX && ysize < smallY)
	                        return true;
	                else
	                        return false;

		} catch (Exception e)
		{
			return false;
		}
	}
   
	static public String PDF2SWF(InputStream source, int id) throws Exception, FileNotFoundException
	{
		String converted = writeFile(source, "pdf", id);
		return PDF2SWF(converted, id);
	}
   
   static public String PDF2SWF(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("Starting PDF2SWF...");
    	isFile(input);
    	
		String tempfile = getTempDir();
    	String output = tempfile+"dspaceConverted"+id+"-PDF2SWF.swf";
    	
    	output = diffFile(input, output);
    	
    	deleteFile(output);
    	
    	if (MediaFilterRecycle.get(output) == false)
		{
	        String pdf2swf = ConfigurationManager.getProperty("filter.exec.pdf2swf");
	        if (pdf2swf == null)
	        	pdf2swf = "pdf2swf";
	        String rfxview = ConfigurationManager.getProperty("filter.SWFToolsPDFFilter.config.rfxview");
	        if (rfxview == null)
	        	rfxview = (String) ConfigurationManager.getProperty("dspace.dir") + File.separator + "modules"+File.separator+"jspui"+File.separator+"src"+File.separator+"main"+File.separator+"resources"+File.separator+"rfxview.swf";
	        
	        String option =  ConfigurationManager.getProperty("filter.SWFToolsPDFFilter.config.pdf2swf-option"
	        							, "-z -s flashversion=7 -q -qq -t");
				String cmd = pdf2swf+ " " +option+" -B " +rfxview+" "+input+" -o "+output;
	        //pdf2swf -o dspace.swf -z -B rfxview.swf -s flashversion=7  -t dspace.pdf
	        //Process p = Runtime.getRuntime().exec(cmd);
	        //p.waitFor();
	        long timeout = ConfigurationManager.getLongProperty("filter.SWFToolsPDFFilter.config.pdf2swf-timeout", 300000);
	        
	        doProcess(cmd, timeout);
	        
	        isFile(output);
	    }
		deleteFile(input);
        
        return output;
    }
    
    static public String PDF2JPEG2SWF(InputStream source, int id) throws Exception, FileNotFoundException
	{
		String converted = writeFile(source, "pdf", id);
		return PDF2JPEG2SWF(converted, id, null);
	}
   
   static public String PDF2JPEG2SWF(String input, int id) throws Exception, FileNotFoundException
   {
   	   return PDF2JPEG2SWF(input, id, null);
   }
   
   static public String PDF2JPEG2SWF(String input, int id, String type) throws Exception, FileNotFoundException
    {
    	System.out.println("Starting PDF2JPEG2SWF...");
    	isFile(input);
    	
		String tempfile = getTempDir();
		String tempDir = tempfile + "dspaceConverted" +id + "-PDF2JPEG2SWF";

        String outputSWF = tempfile+"dspaceConverted"+id+"-PDF2JPEG2SWF.swf";
        if (MediaFilterRecycle.get(outputSWF) == false)
		{
		
		deleteDir(tempDir);
		mkdir(tempDir);
		
		//String firstImage = XpdfPDF2JPEG(input, id, false);
		String firstImage;
		if (true)
		{
			String pdftohtml = ConfigurationManager.getProperty("filter.exec.xpdf-pdftohtml");
			if (pdftohtml == null)
				pdftohtml = "pdftohtml";
			
			String pdfToHtmlConfig = ConfigurationManager.getProperty("filter.exec.xpdf-pdftohtml.config"
					, "-c -noframes -nodrm");
			String cmd = pdftohtml + " " + input + " -f 1 -l 1 "+ pdfToHtmlConfig;
			
			doProcess(cmd);
			
			deletePDFtoHTMLfile(input);
			String outputPNG = input.substring(0, input.lastIndexOf(".")) + "001.png";
			firstImage = outputPNG;
			
			try
			{
				isFile(firstImage);
			}
			catch (Exception e3)
			{
				deleteFile(input, true);
				throw e3;
			}
		}
		
		if (isImageLain(firstImage) == false)
		{
			try
			{
				System.out.println("\nStart Xpdf pdftohtml");
		    	
		    	XpdfPDFAll2JPEGProgressively(tempDir, input);
		    }
		    catch (Exception e)
		    {
		    	System.out.println("\nError! "+e.getMessage());
		    	
				System.out.println("\nStart ImageMagick convert");
				
				ImageMagickPDFAll2JPEGProgressively(tempDir, id, input, true);
		    	
		    	try
		    	{
		    		isFile(tempDir + "/dspaceConverted" + id + "-00000.jpg");
		    	}
		    	catch (Exception e2) 
		    	{
		    		deleteFile(input, true);
		    		throw e2;
		    	}
		    }
		}	//if (isImageLain(inputPNG) == false)
		else
		{
			try
			{
				System.out.println("\nStart ImageMagick convert");
				
				ImageMagickPDFAll2JPEGProgressively(tempDir, id, input);
		    	
		    	isFile(tempDir + "/dspaceConverted" + id + "-00000.jpg");
			}
			catch (Exception e)
			{
				System.out.println("\n Error! "+e.getMessage());
				
				System.out.println("\nStart Xpdf pdftohtml");
		    	
		    	try
		    	{
		    		XpdfPDFAll2JPEGProgressively(tempDir, input, true);
		    	}
		    	catch (Exception e2) {
		    		deleteFile(input, true);
		    		throw e2;
		    	}
			}
		}
    	
    	//jpeg2swf -q 100 -z -f dspaceConvert101122/*.jpg -o dspaceConvert101122/output.swf 
    	String jpeg2swf = ConfigurationManager.getProperty("filter.exec.jpeg2swf");
    	if (jpeg2swf == null)
    		jpeg2swf = "jpeg2swf";
    	
    	String jpeg2swfConfig = ConfigurationManager.getProperty("filter.jpeg2swf.config");
    	if (jpeg2swfConfig == null)
    		jpeg2swfConfig = "-q 100 -z";
    	
    	String outputJPEG2SWF = tempDir + "/output.swf";
    	
    	//調查tempDir裡面的所有檔案，並加入輸入列表當中
    	String inputJPEGs = "";
    	File inputDir = new File(tempDir);
    	String[] jpegs = inputDir.list();
    	Arrays.sort(jpegs);
    	for (int i = 0; i < jpegs.length; i++)
    	{
    		int dot = jpegs[i].lastIndexOf(".");
    		if (dot == -1
    			|| jpegs[i].substring((dot + 1), jpegs[i].length()).equals("jpg") == false)
    			continue;
    		
    		if (i > 0)
    			inputJPEGs = inputJPEGs + " ";
    		
    		inputJPEGs = inputJPEGs + tempDir + "/" + jpegs[i];
    	}
    	
    	doProcess(jpeg2swf + " "
    		+ jpeg2swfConfig 
    		+ " -f " + inputJPEGs
    		+ " -o " + outputJPEG2SWF);
    	
    	isFile(outputJPEG2SWF);
    	
    	//swfcombine -o flashfile.swf /dspace/dspace.getcdb/modules/jspui/src/main/resources/rfxview.swf viewport=dspaceConvert101122/output.swf
		String swfcombine = ConfigurationManager.getProperty("filter.exec.swfcombine");
    	if (swfcombine == null)
    		swfcombine = "swfcombine";
    	String rfxview = ConfigurationManager.getProperty("filter.SWFToolsPDFFilter.config.rfxview");
        if (rfxview == null)
        	rfxview = (String) ConfigurationManager.getProperty("dspace.dir") + File.separator + "modules"+File.separator+"jspui"+File.separator+"src"+File.separator+"main"+File.separator+"resources"+File.separator+"rfxview.swf";
        
        doProcess(swfcombine 
        	+ " -o " + outputSWF
        	+ " " + rfxview
        	+ " viewport=" + outputJPEG2SWF);
    	
        isFile(outputSWF);
		deleteFile(firstImage);
   		}	//if (MediaFilterRecycle.get(outputSWF) == false)
		
		deleteFile(input);
		deleteDir(tempDir);
        
        return outputSWF;
    }
    
    static public String PDF2ALBUM(InputStream source, int id) throws Exception, FileNotFoundException
	{
		String converted = writeFile(source, "pdf", id);
		return PDF2ALBUM(converted, id, null);
	}
   
   static public String PDF2ALBUM(String input, int id) throws Exception, FileNotFoundException
   {
   	   return PDF2ALBUM(input, id, null);
   }
   
   static public String PDF2ALBUM(String input, int id, String type) throws Exception, FileNotFoundException
    {
    	System.out.println("Starting PDF2ALBUM...");
    	isFile(input);
    	
		String tempfile = getTempDir();
		String tempDir = tempfile + "dspaceConverted" +id + "-PDF2ALBUM";

        String outputZIP = tempfile+"dspaceConverted"+id+"-PDF2ALBUM.zip";
        if (MediaFilterRecycle.get(outputZIP) == false)
		{
		
		deleteDir(tempDir);
		mkdir(tempDir);
		
		//String firstImage = XpdfPDF2JPEG(input, id, false);
		String firstImage;
		if (true)
		{
			String pdftohtml = ConfigurationManager.getProperty("filter.exec.xpdf-pdftohtml");
			if (pdftohtml == null)
				pdftohtml = "pdftohtml";
			
			String pdfToHtmlConfig = ConfigurationManager.getProperty("filter.exec.xpdf-pdftohtml.config"
					, "-c -noframes -nodrm");
			String cmd = pdftohtml + " " + input + " -f 1 -l 1 "+ pdfToHtmlConfig;
			
			doProcess(cmd);
			
			deletePDFtoHTMLfile(input);
			String outputPNG = input.substring(0, input.lastIndexOf(".")) + "001.png";
			firstImage = outputPNG;
			
			try
			{
				isFile(firstImage);
			}
			catch (Exception e3)
			{
				deleteFile(input, true);
				throw e3;
			}
		}
		
		try
			{
				System.out.println("\nStart Xpdf pdftohtml");
		    	
		    	XpdfPDFAll2JPEGProgressively(tempDir, input);
		    }
		    catch (Exception e)
		    {
		    	System.out.println("\nError! "+e.getMessage());
		    	
				System.out.println("\nStart ImageMagick convert");
				
				ImageMagickPDFAll2JPEGProgressively(tempDir, id, input, true);
		    	
		    	try
		    	{
		    		isFile(tempDir + "/dspaceConverted" + id + "-00000.jpg");
		    	}
		    	catch (Exception e2) 
		    	{
		    		deleteFile(input, true);
		    		throw e2;
		    	}
		    }
		
		/*
		if (isImageLain(firstImage) == false)
		{
			try
			{
				System.out.println("\nStart Xpdf pdftohtml");
		    	
		    	XpdfPDFAll2JPEGProgressively(tempDir, input);
		    }
		    catch (Exception e)
		    {
		    	System.out.println("\nError! "+e.getMessage());
		    	
				System.out.println("\nStart ImageMagick convert");
				
				ImageMagickPDFAll2JPEGProgressively(tempDir, id, input, true);
		    	
		    	try
		    	{
		    		isFile(tempDir + "/dspaceConverted" + id + "-00000.jpg");
		    	}
		    	catch (Exception e2) 
		    	{
		    		deleteFile(input, true);
		    		throw e2;
		    	}
		    }
		}	//if (isImageLain(inputPNG) == false)
		else
		{
			try
			{
				System.out.println("\nStart ImageMagick convert");
				
				ImageMagickPDFAll2JPEGProgressively(tempDir, id, input);
		    	
		    	isFile(tempDir + "/dspaceConverted" + id + "-00000.jpg");
			}
			catch (Exception e)
			{
				System.out.println("\n Error! "+e.getMessage());
				
				System.out.println("\nStart Xpdf pdftohtml");
		    	
		    	try
		    	{
		    		XpdfPDFAll2JPEGProgressively(tempDir, input, true);
		    	}
		    	catch (Exception e2) {
		    		deleteFile(input, true);
		    		throw e2;
		    	}
			}
		}
		*/
    	//調查tempDir裡面的所有檔案，並加入輸入列表當中
    	String ZoomifyImagePath = ConfigurationManager.getProperty("filter.exec.zoomifyImage", "/opt/ZoomifyImage/ZoomifyFileProcessor.py");
    	String python = ConfigurationManager.getProperty("filter.exec.python", "python");
    	
    	File inputDir = new File(tempDir);
    	String[] jpegs = inputDir.list();
    	Arrays.sort(jpegs);
    	
    	int pageCounter = 1;
    	for (int i = 0; i < jpegs.length; i++)
    	{
    		int dot = jpegs[i].lastIndexOf(".");
    		if (dot == -1
    			|| jpegs[i].substring((dot + 1), jpegs[i].length()).equals("jpg") == false)
    		{
    			FileUtil.delete(tempDir + "/" + jpegs[i]);
    			continue;
    		}
    		
    		String page = "" + pageCounter;
    		while (page.length() < 5)
    			page = "0"+page;
    		
    		String jpg = tempDir + "/" + page + ".jpg";
    		FileUtil.rename(tempDir + "/" + jpegs[i], jpg);
    		
    		//然後來作轉換
    		String zoomifyCmd = python+" "+ZoomifyImagePath+" "+jpg;
    		doProcess(zoomifyCmd);
    		FileUtil.delete(jpg);
    		pageCounter++;
    	}
    	
    	//記錄頁碼
    	String pageFile = tempDir + "/page.js";
    	FileUtil.write("" + (pageCounter-1), pageFile);
    	
    	//接下來作壓縮
    	String zip = makeZip(tempDir, id);
    	FileUtil.rename(zip, outputZIP);
    	
        isFile(outputZIP);
		deleteFile(firstImage);
   		}	//if (MediaFilterRecycle.get(outputSWF) == false)
		
		deleteFile(input);
		deleteDir(tempDir);
        
        return outputZIP;
    }
    
    static public InputStream PDFBox_PDF2Text(String input, int id) throws OutOfMemoryError, IOException, FileNotFoundException
    {
    	isFile(input);
    	
    	InputStream source = readFile(input);
    	return PDFBoxPDF2Text(source, id);
    }
    
    static public InputStream PDFBoxPDF2Text(InputStream source, int id) throws OutOfMemoryError, IOException, FileNotFoundException
    {
    	System.out.println("Starting PDFBoxPDF2Text...");
    	try
        {
            boolean useTemporaryFile = ConfigurationManager.getBooleanProperty("pdffilter.largepdfs", false);

            // get input stream from bitstream
            // pass to filter, get string back
            PDFTextStripper pts = new PDFTextStripper();
            PDDocument pdfDoc = null;
            Writer writer = null;
            File tempTextFile = null;
            ByteArrayOutputStream byteStream = null;

            if (useTemporaryFile)
            {
                tempTextFile = File.createTempFile("dspacepdfextract" + source.hashCode(), ".txt");
                tempTextFile.deleteOnExit();
                writer = new OutputStreamWriter(new FileOutputStream(tempTextFile));
            }
            else
            {
                byteStream = new ByteArrayOutputStream();
                writer = new OutputStreamWriter(byteStream);
            }
            
            try
            {
                pdfDoc = PDDocument.load(source);
                pts.writeText(pdfDoc, writer);
            }
            finally
            {
                try
                {
                    if (pdfDoc != null)
                        pdfDoc.close();
                }
                catch(Exception e)
                {
                   //log.error("Error closing PDF file: " + e.getMessage(), e);
                }

                try
                {
                    writer.close();
                }
                catch(Exception e)
                {
                   //log.error("Error closing temporary extract file: " + e.getMessage(), e);
                }
            }

            if (useTemporaryFile)
            {
                return new FileInputStream(tempTextFile);
            }
            else
            {
                byte[] bytes = byteStream.toByteArray();
                return new ByteArrayInputStream(bytes);
            }
        }
        catch (OutOfMemoryError oome)
        {
            //log.error("Error parsing PDF document " + oome.getMessage(), oome);
            if (!ConfigurationManager.getBooleanProperty("pdffilter.skiponmemoryexception", false))
            {
                throw oome;
            }
        }

        return null;
    }
    
    static public String XpdfPDF2Text(InputStream source, int id) throws Exception, FileNotFoundException
	{
		String converted = writeFile(source, "pdf", id);
		return XpdfPDF2Text(converted, id);
	}
   
   static public String XpdfPDF2Text(String input, int id) throws Exception, FileNotFoundException
    {
    	System.out.println("Starting XpdfPDF2Text...");
    	isFile(input);
    	
		String output = input.substring(0, input.lastIndexOf(".")) + ".txt";
		
		deleteFile(output);
		
        if (MediaFilterRecycle.get(output) == false)
		{
			String pdftotext = ConfigurationManager.getProperty("filter.exec.xpdf-pdftotext");
			if (pdftotext == null)
				pdftotext = "pdftotext";
			
			String cmd = pdftotext + " " + input;
			
			//Process p = Runtime.getRuntime().exec(cmd);
			//p.waitFor();
			doProcess(cmd);
			
			isFile(output);
		}
		deleteFile(input);
		
		return output;
   }
   
   public static void filterMedia(String handle) throws IOException
   {
   	   int delay = ConfigurationManager.getIntProperty("filter.auto-delay");
   	   if (delay == 0)
   	   	   delay = 10000;
   	   filterMedia(delay, handle);
   }
   static public boolean isImageLain(String sourceImage) throws FileNotFoundException, IOException
   {
   		InputStream source = new FileInputStream(sourceImage);
		BufferedImage buf = ImageIO.read(source);
		float xsize = (float) buf.getWidth(null);
        float ysize = (float) buf.getHeight(null);
        
        if (xsize > ysize)
        {
        	System.out.println("Image "+sourceImage+" is lain.");
        	return true;
        }
        else
        {
        	System.out.println("Image "+sourceImage+" is not lain.");
        	return false;
        }
   }
   
   public static void ImageMagickPDFAll2JPEG(String tempDir, int id, String input) throws Exception
   {
   		//convert -verbose -colorspace RGB -interlace none -density 120 -quality 100 -trim 101097.pdf dspaceConvert101122/101122.jpg
    	String outputJPEG = tempDir+"/dspaceConverted"+id+"-%05d.jpg";
    	
    	String imagemagick = ConfigurationManager.getProperty("filter.exec.imagemagick");
    	if (imagemagick == null)
    		imagemagick = "convert";
    	
    	String PDF2JPEGconfig = ConfigurationManager.getProperty("filter.ImageMagick.PDF2JPEG.config", "-trim -verbose -colorspace RGB -interlace none -density 120 -quality 100");
    	
    	doProcess(imagemagick + " " 
    		+ PDF2JPEGconfig + " "
    		+ input + " "
    		+ outputJPEG);
   }
   
   public static void ImageMagickPDFAll2JPEGProgressively(String tempDir, int id, String inputSource) throws Exception
   {
   		ImageMagickPDFAll2JPEGProgressively(tempDir, id, inputSource, false);
   }
   
   public static void ImageMagickPDFAll2JPEGProgressively(String tempDir, int id, String inputSource, boolean isForce) throws Exception
   {
   	   int page = 0;
   	   int errorpage = -1;
   	   int count = 0;
   	   int max = 5;
   	   boolean flag = true;
   	   
   	   String imagemagick = ConfigurationManager.getProperty("filter.exec.imagemagick");
    	if (imagemagick == null)
    		imagemagick = "convert";
   	   String PDF2JPEGconfig = ConfigurationManager.getProperty("filter.ImageMagick.PDF2JPEG.config"
   	   		, "-trim -verbose -colorspace RGB -interlace none -density 120 -quality 100");
   	   String header = tempDir+"/dspaceConverted"+id+"-";
   	   String footer = ".jpg";
   	   
		while (flag == true)
		{
			String num = Integer.toString(page);
			while(num.length() < 5)
				num = "0" + num;
			
			String output = header + num + footer;
			String input = inputSource + "[" + page + "]";
			doProcess(imagemagick + " " 
	    		+ PDF2JPEGconfig + " "
	    		+ input + " "
	    		+ output);
	    	
	    	try
	    	{
	    		isFile(output);

		    	if (errorpage != -1)
		    	{
		    		//發生錯誤，前一頁失敗，但是後一頁卻成功，表示這頁發生錯誤
		    		if (isForce == false)
		    		{
			    		deleteDir(tempDir);
						mkdir(tempDir);
			    		throw new IOException("Error occur in page "+errorpage+"!");
			    	}
		    	}
		    	
		    	Thread.currentThread().sleep(100);
	    	}
	    	catch (FileNotFoundException e)
	    	{
	    		System.out.println("Error occur in page "+page+"!");
	    		
	    		if (errorpage == -1)
	    		{
	    			errorpage = page;
	    		}
	    		else if (errorpage + 1 == page)
	    		{
	    			if (count >= max)
	    			{
	    				System.out.println("Retry max ("+max+"). Process over.");
	    				flag = false;	//完成囉!
	    			}
	    			else
	    			{
	    				count++;
	    				errorpage = page;
	    			}
	    		}
	    		else if (isForce == true)
	    		{
	    			errorpage = page;
	    		}
	    	}
	    	
	    	page++;
		}
   }
   
	public static void XpdfPDFAll2JPEG(String tempDir, String inputSource) throws Exception
	{
		String inputPDF = tempDir + "/input.pdf";
		//第一步，先把檔案複製到那個目錄底下吧
		System.out.println("複製檔案：\n\t來源："+inputSource+"\n\t目的："+inputPDF);
		FileUtil.copy(inputSource, inputPDF);
		isFile(inputPDF);
		
	    //第二步，利用XPDF轉換圖片
	    String pdftohtml = ConfigurationManager.getProperty("filter.exec.xpdf-pdftohtml");
		if (pdftohtml == null)
			pdftohtml = "pdftohtml";
		
		String pdfToHtmlConfig = ConfigurationManager.getProperty("filter.exec.xpdf-pdftohtml.config"
			, "-c -noframes -nodrm");
		
		String cmd = pdftohtml + " " + inputPDF + " "+ pdfToHtmlConfig;
		doProcess(cmd);
		deletePDFtoHTMLfile(inputPDF);
		//檢查是否轉換成功
		
	    String checkOutputPNG = tempDir + "/input001.png";
	    //System.out.println("確認是否有成功轉出……"+checkOutputPNG);
	    isFile(checkOutputPNG);
	    
		//列出該目錄底下的所有png
		//System.out.print("列出該目錄底下的所有png……"+tempDir);
		String[] files = FileUtil.listFiles(tempDir);
		//System.out.println(" 共"+files.length+"個檔案");
		
		String imagemagick = ConfigurationManager.getProperty("filter.exec.imagemagick");
		if (imagemagick == null)
			imagemagick = "convert";
		//System.out.println("\tImageMagick執行指令:"+imagemagick);
		
		for (int i = 0; i < files.length; i++)
		{
			//System.out.println("\t第"+i+"個檔案："+files[i]);
			int dot = files[i].lastIndexOf(".");
			//System.out.println("\t第"+i+"個檔案的dor："+dot);
			if (dot == -1
				|| files[i].substring(dot + 1, files[i].length()).equals("png") == false)
				continue;
			//System.out.println("\t第"+i+"個檔案的extenstion：" + files[i].substring(dot + 1, files[i].length()).equals("png"));
			//設定輸入及輸出路徑
			String inputPNG = tempDir + "/" + files[i];
			String filename = files[i];
			if (dot != -1)
				filename = files[i].substring(0, dot);
			String outputJPEG = tempDir + "/" + filename + ".jpg";
			//System.out.println("\t第"+i+"個檔案的outputJPEG：" + outputJPEG);
			//設定轉換
			
			String cmdConvert = imagemagick+" "+inputPNG+" "+outputJPEG;
			
			/*
			//檢查，如果是投影片系列，則要加入裁邊、轉正的效果
			if (type != null
				&& (type.equals("ppt")
				|| type.equals("pptx")
				|| type.equals("sxi")
				|| type.equals("sti")
				|| type.equals("sdd")
				|| type.equals("sdp")
				|| type.equals("odp")
				|| type.equals("otp")))
			{
				cmdConvert = imagemagick+" "+inputPNG+" -trim -rotate 90 "+outputJPEG;
			}
			*/
			if (isImageLain(inputPNG) == true)
			{
				cmdConvert = imagemagick+" "+inputPNG+" -trim -rotate 90 "+outputJPEG;
			}
			
			//System.out.println("\t第"+i+"個檔案準備執行："+cmdConvert);
			doProcess(cmdConvert);
			
			//檢查有沒有轉換成功
			isFile(outputJPEG);
			//System.out.println("\t第"+i+"個檔案轉換完畢："+files[i]);
		}	//for (int i = 0; i < files.length; i++)
	}
	
	public static void XpdfPDFAll2JPEGProgressively(String tempDir, String inputSource) throws Exception
	{
		XpdfPDFAll2JPEGProgressively(tempDir, inputSource, false);
	}
	
	public static void XpdfPDFAll2JPEGProgressively(String tempDir, String inputSource, boolean isForce) throws Exception
	{
		String inputPDF = tempDir + "/temp.pdf";
		//第一步，先把檔案複製到那個目錄底下吧
		System.out.println("複製檔案：\n\t來源："+inputSource	+"\n\t目的："+inputPDF);
		FileUtil.copy(inputSource, inputPDF);
		isFile(inputPDF);
		
	    //第二步，利用XPDF轉換圖片
	    String pdftohtml = ConfigurationManager.getProperty("filter.exec.xpdf-pdftohtml");
		if (pdftohtml == null)
			pdftohtml = "pdftohtml";
		
		String pdfToHtmlConfig = ConfigurationManager.getProperty("filter.exec.xpdf-pdftohtml.config"
			, "-c -noframes -nodrm");
		
		int page = 1;
		int errorpage = -1;
		int count = 0;
		int max = 5;
		
		String header = tempDir+"/input";
   	   	String footer = ".png";
   	   	
		boolean flag = true;
		while (flag == true)
		{
			String cmd = pdftohtml + " " + inputPDF + " "+ pdfToHtmlConfig 
				+ " -f "+ page + " -l " + page;
			doProcess(cmd);
			
			String num = Integer.toString(page);
			while(num.length() < 3)
				num = "0" + num;
			String output = header + num + footer;
			String temp = tempDir+"/temp" + "001" + footer;
			
			try
	    	{
	    		isFile(temp);
	    		FileUtil.rename(temp, output);
	    		
		    	if (errorpage != -1)
		    	{
		    		//System.out.println("Error occur in page "+errorpage+"!");
		    		//發生錯誤，前一頁失敗，但是後一頁卻成功，表示這頁發生錯誤
		    		
		    		if (isForce == false)
		    		{
			    		deleteDir(tempDir);
						mkdir(tempDir);
			    		throw new IOException("Error occur in page "+errorpage+"!");
			    	}
		    	}
		    	
		    	Thread.currentThread().sleep(100);
	    	}
	    	catch (FileNotFoundException e)
	    	{
	    		System.out.println("Error occur in page "+page+"!");
	    		
	    		if (errorpage == -1)
	    		{
	    			errorpage = page;
	    		}
	    		else if (errorpage + 1 == page)
	    		{
	    			if (count >= max)
	    			{
	    				System.out.println("Retry max ("+max+"). Process over.");
	    				flag = false;	//完成囉!
	    			}
	    			else
	    			{
	    				count++;
	    				errorpage = page;
	    			}
	    		}
	    		else if (isForce == true)
	    		{
	    			errorpage = page;
	    		}
	    	}
	    	
	    	page++;
		}
		deletePDFtoHTMLfile(inputPDF);
		
		//檢查是否轉換成功
		
	    String checkOutputPNG = tempDir + "/input001.png";
	    //System.out.println("確認是否有成功轉出……"+checkOutputPNG);
	    isFile(checkOutputPNG);
	    
		//列出該目錄底下的所有png
		//System.out.print("列出該目錄底下的所有png……"+tempDir);
		String[] files = FileUtil.listFiles(tempDir);
		//System.out.println(" 共"+files.length+"個檔案");
		
		String imagemagick = ConfigurationManager.getProperty("filter.exec.imagemagick");
		if (imagemagick == null)
			imagemagick = "convert";
		//System.out.println("\tImageMagick執行指令:"+imagemagick);
		
		for (int i = 0; i < files.length; i++)
		{
			//System.out.println("\t第"+i+"個檔案："+files[i]);
			int dot = files[i].lastIndexOf(".");
			//System.out.println("\t第"+i+"個檔案的dor："+dot);
			if (dot == -1
				|| files[i].substring(dot + 1, files[i].length()).equals("png") == false)
				continue;
			//System.out.println("\t第"+i+"個檔案的extenstion：" + files[i].substring(dot + 1, files[i].length()).equals("png"));
			//設定輸入及輸出路徑
			String inputPNG = tempDir + "/" + files[i];
			String filename = files[i];
			if (dot != -1)
				filename = files[i].substring(0, dot);
			String outputJPEG = tempDir + "/" + filename + ".jpg";
			//System.out.println("\t第"+i+"個檔案的outputJPEG：" + outputJPEG);
			//設定轉換
			
			String cmdConvert = imagemagick+" "+inputPNG+" "+outputJPEG;
			
			if (isImageLain(inputPNG) == true)
			{
				cmdConvert = imagemagick+" "+inputPNG+" -trim -rotate 90 "+outputJPEG;
			}
			
			//System.out.println("\t第"+i+"個檔案準備執行："+cmdConvert);
			doProcess(cmdConvert);
			
			//檢查有沒有轉換成功
			isFile(outputJPEG);
		}	//for (int i = 0; i < files.length; i++)
	}

	//----------------------------------------------
	   
   public static void filterMedia(long delay, String handle) throws IOException
   {
   	   filterMedia(delay, handle, false);
   }
   
   public static void filterMedia(long delay, String handle, Boolean doWait) throws IOException
   {
   	   filterMedia(delay, handle, doWait, false);
   }
   
   public static void filterMedia(String handle, Boolean doWait, Boolean doIndex) throws IOException
   {
   	   int delay = ConfigurationManager.getIntProperty("filter.auto-delay");
   	   if (delay == 0)
   	   	   delay = 10000;
   		filterMedia(delay, handle, doWait, doIndex);
   }
   
   public static void filterMedia(long delay, String handle, Boolean doWait, Boolean doIndex) throws IOException
   {
   	   Timer timer = new Timer();
   	   FilterMediaTask task = new FilterMediaTask();
   	   task.setup(handle, doWait, doIndex);
   	   
   	   timer.schedule(task, delay);
   }
   


}
