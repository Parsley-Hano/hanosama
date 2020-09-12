//Author: KernCore

enum TheyHungerTHOMPSONM1Animation_e
{
	THOMPSONM1_LONGIDLE = 0,
	THOMPSONM1_IDLE,
	THOMPSONM1_RELOAD_EMPTY,
	THOMPSONM1_RELOAD,
	THOMPSONM1_DEPLOY,
	THOMPSONM1_SHOOT1,
	THOMPSONM1_SHOOT2,
	THOMPSONM1_SHOOT3
};

const int THOMPSON_MAX_CARRY    	= 250;
const int THOMPSON_DEFAULT_GIVE 	= 100;
const int THOMPSON_MAX_CLIP     	= 50;
const int THOMPSON_WEIGHT       	= 25;

class weapon_tommygun : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	string TOMMY_W_MODEL = "models/hunger/weapons/tommygun/w_tommygun.mdl";
	string TOMMY_V_MODEL = "models/hunger/weapons/tommygun/v_tommy.mdl";
	string TOMMY_P_MODEL = "models/hunger/weapons/tommygun/p_tommygun.mdl";

	int m_iShell;

	string TOMMY_S_FIRE1 = "hunger/weapons/tommygun/fire.wav";

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, TOMMY_W_MODEL );
		
		self.m_iDefaultAmmo = THOMPSON_DEFAULT_GIVE;
		
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( TOMMY_W_MODEL );
		g_Game.PrecacheModel( TOMMY_V_MODEL );
		g_Game.PrecacheModel( TOMMY_P_MODEL );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );

		g_SoundSystem.PrecacheSound( TOMMY_S_FIRE1 );
		g_SoundSystem.PrecacheSound( "hunger/weapons/tommygun/M1921_boltback.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/tommygun/M1921_magin.wav" );
		g_SoundSystem.PrecacheSound( "hunger/weapons/tommygun/M1921_magout.wav" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= THOMPSON_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= THOMPSON_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 5;
		info.iFlags		= 0;
		info.iWeight	= THOMPSON_WEIGHT;
		
		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		@m_pPlayer = pPlayer;
		
		NetworkMessage hunger4( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
		hunger4.WriteLong( self.m_iId );
		hunger4.End();
		
		return true;
	}

	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, "weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		return false;
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy ( self.GetV_Model( TOMMY_V_MODEL ), self.GetP_Model( TOMMY_P_MODEL ), THOMPSONM1_DEPLOY, "sniper" );
		
			float deployTime = 0.62;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}

	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.09;
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSpread;

		if( m_pPlayer.pev.flags & FL_DUCKING != 0 && m_pPlayer.pev.flags & FL_ONGROUND != 0 )
		{
			switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
			{
				case 0: 
				self.SendWeaponAnim( THOMPSONM1_SHOOT1, 0, 0 );
				m_pPlayer.pev.punchangle.y += Math.RandomFloat( -0.45, 0.45 );
				break;

				case 1:
				self.SendWeaponAnim( THOMPSONM1_SHOOT2, 0, 0 );
				m_pPlayer.pev.punchangle.y += -0.35;
				break;

				case 2:
				self.SendWeaponAnim( THOMPSONM1_SHOOT3, 0, 0 );
				m_pPlayer.pev.punchangle.y += 0.35;
				break;
			}

			vecSpread = VECTOR_CONE_6DEGREES;
		}
		else
		{
			switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
			{
				case 0: 
				self.SendWeaponAnim( THOMPSONM1_SHOOT1, 0, 0 );
				m_pPlayer.pev.punchangle.y += Math.RandomFloat( -0.9, 0.9 );
				break;

				case 1:
				self.SendWeaponAnim( THOMPSONM1_SHOOT2, 0, 0 );
				m_pPlayer.pev.punchangle.y += -0.7;
				break;

				case 2:
				self.SendWeaponAnim( THOMPSONM1_SHOOT3, 0, 0 );
				m_pPlayer.pev.punchangle.y += 0.7;
				break;
			}

			vecSpread = VECTOR_CONE_9DEGREES;
		}
		
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, TOMMY_S_FIRE1, Math.RandomFloat( 0.95, 1.0 ), ATTN_NORM, 0, 93 + Math.RandomLong( 0, 0xf ) );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );

		m_pPlayer.pev.punchangle.x -= 1.3;
		if( m_pPlayer.pev.punchangle.x <= -6.5 )
		{
			m_pPlayer.pev.punchangle.x = -6.5;
		}

		int m_iBulletDamage = Math.RandomLong( 6, 9 );

		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, vecSpread, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 4, m_iBulletDamage );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );

		Vector vecDir;
		
		if( m_pPlayer.pev.punchangle.x == -1.5 )
		{
			vecDir = vecAiming + x * VECTOR_CONE_1DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;
		}
		else if( m_pPlayer.pev.punchangle.x > -7.5 )
		{
			switch( Math.RandomLong( 0, 1 ) )
			{
				case 0: vecDir = vecAiming + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_5DEGREES.y * g_Engine.v_up; break;
				case 1: vecDir = vecAiming + x * VECTOR_CONE_5DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_7DEGREES.y * g_Engine.v_up; break;
			}
		}
		else if( m_pPlayer.pev.punchangle.x <= -6.5 )
		{
			vecDir = vecAiming + x * VECTOR_CONE_8DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_9DEGREES.y * g_Engine.v_up;
			//m_pPlayer.pev.punchangle.y += 1;
		}

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		Vector vecShellVelocity, vecShellOrigin;
		
		THGetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 19, 7, -7 );
		
		vecShellVelocity.y *= 1;
		
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() == true )
				{
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
				}
			}
		}
	}

	void Reload()
	{
		if( self.m_iClip < THOMPSON_MAX_CLIP )
			BaseClass.Reload();

		self.m_iClip == 0 ? self.DefaultReload( THOMPSON_MAX_CLIP, THOMPSONM1_RELOAD_EMPTY, 2.08, 0 ) : self.DefaultReload( THOMPSON_MAX_CLIP, THOMPSONM1_RELOAD, 1.56, 0 );
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
		{
			case 0:	iAnim = THOMPSONM1_LONGIDLE;
			break;
			
			case 1: iAnim = THOMPSONM1_IDLE;
			break;
		}

		self.SendWeaponAnim( iAnim, 0, 0 );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  5, 7 );
	}
}

string THOMPSONM1Name()
{
	return "weapon_tommygun";
}

void RegisterTHOMPSONM1()
{
	g_CustomEntityFuncs.RegisterCustomEntity( THOMPSONM1Name(), THOMPSONM1Name() );
	g_ItemRegistry.RegisterWeapon( THOMPSONM1Name(), "hunger/weapons", "9mm" );
}