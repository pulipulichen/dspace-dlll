<%--
  - tomcat-restart.jsp
  -	語系檔備份：
    
jsp.dspace-admin.tomcat-restart.title = \u91cd\u65b0\u555f\u52d5\u4f3a\u670d\u5668
jsp.dspace-admin.tomcat-restart.heading = \u91cd\u65b0\u555f\u52d5\u4f3a\u670d\u5668
jsp.dspace-admin.tomcat-restart.confirm = \u60a8\u78ba\u5b9a\u8981\u91cd\u65b0\u555f\u52d5Tomcat\u4f3a\u670d\u5668\u55ce\uff1f\u9019\u6703\u8b93\u4e4b\u524d\u6240\u6709\u8a2d\u5b9a\u751f\u6548\uff0c\u540c\u6642\u6240\u6709\u6b63\u5728\u4f7f\u7528\u7db2\u7ad9\u7684\u4eba\u6703\u88ab\u5f37\u8feb\u767b\u51fa\u3002
jsp.dspace-admin.tomcat-restart.wait1 = \u8acb\u7b49\u5019
jsp.dspace-admin.tomcat-restart.wait2 = \u79d2
jsp.dspace-admin.tomcat-restart.homepage = \u56de\u9996\u9801
jsp.dspace-admin.tomcat-restart.no-respense = \u4f3a\u670d\u5668\u4f3c\u4e4e\u51fa\u4e86\u9ede\u554f\u984c\uff0c\u7cfb\u7d71\u5c07\u572810\u79d2\u9418\u4e4b\u5f8c\u81ea\u52d5\u6aa2\u67e5\u3002
jsp.dspace-admin.tomcat-restart.success = \u91cd\u65b0\u555f\u52d5\u5b8c\u6210\u3002

jsp.layout.navbar-admin.tomcat-restart = \u91cd\u65b0\u555f\u52d5\u4f3a\u670d\u5668

	
  --%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<dspace:layout titlekey ="jsp.dspace-admin.tomcat-restart.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.administer"
               parentlink="/dspace-admin"
               nocache="true">
    
<script type="text/javascript" src="<%= request.getContextPath() %>/extension/jquery.js"></script>
<table width="95%">
    <tr>
      <td align="left">
        <%-- <h1>News Editor</h1> --%>
        <h1>
    		<fmt:message key="jsp.dspace-admin.tomcat-restart.heading"/>
			<%-- 重新啟動伺服器 --%>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#tomcatrestart" %>"><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

<div class="restart-confirm">
	<p>
		<fmt:message key="jsp.dspace-admin.tomcat-restart.confirm"/>
		<%-- 您確定要重新啟動Tomcat伺服器嗎？這會讓之前所有設定生效，同時所有正在使用網站的人會被強迫登出。 --%>
	</p>
	<div style="text-align:center">
	<button type="button">
		<fmt:message key="jsp.dspace-admin.tomcat-restart.do"/>
		<%-- 執行重新啟動Tomcat伺服器 --%>
	</button>
	</div>
</div>

<div class="restart-do" style="display:none;">
<h2 id="countdownHint">
	<fmt:message key="jsp.dspace-admin.tomcat-restart.wait1"/>
	<%-- 請等候 --%>
	<span id="countdown">30</span>
	<fmt:message key="jsp.dspace-admin.tomcat-restart.wait2"/>
	<%-- 秒 --%>
	</h2>
<div id="navigatorButton" style="display:none;text-align:center;">
	<button type="button" onclick="location.href='<%= request.getContextPath() %>'">
		<fmt:message key="jsp.dspace-admin.tomcat-restart.homepage"/>
		<%-- 回首頁 --%>
	</button>
	<button type="button" onclick="location.href='?do=true'">
		<%-- 再次重新啟動 --%>
		<fmt:message key="jsp.dspace-admin.tomcat-restart.again"/>
	</button>
</div>
</div>

<script type="text/javascript">

finishFlag = false;
var countDownTrigger = function () {
	var cd = document.getElementById("countdown");
	var time = parseInt(cd.innerHTML);
	
	var doCountDown = function (cd, time, callback) {
		setTimeout(function () {
			if (time > 0)
			{
				time--;
				cd.innerHTML = time;
				doCountDown(cd, time, callback);
			}
			else
			{
				var hint = document.getElementById("countdownHint");
				if (finishFlag == true)
				{
					callback();
				}
				else
				{
					hint.innerHTML = "<fmt:message key="jsp.dspace-admin.tomcat-restart.no-respense"/>";
					//hint.innerHTML = "伺服器似乎出了點問題，系統將在10秒鐘之後自動檢查。";
					setTimeout(function () {
						doCountDown(cd, 0, callback);
					}, 10000); 
				}
			}
		}, 1000);
	};
	doCountDown(cd, time, function () {
		var hint = document.getElementById("countdownHint");
		hint.innerHTML = "<fmt:message key="jsp.dspace-admin.tomcat-restart.success"/>";
		//hint.innerHTML = "重新啟動完成。";
		document.getElementById("navigatorButton").style.display = "block";
	});
};	

var RestartTomcat = function () {
	var rObj = new Object;
	
	var restartConfirm = jQuery("div.restart-confirm:first");
	var restartDo = jQuery("div.restart-do:first");
	
	var init = function () {
		restartConfirm.find("button:first").click(function () {
			restartConfirm.hide();
			restartDo.show();
			
			jQuery.getJSON("<%= request.getContextPath() %>/dspace-admin/tomcat-restart?action=do&callback=?", function (data) {
				if (data.success == true)
					finishFlag = true;
			});
		
			countDownTrigger();
		});
		
		if (location.search.indexOf("do=true") != -1)
		{
			restartConfirm.find("button:first").click();
		}
	
		return rObj;
	};
	
	return init();
};
RestartTomcat();

</script>

</dspace:layout>