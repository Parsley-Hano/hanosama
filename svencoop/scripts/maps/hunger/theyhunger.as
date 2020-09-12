
#include "weapons/weapon_sawedoff"
#include "weapons/weapon_m16a1"
#include "weapons/weapon_colt1911"
#include "weapons/weapon_tommygun"
#include "weapons/weapon_m14"
#include "weapons/weapon_greasegun"
#include "weapons/weapon_teslagun"
#include "monsters/monster_th_grunt_repel"
#include "monsters/monster_th_cyberfranklin"
#include "monsters/monster_th_boss"
#include "point_checkpoint"
#include "leveldead_loadsaved"
#include "../cubemath/trigger_once_mp"
#include "../cubemath/item_airbubble"

array<ItemMapping@> g_ItemMappings = { 
	ItemMapping( "weapon_9mmAR", THOMPSONM1Name() ), 
	ItemMapping( "weapon_shotgun", SAWEDOFFName() ), 
	ItemMapping( "weapon_m16", M16A1Name() ), 
	ItemMapping( "weapon_9mmhandgun", COLTName() ), 
	ItemMapping( "weapon_eagle", "weapon_357" )
};

void MapInit()
{	
	// Register custom weapons
	RegisterSAWEDOFF();
	RegisterM16A1();
	RegisterCOLT();
	RegisterTHOMPSONM1();
	RegisterM14();
	RegisterTESLAGUN();
	RegisterM3GREASEGUN();
	
	// Register checkpoint entity
	RegisterPointCheckPointEntity();
	
	// Register custom monsters
	GruntRepel::Register();
	if ( g_Engine.mapname == "th_ep3_07" )
	{
		CyberFranklin::Register();
		Boss::Register();
	}
	
	// Register other stuff
	RegisterTriggerOnceMpEntity();
	RegisterAirbubbleCustomEntity();
	
	// Initialize classic mode (item mapping only)
	g_ClassicMode.SetItemMappings( @g_ItemMappings );
	g_ClassicMode.ForceItemRemap( true );
}

void MapActivate()
{
	InitObserver();
	
	if ( g_Engine.mapname == "th_ep3_07" )
	{
		// Adjust difficulty of boss battle (based on skill cvar and player count)
		float flAdjDelay = g_SurvivalMode.IsEnabled() ? g_SurvivalMode.GetDelayBeforeStart() : 20;
		g_Scheduler.SetTimeout( "AdjustDifficulty", flAdjDelay );
	}
}

void SetHealthByClassname( string sClassName, int iHealth )
{
	CBaseEntity@ pEntity = null;
	while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, sClassName ) ) !is null )
	{
		if ( pEntity is null || !pEntity.IsAlive() )
			continue;
			
		pEntity.pev.health = iHealth;
		//g_Game.AlertMessage( at_console, "Setting health of %1 to %2\n", sClassName, iHealth );
	}
}

int CalcNewHealth( int iBaseHealth, int iPerPlayerInc )
{
	int iNumPlayers = g_PlayerFuncs.GetNumPlayers();
	int iPlayerMul = Math.clamp( 0, 8, iNumPlayers );
	int iSkill = int( g_EngineFuncs.CVarGetFloat( "skill" ) );
	iSkill = Math.clamp( 1, 3, iSkill );
	
	int iRelBaseHealth = iBaseHealth + ( iBaseHealth / 3 ) * ( iSkill - 2 );
	int iRelPerPlayerInc = iPerPlayerInc + ( iPerPlayerInc / 3 ) * ( iSkill - 2 );
	return iRelBaseHealth + iRelPerPlayerInc * iPlayerMul;
}

void AdjustDifficulty( void )
{
	int iHealth;
	int iNumPlayers = g_PlayerFuncs.GetNumPlayers();
	int iSkill = int( g_EngineFuncs.CVarGetFloat( "skill" ) );
	//g_Game.AlertMessage( at_console, "Adjusting difficulty for skill %1 and %2 player(s).\n", iSkill, iNumPlayers );
	
	iHealth = CalcNewHealth( Boss::BOSS_HEALTH_BASE, Boss::BOSS_HEALTH_PER_PLAYER_INC );
	SetHealthByClassname( "monster_th_boss", iHealth );
		
	iHealth = CalcNewHealth( CyberFranklin::CYBERFRANKLIN_HEALTH_BASE, CyberFranklin::CYBERFRANKLIN_HEALTH_PER_PLAYER_INC );
	SetHealthByClassname( "monster_th_cyberfranklin", iHealth );
}

void THDynamicLight( Vector vecPos, int radius, int r, int g, int b, int8 life, int decay )
{
	NetworkMessage THDL( MSG_PVS, NetworkMessages::SVC_TEMPENTITY );
	THDL.WriteByte( TE_DLIGHT );
	THDL.WriteCoord( vecPos.x );
	THDL.WriteCoord( vecPos.y );
	THDL.WriteCoord( vecPos.z );
	THDL.WriteByte( radius );
	THDL.WriteByte( int(r) );
	THDL.WriteByte( int(g) );
	THDL.WriteByte( int(b) );
	THDL.WriteByte( life );
	THDL.WriteByte( decay );
	THDL.End();
}

void THGetDefaultShellInfo( CBasePlayer@ pPlayer, Vector& out ShellVelocity, Vector& out ShellOrigin, float forwardScale, float rightScale, float upScale )
{
	Vector vecForward, vecRight, vecUp;
	
	g_EngineFuncs.AngleVectors( pPlayer.pev.v_angle, vecForward, vecRight, vecUp );
	
	const float fR = Math.RandomFloat( 50, 70 );
	const float fU = Math.RandomFloat( 100, 150 );
 
	for( int i = 0; i < 3; ++i )
	{
		ShellVelocity[i] = pPlayer.pev.velocity[i] + vecRight[i] * fR + vecUp[i] * fU + vecForward[i] * 25;
		ShellOrigin[i]   = pPlayer.pev.origin[i] + pPlayer.pev.view_ofs[i] + vecUp[i] * upScale + vecForward[i] * forwardScale + vecRight[i] * rightScale;
	}
}

enum TheyHungerM14ZoomModes_e
{
	TH_MODE_NOSCOPE = 0,
	TH_MODE_SCOPED,
	TH_MODE_2XSCOPED
}

void TheyHungerSmoke( Vector pos, string sprite = "sprites/wep_smoke_02.spr", int scale = 5, int frameRate = 15, NetworkMessageDest msgType = MSG_BROADCAST, edict_t@ dest = null)
{
    NetworkMessage TheyHungerSmoke( msgType, NetworkMessages::SVC_TEMPENTITY, dest );
    TheyHungerSmoke.WriteByte( TE_SMOKE );
    TheyHungerSmoke.WriteCoord( pos.x );
    TheyHungerSmoke.WriteCoord( pos.y );
    TheyHungerSmoke.WriteCoord( pos.z );
    TheyHungerSmoke.WriteShort( g_EngineFuncs.ModelIndex( sprite ) );
    TheyHungerSmoke.WriteByte( scale );
    TheyHungerSmoke.WriteByte( frameRate );
    TheyHungerSmoke.End();
}

/*void TheyHungerDynamicTracer( Vector start, Vector end, NetworkMessageDest msgType = MSG_BROADCAST, edict_t@ dest = null )
{
	NetworkMessage THDT( msgType, NetworkMessages::SVC_TEMPENTITY, dest );
	THDT.WriteByte( TE_TRACER );
	THDT.WriteCoord( start.x );
	THDT.WriteCoord( start.y );
	THDT.WriteCoord( start.z );
	THDT.WriteCoord( end.x );
	THDT.WriteCoord( end.y );
	THDT.WriteCoord( end.z );
	THDT.End();
}*/

void InitObserver()
{
	g_EngineFuncs.CVarSetFloat( "mp_observer_mode", 1 ); 
	g_EngineFuncs.CVarSetFloat( "mp_observer_cyclic", 0 );
}

void EnableObserver(CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	if ( !g_SurvivalMode.IsActive() )
		InitObserver();
	
    if( pActivator is null || !pActivator.IsPlayer() )
        return;
        
    CBasePlayer@ player = cast<CBasePlayer@>( pActivator );

    player.GetObserver().StartObserver(player.pev.origin, Vector(), false);
}

void ActivateSurvival(CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	g_SurvivalMode.Activate();
}
