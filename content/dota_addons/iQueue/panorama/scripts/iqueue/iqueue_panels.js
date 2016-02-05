"use strict;"

var m_QueryBuilding = -1;
var m_Slot = -1;




function UpdateSlot()
{
	
	//$.Msg("UpdateSlot called.");
	//$.Msg("Value of m_Slot: ", m_Slot);
	var abilityName = m_Slot;
	
	//$.Msg("Value of abilityName in UpdateSlot: ", abilityName);
	
	$( "#AbilityImage" ).abilityname = abilityName;
	
	$.Schedule( 0.1, UpdateSlot );
	
}

function Cancel()
{
		var queueParent = $.GetContextPanel().ParentPanel;
		var slotNumber = $.GetContextPanel().SlotNumber;
		
		//$.Msg("Slot number: ", slotNumber);
		$.Schedule( 0.1, function(){
			queueParent.CancelQueueInSlot( slotNumber );
		} );
		
}

function ShowCancelImage()
{
	var queueParent = $.GetContextPanel().ParentPanel;
	var slotNumber = $.GetContextPanel().SlotNumber;
	
	if (queueParent.CheckQueue( slotNumber ))
	{
		$.GetContextPanel().SetHasClass( "show_cancel", true);
	}
}

function HideCancelImage()
{
	$.GetContextPanel().SetHasClass( "show_cancel", false);
}



function SetQueue( queryBuilding, slot )
{
	
	//$.Msg("SetQueue called");

	
	m_Slot = slot;
	m_QueryBuilding = queryBuilding;
	
	//$.Msg("Value of m_Slot in SetQueue: ", m_Slot);
	//$.Msg("Value of m_QueryBuilding in SetQueue: ", m_QueryBuilding);
}

function SetQueueSlot( queueSlot )
{ 
	$("#SlotNumberText").text = queueSlot + 1; 
}


(function()
{
	$.GetContextPanel().SetQueueSlot = SetQueueSlot;
	$.GetContextPanel().SetQueue = SetQueue;
	
	UpdateSlot();
})();

