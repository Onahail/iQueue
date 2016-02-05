"use strict;"

var TREE_WAS_CLICKED = false;

function FindTreeUnderMouse()
{
	$.Msg("FindTreeUnderMouse")
	var playerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit()
	var mouseLocation = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition());
	GameEvents.SendCustomGameEventToServer( "find_tree_under_mouse", {playerID : playerID, mainSelected : mainSelected, mouseLocation : mouseLocation});
}

function WasTreeClicked( event )
{
	if (event.bWasTreeClicked == true)
	{
		$.Msg("Tree was clicked")
		TREE_WAS_CLICKED = true;
	}
	$.Msg("Tree was not clicked")
	TREE_WAS_CLICKED = false;
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

	if ( FindUnitLabel(queryUnit, "Harvester") && eventName === "pressed" &&  Entities.IsControllableByPlayer( queryUnit, Game.GetLocalPlayerID() ))
	{
		//if ( arg === 0 /*&& HarvestButtonPressed == true*/)
		//{
			//HarvestButtonPressed = false;
			//FindTreeUnderMouse();
			//return CONTINUE_PROCESSING_EVENT;
		//}
		
		if ( arg === 1 )
		{
			FindTreeUnderMouse();
			if (TREE_WAS_CLICKED == true)
			{
				return CONSUME_EVENT;
			}
			else
			{
				return CONTINUE_PROCESSING_EVENT;
			}
		}
		
	}
	return CONTINUE_PROCESSING_EVENT;
} );

function IsTargetingTree()
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


function DetermineSelection()
{
	var playerID = Players.GetLocalPlayer();
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var	selectedEntities = Players.GetSelectedEntities( playerID );
	
	if (Entities.IsControllableByPlayer( mainSelected, Game.GetLocalPlayerID()) && FindUnitLabel(mainSelected, "Harvester"))
	{
		$("#HarvestButton").SetHasClass( "_hidden", false);
	}
	else
	{
		$("#HarvestButton").SetHasClass( "_hidden", true);	
	}
	
	/*
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
	}*/
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
		GameEvents.Subscribe( "tree_clicked", WasTreeClicked );

})();