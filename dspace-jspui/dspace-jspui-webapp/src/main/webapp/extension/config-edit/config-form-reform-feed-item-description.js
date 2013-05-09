ConfigForm.reform.feedItemDescription = {
	config: {
		tableClassName: "sort-option-table",
		valueClassName: "feed-item-description",
		createAddButtonText: ConfigLang.form.button.add,
		theads: [ConfigLang.form.header.metadata, ConfigLang.form.header.datatype, ""],
		trs: ["metadata", "isDate", "func"],
		constructor: function () { 
			return {
				metadata: "",
				isDate: ""
			};
		}
	},
	init: function (input) {
		var classObj = ConfigForm.reform.feedItemDescription;
		ConfigForm.utils.init(input, classObj);
	},
	createTr: function(value, classObj) {
		var LANG = ConfigLang.form.select;
		
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
		
		input[trs[1]] = ConfigForm.utils.createInput.select(value[trs[1]], ["", "date"], [LANG.text, LANG.date]
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
			
			var isDate = ConfigForm.utils.getBracketText(lines[i]);
			if (isDate == null)
			{
				o.metadata = lines[i];
			}
			else
			{
				o.metadata = lines[i].substring(0, lines[i].lastIndexOf("("));
				o.isDate = isDate;
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
			
			var isDate = tr.find("> td."+headers[1]+" > ."+headers[1]+"-value").val();
			
			if (isDate == "date")
				isDate = "(date)";
			
			if (text != "")
				text = text + ", ";
			text = text + metadata + isDate;
		}
		table.nextAll("." + classObj.config.valueClassName + ":first").val(text);
	}
};