"use strict;"

//panel.DeleteAsync(0) 

var BuildingQueueTable = {};


function InitializeQueueTable( event ){
	
	var index = event.entindex;
	//$.Msg("Index of unit spawned: ", index);
	
	$.Schedule( 0.1, function(){
		
		if (FindUnitLabel(index, "CanQueue"))
		{
				
				//$.Msg("Initializing building queue table");
				
				BuildingQueueTable[index] = [];
				BuildingQueueTable[index]['RUSlot'] = [];
				BuildingQueueTable[index].length = 0;
				$.Schedule( 0.1, function(){
				BuildingQueueTable[index].timerState = "No Timer";})
				
				
				//$.Msg(BuildingQueueTable[index].length)	
		}
	});
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

function AddToQueue( event ){
	
	//$.Msg("AddToQueue called");
	
	var slotInfo = {queueTime : event.queueTime, abilityName : event.abilityName};
	var index = event.entindex;
	
	//$.Msg(index);
	BuildingQueueTable[index].push(slotInfo);
	//$.Msg(BuildingQueueTable[index].length);
	
}

function RemoveFromQueue( event ){
	
	var index = event.entindex;
	
	//$.Msg("Index of unit in RemoveFromQueue ", index);
	//$.Msg(BuildingQueueTable[index]);
	if (BuildingQueueTable[index][0]){
		BuildingQueueTable[index].shift();
	}
	BuildingQueueTable[index].timerState = "No Timer";
}




function MassQueue( event ){
	
	var iPlayerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var selectedEntities = Players.GetSelectedEntities( iPlayerID );

	//$.Msg("AbilityName is ", event.AbilityName);
	
	for (i = 0; i < selectedEntities.length; i++)
	{
		$.Msg("Telling server to mass queue")
		GameEvents.SendCustomGameEventToServer( "mass_queue_units", { entIndex : selectedEntities[i],
																															 AbilityName : event.AbilityName,
																															 WhatToQueue : event.WhatToQueue, 
																															 QueueTime : event.QueueTime,
																															 QueueType : event.QueueType } );		
	}
}


function ResearchOrUpgradeQueue( event )
{
	
	var iPlayerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var selectedEntities = Players.GetSelectedEntities( iPlayerID );
	
	//$.Msg(selectedEntities.length);
	
	GameEvents.SendCustomGameEventToServer( "queue_research_or_upgrade", { entIndexMainSelected : mainSelected,
																															 selectedEntities : selectedEntities,
																															 AbilityName : event.AbilityName,
																															 WhatToQueue : event.WhatToQueue, 
																															 QueueTime : event.QueueTime,
																															 QueueType : event.QueueType } );		
	
	
}


function PushTimerToTable( timer )
{		
	var index = timer.index;
	
	
	
	var queueBuildTime = timer.queueTime;
	var queueStart = timer.currentGameTime;
	var queueEndTime = queueStart + queueBuildTime;
	var timerState = "Timer";
	
	BuildingQueueTable[index][0].queueBuildTime = queueBuildTime;
	BuildingQueueTable[index][0].queueStart = queueStart;
	BuildingQueueTable[index][0].queueEndTime = queueEndTime;
	BuildingQueueTable[index].timerState = timerState;
	
	/*
	$.Msg(BuildingQueueTable[index][0].queueBuildTime);
	$.Msg(BuildingQueueTable[index][0].queueStart);
	$.Msg(BuildingQueueTable[index][0].queueEndTime);
	$.Msg(BuildingQueueTable[index][0].timerState);*/
}


function CheckControl()
{
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	//$.Msg("Player can control: ", Entities.IsControllableByPlayer( mainSelected, Game.GetLocalPlayerID()))
	
	
}




(function () {
		GameEvents.Subscribe( "npc_spawned", InitializeQueueTable );
		GameEvents.Subscribe( "add_to_queue", AddToQueue );
		GameEvents.Subscribe( "remove_from_queue", RemoveFromQueue );
		GameEvents.Subscribe( "mass_queue", MassQueue );
		GameEvents.Subscribe( "research_or_upgrade_queue", ResearchOrUpgradeQueue );
		GameEvents.Subscribe( "show_timer", PushTimerToTable );
		
		
		GameEvents.Subscribe( "dota_player_update_selected_unit", CheckControl );
		GameEvents.Subscribe( "dota_player_update_query_unit", CheckControl );
		
		
})();






















