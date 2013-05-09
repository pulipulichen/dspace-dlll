//jquery-plugin-inputTypeItem-edit-item-form.js
//2009.06.18
function inputTypeItemHide()
{
	if (typeof(inputTypeItemEditInited) != "undefined")
		return;
	else
		inputTypeItemEditInited = true;
	
	var getValue = location.href;
	jQuery("tr.pageMovie").hide();

	if(getValue.indexOf("input-type=item") != -1)
	{
		//這是getcdb要隱藏的對象
		if (location.href.indexOf("/getcdb/") != -1)
		{
			jQuery("tr.pageBanner").hide();//頭隱藏
			jQuery("tr.pageFooterBar").hide();//尾隱藏
			jQuery("table.submitProgressTable").hide();//ProgressBar隱藏
			jQuery(".cancel").hide();//取消按鈕隱藏
			jQuery(".submitProgressPrev").hide();//上一頁隱藏
			jQuery(".submitProgressNext").hide();//下一頁隱藏
			jQuery(".review-form").hide();//預覽文件頁面隱藏
			//jQuery("#license").hide();//license頁面隱藏
			jQuery(".ui-dialog-titlebar-close").remove();
			jQuery(".locationBar").hide();//連結隱藏
			jQuery(".preview").hide();//預覽按鈕隱藏
			jQuery(".update").hide();//更新按鈕隱藏
			jQuery(".updateAndBack").hide();//更新並回到文件按鈕隱藏
			
			if(jQuery("input[name='submit_grant']").length != 0)
				jQuery("input[name='submit_grant']").click();//按同意鈕
							
			if(jQuery(".submitProgressNext").length != 0)
				jQuery(".submitProgressNext").click();//下一頁按鈕點擊
		}
		else
		{
			//這是原始DSpace要隱藏的對象
			var noscripts = jQuery("noscript");
			for (var i = 0; i < noscripts.length; i++)
			{
				noscripts.eq(i).prevAll("script:first").remove();
				noscripts.eq(i).remove();
			}
			
			jQuery("body").wrapInner("<div style=\"display:none\"></div>");
			
			//中間隱藏一些不必要的東西吧
				jQuery(".colleciton-select-div").hide();
				jQuery("p.locationBar").hide();
				//jQuery(".submitProgressNext,.submitProgressPrev").hide();
			
			var contents = jQuery(".pageContents:first").contents();
			var contentDiv = jQuery("<div class=\"pageContents\"></div>").append(contents)
				.appendTo(jQuery("body"));
			jQuery(".collection-root table:first").hide();
			jQuery("body center:last").hide();
			jQuery("body button.submitProgressPrev").hide();
			jQuery("body button.submitProgressNext").hide();
			
			jQuery("div.pageContents table td.submitFormLabel").css("min-width", "60px");
			
			//點下一頁！
			setTimeout(function () {
				jQuery("#progressbar_button_0_1").click();
				//alert(jQuery(".submitProgressNext:first").length);
				//jQuery(".submitProgressNext:first").click();	//下一頁按鈕點擊
				jQuery("#update_button").appendTo(jQuery("#editMetadataForm"));
				//alert(jQuery("#editMetadataForm").length);
				//jQuery("#editMetadataForm").show().css("border", "1px solid red");
				jQuery("#editMetadataForm").appendTo(jQuery("body"));
				jQuery("#update_button").hide();
			}, 500);
		}
	}
}


if(location.href.indexOf("input-type=") != -1)
{
	jQuery(document).ready(function () {
		inputTypeItemHide();
	});
}