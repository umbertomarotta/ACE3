//#define DEBUG_MODE_FULL
#include "script_component.hpp"
TRACE_1("enter", _this);

#define __LOCKONTIMERANDOM 1    // Deviation in lock on time

if((count _this) > 0) then {
    uiNameSpace setVariable ['ACE_RscOptics_javelin',_this select 0];
};

private _currentShooter = if (ACE_player call CBA_fnc_canUseWeapon) then {ACE_player} else {vehicle ACE_player};
TRACE_2("shooter",_currentShooter,typeOf _currentShooter);
_currentShooter setVariable ["ace_missileguidance_target", nil, false];

__JavelinIGUISeek ctrlSetTextColor __ColorGray;
__JavelinIGUINFOV ctrlSetTextColor __ColorGray;

__JavelinIGUITargeting ctrlShow false;
__JavelinIGUITargetingConstrains ctrlShow false;
__JavelinIGUITargetingGate ctrlShow false;
__JavelinIGUITargetingLines ctrlShow false;

if(GVAR(pfehID) != -1) then {
    [] call FUNC(onOpticUnload); // Unload optic if it was already loaded
};

uiNameSpace setVariable [QGVAR(arguments), 
    [
        diag_tickTime,         // Last runtime
        objNull,   // currentTargetObject
        0,         // Run Time
        0,          // Lock Time
        0,           // Sound timer
        (random __LOCKONTIMERANDOM), // random lock time addition
        -1
    ]
];

GVAR(pfehID) = [FUNC(onOpticDraw), 0, []] call CBA_fnc_addPerFrameHandler;
