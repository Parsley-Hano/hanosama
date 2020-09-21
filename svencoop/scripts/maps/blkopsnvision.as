/*
* |============================================================================|
* | B L A C K  O P S   N I G H T  V I S I O N   [#include version]             |
* | Author: Neo (Discord: NEO) Version: V1.40                                  |
* |         NERO (Night Vision initial basic plugin script version)            |
* | License: This code is protected and licensed with GPL V3.0 (see GPLv3.txt) |
* |============================================================================|
* |This map script enables the Black Ops style NightVision view mode           |
* |============================================================================|
* |Map script install instructions:                                            |
* |----------------------------------------------------------------------------|
* |1. Extract the map script 'scripts/maps/blkopsnvision.as'                   |
* |                       to 'svencoop_addon/scripts/maps'.                    |
* |----------------------------------------------------------------------------|
* |2. Add to main map script the following code:                               |
* |                                                                            |
* | (a) #include "blkopsnvision"                                               |
* |                                                                            |
* | (b) In function 'MapInit()':                                               |
* |     g_NightVision.OnMapInit();                                             |
* |============================================================================|
* |Usage of OF NightVision:                                                    |
* |----------------------------------------------------------------------------|
* |Simply use standard flash light key to switch the                           |
* |OF NightVision view mode on and off                                         |
* |============================================================================|
*/


NightVision@ g_NightVision = @NightVision();


void NightVisionCVar(CCVar@ cvar, const string& in szOldValue, float flOldValue)
{
	g_NightVision.CVar(cvar, szOldValue, flOldValue);
}


final class NightVision
{
	private string m_szSndHudNV  = "player/hud_nightvision.wav";
	private string m_szSndFLight = "items/flashlight2.wav";
	private Vector m_vColor( 255, 0, 0 );
	private float  m_flVolume = 0.8f;
	private int    m_iRadius = 42;
	private int    m_iLife	= 2;
	private int    m_iDecay = 1;
	private float  m_flFadeTime = 0.01f;
	private float  m_flFadeHold = 0.5f;
	private int    m_iFadeAlpha = 64;
	private bool   m_bHookPlayerInitialized = false;
	private bool   m_bHookSayInitialized=false;
	private CCVar@ m_ccvarEnabled;
	private dictionary m_dPlayer;
	private CScheduledFunction@ m_pThinkFunc = null;

	NightVision()
	{
		@m_ccvarEnabled = CCVar( "nvision", 0, "nightvision enabled", ConCommandFlag::None, @NightVisionCVar);
	}

	private void RegisterHooks(bool bEnableSay=false)
	{
		if(!m_bHookPlayerInitialized)
		{
			g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, ClientPutInServerHook(this.OnPlayerClient));
			g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect,  ClientDisconnectHook(this.OnPlayerClient));
			g_Hooks.RegisterHook(Hooks::Player::PlayerKilled,      PlayerKilledHook(this.OnPlayerKilled));
			m_bHookPlayerInitialized = true;
		}
		if(bEnableSay and !m_bHookSayInitialized)
		{
			g_Hooks.RegisterHook(Hooks::Player::ClientSay,         ClientSayHook(this.OnClientSay));
			m_bHookSayInitialized = true;
		}
	}

	void OnMapInit(bool bEnable=true, bool bEnableSay=false)
	{
		g_SoundSystem.PrecacheSound(m_szSndHudNV);
		g_SoundSystem.PrecacheSound(m_szSndFLight);

		RegisterHooks(bEnableSay);

		if(bEnable)
			Enable(bEnable);
	}

	bool IsEnabled()			{ return  (m_ccvarEnabled.GetInt() != 0); }
	void Enable(bool bEnable)	{ m_ccvarEnabled.SetInt(bEnable ? 1 : 0); }

	HookReturnCode OnPlayerClient(CBasePlayer@ pPlayer)
	{
		if(pPlayer !is null)	
			NVoff(pPlayer);

		return HOOK_CONTINUE;
	}

	HookReturnCode OnPlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib)
	{
		return OnPlayerClient(pPlayer);
	}

	HookReturnCode OnClientSay(SayParameters@ pParams)
	{
		CBasePlayer@ plr = pParams.GetPlayer();
		const CCommand@ args = pParams.GetArguments();
		if(args[0] == "/nvis")
		{
			if (args.ArgC() < 2)
				g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, "Nightvision is " + (IsEnabled() ? "enabled" : "disabled") + "\n");
			else if(args[1] == "on")
			{
				Enable(true);
				g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, "Nightvision is enabled\n");
			}
			else if(args[1] == "off")
			{
				Enable(false);
				g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, "Nightvision is disabled\n");
			}
			pParams.ShouldHide = true;
			return HOOK_HANDLED;
		}
		else if(args[0] == "/nvison")
		{
			Enable(true);
			g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, "Nightvision is enabled\n");
			pParams.ShouldHide = true;
			return HOOK_HANDLED;
		}
		else if(args[0] == "/nvisoff")
		{
			Enable(false);
			g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, "Nightvision is disabled\n");
			pParams.ShouldHide = true;
			return HOOK_HANDLED;
		}
		return HOOK_CONTINUE;
	}

	void CVar(CCVar@ cvar, string& in szOldValue, float flOldValue)
	{
		if(cvar.GetInt() != 0) // enabled ?!
			@m_pThinkFunc = g_Scheduler.SetInterval(@this, "Think", 0.05f);
		else if(m_pThinkFunc !is null)
		{
			g_Scheduler.RemoveTimer(m_pThinkFunc);
			@m_pThinkFunc = null;
		}
		Think(); // switch off night vision effect for all
	}

	private void NVon(CBasePlayer@ pPlayer)
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if(!m_dPlayer.exists(szSteamId)) 
		{
			m_dPlayer[szSteamId] = true;
			g_PlayerFuncs.ScreenFade( pPlayer, m_vColor, m_flFadeTime, m_flFadeHold, m_iFadeAlpha, FFADE_OUT | FFADE_STAYOUT);
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, m_szSndHudNV, m_flVolume, ATTN_NORM, 0, PITCH_NORM );
		}

		Vector vecSrc = pPlayer.EyePosition();
		NetworkMessage netMsg( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
		netMsg.WriteByte( TE_DLIGHT );
		netMsg.WriteCoord( vecSrc.x );
		netMsg.WriteCoord( vecSrc.y );
		netMsg.WriteCoord( vecSrc.z );
		netMsg.WriteByte( m_iRadius );
		netMsg.WriteByte( int(m_vColor.x) );
		netMsg.WriteByte( int(m_vColor.y) );
		netMsg.WriteByte( int(m_vColor.z) );
		netMsg.WriteByte( m_iLife );
		netMsg.WriteByte( m_iDecay );
		netMsg.End();
	}

	private void NVoff(CBasePlayer@ pPlayer)
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
		if(m_dPlayer.exists(szSteamId))
		{
			g_PlayerFuncs.ScreenFade( pPlayer, m_vColor, m_flFadeTime, m_flFadeHold, m_iFadeAlpha, FFADE_IN);
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, m_szSndFLight, m_flVolume, ATTN_NORM, 0, PITCH_NORM );
			m_dPlayer.delete(szSteamId);
		}
	}

	void Think()
	{
		for ( int i = 1; i <= g_Engine.maxClients; ++i )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if ( pPlayer !is null and pPlayer.IsConnected() and pPlayer.IsAlive())
			{
				if(IsEnabled() and pPlayer.FlashlightIsOn())	NVon(pPlayer);
				else											NVoff(pPlayer);
			}
		}
	}

	private void UnRegisterHooks()
	{
		if(m_bHookPlayerInitialized)
		{
			g_Hooks.RemoveHook(Hooks::Player::ClientPutInServer, ClientPutInServerHook(this.OnPlayerClient));
			g_Hooks.RemoveHook(Hooks::Player::ClientDisconnect,  ClientDisconnectHook(this.OnPlayerClient));
			g_Hooks.RemoveHook(Hooks::Player::PlayerKilled,      PlayerKilledHook(this.OnPlayerKilled));
			m_bHookPlayerInitialized = false;
		}
		if(m_bHookSayInitialized)
		{
			g_Hooks.RemoveHook(Hooks::Player::ClientSay,         ClientSayHook(this.OnClientSay));
			m_bHookSayInitialized = false;
		}
		if(m_pThinkFunc !is null)
		{
			g_Scheduler.RemoveTimer(m_pThinkFunc);
			@m_pThinkFunc = null;
		}
		m_dPlayer.deleteAll();
	}

	~NightVision()
	{
		UnRegisterHooks();
	}
}
