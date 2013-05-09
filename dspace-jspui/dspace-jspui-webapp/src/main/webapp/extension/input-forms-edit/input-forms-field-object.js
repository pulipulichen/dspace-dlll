function FieldObject(fieldNode, pairsNode)
{
	var LANG = {
		Button: {
			"Edit": "編輯",
			"EditImg": "編輯img",
			"Copy": "複製",
			"CopyImg": "複製img",
			"Repeat": "重複",
			"RepeatImg": "重複img"
		},
		Delete: "刪除",
		DeleteImg: "刪除img",
		DeleteConfirm: "您確定要刪除？",
		Insert: "插入",
		InsertImg: "插入img",
		FieldMove: {
			Up: "↑",
			UpImg: "↑img",
			Down: "↓",
			DownImg: "↓img",
			Left: "←",
			LeftImg: "←img",
			Right: "→",
			RightImg: "→img"
		},
		DateInput: {
			Tip: {
				Day: "日期：",
				Month: "月份：",
				Year: "年："
			},
			Months: {
				Null: "（沒有月份）",
				Jan: "一月",
				Feb: "二月",
				Mar: "三月",
				Apr: "四月",
				May: "五月",
				Jun: "六月",
				Jul: "七月",
				Aug: "八月",
				Sep: "九月",
				Oct: "十月",
				Nov: "十一月",
				Dec: "十二月"
			}
		},
		NameInput: {
			LastName: "姓氏 例如",
			FirstName: "名字(s) + \"Jr\" 例如"
		},
		SeriesInput: {
			Series: "叢集名",
			Number: "報告或論文編號"
		}
	};
	
	if (typeof(getInputFormsEditorLang) != "undefined")
	{
		//LANG = InputFomrsEditorLang.FieldObject;
		var LANG = getInputFormsEditorLang().FieldObject;
		//LANG = l.FieldObject;
	}
	
	var fdObj = new Object;
	
	fdObj.schema = "dc";
	fdObj.element = "title";
	fdObj.qualifier = "";
	fdObj.repeatable = "false";
	fdObj.label = "";
	fdObj.hint = "";
	fdObj.required = "";
	fdObj.inputType = "onebox";
	fdObj.valuePairs = new Array();
	fdObj.defaultValue = "";
	
	fdObj.parseField = function(fieldNode, pairsNode)
	{
		fdObj.schema = fieldNode.children(".dc-schema").html();
		fdObj.element = fieldNode.children(".dc-element").html();
		if (fieldNode.children(".dc-qualifier").length > 0)
			fdObj.qualifier = fieldNode.children(".dc-qualifier").html();
		if (fieldNode.children(".repeatable").length > 0)
			fdObj.repeatable = fieldNode.children(".repeatable").html();
		fdObj.label = fieldNode.children(".label").html();
		if (fieldNode.children(".hint").length > 0)
			fdObj.hint = fieldNode.children(".hint").html();
		if (fieldNode.children(".required").length > 0)
			fdObj.required = fieldNode.children(".required").html();
		fdObj.inputType = fieldNode.children(".input-type").html();
		var pairsName = ""
		if (fieldNode.children(".input-type").attr("value-pairs-name") != "")
			pairsName = fieldNode.children(".input-type").attr("value-pairs-name");
		if (fieldNode.children(".default-value").length > 0)
		{
			fdObj.defaultValue = fieldNode.children(".default-value").html();
			//fdObj.defaultValue = Utils.unescapeHTML(fdObj.defaultValue);
		}

		if (typeof(pairsNode) != "object")
			pairsNode = inputFormsNode.find(".form-value-pairs");
		
		if (typeof(pairsNode) == "object" && pairsNode.length > 0 && pairsName != "")
		{
			fdObj.valuePairs = fdObj.parsePairs(pairsNode, pairsName);
		}
		else if (pairsName != "" && (typeof(pairsNode) == "undefined" || pairsNode.length == 0))
			alert("Cannot find form-value-pairs!");
		
	};
	
	fdObj.parsePairs = function(node, name)
	{
		var vpNode = node.find(".value-pairs[value-pairs-name='"+name+"']");
		//alert([vpNode.length, "value-pairs[value-pairs-name='"+name+"']"])
		var vpAry = new Array();
		
		if (typeof(name) != "undefined"
			&& jQuery.trim(name) != ""
			&& (typeof(node) == "undeifned" || node.length == 0))
			alert("Pairs node error.");

		if (vpNode.length > 0)
		{
			var pNode = vpNode.find(".pair");
			for (var i = 0; i < pNode.length; i ++)
			{
				var vp = ValuePairsObject(pNode.eq(i));
				vpAry.push(vp);
			}
		}
		return vpAry;
	};
	
	fdObj.parseFieldTd = function(fieldNode)
	{	
		fdObj.repeatable = fieldNode.find(".data-repeatable").val();
		fdObj.inputType = fieldNode.find(".data-input-type").val();
		fdObj.defaultValue = fieldNode.find(".data-default-value").val();
		
		var vpAry = new Array();
		var pairs = fieldNode.find(".data-value-pairs").children("option");
		for (var i = 0; i < pairs.length; i++ )
		{
			var stored = pairs.eq(i).attr("value");
			var displayed = pairs.eq(i).attr("innerHTML");
			
			vpAry.push({
				"stored": stored,
				"displayed": displayed
			});
		}
		fdObj.valuePairs = vpAry;
	};
	
	fdObj.getEditor = function()
	{
		var editor = jQuery("<tr class=\"field\"><td class=\"field-function\"></td><td class=\"field-preview\"></td></tr>");

		var func = getFunctionButton()
		func.appendTo(editor.find(".field-function"));
		var preview = getEmptyPreview()
		preview.appendTo(editor.find(".field-preview"));
		var data = getData()
		data.appendTo(editor.find(".field-preview"));
		
		util.setPreview(editor);
		
		editor.hover(function () { jQuery(this).addClass("hover") }
			, function () { jQuery(this).removeClass("hover") });
		
		editor.find(".field-function button").focus(function () {
			editor.parent().children("tr.field.focus").removeClass("focus");
			editor.addClass("focus");
		}).blur(function () {
			editor.removeClass("focus")
				.removeClass("hover");
		});
		
		return editor;
	};
	
	var getFunctionButton = function() {
		var editor = jQuery("<div></div>");
		
		var btnEdit = jQuery("<button type=\"button\" class=\"icon edit\" title=\""+LANG["Button"]["Edit"]+"\">"+LANG["Button"]["EditImg"]+"</button>").appendTo(editor)
			.click(function () {
				var tr = jQuery(this).parents("tr:first");
				tr.addClass("field-data-source")
				//	.css("background-color", "#FFFF00");
				
				//if (tr.css("background-color") != "#FFFF00")
				//{
					//setTimeout(function () {
					//	tr.css("background-color", "#FFFF00");
					//}, 800);
				//}
				
				jQuery("#prompt_field_editor").dialog("open");
			});
		
		var btnDel = jQuery("<button type=\"button\" class=\"icon delete\" title=\""+LANG.Delete+"\">"+LANG.DeleteImg+"</button>").appendTo(editor)
			.click(function () {
				if (window.confirm(LANG.DeleteConfirm) == true)
				{
					var tr = jQuery(this).parents("tr:first").remove();
				}
			});
		
		jQuery("<br />").appendTo(editor);
		
		var btnAdd = jQuery("<button type=\"button\" class=\"icon add\" title=\""+LANG.Insert+"\">"+LANG.InsertImg+"</button>").appendTo(editor)
			.click(function () {
				var field = FieldObject();
				var editor = field.getEditor();
				
				jQuery(this).parents("tr:first").after(editor);
				
				editor.addClass("field-data-source");
				//	.css("background-color", "#FFFF00");
				jQuery("#prompt_field_editor").dialog("open");
			});
		
		var btnCopy = jQuery("<button type=\"button\" class=\"icon copy\" title=\""+LANG["Button"]["Copy"]+"\">"+LANG["Button"]["CopyImg"]+"</button>").appendTo(editor)
			.click(function () {
				jQuery(this).parents("tr:first").addClass("field-data-source")
				jQuery("#prompt_field_editor").dialog("open");
				
				jQuery(this).parents("tr:first").removeClass("field-data-source");
				
				var field = FieldObject();
				var editor = field.getEditor();
				
				jQuery(this).parents("tr:first").after(editor);
				
				editor.addClass("field-data-source")
				//	.css("background-color", "#FFFF00");
				
				//jQuery("#prompt_field_editor").parents(".ui-dialog").find(".ui-state-default:last").click();
			});
			
		jQuery("<br />").appendTo(editor);
		
		var btnMoveUp = jQuery("<button type=\"button\" class=\"icon field-move-up\" title=\""+LANG.FieldMove.Up+"\">"+LANG.FieldMove.UpImg+"</button>").appendTo(editor)
			.click(function () {
				var nowTr = jQuery(this).parents("tr:first");
				var targetTr = nowTr.prevAll("tr:first");
				if (targetTr.length > 0
					&& targetTr.hasClass("field-add") == false)
				{
					targetTr.before(nowTr);
					nowTr.find("button.field-move-up").focus();
				}
			});
		var btnMoveDown = jQuery("<button type=\"button\" class=\"icon field-move-down\" title=\""+LANG.FieldMove.Down+"\">"+LANG.FieldMove.DownImg+"</button>").appendTo(editor)
			.click(function () {
				var nowTr = jQuery(this).parents("tr:first");
				var targetTr = nowTr.nextAll("tr:first");
				if (targetTr.length > 0
					&& targetTr.hasClass("field-add") == false)
				{
					targetTr.after(nowTr);
					nowTr.find("button.field-move-down").focus();
				}	
			});
		
		jQuery("<br />").appendTo(editor);
		
		var btnMoveLeft = jQuery("<button type=\"button\" class=\"icon field-move-left\" title=\""+LANG.FieldMove.Left+"\">"+LANG.FieldMove.LeftImg+"</button>")
			.appendTo(editor)
			.click(function () {
				var nowTr = util.getFieldTr(this);
				
				var nowPage = util.getPageDiv(this);
				var targetPage = nowPage.prevAll("div.page-content:first");
				if (targetPage.length > 0)
				{
					//移動
					var targetTr = util.getFieldToInsert(targetPage);
					targetTr.before(nowTr);
					
					//取得現在頁數、換頁
					var i = util.getPageIndex(nowPage);
					i--;
					util.changePage(nowPage, i);
					
					//鎖定按鈕
					util.focusFieldButton(nowTr, "field-move-up");
				}
			});
		
		var btnMoveRight = jQuery("<button type=\"button\" class=\"icon field-move-right\" title=\""+LANG.FieldMove.Right+"\">"+LANG.FieldMove.RightImg+"</button>")
			.appendTo(editor)
			.click(function () {
				var nowTr = util.getFieldTr(this);
				
				var nowPage = util.getPageDiv(this);
				var targetPage = nowPage.nextAll("div.page-content:first");
				if (targetPage.length > 0)
				{
					//移動
					var targetTr = util.getFieldToInsert(targetPage);
					targetTr.before(nowTr);
					
					//取得現在頁數、換頁
					var i = util.getPageIndex(nowPage);
					i++;
					util.changePage(nowPage, i);
					
					//鎖定按鈕
					util.focusFieldButton(nowTr, "field-move-up");
				}
			});
		
		return editor;
	};
	
	var getEmptyPreview = function () {
		var editor = jQuery("<table><tbody>"
			+ "<tr><td></td><td class=\"preview-hint\"></td><td></td></tr>"
			+ "<tr><td></td><td class=\"preview-required\"></td><td></td></tr>"
			+ "<tr><th class=\"preview-label\"></th><td class=\"preview-input-type-td\"></td><td class=\"preview-function\"><input type=\"button\" value=\""+LANG["Button"]["Repeat"]+"\" /></td></tr>"
			+ "</tbody></table>");
		
		//editor.find(".preview-label").html(fdObj.label);
		//editor.find(".preview-hint").html(fdObj.hint);
		//editor.find(".preview-required").html(fdObj.required);
		//editor.find(".preview-input-type-td").html(fdObj.getInputType());
		
		//以下要修改！
		//if (fdObj.repeatable == "false")
		//{
		//	editor.find(".preview-function").css("visibility", "hidden");
		//}
		
		return editor;
	};
	
	var getData = function () {
		var editor = jQuery("<div></div>");
		
		var dataSchema = jQuery("<input type=\"hidden\" class=\"data-schema\" value=\""+fdObj.schema+"\" />")
			.appendTo(editor);
		var dataElement = jQuery("<input type=\"hidden\" class=\"data-element\" value=\""+fdObj.element+"\" />")
			.appendTo(editor);
		var dataQualifier = jQuery("<input type=\"hidden\" class=\"data-qualifier\" value=\""+fdObj.qualifier+"\" />")
			.appendTo(editor);
		
		var dataLabel = jQuery("<input type=\"hidden\" class=\"data-label\" />")
			.val(fdObj.label)
			.appendTo(editor)
			.change(function () {
				//var preview = jQuery(this).parents("td:first").find(".preview-label");
				//preview.html(this.value);
				
				util.setPreviewValue(this, "label");
			});
		
		var dataHint = jQuery("<input type=\"hidden\" class=\"data-hint\"  />")
			.val(fdObj.hint)
			.appendTo(editor)
			.change(function () {
				//var preview = jQuery(this).parents("td:first").find(".preview-hint");
				//preview.html(this.value);
				
				util.setPreviewValue(this, "hint");
			});
		
		var dataRepeatable = jQuery("<input type=\"hidden\" class=\"data-repeatable\" />")
			.val(fdObj.repeatable)
			.appendTo(editor)
			.change(function () {
				var editor = jQuery(this).parents("td.field-preview:first");
				var target = editor.find(".preview-function:first");
				
				var inputType = editor.find("input:hidden.data-input-type:first").val();
				var selectType = (inputType == "dropdown" || inputType == "list");
				
				if ((this.value == "true" || this.value == true) && selectType == false)
					target.css("visibility", "visible");
				else
					target.css("visibility", "hidden");
			});
		
		var dataRequired = jQuery("<input type=\"hidden\" class=\"data-required\" />")
			.val(fdObj.required)
			.appendTo(editor)
			.change(function () {
				//var preview = jQuery(this).parents("td:first").find(".preview-required");
				//preview.html(this.value);
				util.setPreviewValue(this, "required");
			});
		
		var dataValuePairs = jQuery("<select class=\"data-value-pairs\" style=\"display:none\"></select>")
			.appendTo(editor);
			//var vpAry = fdObj.valuePairs;
			//for (var i = 0; i < vpAry.length; i++)
			//{
			//	var s = vpAry[i].stored;
			//		s = Utils.escapeHTML(s);
			//	var d = vpAry[i].displayed;
			//		d = Utils.unescapeHTML(d);
			//	
			//	jQuery("<option value=\""+s+"\">"+d+"</option>")
			//		.appendTo(dataValuePairs);
			//}
			
			util.setPairValueSelect(dataValuePairs, fdObj.valuePairs);
		
		var dataDefaultValue = jQuery("<input type=\"hidden\" class=\"data-default-value\" />")
			.val(fdObj.defaultValue)
			.appendTo(editor);
		
		var dataInputType = jQuery("<input type=\"hidden\" class=\"data-input-type\" />")
			.val(fdObj.inputType)
			.appendTo(editor)
			.change(function () {
				var previewFieldTd = jQuery(this).parents("td:first");
				
				var field = FieldObject(previewFieldTd);
				
				var previewInputType = field.getInputType();
				
				//previewInputTypeTd.append(previewInputType);
				//alert(previewInputType.html());
				previewFieldTd.find("td.preview-input-type-td:first").empty().append(previewInputType);
				Utils.initFCKEditor(previewInputType);
			});
		
		return editor;
	};
	
	fdObj.getInputType = function () {
		var editor = jQuery("<div class=\"preview-input-type\"></div>");
		try
		{
		var getSelect = function () {
			var select = jQuery("<select></select>");
			//var vpAry = fdObj.valuePairs;
			//for (var i = 0; i < vpAry.length; i++)
			//{
			//	jQuery("<option value=\""+vpAry[i].stored+"\">"+vpAry[i].displayed+"</option>")
			//		.appendTo(select);
			//}
			util.setPairValueSelect(select, fdObj.valuePairs);
			return select;
		};
		
		var getList = function () {
			var list = new Array();
			var vpAry = util.escapePairValue(fdObj.valuePairs);
			var name = fdObj.schema 
				+ "_" + fdObj.element
				+ "_" + fdObj.qualifier;
			for (var i = 0; i < vpAry.length; i++)
			{
				var input = jQuery("<input type=\"radio\" name=\""+name+"\" value=\""+vpAry[i].stored+"\" />");
				if (fdObj.repeatable == "true")
					input.attr("type", "checkbox");
				
				var label = jQuery("<label>"+vpAry[i].displayed+"</label>")
					.click(function () {
						jQuery(this).prevAll("input:first").focus();
					});
				
				var item = jQuery("<span></span>")
					.append(input)
					.append(label);
				list.push(item);
			}
			return list;
		};
		
		
		switch(fdObj.inputType)
		{
			case 'dropdown':
				var input = getSelect();
				if (fdObj.repeatable == "true")
					input.attr("size", 6).attr("multiple", "multiple");
				break;
			case 'qualdrop_value':
				var input = jQuery("<span><input type=\"text\" class=\"text\"></span>")
					.append("<span>&nbsp;<span>").prepend(getSelect());
				break;
			case 'list':
				var input = jQuery("<table><tbody></tbody></table>");
				var list = getList();
				for (var i = 0; i < list.length; i ++)
				{
					var tr = jQuery("<tr></tr>").appendTo(input);
					
					//左邊格子
					var left = jQuery("<td></td>");
					if (i == list.length - 1)	//最後一格
						left.attr("colspan", 2);
					left.append(list[i]).appendTo(tr);
					
					i++;
					if (i < list.length)
					{
						var right = jQuery("<td></td>")
							.append(list[i]).appendTo(tr);
					}
				}
				break;
			case 'date':
				var input = jQuery('<div class=\"input-type-date\"><span class=\"input-tip\">'+LANG.DateInput.Tip.Day+'</span><input name="dc_relation_ispartofseries_day" class=\"input-type-date-day\"  size="2" maxlength="2" value="" type="text"> <span class=\"input-tip\">'+LANG.DateInput.Tip.Month+'</span><select name="dc_relation_ispartofseries_month"  class=\"input-type-date-month\" >'
					+ '<option value="-1" selected="selected">'+LANG.DateInput.Months.Null+'</option>'
					+ '<option value="1">'+LANG.DateInput.Months.Jan+'</option>'
					+ '<option value="2">'+LANG.DateInput.Months.Feb+'</option>'
					+ '<option value="3">'+LANG.DateInput.Months.Mar+'</option>'
					+ '<option value="4">'+LANG.DateInput.Months.Apr+'</option>'
					+ '<option value="5">'+LANG.DateInput.Months.May+'</option>'
					+ '<option value="6">'+LANG.DateInput.Months.Jun+'</option>'
					+ '<option value="7">'+LANG.DateInput.Months.Jul+'</option>'
					+ '<option value="8">'+LANG.DateInput.Months.Aug+'</option>'
					+ '<option value="9">'+LANG.DateInput.Months.Sep+'</option>'
					+ '<option value="10">'+LANG.DateInput.Months.Oct+'</option>'
					+ '<option value="11">'+LANG.DateInput.Months.Nov+'</option>'
					+ '<option value="12">'+LANG.DateInput.Months.Dec+'</option></select> <span class=\"input-tip\">'+LANG.DateInput.Tip.Year+'</span><input class=\"input-type-date-year\" name="dc_relation_ispartofseries_year" size="4" maxlength="4" value="" type="text"></div>');
				input.css("text-align", "center");
				jQuery(input).ready(function () {
					setTimeout(function () {
						setFormDatePicker();
					}, 1000);
				});
				break;
			case 'name':
				var input = jQuery("<table>"
					+ "<tr class=\"input-tip\"><th>"+LANG.NameInput.LastName+"</th><th>"+LANG.NameInput.FirstName+"</th></tr>"
					+ "<tr><td><input type=\"text\" class=\"text\"></td><td><input type=\"text\" class=\"text\"></td></tr>"
					+ "</table>");
				break;
			case 'twobox':
				var input = jQuery("<table><tr><td><input type=\"text\"></td><td><input type=\"text\"></td></tr></table>");
				break;
			case 'series':
				var input = jQuery("<table>"
					+ "<tr class=\"input-tip\"><th>"+LANG.SeriesInput.Series+"</th><th>"+LANG.SeriesInput.Number+"</th></tr>"
					+ "<tr><td><input type=\"text\" class=\"text\"></td><td><input type=\"text\" class=\"text\"></td></tr>"
					+ "</table>");
				break;
			case 'fileupload':
				var input = jQuery("<input type=\"file\" />");
				break;
			case 'xmlmetadata':
				var input = jQuery("<textarea class=\"xmlmetadata\"></textarea>");
				try{
					var dv = fdObj.defaultValue;
					dv = Utils.escapeHTML(dv);
					//input.val(dv);
					input = jQuery("<textarea class=\"xmlmetadata\">"+dv+"</textarea>");
				} catch(e) { alert(["get default-value error", fdObj.defaultValue]); };
				break;
			case 'textarea':
				var input = jQuery("<textarea class=\"text\"></textarea>");
				break;
			case 'texteditor':
				var input = jQuery("<textarea class=\"fckeditor\"></textarea>");
				break;
			case 'taiwanaddress':
				var input = jQuery("<input type=\"text\" class=\"taiwanaddress\" />");
				break;
			case 'item':
				var input = jQuery("<input type=\"text\" class=\"item\" />");
				break;
			default:
				var input = jQuery("<input type=\"text\" class=\"text\" />");		
		}
		input.appendTo(editor);
		} catch(e) {alert(["error: ", fdObj.label, fdObj.inputType]);};
		return editor;
	};
	
	var util = {
		getFieldTr: function (thisObj) {
			var nowTr = jQuery(thisObj).parents("tr:first");
			return nowTr;
		},
		getPageDiv: function (thisObj) {
			var nowPage = jQuery(thisObj).parents("div.page-content:first");
			return nowPage;
		},
		getFieldToInsert: function (targetPage)
		{
			var targetTr = targetPage.find("table.page-content-table tbody.page-content-tbody tr.field-add:last");
			return targetTr;
		},
		getPageIndex: function (nowPage)
		{
			if (typeof(nowPage) == "undefined")
				return -1;
			
			if (nowPage.hasClass("page-content") == false)
			{
				nowPage = nowPage.parents("div.page-content:first");
				if (nowPage.length == 0)
					return -1;
			}
			
			var pages = nowPage.parents("fieldset.page-editor:first").children("div.page-content");
			
			return pages.index(nowPage);
		},
		changePage: function (nowPage, index)
		{
			if (typeof(index) == "undefined")
			{
				index = nowPage;
				nowPage = jQuery("div.page-content:visible:first");
			}
			
			var pageSelect = nowPage.parents("fieldset.page-editor:first").find(" > legend > select.page-select:first");
			
			var targetOption = pageSelect.children("option:eq("+index+")");
			if (targetOption.length > 0)
			{
				pageSelect.children("option:selected").removeAttr("selected");
				targetOption.attr("selected", "selected");
				pageSelect.change();
			}
		},
		focusFieldButton: function (nowFieldTr, buttonName)
		{
			var btn = nowFieldTr.find("button."+buttonName+":first");
			if (btn.length > 0)
				btn.focus();
		},
		setPreview: function (editor)
		{
			var inputs = ["label"
				, "hint"
				, "repeatable"
				, "required"
				, "input-type"];
			
			for (var i = 0; i < inputs.length; i++)
			{
				editor.find("input:hidden.data-"+inputs[i]+":first").change();
			}
		},
		setPreviewValue: function (thisObj, name)
		{
			var preview = jQuery(thisObj).parents("td.field-preview:first")
				.find(".preview-"+name);
			
			var value = jQuery(thisObj).val();
			value = jQuery.trim(value);
			value = Utils.unescapeHTML(value);
			
			preview.html(value);
		},
		escapePairValue: function (vpAry)
		{
			for (var i = 0; i < vpAry.length; i++)
			{
				var s = vpAry[i].stored;
					s = Utils.escapeHTML(s);
				var d = vpAry[i].displayed;
					d = Utils.unescapeHTML(d);
				vpAry[i].stored = s;
				vpAry[i].displayed = d;
			}
			return vpAry;
		},
		setPairValueSelect: function (select, vpAry) {
			vpAry = util.escapePairValue(vpAry);
			
			for (var i = 0; i < vpAry.length; i++)
			{
				s = vpAry[i].stored;
				d = vpAry[i].displayed;
				jQuery("<option value=\""+s+"\">"+d+"</option>")
					.appendTo(select);
			}
		}
	};
	
	//init
	if (typeof(fieldNode) == "object")
	{
		if (fieldNode.find("input[type='hidden']").length == 0)
			fdObj.parseField(fieldNode, pairsNode);
		else
			fdObj.parseFieldTd(fieldNode);
	}
	
	return fdObj;
}	//FieldObject(fieldNode, pairsNode)

function ValuePairsObject(pairNode)
{
	var displayed = pairNode.find(".displayed-value:first").attr("innerHTML");
	var stored = pairNode.find(".stored-value:first").attr("innerHTML");
	
	var pairObj = new Object;
	pairObj.displayed = displayed;
	pairObj.stored = stored;
	
	return pairObj;
}	//function ValuePairsObject(pairNode)
