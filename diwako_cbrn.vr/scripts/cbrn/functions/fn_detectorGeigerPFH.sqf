_low_rad = ["cbrn_low_rad_0", "cbrn_low_rad_1", "cbrn_low_rad_2", "cbrn_low_rad_3"];
_mid_rad = ["cbrn_mid_rad_0", "cbrn_mid_rad_1", "cbrn_mid_rad_2", "cbrn_mid_rad_3"];
_high_rad = ["cbrn_high_rad_0", "cbrn_high_rad_1", "cbrn_high_rad_2", "cbrn_high_rad_3"];
_danger_rad = ["cbrn_danger_rad_0", "cbrn_danger_rad_1", "cbrn_danger_rad_2", "cbrn_danger_rad_3"];
_deadly_rad = ["cbrn_deadly_rad_0", "cbrn_deadly_rad_1", "cbrn_deadly_rad_2", "cbrn_deadly_rad_3"];
_run_rad = ["cbrn_run_rad_0", "cbrn_run_rad_1", "cbrn_run_rad_2", "cbrn_run_rad_3"];
_omg_rad = ["cbrn_omg_rad_0", "cbrn_omg_rad_1", "cbrn_omg_rad_2", "cbrn_omg_rad_3"];

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

if (cbrn_lastGeiger <= _time) then {
	cbrn_lastGeiger = _time + 0.5;
	
	private _soundPlayed = "";
	private _soundNum = cbrn_soundNum;	
	
	if (cbrn_curThreat > 0.25) then { _soundPlayed = _low_rad select _soundNum } ;
	if (cbrn_curThreat > 0.75) then { _soundPlayed = _mid_rad select _soundNum };
	if (cbrn_curThreat > 1.25) then { _soundPlayed = _high_rad select _soundNum };
	if (cbrn_curThreat > 1.75) then { _soundPlayed = _danger_rad select _soundNum };
	if (cbrn_curThreat > 2.25) then { _soundPlayed = _deadly_rad select _soundNum };
	if (cbrn_curThreat > 2.75) then { _soundPlayed = _run_rad select _soundNum };
	if (cbrn_curThreat > 3.25) then { _soundPlayed = _omg_rad select _soundNum };
	
	cbrn_soundSelect = _soundPlayed;
	
	if( _soundNum == 3 ) then [ { _soundNum = 0 }, { _soundNum = _soundNum + 1 }];
	
	cbrn_soundNum = _soundNum;
	
	playSound3D[getMissionPath "\scripts\cbrn\sounds\" + _soundPlayed + ".ogg", ace_player];
};
