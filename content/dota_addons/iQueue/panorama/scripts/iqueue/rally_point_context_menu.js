"use strict;"

function DismissMenu()
{
	$.DispatchEvent( "DismissAllContextMenus" )
}

function ContextMenuRemoveRally( event )
{
	
	var parentPanel = $.GetContextPanel().data().ParentPanel;
	parentPanel.data().RemoveRallyPoint();
	DismissMenu();
	
}

(function () {
	


})();