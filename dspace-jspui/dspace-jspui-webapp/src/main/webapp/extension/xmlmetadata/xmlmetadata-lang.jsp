<%--
	xmlmetadata-lang.jsp
	2009.05.29 布丁
	
	原本的檔案是用JavaScript來作的，可是一些參數必需要用手寫，比較不方便。是故現在改成以JSP的方式讀取參數。
	主要是讓DSpace的語系檔進去。

jsp.extension.xmlmetadata.check-required = \u60a8\u6709\u8868\u55ae\u5c1a\u672a\u586b\u5beb\u5b8c\u6210\uff0c\u662f\u5426\u8981\u7e7c\u7e8c\uff1f
jsp.extension.xmlmetadata.date-picker = \u8acb\u9ede\u6b64\u9078\u64c7\u65e5\u671f
jsp.extension.xmlmetadata.delete-confirm = \u78ba\u5b9a\u8981\u522a\u9664\uff1f
jsp.extension.xmlmetadata.not-has-multiple-files = \u5fc5\u9808\u70ba\u300c\u6587\u4ef6\u7531\u4e00\u500b\u4ee5\u4e0a\u7684 \u6a94\u6848\u6240\u7d44\u6210\u300d\uff01
jsp.extension.xmlmetadata.required-tip = \uff0a\uff1a\u8868\u793a\u5fc5\u9808\u586b\u5beb
jsp.extension.xmlmetadata.input-required-tip = \u5fc5\u9808\u586b\u5beb
jsp.extension.xmlmetadata.button-insert =\u63d2\u5165
jsp.extension.xmlmetadata.button-move-up =\u4e0a\u79fb
jsp.extension.xmlmetadata.button-move-down =\u4e0b\u79fb
jsp.extension.xmlmetadata.alert-title =\u7cfb\u7d71\u8a0a\u606f
jsp.extension.xmlmetadata.close =\u95dc\u9589
jsp.extension.xmlmetadata.view =\u6aa2\u8996
jsp.extension.xmlmetadata.alert-now-saving =\u73fe\u5728\u6b63\u5728\u5132\u5b58\u4e2d\uff0c\u8acb\u7a0d\u5019\u3002
jsp.extension.xmlmetadata.alert-message-display-form =\u6b63\u5728\u8a2d\u5b9a\u8868\u55ae\uff0c\u8acb\u7a0d\u5019\u3002
jsp.extension.xmlmetadata.alert-message-display-table =\u6b63\u5728\u7e6a\u88fd\u7db2\u9801\uff0c\u8acb\u7a0d\u5019\u3002
--%>
<%@ page contentType="application/x-javascript; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
	XMLMETADATA_LANG = {
		<%-- "CheckRequired": "您有表單尚未填寫完成，是否要繼續？", --%>
		"CheckRequired": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.check-required") %>",
		<%-- "FormRequiredFlag": "form-required-check", --%>
		"FormRequiredFlag": "form-required-check",
		<%-- "DataPicker": "請點此選擇日期", --%>
		"DataPicker": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.date-picker") %>",
		<%-- "ButtonRepeat": "重複", --%>
		"ButtonRepeat": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.edit-metadata.button.add") %>",
		<%-- "ButtonDel": "刪除", --%>
		"ButtonDel": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.remove") %>",
		<%-- "DelConfirm": "確定要刪除？", --%>
		"DelConfirm": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.delete-confirm") %>",
		<%-- "RequireTip": "*：表示必須填寫", --%>
		"RequireTip": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.required-tip") %>",
		<%-- "NotHasMultipleFiles": "Please check \"文件由一個以上的 檔案所組成\"! ", --%>
		"NotHasMultipleFiles": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.not-has-multiple-files") %>",
		<%-- "InputRequiredTip": "必須填寫" --%>
		"InputRequiredTip": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.input-required-tip") %>",
		<%-- "ButtonInsert": "插入", --%>
		"ButtonInsert": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.button-insert") %>",
		<%-- "ButtonMoveUp": "上移", --%>
		"ButtonMoveUp": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.button-move-up") %>",
		<%-- "ButtonMoveDown": "下移", --%>
		"ButtonMoveDown": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.button-move-down") %>",
		<%-- "AlertTitle": "系統訊息", --%>
		"AlertTitle": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.alert-title") %>",
		<%-- "AlertMessageDisplayForm": "正在設定表單，請稍候。", --%>
		"AlertMessageDisplayForm": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.alert-message-display-form") %>",
		<%-- "AlertMessageDisplayTable": "正在繪製網頁，請稍候。" --%>
		"AlertMessageDisplayTable": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.alert-message-display-table") %>",
		<%-- 關閉 --%>
		"Close": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.close") %>",
		<%-- 檢視 --%>
		"View": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.view") %>",
		<%-- 現在正在儲存中 --%>
		"AlertNowSaving": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.xmlmetadata.alert-now-saving") %>"
	};
function getXMLMetadataLang()
{
	return XMLMETADATA_LANG;
}