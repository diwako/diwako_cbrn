if (isGamePaused) exitWith {};
params ["_args", "_idPFH"];
_args params ["_lastIteration"];

private _player = ace_player;

private _time = cba_missiontime;
private _delta = _time - _lastIteration;
_args set [0, _time];

private _uptime = _player getVariable ["cbrn_mask_uptime", 0];
private _fogging = _player getVariable ["cbrn_mask_fogging", false];

if (_player getVariable["cbrn_mask_on", false]) then {

private _backpack = backpack _player;
private _unitHasAC = _backpack in cbrn_conditioning;

private _newUptime = 0;

if ( _unitHasAC ) then {
	_newUptime = _uptime + (_delta * cbrn_fogAccumulationCoef);
	} else {
	_newUptime = _uptime + _delta;
	};

_player setVariable["cbrn_mask_uptime", _newUptime];

if (_newUptime > cbrn_fogStartTime) then {
	if !(_fogging) then {
		_player setVariable["cbrn_mask_fogging", true];
	};
		
	private _control = cbrn_fogDisplay select 0 displayCtrl 1336;
	
	private _convertedAlpha = linearConversion [cbrn_fogStartTime, cbrn_fogMaxTime, _newUptime, 0, 1, true];
	
	_control ctrlSetTextColor [1, 1, 1, _convertedAlpha];
	
	private _fogged = _player getVariable["cbrn_mask_fogged", false];
	
	if !( _fogged ) then {		
		"cbrn_gasmask_fog" cutRsc ["cbrn_fog", "PLAIN", 1, false];
		
		_player setVariable ["cbrn_mask_fogged", true];
	};
};
} else {
	private _newUptime = _uptime - (_delta * cbrn_fogFadeCoef);
	
	if(_newUptime < 0) then { _newUptime = 0; };
	
	_player setVariable ["cbrn_mask_uptime", _newUptime];
};