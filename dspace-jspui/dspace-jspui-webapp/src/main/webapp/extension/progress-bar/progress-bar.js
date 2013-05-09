function progressBar(rootID, pages) {
	var pbObj = new Object;
	
	pbObj.selectCollection = function(thisObj) {
		var collectionDiv = jQuery(thisObj).parents("div.collection-root:first");
		var collectionDivID = collectionDiv.attr("id");
		
		jQuery("div.collection-root:not(#"+collectionDivID+")").hide();
		jQuery("div.collection-root#"+collectionDivID).hide();
		
		jQuery("select#collection-select").val(collectionDivID);
		jQuery("select#collection-select").find("option").removeAttr("selected");
		jQuery("select#collection-select").find("option[value='"+collectionDivID+"']:first").attr("selected", "true");
		jQuery("select#collection-select").change();
	};
	
	pbObj.init = function () {
		
		var visible = 7;
		var navigationBar = jQuery("td.navigationBar");
		if (navigationBar.length > 0 && navigationBar.css("display") != "none")
			visible = 8;
		
		if (typeof(root) != "undefined")
		{
			root = root + " ";
		}
		else
		{
			root = "";
		}
		
		var getPageBtnGo = function(pages) {
			var output = new Array();
			for (var i = 0; i < pages; i++)
			{
				var id = parseInt(i + (parseInt(visible) / 2));
				output.push(".progressBar-"+rootID+" .submitProgressButton:eq("+id+")");
			}
			return output;
		};
		jQuery(".progressBar-"+rootID).jCarouselLite({
			btnNext: ".next-"+rootID,
			btnPrev: ".prev-"+rootID,
			visible: visible,
			circular: false,
			scroll: 1,
			btnGo: getPageBtnGo(pages), 
			speed: 800,
			easing: "backout"
		});
		
		var liNum = jQuery(".progressBar-"+rootID).find("ul li").length;
		if (liNum > visible)
		{
			jQuery("div#collection_id_"+rootID + " th.next-th").show();
			jQuery("div#collection_id_"+rootID + " th.prev-th").show();
		}

		jQuery(".progressBarContainer-"+rootID).css("position", "static")
				.css("top", "0")
				.css("visibility", "visible");
		
		jQuery(".progressBar-"+rootID+" input.submitProgressButton").click(function () {
			if (jQuery(this).hasClass("submitProgressButtonCurrent"))
			{
				return;
			}
			var rootNode = jQuery(this).parents("div.collection-root:first");
			
			rootNode.find("input.submitProgressButton.submitProgressButtonCurrent")
				.removeClass("submitProgressButtonCurrent")
				.addClass("submitProgressButtonDone");
			jQuery(this).removeClass("submitProgressButtonDone")
				.addClass("submitProgressButtonCurrent");
			
			rootNode.find("div.submitProgressDiv").hide();
				jQuery("div#progressbar_div_metadata, div#progressbar_div_bitstream").hide();
				
			var id = this.id.replace("progressbar_button_", "");
			
			if (id.indexOf("metadata") != -1)
			{
				id = "metadata";
				var divID = "progressbar_div_" + id;
				var div = jQuery("div.submitProgressDiv#"+divID);
			}
			else if (id.indexOf("bitstream") != -1)
			{
				id = "bitstream";
				var divID = "progressbar_div_" + id;
				var div = jQuery("div.submitProgressDiv#"+divID);
			}
			else
			{
				var divID = "progressbar_div_" + id;
				var div = rootNode.find("div.submitProgressDiv#"+divID);
			}
			
			if (div.find("textarea.javascript").length > 0)
			{
				var js = div.find("textarea.javascript");
				var script = "";
				for (var i = 0; i < js.length; i++)
				{
					script = script + js.eq(i).val() + "\n\n";
					js.eq(i).remove();
				}
					
				setTimeout( function () {
					var f1 = "</sc";
					var f2 = "ript>";
					div.append(jQuery("<script type=\"text/javascript\">\n"+script+"\n\n"+f1+f2));
				}, 0);
			}
			div.show();
			
			window.scrollTo(0, 0);
		});
	};
	
	pbObj.init();
	return pbObj;
}

function setSubmitProgressSwitchButton()
{
		jQuery("button.submitProgressNext:not(.has-set)").click(function () {
			var rootNode = jQuery("div.collection-root:visible:first");
			var nowButton = rootNode.find("input.submitProgressButton.submitProgressButtonCurrent:first");
			var nextButton = nowButton.parents("li:first")
				.nextAll("li:first")
				.children("input:first");
			if (nextButton.length != 0)
				nextButton.click();
		}).addClass("has-set");
		
		jQuery("button.submitProgressPrev:not(.has-set)").click(function () {
			var rootNode = jQuery("div.collection-root:visible:first");
			var nowButton = rootNode.find("input.submitProgressButton.submitProgressButtonCurrent:first");
			var prevButton = nowButton.parents("li:first")
				.prevAll("li:first")
				.children("input:first");
			if (prevButton.length != 0)
				prevButton.click();
		}).addClass("has-set");
}
jQuery(document).ready(function () { 
	setSubmitProgressSwitchButton()
});

var progressBarOfSubmit = function(handle) {
	
	if (location.href.indexOf("/submit") == -1)
		return;
	
	var visible = 8;
	var navigationBar = jQuery("td.navigationBar");
	if (navigationBar.length > 0 && navigationBar.css("display") != "none")
		visible = 7;

	var getPageBtnGo = function(pages) {
		var output = new Array();
		for (var i = 0; i < pages; i++)
		{
			var offset = parseInt(parseInt(visible) / 2);
			var id = parseInt(i + offset);


			var selector = ".submitProgressButton:eq("+id+")";
							
			if (i == 0)
			{
				for (var j = 0; j < id; j++)
					selector = selector + ", .submitProgressButton:eq("+j+")";
			}
			else if (i == pages - parseInt(visible))
			{
				for (var j = i + 1; j < pages; j++)
					selector = selector + ", .submitProgressButton:eq("+j+")";
			}
			else if (i > pages - parseInt(visible))
				selector = "";
			output.push(selector);
		}
		return output;
	};
	
	jQuery(document).ready(function () {
		jQuery('input.classHide').parents("li").remove();
		jQuery("#submitProgressTable").jCarouselLite({
			btnNext: ".next",
			btnPrev: ".prev",
			visible: visible,
			circular: false,
			scroll: 1,
			speed: 800,
			easing: "backout",
			btnGo: getPageBtnGo(jQuery(".progressBar .submitProgressButton").length)
		});
		jQuery("#submitProgressTable").removeClass("progress-bar-hide");
		//alert(jQuery("#submitProgressTable").hasClass("progress-bar-hide"));
		
		jQuery("div.progressBar .submitProgressButton.submitProgressButtonCurrent").click();
		jQuery("div.progressBar .submitProgressButton").unbind("click");		
		//alert(jQuery('input[name="submit_next"]:first').length);
		
		jQuery('input.submitNext').click();
		
		//jQuery('input[name="submit_jump_3.1"]').parents("li:first").hide();
		if(jQuery("input#submission_complete").length == 1)
			inputTypeItemComplete(handle);
	
		if (jQuery("#submitProgressTable ul li:not(.classHide)").length > visible)
		{
			jQuery(".prev-th").show();
			jQuery(".next-th").show();
		}
		
		jQuery("#submitProgressTable").css("position", "static").css("top", "0");	
	});
};