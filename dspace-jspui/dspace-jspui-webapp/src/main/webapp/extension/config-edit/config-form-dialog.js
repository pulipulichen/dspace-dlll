ConfigForm.dialog = {
	init: function () {
		var LANG = ConfigLang.form;
		var dialogDiv = jQuery("<div></div>")
			.addClass("config-form-dialog")
			.attr("title", LANG.dialog.title)
			.hide()
			.appendTo(jQuery("body"));
		dialogDiv.dialog({
				bgiframe: true,
				autoOpen: false,
				height: 100,
				width: 230,
				modal: true,
				resizable: false
			});
		ConfigForm.dialog.div = dialogDiv;
	},
	setMessage: function (msg) {
		ConfigForm.dialog.div.html(msg);
	},
	open: function (callback) {
		if (typeof(readyClose) != "undefined")
			clearTimeout(readyClose);
		
		ConfigForm.dialog.div.dialog("open");
		setTimeout(function () {
			if (typeof(callback) == "function")
				callback();
		}, 100);
		
		readyClose = setTimeout(function () {
			ConfigForm.dialog.div.dialog("close");
		}, 30000);
		
	},
	close: function (callback) {
		if (typeof(callback) == "function")
			callback();
		
		readyClose = setTimeout(function () {
			ConfigForm.dialog.div.dialog("close");
		}, 1000);
	}
};