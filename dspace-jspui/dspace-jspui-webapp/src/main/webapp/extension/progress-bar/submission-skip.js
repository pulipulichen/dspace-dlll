// JavaScript Document
// for submission skip

function submissionSkip() {
	//如果是在init-question.jsp
	//SubmissionAlert.open("系統處理中，請稍候。");
	//jQuery("td.pageContents:first").hide()
	//	.after(jQuery("<td class=\"submission-alert pageContents\">"+"系統處理中，請稍候"+"</td>"));
	
	//if (location.href.indexOf("input-type=") != -1)
	//	jQuery("form").attr("action", "");
	
	//if (jQuery("input[type='checkbox'][name='multiple_files']").length)
	jQuery(document).ready(function () {
		setTimeout(function () {
			var jsp = jQuery("input[type='hidden'][name='jsp']:last").attr("value");
			
			switch (jsp)
			{
				case "/submit/initial-questions.jsp":
					if (document.referrer.indexOf("/submit?input-type=") != -1)
					{
						//表示是瀏覽器抓錯值了，這是特別為了Google瀏覽器而修改的設計
						return;
					}
					else
					{
						jQuery("input[type='checkbox'][name='multiple_titles']").attr("checked", "checked");
						jQuery("input[type='checkbox'][name='published_before']").attr("checked", "checked");
						jQuery("input[type='checkbox'][name='multiple_files']").attr("checked", "checked");
						
						jQuery("input[type='submit'][name='submit_next']:first").click();
					}
					break;
				case "/submit/upload-file-list.jsp":
				case "/submit/review.jsp":
					jQuery("input[type='submit'][name='submit_next']:first").click();
					break;
				case "/submit/choose-file.jsp":
					jQuery("input[type='submit'][name='submit_upload']:first").click();
					break;
				case "/submit/show-license.jsp":
					jQuery("input[type='submit'][name='submit_grant']:first").click();
					break;
				default:
					jsp = "";
			}
		}, 100);
	});	
}

var SubmissionAlert = {
	"open": function(msg)
	{
		if (jQuery("div#submissionAlert").length == 0)
		{
			jQuery("<div id=\"submissionAlert\" class=\"submission-alert\" title=\"系統訊息\"></div>")
				.html(msg)
				.appendTo("body")
				.dialog({
					autoOpen: true,
					modal: true,
					resizable: false,
					draggable: false
				});
			jQuery("div#submissionAlert").parents(".ui-dialog:first").find(".ui-dialog-titlebar-close:first").hide();
		}
		else
		{
			jQuery("div#submissionAlert").html(msg);
			jQuery("div#submissionAlert").dialog("open");
		}
	}
};