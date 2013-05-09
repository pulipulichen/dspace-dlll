ConfigForm.reform.sortOption = {
	config: {
		tableClassName: "sort-option-table"
	},
	init: function (input) {
		var LANG = ConfigLang.form.header;
			
		var util = ConfigForm.reform.sortOption;
		
		var values = util.parseValue(input);
		
		var tableClassName = util.config.tableClassName;
		var tableObj = ConfigForm.utils.createTableObj(tableClassName, 5, input);
		
		ConfigForm.utils.createThead(tableObj.table, [LANG.optionName, LANG.metadata, LANG.datatype, LANG.display, ""]);
		
		var createTr = util.createTr;
		ConfigForm.utils.setTr(tableObj.tbody, values, createTr);
		
		ConfigForm.utils.createAddButton(ConfigLang.form.button.add, tableObj.tfoot, util.insert);
	},
	createTr: function(value) {
		var LANG = ConfigLang.form.select;
		
		var util = ConfigForm.reform.sortOption;
		var tableClassName = util.config.tableClassName;
		var recombination = util.recombination;
		var onchangeEvent = ConfigForm.utils.recombinationTrigger(tableClassName, recombination);
		
		var trObj = ConfigForm.utils.createTrObj(["name", "metadata", "datatype", "display", "func"]);
		
		var inputName = ConfigForm.utils.createInput.text(value.name, "name-value"
			, trObj.name, onchangeEvent);
		var inputMetadata = ConfigForm.utils.createInput.text(value.metadata, "metadata-value"
			, trObj.metadata, onchangeEvent);
		
		var datatype = value.datatype;
		var otherDatatype = "";
		if (datatype != "date" 
			&& datatype != "title" 
			&& datatype != "text")
		{
			otherDatatype = datatype;
			datatype = "other";
		}
		
		var selectDatatype = ConfigForm.utils.createInput.select(datatype, ["date", "text", "other"], [LANG.date, LANG.text, LANG.other]
			, "datatype-value" , trObj.datatype, onchangeEvent);
		
		ConfigForm.utils.spacePadding(trObj.datatype);
		var inputDatatype = ConfigForm.utils.createInput.text(otherDatatype, "datatype-other-value"
			, trObj.datatype, onchangeEvent);
		if (otherDatatype == "") inputDatatype.hide();
		
		selectDatatype.change(function () {
			if (this.value == "other")
				inputDatatype.show().focus();
			else
				inputDatatype.hide();
		});
		
		var selectDisplay = ConfigForm.utils.createInput.select(value.display, ["show", "hide"], [LANG.show, LANG.hide]
			, "display-value" , trObj.display, onchangeEvent);
		
		var insertFunc = util.insert;
		var btnLang = ConfigLang.form.button;
		var btnMoveUp = ConfigForm.utils.createButton(btnLang.moveUp, btnLang.moveUpImg
			, trObj.func, ConfigForm.utils.moveUp, recombination);
		var btnMoveDown = ConfigForm.utils.createButton(btnLang.moveDown, btnLang.moveDownImg
			, trObj.func, ConfigForm.utils.moveDown, recombination);
		var btnInsert = ConfigForm.utils.createButton(btnLang.insert, btnLang.insertImg
			, trObj.func, insertFunc, recombination);
		var btnDelete = ConfigForm.utils.createButton(btnLang.doDelete, btnLang.doDeleteImg
			, trObj.func, ConfigForm.utils.deleteButton, recombination);
		
		return trObj.tr;
	},
	parseValue: function (text) {
		var lines = ConfigForm.utils.splitComma(text);
		
		var output = new Array;
		for (var i = 0; i < lines.length; i++)
		{
			var o = {
				name: "",
				metadata: "",
				datatype: "text",
				display: "show"
			};
			
			var l = lines[i].split(":");
			
			o.name = l[0];
			o.metadata = l[1];
			o.datatype = l[2];
			if (l.length > 3)
				o.display = l[3];
			
			output.push(o);
		}
		return output;
	},
	insert: function (thisObj)
	{
		var value = {
			name: "",
			metadata: "",
			datatype: "text",
			display: "show"
		};
		var tr = ConfigForm.reform.sortOption.createTr(value);
		if (jQuery(thisObj).attr("tagName").toLowerCase() != "tr")
			thisObj = jQuery(thisObj).parents("tr:first");
		thisObj.after(tr);
	},
	recombination: function(table) 
	{
		var text = "";
		var trs = table.find("> tbody > tr");
		for (var i = 0; i < trs.length; i++)
		{
			var tr = trs.eq(i);
			
			var name = ConfigForm.utils.getInputValid(tr.find("> td.name > input.name-value:text"));
			var metadata = ConfigForm.utils.getInputValid(tr.find("> td.metadata > input.metadata-value:text"));
			
			var datatype = tr.find("> td.datatype select.datatype-value").val();
			if (datatype == "other")
			{
				datatype = tr.find("> td.datatype input.datatype-other-value").val();
				if (datatype == "") datatype = "other";
			}
			
			var display = tr.find("> td.display select.display-value").val();
			
			if (text != "")
				text = text + ", ";
			text = text + name + ":" + metadata + ":" + datatype + ":" + display;
		}
		
		table.nextAll("textarea.value.sort-option").val(text);
	}
};