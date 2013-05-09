var FormCollectionObject = function(formMapNode, formDefinitionsNode)
{
	var LANG = {
		HandleEditor: {
			Heading: "請設定套用此form的collection-handle",
			DeleteConfirm: "欄位裡面還有值，確定要刪除？"
		},
		Delete: "刪除",
		Add: "新增",
		PageEditor: {
			"MustHasPage": "最少要有一頁！",
			"DeleteConfirm": "確定要刪除此頁？此動作無法復原"
		},
		Insert: "插入",
		Insert: "插入",
		Move: {
			Up: "上移",
			Down: "下移"
		},
		Button: {
			Edit: "編輯"
		},
		OnlyDefault: "只有traditional表單可以使用「default」類別控制碼"
	};
	
	//if (typeof(InputFomrsEditorLang) != "undefined")
	//	LANG = InputFomrsEditorLang.FormCollectionObject;
	if (typeof(getInputFormsEditorLang) != "undefined")
		var LANG = getInputFormsEditorLang().FormCollectionObject;
	
	var fcObj = this;
	
	fcObj.forms = new Array();
	
	fcObj.parseFormMap = function (fmNode)
	{
		var nameMaps = fmNode.children(".name-map");
		for (var i = 0; i < nameMaps.length; i++)
		{
			var formName = nameMaps.eq(i).attr("form-name");
			var collectionHandle = nameMaps.eq(i).attr("collection-handle");
			fcObj.pushForm(formName, collectionHandle);
		}
	};
	
	fcObj.parseFormDefinitions = function (fdNode)
	{
		var forms = fdNode.children(".form");
		for (var i = 0; i < forms.length; i++)
		{
			var name = forms.eq(i).attr("name");
			var index = fcObj.indexForm(name);
			if (index != -1)
			{
				fcObj.forms[index].setPage(forms.eq(i));
			}
		}
	}
	
	fcObj.pushForm = function(name, handle)
	{
		var index = fcObj.indexForm(name);
		
		if (index != -1)
		{
			fcObj.forms[index].pushHandle(handle);	
		}
		else
		{
			var form = FormObject(name, handle);
			fcObj.forms.push(form);
		}
	};
	
	fcObj.indexForm = function (formName, offset)
	{
		if ( typeof(parseInt(offset)) == "number" )
			offset = 0;
		
		for (var i = offset; i < fcObj.forms.length; i++ )
		{
			var form = fcObj.forms[i];
			if (formName == form.getName())
				return i;
		}
		
		return -1;
	};
	
	fcObj.count = function()
	{
		return fcObj.forms.length;
	};
	
	fcObj.get = function(index)
	{
		if (typeof(index) != "number")
			index = 0;
		return fcObj.forms[index];
	};
	
	fcObj.initFormEditor = function()
	{
		var output = new Array();
		for (var i = 0; i < fcObj.count(); i++)
		{
			var handles = fcObj.forms[i].getHandle();
			var pages = fcObj.forms[i].getPage();
			var editor = fcObj.createFormEditor(handles, pages);
			
			if (i > 0)
				editor.hide();
			
			output.push(editor);
		}
		
		return output;
	};
	
	fcObj.createFormEditor = function (handles, pages)
	{
		var editor = jQuery("<div class=\"form-editor\"></div>");
		var handleEditor = fcObj.createHandleEditor(handles);
			handleEditor.appendTo(editor);
		var pageEditor = fcObj.initPageEditor(pages);
			pageEditor.appendTo(editor);
		return editor;
	};
	
	fcObj.createHandleEditor = function(handles)
	{
		var handleEditor = jQuery("<dl></dl>");
		
		var heading = jQuery("<dt>"+LANG.HandleEditor.Heading+"</dt>")
			.prependTo(handleEditor);
			
		var getHandleList = function (value) {
			if (typeof(value) == "undefined")
				value = "";
			var dd = jQuery("<dd class=\"collection-handle-list\"><input type=\"text\" class=\"collection-handle text\" value=\""+value+"\" /></dd>");
			
			if (value != "default")
			{
				var delBtn = jQuery("<button type=\"button\" class=\"icon delete\" title=\""+LANG.Delete+"\">"+LANG.DeleteImg+"</button>")
					.prependTo(dd)
					.click(function () {
						var thisList = jQuery(this).parents(".collection-handle-list:first");
						if (jQuery.trim(dd.children("input.collection-handle").val()) != "")
						{
							if (window.confirm(LANG.HandleEditor.DeleteConfirm) == true)
								thisList.remove();
						}
						else
							thisList.remove();
					});
			}
			else
			{
				dd.find("input").attr("disabled", "disabled");
			}
			
			dd.find("input").change(function () {
				if (jQuery.trim(this.value) == "default")
				{
					var _passed = false;
					
					if (jQuery("#form_select").val() == "traditional")
					{
						var _inputs = jQuery(this).parents("dl:first").find("input:text");
						var _defaultCount = 0;
						for (var _i = 0; _i < _inputs.length; _i++)
						{
							if (jQuery.trim(_inputs.eq(_i).val()) == "default")
								_defaultCount++;
						}
						if (_defaultCount == 1)
							_passed = true;
					}
					
					
					if (_passed == false)
					{
						//alert("Only traditional form can use \"default\" handle");
						//alert("只有traditional表單可以使用「default」類別控制碼");
						alert(LANG.OnlyDefault);
						this.value = "";
					}
					else
					{
						jQuery(this).val("default");
						jQuery(this).attr("disabled", "disabled");
						jQuery(this).parents("dd:first").find("button").remove();
					}
				}
			});
			
			return dd;
		};
		
		if (typeof(handles) == "object")
		{
			for (var j = 0; j < handles.length; j++)
			{
				var dd = getHandleList(handles[j])
					.appendTo(handleEditor);
			}
		}
		else if (typeof(handles) != "undefined")
		{
			var dd = getHandleList(handles)
				.appendTo(handleEditor);
		}
		else	//typeof(handle) == "undefined"
		{
			//加入空的dd
			var dd = getHandleList()
				.appendTo(handleEditor);
		}
		
		var addHandleDD = jQuery("<dd></dd>")
			.addClass("add-handle")
			.appendTo(handleEditor);
		var addHandleField = jQuery("<button type=\"button\" title=\""+LANG.Add+"\">"+LANG.AddImg+" "+LANG.Add+"</button>")
			.appendTo(addHandleDD)
			.click(function () {
				var handleEditor = jQuery(this).parents("dl:first").children("dd:last");
				var dd = getHandleList()
					.insertBefore(handleEditor);
			});
		return handleEditor;
	};
	
	fcObj.initPageEditor = function (pages) 
	{
		var pcEditor = jQuery("<fieldset class=\"page-editor\"></fieldset>");
	
		var legend = jQuery("<legend></legend>").prependTo(pcEditor);
		var pageSelect = jQuery("<select name=\"page_select\" class=\"page-select\"></select>")
			.appendTo(legend)
			.change(function () {
				var index = getPageSelectIndex();
				var pcEditor = jQuery(this).parents("fieldset.page-editor:first");
				pcEditor.children("div.page-content:visible").hide();
				var content = pcEditor.children("div.page-content:eq("+index+")").show();
				Utils.initFCKEditor(content);
			});
		
		//先來編輯legend吧
			if (typeof(pages) == "object")
			{
				for (var i = 0; i < pages.length; i++)
				{
					//try
					//{
						var pgEditor = fcObj.createPageEditor(pages[i], pages.length);
					//}
					//catch(e) { alert([e, pages[i] , pages.length]); }
				
					var option = pgEditor.option
						.appendTo(pageSelect);
					var content = pgEditor.content
						.appendTo(pcEditor);
					if (i > 0)	
					{
						content.hide();
					}
					else
						Utils.initFCKEditor(content);
				}
			}
			else
			{
				var pgEditor = fcObj.createPageEditor();
				
				var option = pgEditor.option
					.appendTo(pageSelect);
				var content = pgEditor.content
					.appendTo(pcEditor);
				Utils.initFCKEditor(content);
			}
		
		var getPageSelectIndex = function()
		{
			var index = Utils.getSelectIndex(pageSelect);
			return index;
		};
		
		var sortPageSelect = function()
		{
			var pageNumber = pageSelect.children("option").length;
			pageSelect.empty();
			for (var i = 0; i < pageNumber; i++)
			{
				var option = jQuery("<option value=\""+(i+1)+"\">Page: "+(i+1)+"</option>")
					.appendTo(pageSelect);
			}
			
			var pageContents = pcEditor.find("div.page-content");
			for (var i = 0; i < pageContents.length; i++)
				Utils.adaptPageAttr(pageContents.eq(i));
			var index = pageContents.index(pageContents.filter(":visible"));
			pageSelect.children(":eq("+index+")").attr("selected", "selected");
		};
		
		//加一些function的按鈕吧
		var btnDel = jQuery("<button type=\"button\" class=\"icon delete\" title=\""+LANG.Delete+"\">"+LANG.DeleteImg+"</button>")
			.appendTo(legend)
			.click(function () {
				if (pageSelect.children("option").length < 2)
				{
					alert(LANG.PageEditor.MustHasPage);
					return;
				}
				else if (window.confirm(LANG.PageEditor.DeleteConfirm))
				{
					//先取得現在頁數
					var index = getPageSelectIndex();
					
					pageSelect.children("option:eq("+index+")").remove();
					//pageSelect.change();
					pcEditor.children("div.page-content:eq("+index+")").remove();
					var next = pcEditor.children("div.page-content:eq("+index+")");
					if (next.length == 0)
						next = pcEditor.children("div.page-content:last");
					next.show();
					sortPageSelect();
				}
			});
		
		var btnInsert = jQuery("<button type=\"button\" class=\"icon insert\" title=\""+LANG.Insert+"\">"+LANG.InsertImg+"</button>")
			.appendTo(legend)
			.click(function () {
				//先取得現在頁數
				var index = getPageSelectIndex();
				
				var pgEditor = fcObj.createPageEditor();
				
				var option = pgEditor.option
					.insertAfter(pageSelect.children("option:eq("+index+")"));
				var anchor = pcEditor.children("div.page-content:eq("+index+")").hide();
				var content = pgEditor.content
					.insertAfter(anchor);
				Utils.initFCKEditor(content);
				sortPageSelect();
			});
		
		var btnMoveUp = jQuery("<button type=\"button\" class=\"icon move-up\" title=\""+LANG.Move.Up+"\">"+LANG.Move.UpImg+"</button>")
			.appendTo(legend)
			.click(function () {
				var index = getPageSelectIndex();
				
				var content = pcEditor.children("div.page-content:eq("+index+")");
				content.insertBefore(content.prev());
				
				if (index > 0)
				{
					pageSelect.children("option:eq("+(index-1)+")").attr("selected", "selected");
					pageSelect.change();
				}
			});
		var btnMoveDown = jQuery("<button type=\"button\" class=\"icon move-down\" title=\""+LANG.Move.Down+"\">"+LANG.Move.DownImg+"</button>")
			.appendTo(legend)
			.click(function () {
				var index = getPageSelectIndex();
				
				var content = pcEditor.children("div.page-content:eq("+index+")");
				content.insertAfter(content.next());
				
				if (index < pageSelect.children("option").length)
				{
					pageSelect.children("option:eq("+(index+1)+")").attr("selected", "selected");
					pageSelect.change();
				}
			});
		
		
		return pcEditor;
	};
	
	fcObj.createPageEditor = function(page, pageNum)
	{
		var pgEditor = new Object;
		
		//try	{
			if (typeof(page) == "undefined")
				page = PageObject();
			
			pgEditor.option = jQuery("<option value=\""+page.number+"\">Page: "+page.number+"</option>");
			pgEditor.content = jQuery("<div class=\"page-content\"><table class=\"page-content-table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><thead></thead><tbody class=\"page-content-tbody\"></tbody></table></div>");
		
		//} catch(e) {alert(1); }
		//try	{

			var attrEditor = jQuery("<tr><th class=\"function\"></th><td class=\"preview\"></td></tr>")
				.appendTo(pgEditor.content.find("table:first thead:first"));
			
			var btnEdit = jQuery("<button type=\"button\" class=\"icon edit\" title=\""+LANG["Button"]["Edit"]+"\">"+LANG["Button"]["EditImg"]+"</button>").appendTo(attrEditor.children("th.function"))
				.click(function () {
					var label = jQuery(this).parents("tr:first").find("input.page-label[type='hidden']").val();
					var hint = jQuery(this).parents("tr:first").find("input.page-hint[type='hidden']").val();
					PARAMETER = {
						"label": label,
						"hint": hint
					};
					jQuery("#prompt_page_attr").dialog("open");
				});
			
		//} catch(e) {alert(2); } try	{
		
			var heading = "Page "+page.number;
			if (typeof(pageNum) != "undefined")
				heading = heading + "/" + pageNum;
			var label = page.label;
			if (label != "")
				heading = heading +": " + label;
			
		//} catch(e) {alert(3); } try	{
		
			var previewLabel = jQuery("<div class=\"preview-label\"></div>").appendTo(attrEditor.children("td.preview"))
				.html(heading);
			var previewHint = jQuery("<div class=\"preview-hint\"></div>").appendTo(attrEditor.children("td.preview"))
				.html(page.hint);
			
		//} catch(e) {alert(4); } try	{
		
			var dataLabel = jQuery("<input type=\"hidden\" class=\"page-label\" />").appendTo(attrEditor.children("td.preview"))
				.val(page.label)
				.change(function () {
					var label = this.value;
					
					var pageEditor = jQuery(this).parents(".page-editor:first");
					var pageContent = jQuery(this).parents(".page-content:first");
								
					var pageSelect = pageEditor.find("select.page-select:first");
					var pageNum = pageSelect.children("option").length;
					var pageNow = pageEditor.children("div.page-content").index(pageContent);
					pageNow++;
					
					var heading = "Page "+pageNow+"/"+pageNum;
					if (label != "")
						heading = heading + ": " + label;
					
					var previewLabel = jQuery(this).parents("td:first").find("div.preview-label")
						.html(heading);
				});
				
			var dataHint = jQuery("<input type=\"hidden\" class=\"page-hint\" />").appendTo(attrEditor.children("td.preview"))
				.val(page.hint)
				.change(function () {
					var hint = this.value;
					var previewHint = jQuery(this).parents("td:first").find("div.preview-hint")
						.html(hint);
				});
		
		//} catch(e) {alert(5); } try	{
		
			var fields = page.fields;
			
			for (var i = 0; i < fields.length; i++)
			{
				var fieldEditor = fields[i].getEditor();
				//fieldEditor.appendTo();
				pgEditor.content.find("tbody:first").append(fieldEditor);
				
			}
		//} catch(e) {alert(6); }
	
		pgEditor.content.find("tbody:first")
			.append(getFieldAdd())
			.prepend(getFieldAdd());	
				
		return pgEditor;
	};
	
	var getFieldAdd = function () {
		var tr = jQuery("<tr class=\"field-add\"><td colspan=\"2\"></td></tr>");
		
		var btnAdd = jQuery("<button type=\"button\" title=\""+LANG.Add+"\">"+LANG.AddImg+" "+LANG.Add+"</button>")
			.appendTo(tr.find("td:first"))
			.click(function () {
				var thisTr = jQuery(this).parents("tr.field-add:first");

				var field = FieldObject();
				var editor = field.getEditor();
	
				var nextTr = thisTr.nextAll("tr:first");
				if (nextTr.length != 0)
				{
					nextTr.before(editor);
				}
				else
				{
					nextTr = thisTr.prevAll("tr:first");
					nextTr.after(editor);
				}
				
				editor.addClass("field-data-source")
				//	.css("background-color", "#FFFF00");
				jQuery("#prompt_field_editor").dialog("open");
				
			});
		return tr;
	};
	
	//init 
	if (typeof(formMapNode) != "undefined")
		fcObj.parseFormMap(formMapNode);
	if (typeof(formDefinitionsNode) != "undefined")
		fcObj.parseFormDefinitions(formDefinitionsNode);
	
	return fcObj;
}	//var FormCollectionObject = function(formMapNode, formDefinitionsNode)
FormCollection = FormCollectionObject();
