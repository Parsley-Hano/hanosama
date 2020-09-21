//AS Scripts for RAGEMAP TWENTY EIGHTEEN
//the file is called "puchis_scripts" GUESS WHO THIS IS FROM! and again, thank you very much Geckon and Zode.

// RC: "I included my script and calling RCMapInit() from MapInit()"
// =========================================================
#include "../rage5/rage5"
// =========================================================


bool Weaponsfired = false;
bool WeaponsfiredatEnd = false;
bool WeaponsalreadyfiredatEnd = false;
bool g_fShowTimer;

void MapInit()
{
	Puchi::Register();
	RCMapInit();
}

namespace Puchi
{
	void Register()
	{
		g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @PlayerPutInServer);
		g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack,@RabbitholeWeaponUsage);
		g_Hooks.RegisterHook(Hooks::Weapon::WeaponSecondaryAttack,@RabbitholeWeaponUsage);
		g_Hooks.RegisterHook(Hooks::Weapon::WeaponTertiaryAttack,@RabbitholeWeaponUsage);
	}

	HookReturnCode PlayerPutInServer(CBasePlayer@ pPlayer)
	{
		if (g_fShowTimer) Timer::SendTimer(pPlayer);
		return HOOK_CONTINUE;
	}

	HookReturnCode RabbitholeWeaponUsage(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
	{
		if ((pWeapon.pev.classname != "weapon_medkit") && (!Weaponsfired))
		{
			CBaseEntity@ FindBox = null;
			@FindBox = g_EntityFuncs.FindEntityByTargetname(null, "puchi_rabbithole_detector");

			if (FindBox !is null)
			{
				if (g_Utility.IsPlayerInVolume(pPlayer, FindBox))
				{
					if (!WeaponsfiredatEnd)
					{
						g_EntityFuncs.FireTargets("puchi_rabbithole_suppliesgone_mm",pPlayer,null,USE_TOGGLE,0.0f, 0.0f);
						Weaponsfired = true;
						g_PlayerFuncs.HudToggleElement( null, 2, false );
						g_fShowTimer = false;
					}
					if (WeaponsfiredatEnd && !WeaponsalreadyfiredatEnd)
					{
						WeaponsalreadyfiredatEnd = true;

						g_EntityFuncs.FireTargets("puchi_rabbithole_ambient1",null,null,USE_OFF,0.0f, 0.0f);
						g_EntityFuncs.FireTargets("puchi_rabbithole_ambient2",null,null,USE_OFF,0.0f, 0.0f);
						g_EntityFuncs.FireTargets("puchi_rabbithole_ambient3",null,null,USE_OFF,0.0f, 0.0f);
						g_EntityFuncs.FireTargets("puchi_rabbithole_gtfo",null,null,USE_TOGGLE,0.0f, 0.0f);
						g_EntityFuncs.FireTargets("puchi_ragecube_launch_push",null,null,USE_TOGGLE,0.0f, 0.0f);
						g_EntityFuncs.FireTargets("puchi_rabbithole_entry_relay",null,null,USE_ON,0.0f, 5.0f);
						g_EntityFuncs.FireTargets("puchi_rabbithole_entry_red",null,null,USE_ON,0.0f, 5.2f);
						g_EntityFuncs.FireTargets("puchi_rabbithole_entry_green",null,null,USE_OFF,5.0f, 5.2f);
						g_EntityFuncs.FireTargets("puchi_rabbithole_entry",null,null,USE_OFF,0.0f, 5.2f);
						g_EntityFuncs.FireTargets("puchi_rabbithole_entry_relay",null,null,USE_ON,0.0f, 5.3f);
						g_EntityFuncs.FireTargets("puchi_cubythingisremoved",null,null,USE_TOGGLE,0.0f,5.5f);
						g_EntityFuncs.FireTargets("puchi_sector_over",null,null,USE_TOGGLE,0.0f,6.0f);
					}
				}
			}
		}
		return HOOK_CONTINUE;
	}


}//end namespace


// Timer
namespace Timer
{
	int g_iTimerState;
	float g_flStartTime;

	void Start (CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		g_flStartTime = g_Engine.time;
		g_fShowTimer = true;
		SendTimer(null);
		g_Scheduler.SetInterval( "Update", 0.1, g_Scheduler.REPEAT_INFINITE_TIMES );
	}

	void Update()
	{
		if ( g_fShowTimer )
		{
			int iNewState = GetTimerState();

			if ( g_iTimerState != iNewState )
			{
				if (iNewState == -1)
				{
					g_PlayerFuncs.HudToggleElement( null, 2, false );
					g_fShowTimer = false;

					WeaponsfiredatEnd = true;
					g_EntityFuncs.FireTargets("puchi_killtriggeronce",null,null,USE_TOGGLE,0.0f,0.0f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_niceend",null,null,USE_TOGGLE,0.0f, 0.0f);
					g_EntityFuncs.FireTargets("puchi_ragecube_launch_push",null,null,USE_TOGGLE,0.0f, 3.0f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_entry_relay",null,null,USE_ON,0.0f, 20.0f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_entry_red",null,null,USE_ON,0.0f, 20.2f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_entry_green",null,null,USE_OFF,20.0f, 20.2f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_entry",null,null,USE_OFF,0.0f, 20.2f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_entry_relay",null,null,USE_ON,0.0f, 20.3f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_bar",null,null,USE_TOGGLE,0.0f,18.0f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_normal",null,null,USE_TOGGLE,0.0f,18.0f);
					g_EntityFuncs.FireTargets("puchi_cubythingisremoved",null,null,USE_TOGGLE,0.0f,18.5f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_ambient1",null,null,USE_OFF,0.0f, 16.0f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_ambient2",null,null,USE_OFF,0.0f, 16.0f);
					g_EntityFuncs.FireTargets("puchi_rabbithole_ambient3",null,null,USE_OFF,0.0f, 16.0f);
					g_EntityFuncs.FireTargets("puchi_sector_over",null,null,USE_TOGGLE,0.0f,21.0f);
				}
				g_iTimerState = iNewState;
			}
		}
	}

	float GetTimeLeft()
	{
		float TIME = 150.0f;
		return TIME - ( g_Engine.time - g_flStartTime );
	}

	int GetTimerState()
	{
		float flTimeLeft = GetTimeLeft();
		return Math.clamp( -1, 4, int( Math.Floor( flTimeLeft ) ) );
	}

	void SendTimer( CBasePlayer@ pPlayer )
	{
		HUDNumDisplayParams params;

		params.channel = 2;

		params.flags = HUD_TIME_MINUTES | HUD_TIME_SECONDS | HUD_TIME_COUNT_DOWN | HUD_ELEM_DEFAULT_ALPHA;

		params.value = GetTimeLeft();

		params.x = 0.42;
		params.y = 0.55;

		params.color1 = GetTimerState() <= 3 ? RGBA_RED : RGBA_SVENCOOP;

		params.spritename = "stopwatch";

		g_PlayerFuncs.HudTimeDisplay( pPlayer, params );
	}
}// end namespace Timer

