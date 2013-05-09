//doDialog.js
//for BitstreamDisplay

function openDialog(contentID)
{
	
	var dialog = jQuery('#'+contentID).parents("div.ui-dialog:first");
	var offset = dialog.offset();
	if (dialog.width() > window.innerWidth)
	{
		dialog.width((window.innerWidth * 0.8));
		if (offset.left < 0)
			dialog.css("left", (window.innerWidth * 0.1) + "px");
		else
			dialog.css("left", offset.left + (window.innerWidth * 0.1) + "px");
	}
	if (dialog.height() > window.innerHeight)
	{
		dialog.height((window.innerHeight * 0.8));
		dialog.css("top", offset.top + (window.innerHeight * 0.1) + "px");
	}
	
	var textarea = jQuery('#'+contentID).children("textarea:first");
	if (textarea.length > 0)
	{
		var textarea = jQuery('#'+contentID).children("textarea:first");
		var html = textarea.attr("innerHTML");
		//jQuery('.'+contentID+"_a").focus().css("border", "1px solid red");
		//alert([contentID, "\n\n", html, "\n\n", textarea.attr("innerHTML")]);
		html = html.replace(/&lt;/g,"<");
		html = html.replace(/&gt;/g,">");
		textarea.before(html);
		textarea.remove();
	}
	else
	{
		
		var iframe = jQuery('#'+contentID).children("iframe:first");
		if (iframe.length > 0)
		{
			//alert(iframe.attr("src"));
			iframe.attr("src", iframe.attr("src"));
		}
		
	}
	
	//setTimeout(function () {
		jQuery('#'+contentID).dialog("open");
		var content = jQuery('#'+contentID);
		
		jQuery('#'+contentID).children(":first")
			.height((content.height()-5))
			.width((content.width()-5));
		
		/*setTimeout(function () {
			if (jQuery('#'+contentID).css("display") == "none")
			{
				openDialog(contentID);
			}
		}, 500);
		*/
	//}, 500);
}

jQuery(document).ready(function () {
	if (typeof(bitstreamDisplayDo) != "undefined")
	{
		
		var i = 0;
		//alert(bitstreamDisplayDo.length);
		/*
		var exec = function(i) {
			if (i < 5)
				alert(i);
			if (i < bitstreamDisplayDo.length)
			{
				bitstreamDisplayDo[i]();
				i++;
				exec(i);
			}
			else
				break;
		}
		//exec(i);
		*/
		for (var i = 0; i < bitstreamDisplayDo.length; i++)
		{
			bitstreamDisplayDo[i]();
		}
		//execBitstreamDisplayDo(0, bitstreamDisplayDo)
	}
});
/*
function execBitstreamDisplayDo(i, bitstreamDisplayDo)
{
	if (i < bitstreamDisplayDo.length)
	{
		bitstreamDisplayDo[i]();
		i++;
		setTimeout(function () {
			execBitstreamDisplayDo(i, bitstreamDisplayDo);
		}, 100);
	}
	else
	{
		return;
	}
}
*/
function setDialog(contentID, width, height, resizable, allowDownload, path)
{
	if (typeof(bitstreamDisplayDo) == "undefined" 
		|| bitstreamDisplayDo == null)
		bitstreamDisplayDo = new Array();
	
	var width = (parseInt(width)+10);
	var height = (parseInt(height)+90);
	
	if (resizable == "true")
		resizable = true;
	else
		resizable = false;
	
	bitstreamDisplayDo.push(function () {
		if (allowDownload == "true")
		{
			
			jQuery("#"+contentID).dialog({
				"autoOpen": false, width: width, height: height, "resizable": resizable,
				buttons: { "Download": function() { 
					window.open(path, contentID+"_download"); 
				} }
			});
		}
		else
		{
			//height = height - 40;
			jQuery("#"+contentID).dialog({
				"autoOpen": false, width: width, height: height, "resizable": resizable,
				buttons: { "Only Preview": function() { 
					jQuery(this).dialog("close"); 
				} }
			});
		}
		
	});
}