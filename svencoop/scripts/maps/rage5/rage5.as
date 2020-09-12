#include "rage5_block"
#include "rage5_manager"
#include "round_manager"
#include "effects"

void RCMapInit()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "rage5_block", "rage5_block" );
	g_CustomEntityFuncs.RegisterCustomEntity( "rage5_manager", "rage5_manager" );
	g_CustomEntityFuncs.RegisterCustomEntity( "round_manager", "round_manager" );
	
	g_Game.PrecacheModel( "models/ragemap2018/rc_block.mdl" );
	
	g_Game.PrecacheModel( "models/computergibs.mdl" );
	
	g_Game.PrecacheModel( "sprites/ragemap2018/rc/yellow.spr" );
	g_Game.PrecacheModel( "sprites/ragemap2018/rc/orange.spr" );
	g_Game.PrecacheModel( "sprites/ragemap2018/rc/red.spr" );
	g_Game.PrecacheModel( "sprites/ragemap2018/rc/pink.spr" );
	g_Game.PrecacheModel( "sprites/ragemap2018/rc/purple.spr" );
	g_Game.PrecacheModel( "sprites/ragemap2018/rc/green.spr" );
	g_Game.PrecacheModel( "sprites/ragemap2018/rc/blue.spr" );
	g_Game.PrecacheModel( "sprites/ragemap2018/rc/random.spr" );
	g_Game.PrecacheModel( "sprites/ragemap2018/rc/explosive.spr" );
	
	g_Game.PrecacheModel( "sprites/ragemap2018/rc/flare.spr" );
	g_Game.PrecacheModel( "sprites/rc/rc_explosion2HD.spr" );
	g_Game.PrecacheModel( "sprites/rc/rc_explosionHD.spr" );
}