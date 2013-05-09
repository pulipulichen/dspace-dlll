jQuery.fn.extend({
	doItemButton: function () {
		var LANG = {
			"Button": {
				"Edit": "編輯"
			},
			"Hint": {
				"PreviewLimit": "預覽中不會有效果"
			}
		};
		//if (typeof(InputFomrsEditorLang) != "undefined")
		//	LANG = InputFomrsEditorLang.doItemButton;
		if (typeof(getInputFormsEditorLang) != "undefined")
			var LANG = getInputFormsEditorLang().doItemButton;
		
		var itemInput = jQuery(this);
		
		var btn = jQuery("<button type=\"button\">"+LANG["Button"]["Edit"]+"</button>")
			.insertAfter(itemInput)
			.click(function () {
				alert(LANG.Hint.PreviewLimit);
			});
		
		itemInput.hide();
	}
});	//jQuery.fn.extend({
