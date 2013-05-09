<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="java.util.zip.ZipEntry" %>
<%@ page import="java.util.zip.ZipFile" %>
<%@ page import="java.io.ByteArrayOutputStream" %>
<%@ page import="java.lang.Runtime" %>
<%@ page import="java.lang.Process" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.io.FileOutputStream" %>
<%@ page import="java.util.zip.ZipInputStream" %>
<%@ page import="org.dspace.core.Utils" %>

<%

String sourcePath = "/opt/apache-tomcat-6.0.16/webapps/jspui/zoomify/zoomify.zip";
InputStream is = new FileInputStream(sourcePath);

String targetPath = (String) request.getParameter("path");
if (targetPath == null)
	targetPath = "ImageProperties.xml";

ZipInputStream zipis = new ZipInputStream(is);

String name = "";
ZipEntry entry = null;
while ((entry = zipis.getNextEntry()) != null)
{
	name = entry.getName();
	if (name.equals(targetPath))
		break;
}



//out.print(name);

//response.setContentType(bitstream.getFormat().getMIMEType());

// Response length
//response.setHeader("Content-Length", String
//                .valueOf(entry.getSize()));

//InputStream outputis = new 
//	      InputStream(entry.getName());
//FileOutputStream fos = new 
//	      FileOutputStream(entry.getName());

		  
//Utils.bufferedCopy(outputis, response.getOutputStream());
//outputis.close();
//response.getOutputStream().flush();

ByteArrayOutputStream bout = new ByteArrayOutputStream();  
byte[] temp = new byte[1024];  
byte[] buf = null;  
int length = 0;  

while ((length = zipis.read(temp, 0, 1024)) != -1)   {
	bout.write(temp, 0, length);  
} 

buf = bout.toByteArray();  
bout.close();   

//byte[] buf = getData(zis);  
//

response.setHeader("Content-Length", String
                .valueOf(entry.getSize())); 
				
String type = name.substring(name.lastIndexOf(".") + 1, name.length()).toLowerCase();

String MIMEType = "image/jpeg";
if (type.equals("xml"))
{
	MIMEType = "text/xml";
}
else if (type.equals("jpg"))
{
	MIMEType = "image/jpeg";
}
response.setContentType(MIMEType);

/*
OutputStream toClient = response.getOutputStream();   //得到向客户端输出二进制数据的对象 

toClient.write(buf);   //输出数据
toClient.flush();  
toClient.close(); 
*/
Utils.bufferedCopy(zipis, response.getOutputStream());
				zipis.close();
				response.getOutputStream().flush();
%>
