/*
 * Author: Glowbal
 * Sets the hitpoint damage for au nit to the correct values
 *
 * Arguments:
 * 0: Unit for which the hitpoint damage will be sorted out <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

#include "script_component.hpp"

params ["_unit"];

if (!local _unit) exitWith {};

// ["head", "body", "hand_l", "hand_r", "leg_l", "leg_r"]
private _bodyStatus = _unit getVariable [QGVAR(bodyPartStatus), [0,0,0,0,0,0]];

if (GVAR(healHitPointAfterAdvBandage)) then {
    private _hasOpenWounds = [0,0,0,0,0,0];
    private _currentWounds = _unit getVariable [QGVAR(openWounds), []];
    {
        private _bodyPartIndex = _forEachIndex;
        {
            _x params ["", "", "_bodyPart", "_numOpenWounds", "_bloodLoss"];

            if ((_bodyPart == _bodyPartIndex) && {(_numOpenWounds * _bloodLoss) > 0}) exitWith {
                _hasOpenWounds set [_bodyPartIndex, 1];
            };
        } forEach _currentWounds;
    } forEach _hasOpenWounds;
    TRACE_1("",_hasOpenWounds);
    _bodyStatus = +_bodyStatus; //Don't modify real array
    {
        _bodyStatus set [_forEachIndex, (_x * (_hasOpenWounds select _forEachIndex))];
    } forEach _bodyStatus;
};

_bodyStatus params ["_headDamage", "_torsoDamage", "_handsDamageR", "_handsDamageL", "_legsDamageR", "_legsDamageL"];

_unit setHitPointDamage ["hitHead", _headDamage min 0.95];
_unit setHitPointDamage ["hitBody", _torsoDamage min 0.95];
_unit setHitPointDamage ["hitHands", (_handsDamageR + _handsDamageL) min 0.95];
_unit setHitPointDamage ["hitLegs", (_legsDamageR + _legsDamageL) min 0.95];

if (_bodyStatus isEqualTo [0,0,0,0,0,0]) then {
    _unit setDamage 0;
};
