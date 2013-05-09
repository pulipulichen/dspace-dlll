function PageObject(rootNode)
{
	var LANG = {
		Label: {
			Description: "敘述"
		}
	};
	
	//if (typeof(InputFomrsEditorLang) != "undefined")
	//	LANG = InputFomrsEditorLang.PageObject;
	if (typeof(getInputFormsEditorLang) != "undefined")
		var LANG = getInputFormsEditorLang().PageObject;
	
	var pgObj = new Object;
	
	pgObj.number = 1;
	pgObj.label = LANG.Label.Description;
	pgObj.hint = "";
	pgObj.fields = [FieldObject()];
	
	pgObj.parse = function(node)
	{
		pgObj.fields = new Array();
		var fields = node.children(".field");

		for (var i = 0; i < fields.length; i++)
		{
			var field = FieldObject(fields.eq(i));
			pgObj.fields.push(field);
		}
		pgObj.number = node.attr("number");
		if (typeof(node.attr("label")) != "undefined")
			pgObj.label = node.attr("label");
		if (typeof(node.attr("hint")) != "undefined")
			pgObj.hint = node.attr("hint");
	};
	
	if (typeof(rootNode) == "object")
	{
		pgObj.parse(rootNode);
	}
	return pgObj;
}	//function PageObject(rootNode)
