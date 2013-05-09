<%-- 
	input-forms-edit.jsp

//中文語系檔備份：

jsp.dspace-admin.input-forms-edit-js.delete-confirm = \u78ba\u5b9a\u8981\u522a\u9664\uff1f
jsp.dspace-admin.input-forms-edit-js.handle-editor.heading = \u8acb\u8a2d\u5b9a\u5957\u7528\u6b64form\u7684collection-handle
jsp.dspace-admin.input-forms-edit-js.handle-editor.delete-confirm = \u6b04\u4f4d\u88e1\u9762\u9084\u6709\u503c\uff0c\u78ba\u5b9a\u8981\u522a\u9664\uff1f

jsp.dspace-admin.general.accept = \u78ba\u5b9a

jsp.dspace-admin.input-forms-edit-js.page-editor.must-has-page = \u6700\u5c11\u8981\u6709\u4e00\u9801\uff01
jsp.dspace-admin.input-forms-edit-js.page-editor.delete-confirm = \u78ba\u5b9a\u8981\u522a\u9664\u6b64\u9801\uff1f\u6b64\u52d5\u4f5c\u7121\u6cd5\u5fa9\u539f

jsp.dspace-admin.general.insert = \u63d2\u5165

jsp.dspace-admin.input-forms-edit-js.form-collection.move-up = \u4e0a\u79fb
jsp.dspace-admin.input-forms-edit-js.form-collection.move-down = \u4e0b\u79fb

jsp.dspace-admin.general.copy = \u8907\u88fd
jsp.dspace-admin.general.repeat = \u91cd\u8907

jsp.dspace-admin.input-forms-edit-js.field-move-\u2191up = \u2191
jsp.dspace-admin.input-forms-edit-js.field-move-down = \u2193
jsp.dspace-admin.input-forms-edit-js.do-item-button.priview-limit = \u9810\u89bd\u4e2d\u4e0d\u6703\u6709\u6548\u679c

jsp.dspace-admin.input-forms-edit.title = \u7de8\u8f2f\u905e\u4ea4\u8868\u55ae
jsp.dspace-admin.input-forms-edit.heading = \u7de8\u8f2f\u905e\u4ea4\u8868\u55ae
jsp.dspace-admin.input-forms-edit.dialog.title = \u7cfb\u7d71\u8a0a\u606f
jsp.dspace-admin.input-forms-edit.dialog.now-loading = \u7cfb\u7d71\u8655\u7406\u4e2d\uff0c\u8acb\u7a0d\u5019\u2026\u2026
jsp.dspace-admin.input-forms-edit.edit-form-name = \u66f4\u6539\u8868\u55ae\u540d\u7a31
jsp.dspace-admin.input-forms-edit.add-form = \u65b0\u589e\u8868\u55ae
jsp.dspace-admin.input-forms-edit.edit-page = \u9801\u9762\u8a2d\u5b9a
jsp.dspace-admin.input-forms-edit.edit-page.title = \u6a19\u984c
jsp.dspace-admin.input-forms-edit.edit-page.help = \u8aaa\u660e
jsp.dspace-admin.input-forms-edit.edit-field.title = \u6b04\u4f4d\u8a2d\u5b9a
jsp.dspace-admin.input-forms-edit.edit-field.metadata = \u6b04\u4f4d
jsp.dspace-admin.input-forms-edit.edit-field.metadata.add = \u65b0\u589e\u6b04\u4f4d
jsp.dspace-admin.input-forms-edit.edit-field.metadata.reload = \u91cd\u65b0\u8b80\u53d6
jsp.dspace-admin.input-forms-edit.edit-field.metadata.label = \u6a19\u7c64
jsp.dspace-admin.input-forms-edit.edit-field.metadata.hint = \u63d0\u793a
jsp.dspace-admin.input-forms-edit.edit-field.metadata.requeired = \u5fc5\u586b\u8a0a\u606f
jsp.dspace-admin.input-forms-edit.edit-field.metadata.requeired-false = \u4e0d\u9650\u5236\u5fc5\u586b
jsp.dspace-admin.input-forms-edit.edit-field.metadata.requeired-true = \u63d0\u793a\u8a0a\u606f\uff1a
jsp.dspace-admin.input-forms-edit.edit-field.metadata.repeatable = \u662f\u5426\u53ef\u91cd\u8907\uff1f
jsp.dspace-admin.input-forms-edit.edit-field.metadata.repeatable-true = \u662f
jsp.dspace-admin.input-forms-edit.edit-field.metadata.repeatable-false = \u5426
jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type = \u8f38\u5165\u578b\u614b
jsp.dspace-admin.input-forms-edit.pair-value = \u8cc7\u6599\u5217\u8868
jsp.dspace-admin.input-forms-edit.pair-value.display = \u986f\u793a\u540d\u7a31
jsp.dspace-admin.input-forms-edit.pair-value.stored = \u5132\u5b58\u8cc7\u6599
jsp.dspace-admin.input-forms-edit.default-value = \u7bc0\u9ede
jsp.dspace-admin.input-forms-edit.xmlmetadata.title = XMLMetadata\u7de8\u8f2f\u5668
jsp.dspace-admin.input-forms-edit.save-success = \u5df2\u7d93\u5132\u5b58\uff01\u8acb\u91cd\u65b0\u555f\u52d5\u4f3a\u670d\u5668\u4ee5\u770b\u5230\u4fee\u6539\u7684\u7d50\u679c\u3002
	
jsp.dspace-admin.general.true = \u662f
jsp.dspace-admin.general.false = \u5426


--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.Constants" %>
<%@ page import="org.dspace.app.util.EscapeUnescape" %>
<%
	String inputFormsXML = (String)request.getAttribute("inputFormsXML");
	
	//get the existing messages
    String message = (String) request.getAttribute("message");
	
	String successAlert = "";
	if (message != null && message.equals("success"))
	{
		//successAlert = "<script type=\"text/javascript\"> \n"
		//	+ "window.alert(\""+LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit.save-success")+"\"); \n"
		//	+ "</script> \n";
		//已經儲存！請重新啟動Tomcat網頁伺服器以看到修改的結果。
		successAlert = "<div style=\"text-align:center;border:1px solid gray;padding:5px;\">"+LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit.save-success")+"</div>";
	}
	
%>

<%-- <dspace:layout titlekey="編輯遞交表單" --%>
<dspace:layout titlekey="jsp.dspace-admin.input-forms-edit.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin">

<table width="95%">
    <tr>
      <td align="left">
        <%-- <h1>News Editor</h1> --%>
        <h1>
			<fmt:message key="jsp.dspace-admin.input-forms-edit.heading"/>
			<%-- 編輯遞交表單 --%>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#edititemforms" %>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>
<style type="text/css">
.help { font-size: smaller; font-weight:normal;}
</style>

<%= successAlert %>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/jquery.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/bitstream-display/jquery-ui/js/jquery-ui-1.7.1.custom.min.js"></script>
<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/bitstream-display/jquery-ui/css/smoothness/jquery-ui-1.7.1.custom.css" type="text/css" />

<script type="text/javascript" src="<%= request.getContextPath() %>/extension/fckeditor/fckeditor.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/fckeditor/fckeditor_display_toggle.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/fckeditor/FCKeditor-dialog.jsp"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/jquery.color.js"></script>

<script type="text/javascript" src="<%= request.getContextPath() %>/extension/xmlmetadata/xmlmetadata-lang.jsp"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/xmlmetadata/xmlmetadata-core.js"></script>
<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/xmlmetadata/xmlmetadata-style.css" type="text/css" media="screen">
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/xmlmetadata/ui.datepicker.js"></script>
<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/xmlmetadata/flora.datepicker.css" type="text/css" media="screen">

<script type="text/javascript" src="<%= request.getContextPath() %>/extension/taiwan-address/jquery-plugin-taiwain-address.js"></script>

<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/xmlmetadata-editor-lang.jsp"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/xmlmetadata-editor.js"></script>

<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-lang.jsp"></script>
	
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-field-object.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-collection.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-page-object.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-utils.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-do-item-button.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-form-object.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-prompt-dialog.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-prompt-field-editor.js"></script>
		
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-editor.js"></script>

<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/input-forms-edit/input-forms-editor.css" type="text/css" media="screen">

<script type="text/javascript" src="<%= request.getContextPath() %>/extension/metadata-util.jsp"></script>

<script type="text/javascript" src="<%= request.getContextPath() %>/extension/input-forms-edit/jquery-autocomplete/jquery.autocomplete.js"></script>
<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/input-forms-edit/jquery-autocomplete/jquery.autocomplete.css" type="text/css" media="screen">

<form action="?submit_action=save" method="post">
	<textarea id="source" class="need-unescape" style="display:none;"><%= inputFormsXML %></textarea>
</form>

<div id="prompt_processing" style="height:100%;" class="ui-widget" title="<fmt:message key="jsp.dspace-admin.input-forms-edit.dialog.title"/>">
<%-- <div id="prompt_processing" style="height:100%;" class="ui-widget" title="系統訊息"> --%>
	<table height="100%">
		<tbody>
			<tr>
				<th align="center">
					<fmt:message key="jsp.dspace-admin.input-forms-edit.dialog.now-loading"/>
					<%-- 系統處理中，請稍候…… --%>
				</th>
			</tr>
		</tbody>
	</table>
</div>

<div id="prompt_processing_save" style="height:100%;" class="ui-widget" title="<fmt:message key="jsp.dspace-admin.input-forms-edit.dialog.title"/>">
<%-- <div id="prompt_processing_save" style="height:100%;" class="ui-widget" title="系統訊息"> --%>
	<table height="100%">
		<tbody>
			<tr>
				<th align="center">
					<fmt:message key="jsp.dspace-admin.input-forms-edit.dialog.now-loading"/>
					<%-- 系統處理中，請稍候…… --%>
				</th>
			</tr>
		</tbody>
	</table>
</div>

<div id="prompt_form_name_update" class="ui-widget" title="<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-form-name"/>">
<%-- <div id="prompt_form_name_update" class="ui-widget" title="更改表單名稱"> --%>
	<table>
		<tbody>
			<tr>
				<td valign="top" align="center"><input type="text" class="form-name text" name="form_name" value="" style="width: 90%;" /><div class="hint"></div></td>
			</tr>
		</tbody>
	</table>
</div>

<div id="prompt_form_name_add" class="ui-widget" title="<fmt:message key="jsp.dspace-admin.input-forms-edit.add-form"/>">
<%-- <div id="prompt_form_name_add" class="ui-widget" title="新增表單"> --%>
	<table>
		<tbody>
			<tr>
				<td valign="top" align="center"><input type="text" class="form-name text" name="form_name" value="" style="width: 90%;" /><div class="hint"></div></td>
			</tr>
		</tbody>
	</table>
</div>

<div id="prompt_page_attr" class="ui-widget" title="<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-page"/>">
<%-- <div id="prompt_page_attr" class="ui-widget" title="頁面設定"> --%>
	<table style="height:auto;">
		<tbody>
			<tr>
				<th>
					<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-page.title"/>
					<%-- 標題 --%>
				</th>
				<td valign="top"><input type="text" class="page-label text" name="page-label" style="width: 90%" value="" /></td>
			</tr>
			<tr>
				<th>
					<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-page.help"/>
					<%-- 說明 --%>
				</th>
				<td valign="top"><textarea class="page-hint fckeditor" name="page-hint"></textarea></td>
			</tr>
		</tbody>
	</table>
</div>

<div id="prompt_field_editor" class="ui-widget" title="<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.title"/>">
<%-- <div id="prompt_field_editor" class="ui-widget" title="欄位設定"> --%>
	<table>
		<tbody>
			<!--
			<tr>
				<th class="th">
					<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata"/>
					<%-- 欄位 --%>
					<div class="hint" style="text-align:center;">
						<button class="metadata_field_add" title="<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.add"/>"><img src="<%= request.getContextPath() %>/extension/input-forms-edit/insert.gif" border="0" /></button>
						<button class="metadata_field_reload" title="<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.reload"/>"><img src="<%= request.getContextPath() %>/extension/input-forms-edit/reload.gif" border="0" /></button>
						<%-- (新增欄位) --%>
					</div>
				</th>
				<td valign="top" class="data-metadata">
					<table>
						<thead>
							<tr>
								<th class="data-schema-label">
									<fmt:message key="jsp.dspace-admin.list-metadata-fields.schema"/>
									<%-- schema --%>
								</th>
								<th class="data-element-label">
									<fmt:message key="jsp.dspace-admin.list-metadata-fields.element"/>
									<%-- element --%>
								</th>
								<th class="data-qualifier-label">
									<fmt:message key="jsp.dspace-admin.list-metadata-fields.qualifier"/>
									<%-- qualifier --%>
								</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td class="data-schema-container"></td>
								<td class="data-element-container"></td>
								<td class="data-qualifier-container"></td>
							</tr>
						</tbody>
					</table>
				</td>
			</tr>
			-->
			<tr>
				<th>
					<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.label"/>
					<%-- 標籤 --%>
				</th>
				<td valign="top"><input type="text" class="data-label" /></td>
			</tr>
			<tr>
				<th>
					<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.hint"/>
					<%-- 提示 --%>
				</th>
				<td valign="top"><textarea class="data-hint fckeditor"></textarea></td>
			</tr>
			<tr>
				<th class="th">
					<fmt:message key="jsp.tools.edit-item-form.edit-metadata-title"/>
					<%-- 欄位 --%>
				</th>
				<td>
					<input type="hidden" class="data-schema" />
					<input type="hidden" class="data-element" />
					<input type="hidden" class="data-qualifier" />
					<%-- <button type="button" class="field-select" title="請選擇欄位">請選擇欄位</button> --%>
					<button type="button" class="field-select" title="<fmt:message key="jsp.tools.edit-item-form.select-metadata-note"/>"><fmt:message key="jsp.tools.edit-item-form.select-metadata-note"/></button>
				</td>
			</tr>
			<tr>
				<th>
					<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.requeired"/>
					<%-- 必填訊息 --%>
				</th>
				<td valign="top">
					<input type="radio" name="required" class="required-false" checked="checked" onclick="jQuery(this).nextAll('input.data-required:first').attr('disabled','disabled');" />
						<label onclick="jQuery(this).prevAll('input.required-false').click()" >
							<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.requeired-false"/>
							<%-- 不限制必填 --%>
						</label>
					<br />
					<input type="radio" name="required" class="required-true" onclick="jQuery(this).nextAll('input.data-required:first').removeAttr('disabled');jQuery(this).nextAll('input.data-required:first').select()" />
					<label onclick="jQuery(this).prevAll('input.required-true').click()" >
						<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.requeired-true"/>
						<%-- 提示訊息：--%>
					</label>
					<input type="text" class="data-required" disabled="disabled" />
				</td>
			</tr>
			<tr>
				<th>
					<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.repeatable"/>
					<%-- 是否可重複？ --%>
				</th>
				<td>
					<input type="radio" name="repeatable" id="repeatable_true" class="data-repeatable-true" /><label for="repeatable_true">
						<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.repeatable-true"/>
						<%-- 是 --%>
					</label>
					<input type="radio" name="repeatable" id="repeatable_false" class="data-repeatable-false" checked="checked" /><label for="repeatable_false">
						<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.repeatable-false"/>
						<%-- 否 --%>
					</label>
				</td>
			</tr>
			<tr>
				<th>
					<fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type"/>
					<%-- 輸入型態 --%>
				</th>
				<td>
					<select class="data-input-type">
						<option value="onebox"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.onebox"/></option>
						<option value="twobox"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.twobox"/></option>
						<option value="textarea"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.textarea"/></option>
						<option value="texteditor"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.texteditor"/></option>
						<option value="date"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.date"/></option>
						<option value="name"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.name"/></option>
						<option value="series"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.series"/></option>
						<option value="dropdown"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.dropdown"/></option>
						<option value="list"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.list"/></option>
						<option value="qualdrop_value"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.qualdrop_value"/></option>
						<option value="fileupload"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.fileupload"/></option>
						<option value="xmlmetadata"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.xmlmetadata"/></option>
						<%-- <option value="item">item</option> --%>
						<option value="taiwanaddress"><fmt:message key="jsp.dspace-admin.input-forms-edit.edit-field.metadata.input-type.taiwanaddress"/></option>
					</select>
				</td>
			</tr>
			<tr class="tr-value-pairs" style="display:none;">
				<th>
					<fmt:message key="jsp.dspace-admin.input-forms-edit.pair-value"/>
					<%-- 資料列表 --%>
				</th>
				<td>
					<table border="0">
						<thead>
							<tr>
								<th width="170">
									<fmt:message key="jsp.dspace-admin.input-forms-edit.pair-value.display"/>
									<%-- 顯示名稱 --%>
								</th>
								<th width="170">
									<fmt:message key="jsp.dspace-admin.input-forms-edit.pair-value.stored"/>
									<%-- 儲存資料 --%>
								</th>
								<th class="function">&nbsp;</th>
							</tr>
						</thead>
					</table>
					<div class="value-pairs-wrapper" style="max-height: 250px; overflow: auto; overflow-x:visible;">
					<table border="0">
						<tbody class="data-value-pairs">
							<tr style="display:none;" class="data-value-pairs-template">
								<td width="170"><input type="text" class="data-displayed" /></td>
								<td width="170"><input type="text" class="data-stored" /></td>
								<td class="function">
									<button type="button" class="data-value-pairs-del">
										<img src="<%= request.getContextPath() %>/extension/input-forms-edit/delete.gif" border="0" />
										<%--fmt:message key="jsp.dspace-admin.general.delete"/--%>
										<%-- 刪除 --%>
									</button>
									<button type="button" class="data-value-pairs-moveup">
										<%--fmt:message key="jsp.dspace-admin.input-forms-edit-js.field-move-up"/--%>
										<img src="<%= request.getContextPath() %>/extension/input-forms-edit/arrow_up.gif" border="0" />
										<%-- ↑ --%>
									</button>
									<button type="button" class="data-value-pairs-movedown">
										<%--fmt:message key="jsp.dspace-admin.input-forms-edit-js.field-move-down"/--%>
										<img src="<%= request.getContextPath() %>/extension/input-forms-edit/arrow_down.gif" border="0" />
										<%-- ↓ --%>
									</button>
								</td>
							</tr>
						</tbody>
						<tfoot>
							<tr>
								<th colspan="3">
									
								</th>
							</tr>
						</tfoot>
					</table>
					</div>
					<div style="text-align:center;">
						<button type="button" class="data-value-pairs-add">
							<fmt:message key="jsp.dspace-admin.general.addnew"/>
							<%-- 新增 --%>
						</button>
					</div>
				</td>
			</tr>
			<tr class="tr-default-value" style="display:none;">
				<th>
					<fmt:message key="jsp.dspace-admin.input-forms-edit.default-value"/>
					<%-- 節點 --%>
				</th>
				<td>
					<button type="button" class="edit-default-value">
						<fmt:message key="jsp.dspace-admin.general.edit"/>
						<%-- 編輯 --%>
					</button>
					<textarea class="data-default-value" style="display:none"></textarea>
				</td>
			</tr>
		</tbody>
	</table>
</div>

<div id="prompt_xmlmetadata_editor" title="<fmt:message key="jsp.dspace-admin.input-forms-edit.xmlmetadata.title"/>">
<%-- <div id="prompt_xmlmetadata_editor" title="XMLMetadata編輯器"> --%>
	<textarea class="xmlmetadata-source source" style="display:none;"></textarea>
</div>

<%-- <div id="prompt_field_add" style="display:none;" title="新增欄位"> --%>
<div id="prompt_field_add" style="display:none;" title="<fmt:message key="jsp.dspace-admin.input-forms-edit.prompt_field_add"/>">
	
<%-- <div id="prompt_field_add" title="新增欄位"> --%>
	<table cellpadding="5">
		<thead>
			<tr>
				<th class="data-schema-label">
					<fmt:message key="jsp.dspace-admin.list-metadata-fields.schema"/>
					<%-- schema --%>
				</th>
				<th class="data-element-label">
					<fmt:message key="jsp.dspace-admin.list-metadata-fields.element"/>
					<%-- element --%>
				</th>
				<th class="data-qualifier-label">
					<fmt:message key="jsp.dspace-admin.list-metadata-fields.qualifier"/>
					<%-- qualifier --%>
				</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td class="data-schema-container"><input type="text" class="text schema" /></td>
				<td class="data-element-container"><input type="text" class="text element" /></td>
				<td class="data-qualifier-container"><input type="text" class="text qualifier" /></td>
			</tr>
			<tr>
				<td class="data-scope-note" colspan="3">
					<input type="text" class="text scope-note" style="width: 80%;float:right;" />
					<%-- 範圍註 --%>
					<fmt:message key="jsp.dspace-admin.list-metadata-fields.scope"/>
				</td>
			</tr>
		</tbody>
	</table>
</div>

<div id="prompt_metadata_field_selector" style="display:none;overflow:hidden;" 
	<%-- title="選擇元資料"> --%>
	title="<fmt:message key="jsp.dspace-admin.input-forms-edit.select-metadata-note"/>">
	<table cellpadding="5" width="100%">
		<thead>
			<tr>
				<td>
					<button type="button" class="metadata-add" style="float:right;">
						<%-- 元資料登記 --%>
						<fmt:message key="jsp.layout.navbar-admin.metadataregistry"/>
					</button>
					<label for="schema_selector">
						<%-- 格式: --%>
						<fmt:message key="jsp.dspace-admin.input-forms-edit.metadata.schema-heading"/>
					</label>
					<select id="schema_selector" class="schema-selector"></select>
					<input type="hidden" class="data-schema" />
					<input type="hidden" class="data-element" />
					<input type="hidden" class="data-qualifier" />
				</td>
			</tr>
		</thead>
		<tbody>
			<tr class="field-selector">
				<td>
					<div class="field-selector-wrapper">
					<table width="100%" cellspacing="0" cellpadding="0">
						<tbody class="field-selector">
						</tbody>
					</table>
					</div>
				</td>
			</tr>
			<tr class="field-add" style="display:none;">
				<td class="field-add">
					<table width="100%">
						<caption><%-- 元資料登記 --%>
						<fmt:message key="jsp.layout.navbar-admin.metadataregistry"/></caption>
						<tbody>
							<tr>
								<th><fmt:message key="jsp.dspace-admin.list-metadata-fields.schema"/></th>
								<td><input type="text" class="schema" /></td>
							</tr>
							<tr>
								<th><fmt:message key="jsp.dspace-admin.list-metadata-schemas.namespace"/></th>
								<td><input type="text" class="namespace" /></td>
							</tr>
							<tr>
								<th><fmt:message key="jsp.dspace-admin.list-metadata-fields.element"/></th>
								<td><input type="text" class="element" /></td>
							</tr>
							<tr>
								<th><fmt:message key="jsp.dspace-admin.list-metadata-fields.qualifier"/></th>
								<td><input type="text" class="qualifier" /></td>
							</tr>
							<tr>
								<th><fmt:message key="jsp.dspace-admin.list-metadata-fields.scope"/></th>
								<td><textarea class="note" width="100%"></textarea></td>
							</tr>
						</tbody>
					</table>
				</td>
			</tr>
		</tbody>
	</table>
</div>

<textarea id="inputFormsTemplate_header" class="inputFormsTemplate" style="display:none;"><?xml version="1.0"?>
<!DOCTYPE input-forms SYSTEM "input-forms.dtd">


<input-forms>

 <!-- The form-map maps collection handles to forms. DSpace does not       -->
 <!-- require that a collection's name be unique, even within a community .-->
 <!-- DSpace does however insure that each collection's handle is unique.  -->
 <!-- Form-map provides the means to associate a unique collection name    -->
 <!-- with a form. The form-map also provides the special handle "default" -->
 <!-- (which is never a collection), here mapped to "traditional". Any     -->
 <!-- collection which does not appear in this map will be associated with -->
 <!-- the mapping for handle "default".                                    -->

	<form-map>
</textarea>
<textarea id="inputFormsTemplate_formDefinitionsHelp" class="inputFormsTemplate">
	</form-map>


 <!-- The form-definitions map lays out the detailed definition of all the -->
 <!-- submission forms.Each separate form set has a unique name as an      -->
 <!-- attribute. This name matches one of the names in the form-map. One   -->
 <!-- named form set has the name "traditional"; as this name suggests,    -->
 <!-- it is the old style and is also the default, which gets used when    -->
 <!-- the specified collection has no correspondingly named form set.      -->
 <!--                                                                      -->
 <!-- Each form set contains an ordered set of pages; each page defines    -->
 <!-- one submission metadata entry screen. Each page has an ordered list  -->
 <!-- of field definitions, Each field definition corresponds to one       -->
 <!-- metatdata entry (a so-called row), which has a DC element name, a    -->
 <!-- displayed label, a text string prompt which is called a hint , and   -->
 <!-- an input-type. Each field also may hold optional elements: DC        -->
 <!-- qualifier name, a repeatable flag, and a text string whose presence  -->
 <!-- serves as a 'this field is required' flag.                           -->

	<form-definitions>

 </textarea>
<textarea id="inputFormsTemplate_formValuePairsHelp" class="inputFormsTemplate">
	</form-definitions>


 <!-- form-value-pairs populate dropdown and qualdrop-value lists.          -->
 <!-- The form-value-pairs element holds child elements named 'value-pairs' -->
 <!-- A 'value-pairs' element has a value-pairs-name and a dc-term          -->
 <!-- attribute. The dc-term attribute specifies which to which Dublin Core -->
 <!-- Term this set of value-pairs applies.                                 -->
 <!--     Current dc-terms are: identifier-pairs, type-pairs, and           -->
 <!--     language_iso-pairs. The name attribute matches a name             -->
 <!--     in the form-map, above.                                           -->
 <!-- A value-pair contains one 'pair' for each value displayed in the list -->
 <!-- Each pair contains a 'displayed-value' element and a 'stored-value'   -->
 <!-- element. A UI list displays the displayed-values, but the program     -->
 <!-- stores the associated stored-values in the database.                  -->

	<form-value-pairs>
</textarea>
<textarea id="inputFormsTemplate_footer" class="inputFormsTemplate">
	</form-value-pairs>

</input-forms></textarea>

</dspace:layout>