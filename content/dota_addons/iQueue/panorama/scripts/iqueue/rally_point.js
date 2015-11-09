"use strict;"

var FlagTable = {};	

function InitializeFlagTable( event ){
	
	var index = event.entindex;
	
	$.Schedule( 0.1, function(){
		
		if (FindUnitLabel(index, "CanRally"))
		{
			$.Msg("Initialziing flag table for index:", index)	
			FlagTable[index] = [];
			//$.Msg(FlagTable[index])
		}
	});
}

GameUI.SetMouseCallback( function( eventName, arg ) {
	var nMouseButton = arg
	var CONSUME_EVENT = true;
	var CONTINUE_PROCESSING_EVENT = false;
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
		return CONTINUE_PROCESSING_EVENT;

	if ( FindUnitLabel(queryUnit, "CanRally") && eventName === "pressed" )
	{
		if ( arg === 1 )
		{
			//$.Msg("Right click when building selected")
			if (Entities.IsControllableByPlayer( queryUnit, Game.GetLocalPlayerID() ))
			{
					SetRallyPoint();
					return CONSUME_EVENT;
			}
		}
	}
	return CONTINUE_PROCESSING_EVENT;
} );


function SetRallyPoint()
{
	var playerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var selectedEntities = Players.GetSelectedEntities( playerID );
	var mouseLocation = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition());

	for (i = 0; i < selectedEntities.length; i++)
	{
		if (FindUnitLabel( selectedEntities[i], "CanRally" ))
		{		
			//$.Msg("Setting rally for:", selectedEntities[i])
			if (FlagTable[selectedEntities[i]].flag != undefined){
				Particles.DestroyParticleEffect(FlagTable[selectedEntities[i]].flag, true);
				Particles.DestroyParticleEffect(FlagTable[selectedEntities[i]].line, true);
				FlagTable[selectedEntities[i]].flag = undefined;
			}
			GameEvents.SendCustomGameEventToServer( "player_set_rally_point", {entIndex : selectedEntities[i], targetPoint : mouseLocation});
			FlagTable[selectedEntities[i]].flag = Particles.CreateParticle("particles/iqueue_particles/rally_flag.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID);
			Particles.SetParticleControl(FlagTable[selectedEntities[i]].flag, 0, mouseLocation)
			
			FlagTable[selectedEntities[i]].line = Particles.CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID);
			Particles.SetParticleControl(FlagTable[selectedEntities[i]].line, 0, mouseLocation)
			Particles.SetParticleControl(FlagTable[selectedEntities[i]].line, 1, Entities.GetAbsOrigin(selectedEntities[i]))
			Particles.SetParticleControl(FlagTable[selectedEntities[i]].line, 2, Entities.GetAbsOrigin(selectedEntities[i]))
			
			
			FlagTable[selectedEntities[i]].rallySet = true;
			FlagTable[selectedEntities[i]].flagLocation = mouseLocation;
			FlagTable[selectedEntities[i]].buildingLocation = Entities.GetAbsOrigin(selectedEntities[i])
			//$.Msg(FlagTable[selectedEntities[i]].flagLocation)
		}
	}
}

function DetermineSelection()
{
	
	var playerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var	selectedEntities = Players.GetSelectedEntities( playerID );
	
	//$.Msg(selectedEntities)
	for (var index in FlagTable)
	{
		//FlagTable[index].currentlySelected = false
		$.Msg( index );

		if (ArrayContains(selectedEntities, index))
		{
			//FlagTable[index].currentlySelected = true;
			$.Msg(index, " is part of selectedEntities")
			ShowRallyPoint(index, playerID)
		}
		else
		{
			$.Msg(index, " is not part of selectedEntities")
			HideRallyPoint(index, playerID)
		}
	}
}

function ShowRallyPoint(index, playerID)
{
	if (FlagTable[index].flag == undefined)
	{
		$.Msg("Recreating flag for index: ", index);
		FlagTable[index].flag = Particles.CreateParticle("particles/iqueue_particles/rally_flag.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID);
		Particles.SetParticleControl(FlagTable[index].flag, 0, FlagTable[index].flagLocation);
		
		FlagTable[index].line = Particles.CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID);
		Particles.SetParticleControl(FlagTable[index].line, 0, FlagTable[index].flagLocation);
		Particles.SetParticleControl(FlagTable[index].line, 1, FlagTable[index].buildingLocation);
		Particles.SetParticleControl(FlagTable[index].line, 2, FlagTable[index].buildingLocation);
	}
}

function HideRallyPoint(index, playerID)
{
	if (FlagTable[index].flag != undefined)
	{
		$.Msg("Destroying flag for index: ", index)
		Particles.DestroyParticleEffect(FlagTable[index].flag, true);
		Particles.DestroyParticleEffect(FlagTable[index].line, true);
		FlagTable[index].flag = undefined;
	}
}

/*
function ShowOrHideRallyPoint()
{
	var playerID = Players.GetLocalPlayer();
	
	for (var index in FlagTable)
	{
		if (FlagTable[index].currentlySelected == true)
		{
			if (FlagTable[index].rallySet == true && FlagTable[index].flag == undefined)
			{
				$.Msg("Recreating flag for index: ", index);
				FlagTable[index].flag = Particles.CreateParticle("particles/iqueue_particles/rally_flag.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID);
				Particles.SetParticleControl(FlagTable[index].flag, 0, FlagTable[index].flagLocation);
				
				FlagTable[index].line = Particles.CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", ParticleAttachment_t.PATTACH_CUSTOMORIGIN, playerID);
				Particles.SetParticleControl(FlagTable[index].line, 0, FlagTable[index].flagLocation);
				Particles.SetParticleControl(FlagTable[index].line, 1, FlagTable[index].buildingLocation);
				Particles.SetParticleControl(FlagTable[index].line, 2, FlagTable[index].buildingLocation);
			}
		}
		else if (FlagTable[index].currentlySelected = false && FlagTable[index].flag != undefined)
		{
			$.Msg("Destroying flag for index: ", index)
			Particles.DestroyParticleEffect(FlagTable[index].flag, true);
			Particles.DestroyParticleEffect(FlagTable[index].line, true);
			FlagTable[index].flag = undefined;
		} 
	}
}*/


function RightClickRallyButton()
{
	
	bRallyPointActive = true;
	
	var contextMenu = $.CreatePanel( "DOTAContextMenuScript", $.GetContextPanel(), "" );
	contextMenu.AddClass( "ContextMenu_NoArrow" );
	contextMenu.AddClass( "ContextMenu_NoBorder" );
	contextMenu.GetContentsPanel().SetHasClass( "bRallyPointActive", bRallyPointActive );
	contextMenu.GetContentsPanel().BLoadLayout( "file://{resources}/layout/custom_game/rally_point_context_menu.xml", false, false );
	
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









(function () {
	
		GameEvents.Subscribe( "dota_player_update_selected_unit", DetermineSelection );
		GameEvents.Subscribe( "dota_player_update_query_unit", DetermineSelection );
		GameEvents.Subscribe( "npc_spawned", InitializeFlagTable );

})();