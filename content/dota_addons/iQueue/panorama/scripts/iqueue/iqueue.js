"use strict;"

//panel.DeleteAsync(0) 

var BuildingQueueTable = BuildingQueueTable || [];


function InitializeQueueTable( event ){
	
	var index = event.entindex;
	//$.Msg("Index of unit spawned: ", index);
	
	$.Schedule( 0.1, function(){
		
		var unitLabel = GetUnitLabel(index);
		
		if (unitLabel == "CanQueue")
		{
				
				$.Msg("Initializing building queue table");
				
				BuildingQueueTable[index] = [];
				BuildingQueueTable[index].length = 0;
				$.Schedule( 0.1, function(){
				BuildingQueueTable[index].timerState = "No Timer";})
				//$.Msg(BuildingQueueTable[index].length)	
		}
	});
}

function GetUnitLabel( index )
{ 
	 	var unitLabel = Entities.GetUnitLabel( index );
		return unitLabel;
}

function AddToQueue( event ){
	
	$.Msg("AddToQueue called");
	
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
	var queueType = event.QueueType;
	
	$.Msg("AbilityName is ", event.AbilityName);
	
	if (queueType == "Unit"){
		for (i = 0; i < selectedEntities.length; i++)
		{
			$.Msg("Telling server to mass queue")
			GameEvents.SendCustomGameEventToServer( "execute_order", { entIndex : selectedEntities[i],
																																 ability : event.ability,
																																 AbilityName : event.AbilityName,
																																 WhatToQueue : event.WhatToQueue, 
																																 QueueTime : event.QueueTime,
																																 QueueType : event.QueueType } );
					
		}
	}
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


(function () {
		GameEvents.Subscribe( "npc_spawned", InitializeQueueTable );
		GameEvents.Subscribe( "add_to_queue", AddToQueue );
		GameEvents.Subscribe( "remove_from_queue", RemoveFromQueue );
		GameEvents.Subscribe( "mass_queue", MassQueue );
		GameEvents.Subscribe( "show_timer", PushTimerToTable );
})();






















