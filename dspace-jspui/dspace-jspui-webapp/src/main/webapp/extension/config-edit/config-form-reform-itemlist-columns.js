ConfigForm.reform.itemlistColumns = {
	config: {
		tableClassName: "itemlist-columns-table",
		valueClassName: "itemlist-columns",
		valueClassName2: "itemlist-widths",
		createAddButtonText: ConfigLang.form.button.add,
		theads: [ConfigLang.form.header.metadata, ConfigLang.form.header.datatype, ConfigLang.form.header.width, ""],
		trs: ["metadata", "datatype", "width", "func"],
		constructor: function () { 
			return {
				metadata: "",
				datatype: "",
				width: "*"
			};
		}
	},
	init: function (input) {
		var classObj = ConfigForm.reform.itemlistColumns;
		
		var values = classObj.parseValue(input, classObj);
		
		var theads = classObj.config.theads;
		
		var tableClassName = classObj.config.tableClassName;
		var tableObj = ConfigForm.utils.createTableObj(tableClassName, theads.length, input.columns);
		
		ConfigForm.utils.createThead(tableObj.table, theads);
		
		var createTr = classObj.createTr;
		ConfigForm.utils.setTr(tableObj.tbody, values, createTr, classObj);
		
		var createAddButtonText = classObj.config.createAddButtonText;
		ConfigForm.utils.createAddButton(createAddButtonText, tableObj.tfoot, classObj);
	},
	createTr: function(value, classObj) {
		var LANG = ConfigLang.form;
		
		var tableClassName = classObj.config.tableClassName;
		var recombination = function (thisObj) { 
			classObj.recombination(thisObj, classObj)
		};
		var onchangeEvent = ConfigForm.utils.recombinationTrigger(tableClassName, recombination);
		
		var trs = classObj.config.trs;
		var trObj = ConfigForm.utils.createTrObj(trs);
		
		var input = new Object;
		input[trs[0]] = ConfigForm.utils.createInput.text(value[trs[0]], trs[0]+"-value"
			, trObj[trs[0]], onchangeEvent);
		
		ConfigForm.utils.spacePadding(trObj[trs[0]]);
		
		var labelThumb = ConfigForm.utils.createInput.label(LANG.label.thumbnail, trObj[trs[0]]);
		var checkboxThumb = jQuery("<input type=\"checkbox\" class=\"is-thumb\" />").appendTo(labelThumb);
		checkboxThumb.change(function () {
			classObj.recombination(jQuery(this).parents("table:first"), classObj);
			if (ConfigForm.valid.checked(this))
				input[trs[0]].attr("disabled", "disabled");	
			else
				input[trs[0]].removeAttr("disabled");
		});
		if (value[trs[0]] == "thumbnail")
		{
			checkboxThumb.attr("checked", "checked");
			input[trs[0]].attr("disabled", "disabled");
		}
		
		var datatype = value[trs[1]];
		var limit = "";
		if (datatype != "" && datatype != "date")
		{
			limit = datatype;
			datatype = "limit";
		}
		
		input[trs[1]] = ConfigForm.utils.createInput.select(datatype, ["", "date", "limit"]
			, [LANG.select.text, LANG.select.date, LANG.select.limit]
			, trs[1]+"-value" , trObj[trs[1]], onchangeEvent);
		
		ConfigForm.utils.spacePadding(trObj[trs[1]]);
		
		var labelLimit = ConfigForm.utils.createInput.label(LANG.label.limit, trObj[trs[1]]);
		var inputLimit = ConfigForm.utils.createInput.text(limit, "limit-value"
			, labelLimit, onchangeEvent);
		if (datatype != "limit")
			labelLimit.hide();
		input[trs[1]].change(function () {
			if (this.value != "limit")
				labelLimit.hide();
			else
			{
				labelLimit.show();
				inputLimit.focus();
			}
		});
		
		var widthValue = value[trs[2]];
		var widthType = "";
		if (ConfigForm.utils.endsWith(widthValue, "%"))
		{
			widthType = "%";
			widthValue = widthValue.substring(0, widthValue.length-1);
		}
		else if (ConfigForm.utils.endsWith(widthValue, "*"))
		{
			widthType = "*";
			widthValue = "";
		} else if (widthValue == "")
		{
			widthType = "*";
			widthValue = "";
		}
		
		input[trs[2]] = ConfigForm.utils.createInput.text(widthValue, trs[2]+"-value"
			, trObj[trs[2]], onchangeEvent);
		if (widthType == "*" || (widthType == "" && widthValue == ""))
			input[trs[2]].attr("disabled", "disabled");
		
		ConfigForm.utils.spacePadding(trObj[trs[2]]);
		
		var selectWidth = ConfigForm.utils.createInput.select(widthType, ["*", "", "%"]
			, [LANG.select.any, LANG.select.px, LANG.select.percent]
			, "widthtype-value" , trObj[trs[2]], onchangeEvent);
		selectWidth.change(function () {
			if (this.value == "*")
				input[trs[2]].attr("disabled", "disabled");
			else
				input[trs[2]].removeAttr("disabled").focus();
		});
		
		ConfigForm.utils.setFunctionButton(trObj.func, classObj, false);
		
		return trObj.tr;
	},
	parseValue: function (text, classObj) {
		var columns = text.columns;
		var width = text.width;
		var linesCol = ConfigForm.utils.splitComma(columns);
		var linesWidth = ConfigForm.utils.splitComma(width);
		
		var output = new Array;
		for (var i = 0; i < linesCol.length; i++)
		{
			var o = classObj.config.constructor();
			
			var datatype = ConfigForm.utils.getBracketText(linesCol[i]);
			if (datatype == null)
			{
				o.metadata = linesCol[i];
			}
			else
			{
				o.metadata = linesCol[i].substring(0, linesCol[i].lastIndexOf("("));
				o.datatype = datatype;
			}
			
			if (typeof(linesWidth[i]) != "undefined")
				o.width = linesWidth[i];
			
			output.push(o);
		}
		return output;
	},
	insert: function (thisObj, classObj)
	{
		ConfigForm.utils.insert(thisObj, classObj);
	},
	recombination: function(table, classObj) 
	{
		var headers = classObj.config.trs;
		var text = "";
		var textWidth = "";
		var trs = table.find("> tbody > tr");
		for (var i = 0; i < trs.length; i++)
		{
			var tr = trs.eq(i);
			
			var metadata = ConfigForm.utils.getInputValid(tr.find("> td."+headers[0]+" > ."+headers[0]+"-value"));
			var isThumb = ConfigForm.valid.checked(tr.find("> td."+headers[0]+" .is-thumb:first"));
			if (isThumb)
				metadata = "thumbnail";
			if (metadata == "")
				continue;
			
			var datatype = tr.find("> td."+headers[1]+" > ."+headers[1]+"-value").val();
			
			if (datatype == "date")
				datatype = "("+datatype+")";
			else if (datatype != "")
			{
				datatype = ConfigForm.utils.getInputValid(tr.find("> td."+headers[1]+" > .limit-value"));
			}
			
			var width = tr.find("> td."+headers[2]+" > ."+headers[2]+"-value").val();
			var widthType = tr.find("> td."+headers[2]+" > .widthtype-value").val();
			if (widthType == "*")
				width = "*";
			else if (widthType == "%")
				width = width + "%";
			if (width == "")
				width = "*";
			
			if (text != "")
				text = text + ", ";
			text = text + metadata + datatype;
			
			if (textWidth != "")
				textWidth = textWidth + ", ";
			textWidth = textWidth + width;
		}
		table.nextAll("." + classObj.config.valueClassName + ":first").val(text);
		table.nextAll("." + classObj.config.valueClassName2 + ":first").val(textWidth);
	}
};