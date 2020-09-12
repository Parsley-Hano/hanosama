// AoMDCFlashlight.as
// Plugin by Zorbos, with some code used from w00tguy's Anti-Rush plugin (player state code)

// Enables the AoMDC flashlight functionality wherein the flashlight does not recharge, and requires batteries to operate.

// This plugin is only designed to work on the AoMDC maps. Edit the 'FL_ALLOWED' maplist below if you wish to add more maps, but keep in mind
// that things will likely not work the way they are supposed to.

// Also, you NEED this plugin added in your default_plugins.txt file in order for flashlight batteries to spawn in AoMDC levels.

// Flashlight Plugin is ONLY allowed on these maps:
const array<string> FL_ALLOWED = 	{"aomdc_1hospital", "aomdc_1hospital2", "aomdc_1garage", "aomdc_1backalley", "aomdc_1darkalley",
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

CScheduledFunction@ interval;



// The below code is taken from w00tguy123's Anti-Rush plugin.
// All credit goes to him for the code.

class PlayerState
{
	EHandle pPlayer; // Handle to the player whose data this state contains
	int maxFlashlight; // The player's current maximum flashlight level
	bool FlashlightIsEmpty;
}

dictionary player_states;

// Will create a new state if the requested one does not exist
PlayerState@ getPlayerState(CBasePlayer@ pPlayer)
{
	string steamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if(steamId == 'STEAM_ID_LAN' or steamId == 'BOT') {
		steamId = pPlayer.pev.netname;
	}
	
	if(!player_states.exists(steamId))
	{
		PlayerState pState;
		pState.pPlayer = pPlayer;
		pState.maxFlashlight = 60;
		pState.FlashlightIsEmpty = false;
		player_states[steamId] = pState;
	}
	return cast<PlayerState@>(player_states[steamId]);
}

void populatePlayerStates()
{	
	CBaseEntity@ pEntity = null;
	do {
		@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "player"); 
		if (pEntity !is null)
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(pEntity);
			getPlayerState(pPlayer);
		}
	} while (pEntity !is null);
}

// End Anti-Rush code


void FlashlightThink()
{	
	CBaseEntity@ pEntity = null;
	
	// This controls the numerical display at the upper-right
	HUDTextParams pParams;
	pParams.x = 0.975;
	pParams.y = -0.93;
	pParams.a1 = 0;
	pParams.r1 = 255;
	pParams.fadeinTime = 0.0;
	pParams.fadeoutTime = 0.0;
	pParams.holdTime = 60.0;
	pParams.fxTime = 0.0;
	pParams.channel = 8;
	
	do {
		@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "player"); 
		if (pEntity !is null)																			
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(pEntity);
			PlayerState@ pState = getPlayerState(pPlayer);
			
			if(pPlayer.m_iFlashBattery >= 20) // White number display
			{
					pParams.g1 = 255;
					pParams.b1 = 255;
			}
			else // Low battery - Turn the text red
			{
					pParams.g1 = 0;
					pParams.b1 = 0;
			}
			
			g_PlayerFuncs.HudMessage(pPlayer, pParams, pPlayer.m_iFlashBattery);
			
			// Update the player's flashlight max battery state while the flashlight is on
			if(pPlayer.FlashlightIsOn())
			{
				if(pPlayer.m_iFlashBattery < 2) // Don't go below 2 battery power
					pState.maxFlashlight = 2;
				else
					pState.maxFlashlight = pPlayer.m_iFlashBattery;
			}
	
			// Hack: stop flashlight recharge after turning the flashlight off
			if(pPlayer.m_iFlashBattery == pState.maxFlashlight + 1)
				pPlayer.m_iFlashBattery = pState.maxFlashlight;
			else
				pState.maxFlashlight = pPlayer.m_iFlashBattery;

			if(pState.maxFlashlight == 0)
			{
				pState.FlashlightIsEmpty = true;
				
				if(pState.FlashlightIsEmpty)
				{
					g_PlayerFuncs.SayText(pPlayer, "Your flashlight is out of batteries.");
					pPlayer.m_iFlashBattery = 1;
					pState.FlashlightIsEmpty = false;
				}
				pState.maxFlashlight = 1;
			}

		}
	} while (pEntity !is null);
}

void MapInit()
{
	if(FL_ALLOWED.find(g_Engine.mapname) >= 0) // We can use the flashlight system on this map
	{
		populatePlayerStates();
		@interval = g_Scheduler.SetInterval("FlashlightThink", 0.025, -1);
	}
	else // Disable the plugin
	{
		player_states.deleteAll();
		g_Scheduler.RemoveTimer(interval);
	}
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Zorbos" );
	g_Module.ScriptInfo.SetContactInfo( "http://steamcommunity.com/id/zorbos/" );
	
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @PlayerJoin );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @PlayerLeave );
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
	PlayerState@ pState = getPlayerState(pPlayer);
	pPlayer.m_iFlashBattery = pState.maxFlashlight;
	
	return HOOK_CONTINUE;
}

HookReturnCode PlayerJoin(CBasePlayer@ pPlayer)
{
	if(pPlayer is null)
		return HOOK_CONTINUE;
		
	PlayerState@ pState = getPlayerState(pPlayer);
	
	return HOOK_CONTINUE;
}

HookReturnCode PlayerLeave(CBasePlayer@ pPlayer)
{
	string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	player_states.delete(steamId);
	
	return HOOK_CONTINUE;
}

HookReturnCode MapChange()
{
	g_Scheduler.RemoveTimer(interval);
	player_states.deleteAll();

	return HOOK_CONTINUE;
}