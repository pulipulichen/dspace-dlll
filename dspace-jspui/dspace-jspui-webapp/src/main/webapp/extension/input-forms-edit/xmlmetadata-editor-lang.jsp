<%--
	xmlmetadata-editor-lang.jsp
--%>
<%@ page contentType="application/x-javascript; charset=utf-8" language="java" errorPage="" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%--
jsp.dspace-admin.general.true = \u662f
jsp.dspace-admin.general.false = \u5426

jsp.dspace-admin.xmlmetadata-editor.editor-header-list = \u6e05\u55ae
jsp.dspace-admin.xmlmetadata-editor.editor-header-attr = \u5167\u5bb9
jsp.dspace-admin.xmlmetadata-editor.editor-attr-default = \u8acb\u9ede\u9078\u5de6\u65b9\u6e05\u55ae\u5217\u8868\uff0c\u9078\u64c7\u8981\u7de8\u8f2f\u7684\u7bc0\u9ede\u3002
jsp.dspace-admin.xmlmetadata-editor.root-cannot-delete = \u6839\u7bc0\u9ede\u7121\u6cd5\u522a\u9664
jsp.dspace-admin.xmlmetadata-editor.delete-node-confirm = \u78ba\u5b9a\u8981\u522a\u9664\u6b64\u7bc0\u9ede\uff1f

jsp.dspace-admin.input-forms-edit-js.delete-confirm = \u78ba\u5b9a\u8981\u522a\u9664\uff1f

jsp.dspace-admin.xmlmetadata-editor.insert-input = \u63d2\u5165\u6b04\u4f4d
jsp.dspace-admin.xmlmetadata-editor.insert-node = \u63d2\u5165\u7bc0\u9ede
jsp.dspace-admin.xmlmetadata-editor.insert-node-content = \u63d2\u5165\u5167\u5bb9\u7bc0\u9ede
jsp.dspace-admin.xmlmetadata-editor.update-complete = \u66f4\u65b0\u5b8c\u6210
jsp.dspace-admin.xmlmetadata-editor.load-error = \u8b80\u53d6\u5931\u6557\uff01
jsp.dspace-admin.xmlmetadata-editor.node-content-temp-title = (\u9810\u8a2d\u5167\u5bb9\u7bc0\u9ede)
jsp.dspace-admin.xmlmetadata-editor.node-content-title = (\u8cc7\u6599\u5167\u5bb9\u7bc0\u9ede)
jsp.dspace-admin.xmlmetadata-editor.not-select = \u8acb\u5148\u9078\u64c7\u8981\u522a\u9664\u7684\u9805\u76ee
jsp.dspace-admin.xmlmetadata-editor.title-cannot-null = \u6a19\u984c\u4e0d\u53ef\u4ee5\u7a7a\u767d
jsp.dspace-admin.xmlmetadata-editor.label.title = \u6a19\u984c
jsp.dspace-admin.xmlmetadata-editor.label.repeatable = \u53ef\u91cd\u8907
jsp.dspace-admin.xmlmetadata-editor.label.required = \u5fc5\u586b
jsp.dspace-admin.xmlmetadata-editor.label.input-type = \u8f38\u5165\u985e\u578b
jsp.dspace-admin.xmlmetadata-editor.label.options = \u9078\u9805
jsp.dspace-admin.xmlmetadata-editor.label.default-value = \u9810\u8a2d\u503c
jsp.dspace-admin.xmlmetadata-editor.label.value = \u8f38\u5165\u503c
jsp.dspace-admin.xmlmetadata-editor.label.is-temp = \u9810\u8a2d\u7bc0\u9ede
jsp.dspace-admin.xmlmetadata-editor.init-error = \u8b80\u53d6\u932f\u8aa4\uff01
jsp.dspace-admin.xmlmetadata-editor.controller.label = \u7de8\u8f2f\u6a21\u5f0f\uff1a
jsp.dspace-admin.xmlmetadata-editor.controller.editor = \u7de8\u8f2f\u5668
jsp.dspace-admin.xmlmetadata-editor.controller.source = \u539f\u59cb\u78bc
--%>
// JavaScript Document
function getXMLMetadataEditorLang()
{
	var Lang = {
		Object: {
			//EditorHeaderList: "清單",
			EditorHeaderList: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.editor-header-list") %>",
			//EditorHeaderAttr: "內容",
			EditorHeaderAttr: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.editor-header-attr") %>",
			//EditorAttrDefault: "請點選左方清單列表，選擇要編輯的節點。", 
			EditorAttrDefault: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.editor-attr-default") %>", 
			//Delete: "刪除",
			Delete: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.delete") %>",
			DeleteImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/delete.gif\" border=\"0\" />",
			//RootCannotDelete: "根節點無法刪除",
			RootCannotDelete: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.root-cannot-delete") %>",
			//DeleteNodeConfirm: "確定要刪除此節點？",
			DeleteNodeConfirm: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.delete-node-confirm") %>",
			//DeleteConfirm: "確定要刪除？",
			DeleteConfirm: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.delete-confirm") %>",
			InsertImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/insert.gif\" border=\"0\" />",
			//InsertInput: "插入欄位",
			InsertInput: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.insert-input") %>",
			//InsertNode: "插入節點",
			InsertNode: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.insert-node") %>",
			//InsertNodeContent: "插入內容節點",
			InsertNodeContent: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.insert-node-content") %>",
			//MoveUp: "上移",
			MoveUp: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.form-collection.move-up") %>",
			MoveUpImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/arrow_up.gif\" border=\"0\" />",
			//MoveDown: "下移",
			MoveDown: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.form-collection.move-down") %>",
			MoveDownImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/arrow_down.gif\" border=\"0\" />",
			//Add: "新增",
			Add: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.addnew") %>",
			//Save: "儲存",
			Save: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.save") %>",
			//Reload: "重新讀取",
			Reload: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.reload") %>",
			//Update: "更新",
			Update: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.update") %>",
			//UpdateComplete: "更新完成",
			UpdateComplete: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.update-complete") %>",
			//LoadError: "讀取失敗！",
			LoadError: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.load-error") %>",
			//NodeContentTempTitle: "(預設內容節點)",
			NodeContentTempTitle: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.node-content-temp-title") %>",
			//NodeContentTitle: "(資料內容節點)",
			NodeContentTitle: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.node-content-title") %>",
			//BooleanTrue: "是",
			BooleanTrue: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.true") %>",
			//BooleanFalse: "否",
			BooleanFalse: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.false") %>",
			//NotSelect: "請先選擇要刪除的項目",
			NotSelect: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.not-select") %>",
			//TitleCannotNull: "標題不可以空白",
			TitleCannotNull: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.title-cannot-null") %>",
			//LabelTitle: "標題",
			LabelTitle: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.label.title") %>",
			//LabelRepeatable: "可重複",
			LabelRepeatable: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.label.repeatable") %>",
			//LabelRequired: "必填",
			LabelRequired: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.label.required") %>",
			//LabelInputType: "輸入類型",
			LabelInputType: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.label.input-type") %>",
			//LabelOptions: "選項",
			LabelOptions: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.label.options") %>",
			//LabelDefaultValue: "預設值",
			LabelDefaultValue: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.label.default-value") %>",
			//LabelValue: "輸入值",
			LabelValue: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.label.value") %>",
			//LabelIsTemp: "預設節點", 
			LabelIsTemp: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.label.is-temp") %>", 
			//InitError: "讀取錯誤！"
			InitError: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.init-error") %>",
			//EscapeHint: "標題不能有HTML標籤或是<跟>！系統將自動移除HTML標籤跟<與>。",
			EscapeHint: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.escape-hint") %>",
			ValuePair: {
				//display: "顯示值",
				display: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.value-pair.display") %>",
				//stored: "儲存值"
				stored: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.value-pair.store") %>"
			}
		},
		Controller: {
			//LabelMode: "編輯模式：",
			LabelMode: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.controller.label") %>",
			//LabelEditor: "編輯器",
			LabelEditor: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.controller.editor") %>",
			//LabelSource: "原始碼"
			LabelSource: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.xmlmetadata-editor.controller.source") %>"
		}
	};
	
	return Lang;
}

var XMLMetadataEditorLang = getXMLMetadataEditorLang();