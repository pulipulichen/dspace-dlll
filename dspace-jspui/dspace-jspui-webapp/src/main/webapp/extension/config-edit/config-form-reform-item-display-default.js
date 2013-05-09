ConfigForm.reform.itemDisplayDefault = {
	config: {
		tableClassName: "item-display-default-table",
		valueClassName: "item-display-default",
		createAddButtonText: ConfigLang.form.button.add,
		theads: [ConfigLang.form.header.metadata, ConfigLang.form.header.datatype, ""],
		trs: ["metadata", "datatype", "func"],
		constructor: function () { 
			return {
				metadata: "",
				datatype: ""
			};
		}
	},
	init: function (input) {
		var classObj = ConfigForm.reform.itemDisplayDefault;
		ConfigForm.utils.init(input, classObj);
	},
	createTr: function(value, classObj) {
		
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
		var LANG = ConfigLang.form.select;
		input[trs[1]] = ConfigForm.utils.createInput.select(value[trs[1]], ["", "date", "link"], [LANG.text, LANG.date, LANG.link]
			, trs[1]+"-value" , trObj[trs[1]], onchangeEvent);
		
		ConfigForm.utils.setFunctionButton(trObj.func, classObj, false);
		
		return trObj.tr;
	},
	parseValue: function (text, classObj) {
		var lines = ConfigForm.utils.splitComma(text);
		
		var output = new Array;
		for (var i = 0; i < lines.length; i++)
		{
			var o = classObj.config.constructor();
			
			var datatype = ConfigForm.utils.getBracketText(lines[i]);
			if (datatype == null)
			{
				o.metadata = lines[i];
			}
			else
			{
				o.metadata = lines[i].substring(0, lines[i].lastIndexOf("("));
				o.datatype = datatype;
			}
			
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
		var trs = table.find("> tbody > tr");
		for (var i = 0; i < trs.length; i++)
		{
			var tr = trs.eq(i);
			
			var metadata = ConfigForm.utils.getInputValid(tr.find("> td."+headers[0]+" > ."+headers[0]+"-value"));
			if (metadata == "")
				continue;
			
			var datatype = tr.find("> td."+headers[1]+" > ."+headers[1]+"-value").val();
			
			if (datatype == "date" || datatype == "link")
				datatype = "("+datatype+")";
			
			if (text != "")
				text = text + ", ";
			text = text + metadata + datatype;
		}
		table.nextAll("." + classObj.config.valueClassName + ":first").val(text);
	}
};