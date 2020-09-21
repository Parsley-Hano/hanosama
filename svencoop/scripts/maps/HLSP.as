/*
* This script implements HLSP survival mode
*/

#include "point_checkpoint"
#include "hlsp/trigger_suitcheck"
#include "cubemath/trigger_once_mp"
#include "cubemath/func_wall_custom"
#include "HLSPClassicMode"

void MapInit()
{
    RegisterPointCheckPointEntity();
    RegisterTriggerSuitcheckEntity();
    RegisterTriggerOnceMpEntity();
    RegisterFuncWallCustomEntity();
    
    
    g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
    
    ClassicModeMapInit();
}