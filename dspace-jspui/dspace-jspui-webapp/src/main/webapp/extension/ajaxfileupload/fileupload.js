	
	function ajaxFileUpload(thisButton, workspaceItemID, description)
	{	
		var config = fileuploadConfig;
		
		if (typeof(description) == "undefined") description = "";
		
		$("#loading")
			.ajaxStart(function(){
				$(this).show();
			})
			.ajaxComplete(function(){
				//$(this).hide();
			});
		
		var id = config.inputName;
		
		jQuery(thisButton).parents("td:first").children("input[type=file]:first")
			.attr("id", id).attr("name", id);
		
		jQuery.ajaxFileUpload
		(
			{
				url: config.url.upload,
				//url: 'http://www.phpletter.com/contents/ajaxfileupload/doajaxfileupload.php',
				secureuri:false,
				fileElementId: id, //id + "_fileToUpload",
				dataType: 'json',
				workspace_item_id: workspaceItemID,
				file_upload_step: config.step,
				file_upload_page: config.page,
				file_upload_JSP: config.url.upload_jsp,
				file_description: description,
				success: function (data, status)
				{
					if(typeof(data.error) != 'undefined')
					{
						if(data.error != '')
						{
							alert(data.error);
						}else
						{
							//alert(data.msg);
							var d = jQuery(thisButton).parents("td:first");
							d.children("input[type!=file]").val(data.url).change();
							//d.children("input[type!=file]").show();
														
							if (d.nextAll("td:first").children("input[type=submit]:first").length > 0)
							{
								if (location.href.indexOf("submit") != -1)
									d.nextAll("td:first").children("input[type=submit]:first").click();
								return;
							}
							
							var config = fileuploadConfig;
							
							d.children("input[type=file]:first")
								.hide()
								.removeAttr("id")
								.removeAttr("name");
							d.children("span:first")
								.html("<a href=\""+data.url+"\">"+data.filename+"</a> ("+data.format+")");
							
							var btnPreview = jQuery("<button type=\"button\" class=\""+data.url.replace("/retrieve/", "/preview/")+"\">"+"預覽"+"</button>")
								.appendTo(d.children("span:first"))
								.click(function () {
									window.open(this.className);
								});
							
							//if is a pic, prepend img
								if (jQuery.inArray(data.format.toLowerCase(), config.imageFormat) != -1)
								{
									var img = jQuery("<img src=\""+data.url+"\" alt=\""+data.filename+"\" style=\"display:block\" border=\"0\" onload=\"this.style.height='"+config.maxHeight+"px'\" />");

									img.hide();
									img.load(function() {
										var i = jQuery(this);
										var w = i.width();
										var h = i.height();
										var maxWidth = i.parents("div:first").width();
										var maxHeight = config.maxHeight;
										
										if (w > maxWidth)
										{
											i.width(maxWidth);
											i.height(maxWidth/w*h);
										}
										if (h > maxHeight)
										{
											i.height(maxHeight);
											i.width(maxHeight/h*w);
										}
										i.show();
										return false;
									});
									
									var a = jQuery("<a href=\""+data.url+"\" target=\"preview\"></a>").append(img);
									
									d.children("span:first").prepend(a);
									
									
								}
							if (d.nextAll("td:first").children("button.fileupload-cancel[type=button]:first").length == 1)
							{
								d.nextAll("td:first").children("button.fileupload-cancel[type=button]:first").show();
							}
							d.children("button.fileupload-do:first").hide();
							//jQuery(thisButton).hide();
							
						}
					}
				},
				error: function (data, status, e)
				{
					alert(e);
				}
			}
		);	//jQuery.ajaxFileUpload
		
		return false;

	}
	
	function ajaxFileUploadCancel(thisButton, workspace_item_id)
	{
		var config = fileuploadConfig;
		
		var d = jQuery(thisButton).parents("td:first").prevAll("td:first");
		var url = d.children("input[type!=file]:first").val();

		var temp = url.split("/");
		var id = temp[(temp.length-2)];
		jQuery.ajax({
			type:	"post",
			url:	config.url.submit,
			data:	config.delData(id, workspace_item_id),
			complete:function()	{
				var d = jQuery(thisButton).parents("td:first").prevAll("td:first");
				d.children("input[type=file]:first").show().val("");
				d.children("input[type!=file]:first").val("");
				d.children("span:first").html("");
				d.children("button.fileupload-do:first").show();
				jQuery(thisButton).hide();
			}
		});
		return false;
	}
	
	function ajaxFileUploadRemove(thisButton, workspace_item_id)
	{
		var config = fileuploadConfig;
		
		var d = jQuery(thisButton).parents("td:first").prevAll("td:first");
		var url = d.children("input[type!=file]:first").val();
		var temp = url.split("/");
		var id = temp[(temp.length-2)];
		
		jQuery.ajax({
			type:	"post",
			url:	config.url.submit,
			data:	config.delData(id, workspace_item_id),
			complete:function()	{
				jQuery(thisButton).prevAll("input[type=submit]").click();
			}
		});
		return false;
	}

	
	function ajaxFileUploadExist(id)
	{
		var d = jQuery("#"+id).parents("td:first");
		var url = jQuery("#"+id).val();
		if (url == "") return;
		
		var config = fileuploadConfig;
		var filename = decodeURI(url.substring(url.lastIndexOf("/")+1, url.length));
		var format = filename.substring(filename.lastIndexOf(".") + 1, filename.length).toLowerCase();
		if (filename.lastIndexOf(".") == -1) format = "Unknow";
		
		d.children("input[type=file]:first").hide();
		d.children("span:first").html("<a href=\""+url+"\">"+filename+"</a> ("+format+")");
		
		var btnPreview = jQuery("<button type=\"button\" class=\""+url.replace("/retrieve/", "/preview/")+"\">"+"預覽"+"</button>")
			.appendTo(d.children("span:first"))
			.click(function () {
				window.open(this.className);
			});
		
			if (jQuery.inArray(format, config.imageFormat) != -1)
			{
				var img = jQuery("<img src=\""+url+"\" alt=\""+filename+"\" style=\"display:block\" border=\"0\" onload=\"this.style.height='"+config.maxHeight+"px'\" />");

				img.hide();
				img.load(function() {
					var i = jQuery(this);
					
					var w = i.width();
					var maxWidth = i.parents("div:first").width();
					if (w > maxWidth)
					{
						i.width(maxWidth);
						i.height(maxWidth/w*h);
					}
					
					var h = i.height();
					var maxHeight = config.maxHeight;
					if (h > maxHeight)
					{
						i.height(maxHeight);
						i.width(maxHeight/h*w);
					}
					i.show();
					return false;
				});
				
				var a = jQuery("<a href=\""+url+"\" target=\"preview\"></a>").append(img);
				
				d.children("span:first").prepend(a);
			}
		d.children("button.fileupload-do:first").hide();
		
		if (d.nextAll("td:first").children("button[type=button]:first").length == 1)
		{
			d.nextAll("td:first").children("button[type=button]:first").show();
		}

		return false;
	}
	
	function ajaxFileUploadDisplay(url)
	{
		if (url.indexOf("/retrieve/") == -1)
		{
			return url;
		}
		else
		{
			var temp = url.split("/");
			var filename = decodeURI(temp[(temp.length - 1)]);
			var format = filename.substring(filename.lastIndexOf(".") + 1, filename.length).toLowerCase();
			
			var config = fileuploadConfig;
			
			var d = jQuery("<div></div>");
			d.append("<a href=\""+url+"\">"+filename+"</a> ("+format+")");
			var btnPreview = jQuery("<button type=\"button\" class=\""+url.replace("/retrieve/", "/preview/")+"\">"+"預覽"+"</button>")
				.appendTo(d)
				.click(function () {
					window.open(this.className);
				});
			
			if (jQuery.inArray(format, config.imageFormat) != -1)
			{
				var img = jQuery("<img src=\""+url+"\" alt=\""+filename+"\" style=\"display:block\" border=\"0\" onload=\"this.style.height='"+config.maxHeight+"px'\" />");

				img.hide();
				img.load(function() {
					var i = jQuery(this);	//this image
					var w = i.width();
					var h = i.height();
					var maxHeight = config.maxHeight;
					if (h > maxHeight)
					{
						i.height(maxHeight);
						i.width(maxHeight/h*w);
					}
					i.show();
					return false;
				});
				var a = jQuery("<a href=\""+url+"\" target=\"preview\"></a>").append(img);
				
				d.prepend(a);
			}	//if (jQuery.inArray(format, config.imageFormat) != -1)
			
			return d.contents();
		}	//else
		
	}	//function
