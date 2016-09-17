/*
 * Author: KoffeinFlummi, commy2
 * Handles all incoming damage for tanks (including wheeled APCs).
 *
 * Arguments:
 * HandleDamage EH
 *
 * Return Value:
 * Damage to be inflicted.
 *
 * Example:
 * _this call ace_cookoff_fnc_handleDamage
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_simulationType", "_thisHandleDamage"];
_thisHandleDamage params ["_vehicle", "", "_damage", "", "_ammo", "_hitIndex"];

// it's already dead, who cares?
if (damage _vehicle >= 1) exitWith {};

// get hitpoint name
private _hitpoint = "#structural";

if (_hitIndex != -1) then {
    _hitpoint = toLower ((getAllHitPointsDamage _vehicle param [0, []]) select _hitIndex);
};

// get change in damage
private "_oldDamage";

if (_hitpoint isEqualTo "#structural") then {
    _oldDamage = damage _vehicle;
} else {
    _oldDamage = _vehicle getHitIndex _hitIndex;
};

private _newDamage = _damage - _oldDamage;

// handle different types of vehicles
// note: exitWith only works here, because this is not the main scope of handleDamage
// you cannot use the return value together with exitWith in the main scope, it's a bug
// also, we add this event handler with the addEventHandler SQF command,
// because the config version ignores the return value completely
if (_simulationType == "car") exitWith {
    // prevent destruction, let cook-off handle it if necessary
    if (_hitpoint in ["hithull", "hitfuel", "#structural"] && {!IS_EXPLOSIVE_AMMO(_ammo)}) then {
        _damage min 0.89
    } else {
        if (_hitpoint isEqualTo "hitengine" && {_damage > 0.9}) then {
            _vehicle call FUNC(engineFire);
        };
        _damage
    };
};

if (_simulationType == "tank") exitWith {
    // determine ammo storage location
    private _ammoLocationHitpoint = getText (_vehicle call CBA_fnc_getObjectConfig >> QGVAR(ammoLocation));

    if (_hitIndex in (GVAR(cacheTankDuplicates) getVariable (typeOf _vehicle))) then {
        _hitpoint = "#subturret";
    };

    // ammo was hit, high chance for cook-off
    if (_hitpoint == _ammoLocationHitpoint) then {
        if (_damage > 0.5 && {random 1 < 0.7}) then {
            _vehicle call FUNC(cookOff);
        };
    } else {
        if (_hitpoint in ["hitbody", "hitturret", "#structural"] && {_newDamage > 0.6 + random 0.3}) then {
            _vehicle call FUNC(cookOff);
        };
    };

    // prevent destruction, let cook-off handle it if necessary
    if (_hitpoint in ["hithull", "hitfuel", "#structural"]) then {
        _damage min 0.89
    } else {
        _damage
    };
};

if (_simulationType == "box") exitWith {
    if (_hitpoint == "#structural" && {IS_EXPLOSIVE_AMMO(_ammo)}) then {
        // High chance of cook-off when hit by an explosive
        if (_damage > 0.5 && {random 1 < 0.7}) then {
            _vehicle call FUNC(cookOffBox);
        } else {
            _hitpoint = "#death";
            _damage = 1;
        };
    };

    if (_hitpoint == "#structural") then {
        // prevent destruction, let cook-off handle it if necessary
        _damage min 0.89
    } else {
        _damage
    };
};
