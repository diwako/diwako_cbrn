if (isServer) then {
    publicVariable "cbrn_zoneSimulationRange";
        cbrn_vehicles = cbrn_vehicles apply {
        _x params [["_obj", "nothing", [""]], "_value"];
        _obj = missionNamespace getVariable [_obj, _obj];
        if !(_obj isEqualType "") then {
            _obj = typeOf _obj;
        };
        [_obj, _value]
    };
    cbrn_vebiclesHash = createHashMapFromArray cbrn_vehicles;
    {
    _x params ["_class"];
        [_class, "initPost",{
            params ["_vehicle"];
            _vehicle setVariable ["cbrn_proofing", cbrn_vebiclesHash getOrDefault [typeOf _vehicle, 0], true];
        }, false, [], true]call CBA_fnc_addClassEventHandler;
    } forEach cbrn_vehicles;
};

["DeconShower_01_F", "initPost",{
    (_this select 0) call cbrn_fnc_setUpDeconShower;
}, false, [], true]call CBA_fnc_addClassEventHandler;

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

if (cbrn_foggingEnabled) then {
    "cbrn_gasmask_fog" cutRsc ["cbrn_fog", "PLAIN", 0, false];
    cbrn_fogPfh = [cbrn_fnc_fogPFH, 0.05, [cba_missiontime]] call CBA_fnc_addPerFrameHandler;
};

cbrn_loadouteh = ["cba_events_loadoutEvent",{
    call cbrn_fnc_loadoutEH;
}] call CBA_fnc_addEventHandler;
[player] call cbrn_fnc_loadoutEH;

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
        [_unit] call cbrn_fnc_checkOxygen;
    }, [ace_player]] call CBA_fnc_execNextFrame;
},{
    ace_player getVariable ["cbrn_backpack_on", false];
},{},[], [0,0,0], 3] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions","ACE_Equipment"], _action, true] call ace_interact_menu_fnc_addActionToClass;

"ChemiCalDetector" cutRsc ["RscWeaponChemicalDetector", "PLAIN", 1, false];
cbrn_threatPfh = [cbrn_fnc_threatPFH, 0.5, [cba_missiontime]] call CBA_fnc_addPerFrameHandler;
cbrn_beepPfh = -1;
cbrn_geigerPfh = -1;

[{
    private _range = (missionNameSpace getVariable ["cbrn_zoneSimulationRange", 500]);
    private _activateZones = cbrn_localZones inAreaArray [getPosWorld ace_player, _range, _range, 0 ,false, -1];
    {
        if !(simulationEnabled _x) then {
            _x enableSimulation true;
        };
    } forEach _activateZones;
    {
        if (simulationEnabled _x) then {
            _x enableSimulation false;
        };
    } forEach (cbrn_localZones - _activateZones);
}, 10] call CBA_fnc_addPerFrameHandler;

player addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator", "_useEffects"];
    if (_unit getVariable ["cbrn_mask_on", false]) then {
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
    _unit setVariable ["cbrn_using_threat_meter", false, true];
}];

player addEventHandler ["Respawn", {
    player setVariable ["cbrn_damage", nil];
    player setVariable ["cbrn_autoDamage", nil];
    player setVariable ["cbrn_stoppedAutoDamage", nil];
    player getVariable ["cbrn_using_threat_meter", nil];
    player setVariable ["cbrn_oxygen", nil];
    player setVariable ["cbrn_mask_fogging", nil];
    player setVariable ["cbrn_mask_fogged", nil];
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

private _aceMedicalLoaded = isClass (configFile >> "CfgPatches" >> "ace_medical");
private _newAceMedicalLoaded = isClass (configFile >> "CfgPatches" >> "ace_medical_statemachine");

// no ace medical
if (!_aceMedicalLoaded && {!_newAceMedicalLoaded}) then {
    ["CAManBase", 1, ["ACE_SelfActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;
};

// old ace medical
if (_aceMedicalLoaded && {!_newAceMedicalLoaded}) then {
    ["CAManBase", 1, ["ACE_SelfActions","Medical"], _action, true] call ace_interact_menu_fnc_addActionToClass;
};

// new ace medical
if (_aceMedicalLoaded && {_newAceMedicalLoaded}) then {
    ["CAManBase", 1, ["ACE_SelfActions","ACE_Medical"], _action, true] call ace_interact_menu_fnc_addActionToClass;
};

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

if !(isNil "CBA_fnc_addItemContextMenuOption") then {
    {
        [_x, "BACKPACK", "Turn on oxygen", nil, nil, [{
                private _plr = ace_player;
                private _backpackItem = backpackContainer _plr;
                !(_plr getVariable ["cbrn_oxygen", false]) && {!isNull _backpackItem && {_plr getVariable ["cbrn_mask_on", false] && {_plr getVariable ["cbrn_backpack_on", false] && {_backpackItem getVariable ["cbrn_air", 100] > 0}}}}
            }, {
                private _plr = ace_player;
                _plr getVariable ["cbrn_backpack_on", false] && {!(_plr getVariable ["cbrn_oxygen", false])}
            }], {
            [ace_player] call cbrn_fnc_startOxygen;
            false
        }, false] call CBA_fnc_addItemContextMenuOption;

        [_x, "BACKPACK", "Turn off oxygen", nil, nil,
        [{ace_player getVariable ["cbrn_oxygen", false]}, {ace_player getVariable ["cbrn_oxygen", false]}], {
            ace_player setVariable ["cbrn_oxygen", false];
            false
        }, false] call CBA_fnc_addItemContextMenuOption;

        [_x, "BACKPACK", "Check remaining oxygen", nil, nil,
        [{true}, {ace_player getVariable ["cbrn_backpack_on", false]}], {
            [{
                params ["_unit"];
                [_unit] call cbrn_fnc_checkOxygen;
            }, [ace_player]] call CBA_fnc_execNextFrame;
            false
        }, false] call CBA_fnc_addItemContextMenuOption;
    } forEach cbrn_backpacks;


    ["ChemicalDetector_01_watch_F", "WATCH", "Increase volume", nil, nil,
    [{cbrn_beepVolume < 5},{cbrn_beep}], {
        cbrn_beepVolume = cbrn_beepVolume + 1;
        false
    }, false] call CBA_fnc_addItemContextMenuOption;

    ["ChemicalDetector_01_watch_F", "WATCH", "Decrease volume", nil, nil,
    [{cbrn_beepVolume > 0},{cbrn_beep}], {
        cbrn_beepVolume = cbrn_beepVolume - 1;
        false
    }, false] call CBA_fnc_addItemContextMenuOption;

    ["ChemicalDetector_01_watch_F", "WATCH", "Turn beeping on", nil, nil,
    [{!cbrn_beep},{!cbrn_beep}], {
        cbrn_beep = true;
        cbrn_beepPfh = [cbrn_fnc_detectorBeepPFH, 0.05, [cba_missiontime]] call CBA_fnc_addPerFrameHandler;
        false
    }, false] call CBA_fnc_addItemContextMenuOption;

    ["ChemicalDetector_01_watch_F", "WATCH", "Turn beeping off", nil, nil,
    [{cbrn_beep},{cbrn_beep}], {
        cbrn_beep = false;
        false
    }, false] call CBA_fnc_addItemContextMenuOption;

    [cbrn_threatGeiger, "CONTAINER", "Turn counter on", nil, nil,
    [{!cbrn_geiger},{!cbrn_geiger}], {
        cbrn_geiger = true;
        cbrn_geigerPfh = [cbrn_fnc_detectorGeigerPFH, 2, [cba_missiontime]] call CBA_fnc_addPerFrameHandler;
        false
    }, false] call CBA_fnc_addItemContextMenuOption;

    [cbrn_threatGeiger, "CONTAINER", "Turn counter off", nil, nil,
    [{cbrn_geiger},{cbrn_geiger}], {
        cbrn_geiger = false;
        false
    }, false] call CBA_fnc_addItemContextMenuOption;

    [cbrn_threatMeteritem, "CONTAINER", "Turn on threatmeter", nil, nil,
    [{!(ace_player getVariable ["cbrn_using_threat_meter", false]) && {ace_player getVariable ["cbrn_hasThreatMeter", false]}},{!(ace_player getVariable ["cbrn_using_threat_meter", false]) && {ace_player getVariable ["cbrn_hasThreatMeter", false]}}], {
        ace_player setVariable ["cbrn_using_threat_meter", true, true];
        false
    }, false] call CBA_fnc_addItemContextMenuOption;

    [cbrn_threatMeteritem, "CONTAINER", "Turn off threatmeter", nil, nil,
    [{ace_player getVariable ["cbrn_using_threat_meter", false]},{ace_player getVariable ["cbrn_using_threat_meter", false]}], {
        ace_player setVariable ["cbrn_using_threat_meter", false, true];
        false
    }, false] call CBA_fnc_addItemContextMenuOption;
};
