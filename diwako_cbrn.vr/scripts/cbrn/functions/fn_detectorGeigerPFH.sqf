if (!isGameFocused || isGamePaused) exitWith {};
params ["_args", "_idPFH"];
_args params ["_lastIteration"];

private _time = cba_missiontime;
private _delta = _time - _lastIteration;
_args set [0, _time];

if ( !cbrn_geiger ||  {!(ace_player getVariable ["cbrn_detector_geiger", false])} ) exitWith {
    cbrn_geigerPfh = -1;
    [_idPFH] call CBA_fnc_removePerFrameHandler;
};

if (cbrn_curThreat < 0.25) exitWith {};

private _wait = 2;

if ((cbrn_lastGeiger + _wait) <= _time) then {
    cbrn_lastGeiger = _time;
	deleteVehicle _soundSrc;
	
	private _soundPlayed = "";
	
	if (cbrn_curThreat > 0.25) then { _soundPlayed = "cbrn_low_rad"; };
	if (cbrn_curThreat > 0.75) then { _soundPlayed = "cbrn_mid_rad"; };
	if (cbrn_curThreat > 1.25) then { _soundPlayed = "cbrn_high_rad"; };
	if (cbrn_curThreat > 1.75) then { _soundPlayed = "cbrn_danger_rad"; };
	if (cbrn_curThreat > 2.25) then { _soundPlayed = "cbrn_deadly_rad"; };
	if (cbrn_curThreat > 2.75) then { _soundPlayed = "cbrn_run_rad"; };
	if (cbrn_curThreat > 3.25) then { _soundPlayed = "cbrn_omg_rad"; };
	
	ace_player setVariable ["cbrn_last_sound", _soundPlayed];

	private _soundSrc = ace_player say3D _soundPlayed;
};
