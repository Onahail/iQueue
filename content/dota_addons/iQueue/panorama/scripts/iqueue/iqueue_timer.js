"use strict;"

var m_QueueTime = -1;
var m_StartTime = -1;
var m_EndTime = -1;
var m_TimerState = m_TimerState || "No Timer";

function UpdateTimer()
{
	
	//$.Msg(panel);
	
	if (m_TimerState == "No Timer")
	{
		$.GetContextPanel().SetHasClass( "in_cooldown", false );
	}
	else if (m_QueueTime > 0)
	{
		$.GetContextPanel().SetHasClass( "in_cooldown", true );
		var currentGameTime = Game.GetGameTime();
		var timerRemaining = m_EndTime - currentGameTime;
		var timerPercent = Math.ceil( 100 * timerRemaining / m_QueueTime );
		$( "#CooldownTimer" ).text = Math.ceil( timerRemaining );
		$( "#CooldownOverlay" ).style.width = timerPercent+"%";
	}
	else{
		$.Msg("m_QueueTime is equal or less than 0");
	}
	$.Schedule( 0.1, UpdateTimer );
}

function SetTimer(queueTime, startTime, endTime)
{
		m_QueueTime = queueTime;
		m_StartTime = startTime;
		m_EndTime = endTime;
}

function SetTimerState(timerState)
{
	m_TimerState = timerState;
}




(function()
{
	$.GetContextPanel().data().SetTimer = SetTimer;
	$.GetContextPanel().data().SetTimerState = SetTimerState;
	UpdateTimer();
	
})();