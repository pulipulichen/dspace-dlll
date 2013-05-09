<%-- 
	config-edit.jsp

//語系檔備份：
jsp.dspace-admin.config-edit.title = \u7de8\u8f2f\u8a2d\u5b9a\u6a94
jsp.dspace-admin.config-edit.heading = \u7de8\u8f2f\u8a2d\u5b9a\u6a94
jsp.dspace-admin.config-edit.save-success = \u5df2\u7d93\u5132\u5b58\uff01\u8acb\u91cd\u65b0\u555f\u52d5\u4f3a\u670d\u5668\u4ee5\u770b\u5230\u4fee\u6539\u7684\u7d50\u679c\u3002
jsp.dspace-admin.config-edit.js.save-confirm = \u5132\u5b58\u4e4b\u5f8c\u4e0d\u80fd\u5fa9\u539f\uff0c\u662f\u5426\u8981\u7e7c\u7e8c\uff1f

jsp.layout.navbar-admin.config-edit = \u7de8\u8f2f\u8a2d\u5b9a\u6a94

--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.Constants" %>
<%@ page import="javax.servlet.jsp.PageContext" %>
<%
	String dspaceCFG = (String)request.getAttribute("config");
	
	//get the existing messages
    String message = (String) request.getAttribute("message");
	
	String successAlert = "";
	if (message != null && message.equals("success"))
	{
		//已經儲存！請重新啟動Tomcat網頁伺服器以看到修改的結果。
		successAlert = "<div class=\"dspace-admin-alert\">"+LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.config-edit.save-success")+"</div>";
	}
	
%>
<%!
	public String lm (PageContext pageContext, String key)
	{
		return LocaleSupport.getLocalizedMessage(pageContext, "jsp.dspace-admin.config-edit.form." + key);
	}
%>
<%
	PageContext pg = pageContext;
%>


<%-- <dspace:layout titlekey="編輯設定檔" --%>
<dspace:layout titlekey="jsp.dspace-admin.config-edit.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin">

<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/message-utils.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-lang.jsp"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-editor.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-controller.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form-utils.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form-valid.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form-dialog.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form-reform-multi-comma.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form-reform-advanced-field-option.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form-reform-browse-index.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form-reform-sort-option.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form-reform-feed-item-description.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form-reform-item-display-default.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/config-edit/config-form-reform-itemlist-columns.js"></script>
<link rel="stylesheet" href="<%= request.getContextPath() %>/extension/config-edit/config-edit.css" type="text/css" />
<script type="text/javascript">
jQuery(document).ready(function () {
	ConfigForm.init();
	ConfigController.init();
});

</script>

<table width="95%">
    <tr>
      <td align="left">
        <%-- <h1>News Editor</h1> --%>
        <h1>
			<fmt:message key="jsp.dspace-admin.config-edit.heading"/>
			<%-- 編輯遞交表單 --%>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#editconfig" %>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

<%= successAlert %>
	
<form action="?submit_action=save" method="post" onsubmit="return ConfigController.submit(this)">
	<div class="submit-button">
		<button type="submit">
			<fmt:message key="jsp.dspace-admin.general.update"/>
			<%-- 更新 --%>
		</button>
		<button type="button" onclick="location.href='<%= request.getContextPath() %>'/dspace-admin/">
			<fmt:message key="jsp.dspace-admin.general.cancel"/>
			<%-- 取消 --%>
		</button>
	</div>
	
	<div class="config-controller">
		<label>
			<input type="radio" name="configController" class="mode form" checked="checked" />
			<%-- 基本設定 --%>
			<fmt:message key="jsp.dspace-admin.config-edit.controller.basic"/>
		</label>
		<label>
			<input type="radio" name="configController" class="mode code" />
			<%-- 進階設定 --%>
			<fmt:message key="jsp.dspace-admin.config-edit.controller.advance"/>
		</label>
	</div>
<div>

	<table id="configFormTable" class="miscTable" width="80%" align="center">
		<tbody>
			<tr>
			  <th colspan="2">
				<%-- 基本資訊 --%>
			<%= lm(pg, "heading.basic") %>
			</th>
		  </tr>
			<tr>
			  <th class="config-form-th">&nbsp;</th>
			  <td>
				<%-- <p>DSpace的網址，包括埠號，但不包括結尾的反斜線 &quot;/&quot; --%>
			<%= lm(pg, "dspace.url") %>
			</td>
		  </tr>
			<tr>
				<th>
					<%-- DSpace網址 --%>
					<%= lm(pg, "heading.dspace.url") %>
				</th>
				<td>
					<input type="text" class="value text" onchange="ConfigForm.valid.stripEndsWithSlash(this);" />
					<input type="hidden" class="key" value="dspace.url" /></td>
			</tr>
			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>請您輸入主機的名稱，應該跟網址開頭相同，但不包括埠號。</p> --%>
				<%= lm(pg, "dspace.hostname") %>
				</td>
		  </tr>
			<tr>
				<th>
					<%-- DSpace<br />主機名稱 --%>
					<%= lm(pg, "heading.dspace.hostname") %>
				</th>
				<td>
					<input type="text" class="value text" onchange="ConfigForm.valid.startEndsWithPort(this);" />
					<input type="hidden" class="key" value="dspace.hostname" /></td>
			</tr>
			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>請輸入這個網站的名稱。</p> --%>
				<%= lm(pg, "dspace.name") %>
				</td>
		  </tr>
			<tr>
				<th>
					<%-- DSpace<br />網站名稱 --%>
					<%= lm(pg, "heading.dspace.name") %>
				</th>
				<td>
					<input type="text" class="value text" />
					<input type="hidden" class="key" value="dspace.name" /></td>
			</tr>
			<tr>
				<th colspan="2">
					<%-- 電子郵件設定 --%>
					<%= lm(pg, "heading.e-mail") %>
				</th>
			</tr>
			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>電子郵件的寄出地址</p> --%>
				<%= lm(pg, "mail.from.address") %>
				</td>
		  </tr>
			<tr>
				<th>
					<%-- 寄出地址 --%>
					<%= lm(pg, "heading.mail.from.address") %>
				</th>
				<td>
					<input type="text" class="value text" />
					<input type="hidden" class="key" value="mail.from.address" /></td>
			</tr>
			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>意見回饋收件的電子郵件地址。目前DSpace只能設定一個收件地址。</p> --%>
				<%= lm(pg, "feedback.recipient") %>
				</td>
		  </tr>
			<tr>
				<th>
					<%-- 意見回饋<br />收件地址 --%>
					<%= lm(pg, "heading.feedback.recipient") %>
				</th>
				<td>
					<input type="text" class="value text" />
					<input type="hidden" class="key" value="feedback.recipient" /></td>
			</tr>
			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>整個DSpace網站的系統管理者的電子郵件地址。</p> --%>
				<%= lm(pg, "mail.admin") %>
				</td>
		  </tr>
			<tr>
				<th>
					<%-- 管理員<br />電子郵件地址 --%>
					<%= lm(pg, "heading.mail.admin") %>
				</th>
				<td>
					<input type="text" class="value text" />
					<input type="hidden" class="key" value="mail.admin" /></td>
			</tr>
		<tr>
				<th>
					<%-- 管理團隊名稱 --%>
					<%= lm(pg, "heading.mail.admin.group") %>
				</th>
				<td>
					<input type="text" class="value text" />
					<input type="hidden" class="key" value="mail.admin.name" /></td>
			</tr>
			<tr>
				<th colspan="2">
					<%-- 語系設定 --%>
					<%= lm(pg, "heading.locale") %>
				</th>
			</tr>
			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>請設定整個網站預設使用的語言。如果沒有設定，網站將會使用者用的語系。</p> --%>
				<%= lm(pg, "default.locale") %>
				</td>
		  </tr>
			<tr>
				<th>
					<%-- 預設語系 --%>
					<%= lm(pg, "heading.default.locale") %>
				</th>
				<td>
					<input type="text" class="value text short-text" />
					<input type="hidden" class="key" value="default.locale" /></td>
			</tr>
			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>請設定使用者可以選擇的語系。此處的設定將會對應到所使用的語系檔檔名，例如設定 中文語系 &quot;zh_TW&quot; 時，則是對應到語系檔 &quot;Messages_zh_TW.properties&quot;。</p> --%>
				<%= lm(pg, "webui.supported.locales") %>
				</td>
		  </tr>
			<tr>
				<th>
					<%-- 支援語系選項 --%>
					<%= lm(pg, "heading.webui.supported.locales") %>
				</th>
				<td>
					<input type="text" class="value text multi-comma" />
					<input type="hidden" class="key" value="webui.supported.locales" /></td>
			</tr>
			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>現在DSpace當中描述文件後設資料的資料預設語系。 </p> --%>
				<%= lm(pg, "default.language") %>
				</td>
		  </tr>
			<tr>
				<th>
					<%-- 後設資料<br />預設語系 --%>
					<%= lm(pg, "heading.default.language") %>
				</th>
				<td>
					<input type="text" class="value text short-text" />
					<input type="hidden" class="key" value="default.language" /><br /></td>
			</tr>
			<tr>
			  <th colspan="2">
				<%-- 搜尋設定 --%>
					<%= lm(pg, "heading.search") %>
				</th>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>請在此處設定您在 &quot;進階搜尋欄位&quot; 當中各欄位的對應後設資料欄位。</p><ul><li>欄位代號: 進階搜尋的下拉式選單語系將會使用 &quot;jsp.search.advanced.type.&lt;欄位代號&gt;&quot; 。</li><li>後設資料欄位: 輸入格式為 <code>&lt;規範&gt;.&lt;元素&gt;[.&lt;修飾語&gt;|.*]</code>。例如 <code>dc.title</code>、<code>dc.contributor.author</code>。 </li></ul>			    <p>當您變更搜尋欄位對應時，請務必執行[dspace]/bin/dsrun org.dspace.search.DSIndexer -b以重新建立搜尋索引，如此搜尋結果才能符合變更過後的欄位。</p> --%>
				<%= lm(pg, "search.advanced.field.options") %>
				</td>
		  </tr>
		  			<tr>
			  <th>
				<%-- 進階搜尋欄位<br />與搜尋對應 --%>
					<%= lm(pg, "heading.search.advanced.field.options") %>
			  </th>
			  <td>
			  <textarea class="value advanced-field-search-options"></textarea>
			    <input type="hidden" value="search.advanced.field.options" class="key" />
			   
			  <textarea class="value advanced-field-search-metadatas"></textarea>
			    <input type="hidden" value="search.index.*" class="key" />
			  
			  <!--
			  <table width="100%">
			  	<thead>
                <tr>
                  <th scope="col">欄位選項</th>
                  <th scope="col">對應後設資料欄位</th>
                  <th scope="col">&nbsp;</th>
                </tr>
                <tr>
                  <td scope="col">請輸以英數填寫。此處的順序將會與進階搜尋頁面時顯示的順序相同</td>
                  <td scope="col">請以後設資料的指定方式填入，修飾語為&quot;*&quot;時表示任意皆可，例如 &quot;dc.description.abstract&quot; 或 &quot;dc.contribute.*&quot;。</td>
                  <th scope="col">&nbsp;</th>
                </tr>
				</thead>
				<tbody>
					<tr>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					</tr>
				</tbody>
              </table>
              -->
			    
			    </td>
	      </tr>
		  			<tr>
			  <th colspan="2">
			  		<%-- 控制碼設定 --%>
			  					<%= lm(pg, "heading.handle") %>
			  </th>
		  </tr>
		  			<tr>
		  			  <th>&nbsp;</th>
		  			  <td>
				<%-- <p>請填入CNRI的控制碼字首。</p> --%>
							<%= lm(pg, "handle.prefix") %>
				</td>
		  </tr>
		  			<tr>
			  <th>
			  		<%-- 控制碼字首 --%>
			  					<%= lm(pg, "heading.handle.prefix") %>
			  </th>
			  <td><input name="text" type="text"class="value text short-text"/>
                <input name="hidden" type="hidden" class="key" value="handle.prefix" /></td>
		  </tr>
		  			<tr>
			  <th colspan="2">
			  		<%-- 遞交作業設定 --%>
			  		<%= lm(pg, "heading.submission") %>
			  </th>
		  </tr>
		  			<tr>
		  			  <th>&nbsp;</th>
		  			  <td>
				<%-- <p>可限制遞交者是否一定要上傳檔案才能完成遞交。如果選擇 &quot;否&quot;，檔案上傳步驟將會出現略過上傳的選項。</p> --%>
							<%= lm(pg, "webui.submit.upload.required") %>
				</td>
		  </tr>
		  			<tr>
			  <th>
			  		<%-- 必須上傳檔案 --%>
			  					<%= lm(pg, "heading.webui.submit.upload.required") %>
			  </th>
			  <td><label>
			    <input type="radio" value="true" class="value" />
<%-- 是 --%>
				<%= lm(pg, "true") %>
</label>
                <label>
                <input type="radio" value="false" class="value" />
<%-- 否 --%>
				<%= lm(pg, "false") %>
</label>
                <input name="hidden2" type="hidden" class="key" value="webui.submit.upload.required" /></td>
		  </tr>
		  			<tr>
		  			  <th>&nbsp;</th>
		  			  <td>
				<%-- <p>遞交作業中是否要使用創用CC授權條款(Creative Commons licenses)？</p> --%>
							<%= lm(pg, "webui.submit.enable-cc") %>
				</td>
		  </tr>
		  			<tr>
			  <th>
			  		<%-- 使用<br />CC授權條款 --%>
			  					<%= lm(pg, "heading.webui.submit.enable-cc") %>
			  </th>
			  <td>
			  	<label>
			    <input type="radio" value="true" class="value" />
			    <%-- 是 --%>
				<%= lm(pg, "true") %>
			    </label>
				<label>
			    <input type="radio" value="false" class="value" />
			    <%-- 否 --%>
				<%= lm(pg, "false") %>
			    </label>
			    <input name="hidden22" type="hidden" class="key" value="webui.submit.enable-cc" /></td>
		  </tr>
		  			<tr>
		  			  <th colspan="2">
		  				<%-- 縮圖設定 --%>
		  				<%= lm(pg, "heading.thumbnail") %>
		  			</th>
		  </tr>
		  			<tr>
		  			  <th>&nbsp;</th>
		  			  <td>
				<%-- <p>請設定多媒體轉檔產生縮圖時的最大寬度與長度，單位是 &quot;像素&quot;。</p> --%>
							<%= lm(pg, "webui.browse.thumbnail.maxwidth") %>
				</td>
		  </tr>
		  			<tr>
                      <th>
                    	<%-- 縮圖最大寬度 --%>
                    			<%= lm(pg, "heading.webui.browse.thumbnail.maxwidth") %>
                    	</th>
		  			  <td><input name="text22" type="text"class="value text short-text"/>
                          <%-- 像素 --%>
                    		<%= lm(pg, "px") %>
                      <input name="hidden23" type="hidden" class="key" value="thumbnail.maxwidth" /></td>
		  </tr>
		  			<tr>
                      <th>
                    	<%-- 縮圖最大高度 --%>
                    			<%= lm(pg, "heading.thumbnail.maxheight") %>
                    	</th>
		  			  <td><input name="text22" type="text"class="value text short-text"/>
                          <%-- 像素 --%>
                    		<%= lm(pg, "px") %>
                      <input name="hidden23" type="hidden" class="key" value="thumbnail.maxheight" /></td>
		  </tr>
		  			<tr>
		  			  <th>&nbsp;</th>
		  			  <td>
				<%-- <p>文件頁面中是否要為每個檔案顯示縮圖？</p> --%>
							<%= lm(pg, "webui.item.thumbnail.show") %>
				</td>
		  </tr>
		  			<tr>
		  			  <th>
		  				<%-- 文件頁面<br />顯示縮圖  --%>
		  						<%= lm(pg, "heading.webui.item.thumbnail.show") %>
		  			</th>
		  			  <td><label>
		  			    <input type="radio" value="true" class="value" />
<%-- 是 --%>
				<%= lm(pg, "true") %>
</label>
                        <label>
                        <input type="radio" value="false" class="value" />
<%-- 否 --%>
				<%= lm(pg, "false") %>
</label>
                        <input name="hidden2222" type="hidden" class="key" value="webui.item.thumbnail.show" /></td>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>瀏覽或搜尋結果顯示頁面是否要顯示縮圖？如果您要顯示縮圖，請確認文件列表欄位設定當中必須有一欄勾選 &quot;縮圖&quot;。</p> --%>
							<%= lm(pg, "webui.browse.thumbnail.show") %>
				</td>
		  </tr>
		  			<tr>
			  <th>
			  			<%-- 顯示縮圖 --%>
			  					<%= lm(pg, "heading.webui.browse.thumbnail.show") %>
			  			</th>
			  <td><label>
			    <input type="radio" value="true" class="value" />
<%-- 是 --%>
				<%= lm(pg, "true") %>
</label>
                <label>
                <input type="radio" value="false" class="value" />
<%-- 否 --%>
				<%= lm(pg, "false") %>
</label>
                <input name="hidden222" type="hidden" class="key" value="webui.browse.thumbnail.show" /></td>
		  </tr>
		  			<tr>
		  			  <th>&nbsp;</th>
		  			  <td>
				<%-- <p>瀏覽或搜尋結果顯示頁面中縮圖的長度與寬度，單位是 &quot;像素&quot;。當您希望結果顯示頁面的縮圖比多媒體轉檔產生的縮圖還要小的時候，才需要設定此項。</p> --%>
							<%= lm(pg, "webui.browse.thumbnail.maxheight") %>
				</td>
		  </tr>
		  			<tr>
                      <th>
                    	<%-- 瀏覽縮圖<br />最大寬度 --%>
                    			<%= lm(pg, "heading.webui.browse.thumbnail.maxheight") %>
                    	</th>
		  			  <td><input name="text22" type="text"class="value text short-text"/>
                          <%-- 像素 --%>
                    		<%= lm(pg, "px") %>
                      <input name="hidden23" type="hidden" class="key" value="webui.browse.thumbnail.maxheight" /></td>
		  </tr>
		  			<tr>
			  <th>
			  			<%-- 瀏覽縮圖<br />最大高度 --%>
			  					<%= lm(pg, "heading.webui.browse.thumbnail.maxwidth") %>
			  			</th>
			  <td><input name="text22" type="text"class="value text short-text"/>
                <%-- 像素 --%>
                			<%= lm(pg, "px") %>
                <input name="hidden23" type="hidden" class="key" value="webui.browse.thumbnail.maxwidth" /></td>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>點選縮圖連結時，開啟文件或是檔案。 </p> --%>
							<%= lm(pg, "webui.browse.thumbnail.linkbehaviour") %>
				</td>
		  </tr>
		  			<tr>
                      <th>
                    	<%-- 縮圖連結 --%>
                    			<%= lm(pg, "heading.webui.browse.thumbnail.linkbehaviour") %>
                    	</th>
		  			  <td><label>
                        <input type="radio" value="item" class="value" />
                        <%-- 文件 --%>
                    	<%= lm(pg, "item") %>
		  			  </label>
                        <label>
                          <input type="radio" value="bitstream" class="value" />
                          <%-- 檔案 --%>
                    		<%= lm(pg, "bitstream") %>
                    </label>
                          <input name="hidden222" type="hidden" class="key" value="webui.browse.thumbnail.linkbehaviour" /></td>
		  </tr>
		  			<tr>
                      <th colspan="2">
                    	<%-- 文件的檔案預覽圖片 --%>
                    			<%= lm(pg, "heading.preview") %>
                    	</th>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>是否要在文件顯示頁面的頁首顯示預覽圖片？</p><p>注意: 即使文件當中有一個以上的檔案，也只會顯示第一個檔案預覽圖片。</p> --%>
							<%= lm(pg, "webui.preview.enabled") %>
				</td>
		  </tr>
		  			<tr>
			  <th>
			  			<%-- 是否顯示<br />預覽圖片 --%>
			  					<%= lm(pg, "heading.webui.preview.enabled") %>
			  			</th>
			  <td><label>
			    <input type="radio" value="true" class="value" />
<%-- 是 --%>
				<%= lm(pg, "true") %>
</label>
                <label>
                <input type="radio" value="false" class="value" />
<%-- 否 --%>
				<%= lm(pg, "false") %>
</label>
                <input name="hidden2223" type="hidden" class="key" value="webui.preview.enabled" /></td>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>請設定多媒體轉檔時設定預覽圖片的大小，單位是 &quot;像素&quot; 。 </p> --%>
							<%= lm(pg, "webui.preview.maxwidth") %>
				</td>
		  </tr>
		  			<tr>
                      <th>
                    	        <%-- 最大寬度 --%>
                    			<%= lm(pg, "heading.webui.preview.maxwidth") %>
                    	</th>
		  			  <td><input name="text22" type="text"class="value text short-text"/>
		  			    <%-- 像素 --%>
		  					<%= lm(pg, "px") %>
		  			      <input name="hidden23" type="hidden" class="key" value="webui.preview.maxwidth" /></td>
		  </tr>
		  			<tr>
                      <th>
                    	        <%-- 最大高度 --%>
                    			<%= lm(pg, "heading.webui.preview.maxheightwebui.preview.maxheight") %>
                    	</th>
		  			  <td><input name="text22" type="text"class="value text short-text"/>
		  			    <%-- 像素 --%>
		  					<%= lm(pg, "px") %>
	  			      <input name="hidden23" type="hidden" class="key" value="webui.preview.maxheight" /></td>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>預覽圖片是否加上典藏單位標誌？</p> --%>
							<%= lm(pg, "webui.preview.do-brand") %>
				</td>
		  </tr>
		  			<tr>
                      <th>
                    	<%-- 加入標誌 --%>
                    			<%= lm(pg, "heading.webui.preview.do-brand") %>
                    	</th>
		  			  <td><label>
                        <input type="radio" value="true" class="value" />
		  			    <%-- 是 --%>
				<%= lm(pg, "true") %>
</label>
                          <label>
                          <input type="radio" value="false" class="value" />
                            <%-- 否 --%>
				<%= lm(pg, "false") %>
</label>
                          <input name="hidden2223" type="hidden" class="key" value="webui.preview.do-brand" /></td>
		  </tr>
		  			<tr>
		  			  <th>&nbsp;</th>
		  			  <td>
				<%-- <p>如果您選擇加入標誌，請輸入標誌下方顯示的文字。</p> --%>
							<%= lm(pg, "webui.preview.brand") %>
				</td>
		  </tr>
		  			<tr>
                      <th>
                    	<%-- 標誌文字 --%>
                    			<%= lm(pg, "heading.webui.preview.brand") %>
                    	</th>
		  			  <td><input name="text22" type="text"class="value text"/>
                          <input name="hidden23" type="hidden" class="key" value="webui.preview.brand" /></td>
		  </tr>
		  			<tr>
		  			  <th>&nbsp;</th>
		  			  <td>
				<%-- <p>請輸入以上標誌文字的縮寫。當預覽圖片寬度不足以放入標誌文字時，將會改放入縮寫文字。</p> --%>
							<%= lm(pg, "webui.preview.brand.abbrev") %>
				</td>
		  </tr>
		  			<tr>
			  <th>
			  			<%-- 標誌縮寫文字 --%>
			  					<%= lm(pg, "heading.webui.preview.brand.abbrev") %>
			  			</th>
			  <td><input name="text222" type="text"class="value text short-text"/>
                <input name="hidden232" type="hidden" class="key" value="webui.preview.brand.abbrev" /></td>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>標誌空間的高度，單位是 &quot;像素&quot;。</p> --%>
							<%= lm(pg, "webui.preview.brand.height") %>
				</td>
		  </tr>
		  			<tr>
			  <th>
			  			<%-- 標誌高度 --%>
			  					<%= lm(pg, "heading.webui.preview.brand.height") %>
			  			</th>
			  <td><input name="text2222" type="text"class="value text short-text"/>
			    <%-- 像素 --%>
			    			<%= lm(pg, "px") %>
			    <input name="hidden2322" type="hidden" class="key" value="webui.preview.brand.height" /></td>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>標誌文字的字型與字體大小</p> --%>
							<%= lm(pg, "webui.preview.brand.font") %>
				</td>
		  </tr>
		  			<tr>
			  <th>
			  			<%-- 標誌字型 --%>
			  					<%= lm(pg, "heading.font") %>
			  			</th>
			  <td><input name="text22223" type="text"class="value text short-text"/>
			    <input name="hidden23223" type="hidden" class="key" value="webui.preview.brand.font" /></td>
		  </tr>
		  			<tr>
			  <th>
			  			<%-- 標誌字體大小 --%>
			  					<%= lm(pg, "heading.webui.preview.brand.fontpoint") %>
			  			</th>
			  <td><input name="text22222" type="text"class="value text short-text"/>
<%-- pt --%>
					<%= lm(pg, "pt") %>
  <input name="hidden23222" type="hidden" class="key" value="webui.preview.brand.fontpoint" /></td>
		  </tr>
		  			<tr>
			  <th colspan="2">
			  			<%-- 文件計數設定 --%>
			  			<%= lm(pg, "heading.strengths") %>
			  		</th>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>是否要在社群與類別名稱旁邊顯示底下擁有的文件數量？</p> --%>
							<%= lm(pg, "webui.strengths.show") %>
				</td>
		  </tr>
		  			<tr>
                      <th>
                    	<%-- 顯示計數 --%>
                    			<%= lm(pg, "heading.webui.strengths.show") %>
                    	</th>
		  			  <td><label>
                        <input type="radio" value="true" class="value" />
		  			    <%-- 是 --%>
				<%= lm(pg, "true") %>
</label>
                          <label>
                          <input type="radio" value="false" class="value" />
                            <%-- 否 --%>
				<%= lm(pg, "false") %>
</label>
                          <input name="hidden2223" type="hidden" class="key" value="webui.strengths.show" /></td>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>請在此設定使用者可以選擇的排序選項。排序選項會在瀏覽文件的頁面，包括文件的瀏覽、或是搜尋結果中顯示。即使文件列表欄位中沒有顯示這些欄位，你依然可以將它設定在排序選項當中。</p><ul><li>選項名稱: 選項的語系檔將會使用 browse.type.metadata.&lt;選項名稱&gt;。</li><li>後設資料欄位: 格式是 <code>&lt;規範&gt;.&lt;元素&gt;[.&lt;修飾語&gt;|.*]</code>。</li><li>資料類型: 將資料轉換成此類型的資料再做排序。&quot;文字&quot; 是將資料以原始文字排序；&quot;日期&quot; 則是將資料轉換成日期後再排序；&quot;其他&quot; 的排序基本上都是依照 &quot;文字&quot;，您也可以利用外掛管理器(PluginManager)來定義其他的轉換正規化方式。</li><li>顯示: 當您使用特殊的排序方式而又不想讓使用者選用時，請將之設為 &quot;隱藏&quot;。</li></ul> --%>
							<%= lm(pg, "webui.itemlist.sort-option.*") %>
			    </td>
		  </tr>
		  			<tr>
			  <th>
			  			<%-- 排序選項 --%>
			  					<%= lm(pg, "heading.webui.itemlist.sort-option.*") %>
			  			</th>
			  <td>
			  	<textarea class="value sort-option"></textarea>
			    <input type="hidden" value="webui.itemlist.sort-option.*" class="key" />
			  </td>
		  </tr>
		  			<tr>
			  <th colspan="2">
			  			<%-- RSS訂閱設定 --%>
			  			<%= lm(pg, "heading.rss") %>
			  		</th>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>是否開啟RSS訂閱。如果開啟的話，在社群及類別首頁將會顯示RSS訂閱的連結。</p> --%>
							<%= lm(pg, "webui.feed.enable") %>
				</td>
		  </tr>
		  			<tr>
			  <th>
			  			<%-- 開啟RSS訂閱 --%>
			  					<%= lm(pg, "heading.webui.feed.enable") %>
			  			</th>
			  <td><label>
			    <input type="radio" value="true" class="value" />
<%-- 是 --%>
				<%= lm(pg, "true") %>
</label>
                <label>
                <input type="radio" value="false" class="value" />
<%-- 否 --%>
				<%= lm(pg, "false") %>
</label>
                <input name="hidden22232" type="hidden" class="key" value="webui.feed.enable" /></td>
		  </tr>
		  			<tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>請設定RSS訂閱提供最新文件要有幾篇。</p> --%>
							<%= lm(pg, "webui.feed.items") %>
				</td>
		  </tr><tr>
			  <th>
			  			<%-- 文件篇數 --%>
			  					<%= lm(pg, "heading.webui.feed.items") %>
			  			</th>
			  <td><input name="text222232" type="text"class="value text short-text"/>
                <input name="hidden232232" type="hidden" class="key" value="webui.feed.items" /></td>
		  </tr><tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>設定每個RSS訂閱顯示欄位對應到的文件後設資料欄位。以下設定只能對應到 &quot;單一個&quot; 後設資料欄位。</p> --%>
							<%= lm(pg, "webui.feed.item.title") %>
				</td>
		  </tr><tr>
			  <th>
			  			<%-- 標題 --%>
			  					<%= lm(pg, "heading.webui.feed.item.title") %>
			  			</th>
			  <td><input name="text2222322" type="text"class="value text"/>
                <input name="hidden2322322" type="hidden" class="key" value="webui.feed.item.title" /></td>
		  </tr><tr>
			  <th>
			  			<%-- 日期 --%>
			  					<%= lm(pg, "heading.webui.feed.item.date") %>
			  			</th>
			  <td><input name="text2222323" type="text"class="value text"/>
                <input name="hidden2322323" type="hidden" class="key" value="webui.feed.item.date" /></td>
		  </tr><tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>設定每個RSS訂閱顯示敘述欄位(description)時對應到文件後設資料欄位。各欄位的資料會設定時的依序顯示在RSS訂閱的敘述欄位中。</p><ul><li>後設資料欄位: 格式是 <code>&lt;規範&gt;.&lt;元素&gt;[.&lt;修飾語&gt;|.*]</code>。</li><li>資料類型: &quot;文字&quot; 保持資料原始文字； &quot;日期&quot; 將資料轉換成日期格式之後顯示。</li></ul> --%>
							<%= lm(pg, "webui.feed.item.description") %>
		      </td>
		  </tr><tr>
			  <th>
			  			<%-- 敘述 --%>
			  					<%= lm(pg, "heading.webui.feed.item.description") %>
			  			</th>
			  <td><textarea class="value text feed-item-description"></textarea>
                <input name="hidden23223232" type="hidden" class="key" value="webui.feed.item.description" /></td>
		  </tr><tr>
			  <th colspan="2">
			  		<%-- 檔案上傳設定 --%>
			  					<%= lm(pg, "heading.upload") %>
			  	</th>
			  </tr><tr>
			  <th></th>
			  <td>
				<%-- <p>設定上傳檔案最大的大小，單位是 &quot;位元&quot; (byte)。最大只能接受到512MB的大小。 </p> --%>
							<%= lm(pg, "upload.max") %>
				</td>
		  </tr><tr>
			  <th>
			  			<%-- 檔案大小限制 --%>
			  					<%= lm(pg, "heading.upload.max") %>
			  			</th>
			  <td><input name="text22223232" type="text"class="value text short-text"/> 
			  		<%-- 位元 --%>
					<%= lm(pg, "bytes") %>
                <input name="hidden23223233" type="hidden" class="key" value="upload.max" /></td>
		  </tr><tr>
			  <th colspan="2">
			  		<%-- 網頁介面設定 --%>
			  					<%= lm(pg, "heading.webui") %>
			  </th>
			  </tr><tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>是否要顯示授權條款檔案集的內容？</p> --%>
							<%= lm(pg, "webui.licence_bundle.show") %>
				</td>
		  </tr><tr>
			  <th>
			  			<%-- 顯示授權條款檔案集 --%>
			  					<%= lm(pg, "heading.webui.licence_bundle.show") %>
			  			</th>
			  <td><label>
			    <input type="radio" value="true" class="value" />
<%-- 是 --%>
				<%= lm(pg, "true") %>
</label>
                <label>
                <input type="radio" value="false" class="value" />
<%-- 否 --%>
				<%= lm(pg, "false") %>
</label>
                <input name="hidden222322" type="hidden" class="key" value="webui.licence_bundle.show" /></td>
		  </tr><tr>
			  <th>&nbsp;</th>
			  <td>
				<%-- <p>設定文件頁面簡易檢視時要顯示的後設資料欄位。</p><ul><li>後設資料欄位: 格式是 <code>&lt;規範&gt;.&lt;元素&gt;[.&lt;修飾語&gt;|.*]</code>。</li><li>資料類型: &quot;文字&quot; 保持資料原始文字； &quot;日期&quot; 將資料轉換成日期格式之後顯示； &quot;超連結&quot; 把資料本身作為網址，加入超連結後顯示。</li></ul> --%>
							<%= lm(pg, "webui.itemdisplay.default") %>
			    </td>
		  </tr><tr>
			  <th>
			  	<%-- 文件頁面<br />預設顯示欄位 --%>
			  					<%= lm(pg, "heading.webui.itemdisplay.default") %>
		      </th>
			  <td><textarea name="textarea" class="value item-display-default"></textarea>
                <input name="hidden232232322" type="hidden" class="key" value="webui.itemdisplay.default" /></td>
		  </tr><tr>
			  <th>&nbsp;</th>
			  <td>
			  		<%-- <p>設定文件列表頁面時顯示的後設資料欄位。欄位將會依照設定順序的先後、由左至右地排列。</p><ul><li>後設資料欄位:</li><li>縮圖: 如果該欄位要顯示縮圖，請勾選此項。</li><li>資料類型: &quot;文字&quot; 保持資料原始文字； &quot;日期&quot; 將資料轉換成日期格式之後顯示；&quot;摘要&quot; 可限制文字顯示的字數，請在字數限制的欄位裡面填入最多顯示的字數。</li><li>寬度: 請填入數值及單位。單位有: &quot;任意&quot; 沒有數值，隨版面自動調整；&quot;像素&quot; 固定大小，需要輸入數值；&quot;百分比&quot; 依照整個表格的寬度百分比動態計算。</li></ul> --%>
			  				<%= lm(pg, "webui.itemlist.widths") %>
	          </td>
		  </tr><tr>
			  <th>
			  			<%-- 文件列表欄位 --%>
			  					<%= lm(pg, "heading.webui.itemlist.widths") %>
			  			</th>
			  <td><textarea name="textarea2" class="value itemlist-columns"></textarea>
                <input type="hidden" class="key" value="webui.itemlist.columns" />
                <textarea class="value itemlist-widths"></textarea>
                <input type="hidden" class="key" value="webui.itemlist.widths" /></td>
		  </tr>
		</tbody>
	</table>
</div>

<div class="source-div">
	<textarea id="source" class="need-unescape" name="config"><%= dspaceCFG %></textarea>
</div>

	
	<div class="submit-button">
		<button type="submit">
			<fmt:message key="jsp.dspace-admin.general.update"/>
			<%-- 更新 --%>
		</button>
		<button type="button" onclick="location.href='<%= request.getContextPath() %>'/dspace-admin/">
			<fmt:message key="jsp.dspace-admin.general.cancel"/>
			<%-- 取消 --%>
		</button>
	</div>
</form>

</dspace:layout>