ConfigForm.reform.multiComma = {
			init: function (input) {
				ConfigForm.utils.removeRepeatTable("multi-comma-table", input);
				
				input = jQuery(input);
				var values = input.val().split(",");
				
				var table = jQuery("<table cellpadding=\"0\" cellspacing=\"0\" class=\"multi-comma-table\"><tbody></tbody><tfoot><tr><td colspan=\"2\"></td></tr></tfoot></table>")
					.insertBefore(input);
				
				var tbody = table.find("tbody:first");
				for (var i = 0; i < values.length; i++)
				{
					var tr = ConfigForm.reform.multiComma.createTr(values[i])
						.appendTo(tbody);
				}
				
				var tfoot = table.find("tfoot:first tr td");
				var btnAdd = ConfigForm.utils.createButton(ConfigLang.form.button.add, tfoot, ConfigForm.reform.multiComma.add);
				
				input.hide();
			},	//init: function (input) {
			createTr: function(value) {
				var tr = jQuery("<tr><td><input type=\"text\" class=\"multi-value\" /></td><td class=\"function\"></td></tr>");
				
				tr.find("input:text.multi-value").change(function () {
					ConfigForm.reform.multiComma.recombination(jQuery(this).parents("table.multi-comma-table:first"));
				});
				
				if (typeof(value) != "undefined")
				{
					value = jQuery.trim(value);
					tr.find("input.multi-value").val(value);
				}
					
				var func = tr.find("td.function");
				var btnLang = ConfigLang.form.button;
				var btnMoveUp = ConfigForm.utils.createButton(btnLang.moveUp, btnLang.moveUpImg
					, func, ConfigForm.utils.moveUp, ConfigForm.reform.multiComma.recombination);
				var btnMoveDown = ConfigForm.utils.createButton(btnLang.moveDown, btnLang.moveDownImg
					, func, ConfigForm.utils.moveDown, ConfigForm.reform.multiComma.recombination);
				var btnInsert = ConfigForm.utils.createButton(btnLang.insert, btnLang.insertImg
					, func, ConfigForm.reform.multiComma.insert, ConfigForm.reform.multiComma.recombination);
				var btnDelete = ConfigForm.utils.createButton(btnLang.doDelete, btnLang.doDeleteImg
					, func, ConfigForm.utils.deleteButton, ConfigForm.reform.multiComma.recombination);
				
				return tr;
			},
			insert: function (thisBtn)
			{
				var thisTr = jQuery(thisBtn).parents("tr:first");
				var newTr = ConfigForm.reform.multiComma.createTr()
					.insertAfter(thisTr);
			},
			add: function(thisBtn)
			{
				var tbody = jQuery(thisBtn).parents("table:first").find("tbody");
				var newTr = ConfigForm.reform.multiComma.createTr()
					.appendTo(tbody);
			},
			recombination: function (table)
			{
				table = jQuery(table);
				var value = "";
				var values = table.find("input.multi-value");
				for (var i = 0; i < values.length; i++)
				{
					var v = values.eq(i).val();
						v = jQuery.trim(v);
					if (v == "")
						continue;
					
					if (value != "")
						value =  value + ", ";
					value = value + v;
				}
				
				var valueInput = table.nextAll(".multi-comma:first");
				valueInput.val(value);
			}
		}; //multiComma: {