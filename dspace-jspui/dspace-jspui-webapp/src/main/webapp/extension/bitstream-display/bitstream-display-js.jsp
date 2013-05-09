<%@ page contentType="application/javascript;charset=UTF-8" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%!
	public String lm (PageContext pageContext, String key)
	{
		return LocaleSupport.getLocalizedMessage(pageContext, "jsp.extension.bitstream-display-ajax." + key);
	}
%>
<%
	PageContext pg = pageContext;
%>
function bitstreamDisplayDialog(bitstreamID, downloadable)
{
	var dialogID = bitstreamID + "_dialog";
	
	if (jQuery("."+dialogID).length > 0)
		return;
	
	<%-- var loadingMsg = jQuery("<div style=\"font-size:larger;margin: 20px 0;font-weight:bold;\">讀取中，請稍候。</div>"); --%>
	var loadingMsg = jQuery("<div style=\"font-size:larger;margin: 20px 0;font-weight:bold;\"><%= lm(pg, "dialog.now-loading") %></div>");
	
	<%-- var dialogDiv = jQuery("<div title=\""+"系統訊息"+"\" class=\""+dialogID+"\"></div>") --%>
	var dialogDiv = jQuery("<div title=\""+"<%= lm(pg, "dialog.title") %>"+"\" class=\""+dialogID+"\"></div>")
		.append(loadingMsg);
	
	//建立讀取中的訊息
	var dialogConfig = {
		autoOpen: true,
		width: 200,
		height: 170,
		resizable: false,
		close: function () {
			jQuery(this).dialog("destory");
			dialogDiv.remove();
		}
	};
	
	var buttonConfig = new Object;
	<%-- buttonConfig["關閉"] = function () { --%>
	buttonConfig["<%= lm(pg, "dialog.close") %>"] = function () {
		jQuery(this).dialog("close");
	};
	
	dialogConfig["buttons"] = buttonConfig;
	
	dialogDiv.appendTo(jQuery("body"));
	dialogDiv.dialog(dialogConfig);
	
	//嘗試取得值
	var contextPath = "<%= request.getContextPath() %>";
	var jsonPath = contextPath + "/extension/bitstream-display/bitstream-display-json.jsp?bitstreamID=" + bitstreamID + "&downloadable="+downloadable+"&callback=?";
	
	
	//alert(jsonPath);
	
	
	jQuery.getJSON(jsonPath, function(data) {
		if (dialogDiv.length == 1)
		{
			//錯誤阻止
			if (typeof(data.error) != "undefined"
				&& data.error != "null"
				&& data.error != null)
			{
				alert(data.error);
				return;
			}
			
			var contextPath = "<%= request.getContextPath() %>";
			
			//如果沒有預覽，則直接開新視窗
			if ((data.main.mode == "NO_PREVIEW" || data.main.url == "null" || data.main.url == null)
				&& downloadable == true)
			{
				window.open(contextPath + data.raw.url, "_blank");
				dialogDiv.dialog("close");
				return;
			}
			
			//分析取得的值
			
			
			//主畫面物件
			var previewObj = bitstreamDisplayCreatePreview(data, dialogDiv);
			dialogDiv.html(previewObj);
			
			var buttonConfig = new Object;
			<%-- buttonConfig["關閉"] = function () { jQuery(this).dialog("close"); }; --%>
			buttonConfig["<%= lm(pg, "dialog.close") %>"] = function () { jQuery(this).dialog("close"); };
			
			if (downloadable == false)
			{
				var buttonConfig = new Object;
				<%-- buttonConfig["僅供預覽"] = function () { --%>
				buttonConfig["<%= lm(pg, "dialog.only-preview") %>"] = function () {
					jQuery(this).dialog("close");
				};
			}
			
			//下載畫面
			if (downloadable == true)
			{
				if (typeof(data.raw) == "object")
				{
					var name = data.raw.name;
					var url = contextPath + data.raw.url + "?download=1";
					buttonConfig[name] = function () {
						window.open(url, bitstreamID+"_download");
					};
				}
			}
			
			//其他下載畫面
			if (typeof(data.buttons) != "undefined")
			{
				for (var i = 0; i < data.buttons.length; i++)
				{
					var key = data.buttons[i].name;
					var value = contextPath + data.buttons[i].url + "?download=1";
					buttonConfig[key] = function () {
						window.open(value, bitstreamID+"_download");
					};
				}
			}
			
			//開新視窗預覽
			<%-- buttonConfig["開新視窗"] = function () { --%>
			buttonConfig["<%= lm(pg, "dialog.open") %>"] = function () {
				var previewPath = "<%= request.getContextPath() %>/preview/"+bitstreamID;
				window.open(previewPath, bitstreamID+"_download");
				jQuery(this).dialog("close");
			};
			
			//dialogDiv.dialog("option", "width", "auto");
			dialogDiv.dialog("option", "height", "auto");
			dialogDiv.dialog("option", "buttons", buttonConfig);
			
			
			//標題，也就是Bitstream的名稱
			var title = data.name;
			dialogDiv.dialog("option", "title", title);
			
			jQuery(document).ready(function () {
				setTimeout(function () {
					var dialogWidth = dialogDiv.parents(".ui-dialog:first").width();
					dialogWidth = dialogWidth - 50;
					var titleTemp = jQuery("<span>"+title+"</span>")
						.appendTo(jQuery("body"));
					var titleWidth = titleTemp.width();
					titleTemp.remove();
					
					if (titleWidth > dialogWidth)
					{
						var percent = dialogWidth / titleWidth * 0.8;
						var sublen = parseInt(title.length * percent);
						title = "<span title=\""+title+"\">" + title.substring(0, sublen) +"...</span>";
					}
					dialogDiv.dialog("option", "title", title);
				}, 1000);
			});
			
			//dialogDiv.dialog("option", "width", "auto");
			if (jQuery.browser.msie
				&& typeof(data.main) == "object"
				&& typeof(data.main.width) == "string")
			{
				dialogDiv.dialog("option", "width", data.main.width);
			}
			else
			{
				dialogDiv.dialog("option", "width", "auto");
			}
			
			dialogDiv.css("overflow", "hidden");
			
			jQuery(document).ready(function () {
				setTimeout(function () {
					dialogDiv.dialog("option", "position", "center");
				},50);
			});
			
		}
	});
}

function bitstreamDisplayCreatePreview(data, dialogDiv)
{
	if (typeof(data.main) == "undefined")
	{
		//什麼都沒有的情況下
		<%-- return jQuery("<div>"+"沒有預覽檔案"+"</div>"); --%>
		return jQuery("<div>"+"<%= lm(pg, "preview.no-preview") %>"+"</div>");
	}
	
	var config = data.main;
	var url = config.url;
	var id = config.id;
	var mode = config.mode.toUpperCase();
	var height = config.height;
	var width = config.width;
	
	dialogDiv.css("height", "");
	
	var contextPath = "<%= request.getContextPath() %>";
	if (url != "null" && url.substring(0, 7) != "http://")
		url = contextPath + url;
	var getPlayerPath = function (player) {
		return contextPath + "/extension/bitstream-display/" + player;
	};
	
	<%-- var output = jQuery("<div>"+"沒有預覽檔案"+"</div>"); --%>
	var output = jQuery("<div>"+"<%= lm(pg, "preview.no-preview") %>"+"</div>");
	if (url == "null" || url == null)
	{
		//直接顯示沒有預覽檔案，不改變
	}
	else if (mode == "PREVIEW")
	{
		var iframeWidth = width;
		var iframeHeight = height;
		output = jQuery("<iframe src=\""+url+"\" width=\""+iframeWidth+"\" height=\""+iframeHeight+"\" style=\"background-color:transparent;overflow:hidden;\" scrolling=\"no\" frameborder=\"0\" class=\"bitstream-preview-iframe\"></iframe>");
		//alert("<div style=\"width:"+width+"px;height:"+height+"px\"><iframe src=\""+url+"\" width=\""+iframeWidth+"\" height=\""+iframeHeight+"\" style=\"background-color:transparent;\" frameborder=\"0\" class=\"bitstream-preview-iframe></iframe></div>");
		
	}
	else if (mode == "IFRAME")
	{
		var iframeWidth = width.substring(0, width.length - 2);
		var iframeHeight = height.substring(0, height.length - 2);
		output = jQuery("<iframe src=\""+url+"\" width=\""+iframeWidth+"\" height=\""+iframeHeight+"\" style=\"width:"+width+";height:"+height+";\" frameborder=\"0\" class=\"bitstream-preview-iframe\"></iframe>");
	}
	else if (mode == "SNAP")
	{
		//var viewerPath = getPlayerPath("swfoto.swf");
		
		//output = jQuery("<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0\" width=\""+width+"\" height=\""+height+"\"><param name=\"movie\" value=\""+viewerPath+"?image="+url+"\"><embed src=\""+viewerPath+"?image="+url+"\" width=\""+width+"\" height=\""+height+"\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" type=\"application/x-shockwave-flash\"></embed></object>");
		output = jQuery("<div style=\"width: "+width+"px; height: "+height+"px;background-image:url("+url+");background-repeat:no-repeat;background-position:center;\"></div>");
	}
	else if (mode == "ZOOMIFY")
	{
		var viewerPath = getPlayerPath("zoomifyViewer.swf");
		
		output = jQuery("<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0\" \n"
							+ "	style=\"font-size: 0;line-height: 0;border:1px solid #CCCCCC;\""
							+ "	width=\""+width+"\" height=\""+height+"\">"
		        			+ "		<param name=\"FlashVars\" value=\"zoomifyImagePath="+url+"/&zoomifyNavigatorVisible=true\">"
				        	+ "		<param name=\"BGCOLOR\" value=\"#FFFFFF\">"
		        			+ "		<param name=\"MENU\" value=\"true\">"
							+ "		<param name=\"SRC\" value=\""+viewerPath+"\">"
							+ "		<embed flashvars=\"zoomifyImagePath="+url+"/&zoomifyNavigatorVisible=true\""
		                	+ "			src=\""+viewerPath+"\" bgcolor=\"#FFFFFF\" menu=\"true\" pluginspage=\"http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash\""
		            		+ "			style=\"font-size: 0;line-height: 0;border:1px solid #CCCCCC;\""
		                	+ "			width=\""+width+"\" height=\""+height+"\"></embed>"
		    				+ "</object>");
	}
	else if (mode == "AUDIO_PREVIEW")
	{
		var playerPath = getPlayerPath("xspf_player_slim.swf");
		output = jQuery("<object type=\"application/x-shockwave-flash\" \n"
						+ "	data=\""+playerPath+"?&song_url="+url+"&autoplay=true\""
						+ "	style=\"font-size: 0;line-height: 0;\" \n"
						+ "	width=\""+width+"\" height=\""+height+"\">"
						+ "		<param name=\"movie\" "
						+ "			value=\""+playerPath+"?&song_url="+url+"&autoplay=true\" />"
						+ "</object>");
	}
	else if (mode == "VIDEO_PREVIEW"
			|| mode == "VIDEO_MOBILE")
	{
		var player = getPlayerPath("player_flv_maxi.swf");
		output = jQuery("<object class=\"playerpreview\""
					+ "		type=\"application/x-shockwave-flash\" data=\""+player+"\""
					+ "		style=\"font-size: 0;line-height: 0;\""
					+ "		width=\""+width+"\" height=\""+height+"\">"
					+ "	<param name=\"movie\" value=\""+player+"/player_flv_maxi.swf\" />"
					+ "	<param name=\"allowFullScreen\" value=\"true\" />"
					+ "	<param name=\"FlashVars\""
					+ "		value=\"flv="+url+"&width="+width+"&height="+height
					+ "&autoplay=" + "1"
					+ "&autoload=" + "1"
					+ "&showstop=" + "1"
					+ "&showvolume=" + "1"
					+ "&showtime=" + "1"
					+ "&showfullscreen=" + "1"
					+ "&bgcolor1=" + "FFFFFF"
					+ "&bgcolor2=" + "FFFFFF"
					+ "&playercolor=" + "666666"
					+ "\" />"
					+ "</object>");
	}
	else if (mode == "PDF2SWF_PREVIEW")
	{
		var object = "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\""
						+ "	width=\""+width+"\""
						+ "	height=\""+height+"\""
						+ "	codebase=\"http://active.macromedia.com/flash5/cabs/swflash.cab#version=8,0,0,0\">"
						+ "	<param name=\"MOVIE\" value=\""+url+"\">"
						+ "	<param name=\"PLAY\" value=\"true\">"
						+ "	<param name=\"LOOP\" value=\"true\">"
						+ "	<param name=\"QUALITY\" value=\"high\">"
						+ "	<embed src=\""+url+"\" width=\""+width+"\" height=\""+height+"\""
						+ "		play=\"true\" align=\"center\" loop=\"true\" quality=\"high\""
						+ "		type=\"application/x-shockwave-flash\""
						+ "		style=\"font-size: 0;line-height: 0;\""
						+ "		pluginspage=\"http://www.macromedia.com/go/getflashplayer\">"
						+ "	</embed>"
						+ "</object>";
		output = jQuery("<span></span>");
		setTimeout(function () {
			output.html(object);
		},500);
	}
	else if (mode == "DOC_PREVIEW")
	{
		output = jQuery("<div class=\"zoomify-album-container id"+id+"\"></div>");
		jQuery(document).ready(function () {
			ZoomifyAlbum.setup();
		});
	}
	return output;
}

ZoomifyAlbum = {
	config: {
		container: ".zoomify-album-container",
		width: 640,
		inited: "inited",
		pageHeader: "page",
		idHeader: "id",
		retrieve: "<%= request.getContextPath() %>/retrieve-zip",
		buttons: {
			container: "zoomify-album-button-container",
			className: "zoomify-album-button",
			nowPage: "now-page",
			<%-- first: "第一頁", --%>
			first: "<%= lm(pg, "zoomify-album.first") %>",
			firstImg: "<img src=\"<%= request.getContextPath() %>/extension/bitstream-display/zoomify-album/first.gif\" border=\"0\" />",
			<%-- prev: "上一頁", --%>
			prev: "<%= lm(pg, "zoomify-album.prev") %>",
			prevImg: "<img src=\"<%= request.getContextPath() %>/extension/bitstream-display/zoomify-album/prev.gif\" border=\"0\" />",
			<%-- next: "下一頁", --%>
			next: "<%= lm(pg, "zoomify-album.next") %>",
			nextImg: "<img src=\"<%= request.getContextPath() %>/extension/bitstream-display/zoomify-album/next.gif\" border=\"0\" />",
			<%-- last: "最後一頁", --%>
			last: "<%= lm(pg, "zoomify-album.last") %>",
			lastImg: "<img src=\"<%= request.getContextPath() %>/extension/bitstream-display/zoomify-album/last.gif\" border=\"0\" />"
		},
		slide: {
			className: "zoomify-album-slide",
			handlePage: "slide-handle-page", 
			preview: "zoomify-album-slide-preview",
			previewWidth: 200,
			<%-- pageHandle: "現在頁數", --%>
			pageHandle: "<%= lm(pg, "zoomify-album.page-handle") %>",
			<%-- pageHeader: "第", --%>
			pageHeader: "<%= lm(pg, "zoomify-album.page-header") %>",
			<%-- pageFooter: "頁", --%>
			pageFooter: "<%= lm(pg, "zoomify-album.page-footer") %>",
			<%-- slideTitle: "PAGE: " --%>
			slideTitle: "<%= lm(pg, "zoomify-album.slide-title") %>"
				
		},
		zoomify: {
			container: "zoomify-album-zoomify-container",
			width: "620",
			height: "422",
			viewer: "<%= request.getContextPath() %>/extension/bitstream-display/zoomifyViewer.swf"
		},
		<%-- readPageError: "頁碼錯誤" --%>
		readPageError: "<%= lm(pg, "zoomify-album.read-page-error") %>"
	},
	setup: function () {
		if (typeof(ZoomifyAlbumSetupPrepare) == "undefined")
		{
			ZoomifyAlbumSetupPrepare = true;
			jQuery(document).ready(function () {
				var config = ZoomifyAlbum.config;
				var albums = jQuery(config.container + ":not("+config.inited+")");
				for (var i = 0; i < albums.length; i++)
				{
					ZoomifyAlbum.init(albums.eq(i));
					albums.eq(i).addClass(config.inited);
				}
				delete ZoomifyAlbumSetupPrepare;
			});
		}
	},
	init: function (container) {
		var config = ZoomifyAlbum.config;
		var pages = ZoomifyAlbum.getPage(container);
		
		if (pages == -1)
		{
			var id = ZoomifyAlbum.getID(container);
			var getPageURL = ZoomifyAlbum.getPageURL(id) + "/page.js";
			try
			{
				jQuery.get(getPageURL, function(data) {
					container.addClass(ZoomifyAlbum.config.pageHeader + "" +data);
					ZoomifyAlbum.init(container);
				});
			} catch (e) { }
			return;
		}
		
		var createButton = ZoomifyAlbum.createButton;
		var buttonContainer = jQuery("<table width=\"100%\"><tbody><tr></tr></tbody></table>")
			.addClass(config.buttons.container)
			.prependTo(container);
		var tr = buttonContainer.find("tbody tr");
		var firstTd = jQuery("<td></td>").addClass("first").appendTo(tr);
		var prevTd = jQuery("<td></td>").addClass("prev").appendTo(tr);
		var slideTitleTd = jQuery("<td></td>").addClass("slide-title")
			.html(config.slide.slideTitle)
			.css("font-size", "small")
			.css("font-weight", "bold")
			.appendTo(tr);
		var slideTd = jQuery("<td></td>").addClass("slide").appendTo(tr);
		var nextTd = jQuery("<td></td>").addClass("next").appendTo(tr);
		var lastTd = jQuery("<td></td>").addClass("last").appendTo(tr);
		
		var navEvt = ZoomifyAlbum.navigationEvent;
		var btnFirst = createButton(config.buttons.firstImg
			, config.buttons.first, navEvt.first, firstTd);
		var btnPrev = createButton(config.buttons.prevImg
			, config.buttons.prev, navEvt.prev, prevTd);
		
		var btnNext = createButton(config.buttons.nextImg
			, config.buttons.next, navEvt.next, nextTd);
		
		var btnLast = createButton(config.buttons.lastImg
			, config.buttons.last, navEvt.last, lastTd);
		
		//在這邊插入頁碼切換
		var pageContainer = jQuery("<span></span>")
			.appendTo(slideTd)
			.hide();
		var nowPage = jQuery("<input type=\"text\" />")
			.addClass(config.buttons.nowPage)
			.val(1)
			.attr("nowPage", -1)
			.change(function () {
				if (jQuery(this).attr("nowPage") != this.value)
				{
					ZoomifyAlbum.readPage(this.value, this);
					jQuery(this).attr("nowPage", this.value);
					var slide = ZoomifyAlbum.getSlide(this);
					slide.slider("value", this.value);
					var handlePage = ZoomifyAlbum.getSlideHandlePage(this);
					handlePage.html(this.value);
				}
			})
			.prependTo(pageContainer);
		//var allPage = ZoomifyAlbum.getPage(container);
		//	pageContainer.append(allPage);
		var slideContainer = jQuery("<div></div>")
			.addClass(config.slide.className)
			.appendTo(slideTd);
		
		slideContainer.slider({
			value: 1,
			min: 1,
			max: pages,
			step: 1,
			slide: function(event, ui) {
				nowPage.val(ui.value);
				var handle = slideContainer.find(".ui-slider-handle:first");
				var handlePage = handle.children("."+config.slide.handlePage);
				if (handlePage.length == 0)
				{
					handlePage = jQuery("<div></div>")
						.addClass(config.slide.handlePage)
						.appendTo(handle);
				}
				var p = ui.value;
				handlePage.removeClass("size3").removeClass("size4");
				if (p.length > 2)
				{
					var size = p.length;
					if (size > 4)
						size = 4;
					handlePage.addClass("size" + size);
				}
				handlePage.html(p);
				
				setTimeout(function () {
					ZoomifyAlbum.slidePreview.open(slideContainer, ui.value);
				}, 10);
			},
			stop: function (event, ui) {
				nowPage.change();
				ZoomifyAlbum.slidePreview.close();
			}
		});
		
		var handle = slideContainer.find(".ui-slider-handle:first");
		var handlePage = handle.children("."+config.slide.handlePage);
		if (handlePage.length == 0)
		{
			handlePage = jQuery("<div></div>")
				.addClass(config.slide.handlePage)
				.appendTo(handle);
		}
		handlePage
			.attr("title", config.slide.pageHandle)
			.html(1);
		
		/*
		slideContainer.prepend("<div class=\"first page\">"+1+"</div>")
			.prepend("<div class=\"last page\">"+ZoomifyAlbum.getPage(container)+"</div>");
		*/
		var pageNumberTable = jQuery("<table algin=\"center\" cellpadding=\"0\" cellspacing=\"0\" class=\"page\" width=\"99%\"><tbody><tr><td align=\"left\">"+1+"</td><td align=\"right\">"+pages+"</td></tr></tbody></table>")
			.appendTo(slideContainer);
		
		var zoomifyContainer = jQuery("<div></div>")
			.addClass(config.zoomify.container)
			.appendTo(container);
		
		nowPage.change();
		
	},
	getPageInput: function (container)
	{	
		container = ZoomifyAlbum.getContainer(container);
		var pageInput = container.find("."+ZoomifyAlbum.config.buttons.nowPage+":first");
		return pageInput;
	},
	getSlide: function (container)
	{
		container = ZoomifyAlbum.getContainer(container);
		var slider = container.find("."+ ZoomifyAlbum.config.slide.className + ":first");
		return slider;
	},
	getSlideHandlePage: function (container)
	{
		container = ZoomifyAlbum.getContainer(container);
		var sliderHandlePage = container.find("."+ ZoomifyAlbum.config.slide.className + ":first ."+ZoomifyAlbum.config.slide.handlePage);
		return sliderHandlePage;
	},
	navigationEvent: {
		first: function (thisObj) {
			var pageInput = ZoomifyAlbum.getPageInput(thisObj);
			var page = 1;
			if (page != pageInput.val())
				pageInput.val(page).change();
		},
		prev: function (thisObj) {
			var pageInput = ZoomifyAlbum.getPageInput(thisObj);
			var page = pageInput.val();
			page--;
			if (page < 1)
				page = 1;
			if (page != pageInput.val())
				pageInput.val(page).change();
		},
		next: function (thisObj) {
			var pageInput = ZoomifyAlbum.getPageInput(thisObj);
			var pages = ZoomifyAlbum.getPage(thisObj);
			var page = pageInput.val();
			page++;
			if (page > pages)
				page = pages;
			if (page != pageInput.val())
				pageInput.val(page).change();
		},
		last: function (thisObj) {
			var pageInput = ZoomifyAlbum.getPageInput(thisObj);
			var pages = ZoomifyAlbum.getPage(thisObj);
			var page = pages;
			if (page != pageInput.val())
				pageInput.val(page).change();
		}
	},
	getPage: function (container) {
		container = ZoomifyAlbum.getContainer(container);
		var pageHeader = ZoomifyAlbum.config.pageHeader;
		var classes = container.attr("className").split(" ");
		var page = -1;
		for (var i = 0; i < classes.length; i++)
		{
			var c = classes[i];
			if (c.indexOf(pageHeader) == 0
				&& (c.substring(0, pageHeader.length) == pageHeader))
			{
				var len = c.length;
				page = c.substring(pageHeader.length, len);
				page = parseInt(page);
				break;
			}
		}
		return page;
	},
	getID: function (container) {
		container = ZoomifyAlbum.getContainer(container);
		var header = ZoomifyAlbum.config.idHeader;
		var classes = container.attr("className").split(" ");
		var id = -1;
		for (var i = 0; i < classes.length; i++)
		{
			var c = classes[i];
			if (c.indexOf(header) == 0
				&& (c.substring(0, header.length) == header))
			{
				var len = c.length;
				id = c.substring(header.length, len);
				id = parseInt(id);
				break;
			}
		}
		return id;
	},
	getContainer: function (container) {
		container = jQuery(container);
		var className = ZoomifyAlbum.config.container;
		if (container.hasClass(className))
			return container;
		else
		{
			var parents = container.parents(className + ":first");
			if (parents.length == 1)
				return parents;
			else
				return null;
		}
	},
	slidePreview: {
		get: function () {
			var config = ZoomifyAlbum.config;
			var slidePreview = jQuery("." + config.slide.preview + ":first");
			if (slidePreview.length == 0)
			{
				slidePreview = jQuery("<div><span class=\"page-number\"></span><img /></div>")
					.addClass(config.slide.preview)
					.hide()
					.appendTo(jQuery("body"));
			}
			return slidePreview;
		},
		open: function (slideContainer, page) {
			var config = ZoomifyAlbum.config;
			var slidePreview = ZoomifyAlbum.slidePreview.get();
			
			slidePreview.css("position", "absolute");
			
			var slideContainerOffset = slideContainer.offset();
			var top = slideContainerOffset.top;
				top = top + slideContainer.height()*1.5;
			//zoomify.css("z-index", -1);
			slidePreview.css("top", top + "px");
			
			var handle = slideContainer.find(".ui-slider-handle:first");
			var handleOffset = handle.offset();
			var left = handleOffset.left + parseInt(handle.width() / 2) - parseInt(config.slide.previewWidth / 2);
			//if (left < 0)
			//	left = 0;
			//else if (left + config.slide.previewWidth > config.width)
			//	left = config.width - config.slide.previewWidth;
			
			slidePreview.css("left", left + "px");
			slidePreview.css("z-index", 999);
			
			var id = ZoomifyAlbum.getID(slideContainer);
			ZoomifyAlbum.slidePreview.set(id ,page);
			
			slidePreview.fadeIn();
			
			if (typeof(slidePreviewClose) != "undefined")
			{
				clearTimeout(slidePreviewClose);
				delete slidePreviewClose;
			}
			slidePreviewClose = setTimeout(function () {
				slidePreview.fadeOut();
			}, 3000);
		},
		close: function () {
			var slidePreview = ZoomifyAlbum.slidePreview.get();
			slidePreview.fadeOut();
			if (typeof(slidePreviewClose) != "undefined")
			{
				clearTimeout(slidePreviewClose);
				delete slidePreviewClose;
			}
		},
		set: function (id, page) {
			var config = ZoomifyAlbum.config;
			var slidePreview = ZoomifyAlbum.slidePreview.get();
			slidePreview.find(".page-number").html(config.slide.pageHeader+ page + config.slide.pageFooter);
			
			var thumbnailURL = ZoomifyAlbum.getPageURL(id, page) + "/TileGroup0/0-0-0.jpg";
			slidePreview.find("img").attr("src", thumbnailURL);
		}
	},
	readPage: function (page, container) {
		var config = ZoomifyAlbum.config.zoomify;
		container = ZoomifyAlbum.getContainer(container);
		
		page = parseInt(page);
		if (typeof(page) != "number")
		{
			alert(ZoomifyAlbum.config.readPageError + typeof(page));
			return;
		}
		
		var zoomifyContainer = container.children("."+config.container+":first");
		
		
		//zoomifyContainer.empty();
		
		var id = ZoomifyAlbum.getID(container);
		var url = ZoomifyAlbum.getPageURL(id, page);
		var viewer = ZoomifyAlbum.getZoomifyViewer(url);
		
		//建立遮罩
		var cover = jQuery("<div></div>")
			.addClass("cover")
			.hide()
			.prependTo(zoomifyContainer);
		
		cover.css("width", zoomifyContainer.width() + "px")
			.css("height", zoomifyContainer.height() + "px");
		
		cover.fadeIn(300);
		var changeLock = url;
		setTimeout(function () {
			if (typeof(changeLock) != "undefined"
				&& changeLock == url)
			{
				var oldViewer = zoomifyContainer.children("span");
				oldViewer.remove();
				viewer.appendTo(zoomifyContainer);
				//setTimeout(function () {
				if (typeof(changeLock) != "undefined"
					&& changeLock == url)
				{
					jQuery.get(url + "/ImageProperties.xml", function (data) {
						if (typeof(changeLock) != "undefined"
							&& changeLock == url)
						{
							setTimeout(function () {
								cover.fadeOut(300, function () {
									cover.remove();
									delete changeLock;
								});
							}, 500);
						}
					});
				}
			}
		}, 300);
		
		/*
		var oldViewer = zoomifyContainer.children("object");
				oldViewer.remove();
				viewer.appendTo(zoomifyContainer);
		*/
	},
	getPageURL: function (id, page) {
		var retrieve = ZoomifyAlbum.config.retrieve;
		
		if (typeof(page) != "undefined")
		{
			page = "" + page;
			while (page.length < 5)
				page = "0" + page;
			page = "/" + page;
		}
		else
			page = "";
		
		var url = retrieve + "/" + id + page;
		return url;
	},
	getZoomifyViewer: function (url) {
		var config = ZoomifyAlbum.config.zoomify
		var viewerPath = config.viewer;
		var object = "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0\" \n"
							+ "	style=\"font-size: 0;line-height: 0;border:1px solid #CCCCCC;\""
							+ "	width=\""+config.width+"\" height=\""+config.height+"\">"
		        			+ "		<param name=\"FlashVars\" value=\"zoomifyImagePath="+url+"/&zoomifyNavigatorVisible=false\">"
				        	+ "		<param name=\"BGCOLOR\" value=\"#FFFFFF\">"
		        			+ "		<param name=\"MENU\" value=\"true\">"
							+ "		<param name=\"SRC\" value=\""+viewerPath+"\">"
							+ "		<param name=\"wmode\" value=\"opaque\">"
							+ "		<embed flashvars=\"zoomifyImagePath="+url+"/&zoomifyNavigatorVisible=false\""
		                	+ "			src=\""+viewerPath+"\" bgcolor=\"#FFFFFF\" menu=\"true\" pluginspage=\"http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash\""
		            		+ "			style=\"font-size: 0;line-height: 0;border:1px solid #CCCCCC;\""
		    				+ "			wmode=\"opaque\""
		                	+ "			width=\""+config.width+"\" height=\""+config.height+"\"></embed>"
		    				+ "</object>";
		var output = jQuery("<span></span>");
		setTimeout(function () {
			output.html(object);
		}, 500);
		return output;
	},
	createButton: function (innerHTML, title, clickEvent, appendToObj) {
		var className = ZoomifyAlbum.config.buttons.className;
		var btn = jQuery("<a href=\"#\"></a>")
			.addClass(className)
			.attr("title", title)
			.html(innerHTML)
			.click(function () {
				var btn = this;
				jQuery(btn).addClass("click");
				clickEvent(this);
				setTimeout(function () {
					jQuery(btn).removeClass("click");
				}, 100);
				
			})
			.appendTo(appendToObj)
			.hover(function () {jQuery(this).addClass("hover");}, function () {jQuery(this).removeClass("hover");});
		return btn;
	}
};