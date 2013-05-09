ConfigController = {
	config: {
		controller: "div.config-controller",
		form: "table#configFormTable",
		code: "textarea#source"
	},
	init: function () {
		var controller = jQuery(ConfigController.config.controller);
		var form = jQuery(ConfigController.config.form).parents("div:first");
		var code = jQuery(ConfigController.config.code).parents("div:first");
		
		var radioForm = controller.find("input:radio.mode.form")
			.change(function () {
				if (jQuery(this).attr("checked") != "")
				{
					//把code轉換到form
					ConfigForm.codeToForm(function () {
						form.show();
						code.hide();
					});
				}
			})
			.attr("checked", "checked");
			
		var radioCode = controller.find("input:radio.mode.code")
			.change(function () {
				if (jQuery(this).attr("checked") != "")
				{
					//把form轉換到code
					ConfigForm.formToCode(function () {
						form.hide();
						code.show();
					});
				}
			});
	},
	submit: function (thisForm) {
		if (window.confirm(ConfigLang.form.submitConfirm) == false)
			return false;
		
		var mode = ConfigController.detectMode(thisForm);
		
		if (mode == "form")
		{
			if (typeof(formToCode) == "undefined")
			{
				ConfigForm.formToCode(function () {
					jQuery(thisForm).submit();
				});
				return false;
			}
		}
	},
	detectMode: function (thisForm)
	{
		var form = jQuery(thisForm);
		var table = form.find("table#configFormTable").parents("div:first");
		
		if (table.css("display") == "none")
			return "code";
		else
			return "form";
	}
};
