"use strict;"


var m_QueuePanels = []
var BUILDING_QUEUE_MAX = 6;


var timerState = timerState || "No Timer";

function CreateQueuePanels()
{
	var queueParent = $("#queue_row");
	queueParent.data().CancelQueueInSlot = CancelQueueInSlot;
	queueParent.data().CheckQueue = CheckQueue;
	
	//queueParent.AddClass("_hidden");
	
	if (!queueParent){return;}
	
	queueParent.RemoveAndDeleteChildren();
	
	m_QueuePanels = [];
	
	for(i = 0; i < BUILDING_QUEUE_MAX; i++)
	{
		var parentPanel = queueParent;
		var queuePanel = $.CreatePanel("Panel", parentPanel, "");
		
		if (i == 0){ 
			queuePanel.BLoadLayout( "file://{resources}/layout/custom_game/iqueue_panel_1.xml", false, false );
		}else{
			queuePanel.BLoadLayout( "file://{resources}/layout/custom_game/iqueue_panels.xml", false, false );
		}
		queuePanel.data().SetQueueSlot( i );
		queuePanel.data().SlotNumber = i + 1;
		queuePanel.data().ParentPanel = parentPanel;
		
		m_QueuePanels.push(queuePanel);
	}
		
}

function UpdateQueue()
{
	var queryBuilding = Players.GetLocalPlayerPortraitUnit();
	var timerPanel = m_QueuePanels[0];
	var queueParent = $("#queue_row");
	
	if (FindUnitLabel(queryBuilding, "CanQueue") && Entities.IsControllableByPlayer( queryBuilding, Game.GetLocalPlayerID()))
	{
		queueParent.SetHasClass( "_hidden", false);
		for (i = 0; i < BUILDING_QUEUE_MAX; ++i)
		{
			var queuePanel = m_QueuePanels[i];
			var slot = GetQueuedInSlot(queryBuilding, i);
			//$.Msg("Value of slot in UpdateQueue: ", slot);
			queuePanel.data().SetQueue( queryBuilding, slot, i);
			m_SlotNumber = i;
		}
		timerPanel.data().SetTimerState(BuildingQueueTable[queryBuilding].timerState)
		if (BuildingQueueTable[queryBuilding][0])
		{
			//$.Msg("Calling SetTimer");
			timerPanel.data().SetTimer(BuildingQueueTable[queryBuilding][0].queueBuildTime, 
							 BuildingQueueTable[queryBuilding][0].queueStart,
							 BuildingQueueTable[queryBuilding][0].queueEndTime);
		}
	}
	else{
		queueParent.SetHasClass( "_hidden", true);
	}
	$.Schedule( 0.05, UpdateQueue );
}


function GetQueuedInSlot( queryBuilding, i)
{
	
	//$.Msg("GetQueuedInSlot called.");
	if (BuildingQueueTable[queryBuilding][i]){
		var slot = BuildingQueueTable[queryBuilding][i].abilityName;
		return slot;
	}
}

function CheckQueue( slotNumber )
{
	var queueTableIndex = slotNumber - 1;
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	
	if (BuildingQueueTable[mainSelected][queueTableIndex]){
		return true;
	}
}

function CancelQueueInSlot( slotNumber )
{
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var queueTableIndex = slotNumber - 1;
	//$.Msg("Slot number ", slotNumber, " has been double clicked");
	if (BuildingQueueTable[mainSelected][queueTableIndex]){
		//$.Msg("Removing queue from index: ", queueTableIndex);
		BuildingQueueTable[mainSelected].splice(queueTableIndex, 1);
		
		 // Sending slotNumber because Lua is stupid and its first position in a table is 1
		GameEvents.SendCustomGameEventToServer( "remove_from_queue", { slotNumber : slotNumber, entindex : mainSelected });
	}
	UpdateQueue();
}

function ChangeTimerState( event )
{
	var index = event.entindex;
	BuildingQueueTable[index].timerState = "No Timer";
}

function FindUnitLabel( index, queryLabel )
{ 
	 	var unitLabel = Entities.GetUnitLabel( index );
		var re = RegExp(queryLabel);
		if (unitLabel.match(re)){
			return true;
		}else{
			return false;}
}






(function () {
	
		GameEvents.Subscribe( "add_to_queue", UpdateQueue );
		GameEvents.Subscribe( "remove_from_queue", UpdateQueue );
		GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateQueue );
		GameEvents.Subscribe( "dota_player_update_query_unit", UpdateQueue );
		GameEvents.Subscribe( "update_timer", UpdateQueue);
		GameEvents.Subscribe( "change_timer_state", ChangeTimerState );
	
		CreateQueuePanels();
		UpdateQueue();

})();