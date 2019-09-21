params ["_unit", "_threadLevel", "_delta"];

if !(isDamageAllowed _unit) exitWith {};
private _actualThreat = _threadLevel;
private _curDamage = _unit getVariable ["cbrn_damage", 0];
private _maxDamage = cbrn_maxDamage;

if ((_curDamage / _maxDamage) > 0.5 && {!(_unit getVariable ["cbrn_autoDamage", false])}) then {
    _unit setVariable ["cbrn_autoDamage", true];
    "WARNING!" hintC ["Your CBRN exposure is now rising automatically!!","SEEK DECONTAMINATION IMMIDIATELY!!","FIND DECONTAMINATION SHOWERS!"];
    [{
        params ["_args", "_idPFH"];
        _args params ["_unit"];

        if (!alive _unit || {_unit getVariable ["cbrn_stoppedAutoDamage", false]}) exitWith {
            [_idPFH] call CBA_fnc_removePerFrameHandler;
        };

        // private _newDamage = ((_unit getVariable ["cbrn_damage", 0]) + 1) min 100;
        private _newDamage = ((_unit getVariable ["cbrn_damage", 0]) + 0.0277777777777777) min 100;
        _unit setVariable ["cbrn_damage", _newDamage];
        if (_newDamage >= 100) then {
            _unit setDamage 1;
        };
    }, 1, [_unit]] call CBA_fnc_addPerFrameHandler;
};

if (_threadLevel >= 1) then {
    // level 2 threat
    // requires mask
    _actualThreat = _actualThreat - ([0,1] select (_unit getVariable ["cbrn_mask_on", false]));
};
if (_threadLevel >= 2) then {
    // level 3 threat
    // requires oxygen
    _actualThreat = _actualThreat - ([0,1] select (_unit getVariable ["cbrn_oxygen", false]));
};
if (_threadLevel >= 3) then {
    // level 4 threat
    // requires cbrn suit
    _actualThreat = _actualThreat - ([0,1] select (_unit getVariable ["cbrn_hasSuite", false]));
};

_actualThreat = _actualThreat max 0;

// systemChat format ["Actual Threat: %1 | Mitigated Threat: %2", _threadLevel, _actualThreat];

if (_actualThreat < 1) exitWith {
    cbrn_mask_damage ppEffectAdjust [0, 0, true];
    cbrn_mask_damage ppEffectCommit 5;
};


private _effectStrength = _actualThreat / 5;

_curDamage = _curDamage + (_actualThreat * _delta);
_unit setVariable ["cbrn_damage", _curDamage];

if (alive _unit && {_curDamage > _maxDamage}) exitWith {
    // I am sorry john...
    _unit setDamage 1;
};


cbrn_mask_damage ppEffectAdjust [_effectStrength, _effectStrength, true];
cbrn_mask_damage ppEffectCommit 5;

if (cba_missionTime > (_unit getVariable ["cbrn_nextCough", -1])) then {
    _unit setVariable ["cbrn_nextCough", cba_missionTime + (20 / _threadLevel)];
    // [_unit, ("choke_" + str( (floor random 9) + 1))] remoteExec ["say3D"];
    _unit setVariable ["cbrn_damage", _curDamage, true];
};

private _pain = _unit getVariable ["ace_medical_pain", 0];
if (_pain < 1) then {
    [_unit, 0.05 * _delta] call ace_medical_fnc_adjustPainLevel;
};
