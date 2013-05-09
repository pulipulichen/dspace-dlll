<%--
  - filter-media.jsp
  -	語系檔備份：

  --%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.app.util.FileUtil" %>
<%
	//String command = "[dspace]/bin/filter-media -n -v -i 707";
	//String parameter = "n=true&i=707&m=5";
	//String logID = "1099373845";
	//String logID = "1099373630";
	
	String logID = (String) request.getAttribute("logID");
	String command = (String) request.getAttribute("command");
    String parameter = (String) request.getAttribute("parameter");
%>
<dspace:layout titlekey ="jsp.dspace-admin.filter-media.display.title"
               navbar="admin"
               locbar="link"
               parenttitlekey="jsp.dspace-admin.filter-media.title"
               parentlink="/dspace-admin/filter-media"
               nocache="true">

  <table width="95%">
    <tr>
      <td align="left">
        <h1>
      		<button type="button" style="float:right" onclick="window.open('<%= request.getContextPath() %>/dspace-admin/filter-media?do_queue_manager=true&<%= parameter %>', '_blank')">
      			<%-- 管理轉檔排程 --%>
    			<fmt:message key="jsp.dspace-admin.filter-media.queue-manager"/>
      		</button>
			<%-- 多媒體轉檔 --%>
    		<fmt:message key="jsp.dspace-admin.filter-media.display.heading"/>
		</h1>
      </td>
      <td align="right" class="standard">
        <dspace:popup page='<%= LocaleSupport.getLocalizedMessage(pageContext, "help.site-admin") + "#editmessages" %>'><fmt:message key="jsp.help"/></dspace:popup>
      </td>
    </tr>
  </table>

  <style type="text/css">
  div#filterMediaDisplay span.flag {
  	border: 5px double #FF9900;
  	color: white;
  }
  div#filterMediaDisplay span.flag span {
  	background-color: #FF9900;
  }
  div#filterMediaDisplay div { padding-left: 15px; }
  div#filterMediaDisplay span.flag.complete {
  	border-color: #009933;
  }
  div#filterMediaDisplay span.flag.complete span {
  	  background-color: #009933;
  }
  div#filterMediaDisplay span.flag.error {
  	border-color: red;
  }
  div#filterMediaDisplay span.flag.error span {
  	  background-color: red;
  }
  div#filterMediaDisplay div.content
  {
  	display:block;width:90%;margin: 20px;padding: 10px;border: 1px solid gray;
  }
  div#filterMediaDisplay div.content pre
  {
  	display:block;
  	border-top: 1px solid #CCCCCC;
  }
  div#filterMediaDisplay div.content pre div.timestamp
  {
  	float:right;
  	background-color: #CCCCCC;
  	padding: 2px 5px;
  	margin-right: 0;
  	color: #FFFFFF;
  	font-size:smaller;
  }
  </style>
  
  <div id="filterMediaDisplay">
  <div>
  	  <%-- 您也可在伺服器中執行以下指令: --%>
      <fmt:message key="jsp.dspace-admin.filter-media.display.command-heading"/>
  	  <div style="padding:10px 0;margin-top:10px;"><code style="border: 1px solid gray;padding: 10px;width:90%;font-weight:bold;color:gray;"><%= command %></code></div>
  	  <button type="button" onclick="location.href='<%= request.getContextPath() %>/dspace-admin/filter-media?<%= parameter %>'">
  	  	<%-- 編輯轉檔指令 --%>
  	  	<fmt:message key="jsp.dspace-admin.filter-media.display.command-editing"/>
  	  </button>
  </div>
	
  <h2>
  	  <%-- 處理記錄 --%>
  	  <fmt:message key="jsp.dspace-admin.filter-media.display.log-heading"/>
  </h2>
  <div class="content" style="">
  	  <%-- 訊息讀取中…… --%>
  	  <fmt:message key="jsp.dspace-admin.filter-media.display.log-loading"/>
  </div>
  <div>
  	  <%-- 現在狀態： --%>
  	  <fmt:message key="jsp.dspace-admin.filter-media.display.log.status.heading"/>
  	  <%
  	  if (logID != null)
  	  {
		//out.print("<span class=\"flag\"><span>"+"讀取中"+"</span></span>");
		%>
			<span class="flag"><span>
				<%-- 讀取中 --%>
  	  			<fmt:message key="jsp.dspace-admin.filter-media.display.log.status.loading"/>
			</span></span>
		<%
	  }
	  else
	  {
	  	//out.print("<span class=\"flag error\"><span>"+"參數錯誤"+"</span></span>");
	  		%>
	  		<span class="flag error"><span>
				<%-- 參數錯誤 --%>
  	  			<fmt:message key="jsp.dspace-admin.filter-media.display.log.status.error"/>
			</span></span>
	  		<%
	  }
  	  %>
  	  <span class="time"></span>
  </div>
	  <div>
	  	<input type="checkbox" checked="checked" id="auto_scroll" />
	  	<label for="auto_scroll">
	  		  	<%-- 當有更新時，自動跳到最新更新處 --%>
  	  			<fmt:message key="jsp.dspace-admin.filter-media.display.log.auto-scroll"/>
	  	</label>
	  </div>
  </div>
  <%
  if (logID != null)
  {
  	%>
  	<script type="text/javascript">
  	
  	function setStatus(msg, className)
  	{
  		var flag = jQuery("div#filterMediaDisplay span.flag:first");
  		flag.find("span").html(msg);
  		
  		if (typeof(className) == "string")
  			flag.attr("className", "flag " + className);
  		
  		
	  	setTime();
  	}
  	function isComplete()
  	{
  		if (typeof(filterMediaComplete) == "boolean" && filterMediaComplete == true)
  			return true;
  		else
  			return false;
  	}
  	
  	function scollBottom()
  	{
  		if (jQuery("#auto_scroll:checked").length == 1)
  		{  		
	  		var flag = jQuery("div#filterMediaDisplay span.flag:first");
	  		//讓畫面跳到這邊吧
	  		var offsetTop = flag.attr("offsetTop");
		  	offsetTop = offsetTop - 100;
		  	scrollTo(window.scrollX, offsetTop);
		}
  	}
  	
  	function setContent(msg, isAppend)
  	{
  		if (typeof(isAppend) == "boolean" && isAppend == true)
  		{
  			msg = jQuery("div#filterMediaDisplay pre.content:first").html() + "<br/>\n<br/>\n" + msg;
  		}
  		jQuery("div#filterMediaDisplay pre.content:first").html(msg);
  	}
  	
  	function pushContent(msg)
  	{
  		if (msg == "")
  			return;
		
		//msg = unescape(msg);
		//msg = jQuery.trim(msg);
		
		//if (jQuery.browser.msie && msg != "")
			msg = msg.replace(new RegExp("\\\\n", 'g'), "<br />");
  		var m = jQuery("<pre title=\"取得時間："+getTime()+"\"></pre>")
  			.html(msg);
  		
  		var time = jQuery("<div class=\"timestamp\"></div>")
  			.html(getTime())
  			.prependTo(m);
  		
  		jQuery("div#filterMediaDisplay div.content:first").append(m);
  	}
  	
  	function getContent()
  	{
  		var c = jQuery("div#filterMediaDisplay pre.content:first").html();
  		c = jQuery.trim(c);
  		return c;
  	}
  	function getTime()
  	{
  		var d = new Date();
  		
  		var h = d.getHours();
  		var m = d.getMinutes() + "";
  		if (m.length < 2)
  			m = "0" + m;
  		var s = d.getSeconds() + "";
  		if (s.length < 2)
  			s = "0" + s;
  		
  		return h + ":" + m + ":" + s;
  	}
  	function setTime(defaultTime)
  	{
  		if (typeof(defaultTime) == "undefined")
  			defaultTime = time;
  		
  		var d = new Date();
  		
  		var h = d.getHours();
  		var m = d.getMinutes() + "";
  		if (m.length < 2)
  			m = "0" + m;
  		var s = d.getSeconds() + "";
  		if (s.length < 2)
  			s = "0" + s;
  		
  		var nh = d.getHours();
  		var nm = d.getMinutes();
  		var ns = d.getSeconds();
  		ns = ns + (defaultTime / 1000);
  		if (ns > 59)
  		{
  			var add_minute = parseInt(ns / 60);
  			nm = nm + add_minute;
  			ns = ns % 60;
  		}
  		if (nm > 59)
  		{
  			var add_hour = parseInt(nm / 60);
  			nh = parseInt(nh) + add_hour;
  			nm = nm % 60;
  		}
  		
  		var cost = parseInt((d.getTime() - startTime.getTime())/1000);
  		
  		var costH = 0;
  		var costM = 0;
  		var costS = cost;
  		
  		var carry = function (base, advan, denominator)
  		{
  			if (base > denominator -1)
  			{
  				var add = parseInt(base / denominator);
  				advan = advan + add;
  				base = base % denominator;
  			}
  			return [base, advan];
  		};
  		
  		var temp = carry(costS, costM, 60);
  		costS = temp[0];
  		costM = temp[1];
  		var temp = carry(costM, costH, 60);
  		costM = temp[0];
  		costH = temp[1];
  		
  		var fill = function(num) {
  			if (num < 10)
  				num = "0" + num;
  			else
  				num = "" + num;
  			return num;
  		}
  		
  		var costOutput = fill(costS) 
  			<%-- + "秒"; --%>
  			+ "<fmt:message key="jsp.dspace-admin.filter-media.display.js.second"/>";
  		if (costM > 0)
  			costOutput = fill(costM) 
  				<%-- + "分" --%>
  				+ "<fmt:message key="jsp.dspace-admin.filter-media.display.js.minute"/>"
  				+ costOutput;
  		if (costH > 0)
  			costOutput = costH 
  				<%-- + "小時" --%>
  				+ "<fmt:message key="jsp.dspace-admin.filter-media.display.js.hour"/>"
  				+ costOutput;
  		
  		
  		var msg = "；";
  		msg = msg 
  			<%-- + "最近讀取時間：<span class=\"last-load\">" --%>
  			+ "<fmt:message key="jsp.dspace-admin.filter-media.display.js.last-load-time"/> <span class=\"last-load\">"
  			+ h + ":" + m + ":" + s + "</span>；";
  		if (isComplete() == false)
  		{
  			msg = msg 
  				<%-- + "等待間隔時間：" --%>
  				+ "<fmt:message key="jsp.dspace-admin.filter-media.display.js.wait-internal-time"/>"
  				+ "<span class=\"next-wait\">" + (defaultTime / 1000) + "</span>秒；";
  			msg = msg 
  				<%-- + "下次讀取時間：" --%>
  				+ "<fmt:message key="jsp.dspace-admin.filter-media.display.js.next-load-time"/>"
  				+ "<span class=\"next-load\">" + nh + ":" + fill(nm) + ":" + fill(ns) + "</span>；";
  		}
  		msg = msg 
  			<%-- + "已經執行時間："  --%>
  			+ "<fmt:message key="jsp.dspace-admin.filter-media.display.js.cost-time"/>"
  			+ "<span class=\"cost-time\">" + costOutput + "</span>";
  		jQuery("div#filterMediaDisplay span.time:first").html(msg);
  	}
  	
  	var waitTime = 10000;
  	time = waitTime;
  	var expand = waitTime / 2;
  	var maxWait = waitTime * 6 * 30;
  	
  	var queueWaitTime = waitTime * 10;
    var getJSONtimeout = waitTime * 6 * 10;
  	var logStart = 0;
  	var logLines = 0;
  	
  	loaded = false;
  	
  	getJSONsuccess = function (data) {
  				logLines = data.lines;
  				logStart = logLines + 1;
  				
  				var c = jQuery.trim(unescape(data.content));
  				
  				if (c.substring(c.length - 2) == "\\n")
  					c = c.substring(0, c.length-2);
  				
  				var needle = "Filter-media complete";
  				var isComplete = (c.substring(c.length - needle.length, c.length) ==  needle);
	  			if (data.status == "log")
	  			{
	  				//var changed = (jQuery.trim(data.content) != getContent());
	  				var changed = (c != "");
	  				if (changed == true)
	  				{
		  				
		  				pushContent(c);
		  				
		  				if (isComplete == false)
		  				{
		  					loaded = true;
		  					time = waitTime;
		  					<%-- setStatus("處理中"); --%>
		  					setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.processing"/>");
		  					scollBottom();
		  					setTimeout(loadLog, time);
		  				}
		  				else
		  				{
		  					filterMediaComplete = true;
		  					<%-- setStatus("完成", "complete"); --%>
		  					setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.complete"/>", "complete");
		  					scollBottom();
		  				}
		  			}
		  			else
		  			{
		  				time = time + expand;
		  				<%-- setStatus("處理中"); --%>
		  				setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.processing"/>");
		  				setTimeout(loadLog, time);
		  			}
	  			}
	  			else if (data.status == "queue")
	  			{
	  				<%-- setStatus("排隊中", "queue"); --%>
	  				setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.in-queue"/>", "queue");
	  				setTime(queueWaitTime);
	  				var changed = (jQuery.trim(data.content) != getContent());
	  				if (changed == true)
	  				{
		  				var c = jQuery.trim(data.content);
		  				setContent(c);
		  				scollBottom();
		  			}
		  			setTimeout(loadLog, queueWaitTime);
	  			}
	  			else if (data.status == "out_of_queue")
	  			{
	  				<%-- setStatus("錯誤", "error"); 
	  				setContent("排隊中找不到這個任務。", true); --%>
	  				setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.error"/>", "error"); 
	  				setContent("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.queue-not-found"/>", true);
	  				scollBottom();
	  			}
	  			else if (data.status == "lost_parameter")
	  			{
	  				<%-- setStatus("錯誤", "error");
	  				setContent("遺失參數。"); --%>
	  				setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.error"/>", "error");
	  				setContent("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.parameter-lost"/>");
	  				scollBottom();
	  			}
	  			else //if (data.status == "no_file")
	  			{
	  				if (loaded == true)
	  				{
	  					if (isComplete == true)
	  					{
	  						<%-- setStatus("完成", "complete"); --%>
	  						setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.complete"/>", "complete");
	  					}
	  					else
	  					{
	  						<%-- setStatus("錯誤", "error");
	  						setContent("轉檔尚未處理完畢，但是記錄檔已經被刪除。", true); --%>
	  						setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.error"/>", "error");
	  						setContent("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.log-deleted"/>", true);
	  					}
	  					
	  				}
	  				else
	  				{
	  					<%-- setStatus("錯誤", "error");
	  					setContent("沒有產生記錄檔。"); --%>
	  					setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.error"/>", "error");
	  					setContent("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.log-not-found"/>");
	  				}
	  				scollBottom();
	  			}
	  		};
  	getJSONurl = "<%= request.getContextPath() %>/extension/filter-media/get-filter-media-log.jsp?logID=<%= logID %>&callback=?";
  	getJSONerror = function()
  	{
  		<%-- var msg = "\n\n伺服器錯誤，或是伺服器超過" + (getJSONtimeout/1000) + "秒沒有回應，可能已經斷線，請聯絡管理者以修復這個問題。"; --%>
  		var msg = "\n\n" + "<fmt:message key="jsp.dspace-admin.filter-media.display.js.error-message1"/>" + (getJSONtimeout/1000) + "<fmt:message key="jsp.dspace-admin.filter-media.display.js.error-message2"/>";
  		setContent(msg, true);
  		setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.error"/>", "error");
  		scollBottom();
  		alert(msg)
  	}
  	
  	//alert(getJSONurl);
  	
  	function loadLog() 
  	{
  		if (time == maxWait || time > maxWait)
  		{
  			setTime();
			setStatus("<fmt:message key="jsp.dspace-admin.filter-media.display.js.status.error"/>", "error");
			<%-- setContent("\n\n" + "等待時間超過" + (maxWait / 1000) + "，可能發生錯誤了，停止讀取。", true); --%>
			setContent("\n\n" + "<fmt:message key="jsp.dspace-admin.filter-media.display.js.wait-time-over1"/>" + (maxWait / 1000) + "<fmt:message key="jsp.dspace-admin.filter-media.display.js.wait-time-over2"/>", true);
			return;
  		}
  		
  		var url = getJSONurl + "&start=" + logStart;
  		jQuery.getJSON(url
	  		, getJSONsuccess);
	  	
	  	/*
	  	jQuery.ajax({
	  		url: getJSONurl,
	  		dataType: "json",
	  		success: getJSONsuccess,
	  		timeout: getJSONtimeout,
	  		error: getJSONerror
	  	});
	  	*/
  	}
  	
  	startTime = new Date();
  	setTimeout(loadLog, 1500);
  	</script>
  	<%
  }
  %>
  
</dspace:layout>