<%--
  - messages-main.jsp
  -	語系檔備份：
jsp.layout.navbar-admin.editmessages = \u7de8\u8f2f\u8a9e\u7cfb\u6a94

jsp.dspace-admin.messages-main.title = \u7de8\u8f2f\u8a9e\u7cfb\u6a94
jsp.dspace-admin.messages-main.heading = \u7de8\u8f2f\u8a9e\u7cfb\u6a94
jsp.dspace-admin.messages-main.submit_saved = \u5df2\u7d93\u5132\u5b58\uff01\u8acb\u91cd\u65b0\u555f\u52d5\u4f3a\u670d\u5668\u4ee5\u770b\u5230\u4fee\u6539\u7684\u7d50\u679c\u3002
jsp.dspace-admin.messages-main.submit_cancel = \u53d6\u6d88\u7de8\u8f2f
jsp.dspace-admin.messages-main.default.language = \u76ee\u524d\u9810\u8a2d\u7684\u8a9e\u7cfb\u662f\uff1a
jsp.dspace-admin.messages-main.change-default-language = \u5982\u9700\u8981\u8b8a\u66f4\u7cfb\u7d71\u9810\u8a2d\u8a9e\u7cfb\uff0c\u8acb\u4fee\u6539dspace.cfg\u4e2d\u7684default.language\u8a2d\u5b9a\u3002
jsp.dspace-admin.messages-main.edit = \u7de8\u8f2f\u8a9e\u7cfb\u6a94
jsp.dspace-admin.messages-main.create = \u5efa\u7acb\u65b0\u7684\u8a9e\u7cfb\u6a94
jsp.dspace-admin.messages-main.create.source = \u5f9e\u4f86\u6e90\u6a94\u6848\u8907\u88fd
jsp.dspace-admin.messages-main.create.to-file-name = \u5230\u65b0\u7684\u8a9e\u7cfb\u6a94\u540d\u7a31
jsp.dspace-admin.messages-main.lang-collision = \u4e0d\u80fd\u8ddf\u73fe\u6709\u7684\u8a9e\u7cfb\u6a94\u540d\u7a31\u91cd\u8907\uff01
jsp.dspace-admin.messages-main.lang-empty = \u8a9e\u7cfb\u6a94\u540d\u7a31\u4e0d\u80fd\u662f\u7a7a\u503c\uff01
jsp.dspace-admin.messages-main.lang-active = \u73fe\u5728\u4f7f\u7528
  --%>


<%--
  - Display list of Groups, with 'edit' and 'delete' buttons next to them
  -
  - Attributes:
  -
  -   groups - Group [] of groups to work on
  --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.Constants" %>

<%
try
{
    String submit_action = (String)request.getAttribute("submit_action");

    if (submit_action == null)
        submit_action = "false";

	String position = (String)request.getAttribute("position");	
	if (position == null)
		position = "";
	
	String defaultLanguage = (String)request.getAttribute("defaultLanguage");
	if (defaultLanguage == null)
		defaultLanguage = "";
	
	String defaultLanguageFilename = (String)request.getAttribute("defaultLanguageFilename");
	if (defaultLanguageFilename == null)
		defaultLanguageFilename = "";
	
	String[] messagesProperties = (String[])request.getAttribute("messagesProperties");
	if (messagesProperties == null)
		messagesProperties = new String[0];
%>

<dspace:layout titlekey ="jsp.dspace-admin.messages-main.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin"
               nocache="true">
    
  <table width="95%">
    <tr>
      <td align="left">
        <%-- <h1>News Editor</h1> --%>
        <h1>
			<fmt:message key="jsp.dspace-admin.messages-main.heading"/>
			<%-- 編輯語系檔 --%>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#editmessages" %>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>
<style type="text/css">
.help { font-size: smaller; font-weight:normal;}
</style>
<%
if ( submit_action.equals("saved") && !position.equals("") )
{
	out.print("<div class=\"dspace-admin-alert\">"
		+position
		+LocaleSupport.getLocalizedMessage(pageContext
			, "jsp.dspace-admin.messages-main.submit_saved")
		+"</div>");
//	out.print("<div>"+position+"已經儲存！請重新啟動Tomcat網頁伺服器以看到修改的結果。</div>");
}
else if ( submit_action.equals("cancel_edit") && position.equals("") )
{
	//out.print("<div>取消編輯</div>");
	out.print("<div class=\"dspace-admin-alert\">"
		+LocaleSupport.getLocalizedMessage(pageContext
			, "jsp.dspace-admin.messages-main.submit_cancel")
		+position
		+"</div>");
}
else if ( submit_action.equals("integrated-success") && position.equals("") )
{
	//out.print("<div>取消編輯</div>");
	out.print("<div class=\"dspace-admin-alert\">"
		+LocaleSupport.getLocalizedMessage(pageContext
			, "jsp.dspace-admin.messages-main.submit_integrated-success")
		+position
		+"</div>");
}
else if ( submit_action.equals("integrated-fail") && position.equals("") )
{
	//out.print("<div>取消編輯</div>");
	out.print("<div class=\"dspace-admin-alert\">"
		+LocaleSupport.getLocalizedMessage(pageContext
			, "jsp.dspace-admin.messages-main.submit_integrated-fail")
		+position
		+"</div>");
}
%>
	<h2>
		<fmt:message key="jsp.dspace-admin.messages-main.default.language"/>
		<%--目前預設的語系是：--%>
		<%
			out.print(defaultLanguage);
		%>
	</h2>
	
	
	<div class="help">
		<fmt:message key="jsp.dspace-admin.messages-main.change-default-language"/>
		<%--如需要變更系統預設語系，請修改dspace.cfg中的預設語系(default.language)設定。--%>
		(<a href="<%= request.getContextPath() %>/dspace-admin/config-edit" target="config">
			<fmt:message key="jsp.layout.navbar-admin.config-edit"/>
		</a>)
	</div>
 <form action="<%= request.getContextPath() %>/dspace-admin/messages-edit" method="post">
    <table class="miscTable" align="center" width="80%">
            <tr>
				<th id="t2" class="evenRowOddCol" width="30%">
					<label for="position">
						<fmt:message key="jsp.dspace-admin.messages-main.edit"/>
						<%-- 編輯語系檔 --%>
					</label>
				</th>
                <td headers="t2" class="evenRowEvenCol">
        			<div style="text-align:center;">
					<select name="position" id="position">
						<%
					try
					{
						String active = LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-main.lang-active");	//現在使用
						String filename = "Messages.properties";
						if (!defaultLanguage.equals("en") && !defaultLanguage.equals("en_US"))
							filename = "Messages_"+defaultLanguage+".properties";
						for (int i = 0; i < messagesProperties.length; i++)
						{
							if (messagesProperties[i] == null)
								continue;
							String lang = messagesProperties[i];

							if (lang.equals(filename))
								out.println("<option value=\""+lang+"\" selected=\"true\">"+lang+" ("+active+")</option>");
							else
								out.println("<option value=\""+lang+"\">"+lang+"</option>");
						}
					}
					catch (Exception e) { e.printStackTrace(); }
						%>
					</select>
					</div>
					<div style="text-align:center;">
						<input type="hidden" name="submit_action" value="submit_edit" />
	                    <input type="submit" value="<fmt:message key="jsp.dspace-admin.general.edit"/>" />
	                    <input type="button" value="開新視窗編輯" onclick="openWindowSubmit(this);" />
	                 </div>
                </td>
			</tr>
    </table>
  </form>
  <form action="<%= request.getContextPath() %>/dspace-admin/messages-edit" method="post" onsubmit="return checkCreate(this);">
    <table class="miscTable" align="center" width="80%">
            <tr>
				<th id="t3" class="oddRowOddCol" width="30%">
					<label for="filename">
						<fmt:message key="jsp.dspace-admin.messages-main.create"/>
						<%-- 建立新的語系檔 --%>
					</label>
				</th>
                <td headers="t3" class="oddRowEvenCol">
					<div>
					<fmt:message key="jsp.dspace-admin.messages-main.create.source"/>
					<%-- 從來源檔案複製 --%>
					<select name="source" id="source">
						<%
						String active = LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-main.lang-active");	//現在使用
						String filename = "Messages.properties";
						if (!defaultLanguage.equals("en") && !defaultLanguage.equals("en_US"))
							filename = "Messages_"+defaultLanguage+".properties";
						for (int i = 0; i < messagesProperties.length; i++)
						{
							if (messagesProperties[i] == null)
								continue;
							String lang = messagesProperties[i];
							if (lang.equals(filename))
								out.println("<option value=\""+lang+"\" selected=\"true\">"+lang+" ("+active+")</option>");
							else
								out.println("<option value=\""+lang+"\">"+lang+"</option>");
						}
						%>
					</select>
					</div>
					<div><fmt:message key="jsp.dspace-admin.messages-main.create.to-file-name"/>
					<%-- 到新的語系檔名稱 --%>
							
							Messages_<input type="text" name="position" id="filename" />.properties
					</div>
                    <%-- <input type="submit" name="submit_edit" value="Edit..."> --%>
                    <div style="text-align:center;">
						<input type="hidden" name="submit_action" value="submit_create" />
                    	<input type="submit" value="<fmt:message key="jsp.dspace-admin.general.addnew"/>" />
                    	<input type="button" value="開新視窗編輯" onclick="openWindowSubmit(this);" />
                    </div>
                </td>
			</tr>
    </table>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/jquery.js"></script>
	<script type="text/javascript">
	<!--
	function checkCreate(thisForm)
	{
		if (thisForm.filename.value == '') 
		{ 
			alert('<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-main.lang-empty") %>');
			<%-- alert('語系檔名稱不能是空值！'); --%>
			this.filename.focus();
			return false; 
		}
		
		var filename = "Messages" + "_" + thisForm.filename.value + ".properties";
		
		var opts = jQuery(thisForm.source).children("option");
		for (var i = 0; i < opts.length; i++)
		{
			var exsitFilename = opts.eq(i).attr("value");
			//alert([filename, exsitFilename]);
			if (exsitFilename == filename)
			{
				alert('<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-main.lang-collision") %>');
				<%-- alert('不能跟現有的語系檔名稱重複！'); --%>
				return false;
			}
		}
		
		return true;
	}
	function openWindowSubmit(thisBtn)
	{
		var form = jQuery(thisBtn).parents("form:first");
		form.attr("target", "_blank");
		form.submit();
		form.removeAttr("target");
	}
	-->
	</script>
  </form>

  <form action="<%= request.getContextPath() %>/dspace-admin/messages-edit" method="post">
    <table class="miscTable" align="center" width="80%">
            <tr>
				<th id="t3" class="evenRowOddCol" width="30%">
					<label for="integrate_from">
						<fmt:message key="jsp.dspace-admin.messages-main.integrate"/>
						<%-- 整合語系檔 --%>
					</label>
				</th>
                <td headers="t3" class="evenRowEvenCol">
					<div>
						<fmt:message key="jsp.dspace-admin.messages-main.integrate.from"/>
						<%-- 將此語系檔 --%>
						<select name="source" id="integrate_source">
							<%
							for (int i = 0; i < messagesProperties.length; i++)
							{
								if (messagesProperties[i] == null)
									continue;
								String lang = messagesProperties[i];
								
								String selected = "";
								if (lang.equals("Messages.properties"))
									selected = " selected=\"selected\"";
								
								if (lang.equals(filename))
									out.println("<option value=\""+lang+"\""+selected+">"+lang+" ("+active+")</option>");
								else
									out.println("<option value=\""+lang+"\""+selected+">"+lang+"</option>");
							}
							%>
						</select>
					</div>
					<div>
						<fmt:message key="jsp.dspace-admin.messages-main.integrate.to"/>
						<%-- 整合到此語系檔:	 --%>
						
						<select name="target" id="integrate_target">
						<%
						for (int i = 0; i < messagesProperties.length; i++)
						{
							if (messagesProperties[i] == null)
								continue;
							String lang = messagesProperties[i];
							if (lang.equals(filename))
								out.println("<option value=\""+lang+"\" selected=\"true\">"+lang+" ("+active+")</option>");
							else
								out.println("<option value=\""+lang+"\">"+lang+"</option>");
						}
						%>
					</select>
					</div>
					
                    <%-- <input type="submit" name="submit_edit" value="Edit..."> --%>
                    <div style="text-align:center;">
						<input type="hidden" name="submit_action" value="submit_integrate" />
                    	<input type="submit" value="<fmt:message key="jsp.dspace-admin.messages-main.integrate-submit"/>" />
                    </div>
                </td>
			</tr>
    </table>
	<script type="text/javascript" src="<%= request.getContextPath() %>/extension/jquery.js"></script>
	<script type="text/javascript">
	<!--
	function checkCreate(thisForm)
	{
		if (thisForm.filename.value == '') 
		{ 
			alert('<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-main.lang-empty") %>');
			<%-- alert('語系檔名稱不能是空值！'); --%>
			this.filename.focus();
			return false; 
		}
		
		var filename = "Messages" + "_" + thisForm.filename.value + ".properties";
		
		var opts = jQuery(thisForm.source).children("option");
		for (var i = 0; i < opts.length; i++)
		{
			var exsitFilename = opts.eq(i).attr("value");
			//alert([filename, exsitFilename]);
			if (exsitFilename == filename)
			{
				alert('<%=LocaleSupport.getLocalizedMessage(pageContext
				, "jsp.dspace-admin.messages-main.lang-collision") %>');
				<%-- alert('不能跟現有的語系檔名稱重複！'); --%>
				return false;
			}
		}
		
		return true;
	}
	function openWindowSubmit(thisBtn)
	{
		var form = jQuery(thisBtn).parents("form:first");
		form.attr("target", "_blank");
		form.submit();
		form.removeAttr("target");
	}
	-->
	</script>
  </form>
	
<h2>
	<fmt:message key="jsp.dspace-admin.messages-main.translator.heading"/>
	<%-- 語系檔轉換器 --%>
</h2>
	
<style type="text/css">
#message_convertor,
#message_convertor_result	{
	width: 90%;
}
#message_convertor textarea,
#message_convertor_result textarea {
	width: 90%;
}
#message_convertor td,
#message_convertor_result td	{
	text-align:center;
}

#message_convertor_result {
	display: none;
}
</style>

<table id="message_convertor" align="center">
	<thead>
		<tr>
			<th>
				<fmt:message key="jsp.dspace-admin.messages-main.translator.editor-heading-unescape"/>
				<%-- 請輸入待轉的原始文字 --%>
			</th>
			<th>
				<fmt:message key="jsp.dspace-admin.messages-main.translator.editor-heading-escape"/>
				<%-- 請輸入待轉的編碼文字 --%>
			</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<textarea class="unescape"></textarea>
			</td>
			<td>
				<textarea class="escape"></textarea>
			</td>
		</tr>
	</tbody>
	<tfoot>
		<tr>
			<th>
				<button type="button" onclick="convert_unescape()">
					<fmt:message key="jsp.dspace-admin.messages-main.translator.convertor"/>
					<%-- 轉換 --%>
				</button>
			</th>
			<th>
				<button type="button" onclick="convert_escape()">
					<fmt:message key="jsp.dspace-admin.messages-main.translator.convertor"/>
					<%-- 轉換 --%>
				</button>
			</th>
		</tr>
	</tfoot>
</table>

<table id="message_convertor_result" align="center">
	<thead>
		<tr>
			<th>
				<fmt:message key="jsp.dspace-admin.messages-main.translator.result.heading.unescape"/>
				<%-- 原始文字 --%>
			</th>
			<th>
				<fmt:message key="jsp.dspace-admin.messages-main.translator.result.heading.escape"/>
				<%-- 編碼文字 --%>
			</th>
		</tr>
	</thead>
	<tbody>

	</tbody>
</table>

<script type="text/javascript">
var MessageUtils = {
	encode: function (source)
	{
	  //var source = document.getElementById("source").value;
	  var utf = "";
	  
	  //轉換成UTF8碼
	  for (var i = 0; i < source.length; i++)
	  {
		char = source.substr(i, 1);
		var encoded = source.charCodeAt(i).toString(16);
		if (encoded.length == 4)
			utf = utf + "\\u" + encoded;
		else
	   		utf = utf + char;
	  }
	  var result = utf;;
	  return result;
	},
	decode: function(source)
	{
	  var utf = "";
		for (var i = 0; i < source.length; i++)
		{
			var char = source.substr(i, 1);
			
			if (char == "\\" && i < source.length - 1)
			{
				char = source.substr(i, 2);
			   
			   if (char == "\\u" && i < source.length - 5)
			   {
					code = source.substr(eval(i+2), 4);
					if (code.indexOf("\\") == -1 && code.indexOf(" ") == -1)
					{
						utf = utf + String.fromCharCode(MessageUtils.HEXtoDEC(code));
						i = i + 5;
					}
					else
						utf = utf + char;
				}
				else
					utf = utf + char;
			}
			else
				utf = utf + char;
		}
	  
	  var result = utf;
	  return result;
	},
	HEXtoDEC: function(six)
	{
		  var ten = 0;
		  
		  for (var i = 0; i < six.length; i++)
		  {
			char = six.substr(i, 1);
		 number = 0;
		 
		 switch (char)
		 {
		   case 'a':
			 number = 10;break;
		   case 'b':
			 number = 11;break;
		   case 'c':
			 number = 12;break;
		   case 'd':
			 number = 13;break;
		   case 'e':
			 number = 14;break;
		   case 'f':
			 number = 15;break;  
		   default:
			 number = char;break;
		 }
		
		 for (var j = 0; j < (six.length - i - 1); j++)
		 {
		   number = number * 16;
		 }
		 ten = ten + parseInt(number);
		  }
		  
		  return ten;
	}
};

function convert_unescape() {
	var unescapeText = jQuery("#message_convertor .unescape").val();
	
	var escapeText = MessageUtils.encode(unescapeText);
	
	pushResult(unescapeText, escapeText, false);
}

function convert_escape() {
	var escapeText = jQuery("#message_convertor .escape").val();
	
	var unescapeText = MessageUtils.decode(escapeText);
	
	pushResult(unescapeText, escapeText, true);
	
	cleanText()
}

function pushResult(unescapeText, escapeText, selectUnescape)
{
	unescapeText = jQuery.trim(unescapeText);
	escapeText = jQuery.trim(escapeText);
	if (unescapeText == ""
		|| escapeText == "")
		return;
	
	jQuery("#message_convertor_result").show();
	
	var result = jQuery("<tr><td><textarea class=\"unescape\"></textarea></td><td><textarea class=\"escape\"></textarea></td></tr>");
	
	result.find(".unescape").val(unescapeText);
	result.find(".escape").val(escapeText);
	
	jQuery("#message_convertor_result tbody").prepend(result);
	
	if (selectUnescape)
		result.find(".unescape").select();
	else
		result.find(".escape").select();
}

function cleanText()
{
	jQuery("#message_convertor .unescape").val("");
	jQuery("#message_convertor .escape").val("");
}
</script>
  		

</dspace:layout>
<%
}
catch (Exception e) { e.printStackTrace(); }
%>