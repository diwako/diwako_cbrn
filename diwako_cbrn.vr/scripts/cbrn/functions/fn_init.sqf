if (isNil "MISSION_ROOT") then {
    if(isDedicated) then {
        MISSION_ROOT = "mpmissions\__CUR_MP." + worldName + "\";
    } else {
        MISSION_ROOT = str missionConfigFile select [0, count str missionConfigFile - 15];
    };
};

if (isServer) then {
    cbrn_zoneSimulationRange = 500;
    publicVariable "cbrn_zoneSimulationRange";
};

if !(hasInterface) exitWith {};

if (isNil "cbrn_mask_abberation") then {
    private _name = "ChromAberration";
    private _priority = 400;
    cbrn_mask_abberation = ppEffectCreate [_name, _priority];
    while {
        cbrn_mask_abberation < 0
    } do {
        _priority = _priority + 1;
        cbrn_mask_abberation = ppEffectCreate [_name, _priority];
    };
};
if (isNil "cbrn_mask_damage") then {
    private _name = "ChromAberration";
    private _priority = 400;
    cbrn_mask_damage = ppEffectCreate [_name, _priority];
    while {
        cbrn_mask_damage < 0
    } do {
        _priority = _priority + 1;
        cbrn_mask_damage = ppEffectCreate [_name, _priority];
    };
    cbrn_mask_damage ppEffectEnable true;
    cbrn_mask_damage ppEffectAdjust [0, 0, true];
    cbrn_mask_damage ppEffectCommit 0;
};

cbrn_loadouteh = ["cba_events_loadoutEvent",{
    params ["_unit", "_oldLoadout"];
    if (_unit != player) exitWith {};
    private _goggles = goggles _unit;
    private _backpack = backpack _unit;
    private _uniform = uniform _unit;

    private _hasMask = (cbrn_masks findIf {_x isEqualTo _goggles}) > -1;
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
        cbrn_mask_abberation ppEffectEnable true;
        cbrn_mask_abberation ppEffectAdjust [0,0,true];
        cbrn_mask_abberation ppEffectCommit 1;
        "cbrn_gasmask_overlay" cutFadeOut 1;
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
    // private _textures = getObjectTextures _backPackContainer;
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
}] call CBA_fnc_addEventHandler;

private _action = ["cbrn_turn_on_oxygen", "Turn on oxygen","",{
    [ace_player] call cbrn_fnc_startOxygen;
},{
    private _plr = ace_player;
    private _backpackItem = backpackContainer _plr;
    !(_plr getVariable ["cbrn_oxygen", false]) && {!isNull _backpackItem && {_plr getVariable ["cbrn_mask_on", false] && {_plr getVariable ["cbrn_backpack_on", false] && {_backpackItem getVariable ["cbrn_air", 100] > 0}}}}
},{},[], [0,0,0], 3] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions","ACE_Equipment"], _action, true] call ace_interact_menu_fnc_addActionToClass;

_action = ["cbrn_turn_off_oxygen", "Turn off oxygen","",{
    ace_player setVariable ["cbrn_oxygen", false];
},{
    ace_player getVariable ["cbrn_oxygen", false]
},{},[], [0,0,0], 3] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions","ACE_Equipment"], _action, true] call ace_interact_menu_fnc_addActionToClass;

_action = ["cbrn_check_oxygen", "Check remaining oxygen","",{
    [{
        params ["_unit"];
        private _remaining = (backpackContainer _unit) getVariable ["cbrn_oxygen", cbrn_maxOxygenTime];
        private _bars = round ((_remaining / cbrn_maxOxygenTime) * 10);
        if (_bars isEqualTo 0 && {_remaining > 0}) then {
            _bars = 1;
        };
        private _emptyBars = 10 - _bars;

        private _color = [((2 * (1 - _remaining / cbrn_maxOxygenTime)) min 1), ((2 * _remaining / cbrn_maxOxygenTime) min 1), 0];

        private _string = "";
        for "_a" from 1 to _bars do {
            _string = _string + "|";
        };
        private _text = [_string, _color] call ace_common_fnc_stringToColoredText;

        _string = "";
        for "_a" from 1 to _emptyBars do {
            _string = _string + "|";
        };
        _text = composeText [_text, [_string, "#808080"] call ace_common_fnc_stringToColoredText];

        private _picture = getText (configFile >> "CfgVehicles" >> (backpack _unit) >> "picture");
        [_text, _picture] call ace_common_fnc_displayTextPicture;
    }, [ace_player]] call CBA_fnc_execNextFrame;
},{
    ace_player getVariable ["cbrn_backpack_on", false];
},{},[], [0,0,0], 3] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions","ACE_Equipment"], _action, true] call ace_interact_menu_fnc_addActionToClass;

cbrn_threatPfh = [cbrn_fnc_threatPFH, 0.5, [cba_missiontime]] call CBA_fnc_addPerFrameHandler;

[{
    private _player = ace_player;
    private _range = missionNameSpace getVariable ["cbrn_zoneSimulationRange", 500];
    {
        if ((_player distance2D _x) < _range) then {
            if !(simulationEnabled _x) then {
                _x enableSimulation true;
            };
        } else {
            if (simulationEnabled _x) then {
                _x enableSimulation false;
            };
        };
    } forEach cbrn_localZones;
}, 10] call CBA_fnc_addPerFrameHandler;

player addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];
    if (_unit getVariable ["cbrn_mask_on", false]) then {
        _unit setVariable ["cbrn_mask_on", false, true];
        cbrn_mask_abberation ppEffectEnable true;
        cbrn_mask_abberation ppEffectAdjust [0,0,true];
        cbrn_mask_abberation ppEffectCommit 1;
        "cbrn_gasmask_overlay" cutFadeOut 1;
        terminate cbrn_breath_handle;
    };
    _unit setVariable ["cbrn_using_threat_meter", false, true];
}];

player addEventHandler ["Respawn", {
    player setVariable ["cbrn_damage", nil];
    player setVariable ["cbrn_autoDamage", nil];
    player setVariable ["cbrn_stoppedAutoDamage", nil];
    player setVariable ["cbrn_oxygen", nil];
}];

_action = ["cbrn_turn_check_damage", "Check CRBN Exposure","",{
    private _damage = ace_player getVariable ["cbrn_damage", 0];
    private _coef = _damage / cbrn_maxDamage;
    if (_coef < 0.1) exitWith {
        titleText ["You are feeling <t color='#00ff00'>fine</t>!" , "PLAIN DOWN", -1, false, true];
    };
    if (_coef < 0.4) exitWith {
        titleText ["You are feeling <t color='#ffff00'>okay</t>! Breathing stings a little..." , "PLAIN DOWN", -1, false, true];
    };
    if (_coef < 0.9) exitWith {
        titleText ["You are feeling <t color='#ff7b00'>not good</t>! Breathing stings, your skin feels bad..." , "PLAIN DOWN", -1, false, true];
    };
    titleText ["You are feeling <t color='#ff0000'>really fucking bad</t>! The end is near..." , "PLAIN DOWN", -1, false, true];
},{true},{},[], [0,0,0], 3] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions","Medical"], _action, true] call ace_interact_menu_fnc_addActionToClass;

_action = ["cbrn_turn_on_threatmeter", "Turn on threatmeter","",{
    ace_player setVariable ["cbrn_using_threat_meter", true, true];
},{
    !(ace_player getVariable ["cbrn_using_threat_meter", false]) && {ace_player getVariable ["cbrn_hasThreatMeter", false]}
},{},[], [0,0,0], 3] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions","ACE_Equipment"], _action, true] call ace_interact_menu_fnc_addActionToClass;
_action = ["cbrn_turn_off_threatmeter", "Turn off threatmeter","",{
    ace_player setVariable ["cbrn_using_threat_meter", false, true];
},{
    ace_player getVariable ["cbrn_using_threat_meter", false]
},{},[], [0,0,0], 3] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions","ACE_Equipment"], _action, true] call ace_interact_menu_fnc_addActionToClass;

["cbrn_turnOnShower", {
    params ["_shower"];
    [_shower, true] call cbrn_fnc_toggleShower;
}] call CBA_fnc_addEventhandler;
["cbrn_turnOffShower", {
    params ["_shower"];
    [_shower, false] call cbrn_fnc_toggleShower;
}] call CBA_fnc_addEventhandler;

player createDiaryRecord ["Diary", ["CBRN Mechanic",
"This Mission will feature several CBRN mechanics! There is CBRN related damage, you can check on your approximate health via ACE self-interacting -> Medical -> Check CBRN Exposure.<br/><br/>Warning CBRN exposure will never vanish in this mission, it takes days to get rid of it, so it is not simulated! Be careful and do not soak up too much! If you soak up too much a vicious cycle will start, and the exposure will constantly rise. It will continue to rise even in non-exposed areas until you use a decontamination shower. You will be notified when this happens!<br/><br/>If you exceed the maximum threshold you will die, flat out.<br/><br/>Oxygen in backpack tanks are finite! Once the air runs out they are useless, constantly keep checking your tanks air pressure! The tank will beep 3 times if your remaining air is below 5 minutes, it will sound a constant tone for 10 seconds when you reach 30 seconds left. You can switch out an oxygen tank while oxygen is still running without the oxygen supply to dry up.<br/><br/>People with a MicroDagr can open a threat monitor. It will appear at the top of the screen. The threat meter is rainbow color coded, going from Green to Yellow to Orange to Red, indicating the threat level. Each level is additive and need the previous requirements!<br/><br/>Threat level 1 (Green): No Mask needed<br/><br/>Threat level 2 (Yellow): Mask needed<br/><br/>Threat level 3 (Orange): Fresh oxygen supply needed<br/><br/>Threat level 4 (Red): Full CBRN suit<br/><br/>Any threat level above cannot be displayed on the threat meter, it is kind of the equivalent of 3.6 roentgen."]];
