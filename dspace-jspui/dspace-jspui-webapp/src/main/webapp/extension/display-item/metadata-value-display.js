// JavaScript Document
function metadataValueDisplay(rootUrl)
{
	var values = jQuery("td.metadataFieldValue");
	var bitstreamHeader = rootUrl + "/retrieve/";
	var xmlMetadataNeedle = 'div.xml-root:first';
	for (var i = 0; i < values.length; i++)
	{
		var val = values.eq(i).html();
		//if (values.eq(i).children("a:first").length == 1)
		//	val = values.eq(i).children("a:first").html();
		
		if (val.substr(0, bitstreamHeader.length) == bitstreamHeader)
		{
			val = val.substring(0, val.indexOf("<"));
			values.eq(i).html(ajaxFileUploadDisplay(val));
		}
		else if (values.eq(i).find(xmlMetadataNeedle).length == 1)
		{
			
			var xm = new XMLMetadata(values.eq(i));
			xm.displayRootTable(values.eq(i));
			/*
			var xmlID = "xmlMetadataDisplay["+i+"]";
			var c = values.eq(i).find(xmlMetadataNeedle).parents(":first").html();	//.parents(":first");
			//alert(c.html());
			var textarea = jQuery("<textarea class=\"xmlMetadataTextarea\" id=\""+xmlID+"\" />")
			values.eq(i).html("");
			values.eq(i).append(textarea);
			//alert(typeof(c) + "[" + "textarea.xmlMetadataTextarea:last" + "]" + jQuery("textarea.xmlMetadataTextarea:last").length);
			jQuery("textarea.xmlMetadataTextarea:last").val(c);
			alert(jQuery("textarea.xmlMetadataTextarea:last").val());
			*/
			//var xm = new XMLMetadata(xmlID);
			//xm.createRootForm();
		}
	}
	
	/*
	var xml = jQuery("textarea.xmlMetadataTextarea");
	for (var i = 0; i < xml.length; i++)
	{
		var xm = new XMLMetadata(xml.eq(i).attr("id"));
		xm.workspaceItemID = 61;
		xm.fieldTitle = "Label";
		//xm.displayTable = true;
		//xm.displayTable = true;
		alert([xm.storage.length, xm.workspaceItemID, xm.fieldTitle, xm.displayTable]);
		xm.createRootForm();
	}
	*/
}
