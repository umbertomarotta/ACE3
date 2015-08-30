/*
 * Author: joko // Jonas
 *
 * Handle fire of local launchers
 *
 * Argument:
 * 0: Weapon <STRING>
 * 1: Magazine <STRING>
 * 2: Ammo <STRING>
 *
 * Return value:
 * Array:
 *  0: Angle <Number>
 *  1: Range <Number>
 *  2: Damage <Number>
 *
 */
 #include "script_component.hpp"

params ["_weapon", "_magazine", "_ammo"];
TRACE_3("Parameter",_weapon,_magazine,_ammo);

private ["_array", "_type", "_return", "_config"];

// get Priority Array from Config
_array = [
    getNumber (configFile >> "CfgWeapons" >> QGVAR(priority)),
    getNumber (configFile >> "CfgMagazines" >> QGVAR(priority)),
    getNumber (configFile >> "CfgAmmo" >> QGVAR(priority))
];

TRACE_1("Proiroity Array",_array);
// define Fist Values for Types
_type = 0;
_array params ["_max"];

// get Highest Entry out the the Priority Array
{
    if (_max < _x) then {
        _max = _x;
        _type = _forEachIndex;
    };
} forEach _array;

TRACE_2("Highest Value",_max,_type);
// create the Config entry Point
_config = [
    (configFile >> "CfgWeapons" >> _weapon),
    (configFile >> "CfgMagazines" >> _magazine),
    (configFile >> "CfgAmmo" >> _ammo)
] select _type;
TRACE_1("ConfigPath",_config);

// get the Variables out of the Configes and create a array with then
_return = [
    (getNumber (_config >> QGVAR(angle))),
    (getNumber (_config >> QGVAR(range))),
    (getNumber (_config >> QGVAR(damage)))
];
TRACE_1("Return",_return);

missionNameSpace setVariable [format [QGVAR(values%1%2%3), _weapon, _ammo, _magazine], _return];

_return
