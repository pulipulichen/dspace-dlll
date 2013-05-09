//Please Upload to [dspace-source]/dspace-api/src/main/java/org/dspace/app/util
package org.dspace.app.util;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;

import java.lang.ArrayIndexOutOfBoundsException;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.File;
import java.io.FileWriter;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.FileNotFoundException;

public class FileUtil
{
	public static String[] list(String dirpath) throws ServletException, IOException
	{
		File dir = new File(dirpath);

		if (dir.isDirectory())
		    return  dir.list();
		else
			return null;
	}
	
	public static String[] listFiles(String dirpath)
	{
		String[] filenames = new String[0];
		try
		{
			File dir = new File(dirpath);

			if (dir.isDirectory())
			{
				File[] list = dir.listFiles() ;
				filenames = new String[list.length];
				for (int i = 0; i < list.length; i++)
					filenames[i] = list[i].getName();
				//return filenames;
			}
		}
		catch (Exception e) { }
		return filenames;
	}
	
	public static String read(String filepath) throws ServletException, IOException
    {
    	if (exists(filepath) == false)
    		return null;
    	
    	String messages = "";
    	
    	// 1. 建立文字檔讀取物件
	    //FileReader FileStream = new FileReader(filepath); 
	    FileInputStream fin = new FileInputStream(filepath);
	    InputStreamReader in = new InputStreamReader(fin, "utf-8");
		// 2. 透過 BufferedReader 幫我們讀資料
		BufferedReader BufferedStream = new BufferedReader(in);

		String data;
		do{
	         	// 3. 接著 一行一行 的把資料從檔案中讀出來
	            data = BufferedStream.readLine();

	         	// 4. 當讀取到最後一行後,
	            if(data == null)
	                break;          // 讀到檔案結束
				else
					messages = messages + data + "\r\n";
	    } while(BufferedStream.ready());
	    
	    return messages;
    }
    
    public static String read(String filepath, long start, long end) throws ServletException, IOException
    {
    	if (exists(filepath) == false)
    		return null;
    	
    	String messages = "";
    	
    	// 1. 建立文字檔讀取物件
	    FileReader FileStream = new FileReader(filepath); 
		// 2. 透過 BufferedReader 幫我們讀資料
		BufferedReader BufferedStream = new BufferedReader(FileStream);
		
		//long i = 0;
		int data;
		if (start < 0)
			start = 0;
		FileStream.skip(start);
		char buffer[];
		int size = (int) (end - start);
		buffer = new char[size];
		FileStream.read(buffer); 
		for (int i = 0; i < buffer.length; i++)
			messages = messages + buffer[i];
		/*
		do{
	         	// 3. 接著 一行一行 的把資料從檔案中讀出來
	            data = BufferedStream.read();

	         	// 4. 當讀取到最後一行後,
	            if(data == -1)
	                break;          // 讀到檔案結束
				else
				{
					if (i == end - start || i > (end - start))
						break;
					messages = messages + data;
					
				}
	    } while(true);
	    */
	    return messages;
    }
    
    public static long readLength(String filepath) throws ServletException, IOException
    {
    	if (exists(filepath) == false)
    		return -1;
    	
    	long len = 0;
    	
    	// 1. 建立文字檔讀取物件
	    FileReader FileStream = new FileReader(filepath); 
		char buffer[] = new char[1];
		//long i = 0;
		while (FileStream.ready())
		{
         	// 3. 接著 一行一行 的把資料從檔案中讀出來
            FileStream.read(buffer);
			len++;
	    }
	    return len;
    }
	
	public static void write(String messages, String filepath, boolean append) throws ServletException, IOException
    {
    	mkdirsForFile(filepath);
    	File f = new File(filepath);
		FileWriter fw = new FileWriter(f , append);
		
		fw.write(messages);
		fw.close();
    }
    
    public static void write(String messages, String filepath) throws ServletException, IOException
    {
    	write(messages, filepath, true);
    }
    
    public static void writeForce(String messages, String filepath) throws ServletException, IOException
    {
    	//delete(filepath);
    	write(messages, filepath, false);
    }
    
    public static void copy(String sourceFile, String targetFile) throws ServletException, IOException
    {
    	try {
	            byte[] buffer = new byte[1024]; 

	            FileInputStream fileInputStream = 
	                new FileInputStream(new File(sourceFile)); 
	            //deleteFile(targetFile);
	            mkdirsForFile(targetFile);
	            File tf = new File(targetFile);
	            FileOutputStream fileOutputStream = 
	                new FileOutputStream(tf); 

	            int length = -1;
	            // 從來源檔案讀取資料至緩衝區 
	            while((length = fileInputStream.read(buffer)) != -1) { 
	                // 將陣列資料寫入目的檔案 
	                fileOutputStream.write(buffer, 0, length);
	            } 

	            // 關閉串流 
	            fileInputStream.close(); 
	            fileOutputStream.close(); 
				
	        } 
	        catch(ArrayIndexOutOfBoundsException e) {  
	            e.printStackTrace(); 
	        } 
	        catch(IOException e) { 
	            e.printStackTrace(); 
	        }
    }
    
    public static void move(String sourceFile, String targetFile) throws ServletException, IOException
	{
		copyForce(sourceFile, targetFile);
		delete(sourceFile);
	}
	
	public static void rename(String sourceFile, String targetFile) throws ServletException, IOException
	{
		File s = new File(sourceFile);
		File t = new File(targetFile);
		
		if (t.exists())
		{
			delete(targetFile);
		}
		
		s.renameTo(t);
	}
    
    public static void copyForce(String sourceFile, String targetFile) throws ServletException, IOException
    {
    	delete(targetFile);
    	copy(sourceFile, targetFile);
    }
    
    public static boolean delete(String filepath) throws ServletException, IOException
    {
    	File f = new File(filepath);
    	if (f.exists())
    		return f.delete();
    	else
    		return false;
    }
    
    public static boolean exists(String filepath) throws ServletException, IOException
    {
    	File f = new File(filepath);
    	return f.exists();
    }
    public static boolean exist(String filepath) throws ServletException, IOException
    {
    	return exists(filepath);
    }
    
    public static boolean mkdirsForFile(String filepath) throws ServletException, IOException
    {
    	String dirpath = filepath.substring(0, filepath.lastIndexOf("/"));
    	File d = new File(dirpath);
    	return d.mkdirs();
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
}
