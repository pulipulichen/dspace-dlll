ConfigForm.reform.browseIndex = {
	config: {
		tableClassName: "browse-index-table"
	},
	init: function (input) {
		var LANG = ConfigLang.form.header;
		var values = ConfigForm.reform.browseIndex.parseValue(input);
		
		var tableClassName = ConfigForm.reform.browseIndex.config.tableClassName;
		var tableObj = ConfigForm.utils.createTableObj(tableClassName, 5, input);
		
		ConfigForm.utils.createThead(tableObj.table, [LANG.indexName, LANG.type, "", LANG.order, ""]);
		
		var createTr = ConfigForm.reform.browseIndex.createTr;
		ConfigForm.utils.setTr(tableObj.tbody, values, createTr);
		
		ConfigForm.utils.createAddButton(ConfigLang.form.button.add, tableObj.tfoot, ConfigForm.reform.browseIndex.insert);
	},
	createTr: function(value) {
		var LANG = ConfigLang.form;
		
		var tableClassName = ConfigForm.reform.browseIndex.config.tableClassName;
		var recombination = ConfigForm.reform.browseIndex.recombination;
		var onchangeEvent = ConfigForm.utils.recombinationTrigger(tableClassName, recombination);
		
		var trObj = ConfigForm.utils.createTrObj(["name", "type", "value", "order", "func"]);
		
		var inputName = ConfigForm.utils.createInput.text(value.name, "name-value"
			, trObj.name, onchangeEvent);
		var selectType = ConfigForm.utils.createInput.select(value.type, ["metadata", "item"], [LANG.select.metadata, LANG.select.item]
			, "type-value" , trObj.type, onchangeEvent);
		
		var datatype = value.datatype;
		var otherDatatype = "";
		if (datatype != "date" 
			&& datatype != "title" 
			&& datatype != "text")
		{
			otherDatatype = datatype;
			datatype = "other";
		}
		
		var tableMetadata = jQuery("<table><tr class=\"metadata\"><th></th><td></td></tr><tr class=\"datatype\"><th></th><td></td></tr></table>")
			.appendTo(trObj.value);
		
		//var divMetadata = jQuery("<div></div>")
		//	.addClass("metadata-div")
		//	.appendTo(trObj.value);
		
		var labelMetdata = ConfigForm.utils.createInput.label(LANG.label.metadata, tableMetadata.find("tr.metadata > th"))
			.css("display", "block");
		var inputMetadata = ConfigForm.utils.createInput.text(value.metadata, "metadata-value"
			, tableMetadata.find("tr.metadata > td"), onchangeEvent);
		
		
		var labelDatatype = ConfigForm.utils.createInput.label(LANG.label.datatype, tableMetadata.find("tr.datatype > th"));
		var selectDatatype = ConfigForm.utils.createInput.select(datatype, ["date", "title", "text", "other"]
			, [LANG.select.date, LANG.select.title, LANG.select.text, LANG.select.other]
			, "datatype-value" , tableMetadata.find("tr.datatype > td"), onchangeEvent);
		
		ConfigForm.utils.spacePadding(tableMetadata.find("tr.datatype > td"));
		var inputDatatype = ConfigForm.utils.createInput.text(otherDatatype, "datatype-other-value"
			, tableMetadata.find("tr.datatype > td"), onchangeEvent);
		if (otherDatatype == "") inputDatatype.hide();
		
		selectDatatype.change(function () {
			if (this.value == "other")
				inputDatatype.show().focus();
			else
				inputDatatype.hide();
		});
		
		//var divOption = jQuery("<div></div>")
		//	.addClass("option-div")
		//	.appendTo(trObj.value);
		var tableOption = jQuery("<table><tr class=\"option\"><th></th><td></td></tr></table>")
			.appendTo(trObj.value);
		
		var labelOption = ConfigForm.utils.createInput.label(LANG.label.option, tableOption.find("tr.option > th"));
		var inputOption = ConfigForm.utils.createInput.text(value.option, "option-value"
			, tableOption.find("tr.option > td"), onchangeEvent);
		
		if (value.type == "metadata")
		{
			tableMetadata.show();
			tableOption.hide();
		}
		else
		{
			tableMetadata.hide();
			tableOption.show();
		}
		selectType.change(function () {
			if (this.value == "metadata")
			{
				tableMetadata.show();
				tableOption.hide();
			}
			else
			{
				tableMetadata.hide();
				tableOption.show();
			}
		});
		
		//最後是排序
		var selectOrder = ConfigForm.utils.createInput.select(value.order, ["asc", "desc"]
			, [LANG.select.asc, LANG.select.desc]
			, "order-value" , trObj.order, onchangeEvent);
		
		var insertFunc = ConfigForm.reform.browseIndex.insert;
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
				type: "metadata",
				metadata: "",
				datatype: "text",
				option: "",
				order: "asc"
			};
			
			var l = lines[i].split(":");
			
			o.name = l[0];
			o.type = l[1];
			
			if (o.type == "metadata")
			{
				o.metadata = l[2];
				o.datatype = l[3];
				if (l.length > 4)
					o.order = l[4];
			}
			else if (o.type == "item")
			{
				o.option = l[2];
				if (l.length > 3)
					o.order = l[3];
			}
			output.push(o);
		}
		return output;
	},
	insert: function (thisObj)
	{
		var value = {
			name: "",
			type: "metadata",
			metadata: "",
			datatype: "text",
			option: "",
			order: "asc"
		};
		var tr = ConfigForm.reform.browseIndex.createTr(value);
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
			var type = tr.find("> td.type > select.type-value").val();
			
			var value = "";
			if (type == "metadata")
			{
				var metadata = ConfigForm.utils.getInputValid(tr.find("> td.value input.metadata-value"));
				
				var datatype = tr.find("> td.value select.datatype-value").val();
				if (datatype == "other")
				{
					datatype = tr.find("> td.value input.datatype-other-value").val();
					if (datatype == "") datatype = "other";
				}
				value = metadata + ":" + datatype;
			}
			else
			{
				value = ConfigForm.utils.getInputValid(tr.find("> td.value input.option-value"));
			}
			
			var order = tr.find("> td.order > select.order-value").val();
			
			if (text != "")
				text = text + ", ";
			text = text + name + ":" + type + ":" + value + ":" + order;
		}
		
		table.nextAll("textarea.value.browse-index").val(text);
	}
};