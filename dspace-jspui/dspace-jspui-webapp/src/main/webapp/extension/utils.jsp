<%@ page contentType="application/javascript;charset=UTF-8" %>
jQuery.XMLMetadataDisplayTable();

jQuery(document).ready(function () {
	
	var div_prefs = '<p>\n<div_prefs id="div_prefs"></div_prefs>\n</p>';
	
	if (jQuery("textarea.general-fckeditor").length > 0)
	{
		var fcks = jQuery("textarea.general-fckeditor");
		
		for (var i = 0; i < fcks.length; i++)
		{
			var f = fcks.eq(i);
			
			var h = f.attr("rows");
			if (typeof(h) == "undefined" || h == "")
				h = 300;
			
			if (jQuery.browser.msie)
				h = (h * 20) + 'px';
			else
				h = h + "em";
			
			/*
			//發現會偵測不到em，所以改統一使用%
			var w = f.attr("cols");
			if (typeof(w) != "undefined" && w != -1 && w != "")
			{
				w = w + "em";
			}
			else
				w = "100%";
			*/
			w = "90%";
			
			f.fck({ path:'/jspui/extension/fckeditor/'
				, toolbar: "General"
				, height: h
				, width: w
				, config: {
					ToolbarStartExpanded: false
					}}
				);
			
			while (jQuery.trim(f.val().substring(f.val().length - div_prefs.length, f.val().length)) == div_prefs)
				f.val(jQuery.trim(f.val().substring(0, f.val().length - div_prefs.length)));
			
			while (jQuery.trim(f.val().substring(0, div_prefs.length)) == div_prefs)
				f.val(jQuery.trim(f.val().substring(div_prefs.length, f.val().length)));
		}
		
		/*
		//舊方法，沒辦法設定高度
		jQuery("textarea.general-fckeditor")
			.fck({ path:'/jspui/extension/fckeditor/'
				, toolbar: "General"
				, height: "150px"
				, width: "90%"
				, config: {
					ToolbarStartExpanded: false
					}}
				);
		*/
	}
});

function addCounter(type, id)
{
	if (navigator.cookieEnabled == false)
		return;
	
	jQuery(document).ready(function () {
		var url = "<%= request.getContextPath() %>/extension/counter.jsp?type="+type+"&id="+id;
		jQuery.get(url);
	});
}