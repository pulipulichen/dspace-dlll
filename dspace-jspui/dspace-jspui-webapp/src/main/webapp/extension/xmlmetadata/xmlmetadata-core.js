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
	oXML.hiddenRootTitle = true;
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
	
	oXML.basePath = location.pathname;
	if (location.pathname.indexOf("/", 1) != -1)
		oXML.basePath = location.pathname.substring(0, location.pathname.indexOf("/", 1));
	oXML.fckeditorPath = oXML.basePath + "/extension/fckeditor/";
	oXML.fckeditorStyle = "";
	
	oXML.setFCKeditorPath = function (path)
	{
		oXML.oFCKeditorBasePath = path;
		oXML.fckeditorPath = path;
		FCKeditorPath = path;
	};
	
	oXML.setFCKeditorStyle = function (style)
	{
		oXML.fckeditorStyle = style;
		FCKeditorStyle = style;
	}
	oXML.cssPath = oXML.basePath + "/extension/xmlmetadata/xmlmetadata-style.css";
	oXML.fileuploadPath = location.pathname + "?action=json";
	
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
		{
			oXML.storage = jQuery(inputID);
		}
		
		if (oXML.debug == true)
		{
			oXML.storage.css("width", "100%")
				.css("height", "30em")
			oXML.storage.before("<button type=\"button\" onclick=\"(new XMLMetadata()).buttonCreateForm('"+inputID+"')\">轉換成表單</button>");
		}
	}
	//Language
	//預設值
	var DEFAULT_XMLMETADATA_LANG = {
		"CheckRequired": "您有表單尚未填寫完成，是否要繼續？",
		"FormRequiredFlag": "form-required-check",
		"DataPicker": "請點此選擇日期",
		"ButtonRepeat": "新增",
		"ButtonDel": "刪除",
		"DelConfirm": "確定要刪除？",
		"RequireTip": "*：表示必須填寫",
		"NotHasMultipleFiles": "Please check \"文件由一個以上的 檔案所組成\"! ",
		"InputRequiredTip": "必須填寫",
		"ButtonInsert": "插入",
		"ButtonMoveUp": "上移",
		"ButtonMoveDown": "下移",
		"AlertTitle": "系統訊息",
		"AlertMessageDisplayForm": "正在設定表單，請稍候。",
		"AlertMessageDisplayTable": "正在繪製網頁，請稍候。",
		"AlertNowSaving": "現在正在儲存中，請稍候。",
		"AlertNowSaving1": "現在正在儲存表單中，剩餘",
		"AlertNowSaving2": "個表單，請稍候。",
		"AlertStop": "停止",
		"AlertStopConfirm": "如果停止的話，只有重新讀取網頁才能再次啟動。您確定要停止嗎？"
	};
		
	var XMLMETADATA_LANG = getXMLMetadataLang();
	
	if (typeof(XMLMETADATA_LANG) == "undefined")
		var XMLMETADATA_LANG = new Object;
	
	jQuery.each(DEFAULT_XMLMETADATA_LANG, function (name, value) {
		//先確認是否有值
		if (typeof(XMLMETADATA_LANG) != "undefined"
			&& typeof(XMLMETADATA_LANG[name]) != "undefined")
			value = XMLMETADATA_LANG[name];
		
		var langName = "lang"+name;
		oXML[langName] = value;
	});
	
	oXML.alert = jQuery(".xmlmetadata-alert");
	
	oXML.createRootFormFlag = false;
	
	oXML.delay = 10;
	
	var getStopProcessFlag = function () {
		if (typeof(stopProcessFlag) == "undefined" || stopProcessFlag == false)
			return false;
		else
			return true;
	};
	
	oXML.createRootForm = function(completeCallback) {
		jQuery(document).ready(function () {
		
			oXML.initAlert();
			
			if (oXML.isAlerting() == true
				&& oXML.createRootFormFlag == false)	//表示別人正在開啟中
			{
				setTimeout(function() {
					oXML.createRootForm(completeCallback);
				}, oXML.delay*20);
				
				return;
			}
			if (oXML.isAlerting() == false)
			{
				if (oXML.displayTable == false)
				{
					oXML.setAlert(oXML.langAlertMessageDisplayForm);
				}
				else
					oXML.setAlert(oXML.langAlertMessageDisplayTable);
				oXML.openAlert();
				setTimeout(function () {
					if (getStopProcessFlag()) return;
					oXML.createRootForm(completeCallback);
					oXML.createRootFormFlag = true;
					
				}, oXML.delay * 10);
				return;
			}
			oXML.storage.addClass("xmlmetadata-source");
			var inputXML = oXML.storage.val();
			
			var parsingError = false;
			try
			{
				var root = jQuery(inputXML);
			}
			catch (e) {
				//alert("Parsing inputXML error: "+e); 
				//parsingError = true;
				
				try
				{
					inputXML = XMLfunc.replaceAll(inputXML, "%u6709", "有");
					
					
					var root = jQuery(inputXML);
				}
				catch (e2)
				{
					try
					{
						inputXML = XMLfunc.replaceAll(inputXML, "%u8207", "與");
						var root = jQuery(inputXML);
					}
					catch (e3)
					{
						alert("Parsing inputXML error: \n"+e3); 
						parsingError = true;
					}
				}
			}
			if (parsingError == true
				|| jQuery.trim(inputXML) == ""
				|| (root.hasClass("xml-root") == false
				&& root.find(".xml-root").length == 0))
			{	
				if (oXML.storage.hasClass("inited") == false)
					oXML.storage.show();
				oXML.closeAlert();
				return;
			}
			
			if (oXML.storage.hasClass("inited") == true)
			{
				oXML.closeAlert();
				return;
			}
			else
				oXML.storage.addClass("inited");
					
			try
			{
				var rootNode = root.children();
			}
			catch (e) {
				alert("Parsing inputXML error: "+e); 
				return;
			}
			var loopCount = 0;
			while (oXML.hiddenRootNode && rootNode.length == 1)
			{
				if (rootNode.children("div.node-contents").length > 0)
					rootNode = rootNode.children("div.node-contents:last").children();
				else if (rootNode.children("div.node-content-temp").length == 1)
					rootNode = rootNode.children("div.node-content-temp:first").children();
				else
					break;
				
				loopCount++;
				if (loopCount > 10)
					break;
			}
			if (oXML.debug == false)
				oXML.storage.hide();
			var xmlRoot = jQuery("<div></div>").addClass("xml-root");
			oXML.StatisticFlag = false;
			
			
			var loopCreateNode = function(i, rootNode, callback) {
				if (i < rootNode.length)
				{
					oXML.createNode(rootNode.eq(i), function(returnObject) {
						if (jQuery.trim(rootNode.eq(i).html()) != "") 
						{
							xmlRoot.append(returnObject);
						}
						i++;
						setTimeout(function () {
							if (stopProcessFlag) return;
							loopCreateNode(i, rootNode, callback);
							count("loopCreateNode(i("+i+"), rootNode(rootNode.length:"+rootNode.length+"), callback);");
						}, oXML.delay);
					});
				}
				else
					callback();
				
			};
			
			setTimeout(function () {
				if (stopProcessFlag) 
					return;
				
				loopCreateNode(0, rootNode, function () {
					
					if (oXML.displayTable == false && xmlRoot.children().length != 0)
						xmlRoot.prepend("<span class=\"require-tip\">"+oXML.langRequireTip+"</span>");
					oXML.storage.after(xmlRoot);
					
					setTimeout(function () {
						oXML.storage.hide()
							.css("display", "none");
						
						jQuery(document).ready(function () {
							if (oXML.displayTable == false)
							{
								if (jQuery(inputXML).hasClass("edited") == false)
								{
									oXML.storage.attr("innerHTML", "")
										.val("");
								}
								else
								{
									//oXML.setChanged(true);	//為什麼要加這個呢？
								}
								
								oXML.bindFormOnSubmit();
							}
							oXML.closeAlert();
							oXML.createRootFormFlag = false;
							
							oXML.storage.hide();
							
							if (typeof(completeCallback) == "function")
								completeCallback();
						});
					}, oXML.delay * 10);
				})
			}, oXML.delay);
		
		});	//jQuery(document).ready(function () {
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
		var loopCreateNode = function(i, rootNode, callback) {
			if (i < rootNode.length)
			{
				oXML.createNode(rootNode.eq(i), function(returnObject) {
					if (jQuery.trim(rootNode.eq(i).html()) != "") 
					{
						xmlRoot.append(returnObject);
					}
					i++;
					setTimeout(function () {
						if (getStopProcessFlag()) 
							return;
						loopCreateNode(i, rootNode, callback);
						count("loopCreateNode(i("+i+"), rootNode(rootNode.length:"+rootNode.length+"), callback);");
					}, oXML.delay);
				});
			}
			else
				callback();
			
		};
		
		setTimeout(function () {
			if (getStopProcessFlag()) 
				return;
			loopCreateNode(0, rootNode, function () {
				targetObj.contents().hide();
				targetObj.append(xmlRoot);
			});
			count("loopCreateNode(0, rootNode(rootNode.length:"+rootNode.length+"), function () {;");
		}, oXML.delay);
		/*
		for (var i = 0; i < rootNode.length; i++)
		{
			if (jQuery.trim(rootNode.eq(i).html()) == "") 
				continue;
			xmlRoot.append(oXML.createNode(rootNode.eq(i)));
		}
		targetObj.contents().hide();
		targetObj.append(xmlRoot);
		*/
		
		
	};
	
	oXML.createNode = function(inputObj, callback) {
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
			
			//在這裡把unescape做完吧！
			for (var i = 0; i < values.length; i++)
			{
				var v = values.eq(i).html();
				v = unescape(v);
				values.eq(i).html(v);
			}
			
			//if no defaultValue, clone last values to defaultValue
			if (defaultValue.length == 0)
				var defaultValue = inputObj.children(".input-values:last").clone();
			//if no values, clone defaultValue to values
			if (values.length == 0)
				var values = defaultValue.clone();
			
			attrCaption.append("<input type=\"hidden\" title=\"input-default-value\" value=\""+defaultValue.html()+"\" />");
			
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
				//filter value
				for (var i = 0; i < inputOptions.length; i++)
				{
					var option = inputOptions.eq(i);
					if (typeof(option.attr("value")) == "undefined")
						option.attr("value", XMLfunc.escapeHTML(option.html()));
				}
			
				//values
				for (var i = values.length - 1; i > -1; i--)
				{
					var valueHTML = values.filter(":eq("+i+")").html();
					valueHTML = escape(valueHTML);
					if (inputOptions.children("option[value="+valueHTML+"]").length == 0)
						inputOptions.prepend("<option value=\""+valueHTML+"\">"+valueHTML+"</option>");	
				}
				//default value option
				//	if (inputOptions.children("option[value="+defaultValue.html()+"]").length == 0)
				//		inputOptions.prepend("<option value=\""+defaultValue.html()+"\">"+defaultValue.html()+"</option>");
				attrCaption.append(inputOptions.clone().hide());
				
		}
		outputObj.append(attrCaption);
		
		//create thTitleTemp
		if (oXML.debug == true)
			var thTitleTemp = jQuery("<th onclick=\"XMLNodeFn.showNode(this)\"></th>");
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
			if (oXML.hiddenRootTitle == true)
				oXML.hiddenRootTitle = false;
			else
				attrCaption.append("<span class=\"caption-title\">"+attrTitle+"</span>");
		}
		
		if (type == "node")
			thTitleTemp.attr("title", attrTitle);
		
		//initialize tbody
		var tbodyObj = jQuery("<tbody></tbody>");
		
		//先宣告完成函式
		var complete = function () {
			if (attrInputType == "list" && oXML.displayTable == false)
			{
				var listTr = jQuery("<tr></tr>").addClass("input");
				
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
					
					if (jQuery.trim(listValue) == "")
						continue;
					/*
					var compareValue = (jQuery.trim(inputObj.html()) == listValue);
					
					if (compareValue == true) 
						var checked = "checked=\"true\"";
					else 
						var checked = "";
					*/
					//alert([compareValue, jQuery.trim(inputObj.html()), listValue, attrRepeatable]);
					
					if (attrRepeatable == "true") 
						var listType = "checkbox";
					else 
						var listType = "radio";
					
					//var listOption = jQuery("<input type=\""+listType+"\" class=\"input-list\" onclick=\"XMLNodeFn.switchList(this, this.value);\" name=\""+listName+"\" value=\""+listValue+"\" style=\"width:1em\" id=\""+listID+"\" "+checked+" />");
					var listOption = jQuery("<input type=\""+listType+"\" class=\"input-list\" onclick=\"XMLfunc.setChanged(this);\" name=\""+listName+"\" value=\""+listValue+"\" style=\"width:1em\" id=\""+listID+"\" />");
					
					/*
					if (jQuery.trim(inputObj.html()) == listValue && attrRepeatable == "true")
						listOption.attr("checked", true);
					else if (jQuery.trim(inputObj.html()) == listValue && attrRepeatable == "false")
						listOption.attr("checked", "checked");
					*/
					
					var listLabel = jQuery("<label></label>");
					listLabel.html(XMLfunc.unescapeHTML(listTitle));
					listLabel.attr("for", listID);
					
					var listSpan = jQuery("<span></span>");
					listSpan.append(listOption);
					listSpan.append(listLabel);
					
					tdContents.append(listSpan);
				}
				
				for (var c1 = 0; c1 < values.length; c1++)
				{
					var inputObj = values.filter(":eq("+c1+")");
					tdContents.find("input[value='"+inputObj.html()+"']").attr("checked", "checked");
				}
				
				if (attrRepeatable == true)
					tdContents.attr("colspan", 2)
				
				listTr.append(tdContents);
				
				oXML.listID++;
				tbodyObj.children().hide().removeClass("input");
				tbodyObj.append(listTr);
				
			}	//if (attrInputType == "list")
			
			
			tbodyObj.children("tr:last").children("td").css("border-bottom-width", 0);
			//End of tbody
			
			XMLNodeFn.buttonAdjust(tbodyObj, type, attrInputType);
			outputObj.append(tbodyObj);
			
			if (typeof(callback) == "function")
				callback(outputObj);
			else
				alert("callback參數錯誤！");
		};
		
		
		if (type == "node")
		{	
			var loopCreateNodeTR = function (c1, contents, callback) {
				if (c1 < contents.length)
				{
					oXML.createNodeTR(contents.filter(":eq("+c1+")"), type, "false", attrRepeatable, thTitleTemp
						, function (returnObject) {
							//var returnObject = 
							tbodyObj.append(returnObject);
							
							c1++
							setTimeout(function () {
								if (stopProcessFlag) return;
								
								if (startStatisticFlag == true)
									oXML.statisticAlert(c1);
								
								loopCreateNodeTR(c1, contents, callback);
								count("loopCreateNodeTR(c1("+c1+"), contents(contents.length:"+contents.length+"), callback);");
							}, oXML.delay);
						});
				}
				else
				{
					callback();
				}
			};
			
			var startStatisticFlag = false;
			if (contents.length > 1
				&& oXML.StatisticFlag == false)
			{
				oXML.StatisticFlag = true;
				//alert(contents.length);
				//oXML.statisticAlert(0, contents.length);
				var startStatisticFlag = true;
			}
			
			
			//Let's create contentTemp!
			oXML.createNodeTR(contentTemp, type, "true", attrRepeatable, thTitleTemp
				, function (returnObject) {
					tbodyObj.append(returnObject);
				
					//Let's create contents
					setTimeout(function () {
						if (stopProcessFlag) return;
						
						if (startStatisticFlag == true)
							oXML.statisticAlert(0, contents.length);
						
						loopCreateNodeTR(0, contents, complete);
						count("loopCreateNodeTR(0, contents(contents.length:"+contents.length+"), complete);");
					}, oXML.delay);
				});
				//var returnObject = oXML.createNodeTR(contentTemp, type, "true", attrRepeatable, thTitleTemp);
			/*
			//Let's create contents
			for (var c1 = 0; c1 < contents.length; c1++)
			{
				var returnObject = oXML.createNodeTR(contents.filter(":eq("+c1+")"), type, "false", attrRepeatable, thTitleTemp);
				tbodyObj.append(returnObject);
			}
			*/
		}
		else if (type == "input")
		{
			var loopCreateNodeTR = function (c1, values, callback) {
				if (c1 < values.length)
				{
					var inputObj = values.filter(":eq("+c1+")");
					
					if (!(oXML.displayTable == true && oXML.displayTableHideEmpty && jQuery.trim(inputObj.html()) == ""))
					{
					
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
						
						
					}	//if (!(oXML.displayTable == true && oXML.displayTableHideEmpty && jQuery.trim(inputObj.html()) == ""))
					oXML.createNodeTR(inputObj, type, "false", attrRepeatable, thTitleTemp, attrInputType, inputOptions, attrRequired
							, function (returnObject) {
								tbodyObj.append(returnObject);
								
								c1++;
								setTimeout(function () {
									if (stopProcessFlag) return;
									loopCreateNodeTR(c1, values, callback);
									count("loopCreateNodeTR(c1("+c1+"), values(values.length:"+values.length+"), callback);");
								}, oXML.delay);
							});
				}
				else
				{
					callback();
				}
			};
			
			//Let's create defalutValue
			oXML.createNodeTR(defaultValue, type, "true", attrRepeatable, thTitleTemp, attrInputType, inputOptions, attrRequired
				, function (returnObject) {
					tbodyObj.append(returnObject);
					
					setTimeout(function () {
						if (stopProcessFlag) return;
						loopCreateNodeTR(0, values, complete);
						count("loopCreateNodeTR(0, values(values.length:"+values.length+"), complete);");
					}, oXML.delay);
				});
			
			//Let's create values
			/*
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
				
				var returnObject = oXML.createNodeTR(inputObj, type, "false", attrRepeatable, thTitleTemp, attrInputType, inputOptions, attrRequired);
				tbodyObj.append(returnObject);
			}
			*/
		}
		
		//complete(tbodyObj);
	};
	
	oXML.createNodeTR = function (node, type, isTemp, attrRepeatable, thTitleTemp, attrInputType, inputOptions, attrRequired, completeCallback)
	{
		if (typeof(completeCallback) != "function")
		{
			if (typeof(attrInputType) == "function")
				completeCallback = attrInputType;
		}
		
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
		
		//先宣告完成函數
		var complete = function () {
			//alert([node, type, isTemp, attrRepeatable, thTitleTemp, attrInputType, inputOptions, attrRequired, completeCallback]);
			trObj.append(tdContents);
			
			if (oXML.displayTable == false)
			{
				var tdFunction = jQuery("<td></td>").addClass(className + "-function");
				if (attrRepeatable == "true")
				{
					if (attrInputType != "fileupload")
						var buttonDel = jQuery("<button type=\"button\" onclick=\"XMLNodeFn.deleteNode(this)\"></button>")
							.addClass("buttonDel").html(oXML.langButtonDel);
					else
						var buttonDel = jQuery("<button type=\"button\" onclick=\"ajaxFileUploadRemoveXML(this, "+oXML.workspaceItemID+")\"></button>")
							.addClass("buttonDel").html(oXML.langButtonDel);
					
					buttonDel.hide();
					tdFunction.append(buttonDel);

					var buttonRepeat = jQuery("<button type=\"button\" onclick=\"XMLNodeFn.repeatAction(this)\"></button>")
						.addClass("buttonRepeat")
						.html(oXML.langButtonRepeat);
						//.html(oXML.langButtonInsert);
					tdFunction.append(buttonRepeat);
					
					tdFunction.append("<br />");
					
					var bunttionMoveUp = jQuery("<button type=\"button\" onclick=\"XMLNodeFn.moveAction(this, 'up')\"></button>")
						.addClass("buttonMove").html(oXML.langButtonMoveUp)
						.hide();
					tdFunction.append(bunttionMoveUp);
					
					var bunttionMoveDown = jQuery("<button type=\"button\" onclick=\"XMLNodeFn.moveAction(this, 'down')\"></button>")
						.addClass("buttonMove").html(oXML.langButtonMoveDown)
						.hide();
					tdFunction.append(bunttionMoveDown);
					
					if (tdFunction.children().length > 0 && jQuery.trim(thTitle.attr("title")) != "")
					{
						var functionTitle = jQuery.trim(thTitle.attr("title"));
						tdFunction.append("<div class='node-function-title'>" + functionTitle + "<span class=\"counter\"></span></div>");
					}
				}	//if (attrRepeatable == "true")
				else if (attrInputType == "fileupload" && jQuery.trim(node.html()) != "")
				{
						var buttonDel = jQuery("<button type=\"button\" onclick=\"ajaxFileUploadCancelXML(this, "+oXML.workspaceItemID+")\"></button>")
							.addClass("buttonDel").html(oXML.langButtonDel);
						tdFunction.append(buttonDel);
				}	//else if (attrInputType == "fileupload" && jQuery.trim(node.html()) != "")
				
				if (oXML.displayTable == false && tdFunction.children().length > 0 )
				{
					var widthDIV = jQuery("<div class='width-extension-function'></div>");
					tdFunction.append(widthDIV);
				}
				
				trObj.append(tdFunction);
			}	//if (oXML.displayTable == false)
			
			//return trObj;
			completeCallback(trObj);
		};	//var complete = function () {
		
		if (type == "node")
		{
			var loopCreateNode = function (i, node, callback) {
				if (i < node.children().length)
				{
					var childObj = node.children(":eq("+i+")"); //.contents();
					oXML.createNode(childObj, function (returnObject) {
						//var returnObject = oXML.createNode(childObj);
						tdContents.append(returnObject);
						
						i++;
						setTimeout(function () {
							if (stopProcessFlag) return;
							loopCreateNode(i, node, callback);
							count("loopCreateNode(i("+i+"), node(node.children().length:"+node.children().length+"), callback);");
						}, oXML.delay);
					});
				}
				else
				{
					callback();
				}
			};
			
			setTimeout(function () {
				if (stopProcessFlag) return;
				loopCreateNode(0, node, complete);
				count("loopCreateNode(0, node(node.children().length: "+node.children().length+"), complete);");
			}, oXML.delay);
			
			/*
			for (var i = 0; i < node.children().length; i++)
			{
				var childObj = node.children(":eq("+i+")"); //.contents();
				tdContents.append(oXML.createNode(childObj));
			}
			*/
		}
		else if (type == "input")
		{
			tdContents.append(oXML.createInputForm(node, attrInputType, inputOptions, attrRequired));
			complete();
		}
	}
	
	oXML.createInputForm = function(value, attrInputType, inputOptions, attrRequired)
	{
		var outputObj;
		//return jQuery("<div>1212</div>");
		
		if (oXML.displayTable == false)
		{
			//alert(attrInputType);
			switch(attrInputType)
			{
				case "list":
					outputObj = jQuery("<span></span>");
					break;
				case "onebox":
					outputObj = jQuery("<input type=\"text\" onchange=\"XMLfunc.setChanged(this);\" value=\""+value.html()+"\" />");
					break;
				case "dropdown":
					var value = value.html();
					value = unescape(value);
					outputObj = jQuery("<select onchange=\"XMLfunc.setChanged(this);\"></select>")
						.append(inputOptions.html());
					var options = outputObj.children("option");
					for (var i = 0; i < options.length; i++)
					{
						var v = options.eq(i).attr("value");
						v = unescape(v);
						options.eq(i).attr("value", v);
						var h = options.eq(i).attr("innerHTML");
						h = unescape(h);
						options.eq(i).attr("innerHTML", h);
					}
					outputObj.children("option").removeAttr("selected");
					outputObj.children("option[value="+value+"]").attr("selected", "selected");
					outputObj.attr("value", value);
					//if (outputObj.children("option[value="+value.html()+"]").length == 0)
					//	alert([outputObj.attr("value"), outputObj.children("option[value="+value.html()+"]").length, inputOptions.html(), value.html(), outputObj.html()]);
					break;
				case "texteditor":
					if (typeof(xmlmetadataFCKeditorCounter) == "undefined")
						xmlmetadataFCKeditorCounter = 0;
					outputObj = jQuery("<textarea class=\"embedFCKeditor-"+inputID+" embedFCKeditor\" name=\"embedFCKeditor-"+xmlmetadataFCKeditorCounter+"\" onchange=\"XMLfunc.setChanged(this);\">"+value.html()+"</textarea>").css("width", "100%");
					try
					{
						outputObj.doFCKeditorDialog();
					}
					catch (e)
					{
						if (typeof(errorNotImportDoFCKeditorDialog) == "undefined")
						{
							errorNotImportDoFCKeditorDialog = true;
							//alert("doFCKeditorDialog not import! Error message: \n" + e);
						}
					}
					xmlmetadataFCKeditorCounter++;
					break;
				case "date":
					outputObj = jQuery("<input type=\"text\" value=\""+oXML.langDataPicker+"\" onfocus=\"XMLNodeFn.datePicker(this)\" onchange=\"XMLfunc.setChanged(this);\" />").css("cursor", "pointer");
					//.datepicker();
					break;
				case "fileupload":
					var v = jQuery.trim(value.html());
					if (v.indexOf("/retrieve/") == -1)
						v = "";
					
					var fileInput = jQuery('<input type="text" style="display:none" class="'+oXML.storageID+' fileupload" onchange=\"XMLfunc.setChanged(this);\" value=\"'+v+'\" />');
					
					if (oXML.hasMultipleFiles == false)
					{
						outputObj = oXML.langNotHasMultipleFiles;
					}
					else if (v == "")
					{
						var o2 = jQuery("<div></div>");
						o2.append(fileInput);
						o2.append('<span></span>');
						o2.append('<input name="file" type="file" onchange="jQuery(this).nextAll(\'button.fileupload-do:first\').click()" class=\"input-file\"  size="1" />');
						o2.append("	<button style=\"display:none\" class=\"fileupload-do\" onclick=\"return ajaxFileUploadXML(this, "+oXML.workspaceItemID+", '"+oXML.fieldTitle+"');\" type=\"button\">Upload</button>");
						outputObj = o2.contents();
					}
					else
					{
						var o2 = jQuery("<div></div>");
						o2.append('<span style=\"display:block;\"></span>');
						o2.append(fileInput);
						o2.append('<input name="file" type="file" onchange="jQuery(this).nextAll(\'button.fileupload-do:first\').click()" size="1" />');
						o2.append("	<button class=\"fileupload-do\" style=\"display:none;\" onclick=\"return ajaxFileUploadXML(this, "+oXML.workspaceItemID+", '"+oXML.fieldTitle+"');\" type=\"button\">Upload</button>");
						
						outputObj = oXML.ajaxFileUploadExistXML(o2, v);
					}					
					break;
				default:	//case "textarea":
					outputObj = jQuery("<textarea  onchange=\"XMLfunc.setChanged(this);\" onfocus=\"\" >"+value.html()+"</textarea>").css("width", "100%");
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
				c = oXML.ajaxFileUploadDisplay(c);
			}
			else if (attrInputType == "dropdown" || attrInputType == "list")
			{
				//alert(inputOptions.children("option[value="+c+"]").length);
				c = inputOptions.children("option[value="+c+"]").html();
				c = XMLfunc.unescapeHTML(c);
				c = XMLfunc.unescapeHTML(c);
			}
			else
			{
				c = XMLfunc.unescapeHTML(c);
				c = jQuery.trim(c);
				if (c.length > 7 && c.substring(0, 7) == "http://")
				{
					var url = c;
					if (url.indexOf(" "))
						url = c.substring(0, url.indexOf(" "));
					c = "<a href=\""+url+"\" target=\"_blank\">"+c+"</a>";
				}
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
	oXML.formToXML = function(forceDo, completeCallback)
	{
		if (!(typeof(forceDo) != "undefined" && forceDo == true))
		{
			if (oXML.debugFormToXML == false || oXML.displayTable == true)
				return;
		}
		var outputObj = jQuery("<div></div>");
		
		var xmlRootDiv = oXML.storage.next();
		
		var rootTable = xmlRootDiv.children("table");
		oXML.StatisticFlag = false;
		
		oXML.nodeToXML(rootTable, function(returnObject) {
			
			//var returnObject = oXML.nodeToXML(rootTable);
			outputObj.append(returnObject);
			
			if (oXML.storage.val() != "<div class=\"xml-root\">\n"+outputObj.html()+"\n</div>")
			{
				var val = "<div class=\"xml-root edited\">\n"+outputObj.html()+"\n</div>";
				//val = oXML.XMLReform(val);
				//oXML.storage.val(val).change();
				oXML.XMLReform(val, function (val) {
					oXML.storage.val(val).change();
					
					if (typeof(completeCallback) == "function")
					{
						completeCallback();
					}
				});
			}
		});
	}
	
	//Single Node(table) to XML
	oXML.nodeToXML = function(tableObj, completeCallback)
	{
		
		//t(tableObj.html());
		var outputObj = jQuery("<div class=\"node\"></div>");	//.addClass("node");
		
		var type = XMLNodeFn.nodeAttr(tableObj, "node-type");
		
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
			
			var loopContentTempNodeToXML = function (i, contentTempTables, callback) {
				if (i < contentTempTables.length)
				{
					oXML.nodeToXML(contentTempTables.eq(i), function(returnObject) {
						contentTempDiv.append(returnObject);
						
						i++;
						setTimeout(function () {
							if (stopProcessFlag) return;
							loopContentTempNodeToXML(i, contentTempTables, callback);
							count("loopContentTempNodeToXML(i("+i+"), contentTempTables(contentTempTables.length: "+contentTempTables.length+"), callback);");
						}, oXML.delay);
					});
				}
				else
				{
					callback();
				}
			};
			
			loopContentTempNodeToXML(0, contentTempTables, function () {
				
				outputObj.append(contentTempDiv);
				
				var contentsTr = tableObj.children("tbody").children(".node");
				
				var loopContentsNodeToXML = function (j, contentsTables, contentsDiv, callback)
				{
					if (j < contentsTables.length)
					{
						var c = contentsTables.eq(j);
						oXML.nodeToXML(c, function (returnObject) {
							contentsDiv.append(returnObject);
							
							j++;
							setTimeout(function () {
								if (stopProcessFlag) return;
								loopContentsNodeToXML(j, contentsTables, contentsDiv, callback);
								count("loopContentsNodeToXML(j("+j+"), contentsTables(contentsTables.length:"+contentsTables.length+"), contentsDiv, callback);");
							}, oXML.delay);
						});
					}
					else
					{
						callback();
					}
				};
				
				var loopContentsTr = function (i, contentsTr, callback)
				{
					if (i < contentsTr.length)
					{
						var contentsTables = contentsTr.filter(":eq("+i+")").children(".node-contents").children();
						var contentsDiv = jQuery("<div></div>").addClass("node-contents");
						
						loopContentsNodeToXML(0, contentsTables, contentsDiv, function () {
							outputObj.append(contentsDiv);
							
							i++;
							setTimeout(function () {
								if (stopProcessFlag) return;
								loopContentsTr(i, contentsTr, callback);
								count("loopContentsTr(i("+i+"), contentsTr(contentsTr.length:"+contentsTr.length+"), callback);");
								
								if (startStatisticFlag == true)
									oXML.statisticAlert(i, contentsTr.length);
							}, oXML.delay);
						});
					}
					else
					{
						callback();
					}
				};
				
				var startStatisticFlag = false;
				if (contentsTr.length > 1
					&& oXML.StatisticFlag == false)
				{
					oXML.StatisticFlag = true;
					var startStatisticFlag = true;
				}
				
				if (startStatisticFlag == true)
					oXML.statisticAlert(0, contentsTr.length);
				
				loopContentsTr(0, contentsTr, function () {
					completeCallback(outputObj);
				});
				
				/*
				for (var i = 0; i < contentsTr.length; i++)
				{
					var contentsTables = contentsTr.filter(":eq("+i+")").children(".node-contents").children();
					var contentsDiv = jQuery("<div></div>").addClass("node-contents");
					
					loopContentsNodeToXML(0, contentsTables, function () {
						outputObj.append(contentsDiv);
						completeCallback(outputObj);
					});
					
					//for (var j = 0; j < contentsTables.length; j++)
					//	contentsDiv.append(oXML.nodeToXML(contentsTables.filter(":eq("+j+")")));
					//outputObj.append(contentsDiv);
					
				}	//for (var i = 0; i < contentsTr.length; i++)
				*/
			});
			
			/*
			for (var i = 0; i < contentTempTables.length; i++)
			{
				var returnObject = oXML.nodeToXML(contentTempTables.eq(i));
				contentTempDiv.append(returnObject);
			}
			outputObj.append(contentTempDiv);
			*/
			
			//contents
			
		}
		else if (type == "input")
		{
			outputObj.append(oXML.nodeAttrToXML(tableObj, "input-default-value"))
				.append(oXML.nodeAttrToXML(tableObj, "input-required"))
				.append(oXML.nodeAttrToXML(tableObj, "input-type"));
			var inputType = oXML.nodeAttrToXML(tableObj, "input-type").html();
			
			//if (inputType == "dropdown")
				outputObj.append(oXML.nodeAttrToXML(tableObj, "input-options"));
			
			//get values
			var valueTbody = tableObj.children("tbody");
			var valuesTr = valueTbody.children("tr.input");
			
			for (var i = 0; i < valuesTr.length; i++)
			{
				var valuesInputs = tableObj.children("tbody").children("tr.input:eq("+i+")").children("td.input-contents");
				
				//取得value的參數
				if (inputType == "texteditor")
				{
					var valueFromTextarea = valuesInputs.children("textarea:eq(0)").attr("value");
					
					if (oXML.displayTable == false)
						valueFromTextarea = XMLfunc.escapeHTML(valueFromTextarea);
					else
						valueFromTextarea = XMLfunc.unescapeHTML(valueFromTextarea);
					
					var valuesDiv = jQuery("<div></div>").addClass("input-values")
						.html(valueFromTextarea);
					outputObj.append(valuesDiv);
				}
				else if (inputType == "list")
				{
					//先找到底下有打勾的
					var checkedList = valuesInputs.find("input:checked");
					for (var j = 0; j < checkedList.length; j++)
					{
						var list = checkedList.eq(j);
						var valueFromList = list.attr("value");
						if (oXML.displayTable == false)
							valueFromList = XMLfunc.escapeHTML(valueFromList);
						else
							valueFromList = XMLfunc.unescapeHTML(valueFromList);
						var valuesDiv = jQuery("<div></div>").addClass("input-values")
							.html(valueFromList);
						outputObj.append(valuesDiv);
					}
				}
				else if (inputType == "fileupload")
				{
					var valueFromNode = valuesInputs.children(".fileupload:first").attr("value");
					if (oXML.displayTable == false)
						valueFromNode = XMLfunc.escapeHTML(valueFromNode);
					else
						valueFromNode = XMLfunc.unescapeHTML(valueFromNode);
					var valuesDiv = jQuery("<div></div>").addClass("input-values")
						.html(valueFromNode);
					outputObj.append(valuesDiv);
				}
				else
				{
					var valueFromNode = valuesInputs.find(":eq(0)").attr("value");
				
					
					
					if (inputType == "date" && valueFromNode == oXML.langDataPicker)
						valueFromNode = "";
					
					if (oXML.displayTable == false)
						valueFromNode = XMLfunc.escapeHTML(valueFromNode);
					else
						valueFromNode = XMLfunc.unescapeHTML(valueFromNode);
					var valuesDiv = jQuery("<div></div>").addClass("input-values")
						.html(valueFromNode);
					outputObj.append(valuesDiv);
				}
				
			}
			//return outputObj;
			completeCallback(outputObj);
		}
	}
	
	oXML.ajaxFileUploadExistXML = function (o2, url)
	{
		var d = o2;
		//var d = jQuery("#"+id).parents("td:first");
		//var url = d.children("input[type!=file]:first").val();
		if (url == "") return;
		
		var DEFAULT_fileupladConfig = {
			"inputName": "file", 
			"step": 2,
			"page": 1,
			"url": {
				"upload": '?action=json',
				"remove": location.pathname,
				"upload_jsp": ""
			},
			"maxHeight": "80",
			"imageFormat": ["jpg", "jpeg", "gif", "png", "image/png"],
			"langDelConfirm": "您確定要刪除？",
			"delData": function (bitstream_id, item_id) {
				return "submit_delete_bitstream_"+item_id+"_"+bitstream_id+"=移除";
			}
		};
		
		if (typeof(fileuploadConfig) == "undefined")
			var fileuploadConfig = new Object;
		jQuery.each(DEFAULT_fileupladConfig, function (name, value) {
			if (typeof(fileuploadConfig) != "undefined"
				&& typeof(fileuploadConfig[name]) != "undefined")
				value = fileuploadConfig[name];
			fileuploadConfig[name] = value;
		});
		
		var config = fileuploadConfig;
		var filename = decodeURI(url.substring(url.lastIndexOf("/")+1, url.length));
		var filenameDisplay = filename
		if (filenameDisplay.length > 10)
			filenameDisplay = filenameDisplay.substring(0, 10) + "...";
		var format = filename.substring(filename.lastIndexOf(".") + 1, filename.length).toLowerCase();
		if (filename.lastIndexOf(".") == -1) format = "Unknow";
		d.children("span:first").html("<a href=\""+url+"\">"+filenameDisplay+"</a> ("+format+")");
		if (location.href.indexOf("/submit") == -1)
		{
			var btnPreview = jQuery("<button type=\"button\" class=\""+url.replace("/retrieve/", "/preview/")+"\">"+"預覽"+"</button>")
				.appendTo(d.children("span:first"))
				.click(function () {
					window.open(this.className);
				});
		}
		//if is a pic, prepend img
			if (jQuery.inArray(format, config.imageFormat) != -1)
			{
				var img = jQuery("<img src=\""+url+"?width="+config.maxHeight+"&height"+config.maxHeight+"\" alt=\""+filename+"\" style=\"display:block\" border=\"0\" onload=\"this.style.height = '"+config.maxHeight+"px'\" />");

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
				});
				
				var a = jQuery("<a href=\""+url+"\" target=\"preview\"></a>").append(img);
				
				d.children("span:first").prepend(a);
			}
		d.children("input:file:first").hide();
		d.children("button.fileupload-do:first").hide();
		
		return d.contents();	
	};
	
	oXML.ajaxFileUploadDisplay = function (url) {

		if (url.indexOf("/retrieve/") == -1)
		{
			return url;
		}
		else
		{
			var temp = url.split("/");
			var filename = decodeURI(temp[(temp.length - 1)]);
			var format = filename.substring(filename.lastIndexOf(".") + 1, filename.length).toLowerCase();
			
			if (typeof(fileuploadConfig) == "undefined")
			{
				fileuploadConfig = {
					"inputName": "file", 
					"step": 2,
					"page": 1,
					"url": {
						"upload": '?action=json',
						"remove": location.pathname,
						"upload_jsp": ""
					},
					"maxHeight": 80,
					"imageFormat": ["jpg", "jpeg", "gif", "png", "image/png"],
					"langDelConfirm": "<%= langDelConfirm %>",
					"delData": function (bitstream_id, item_id) {
						return "submit_delete_bitstream_"+item_id+"_"+bitstream_id+"=移除";
					}
				};
			}
			var config = fileuploadConfig;
			
			var d = jQuery("<div></div>");
			d.append("<a href=\""+url+"\" target=\"_blank\">"+filename+"</a> ("+format+")");

			if (jQuery.inArray(format, config.imageFormat) != -1)
			{
				var img = jQuery("<img src=\""+url+"\" alt=\""+filename+"\" style=\"display:block\" border=\"0\" onload=\"this.style.height='"+config.maxHeight+"px'\" />");

				img.hide();
				img.load(function() {
					var i = jQuery(this);	//this image
					var w = i.width();
					var h = i.height();
					var maxHeight = config.maxHeight;
					if (h > maxHeight)
					{
						i.height(maxHeight);
						i.width(maxHeight/h*w);
					}
					i.show();
					return false;
				});
				var a = jQuery("<a href=\""+url+"\" target=\"preview\"></a>").append(img);
				
				d.prepend(a);
			}	//if (jQuery.inArray(format, config.imageFormat) != -1)
			return d;//.contents();
		}	//else
		
	};
	
	oXML.nodeAttrToXML = function(tableObj, attrName)
	{
		var attrValue = XMLNodeFn.nodeAttr(tableObj, attrName);
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
	
	oXML.XMLReform = function (inputText, completeCallback)
	{
		var output = "";

			var needleLast = 0;
			
			//幫標籤加上"……果然風險很大
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
			
			var replacePair = [
				["<div class=\"node\"><div class=\"node-type\">", "<DIV class=\"node\"><DIV class=\"node-type\">"],
				["</div><div class=\"node", "</DIV><DIV class=\"node"],
				["</div><div class=\"input", "</DIV><DIV class=\"input"],
				["</div></div><DIV class=\"node\">", "</DIV></DIV><DIV class=\"node\">"],
				["</div><DIV class=\"node\">", "</DIV><DIV class=\"node\">"],
				["</div></div></div></div>\n</div>", "</DIV></DIV></DIV></DIV>\n</div>"],
				["</div></div></div></div></div>", "</DIV></DIV></DIV></DIV></div>"],
				["</div><select", "</DIV><select"],
				["</select><div", "</select><DIV"],
				["</div><SELECT", "</DIV><SELECT"],
				["</div></div></DIV>", "</DIV></DIV></DIV>"],
				["selected ", "selected=\"true\" "],
				["selected>", "selected=\"true\">"],
				["</select></div></DIV>", "</select></DIV></DIV>"],
				["<DIV class=\"input-values\"></div></div>", "<DIV class=\"input-values\"></DIV></DIV>"]
			];
			
			/*
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
			output = replaceAll(output, "</select></div></DIV>", "</select></DIV></DIV>");
			output = replaceAll(output, "<DIV class=\"input-values\"></div></div>", "<DIV class=\"input-values\"></DIV></DIV>");
			*/
			
			var loopReplaceAll = function (i, replacePair, callback) {
				if (i < replacePair.length)
				{
					var reallyDo = replacePair[i][0];
					var repleaceWith = replacePair[i][1];
					output = replaceAll(output, reallyDo, repleaceWith);
					
					i++;
					setTimeout(function () {
						if (stopProcessFlag) return;
						loopReplaceAll(i, replacePair, callback);
						count("loopReplaceAll(i("+i+"), replacePair(replacePair.length:"+replacePair.length+"), callback);");
					}, oXML.delay);
				}
				else
				{
					callback(output);
				}
			};
			
			loopReplaceAll(0, replacePair, function(output) {
				output = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" + output;
				completeCallback(output);
			});

	};
	
	oXML.hasStorage = function () {
		if (typeof(oXML.storage) == "undefined"
			|| oXML.storage == null
			|| (typeof(oXML.storage) == "object" && oXML.storage.length == 0))
			return false;
		else
			return true;
	};
	
	oXML.bindFormOnSubmit = function () {
		if (oXML.hasStorage() == false)
			return;
		var boundObj = jQuery("form:not(.bind-xmlmetadata-onsubmit)"); //jQuery(oXML.storage).parents("form:first");
		var bindType = "submit";
		if (boundObj.length == 0)
		{
			boundObj = jQuery(oXML.storage).parents("body:not(.bind-xmlmetadata-onsubmit):first");
			bindType = "unload";
		}
		
		boundObj.addClass("bind-xmlmetadata-onsubmit");
			//.css("border", "1px solid green");;
		
		boundObj.bind(bindType, function () {
			var changed = jQuery("textarea.xmlmetadata-source.changed");
			if (changed.length > 0)
			{
				var c = changed.eq(0);
				var xmlObj = new XMLMetadata(c);
				stopProcessFlag = false;
				var msg = oXML.langAlertNowSaving1 + (changed.length)+ oXML.langAlertNowSaving2;
				xmlObj.setAlert(msg);
				xmlObj.openAlert();
				
				setTimeout(function () {
					if (stopProcessFlag) return;
					var complete = function () {
						var btn = jQuery("[type='submit'].this-button-submit:first");
						btn.click();
						if (btn.length == 0)
							alert("Please press same button again.");
						
						setTimeout(function () {
							if (stopProcessFlag) return;
							xmlObj.closeAlert();
						}, 10000);
					};
					
					var loopFormToXML = function(i, changed, callback) {
						if ((changed.length-i) > 0)
							var msg = oXML.langAlertNowSaving1 + (changed.length-i)+ oXML.langAlertNowSaving2;
						else
							var msg = oXML.langAlertNowSaving;
						oXML.setAlert(msg);
						if (i < changed.length)
						{
							var c = changed.eq(i);
							var xmlObj = new XMLMetadata(c);
							xmlObj.formToXML(true, function () {
								xmlObj.setChanged(false);
								//檢查用
									//xmlObj.storage.show();
									//alert(jQuery(xmlObj.storage.val()).find(".input-type").length);
									
								i++;
								setTimeout(function () {
									if (stopProcessFlag) return;
									loopFormToXML(i, changed, callback);
									count("loopFormToXML(i("+i+"), changed(changed.length:"+changed.length+"), callback);");
								}, oXML.delay);
							});
							
						}
						else
						{
							callback();
						}
					};
					
					loopFormToXML(0, changed, complete);
					
				}, oXML.delay);
				return false;
			}
		});
		
		
		//boundObj.find("[type='submit']:not(.bind-xmlmetadata-onsubmit)").click(function () {	
		jQuery("[type='submit']:not(.bind-xmlmetadata-onsubmit)").click(function () {
				//jQuery(this).css("border", "1px solid red");
				//jQuery(this).parents("form:first").css("border", "1px solid red");
				jQuery(this).addClass("this-button-submit");
			})
			.addClass("bind-xmlmetadata-onsubmit");
	};
	
	oXML.setChanged = function (flag) {
		if (typeof(flag) == "undefined")
			flag = true;
		
		if (flag == true)
			oXML.storage.addClass("changed");
		else
			oXML.storage.removeClass("changed");
	};
	
	oXML.initAlert = function () {
		if (oXML.alert.length == 0)
		{
			var xmlAlert = jQuery("<div class=\"xmlmetadata-alert\" title=\""+oXML.langAlertTitle+"\" style=\"padding: 10px;\"></div>")
				.appendTo(jQuery("body"));
			
			oXML.alert = xmlAlert;
			
			var btns = new Object;
			btns[oXML.langAlertStop] = function () {
				if (window.confirm(oXML.langAlertStopConfirm))
				{
					stopProcessFlag = true;
					jQuery(this).dialog("close");
				}
			};
			
			stopProcessFlag = false;
			
			xmlAlert.dialog({
				bgiframe: true,
				autoOpen: false,
				height: "auto",
				width: 400,
				modal: true,
				draggable: false,
				resizable: false,
				open: function () {
					jQuery(".xmlmetadata-alert").parents(".ui-dialog:first").find(".ui-icon-closethic, .ui-dialog-titlebar-close").hide();
				},
				buttons: btns
			});
		}
	};
	
	oXML.setAlert = function (msg) {
		//oXML.initAlert();
		oXML.alert.html(msg);
	};
	
	oXML.openAlert = function () {
		oXML.alert.dialog("open");
	};
	oXML.closeAlert = function () {
		jQuery(document).ready(function () {
			setTimeout(function () {
				oXML.alert.find(".statistic").remove();
				//alert(["實際耗費秒數："+parseInt(((new Date()).getTime() - oXML.statistisStartTime) / 1000), oXML.statistisStartTime]);
				oXML.alert.dialog("close");
			}, 500);
		});
	};
	oXML.isAlerting = function () {
		return (oXML.alert.parents(".ui-dialog:first").css("display") == "block");
	};
	
	oXML.statisticAlert = function (index, total) {
		if (oXML.alert.find(".statistic").length == 0)
		{
			jQuery("<div class=\"statistic\"></div>")
				.append("<span class=\"heading\">"+"此表單目前完成"+"</span>")
				.append("<span class=\"index\">0</span>")
				.append("<span class=\"percent\">%</span>")
				.append("<span class=\"total\" style=\"display:none\">100</span>")
				.appendTo(oXML.alert);
		}
		
		var statistic = oXML.alert.find(".statistic:first");
		if (typeof(total) != "undefined")
		{
			statistic.find(".total:first").html(total);
		}
		else
		{
			total = statistic.find(".total:first").html();
			total = parseInt(total);
		}
		if (total < 1)
		{
			alert("Statistic total error: "+total);
			return;
		}
		
		var percent = parseInt((parseInt(index) / total) * 100);
		
		if (index == 0)
		{
			oXML.statistisStartTime = (new Date()).getTime();
			percent = 2;
			statistic.find(".percent:first").html("% <br />(估計剩餘時間統計中)");
		}
		else
		{
			var interval = (new Date()).getTime() - oXML.statistisStartTime;
			if (interval > 0)
			{
				if (statistic.find(".predict").length > 0)
					var prevPredict = parseInt(statistic.find(".predict:first").html());
				else
					var prevPredict = 0;
				
				var predict = (interval / index) * (total - index) / 1000;
				
				//if (index == 1)
				//{
					predict = predict * (total / index);
				//}
				
				if (prevPredict != 0)
				{
					if (predict > prevPredict)
					{
						predict = prevPredict - 1;
					}
					else 
					{
						predict = predict + ((prevPredict - predict) / 2);
					}
				}
				
				if (index == total -1)
				{
					predict = 1;
				}
				
				if (predict == 0)
					predict = 1;
				
				predict = parseInt(predict);
				
				statistic.find(".percent:first").html("% <br />(估計剩餘時間<span class=\"predict\">"+predict+"</span>秒)");
			}
		}
		
		statistic.find(".index:first").html(percent);
	};
	
	return oXML;
}

XMLNodeFn = {
	repeatAction : function(thisButton)
	{
		var tbodyObj = jQuery(thisButton).parents("tbody:first");
		var type = XMLNodeFn.nodeAttr(thisButton, "node-type");
		
		//Copy temp then append to tbodyObj
			//get tr.?-temp
			var trTemp = tbodyObj.children("tr."+type+"-temp");
			var newTrObj = trTemp.clone(true);
			newTrObj.removeClass(type+"-temp").addClass(type);
			newTrObj.children("th").css("visibility", "hidden");
			newTrObj.show();
			
			//調整select的預設值
			var selecteds = newTrObj.find("select[value!='']");
			for (var i = 0; i < selecteds.length; i++)
			{
				var value = selecteds.eq(i).parents("table.table-input:first").children("caption:first").children("input:hidden[title='input-default-value']:first").val();
				selecteds.eq(i).children("option[value='"+value+"']").attr("selected", "selected");
				selecteds.eq(i).val(value);
			}
			
			//tbodyObj.append(newTrObj);
			jQuery(thisButton).parents("tr:first")
				.after(newTrObj);
			
			//檢查裡面是否有FCKeditor
			var fck = newTrObj.find("tr.input:visible textarea.embedFCKeditor");
			for (var i = 0; i < fck.length; i++)
			{
				try
				{
					fck.eq(i).doFCKeditorDialog();
				}
				catch (e)
				{
					if (typeof(errorNotImportDoFCKeditorDialog) == "undefined")
					{
						errorNotImportDoFCKeditorDialog = true;
						alert("doFCKeditorDialog not import! Error message: \n" + e);
					}
				}
			}
	
		XMLNodeFn.buttonAdjust(tbodyObj, type);
		
		//jQuery(thisButton).addClass("button-hidden").blur();
		
		var inputID = XMLNodeFn.getInputID(thisButton);
		(new XMLMetadata(inputID)).setChanged();
	},
	buttonAdjust : function(tbodyObj, type, inputType)
	{
		//讀取語言列
		var DEFAULT_XMLMETADATA_LANG = {
			"ButtonInsert": "插入",
			"ButtonRepeat": "新增"
		};
		
		if (typeof(XMLMETADATA_LANG) == "undefined")
			var XMLMETADATA_LANG = new Object;
		
		jQuery.each(DEFAULT_XMLMETADATA_LANG, function (name, value) {
			if (typeof(XMLMETADATA_LANG[name]) != "undefined")
				value = XMLMETADATA_LANG[name];
			XMLMETADATA_LANG[name] = value;
		});
		
		if (jQuery(".xmlmetadata-alert:first").parents("div.ui-dialog:first").css("display") != "none")
		{
			setTimeout(function () {
				XMLNodeFn.buttonAdjust(tbodyObj, type, inputType)
			}, 200);
			return;
		}
		
		//先作微調
		tbodyObj = jQuery(tbodyObj);
		if (tbodyObj.attr("nodeName").toLowerCase() != "tbody")
			tbodyObj = tbodyObj.parents("tbody:first");
		
		jQuery(document).ready(function () {
			setTimeout( function () {
				var trObj = tbodyObj.children("."+type+":visible");
				//Adjust title
				trObj.children(".input-title").addClass("title-hidden");
				trObj.children("."+type+"-title:first").removeClass("title-hidden");
				//alert(trObj.children("."+type+"-title:visible").length);
				/*
				if (trObj.children("."+type+"-title:visible").length == 0)
					trObj.children("."+type+"-title:first").css("visibility", "visible");
				*/
				tbodyObj.children("tr."+type+":first").children("."+type+"-title").css("visibility", "visible");
				//Adjust delete button
				var buttonDel = trObj.children("."+type+"-function").children(".buttonDel");
				var buttonMove = trObj.children("."+type+"-function").children(".buttonMove");
				buttonDel.css("display", "inline");
				if (type == "node" && trObj.length > 1)
					buttonMove.css("display", "inline");
				
				if (XMLNodeFn.nodeAttr(tbodyObj.parents("table:first"), "node-type") == "input"
					&& XMLNodeFn.nodeAttr(tbodyObj.parents("table:first"), "input-type") == "fileupload")
				{
					buttonDel.css("display", "none");
					var input = trObj.children(".input-contents").children("input:first");
					if (input.length == 1 && input.val() != "")
					{
						buttonDel.css("display", "inline");
					}
				}
				else if (trObj.length < 2)
				{
					buttonDel.css("display", "none");
					
					buttonMove.css("display", "none");
				}
				
				//Adjust repeat button
				var buttonRepeat = trObj.children("."+type+"-function").children("button.buttonRepeat");
				//buttonRepeat.removeClass("button-hidden");
				//if (buttonRepeat.filter(":visible").length > 1)
				//	buttonRepeat.filter(":visible").not(":last").addClass("button-hidden");
				buttonRepeat.filter(":visible").not(":last").html(XMLMETADATA_LANG.ButtonInsert);
				buttonRepeat.filter(":visible").filter(":last").html(XMLMETADATA_LANG.langButtonRepeat);
				
				//調整顯示標題
				var functionTitleCounterTr = tbodyObj.children("tr.node:visible");
				for (var i = 0; i < functionTitleCounterTr.length; i++)
				{
					var counter = functionTitleCounterTr.eq(i).children("td.node-function:last").children("div.node-function-title:first").children("span.counter:first");
					counter.html(": "+(i+1));
					
					/*
					//var contentsTbody = functionTitleCounterTr.eq(i).children("td.node-contents:visible").children("table").children("tbody");
					var contentsTbody = functionTitleCounterTr.eq(i).find("td.node-contents:visible > table > tbody");
					alert(contentsTbody.length);
					for (var j = 0; j < contentsTbody.length; j++)
					{
						var type = (contentsTbody.eq(j).parents("table:first").hasClass("table-input") ? "input" : "node");
						XMLNodeFn.buttonAdjust(contentsTbody.eq(j), type);
					}
					*/
				}
				
				XMLfunc.waitFor(function () {
					
				});
			}, 50);	//setTimeout( function () {
		});	//jQuery(document).ready(function () {
	},	//oXMLFn.buttonAdjust = function(tbodyObj, type, inputType)
	nodeAttr : function(thisObj, attrName)
	{
		if (jQuery(thisObj).children("caption:first").length == 0)
			var tableObj = jQuery(thisObj).parents("table:first");
		else
			var tableObj = thisObj;
		
		switch(attrName)
		{
			case "input-options":
				var attrObj = tableObj.children("caption:first").children("select:first").clone();
				var defaultValue = tableObj.children("caption:first").children("input:hidden[title='input-default-value']:first").val();
				var c = attrObj.children("option");
				var select = jQuery("<select></select>");
				for (var i = 0; i < c.length;i++)
				{
					var value = c.eq(i).attr("value");
					if (typeof(value) == "undefined" || value == null)
						value = c.eq(i).html();
					value = XMLfunc.escapeHTML(value);
					value = jQuery.trim(value);
					
					var html = c.eq(i).html();
					html = XMLfunc.escapeHTML(html);
					html = jQuery.trim(html);
					
					if (value == "" && html == "")
						continue;
					
					var option = jQuery("<option></option>").html(html)
						.attr("value", value);
					
					if (typeof(defaultValue) != "undefined"
						&& value == defaultValue)
						option.attr("selected", "selected");
					
					option.appendTo(select);
				}
				return select.children();
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
		{
			var value = attrObj.val();
			if (inputType == "texteditor") 
			{
				value = XMLfunc.escapeHTML(value);
			}
			return value;
		}
	},
	deleteNode : function(thisButton, force)
	{
		var noteType = jQuery(thisButton).parents("table:first").children("caption:first").children("input[type=hidden][title=node-type]").val();
		if (noteType == "input")
			var inputValue = jQuery.trim(jQuery(thisButton).parents("td:first").prevAll("td:first").children(":first").val());
		else 
		{
			var inputValue = "this is node tr";
			var force = false;
		}			
		
		if ((typeof(force) == "boolean" && force == true) 
			|| inputValue == ""
			|| window.confirm(((new XMLMetadata()).langDelConfirm)))
		//if (window.confirm(((new XMLMetadata()).langDelConfirm)));
		{
			var rootTable = jQuery(thisButton).parents("div.xml-root:first").children("table:first");
			//alert(rootTable.length);
			var trObj = jQuery(thisButton).parents("tr:first");
			var tbodyObj = jQuery(thisButton).parents("tbody:first");
			var type = XMLNodeFn.nodeAttr(thisButton, "node-type");
			
			//if del node has repeatbutton show 
			if (jQuery(thisButton).nextAll("button.buttonRepeat:first:visible").length > 0)
			{
				var prexTrObj = trObj.prevAll("tr:first");
				prexTrObj.children("td."+type+"-function").children("button.buttonRepeat").removeClass("button-hidden");
			}
			trObj.remove();	
			XMLNodeFn.buttonAdjust(tbodyObj, type); 
			
			XMLfunc.setChanged(rootTable);
		}
	},
	datePicker : function(thisInput)
	{
		jQuery(thisInput).datepicker({dateFormat: 'yymmdd'});	
		jQuery(thisInput).focus();
	},
	formChange : function(thisForm, inputID, force)
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
				(new XMLMetadata(inputID)).setChanged();
			else if (force == true)
				(new XMLMetadata(inputID)).setChanged(true);
		}
	},
	showNode : function(thisTitle)
	{
		var tableObj = jQuery(thisTitle).parents("tbody:first");
		t(tableObj.html());
	},
	getInputID : function (thisObj)
	{
		var divObj = jQuery(thisObj).parents("div.xml-root:first");
		var textareaObj = divObj.prevAll("textarea:first");
		return textareaObj.attr("id");
	},
	switchList : function(thisList, value)
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
	},
	moveAction: function (thisBtn, action) {
		var thisTr = jQuery(thisBtn).parents("tr.node:first");
		if (typeof(action) == "undefined")
			action = "up";
		
		if (action == "up")
			var targetTr = thisTr.prevAll("tr:visible:first");
		else
			var targetTr = thisTr.nextAll("tr:visible:first");
		
		if (targetTr.length == 0)
			return;
		else
		{
			if (action == "up")
				targetTr.before(thisTr);
			else
				targetTr.after(thisTr);
		}
		var type = XMLNodeFn.nodeAttr(thisBtn, "node-type");
		XMLNodeFn.buttonAdjust(thisBtn, type);
	}
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

var XMLfunc = {
	formToXML: function (thisObj)
	{
		var storage = jQuery(thisObj).parents("div.xml-root:first").prevAll("textarea.xmlmetadata-source:first");
		storage.removeClass("inited");
		var xmlObj = new XMLMetadata(storage);
		xmlObj.formToXML(true);
		//storage.change();
	},
	setChanged: function (thisObj)
	{
		var storage = jQuery(thisObj).parents("div.xml-root:first").prevAll("textarea.xmlmetadata-source:first");
		storage.removeClass("inited");
		var xmlObj = new XMLMetadata(storage);
		xmlObj.setChanged();
	},
	escapeHTML: function (input)
	{
		if (typeof(input) == "undefined")
		{
			return input;
		}
		else if (typeof(input) == "object")
		{
			if (input == null)
				return input;
			else if (typeof(input.value) != "undefined")
				return XMLfunc.escapeHTML(input.value);
			else
				return XMLfunc.escapeHTML(input.val());
		}
		else
		{
			
			var original = input;
			/*
			input = XMLfunc.replaceAll(input, "&nbsp;", " ");
			input = XMLfunc.replaceAll(input, "<", "&lt;");
			//input = XMLfunc.replaceAll(input, ">", "&gt;");
			input = XMLfunc.replaceAll(input, "\"", "&quot;");
			input = XMLfunc.replaceAll(input, "&", "&amp;");
			*/
			input = escape(input);
			return input;
		}
	},
	unescapeHTML: function (input)
	{
		if (typeof(input) == "undefined")
		{
			return input;
		}
		else if (typeof(input) == "object")
		{
			if (input == null)
				return input;
			else if (typeof(input.value) != "undefined")
				return XMLfunc.unescapeHTML(input.value);
			else
				return XMLfunc.unescapeHTML(input.val());
		}
		else
		{
			/*
			input = XMLfunc.replaceAll(input, "&amp;", "&");
			input = XMLfunc.replaceAll(input, "&lt;", "<");
			input = XMLfunc.replaceAll(input, "&gt;", ">");
			*/
			input = unescape(input);
			return input;
		}
	},
	replaceAll: function (str, reallyDo, replaceWith)
	{
		return str.replace(new RegExp(reallyDo, 'g'), replaceWith);
	},
	waitFor: function(func, time)
	{
		jQuery(document).ready(function () {
			if (typeof(time) == "undefined")
				time = 500;
			
			setTimeout(func, time);
		});
	},
	countChanged: function () {
		return jQuery("textarea.xmlmetadata-source.changed").length;
	},
	checkChanged: function (func) {
		var changed = jQuery("textarea.xmlmetadata-source.changed");
		if (changed.length > 0)
		{
			var c = changed.eq(0);
			var xmlObj = new XMLMetadata(c);
			var langAlertNowSaving = xmlObj.langAlertNowSaving;
			var langAlertNowSaving1 = xmlObj.langAlertNowSaving1;
			var langAlertNowSaving2 = xmlObj.langAlertNowSaving2;
			
			xmlObj.setAlert(langAlertNowSaving1 + changed.length + langAlertNowSaving2);
			xmlObj.openAlert();
			
			setTimeout(function () {
				var xmlObj = new XMLMetadata(c);
				
				for (var i = 0; i < changed.length; i++)
				{
					if ((changed.length-i) > 0)
						var msg = langAlertNowSaving1 + (changed.length-i) + langAlertNowSaving2;
					else
						var msg = langAlertNowSaving;
					xmlObj.setAlert(msg);
					var c = changed.eq(i);
					var xmlObj = new XMLMetadata(c);
					xmlObj.formToXML(true);
					xmlObj.setChanged(false);
					//檢查用
						//xmlObj.storage.show();
						//alert(jQuery(xmlObj.storage.val()).find(".input-type").length);
				}
				
				var btn = jQuery(".this-button-submit:first");
				btn.click();
				if (btn.length == 0)
					alert("Please press same button again.");
				
				if (typeof(func) == "undefined")
				{
					setTimeout(function () {
						xmlObj.closeAlert();
					}, 10000);
				}
				else
				{
					func();
					xmlObj.closeAlert();
				}
			}, 500);
			return false;
		}
		else
			return true;
	}
};	//var XMLfunc = {	

jQuery.fn.extend({
	doXMLMetadata: function (params) {
		var thisObj = jQuery(this);
		var xm = new XMLMetadata(jQuery(thisObj));
		if (typeof(params) == "object")
		{
			if (typeof(params.basePath) != "undefined")
				xm.basePath = params.basePath;
			if (typeof(params.FCKeditorPath) != "undefined")
				xm.setFCKeditorPath(params.FCKeditorPath);
			if (typeof(params.workspaceItemID) != "undefined")
				xm.workspaceItemID = params.workspaceItemID;
			if (typeof(params.fieldTitle) != "undefined")
				xm.fieldTitle = params.fieldTitle;
			if (typeof(params.hasMultipleFiles) != "undefined")
				xm.hasMultipleFiles = params.hasMultipleFiles;
			if (typeof(params.langNotHasMultipleFiles) != "undefined")
				xm.langNotHasMultipleFiles = params.langNotHasMultipleFiles;
			if (typeof(params.nonInternalBistreamsID) != "undefined")
				xm.nonInternalBistreamsID = params.nonInternalBistreamsID;
			xm.createRootForm();
		}
		else if (typeof(params) == "boolean")
		{
			if (params == true)
			{
				xm.createRootForm();
			}
			else
			{
				xm.displayTable = true;
				xm.createRootForm();
			}
		}
		else if (typeof(params) == "string" && params == "displayTable")
		{
			if (jQuery.trim(jQuery(thisObj).val()) == ""
				|| jQuery(jQuery(thisObj).val()).hasClass("xml-root") == false)
				return;
			if (jQuery(".xml-display-dialog").length == 0)
			{
				var dialogContainer = jQuery("<div class=\"xml-display-dialog\"><div style=\"min-width: 600px;\"><textarea></textarea></div></div>")
					.appendTo(jQuery("body"));
				
				var langClose = "關閉";
				if (typeof(XMLMETADATA_LANG) != "undefined")
					langClose = XMLMETADATA_LANG.Close;
				
				var btns = {};
				btns[langClose] = function () {
						alert(jQuery(".xmlmetadata-alert").length);
					jQuery(this).dialog("close");
				};
				
				dialogContainer.dialog({
					bgiframe: true,
					autoOpen: false,
					/*height: "auto",*/
					width: 800,
					height: 600,
					/*modal: true,*/
					draggable: true,
					resizable: true,
					buttons: btns
				});
			}
			
			thisObj.hide();
			
			var langView = "檢視";
				if (typeof(XMLMETADATA_LANG) != "undefined")
					langView = XMLMETADATA_LANG.View;
			var displayBtn = jQuery("<button type=\"button\" class=\"doXMLMetadata-button\">"+langView+"</button>")
				.insertAfter(thisObj)
				.click(function () {
					
					jQuery(".xml-display-dialog:first").empty()
						.append(jQuery("<textarea></textarea>"));
					
					var xml = jQuery(this).prevAll("textarea:first").val();
					var dialogContainer = jQuery(".xml-display-dialog:first");
					dialogContainer.dialog("open");
					dialogContainer.css("width", "600px");
					dialogContainer.css("max-height", "480px");
					dialogContainer.dialog("option", "height", "auto");
					dialogContainer.dialog("option", "width", "600");
					
					var textarea = dialogContainer.find("textarea:first");
					textarea.val(xml);
					var xm = new XMLMetadata(textarea);
					xm.displayTable = true;
					dialogContainer.dialog('option', 'position', 'center');
					
					//取得title
					var title = jQuery.trim(jQuery(this).parent().prev().text());
					if (title.substring(title.length-1, title.length) == ":")
						title = title.substring(0, title.length-1);
					if (title.length > 34)
						title = title.substring(0, 34) + "...";
					
					dialogContainer.dialog("option", "title", title);
					//xm.displayRootTable();
					xm.createRootForm(function () {
						jQuery(document).ready(function () {
							setTimeout(function () {
								dialogContainer.dialog('option', 'position', 'center');
								var d = jQuery("div.xmlmetadata-alert");
								for (var i = 0; i < d.length; i++)
									d.eq(i).dialog("close");
							}, 100);
						});
					});
				});
			
			//jQuery(document).ready(function () {
			//	displayBtn.click();
			//});
			
			
			//xm.displayTable = true;
			//xm.createRootForm();
		}
		else
		{
			xm.createRootForm();
		}
	}
});

jQuery.extend({
	XMLMetadataDisplayTable: function () {
		jQuery(document).ready(function () {
			var xmlSourceCollection = jQuery("div.xml-root:has(DIV.node)");
			
			if (xmlSourceCollection.length > 0 && jQuery(".xml-display-dialog").length == 0)
			{
				var dialogContainer = jQuery("<div class=\"xml-display-dialog\"><textarea></textarea></div>")
					.appendTo(jQuery("body"));
				
				dialogContainer.dialog({
				bgiframe: true,
				autoOpen: false,
				height: "auto",
				width: "auto",
				modal: true,
				draggable: true,
				resizable: true,
				open: function () {
						jQuery(".ajaxfileupload-now-uploading:first").parents(".ui-dialog:first").find(".ui-icon-closethic, .ui-dialog-titlebar-close").hide();
					},
				buttons: {
						"close": function () {
							jQuery(this).dialog("close");
						}
					}
				});
			}
			for (var i = 0; i < xmlSourceCollection.length; i++)
			{
				var container = xmlSourceCollection.eq(i);
				var h = container.html();
				
				var source = "<div class=\"xml-root\">" + h + "</div>";
				var textarea = jQuery("<textarea></textarea>")
					.insertAfter(container)
					.val(source);
				xmlSourceCollection.eq(i).remove();
				textarea.doXMLMetadata("displayTable");
			}
		});
	}
});

function v(v) {
	if (typeof(tCounter) == "undefined")
		tCounter = 0;
	else
		tCounter++;
	
	if (typeof(vFlag) == "undefined")
		vFlag = true;
	
	if (vFlag == false)
		return;
	
	if (typeof(v) == "undefined")
		v = "測試用訊息";
	
	vFlag = window.confirm(tCounter + ": |" + v + "| ");
}

function count(msg) {
	/*
	if (typeof(counter) == "undefined")
		counter = 0;
	
	if (counter % 300 == 299)
	{
		jQuery("#counterMsg").removeAttr("id");
	}
	
	
	if (jQuery("#counterMsg").length == 0)
	{
		jQuery("<div id=\"counterMsg\"></div>")
			.prependTo(jQuery("body"));
		
		jQuery("<div class=\"counter\" style=\"border-bottom: 1px solid red;\"></div>")
			.appendTo(jQuery("#counterMsg"));
	}
	if (typeof(msg) == "undefined")
		msg = "";
	
	var counterMsg = jQuery("<div class=\"msg\"></div>")
		.html(counter+":"+msg);
	
	jQuery("#counterMsg").append(counterMsg);
	jQuery("#counterMsg .counter").html(counter);
	counter++;
	*/
}
