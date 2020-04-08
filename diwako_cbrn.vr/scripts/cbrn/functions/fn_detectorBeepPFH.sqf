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

private _wait = linearConversion [0.75, 3, cbrn_curThreat, 2, 0.05, true];
if ((cbrn_lastBeep + _wait) <= _time) then {
    cbrn_lastBeep = _time;
    playSound format ["detector_beep_%1", cbrn_beepVolume];
};
