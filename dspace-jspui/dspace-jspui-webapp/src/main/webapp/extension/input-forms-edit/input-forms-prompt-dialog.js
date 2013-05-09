var PromptDialog = {
	"FormNameUpadte": function () {
		
		
		var buttonsOption = {};
		buttonsOption[PromptDialog.LANG.Cancel] = PromptDialog.Buttons.Cancel;
		buttonsOption[PromptDialog.LANG.Accept] = function () {
			var newName = jQuery(this).find("input.form-name[type='text']:first").val();
			
			if (typeof(newName) != "undefined" && newName != "")
			{
				var formSelect = jQuery("select#form_select");
				var selectedOption = formSelect.children(":selected:first");
				
				selectedOption.attr("value", newName);
				selectedOption.attr("innerHTML", newName);
				formSelect.val(newName);

			}
			jQuery(this).dialog("close");
		};
		
		var dialogOption = {
			bgiframe: true,
			autoOpen: false,
			height: 160,
			width: 330,
			modal: true,
			resizable: false,
			buttons: buttonsOption,
			open: function(event, ui)
			{
				
				var oldName = jQuery("select#form_select").val();
				var rootNode = jQuery(this).parents("div.ui-dialog:first");
				var inputFormName = rootNode.find("input.form-name[type='text']:first");
				inputFormName.val(oldName);
				if (rootNode.hasClass("inited") == false)
				{
					rootNode.find("button:contains('"+PromptDialog.LANG.Accept+"')").addClass("accept");
					inputFormName.keyup(function () {Utils.checkFormName(this);});
					rootNode.addClass("inited");
				}
				inputFormName.keyup();
			}
		};
		
		jQuery("#prompt_form_name_update").dialog(dialogOption);
	},
	"FormNameAdd": function () {
		var buttonsOption = {};
		buttonsOption[PromptDialog.LANG.Cancel] = PromptDialog.Buttons.Cancel;
		buttonsOption[PromptDialog.LANG.Accept] = function () {
			var newName = jQuery(this).find("input.form-name[type='text']:first").val();
			
			if (typeof(newName) != "undefined" && newName != "")
			{
				var formSelect = jQuery("select#form_select");
				formSelect.children("option").removeAttr("selected");
				var option = jQuery("<option value=\""+newName+"\" selected=\"selected\">"+newName+"</option>")
					.appendTo(formSelect);
				
				
				var formEditor = jQuery("#form_collection:first");
				formEditor.children("div.form-editor").hide();
				var editor = FormCollection.createFormEditor();
				
				if (typeof(defaultHandle) != "undefined"
					&& defaultHandle != "")
				{
					editor.find("input.collection-handle.text:first").val(defaultHandle);
					defaultHandle = "";
				}
				
				editor.appendTo(formEditor);
				editor.find("td:visible.field-function:first button.edit:first").click();
			}
			jQuery(this).dialog("close");
		};
		
		var dialogOption = {
			bgiframe: true,
			autoOpen: false,
			height: 160,
			width: 330,
			modal: true,
			resizable: false,
			buttons: buttonsOption,
			open: function(event, ui)
			{
				var rootNode = jQuery(this).parents("div.ui-dialog:first");
				var inputFormName = rootNode.find("input.form-name[type='text']:first");
				inputFormName.val("");
				if (rootNode.hasClass("inited") == false)
				{
					rootNode.find("button:contains('"+PromptDialog.LANG.Accept+"')").addClass("accept");
					inputFormName.keyup(function () {Utils.checkFormName(this);});
					rootNode.addClass("inited");
				}
				
				var defaultHandle = Utils.getDefaultHandle();
				if (typeof(defaultHandle) != "undefined"
					&& defaultHandle != "")
				{
					var h = defaultHandle;
					h = Utils.replaceAll(h, "/", "_");
					rootNode.find("input.form-name.text:first").val(h);
				}
				
				inputFormName.keyup();
			}
		};
		
		jQuery("#prompt_form_name_add").dialog(dialogOption);
	},
	"Processing": function (callback) {
		jQuery("#prompt_processing").dialog({
			bgiframe: true,
			autoOpen: true,
			height: 110,
			width: 330,
			modal: true,
			resizable: false,
			open: function () {
				jQuery("#prompt_processing").parents(".ui-dialog:first").find(".ui-icon-closethic, .ui-dialog-titlebar-close").hide();
				if (typeof(callback) != "undefined")
				{
					setTimeout(function () {
						//try
						//{
							callback();
						//}
						//catch (e) { alert("Processing callback error!"); }
					}, 100);
				}
			}
		});
	},
	"ProcessingSave": function () {
		jQuery("#prompt_processing_save").dialog({
			bgiframe: true,
			autoOpen: false,
			height: 110,
			width: 330,
			modal: true,
			draggable: false,
			resizable: false,
			open: function () {
				jQuery("#prompt_processing_save").parents(".ui-dialog:first").find(".ui-icon-closethic, .ui-dialog-titlebar-close").hide();
			}
		});
	},
	"PageAttr": function () {
		var buttonsOption = {};
		buttonsOption[PromptDialog.LANG.Cancel] = PromptDialog.Buttons.Cancel;
		buttonsOption[PromptDialog.LANG.Accept] = function () {
			var rootNode = Utils.getDialogRoot(this);
			rootNode.find("input.page-label").focus();
			var label = rootNode.find("input.page-label").val();
				label = jQuery.trim(label);
			
			var pagePreview = jQuery("#form_collection .form-editor:visible .page-editor:visible .page-content:visible table thead tr td.preview");
			pagePreview.find("input.page-label:first").val(label).change();
			
			setTimeout(function() {
				var hint = rootNode.find("textarea.page-hint").attr("value");
					hint = jQuery.trim(hint);
				pagePreview.find("input.page-hint:first").val(hint).change();
			}, 100);
			
			jQuery(this).dialog("close");
		};
		
		var dialogOption = {
			bgiframe: true,
			autoOpen: false,
			height: 200,
			width: 530,
			modal: true,
			resizable: false,
			buttons: buttonsOption,
			open: function(event, ui)
			{
				var rootNode = jQuery("#prompt_page_attr");
				if (rootNode.hasClass("inited") == false)
				{
					Utils.initFCKEditor(rootNode);
					rootNode.addClass("inited");
				}
				
				var label = "";
				var hint = "";
				if (typeof(PARAMETER) == "object")
				{
					var label = PARAMETER.label;
					rootNode.find("input.page-label:first").val(label);
					var hint = PARAMETER.hint;
					rootNode.find("textarea.page-hint:first").val(hint);
				}
			}
		};
		
		jQuery("#prompt_page_attr").dialog(dialogOption);
	},
	"XMLMetadataEditor": function () {
		var buttonsOption = {};
		buttonsOption[PromptDialog.LANG.Cancel] = PromptDialog.Buttons.Cancel;
		buttonsOption[PromptDialog.LANG.Accept] = function () {
			var thisDialog = this;
			var rootNode = Utils.getDialogRoot(thisDialog);
			//alert(rootNode.find("div.xmlmetadata-controller:first input:radio.source:first").length);
			//先偵測現在的模式
			var radioSource = rootNode.find("div.xmlmetadata-controller:first input:radio.source:first");
			if (radioSource.attr("checked") == false)
				rootNode.find("div.xmlmetadata-controller:first input:radio.source:first").click();
			
			setTimeout(function () {
				var source = rootNode.find("textarea.source:first").val();
			
				//alert(source);
				jQuery("div#prompt_field_editor textarea.data-default-value").val(source);
				
				jQuery(thisDialog).dialog("close");
			},100);
		};
		
		var dialogOption = {
			bgiframe: true,
			autoOpen: false,
			height: "auto",
			width: 800,
			//modal: true,
			resizable: false,
			buttons: buttonsOption,
			open: function(event, ui)
			{
				var rootNode = jQuery("#prompt_xmlmetadata_editor");
				
				var sourceXML = rootNode.find(".xmlmetadata-source:first").val();
				var source = jQuery("<textarea class=\"xmlmetadata-source source\"></textarea>").val(sourceXML);
				
				rootNode.empty().append(source);
				//var source = rootNode.find(".source:first");
				source.XMLMetadataEditor();
				rootNode.find("div.xmlmetadata-controller:first input:radio.editor:first").click();
				rootNode.dialog("option", "position", "center");
			}
			/*,close: function () {
				alert(121);
				jQuery("#prompt_field_editor").dialog("moveToTop");
			}*/
		};
		
		jQuery("#prompt_xmlmetadata_editor").dialog(dialogOption);
		//var rootNode = jQuery("#prompt_xmlmetadata_editor");
		//var source = rootNode.find(".source:first");
		//source.XMLMetadataEditor();
	},
	"FieldAdd": function () {
		var LANG = PromptDialog.LANG.FieldAdd;
		
		var id = "#prompt_field_add";
		var buttonsOption = {};
		buttonsOption[PromptDialog.LANG.Cancel] = PromptDialog.Buttons.Cancel;
		buttonsOption[PromptDialog.LANG.Accept] = function () {
			var root = Utils.getDialogRoot(this);
			
			var schema = root.find("input.schema.text:first");
			var element = root.find("input.element.text:first");
			var qualifier = root.find("input.qualifier.text:first");
			var note = root.find("input.scope-note.text:first");
			var schemaValue = jQuery.trim(schema.val());
			var elementValue = jQuery.trim(element.val());
			var qualifierValue = jQuery.trim(qualifier.val());
			var noteValue = jQuery.trim(note.val());
			if (schemaValue != ""
				&& elementValue != "")
			{
				//執行新增
				root.find("div.ui-dialog-buttonpane button:last").html(PromptDialog.LANG.WaitMessage);
				jQuery(id).dialog("disable");
				
				var url = Utils.getContextPath() + "/extension/input-forms-edit/input-forms-add-field.jsp?callback=?";
				var search = "";
				if (schemaValue != "")
					search = search + "&schema=" + schemaValue;
				if (elementValue != "")
					search = search + "&element=" + elementValue;
				if (qualifierValue != "")
					search = search + "&qualifier=" + qualifierValue;
				if (noteValue != "")
					search = search + "&note=" + noteValue;
				
				url = url + search;
				
				jQuery.getJSON(url, function (data) {
					var state = data.state;
					
					if (state == "create_schema"
						|| state == "create_field")
					{
						jQuery(id).dialog("close");
						jQuery(id).dialog("enable");
						
						//要讓某個東西click才行
						jQuery("div#prompt_field_editor button.metadata_field_reload:first").click();
					}
					else
					{
						alert(LANG.exception+state);
						jQuery(id).dialog("enable");
					}
				});
			}
			else
			{
				alert(LANG.schemaAndElementRequire);
				if (schemaValue == "")
					root.find("input.schema.text:first").focus();
				else
					root.find("input.element.text:first").focus();
			}
		};
		
		var dialogOption = {
			bgiframe: true,
			autoOpen: false,
			height: 200,
			width: 600,
			//modal: true,
			resizable: false,
			buttons: buttonsOption,
			open: function(event, ui)
			{
				
	            if (typeof(findValue) != "function") 
	            {
		            function findValue(li) {
		                if (li == null) return alert("Not match!");
		                schema.val(li.extra[0]);
		                //$("#txtCName").val(li.extra[1]);
		            }
		        }
		        
				var schema = jQuery(id).find("input.schema.text:first");
				var element = jQuery(id).find("input.element.text:first");
				var qualifier = jQuery(id).find("input.qualifier.text:first");
				var note = jQuery(id).find("input.scope-note.text:first");
				schema.val("");
				element.val("");
				qualifier("");
				note("");
		        
		        var autocompleteOption = {
	                delay: 10,
	                width: 190,
	                minChars: 0, //至少輸入幾個字元才開始給提示?
	                matchSubset: true,
	                matchContains: true,
	                highlightItem: true,
	                cacheLength: 0, 
	                noCache: true, //黑暗版自訂參數，每次都重新連後端查詢(適用總資料筆數很多時)
	                onItemSelect: findValue,
	                onFindValue: findValue,
	                extraParams: {
	                	schema: function () {
	                		return schema.val();
	                	},
	                	element: function () {
	                		return element.val();
	                	}
	                },
	                formatItem: function(row) {
	                	var output = row[0];
	                    return "<div style='height:12px'>" + row[0] +
	                            "</div>";
	                },
	                autoFill: false,
	                mustMatch: false //是否允許輸入提示清單上沒有的值?
	            };
				
				var schemaURL = Utils.getContextPath() + "/extension/input-forms-edit/query-schema.jsp";
				var elementURL = Utils.getContextPath() + "/extension/input-forms-edit/query-element.jsp";
				var qualifierURL = Utils.getContextPath() + "/extension/input-forms-edit/query-qualifier.jsp"
				schema.autocomplete(schemaURL
					, autocompleteOption);
				element.autocomplete(elementURL
					, autocompleteOption);
				qualifier.autocomplete(qualifierURL
					, autocompleteOption);
				
				/*
				var updateAutocomplete = function () {
					var surl = schemaURL;
					var eurl = elementURL;
					var qurl = qualifierURL;
					var schemaValue = jQuery.trim(schema.val());
					if (schemaValue != "")
					{
						eurl = eurl + "?schema="+schemaValue;
						qurl = qurl + "?schema="+schemaValue;
					}
					var elementValue = jQuery.trim(element.val());
					if (schemaValue != "" && elementValue != "")
					{
						qurl = qurl + "&element="+elementValue;
					}
					
					element.autocomplete(eurl
						, autocompleteOption);
					qualifier.autocomplete(qurl
						, autocompleteOption);
				};
				
				schema.change(updateAutocomplete);
				element.change(updateAutocomplete);
				*/
			}
		};
		
		jQuery(id).dialog(dialogOption);
	},
	MetadataFieldSelector: function () {
		var LANG = PromptDialog.LANG.MetadataFieldSelector;
		
		var rootNode = jQuery("#prompt_metadata_field_selector");
		
		var util = {
			loadSchema: function (callback) {
				//載入schema
				var schemaSelector = rootNode.find("select.schema-selector:first");
				schemaSelector.empty();
				
				var optgroup = jQuery("<optgroup label=\""+LANG.schemaAndNamespace+"\"></optgroup>")
					.appendTo(schemaSelector);
				
				var optionWrapper = function (schema, namespace) {
					var stored = Utils.escapeHTML(schema);
					var displayed = Utils.unescapeHTML(schema + " - " + namespace);
					var opt = jQuery("<option value=\""+stored+"\" namespace=\""+namespace+"\">"+displayed+"</option>");
					return opt;
				};
				
				var schemaURL = Utils.getContextPath() + "/extension/input-forms-edit/json-schema.jsp?callback=?";
				//alert(schemaURL);
				jQuery.getJSON(schemaURL, function (schemas) {
					for (var i = 0; i < schemas.length; i++)
					{
						var s = schemas[i][0];
						var n = schemas[i][1];
						var opt = optionWrapper(s, n);
						opt.appendTo(optgroup);
					}
					schemaSelector.addClass("inited");
					
					schemaSelector.change(function () {
						util.loadField();
						
						var opt = jQuery(this).find("option:selected:first");
						if (opt.length == 0)
							opt = jQuery(this).find("option:first");
						
						var temp = opt.html().split(" - ");
						var s = temp[0];
						var n = temp[1];
						util.setAddField(s, n);
					});
					
					//讀取值
					var schema = rootNode.find("input:hidden:data-schema:first").val();
					schemaSelector.val(schema)
						.change();
					
					if (typeof(callback) == "function")
						callback();
					
				});
			},
			isSchemaReady: function () {
				var schemaSelector = rootNode.find("select.schema-selector:first");
				return schemaSelector.hasClass("inited");
			},
			getSchema: function () {
				if (util.isSchemaReady() == false)
				{
					alert("schema is not ready.");
					return "";
				}
				
				var s = "";
				//try {
					var schemaSelector = rootNode.find("select.schema-selector:first");
					s = schemaSelector.val();
				//} catch (e) {}
				return s;
			},
			getSchemaNamespace: function () {
				if (util.isSchemaReady() == false)
				{
					alert("schema is not ready.");
					return "";
				}
				
				//try {
					var schemaSelector = rootNode.find("select.schema-selector:first optgroup");
					var opt = schemaSelector.children("option:selected:first");
					if (opt.length == 0)
						schemaSelector.children("option:first");
					var s = opt.attr("value");
					var n = opt.attr("namespace");
				//} catch (e) {}
				return {
					schema: s,
					namespace: n
				};
			},
			setAddField: function (schema, namespace, element, qualifier, note) {
				var fieldAdd = rootNode.find("td.field-add:first");
				
				if (typeof(schema) == "undefined")
					schema = "";
				fieldAdd.find("input.schema:first").val(schema);
				
				if (typeof(element) == "undefined")
					element = "";
				fieldAdd.find("input.element:first").val(element);
				
				if (typeof(namespace) == "undefined")
					namespace = "";
				fieldAdd.find("input.namespace:first").val(namespace);
				
				if (typeof(qualifier) == "undefined")
					qualifier = "";
				fieldAdd.find("input.qualifier:first").val(qualifier);
				
				if (typeof(note) == "undefined")
					note = "";
				fieldAdd.find(".note:first").val(note);
			},
			isAddMode: function () {
				//return (rootNode.find("tr.field-add:visible").length == 1);
				return (rootNode.find("tr.field-add:first").css("display") != "none")
			},
			loadField: function () {
				if (util.isSchemaReady() == false)
				{
					setTimeout(function () {
						util.loadField();
					}, 500);
					return;
				}
				
				//讀取欄位值
				var fieldSelector = rootNode.find("tbody.field-selector:first");
				fieldSelector.empty();
				
				var fieldURL = Utils.getContextPath() + "/extension/input-forms-edit/json-field.jsp?callback=?";
				var nowSchema = util.getSchema();
				if (nowSchema != "")
					fieldURL = fieldURL + "&schema=" + nowSchema;
				jQuery.getJSON(fieldURL, function(data) {
					for (var i = 0; i < data.length; i ++)
					{
						var s = data[i][0];
						var e = data[i][1];
						var q = data[i][2];
						var n = data[i][3];
							n = unescape(n);
						
						var opt = util.fieldWrapper(s, e, q, n);
						opt.appendTo(fieldSelector);
					}
					
					fieldSelector.addClass("inited");
					util.selectDefaultField();
					util.dialogCenter();
				});
			},
			fieldWrapper: function (s, e, q, n) {
				var template = jQuery("<tr class=\"field-selector-tr\"><th width=\"50\"><input type=\"radio\" name=\"field-selector-radio\" value=\"\" /></th><td class=\"field-metadata\"></td></tr>");
				var fieldMetadata = template.find("td.field-metadata:first");
				
				var title = jQuery("<div><span class=\"metadata\" style=\"font-weight:bold;\">" + s + "." + e + "</span></div>");
				if (q != "")
					title.find("span.metadata:first").append("." + q);
				title.appendTo(fieldMetadata);
				
				n = jQuery.trim(n);
				if (n != "")
				{
					var summary = n;
					var limit = 25;
					if (summary.length > limit)
						summary = jQuery.trim(summary.substring(0, limit)) + "...";
					
					var temp = summary.split("\r");
					output = "";
					for (var i = 0; i < temp.length; i++)
						output = output + jQuery.trim(temp[i]);
					summary = output;
					
					jQuery("<pre class=\"summary\"></pre>")
						.html(summary)
						.css("float", "right")
						.prependTo(title);
					
					var note = jQuery("<div class=\"note\" style=\"display:none\">"+n+"</div>")
						.appendTo(fieldMetadata);
				}
				jQuery("<input type=\"hidden\" class=\"schema\" value=\""+s+"\" />").appendTo(fieldMetadata);
				jQuery("<input type=\"hidden\" class=\"element\" value=\""+e+"\" />").appendTo(fieldMetadata);
				jQuery("<input type=\"hidden\" class=\"qualifier\" value=\""+q+"\" />").appendTo(fieldMetadata);
				
				//先處理hover
				template.hover(function () { util.fieldMouseOver(jQuery(this)); }
					, function () { util.fieldMouseOut(jQuery(this)); });
				
				//後處理radio
				var radio = template.find("input:radio:first");
				radio.change(function () {
					var template = jQuery(this).parents("tr.field-selector-tr:first");
					if (template.hasClass("selected") == true)
						return;
					
					var fieldSelector = template.parents("tbody.field-selector:first");
					var others = fieldSelector.children(".selected");	//.removeClass("selected");
					for (var i = 0; i < others.length; i++)
					{
						others.eq(i).removeClass("selected");
						util.fieldMouseOut(others.eq(i));
					}
					
					util.fieldMouseOver(template);
					template.addClass("selected");
				});
				
				template.click(function () {
					var template = jQuery(this);
					var radio = template.find("input:radio:first");
					radio.attr("checked", "checked").change();
				});
				
				return template;
			},
			fieldMouseOver: function (template)
			{
				if (template.hasClass("selected"))
					return;
				
				var fieldSelector = template.parents("tbody.field-selector:first");
				var others = fieldSelector.children(".hover");	//.removeClass("selected");
				others.removeClass("hover");
				
				template.addClass("hover");
				
				var summary = template.find(".summary:first");
				if (summary.length == 0)
					return;
				
				summary.hide();
				var note = template.find("div.note:first")
					.show();
			},
			fieldMouseOut: function (template)
			{
				if (template.hasClass("selected"))
					return;
				
				//template.removeClass("hover");
				var fieldSelector = template.parents("tbody.field-selector:first");
				var others = fieldSelector.children(".hover");	//.removeClass("selected");
				others.removeClass("hover");
				
				var summary = template.find(".summary:first");
				if (summary.length == 0)
					return;
				summary.show();
				var note = template.find("div.note:first")
					.hide();
			},
			selectDefaultField: function () {
				var metadata = util.getData();
				var selector = rootNode.find("tbody.field-selector");
				var fields = selector.find("tr > td.field-metadata");
				for (var i = 0; i < fields.length; i++)
				{
					var f = fields.eq(i);
					var s = f.find("input:hidden.schema:first").val();
					var e = f.find("input:hidden.element:first").val();
					var q = f.find("input:hidden.qualifier:first").val();
					
					if (s == metadata.schema
						&& e == metadata.element
						&& q == metadata.qualifier)
					{
						//找到目標了
						var field = f.parents("tr:first");
						field.click();
						//field.focus();
						selector.prepend(field);
						break;
					}
				}
			},
			getSource: function () {
				var source = jQuery("#prompt_field_editor");
				var sourceSchema = source.find("input.data-schema:first").val();
				var sourceElement = source.find("input.data-element:first").val();
				var sourceQualifier = source.find("input.data-qualifier:first").val();
				
				return {schema: sourceSchema, element: sourceElement, qualifier: sourceQualifier};
			},
			setSource: function (schema, element, qualifier)
			{
				if (typeof(schema) == "undefined")
					schema = util.getData();
				
				if (typeof(schema) == "object"
					&& typeof(element) == "undefined"
					&& typeof(qualifier) == "undefined")
				{
					element = schema.element;
					qualifier = schema.qualifier;
					schema = schema.schema;
				}
				
				var source = jQuery("#prompt_field_editor");
				var s = source.find("input.data-schema:first").val(schema);
				source.find("input.data-element:first").val(element);
				source.find("input.data-qualifier:first").val(qualifier);
				s.change();
			},
			focusSource: function () {
				var source = jQuery("#prompt_field_editor");
				source.find("button.field-select:first").focus();
			},
			setData: function (schema, element, qualifier)
			{
				if (typeof(schema) == "object"
					&& typeof(element) == "undefined"
					&& typeof(qualifier) == "undefined")
				{
					element = schema.element;
					qualifier = schema.qualifier;
					schema = schema.schema;
				}
				
				rootNode.find("input:hidden.data-schema").val(schema);
				rootNode.find("input:hidden.data-element").val(element);
				rootNode.find("input:hidden.data-qualifier").val(qualifier);
				
				rootNode.find("input:hidden.data-schema").change();
			},
			getData: function () {
				var s = rootNode.find("input.data-schema:first").val();
				var e = rootNode.find("input.data-element:first").val();
				var q = rootNode.find("input.data-qualifier:first").val();
				
				return {schema: s, element: e, qualifier: q};
			},
			dialogCenter: function () {
				rootNode.dialog("option", "position", "center");
			},
			getFieldAdd: function (field, doVaild) {
				var f = rootNode.find("td.field-add:first ."+field+":first");
				var v = f.val();
				v = jQuery.trim(v);
				if (doVaild == true && v == "")
				{
					alert(LANG.require);
					f.select();
					return null;
				}
				return v;
			},
			addFieldMode: function (mode) {
				var selector = rootNode.find("tr.field-selector");
				var add = rootNode.find("tr.field-add");
				if (mode == "open")
				{
					selector.hide();
					add.show();
				}
				else
				{
					selector.show();
					add.hide();
				}
			}
		};
		
		var buttonsOption = {};
		buttonsOption[PromptDialog.LANG.Cancel] = PromptDialog.Buttons.Cancel;
		buttonsOption[PromptDialog.LANG.Accept] = function () {
			//var rootNode = Utils.getDialogRoot(this);
			rootNode.dialog("disable");
			if (util.isAddMode())
			{
				//如果是新增表單，請在此處撰寫新增表單的功能
				var addURL = Utils.getContextPath() + "/extension/input-forms-edit/input-forms-add-field.jsp?callback=?";
				
				var fieldAdd = rootNode.find("td.field-add:first");
				var schema = util.getFieldAdd("schema", true);
				if (schema == null) 
				{
					rootNode.dialog("enable");
					return;
				}
				else
					addURL = addURL + "&schema=" + schema;
				
				var namespace = util.getFieldAdd("namespace", true);
				if (namespace == null) 
				{
					rootNode.dialog("enable");
					return;
				}
				else
					addURL = addURL + "&namespace=" + namespace;
				
				var element = util.getFieldAdd("element", true);
				if (element == null) 
				{
					rootNode.dialog("enable");
					return;
				}
				else
					addURL = addURL + "&element=" + element;
				
				var qualifier = util.getFieldAdd("qualifier", false);
				addURL = addURL + "&qualifier=" + qualifier;
				
				var note = util.getFieldAdd("note", false);
				addURL = addURL + "&note=" + note;
				
				jQuery.getJSON(addURL, function(data) {
					if (data.state == "true")
					{
						util.setData(schema, element, qualifier);
						util.setSource();
						
						rootNode.dialog("enable");
						rootNode.dialog("close");
						
					}
					else
					{
						alert(LANG.addFieldException + addURL);
						rootNode.dialog("enable");
					}
				});
				
			}
			else
			{
				//請在此處撰寫把值取得之後再填寫到欄位編輯器的功能
				var selected = rootNode.find("tbody.field-selector > tr.field-selector-tr.selected:first");
				if (selected.length == 0)
					selected = rootNode.find("tbody.field-selector > tr.field-selector-tr:first");
				
				var s = selected.find("input.schema:first").val();
				var e = selected.find("input.element:first").val();
				var q = selected.find("input.qualifier:first").val();
				util.setData(s, e ,q);
				util.setSource();
				
				rootNode.dialog("enable");
				rootNode.dialog("close");
				util.focusSource();
			}
		};	
		
		var dialogOption = {
			bgiframe: true,
			autoOpen: false,
			height: "auto",
			width: 600,
			//modal: true,
			resizable: false,
			buttons: buttonsOption,
			open: function(event, ui)
			{
				//rootNode;
				
				if (rootNode.hasClass("inited") == false)
				{
					rootNode.dialog("disable");
					
					//請在此處加入初始化的動作
					
					//schema
					util.loadSchema();
					
					//設定元資料登記的功能
					var addBtn = rootNode.find("button.metadata-add:first");
					var btn1 = LANG.metadataRegister;
					var btn2 = LANG.metadataSelect;
					addBtn.click(function () {
						//切換
						var isAddMode = util.isAddMode();
						
						if (isAddMode == false)
						{
							rootNode.find("tr.field-selector").toggle();
							rootNode.find("tr.field-add").toggle();
							
							addBtn.html(btn2);
						}
						else
						{
							rootNode.find("tr.field-selector").toggle();
							rootNode.find("tr.field-add").toggle();
							
							addBtn.html(btn1);
						}
					});
					
					var dataSchema = rootNode.find("input:hidden.data-schema:first").change(function () {
						var schemaSelector = rootNode.find("select.schema-selector:first");
						schemaSelector.val(this.value);
						schemaSelector.change();
					});
					
					//等待讀取結束					
					var schemaSelector = rootNode.find("select.schema-selector:first");
					var fieldSelector = rootNode.find("tbody.field-selector:first");
					var waitLoad = function (callback) {
						if (schemaSelector.hasClass("inited") == true
							&& fieldSelector.hasClass("inited") == true)
						{
							callback();
						}
						else
						{
							setTimeout(function () {
								waitLoad(callback);
							},500);
						}
					};
					
					waitLoad(function () {
						rootNode.dialog("enable");
						rootNode.addClass("inited");
					});
				}
				
				//請在此處讀取資料
				var sourceData = util.getSource();
				util.setData(sourceData);
				
				//關閉編輯模式
				util.addFieldMode("close");
			}
		};
		
		rootNode.dialog(dialogOption);
	},
	Buttons: {
		Cancel: function () {
			jQuery(this).dialog("close");
		}
	}
};	//var PromptDialog = {

PromptDialog.LANG = {
	Cancel: "取消",
	Accept: "確定",
	DeleteConfirm: "您確定要刪除嗎？",
	MetadataFieldSelector: {
		schemaAndNamespace: "格式 - 名稱空間",
		require: "此欄必填",
		addFieldException: "新增欄位時發生錯誤：",
		metadataRegister: "元資料登記",
		metadataSelect: "元資料選擇"
	},
	WaitMessage: "請稍候",
	FieldEditor: {
		fieldNullDelete: "此欄沒有設定，將自動刪除",
		fieldUnavailable1: "後設資料",
		fieldUnavailable2: "已經被其他欄位使用，請選用其他後設資料。",
		labelRequire: "必須填寫標籤！",
		valuePairRequire1: "輸入型態",
		valuePairRequire2: "必需要有資料列表",
		qualdrop_value_note1: "輸入型態",
		qualdrop_value_note2: "的後設資料中修飾語必須空白",
		qualdrop_value_match1: "輸入型態",
		qualdrop_value_match2: "的資料列表中儲存資料必須對應到後設資料",
		qualdrop_value_match3: "下的修飾語，請問是否要由系統自動重整？"
	},
	FieldAdd: {
		exception: "發生錯誤。錯誤訊息: ",
		schemaAndElementRequire: "請填寫格式及元素！"
	}
};
//if (typeof(InputFomrsEditorLang) != "undefined")
//	PromptDialog.LANG = InputFomrsEditorLang.PromptDialog;
if (typeof(getInputFormsEditorLang) != "undefined")
	PromptDialog.LANG = getInputFormsEditorLang().PromptDialog;
