params ["_shower", ["_on", false]];

if !(hasInterface) exitWith {};

if (_on) then {
    if (_shower getVariable ["cbrn_water", 120] isEqualTo 0) exitWith {};

    private _particles    = [];
    private _power = 1.4;
    private _sizeFactor = 1;
    private _count = 3;

    // Iterate through all memory points
    for "_i" from 1 to _count do
    {
        // Calculate position & direction of particle effects
        private _pos = _shower selectionPosition format["shower_%1_pos",_i];
        private _dir = _shower selectionPosition format["shower_%1_dir",_i];
        private _vector = ((_shower modelToWorldVisual _pos) vectorFromTo (_shower modelToWorld _dir)) vectorMultiply _power;

        // Create particle effect
        private _particle = "#particlesource" createVehicleLocal [0,0,0];
        _particle attachTo [_shower,[0,0,0]];
        _particle setParticleCircle [0, [0, 0, 0]];
        _particle setParticleRandom [0, [0, 0, 0], [0, 0, 0], 53, 0.25, [0, 0, 0, 1], 0, 0];
        _particle setParticleParams [["\A3\data_f\Cl_water", 1, 0, 0], "", "Billboard", 1, 1.25, _pos, _vector, 0, 1.275*1.45, 1, 0, [0.1*_sizeFactor, 0.7*_sizeFactor,0.9*_sizeFactor], [[1, 1, 1, 0.02], [1, 1, 1, 0.001]], [1], 0, 0, "", "", _shower];
        _particle setDropInterval 0.02;

        // Add particle to array
        _particles pushBack _particle;
    };

    // Unhide mist effect & animate valve
    // if(local _shower)then
    // {
    //     _shower animateSource ["Valve_Source",1];
        _shower animateSource ["Hide_Mist_Source",0,true];
    //     _shower setVariable ["BIN_Shower_Stop",false,true];
    // };

    // Create sounds effect
    private _sound = "DeconShower_01_sound_F" createVehicleLocal [0,0,0];
    //private _sound = createSoundSource ["Sound_DeconShower_01_loop" , [0,0,1], [], 0];
    _sound setPosASL (getPosASLVisual _shower);

    private _trg = createTrigger ["EmptyDetector", getpos _shower, false];
    // _trg setPosWorld getPosWorld _shower;
    _trg setTriggerArea [1, 1, (getDir _shower), true, 1];
    _trg setTriggerActivation ["ANYPLAYER", "PRESENT", true];
    _trg setTriggerTimeout [5, 5, 5, true];
    _trg setTriggerStatements ["ace_player getVariable ['cbrn_autoDamage', false] && { !(ace_player getVariable ['cbrn_stoppedAutoDamage', false]) && {ace_player in thisList}}", "ace_player setVariable ['cbrn_stoppedAutoDamage', true]; 'Success!' hintC 'The contamination stopped, it should have not come to this in the first place!'", ""];
    _particles pushBack _trg;

    // Update objects list to delete
    _shower setVariable ["cbrn_objects",[_sound] + _particles];

    if (isNull (_shower getVariable ["cbrn_puddle", objNull])) then {
        private _waterPuddle = createSimpleObject ["a3\Props_F_Enoch\Military\Decontamination\WaterSpill_01_Small_F.p3d", (getPosWorld _shower) vectorAdd [0,0,-1.2], true];
        _waterPuddle setDir (random 360);
        _shower setVariable ["cbrn_puddle", _waterPuddle];
        [{deleteVehicle _this}, _waterPuddle, 180] call CBA_fnc_waitAndExecute;
    };
} else {
    {
        // Current result is saved in variable _x
        detach _x;
        deleteVehicle _x;
    } forEach (_shower getVariable ["cbrn_objects",[]]);
    _shower animateSource ["Hide_Mist_Source",1,true];
};