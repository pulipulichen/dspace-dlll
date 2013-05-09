<%--
  - filter-media.jsp
  -	語系檔備份：

  --%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.app.util.FileUtil" %>
<%
	String queueFilePath = ConfigurationManager.getProperty("log.dir","/dspace/log") + "/filter-media-queue.log";
	String filterMediaQueue = FileUtil.read(queueFilePath);
	
	if (filterMediaQueue == null)
		filterMediaQueue = "";
%>
<dspace:layout titlekey ="jsp.dspace-admin.filter-media.queue.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.dspace-admin.filter-media.title"
               parentlink="/dspace-admin/filter-media"
               nocache="true">
  <table width="95%">
    <tr>
      <td align="left">
        <h1>
    		<button type="button" style="float:right" onclick="openFilterMedia();">
    			<%-- 回到多媒體轉檔 --%>
				<fmt:message key="jsp.dspace-admin.filter-media.queue.back-to-form"/>
    		</button>
			<%-- 多媒體轉檔 任務列表 --%>
			<fmt:message key="jsp.dspace-admin.filter-media.queue.heading"/>
			<script type="text/javascript">
			function openFilterMedia()
			{
				var url = '<%= request.getContextPath() %>/dspace-admin/filter-media';
				var search = location.search;
				var needle = "?do_queue_manager=true";
				if (search.length > needle.length)
				{
					if (search.substring(0, needle.length) == needle)
						search = search.substring(needle.length, search.length);
					
					if (search.substring(0, 1) == "&")
						search = search.substring(1, search.length);
					
					url = url + "?" + search;
				}
				location.href = url;
			}
			</script>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page='<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#editmessages" %>'><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

<script type="text/javascript">
function cleanQueue() {
	<%-- if (window.confirm("確定要清除？")) --%>
	if (window.confirm("<fmt:message key="jsp.dspace-admin.filter-media.queue.confirm-clean"/>"))
		document.getElementById("queue").value = "";
}
function setParamenter(thisForm) {
	<%-- if (window.confirm('確定修改？') == false) --%>
	if (window.confirm('<fmt:message key="jsp.dspace-admin.filter-media.queue.confirm-edit"/>') == false)
		return false;
	
	var action = thisForm.action;
	
	var search = location.search;
	var needle = "?do_queue_manager=true";
	if (search.length > needle.length)
	{
		if (search.substring(0, needle.length) == needle)
			search = search.substring(needle.length, search.length);
		
		if (search.substring(0, 1) == "&")
			search = search.substring(1, search.length);
		
		action = action + "&" + search;
	}
	thisForm.action = action;
}
</script>
<form method="post" action="<%= request.getContextPath() %>/dspace-admin/filter-media?do_queue_manager=true" onsubmit="return setParamenter(this);">
	<div style="text-align:center">

	<textarea name="queue" id="queue" style="width: 90%;height: 20em;display:block;margin:auto;"><%= filterMediaQueue %></textarea>
	<input type="hidden" name="edit_queue" value="true" />
	
	<button type="button" onclick="location.reload()">
		<%-- 重新整理 --%>
		<fmt:message key="jsp.dspace-admin.filter-media.queue.reload"/>
	</button>
	<button type="reset">
		<%-- 復原 --%>
		<fmt:message key="jsp.dspace-admin.filter-media.queue.reset"/>
	</button>
	<button type="button" onclick="cleanQueue()">
		<%-- 清除 --%>
		<fmt:message key="jsp.dspace-admin.filter-media.queue.clean"/>
	</button>
	<button type="submit">
		<%-- 修改 --%>
		<fmt:message key="jsp.dspace-admin.filter-media.queue.edit"/>
	</button>
		
	</div>

	</form>

</dspace:layout>