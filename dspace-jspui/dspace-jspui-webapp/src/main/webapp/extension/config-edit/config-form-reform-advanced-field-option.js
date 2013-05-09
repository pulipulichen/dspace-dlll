ConfigForm.reform.advancedFieldOption= {
			init: function (options, metadatas) {
				var LANG = ConfigLang.form.header;
				ConfigForm.utils.removeRepeatTable("advanced-option-table", options);
				
				//author:dc.contributor.*, 
				//author:dc.creator.*, title:dc.title.*, ...
				var optionTable = jQuery("<table cellpadding=\"0\" cellspacing=\"0\" class=\"advanced-option-table\"><tbody></tbody><tfoot><tr><td colspan=\"3\"></td></tr></tfoot></table>")
					.insertBefore(options);
				
				var thead = jQuery("<thead><tr><th class=\"option\">"
					+ LANG.fieldName
					+ "</th><th class=\"metadata\">" 
					+ LANG.metadata
					+ "</th></tr></thead>")
					.appendTo(optionTable);
				var tbody = optionTable.find("tbody:first");
				var optionPair = ConfigForm.reform.advancedFieldOption.parseValue(options, metadatas);
				jQuery.each(optionPair, function (option, metadatas) {
					var optionTr = ConfigForm.reform.advancedFieldOption.createOptionTr(option, metadatas.show, metadatas.data, tbody);
				});
				
				var tfoot = optionTable.children("tfoot:last tr td");
				var btnAdd = ConfigForm.utils.createButton(ConfigLang.form.button.add, tfoot, ConfigForm.reform.advancedFieldOption.insertOption);
				
				options.hide();
				metadatas.hide();
			}, //init: function (input) {
			parseValue: function(options, metadatas) {
				var values = options.val().split(",");
				
				var output = new Object;
				for (var i = 0; i < values.length; i++)
				{
					var option = values[i];
						option = jQuery.trim(option);
					
					if (typeof(output[option]) == "undefined")
					{
						output[option] = { 
							show: true,
							data: new Array
						};
					}
					
				}	//for (var i = 0; i < values.length; i++)
				
				values = metadatas.val().split(",");
				for (var i = 0; i < values.length; i++)
				{
					var v = jQuery.trim(values[i]);
					if (v.indexOf(":") == -1)
						continue;
					
					var option = v.substring(0, v.indexOf(":"));
						option = jQuery.trim(option);
					var metadata = v.substring(v.indexOf(":") + 1, v.length);
						metadata = jQuery.trim(metadata);
					
					if (typeof(output[option]) != "undefined")
					{
						output[option].data.push(metadata);
					}
					else
					{
						output[option] = {
							show: false,
							data: new Array
						}
						output[option].data.push(metadata);
					}
				}
				
				return output;
			},
			createOptionTr: function (option, show, metadatas, appendToObj)
			{
				var LANG = ConfigLang.form.label;
				
				var tr = jQuery("<tr class=\"option\"><td class=\"option\"><input type=\"text\" class=\"option-value\" /></td><td class=\"metadata\"></td><td class=\"function\"></td></tr>");
				
				if (typeof(option) != "undefined")
					tr.find("input:text.option-value").val(option);
				if (typeof(appendToObj) == "object")
					tr.appendTo(appendToObj);
				tr.find("input:text.option-value").change(function () {
					ConfigForm.reform.advancedFieldOption.recombination(jQuery(this).parents("table.advanced-option-table:first"));
				});
				
				var th = tr.find(".option:first");
				var checkboxANYLabel = jQuery("<label><input type=\"checkbox\" class=\"is-any\" /> "+LANG.anyField+"<label>")
					.appendTo(th);
				
				var checkboxShowLabel = jQuery("<label><input type=\"checkbox\" class=\"is-show\" /> "+LANG.show+"<label>")
					.appendTo(th)
					.change(function () {
						ConfigForm.reform.advancedFieldOption.recombination(jQuery(this).parents("table.advanced-option-table:first"));
					});
				if (show == true)
					checkboxShowLabel.find("input:checkbox").attr("checked","checked");
				
				var metadataTd = tr.find("td.metadata:first");
				var metadataTable = jQuery("<table cellspacing=\"0\" cellpadding=\"0\"><tbody></tbody><tfoot><tr><td colspan=\"2\"></td></tr></tfoot></table>")
					.appendTo(metadataTd);
				var metadataTbody = metadataTable.find("tbody");
				for (var i = 0; i < metadatas.length; i++)
				{
					var optionTr = ConfigForm.reform.advancedFieldOption.createMetadataTr(metadatas[i], metadataTbody);
				}
				
				
				var checkboxANY = checkboxANYLabel.find("input:checkbox.is-any:first")
					.change(function () {
						var optionInput = jQuery(this).parents("label:first").prevAll("input:text.option-value:first");
						var metadataTd = jQuery(this).parents("tr:first").children("td.metadata:first").children();
						if (ConfigForm.valid.checked(this) == true)
						{
							optionInput.attr("disabled", "disabled");
							metadataTd.hide();
							//metadataTd.css("visibility", "hidden");
						}
						else
						{
							optionInput.removeAttr("disabled");
							metadataTd.show();
							//metadataTd.css("visibility", "visible");
						}
						ConfigForm.reform.advancedFieldOption.recombination(jQuery(this).parents("table.advanced-option-table:first"));
					});
				
				if (typeof(option) != "undefined" && option == "ANY")
				{
					setTimeout(function () {
						checkboxANY.click().change();
					}, 50);
				}
				
				var func = tr.children("td.function:last");
				var btnLang = ConfigLang.form.button;
				var btnMoveUp = ConfigForm.utils.createButton(btnLang.moveUp, btnLang.moveUpImg
					, func, ConfigForm.utils.moveUp, ConfigForm.reform.advancedFieldOption.recombination);
				var btnMoveDown = ConfigForm.utils.createButton(btnLang.moveDown, btnLang.moveDownImg
					, func, ConfigForm.utils.moveDown, ConfigForm.reform.advancedFieldOption.recombination);
				var btnInsert = ConfigForm.utils.createButton(btnLang.insert, btnLang.insertImg
					, func, ConfigForm.reform.multiComma.insert, ConfigForm.reform.advancedFieldOption.recombination);
				var btnDelete = ConfigForm.utils.createButton(btnLang.doDelete, btnLang.doDeleteImg
					, func, ConfigForm.utils.deleteButton, ConfigForm.reform.advancedFieldOption.recombination);
				
				var metadataTfoot = metadataTable.find("tfoot tr td");
				var btnAdd = ConfigForm.utils.createButton(ConfigLang.form.button.add, metadataTfoot, ConfigForm.reform.advancedFieldOption.insertMetadata);
				
				return tr;
			},
			insertOption: function (thisBtn) {
				var tbody = jQuery(thisBtn).parents("table:first").find("tbody:first");
				var tr = ConfigForm.reform.advancedFieldOption.createOptionTr("", new Array, tbody);
				tr.find("> td.metadata table > tfoot > tr > td > button").click();
				ConfigForm.reform.advancedFieldOption.recombination(jQuery(thisBtn).parents("table.advanced-option-table:first"));
			},
			insertMetadata: function(thisBtn) {
				var tbody = jQuery(thisBtn).parents("table:first").find("tbody:first");
				var tr = ConfigForm.reform.advancedFieldOption.createMetadataTr("", tbody);
				ConfigForm.reform.advancedFieldOption.recombination(jQuery(thisBtn).parents("table.advanced-option-table:first"));
			},
			createMetadataTr: function (metadata, appendToObj)
			{
				var tr = jQuery("<tr><td>"
					+ "<input type=\"text\" class=\"metadata-value\" />" 
					+ "</td><td class=\"function\"></td></tr>");
				/*
				var tr = jQuery("<tr><td>"
					+ "<input type=\"text\" class=\"metadata-value schema\" />." 
					+ "<input type=\"text\" class=\"metadata-value element\" />."
					+ "<input type=\"text\" class=\"metadata-value qualifeir\" />"
					+ "</td><td class=\"function\"></td></tr>");
				*/
				
				tr.find("input:text.metadata-value").change(function () {
					ConfigForm.reform.advancedFieldOption.recombination(jQuery(this).parents("table.advanced-option-table:first"));
				});
				
				if (typeof(metadata) != "undefined")
				{
					tr.find(".metadata-value").val(metadata);
					/*
					var metadatas = metadata.split(".");
					tr.find(".metadata-value.schema").val(metadatas[0]);
					tr.find(".metadata-value.element").val(metadatas[1]);
					if (metadatas.length == 3)
						tr.find(".metadata-value.qualifeir").val(metadatas[2]);
					*/
				}
				if (typeof(appendToObj) == "object")
					tr.appendTo(appendToObj);
				
				
				var func = tr.find("td.function");
				
				var btnLang = ConfigLang.form.button;
				var btnDelete = ConfigForm.utils.createButton(btnLang.doDelete, btnLang.doDeleteImg
					, func, ConfigForm.utils.deleteButton
					, ConfigForm.reform.advancedFieldOption.recombination);
				
				return tr;
			},
			recombination: function (table) {
				var optionValues = table.find("input.option-value");
				var optionValue = "";
				for (var i = 0; i < optionValues.length; i++)
				{
					var v = jQuery.trim(optionValues.eq(i).val());
					if (v == "")
						continue;
					
					var checkbox = optionValues.eq(i).nextAll("label:first").children("input:checkbox");
					if (ConfigForm.valid.checked(checkbox))
						v = "ANY";
					
					var isShow = optionValues.eq(i).parent("td:first").find("input.is-show:checkbox");
					if (ConfigForm.valid.checked(isShow) == true)
					{
						if (optionValue != "")
							optionValue = optionValue + ", ";
						optionValue = optionValue + v;
					}
				}
				
				var optionInput = table.nextAll("textarea.advanced-field-search-options:first");
				optionInput.val(optionValue);
				
				var metadataValues = table.find("td.metadata table tbody tr td input.metadata-value");
				var value = "";
				for (var i = 0; i < metadataValues.length; i++)
				{
					var input = metadataValues.eq(i);
					
					var metadata = jQuery.trim(input.val());
					if (metadata == "")
						continue;
					var optionTr = input.parents("tr.option:first");
					
					var option = jQuery.trim(optionTr.find("input:text.option-value:first").val());
					var checkbox = optionTr.find("input:checkbox.is-any:first");
					if (ConfigForm.valid.checked(checkbox))
						option = "ANY";
					
					if (option == "" || option == "ANY")
						continue;
					
					if (value != "")
						value = value + ", ";
					
					value = value + option + ":" + metadata;
				}
				var metadataInput = table.nextAll("textarea.advanced-field-search-metadatas:first");
				metadataInput.val(value);
			}
		};	//advancedFieldOption: {