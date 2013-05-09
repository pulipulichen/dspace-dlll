
var Utils = {
	"getSelectIndex": function (selectObj)
	{
		var options = selectObj.children("option");
		var selectedOption = selectObj.children("option:selected");
		var index = options.index(selectedOption);
		return index;
	},
	"initFCKEditor": function (node, denyInited)
	{
		//textarea.fck(CONFIG.FCKEditorConfig);
		if (typeof(denyInited) == "boolean" && denyInited == false)
		{
			var textarea = node.find("textarea.fckeditor");
			for (var i = 0; i < textarea.length; i++)
			{
				var t = textarea.eq(i);
				t.removeClass("inited");
				//var newTextarea = t.clone(true);
				//newTextarea.removeClass("inited")
				//	.show()
				//	.insertBefore(t);
				//if (t.next().hasClass("do-fckeditor-dialog-button"))
				//{
				t.nextAll(".do-fckeditor-dialog-button:first").remove();
				t.nextAll(".fckeditor-dialog-textpreview:first").remove();
				//}
				t.doFCKeditorDialog(false);
			}
		}
		else
		{
			var textarea = node.find("textarea.fckeditor:not(.inited)");
			textarea.doFCKeditorDialog(false);
			textarea.addClass("inited");
		}
		
		//node.css("border", "1px solid green");
		
		
		var xmlmetadatas = node.find("textarea.xmlmetadata:not(.input-type-inited)");
		//xmlmetadatas.css("border", "1px solid blue");
		//alert(xmlmetadata.length)
		//jQuery(document).ready(function () {
			for (var j = 0; j < xmlmetadatas.length; j++)
			{
				//setTimeout(function () {
					//xmlmetadatas.eq(j).css("border", "1px solid red");
					var xm = new XMLMetadata(xmlmetadatas.eq(j));
					//xm.basePath = '';
					//xm.setFCKeditorPath("fckeditor/");
					//xm.setFCKeditorStyle("body {background-color:#626262;color:white;}");
					//xm.workspaceItemID = "";
					//xm.fieldTitle = textarea.eq(i).parents("tr.field-preview:first").find(".data-label").val();
					xm.createRootForm();
					
					xmlmetadatas.eq(j).addClass("input-type-inited");
					
				//}, 1000 * (j+1));
			}
		//});
		
		//jQuery.doXMLMetadata();
		
		var taiwanaddress = node.find("input.taiwanaddress:not(.inited)");
		for (var i = 0; i < taiwanaddress.length; i++)
		{
			var ta = taiwanaddress.eq(i);
			ta.taiwanAddress();
			ta.addClass("inited");
		}
		/*
		for (var i = 0; i < taiwanaddress.length; i++)
		{
			taiwanaddress.eq().doTaiwanAddress();
			
		}
		*/
		var item = node.find("input.item:not(.inited)");
		for (var i = 0; i < item.length; i++)
		{
			var it = item.eq(i);
			it.doItemButton();
			it.addClass("inited");
		}
	},
	"getDialogRoot": function (thisBtn)
	{
		var rootNode = jQuery(thisBtn).parents("div.ui-dialog:first");
		return rootNode;
	},
	"adaptPageAttr": function (pageNode)
	{
		pageNode.find("input.page-label:first").change();
	},
	"replaceAll": function (str, reallyDo, replaceWith) {
		return str.replace(new RegExp(reallyDo, 'g'), replaceWith);
	},
	"escapeHTML": function (value)
	{
		value = Utils.unescapeHTML(value);
		
		value = Utils.replaceAll(value, "&", "&amp;");
		value = Utils.replaceAll(value, "<", "&lt;");
		value = Utils.replaceAll(value, ">", "&gt;");
		value = Utils.replaceAll(value, "\"", "&quot;");
		return value;
	},
	"unescapeHTML": function (value)
	{
		var original = value;
		
		value = Utils.replaceAll(value, "&lt;", "<");
		value = Utils.replaceAll(value, "&gt;", ">");
		value = Utils.replaceAll(value, "&quot;", "\"");
		value = Utils.replaceAll(value, "&amp;", "&");
		
		if (original == value)
			return value;
		else
			return Utils.unescapeHTML(value);
	},
	"escapeInputForms": function (xml)
	{
		xml = xml.replace('<?xml version="1.0"?>', "");
		xml = xml.replace('<!DOCTYPE input-forms SYSTEM "input-forms.dtd">', "");
	
		var replaceTags = [
			"input-forms",
			"form-map",
			"name-map",
			"form-definitions",
			"page",
			"field",
			"dc-schema",
			"dc-element",
			"dc-qualifier",
			"repeatable",
			"label",
			"input-type",
			"hint",
			"required",
			"default-value",
			"form-value-pairs",
			"value-pairs",
			"pair",
			"displayed-value",
			"stored-value",
			"form",
		];
		
		for (var i = 0; i < replaceTags.length; i++)
		{
			var tag = replaceTags[i];
			xml2 = xml;
			xml = Utils.replaceAll(xml
				, "<"+tag
				, "<div class=\""+tag+"\"");
			xml = Utils.replaceAll(xml
				, "</"+tag
				, "</div");
		}
	
		return xml;
	},
	getContextPath: function () {
		var output = location.href;
		
		var l = output;
		var needle = "/dspace-admin/";
		if (l.indexOf("/dspace-admin/") != -1)
		{
			output = l.substring(0, l.indexOf("/dspace-admin/"));
		}
		return output;
	},
	validAttr: function (value) {
		var regObj = /^[0-9A-Za-z]|[_]|[-]|[\.]$/;
		var result = true;
		for (var i = 0; i < value.length; i++)
		{
			if (regObj.test(value.substr(i, 1)) == false)
			{
				result = false;
				//alert(value.substr(i, 1));
				break;
			}
		}
		//result = false;
		return result;
	},
	checkFormName: function (thisObj) 
	{
		var LANG = {
			Hint: {
				"NotNull": "※不能是空值",
				"OnlyEnglish": "※只能是英文、數字、底線、橫線與點"
			}
		};
		
		if (typeof(getInputFormsEditorLang) != "undefined")
			LANG = getInputFormsEditorLang().InputFormsParser;
		
		var value = jQuery.trim(thisObj.value);
		var acceptBtn = jQuery(thisObj).parents("div.ui-dialog:first").find("button.accept:first");
		var hint = jQuery(thisObj).nextAll("div.hint:first");
		if (value == "")
		{
			hint.html(LANG.Hint.NotNull);
			acceptBtn.attr("disabled", "disabled").addClass("disabled");
		}
		else
		{
			var result = Utils.validAttr(value);
			
			if (result == false)
			{
				hint.html(LANG.Hint.OnlyEnglish);
				acceptBtn.attr("disabled", "disabled").addClass("disabled");
			}
			else
			{
				hint.html("");
				acceptBtn.removeAttr("disabled").removeClass("disabled");
			}
		}
	},
	getDefaultHandle: function () {
		var handle = location.search;
		var needle = "handle=";
		if (handle.indexOf(needle) == -1)
			return "";
		//取出handle的值吧
		var start = handle.indexOf(needle) + needle.length;
		var end = handle.length;
		handle = handle.substring(start, end);
		handle = unescape(handle);
		
		return handle;
	},
	searchCollectionHandle: function () {
		var handle = Utils.getDefaultHandle();
		if (handle == "")
			return;
		
		//找找看有沒有handle在input.collection-handle.text裡面
		var matchInput = jQuery("input.collection-handle.text[value='"+handle+"']:first");
		
		var LANG = {
			Hint: {
				"CreateFormConfirm": "您使用的是預設的traditional表單，是否要為此類別指定新的表單呢？"
			}
		};
		if (typeof(getInputFormsEditorLang) != "undefined")
			LANG = getInputFormsEditorLang().InputFormsParser;
		
		if (matchInput.length == 0)
		{
			//if (window.confirm("您使用的是預設的traditional表單，是否要新增該合集的特別表單呢？"))
			if (window.confirm(LANG.Hint.CreateFormConfirm))
			
			{
				jQuery("fieldset#form_collection legend:first button:last").click();
				defaultHandle = handle;
			}
			else
			{
				return;
			}
		}
		
		var formEditors = jQuery("fieldset#form_collection").children("div.form-editor");
		var nowEditor = matchInput.parents("div.form-editor:first");
		var index = formEditors.index(nowEditor);
		
		if (index == 0)
			return;
		
		var formSelect = jQuery("select#form_select");
		formSelect.children("option:eq("+index+")")
			.attr("selected", "selected");
		formSelect.change();
	},
	setFieldPreview: function (fieldEditor)
	{
		if (fieldEditor.hasClass("field") == false)
		{
			fieldEditor = fieldEditor.parents("tr.field:first");
			if (fieldEditor.length == 0)
			{
				throw "Cannot found fieldEditor!";
				return;
			}
		}
		
		var inputs = ["label"
			, "hint"
			, "repeatable"
			, "required"
			, "input-type"];
		
		for (var i = 0; i < inputs.length; i++)
		{
			fieldEditor.find("input:hidden.data-"+inputs[i]+":first").change();
		}
	}
};	//var Utils = {
