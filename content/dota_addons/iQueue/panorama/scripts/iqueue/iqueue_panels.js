"use strict;"

var m_QueryBuilding = -1;
var m_Slot = -1;
var m_SlotNumber = 0;


function UpdateSlot()
{
	
	//$.Msg("UpdateSlot called.");
	//$.Msg("Value of m_Slot: ", m_Slot);
	
	
	var abilityName = m_Slot;
	
	//$.Msg("Value of abilityName in UpdateSlot: ", abilityName);
	
	$( "#AbilityImage" ).abilityname = abilityName;
	$.GetContextPanel().SetHasClass( "in_cooldown", true );
	
	$.Schedule( 0.1, UpdateSlot );
	
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
	m_QueueSlot = queueSlot;
	$("#SlotNumberText").text = queueSlot + 1; 
	
}


(function()
{
	$.GetContextPanel().data().SetQueueSlot = SetQueueSlot;
	$.GetContextPanel().data().SetQueue = SetQueue;
	
	UpdateSlot();
})();

