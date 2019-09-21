params ["_unit"];
private _fatigue = 100;
if ((isPlayer _unit) && (missionNamespace getVariable ["ace_advanced_fatigue_enabled",false])) then {
    _fatigue = 1 - (ace_advanced_fatigue_anReserve / 2300);
} else {
    _fatigue = getFatigue _unit;
};

_fatigue
