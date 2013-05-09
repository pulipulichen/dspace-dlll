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
<%
	String identifier = (request.getParameter("i") != null ? request.getParameter("i") : "");
	boolean isForce = (request.getParameter("f") == null ? false : true );
	if (request.getParameter("f") != null
		&& ((String) request.getParameter("f")).equals("true"))
		isForce = true;
	else
		isForce = false;
	boolean noIndex = (request.getParameter("n") == null ? true : false );
	if (request.getParameter("n") != null
		&& ((String) request.getParameter("n")).equals("false"))
		noIndex = false;
	else
		noIndex = true;
	String plugin = (request.getParameter("p") != null ? request.getParameter("p") : "");
	int max2Process = 0;
	try
	{
		if (request.getParameter("m") != null)
			max2Process = Integer.parseInt(request.getParameter("m"));
	}
	catch (Exception e) {}
	
	boolean alone = (request.getParameter("a") == null ? true : false );
	if (request.getParameter("a") != null
		&& ((String) request.getParameter("a")).equals("false"))
		alone = false;
	else
		alone = true;
%>
<dspace:layout titlekey ="jsp.dspace-admin.filter-media.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin"
               nocache="true">
  <table width="95%">
    <tr>
      <td align="left">
        <h1>
    		<button type="button" style="float:right" onclick="openQueueManager();">
    			<%-- 管理轉檔排程 --%>
    			<fmt:message key="jsp.dspace-admin.filter-media.queue-manager"/>
    		</button>
			<%-- 多媒體轉檔 --%>
			<fmt:message key="jsp.dspace-admin.filter-media.heading"/>
			<script type="text/javascript">
			function openQueueManager()
			{
				var url = '<%= request.getContextPath() %>/dspace-admin/filter-media?do_queue_manager=true';
				var search = location.search;
				if (search.length > 3)
				{
					if (search.substring(0, 1) == "?")
						search = search.substring(1, search.length);
					
					url = url + "&" + search;
				}
				window.open(url, '_blank');
			}
			</script>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page='<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#editmessages" %>'><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

<form method="post" action="<%= request.getContextPath() %>/dspace-admin/filter-media" onsubmit="return beforeSubmit()">
	<input type="hidden" name="do_filter_media" value="true" />

<script type="text/javascript">
function doCheck(id) {
	jQuery("#"+id).attr("checked", "checked");
}

function beforeSubmit() {
	//蒐集已經打勾的項目
	var plugin = "";
	var checkedPlugins = jQuery("table.filter-media-command-form table#pluginList tbody:first input:checkbox:checked");
	var plugins = jQuery("table.filter-media-command-form table#pluginList tbody:first input:checkbox");
	
	if (checkedPlugins.length != plugins.length)
	{
		for (var i = 0; i < checkedPlugins.length; i++)
		{
			if (plugin != "")
				plugin = plugin + ",";
			plugin = plugin + checkedPlugins.eq(i).attr("value");
		}
		jQuery("table.filter-media-command-form input[name='plugin_value']").val(plugin);
	}
	else
		jQuery("table.filter-media-command-form input[name='plugin_value']").val("");
	return true;
}
</script>
<style type="text/css">
.filter-media-command-form th {
	vertical-align:top;
}
</style>

<table class="filter-media-command-form" align="center" width=" 70%">
	<tbody>
		<tr>
			<th width="70" style="min-width:70px;">
				<%-- 指定對象 --%>
				<fmt:message key="jsp.dspace-admin.filter-media.form.content-type"/>
			</th>
			<td>
				<table cellpadding="0" cellspacing="0">
					<tbody>
						<tr>
							<th>
								<input type="radio" name="identifier" value="false" id="identifier_false" 
								<%
									if (identifier.equals("") == true)
										out.print("checked=\"checked\"");
								%>
								 />
							</th>
							<td>
								<label for="identifier_false">
									<%-- 全部 DSpace --%>
									<fmt:message key="jsp.dspace-admin.filter-media.form.all-dspace"/>
								</label>
							</td>
						</tr>
						<tr>
							<th>
								<input type="radio" name="identifier" value="true" id="identifier_true"
									<%
									if (identifier.equals("") == false)
										out.print("checked=\"checked\"");
									%>
									 />
							</th>
							<td>
								<input type="text" name="identifier_value" onfocus="doCheck('identifier_true');" style="width:90%;" value="<%= identifier %>" />
								<br />
								<fmt:message key="jsp.dspace-admin.filter-media.form.scope-note"/>
								
							</td>
						</tr>
					</tbody>
				</table>
			</td>
		</tr>
		<tr>
			<th>
				<%-- 重新轉檔 --%>
				<fmt:message key="jsp.dspace-admin.filter-media.form.force"/>
			</th>
			<td>
				<input type="radio" name="force" value="false" id="force_false" <%= (isForce == false ? "checked=\"checked\"" : "") %> />
				<label for="force_false">
					<%-- 略過已經轉檔完成的檔案 --%>
					<fmt:message key="jsp.dspace-admin.filter-media.form.force-false"/>
				</label><br />
				<input type="radio" name="force" value="true" id="force_true" <%= (isForce == true ? "checked=\"checked\"" : "") %> />
				<label for="force_true">
					<%-- 是，轉換成功之後刪除之前的轉檔 --%>
					<fmt:message key="jsp.dspace-admin.filter-media.form.force-true"/>
				</label>
			</td>
		</tr>
		<tr>
			<th>
				<%-- 製作索引 --%>
				<fmt:message key="jsp.dspace-admin.filter-media.form.index"/>
			</th>
			<td><input type="radio" name="noIndex" value="false" id="noIndex_false" <%= (noIndex == false ? "checked=\"checked\"" : "") %> />
				<label for="noIndex_true">
					<%-- 製作索引，需要多花一點時間處理 --%>
					<fmt:message key="jsp.dspace-admin.filter-media.form.index-false"/>
				</label><br />
				<input type="radio" name="noIndex" value="true" id="noIndex_true" <%= (noIndex == true ? "checked=\"checked\"" : "") %> />
				<label for="noIndex_false">
					<%-- 不製作索引 --%>
					<fmt:message key="jsp.dspace-admin.filter-media.form.index-true"/>
				</label>
				
			</td>
		</tr>
		<tr>
			<th>
				<%-- 轉檔類型 --%>
				<fmt:message key="jsp.dspace-admin.filter-media.form.plugin"/>
			</th>
			<td>
				<input type="text" name="plugin_value" style="display:none;" value="<%= plugin %>" />
								<!-- ※可使用的類型有：<%= ConfigurationManager.getProperty("filter.plugins","沒有可以用的類型") %>，請以「,」連接多個類型 -->
								<table id="pluginList" width="100%"><tbody></tbody></table>
								<button id="pluginListSelectAll" type="button">
									<%-- 全選 --%>
									<fmt:message key="jsp.dspace-admin.filter-media.form.plugin-select-all"/>
								</button>
								<button id="pluginListDeselectAll" type="button">
									<%-- 取消全選 --%>
									<fmt:message key="jsp.dspace-admin.filter-media.form.plugin-deselect-all"/>
								</button>
								<script type="text/javascript">
								jQuery(document).ready(function () {
									var filterPlugins = "<%= ConfigurationManager.getProperty("filter.plugins","") %>";
									
									if (filterPlugins == "")
									{
										<%-- //jQuery("table#pluginList").after("沒有可以用的類型"); --%>
										jQuery("table#pluginList").after("<fmt:message key="jsp.dspace-admin.filter-media.form.plugin-null"/>");
										jQuery("table#pluginList").remove();
									}
									else
									{
										var cols = 3;
										
										var tbody = jQuery("table#pluginList tbody:first");
										
										var list = filterPlugins.split(",");
										
										var selectPlugins = jQuery.trim("<%= plugin %>");
										var selectList = [];
										if (selectPlugins != "")
											selectList = selectPlugins.split(",");
										
										for (var i = 0; i < list.length; i++)
										{
											var p = jQuery.trim(list[i]);
											
											if (i % cols == 0)
												var tr = jQuery("<tr></tr>");
											
											var checkbox = jQuery("<input type=\"checkbox\" title=\""+p+"\" value=\""+p+"\" />");
											
											if (selectList.length > 0)
											{
												for (var j = 0; j < selectList.length; j++)
												{
													if (p == jQuery.trim(selectList[j]))
													{
														checkbox.attr("checked", "checked");
														break;
													}
												}
											}
											else
												checkbox.attr("checked", "checked");
											
											var label = jQuery("<label>"+p+"</lable>")
												.css("cursor", "pointer")
												.click(function () {
													jQuery(this).parent().prev().children("input:checkbox").click();
												});
											
											tr.append(jQuery("<th valign=\"top\"></th>").append(checkbox))
												.append(jQuery("<td valign=\"top\"></td>").append(label));
											
											if (i % cols == cols - 1
												|| i == list.length -1)
												tr.appendTo(tbody);
										}
									}
									
									jQuery("button#pluginListSelectAll").click(function () {
										jQuery("table#pluginList input:checkbox").attr("checked", "checked");
									});
									jQuery("button#pluginListDeselectAll").click(function () {
										jQuery("table#pluginList input:checkbox").removeAttr("checked");
									});
								});
								</script>
			</td>
		</tr>
		<tr>
			<th>
				<%-- 轉檔筆數 --%>
				<fmt:message key="jsp.dspace-admin.filter-media.max"/>
			</th>
			<td>
				<table cellpadding="0" cellspacing="0">
					<tbody>
						<tr>
							<th><input type="radio" name="max2Process" value="false" id="max2Process_false" <%= (max2Process == 0 ? "checked=\"checked\"" : "") %> /></th>
							<td>
								<label for="max2Process_false">
									<%-- 不限制 --%>
									<fmt:message key="jsp.dspace-admin.filter-media.max-false"/>
								</label>
							</td>
						</tr>
						<tr>
							<th><input type="radio" name="max2Process" value="true" id="max2Process_true" <%= (max2Process > 0 ? "checked=\"checked\"" : "") %> /></th>
							<td>
								<%-- 轉換<input type="text" name="max2Process_value" onfocus="doCheck('max2Process_true');" value="<%= max2Process %>" />個檔案就停止 --%>
								<fmt:message key="jsp.dspace-admin.filter-media.max-true">
					    			<fmt:param><input type="text" name="max2Process_value" onfocus="doCheck('max2Process_true');" value="<%= max2Process %>" /></fmt:param>
					        	</fmt:message>
							</td>
						</tr>
					</tbody>
				</table>
			</td>
		</tr>
		<tr>
			<th>
				<%-- 直接轉檔 --%>
				<fmt:message key="jsp.dspace-admin.filter-media.alone"/>
			</th>
			<td><input type="radio" name="alone" value="false" id="alone_false" <%= (alone == false ? "checked=\"checked\"" : "") %> />
				<label for="noIndex_true">
					<%-- 如果有其他轉檔進行中，則排隊等待其他轉檔完成之後再進行 --%>
					<fmt:message key="jsp.dspace-admin.filter-media.alone-false"/>
				</label><br />
				<input type="radio" name="alone" value="true" id="alone_true" <%= (alone == true ? "checked=\"checked\"" : "") %> />
				<label for="noIndex_false">
					<%-- 直接進行轉檔 --%>
					<fmt:message key="jsp.dspace-admin.filter-media.alone-true"/>
				</label>
				
			</td>
		</tr>
	</tbody>
</table>

<div style="text-align:center;padding: 20px;">
	<%-- 轉檔的過程中，指定的對象(甚至是全部文件)會被資料庫鎖定而暫時無法瀏覽。建議在離峰期進行轉檔。 --%>
	<fmt:message key="jsp.dspace-admin.filter-media.form.warning"/>
	<br />
	<button type="submit">
		<%-- 開始轉檔 --%>
		<fmt:message key="jsp.dspace-admin.filter-media.form.submit"/>
	</button>
</div>

</form>

</dspace:layout>