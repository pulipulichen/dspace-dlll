<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %>
<%@ page import="org.dspace.content.Bitstream" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%
    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);    

	//get submission information object
    SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);

Bitstream[] bitstreams = subInfo.getSubmissionItem().getItem().getNonInternalBitstreams();
Bitstream json_bitsream = bitstreams[0];	//bitstreams[(bitstreams.length-1)];	
%>
{
	error: '',
	filename: '<%= bitstreams[(bitstreams.length-1)].getName() %>',
	url: '<%= request.getContextPath() %>/retrieve/<%= bitstreams[(bitstreams.length-1)].getID() %>/<%= org.dspace.app.webui.util.UIUtil.encodeBitstreamName(bitstreams[(bitstreams.length-1)].getName()) %>',
	format: '<%= bitstreams[(bitstreams.length-1)].getFormatDescription() %>'
}