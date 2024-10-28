params ["_unit"];
if (_unit != player) exitWith {};
private _goggles = goggles _unit;
private _backpack = backpack _unit;
private _uniform = uniform _unit;

private _hasMask = _goggles in cbrn_masks;
if (_hasMask && {cbrn_kat_enabled}) then {
    _hasMask = (missionNamespace getVariable ["kat_chemical_availGasmaskList",[]] findIf {_x isEqualTo _goggles}) > -1;
};

if (!(_unit getVariable ["cbrn_mask_on", false]) && {_hasMask}) then {
    // guy JUST put that mask on
    _unit setVariable ["cbrn_mask_on", true, true];
    cbrn_mask_abberation ppEffectEnable true;
    cbrn_mask_abberation ppEffectAdjust [0.005,0.005,true];
    cbrn_mask_abberation ppEffectCommit 1;

    "cbrn_gasmask_overlay" cutRsc ["cbrn_gasmask", "PLAIN", 1, false];
    cbrn_breath_handle = [_unit] spawn {
        params ["_unit"];
        private _fat = 0;
        while{alive _unit && _unit getVariable ["cbrn_mask_on", false]} do {
            _fat = [_unit] call cbrn_fnc_getFatigue;
            sleep (0.75 + (3 - (3 * _fat)) + (random (2 - (2 * _fat))));
            if !(alive _unit && _unit getVariable ["cbrn_mask_on", false]) exitWith {};
            playSound format ["gas_breath_in_%1", floor (random 4) + 1];
            _fat = [_unit] call cbrn_fnc_getFatigue;
            sleep (0.75 + (2 - (2 * _fat)) + (random (2 - (2 * _fat))));
            if !(alive _unit && _unit getVariable ["cbrn_mask_on", false]) exitWith {};
            playSound format ["gas_breath_out_%1", floor (random 4) + 1];
        };
    };
};
if (_unit getVariable ["cbrn_mask_on", false] && {!_hasMask}) then {
    // guy JUST put that mask away
    _unit setVariable ["cbrn_mask_on", false, true];
    _unit setVariable ["cbrn_mask_fogging", false];
    _unit setVariable ["cbrn_mask_fogged", false];
    cbrn_mask_abberation ppEffectEnable true;
    cbrn_mask_abberation ppEffectAdjust [0,0,true];
    cbrn_mask_abberation ppEffectCommit 1;
    "cbrn_gasmask_overlay" cutFadeOut 1;
    "cbrn_gasmask_fog" cutFadeOut 1;
    terminate cbrn_breath_handle;
};

private _hasBackpack = (cbrn_backpacks findIf {_x isEqualTo _backpack}) > -1;
if (!(_unit getVariable ["cbrn_backpack_on", false]) && {_hasBackpack}) then {
    _unit setVariable ["cbrn_backpack_on", true, true];
};
if (_unit getVariable ["cbrn_backpack_on", false] && {!_hasBackpack}) then {
    _unit setVariable ["cbrn_backpack_on", false, true];
};

private _hasThreatMeter = [_unit, cbrn_threatMeteritem] call ace_common_fnc_hasItem;
if (!(_unit getVariable ["cbrn_hasThreatMeter", false]) && {_hasThreatMeter}) then {
    _unit setVariable ["cbrn_hasThreatMeter", true, true];
};
if (_unit getVariable ["cbrn_hasThreatMeter", false] && {!_hasThreatMeter}) then {
    _unit setVariable ["cbrn_hasThreatMeter", false, true];
    if (_unit getVariable ["cbrn_using_threat_meter", false]) then {
        _unit setVariable ["cbrn_using_threat_meter", false, true];
    };
};

private _hasSuit = (cbrn_suits findIf {_x isEqualTo _uniform}) > -1;
if (!(_unit getVariable ["cbrn_hasSuite", false]) && {_hasSuit}) then {
    _unit setVariable ["cbrn_hasSuite", true, true];
};
if (_unit getVariable ["cbrn_hasSuite", false] && {!_hasSuit}) then {
    _unit setVariable ["cbrn_hasSuite", false, true];
};

private _backPackContainer = backpackContainer _unit;
if (_unit getVariable ["cbrn_backpack_on", false] && {_unit getVariable ["cbrn_mask_on", false]}) then {
    // add hose
    if !(_backPackContainer getVariable ["cbrn_hose_attached", false]) then {
        _backPackContainer setVariable ["cbrn_hose_attached", true];

        if (_goggles isEqualTo "G_RegulatorMask_F") then {
            _backPackContainer setObjectTextureGlobal [2,"a3\supplies_f_enoch\bags\data\b_cur_01_co.paa"];
        } else {
            _backPackContainer setObjectTextureGlobal [1,"a3\supplies_f_enoch\bags\data\b_cur_01_co.paa"];
            _backPackContainer setObjectTextureGlobal [3,"a3\supplies_f_enoch\bags\data\b_cur_01_co.paa"];
        };
    };
} else {
    if (_backPackContainer getVariable ["cbrn_hose_attached", false]) then {
        _backPackContainer setVariable ["cbrn_hose_attached", false];
        _backPackContainer setObjectTextureGlobal [1,""];
        _backPackContainer setObjectTextureGlobal [2,""];
        _backPackContainer setObjectTextureGlobal [3,""];
    };
};
