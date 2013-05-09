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

if (bitstreams.length > 0)
{
	int[] bsIDs = new int[bitstreams.length];
	
	for (int i = 0; i < bsIDs.length; i++)
		bsIDs[i] = bitstreams[i].getID();
	
	Arrays.sort(bsIDs);
	
	Bitstream json_bitsream = Bitstream.find(context, bsIDs[(bsIDs.length-1)]);
	String name = org.dspace.app.webui.util.UIUtil.encodeBitstreamName(json_bitsream.getName());
	
%><script type="text/javascript">
(function(){var d=document.domain;while (true){try{var A=window.parent.document.domain;break;}catch(e) {};d=d.replace(/.*?(?:\.|$)/,'');if (d.length==0) break;try{document.domain=d;}catch (e){break;}}})();
window.parent.OnUploadCompleted(0, '<%= request.getContextPath() %>/retrieve/<%= json_bitsream.getID() %>/<%= name %>', '<%= name %>', '<%= json_bitsream.getFormatDescription() %>');
</script><%
}
else
{
%><script type="text/javascript">
(function(){var d=document.domain;while (true){try{var A=window.parent.document.domain;break;}catch(e) {};d=d.replace(/.*?(?:\.|$)/,'');if (d.length==0) break;try{document.domain=d;}catch (e){break;}}})();
window.parent.OnUploadCompleted(1, '', '', 'There are no file uploaded.');
</script><%
	
}
%>