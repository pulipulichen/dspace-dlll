var fileuploadConfig = {
	"inputName": "file", 
	"step": 3,
	"page": 6,
	"url": {
		"upload": '?action=json',
		"remove": location.pathname,
		"upload_jsp": location.pathname + "/choose-file.jsp"
	},
	"maxHeight": 100,
	"imageFormat": ["jpg", "jpeg", "gif", "png", "image/png"],
	"langDelConfirm": "是否確定要刪除？",
	"delData": function (id, workspace_item_id) {
		return "submit_remove_" + id + "=移除&workspace_item_id="+workspace_item_id+"&step="+config.fileUploadStep+"&page="+config.page+"&jsp="+config.jsp 
	}
};

function dspaceFileUploadConfig()
	{
		var f = new Object;
		f.fileUploadStep = 3;
		f.page = 6;
		f.jsp = "/submit/choose-file.jsp";
		f.maxHeight = 100;
		f.imageFormat = ["jpg", "jpeg", "gif", "png", "image/png"];
		f.langDelConfirm = "是否確定要刪除？";
		return f;
	}