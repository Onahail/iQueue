"use scrict";
 
//panel.DeleteAsync(0) 

function OnBuildingSelection( event ) {
		
		var mainSelected = Players.GetLocalPlayerPortraitUnit();
		var queueRoot = $("#queue_row")
		
		if (Entities.GetUnitLabel( mainSelected ) == "CanQueue"){
			//$.Msg("Index ", mainSelected, " contains ", BuildingQueueTable[mainSelected]);
			//$.Msg(print_r(BuildingQueueTable[mainSelected]));
		}
		

		//$.Msg( "Player ", iPlayerID, " Selected Entities (", selectedEntities.length, ")" );
		//$.Msg( "Player ", iPlayerID, " Main Selected (", mainSelected, ")" );	
		
	/*
		if ( CanQueue(mainSelected) ){
			ShowQueue(queueRoot);
			//$.Msg("CanQueue returned true");
		} else {
			if (queueRoot.BHasClass){
				HideQueue(queueRoot);
			}
		}
	*/
		// Function check
		
		//$.Msg( "Unit Label is ", unitLabel);
		
		//GameEvents.SendCustomGameEventToServer( "player_clicked_building", { pID : iPlayerID } );  //Uncomment if needed for some reason
		
}

function CanQueue( entityIndex ){
	
	//$.Msg("Function called properly")
	
	return (Entities.GetUnitLabel( entityIndex ) == "CanQueue");
}

function HideQueue( panel ){
	panel.AddClass("_hidden")
	panel.hittest = false;
}

function ShowQueue( panel ){
	panel.RemoveClass("_hidden")
}

(function () {
	GameEvents.Subscribe( "dota_player_update_selected_unit", OnBuildingSelection );
})();




















function print_r(arr,level) {
var dumped_text = "";
if(!level) level = 0;

//The padding given at the beginning of the line.
var level_padding = "";
for(var j=0;j<level+1;j++) level_padding += "    ";

if(typeof(arr) == 'object') { //Array/Hashes/Objects 
    for(var item in arr) {
        var value = arr[item];

        if(typeof(value) == 'object') { //If it is an array,
            dumped_text += level_padding + "'" + item + "' ...\n";
            dumped_text += print_r(value,level+1);
        } else {
            dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
        }
    }
} else { //Stings/Chars/Numbers etc.
    dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
}
return dumped_text;
}
