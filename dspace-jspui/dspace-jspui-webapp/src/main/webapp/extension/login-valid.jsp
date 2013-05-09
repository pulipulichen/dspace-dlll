<%@ page contentType="application/x-javascript; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%
Context c = UIUtil.obtainContext(request);
EPerson user = c.getCurrentUser();

String check_userID = request.getParameter("uid");

boolean isLogin = false;

if (user == null)
	isLogin = false;
else
{
	if (check_userID == null || check_userID.equals("-1"))
		isLogin = true;
	else
	{
		String now_userID = user.getID() + "";
		if (check_userID.equals(now_userID))
			isLogin = true;
		else
			isLogin = false;
	}
}

String output = "{isLogin: \"" + isLogin + "\"}";
String callback = request.getParameter("callback");
if (callback != null)
	output = callback + "(" + output + ");";
out.print(output);
%>