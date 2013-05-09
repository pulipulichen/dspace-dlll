ConfigForm.valid = {
	stripEndsWithSlash: function(thisInput) {
		var value = thisInput.value;
		if (ConfigForm.utils.endsWith(value, "/"))
		{
			value = value.substring(0, value.length - 1);
			thisInput.value = value;
		}
	},
	startEndsWithPort: function(thisInput) {
		var value = thisInput.value;
		
		
		if (ConfigForm.utils.startsWith(value, "http://"))
		{
			value = value.substring(7, value.length);
			thisInput.value = value;
		}
		
		if (value.indexOf(":") > 0)
		{
			value = value.substring(0, value.indexOf(":"));
			thisInput.value = value;
		}
		
		if (value.indexOf("/") != -1)
		{
			value = value.substring(0, value.indexOf("/"));
			thisInput.value = value;
		}
	}, 
	checked: function (checkbox)
	{
		checkbox = jQuery(checkbox);
		if (typeof(checkbox.attr("checked")) == "undefined"
			|| checkbox.attr("checked") == false)
			return false;
		else
			return true;
	}
};