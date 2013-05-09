// XMLMetadata() for DSpace
// require jquery.js, flora.datepicker.css, ui.datepicker.js, 
//
function XMLMetadata(inputID)
{
	var oXML = this;
	oXML.debug = false;	//true || false
	oXML.debugFormToXML = false;	//true: do FormToXML || false: stop FormToXML;
	oXML.displayTable = false;	//true: display table || false: display form
	oXML.hiddenRootNode = false;
	oXML.displayTableHideEmpty = true;
	oXML.titleModeNode = "up";	//left | up
	oXML.titleModeInput = "left";	//left | up

	oXML.storageID = "";
	oXML.storage = null;
	oXML.workspaceItemID = "";
	oXML.fieldTitle = "";
	oXML.hasMultipleFiles = true;
	oXML.nonInternalBistreamsID = new Array;
	oXML.listID = 0;
	
	oXML.basePath = null;
	oXML.fckeditorPath = "/extension/fckeditor/";
	oXML.fckeditorStyle = "";
	oXML.setFCKeditorPath = function (path)
	{
		oXML.fckeditorPath = path;
		FCKeditorPath = path;
	}
	oXML.setFCKeditorStyle = function (style)
	{
		oXML.fckeditorStyle = style;
	}
	oXML.cssPath = "/extension/xmlmetadata/dspace-inputtype-xml.css";
	oXML.fileuploadPath = "/jspui/submit?action=json";
	
	// for Debug
	var t = function(msg)
	{
		if (oXML.debug == true)
		{	
			if (typeof(msg) != "undefined")
				alert("["+msg+"]");
			else
				alert("-=＝[no value]＝--");
		}
	}

	
	if (typeof(inputID) != "undefined")
	{
		oXML.storageID = inputID;
		if (typeof(inputID) == "string")
			oXML.storage = jQuery("#"+oXML.storageID);
		else if (typeof(inputID) == "object")
			oXML.storage = inputID;
		if (oXML.debug == true)
		{
			oXML.storage.css("width", "100%")
				.css("height", "30em")
			oXML.storage.before("<button type=\"button\" onclick=\"(new XMLMetadata()).buttonCreateForm('"+inputID+"')\">轉換成表單</button>");
		}
		if (typeof(oFCKeditorBasePath) == "undefined")
			oXML.oFCKeditorBasePath = "fckeditor/";
		else
			oXML.oFCKeditorBasePath = oFCKeditorBasePath;
	}
	//Language
	oXML.langCheckRequired = "您有表單尚未填寫完成，是否要繼續？";	//您有表單尚未填寫完成，是否要繼續？
	oXML.langFormRequiredFlag = "form-required-check";	//Required Check
	oXML.langDataPicker = "請點此選擇日期";	//請點此選擇日期
	oXML.langButtonRepeat = "重複";	//重複
	oXML.langButtonDel = "刪除";	//刪除
	oXML.langDelConfirm = "確定要刪除？";
	oXML.langRequireTip = "*：表示必須填寫";
	oXML.langNotHasMultipleFiles = "Please check \"文件由一個以上的 檔案所組成\"! ";
	oXML.langInputRequiredTip = "必須填寫";
	
	oXML.createRootForm = function() {
		var inputXML = oXML.storage.val();
		if (jQuery.trim(inputXML) == "") 
			return;
		var rootNode = jQuery(inputXML).children();
		//alert(jQuery(inputXML).contents().length);
		while (oXML.hiddenRootNode && rootNode.length == 1)
		{
			if (rootNode.children("div.node-contents").length > 0)
				rootNode = rootNode.children("div.node-contents:last").children();
			else if (rootNode.children("div.node-content-temp").length == 1)
				rootNode = rootNode.children("div.node-content-temp:first").children();
			else
				break;
		}
		
		if (oXML.debug == false)
			oXML.storage.hide();
		var xmlRoot = jQuery("<div></div>").addClass("xml-root");
		for (var i = 0; i < rootNode.length; i++)
		{
			if (jQuery.trim(rootNode.eq(i).html()) == "") continue;
			xmlRoot.append(oXML.createNode(rootNode.eq(i)));
		}
		if (oXML.displayTable == false)
			xmlRoot.prepend("<span class=\"require-tip\">"+oXML.langRequireTip+"</span>");
		oXML.storage.after(xmlRoot);
		
		
		for (var i = 0; i < jQuery(".embedFCKeditor-"+inputID).length; i++)
		{
			var eID = "embedFCKeditor-"+inputID+"[" + i + "]";
			jQuery("textarea.embedFCKeditor-"+inputID+":eq("+i+")").attr("id", eID);
			oFCKeditor = new FCKeditor( eID ) ;
			oFCKeditor.BasePath	= oXML.oFCKeditorBasePath ;
			oFCKeditor.Config['ToolbarStartExpanded'] = false ;
			if (oXML.fckeditorStyle != "")
				oFCKeditor.Config["EditorAreaStyles"]	= oXML.fckeditorStyle;
			oFCKeditor.ReplaceTextarea() ;
		}
	};
	
	oXML.displayRootTable = function(targetObj) {
		oXML.displayTable = true;
		var rootNode = oXML.storage.find("div.xml-root:first").contents();
		while (oXML.hiddenRootNode && rootNode.length == 1)
		{
			if (rootNode.children("div.node-contents").length > 0)
				rootNode = rootNode.children("div.node-contents:last").children();
			else if (rootNode.children("div.node-content-temp").length == 1)
				rootNode = rootNode.children("div.node-content-temp:first").children();
			else
				break;
		}
		
		var xmlRoot = jQuery("<div></div>").addClass("xml-root");

		for (var i = 0; i < rootNode.length; i++)
		{
			if (jQuery.trim(rootNode.eq(i).html()) == "") continue;
			xmlRoot.append(oXML.createNode(rootNode.eq(i)));
		}
		targetObj.contents().hide();
		targetObj.append(xmlRoot);
	};
	
	oXML.createNode = function(inputObj) {
		if (oXML.debug == true)
			var outputObj = jQuery("<table border=\"1\"></table>");
		else
			var outputObj = jQuery("<table></table>");	
		outputObj.attr("width", "100%");
		
		//Get & initialize Attribute
			//save attribute in cpation
			var attrCaption = jQuery("<caption></caption>");
		
		var type = inputObj.children(".node-type:first").text();
			if (type == "") type = "node";
			attrCaption.append("<input type=\"hidden\" title=\"node-type\" value=\""+type+"\" />");
			if (type == "input")
			{
				outputObj.attr("width", "");
				outputObj.addClass("table-input");
			}
			else if (type == "node")
				outputObj.addClass("table-node");
		var attrTitle = inputObj.children(".node-title:first").html();
			//if (attrTitle == "") attrTitle = "";
			attrCaption.append("<input type=\"hidden\" title=\"node-title\" value=\""+attrTitle+"\" />");
		var attrRepeatable = inputObj.children(".node-repeatable:first").text();
			if (oXML.debug == true)
				if (attrRepeatable == "") attrRepeatable = "true";	//attrRepeatable = "false";
			else
				if (attrRepeatable == "") attrRepeatable = "false";	//attrRepeatable = "false";
			attrCaption.append("<input type=\"hidden\" title=\"node-repeatable\" value=\""+attrRepeatable+"\" />");
		var attrID = inputObj.children(".node-id:first").text();
			if (attrID != "")	outputObj.attr("id", attrID);
		var attrClass = inputObj.children(".node-class:first").text();
			if (attrClass != "")	outputObj.attr("class", attrClass);
		
		if (type == "node")
		{
			var contentTemp = inputObj.children(".node-content-temp:first");
			var contents = inputObj.children(".node-contents");
			
			//if no contentTemp, clone last contents to contentTemp
			if (contentTemp.length == 0)
				var contentTemp = inputObj.children(".node-contents:last").clone();
			//if no contents, clone contenpTemp to contents
			if (contents.length == 0)
				var contents = contentTemp.clone();
		}
		else if (type == "input")
		{
			var defaultValue = inputObj.children(".input-default-value:first");
			var values = inputObj.children(".input-values");
			//if no defaultValue, clone last values to defaultValue
			if (defaultValue.length == 0)
				var defaultValue = inputObj.children(".input-values:last").clone();
			//if no values, clone defaultValue to values
			if (values.length == 0)
				var values = defaultValue.clone();
			
			var attrRequired = inputObj.children(".input-required:first").text();
				if (attrRequired == "") attrRequired = "false";
				attrCaption.append("<input type=\"hidden\" title=\"input-required\" value=\""+attrRequired+"\" />");
				if (attrRequired == "true" && oXML.displayTable == false)
					attrTitle = attrTitle + "<span class=\"input-required-tip\" title=\""+oXML.langInputRequiredTip+"\">*</span>";
			var attrInputType = inputObj.children(".input-type:first").text(); 
				if (attrInputType == "") attrInputType = "onebox";
				attrCaption.append("<input type=\"hidden\" title=\"input-type\" value=\""+attrInputType+"\" />");
				if (attrInputType == "fileupload") defaultValue.html("");
			var inputOptions = inputObj.children("select.input-options:first");
				//values
				for (var i = values.length - 1; i > -1; i--)
				{
					var valueHTML = values.filter(":eq("+i+")").html();
					if (inputOptions.children("option[value="+valueHTML+"]").length == 0)
						inputOptions.prepend("<option value=\""+valueHTML+"\">"+valueHTML+"</option>");	
				}
				//default value option
					if (inputOptions.children("option[value="+defaultValue.html()+"]").length == 0)
						inputOptions.prepend("<option value=\""+defaultValue.html()+"\">"+defaultValue.html()+"</option>");
				attrCaption.append(inputOptions.clone().hide());
				
		}
		outputObj.append(attrCaption);
		
		//create thTitleTemp
		if (oXML.debug == true)
			var thTitleTemp = jQuery("<th onclick=\"(new XMLNodeFn()).showNode(this)\"></th>");
		else
			var thTitleTemp = jQuery("<th></th>");

		if ((type == "node" && oXML.titleModeNode == "left") || (type == "input" && oXML.titleModeInput == "left"))
		{
			thTitleTemp.html(attrTitle).addClass("title-has-value");
			if (type == "input") 
				thTitleTemp.append(": ");
			if (type == "input" && oXML.displayTable == false) 
				thTitleTemp.append("<div class=\"width-extension-title\"></div>");
		}
		else if ((type == "node" && oXML.titleModeNode == "up") || (type == "input" && oXML.titleModeInput == "up"))
		{
			thTitleTemp.addClass("title-no-value");
			attrCaption.append("<span class=\"caption-title\">"+attrTitle+"</span>");
		}
		
		if (type == "node")
			thTitleTemp.attr("title", attrTitle);
		
		//initialize tbody
		var tbodyObj = jQuery("<tbody></tbody>");
		
		if (type == "node")
		{
			//Let's create contentTemp!
				tbodyObj.append(oXML.createNodeTR(contentTemp, type, "true", attrRepeatable, thTitleTemp));

			//Let's create contents
			for (var c1 = 0; c1 < contents.length; c1++)
				tbodyObj.append(oXML.createNodeTR(contents.filter(":eq("+c1+")"), type, "false", attrRepeatable, thTitleTemp));
		}
		else if (type == "input")
		{
			//Let's create defalutValue
				tbodyObj.append(oXML.createNodeTR(defaultValue, type, "true", attrRepeatable, thTitleTemp, attrInputType, inputOptions, attrRequired));
				
			//Let's create values
			for (var c1 = 0; c1 < values.length; c1++)
			{
				var inputObj = values.filter(":eq("+c1+")");
				
				if (oXML.displayTable == true && oXML.displayTableHideEmpty && jQuery.trim(inputObj.html()) == "")
					continue;
				
				//is file in 
				if (oXML.displayTable == "false" && attrInputType == "fileupload" && jQuery.trim(inputObj.html()) != "")
				{
					if (oXML.nonInternalBistreamsID.length > 0)
					{
						var temp = jQuery.trim(inputObj.html()).split("/");
						var bitstreamID = temp[(temp.length-2)];
						if (!jQuery.inArray(bitstreamID, oXML.nonInternalBistreamsID))
							inputObj.html("");
					} else
						inputObj.html("");
				}

				tbodyObj.append(oXML.createNodeTR(inputObj, type, "false", attrRepeatable, thTitleTemp, attrInputType, inputOptions, attrRequired));
			}
		}
		
		
		if (attrInputType == "list" && oXML.displayTable == false)
		{
			var listTr = jQuery("<tr></tr>");
			
			var thTitle = thTitleTemp.clone().show().addClass("input-title");
			listTr.append(thTitle);
			
			var tdContents = jQuery("<td></td>").addClass("input-contents");
			
			//alert([oXML.listID, inputOptions.children(":eq(0)").html(), inputOptions.children(":eq(0)").attr("value")]);
			
			for (var oi = 0; oi < inputOptions.children().length; oi++)
			{
				var listName = "list["+oXML.listID+"]";
				var listID = listName + "["+oi+"]";
				var listTitle = inputOptions.children(":eq("+oi+")").html();
				var listValue = inputOptions.children(":eq("+oi+")").attr("value");
				
				var compareValue = (jQuery.trim(inputObj.html()) == listValue);
				if (compareValue == true) var checked = "checked=\"true\"";
				else var checked = "";
				//alert([compareValue, jQuery.trim(inputObj.html()), listValue, attrRepeatable]);
				
				if (attrRepeatable == "true") var listType = "checkbox";
				else var listType = "radio";
				
				var listOption = jQuery("<input type=\""+listType+"\" class=\"input-list\" onclick=\"(new XMLNodeFn()).switchList(this, this.value);\" name=\""+listName+"\" value=\""+listValue+"\" style=\"width:1em\" id=\""+listID+"\" "+checked+" />");
				
				if (jQuery.trim(inputObj.html()) == listValue && attrRepeatable == "true")
					listOption.attr("checked", true);
				else if (jQuery.trim(inputObj.html()) == listValue && attrRepeatable == "false")
					listOption.attr("checked", "checked");
					
				
				var listLabel = jQuery("<label></label>");
				listLabel.html(listTitle);
				listLabel.attr("for", listID);
				
				var listSpan = jQuery("<span></span>");
				listSpan.append(listOption);
				listSpan.append(listLabel);
				
				tdContents.append(listSpan);
			}
			
			if (attrRepeatable == true)
				tdContents.attr("colspan", 2)
			
			listTr.append(tdContents);
			
			oXML.listID++;
			tbodyObj.children().hide();
			tbodyObj.append(listTr);
			
		}	//if (attrInputType == "list")
		
		
		tbodyObj.children("tr:last").children("td").css("border-bottom-width", 0);
		//End of tbody
		
		(new XMLNodeFn()).buttonAdjust(tbodyObj, type, attrInputType);
		outputObj.append(tbodyObj);
		return outputObj;
	};
	
	oXML.createNodeTR = function (node, type, isTemp, attrRepeatable, thTitleTemp, attrInputType, inputOptions, attrRequired)
	{
		if (type == "node")
		{
			var trClassName = "node";
			var className = "node";
		}
		else if (type == "input")
		{
			var trClassName = "input";
			var className = "input";
		}
		if (isTemp == "true") trClassName = trClassName + "-temp";
		
		var trObj = jQuery("<TR></TR>").addClass(trClassName);	

			var thTitle = thTitleTemp.clone();
			thTitle.addClass(className + "-title");
			trObj.append(thTitle);
			
			var tdContents = jQuery("<td></td>").addClass(className + "-contents");
			if (thTitle.hasClass("title-no-value")) tdContents.addClass("td-no-title");
			
			if (type == "node")
			{
				for (var i = 0; i < node.children().length; i++)
				{
					var childObj = node.children(":eq("+i+")"); //.contents();
					tdContents.append(oXML.createNode(childObj));
				}
			}
			else if (type == "input")
			{
				tdContents.append(oXML.createInputForm(node, attrInputType, inputOptions, attrRequired));
			}
			trObj.append(tdContents);
			
			if (oXML.displayTable == false)
			{
				var tdFunction = jQuery("<td></td>").addClass(className + "-function");
				if (attrRepeatable == "true")
				{
					if (attrInputType != "fileupload")
						var buttonDel = jQuery("<button type=\"button\" onclick=\"(new XMLNodeFn()).deleteNode(this)\"></button>")
							.addClass("buttonDel").html(oXML.langButtonDel);
					else
						var buttonDel = jQuery("<button type=\"button\" onclick=\"ajaxFileUploadRemoveXML(this, "+oXML.workspaceItemID+")\"></button>")
							.addClass("buttonDel").html(oXML.langButtonDel);
					
					tdFunction.append(buttonDel);

					var buttonRepeat = jQuery("<button type=\"button\" onclick=\"(new XMLNodeFn()).repeatAction(this)\"></button>")
						.addClass("buttonRepeat").html(oXML.langButtonRepeat);
					tdFunction.append(buttonRepeat);
					
					if (jQuery.trim(thTitle.attr("title")) != "")
					{
						tdFunction.append("<div class='node-function-title'>" + jQuery.trim(thTitle.attr("title")) + "</div>");
					}
				}
				else if (attrInputType == "fileupload" && jQuery.trim(node.html()) != "")
				{
						var buttonDel = jQuery("<button type=\"button\" onclick=\"ajaxFileUploadCancelXML(this, "+oXML.workspaceItemID+")\"></button>")
							.addClass("buttonDel").html(oXML.langButtonDel);
						tdFunction.append(buttonDel);
				}
				
				if (oXML.displayTable == false)
				{
					var widthDIV = jQuery("<div class='width-extension-function'></div>");
					tdFunction.append(widthDIV);
				}
				
				trObj.append(tdFunction);
			}
		
		return trObj;
	}
	
	oXML.createInputForm = function(value, attrInputType, inputOptions, attrRequired)
	{
		var outputObj;
		
		if (oXML.displayTable == false)
		{
			//alert(attrInputType);
			switch(attrInputType)
			{
				case "onebox":
				case "list":
					outputObj = jQuery("<input type=\"text\" onchange=\"(new XMLNodeFn()).formChange(this, '"+inputID+"')\" value=\""+value.html()+"\" />");
					outputObj.change(function () {
						var o = new XMLMetadata(oXML.storageID);
						o.formToXML(true);
					});
					break;
				case "dropdown":
					outputObj = jQuery("<select onchange=\"(new XMLNodeFn()).formChange(this, '"+inputID+"')\"></select>")
						.append(inputOptions.html());
					outputObj.children("option").remove("selected");
					outputObj.children("option[value="+value.html()+"]").attr("selected", "true");
					outputObj.change(function () {
						var o = new XMLMetadata(oXML.storageID);
						o.formToXML(true);
					});
					break;
				case "texteditor":
					if (typeof(xmlmetadataFCKeditorCounter) == "undefined")
						xmlmetadataFCKeditorCounter = 0;
					outputObj = jQuery("<textarea class=\"embedFCKeditor-"+inputID+" embedFCKeditor\" onchange=\"(new XMLNodeFn()).formChange(this, '"+inputID+"', true); \" name=\"embedFCKeditor-"+xmlmetadataFCKeditorCounter+"\" >"+value.html()+"</textarea>").css("width", "100%");
					outputObj.load(function () {
						var oFCKeditor = new FCKeditor( this.name ) ;
						oFCKeditor.BasePath	= FCKeditorPath;
						oFCKeditor.Config["ToolbarStartExpanded"] = false;
						if (oXML.fckeditorStyle != "")
							oFCKeditor.Config["EditorAreaStyles"]	= oXML.fckeditorStyle;
						oFCKeditor.ReplaceTextarea()  ;
					});
					outputObj.change(function () {
						var o = new XMLMetadata(oXML.storageID);
						o.formToXML(true);
					});
					xmlmetadataFCKeditorCounter++;
					break;
				case "date":
					outputObj = jQuery("<input type=\"text\" value=\""+oXML.langDataPicker+"\" onfocus=\"(new XMLNodeFn()).datePicker(this)\" onchange=\"(new XMLNodeFn()).formChange(this, '"+inputID+"')\" />").css("cursor", "pointer");
					//.datepicker();
					outputObj.change(function () {
						var o = new XMLMetadata(oXML.storageID);
						o.formToXML(true);
					});
					break;
				case "fileupload":
					var v = jQuery.trim(value.html());
					if (v.indexOf("/retrieve/") == -1)
						v = "";
					
					if (oXML.hasMultipleFiles == false)
					{
						outputObj = oXML.langNotHasMultipleFiles;
					}
					else if (v == "")
					{
						var o2 = jQuery("<div></div>");
						o2.append('<input type="text" style="display:none"   />');
						o2.append('<input name="file" type="file" onchange="jQuery(this).nextAll(\'button.fileupload-do:first\').click()" class=\"input-file\" />');
						o2.append('<span></span>');
						o2.append("	<button style=\"display:none\" class=\"fileupload-do\" onclick=\"return ajaxFileUploadXML(this, "+oXML.workspaceItemID+", '"+oXML.fieldTitle+"');\" type=\"button\">Upload</button>");
						outputObj = o2.contents();
					}
					else
					{
						var o2 = jQuery("<div></div>");
						o2.append('<span></span>');
						o2.append('<input type="text" value="'+v+'" style="display:none"   />');
						o2.append('<input name="file" type="file" onchange="jQuery(this).nextAll(\'button.fileupload-do:first\').click()" />');
						o2.append("	<button class=\"fileupload-do\" onclick=\"return ajaxFileUploadXML(this, "+oXML.workspaceItemID+", '"+oXML.fieldTitle+"');\" type=\"button\">Upload</button>");
						outputObj = oXML.ajaxFileUploadExistXML(o2);
					}					
					break;
				default:	//case "textarea":
					outputObj = jQuery("<textarea onfocus=\"\" >"+value.html()+"</textarea>").css("width", "100%");
					outputObj.change(function () {
						var o = new XMLMetadata(oXML.storageID);
						o.formToXML(true);
					});
			}
			//outputObj.val(value.html());
			//outputObj = attrInputType;
			
			return outputObj;
		}	//if (oXML.displayTable == false)
		else if (oXML.displayTable == true)
		{
			var c = jQuery.trim(value.html());
			if (attrInputType == "fileupload")
			{
				c = ajaxFileUploadDisplay(c);
			}
			else if (attrInputType == "dropdown" || attrInputType == "list")
			{
				//alert(inputOptions.children("option[value="+c+"]").length);
				c = inputOptions.children("option[value="+c+"]").html();
			}			
			
			//outputObj = jQuery("<div class=\"xmlMetadataValueDiv\"></div>").append(c);
			outputObj = jQuery("<span class=\"xmlMetadataValueDiv\" />").append(c);
			
			return outputObj;
		}

	};
	
	//Setup required form check
	
	if (typeof(inputID) != "undefined")
	{
		var formObj = oXML.storage.parent("form:first");
		if (formObj.hasClass(oXML.langFormRequiredFlag) == false)
		{
			formObj.submit(function() {
				if (jQuery(this).find(".form-required").length > 0)
				{
					if (window.confirm(oXML.langCheckRequired))
					{
						jQuery(this).find(".form-required:first").focus();
						return false;
					}
				}
									
			});
			formObj.addClass(oXML.langFormRequiredFlag);
		}
	}
	
	//All Form to XML
	oXML.formToXML = function(forceDo)
	{
		if (!(typeof(forceDo) != "undefined" && forceDo == true))
		{
			if (oXML.debugFormToXML == false || oXML.displayTable == true)
				return;
		}
		var outputObj = jQuery("<div></div>");
		
		var rootTable = oXML.storage.next().children("table");
		
		outputObj.append(oXML.nodeToXML(rootTable));
		
		if (oXML.storage.val() != "<div class=\"xml-root\">\n"+outputObj.html()+"\n</div>")
		{
			var val = "<div class=\"xml-root\">\n"+outputObj.html()+"\n</div>";
			val = oXML.XMLReform(val);
			oXML.storage.val(val);
			oXML.storage.change();
		}
	}
	
	//Single Node(table) to XML
	oXML.nodeToXML = function(tableObj)
	{
		//t(tableObj.html());
		var outputObj = jQuery("<div class=\"node\"></div>");	//.addClass("node");
		
		var type = (new XMLNodeFn()).nodeAttr(tableObj, "node-type");
		
		outputObj.append(oXML.nodeAttrToXML(tableObj, "node-type"))
			.append(oXML.nodeAttrToXML(tableObj, "node-title"))
			.append(oXML.nodeAttrToXML(tableObj, "node-repeatable"))
			.append(oXML.nodeAttrToXML(tableObj, "node-id"))
			.append(oXML.nodeAttrToXML(tableObj, "node-class"));
		if (type == "node")
		{
			//get content-temp
			var contentTempDiv = jQuery("<div></div>").addClass("node-content-temp");
			var contentTempTables = tableObj.children("tbody").children(".node-temp").children(".node-contents").children();
			for (var i = 0; i < contentTempTables.length; i++)
				contentTempDiv.append(oXML.nodeToXML(contentTempTables.filter(":eq("+i+")")));		
			outputObj.append(contentTempDiv);
			
			//contents
			var contentsTr = tableObj.children("tbody").children(".node");
			for (var i = 0; i < contentsTr.length; i++)
			{
				var contentsTables = contentsTr.filter(":eq("+i+")").children(".node-contents").children();
				var contentsDiv = jQuery("<div></div>").addClass("node-contents");
				for (var j = 0; j < contentsTables.length; j++)
					contentsDiv.append(oXML.nodeToXML(contentsTables.filter(":eq("+j+")")));
				outputObj.append(contentsDiv);
			}
		}
		else if (type == "input")
		{
			outputObj.append(oXML.nodeAttrToXML(tableObj, "input-default-value"))
				.append(oXML.nodeAttrToXML(tableObj, "input-required"))
				.append(oXML.nodeAttrToXML(tableObj, "input-type"))
				.append(oXML.nodeAttrToXML(tableObj, "input-options"))
			var inputType = oXML.nodeAttrToXML(tableObj, "input-type").html();
			
			//get values
			var valuesTr = tableObj.children("tbody").children("tr.input");
			for (var i = 0; i < valuesTr.length; i++)
			{
				var valuesInputs = tableObj.children("tbody").children("tr.input:eq("+i+")").children("td.input-contents");
				if (inputType != "texteditor")
					var valuesDiv = jQuery("<div></div>").addClass("input-values")
						.html(valuesInputs.children(":eq(0)").val());
				else
					var valuesDiv = jQuery("<div></div>").addClass("input-values")
						.html(valuesInputs.children("textarea:eq(0)").val());
				outputObj.append(valuesDiv);
			}
		}
		
		return outputObj;
	}
	
	oXML.ajaxFileUploadExistXML = function (o2)
	{
		var d = o2;
		//var d = jQuery("#"+id).parents("td:first");
		var url = d.children("input[type!=file]:first").val();
		
		if (url == "") return;
		
		var config = dspaceFileUploadConfig();
		var filename = decodeURI(url.substring(url.lastIndexOf("/")+1, url.length));
		var format = filename.substring(filename.lastIndexOf(".") + 1, filename.length).toLowerCase();
		if (filename.lastIndexOf(".") == -1) format = "Unknow";
		
		d.children("span:first").html("<a href=\""+url+"\">"+filename+"</a> ("+format+")");
		//if is a pic, prepend img
			if (jQuery.inArray(format, config.imageFormat) != -1)
			{
				var img = jQuery("<img src=\""+url+"\" alt=\""+filename+"\" style=\"display:block\" border=\"0\" onload=\"this.style.height = '"+config.maxHeight+"px'\" />");

				img.hide();
				img.load(function() {
					var i = jQuery(this);
					var w = i.width();
					var h = i.height();
					var maxWidth = i.parents("div:first").width();

					if (w > maxWidth)
					{
						i.width(maxWidth);
						i.height(maxWidth/w*h);
					}
					
					var maxHeight = 100;
					if (h > maxHeight)
					{
						i.height(maxHeight);
						i.width(maxHeight/h*w);
					}
					i.show();
					return false;
				});
				
				var a = jQuery("<a href=\""+url+"\" target=\"preview\"></a>").append(img);
				
				d.children("span:first").prepend(a);
			}
		d.children("button.fileupload-do:first").hide();

		return d.contents();	
	};
	
	oXML.nodeAttrToXML = function(tableObj, attrName)
	{
		var attrValue = (new XMLNodeFn()).nodeAttr(tableObj, attrName);
			
			if (attrName != "input-options")
				var xmlObj = jQuery("<div></div>");
			else
				var xmlObj = jQuery("<select></select>");
			
			if ((attrName != "input-default-value" && attrName != "input-values" && attrName != "node-title") &&
				(attrValue == null || typeof(attrValue) == "undefined" || 
				(typeof(attrValue) == "object" && attrValue.length == 0)))
			{
				return;
			}
			xmlObj.addClass(attrName).html(attrValue);
			return xmlObj;
		
	}
	
	oXML.locate = function(path)
	{
		nodes = path.split("\.");
		var output = "";
		for (var i = 0; i < nodes.length; i++)
		{
			if (i != nodes.length-1)
			{
				output = output + "div.node:has(div.node-title:contains("+nodes[i]+")) div.node-contents ";
			}
			else
			{
				output = output + "div.node:has(div.node-title:contains("+nodes[i]+")) div.input-values";		
			}
		}
		
		var nodeList = oXML.storage.find(output);
		outputList = new Array;
		for (var i = 0; i < nodeList.length;i++)
			outputList.push(nodeList.eq(i).html());
		return outputList;
	};
	
	oXML.XMLReform = function (inputText)
	{
		var output = "";

			var needleLast = 0;
			
			while(inputText.indexOf("=", needleLast) != -1)
			{
				var needle = inputText.indexOf("=", needleLast);
				
				//Add before to output
				output = output + inputText.substring(needleLast, needle+1);
				
				//觀察是否在標籤內
				if (inputText.indexOf("<", needle) < inputText.indexOf(">", needle)
					&& inputText.indexOf("<", needle) != -1)
				{
					needleLast = needle+1;
					continue;
				}
				
				
				//check next char is " ?
				var nextChar = inputText.substring(needle+1, needle+2);
				if (nextChar != "\"")
				{
					output = output + "\"";
					
					var needleFooter;
					//we have to know who is first between " " or ">"
					
					var needleFooter1 = inputText.indexOf(" ", needle+1);	//for " "
					var needleFooter2 = inputText.indexOf(">", needle+1);	//for ">"
					
					if (needleFooter1 < needleFooter2 && needleFooter1 != -1)
						needleFooter = needleFooter1;
					else if (needleFooter2 != -1)
						needleFooter = needleFooter2;
					else
						needleFooter = needleFooter1;
					
					output = output + inputText.substring(needle+1, needleFooter);
					
					output = output + "\"";
					
					needleLast = needleFooter;
					
					//needleLast = needle + 1;
				}
				else	//next char isn't ".
				{
					needleLast = needle+1;
				}
			}
		
			output = output + inputText.substring(needleLast, inputText.length); 			
			
			
			//<DIV class="node"><DIV
			
			var replaceAll = function (str, reallyDo, replaceWith)
			{
				return str.replace(new RegExp(reallyDo, 'g'), replaceWith);
			}
			
			output = replaceAll(output, "<div class=\"node\"><div class=\"node-type\">", "<DIV class=\"node\"><DIV class=\"node-type\">");
			output = replaceAll(output, "</div><div class=\"node", "</DIV><DIV class=\"node");
			output = replaceAll(output, "</div><div class=\"input", "</DIV><DIV class=\"input");
			output = replaceAll(output, "</div></div><DIV class=\"node\">", "</DIV></DIV><DIV class=\"node\">");
			output = replaceAll(output, "</div><DIV class=\"node\">", "</DIV><DIV class=\"node\">");
			output = replaceAll(output, "</div></div></div></div>\n</div>", "</DIV></DIV></DIV></DIV>\n</div>");
			output = replaceAll(output, "</div></div></div></div></div>", "</DIV></DIV></DIV></DIV></div>");
			output = replaceAll(output, "</div><select", "</DIV><select");
			output = replaceAll(output, "</select><div", "</select><DIV");
			output = replaceAll(output, "</div><SELECT", "</DIV><SELECT");
			output = replaceAll(output, "</div></div></DIV>", "</DIV></DIV></DIV>");
			output = replaceAll(output, "selected ", "selected=\"true\" ");
			output = replaceAll(output, "selected>", "selected=\"true\">");
			
			/*
			output = output.replace("<div class=\"node\"><div class=\"node-type\">", "<DIV class=\"node\"><DIV class=\"node-type\">");
			output = output.replace("</div><div class=\"node", "</DIV><DIV class=\"node");
			output = output.replace("</div><div class=\"input", "</DIV><DIV class=\"input");
			output = output.replace("</div></div><DIV class=\"node\">", "</DIV></DIV><DIV class=\"node\">");
			output = output.replace("</div></div><DIV class=\"node\">", "</DIV></DIV><DIV class=\"node\">");
			output = output.replace("</div><DIV class=\"node\">", "</DIV><DIV class=\"node\">");
			output = output.replace("</div></div></div></div>\r\n</div>", "</DIV></DIV></DIV></DIV>\r\n</div>");
			output = output.replace("</div></div></div></div>\n\r</div>", "</DIV></DIV></DIV></DIV>\n\r</div>");
			output = output.replace("</div></div></div></div></div>", "</DIV></DIV></DIV></DIV></div>");
			output = output.replace("</div></div></div></div>\n</div>", "</DIV></DIV></DIV></DIV>\n</div>");
			output = output.replace("</div><select", "</DIV><select");
			output = output.replace("</select><div", "</select><DIV");
			output = output.replace("</div><SELECT", "</DIV><SELECT");
			output = output.replace("</div></div></DIV>", "</DIV></DIV></DIV>");
						
			output = output.replace("selected ", "selected=\"true\" ");
			output = output.replace("selected>", "selected=\"true\">");
			*/
			
		return output;
	};
}

function XMLNodeFn()
{
	var oXMLFn = this;
	
	oXMLFn.repeatAction = function(thisButton)
	{
		var tbodyObj = jQuery(thisButton).parents("tbody:first");
		var type = (new XMLNodeFn()).nodeAttr(thisButton, "node-type");
		
		//Copy temp then append to tbodyObj
			//get tr.?-temp
			var trTemp = tbodyObj.children("tr."+type+"-temp");
			var newTrObj = trTemp.clone();
			newTrObj.removeClass(type+"-temp").addClass(type);
			newTrObj.children("th").css("visibility", "hidden");
			newTrObj.show();
			tbodyObj.append(newTrObj);
			
			//檢查裡面是否有FCKeditor
			var fck = newTrObj.find("textarea.embedFCKeditor");
			for (var i = 0; i < fck.length; i++)
			{
				var f = fck.eq(i);
				f.attr("name", "embedFCKeditor-"+xmlmetadataFCKeditorCounter);
				f.attr("id", "embedFCKeditor-"+xmlmetadataFCKeditorCounter);
				//f.html("測試，如果這個文字沒有出來，表示FCKeditor載入錯誤");
				f.prevAll().remove();
				jQuery(document).ready(function () {
					var name = f.attr("name");
					var oFCKeditor = new FCKeditor( name ) ;
					oFCKeditor.BasePath	= FCKeditorPath;
					oFCKeditor.Config["ToolbarStartExpanded"] = false;
					if (oXML.fckeditorStyle != "")
						oFCKeditor.Config["EditorAreaStyles"]	= oXML.fckeditorStyle;
					oFCKeditor.ReplaceTextarea();
				});
				xmlmetadataFCKeditorCounter++;
			}
	
		(new XMLNodeFn()).buttonAdjust(tbodyObj, type);
		
		jQuery(thisButton).addClass("button-hidden").blur();
		
		var inputID = oXMLFn.getInputID(thisButton);
		(new XMLMetadata(inputID)).formToXML();
	};
	
	oXMLFn.buttonAdjust = function(tbodyObj, type, inputType)
	{
		var trObj = tbodyObj.children("."+type);
		//Adjust title
		trObj.children(".input-title").addClass("title-hidden");
		trObj.children("."+type+"-title:first").removeClass("title-hidden");
		if (trObj.children("."+type+"-title:visible").length == 0)
			trObj.children("."+type+"-title:first").css("visibility", "visible");
		
		//Adjust delete button
		var buttonDel = trObj.children("."+type+"-function").children(".buttonDel");
		buttonDel.css("display", "inline");
		if ((new XMLNodeFn()).nodeAttr(tbodyObj.parents("table:first"), "input-type") != "fileupload" && trObj.length < 2)	buttonDel.css("display", "none");
		
		//Adjust repeat button
		var buttonRepeat = trObj.children("."+type+"-function").children("button.buttonRepeat");
		if (buttonRepeat.filter(":visible").length > 1)
			buttonRepeat.filter(":visible").not(":last").addClass("button-hidden");
	};
	
	oXMLFn.nodeAttr = function(thisObj, attrName)
	{
		if (jQuery(thisObj).children("caption:first").length == 0)
			var tableObj = jQuery(thisObj).parents("table:first");
		else
			var tableObj = thisObj;
		
		switch(attrName)
		{
			case "input-options":
				var attrObj = tableObj.children("caption").children("select");
				return attrObj.children();
				/*
				var attrObj = tableObj.find("tr.input-temp td.input-contents")
					.children("select:eq(0)");
				alert(tableObj.find("tr.input-temp td.input-contents").html());
				optionsObj = attrObj.clone();
				optionsObj.children("option").removeAttr("selected");
				return optionsObj.html();
				*/
				break;
			/*case "input-default-value":
				var attrObj = tableObj.find("tr.input-temp td.input-contents")
					.children(":eq(0)");	
				break;*/
			case "node-id":
				return tableObj.attr("id");
				break;
			case "node-class":
				return tableObj.attr("class");
				break;
			case "input-default-value":
				var inputType = tableObj.children("caption").children("input[title=input-type]").val();
				var tag = "";
				if (inputType == "texteditor") tag = "textarea";
				var attrObj = tableObj.children("tbody").children("tr.input-temp").children("td.input-contents")
					.children(tag+":eq(0)");
				//alert([tableObj.children("tbody").children("tr.input-temp").length, inputType, attrObj.val(), tableObj.children("caption").children("input[title=input-type]").length]);
				break;
			default:
				var attrObj = tableObj.find("input[title="+attrName+"]");
		}
		if (attrObj.length != 0)
			return attrObj.val();
	};
	
	oXMLFn.deleteNode = function(thisButton, force)
	{
		var noteType = jQuery(thisButton).parents("table:first").children("caption:first").children("input[type=hidden][title=node-type]").val();
		if (noteType == "input")
			var inputValue = jQuery.trim(jQuery(thisButton).parents("td:first").prevAll("td:first").children(":first").val());
		else 
		{
			var inputValue = "";
			var force = true;
		}			
		
		if ((typeof(force) == "boolean" && force == true) 
			|| inputValue == ""
			|| window.confirm(((new XMLMetadata()).langDelConfirm)))
		//if (window.confirm(((new XMLMetadata()).langDelConfirm)));
		{
			var trObj = jQuery(thisButton).parents("tr:first");
			var tbodyObj = jQuery(thisButton).parents("tbody:first");
			var type = (new XMLNodeFn()).nodeAttr(thisButton, "node-type");
			
			//if del node has repeatbutton show 
			if (jQuery(thisButton).nextAll("button.buttonRepeat:first:visible").length > 0)
			{
				var prexTrObj = trObj.prevAll("tr:first");
				prexTrObj.children("td."+type+"-function").children("button.buttonRepeat").removeClass("button-hidden");
			}
			trObj.remove();	
			(new XMLNodeFn()).buttonAdjust(tbodyObj, type); 
		}
	};
	
	oXMLFn.datePicker = function(thisInput)
	{
		jQuery(thisInput).datepicker();	
		jQuery(thisInput).focus();
	};
	
	oXMLFn.formChange = function(thisForm, inputID, force)
	{
		var f = jQuery(thisForm);
		if (f.val() == "")
		{
			f.addClass("form-required");
			var thTitle = f.parents("tr:first").children("th");
				thTitle.addClass("form-required-title");
		}
		else
		{
			f.removeClass("form-required");
			(f.parents("tr:first").children("th")).removeClass("form-required-title");
			//Form to XML
			if (typeof(force) == "undefined")
				(new XMLMetadata(inputID)).formToXML();
			else if (force == true)
				(new XMLMetadata(inputID)).formToXML(true);
		}
	};
	
	oXMLFn.showNode = function(thisTitle)
	{
		var tableObj = jQuery(thisTitle).parents("tbody:first");
		t(tableObj.html());
	}
	
	oXMLFn.getInputID = function (thisObj)
	{
		var divObj = jQuery(thisObj).parents("div.xml-root:first");
		var textareaObj = divObj.prevAll("textarea:first");
		return textareaObj.attr("id");
	};
	
	oXMLFn.switchList = function(thisList, value)
	{
		var repeatable = oXMLFn.nodeAttr(thisList, "node-repeatable");
		
		var trTemp = jQuery(thisList).parents("tbody:first").children("tr.input-temp").clone();
		trTemp.removeClass("input-temp")
			.addClass("input")
			.hide();
		
		if (repeatable == "false")
		{
			jQuery(thisList).parents("tbody:first").children("tr.input").remove();
			
			trTemp.children("td.input-contents:first").children(":first").val(value);
			jQuery(thisList).parents("tbody:first").children(":last").before(trTemp);
			
			thisList.checked = "checked";
			
			return true;
		} else
		{
			var checked = thisList.checked;
			//alert(checked);
			
			var trObjs = jQuery(thisList).parents("tbody:first").children("tr.input");
			for (var i = 0; i < trObjs.length; i++)
			{
				var trValue = jQuery.trim(trObjs.eq(i).children("td.input-contents").children(":first").val());
				if (trValue == jQuery.trim(value))
				{
					if (checked == false)	// delete option
						trObjs.eq(i).remove();
					return false;
				}
			}
			if (checked == true)
			{
				trTemp.children("td.input-contents:first").children(":first").val(value);
				jQuery(thisList).parents("tbody:first").children(":last").before(trTemp);
			}
		}
	};
}	//function XMLNodeFn()


function formToXMLonSubmit()
{	
	//alert("on submit");
	//get all div.xml-root
	var d = jQuery("div.xml-root");
	for (var i = 0; i < d.length; i++)
	{
		var id = d.eq(i).prevAll("textarea:first").attr("id");
		if (typeof(id) == "undefined") continue;
		var o = new XMLMetadata(id);
		o.formToXML(true);
	}
	
	return true;
}
	
