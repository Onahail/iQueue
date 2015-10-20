var percent = 0;
  
function SetProgress(bar, perc)
{
  var left = bar.GetChild(0);
  var right = bar.GetChild(1);
 
  left.style.width = perc + "%";
  right.style.width = (100-perc) + "%";
}
 
function StartProgress( event ){
	
	
  var bar = $('#Progress');
  var rate = 100 / 5;
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
 
  var f = function(){
    percent += rate / 60;
    if (percent > 99.9) {
      percent = 0;
			if (BuildingQueueTable[mainSelected][0] == null){
				bar.AddClass("_hidden")
			}
    }
 
    SetProgress(bar, percent);
 
    $.Schedule(1/60, f);
  };
 
  $.Schedule(1/60, f);
 
}


(function () {
	
    GameEvents.Subscribe( "show_progress", StartProgress );
})();
