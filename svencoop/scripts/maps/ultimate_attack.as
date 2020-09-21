/*
* |====================================================================|
* | HALF LIFE: ULTIMATE ATTACK MAP SCRIPT                              |
* | Author: Neo (SC, Discord),  Version 1.22, September, 27th 2019     |
* |====================================================================|
* |This plugin enables SC Point CheckPoint,BlkOps NightVision mode,    |
* |H2's Crouch Spawn support and CubeMath's Anti-Rush entities.        |
* |====================================================================|
* |Usage of Survival Mode, BLKOPS NightVision and Crouch Spawn support:|
* |--------------------------------------------------------------------|
* |Survival mode must be activated over map/server config.             |
* |NightVision view mode must be initiated and replaces Flash Light    |
* |Crouch Spawn support must be initiated on MapInit, if needed for map|
* |====================================================================|
*/

#include "point_checkpoint"
#include "cubemath/trigger_once_mp"
#include "cubemath/func_wall_custom"
#include "blkopsnvision"
#include "crouch_spawn"

void MapInit()
{
	// Enable SC PointCheckPoint Support
	RegisterPointCheckPointEntity();
	// Enable custom trigger zone script for Anti-Rush
	RegisterTriggerOnceMpEntity();
	// Enable custom blocker entity script for Anti-Rush
	RegisterFuncWallCustomEntity();
	// Enable BlkOps Nightvision Support
	g_NightVision.OnMapInit();
	
    // CROUCH SPAWN Support (only in map ss2a1)
    if(g_Engine.mapname != "ss2a1")
        g_crspawn.Disable(); // Disable, if not needed, because its enabled by default
}