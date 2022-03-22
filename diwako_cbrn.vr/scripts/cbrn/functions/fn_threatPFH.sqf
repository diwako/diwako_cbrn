if (isGamePaused) exitWith {};
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
cbrn_curThreat = _max;
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
    private _brightness = ([] call ace_common_fnc_ambientBrightness) max 0.25;
    private _base = uiNamespace getVariable ["cbrn_threatBaseCtrl", ctrlNull];
    private _overlay = uiNamespace getVariable ["cbrn_threatOverlayCtrl", ctrlNull];
    private _needle = uiNamespace getVariable ["cbrn_threatNeedleCtrl", ctrlNull];
    _base ctrlSetTextColor [_brightness, _brightness, _brightness, 1];
    _base ctrlCommit _delta;
    _overlay ctrlSetTextColor [_brightness, _brightness, _brightness, 1];
    _overlay ctrlCommit _delta;
    _needle ctrlSetTextColor [_brightness, _brightness, _brightness, 1];
    _needle ctrlCommit _delta;

    private _dir = (linearConversion [0, 4, _max - 0.05 + (random 0.1), 90, -90, true]) mod 360;
    _needle ctrlSetAngle [_dir, 0.5, 0.5];
} else {
    ctrlDelete (uiNamespace getVariable ["cbrn_threatBaseCtrl", ctrlNull]);
    ctrlDelete (uiNamespace getVariable ["cbrn_threatNeedleCtrl", ctrlNull]);
    ctrlDelete (uiNamespace getVariable ["cbrn_threatOverlayCtrl", ctrlNull]);
};

private _hasChemDetector = "ChemicalDetector_01_watch_F" in (assignedItems _player);
private _hasGeigerCounter = [_player, cbrn_threatGeiger] call ace_common_fnc_hasItem;

if (_hasChemDetector && {visibleWatch}) then {
    private _ui = uiNamespace getVariable ["RscWeaponChemicalDetector", displayNull];
    if !(isNull _ui) then {
        private _obj = _ui displayCtrl 101;
        _obj ctrlAnimateModel ["Threat_Level_Source", (_max - 0.05 + (random 0.1)) max 0, true];
    };
};

if (_hasChemDetector isNotEqualTo (_player getVariable ["cbrn_detector_beeps", false]))then {
    _player setVariable ["cbrn_detector_beeps", _hasChemDetector];
    if (cbrn_beep && {cbrn_beepPfh < 0}) then {
        cbrn_beepPfh = [cbrn_fnc_detectorBeepPFH, 0.05, [cba_missiontime]] call CBA_fnc_addPerFrameHandler;
    };
};

if (_hasGeigerCounter isNotEqualTo (_player getVariable ["cbrn_detector_geiger", false])) then {
    _player setVariable ["cbrn_detector_geiger", _hasGeigerCounter];
    if (cbrn_geiger && {cbrn_geigerPfh < 0}) then {
        cbrn_geigerPfh = [cbrn_fnc_detectorGeigerPFH, 2, [cba_missiontime]] call CBA_fnc_addPerFrameHandler;
    };
};


if (!(_player getVariable ["cbrn_autoDamage", false]) && {cbrn_healingRate > 0}) then {
    private _curDamage = _player getVariable ["cbrn_damage", 0];
    _player setVariable ["cbrn_damage", (_curDamage - (cbrn_healingRate * _delta)) max 0];
};
