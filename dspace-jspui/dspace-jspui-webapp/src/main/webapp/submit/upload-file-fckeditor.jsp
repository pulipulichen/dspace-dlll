<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" 
%><%@ page import="org.dspace.core.Context" 
%><%@ page import="org.dspace.content.Item" 
%><%@ page import="org.dspace.content.Bitstream" 
%><%@ page import="java.util.Arrays" 
%><%@ page import="org.dspace.app.webui.util.UIUtil" %><%@ page import="org.dspace.app.webui.servlet.SubmissionController" %>
<%@ page import="org.dspace.app.util.SubmissionInfo" %><%
    // Obtain DSpace context
    Context context = UIUtil.obtainContext(request);    
	SubmissionInfo subInfo = SubmissionController.getSubmissionInfo(context, request);

Bitstream[] bitstreams = subInfo.getSubmissionItem().getItem().getNonInternalBitstreams();
Bitstream json_bitsream = bitstreams[0];	//bitstreams[(bitstreams.length-1)];	
	String name = UIUtil.encodeBitstreamName(json_bitsream.getName());
%>	
<script type="text/javascript">
(function(){var d=document.domain;while (true){try{var A=window.parent.document.domain;break;}catch(e) {};d=d.replace(/.*?(?:\.|$)/,'');if (d.length==0) break;try{document.domain=d;}catch (e){break;}}})();
window.parent.OnUploadCompleted(0, '<%= request.getContextPath() %>/retrieve/<%= json_bitsream.getID() %>/<%= name %>', '<%= name %>', '<%= json_bitsream.getFormatDescription() %>');
</script>