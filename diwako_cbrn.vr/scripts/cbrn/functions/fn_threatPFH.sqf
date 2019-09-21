params ["_args", "_idPFH"];
_args params ["_lastIteration"];
private _player = ace_player;
private _zones = _player getVariable ["cbrn_zones", []];
private _max = 0;
if (alive _player && {!(_zones isEqualTo [])}) then {
    private _zone = objNull;
    private _size = 0;
    private _threatLevel = 0;
    private _falloffArea = 0;
    private _dist = 0;
    {
        _threatLevel = _x getVariable ["cbrn_threatLevel", 0];
        if (_max < _threatLevel) then {
            _size = _x getVariable ["cbrn_size", 0];
            _dist = _player distance2D _x;
            if( _dist > _size) then {
                _falloffArea = _x getVariable ["cbrn_falloffArea", 0];
                _threatLevel = linearConversion [_size + _falloffArea, _size, _dist, 0 , _threatLevel];
            };

            _max = _max max _threatLevel;
        };
    } forEach _zones;
};
private _time = cba_missiontime;
private _delta = _time - _lastIteration;
_args set [0, _time];
[_player, _max, _delta] call cbrn_fnc_handleDamage;

if (_player getVariable ["cbrn_using_threat_meter", false]) then {
    if (isNull (uiNamespace getVariable ["cbrn_threatBaseCtrl", objNull])) then {
        private _display = findDisplay 46;
        if (isNull _display) exitWith {};
        private _pos = [0.5 - ((256 * pixelW) / 2),safeZoneY,256 * pixelW, 256 * pixelH];
        private _ctrl = _display ctrlCreate ["RscPicture", 753];
        _ctrl ctrlSetPosition _pos;
        _ctrl ctrlSetBackgroundColor [1,1,1,0.5];
        _ctrl ctrlSetText "scripts\cbrn\images\threatmetercolours.paa";
        _ctrl ctrlSetTextColor [1,1,1,1];
        _ctrl ctrlCommit 0;
        uiNamespace setVariable ["cbrn_threatBaseCtrl", _ctrl];

        _ctrl = _display ctrlCreate ["RscPicture", 755];
        _ctrl ctrlSetPosition [0.5 - ((256 * pixelW) / 2),safeZoneY - ((256 * pixelH) / 2),256 * pixelW, 256 * pixelH];
        _ctrl ctrlSetBackgroundColor [1,1,1,1];
        _ctrl ctrlSetText "scripts\cbrn\images\needle.paa";
        _ctrl ctrlSetTextColor [1,1,1,1];
        _ctrl ctrlCommit 0;
        uiNamespace setVariable ["cbrn_threatNeedleCtrl", _ctrl];

        _ctrl = _display ctrlCreate ["RscPicture", 755];
        _ctrl ctrlSetPosition _pos;
        _ctrl ctrlSetBackgroundColor [1,1,1,1];
        _ctrl ctrlSetText "scripts\cbrn\images\threatmeteroverlay.paa";
        _ctrl ctrlSetTextColor [1,1,1,1];
        _ctrl ctrlCommit 0;
        uiNamespace setVariable ["cbrn_threatOverlayCtrl", _ctrl];
    };
    private _needle = uiNamespace getVariable ["cbrn_threatNeedleCtrl", ctrlNull];
    private _dir = (linearConversion [0, 4, _max - 0.05 + (random 0.1), 90, -90, true]) mod 360;
    _needle ctrlSetAngle [_dir, 0.5, 0.5];
} else {
    ctrlDelete (uiNamespace getVariable ["cbrn_threatBaseCtrl", ctrlNull]);
    ctrlDelete (uiNamespace getVariable ["cbrn_threatNeedleCtrl", ctrlNull]);
    ctrlDelete (uiNamespace getVariable ["cbrn_threatOverlayCtrl", ctrlNull]);
};
