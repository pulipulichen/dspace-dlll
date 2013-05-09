// JavaScript Document

jQuery.fn.extend({
	XMLMetadataEditor: function () {
		var thisObj = jQuery(this);		
		
		var xml = thisObj.val();
		var editor = XMLMetadataEditorObject(xml);
		if (typeof(editor) == "object")
		{
			thisObj.wrap("<div class=\"xmlmetadata-area\"></div>");
		
			thisObj.after(editor);
			
			thisObj.addClass("xmlmetadata-source")
				.css("width", "100%")
				.css("height", "480px")
				.hide();
				
			var controller = XMLMetadataEditorController();
			thisObj.before(controller);
		}
		else
			alert(editor);
	}
});

var XMLMetadataEditorObject = function (xml) {

	var xmlRoot = new Object;
	
	if (typeof(getXMLMetadataEditorLang) == "undefined")
	{
		var LANG = {
			EditorHeaderList: "清單",
			EditorHeaderAttr: "內容",
			EditorAttrDefault: "請點選左方清單列表，選擇要編輯的節點。", 
			Delete: "刪除",
			RootCannotDelete: "根節點無法刪除",
			DeleteNodeConfirm: "確定要刪除此節點？",
			DeleteConfirm: "確定要刪除？",
			InsertInput: "插入欄位",
			InsertNode: "插入節點",
			InsertNodeContent: "插入內容節點",
			MoveUp: "上移",
			MoveDown: "下移",
			Add: "新增",
			Save: "儲存",
			Reload: "重新讀取",
			Update: "更新",
			UpdateComplete: "更新完成",
			LoadError: "讀取失敗！",
			NodeContentTempTitle: "(預設內容節點)",
			NodeContentTitle: "(資料內容節點)",
			BooleanTrue: "是",
			BooleanFalse: "否",
			NotSelect: "請先選擇要刪除的項目",
			TitleCannotNull: "標題不可以空白",
			LabelTitle: "標題",
			LabelRepeatable: "可重複",
			LabelRequired: "必填",
			LabelInputType: "輸入類型",
			LabelOptions: "選項",
			LabelDefaultValue: "預設值",
			LabelValue: "輸入值",
			LabelIsTemp: "預設節點",
			InitError: "讀取錯誤！",
			EscapeHint: "標題不能有HTML標籤或是<跟>！系統將自動移除HTML標籤跟<與>。",
			ValuePair: {
				display: "顯示值",
				stored: "儲存值"
			}
		};
	}
	else
		var LANG = getXMLMetadataEditorLang().Object;
	
	var init = function (xml)
	{
		xmlRoot = jQuery(xml);
		if (xmlRoot.hasClass("xml-root") == false)
		{
			xmlRoot = xmlRoot.find(".xml-root:first");
			if (xmlRoot.length == 0)
			{
				//return LANG.InitError;
				xmlRoot = jQuery("<div class=\"xml-root\"><DIV class=\"node\"><DIV class=\"node-type\">node</DIV><DIV class=\"node-title\">-</DIV><DIV class=\"node-repeatable\">true</DIV><DIV class=\"node-id\"></DIV><DIV class=\"node-class\"></DIV><DIV class=\"node-content-temp\" /></DIV></div>");
			}
		}
	
		var eTable = jQuery("<table class=\"xmlmetadata-editor\" border=\"0\"><thead></thead><tbody></tbody></table>");
		
		var header = jQuery("<tr><th class=\"editor-header-list\"></th><th class=\"editor-header-attr\" width=\"300\"></th></tr>")
			.appendTo(eTable.find("thead:first"));
		
		
		//插入兩個按鈕
		var btnListToXML = getButton(LANG.Save)
			.hide()
			.addClass("list-to-xml")
			.click(function () {
				var list = jQuery(this).parents("table.xmlmetadata-editor").find("div.editor-list:first");
				var xml = getListToXML(list);
				
				var source = jQuery(this).parents(".xmlmetadata-area:first").children(".xmlmetadata-source:first");
				source.val(xml);
			});
		
		var btnXMLToList = getButton(LANG.Reload)
			.addClass("xml-to-list")
			.click(function () {
				var source = jQuery(this).parents(".xmlmetadata-area").children(".xmlmetadata-source:first");
				var xml = source.val();
				var editor = XMLMetadataEditorObject(xml);
				
				if (editor != false)
				{
					source.nextAll(".xmlmetadata-editor").remove();
					source.after(editor);
				}
				else
					alert(LANG.LoadError);
			});
		
		
		header.find(".editor-header-list:first").html(LANG.EditorHeaderList)
			.append(btnListToXML).append(btnXMLToList)
			.append(listConroller());
		header.find(".editor-header-attr:first").html(LANG.EditorHeaderAttr);
		
		var content = jQuery("<tr><td><div class=\"editor-list\"></div></td><td><div class=\"editor-attr\"></div></td></tr>")
			.appendTo(eTable.find("tbody:first"));
		
		var list = getList(xmlRoot, true);
		content.find(".editor-list")
			.append(list);
		content.find(".editor-attr").html(LANG.EditorAttrDefault);
		
		
		return eTable;
	}
	
	var getButton = function (text, img) {
		if (typeof(img) == "undefined")
			var btn = jQuery("<button type=\"button\" title=\""+text+"\">"+text+"</button>");
		else
		{
			var btn = jQuery("<button type=\"button\" title=\""+text+"\" class=\"icon\">"+img+"</button>");
		}
		return btn;
	};
	
	var getSelected = function () {
		var selector = jQuery("input[name='xmlmetadata_list_selector']:checked:first");
		if (selector.length == 1)
		{
			var li = selector.parents("li:first");
			return li;
		}
		else
			return null;
	};
	
	var listConroller = function () {
		var controller = jQuery("<div class=\"list-controller\"></div>");
		
		var insert = function (item, type)
		{
			var selected = getSelected();
				
			if (type == "input"
				|| type == "node")
			{
				if (selected.hasClass("node-content"))
				{
					var ul = selected.children("ul:first");
					if (ul.length == 0)
					{
						ul = jQuery("<ul></ul>")
							.appendTo(selected);
					}
					ul.append(item);
				}
				else
					selected.after(item);
			}
			else
			{
				if (selected.hasClass("node"))
					selected.children("ul:first").append(item);
				else if (selected.hasClass("node-content"))
					selected.after(item);
				else
					return;
			}
			/*
			else if (selected.children("ul.temp").length > 0)
			{
				var contentTemp = selected.children("ul.temp:first");
				if (contentTemp.length == 0)
					contentTemp = jQuery("<ul class=\"temp\"></ul>").appendTo(selected);
				
				var contents = selected.children("ul.content:has(li)");
				
				if (contents.length > 0)
				{
					if (window.confirm("是否插入到預設內容節點？"))
						contentTemp.append(item);

					for (var i = 0; i < contents.length; i++)
					{
						if (window.confirm("是否插入到第"+(i+1)+"個節點？"))
						{
							contents.eq(i).append(item);
							break;
						}
					}
				}
				else
				{
					contentTemp.append(item);
				}
			}
			*/
			
			item.children("input[type='radio']:first").click().focus();
		};
		
		var btnInsertInput = getButton(LANG.InsertInput, LANG.InsertImg+" "+LANG.InsertInput)
			.addClass("insert-input")
			.appendTo(controller)
			.click(function () {
				var input = getInput();
				insert(input, "input");
			});
		
		var btnInsertNode = getButton(LANG.InsertNode, LANG.InsertImg+" "+LANG.InsertNode)
			.addClass("insert-node")
			.appendTo(controller)
			.click(function () {
				var node = getNode();
				insert(node, "node");
			});
		
		var btnInsertNodeContent = getButton(LANG.InsertNodeContent, LANG.InsertImg+" "+LANG.InsertNodeContent)
			.addClass("insert-node-content")
			.appendTo(controller)
			.click(function () {
				var nodeContent = getNodeContent();
				insert(nodeContent, "nodeContent");
			});
			
		
		jQuery("<br />").appendTo(controller);
		
		var btnDel = getButton(LANG.Delete, LANG.DeleteImg)
			.appendTo(controller)
			.click(function () {
				var selected = getSelected();
				if (selected != null && selected.parent().parent().hasClass("editor-list"))
				{
					alert(LANG.RootCannotDelete);
					return;
				}
				
				if (selected != null && window.confirm(LANG.DeleteNodeConfirm))
				{
					if (selected.parents("ul:first").children("li").length == 1)
						selected = selected.parents("ul:first");
						
					selected.remove();
				}	
			});
		
		
		var btnMoveUp = getButton(LANG.MoveUp, LANG.MoveUpImg)
			.appendTo(controller)
			.click(function () {
				var selected = getSelected();
				
				var needle = selected.prev();
				if (needle.length > 0)
					needle.before(selected);
			});
		var btnMoveDown = getButton(LANG.MoveDown, LANG.MoveDownImg)
			.appendTo(controller)
			.click(function () {
				var selected = getSelected();
				
				var needle = selected.next();
				if (needle.length > 0)
					needle.after(selected);
			});	
		
		return controller;
	};
	
	var getList = function (nodeContent, isTemp)
	{
		var list = jQuery("<ul></ul>");
		
		//if (typeof(isTemp) != "undefined" && isTemp == true)
		//	list.addClass("temp");
		
		var nodes = nodeContent.children(".node");
		
		for (var i = 0; i < nodes.length; i++)
		{
			var node = nodes.eq(i);
			
			if (node.children(".node-type:first").html() == "node")
				var item = getNode(node);
			else
				var item = getInput(node);
			
			list.append(item);
		}
		
		return list;
	};
	
	var getNode = function(node) {
		var item = getItem("node");
		
		var obj = nodeToJSON(node);
		
		item.setTitle(obj.title);
		item.setStorer(obj.getStorer());
		
		var nodeContent = jQuery("<ul class=\"node-content\"></ul>")
			.appendTo(item);
		
		for (var i = 0; i < obj.contentTemp.length; i++)
		{
			var contentTemp = obj.contentTemp.eq(i);
			//item.append(getList(contentTemp, true));
			nodeContent.append(getNodeContent(contentTemp, true));
		}
		if (typeof(obj.content) != "undefined")
		{
			for (var i = 0; i < obj.content.length; i++)
			{
				var content = obj.content.eq(i);
				nodeContent.append(getNodeContent(content, false));
			}
		}
		
		return item;
	};
	
	var getNodeContent = function(content, isTemp) {
		if (typeof(isTemp) == "undefined" || isTemp != false)
			isTemp = true;
		
		var item = jQuery("<li></li>")
			.addClass("node-content");
		
		if (isTemp == true)
		{
			item.addClass("temp")
				.html("<label>"+LANG.NodeContentTempTitle+"</label>");
		}
		else
		{
			item.html("<label>"+LANG.NodeContentTitle+"</label>");
		}
		
		var data = jQuery("<div></div>")
			.addClass("data")
			.hide()
			.prependTo(item);
		var isTempInput = jQuery("<input type=\"text\" class=\"isTemp\" value=\"true\" title=\"isTemp\" />")
			.appendTo(data)
			.change(function () {
				var li = jQuery(this).parents("li:first");
				var label = li.children("label:first");
			
				if (this.value == "false")
				{
					label.html(LANG.NodeContentTitle);
					li.removeClass("temp");
				}
				else
				{
					label.html(LANG.NodeContentTempTitle);
					li.addClass("temp");
				}
			});
		if (isTemp == false)
			isTempInput.val("false");
		
		var toggle = jQuery("<span class=\"toggle-trigger\">[-]</span>")
			.prependTo(item)
			.click(function () {
				var nodesUl = jQuery(this).parents("li:first").children("ul:first");
				nodesUl.toggle();
				
				if (nodesUl.filter(":visible").length == 0)
					this.innerHTML = "[+]";
				else
					this.innerHTML = "[-]";
			});
		
		item.find("label").click(function () {
			var selector = jQuery(this).prevAll("input[type='radio'][name='xmlmetadata_list_selector']:first");
				selector.click();
		});
		
		var selector = jQuery("<input type=\"radio\" name=\"xmlmetadata_list_selector\" />")
			.prependTo(item)
			.click(function () { showEditor(this); });
		
		
		//var contentUl = jQuery("<ul></ul>")
		//	.appendTo(item);
		
		if (typeof(content) != "undefined")
		{
			
			//if (isTemp == false)
			//	alert(content.html());
			/*
			var nodes = content.children("div.node");
			for (var i = 0; i < nodes.length; i++)
			{
				var node = nodes.eq(i);
			}
			*/
			item.append(getList(content));	
		}
		return item;
	}
	
	var getInput = function(node) {
		var item = getItem("input");
		
		var obj = inputToJSON(node);
		
		item.setTitle(obj.title);
		item.setStorer(obj.getStorer());
		
		return item;
	};
	
	var getItem = function (type)
	{
		if (typeof(type) == "undefined" || type != "node")
			type = "input";
	
		var item = jQuery("<li></li>")
			.addClass(type);
		
		if (type == "node")
		{
			var toggle = jQuery("<span class=\"toggle-trigger\">[-]</span>")
				.prependTo(item)
				.click(function () {
					var nodesUl = jQuery(this).parents("li:first").children("ul:first");
					nodesUl.toggle();
					
					if (nodesUl.filter(":visible").length == 0)
						this.innerHTML = "[+]";
					else
						this.innerHTML = "[-]";
				});
		}	
		
		var selector = jQuery("<input type=\"radio\" name=\"xmlmetadata_list_selector\" />")
			.prependTo(item)
			.click(function () { showEditor(this); });
			
		var label = jQuery("<label></label>").appendTo(item)
			.click(function () {
				var selector = jQuery(this).prevAll("input[type='radio'][name='xmlmetadata_list_selector']:first");
				selector.click();
			});
		
		item.setTitle = function (title) {
			jQuery(this).find("label:first").html(title);
		};
		item.setStorer = function (storer) {
			jQuery(this).prepend(storer);
		};
		
		return item;
	}
	
	var nodeToJSON = function(node)
	{
		var obj = new Object;
		
		obj.type = "node";
		obj.title = "-";
		obj.id = "";
		obj.className ="";
		obj.repeatable = "false";
		obj.contentTemp = jQuery("<div class=\"node-content-temp\"></div>");
		//obj.content = jQuery("<div class=\"node-content\"></div>");
		if (typeof(node) == "object" && node.length > 0)
		{
			obj.type = node.children(".node-type:first").html();
			obj.title = node.children(".node-title:first").html();
			if (node.children(".node-id:first").length > 0)
				obj.id = node.children(".node-id:first").html();
			if (node.children(".node-class:first").length > 0)
				obj.className = node.children(".node-class:first").html();
			obj.repeatable = node.children(".node-repeatable:first").html();
			
			if (node.children(".node-content-temp:first").length > 0)
				obj.contentTemp = node.children(".node-content-temp");
				
			if (node.children(".node-contents:first").length > 0)
				obj.content = node.children(".node-contents");
			
			if (node.children(".node-content-temp:first").length == 0
				&& node.children(".node-contents:first").length > 0)
				obj.contentTemp = node.children(".node-contents:first");
		}
		obj.getStorer = jsonDataStorer;
		
		return obj;
	};
	
	var inputToJSON = function(node)
	{
		var obj = new Object;
		
		obj.type = "input";
		obj.title = "-";
		obj.repeatable = "false";
		obj.required = "false";
		obj.inputType = "onebox";
		obj.options = jQuery("<select class=\"input-options\"></select>");
		obj.defaultValue = [""];
		obj.value = [""];
		if (typeof(node) == "object" && node.length > 0)
		{
			obj.type = node.children(".node-type:first").html();
			obj.title = node.children(".node-title").html();
			obj.repeatable = node.children(".node-repeatable:first").html();
			obj.required = node.children(".input-required:first").html();
			obj.inputType = node.children(".input-type:first").html();
			
			if (node.children(".input-options:first").length > 0)
				obj.options = node.children(".input-options:first");
			else
				obj.options = jQuery("<select class=\"input-options\"></select>");
			
			
			if (node.children(".input-default-value:first").length > 0)
			{
				var attr = node.children(".input-default-value");
				obj.defaultValue = new Array();
				
				for (var i = 0; i < attr.length; i++)
				{
					var value = attr.eq(i).html();
					obj.defaultValue.push(value);
				}
			}
			else
				obj.defaultValue = [""];
			
			if (node.children(".input-values:first").length > 0)
			{
				var attr = node.children(".input-values");
				obj.value = new Array();
				
				for (var i = 0; i < attr.length; i++)
				{
					var value = attr.eq(i).html();
					obj.value.push(value);
				}
			}
			else
				obj.value = [""];
		}
		obj.getStorer = jsonDataStorer;
		
		return obj;
	};
	
	var jsonDataStorer = function () {
		var data = this;
		
		var storer = jQuery("<div class=\"data\"></div>")
			.hide();
		
		var inputHidden = function (name, data)
		{
			if (name == "className")
				name = "class";
			
			if (typeof(data) == "string" || typeof(data) == "number")
			{
				var input = jQuery("<input type=\"text\" class=\""+name+"\" title=\""+name+"\" />")
					.val(data);
				if (name == "title")
				{
					input.change(function () {
						var title = this.value;
						var node = jQuery(this).parents(":eq(1)");
						node.children("label:first").html(title);
					});
				}
			}
			else if (name == "options" && typeof(data) == "object")
			{
				var input = data.addClass("options");
			}
			else if (name == "value" || name == "defaultValue")
			{
				var container = jQuery("<div></div>");
				
				for (var i = 0; i < data.length; i++)
				{
					var value = jQuery.trim(data[i]);
					if (value == "")
						continue;
				
					var input = jQuery("<input type=\"text\" class=\""+name+"\" title=\""+name+"\" />")
						.val(value)
						.appendTo(container);
				}
				
				var input = container.contents();
			}
			else
				var input = null;
			
			return input;
		};
		
		jQuery.each(data, function (name, value) {
			storer.append(inputHidden(name, value));
		});
		
		return storer;
	};
	
	var showEditor = function (thisInput) {
		var selected = jQuery(thisInput).parents("li:first");
		var data = itemToJSON(selected);
		var editorContainer = jQuery(".editor-attr:first").empty();
		
		var isRoot = selected.parents("ul:first").parent().hasClass("editor-list");
		
		var controller = jQuery(thisInput).parents("table.xmlmetadata-editor:first").find("thead tr th.editor-header-list div.list-controller");
		var insertInput = controller.find("button.insert-input").show();
		var insertNode = controller.find("button.insert-node").show();
		var insertNodeContent = controller.find("button.insert-node-content").show();
		if (data.type == "input")
		{
			var editor = getInputEditor(data);
			insertNodeContent.hide();
		}
		else if (data.type == "node")
		{
			var editor = getNodeEditor(data,isRoot);
			if (isRoot == true)
			{
				insertInput.hide();
				insertNode.hide();
			}
		}
		else
		{
			var editor = getNodeContentEditor(data);
		}
		
		editor.appendTo(editorContainer);
	};
	
	var itemToJSON = function(item) {
		
		var data = item.children(".data:first");
		
		var getNodeJSON = function (data) {
			var obj = new Object;
		
			obj.type = data.children(".type").val();
			obj.title = data.children(".title").val();
				//obj.title = EditorUtils.escape(obj.title);
			obj.repeatable = data.children(".repeatable").val();
			
			obj.id = data.children(".id:first").val();
			obj.className = data.children(".class:first").val();
			obj.isTemp = data.children(".isTemp:first").val();
			
			return obj;
		};
		
		var getInputJSON = function(data) {
			var obj = new Object;
			
			obj.type = data.children(".type").val();
			obj.title = data.children(".title").val();
				//obj.title = EditorUtils.escape(obj.title);
			obj.repeatable = data.children(".repeatable").val();
			
			obj.required = data.children(".required").val();
			obj.inputType = data.children(".inputType").val();
			
			obj.defaultValue = new Array();
			var dvObj = data.children(".defaultValue");
			for (var i = 0; i < dvObj.length; i++)
			{
				var value = jQuery.trim(dvObj.eq(i).val());
				value = EditorUtils.unescape(value);
				obj.defaultValue.push(value);
			}
			
			obj.value = new Array();
			var vObj = data.children(".value");
			for (var i = 0; i < vObj.length; i++)
			{
				var value = jQuery.trim(vObj.eq(i).val());
				value = EditorUtils.unescape(value);
				obj.value.push(value);
			}
			obj.options = data.children(".options");
			var options = data.children(".options:first").children("option");
			obj.valuePairs = new Array();
			for (var i = 0; i < options.length; i++)
			{
				var stored = options.eq(i).attr("value");
					stored = EditorUtils.unescape(stored);
				var displayed = options.eq(i).attr("innerHTML");
					displayed = EditorUtils.unescape(displayed);
				
				obj.valuePairs.push({
					stored: stored,
					displayed: displayed
				});
			}
			
			return obj;
		};
		
		var getNodeContentJSON = function (data) {
			var obj = new Object;
			
			obj.type = "nodeContent";
			
			var isTemp = data.children(".isTemp:first").val();
			if (isTemp == "true")
				obj.isTemp = true;
			else
				obj.isTemp = false;
			
			return obj;
		};
		
		if (item.hasClass("input"))
		{
			var obj = getInputJSON(data);
		}
		else if (item.hasClass("node"))
		{
			var obj = getNodeJSON(data);
		}
		else
		{
			var obj = getNodeContentJSON(data);
		}
		
		return obj;
	};
	
	var EditorUtils = {
		getText: function(label, name, value, repeatable) {
			if (typeof(repeatable) == "undefined")
				repeatable = false;
			else if (repeatable == "true" || repeatable == true)
				repeatable = true;
			else
				repeatable = false;

			var textTr = jQuery("<tr class=\""+name+"-tr\"><th>"+label+"</th><td></td></tr>");

			if (typeof(value) != "object")
				var valueAry = [value];
			else
				var valueAry = value;
			
			if (valueAry.length == 0)
				valueAry = [""];
			
			var createTextInput = function (name, value)
			{
				var textDiv = jQuery("<div></div>");
				
				var textRadio = jQuery("<input type=\"radio\" name=\""+name+"-radio\" />")
					.addClass("repeatable-option")
					.appendTo(textDiv)
					.click(function () {
						jQuery(this).nextAll("input:first").focus();
					});
				
				var textInput = jQuery("<input type=\"text\" class=\"text "+name+"\" />")
					.val(value)
					.appendTo(textDiv)
					.focus(function () {
						jQuery(this).prevAll("input:first").attr("checked", "checked");
					});
				return textDiv;
			};
			
			var btnDel = jQuery("<button type=\"button\">"+LANG.Delete+"</button>")
				.appendTo(textTr.find("td:first"))
				.addClass("repeatable-option")
				.click(function () {
					var selectedInput = jQuery(this).parents("td:first").find("input:radio:checked").nextAll("input:first");
					
					if (selectedInput.length > 0 
						&& jQuery.trim(selectedInput.val()) != ""
						&& window.confirm(LANG.DeleteConfirm))
						selectedInput.parents("div:first").remove();
					else if (selectedInput.length > 0 
						&& jQuery.trim(selectedInput.val()) == "")
						selectedInput.parents("div:first").remove();
					else if (selectedInput.length == 0)
						window.alert(LANG.NotSelect);
				});
			
			var btnInset = jQuery("<button type=\"button\">"+LANG.Add+"</button>")
				.appendTo(textTr.find("td:first"))
				.addClass("repeatable-option")
				.click(function () {
					var selectedInput = jQuery(this).parents("td:first").find("input:radio:checked").nextAll("input:first");
					var textDiv = createTextInput(name, "");
					
					if (selectedInput.length > 0)
					{
						var selectedDiv = selectedInput.parents("div:first")
							.after(textDiv);
					}
					else
					{
						jQuery(this).parents("td:first")
							.append(textDiv);
					}
					
					textDiv.find("input:text:first").focus();
				});
				
			for (var i = 0; i < valueAry.length; i++)
			{
				var textDiv = createTextInput(name, valueAry[i]);
				textDiv.appendTo(textTr.find("td:first"));
			}
			
			if (repeatable == false)
			{
				textTr.find(".repeatable-option").hide();
			}
			
			return textTr;
		},
		getBoolean: function(label, name, value) {
			var tr = jQuery("<tr><th>"+label+"</th><td></td></tr>");
			
			var radioTrue = EditorUtils.getRadio(LANG.BooleanTrue, name + " true")
				.appendTo(tr.find("td:first"));
			var radioFalse = EditorUtils.getRadio(LANG.BooleanFalse, name + " false")
				.appendTo(tr.find("td:first"));
			
			if (value == "true" || value == true)
				radioTrue.find("input[type=\"radio\"]:first").attr("checked","checked");
			else
				radioFalse.find("input[type=\"radio\"]:first").attr("checked","checked");
			
			return tr;
		},
		getRadio: function(label, name)
		{
			var radio = jQuery("<input type=\"radio\" class=\""+name+"\" />")
				.click(function() {
					var radios = jQuery(this).parents("td:first").find("input[type='radio']");
					radios.removeAttr("checked");
					
					jQuery(this).attr("checked","checked");
				});
			var label = jQuery("<label>"+label+"</label>")
				.click(function () {
					radio = jQuery(this).prevAll("input[type='radio']:first");
					radio.click();
				});
			
			var container = jQuery("<span></span>")
				.append(radio)
				.append(label);
			return container;
		},
		getSelect: function (label, name, value, options) {
			var tr = jQuery("<tr><th>"+label+"</th><td><select class=\""+name+"\"></select></td></tr>");
			for (var i = 0; i < options.length; i++)
			{
				var option = jQuery("<option></option>")
					.html(options[i])
					.attr("value", options[i]);
				option.appendTo(tr.find("select:first"));
				
				if (value == options[i])
					option.attr("selected","selected");
			}
			return tr;
		},
		getValuePairs: function (label, name, select) {
			var tr = jQuery("<tr><th>"+label+"</th><td><table class=\"value-pairs\"><thead><tr><th class=\"controller\" colspan=\"3\"></th></tr><tr><th>&nbsp;</th><th>"
				+ LANG.ValuePair.display + "</th><th>"
				+ LANG.ValuePair.stored + "</th></tr></thead><tbody></tbody><tfoot><tr><td colspan=\"2\"></td></tr></tfoot></table></td></tr>");
			
			//var options = select.children("option");
			for (var i = 0; i < select.length; i++)
			{
				//var stored = options.eq(i).attr("value");
				//var displayed = options.eq(i).attr("innerHTML");
				var stored = select[i].stored;
				var displayed = select[i].displayed;
				
				var item = EditorUtils.getValuePairItem(stored, displayed);
				
				item.appendTo(tr.find("tbody:first"));
			}
			
			var btnInsert = getButton(LANG.Add).appendTo(tr.find("th.controller:first"))
				.click(function () {
					var item = EditorUtils.getValuePairItem("", "");
				
					var selected = jQuery("input[type='radio'][name='input_value_pairs']:checked");
					if (selected.length > 0)
					{
						var tr = selected.parents("tr:first");
						tr.after(item);
					}					
					else
					{
						var tbody = jQuery(this).parents("table.value-pairs:first").children("tbody");
						tbody.append(item);
					}
					
					item.find("input[type='radio'][name='input_value_pairs']:first").attr("checked", "checked");
				});
			
			var btnDel = getButton(LANG.Delete).appendTo(tr.find("th.controller:first"))
				.click(function () {
					//先取得被選擇的對象
					try
					{
						var selectedTr = jQuery(this).parents("table:first")
							.find("input:radio:checked:first").parents("tr:first");
					}
					catch (e) {
						return;
					}
					
					if (selectedTr.length > 0 && window.confirm(LANG.DeleteConfirm))
					{
						selectedTr.remove();
					}
					else if (selectedTr.length == 0)
					{
						window.alert(LANG.NotSelect);
					}
				});
			
			return tr;
		},
		getValuePairItem: function (stored, displayed)
		{
			var item = jQuery("<tr><td class=\"function\"></td>"
				+ "<td class=\"displayed\"></td>"
				+ "<td class=\"stored\"></td></tr>");
			
			var text = jQuery("<input type=\"text\" class=\"text\" />");
			text.clone().val(stored).appendTo(item.find("td.stored:first"));
			text.val(displayed).appendTo(item.find("td.displayed:first"));
			
			var selector = jQuery("<input type=\"radio\" name=\"input_value_pairs\">")
				.appendTo(item.find("td.function"));
			
			item.find("input").focus(function () {
				var selector = jQuery(this).parents("tr:first").find("input[type='radio'][name='input_value_pairs']:first");
				selector.attr("checked","checked");
			});
			
			return item;
		},
		escape: function(value)
		{
			value = EditorUtils.unescape(value);
			
			value = escape(value);
			return value;
		},
		unescape: function (value)
		{
			var original = value;
			
			value = unescape(value);
			if (original == value)
				return value;
			else
				return EditorUtils.unescape(value);
		},
		removeBrackets: function (value) 
		{
			value = EditorUtils.stripHTML(value);
			value = EditorUtils.replaceAll(value, "<", "");
			value = EditorUtils.replaceAll(value, ">", "");
			return value;
		},
		stripHTML: function (value) {
			return value.replace(/<.*?>/g, "");
		},
		replaceAll: function (str, reallyDo, replaceWith) {
			return str.replace(new RegExp(reallyDo, 'g'), replaceWith);
		},
		pruneID: function (value) {
			
			return value;
		},
		pruneClassName: function (value) {
			
			return value;
		}
	};	//var EditorUtils = {
	
	var getInputEditor = function (data) {
		var editor = jQuery("<table class=\"editor-table\"><thead><tr><th colspan=\"2\"></th></tr></thead><tbody></tbody><tfoot><tr><th colspan=\"2\"></th></tr></tfoot></table>");
		
		var tbody = editor.find("tbody:first");
		
		var btnUpdate = getButton(LANG.Update)
			.click(function () {
				var data = jQuery(this).parents("table.editor-table:first");
				
				var selected = getSelected();
				var storer = selected.children(".data:first");
				
				var title = jQuery.trim(data.find(".title").val());
				if (title.indexOf("<") != -1 || title.indexOf(">") != -1)
				{
					alert(LANG.EscapeHint);
					title = EditorUtils.removeBrackets(title);
				}
				if (title == "")
				{
					window.alert(LANG.TitleCannotNull);
					return;
				}
				storer.find(".title:first").val(title).change();

				if (data.find(".repeatable.true:checked").length == 1)
					storer.find(".repeatable").val("true");
				else
					storer.find(".repeatable").val("false");
					
				if (data.find(".required.true:first:checked").length == 1)
					storer.find(".required").val("true");
				else
					storer.find(".required").val("false");
				
				var inputType = data.find(".inputType").val()
				storer.find(".inputType").val(inputType);
				
				var options = data.find("table.value-pairs tbody:first tr");
				var select = storer.find("select.options:first").empty();
				
				if (inputType == "dropdown" || inputType == "list")
				{
					for (var i = 0; i < options.length; i++)
					{
						var stored = options.eq(i).find("td.stored input:first").val();
							stored = EditorUtils.escape(stored);
						var displayed = options.eq(i).find("td.displayed input:first").val();
							displayed = EditorUtils.escape(displayed);
						
						var option = jQuery("<option></option>")
							.val(stored)
							.html(displayed)
							.appendTo(select);
					}
				}
				
				storer.find(".defaultValue, .value").remove();
				var createDataInput = function (name, value)
				{
					value = jQuery.trim(value);
					value = EditorUtils.escape(value);
					if (value != "")
						return jQuery("<input type=\"text\" class=\""+name+"\" title=\""+name+"\" />")
							.val(value);
					else
						return null;
				}
				if (inputType != "fileupload" && inputType != "date")
				{
					var ipts = data.find(".defaultValue");
					for (var i = 0; i < ipts.length; i++)
						storer.append(createDataInput("defaultValue", ipts.eq(i).val()));
					
					var ipts = data.find(".value");
					for (var i = 0; i < ipts.length; i++)
						storer.append(createDataInput("value", ipts.eq(i).val()));
					//storer.find(".defaultValue").val(data.find(".defaultValue").val());
					//storer.find(".value").val(data.find(".value").val());
				}
				else
				{
					storer.append(createDataInput("defaultValue", ""));
					storer.append(createDataInput("value", ""));
					//storer.find(".defaultValue").val("");
					//storer.find(".value").val("");
				}
				
				//selected.children("label:first").html(data.find(".title").val());
				
				alert(LANG.UpdateComplete);
			})
			.appendTo(editor.find("thead tr th"));
		
		var btnUpdateFooter = btnUpdate.clone(true)
			.appendTo(editor.find("tfoot tr th"));
			
		//來吧，內容……
		var title = EditorUtils.getText(LANG.LabelTitle, "title", data.title, false)
			.appendTo(tbody);
		title.find("input.title:first").focus(function () {
				if (this.value == "-")
					this.value = "";
			});
		var repeatable = EditorUtils.getBoolean(LANG.LabelRepeatable, "repeatable", data.repeatable)
			.appendTo(tbody);
			repeatable.find("input:radio").click(function() {
				var rootTable = jQuery(this).parents("table:first");
				var reopt = rootTable.find(".defaultValue-tr .repeatable-option"
					+ ", .value-tr .repeatable-option"
					+ ", .defaultValue-tr .text.defaultValue:not(:first)"
					+ ", .value-tr .text.value:not(:first)");
				if (jQuery(this).hasClass("true"))
				{
					reopt.show();
				}
				else
				{
					reopt.hide();
				}
			});
		
		var required = EditorUtils.getBoolean(LANG.LabelRequired, "required", data.required)
			.appendTo(tbody);
		
		var inputType = EditorUtils.getSelect(LANG.LabelInputType, "inputType", data.inputType
			, ["onebox",
				"date",
				"textarea",
				"texteditor",
				"fileupload",
				"dropdown",
				"list",
				"taiwanaddress"
			])
			.appendTo(tbody)
			.change(function () {
				var type = jQuery(this).find("select:first").val();
				var tbody = jQuery(this).parents("tbody:first");
				
				var valuePairs = tbody.find(".value-pairs").parents("tr:first");
				var defaultValue = tbody.find(".defaultValue").parents("tr:first");
				var value = tbody.find(".value").parents("tr:first");
				
				if (type == "dropdown"
					|| type == "list")
				{
					valuePairs.show();
					defaultValue.show();
					value.show();
				}
				else if (type == "fileupload" 
					|| type == "date"
					|| type == "taiwanaddress")
				{
					valuePairs.hide();
					defaultValue.hide();
					value.hide();
				}
				else
				{
					valuePairs.hide();
					defaultValue.show();
					value.show();
				}
			});
		setTimeout(function () {
			inputType.change();
		}, 100);
		
		
		var valuePairs = EditorUtils.getValuePairs(LANG.LabelOptions, "options", data.valuePairs)
			.appendTo(tbody);
		
		var defaultValue = EditorUtils.getText(LANG.LabelDefaultValue, "defaultValue", data.defaultValue, data.repeatable)
			.appendTo(tbody);
		
		var value = EditorUtils.getText(LANG.LabelValue, "value", data.value, data.repeatable)
			.appendTo(tbody);
		
		
		return editor;
	};
	
	var getNodeEditor = function (data, isRoot) {
		var editor = jQuery("<table class=\"editor-table\"><thead><tr><th colspan=\"2\"></th></tr></thead><tbody></tbody><tfoot><tr><th colspan=\"2\"></th></tr></tfoot></table>");
		
		var btnUpdate = getButton(LANG.Update)
			.appendTo(editor.find("thead tr th"))
			.click(function () {
				
				var data = jQuery(this).parents("table.editor-table:first");
				
				var selected = getSelected();
				var storer = selected.children(".data:first");
				
				var title = jQuery.trim(data.find("input.title:first").val());
				if (title.indexOf("<") != -1 || title.indexOf(">") != -1)
				{
					alert(LANG.EscapeHint);
					title = EditorUtils.removeBrackets(title);
				}
				if (title == "")
				{
					window.alert(LANG.TitleCannotNull);
					data.find("input.title:first").focus();
					return;
				}
				storer.find(".title").val(title).change();
				
				if (data.find(".repeatable.true:checked").length == 1)
					storer.find(".repeatable").val("true");
				else
					storer.find(".repeatable").val("false");
				
				var id = jQuery.trim(data.find("input.id:first").val());
					id = EditorUtils.pruneID(id);
				storer.find(".id").val(id);
				
				var className = jQuery.trim(data.find("input.class:first").val());
					className = EditorUtils.pruneClassName(className);
				storer.find(".class").val(className);
				
				if (data.find(".isTemp.true:checked").length == 1)
					storer.find(".isTemp").val("true");
				else
					storer.find(".isTemp").val("false");
				
				alert(LANG.UpdateComplete);
			});
		
		var btnUpdateFooter = btnUpdate.clone(true)
			.appendTo(editor.find("tfoot tr th"));
		
		var tbody = editor.find("tbody:first");
		
		//alert([data.type, data.title, data.repeatable]);
		var title = EditorUtils.getText(LANG.LabelTitle, "title", data.title, false)
			.appendTo(tbody);
		title.find("input.title:first").focus(function () {
				if (this.value == "-")
					this.value = "";
			});
		
		var ID = EditorUtils.getText("ID", "id", data.id, false)
			.appendTo(tbody);
		
		var className = EditorUtils.getText("class", "class", data.className, false)
			.appendTo(tbody);
			
		var repeatable = EditorUtils.getBoolean(LANG.LabelRepeatable, "repeatable", data.repeatable)
			.appendTo(tbody);
		
		//if (typeof(isRoot) != "undefined" && isRoot == true)
		//{
		//	repeatable.hide();
		//}
		
		return editor;
	};
	
	var getNodeContentEditor = function (data, isRoot) {
		var editor = jQuery("<table class=\"editor-table\"><thead><tr><th colspan=\"2\"></th></tr></thead><tbody></tbody><tfoot><tr><th colspan=\"2\"></th></tr></tfoot></table>");
		
		var btnUpdate = getButton(LANG.Update)
			.appendTo(editor.find("thead tr th"))
			.click(function () {
				var data = jQuery(this).parents("table.editor-table:first");
				
				var selected = getSelected();
				var storer = selected.children(".data:first");
				
				if (data.find(".isTemp.true:checked").length == 1)
					storer.find(".isTemp").val("true");
				else
					storer.find(".isTemp").val("false");
				
				storer.find(".isTemp").change();
				
				alert(LANG.UpdateComplete);
			});
		
		var btnUpdateFooter = btnUpdate.clone(true)
			.appendTo(editor.find("tfoot tr th"));
		
		var tbody = editor.find("tbody:first");
		
		var isTemp = EditorUtils.getBoolean(LANG.LabelIsTemp, "isTemp", data.isTemp)
			.appendTo(tbody);
		
		return editor;
	};
	
	var getListToXML = function(list) {
		var xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><div class=\"xml-root\">";
		
		var ul = list.children("ul:first");
		var li = ul.children("li:first");
		xml = xml + getLiNodeToXML(li);
		/*
		for (var i = 0; i < ul.length; i++)
		{
			var ulXML = getUlToXML(ul.eq(i));
			xml = xml + ulXML;
		}
		*/
		
		xml = xml + "</div>";
		
		return xml;
	};
	
	var getLiNodeToXML = function(li) {
		var xml = "<DIV class=\"node\">";
		
		var data = itemToJSON(li);
		
		xml = xml + "<DIV class=\"node-type\">node</DIV>"
			+ "<DIV class=\"node-title\">"+data.title+"</DIV>"
			+ "<DIV class=\"node-repeatable\">"+data.repeatable+"</DIV>"
			+ "<DIV class=\"node-id\">"+data.id+"</DIV>"
			+ "<DIV class=\"node-class\">"+data.className+"</DIV>";
		
		var nodeContent = li.children("ul:first").children("li");
		for (var i = 0; i < nodeContent.length;i++)
		{
			xml = xml + getLiNodeContentToXML(nodeContent.eq(i));
		}
		if (nodeContent.length == 0)
			xml = xml + "<DIV class=\"node-content-temp\" />";
		
		xml = xml + "</DIV>";
		
		return xml;
	};
	var getLiNodeContentToXML = function (li) {
		if (li.hasClass("temp"))
			var xml = "<DIV class=\"node-content-temp\">";
		else
			var xml = "<DIV class=\"node-contents\">";
		
		var nodes = li.children("ul:first").children("li");
		for (var i = 0; i < nodes.length; i++)
		{
			var node = nodes.eq(i);
			if (node.hasClass("node"))
				xml = xml + getLiNodeToXML(node);
			else
				xml = xml + getLiInputToXML(node);
		}
		
		xml = xml + "</DIV>";
		
		return xml;
	};
	
	var getLiInputToXML = function(li) {
		var xml = "<DIV class=\"node\">";
		
		var data = itemToJSON(li);
		
		xml = xml + "<DIV class=\"node-type\">input</DIV>"
			+ "<DIV class=\"node-title\">"+data.title+"</DIV>"
			+ "<DIV class=\"node-repeatable\">"+data.repeatable+"</DIV>"
			+ "<DIV class=\"input-required\">"+data.required+"</DIV>"
			+ "<DIV class=\"input-type\">"+data.inputType+"</DIV>";
		
		xml = xml + "<select class=\"input-options\">";
		var opts = data.options.children("option");
		for (var i = 0; i < opts.length; i++)
		{
			var opt = opts.eq(i);
			xml = xml + "<option value=\""+opt.attr("value")+"\">"+opt.html()+"</option>";
		}
		xml = xml + "</select>";
		
		for (var i = 0; i < data.defaultValue.length; i++)
		{
			xml = xml + "<DIV class=\"input-default-value\">"+data.defaultValue[i]+"</DIV>";
		}
		
		for (var i = 0; i < data.value.length; i++)
		{
			xml = xml + "<DIV class=\"input-values\">"+data.value[i]+"</DIV>";
		}
		
		if (data.defaultValue.length == 0 && data.value.length == 0)
			xml = xml + "<DIV class=\"input-default-value\" />";
		
		xml = xml + "</DIV>";
		
		return xml;
	};
	
	var eTable = init(xml);
	
	return eTable;
};

var XMLMetadataEditorController = function () {
	
	if (typeof(getXMLMetadataEditorLang) == "undefined")
	{
		var LANG = {
			LabelMode: "編輯模式：",
			LabelEditor: "編輯器",
			LabelSource: "原始碼"
		};
	}
	else
	{
		var LANG = getXMLMetadataEditorLang().Controller;
	}
	
	var init = function () {
		var controller = jQuery("<div class=\"xmlmetadata-controller\" style=\"text-align:center\"></div>");
		
		//模式切換
		var modeSwitcher = jQuery("<div class=\"mode-switcher\"></div>")
			.appendTo(controller);
		
			jQuery("<span>"+LANG.LabelMode+"</span>").appendTo(modeSwitcher);
			var editorRadio = jQuery("<input type=\"radio\" class=\"editor\" checked=\"checked\" />")
				.appendTo(modeSwitcher)
				.click(function () {
					jQuery(this)
						.attr("checked", "checked")
						.nextAll("input:radio:first").removeAttr("checked");
					
					var area = jQuery(this).parents("div.xmlmetadata-area:first");
					
					//先按按鈕
					area.find(".xmlmetadata-editor .xml-to-list:first").click();
					
					area.children(".xmlmetadata-source:first").hide();
					area.children(".xmlmetadata-editor:first").show();
				});
			var editorLabel = jQuery("<label>"+LANG.LabelEditor+"</label>")
				.css("cursor", "pointer")
				.click(function () {
					jQuery(this).prevAll("input:radio:first").click();
				})
				.appendTo(modeSwitcher);
		
			var sourceRadio = jQuery("<input type=\"radio\" class=\"source\" />")
				.appendTo(modeSwitcher)
				.click(function () {
					jQuery(this)
						.attr("checked", "checked")
						.prevAll("input:radio:first").removeAttr("checked");
					
					var area = jQuery(this).parents("div.xmlmetadata-area:first");
					
					//先按按鈕
					area.find(".xmlmetadata-editor .list-to-xml:first").click();
					
					area.children(".xmlmetadata-source:first").show();
					area.children(".xmlmetadata-editor:first").hide();
				});
			var sourceLabel = jQuery("<label>"+LANG.LabelSource+"</label>")
				.css("cursor", "pointer")
				.click(function () {
					jQuery(this).prevAll("input:radio:first").click();
				})
				.appendTo(modeSwitcher);
		
		return controller;
	};
	
	var controller = init();
	return controller;
};
