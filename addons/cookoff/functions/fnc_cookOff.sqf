/*
 * Author: KoffeinFlummi, commy2
 * Start a cook-off in the given vehicle.
 *
 * Arguments:
 * 0: Vehicle <Object>
 *
 * Return Value:
 * None
 *
 * Example:
 * (vehicle player) call ace_cookoff_fnc_cookOff
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_vehicle"];

if (_vehicle getVariable [QGVAR(isCookingOff), false]) exitWith {};
_vehicle setVariable [QGVAR(isCookingOff), true];

[QGVAR(cookOff), _vehicle] call CBA_fnc_remoteEvent;

[{
    params ["_vehicle"];

    private _config = _vehicle call CBA_fnc_getObjectConfig;
    private _positions = getArray (_config >> QGVAR(cookoffSelections)) select {!((_vehicle selectionPosition _x) isEqualTo [0,0,0])};

    if (_positions isEqualTo []) then {
        ACE_LOGWARNING_1("no valid selection for cookoff found. %1", typeOf _vehicle);
        _positions pushBack "#noselection";
    };

    private _turretConfig = [_vehicle, [0]] call CBA_fnc_getTurret;
    private _positionBarrelEnd = getText (_turretConfig >> "gunBeg");

    // smoke out of cannon and hatches
    private _smokeBarrel = "#particlesource" createVehicleLocal [0,0,0];
    _smokeBarrel setParticleClass "MediumDestructionSmoke";
    _smokeBarrel attachTo [_vehicle, [0,0,0], _positionBarrelEnd];

    private _effects = [_smokeBarrel];

    {
        private _position = [0,-2,0];

        if !(_x isEqualTo "#noselection") then {
            _position = _vehicle selectionPosition _x;
        };

        private _smoke = "#particlesource" createVehicleLocal [0,0,0];
        _smoke setParticleClass "ObjectDestructionSmoke1_2Smallx";
        _smoke attachTo [_vehicle, _position];

        _effects pushBack _smoke;
    } forEach _positions;

    [{
        params ["_vehicle", "_effects", "_positions"];

        // this shit is busy being on fire, can't go driving around all over the place
        if (local _vehicle) then {
            _vehicle setFuel 0;
        };

        private _light = "#lightpoint" createVehicleLocal [0,0,0];
        _light setLightBrightness 0.7;
        _light setLightAmbient [1,0.4,0.15];
        _light setLightColor [1,0.4,0.15];
        _light lightAttachObject [_vehicle, [0,0,4]];

        _effects pushBack _light;

        // cookoffs
        {
            private _position = [0,-2,0];

            if !(_x isEqualTo "#noselection") then {
                _position = _vehicle selectionPosition _x;
            };

            private _fire = "#particlesource" createVehicleLocal [0,0,0];
            _fire setParticleClass QGVAR(CookOff);
            _fire attachTo [_vehicle, _position];

            _effects pushBack _fire;
        } forEach _positions;

        if (isServer) then {
            private _sound = createSoundSource [QGVAR(Sound), position _vehicle, [], 0];

            _effects pushBack _sound;
        };

        // indicator for the crew - yo, your shit's on fire
        private _fnc_FlameEffect = {
            params ["_vehicle", "_fnc_FlameEffect", "_counter"];

            if (_vehicle == cameraOn) then {
                [] call BIS_fnc_flamesEffect;
            };

            DEC(_counter);

            if (_counter > 0) then {
                [_fnc_FlameEffect, [_vehicle, _fnc_FlameEffect, _counter], 0.4] call CBA_fnc_waitAndExecute
            };
        };

        [_vehicle, _fnc_FlameEffect, 12] call _fnc_FlameEffect; // recursive function

        {
            if (local _x && {!(_x call EFUNC(common,isPlayer))}) then {
                _x action ["Eject", _vehicle];
            };
        } forEach crew _vehicle;

        [{
            params ["_vehicle", "_effects"];

            {
                deleteVehicle _x;
            } forEach _effects;

            if (local _vehicle) then {
                _vehicle setDamage 1;
            };
        }, [_vehicle, _effects], 4 + random 20] call CBA_fnc_waitAndExecute;
    }, [_vehicle, _effects, _positions], 3 + random 15] call CBA_fnc_waitAndExecute;
}, _vehicle, 0.5 + random 5] call CBA_fnc_waitAndExecute;
