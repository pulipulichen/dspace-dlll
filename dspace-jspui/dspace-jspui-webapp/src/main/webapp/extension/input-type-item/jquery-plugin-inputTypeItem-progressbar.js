//jquery-plugin-inputTypeItem-progressbar.js
//2009.06.18
function inputTypeItemHide()
{
	//鎖
	if (typeof(inputTypeItemHideInited) != "undefined")
		return;
	else
		inputTypeItemHideInited = true;
	
	//先把form的action的問題解決掉吧
	//如果有要傳遞參數，則把所有的form的action都移除掉，讓他能夠順利把參數丟到下一頁。
	if (location.href.indexOf("input-type=") != -1)
	{
		jQuery(document).ready(function () {
			var forms = jQuery("form");
			//alert(forms.length);
			for (var i = 0; i < forms.length; i++)
			{
				forms.eq(i).attr("action", "");
				//alert(forms.eq(i).attr("action"));
			}
		});
	}
	
	var getValue = location.search;
	jQuery("tr.pageMovie").hide();
	//if(getValue.indexOf("?") != -1)
		//getValue = getValue.substring(1,getValue.length);	
	if (getValue.indexOf("input-type=item") != -1)
	{
		if (jQuery("form[name='edit_metadata']").length ==1)
		{
			var iframe = jQuery(parent.document).find("iframe[name=\""+self.name+"\"]");
			iframe.css("visibility", "visible");
		}
		
		var noscripts = jQuery("noscript");
		for (var i = 0; i < noscripts.length; i++)
		{
			noscripts.eq(i).prevAll("script:first").remove();
			noscripts.eq(i).remove();
		}
		
		var contents = jQuery(".pageContents:first");
		
		jQuery(".submitProgressTable").hide();//ProgressBar隱藏
		
		submissionSkip();	//強迫執行跳躍
		
		jQuery(document).ready(function () {
			
			if (jQuery("input[type='hidden'][name='jsp']").length > 0)
				var jsp = jQuery("input[type='hidden'][name='jsp']").val();
			else
				var jsp = "/submit/edit-metadata.jsp";
				
			if (jsp == "/submit/edit-metadata.jsp")
			{
				//取消item的功能！
				denyDoItem = true;
				
				jQuery(document).ready(function () {
					jQuery("body").wrapInner("<div id=\"hideBody\"></div>");
					var contentDiv = jQuery("<table width=\"100%\"><tbody><tr></tr></tbody></table>")
					jQuery("body").append(contentDiv);
					contentDiv.find("tr").append(contents);
					
					//contentDiv.appendTo(jQuery("body"));
					jQuery("center:last").css("display", "none");	//按鈕隱藏
					jQuery("div#hideBody").hide();
					//jQuery("body").css("padding-left", "100px");
					
					
				});
			}
		});
		/*
		jQuery("tr.pageBanner").hide();//頭隱藏
		jQuery("tr.pageFooterBar").hide();//尾隱藏
		jQuery("table.submitProgressTable").hide();//ProgressBar隱藏
		jQuery(".cancel").hide();//取消按鈕隱藏
		jQuery(".submitProgressPrev").hide();//上一步隱藏
		jQuery(".submitProgressNext").hide();//下一步隱藏
		jQuery(".review-form").hide();//預覽文件頁面隱藏
		//jQuery("#license").hide();//license頁面隱藏
		jQuery("input[name='submit_prev']").hide();
		jQuery("input[name='submit_cancel']").hide();
		jQuery(".ui-dialog-titlebar-close").remove();
		if(jQuery("input[name='submit_grant']").length != 0)
			{jQuery("input[name='submit_grant']").click();}//按同意鈕
				
		if(jQuery("input[class='review_next_step']").length != 0)
			{jQuery("input[class='review_next_step']").click();}
		*/
		
		
	}
}
var inputTypeItemComplete = function (handle)
{
	//鎖
	if (typeof(inputTypeItemCompleteInited) != "undefined")
		return;
	else
		inputTypeItemCompleteInited = true;
	
	if (typeof(handle) == "undefined"
		|| handle == "null")
		return;
	
	//alert([
	//	"input-type-item complete?", 
	//	self.document.referrer]);
	//return;
	var getValue = self.document.referrer;
	if(getValue.indexOf("input-type=item") != -1)
	{
		var textID = self.name.replace("_prompt", "");
		
		var text = parent.document.getElementById(textID);
		
		text.value = handle;
		
		jQuery(text).change();
			
		var promptDiv = jQuery(parent.document.getElementById(self.name));
		
		promptDiv.parents("div.ui-dialog").find("button.ui-state-default:first")
			.removeAttr("disabled")
			.click();
	}
};
