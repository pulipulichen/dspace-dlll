<%@ page contentType="application/javascript;charset=UTF-8" %>
<%@ page import="org.dspace.app.webui.util.UIUtil"
 %><%@ page import="org.dspace.core.Context"
 %><%@ page import="org.dspace.content.DSpaceObject"
 %><%
    Context c = UIUtil.obtainContext(request);
	int type = UIUtil.getIntParameter(request, "type", -1);
	int id = UIUtil.getIntParameter(request, "id", -1);
	if (type != -1 && id != -1)
	{
		DSpaceObject dso = DSpaceObject.find(c, type, id);
		if (dso != null)
		{
			UIUtil.addCounter(request, dso);
		}
	}
%>