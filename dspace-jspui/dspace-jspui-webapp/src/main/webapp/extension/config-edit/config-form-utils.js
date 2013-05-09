ConfigForm.utils = {
	startsWith: function (value, needle)
	{
		if (value.substring(0, needle.length) == needle)
			return true;
		else
			return false;
	},
	endsWith: function (value, needle)
	{
		var len = value.length;
		if (value.substring(len-needle.length, len) == needle)
			return true;
		else
			return false;
	},
	createButton: function(innerHTML, img, appendTo, onclickEvent, recombinationEvent)
	{
		var btn = jQuery("<button type=\"button\"></button>")
			.attr("title", innerHTML);
		
		if (typeof(img) == "string")
		{
			var image = jQuery("<img border=\"0\" />")
				.attr("title", innerHTML)
				.attr("src", img)
				.attr("alt", innerHTML)
				.appendTo(btn);
		}
		else
		{
			btn.html(innerHTML);
			
			recombinationEvent = onclickEvent;
			onclickEvent = appendTo;
			appendTo = img;
		}
		
		if (typeof(appendTo) == "object")
			btn.appendTo(appendTo);
		
		
		if (typeof(onclickEvent) == "function")
		{
			btn.click(function () {
				if (typeof(recombinationEvent) == "function")
				{
					var table = jQuery(this).parents("table:first");
					onclickEvent(this);
					recombinationEvent(table);
				}
				else
					onclickEvent(this);
			});
		}
		
		return btn;
	},
	createAddButton: function (text, tfoot, classObj)
	{
		var btnAdd = jQuery("<button type=\"button\"></button>")
			.html(text)
			.click(function () {
				var lastTr = jQuery(this).parents("table:first").find("> tbody > tr:last");
				classObj.insert(lastTr, classObj);
			})
			.appendTo(tfoot);
		return btnAdd;
	},
	createTableObj: function(className, col, insertBeforeObj) {
		ConfigForm.utils.removeRepeatTable(className, insertBeforeObj);
		
		var table = jQuery("<table cellpadding=\"0\" cellspacing=\"0\"><tbody></tbody><tfoot><tr><td colspan=\""+col+"\"></td></tr></tfoot></table>")
			.addClass(className);
		
		var tbody = table.find("tbody:first");
		var tfoot = table.find("tfoot:last > tr > td");
		
		if (typeof(insertBeforeObj) == "object")
			table.insertBefore(insertBeforeObj);
		
		insertBeforeObj.hide();
		
		return {
			table: table,
			tbody: tbody,
			tfoot: tfoot
		};
	},
	removeRepeatTable: function (className, insertBeforeObj)
	{
		insertBeforeObj = jQuery(insertBeforeObj);
		insertBeforeObj.prevAll("table."+className).remove();
	},
	moveUp: function(thisBtn)
	{
		var thisTr = jQuery(thisBtn).parents("tr:first");
		var needleTr = thisTr.prev();
		if (needleTr.length == 1)
		{
			needleTr.before(thisTr);
			jQuery(thisBtn).focus();
		}
	},
	moveDown: function(thisBtn)
	{
		var thisTr = jQuery(thisBtn).parents("tr:first");
		var needleTr = thisTr.next();
		if (needleTr.length == 1)
		{
			needleTr.after(thisTr);
			jQuery(thisBtn).focus();
		}
	},
	deleteButton: function(thisBtn)
	{
		if (window.confirm(ConfigLang.form.deleteConfirm))
		{
			var thisTr = jQuery(thisBtn).parents("tr:first");
			thisTr.remove();
		}
	},
	splitComma: function (text)
	{
		if (typeof(text) == "object")
		{
			try
			{
				text = jQuery(text).val();
			} catch (e) {}
		}
		var values = text.split(",");
		for (var i = 0; i < values.length; i++)
			values[i] = jQuery.trim(values[i]);
		
		return values;
	},
	createThead: function (table, headers)
	{
		var thead = jQuery("<thead><tr></tr></thead>")
			.prependTo(table);
		
		var tr = thead.find("tr:first");
		for (var i = 0; i < headers.length; i++)
		{
			var th = jQuery("<th></th>")
				.html(headers[i])
				.appendTo(tr);
		}
		return thead
	},
	createTrObj: function (cols)
	{
		var tr = jQuery("<tr></tr>");
		
		var obj = {
			tr: tr
		};
		for (var i = 0; i < cols.length; i++)
		{
			obj[cols[i]] = jQuery("<td></td>")
				.addClass(cols[i])
				.appendTo(tr);
		}
		
		return obj;
	},
	createInput: {
		label: function (text, appendToObj) 
		{
			var label = jQuery("<label></label>").html(text)
				label.appendTo(appendToObj);
			return label;
		},
		text: function (value, className, appendToObj, onchangeEvent)
		{
			var input = jQuery("<input type=\"text\" />")
				.addClass(className)
				.appendTo(appendToObj);
			input.val(value);
			if (typeof(onchangeEvent) == "function")
				input.change(function () { onchangeEvent(this); });
			return input;
		},
		select: function (value, optionValues, optionHTMLs, className
			, appendToObj, onchangeEvent)
		{
			var select = jQuery("<select></select>")
				.addClass(className)
				.appendTo(appendToObj);
			
			if (typeof(onchangeEvent) == "function")
				select.change(function () { onchangeEvent(this); });
			
			for (var i = 0; i < optionValues.length; i++)
			{
				if(typeof(optionHTMLs[i]) == "undefined")
					alert(optionValues[i]);
				var option = jQuery("<option></option>")
					.html(optionHTMLs[i])
					.attr("value", optionValues[i])
					.appendTo(select);
				
				if (optionValues[i] == value)
					option.attr("selected", "selected");
			}
			
			return select;
		}
	},
	recombinationTrigger: function(tableClassName, func)
	{
		return function(thisObj)
		{
			func(jQuery(thisObj).parents("table."+tableClassName+":first"));
		}
	},
	setTr: function (tbody, values, createTr, classObj) {
		for (var i = 0; i < values.length; i++)
		{
			var v = values[i];
			var tr = createTr(v, classObj)
				.appendTo(tbody);
		}
	},
	spacePadding: function(appendToObj)
	{
		jQuery("<span> </span>").appendTo(appendToObj);
	},
	getInputValid: function(input)
	{
		var value = input.val();
			value = jQuery.trim(value);
		if (value == "")
			input.addClass("empty");
		else
			input.removeClass("empty");
		return value;
	},
	init: function (input, classObj) {
		
		var values = classObj.parseValue(input, classObj);
		
		var theads = classObj.config.theads;
		
		var tableClassName = classObj.config.tableClassName;
		var tableObj = ConfigForm.utils.createTableObj(tableClassName, theads.length, input);
		
		ConfigForm.utils.createThead(tableObj.table, theads);
		
		var createTr = classObj.createTr;
		ConfigForm.utils.setTr(tableObj.tbody, values, createTr, classObj);
		
		var createAddButtonText = classObj.config.createAddButtonText;
		ConfigForm.utils.createAddButton(createAddButtonText, tableObj.tfoot, classObj);
	},
	setFunctionButton: function (tdFunc, classObj, onlyDelete)
	{
		var recombination = function (thisObj)
			{
				classObj.recombination(thisObj, classObj);
			};
		var insertFunc = function (thisObj)
			{
				ConfigForm.utils.insert(thisObj, classObj);
			};
			
		var btnLang = ConfigLang.form.button;
		if (typeof(onlyDelete) == "undefined"
			|| (typeof(onlyDelete) != "undefined" && onlyDelete != true))
		{
			var btnMoveUp = ConfigForm.utils.createButton(btnLang.moveUp, btnLang.moveUpImg
				, tdFunc, ConfigForm.utils.moveUp, recombination);
			var btnMoveDown = ConfigForm.utils.createButton(btnLang.moveDown, btnLang.moveDownImg
				, tdFunc, ConfigForm.utils.moveDown, recombination);
			var btnInsert = ConfigForm.utils.createButton(btnLang.insert, btnLang.insertImg
				, tdFunc, insertFunc, recombination);
		}
		var btnDelete = ConfigForm.utils.createButton(btnLang.doDelete, btnLang.doDeleteImg
			, tdFunc, ConfigForm.utils.deleteButton, recombination);
	},
	getBracketText: function (text)
	{
		var text = jQuery.trim(text);
		var len = text.length;
		if (text.indexOf("(") != -1
			&& text.substring(len-1, len) == ")")
		{
			var start = text.lastIndexOf("(") + 1;
			var end = len-1;
			var value = text.substring(start,end);
			value = jQuery.trim(value);
			return value;
		}
		else
			return null;
	},
	insert: function (thisObj, classObj)
	{
		var value = classObj.config.constructor();
		var tr = classObj.createTr(value, classObj);
		if (jQuery(thisObj).attr("tagName").toLowerCase() != "tr")
			thisObj = jQuery(thisObj).parents("tr:first");
		thisObj.after(tr);
	}
};