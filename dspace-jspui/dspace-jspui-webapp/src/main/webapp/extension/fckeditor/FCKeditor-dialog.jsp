<%@ page contentType="application/x-javascript; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
//if (typeof(FCKeditorAPI) != "undefined")
//	var FCKeditorAPI = FCKeditorAPI;
jQuery.fn.extend({
	doFCKeditorDialog: function (modalConfig) {
		var thisObj = jQuery(this);
		
		if (typeof(modalConfig) == "undefined")
			modalConfig = true;
		
		if (thisObj.length == 0)
		{
			return;
		}
		else if (thisObj.length > 1)
		{
			for (var i = 0; i < thisObj.length; i++)
				thisObj.eq(i).doFCKeditorDialog(modalConfig);
			return;
		}
		
		var CONFIG = {
			"FCKeditorBasePath": "<%= request.getContextPath() %>"+"/extension/fckeditor/"
			//, "FCKeditorEditorAreaStyle" : "background-color: #666; color:white"
		};
			
		var LANG = {
			"edit": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.edit") %>",	//編輯
			"accept": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.general.update") %>",	//確定
			"cancel": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.cancel") %>"	//取消
		};
		
		
		if (thisObj.hasClass("inited"))
		{
			return;
			//解inited
			//thisObj.nextAll("button.do-fckeditor-dialog-button").remove();
		}
		else
			thisObj.addClass("inited");
		
		//移除多餘的	
		if (thisObj.nextAll(":first").hasClass("do-fckeditor-dialog-button"))
			thisObj.nextAll(":first").remove();
		
		
		//先把畫面轉換一下吧
		
		var init = function (thisObj) {
			jQuery(thisObj).addClass("do-fackeditor");
			var editor = jQuery("<button class=\"do-fckeditor-dialog-button\" type=\"button\">"+LANG.edit+"</button>")
				.click(function () {
					var thisBtn = jQuery(this);
					var value = thisBtn.prevAll("textarea.do-fackeditor:first").val();
					
					var dialogDiv = jQuery("#FCKeditorDialog");
					jQuery("#FCKeditorDialog").children().remove();
					var sourceName = "FCKeditorDialogSource" + (new Date()).getTime();
					//var source = dialogDiv.find("textarea.source")
					//	.attr("name", sourceName)
					//	.val(value);
					var source = jQuery("<textarea class=\"source\" id=\""+sourceName+"\" name=\""+sourceName+"\" ></textarea>")
						.css("width", "100%")
						//.css("height", "100%")
						.val(value)
						.appendTo(dialogDiv);
					/*
					*/
					/*
					if (typeof(FCKeditorAPI) != "undefined")
					{
						var editorInstance = FCKeditorAPI.GetInstance("FCKeditorDialogSource");
						
						editorInstance.Textarea.value = value;
						//editorInstance.UpdateLinkedField();
					}
					else
					{
						jQuery("#FCKeditorDialog").find("textarea.source:first")
							//.val("")
							//.html("")
							//.html(value)
							.val(value)
							.change();
					}
					*/
					//alert([value, jQuery("#FCKeditorDialog").find("textarea.source:first").length, jQuery("#FCKeditorDialog").find("textarea.source:first").html()]);
					
					/*
					if (typeof(FCKeditorAPI) != "undefined")
					{
						var editorInstance = FCKeditorAPI.GetInstance("FCKeditorDialogSource");
						editorInstance.UpdateLinkedField();
					}
					
					*/
					thisBtn.prevAll("textarea.do-fackeditor:first").addClass("fckeditor-dialog-target");
					
					var title = "";
					titleObj = thisBtn.parent().prev();
					if (titleObj.length > 0)
					{
						title = jQuery.trim(titleObj.text());
						if (title.substring(title.length-1, title.length) == ":")
							title = title.substring(0, title.length-1);
					}
					jQuery("#FCKeditorDialog").dialog("option", "title", title);
					
					jQuery("#FCKeditorDialog").dialog("open");
					//jQuery("#FCKeditorDialog").find("textarea.source").show();
					//jQuery("#FCKeditorDialog").children().show();
					
				})
				.hover(function () {
					var preview = jQuery("#FCKeditorDialogPreview");
					var source = jQuery(this).prevAll("textarea:first").val();
					
					preview.html(source);
					
					var offset = jQuery(this).offset();
					
					preview.css("top", offset.top + jQuery(this).height())
						.css("left", offset.left);
					
					preview.show();
				}, function () {
					jQuery("#FCKeditorDialogPreview").hide();
				});
			
			var textPreview = jQuery("<span class=\"fckeditor-dialog-textpreview\"></span>");
			
			jQuery(thisObj)
				.hide()
				.after(textPreview)
				.after(editor);
			jQuery(thisObj).change(function () {
				setTextPreview(jQuery(this));
			});
		};
		
		var createDialog = function (thisObj) {
			if (jQuery("#FCKeditorDialog").length > 0)
				return;
			
			var dialogDiv = jQuery("<div id=\"FCKeditorDialog\" class=\"fckeditor-dialog\"></div>")
				.hide()
				.appendTo(jQuery("body"));
			
			var sourceName = "FCKeditorDialogSource";
			
			/*
			var source = jQuery("<textarea class=\"source\" id=\""+sourceName+"\" name=\""+sourceName+"\" ></textarea>")
				.css("width", "100%")
				.css("height", "100%")
				.appendTo(dialogDiv);
			*/
			if (location.href.indexOf("input-type=") == -1)
			{
				var w = 640;
				var h = 480;
			}
			else
			{
				var w = 480;
				var h = 320;
			}
			
			dialogDiv.dialog({
				width: w,
				height: h, 
				autoOpen: false,
				bgiframe: true,
				draggable: true,
				modal: modalConfig,
				resizable: true,
				dialogClass: sourceName,
				closeOnEscape: true,
				open: function () {
					//var sourceName = jQuery(this).dialog("option", "dialogClass");
					jQuery(this).parents("div.ui-dialog:first").find("a.ui-dialog-titlebar-close").hide();
					if (jQuery(this).parents("div.ui-dialog:first").find("iframe").length == 0)
					{
						var sourceName = jQuery("#FCKeditorDialog").find("textarea.source").attr("name");
						oFCKeditor = new FCKeditor( sourceName ) ;
						oFCKeditor.BasePath	= CONFIG.FCKeditorBasePath;
						oFCKeditor.Config['ToolbarStartExpanded'] = true ;
						oFCKeditor.Height = "100%";
						if (typeof(CONFIG.FCKeditorEditorAreaStyle) != "undefined")
							oFCKeditor.Config["EditorAreaStyles"]	= "body {"+CONFIG.FCKeditorEditorAreaStyle+"}";
						oFCKeditor.ReplaceTextarea() ;
					}
				},
				buttons: {
					"<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.cancel") %>": function () {
						jQuery(this).dialog("close");
					},
					"<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.tools.general.update") %>": function () {
						//var sourceName = jQuery(this).dialog("option", "dialogClass");
						var sourceName = jQuery("#FCKeditorDialog").find("textarea.source").attr("name");
						var editorInstance = FCKeditorAPI.GetInstance(sourceName);
						editorInstance.UpdateLinkedField();
						jQuery(editorInstance.LinkedField).change();
						var sourceValue = jQuery.trim(editorInstance.LinkedField.value);
						
						//if (sourceValue == "")
						//	return;
						
						var thisObj = jQuery(this);
						thisObj.focus();
						
						setTimeout(function () {
							
							var source = jQuery(this).parents("div.ui-dialog:first").find("textarea.source:first");
							jQuery(".fckeditor-dialog-target:first").val(sourceValue);
							jQuery(".fckeditor-dialog-target:first").change();
							thisObj.dialog("close");
						}, 100);
					}
				},
				close: function () {
					jQuery(".fckeditor-dialog-target:first").removeClass("fckeditor-dialog-target");
				}
			});
		};
		
		var createPreview = function () {
			if (jQuery("#FCKeditorDialogPreview").length > 0)
				return;
			
			var preview = jQuery("<div id=\"FCKeditorDialogPreview\"></div>")
				.hide()
				.appendTo(jQuery("body"));
			
			preview.css("background-color", "white");
			
			if (typeof(CONFIG.FCKeditorEditorAreaStyle) != "undefined")
				preview.attr("style", CONFIG.FCKeditorEditorAreaStyle);
			
			preview.css("position", "absolute");
			preview.css("border", "3px double #000");
			preview.css("padding", "5px");
			preview.css("top", "-1000px");
			//preview.css("width", window.innerWidth + "px");
			preview.hide();
		};
		
		var replaceAll = function (str, reallyDo, replaceWith)
		{
			return str.replace(new RegExp(reallyDo, 'g'), replaceWith);
		};
		
		var setTextPreview = function (thisObj) {
			var text = thisObj.val();
			
			//text = text.replace(/<\s*([a-oq-z]|p\w|\!)[^>]*>|<\s*\/\s*([a-oq-z]|p\w)[^>]*>/gi, "");
			//text = text.replace(/<\s*p[^>]+>/gi, "<p>");
			text = text.replace(/<[^>].*?>/g,"");
			text = jQuery.trim(text);
			while (text.substring(0, 6) == "&nbsp;")
				text = jQuery.trim(text.substring(6, text.length));
			
			if (text.length > 15)
				text = text.substring(0, 15) + "...";
			
			thisObj.nextAll("span.fckeditor-dialog-textpreview").text(text);
		};
		
		jQuery(document).ready(function () {
			setTimeout(function () {
				init(thisObj);
				createDialog(thisObj);
				createPreview();
				setTextPreview(thisObj);
			}, 100);
		});
	}
});