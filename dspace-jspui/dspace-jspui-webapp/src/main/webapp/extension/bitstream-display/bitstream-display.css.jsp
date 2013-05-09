<%--
  - bitstream-display.css.jsp

  --%>

<%@ page import="org.dspace.app.webui.util.JSPManager" %>
<%@ page contentType="text/css;charset=UTF-8" %>
div.zoomify-album-container {
	width: 640px;
	margin: 0 auto;
	/*border: 1px solid red;*/
}

.zoomify-album-button-container tr td {
	vertical-align:middle;
	width: 24px;
}
.zoomify-album-button-container tr td.slide {
	width:450px;
}
.zoomify-album-button-container tr td.slide-title {
	font-size:small;
	font-weight: bold;
}

.zoomify-album-button-container td.next, 
.zoomify-album-button-container td.last {
	text-align:right;
}

div.zoomify-album-container .zoomify-album-slide {
	margin: 0.8em /*70px*/;
}

div.zoomify-album-container .zoomify-album-button {
	display:block;
	margin:0;
	background: #E6E6E6 url(<%= request.getContextPath() %>/extension/bitstream-display/jquery-ui/css/smoothness/images/ui-bg_glass_75_e6e6e6_1x400.png) repeat-x scroll 50% 50%;
	border: 1px solid #D3D3D3;
	width: 20px;
	height: 20px;
	text-align:center;
	
	-moz-border-radius-bottomleft: 4px;
	-moz-border-radius-bottomright: 4px;
	-moz-border-radius-topleft: 4px;
	-moz-border-radius-topright: 4px;
	-webkit-border-bottom-left-radius: 4px;
	-webkit-border-bottom-right-radius: 4px;
	-webkit-border-top-left-radius: 4px;
	-webkit-border-top-right-radius: 4px;
	outline-color: -moz-use-text-color;
	outline-style: none;
	outline-width: medium;
	-moz-background-clip: border;
	-moz-background-inline-policy: continuous;
	-moz-background-origin:padding;
	margin: 0.6em 0.1em;
}
div.zoomify-album-container .zoomify-album-button.hover {
	border-color: #666666;
}
div.zoomify-album-container .zoomify-album-button.click {
	background-image: none;
	background-color: white;
}

div.zoomify-album-container .zoomify-album-button img {
	margin-top: 8px;
}

div.zoomify-album-container .zoomify-album-slide .ui-slider-handle {
	text-align:center;
	text-decoration: none;
}
div.zoomify-album-container .zoomify-album-slide .page {
	font-size: 0.6em;
	/*padding: 0.2em 0.5em;*/
	color: gray;
	margin:0 auto;
	
}

div.zoomify-album-container .zoomify-album-slide .ui-slider-handle .slide-handle-page {
	/*font-size: 0.5em;*/
	cursor: pointer;
}
div.zoomify-album-container .zoomify-album-slide .ui-slider-handle .slide-handle-page.size3 {
	font-size: 0.7em;
	margin-top: 0.2em;
}

div.zoomify-album-container .zoomify-album-slide .ui-slider-handle .slide-handle-page.size4 {
	font-size: 0.5em;
	margin-top: 0.5em;
}


div.zoomify-album-slide-preview {
	position: absolute;
	top: 0;
	left: 0;
	width: 200px;
	text-align:center;
	font-size: small;
}
div.zoomify-album-slide-preview .page-number {
	display:inline;
	position:relative;
	top: 2em;
	width: auto;
	background: #E6E6E6 url(<%= request.getContextPath() %>/extension/bitstream-display/jquery-ui/css/smoothness/images/ui-bg_glass_75_e6e6e6_1x400.png) repeat-x scroll 50% 50%;
	border: 1px solid #666666;
	font-weight: bold;
	padding: 0 0.2em;
}
div.zoomify-album-slide-preview img {
	display:block;
	margin: 0 auto;
}

div.zoomify-album-slide-preview img {
	border: 1px solid #666666;
}

div.zoomify-album-zoomify-container {
	text-align:center;
}
div.zoomify-album-zoomify-container .cover {
	background-color:#FFFFFF;
	/*opacity: 0.8;*/
	position: absolute;
}