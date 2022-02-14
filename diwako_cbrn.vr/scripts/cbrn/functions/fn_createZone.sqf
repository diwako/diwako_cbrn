/*
 * Arguments:
 * 0: Center of zone, position array
 * 1: Threatlevel between 1 and 4.9, float
 * 2: Radius of full effect, float
 * 3: Radius of partial effect, float
 *
 * Returns trigger/zone object
 */
params [["_pos", [0,0,0]], ["_threatLevel", 1, [0]], ["_size",100], ["_falloffArea",50]];

if !(isServer) exitWith {};
if (_pos isEqualTo [0,0,0] || {_threatLevel < 0}) exitWith {};

_pos = _pos call CBA_fnc_getPos;
private _trg = createTrigger ["EmptyDetector", _pos, true];
_trg setVariable ["cbrn_active", true, true];
_trg setVariable ["cbrn_zone", true, true];
_trg setVariable ["cbrn_threatLevel", _threatLevel, true];
_trg setVariable ["cbrn_size", _size, true];
_trg enableDynamicSimulation false;

["cbrn_createZone", [_pos, _threatLevel, _size, _falloffArea, _trg]] call CBA_fnc_globalEventJip;
if ((_size + _falloffArea) > cbrn_zoneSimulationRange) then {
    cbrn_zoneSimulationRange = _size + _falloffArea + 50;
    publicVariable "cbrn_zoneSimulationRange";
};

_trg
