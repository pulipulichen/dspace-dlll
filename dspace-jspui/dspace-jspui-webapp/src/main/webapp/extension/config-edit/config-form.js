ConfigForm = {
	initConfig: function () {
		ConfigForm.config = {
			form: jQuery("table#configFormTable")
		}
	},
	init: function() {
		ConfigForm.initConfig();
		ConfigForm.dialog.init();
		
		var form = ConfigForm.config.form;
		ConfigForm.formatTable(form);
		
		ConfigForm.reform.setup(form);
		
		ConfigForm.codeToForm(form, function () {
			
		});
	},
	codeToForm: function (form, callback) {
		var LANG = ConfigLang.form;
		ConfigForm.dialog.setMessage(LANG.dialog.message);
		ConfigForm.dialog.open(function () {
			if (typeof(form) == "function")
			{
				callback = form;
				form = ConfigForm.config.form;
			}
			else if (typeof(form) == "undefined")
				form = ConfigForm.config.form;
			
			var inputKeys = form.find("input:hidden.key:not(.spec)");
			
			var loop = function (i, inputKeys, callback) {
				if (i < inputKeys.length)
				{
					var key = inputKeys.eq(i).val();
					var value = ConfigEditor.getProperty(key);
					if (typeof(value) != "undefined")
					{
						var inputValue = inputKeys.eq(i).prevAll(".value:first");
						if (inputValue.length == 0)
							inputValue = inputKeys.eq(i).parents("td:first").find(".value");
						
						if (inputValue.length == 1)
							inputValue.val(value).change();
						else (inputValue.length > 1)
						{
							for (var v = 0; v < inputValue.length; v++)
							{
								if (inputValue.eq(v).val() == value)
								{
									inputValue.eq(v).attr("checked", "checked").change();
									break;
								}
							}
						}
					}
					
					i++
					if (i % 10 == 0)
					{
						setTimeout(function() {
							loop(i, inputKeys, callback);
						}, 10);
					}
					else
						loop(i, inputKeys, callback);
				}
				else
				{
					if (typeof(callback) == "function")
						callback();
				}
			};
			
			loop(0, inputKeys, function () {
				ConfigForm.dialog.close();
				
				if (typeof(callback) == "function")
					callback();
			});
		});
	},
	formToCode: function (form, callback) {
		var LANG = ConfigLang.form;
		ConfigForm.dialog.setMessage(LANG.dialog.message);
		ConfigForm.dialog.open(function () {
			if (typeof(form) == "function")
			{
				callback = form;
				form = ConfigForm.config.form;
			}
			else if (typeof(form) == "undefined")
				form = ConfigForm.config.form;
			
			var inputKeys = form.find("input:hidden.key:not(.spec)");
			
			var loop = function (i, inputKeys, callback) {
				if (i < inputKeys.length)
				{
					var keyInput = inputKeys.eq(i);
					var key = keyInput.val();
					var valueInput = keyInput.prevAll(".value:first");
					if (valueInput.length == 1)
						var value = valueInput.val();
					else if (valueInput.length == 0)
					{
						valueInput = keyInput.parent().find(".value");
						if (valueInput.length == 1)
							var value = valueInput.val();
						else if (valueInput.length > 1)
							var value = valueInput.filter(":checked:first").attr("value");
						else
							var value = "";
					}
					ConfigEditor.setProperty(key, value);
					
					i++
					
					if (i % 10 == 0)
					{
						setTimeout(function() {
							loop(i, inputKeys, callback);
						}, 50);
					}
					else
						loop(i, inputKeys, callback);
				}
				else
				{
					if (typeof(callback) == "function")
						callback();
				}
			};
			
			loop(0, inputKeys, function () {
				ConfigForm.dialog.close();
				
				if (typeof(callback) == "function")
					callback();
			});
		});
	},
	formatTable: function (form)
	{
		//著色！
		var trs = form.find("> tbody > tr");
		var rowCounter = 0;
		for (var i = 0; i < trs.length; i++)
		{
			var cols = trs.eq(i).children();
			if (cols.length == 1)
			{
				rowCounter = 1;
				cols.addClass("col-span");
				continue;
			}
			
			var row = "odd";
			if (rowCounter % 2 == 0)
				row = "even";
			
			
			for (var j = 0; j < cols.length; j++)
			{
				var col = "Odd";
				if (j % 2 == 1) col = "Even";
				
				var className = row + "Row" + col + "Col";
				
				cols.eq(j).addClass(className);
			}
			rowCounter++;
		}
	},
	reform: {
		setup: function (form)
		{
			//reform
			var inputs = form.find(".value.multi-comma").change(function () {
					ConfigForm.reform.multiComma.init(jQuery(this));
				});
			
			//var options = form.find(".value.advanced-field-search-options").change(function () {
			//		var metadatas = form.find(".value.advanced-field-search-metadatas");
			//		ConfigForm.reform.advancedFieldOption.init(jQuery(this), metadatas);
			//	});
			var metadatas = form.find(".value.advanced-field-search-metadatas").change(function () {
					var options = form.find(".value.advanced-field-search-options");
					var metadatas = jQuery(this);
					ConfigForm.reform.advancedFieldOption.init(options, metadatas);
				});
			
			/*
			var browseIndex = form.find(".value.browse-index:first").change(function () {
					ConfigForm.reform.browseIndex.init(jQuery(this));
				});
			*/
			
			var sortOption = form.find(".value.sort-option:first").change(function () {
					ConfigForm.reform.sortOption.init(jQuery(this));
				});
			
			
			var feedItemDescription = form.find(".value.feed-item-description:first")
				.change(function () {
					ConfigForm.reform.feedItemDescription.init(jQuery(this));
				});
			
			var itemDisplayDefault = form.find(".value.item-display-default:first")
				.change(function () {
					ConfigForm.reform.itemDisplayDefault.init(jQuery(this));
				});
			
			form.find(".value.itemlist-columns:first").change(function () {
				ConfigForm.reform.itemlistColumns.init( {
					columns: form.find(".value.itemlist-columns:first"), 
					width: form.find(".value.itemlist-widths:first")
				});
			});
		}
	}
};

