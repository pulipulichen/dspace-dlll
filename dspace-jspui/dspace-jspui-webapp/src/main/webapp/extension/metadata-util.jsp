<%@ page contentType="application/x-javascript; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

function setFormDatePicker() {
	jQuery(document).ready(function () {
		var dates = jQuery(".input-type-date");
		for (var i = 0; i < dates.length; i++)
		{
			var d = dates.eq(i);
			if (d.find("input.input-type-date-data").length > 0)
				continue;
			var year = d.find(".input-type-date-year:first").val();
			if (year == "")
				year = "";
			else if (year.length == 3)
				year = "0" + year;
			var month = d.find(".input-type-date-month:first").val();
			if (month == "" || month == -1)
				month = "";
			else if (month.length < 2)
				month = "0"+month;
			var day = d.find(".input-type-date-day:first").val();
			if (day == "")
				day = "";
			else if (day.length < 2)
				day = "0"+day;
			
			
			var input = jQuery("<input type=\"text\" class=\"input-type-date-data\" value=\""+year + month + day+"\" /> ")
				.width(0)
				.css("visibility", "hidden")
				.change(function () {
					var year = this.value.substring(0, 4);
					if (year.substring(0, 1) == "0")
						year = year.substring(1, year.length);
					var month = this.value.substring(4, 6);
					if (month.substring(0, 1) == "0")
						month = month.substring(1, month.length);
					var day = this.value.substring(6, 8);
					if (day.substring(0, 1) == "0")
						day = day.substring(1, day.length);
					
					var d = jQuery(this).parents(".input-type-date:first");
					d.find(".input-type-date-year:first").val(year);
					d.find(".input-type-date-month:first").children("option").remove("selected");
					d.find(".input-type-date-month:first").children("option[value='"+month+"']").attr("selected", "selected");
					d.find(".input-type-date-month:first").val(month);
					d.find(".input-type-date-day:first").val(day);
				})
				.appendTo(d);
			
			jQuery(document).ready(function () {
				input.datepicker({dateFormat: 'yymmdd',showOn: 'button', buttonImage: '<%= request.getContextPath() %>/extension/input-type-date/cal.gif', buttonImageOnly: true});
			});
		}
	});
}

function setSaveButton()
{
	jQuery(document).ready(function()
	{	
		jQuery("tr.pageBanner:first").hide();
		
		jQuery("#edit_metadata_save").click(function () {
			if (jQuery("iframe#edit_metadata_save_iframe").length > 0)
				jQuery("iframe#edit_metadata_save_iframe").remove();
			
				jQuery("<iframe id=\"edit_metadata_save_iframe\" name=\"edit_metadata_save_iframe\"></firame>")
					.css("width", "0").css("height", "0")
					.appendTo(jQuery("body"));
				
					jQuery("iframe#edit_metadata_save_iframe").load(function () {
							var io = this;
							if(io.contentWindow)
								var html = io.contentWindow.document.XMLDocument?io.contentWindow.document.XMLDocument:io.contentWindow.document;
							else if(io.contentDocument)
								var html = io.contentDocument.document.XMLDocument?io.contentDocument.document.XMLDocument:io.contentDocument.document;
							
							if (typeof(html) == "undefined")
							{
								alert("讀取錯誤!");
								return;
							}
							
							var htmlObj = jQuery(html);
							if (htmlObj.find("form#loginForm:first").length > 0)
							{
								//.....開始建立登入的對話框
								jQuery("div#loginDialog").remove();
								var loginDialog = jQuery("<div id=\"loginDialog\" style=\"text-align:center\" title=\"登入\"><h3 class=\"msg\">系統處理中，請稍候。</h3></div>")
									.appendTo(jQuery("body"));
								
								var loginForm = jQuery("<iframe id=\"submitSaveLoginIframe\" src=\"<%= request.getContextPath() %>/mydspace\" width=\"95%\" height=\"95%\"></iframe>")
									.css("border-width", "0")
									.hide()
									.appendTo(loginDialog)
									.unload(function () {
										jQuery(this).hide();
										jQuery("div#loginDialog h3.msg").show();
									})
									.load(function () {
										var io = this;
										if(io.contentWindow)
											var html = io.contentWindow.document.XMLDocument?io.contentWindow.document.XMLDocument:io.contentWindow.document;
										else if(io.contentDocument)
											var html = io.contentDocument.document.XMLDocument?io.contentDocument.document.XMLDocument:io.contentDocument.document;
										
										if (typeof(html) == "undefined")
										{
											alert("讀取錯誤!");
											return;
										}
										
										var htmlObj = jQuery(html);
										
										if (htmlObj.find("form#loginForm:first").length > 0)
										{
											htmlObj.find("script").remove();
											htmlObj.find("body").wrapInner("<div style=\"display:none\"></div>");
											
											var form = jQuery("<div class=\"form\"></div>")
												.appendTo(htmlObj.find("body:first"));
											htmlObj.find("form#loginForm:first")
												.appendTo(form);
											
											htmlObj.find("p.newuser").hide();
											
											jQuery(html).ready(function () {
												jQuery(io).show();
												jQuery("div#loginDialog h3.msg").hide();
											});
										}
										else
										{
											jQuery("iframe#edit_metadata_save_iframe").remove();
											jQuery("div#loginDialog").remove();
											jQuery("#edit_metadata_save")
												.removeAttr("disabled")
												.click();
										}
									});
								
								loginDialog.dialog({
									bgiframe: true,
									autoOpen: true,
									height: 250,
									width: 350,
									modal: true,
									draggable: true,
									resizable: false
								});
							}	//if (htmlObj.find("form#loginForm:first").length > 0)
							else if (htmlObj.find("form#cancel_remove_form:first").length > 0)
							{
								var d = new Date();
								var msg = "(" + d.getHours() + ":" + d.getMinutes() + " 已儲存)";
								jQuery("span#edit_metadata_save_message:last").html(msg);
							}	//else if (htmlObj.find("form#cancel_remove_form:first").length > 0)
							jQuery("#edit_metadata_save").removeAttr("disabled");
							jQuery(this).remove();
					});	//jQuery("<iframe id=\"edit_metadata_save_iframe\" name=\"edit_metadata_save_iframe\"></firame>")
					
					var thisForm = jQuery(this).parents("form:first");
					
					thisForm.attr("target", "edit_metadata_save_iframe");
					/*
					thisForm.find("input.cancel:submit:first").click(function () {
						jQuery("iframe#edit_metadata_save_iframe").load(function () {
							var d = new Date();
							var msg = "(" + d.getHours() + ":" + d.getMinutes() + " 已儲存)";
							jQuery("span#edit_metadata_save_message:last").html(msg);
							jQuery("#edit_metadata_save").removeAttr("disabled");
							jQuery(this).remove();
						});
						jQuery(this).unbind("click");
					});
					*/
					
					if (XMLfunc.countChanged() == 0)
					{
						thisForm.find("input.cancel:submit:first").click();
						thisForm.removeAttr("target");
					}
					else
					{
						var thisBtn = this;
						jQuery(thisBtn).addClass("this-button-submit");
						XMLfunc.checkChanged(function () {
							
									jQuery(thisBtn).removeAttr("disabled")
										.removeClass("this-button-submit")
										.click();
						});
					}
				jQuery(this).attr("disabled", "disabled");
		});
		
		setInterval(function () {
			if (jQuery("div.ui-dialog:visible").length == 0)
				jQuery("#edit_metadata_save").click();
		}, 1000*60*10);
		//}, 1000);
	});

}

function setSubmissionController() {
	jQuery(document).ready(function () {
		var names = [
			"workspace_item_id",
			"bundle_id",
			"bitstream_id",
			"step",
			"page",
			"jsp"
		];
		
		for (var i = 0; i < names.length; i++)
			jQuery("input:hidden[name='"+names[i]+"']").attr("id", names[i]);
		//jQuery("input:hidden[name='']")
	});
}