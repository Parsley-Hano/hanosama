#include "point_checkpoint"
#include "hlsp/trigger_suitcheck"
#include "HLSPClassicMode"
#include "cubemath/geneworm"

void MapInit()
{
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();
	RegisterGenewormCustomEntity();
	
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
	
	ClassicModeMapInit();
}
