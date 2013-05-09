<%--
	input-forms-lang.jsp
	
語系檔備份：
jsp.dspace-admin.input-forms-edit-js.update-confirm = \u78ba\u5b9a\u66f4\u65b0\uff1f\u6b64\u52d5\u4f5c\u7121\u6cd5\u5fa9\u539f
jsp.dspace-admin.input-forms-edit-js.form-mode = \u8868\u55ae\u9810\u89bd\u6a21\u5f0f
jsp.dspace-admin.input-forms-edit-js.code-mode = \u7a0b\u5f0f\u78bc\u6a21\u5f0f
jsp.dspace-admin.input-forms-edit-js.reload = \u91cd\u65b0\u8b80\u53d6
jsp.dspace-admin.input-forms-edit-js.description = \u6558\u8ff0
jsp.dspace-admin.input-forms-edit-js.not-null = \u203b\u4e0d\u80fd\u662f\u7a7a\u503c
jsp.dspace-admin.input-forms-edit-js.only-english = \u203b\u53ea\u80fd\u662f\u82f1\u6587\u3001\u6578\u5b57\u3001\u5e95\u7dda\u3001\u6a6b\u7dda\u8207\u9ede
jsp.dspace-admin.input-forms-edit-js.form-heading = \u60a8\u6b63\u5728\u7de8\u8f2f
jsp.dspace-admin.input-forms-edit-js.rename = \u66f4\u540d
jsp.dspace-admin.input-forms-edit-js.delete-confirm = \u78ba\u5b9a\u8981\u522a\u9664\uff1f
jsp.dspace-admin.input-forms-edit-js.handle-editor.heading = \u8acb\u8a2d\u5b9a\u5957\u7528\u6b64form\u7684collection-handle
jsp.dspace-admin.input-forms-edit-js.handle-editor.delete-confirm = \u6b04\u4f4d\u88e1\u9762\u9084\u6709\u503c\uff0c\u78ba\u5b9a\u8981\u522a\u9664\uff1f
jsp.dspace-admin.input-forms-edit-js.page-editor.must-has-page = \u6700\u5c11\u8981\u6709\u4e00\u9801\uff01
jsp.dspace-admin.input-forms-edit-js.page-editor.delete-confirm = \u78ba\u5b9a\u8981\u522a\u9664\u6b64\u9801\uff1f\u6b64\u52d5\u4f5c\u7121\u6cd5\u5fa9\u539f
jsp.dspace-admin.input-forms-edit-js.form-collection.move-up = \u4e0a\u79fb
jsp.dspace-admin.input-forms-edit-js.form-collection.move-down = \u4e0b\u79fb
jsp.dspace-admin.input-forms-edit-js.field-move-\u2191up = \u2191
jsp.dspace-admin.input-forms-edit-js.field-move-down = \u2193
jsp.dspace-admin.input-forms-edit-js.do-item-button.priview-limit = \u9810\u89bd\u4e2d\u4e0d\u6703\u6709\u6548\u679c

jsp.dspace-admin.general.accept = \u78ba\u5b9a
jsp.dspace-admin.general.insert = \u63d2\u5165
jsp.dspace-admin.general.copy = \u8907\u88fd
jsp.dspace-admin.general.repeat = \u91cd\u8907
	
--%>
<%@ page contentType="application/x-javascript; charset=utf-8" language="java" errorPage="" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.content.DCDate" %>
<%@ page import="org.dspace.core.I18nUtil" %>
function getInputFormsEditorLang()
{
	
var InputFormsEditorLang = {
	InputFormsParser: {
		//Update: "更新",
		Update: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.save") %>",
		//UpdateConfirm: "確定更新？此動作無法復原",
		UpdateConfirm: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.update-confirm") %>",
		EditorMode: {
			//FormMode: "表單預覽模式",
			FormMode: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.form-mode") %>",
			//CodeMode: "程式碼模式"
			CodeMode: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.code-mode") %>"
		},
		//Save: "儲存",
		Save: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.save") %>",
		//Reload: "重新讀取",
		Reload: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.reload") %>",
		Label: {
			//"Description": "敘述"
			"Description": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.description") %>"
		},
		Hint: {
			//"NotNull": "※不能是空值",
			"NotNull": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.not-null") %>",
			//"OnlyEnglish": "※只能是英文、數字、底線、橫線與點"
			"OnlyEnglish": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.only-english") %>",
			//"CreateFormConfirm": "您使用的是預設的traditional表單，是否要為此類別指定新的表單呢？"
			"CreateFormConfirm": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.create-form-confirm") %>"
		},
		//FormHeading: "您正在編輯",
		FormHeading: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.form-heading") %>",
		"Button": {
			//"Rename": "更名",
			"Rename": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.rename") %>",
			"RenameImg": "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/edit.gif\" border=\"0\" />",
			//"Edit": "編輯"
			"Edit": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.edit") %>",
			"EditImg": "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/edit.gif\" border=\"0\" />"
		},
		//Delete: "刪除",
		Delete: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.delete") %>",
		DeleteImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/delete.gif\" border=\"0\" />",
		//DeleteConfirm: "確定要刪除？",
		DeleteConfirm: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.delete-confirm") %>",
		//Add: "新增"
		Add: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.addnew") %>",
		AddImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/insert.gif\" border=\"0\" />"
	},
	"FormCollectionObject": {
		HandleEditor: {
			//Heading: "請設定套用此form的collection-handle",
			Heading: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.handle-editor.heading") %>",
			//DeleteConfirm: "欄位裡面還有值，確定要刪除？"
			DeleteConfirm: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.handle-editor.delete-confirm") %>"
		},
		//Delete: "刪除",
		Delete: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.delete") %>",
		DeleteImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/delete.gif\" border=\"0\" />",
		//Add: "新增",
		Add: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.addnew") %>",
		AddImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/insert.gif\" border=\"0\" />",
		PageEditor: {
			//"MustHasPage": "最少要有一頁！",
			"MustHasPage": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.page-editor.must-has-page") %>",
			//"DeleteConfirm": "確定要刪除此頁？此動作無法復原"
			"DeleteConfirm": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.page-editor.delete-confirm") %>"
		},
		//Insert: "插入",
		Insert: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.insert") %>",
		InsertImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/insert.gif\" border=\"0\" />",
		Move: {
			//Up: "上移",
			Up: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.form-collection.move-up") %>",
			UpImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/arrow_up.gif\" border=\"0\" />",
			//Down: "下移"
			Down: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.form-collection.move-down") %>",
			DownImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/arrow_down.gif\" border=\"0\" />"
		},
		Button: {
			//Edit: "編輯"
			Edit: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.edit") %>",
			"EditImg": "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/edit.gif\" border=\"0\" />"
		},
		//OnlyDefault: "只有traditional表單可以使用「default」類別控制碼"
		OnlyDefault: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.form-collection.only-default") %>"
	},
	"FieldObject": {
		Button: {
			//"Edit": "編輯",
			"Edit": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.edit") %>",
			"EditImg": "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/edit.gif\" border=\"0\" />",
			//"Copy": "複製",
			"Copy": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.copy") %>",
			"CopyImg": "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/copy.gif\" border=\"0\" />",
			//"Repeat": "重複"
			"Repeat": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.add") %>",
			"RepeatImg": "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/insert.gif\" border=\"0\" />"
		},
		//Delete: "刪除",
		Delete: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.delete") %>",
		DeleteImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/delete.gif\" border=\"0\" />",
		//DeleteConfirm: "您確定要刪除？",
		DeleteConfirm: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.delete-confirm") %>",
		//Insert: "插入",
		Insert: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.insert") %>",
		InsertImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/insert.gif\" border=\"0\" />",
		FieldMove: {
			//Up: "↑",
			Up: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.field-move-up") %>",
			UpImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/arrow_up.gif\" border=\"0\" />",
			//Down: "↓"
			Down: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.field-move-down") %>",
			DownImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/arrow_down.gif\" border=\"0\" />",
			Left: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.field-move-left") %>",
			LeftImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/arrow_left.gif\" border=\"0\" />",
			Right: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.field-move-right") %>",
			RightImg: "<img src=\"<%= request.getContextPath() %>/extension/input-forms-edit/arrow_right.gif\" border=\"0\" />"
		},
		DateInput: {
			Tip: {
				//Day: "日期：",
				Day: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.day") %>",
				//Month: "月份：",
				Month: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.month") %>",
				//Year: "年："
				Year: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.year") %>"
			},
			Months: {
				//Null: "（沒有月份）",
				Null: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.no_month") %>",
				//Jan: "一月",
				Jan: "<%= DCDate.getMonthName(1,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//Feb: "二月",
				Feb: "<%= DCDate.getMonthName(2,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//Mar: "三月",
				Mar: "<%= DCDate.getMonthName(3,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//Apr: "四月",
				Apr: "<%= DCDate.getMonthName(4,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//May: "五月",
				May: "<%= DCDate.getMonthName(5,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//Jun: "六月",
				Jun: "<%= DCDate.getMonthName(6,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//Jul: "七月",
				Jul: "<%= DCDate.getMonthName(7,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//Aug: "八月",
				Aug: "<%= DCDate.getMonthName(8,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//Sep: "九月",
				Sep: "<%= DCDate.getMonthName(9,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//Oct: "十月",
				Oct: "<%= DCDate.getMonthName(10,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//Nov: "十一月",
				Nov: "<%= DCDate.getMonthName(11,I18nUtil.getSupportedLocale(request.getLocale())) %>",
				//Dec: "十二月"
				Dec: "<%= DCDate.getMonthName(12,I18nUtil.getSupportedLocale(request.getLocale())) %>"
			}
		},
		NameInput: {
			//LastName: "姓氏 例如",
			LastName: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.lastname") %>",
			//FirstName: "名字(s) + \"Jr\" 例如"
			FirstName: '<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.firstname") %>'
		},
		SeriesInput: {
			//Series: "叢集名",
			Series: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.seriesname") %>",
			//Number: "報告或論文編號"
			Number: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.paperno") %>"
		}
	},
	PageObject: {
		Label: {
			//Description: "敘述"
			Description: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.description") %>"
		}
	},
	PromptDialog: {
		//Cancel: "取消",
		Cancel: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.cancel") %>",
		//Accept: "確定",
		Accept: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.accept") %>",
		//DeleteConfirm: "您確定要刪除嗎？"
		DeleteConfirm: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.delete-confirm") %>",
		MetadataFieldSelector: {
			//schemaAndNamespace: "格式 - 名稱空間",
			//require: "此欄必填",
			//addFieldException: "新增欄位時發生錯誤：",
			//metadataRegister: "元資料登記",
			//metadataSelect: "元資料選擇"
			schemaAndNamespace: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.schemaAndNamespace") %>",
			require: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.require") %>",
			addFieldException: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.addFieldException") %>",
			metadataRegister: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.layout.navbar-admin.metadataregistry") %>",
			metadataSelect: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.metadataSelect") %>"
		},
		//WaitMessage: "請稍候"
		WaitMessage: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.WaitMessage") %>",
		FieldEditor: {
			//fieldNullDelete: "此欄沒有設定，將自動刪除",
			//fieldUnavailable1: "後設資料",
			//fieldUnavailable2: "已經被其他欄位使用，請選用其他後設資料",
			//labelRequire: "必須填寫標籤！",
			//valuePairRequire1: "輸入型態",
			//valuePairRequire2: "必需要有資料列表",
			//qualdrop_value_note1: "輸入型態",
			//qualdrop_value_note2: "的後設資料中修飾語必須空白",
			//qualdrop_value_match1: "輸入型態",
			//qualdrop_value_match2: "的資料列表中儲存資料必須對應到後設資料",
			//qualdrop_value_match3: "下的修飾語，請問是否要由系統自動重整？"
			fieldNullDelete: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.fieldNullDelete") %>",
			fieldUnavailable1: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.fieldUnavailable1") %>",
			fieldUnavailable2: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.fieldUnavailable2") %>",
			labelRequire: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.labelRequire") %>",
			valuePairRequire1: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.valuePairRequire1") %>",
			valuePairRequire2: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.valuePairRequire2") %>",
			qualdrop_value_note1: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.qualdrop_value_note1") %>",
			qualdrop_value_note2: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.qualdrop_value_note2") %>",
			qualdrop_value_match1: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.qualdrop_value_match1") %>",
			qualdrop_value_match2: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.qualdrop_value_match2") %>",
			qualdrop_value_match3: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.qualdrop_value_match3") %>"
		},
		FieldAdd: {
			//exception: "發生錯誤。錯誤訊息: ",
			//schemaAndElementRequire: "請填寫格式及元素！"
			exception: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.prompt.exception") %>",
			schemaAndElementRequire: "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.prompt.schemaAndElementRequire") %>"
		}
	},
	doItemButton: {
		"Button": {
			//"Edit": "編輯"
			"Edit": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.edit") %>"
		},
		"Hint": {
			//"PreviewLimit": "預覽中不會有效果"
			"PreviewLimit": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.input-forms-edit-js.do-item-button.priview-limit") %>"
		}
	}
};
	return InputFormsEditorLang;
}	//function

InputFormsEditorLang = getInputFormsEditorLang();
	
<%-- 
//	if (typeof(InputFomrsEditorLang) != "undefined")
//		LANG = InputFomrsEditorLang.InputFormsParser;
--%>