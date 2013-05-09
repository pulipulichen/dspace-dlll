if (typeof(PromptDialog) == "undefined")
{
	PromptDialog = new Object;
}

PromptDialog.FieldEditor = function () {
		
		var LANG = PromptDialog.LANG.FieldEditor;
		
		var util = {
			getData: function (rootNode, name, isVisible) {
				if (rootNode.length == 0)
				{
					throw "No root node";
					return;
				}
				
				if (typeof(isVisible) == "undefined")
					isVisible = false;
				
				var value = "";
				
				var needle = ".data-";
				if (name.substring(0, needle.length) != needle)
				{
					name = ".data-"+name;
					if (isVisible == true)
						name = name + ":visible";
					name = name + ":enable:first";
				}
				
				var input = rootNode.find(name);
				if (input.length != 0)
				{
					value = input.val();
					value = Utils.escapeHTML(value);
					value = jQuery.trim(value);
				}
				return value;
			},
			focusData: function (rootNode, selector) {
				if (selector.substring(0,1) != ".")
					selector = ".data-"+selector+":first";
				
				rootNode.find(selector).focus();
			},
			setSource: function (source, name, value) {
				if (source.length == 0)
				{
					source = jQuery("tr.field-data-source:first");
					
					if (source.length == 0)
					{
						throw "No source";
						return;
					}
				}
				
				//source.find(".data-"+name+":first").val(value);
				source.find(".data-"+name+":first").attr("value", value);
			},
			setDataToSource: function (rootNode, source, inputName, outputName)
			{
				if (typeof(outputName) == "undefined")
					outputName = inputName;
				
				var value = util.getData(rootNode, inputName);
				util.setSource(source, outputName, value);
			},
			getSource: function (source, name)
			{
				if (source.length == 0)
				{
					source = jQuery("tr.field-data-source:first");
					
					if (source.length == 0)
					{
						throw "No source";
						return;
					}
				}
				
				var needle = ".data-";
				if (name.substring(0, needle.length) != needle)
					name = ".data-"+name+":first";
				
				var value = "";
				var input = source.find(name);
				if (input.length > 0)
				{
					value = input.val();
					value = Utils.unescapeHTML(value);
				}
				return value;
			},
			setData: function (rootNode, name, value)
			{
				if (rootNode.length == 0)
				{
					throw "No root node";
					return;
				}
				
				var needle = ".data-";
				if (name.substring(0, needle.length) != needle)
					name = ".data-"+name+":first";
				
				var input = rootNode.find(name);
				if (input.length > 0)
				{
					//input.attr("value", value);
					input.val(value);
				}
			},
			setMetadata: function (rootNode, schema, element, qualifier) {
				var s = rootNode.find("input.data-schema:first").val(schema);
				rootNode.find("input.data-element:first").val(element);
				rootNode.find("input.data-qualifier:first").val(qualifier);
				
				s.change();
			},
			getMetadata: function (rootNode) {
				var s = rootNode.find("input.data-schema:first").val();
				var e = rootNode.find("input.data-element:first").val();
				var q = rootNode.find("input.data-qualifier:first").val();
				return {schema: s, element: e, qualifier: q};
			},
			getSourceMetadata: function (source) {
				var schema = util.getSource(source, "schema");
				var element = util.getSource(source, "element");
				var qualifier = util.getSource(source, "qualifier");
				return {schema: schema, element: element, qualifier: qualifier};
			},
			metadataEqual: function (meta1, meta2)
			{
				if (meta1.schema == meta2.schema
					&& meta1.element == meta2.element
					&& meta1.qualifier == meta2.qualifier)
					return true;
				else
					return false;
			},
			metadataToString: function (meta) {
				var output = meta.schema + "." + meta.element;
				if (meta.qualifier != "")
					output = output + "." + meta.qualifier;
				return output;
			},
			setSourceToData: function (source, rootNode, inputName, outputName)
			{
				if (typeof(outputName) == "undefined")
					outputName = inputName;
				
				var value = util.getSource(source, inputName);
				util.setData(rootNode, outputName, value);
			},
			valuePair: {
				parse: function (valuePairs) {
					var vpAry = new Array();
					for (var i = 0; i < valuePairs.length; i++)
					{
						var stored = jQuery.trim(valuePairs.eq(i).find(".data-stored").val());
							stored = Utils.escapeHTML(stored);
						var displayed = jQuery.trim(valuePairs.eq(i).find(".data-displayed").val());
							displayed = Utils.escapeHTML(displayed);
						
						
						vpAry.push({stored: stored, displayed: displayed});
					}
					return vpAry;
				},
				add: function (rootNode) {
					rootNode.find("button.data-value-pairs-add").click();
				},
				focusFirst: function (rootNode) {
					var valuePairsObj = rootNode.find("tbody.data-value-pairs:first").children("tr:visible:first");
					if (valuePairsObj.length == 0)
					{
						util.valuePair.add(rootNode);
						valuePairsObj = rootNode.find("tbody.data-value-pairs:first").children("tr:visible:first");
					}
					
					valuePairsObj.find("input:first").select();
				}
			},
			accept: function (rootNode) {
				rootNode.find("div.ui-dialog-buttonpane button:last").click();
			}
		};
		
		var buttonsOption = {};
		buttonsOption[PromptDialog.LANG.Cancel] = function () {
			//再這裡加上檢查
			var source = jQuery("tr.field-data-source:first");
			
			var names = ["schema", "element", "qualifier", "label"];
			var defaultValues = ["dc", "title", "", ""];
			
			var delFlag = true;
			for (var i = 0; i < names.length; i++)
			{
				var value = util.getSource(source, names[i]);
				
				//result.push((value == defaultValue[i]));
				var diff = (value != defaultValues[i]);
				
				if (diff == true)
				{
					delFlag = false;
					break;
				}
			}
			
			if (delFlag == true)
			{
				window.alert(LANG.fieldNullDelete);
				source.remove();
			}
			
			jQuery(this).dialog("close");
		};
		buttonsOption[PromptDialog.LANG.Accept] = function () {
			var rootNode = Utils.getDialogRoot(this);
			
			rootNode.dialog("disable");
			
			var source = jQuery("tr.field-data-source:first");
			
			//schema, element, qualifier
			//var schema = rootNode.find(".data-schema").val();
			//var element = rootNode.find(".data-element:visible").val();
			//var qualifierSelect = rootNode.find(".data-qualifier:visible");
			//if (qualifierSelect.length = "")
			//	var qualifier = "";
			//else
			//	var qualifier = qualifierSelect.val();
			
			//source.find(".data-schema").val(schema);
			//source.find(".data-element").val(element);
			//source.find(".data-qualifier").val(qualifier);
			
			//util.setDataToSource(rootNode, source, "schema");
			//util.setDataToSource(rootNode, source, "element");
			//util.setDataToSource(rootNode, source, "qualifier");
			var metadata = util.getMetadata(rootNode);
			
			//檢查所有的metadata吧！（天啊好麻煩
			var nowForm = source.parents("div.form-editor:first");
			var fields = nowForm.find("div.page-content > table.page-content-table > tbody.page-content-tbody > tr.field:not(.field-data-source)");
			for (var i = 0; i < fields.length; i++)
			{
				var sourceMetadata = util.getSourceMetadata(fields.eq(i));
				if (util.metadataEqual(metadata, sourceMetadata))
				{
					alert(LANG.fieldUnavailable1 
						+ util.metadataToString(metadata) 
						+ LANG.fieldUnavailable2);
					util.focusData(rootNode, ".field-select:first");
					rootNode.dialog("enable");
					return;
				}
			}
			
			var label = util.getData(rootNode, "label");
			
			if (label == "")
			{
				alert(LANG.labelRequire);
				util.focusData(rootNode, "label");
				rootNode.dialog("enable");
				return;
			}
			
			//alert([metadata.schema, metadata.element, metadata.qualifier]);
			util.setSource(source, "schema", metadata.schema);
			util.setSource(source, "element", metadata.element);
			util.setSource(source, "qualifier", metadata.qualifier);
			
			util.setSource(source, "label", label);
			
			var inputType = util.getData(rootNode, "input-type");
			util.setSource(source, "input-type", inputType);
			
			var hint = util.getData(rootNode, "hint");
			//setTimeout(function () {
				util.setSource(source, "hint", hint);
			//}, 10);
			
			//required
			var requiredFalse = rootNode.find(".required-false:first");
			if (requiredFalse.attr("checked") != "")
				util.setSource(source, "required", "");
			else
				util.setDataToSource(rootNode, source, "required");
			
			//repeatable
			var repeatableInput = rootNode.find(".data-repeatable-false:first");
			if (repeatableInput.attr("checked") != "")
				var repeatable = "false";
			else
				var repeatable = "true";
			util.setSource(source, "repeatable", repeatable);
			
			//value-pairs
			var valuePairsObj = rootNode.find("tbody.data-value-pairs:first").children("tr:visible");
			var valuePairs = util.valuePair.parse(valuePairsObj);
			if ((inputType == "list" || inputType == "dropdown"  || inputType == "qualdrop_value" ) 
				&& valuePairs.length == 0)
			{
				alert(LANG.valuePairRequire1+inputType+LANG.valuePairRequire2);
				util.valuePair.focusFirst(rootNode);
				rootNode.dialog("enable");
				return;
			}
			
			if (inputType == "qualdrop_value")
			{
				if (metadata.qualifier != "")
				{
					alert(LANG.qualdrop_value_note1+inputType+LANG.qualdrop_value_note2);
					rootNode.find("button.field-select:first").focus();
					rootNode.dialog("enable");
					return;
				}
				
				//如果沒有available_qualifier
				if (typeof(aq) == "undefined")
				{
					var aqURL = Utils.getContextPath() + "/extension/input-forms-edit/query-available-qualifier.jsp?callback=?"
						+ "&schema=" + metadata.schema
						+ "&element=" + metadata.element;
					jQuery.getJSON(aqURL, function (data) {
						//保存在available_qualifier當中
						aq = data;
						
						//再次點下確認按鍵
						util.accept(rootNode);
					});
					return;
				}
				else	//如果有
				{
					var available_qualifier = aq;
					delete aq;	//刪除available_qualifier
					
					
					//檢查valuePairs是否吻合
					var beyondScope = false;
					for (var i = 0; i < valuePairs.length; i++)
					{
						var s = valuePairs[i].stored;
						var found = jQuery.inArray(s, available_qualifier);
						if (found == -1)
						{
							beyondScope = true;
							break;
						}
					}
					
					//如果超出範圍，則跳出對話視窗，幫忙重整
					if (beyondScope == true)
					{
						if (window.confirm(LANG.qualdrop_value_match1+inputType+LANG.qualdrop_value_match2
								+ metadata.schema + "." + metadata.element
								+ LANG.qualdrop_value_match3))
						{
							
						}
						
						util.valuePair.focusFirst(rootNode);
						rootNode.dialog("enable");
						return;
					}
				}
			}
			
			var sourceVP = source.find(".data-value-pairs:first").empty();
			for (var i = 0; i < valuePairs.length; i++)
			{
				var stored = valuePairs[i].stored;
				var displayed = valuePairs[i].displayed;
				
				var option = jQuery("<option value=\""+stored+"\">"+displayed+"</option>")
					.appendTo(sourceVP);
			}
			
			//default-value
			//var defaultValue = rootNode.find(".data-default-value").val();
			//source.find(".data-default-value").val(defaultValue);
			util.setDataToSource(rootNode, source, "default-value");
			
			
			//source.find(".data-input-type").change();
			Utils.setFieldPreview(source);
			
			jQuery(this).dialog("close");
			rootNode.dialog("enable");
		};
		
		var dialogOption = {
			bgiframe: true,
			autoOpen: false,
			//height: (window.innerHeight - 100),
			//width: (window.innerWidth - 100),
			height: "auto",
			width: 640,
			autoResize:false,
			modal: true,
			resizable: false,
			buttons: buttonsOption,
			stack: false,
			close: function(event, ui)
			{
				var source = jQuery("tr.field-data-source:first");
				if (source.length == 1)
				{
					//source.animate({
					//	backgroundColor: "#FFFFFF"
					//}, 1000);
					source.removeClass("field-data-source");
					//source.removeClass("focus");
				}				
			},
			open: function(event, ui)
			{
				var rootNode = jQuery("#prompt_field_editor");
				var rootDialog = rootNode.parents("div.ui-dialog:first");

				if (rootNode.hasClass("inited") == false)
				{
					rootNode.find("input.data-schema:first").change(function () {
						var s = this.value;
						var e = rootNode.find("input.data-element:first").val();
						var q = rootNode.find("input.data-qualifier:first").val();
						var output = s+"."+e;
						if (q != "")
							output = output + "." + q;
						
						var btn = rootNode.find("button.field-select:first");
						btn.html(output);
					});
					
					var btn = rootNode.find("button.field-select:first").click(function () {
						jQuery("#prompt_metadata_field_selector").dialog("open");
					});
					
					//處理一下pair的按鈕吧
					rootNode.find("input.data-displayed").change(function () {
						var store = jQuery(this).parents("tr:first").find("input.data-stored:first");
						if (jQuery.trim(store.val()) == "" && this.value != "N/A")
							store.val(jQuery.trim(this.value));
					});
					
					rootNode.find("button.data-value-pairs-del").click(function () {
						//先確認值
						var display = jQuery.trim(jQuery(this).parents("tr:first").find("input.data-displayed").val());
						var stored = jQuery.trim(jQuery(this).parents("tr:first").find("input.data-stored").val());
						
						if (display != "" || stored != "")
						{
							if (window.confirm(PromptDialog.LANG.DeleteConfirm) == false)
								return;
						}
						
						var tr = jQuery(this).parents("tr:first");
						tr.remove();
					});
					
					rootNode.find("button.data-value-pairs-moveup").click(function () {
						var tr = jQuery(this).parents("tr:first");
						tr.prevAll("tr:first").before(tr);
						tr.find("button.data-value-pairs-moveup").focus();
					});
					
					rootNode.find("button.data-value-pairs-movedown").click(function () {
						var tr = jQuery(this).parents("tr:first");
						tr.nextAll("tr:first").after(tr);
						tr.find("button.data-value-pairs-movedown").focus();
					});
					
					rootNode.find("button.data-value-pairs-add").click(function () {
						var template = jQuery(this).parents("table:first").find("tr.data-value-pairs-template:last")
							.clone(true)
							.show().removeClass("data-value-pairs-template");
						jQuery(this).parents("table:first").find("tr.data-value-pairs-template:first").before(template);
						
						//定位到新增的表單，然後再回來這個位置
						template.find("input:first").focus();
						jQuery(this).focus();
					});
					
					rootNode.find("button.edit-default-value").click(function () {
						var source = jQuery(this).nextAll("textarea.data-default-value:first").val();
						jQuery("div#prompt_xmlmetadata_editor").find("textarea.xmlmetadata-source:first").val(source);
						jQuery("div#prompt_xmlmetadata_editor").dialog("open");
					});
					
					//輸入型態調整
					rootNode.find("select.data-input-type").change(function () {
						switch(this.value)
						{
							case 'xmlmetadata':
								rootNode.find("tr.tr-value-pairs").hide();
								rootNode.find("tr.tr-default-value").show()
								
								rootNode.find("tr.tr-default-value").find("textarea.data-default-value").select();
								break;
							case 'dropdown':
							case 'list':
							case 'qualdrop_value':
								rootNode.find("tr.tr-value-pairs").show();
								rootNode.find("tr.tr-default-value").hide();
								
								var focus = rootNode.find("tr.tr-value-pairs").find("input.data-displayed:visible:first");
								if (focus.length > 0)
								{
									focus.select();
								}
								else
								{
									rootNode.find("tr.tr-value-pairs").find("button.data-value-pairs-add")
										.click();
									focus = rootNode.find("tr.tr-value-pairs").find("input.data-displayed:visible:first");
									focus.select();
								}
								break;
							default:
								rootNode.find("tr.tr-value-pairs").hide();
								rootNode.find("tr.tr-default-value").hide();
						}	//switch(this.value)
						
						//強迫會使用重複的型態
						if (this.value == "twobox"
							|| this.value == "qualdrop_value")
						{
							rootNode.find("tr td input:radio:.data-repeatable-true").click();
							rootNode.find("tr td input:radio:.data-repeatable-false").attr("disabled", "disabled");
						}
						else
						{
							rootNode.find("tr td input:radio:.data-repeatable-false").removeAttr("disabled");
						}
					});
					
					
					
					rootNode.addClass("inited");
				}	//if (rootNode.hasClass("inited") == false)
				Utils.initFCKEditor(rootNode, false);
				
				//總算做完基礎表單了，接下來是輸入資料
				var source = jQuery("tr.field-data-source:first");
				
				if (source.length > 0)
				{
					var schema = util.getSource(source, "schema");
					var element = util.getSource(source, "element");
					var qualifier = util.getSource(source, "qualifier");
					util.setMetadata(rootNode, schema, element, qualifier);
					
					//label, hint
					//var label = source.find(".data-label:first").val();
					//rootNode.find(".data-label:first").val(label);
					util.setSourceToData(source, rootNode, "label");
					
					//var hint = source.find(".data-hint:first").val();
					//rootNode.find(".data-hint:first").attr("value", hint);
					util.setSourceToData(source, rootNode, "hint");
					
					//required
					//var required = source.find(".data-required:first").val();
					var required = util.getSource(source, "required");
					if (required == "")
					{
						rootNode.find(".required-false").attr("checked", "checked");
						rootNode.find(".required-true").removeAttr("checked");
						rootNode.find(".data-required").val("").attr("disabled","disabled");
					}
					else
					{
						rootNode.find(".required-true").attr("checked", "checked");
						rootNode.find(".required-false").removeAttr("checked");
						rootNode.find(".data-required").val(required).removeAttr("disabled");
					}
					
					//repeatable
					//var repeatable = source.find(".data-repeatable:first").val();
					var repeatable = util.getSource(source, "repeatable");
					if (repeatable == "true")
					{
						rootNode.find(".repeatable-true").attr("checked", "checked");
						rootNode.find(".repeatable-false").removeAttr("checked");
					}
					else
					{
						rootNode.find(".repeatable-false").attr("checked", "checked");
						rootNode.find(".repeatable-true").removeAttr("checked");
					}
					
					//value-pairs
					var valuePairs = source.find(".data-value-pairs:first").children("option");
					var tbody = rootNode.find("tbody.data-value-pairs:first");
					tbody.children("tr:not(.data-value-pairs-template)").remove();
					for (var i = 0; i < valuePairs.length; i++)
					{
						var stored = valuePairs.eq(i).attr("value");
							stored = Utils.unescapeHTML(stored);
						var displayed = valuePairs.eq(i).attr("innerHTML");
							displayed = Utils.unescapeHTML(displayed);
						
						var template = tbody.find("tr.data-value-pairs-template:last")
							.clone(true)
							.show().removeClass("data-value-pairs-template");
						tbody.find("tr.data-value-pairs-template:last").before(template);
						
						var tr = tbody.children("tr:not(.data-value-pairs-template):last");
						tr.find(".data-displayed:first").val(displayed);
						tr.find(".data-stored:first").val(stored);
					}
					
					//default-value
					//var defaultValue = source.find(".data-default-value").val();
					//rootNode.find(".data-default-value").val(defaultValue);
					util.setSourceToData(source, rootNode, "default-value");
					
					//input-type
					//var inputType = source.find(".data-input-type").val();
					var inputType = util.getSource(source, "input-type");
					var inputTypeSelect = rootNode.find(".data-input-type");
					inputTypeSelect.children("option[value='"+inputType+"']").attr("selected","selected");
					inputTypeSelect.children("option:not([value='"+inputType+"'])").removeAttr("selected");
					inputTypeSelect.change();
					
					jQuery(this).dialog("option","position", "center");
				}
			}
		};
		
		jQuery("#prompt_field_editor").dialog(dialogOption);
	};