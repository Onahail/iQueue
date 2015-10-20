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
	
	var queueTable = event.QueueTable
	var iPlayerID = Players.GetLocalPlayer();
	var selectedEntities = Players.GetSelectedEntities( iPlayerID );
	
	var slotInfo = {queueTime : event.queueTime, abilityName : event.abilityName};
	
	for (i = 0; i < selectedEntities.length; i++)
	{
		var index = selectedEntities[i];
		BuildingQueueTable[index].push(slotInfo);
		
		//$.Msg(BuildingQueueTable[index]);
		$.Msg(BuildingQueueTable[index].length);
		//x = BuildingQueueTable[index].length - 1;
		//$.Msg(BuildingQueueTable[index][x].abilityName)
	}
}

function RemoveFromQueue( event ){
	
	var index = event.entindex;
	
	//$.Msg("Index of unit in RemoveFromQueue ", index);
	//$.Msg(BuildingQueueTable[index]);
	if (BuildingQueueTable[index][0] != -1){
		BuildingQueueTable[index].shift();
	}
	
	//$.Msg(BuildingQueueTable[index].length);
	
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

			GameEvents.SendCustomGameEventToServer( "execute_order", { entIndex : selectedEntities[i],
																																 ability : event.ability,
																																 AbilityName : event.AbilityName,
																																 WhatToQueue : event.WhatToQueue, 
																																 QueueTime : event.QueueTime,
																																 QueueType : event.QueueType } );
					
		}
	}
	

}


(function () {
		GameEvents.Subscribe( "npc_spawned", InitializeQueueTable );
		GameEvents.Subscribe( "add_to_queue", AddToQueue );
		GameEvents.Subscribe( "remove_from_queue", RemoveFromQueue );
		GameEvents.Subscribe( "mass_queue", MassQueue );
})();






















