<%-- 
	messages-edit.jsp
	語系檔備份：
jsp.dspace-admin.messages-edit.title = \u7de8\u8f2f\u8a9e\u7cfb\u6a94
jsp.dspace-admin.messages-edit.editing-position = \u60a8\u6b63\u5728\u7de8\u8f2f {0} \u8a9e\u7cfb\u6a94
jsp.dspace-admin.messages-edit.filter.key = \u7d22\u5f15\u540d\u7a31\u5305\u542b
jsp.dspace-admin.messages-edit.filter.or = \u6216
jsp.dspace-admin.messages-edit.filter.and = \u4e26
jsp.dspace-admin.messages-edit.filter.key = \u986f\u793a\u5167\u6587\u5305\u542b
jsp.dspace-admin.messages-edit.filter.do = \u641c\u5c0b
jsp.dspace-admin.messages-edit.filter.reset = \u986f\u793a\u5168\u90e8
jsp.dspace-admin.messages-edit.function.create = \u65b0\u589e\u9805\u76ee
jsp.dspace-admin.messages-edit.function.scroll-to-button = \u79fb\u81f3\u9801\u5c3e
jsp.dspace-admin.messages-edit.function.scroll-to-top = \u56de\u5230\u9801\u9996
jsp.dspace-admin.messages-edit.table.key = \u7d22\u5f15\u540d\u7a31
jsp.dspace-admin.messages-edit.table.value = \u986f\u793a\u5167\u6587
jsp.dspace-admin.messages-edit.js.nowLoading = \u8b80\u53d6\u4e2d\u2026\u2026\u8acb\u7a0d\u5019\u2026\u2026
jsp.dspace-admin.messages-edit.js.deleteButton = \u522a\u9664
jsp.dspace-admin.messages-edit.js.deleteConfirm = \u78ba\u5b9a\u662f\u5426\u8981\u522a\u9664\uff1f
jsp.dspace-admin.messages-edit.js.insertButton = \u63d2\u5165
jsp.dspace-admin.messages-edit.js.moveUpButton = \u2191
jsp.dspace-admin.messages-edit.js.moveDownButton = \u2193
jsp.dspace-admin.messages-edit.js.error.heading = \u767c\u751f\u932f\u8aa4
jsp.dspace-admin.messages-edit.js.error.name = \u932f\u8aa4\u540d\u7a31
jsp.dspace-admin.messages-edit.js.error.message = \u932f\u8aa4\u8a0a\u606f
jsp.dspace-admin.messages-edit.js.error.ValueEmpty = \u4e0d\u80fd\u662f\u7a7a\u767d\uff01
jsp.dspace-admin.messages-edit.js.error.WithSlash = \u4e0d\u80fd\u5305\u542b\uff1a
jsp.dspace-admin.messages-edit.js.error.WithNewLine = \u4e0d\u80fd\u63db\u884c\uff01
jsp.dspace-admin.messages-edit.js.error.CharsetError = \u4e0d\u80fd\u5305\u542b\u975e\u82f1\u6578\u5b57\u7684\u6587\u5b57
jsp.dspace-admin.messages-edit.js.save.KeyEmptyError = \u986f\u793a\u5167\u6587\u300c[0]\u300d\u7f3a\u5c11\u7d22\u5f15\u540d\u7a31\uff01
jsp.dspace-admin.messages-edit.js.save.ValueEncodeError = \u89e3\u78bc\u5230\u300c[0]\u300d\u6642\u767c\u751f\u932f\u8aa4\uff01
jsp.dspace-admin.messages-edit.js.filter.processing = \u641c\u5c0b\u4e2d\uff0c\u8acb\u7a0d\u5019\u3002
jsp.dspace-admin.messages-edit.js.sortConfirm = \u6392\u5e8f\u9700\u8981\u4e00\u6bb5\u6642\u9593\u904b\u7b97\uff0c\u800c\u4e14\u6392\u5e8f\u4e4b\u5f8c\u7684\u7d50\u679c\u7121\u6cd5\u5fa9\u539f\uff0c\u8acb\u554f\u662f\u5426\u8981\u7e7c\u7e8c\uff1f
jsp.dspace-admin.messages-edit.js.filter.not-found = \u641c\u5c0b\u6c92\u6709\u7d50\u679c\u3002
jsp.dspace-admin.messages-edit.encode-demo.heading = \u6e2c\u8a66\u8f49\u78bc\u5668
jsp.dspace-admin.messages-edit.encode-demo.text-to-dspace = \u2190
jsp.dspace-admin.messages-edit.encode-demo.dspace-to-text = \u2192	
jsp.dspace-admin.messages-edit.text-decoded = \u539f\u59cb\u6587\u5b57
jsp.dspace-admin.messages-edit.text-encoded = \u7de8\u78bc\u6587\u5b57
jsp.dspace-admin.messages-edit.js.save.Confirm = \u5132\u5b58\u4e4b\u5f8c\u4e0d\u80fd\u5fa9\u539f\uff0c\u662f\u5426\u8981\u7e7c\u7e8c\uff1f
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.Constants" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%
	String position = (String)request.getAttribute("position");
	
	//get the existing messages
    String messages = (String)request.getAttribute("messages");

    if (messages == null)
    {
        messages = "";
    }

	request.setAttribute("LanguageSwitch", "hide");
%>

<dspace:layout titlekey="jsp.dspace-admin.messages-edit.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.dspace-admin.messages-main.title"
               parentlink="/dspace-admin/messages-edit">

<script type="text/javascript" src="<%= request.getContextPath() %>/extension/jquery.js"></script>
<style type="text/css">
textarea.file_text	{display:none;}
div.functionArea { text-align:center; }
div.list-container { text-align:center; }
div.encode_demo { text-align:center; }
div.list-container table {margin: auto;width: 100%;}
div.list-container table tbody tr td { text-align:center;vertical-align:top; }
div.list-container table tbody tr td .input-text { width: 100%; }
/*div.list-container table tbody tr td .input-text.expand	{ height: 10em; }*/
div.list-container table tbody tr td .invalid { background-color:#FF6666; }
div.list-container table tbody tr td div.hint { font-size:small;color:#FF0000; }
div.list-container table tbody tr td.function button { font-size:smaller; }

div.filterArea { text-align:center; }
div.filterArea table { margin:auto; }
div.filterArea table tbody tr th { width: 4em;text-align:left; }
</style>

 <form action="<%= request.getContextPath() %>/dspace-admin/messages-edit" method="post" onsubmit="return MessageTable.saveToSource(this)">
 	<h1>
		<fmt:message key="jsp.dspace-admin.messages-edit.editing-position">
        	<fmt:param><%=position%></fmt:param>
    	</fmt:message>
		
		<%-- 您正在編輯<= position >語系檔 --%>
	</h1>
 	<input type="hidden" name="position" value="<%=position %>" />
	<input type="hidden" name="submit_action" value="submit_save" />
	
	<textarea id="file_text" name="messages" class="file_text"><%= messages %></textarea>
	
	<div class="filterArea">
		<a id="filter_anchor" name="filter_anchor"></a>
		<table>
			<tbody>
				<tr>
					<td>
						<fmt:message key="jsp.dspace-admin.messages-edit.filter.key" />
						<%-- 索引名稱包含 --%>
						<input type="text" class="filter-key" value="" id="filterKey" onfocus="jQuery(this).select();" /></td>
					<td>
						<select id="filterCond">
							<option selected="true" value="or">
								<fmt:message key="jsp.dspace-admin.messages-edit.filter.or" />
								<%-- 或 --%>
							</option>
							<option value="and">
								<fmt:message key="jsp.dspace-admin.messages-edit.filter.and" />
								<%-- 並 --%>
							</option>
						</select>
					</td>
					<td>
						<fmt:message key="jsp.dspace-admin.messages-edit.filter.value" />
						<%-- 顯示內文包含 --%>
						<input type="text" class="filter-value" value="" id="filterValue" onfocus="jQuery(this).select();" /></td>
					<td>
						<button type="button" id="filterDo">
							<fmt:message key="jsp.dspace-admin.messages-edit.filter.do" />
							<%-- 搜尋 --%>
						</button>
						<button type="button" id="filterReset">
							<fmt:message key="jsp.dspace-admin.messages-edit.filter.reset" />
							<%-- 顯示全部 --%>
						</button>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
	
	<div class="encode_demo" style="display:none;">
		<table style="margin:auto;">
			<tr>
				<td>&nbsp;</td>
				<td>
					<fmt:message key="jsp.dspace-admin.messages-edit.text-decoded" />
					<%-- 原始文字 --%>
				</td>
				<td>&nbsp;</td>
				<td>
					<fmt:message key="jsp.dspace-admin.messages-edit.text-encoded" />
					<%-- 編碼文字 --%>
				</td>
			</tr>
			<tr>
				<th>
					<fmt:message key="jsp.dspace-admin.messages-edit.encode-demo.heading" />
					<%-- 測試轉碼器 --%>
				</th>
				<td>
					<input type="text" id="forText" />
				</td>
				<td>
					<button type="button" class="dspaceToText">
						<fmt:message key="jsp.dspace-admin.messages-edit.encode-demo.text-to-dspace" />
						<%-- ← --%>
					</button>
					<button type="button" class="textToDspace">
						<fmt:message key="jsp.dspace-admin.messages-edit.encode-demo.dspace-to-text" />
						<%-- → --%>
					</button>
				</td>
				<td>
					<input type="text" id="forDspace" />
				</td>
			</tr>
		</table>
	</div>
	
	<div class="functionArea">
		<%--
		<input type="button" name="submit_save" class="file_save" value="儲存" />
		<input type="button" class="addMessage" value="新增項目" />
		<input type="button" class="scrollToButton" value="移至頁尾" />
		--%>
		<input type="button" name="submit_save" class="file_save" value="<fmt:message key="jsp.dspace-admin.messages-edit.file-save" />" />
		<input type="button" name="submit_save" class="file_save_exit" value="<fmt:message key="jsp.dspace-admin.messages-edit.file-save-exit" />" />
		<input type="button" class="addMessage" value="<fmt:message key="jsp.dspace-admin.messages-edit.function.create" />" />
		<input type="button" class="scrollToButton" value="<fmt:message key="jsp.dspace-admin.messages-edit.function.scroll-to-button" />" />
		
		<input type="button" class="submit_cancel" name="cancel" value="<fmt:message key="jsp.dspace-admin.general.cancel"/>" />
	</div>
	
	<div class="list-container" id="list_container">
		<table cellspacing="5" cellpadding="5" style="display:none;">
			<thead>
				<th width="30%">
					<fmt:message key="jsp.dspace-admin.messages-edit.table.key" />
					<%-- 索引名稱 --%>
				</th>
				<th>
					<fmt:message key="jsp.dspace-admin.messages-edit.table.value" />
					<%-- 顯示內文 --%>
				</th>
				<th style="width: 8em;">&nbsp;</th>
			</thead>
			<tbody>
			
			</tbody>
			<tfoot>
				<th width="30%">
					<fmt:message key="jsp.dspace-admin.messages-edit.table.key" />
					<%-- 索引名稱 --%>
				</th>
				<th>
					<fmt:message key="jsp.dspace-admin.messages-edit.table.value" />
					<%-- 顯示內文 --%>
				</th>
				<th>&nbsp;</th>
			</tfoot>
		</table>
	</div>
	
	<div class="functionArea" style="display:none;">
		<%--
		<input type="button" name="submit_save" class="file_save" value="儲存" />
		<input type="button" class="addMessage" value="新增項目" />
		<input type="button" class="scrollToTop" value="回到頁首" />
		--%>
		<input type="button" name="submit_save" class="file_save" value="<fmt:message key="jsp.dspace-admin.messages-edit.file-save" />" />
		<input type="button" name="submit_save" class="file_save_exit" value="<fmt:message key="jsp.dspace-admin.messages-edit.file-save-exit" />" />
		<input type="button" class="addMessage" value="<fmt:message key="jsp.dspace-admin.messages-edit.function.create" />" />
		<input type="button" class="scrollToTop" value="<fmt:message key="jsp.dspace-admin.messages-edit.function.scroll-to-top" />" />
		<input type="button" class="submit_cancel" name="cancel" value="<fmt:message key="jsp.dspace-admin.general.cancel"/>" />
	</div>
	<div><fmt:message key="jsp.dspace-admin.messages-edit.hint-title" />
		<ul>
			<li>
				<fmt:message key="jsp.dspace-admin.messages-edit.hint-1" /> <button type="button" id="filterReset2"><fmt:message key="jsp.dspace-admin.messages-edit.filter.reset" /></button>
			</li>
			<li>
				<fmt:message key="jsp.dspace-admin.messages-edit.hint-2" /> 
				<a href="#filter_anchor" onclick="jQuery('#filterValue').select()"><fmt:message key="jsp.dspace-admin.messages-edit.hint-3" /></a> 
				<fmt:message key="jsp.dspace-admin.messages-edit.hint-4" />
			</li>
		</ul>
	</div>
</form>

<!-- <textarea id="t"></textarea> -->

<script type="text/javascript">
jQuery(document).ready(function () {

	MessageTable.setup();

});

function MessageTableController()
{
	var mObj = this;
	
	var LANG = {
		"nowLoading": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.nowLoading") %>", //"讀取中……請稍候……",
		"deleteButton": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.deleteButton") %>", //"刪除",
		"deleteConfirm": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.deleteConfirm") %>", //"確定是否要刪除？",
		"insertButton": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.insertButton") %>", //"插入",
		"moveUpButton": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.moveUpButton") %>", //"↑",
		"moveDownButton": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.moveDownButton") %>", //"↓",
		"error": {
			"heading": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.error.heading") %>", //"發生錯誤",
			"name": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.error.name") %>", //"錯誤名稱",
			"message": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.error.message") %>", //"錯誤訊息",
			"ValueEmpty": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.error.ValueEmpty") %>", //"不能是空白！",
			"WithSlash": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.error.WithSlash") %>\\", //"不能包含「\\」！",
			"WithNewLine": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.error.WithNewLine") %>", //"不能換行！",
			"CharsetError": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.error.CharsetError") %>" //"不能包含非英數字的文字"
		},
		"save": {
			"KeyEmptyError": '<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.save.KeyEmptyError") %>', //"顯示內文「[0]」缺少索引名稱！",
			"ValueEncodeError": '<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.save.ValueEncodeError") %>', //"解碼到「[0]」時發生錯誤！"
			"Confirm": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.save.Confirm") %>"	//儲存之後不能復原，是否要繼續？
		},
		"filter": {
			"processing": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.filter.processing") %>", //"搜尋中，請稍候。"
			"NotFound": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.filter.not-found") %>", //"搜尋沒有結果。"
		},
		"sortConfirm": "<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-edit.js.sortConfirm") %>" //"排序需要一段時間運算，而且排序之後的結果無法復原，請問是否要繼續？"
		
	};
	
	mObj.config = {
		"source": "#file_text",
		"save": ".file_save",
		"saveExit": ".file_save_exit",
		"container" : "#list_container",
		"filterKey" : "#filterKey",
		"filterValue" : "#filterValue",
		"filterDo" : "#filterDo",
		"filterReset" : "#filterReset, #filterReset2",
		"filterCond" : "#filterCond",
		"addMessage": ".addMessage",
		"functionArea": ".functionArea",
		"filterArea": ".filterArea",
		"scrollToTop": ".scrollToTop",
		"scrollToButton": ".scrollToButton",
		"sortMessage": ".sortMessage",
		"cancel": ".submit_cancel",
		"encodeDemo": {
			"forText": "#forText",
			"forDspace": "#forDspace",
			"textToDspace": ".textToDspace",
			"dspaceToText": ".dspaceToText"
		}
	};
	
	mObj.debug = false;	//false;
	
	mObj.setup = function () {
		try
		{
			var processing = jQuery("<div class='help'>"+LANG.nowLoading+"</div>");
			
			if (mObj.debug == true)
			{
				jQuery(mObj.config.source).show();
			}
			
			jQuery(mObj.config.container).prepend(processing);
			
			mObj.loadFromSource(function () {
				processing.remove();
			});
			
			var addClickListener = function (jQueryObj, func)
			{
				for (var i = 0; i < jQueryObj.length; i++)
				{
					jQueryObj.eq(i).click(func);
				}
			}
			
			//jQuery(mObj.config.filterDo).click(function () { 
			//	filterDo(); 
			//});
			addClickListener(jQuery(mObj.config.filterDo), function () {
				filterDo(); 
			});
			//jQuery(mObj.config.filterReset).click(function () { 
			//	filterReset(); 
			//});
			addClickListener(jQuery(mObj.config.filterReset), function () {
				filterReset(); 
			});
			//jQuery(mObj.config.save+":eq(0)").click(function () {
			//	saveToSource(this.form);
			//});
			addClickListener(jQuery(mObj.config.save), function () {
				saveToSource(this.form, false);
			});
			addClickListener(jQuery(mObj.config.saveExit), function () {
				saveToSource(this.form, true);
			});
			//jQuery(mObj.config.addMessage).click(function () {
			//	addRow();
			//});
			addClickListener(jQuery(mObj.config.addMessage), function () {
				addRow();
			});
			//jQuery(mObj.config.scrollToTop).click(function () {
			//	document.body.scrollIntoView(true);
			//});
			addClickListener(jQuery(mObj.config.scrollToTop), function () {
				window.scrollTo(0, 0);
			});
			//jQuery(mObj.config.scrollToButton).click(function () {
			//	jQuery().scrollIntoView(true);
			//});
			addClickListener(jQuery(mObj.config.scrollToButton), function () {
				window.scrollTo(0, jQuery("body").height());
			});
			addClickListener(jQuery(mObj.config.cancel), function () {
				submitCancel(this.form);
			});
			
			addClickListener(jQuery(mObj.config.encodeDemo.textToDspace), function () {
				textToDspace();
			});
			
			addClickListener(jQuery(mObj.config.encodeDemo.dspaceToText), function () {
				dspaceToText();
			});
			//jQuery(mObj.config.sortMessage).click(function () {
			//	sortRow();
			//});
			return mObj;
		}
		catch (e) {
			alert(LANG.error.heading + "\n" 
				+ LANG.error.name + e.name + "\n"
				+ LANG.error.msg + e.message);
		}
	};
	
	var textToDspace = function () {
		var forText = jQuery(mObj.config.encodeDemo.forText);
		var forDspace = jQuery(mObj.config.encodeDemo.forDspace);
		
		var input = forText.val();
		input = encode(input);
		forDspace.val(input);
	};
	
	var dspaceToText = function () {
		var forText = jQuery(mObj.config.encodeDemo.forText);
		var forDspace = jQuery(mObj.config.encodeDemo.forDspace);
		
		var input = forDspace.val();
		input = decode(input);
		forText	.val(input);
	};
	
	var submitCancel = function (form) {
		jQuery(form).find("input[type='hidden'][name='submit_action']").val("submit_cancel");
		jQuery(form).submit();
	};
	
	mObj.loadFromSource = function (callback) {
		setTimeout(function () {
			var source = jQuery(mObj.config.source).val();
			var sourceLineAry = source.split("%0d%0a");
			
			if (sourceLineAry.length < 2)
			{
				//source = escape(source);
				sourceLineAry = source.split("\n");
				if (sourceLineAry.length < 2)
				{
					//alert("語系檔剖析錯誤！請檢查語系檔來源是否正確。");
					alert("<fmt:message key="jsp.dspace-admin.messages-edit.js.parse-error" />");
					
				}
			}
			
			//jQuery(mObj.config.container).hide();
			functionDisable();
			
			var target = jQuery(mObj.config.container+" table tbody");
			//jQuery(mObj.config.container+" table tfoot").hide();
			
			var i = 0;
			var limit = sourceLineAry.length;
			if (mObj.debug == true)
				limit = 10;
			
			var forLoop = function (i, forCallBack)
			{
				if (i < limit)
				{
					var line = sourceLineAry[i];
					line = unescape(line);
					line = jQuery.trim(line);
					if (line != "")
					{
						if (line.substr(0, 1) != "#")
						{
							//var lineAry = line.split("=", 2);
							var equalIndex = line.indexOf("=");
							//var key = jQuery.trim(lineAry[0]);
							var key = line.substring(0, equalIndex);
								key = jQuery.trim(key);
							var value = line.substring((equalIndex + 1));
								value = jQuery.trim(value);
							//var value = jQuery.trim(lineAry[1]);
						}
						else
						{
							var key = line;
							var value = "";
						}
						
						var tr = createRow(key, value);
						tr.hide();
						tr.appendTo(target);
					}
					i++;
					
					var help = jQuery(mObj.config.container).children(".help:first");
					help.html(LANG.nowLoading + " "+i+"/"+limit+" ("+parseInt((i/limit)*100)+"%)");
					
					setTimeout(function () {
						forLoop(i, forCallBack);
					}, 10);
				}
				else
				{
					forCallBack();
				}
			}
			
			forLoop(i, function () {
				functionEnable();
				//jQuery(mObj.config.container+" table tbody tr").show();
				//jQuery(mObj.config.container+" table tfoot").show();
				jQuery(mObj.config.container+" table").show();
				jQuery(mObj.config.functionArea + ":last").show();
				callback();
			});
		}, 0);
	};
	
	var sortRow = function () 
	{
		//太難設計了，放棄吧。
		return;
		
		if (!window.confirm(LANG.sortConfirm))
			return;
		
		var forLoop = function (i, limit, exec, callback) {
			if (i < limit)
			{
				exec(i);
				i++;
				setTimeout(function () {
					forLoop(i, limit, exec, callback);
				}, 50);
			}
			else
				callback();
		};
		
		//先取出所有的key值
		var sourceTbody = jQuery(mObj.config.container+" table tbody").hide();
		var trs = jQuery(mObj.config.container+" table tbody tr");
		var keysAry = new Array();
		forLoop(0, trs.length, function (i) {
			var key = trs.eq(i).find("td .key").val();
			keysAry.push(key);
		}, function () {
			keysAry.sort();
		
			var sortTbody = sourceTbody.clone().empty().show()
				.insertBefore(sourceTbody)			
			var limit = keysAry.length;
			
			/*
			for (var i = 0; i < limit; i++)
			{
				
			}*/
			forLoop(0, limit, function (i) {			
				var key = keysAry[i];
				var tr = sourceTbody.find("tr:has(td .key[value='"+key+"']):first");
				tr.appendTo(sortTbody);
			}, function () {
				sourceTbody.remove();
			});
		});
	};
	
	var addRow = function (thisBtn)
	{
		var tbody = jQuery(mObj.config.container+" table tbody");
		var tr = createRow();
		
		if (typeof(thisBtn) == "undefined")
			tbody.append(tr);
		else
			jQuery(thisBtn).parents("tr:first").after(tr);
		tr.find(".key").focus();
	};
	
	var createRow = function(key, value)
	{
		var tr = jQuery("<tr></tr>");
		
		//var keyInput = jQuery("<input type='text' value='' class='input-text key' />")
		var keyInput = jQuery("<textarea class=\"input-text key\" ></textarea>")
			//.focus(function () {
				//jQuery(this).select();
			//})
			.blur(function () {
				var result = checkValueValid(this.value, true);
				if (result != "")
				{
					if (!jQuery(this).hasClass("invalid"))
					{
						jQuery(this).addClass("invalid");
						//jQuery(this).before(jQuery("<div class='hint'>"+result+"</div>"));
					}
				}
				else if (jQuery(this).hasClass("invalid"))
				{
					jQuery(this).removeClass("invalid");
					//jQuery(this).prevAll().remove();
				}
				
				var tr = jQuery(this).parents("tr:first");
				if (this.value.substr(0, 1) != "#")
				{
					if (tr.children("td:visible").length == 2)
					{
						tr.children("td:hidden").show();
						tr.children("td:eq(0)").attr("colspan", 1);
					}
				}
				else
				{
					if (tr.children("td:visible").length == 3)
					{
						tr.children("td:eq(1)").hide();
						tr.children("td:eq(0)").attr("colspan", 2);
					}
				}
			});
		
		var valueInput = jQuery("<textarea class='input-text value'></textarea>")
			//.focus(function () {
			//	jQuery(this).toggleClass("expand").select();
			//})
			.blur(function () {
				jQuery(this).toggleClass("expand");
				var result = checkValueValid(this.value);
				if (result != "")
				{
					if (!jQuery(this).hasClass("invalid"))
					{
						jQuery(this).addClass("invalid");
						//jQuery(this).before(jQuery("<div class='hint'>"+result+"</div>"));
					}
				}
				else if (jQuery(this).hasClass("invalid"))
				{
					jQuery(this).removeClass("invalid");
					//jQuery(this).prevAll().remove();
				}
			});
		
		tr.append(jQuery("<td></td>").append(keyInput))
			.append(jQuery("<td></td>").append(valueInput))
			.append("<td class='function'></td>");
		
		var btnDel = jQuery("<button class='delete' type='button'>"+LANG.deleteButton+"</button>")
					.click(function () { deleteRow(this); });
		var btnInsert = jQuery("<button class='insert' type='button'>"+LANG.insertButton+"</button>")
					.click(function () { addRow(this); });
		var btnMoveUp = jQuery("<button class='move' type='button'>"+LANG.moveUpButton+"</button>")
					.click(function () { rowMoveUp(this); });
		var btnMoveDown = jQuery("<button class='move' type='button'>"+LANG.moveDownButton+"</button>")
					.click(function () { rowMoveDown(this); });
		tr.find(".function")
			.append(btnDel)
			.append(btnInsert)
			.append("<br />")
			.append(btnMoveUp)
			.append(btnMoveDown);
		
		if (typeof(key) != "undefined")
		{
			if (!isComment(key))
				key = mObj.decode(key);
			tr.find(".key").val(key);
		}
		if (typeof(value) != "undefined")
		{
			value = mObj.decode(value);
			//valueInput.attr("innerHTML", value);
			valueInput.val(value);
			//alert([valueInput.val(), value]);
		}
		
		if (typeof(key) != "undefined"
			&& key.substr(0, 1) == "#")
		{
			tr.children("td:eq(0)").attr("colspan", 2);
			tr.children("td:eq(1)").remove();
		}
		return tr;
	}
	
	var checkValueValid = function (value, isKey)
	{
		value = jQuery.trim(value);
		if (value == "")
			return LANG.error.ValueEmpty;	//"不能是空白！"
		else if (typeof(isKey) != "undefined"
			&& isComment(value))
			return "";
		else if (value.indexOf("\\") != -1)
			return LANG.error.WithSlash;	//"不能包含「\\」！";
		else if (value.indexOf("\n") != -1)
			return LANG.error.WithNewLine;
		else if (typeof(isKey) != "undefined" 
			&& mObj.encode(value) != value)
			return LANG.error.CharsetError;
		else
			return "";
	};
	
	var deleteRow = function (thisBtn)
	{
		if (window.confirm(LANG.deleteConfirm))
		{
			var tr = jQuery(thisBtn).parents("tr:first");
			tr.remove();
		}
	};
	
	var rowMoveUp = function (thisBtn)
	{
		var tr = jQuery(thisBtn).parents("tr:first");
		tr.insertBefore(tr.prev());
		thisBtn.focus();
	} 
	var rowMoveDown = function (thisBtn)
	{
		var tr = jQuery(thisBtn).parents("tr:first");
		tr.insertAfter(tr.next());
		thisBtn.focus();
	} 
	
	var filterDo = function() {
		functionDisable();
		var filterKey = jQuery.trim(jQuery(mObj.config.filterKey).val());
		var filterValue = jQuery.trim(jQuery(mObj.config.filterValue).val());
		var filterCond = jQuery(mObj.config.filterCond).val();
		
		if (filterKey == "" && filterValue == "")
		{
			filterReset();
			functionEnable();
			return;
		}
		else
			filterAll();
		
		jQuery(mObj.config.filterKey).val("");
		jQuery(mObj.config.filterValue).val("");
		
		var helpFiltering = LANG.filter.processing;
		var found = false;
		var msg = jQuery("<div class='help'>"+helpFiltering+"</div>");
		var area = jQuery(mObj.config.filterArea);
		for (var i = 0; i < area.length; i++)
			area.eq(i).append(msg.clone());
		
		setTimeout(function () {		
			if (filterCond == "or")
			{
				if (filterKey != "")
				{
					var trs = jQuery(mObj.config.container+" table tbody tr:hide");
					for (var i = 0; i < trs.length; i++)
					{
						var tr = trs.eq(i);
						
						var key = tr.find(".key:first").val();
						if (key.indexOf(filterKey) != -1)
						{
							tr.show();
							found = true;
						}
					}
				}
				
				if (filterValue != "")
				{
					var trs = jQuery(mObj.config.container+" table tbody tr:hidden");
					for (var i = 0; i < trs.length; i++)
					{
						var tr = trs.eq(i);
						if (tr.find(".value").length == 0)
							continue;
						
						
						var value = tr.find(".value:first").val();
						if (value.indexOf(filterValue) != -1)
						{
							tr.show();
							found = true;
						}
					}
				}
			}	//if (filterCond == "or")
			else
			{
				var trs = jQuery(mObj.config.container+" table tbody tr:hidden");
				for (var i = 0; i < trs.length; i++)
				{
					var tr = trs.eq(i);
					
					var key = tr.find(".key:first").val();
					if (tr.find(".value").length > 0)
					{						
						var value = tr.find(".value:first").val();
						if (key.indexOf(filterKey) != -1
							&& value.indexOf(filterValue) != -1)
						{
							tr.show();
							found = true;
						}
					
					}
				}
			}
			
			if (found == false)
			{
				var notFound = jQuery("<div class=\"help \">"+LANG.filter.NotFound+"</div>");
				setTimeout(function () {
					notFound.remove();
				}, 5000);
				jQuery(mObj.config.container).prepend(notFound);
			}
			functionEnable();
		}, 100);
		area.children(".help").remove();
	};
	
	var filterAll = function () {
		var target = jQuery(mObj.config.container+" table tbody tr");
		target.hide();
	}
	
	var filterReset = function() {
		var target = jQuery(mObj.config.container+" table tbody tr:hidden");
		//target.show();
		
		var loopShow = function (anchor)
		{
			var nextAnchor = anchor + 50;
			for (var i = anchor; i < nextAnchor && i < target.length; i++)
			{
				target.eq(i).show();
			}
			
			setTimeout(function () {
				loopShow(nextAnchor);
			}, 10);
		};
		
		loopShow(0);
	};
	
	var saveToSource = function(form, doExit) {
		
		if (window.confirm(LANG.save.Confirm) == false)
			return false;
		
		functionDisable();
							
		var trs = jQuery(mObj.config.container+" table tbody tr");
		var output = "";
		var lastKey = "";
		var lastState = "key";
		
		for (var i = 0; i < trs.length; i++)
		{
			var tr = trs.eq(i);
			var key = jQuery.trim(tr.find(".key:first").val());
			var value = jQuery.trim(tr.find(".value:first").attr("value"));
			
			if (key == "" && value == "")
			{
				output = output + "\n";
				continue;
			}
			
			if (key == "")
			{
				var msg = LANG.save.KeyEmptyError.replace("[0]", value);
				alert(msg);
				tr.show();
				tr.find(".key:first").focus();
				functionEnable();
				return false;
			}
			else
			{
				if (!isComment(key))
					key = mObj.encode(key);
			}
			
			if (value != "")
			{
				try
				{
					//alert([value , mObj.encode(value)]);
					value = mObj.encode(value);
					value = replaceAll(value, "\n", "");
				}
				catch (e)
				{
					var msgTitle = (LANG.save.ValueEncodeError).replace("[0]", value);
					alert(msgTitle + "\n"
						+ LANG.error.name + e.name + "\n"
						+ LANG.error.msg + e.message);
					tr.find(".value:first").focus();
					functionEnable();
					return false;
				}
			}
			
			if (key.substr(0, 1) != "#")
			{
				var line = key + " = " + value + "\n";
				
				if (lastState != "key")
					line = "\n" + line;
				else
				{
					var keyTrimAry = key.split(".");
					var lastKeyTrimAry = lastKey.split(".");
					
					var matchCount = 0;
					for (var k = 0; k < 3 && k < keyTrimAry.length && k < lastKeyTrimAry.length; k++)
					{
						if (keyTrimAry[k] == lastKeyTrimAry[k])
							matchCount++;
					}
					
					if (matchCount < 3
						&& !(keyTrimAry.length < 4 && lastKeyTrimAry.length < 4 && matchCount == 2))
						line = "\n" + line;
				}
				
				lastKey = key;
				lastState = "key";
			}
			else
			{	
				var line = key + "\n";
				if (lastState == "key")
					line = "\n" + line;
				lastState = "comment";
			}	
			output = output + line;
		}
		
		jQuery(mObj.config.source).attr("innerHTML", output);
		jQuery(mObj.config.source).attr("value", output);
		if (mObj.debug == true)
		{
			alert([jQuery(mObj.config.source).attr("innerHTML")
				,jQuery(mObj.config.source).attr("value")]);
		}
		else
		{
			
				//先檢查是否已經登入
				var validLogin = "<%= request.getContextPath() %>/extension/login-valid.jsp?callback=?&uid=<%= UIUtil.getCurrentUserID(request) %>";
				
				jQuery.getJSON(validLogin, function (data) {
					if (data.isLogin == "true")
					{
						//開啟一個新的iframe，隱藏，放到body後面
						var targetIframe = jQuery("<iframe id=\"msg_save\" name=\"msg_save\" src=\"_blank\"></iframe>")
							.hide()
							.appendTo(jQuery("body"));
						
						jQuery(form).attr("target", "msg_save");
						
						targetIframe.load(function () {
							
							if (typeof(ConfirmTomcatStop) == "boolean")
							{
								window.alert("<fmt:message key="jsp.dspace-admin.messages-edit.js.complete-save" />");
							}
							else if (typeof(ConfirmTomcatStop) == "undefined" &&
								//window.confirm("儲存完成，您是否要重新啟動伺服器？")
								window.confirm("<fmt:message key="jsp.dspace-admin.messages-edit.js.confirm-tomcat-restart" />"))
							{
								//20110531 chrome會擋下window.open
								//window.open("<%= request.getContextPath() %>/dspace-admin/tomcat-restart", "tomcat_restart", "");
								
								location.href="<%= request.getContextPath() %>/dspace-admin/tomcat-restart";
							}
							else if (doExit != true)
							{
								if (typeof(ConfirmTomcatStop) == "undefined" &&
									//window.confirm("下次是否停止詢問重新啟動伺服器？") == true
									window.confirm("<fmt:message key="jsp.dspace-admin.messages-edit.js.confirm-tomcat-stop" />"))
								{
									ConfirmTomcatStop = true;
								}
							}
							
							if (doExit == true)
							{
								location.href="<%= request.getContextPath() %>/dspace-admin/messages-edit";
								return false;
							}
							
							jQuery(form).removeAttr("target");
							functionEnable();
							
							targetIframe.remove();
						});
						
						jQuery(form).submit();
						
					}	//if (data.isLogin == "true")
					else
					{
						alert("<fmt:message key="jsp.dspace-admin.messages-edit.js.has-logout" />");
						functionEnable();
					}
				});
		}
		//正式使用的時候，把下面的註解拿掉，才能正確地送出去
		//jQuery(mObj.config.source).show();
		
		//return false;
		//return true;
		
		//jQuery(form).submit();
	};
	mObj.saveToSource = saveToSource;
	
	var disableFunction = [
		mObj.config.filterDo,
		mObj.config.filterReset,
		mObj.config.addMessage,
		mObj.config.save,
		mObj.config.saveExit,
		mObj.config.sortMessage
	];
	
	var functionDisable = function () {
		for (var i = 0; i < disableFunction.length; i++)
		{
			var func = disableFunction[i];
			var funcObj = jQuery(func);
			for (var j = 0; j < funcObj.length; j++)
				funcObj.eq(j).attr("disabled", true);
		}
	};
	
	var functionEnable = function () {
		for (var i = 0; i < disableFunction.length; i++)
		{
			var func = disableFunction[i];
			var funcObj = jQuery(func);
			for (var j = 0; j < funcObj.length; j++)
				funcObj.eq(j).removeAttr("disabled");
		}
		//jQuery(disableFunction.toString()).removeAttr("disabled");
	};
	
	var replaceAll = function (str, reallyDo, replaceWith)
	{
		return str.replace(new RegExp(reallyDo, 'g'), replaceWith);
	};
	
	var isComment = function (key)
	{
		key = jQuery.trim(key);
		if (key.substr(0, 1) == "#")
			return true;
		else
			return false;
	}
	
	var matchStr = new RegExp(/[0-9]|[a-z]|[A-Z]|[ ]|[-]|[.]|[(]|[)]|[_]|[<]|[>]|[\/]|["]|[']|[=]|[,]|[:]|[{]|[}]|[*]|[?]|[#]|[!]|[+]|[;]|[&]|[~]|[\[]|[\]]/i);	//'"
	mObj.encode = function (source)
	{
	  //var source = document.getElementById("source").value;
	  var utf = "";
	  
	  //轉換成UTF8碼
	  for (var i = 0; i < source.length; i++)
	  {
		char = source.substr(i, 1);
	 
	 	//if (char == " ")
		//	utf = utf + "&amp;nbsp;";
		//else if (char == "&")
		//	utf = utf + "&amp;";
		var encoded = source.charCodeAt(i).toString(16);
	 	//if (char.match(matchStr) == null
		//	|| encoded.length == 4)
		if (encoded.length == 4)
			utf = utf + "\\u" + encoded;
		else
	   		utf = utf + char;
	  }
	  
	  var result = utf;
	  //result = replaceAll(result, "&amp;", "&");
	  //result = replaceAll(result, " ", "&amp;nbsp;");
	  //result = replaceAll(result, "&", "&amp;");
	  //result = replaceAll(result, " ", "&nbsp;");
	  //document.getElementById("target").value = result;
	  return result;
	};
	
	mObj.decode = function(source)
	{
	 // var source = document.getElementById("target").value;
	  var utf = "";
	  
		for (var i = 0; i < source.length; i++)
		{
			char = source.substr(i, 1);
			
			if (char == "\\" && i < source.length - 1)
			{
				char = source.substr(i, 2);
			   
			   if (char == "\\u" && i < source.length - 5)
			   {
					code = source.substr(eval(i+2), 4);
					if (code.indexOf("\\") == -1 && code.indexOf(" ") == -1)
					{
						utf = utf + String.fromCharCode(HEXtoDEC(code));
						i = i + 5;
					}
					else
						utf = utf + char;
				}
				else
					utf = utf + char
			}
			else
				utf = utf + char
		}
	  
	  var result = utf;
	  //result = replaceAll(result, "&", "&amp;amp;");
	  //result = replaceAll(result, " ", "&amp;nbsp;");
	  //result = replaceAll(result, "&amp;nbsp;", " ");
	  //result = replaceAll(result, "&amp;amp;", "&");
	  //document.getElementById("source").value = result;
	  return result;
	};

	var HTMLtoTXT = function (str){
	  var RexStr = /\<|\>|\"|\'|\&/g;
	  str = str.replace(RexStr, function(MatchStr){
		switch(MatchStr){
		  case "<":
			return "&lt;";
			break;
		  case ">":
			return "&gt;";
			break;
		  case "\"":
			return "&quot;";
			break;
		  case "'":
			return "&#39;";
			break;
		  case "&":
			return "&amp;";
			break;
		  default :
			break;
		}
	  })
	  return str;
	}
	
	var HEXtoDEC = function(six)
	{
		  var ten = 0;
		  
		  for (var i = 0; i < six.length; i++)
		  {
			char = six.substr(i, 1);
		 number = 0;
		 
		 switch (char)
		 {
		   case 'a':
			 number = 10;break;
		   case 'b':
			 number = 11;break;
		   case 'c':
			 number = 12;break;
		   case 'd':
			 number = 13;break;
		   case 'e':
			 number = 14;break;
		   case 'f':
			 number = 15;break;  
		   default:
			 number = char;break;
		 }
		
		 for (var j = 0; j < (six.length - i - 1); j++)
		 {
		   number = number * 16;
		 }
		 ten = ten + parseInt(number);
		  }
		  
		  return ten;
	};


	
	return mObj;
}
var MessageTable = MessageTableController();
</script>
    </form>
</dspace:layout>
