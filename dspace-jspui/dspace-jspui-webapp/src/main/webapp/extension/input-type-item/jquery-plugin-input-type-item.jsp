<%@ page contentType="application/x-javascript; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%--
需要新增的語系檔：
jsp.submit.input-type-item.next-save = \u4e0b\u4e00\u6b65/\u5132\u5b58
jsp.submit.input-type-item.loading-msg = \u8655\u7406\u4e2d\uff0c\u8acb\u7a0d\u5019\u2026\u2026
jsp.submit.input-type-item.loading-err = \u8655\u7406\u642\u4f3c\u4e4e\u65b7\u7dda\u4e86\u3002
jsp.submit.input-type-item.reload = \u91cd\u65b0\u8b80\u53d6
	
jsp.submit.input-type-item.next-save	//下一步/儲存
jsp.submit.input-type-item.loading-msg	//處理中，請稍候……
jsp.submit.input-type-item.loading-err	//處理時似乎斷線了。
jsp.submit.input-type-item.reload	//重新讀取
--%>
jQuery.fn.extend({
	doItem: function (collectionID) {
		if (typeof(denyDoItem) != "undefined" && denyDoItem == true)
			return;
		
		if (typeof(collectionID) == "undefined"
				|| collectionID == ""
				|| collectionID == "null")
		{
			window.alert("collectionID not set!");
			return;
		}
		
		var thisObj = jQuery(this);
		
		if (thisObj.length == 0)
			return;
		else if (thisObj.length > 1)
		{
			for (var i = 0; i < thisObj.length; i++)
				thisObj.eq(i).doItem(collectionID);
			return;
		}
		
		var LANG = {
			"add": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.addnew") %>",	//"新增"
			"edit": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.edit") %>",	//"修改"
			"remove": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.search.advanced.clear") %>",	//"清空"
			"close": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.suggestok.button.close") %>",	//關閉
			"reload": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.input-type-item.reload") %>",	//重新讀取
			"loadingMsg": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.input-type-item.loading-msg") %>", //"處理中，請稍候。"
			"loadingErr": "<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.input-type-item.loading-err") %>"	//"處理時似乎斷線了"
		};
						
		var inputID = thisObj.attr("id");
		if (inputID == "")
		{
			if (typeof(inputTypeItemCounter) == "undefined")
				inputTypeItemCounter = 0;
			else
				inputTypeItemCounter++;
				
			inputID = "inputTypeItem_"+inputTypeItemCounter;
			thisObj.attr("id", inputID);
		}
		var promptID = inputID + "_prompt";
		var iframeID = inputID + "_iframe";
		thisObj.hide();
		
		var removeEditor = function (thisObj) {
			if(thisObj.nextAll("div.item-editor").length > 0)
				thisObj.nextAll("div.item-editor").remove();
		};
		var createEditor = function(thisObj) {
			removeEditor(thisObj);
		
			var editDiv = jQuery("<div class ='item-editor' ></div>")
				.insertAfter(thisObj);
			
			if (thisObj.val() == "")
			{
				var btnAdd = jQuery("<button type=\"button\" class=\"do-item-add\">"+LANG.add+"</button>")
					.appendTo(editDiv)
					.click(function () {
						createPromptAdd(promptID, inputID);
					});
			
			}
			else
			{
				var handle = jQuery("<span>"+thisObj.val()+"</span>")
					.appendTo(editDiv);
				
				var btnEdit = jQuery("<button type=\"button\" class=\"do-item-edit\">"+LANG.edit+"</button>")
					.css("float", "right")
					.css("margin", "0")
					.prependTo(editDiv)
					.click(function(){
						createPromptEdit(promptID, inputID, thisObj.val());
					});
				
				var btnClear = jQuery("<button type=\"button\" class=\"do-item-clear\">"+LANG.remove+"</button>")
					.css("float", "right")
					.css("margin", "0")
					.prependTo(editDiv)
					.click(function(){
						//var thisObj = jQuery(this).parents("div.item-editor:first").prevAll("input[type='text']:first");
						//thisObj.val("");
						//createEditor(thisObj);
						
						//請改成刪除這筆item的作法吧
						createPromptRemove(promptID ,inputID ,thisObj.val());
					});
			}
			
		};
		
		//var iframeDebug = true; 	//true || false
		
		var createPromptAdd = function (promptID ,inputID) {
			if (jQuery("#"+promptID).length > 0)
				jQuery("#"+promptID).remove();
			
			var promptDiv = jQuery("<div id=\""+promptID+"\" class=\"do-item-prompt\"></div>")
				.css("background-color", "#FFF")
				.css("overflow", "hidden")
				.appendTo(jQuery("body"));
			
			var src = "<%= request.getContextPath() %>/submit?input-type=item";
			
			var promptMsg = getPromptMsg()
				.html(LANG.loadingMsg)
				.appendTo(promptDiv);
		
			var promptIframe = getPromptIframe()
				.appendTo(promptDiv)
				.load(function () {
					var iframeDoc = getIframeDoc(this);
					
					//先確認是不是在登入畫面
					if (jQuery(iframeDoc).find("input[type='password'][name='login_password']").length == 0)
					{
						var jsp = jQuery(iframeDoc).find("input[type='hidden'][name='jsp']:first").val();
						
						if (jsp == "/submit/edit-metadata.jsp")
						{
							var cancellationInput = jQuery(iframeDoc).find("input[type='hidden'][name='cancellation']:first");
							if (cancellationInput.length == 0 
								|| (cancellationInput.length > 0 && cancellationInput.val() != "true"))
							{
								var btnShow = findDialog(this, "button.iframe-show:first")
									.click();
							}
							else
							{
								jQuery(this).unbind("load")
									.load(function () {
										//alert("ok囉？準備關閉囉！");
										var btnClose = findDialog(this, "button.ui-state-default:first")
											.removeAttr("disabled")
											.click();	
									});
								var btnRemove = iframeDoc.find("input[type='submit'][name='submit_remove']:first").click();
							}
						}
						//alert(jsp);
					}	//if (jQuery("form[action='<%= request.getContextPath() %>/password-login']").length == 0)
					else
					{
						//讓他登入吧
						simplifyLogin(iframeDoc, this);
					}
				});
			
			
			var selectForm = jQuery("<form action=\""+src+"\" target=\""+promptID+"\" method=\"post\"></form>")
				.append("<input name=\"collection\" value=\""+collectionID+"\" type=\"hidden\">")
				.append("<input name=\"submit\" type=\"submit\" style=\"display:none\">")
				.appendTo(promptDiv);
			
			var editor = getPromptEditor()
				.prependTo(promptDiv);
			
			if (typeof(iframeDebug) != "undefined" && iframeDebug == true)
			{
				editor.show();
				promptIframe.css("visibility", "visible");
				promptMsg.hide();
			}
			
			var option = initDialogOption();
			
			option.buttons = {
				"<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.suggestok.button.close") %>": function () {
					jQuery(this).dialog("close"); 
				},
				"<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.cancel") %>": function () { 
					if (!(typeof(iframeDebug) != "undefined" && iframeDebug == true))
					{
						var dialogRoot = jQuery(this).parents("div.ui-dialog:first");
						dialogRoot.find("button.iframe-hide:first").click();
					}
					
					//jQuery(this).dialog("close"); 
					var iframe = findDialog(this, "iframe.do-item-iframe:first");
					//iframe.hide();
					var iframeDoc = getIframeDoc(iframe);
					
					var submitCancel = iframeDoc.find("input[type='submit'][name='submit_cancel']:first");
					//alert(submitCancel.length);
					
					if (submitCancel.length == 1)
					{
						submitCancel.click();
					}
				},	//"取消": function () { 
				"<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.input-type-item.next-save") %>": function () {
					if (!(typeof(iframeDebug) != "undefined" && iframeDebug == true))
					{
						var dialogRoot = jQuery(this).parents("div.ui-dialog:first");
						dialogRoot.find("button.iframe-hide:first").click();
					}
					
					var iframe = document.getElementById(iframeID)
										
					if(iframe.contentWindow)
					{
						var iframeDoc = iframe.contentWindow.document;
					}
					else if(iframe.contentDocument)
					{
       					var iframeDoc = iframe.contentDocument.document;
					}
					iframeDoc.getElementById("submitProgressNext").click();
				}	//"下一步/儲存": function () {
			};	//option.buttons = {
				
			option.open = function () {
				selectForm.find("input[name='submit']").click();
				var dialogBtn = findDialog(this, "button.ui-state-default")
					.attr("disabled", "disabled");
				dialogBtn.filter(":first").hide();
				var dialogClose = findDialog(this, "a.ui-dialog-titlebar-close")
					.hide();
			};
			option.close = function () {
				var inputID = jQuery(this).dialog("option", "dialogClass");
				
				var input = jQuery("#"+inputID);
				if (input.val() != "")
				{
					input.change();
				}
				else
				{
					//如果沒有值，表示他並沒有正確地更新，那就要把原來那個刪掉
					//改用按鈕來控制了，普通情況下不能關閉這個dialog
				}
			};
			
			promptDiv.dialog(option);
			
			editor.find("button.iframe-hide").click();
		};
		
		var createPromptEdit = function (promptID ,inputID ,handle) {
			var promptDiv = jQuery("<div id=\""+promptID+"\" class=\"do-item-prompt\"></div>")
				.css("overflow", "hidden")
				.css("background-color", "#FFF")
				.appendTo(jQuery("body"));
			
			var src = "<%= request.getContextPath() %>/tools/edit-item?handle="+handle+"&input-type=item";
			//var src = "";
			
			var promptMsg = getPromptMsg()
				.html(LANG.loadingMsg)
				.appendTo(promptDiv);
			
			var promptIframe = getPromptIframe()
				.appendTo(promptDiv)
				.load(function () {
					var iframeDoc = getIframeDoc(this);
					//先確認是不是在登入畫面
					if (jQuery(iframeDoc).find("input[type='password'][name='login_password']").length == 0)
					{
						//是正確的編輯畫面……打開iframe吧
						var btnShow = findDialog(this, "button.iframe-show:first")
									.click();
					}
					else
					{
						//讓他登入吧
						simplifyLogin(iframeDoc, this);
					}
				});
			
			var editor = getPromptEditor()
				.prependTo(promptDiv);
			
			
			
			if (typeof(iframeDebug) != "undefined" && iframeDebug == true)
			{
				editor.show();
				promptIframe.css("visibility","visible");
				promptMsg.hide();
			}
			
			promptIframe.attr("src", src);
			
			var option = initDialogOption();
			option.buttons = {
				"<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.cancel") %>": function () { 
					jQuery(this).dialog("close"); 
				},
				"<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.submit.input-type-item.next-save") %>": function () {
					//var iframeID = jQuery(this).dialog('option', "dialogClass");
					var iframe = findDialog(this, "iframe:first");
					var iframeDoc = getIframeDoc(iframe);
					var currentButton = jQuery(iframeDoc).find(".submitProgressButton.submitProgressButtonCurrent:first");
					var nextButton = currentButton.parents("li:first").nextAll("li:first").children("input:first");
					
					if (nextButton.length == 0 ||
						typeof(nextButton.attr("id")) == "undefined" ||
						nextButton.attr("id").indexOf("_metadata") != -1)
					{
						//如果沒有後面的資料了，才按下更新
						var btnHide = findDialog(this, "button.iframe-hide:first")
									.click();
						//jQuery(iframeDoc).find("body").wrapInner("<form action=\"?action=3\" method=\"post\"></form>");
						
						var editMetadataForm = jQuery(iframeDoc).find("#editMetadataForm");
						
						var itemId = jQuery(iframeDoc).find("input:hidden[name='item_id']").clone()
							.appendTo(editMetadataForm);
						var btnSubmit = jQuery("<input type=\"submit\" name=\"submit\" value=\"\" />")
							.appendTo(editMetadataForm);
						
						iframe.unbind("load");
						iframe.load(function () {
							var iframeDoc = getIframeDoc(this);
							if (jQuery(iframeDoc).find("input[type='password'][name='login_password']").length == 0)
								jQuery(this).parents("div.ui-dialog:first").find("button.ui-state-default:first").click();
							else
								simplifyLogin(iframeDoc, this);
						});
						
						//jQuery(iframeDoc).find("#update_button:first").click();
						btnSubmit.click();
					}
					else
					{
						nextButton.click();
					}
				}
			};
			
			option.open = function () {
				var dialogBtn = findDialog(this, "button.ui-state-default")
					.attr("disabled", "disabled");
				var dialogClose = findDialog(this, "a.ui-dialog-titlebar-close")
					.hide();
			};
			
			promptDiv.dialog(option);
			
			editor.find("button.iframe-hide").click();
		};
		
		var createPromptRemove = function (promptID ,inputID ,handle) {
			var promptDiv = jQuery("<div id=\""+promptID+"\" class=\"do-item-prompt\"></div>")
				.css("overflow", "hidden")
				.css("background-color", "#FFF")
				.appendTo(jQuery("body"));
			
			var src = "<%= request.getContextPath() %>/tools/edit-item?handle="+handle+"&input-type=item";
			
			var promptMsg = getPromptMsg()
				.html(LANG.loadingMsg)
				.appendTo(promptDiv);
			
			var promptIframe = getPromptIframe()
				.appendTo(promptDiv)
				.load(function () {
					var iframeDoc = getIframeDoc(this);
					
					//先確認是不是在登入畫面
					if (jQuery(iframeDoc).find("input[type='password'][name='login_password']").length == 0)
					{
						//是正確的編輯畫面……點下刪除鈕吧
						if (typeof(iframeDebug) != "undefined" && iframeDebug == true)
							var btnShow = findDialog(this, "button.iframe-show:first").click();
						
						iframeDoc.ready(function () {
							var removeForm = iframeDoc.find("form:has(input[name='action'][value='1']:hidden)");
							var removeFormConfirm = iframeDoc.find("form:has(input[name='action'][value='2']:hidden)");
							
							if (removeForm.length > 0)
							{
								//alert(1);
								removeForm.find("input[name='action']:first").val(2);
								var removeBtn = removeForm.find("input[type='submit'][name='submit']:first").click();
							}
							else if (removeFormConfirm.length > 0)
							{
								//alert(2);
								var removeBtn = removeFormConfirm.find("input[type='submit'][name='submit']:first").click();
							}
							else
							{
								//alert(3);
								var textID = promptDiv.dialog("option", "dialogClass");
								var text = document.getElementById(textID);
								text.value = "";
								promptDiv.dialog("close");
								jQuery(text).change();
							}
						});
					}
					else
					{
						//讓他登入吧
						simplifyLogin(iframeDoc, this);
					}
				});
			
			var editor = getPromptEditor()
				.prependTo(promptDiv);
			
			if (typeof(iframeDebug) != "undefined" && iframeDebug == true)
			{
				editor.show();
				promptIframe.css("visibility","visible");
				promptMsg.hide();
			}
			
			promptIframe.attr("src", src);
			
			var option = initDialogOption();
			
			option.width = 320;
			option.height = 220;
			
			option.open = function () {
				var dialogBtn = findDialog(this, "button.ui-state-default")
					.attr("disabled", "disabled");
				dialogBtn.filter(":first").hide();
				var dialogClose = findDialog(this, "a.ui-dialog-titlebar-close")
					.hide();
			};
			
			promptDiv.dialog(option);
			
			editor.find("button.iframe-hide").click();
		};
		
		var getDialogRoot = function(obj)
		{
			var dialogRoot = jQuery(obj).parents("div.ui-dialog:first");
			return dialogRoot;
		};
		
		var findDialog = function(obj, selector)
		{
			var dialogRoot = getDialogRoot(obj);
			return dialogRoot.find(selector);
		};
		
		var getIframeDoc = function(iframe)
		{
			if (typeof(iframe.length) == "undefined")
				iframe = jQuery(iframe);
			
			if(iframe.attr("contentWindow"))
			{
				var iframeDoc = iframe.attr("contentWindow").document;
			}
			else if(iframe.attr("contentDocument"))
			{
				var iframeDoc = iframe.attr("contentDocument").document;
			}
			return jQuery(iframeDoc);
		};
		
		var initDialogOption = function () {
			var option = {
				width: 800,
				height: 600, 
				autoOpen: true,
				bgiframe: true,
				draggable: false,
				modal: true,
				resizable: false,
				dialogClass: inputID,
				closeOnEscape: false,
				zIndex: 5
			};			
			return option;
		};
		
		var getPromptMsg= function () {
			var promptMsg = jQuery("<div style=\"width:100%;height: 100%;text-align:center;padding-top:3em;font-size: 2em;\" class=\"prompt-msg\"></div>");
			return promptMsg;
		};
		
		var getPromptIframe = function () {
			var promptIframe = jQuery("<iframe class=\"do-item-iframe\" width=\"100%\" height=\"100%\" id=\""+iframeID+"\" name=\""+promptID+"\"></iframe>")
				.css("visibility", "hidden");
			return promptIframe;
		};
		
		var getPromptEditor = function() {
			var editor = jQuery("<div class=\"editor\"></div>")
				.hide();
			
			var btnShow = jQuery("<button type=\"button\" class=\"iframe-show\">"+"Show Iframe"+"</button>")
				.appendTo(editor)
				.click(function () {
					var prompt = jQuery(this).parents("div.do-item-prompt:first");
					prompt.children("iframe:first").css("visibility", "visible");
					prompt.children("div.prompt-msg:first").hide();
					var dialogBtn = findDialog(this, "button.ui-state-default")
						.removeAttr("disabled");
					
					if (typeof(promptDie) != "undefined")
					{
						clearTimeout(promptDie);
						prompt.children("div.prompt-msg:first").html(LANG.loadingMsg);
					}
					
				});
			var btnHide = jQuery("<button type=\"button\" class=\"iframe-hide\">"+"Hide Iframe"+"</button>")
				.appendTo(editor)
				.click(function () {
					var prompt = jQuery(this).parents("div.do-item-prompt:first");
					prompt.children("iframe:first").css("visibility", "hidden")
					prompt.children("div.prompt-msg:first").show();
					var dialogBtn = findDialog(this, "button.ui-state-default")
						.attr("disabled", "disabled");
					
					promptDie = setTimeout(function () {
						var msg = prompt.find("div.prompt-msg:first");
						
						var errMsg = jQuery("<div style=\"font-size: 1em;margin-top: 0.8em;\">"+LANG.loadingErr+"</div>")
							.appendTo(msg);
						
						var btnClose = jQuery("<button style=\"font-size: 0.8em;\" type=\"button\">"+LANG.close+"</button>")
							.insertAfter(errMsg)
							.click(function () {
								jQuery(this).parents("div.ui-dialog:first")
									.find("button.ui-state-default:first").click();
							});
						var btnReload = jQuery("<button style=\"font-size: 0.8em;\" type=\"button\">"+LANG.reload+"</button>")
							.insertAfter(errMsg)
							.click(function () {
								var dialogRoot = jQuery(this).parents("div.ui-dialog:first");
								var id = dialogRoot.find("div.do-item-prompt").attr("id").replace("_prompt", "");
								var btnAdd = jQuery("#"+id).nextAll(".item-editor:first").children(".do-item-add:first");
								dialogRoot.find("button.ui-state-default:first").click();
								setTimeout(function () {
									btnAdd.click();
								}, 100);
							});
						//alert("成功地呼叫？");
					}, 120000);
				});
			
			return editor;
		};
		
		var simplify = function (doc, process, callback) {
			if (doc.find("body").length > 0)
				doc = doc.find("body");
			
			var noscripts = doc.find("noscript");
			for (var i = 0; i < noscripts.length; i++)
			{
				var n = noscripts.eq(i);
				n.prevAll("script:first").remove();
				n.remove();
			}
			
			setTimeout(function () {
				doc.wrapInner("<div style=\"display:none\" class=\"\"></div>");
				
				var contents = doc.find(".pageContents:first").contents();
				var contentDiv = jQuery("<div class=\"pageContents\"></div>")
					.append(contents)
					.appendTo(doc);
				
				contentDiv.find("#update_button")
					.appendTo(contentDiv.find("#editMetadataForm"));
				
				process();
				if (typeof(callback) != "undefined")
					callback();
			}, 1000);			
		};
		
		var simplifyLogin = function (iframeDoc, iframeObj) {
			simplify(iframeDoc, function () {
					//alert(121);
					iframeDoc.find("div.pageContents form strong:first").hide();
					iframeDoc.find("div.pageContents table:first td.standard").hide();
					iframeDoc.find("div.pageContents input[type='submit'][name='login_submit']:first").click(function () {
						//點下去的話，把上面的框架隱藏吧
						var promptDiv = parent.document.getElementById(self.name);
						jQuery(promptDiv).find("button.iframe-hide:first").click();
					});
				}, function () {
					var btnShow = findDialog(iframeObj, "button.iframe-show:first")
						.click();
				});
		};
		
		//調整移除此文件按鈕
		var btnRemove = thisObj.parents("td:first").nextAll("td:first").find("input[type='submit']:not([name$='_add'])");
		if (btnRemove.length > 0)
		{
			
			btnRemove.hide();
			
			var btnRemoveAlt = jQuery("<button type=\"button\">"+btnRemove.val()+"</button>")
				.insertAfter(btnRemove)
				//.attr("type", "button")
				.click(function () {
					//先檢查thisObj有沒有值
					var thisObj = jQuery(this).parents("td:first").prevAll("td:first").find("input:text:first");
					if (thisObj.val() == "")
					{
						jQuery(this).attr("type", "submit").click();
					}
					else
					{
						thisObj.change(function () {
							var btmRemove = jQuery(this).parents("td:first").nextAll("td:first").find("input[type='submit']:not([name$='_add'])")
								.click();
						});
						
						jQuery(this).parents("td:first").prevAll("td:first").find("button.do-item-clear:first").click();
					}
				});
		}
		
		thisObj.change(function () {
			createEditor(thisObj);
		});
		thisObj.change();
	}
});