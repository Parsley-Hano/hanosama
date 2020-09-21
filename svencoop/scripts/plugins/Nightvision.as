//Version 1.3
CScheduledFunction@ g_pNVThinkFunc = null;
dictionary g_PlayerNV;
const Vector NV_COLOR( 0, 255, 0 );
const int g_iRadius = 42;
const int iDecay = 1;
const int iLife	= 2;
const int iBrightness = 64;

const array<string> DISALLOWED =    {"aomdc_1hospital", "aomdc_1hospital2", "aomdc_1garage", "aomdc_1backalley", "aomdc_1darkalley",
                            "aomdc_1sewer", "aomdc_1city", "aomdc_1city2", "aomdc_1cityx", "aomdc_1ridingcar",
                            "aomdc_1carforest", "aomdc_1afterforest", "aomdc_1angforest", "aomdc_1forhouse",
                            "aomdc_1forest2", "aomdc_1forest3", "aomdc_1heaven1", "aomdc_1heaven2", "aomdc_2hospital",
                            "aomdc_2hospital2", "aomdc_2garage", "aomdc_2backalley", "aomdc_2darkalley",
                            "aomdc_2sewer", "aomdc_2city", "aomdc_2city2", "aomdc_2city3", "aomdc_2sick",
                            "aomdc_2sick2", "aomdc_2sorgarden", "aomdc_2sorgarden2", "aomdc_2arforest",
                            "aomdc_2afterforest", "aomdc_2angforest", "aomdc_2forhouse",
                            "aomdc_2forest2", "aomdc_2forest3", "aomdc_2heaven1", "aomdc_2heaven2",
                            "aomdc_3hospital", "aomdc_3hospital2", "aomdc_3garage", "aomdc_3backalley", "aomdc_3darkalley",
                            "aomdc_3sewer", "aomdc_3city", "aomdc_3city2", "aomdc_3city3", "aomdc_3city4", "aomdc_3cityz",
                            "aomdc_3sick", "aomdc_3sick2", "aomdc_3sorgarden", "aomdc_3sorgarden2",
                            "aomdc_3arforest", "aomdc_3afterforest", "aomdc_3angforest", "aomdc_3forhouse",
                            "aomdc_3forest2", "aomdc_3forest3", "aomdc_3heaven1", "aomdc_3heaven2"};

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Nero" );
	g_Module.ScriptInfo.SetContactInfo( "Nero @ Svencoop forums" );
  
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  
	if( g_pNVThinkFunc !is null )
		g_Scheduler.RemoveTimer( g_pNVThinkFunc );

	@g_pNVThinkFunc = g_Scheduler.SetInterval( "nvThink", 0.05f );
}

CClientCommand nightvision( "nightvision", "Toggles night vision on/off", @ToggleNV );

void MapInit()
{
	g_SoundSystem.PrecacheSound( "player/hud_nightvision.wav" );
	g_SoundSystem.PrecacheSound( "items/flashlight2.wav" );
}

class PlayerNVData
{
  Vector nvColor;
}

void ToggleNV( const CCommand@ args )
{
   if(DISALLOWED.find(g_Engine.mapname) >= 0)
      return;
  
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

	if( pPlayer.IsAlive() )	
	{
		if ( args.ArgC() == 1 )
		{
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

			if ( g_PlayerNV.exists( szSteamId ) )
			{
				removeNV( pPlayer );
			}
			else
			{
				PlayerNVData data;
				data.nvColor = Vector(0, 255, 0);
				g_PlayerNV[szSteamId] = data;
				g_PlayerFuncs.ScreenFade( pPlayer, NV_COLOR, 0.01, 0.5, iBrightness, FFADE_OUT | FFADE_STAYOUT);
				g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "player/hud_nightvision.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
			}
		}
	
	}
}

void nvMsg( CBasePlayer@ pPlayer, const string szSteamId )
{
	PlayerNVData@ data = cast<PlayerNVData@>( g_PlayerNV[szSteamId] );

	Vector vecSrc = pPlayer.EyePosition();

	NetworkMessage nvon( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
		nvon.WriteByte( TE_DLIGHT );
		nvon.WriteCoord( vecSrc.x );
		nvon.WriteCoord( vecSrc.y );
		nvon.WriteCoord( vecSrc.z );
		nvon.WriteByte( g_iRadius );
		nvon.WriteByte( int(NV_COLOR.x) );
		nvon.WriteByte( int(NV_COLOR.y) );
		nvon.WriteByte( int(NV_COLOR.z) );
		nvon.WriteByte( iLife );
		nvon.WriteByte( iDecay );
	nvon.End();
}

void removeNV( CBasePlayer@ pPlayer )
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	
	g_PlayerFuncs.ScreenFade( pPlayer, NV_COLOR, 0.01, 0.1, iBrightness, FFADE_IN);
	g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "items/flashlight2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
	
	if ( g_PlayerNV.exists(szSteamId) )
		g_PlayerNV.delete(szSteamId);
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	
	if ( g_PlayerNV.exists(szSteamId) )
		removeNV( pPlayer );
 
	return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	
	if ( g_PlayerNV.exists(szSteamId) )
		removeNV( pPlayer );
 
	return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	
	if ( g_PlayerNV.exists(szSteamId) )
		removeNV( pPlayer );
 
	return HOOK_CONTINUE;
}

void nvThink()
{
	for ( int i = 1; i <= g_Engine.maxClients; ++i )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

		if ( pPlayer !is null && pPlayer.IsConnected() )
		{
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

			if ( g_PlayerNV.exists(szSteamId) )
				nvMsg( pPlayer, szSteamId );
		}
	}
}
