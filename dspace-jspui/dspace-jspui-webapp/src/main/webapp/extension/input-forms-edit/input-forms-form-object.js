var FormObject = function(name, handle)
{
	var formObj = new Object;
	
	formObj.name = "";
	
	formObj.setName = function(n) {
		formObj.name = n;
	};
	formObj.getName = function() {
		return formObj.name;
	};
	
	formObj.handle = new Array;
	
	formObj.pushHandle = function(h) {
		if (jQuery.inArray(h, formObj.handle) ==  -1)
		{
			formObj.handle.push(h);
		}
	};
	formObj.getHandle = function(index) {
		if (typeof(parseInt(index)) != "number"
			|| typeof(index) == "undefined")
			return formObj.handle;
		else
			return formObj.handle[index];
	};
	
	formObj.pages = [PageObject()];
	formObj.setPage = function(formNode)
	{
		var pages = formNode.children(".page");
		formObj.pages = new Array();
		for (var i = 0; i < pages.length; i++)
		{
			var page = PageObject(pages.eq(i));
			
			formObj.pages.push(page);
		}
	};
	formObj.getPage = function () {
		return formObj.pages; 
	};
	
	if (typeof(name) != "undefined")
		formObj.name = name;
	if (typeof(handle) == "array")
		formObj.handle = handle
	else if (typeof(handle) != "undefined")
		formObj.pushHandle(handle);
	
	return formObj;
}	//var FormObject = function(name, handle)
