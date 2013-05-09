//var debug = true;

jQuery.extend({

    createUploadIframe: function(id, uri)
	{
			//create frame
            var frameId = 'jUploadFrame' + id;
            
            if(window.ActiveXObject) {
                var io = document.createElement('<iframe id="' + frameId + '" name="' + frameId + '" />');
                if(typeof uri== 'boolean'){
                    io.src = 'javascript:false';
                }
                else if(typeof uri== 'string'){
                    io.src = uri;
                }
            }
            else {
                var io = document.createElement('iframe');
                io.id = frameId;
                io.name = frameId;
            }
            io.style.position = 'absolute';
            io.style.top = '-1000px';
            io.style.left = '-1000px';
			if (typeof(debug) != "undefined")
			{
            	io.style.top = '1px';
            	io.style.left = '1px';
			}

            document.body.appendChild(io);

            return io;
    },
    createUploadForm: function(id, fileElementId, workspace_item_id, step, jsp, description)
	{
		//create form	
		var formId = 'jUploadForm' + id;
		var fileId = 'jUploadFile' + id;
		var form = $('<form  action="" method="POST" name="' + formId + '" id="' + formId + '" enctype="multipart/form-data"></form>');	
		var oldElement = $('#' + fileElementId);
		var newElement = $(oldElement).clone();
		$(oldElement).attr('id', fileId);
		$(oldElement).before(newElement);
		$(oldElement).appendTo(form);
		
		form.append('<input type="hidden" name="step" value="'+step+'"/>');
		//form.append('<input type="hidden" name="page" value="'+page+'"/>');
		form.append('<input type="hidden" name="jsp" value="'+jsp+'"/>');
		form.append('<input type="hidden" name="description" id="tdescription" value="'+description+'" />');
		form.append('<input type="hidden" name="submit_upload" value="&gt;"/>');
		
		if (location.href.indexOf("/submit") != -1)
			form.append('<input type="hidden" name="workspace_item_id" value="'+workspace_item_id+'"/>');
		else
			form.append('<input type="hidden" name="item_id" value="'+workspace_item_id+'"/>');

		//set attributes
		$(form).css('position', 'absolute');
		$(form).css('top', '-1200px');
		$(form).css('left', '-1200px');
		
		if (typeof(debug) != "undefined")
		{
			$(form).css('top', '200px');
			$(form).css('left', '200px');
		}
		
		$(form).appendTo('body');		
		return form;
    },

    ajaxFileUpload: function(s) {
        // TODO introduce global settings, allowing the client to modify them for all requests, not only timeout		
        s = jQuery.extend({}, jQuery.ajaxSettings, s);
        var id = new Date().getTime();
		var form = jQuery.createUploadForm(id, s.fileElementId, s.workspace_item_id, s.file_upload_step, s.file_upload_JSP, s.file_description);
		var io = jQuery.createUploadIframe(id, s.secureuri);	
		var frameId = 'jUploadFrame' + id;
		var formId = 'jUploadForm' + id;		
        // Watch for a new set of requests
        if ( s.global && ! jQuery.active++ )
		{
			jQuery.event.trigger( "ajaxStart" );
		}            
        var requestDone = false;
        // Create the request object
        var xml = {}   
        if ( s.global )
            jQuery.event.trigger("ajaxSend", [xml, s]);
        // Wait for a response to come back
        var uploadCallback = function(isTimeout)
		{			
			var io = document.getElementById(frameId);
			
            try 
			{				
				if(io.contentWindow)
				{
					 xml.responseText = io.contentWindow.document.body?io.contentWindow.document.body.innerHTML:null;
                	 xml.responseXML = io.contentWindow.document.XMLDocument?io.contentWindow.document.XMLDocument:io.contentWindow.document;
					 var doc = jQuery(io.contentWindow.document);
					 
				}else if(io.contentDocument)
				{
					 xml.responseText = io.contentDocument.document.body?io.contentDocument.document.body.innerHTML:null;
                	xml.responseXML = io.contentDocument.document.XMLDocument?io.contentDocument.document.XMLDocument:io.contentDocument.document;
                	
					var doc = jQuery(io.contentDocument.document);
				}
				
				if (typeof(debug) != "undefined")
					alert("有正確讀入doc");
					
				//偵測是否設定錯誤
				var jsp = doc.find("input[type='hidden'][name='jsp']").val();
				if (jsp == "/submit/verify-prune.jsp")
				{
					alert("需要確認！");
					doc.find("input[type='submit'][name='prune']").click();
					doc.find("form").attr("action", "");
					document.getElementById(frameId).onload(function () {
						uploadCallback(false);											  
					});
					return;
				}
            }catch(e)
			{
				jQuery.handleError(s, xml, null, e);
			}
			
			if (doc.find("div").length > 0)
				doc.find("div").remove();
			
            if ( xml || isTimeout == "timeout") 
			{				
                requestDone = true;
                var status;
                try {
                    status = isTimeout != "timeout" ? "success" : "error";
                    // Make sure that the request was successful or notmodified
                    if ( status != "error" )
					{
                        // process the data (runs the xml through httpData regardless of callback)
                        var data = jQuery.uploadHttpData( xml, s.dataType );    
                        // If a local callback was specified, fire it and pass it the data
                        if ( s.success )
                            s.success( data, status );
    
                        // Fire the global callback
                        if( s.global )
                            jQuery.event.trigger( "ajaxSuccess", [xml, s] );
                    } else
                        jQuery.handleError(s, xml, status);
                } catch(e) 
				{
                    status = "error";
                    jQuery.handleError(s, xml, status, e);
                }

                // The request was completed
                if( s.global )
                    jQuery.event.trigger( "ajaxComplete", [xml, s] );

                // Handle the global AJAX counter
                if ( s.global && ! --jQuery.active )
                    jQuery.event.trigger( "ajaxStop" );

                // Process result
                if ( s.complete )
                    s.complete(xml, status);

                jQuery(io).unbind()

                setTimeout(function()
									{	try 
										{
											if (typeof(debug) == "undefined")
											{
												$(io).remove();
												$(form).remove();
											}
											
										} catch(e) 
										{
											jQuery.handleError(s, xml, null, e);
										}									

									}, 100)

                xml = null

            }
        }
        // Timeout checker
        if ( s.timeout > 0 ) 
		{
            setTimeout(function(){
                // Check to see if the request is still happening
                if( !requestDone ) uploadCallback( "timeout" );
            }, s.timeout);
        }
        try 
		{
           // var io = $('#' + frameId);
			var form = $('#' + formId);
			$(form).attr('action', s.url);
			$(form).attr('method', 'POST');
			$(form).attr('target', frameId);
			
			if (typeof(debug) != "undefined")
				alert(s.url);
			
            if(form.encoding)
			{
                form.encoding = 'multipart/form-data';				
            }
            else
			{				
                form.enctype = 'multipart/form-data';
            }			
            $(form).submit();

        } catch(e) 
		{			
            jQuery.handleError(s, xml, null, e);
        }
        if(window.attachEvent){
            document.getElementById(frameId).attachEvent('onload', uploadCallback);
        }
        else{
            document.getElementById(frameId).addEventListener('load', uploadCallback, false);
        } 		
        return {abort: function () {}};	

    },

    uploadHttpData: function( r, type ) {
        var data = !type;
        data = type == "xml" || data ? r.responseXML : r.responseText;
		
		data = data.replace("<div_prefs></div_prefs>", "");
		if (data.indexOf("}") != -1)
		{
			data = data.substr(0, data.indexOf("}") + 1);
		}
		
		if (typeof(debug) != "undefined")
			alert("uploadHttpData: \n" + data);
		
        // If the type is "script", eval it in global context
        if ( type == "script" )
            jQuery.globalEval( data );
        // Get the JavaScript object, if JSON is used.
        if ( type == "json" )
            eval( "data = " + data );
        // evaluate scripts within html
        if ( type == "html" )
        {
            jQuery("<div>").html(data).evalScripts();
			//alert($('param', data).each(function(){alert($(this).attr('value'));}));
		}
        return data;
    }
})

