// JavaScript Document
function FCKeditor_OnComplete( editorInstance )
{
	editorInstance.Events.AttachEvent( 'OnBlur'	, FCKeditor_OnBlur ) ;
	editorInstance.Events.AttachEvent( 'OnFocus', FCKeditor_OnFocus ) ;
}

function FCKeditor_OnBlur( editorInstance )
{			
	editorInstance.ToolbarSet.Collapse() ;
	editorInstance.UpdateLinkedField();
	jQuery(editorInstance.LinkedField).change();
}

function FCKeditor_OnFocus( editorInstance )
{
	editorInstance.ToolbarSet.Expand() ;
}