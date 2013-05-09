<%@ page contentType="application/javascript;charset=UTF-8" %>
//doDialog.jsp
//for BitstreamDisplay

function openDialog(contentID)
{
	var content = jQuery('.'+contentID+":first");
	var dialog = content.parents("div.ui-dialog:first");
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
	
	content.children(":not(textarea.html)").remove();
	var textarea = content.children("textarea.html:first");
	if (textarea.length > 0)
	{
		var textarea = content.children("textarea.html:first");
		var html = textarea.attr("innerHTML");
		html = html.replace(/&lt;/g,"<");
		html = html.replace(/&gt;/g,">");
		textarea.before(html);
		//textarea.remove();
	}
	else
	{
		
		var iframe = content.children("iframe:first");
		if (iframe.length > 0)
		{
			iframe.attr("src", iframe.attr("src"));
		}
		
	}
	content.dialog("open");
}

jQuery(document).ready(function () {
	if (typeof(bitstreamDisplayDo) != "undefined")
	{
		
		var i = 0;
		//alert(bitstreamDisplayDo.length);

		for (var i = 0; i < bitstreamDisplayDo.length; i++)
		{
			bitstreamDisplayDo[i]();
		}
		//execBitstreamDisplayDo(0, bitstreamDisplayDo)
	}
});

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
	
	
	
	if (jQuery("."+contentID).length == 0)
	{
		return;
	}
	else if (jQuery("."+contentID).length > 1)
	{
		jQuery("."+contentID).not(":first").remove();
	}
	
	bitstreamDisplayDo.push(function () {
		
		var dialogOptions = {
			"autoOpen": false, width: width, height: height, "resizable": resizable,
			close: function () {
				var content = jQuery(this).parents(".ui-dialog:first").find(".ui-dialog-content");
				content.children(":not(.html)").remove();
			}
		};
		
		if (allowDownload == "true")
		{
			dialogOptions.buttons = { 
				"下載": function() { 
					window.open(path, contentID+"_download"); 
					jQuery(this).dialog("close");
				},
				"開新視窗": function () {
					var bitstreamID = contentID.replace("bitstream_display_content_id_", "");
					var previewPath = "<%= request.getContextPath() %>/preview/"+bitstreamID;
					window.open(previewPath, contentID+"_download");
					jQuery(this).dialog("close");
				}
			};
			
			
		}
		else
		{
			//height = height - 40;
			dialogOptions.buttons = {
				"僅供預覽": function() { 
					jQuery(this).dialog("close"); 
				} ,
				"開新視窗": function () {
					var bitstreamID = contentID.replace("bitstream_display_content_id_", "");
					var previewPath = "<%= request.getContextPath() %>/preview/"+bitstreamID;
					window.open(previewPath, contentID+"_download");
					jQuery(this).dialog("close");
				}
			};
		}
		jQuery("."+contentID+":first").dialog(dialogOptions);
		
	});
}