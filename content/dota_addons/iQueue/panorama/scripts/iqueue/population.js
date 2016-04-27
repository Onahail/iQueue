"use strict;"

function UpdatePopulation( event )
{
	$.Msg("Updating population");
	var currentPopulation = event.currentPopulation;
	var totalPopulation = event.totalPopulation;
	
	$("#PopulationText").text = currentPopulation+"/"+totalPopulation;
}

(function () {
	
	GameEvents.Subscribe( "update_population_values", UpdatePopulation );

})();
