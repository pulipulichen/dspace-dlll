<%--
	config-lang.jsp
--%>
<%@ page contentType="application/x-javascript; charset=utf-8" language="java" errorPage="" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%!
	public String lm (PageContext pageContext, String key)
	{
		return LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.config-edit.js." + key);
	}
%>
<%
	PageContext pg = pageContext;
%>
ConfigLang = {
	form: {
		dialog: {
			<%-- title: "系統訊息", --%>
			title: "<%= lm(pg, "dialog.title") %>",
			<%-- message: "系統處理中，請稍候。" --%>
			message: "<%= lm(pg, "dailog.message") %>"
		},
		button: {
			<%-- moveUp: "上移", --%>
			moveUp: "<%= lm(pg, "button.move-up") %>",
			moveUpImg: "<%= request.getContextPath() %>/extension/input-forms-edit/arrow_up.gif",
			<%-- moveDown: "下移", --%>
			moveDown: "<%= lm(pg, "button.move-down") %>",
			moveDownImg: "<%= request.getContextPath() %>/extension/input-forms-edit/arrow_down.gif",
			<%-- insert: "插入", --%>
			insert: "<%= lm(pg, "button.insert") %>",
			insertImg: "<%= request.getContextPath() %>/extension/input-forms-edit/insert.gif",
			<%-- delete: "刪除", --%>
			doDelete: "<%= lm(pg, "button.delete") %>",
			doDeleteImg: "<%= request.getContextPath() %>/extension/input-forms-edit/delete.gif",
			<%-- add: "新增" --%>
			add: "<%= lm(pg, "button.add") %>"
		},
		header: {
			<%-- fieldName: "欄位代號", --%>
			fieldName: "<%= lm(pg, "header.filed-name") %>",
			<%-- indexName: "索引名稱", --%>
			indexName: "<%= lm(pg, "header.index-name") %>",
			<%-- optionName: "選項名稱", --%>
			optionName: "<%= lm(pg, "header.option-name") %>",
			<%-- type: "類別", --%>
			type: "<%= lm(pg, "header.type") %>",
			<%-- order: "排序", --%>
			order: "<%= lm(pg, "header.order") %>",
			<%-- metadata: "後設資料欄位", --%>
			metadata: "<%= lm(pg, "header.metadata") %>",
			<%-- datatype: "資料類型", --%>
			datatype: "<%= lm(pg, "header.datatype") %>",
			<%-- width: "寬度", --%>
			width: "<%= lm(pg, "header.width") %>",
			<%-- display: "顯示" --%>
			display: "<%= lm(pg, "header.display") %>"
		},
		select: {
			<%-- text: "文字", --%>
			text: "<%= lm(pg, "select.text") %>",
			<%-- date: "日期", --%>
			date: "<%= lm(pg, "select.date") %>",
			<%-- link: "超連結", --%>
			link: "<%= lm(pg, "select.link") %>",
			<%-- title: "標題連結", --%>
			title: "<%= lm(pg, "select.title") %>",
			<%-- other: "其他...",  --%>
			other: "<%= lm(pg, "select.other") %>",
			<%-- asc: "遞增", --%>
			asc: "<%= lm(pg, "select.asc") %>",
			<%-- desc: "遞減", --%>
			desc: "<%= lm(pg, "select.desc") %>",
			<%-- metadata: "後設資料", --%>
			metadata: "<%= lm(pg, "select.metadata") %>",
			<%-- item: "排序選項", --%>
			item: "<%= lm(pg, "select.item") %>",
			<%-- limit: "摘要", --%>
			limit: "<%= lm(pg, "select.limit") %>",
			<%-- any: "任意", --%>
			any: "<%= lm(pg, "select.any") %>",
			<%-- px: "像素", --%>
			px: "<%= lm(pg, "select.px") %>",
			<%-- percent: "百分比", --%>
			percent: "<%= lm(pg, "select.percent") %>",
			<%-- show: "顯示", --%>
			show: "<%= lm(pg, "select.show") %>",
			<%-- hide: "隱藏" --%>
			hide: "<%= lm(pg, "select.hide") %>"
		},
		label: {
			<%-- anyField: "任意欄位", --%>
			anyField: "<%= lm(pg, "label.any-field") %>",
			<%-- show: "顯示", --%>
			show: "<%= lm(pg, "label.show") %>",
			<%-- metadata: "後設資料欄位: ", --%>
			metadata: "<%= lm(pg, "label.metadata") %> ",
			<%-- datatype: "資料類型: ", --%>
			datatype: "<%= lm(pg, "label.datatype") %> ",
			<%-- option: "選項名稱: ", --%>
			option: "<%= lm(pg, "label.option") %> ",
			<%-- thumbnail: "縮圖", --%>
			thumbnail: "<%= lm(pg, "label.thumbnail") %>",
			<%-- limit: "字數限制: " --%>
			limit: "<%= lm(pg, "label.limit") %> "
		},
		<%-- deleteConfirm: "您確定要刪除？" --%>
		deleteConfirm: "<%= lm(pg, "delete-confirm") %>",
		submitConfirm: "<%= lm(pg, "save-confirm") %>"
	}
};