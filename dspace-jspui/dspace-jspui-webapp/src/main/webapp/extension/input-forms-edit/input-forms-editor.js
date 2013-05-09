
jQuery(document).ready(function () {
	//try
	//{
		FCKeditorCounter = 0;
		CONFIG = {
			'FCKEditorConfig': {path: 'fckeditor/', toolbar: 'Default', height: "300", config: {ToolbarStartExpanded: true}},
			'InputFormsTemplate': {
				"header": jQuery("#inputFormsTemplate_header").val(),
				"formDefinitionsHelp": jQuery("#inputFormsTemplate_formDefinitionsHelp").val(),
				"formValuePairsHelp": jQuery("#inputFormsTemplate_formValuePairsHelp").val(),
				"footer": jQuery("#inputFormsTemplate_footer").val()
			}
		};
		
		jQuery("textarea#source").hide()
			.addClass("input-forms-source")
			.wrap("<div class=\"input-forms-area\"></div>")
			.attr("name", "inputFormsXML");
		setTimeout(function () {
			PromptDialog.Processing(function () {
				InputFormsParser("textarea#source", function() {
					jQuery("#prompt_processing").dialog("close");
					
					Utils.searchCollectionHandle();
				});
			});
		},10);
	//}
	//catch(e) {alert("Prompt Dialog Process Error!");}
	
});

inputFormsNode = new Object;
function InputFormsParser(rootSelector, callback) 
{
	var ifpObj = this;

	var LANG = {
		Update: "更新",
		UpdateConfirm: "確定更新？此動作無法復原",
		EditorMode: {
			FormMode: "表單預覽模式",
			CodeMode: "程式碼模式"
		},
		Save: "儲存",
		Reload: "重新讀取",
		Label: {
			"Description": "敘述"
		},
		Hint: {
			"NotNull": "※不能是空值",
			"OnlyEnglish": "※只能是英文、數字、底線、橫線與點",
			"CreateFormConfirm": "您使用的是預設的traditional表單，是否要為此類別指定新的表單呢？"
		},
		FormHeading: "您正在編輯",
		"Button": {
			"Rename": "更名",
			"Edit": "編輯"
		},
		Delete: "刪除",
		DeleteConfirm: "確定要刪除？",
		Add: "新增"
	};
		
	//if (typeof(InputFomrsEditorLang) != "undefined")
	//	LANG = InputFomrsEditorLang.InputFormsParser;
	if (typeof(getInputFormsEditorLang) != "undefined")
		var LANG = getInputFormsEditorLang().InputFormsParser;
	
	ifpObj.rootNode = new Object;
	ifpObj.setRootNode = function (xml)
	{
		xml = Utils.escapeInputForms(xml);
		var root = jQuery("<div></div>").html(xml);
		ifpObj.rootNode = root.find(".input-forms:first");
		inputFormsNode = root.find(".input-forms:first");
	};
	
	ifpObj.init = function (root, callback)
	{
		//try
		//{
			PromptDialog.FormNameUpadte();
			PromptDialog.FormNameAdd();
			PromptDialog.PageAttr();
			PromptDialog.FieldEditor();
			PromptDialog.XMLMetadataEditor();
			PromptDialog.ProcessingSave();
			//PromptDialog.FieldAdd();
			PromptDialog.MetadataFieldSelector();
			
			//加入遞交檢查
			jQuery(root).parents("form:first").submit(function () {
				var thisForm = jQuery(this);
				if ((typeof(thisFormSubmit) == "boolean" && thisFormSubmit == true)
					|| window.confirm(LANG.UpdateConfirm))
				{
					//alert(thisForm.find("div.switch-code-editor:first").css("display"));
					if (!(typeof(thisFormSubmit) == "boolean" && thisFormSubmit == true))
					{
						jQuery(this).find("button.form-to-code:first").click();
						var waitFor = function () {
							setTimeout(function () {
								if (jQuery("#prompt_processing_save").dialog("isOpen") == true)
									waitFor();
								else
								{
									thisFormSubmit = true;
									thisForm.submit();
								}
							}, 1000);
						};
						
						waitFor();
						return false;
						
					}
					else
					{
						return true;
					}
				}
				else
					return false;
			});
		//}
		//catch (e) {alert("PromptDialog init error!");}
		//try
		//{
			var xml = jQuery(root).val();
			if (jQuery(root).hasClass("need-unescape"))
			{
				xml = unescape(xml);
				jQuery(root).val(xml)
					.removeClass("need-unescape");
			}
			ifpObj.setRootNode(xml);
			var forms = createForms();
			var formsEditor = jQuery("<div class=\"switch-forms-editor\"></div>")
				.append(forms);
			jQuery(root).after(formsEditor);
		//}
		//catch (e) {alert("Set up forms error");}
		//try
		//{
			var inputFormsArea = jQuery(root).parents(".input-forms-area:first");
			
			forms.after(createSubmitButton())
				.before(createSubmitButton());

			var codeEditorContainer = jQuery("<div></div>")
				.addClass("switch-code-editor")
				.hide();
			jQuery(root).css("width", "100%")
			var rootHeight = "10em";
			if (jQuery("body").height() != "")
				rootHeight = parseInt(jQuery("body").height() * 0.7) + "px";
			else if (typeof(window.innerHeight) != "undefined" && window.innerHeight != "")
				rootHeight = parseInt(window.innerHeight * 0.7) + "px";
			jQuery(root).css("height", rootHeight)
				.show()
				.appendTo(codeEditorContainer);
			
			inputFormsArea
				.prepend(codeEditorContainer)
				.prepend(createEditorSwitch());
				
			var btnSubmit = jQuery("<div style=\"text-align:center\"><button type=\"submit\">"+LANG.Update+"</button></div>")
				.prependTo(inputFormsArea);
			
			/*
			btnSubmit.find("button[type='submit']").click(function () {
				
				if (window.confirm(LANG.UpdateConfirm))
				{
					//如果是表單預覽模式，那麼就要先切換
					jQuery(this).parents("form:first").find("button.form-to-code:first").click();
					
					jQuery(this).parents("form:first").submit();
				}
			});
			*/
		//}
		//catch(e) {alert("Set up submit button error!");}
		if (typeof(callback) != "undefined")
			setTimeout(function () { callback(); }, 1500);
	}
	
	var createEditorSwitch = function () {
		var switcher = jQuery("<div class=\"input-forms-switch-container\"></div>");
		
		var formsRadio = jQuery("<input type=\"radio\" value=\"forms\" name=\"editor_switch\" />")
			.attr("checked", "checked")
			.appendTo(switcher)
			.click(function () {
				//jQuery(this).attr("checked", false);
				if (this.value == "forms")
				{
					jQuery(this).parents(".input-forms-area:first").find("button.code-to-form:first").click();
					//setTimeout(function () {
						jQuery(document).ready(function () {
							jQuery(".switch-code-editor:first").hide();
							jQuery(".switch-forms-editor:first").show();
						});
					//}, 1000);
				}
				else
				{
					jQuery(this).parents(".input-forms-area:first").find("button.form-to-code:first").click();
					//setTimeout(function () {
						jQuery(document).ready(function () {
							jQuery(".switch-code-editor:first").show().css("display", "block");
							jQuery(".switch-forms-editor:first").hide();
						});
					//}, 100);
				}
				//jQuery(this).attr("checked", true);
			});
		
		var formsLabel = jQuery("<label>"+LANG.EditorMode.FormMode+"</label>")
			.appendTo(switcher)
			.css("cursor", "pointer")
			.click(function () {
				var radio = jQuery(this).prevAll("input[type=\"radio\"]:first");
				radio.click();
			});
		
		var codeRadio = formsRadio.clone(true).attr("value", "code")
			.removeAttr("checked")
			.appendTo(switcher);
			
		var codeLabel = formsLabel.clone(true)
			.html(LANG.EditorMode.CodeMode)
			.appendTo(switcher);
		
		return switcher;
	}
	
	var createSubmitButton = function() {
		var container = jQuery("<div class=\"input-forms-submit-container\"></div>");
		
		var btnEditorToSource = jQuery("<button type=\"button\">"+LANG.Save+"</button>")
			.appendTo(container).hide()
			.addClass("form-to-code")
			.click(function () {
				if (jQuery("div.switch-code-editor:visible").length == 1)
				{
					return;
				}
				
				//要先作轉換
				jQuery("#prompt_processing_save").dialog("open");
				
				setTimeout(function () {
					var output = "";
					var formMap = getFormMap();
					var formDefinition = getFormDefinition();
					var formValuePairs = getFormValuePairs();
					
					output = output + CONFIG.InputFormsTemplate.header
						+ formMap
						+ CONFIG.InputFormsTemplate.formDefinitionsHelp
						+ formDefinition
						+ CONFIG.InputFormsTemplate.formValuePairsHelp
						+ formValuePairs
						+ CONFIG.InputFormsTemplate.footer;
					
					value = output;
					
					jQuery("textarea#source").attr("value", value);
					
					jQuery("textarea#source").removeClass("need-unescape");
					
					jQuery("#prompt_processing_save").dialog("close");
				}, 100);
				//alert(1212);
			});

		var btnSourceToEditor = jQuery("<button type=\"button\">"+LANG.Reload+"</button>")
			.addClass("code-to-form")
			.appendTo(container).hide()
			.click(function () {
				if (jQuery("div.switch-form-editor:visible").length == 1)
					return;
				//要先作轉換
				jQuery("#prompt_processing_save").dialog("open");
				var thisBtn = this;
				setTimeout(function () {
					
					setTimeout(function () {
						var area = jQuery(thisBtn).parents(".input-forms-area:first");
						
						area.find("textarea#source").insertBefore(area);
						area.remove();
						
						jQuery("textarea#source").hide()
							.addClass("input-forms-source")
							.wrap("<div class=\"input-forms-area\"></div>");
						InputFormsParser("textarea#source",function () {});
						
						setTimeout(function () {
							jQuery("#prompt_processing_save").dialog("close");
						}, 100);
					}, 100);
				}, 100);
			});
		
		return container;
	};
	
	var getNameMaps = function() {
		var formNames = jQuery("#form_collection select#form_select option");
		var forms = jQuery("#form_collection div.form-editor");
		
		var nameMaps = new Array();
		
		for (var i = 0; i < forms.length; i++)
		{
			var name = formNames.eq(i).attr("value");
			var handles = forms.eq(i).find("dl dd.collection-handle-list");
			
			var nameMap = {
				name: name,
				handle: new Array()
			};
			
			for (var j = 0; j < handles.length; j++)
			{
				var handle = handles.eq(j).find("input.collection-handle:first").attr("value");
				handle = jQuery.trim(handle);
				if (handle != "")
					nameMap.handle.push(handle);
			}
			nameMaps.push(nameMap);
		}
		return nameMaps;
	}; 
	
	var getFormMap = function() {
		var nameMaps = getNameMaps();
		
		var output = "";
		for (var i = 0; i < nameMaps.length; i++)
		{
			if (nameMaps[i].handle.length > 0)
			{
				for (var j = 0; j < nameMaps[i].handle.length; j++)
				{
					output = output
						+ '		<name-map collection-handle="'+nameMaps[i].handle[j]+'" form-name="'+nameMaps[i].name+'" />' + "\n";
				}
			}
			else
			{
				output = output
						+ '		<name-map collection-handle="" form-name="'+nameMaps[i].name+'" />' + "\n";
			}
				
			
		}
		
		return output;
	};
	
	var getFormDefinition = function() {
		var nameMaps = getNameMaps();
		var forms = jQuery("#form_collection div.form-editor");
		
		var pairNameCounter = 0;
		
		var output = "";
		for (var i = 0; i < forms.length; i++)
		{
			output = output + '		<form name="'+nameMaps[i].name+'">' + "\n";
			
			var pages = forms.eq(i).find("div.page-content");
			for (var j = 0; j < pages.length; j++)
			{
				var page = pages.eq(j);
			
				var number = (j+1);
				var label = jQuery.trim(page.find(".page-label").attr("value"));
				if (label != "" && label != LANG.Label.Description)
				{
					hint = Utils.escapeHTML(hint);
					label = ' label="'+label+'"';
				}
				else if (label == LANG.Label.Description)
					label = "";
				
				var hint = jQuery.trim(page.find(".page-hint").attr("value"));
				if (hint != "")
				{
					hint = Utils.escapeHTML(hint);
					hint = ' hint="'+hint+'"';
				}
				output = output + '			<page number="'+number+'"'+label+hint+'>' + "\n";
				
				var fields = page.find(".field-preview");
				for (var k = 0; k < fields.length; k++)
				{
					var field = fields.eq(k);
					
					output = output + '				<field>' + "\n";
					
					//var schema = field.find(".data-schema").attr("value");
					//output = output + '					<dc-schema>'+schema+'</dc-schema>' + "\n";
					output = output + util.appendField(field, "schema", "dc-schema");
					
					//var element = field.find(".data-element").attr("value");
					//output = output + '					<dc-element>'+element+'</dc-element>' + "\n";
					output = output + util.appendField(field, "element", "dc-element");
					
					//var qualifier = field.find(".data-qualifier").attr("value");
					//output = output + '					<dc-qualifier>'+qualifier+'</dc-qualifier>' + "\n";
					output = output + util.appendField(field, "qualifier", "dc-qualifier");
					
					//var repeatable = field.find(".data-repeatable").attr("value");
					//output = output + '					<repeatable>'+repeatable+'</repeatable>' + "\n";
					output = output + util.appendField(field, "repeatable");
					
					//var label = field.find(".data-label").attr("value");
					//	label = Utils.escapeHTML(label);
					//output = output + '					<label>'+label+'</label>' + "\n";
					output = output + util.appendField(field, "label");
					
					//var inputType = field.find(".data-input-type").attr("value");
					var inputType = util.getFieldValue(field, "input-type");
					if (inputType == "dropdown"
						|| inputType == "list"
						|| inputType == "qualdrop_value")
					{
						var schema = util.getFieldValue(field, "schema");
						var element = util.getFieldValue(field, "element");
						var qualifier = util.getFieldValue(field, "qualifier");
						var pairName = schema + "_" + element;
						if (qualifier != "")	pairName = pairName + "_" + qualifier;
						pairName = pairName + "_" + pairNameCounter;
						pairNameCounter++;
						output = output + '					<input-type value-pairs-name=\"'+pairName+'\">'+inputType+'</input-type>' + "\n";
					}
					else
						output = output + '					<input-type>'+inputType+'</input-type>' + "\n";
					
					//var hint = field.find(".data-hint").attr("value");
					//	hint = Utils.escapeHTML(hint);
					//output = output + '					<hint>'+hint+'</hint>' + "\n";
					output = output + util.appendField(field, "hint");
					
					//var required = field.find(".data-required").attr("value");
					//	required = Utils.escapeHTML(required);
					//output = output + '					<required>'+required+'</required>' + "\n";
					output = output + util.appendField(field, "required");
					
					//if (inputType == "xmlmetadata")
					//{
						//var defaultValue = field.find(".data-default-value").attr("value");
						//
						//	defaultValue = Utils.escapeHTML(defaultValue);
						//output = output + '					<default-value>'+defaultValue+'</default-value>' + "\n";
					//}
					output = output + util.appendField(field, "default-value");
					
					output = output + '				</field>' + "\n";
				}
				
				output = output + '			</page>' + "\n";
			}
			
			output = output + '		</form>' + "\n";
		}
		
		return output;
	};
	var getFormValuePairs = function() {
		var inputTypes = jQuery(".data-input-type");
		var pairNameCounter = 0;
		
		var output = "";
		for (var i = 0; i < inputTypes.length; i++)
		{
			var inputType = inputTypes.eq(i).attr("value");
			
			if (inputType != "dropdown"
				&& inputType != "list"
				&& inputType != "qualdrop_value")
				continue;
			
			var schema = inputTypes.eq(i).parents("td.field-preview:first").find(".data-schema:first").val();
			var element = inputTypes.eq(i).parents("td.field-preview:first").find(".data-element:first").val();
			var qualifier = inputTypes.eq(i).parents("td.field-preview:first").find(".data-qualifier:first").val();
			
			var name = schema + "_" + element;
			var term = element;
			if (qualifier != "")
			{
				name = name + "_" + qualifier;
				term = qualifier;
			}
			name = name + "_" + pairNameCounter;
			pairNameCounter++;
			
			output = output + '		<value-pairs value-pairs-name="'+name+'" dc-term="'+term+'">' + "\n";
			
			var pairs = inputTypes.eq(i).parents("td.field-preview:first").find(".data-value-pairs:first option");
			for (var j = 0; j < pairs.length; j++)
			{
				var stored = pairs.eq(j).attr("value");
					stored = Utils.escapeHTML(stored);
				var displayed = pairs.eq(j).attr("innerHTML");
					display = Utils.escapeHTML(displayed);
				
				output = output 
					+ '			<pair>' + "\n"
					+ '				<displayed-value>'+displayed+'</displayed-value>' + "\n"
					+ '				<stored-value>'+stored+'</stored-value>' + "\n"
					+ '			</pair>' + "\n"
			}
			
			output = output + '		</value-pairs>' + "\n";
			
		}
	
		return output;
	};
	
	var validAttr = Utils.validAttr;
	
	var checkFormName = function () 
	{
		
		var value = jQuery.trim(this.value);
		var acceptBtn = jQuery(this).parents("div.ui-dialog:first").find("button.accept:first");
		var hint = jQuery(this).nextAll("div.hint:first");
		if (value == "")
		{
			hint.html(LANG.Hint.NotNull);
			acceptBtn.attr("disabled", "disabled").addClass("disabled");
		}
		else
		{
			var result = validAttr(value);
			
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
	};

	var createForms = function()
	{
		var fieldSet = jQuery("<fieldset id=\"form_collection\"></fieldset>");
		var legend = jQuery("<legend></legend>").prependTo(fieldSet);
		
		var heading = jQuery("<span>"+LANG.FormHeading+" </span>")
			.appendTo(legend);
		
		var formSelect = jQuery("<select id=\"form_select\"></select>")
			.appendTo(legend)
			.change(function () {
				var options = jQuery(this).children("option");
				var index = options.index(options.filter(":selected"));
				if (index != -1)
				{
					var formEditors = jQuery(this).parents("fieldset:first").find("div.form-editor");
					formEditors.hide();
					formEditors.eq(index).show();
				}
			});
		
		var formCollection = FormCollectionObject(ifpObj.rootNode.children(".form-map"), ifpObj.rootNode.children(".form-definitions"));
		for (var i = 0; i < formCollection.count(); i++)
		{
			var name = formCollection.get(i).getName();
			var option = jQuery("<option value=\""+name+"\">"+name+"</option>")
				.appendTo(formSelect);
		}
		
		var btnEdit = jQuery("<button type=\"button\" class=\"icon edit\" title=\""+LANG["Button"]["Rename"]+"\">"+LANG["Button"]["RenameImg"]+"</button>")
			.appendTo(legend)
			.click(function () {
				jQuery("#prompt_form_name_update").dialog("open");
			});
		
		var btnDel = jQuery("<button type=\"button\" class=\"icon delete\" title=\""+LANG.Delete+"\">"+LANG.DeleteImg+"</button>")
			.appendTo(legend)
			.click(function () {
				if (window.confirm(LANG.DeleteConfirm) == false)
					return;
				
				var index = jQuery("select#form_select").children("option").index(jQuery(":selected"));
				if (index == -1)
					index = 0;
				jQuery("select#form_select").children("option:eq("+index+")").remove();
				jQuery("div.form-editor:eq("+index+")").remove();
				jQuery("select#form_select").change();
			});
		
		var btnAdd = jQuery("<button type=\"button\" class=\"icon add\" title=\""+LANG.Add+"\">"+LANG.AddImg+"</button>")
			.appendTo(legend)
			.click(function() {
				jQuery("#prompt_form_name_add").dialog("open");
			});
		
		
		var formDenyTraditionalDelete = function () {
			if (formSelect.val() == "traditional")
			{
				btnEdit.hide();
				btnDel.hide();
			}
			else
			{
				btnEdit.show();
				btnDel.show();
			}
		};
		
		formSelect.change(function () {
			formDenyTraditionalDelete();
		});
		
		formDenyTraditionalDelete();
		
		var formEditors = formCollection.initFormEditor();
		for (var i = 0; i < formEditors.length; i++)
			formEditors[i].appendTo(fieldSet);
		return fieldSet;
	}
	
	var util = {
		getFieldValue: function(field, name) {
			var value = field.find(".data-"+name).attr("value");
			value = jQuery.trim(value);
			value = Utils.escapeHTML(value);
			
			return value;
		},
		appendField: function (field, name, tagName) {
			if (typeof(tagName) == "undefined")
				tagName = name;
			
			var value = util.getFieldValue(field, name);
			
			if (value != "")
			{
				var prefix = "					<"+tagName+">";
				var suffix = "</" + tagName+">\n";
				return prefix + value + suffix;
			}
			else
				return "";
		}
	};
	
	if (typeof(rootSelector) != "undefined")
	{
		if (typeof(callback) == "undefined")
			var callback = function () {};
		ifpObj.init(rootSelector, callback);
	}
	
	return ifpObj;
}	//function InputFormsParser(rootSelector, callback) 