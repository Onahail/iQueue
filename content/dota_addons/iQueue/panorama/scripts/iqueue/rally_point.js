"use strict;"

var RallyTable = {};	



function InitializeRallyTable( event ){
	
	var index = event.entindex;
	
	$.Schedule( 0.1, function(){
		
		if (FindUnitLabel(index, "CanRally"))
		{
			$.Msg("Initialziing flag table for index:", index)	
			RallyTable[index] = [];
			RallyTable[index].rallySet = false;
			RallyTable.RallyButtonPressed = false;
			//$.Msg(RallyTable[index])
		}
	});
}

GameUI.SetMouseCallback( function( eventName, arg ) {
	var nMouseButton = arg
	var CONSUME_EVENT = true;
	var CONTINUE_PROCESSING_EVENT = false;
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	var playerID = Players.GetLocalPlayer();
	var selectedEntities = Players.GetSelectedEntities( playerID );
	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
		return CONTINUE_PROCESSING_EVENT;

	if ( FindUnitLabel(queryUnit, "CanRally") && eventName === "pressed" &&  Entities.IsControllableByPlayer( queryUnit, Game.GetLocalPlayerID() ))
	{
		if ( arg === 0 && RallyTable.RallyButtonPressed == true)
		{
			RallyTable.RallyButtonPressed = false;
			SetRallyPoint()
			return CONSUME_EVENT;
		}
		if ( arg === 1 )
		{
			SetRallyPoint();
			return CONSUME_EVENT;
		}
	}
	return CONTINUE_PROCESSING_EVENT;
} );

function GetRallyPointTarget()
{
	var mouseEntities = GameUI.FindScreenEntities( GameUI.GetCursorPosition() );
	mouseEntities = mouseEntities.filter( function(e) { return e.entityIndex;} );
	for ( var e of mouseEntities )
	{
		if ( !e.accurateCollision )
			continue;
		return e.entityIndex;
	}

	for ( var e of mouseEntities )
	{
		return e.entityIndex;
	}

	return -1;
}




function SetRallyPoint()
{
	var playerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var selectedEntities = Players.GetSelectedEntities( playerID );
	var mouseLocation = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition());
	var targetEntity = GetRallyPointTarget()

	for (i = 0; i < selectedEntities.length; i++)
	{
		if (FindUnitLabel( selectedEntities[i], "CanRally" ))
		{	
			//$.Msg("Setting rally for:", selectedEntities[i])
			if (targetEntity != -1)
			{
				// Player set rally point on an entity
				//$.Msg("Target is an entity: ", Entities.GetUnitName( targetEntity ))
				
				GameEvents.SendCustomGameEventToServer( "player_set_rally_point_entity", {entIndex : selectedEntities[i], targetEntity : targetEntity});
				RallyTable[selectedEntities[i]].rallySet = true;
				RallyTable[selectedEntities[i]].rallyOnEntity = true;
				RallyTable[selectedEntities[i]].targetEntity = targetEntity;
				RallyTable[selectedEntities[i]].buildingLocation = Entities.GetAbsOrigin(selectedEntities[i])
				ShowRallyPoint(selectedEntities[i], playerID)
			}
			else
			{
				// Player set rally point on ground
				GameEvents.SendCustomGameEventToServer( "player_set_rally_point_ground", {entIndex : selectedEntities[i], targetPoint : mouseLocation});
				RallyTable[selectedEntities[i]].rallySet = true;
				RallyTable[selectedEntities[i]].rallyOnEntity = false;
				RallyTable[selectedEntities[i]].flagLocation = mouseLocation;
				RallyTable[selectedEntities[i]].buildingLocation = Entities.GetAbsOrigin(selectedEntities[i])
				ShowRallyPoint(selectedEntities[i], playerID)
			}
		}
	}
}

function ShowRallyPoint(index, playerID, entityTargetRally)
{
	if (RallyTable[index].line != undefined)
	{
		Particles.DestroyParticleEffect(RallyTable[index].line, true);
		RallyTable[index].line = undefined;
	}
	if (RallyTable[index].flag != undefined)
	{
		Particles.DestroyParticleEffect(RallyTable[index].flag, true)
		RallyTable[index].flag = undefined;
	}
	
	if (RallyTable[index].flag == undefined && RallyTable[index].line == undefined &&  RallyTable[index].rallySet == true)
	{
		if (RallyTable[index].rallyOnEntity == false)
		{
			$.Msg("Recreating flag for index: ", index);
			RallyTable[index].flag = Particles.CreateParticle("particles/iqueue_particles/rally_flag.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID);
			Particles.SetParticleControl(RallyTable[index].flag, 0, RallyTable[index].flagLocation);
			
			RallyTable[index].line = Particles.CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID);
			Particles.SetParticleControl(RallyTable[index].line, 0, RallyTable[index].flagLocation);
			Particles.SetParticleControl(RallyTable[index].line, 1, RallyTable[index].buildingLocation);
			Particles.SetParticleControl(RallyTable[index].line, 2, RallyTable[index].buildingLocation);
		}
		else if (RallyTable[index].rallyOnEntity == true)
		{
			RallyTable[index].line = Particles.CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID);
			Particles.SetParticleControl(RallyTable[index].line, 0, Entities.GetAbsOrigin(RallyTable[index].targetEntity));
			Particles.SetParticleControl(RallyTable[index].line, 1, RallyTable[index].buildingLocation);
			Particles.SetParticleControl(RallyTable[index].line, 2, RallyTable[index].buildingLocation);
			KeepLineOnEntity(index)
		}
	}
}

function KeepLineOnEntity(index)
{
	var playerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();

	var targetLocation = Entities.GetAbsOrigin(RallyTable[index].targetEntity);
	if ( targetLocation !== null && RallyTable[index].rallyOnEntity == true && RallyTable[index].line != undefined)
	{
		Particles.SetParticleControl(RallyTable[index].line, 0, targetLocation); 
		$.Schedule(1/60, function(){KeepLineOnEntity(index);})
	}
}


function HideRallyPoint(index, playerID)
{
	if (RallyTable[index].line != undefined)
	{
		Particles.DestroyParticleEffect(RallyTable[index].line, true);
		RallyTable[index].line = undefined;
	}
	if (RallyTable[index].flag != undefined)
	{
		Particles.DestroyParticleEffect(RallyTable[index].flag, true);
		RallyTable[index].flag = undefined
	}
}


function DetermineSelection()
{
	
	var playerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var	selectedEntities = Players.GetSelectedEntities( playerID );
	
	if (FindUnitLabel(mainSelected, "CanRally"))
	{
		$("#RallyButton").SetHasClass( "_hidden", false);
	}
	else
	{
		$("#RallyButton").SetHasClass( "_hidden", true);	
	}
	
	if (Entities.IsControllableByPlayer( mainSelected, Game.GetLocalPlayerID()))
	{
		for (var index in RallyTable)
		{
			if (ArrayContains(selectedEntities, index))
			{
				ShowRallyPoint(index, playerID)
			}
			else
			{
				HideRallyPoint(index, playerID)
			}
		}
	}
}

function LeftClickRallyButton()
{

	$.Msg("Rally button pressed")
	
	var playerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var selectedEntities = Players.GetSelectedEntities( playerID );
	
	RallyTable.RallyButtonPressed = true;
	RallyTable[mainSelected].rallySet = false;
	
	for (i = 0; i < selectedEntities.length; i++)
	{
		if (FindUnitLabel( selectedEntities[i], "CanRally" ) == false)
		{
			var a = selectedEntities.indexOf(selectedEntities[i]);
			if (a != -1)
			{
				selectedEntities.splice(a, 1);
			}	
		}
	}
	
	for (i = 0; i < selectedEntities.length; i++)
	{
		RallyTable[selectedEntities[i]].rallySet = false;
		$.Msg(RallyTable[mainSelected].rallySet)
		if (RallyTable[selectedEntities[i]].flag != undefined)
		{
			Particles.DestroyParticleEffect(RallyTable[selectedEntities[i]].flag, true);
			Particles.DestroyParticleEffect(RallyTable[selectedEntities[i]].line, true);
			RallyTable[selectedEntities[i]].flag = undefined;
		}
		RallyTable[selectedEntities[i]].flag = Particles.CreateParticle("particles/iqueue_particles/rally_flag.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID)
		RallyTable[selectedEntities[i]].line = Particles.CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID);
		Particles.SetParticleControl(RallyTable[selectedEntities[i]].line, 1, Entities.GetAbsOrigin(selectedEntities[i]))
		Particles.SetParticleControl(RallyTable[selectedEntities[i]].line, 2, Entities.GetAbsOrigin(selectedEntities[i]))
	}
	
	var b = selectedEntities.indexOf(mainSelected);
	if (b != -1)
	{
		selectedEntities.splice(b, 1);
	}
	

	//$.Msg(mainSelected)
	//$.Msg(selectedEntities)
	//$.Msg(RallyTable[mainSelected].rallySet)
	KeepFlagOnMouse(mainSelected, selectedEntities)
	
}

function KeepFlagOnMouse(mainSelected, selectedEntities)
{
	
	//var mainSelected = Players.GetLocalPlayerPortraitUnit();
	//$.Msg(mainSelected)
	//$.Msg(selectedEntities)
	var mouseLocation = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition());
	if ( mouseLocation !== null && RallyTable[mainSelected].rallySet == false)
	{
		Particles.SetParticleControl(RallyTable[mainSelected].flag, 0, mouseLocation); 
		Particles.SetParticleControl(RallyTable[mainSelected].line, 0, mouseLocation);
		if (selectedEntities.length > 0)
		{
			for (i = 0; i < selectedEntities.length; i++)
			{
			Particles.SetParticleControl(RallyTable[selectedEntities[i]].line, 0, mouseLocation); 
			}
		}
		$.Schedule(1/60, function(){KeepFlagOnMouse(mainSelected, selectedEntities)});
	}
}






function RightClickRallyButton()
{
	
	bRallyPointActive = true;
	
	var contextMenu = $.CreatePanel( "DOTAContextMenuScript", $.GetContextPanel(), "" );
	contextMenu.AddClass( "ContextMenu_NoArrow" );
	contextMenu.AddClass( "ContextMenu_NoBorder" );
	contextMenu.GetContentsPanel().SetHasClass( "bRallyPointActive", bRallyPointActive );
	contextMenu.GetContentsPanel().BLoadLayout( "file://{resources}/layout/custom_game/rally_point_context_menu.xml", false, false );
	contextMenu.GetContentsPanel().data().ParentPanel = $("#RallyButton");
	
}

function RemoveRallyPoint()
{
	var playerID = Players.GetLocalPlayer();
	var selectedEntities = Players.GetSelectedEntities( playerID );
	
	for (i = 0; i < selectedEntities.length; i++)
	{
		if (RallyTable[selectedEntities[i]].rallySet == true)
		{
			HideRallyPoint(selectedEntities[i], playerID, false)
			GameEvents.SendCustomGameEventToServer( "player_removed_rally_point", {entIndex : selectedEntities[i]});
			RallyTable[selectedEntities[i]].rallySet = false;
		}
	}
}


function ArrayContains(array, query)
{
	for (i = 0; i < array.length; i++)
	{
		if (array[i] == query)
		{
			return true;
		}
	}
	return false;
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
	
		GameEvents.Subscribe( "dota_player_update_selected_unit", DetermineSelection );
		GameEvents.Subscribe( "dota_player_update_query_unit", DetermineSelection );
		GameEvents.Subscribe( "npc_spawned", InitializeRallyTable );
		
		$("#RallyButton").data().RemoveRallyPoint = RemoveRallyPoint;

})();