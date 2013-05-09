<%@ page contentType="application/x-javascript; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
function doBackToItem(handle) {
	//確認網址是否有itemReturn=true
	//http://localhost:8080/jspui/tools/edit-item?tb=1&itemReturn=true
	//http://localhost:8080/jspui/tools/edit-item?itemReturn=true
	//http://localhost:8080/jspui/tools/edit-item?dfsgijsithkolp&itemReturn=true
	
	var href = location.href;
	//alert(href);

	if(href.indexOf("itemReturn=true") != -1 )
	{	
		
		var basePath = "<%= request.getContextPath() %>/handle/"+handle;
		
		if (href.indexOf("/edit-item?") != -1 && href.indexOf("itemReturn=true") != -1)
		{
			var itemParament = href.substring(href.indexOf("/edit-item?")+(("/edit-item?").length)
									, href.indexOf("itemReturn=true") - 1);
		
			if (itemParament != "" && itemParament != "?")
				var path = basePath + "?" + itemParament;
			else
				var path = basePath;
		}
		else
		{
			var path = basePath;
		}
			location.href = path;
		document.close();
	}
}

var editItemFormSync = function(fieldID, thisObj)
{
	if (jQuery(thisObj).hasClass("input-type-name"))
		var value = DescribeStep.readNames(thisObj);
	else if (jQuery(thisObj).hasClass("input-type-date"))
		var value = DescribeStep.readDate(thisObj);
	else if (jQuery(thisObj).hasClass("input-type-series"))
		var value = DescribeStep.readSeriesNumbers(thisObj);
	else if (jQuery(thisObj).hasClass("input-type-qualdrop_value"))
	{
		var result = DescribeStep.readQualdropValue(thisObj, fieldID);
		var fieldID = result.field;
		var value = result.value;
	}
	else if (jQuery(thisObj).hasClass("input-type-list"))
	{
		DescribeStep.setList(thisObj, fieldID);
		return;
	}
	else if (jQuery(thisObj).hasClass("input-type-dropdown"))
	{
		DescribeStep.setDropdown(thisObj, fieldID);
		return;
	}
	else
		var value = thisObj.value;
	
	var field = jQuery("div#progressbar_div_metadata textarea[name='"+fieldID+"']:first");
	if (field.length > 0)
	{
		field.val(value);
	}
	else
	{
		if (jQuery.trim(value) == "")
			return;
		
		DescribeStep.addMetadata(fieldID, value);
		//editItemAdd(fieldID, value);
	}
};

var DescribeStep = {
	"getField": function (container, selector) {
		var input = container.find(selector+":first");
		
		if (input.length == 1)
			return jQuery.trim(input.val());
		else
			return "";
	},
	"readNames": function (thisObj) {
		var container = jQuery(thisObj).parents("tr:first");
		var l = jQuery.trim(container.find("input.input-type-name-last:first").val());
		var f = jQuery.trim(container.find("input.input-type-name-first:first").val());
		
		if (l == "")
			return "";
		
		var comma = l.indexOf(',');
		
		if (comma != -1)
        {
            f = f + jQuery.trim(l.substring(comma + 1));
            l = jQuery.trim(l.substring(0, comma));
        }
        
        var name = l;
        if (f != "")
        	name = name + ", " + f;
        
        return name;
	},
	"readDate": function (thisObj) {
		var container = jQuery(thisObj).parents("tr:first");
		
		var year = DescribeStep.getField(container, ".input-type-date-year");
		var month = DescribeStep.getField(container, ".input-type-date-month");
		var day = DescribeStep.getField(container, ".input-type-date-day");
		
		alert([year, month, day]);
		
		//範例：2008-08-08T04:32:49Z
		var date = year;
		if (month != "")
			date = date + "-" + month;
		if (day != "")
			date = date + "-" + day;
		
		date = date + "T00:00:00Z";
		
		return date;
	},
	"readSeriesNumbers": function (thisObj) {
		var container = jQuery(thisObj).parents("tr:first");
		
		var s = DescribeStep.getField(container, ".input-type-series-series");
		var n = DescribeStep.getField(container, ".input-type-series-number");
		
		if (s == "")
			return "";
		else if (n == "")
			return s;
		else
			return s+";"+n;
	},
	"readQualdropValue": function (thisObj, field) {
		var container = jQuery(thisObj).parents("tr:first");
		
		var oldField = field;
		
		var q = DescribeStep.getField(container, ".input-type-qualdrop_value-qualifier");
		var v = DescribeStep.getField(container, ".input-type-qualdrop_value-value");
		if (q != "")
		{
			var fieldAry = field.split("_");
			var header = fieldAry[0] + "_"
				+ fieldAry[1] + "_"
				+ fieldAry[2] + "_";
			var footer = field.substring(field.lastIndexOf("_"), field.length);
			
			var newField = header + q + footer;
		}
		else
			var newField = field;
				
		var result = {
			"field": newField,
			"value": v
		};
			
		//刪除舊版的……
		jQuery("#progressbar_div_metadata table:first tbody tr:has(td textarea[name='"+oldField+"'])").remove();
		
		var inputs = container.find(".input-type-qualdrop_value");
		inputs
			.removeAttr("onchange")
			.unbind("change")
			.change(function () {
				editItemFormSync(newField, this);
			});
		
		//alert([oldField, newField, v, header, footer]);
		
		return result;
	},
	"setDropdown": function (thisObj, fieldID) {
		var selected = jQuery(thisObj).children("option:selected");
		var metadataForm = jQuery("form#editMetadataForm");
		
		var fieldHeader = fieldID.substring(0, fieldID.lastIndexOf("_") + 1);
		
		
		for (var i = 0; i < selected.length; i++)
		{
			var value = selected.eq(i).attr("value");
			
			if (i < 10)
				var field = fieldHeader + "0" + i;
			else
				var field = fieldHeader + i;
			
			if (metadataForm.find("[name=\'"+field+"\']").length > 0)
				metadataForm.find("[name=\'"+field+"\']").val(value);
			else
			{
				DescribeStep.addMetadata(field, value);
				/*
				var textarea = jQuery("<textarea name=\""+field+"\"></textarea>")
					.val(value);
					//.hide()
				metadataForm.find("#progressbar_div_metadata").append(textarea);
				*/
			}
		}
	},
	"setList": function (thisObj, fieldID) {
		var checked = jQuery(thisObj).parents("tr:first").find("input.input-type-list:checked");
		var metadataForm = jQuery("form#editMetadataForm");
		
		var fieldHeader = fieldID.substring(0, fieldID.lastIndexOf("_") + 1);
		
		for (var i = 0; i < checked.length; i++)
		{
			var value = checked.eq(i).attr("value");
			
			if (i < 10)
				var field = fieldHeader + "0" + i;
			else
				var field = fieldHeader + i;
			
			if (metadataForm.find("[name=\'"+field+"\']").length > 0)
				metadataForm.find("[name=\'"+field+"\']").val(value);
			else
			{
				DescribeStep.addMetadata(field, value);
				/*
				var textarea = jQuery("<textarea name=\""+field+"\"></textarea>")
					.val(value);
				metadataForm.find("#progressbar_div_metadata").append(textarea);
				*/
			}
		}
	}, 
	"addMetadata": function (name, value) {
		var dc = name.replace("value_", "_");
		
		var dcs = dc.split("_");
		var schema = dcs[1];
		var element = dcs[2];
		var qualifier = "";
		if (dcs.length == 5)
			qualifier = dcs[3];
		
		var tr = jQuery('<tr><td headers="t0" class="evenRowOddCol">'+schema+'</td>'
			+ '<td headers="t1" class="evenRowEvenCol">'+element+'&nbsp;&nbsp;</td>'
			+ '<td headers="t2" class="evenRowOddCol">'+qualifier+'</td>'
			+ '<td headers="t3" class="evenRowEvenCol">'
			+ '<textarea name="value'+dc+'" rows="3" cols="50"></textarea>'
			+ '</td>'
            + '<td headers="t4" class="evenRowOddCol">'
            + '<input name="language'+dc+'" value="en" size="5" type="text">'
            + '</td>'
            + '<td headers="t5" class="evenRowEvenCol">'
            + '<input name="submit_remove'+dc+'" value="<%= LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.general.remove") %>" type="submit">'
		    + '</td>'
            + '</tr>');
        
        tr.find("textarea:first").val(value);
        
        jQuery("#progressbar_div_metadata table:first tbody tr:last").prev().before(tr);

	}
};

var editItemSubmit = function (addID) {
	//變更一下action網址吧
	var action = jQuery("form.edit-metadata[method='post']").attr('action');
	var fieldAry = addID.split(".");
	action = action 
			+ "&fieldSchema=" + fieldAry[0]
			+ "&fieldElement=" + fieldAry[1];
	if (fieldAry.length > 2)
	{
		action = action + "&fieldQualifier=" + fieldAry[2];
	}
	
	if (location.href.indexOf("input-type=item") != -1)
		action = action + "&input-type=item";
	
	jQuery("form.edit-metadata[method='post']").attr('action', action);
	
	if (jQuery("form#editMetadataForm:first input[name='item_id']").length == 0)
	{
		var itemID = jQuery("input[name='item_id']:hidden:first").clone();
		jQuery("div#progressbar_div_metadata input[name='submit_addfield']").after(itemID);
	}
	
	var btnSubmit = jQuery("<input type=\"submit\" name=\"submit\" value=\"\" />")
		.appendTo(jQuery("#progressbar_div_metadata"))
		.click();
};

function editItemRemove(removeID)
{
	if (window.confirm("確定要移除？") == false)
		return;
	
	//記得要修改form的action喔
	var action = jQuery("form.edit-metadata[method='post']").attr('action');
	var fieldAry = removeID.split("_");
	action = action 
			+ "&fieldSchema=" + fieldAry[2]
			+ "&fieldElement=" + fieldAry[3];
	if (fieldAry.length > 4)
	{
		action = action + "&fieldQualifier=" + fieldAry[4]
	}
	jQuery("form.edit-metadata[method='post']").attr('action', action);
	
	var button = jQuery("div#progressbar_div_metadata input[name='"+removeID+"']:first");
	button.click();
}


function editItemAdd(addID, value)
{
	//記得要修改form的action喔
	var action = jQuery("form.edit-metadata[method='post']").attr('action');
	var fieldAry = addID.split(".");
	action = action 
			+ "&fieldSchema=" + fieldAry[0]
			+ "&fieldElement=" + fieldAry[1];
	if (fieldAry.length > 2)
	{
		action = action + "&fieldQualifier=" + fieldAry[2];
	}
	
	if (location.href.indexOf("input-type=item") != -1)
		action = action + "&input-type=item";
	
	jQuery("form.edit-metadata[method='post']").attr('action', action);
	
	jQuery("div#progressbar_div_metadata select[name='addfield_dctype']").find("option").removeAttr("selected");
	jQuery("div#progressbar_div_metadata select[name='addfield_dctype']").find("option:contains('"+addID+"')").attr("selected", "true");
	if (typeof(value) != "undefined")
	{
		jQuery("div#progressbar_div_metadata textarea[name='addfield_value']").val(value);
	}
	
	//幫他移動一下itemID
	if (jQuery("form#editMetadataForm:first input[name='item_id']").length == 0)
	{
		var itemID = jQuery("input[name='item_id']:hidden:first").clone();
		jQuery("div#progressbar_div_metadata input[name='submit_addfield']").after(itemID);
	}
	setTimeout(function () {
		var buttonAdd = jQuery("div#progressbar_div_metadata input[name='submit_addfield']")
			.click();		
	}, 100);
    
}

function locationSearch ()
{	
	
	var getvar = location.search;
	
	if (getvar.indexOf("?"))
			getvar = getvar.substring(1, getvar.length);
	
	var varAry = getvar.split("&");	
	var fieldSchema;
	var fieldElement;
	var fieldQualifier;
	for (var i = 0; i < varAry.length; i++)
	{
		var temp = varAry[i].split("=", 2);
		var fieldName = temp[0];
		var fieldValue = temp[1];
		
		if (fieldName == "fieldSchema")
			fieldSchema = fieldValue;
		else if (fieldName == "fieldElement")
			fieldElement = fieldValue;
		else if (fieldName == "fieldQualifier")
			fieldQualifier = fieldValue;
	}
	
	if (typeof(fieldSchema) == "undefined" || typeof(fieldElement) == "undefined")
		return;
	
	var name = fieldSchema + "_" + fieldElement;
	if (typeof(fieldQualifier) != "undefined")
		name = name + "_" + fieldQualifier;

	//alert([name, jQuery("[name='"+name+"']:eq(0)").length]);
	
	setTimeout(function () {
		
		if (jQuery("[name^='"+name+"']:eq(0)").length == 0)
		{
			name = name.substring(0, name.lastIndexOf("_") + 1);
			if (jQuery("[name^='"+name+"']:eq(0)").length == 0)
				alert("找不到"+name)
		}
		
		var input = jQuery("[name='"+name+"']:eq(0)");
		if (input.length == 0)
			input = jQuery("[name^='"+name+"']:eq(0)");
		
		var divID = input.parents("div.submitProgressDiv:first").attr("id");
		
		if (typeof(divID) != "undefined")
			var id = divID.replace("progressbar_div_", "");
		else
			var id = "progressbar_div_0_0";
		
		var selectCollection = jQuery("select#collection_select");
		var select_id = id.substring(0, id.indexOf("_"));
		selectCollection.val("collection_id_"+select_id).click();
			
		//document.getElementById(buttonID).click();
		
		//var td = document.getElementsByName(name)[0].parentNode
		var td = input.attr("parentNode");
		setTimeout(function () {
			var buttonID = "progressbar_button_" + id;
			jQuery("input[id='"+buttonID+"']").click();
			setTimeout(function() {
				td.scrollIntoView(true);
				jQuery(td).prevAll("td.submitFormLabel:first").css("color", "red");
			});
		}, 100);
	}, 100);
		
	
}

jQuery(document).ready(function () {
	locationSearch();
});


function checkBackToItem(btn) {
	
	var href = location.href;
	
	if (!(href.indexOf("?") == -1 && href.indexOf("handle") == -1))
	{
		if (href.indexOf("?handle") != -1 )
			var itemParament = "";
		else if (href.indexOf("&handle") != -1 )
		{
			var itemParament = href.substring(href.indexOf("/edit-item?")+(("/edit-item?").length)
									, href.indexOf("&handle"));
		}//判斷有沒有?tb=1,2,3....
		else
			var itemParament = "";
		
		var action = jQuery("form.edit-metadata[method='post']").attr('action');
		//alert(itemParament);
		if (itemParament == ""
			|| itemParament.substring(0, ("action=").length) == "action=")
			action = action + "&itemReturn=true";
		else
			action = action + "&" + itemParament + "&itemReturn=true";
		
		jQuery("form.edit-metadata[method='post']").attr('action', action);
			
	}
	else
	{
		var action = jQuery("form.edit-metadata[method='post']").attr('action');
		action = action + "&itemReturn=true";
		jQuery("form.edit-metadata[method='post']").attr('action', action);
	}
	
	setTimeout(function () {
		btn.disabled = "disabled";
	}, 100);
}

function collectionSelect(collectionID)
{
	var id = "#" + collectionID;
	
	if (jQuery("div.collection-root" + id).css("display") != "none")
		return;
	
	jQuery("div.collection-root").hide();
	jQuery("div.collection-root" + id).show();
	
	var jsObj = jQuery("div.collection-root" + id).find("textarea.progress-init-javascript");
	if (jsObj.length > 0)
	{
		var js = "";
		for (var i = 0; i < jsObj.length; i++)
		{
			js = js + jsObj.eq(i).val() + "\n";
			jsObj.eq(i).remove();
		}
		//alert(js);
		eval(js);
	}
}

jQuery.getScript("<%= request.getContextPath() %>/extension/input-type-item/jquery-plugin-inputTypeItem-edit-item-form.js");