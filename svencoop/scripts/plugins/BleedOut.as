// BleedOut.as
// Plugin by Zorbos & w00tguy123

// Enables a Bleedout functionality where players begin to lose health slowly over time after dropping below a certain threshold.
// At < 25 health, players will begin to bleed for 1 health every 6 seconds, their vision will become slightly distorted, and their movement speed will be slightly impaired.
// When dropping below 15 health, players will begin to bleed faster, for 1 health every 3.5 seconds.
// When reaching 1 health, vision will become very distorted and movement speed will be drastically reduced.
// To stop the bleeding, players must heal themselves above 25 health using pills.

// This plugin is only designed to work on the Afraid of Monsters maps. Edit the 'BLEED_ALLOWED' maplist below if you wish to add more maps.

// BleedOut Plugin is ONLY allowed on these maps:
const array<string> BLEED_ALLOWED = {"aom_hospital", "aom_hospital2", "aom_garage", "aom_backalley", "aom_darkalley", "aom_city",
									 "aom_city", "aom_city2", "aom_city3", "aom_sick", "aom_sick2", "aom_sick3", "aom_forest",
									 "aom_forhouse", "aom_forest2", "aom_forest3", "aom_heaven1", "aom_heaven2",
									 "aomdc_1hospital", "aomdc_1hospital2", "aomdc_1garage", "aomdc_1backalley", "aomdc_1darkalley",
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

const float PLAYER_MOD_BLEEDTICK_CAUTION = 6; // Time between bleed ticks, first stage
const float PLAYER_MOD_BLEEDTICK_INJURED = 3.5; // Time between bleed ticks, second stage
const float PLAYER_MOD_MINHEALTH_CAUTION = 24; // Minimum health to start bleeding, first stage
const float PLAYER_MOD_MINHEALTH_INJURED = 14; // Minimum health to start bleeding, second stage
const float PLAYER_MOD_MOVESPEED_CAUTION = 190; // Player movespeed during first stage
const float PLAYER_MOD_MOVESPEED_INJURED = 190; // Player movespeed during second stage
const float PLAYER_MOD_MOVESPEED_CRITICAL = 140; // Player movespeed during critical stage
const float PLAYER_MOD_FOV_CRITICAL = 115.0; // The player's FOV upon entering critical pState



// The below code is taken from w00tguy123's Anti-Rush plugin.
// All credit goes to him for the code.

class PlayerState
{
	EHandle pPlayer;
	int reportState;
}

dictionary player_states;
CScheduledFunction@ interval;

// Will create a new pState if the requested one does not exist
PlayerState@ getPlayerState(CBasePlayer@ pPlayer)
{
	string steamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if(steamId == 'STEAM_ID_LAN' or steamId == 'BOT')
		steamId = pPlayer.pev.netname;

	if(!player_states.exists(steamId))
	{
		PlayerState pState;
		pState.pPlayer = pPlayer;
		pState.reportState = 0;
		player_states[steamId] = pState;
	}
	
	return cast<PlayerState@>(player_states[steamId]);
}

void populatePlayerStates()
{	
	CBaseEntity@ pEntity = null;
	do {
		@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "player"); 
		if(pEntity !is null)
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(pEntity);
			getPlayerState(pPlayer);
		}
	} while(pEntity !is null);
}

// End Anti-Rush code



// Spawns a blood splatter at the player's feet
void SpawnBlood(CBasePlayer@ pPlayer)
{
	Vector vecOrigin = pPlayer.GetOrigin();
	Vector vecEnd = Vector(0, 0, -1.0) * Math.RandomLong(5000, 8000);
	int iColor = BLOOD_COLOR_RED;
	int iAmount = Math.RandomLong(5, 10);
	TraceResult tr;
	
	g_Utility.TraceLine( vecOrigin, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );
	
	if(tr.pHit !is null)
	{
		CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
		
		if(pHit is null || pHit.IsBSPModel() == true)
		{
			g_Utility.BloodDecalTrace(tr, iColor);
			g_Utility.BloodStream(pPlayer.GetOrigin(), g_Utility.RandomBloodVector() * 100, iColor, iAmount);
			g_Utility.BloodStream(pPlayer.GetOrigin(), g_Utility.RandomBloodVector() * 100, iColor, iAmount);
			g_Utility.BloodDrips(pPlayer.GetOrigin(), vecEnd, iColor, iAmount);
		}
	}
}

// Sets player FOV
void SetPlayerFOV(CBasePlayer@ pPlayer, const int iFov)
{
	pPlayer.pev.fov = pPlayer.m_iFOV = iFov;
}

// The main function
// Checks and updates player states every 2.142 seconds
void BleedThink()
{
	CBaseEntity@ pEntity = null;
	
	do {
		@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "player"); 
		if(pEntity !is null)
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(pEntity);
			PlayerState@ pState = getPlayerState(pPlayer);
			
			if(!pPlayer.IsAlive() or !pPlayer.IsConnected())
			{
				pState.reportState = 0;
				continue;
			}
			
			bool critical = pPlayer.pev.health <= 1;
			bool injured = pPlayer.pev.health <= PLAYER_MOD_MINHEALTH_INJURED && pPlayer.pev.health > 1;
			bool caution = pPlayer.pev.health <= PLAYER_MOD_MINHEALTH_CAUTION && pPlayer.pev.health > PLAYER_MOD_MINHEALTH_INJURED;
			
			if(pPlayer.pev.waterlevel == WATERLEVEL_HEAD && pState.reportState != 2 && pState.reportState != 1) // Don't start bleeding when drowning from healthy status
			{
				pState.reportState = 3; // Player was drowning from healthy status.
				return;
			}
			else
			{
				if(critical) // Below critical threshold
				{
					if(pState.reportState != 3) // Player was recovering from drowning. Don't bleed
					{
						if(pState.reportState != 2) // We haven't reported the players condition yet
						{
							g_PlayerFuncs.SayText(pPlayer, "DANGER: You are critical!!");
							pState.reportState = 2;
						}
						
						if(pPlayer.pev.flags & FL_DUCKING != 0) // Player is ducking. Speed them up a bit
							pPlayer.pev.maxspeed = 175;
						else
							pPlayer.pev.maxspeed = PLAYER_MOD_MOVESPEED_CRITICAL;
						
						g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "AoMDC/misc/breathe1.wav", 0.50f, 1.0f, 0, 100);
						g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STREAM, "AoMDC/misc/breathe2.wav", 0.65f, 1.0f, 0, 100, pPlayer.entindex());
						

						g_PlayerFuncs.ScreenFade(pPlayer, Vector(120, 0, 0), PLAYER_MOD_BLEEDTICK_INJURED, 2.412, 220, FFADE_MODULATE | FFADE_IN);
						SpawnBlood(pPlayer);
						SetPlayerFOV(pPlayer, PLAYER_MOD_FOV_CRITICAL);
					}
				}
				else if(caution) // Stage 1 bleed
				{
					if(pState.reportState != 3) // Player was recovering from drowning. Don't bleed
					{
						if(pState.reportState != 1) // We haven't reported the players condition yet
						{
							g_PlayerFuncs.SayText(pPlayer, "CAUTION: You are hurt!");
							pState.reportState = 1;
						}
						
						if(pPlayer.pev.flags & FL_DUCKING != 0) // Player is ducking. Speed them up a bit
							pPlayer.pev.maxspeed = 235;
						else
							pPlayer.pev.maxspeed = PLAYER_MOD_MOVESPEED_INJURED;
						
						if(pPlayer.pev.yaw_speed + PLAYER_MOD_BLEEDTICK_CAUTION < g_Engine.time)
						{
							pPlayer.pev.punchangle.x = -3.0;
							pPlayer.pev.health -= 1;
							pPlayer.pev.yaw_speed = g_Engine.time;
						}

						
						g_PlayerFuncs.ScreenFade(pPlayer, Vector(120, 0, 0), PLAYER_MOD_BLEEDTICK_CAUTION, 2.412, 175, FFADE_MODULATE | FFADE_IN);
						SpawnBlood(pPlayer);
						SetPlayerFOV(pPlayer, 0);
					}
				}
				else if(injured) // Stage 2 bleed
				{
					if(pState.reportState != 3) // Player was recovering from drowning.
					{
						if(pState.reportState != 1) // We haven't reported the players condition yet
						{
							g_PlayerFuncs.SayText(pPlayer, "CAUTION: You are hurt!");
							pState.reportState = 1;
						}
						
						g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "AoMDC/misc/breathe1.wav", 0.50f, 1.0f, 0, 100);
						
						if(pPlayer.pev.flags & FL_DUCKING != 0) // Player is ducking. Speed them up a bit
							pPlayer.pev.maxspeed = 235;
						else
							pPlayer.pev.maxspeed = PLAYER_MOD_MOVESPEED_INJURED;
						
						if(pPlayer.pev.yaw_speed + PLAYER_MOD_BLEEDTICK_INJURED < g_Engine.time)
						{
							pPlayer.pev.punchangle.x = -3.0;
							pPlayer.pev.health -= 1;
							pPlayer.pev.yaw_speed = g_Engine.time;
						}

						g_PlayerFuncs.ScreenFade(pPlayer, Vector(120, 0, 0), PLAYER_MOD_BLEEDTICK_INJURED, 2.412, 175, FFADE_MODULATE | FFADE_IN);
						SpawnBlood(pPlayer);
						SetPlayerFOV(pPlayer, 0);

					}
				}
				else // Healthy
				{
					if(pState.reportState != 0 && pState.reportState != 3) // Player was not recovering from drowning and we haven't reported their condition yet
					{
						g_PlayerFuncs.SayText(pPlayer, "You've stopped the bleeding.");
						pState.reportState = 0;
					}
					else // Player was recovering from drowning but is now healthy. Reset their status
						pState.reportState = 0;
					
					pPlayer.pev.maxspeed = 0;
					SetPlayerFOV(pPlayer, 0); // Reset FOV
				}
			}
		}
	} while (pEntity !is null);
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Zorbos & w00tguy123" );
	g_Module.ScriptInfo.SetContactInfo( "Zorbos - steamcommunity.com/id/zorbos, w00tguy123 - forums.svencoop.com" );
	
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

void MapInit()
{
	g_SoundSystem.PrecacheSound("AoMDC/misc/breathe1.wav");
	g_SoundSystem.PrecacheSound("AoMDC/misc/breathe2.wav");
	
	if(BLEED_ALLOWED.find(g_Engine.mapname) >= 0)
		@interval = g_Scheduler.SetInterval("BleedThink", 2.412, -1);
	else
		g_Scheduler.RemoveTimer(interval);
}

HookReturnCode MapChange()
{
	g_Scheduler.RemoveTimer(interval);
	player_states.deleteAll();
	return HOOK_CONTINUE;
}