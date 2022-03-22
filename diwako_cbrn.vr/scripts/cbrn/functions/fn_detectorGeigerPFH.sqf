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

private _soundPlayed = "cbrn_low_rad";
switch (true) do {
    case (cbrn_curThreat > 3.25): { _soundPlayed = "cbrn_omg_rad" };
    case (cbrn_curThreat > 2.75): { _soundPlayed = "cbrn_run_rad" };
    case (cbrn_curThreat > 2.25): { _soundPlayed = "cbrn_deadly_rad" };
    case (cbrn_curThreat > 1.75): { _soundPlayed = "cbrn_danger_rad" };
    case (cbrn_curThreat > 1.25): { _soundPlayed = "cbrn_high_rad" };
    case (cbrn_curThreat > 0.75): { _soundPlayed = "cbrn_mid_rad" };
    default { };
};

[ace_player, _soundPlayed] remoteExec ["say3D"];
