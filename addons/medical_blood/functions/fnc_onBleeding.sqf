/*
 * Author: Glowbal
 * handle bleeding state (state machine)
 *
 * Arguments:
 * 0: unit <TYPE>
 *
 * Return Value:
 * is Bleeding <BOOL>
 *
 * Example:
 * [UNIT] call ace_medical_blood_fnc_onBleeding
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit"];

if (GVAR(enabledFor) == 1 && {!isPlayer _unit || {_unit == ACE_player}}) exitWith {};

private _lastTime = _unit getVariable [QGVAR(lastTime), -10];
private _bloodLoss = (if (GVAR(useAceMedical)) then {([_unit] call EFUNC(medical,getBloodLoss)) * 2.5} else {getDammage _unit * 2}) min 6;

if (((CBA_missionTime - _lastTime) + _bloodLoss) >= (8 + random(2))) then {
    _unit setVariable [QGVAR(lastTime), CBA_missionTime];

    private _position = getPosATL _unit;
    _position = _position apply {if (random 1 >= 0.5) then {_x -(random(0.2))} else {_x + (random(0.2))}};
    _position set [2, 0];

    private _bloodDrop = ["ACE_Blooddrop_1", "ACE_Blooddrop_2", "ACE_Blooddrop_3", "ACE_Blooddrop_4"] select (floor (_bloodLoss max 3));
    [_bloodDrop, _position, getDir _unit] call FUNC(spawnBlood);
};
