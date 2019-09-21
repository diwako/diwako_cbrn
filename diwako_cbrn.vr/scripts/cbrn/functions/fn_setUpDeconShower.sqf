params ["_shower"];

if (local _shower) then {
    _shower setVariable ["cbrn_water", 120, true];
};

if !(hasInterface) exitWith {};

_shower setVariable ["BIN_deconshower_disableAction", true];

private _action = ["cbrn_turn_on", "Turn on","",{
    ["cbrn_turnOnShower", [_target]] call cba_fnc_globalEvent;
    _target setVariable ["cbrn_starTime", cba_missionTime];
    _target setVariable ["cbrn_on", true, true];
    private _remainingWater = _target getVariable ["cbrn_water", 120];

    [{!(_this getVariable ["cbrn_on", false])}, {}, _target, _remainingWater, {
        ["cbrn_turnOffShower", [_this]] call cba_fnc_globalEvent;
        _this setVariable ["cbrn_water", 0, true];
        _this setVariable ["cbrn_on", false, true];
    }] call CBA_fnc_waitUntilAndExecute;
},{
    !(_target getVariable ["cbrn_on", false]) && {(_target getVariable ["cbrn_water", 120]) > 0}
},{},[], [0,0,0], 5] call ace_interact_menu_fnc_createAction;
[_shower, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["cbrn_turn_off", "Turn off","",{
    ["cbrn_turnOffShower", [_target]] call cba_fnc_globalEvent;
    private _diff = cba_missionTime - (_target getVariable ["cbrn_starTime", cba_missionTime]);
    private _waterRemaining = ((_target getVariable ["cbrn_water", 120]) - _diff) max 0;
    _target setVariable ["cbrn_water", _waterRemaining, true];
    _target setVariable ["cbrn_on", false, true];
},{
    _target getVariable ["cbrn_on", false]
},{},[], [0,0,0], 5] call ace_interact_menu_fnc_createAction;
[_shower, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
