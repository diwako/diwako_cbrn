_lowRadiation =		"scripts\cbrn\sounds\cbrn_low_rad.ogg"; 	// 0.25 -> 0.75
_midRadiation = 	"scripts\cbrn\sounds\cbrn_mid_rad.ogg";		// 0.75 -> 1.25
_highRadiation = 	"scripts\cbrn\sounds\cbrn_high_rad.ogg"; 	// 1.25 -> 1.75
_dangerRadiation = 	"scripts\cbrn\sounds\cbrn_danger_rad.ogg";	// 1.75 -> 2.00
_deadlyRadiation = 	"scripts\cbrn\sounds\cbrn_deadly_rad.ogg"; 	// 2.00 -> 2.75
_runRadiation = 	"scripts\cbrn\sounds\cbrn_run_rad.ogg";		// 2.75 -> 3.00
_omgRadiation = 	"scripts\cbrn\sounds\cbrn_omg_rad.ogg";		// 3.00 ->

if (!isGameFocused || isGamePaused) exitWith {};
params ["_args", "_idPFH"];
_args params ["_lastIteration"];

private _time = cba_missiontime;
private _delta = _time - _lastIteration;
_args set [0, _time];

if ( !cbrn_beep ||  {!(ace_player getVariable ["cbrn_detector_beeps", false])} ) exitWith {
    cbrn_beepPfh = -1;
    [_idPFH] call CBA_fnc_removePerFrameHandler;
};

if (cbrn_curThreat < 0.25) exitWith {};

// private _wait = linearConversion [0.75, 3, cbrn_curThreat, 2, 0.05, true];
private _wait = 2;

private _soundPlayed = "";

if ((cbrn_lastBeep + _wait) <= _time) then {
    cbrn_lastBeep = _time;
		
	if (cbrn_curThreat > 0.25) then { _soundPlayed = _lowRadiation; };
	if (cbrn_curThreat > 0.75) then { _soundPlayed = _midRadiation; };
	if (cbrn_curThreat > 1.25) then { _soundPlayed = _highRadiation; };
	if (cbrn_curThreat > 1.75) then { _soundPlayed = _dangerRadiation; };
	if (cbrn_curThreat > 2) then { _soundPlayed = _deadlyRadiation; };
	if (cbrn_curThreat > 2.75) then { _soundPlayed = _runRadiation; };
	if (cbrn_curThreat > 3) then { _soundPlayed = _omgRadiation; };
	
	//hint _soundPlayed;
	
    playSound3D [getMissionPath _soundPlayed, ace_player];
};
