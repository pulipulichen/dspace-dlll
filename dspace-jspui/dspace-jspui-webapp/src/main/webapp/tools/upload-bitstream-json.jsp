<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" 
%><%@ page import="org.dspace.core.Context" 
%><%@ page import="org.dspace.content.Item" 
%><%@ page import="org.dspace.content.Bitstream" 
%><%@ page import="java.util.Arrays" 
%><%@ page import="org.dspace.app.webui.util.UIUtil" %><%
    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);    
	Item item = (Item) request.getAttribute("item");
	Bitstream[] bitstreams = item.getNonInternalBitstreams();
	int[] bsIDs = new int[bitstreams.length];
	for (int i = 0; i < bsIDs.length; i++)
		bsIDs[i] = bitstreams[i].getID();
	
	Arrays.sort(bsIDs);
	
	Bitstream json_bitsream = Bitstream.find(context, bsIDs[(bsIDs.length-1)]);
%>{
	error: '',
	filename: '<%= json_bitsream.getName() %>',
	url: '<%= request.getContextPath() %>/retrieve/<%= json_bitsream.getID() %>/<%= org.dspace.app.webui.util.UIUtil.encodeBitstreamName(json_bitsream.getName()) %>',
	format: '<%= json_bitsream.getFormatDescription() %>'
}