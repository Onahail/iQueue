"use strict;"


var m_QueuePanels = []
var BUILDING_QUEUE_MAX = 6;



function CreateQueuePanels()
{
	var queueParent = $("#queue_row");
	
	//queueParent.AddClass("_hidden");
	
	if (!queueParent){return;}
	
	queueParent.RemoveAndDeleteChildren();
	
	m_QueuePanels = [];
	
	for(i = 0; i < BUILDING_QUEUE_MAX; i++)
	{
		var parentPanel = queueParent;
		var queuePanel = $.CreatePanel("Panel", parentPanel, "");
		queuePanel.BLoadLayout( "file://{resources}/layout/custom_game/iqueue_panels.xml", false, false );
		queuePanel.data().SetQueueSlot( i );
		
		m_QueuePanels.push(queuePanel);
	}
		
}

function UpdateQueue()
{
	var queryBuilding = Players.GetLocalPlayerPortraitUnit();
	var unitLabel = Entities.GetUnitLabel( queryBuilding );
	
	//$.Msg("UpdateQueue value of unitLabel: ", unitLabel);
	
	if (unitLabel == "CanQueue")
	{
		for (i = 0; i < BUILDING_QUEUE_MAX; ++i)
		{
			var queuePanel = m_QueuePanels[i];
			var slot = GetQueuedInSlot(queryBuilding, i);
			//$.Msg("Value of slot in UpdateQueue: ", slot);
			queuePanel.data().SetQueue( queryBuilding, slot);
			m_SlotNumber = i;
			
			
		}
	$.Schedule( 0.1, UpdateQueue );
	}
}


function GetQueuedInSlot( queryBuilding, i)
{
	
	//$.Msg("GetQueuedInSlot called.");
	if (BuildingQueueTable[queryBuilding][i]){
		var slot = BuildingQueueTable[queryBuilding][i].abilityName;
		return slot;
	}
	
	
	
	//$.Msg("Value of slot in GetQueuedInSlot: ", slot);
	
	
	
}



(function () {
	
		GameEvents.Subscribe( "add_to_queue", UpdateQueue );
		GameEvents.Subscribe( "remove_from_queue", UpdateQueue );
		GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateQueue );
		GameEvents.Subscribe( "dota_player_update_query_unit", UpdateQueue );
	
		CreateQueuePanels();
		UpdateQueue();
		
		
    
})();