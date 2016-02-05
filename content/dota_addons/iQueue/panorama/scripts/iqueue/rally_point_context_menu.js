"use strict;"

function DismissMenu()
{
	$.DispatchEvent( "DismissAllContextMenus" )
}

function ContextMenuRemoveRally( event )
{
	
	var parentPanel = $.GetContextPanel().ParentPanel;
	parentPanel.RemoveRallyPoint();
	DismissMenu();
	
}

(function () {
	


})();