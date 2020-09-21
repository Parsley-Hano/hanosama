#include "point_checkpoint"
#include "hlsp/trigger_suitcheck"
#include "cubemath/trigger_once_mp"
#include "cubemath/trigger_mediaplayer"

void MapInit()
{
	RegisterPointCheckPointEntity();
	RegisterTriggerSuitcheckEntity();
	RegisterTriggerOnceMpEntity();
	RegisterTriggerMediaPlayerEntity();
	
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
	
}
