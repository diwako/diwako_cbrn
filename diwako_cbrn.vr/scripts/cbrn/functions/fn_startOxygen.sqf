params ["_unit"];

if (!alive _unit || {_unit getVariable ["cbrn_oxygen", false]}) exitWith {};

_unit setVariable ["cbrn_oxygen", true];
private _backpack = backpackContainer _unit;
if (isNull (uiNamespace getVariable ["cbrn_o2", objNull])) then {
    private _display = findDisplay 46;
    if !(isNull _display) then {
        private _air = _backpack getVariable ["cbrn_oxygen", cbrn_maxOxygenTime];
        private _color = "ffffff";
        if (_air <= 300) then {
            _color = "ffa500";
            if (_air <= 30) then {
                _color = "ff0000";
            };
        };
        private _ctrl = _display ctrlCreate ["RscStructuredText", 856];
        _ctrl ctrlSetPosition [safeZoneX,safeZoneY + (50 * pixelH),256 * pixelW, 256 * pixelH];
        _ctrl ctrlSetBackgroundColor [0,0,0,0];
        _ctrl ctrlSetStructuredText parseText format ["<t color='#%1' align='left' valign='top' size='1.2'>O²</t>", _color];
        _ctrl ctrlSetTextColor [1,1,1,1];
        _ctrl ctrlCommit 0;
        uiNamespace setVariable ["cbrn_o2", _ctrl];
    };
};

[{
    params ["_args", "_idPFH"];
    _args params ["_unit", "_oldBackpack", "_lastTimeUpdated"];
    private _backpack = backpackContainer _unit;
    private _curOxygen = _backpack getVariable ["cbrn_oxygen", cbrn_maxOxygenTime];
    if (!alive _unit || {!(_unit getVariable ["cbrn_oxygen", false]) || {!(_unit getVariable ["cbrn_mask_on", false]) || !(_unit getVariable ["cbrn_backpack_on", false]) || {_curOxygen <= 0}}}) exitWith {
        [_idPFH] call CBA_fnc_removePerFrameHandler;
        _backpack setVariable ["cbrn_oxygen", _curOxygen, true];
        _unit setVariable ["cbrn_oxygen", false];
        ctrlDelete (uiNamespace getVariable ["cbrn_o2", ctrlNull]);
    };

    if !(_oldBackpack isEqualTo _backpack) then {
        systemChat format ["Connected to new oxygen tank with %1%2 reaming air!", round ((_curOxygen/cbrn_maxOxygenTime) * 100), "%"];
        _oldBackpack setVariable ["cbrn_oxygen", (_oldBackpack getVariable ["cbrn_oxygen", cbrn_maxOxygenTime]), true];
        private _color = "ffffff";
        if (_curOxygen <= 300) then {
            _color = "ffa500";
            if (_curOxygen <= 30) then {
                _color = "ff0000";
            };
        };
        (uiNamespace getVariable ["cbrn_o2", ctrlNull]) ctrlSetStructuredText parseText format ["<t color='#%1' align='left' valign='top' size='1.2'>O²</t>", _color];
        _args set [1, _backpack];
    };

    private _delta = CBA_missionTime - _lastTimeUpdated;
    private _reserve = (_curOxygen - _delta) max 0;
    _backpack setVariable ["cbrn_oxygen", _reserve];

    if (!(_backpack getVariable ["cbrn_5min_warning", false]) && {_reserve < 300 && _reserve >= 30 }) then {
        _backpack setVariable ["cbrn_5min_warning", true];
        private _proxy = "building" createVehicle position _unit;
        _proxy attachTo [_unit, [0, 0, 0.5], "Head"];
        [_proxy, "lowoxwarning_short"] remoteExec ["say3D"];
        (uiNamespace getVariable ["cbrn_o2", ctrlNull]) ctrlSetStructuredText parseText "<t color='#ffa500' align='left' valign='top' size='1.2'>O²</t>";
        [{
            detach _this;
            deleteVehicle _this;
        }, _proxy, 2] call CBA_fnc_waitAndExecute;
    };
    if (!(_backpack getVariable ["cbrn_1min_warning", false]) && {_reserve < 30}) then {
        _backpack setVariable ["cbrn_1min_warning", true];
        private _proxy = "building" createVehicle position _unit;
        _proxy attachTo [_unit, [0, 0, 0.5], "Head"];
        [_proxy, "lowoxwarning"] remoteExec ["say3D"];
        (uiNamespace getVariable ["cbrn_o2", ctrlNull]) ctrlSetStructuredText parseText "<t color='#ff0000' align='left' valign='top' size='1.2'>O²</t>";
        [{
            detach _this;
            deleteVehicle _this;
        }, _proxy, 15] call CBA_fnc_waitAndExecute;
    };

    _args set [2, CBA_missionTime];
}, 1, [_unit, _backpack, CBA_missionTime]] call CBA_fnc_addPerFrameHandler;