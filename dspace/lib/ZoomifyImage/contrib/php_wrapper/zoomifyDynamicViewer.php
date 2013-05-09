<HTML>

<HEAD>
<TITLE>Zoomify Flash Dynamic Display</TITLE>
</HEAD>

<BODY BGCOLOR="#ffffff">

<DIV ALIGN="center">

<?php
	if (!($file = $_GET["file"]))
		$file = "";
	
	if (!($path = $_GET["path"]))
		$path = "upload";
		
?>

<OBJECT CLASSID="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" CODEBASE="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0" WIDTH="900" HEIGHT="550" ID="theMovie">

    <PARAM NAME="FlashVars" VALUE="zoomifyImagePath=<?= $path . $file ?>&zoomifyX=0.0&zoomifyY=0.0&zoomifyZoom=-1&zoomifyToolbar=1&zoomifyNavWindow=1">

    <PARAM NAME="src" VALUE="zoomifyDynamicViewer.swf">

    <EMBED FlashVars="zoomifyImagePath=<?= $path . $file ?>&zoomifyX=0.0&zoomifyY=0.0&zoomifyZoom=-1&zoomifyToolbar=1&zoomifyNavWindow=1" SRC="zoomifyDynamicViewer.swf" PLUGINSPAGE="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"  WIDTH="900" HEIGHT="550" NAME="theMovie">
    </EMBED>

</OBJECT>

</DIV>

</BODY>
</HTML>