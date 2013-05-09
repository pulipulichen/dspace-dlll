jQuery.XMLMetadataDisplayTable();

jQuery(document).ready(function () {
	jQuery("textarea.general-fckeditor")
		.fck({ path:'/jspui/extension/fckeditor/'
			, toolbar: "General"
			, height: "150px"
			, width: "90%"
			, config: {
				ToolbarStartExpanded: false
				}}
			);
});