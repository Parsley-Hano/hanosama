enum ElitesAnimation
{
	ELITES_IDLE = 0,
	ELITES_IDLE_LEFTEMPTY,
	ELITES_SHOOTLEFT1,
	ELITES_SHOOTLEFT2,
	ELITES_SHOOTLEFT3,
	ELITES_SHOOTLEFT4,
	ELITES_SHOOTLEFT5,
	ELITES_SHOOTLEFTLAST,
	ELITES_SHOOTRIGHT1,
	ELITES_SHOOTRIGHT2,
	ELITES_SHOOTRIGHT3,
	ELITES_SHOOTRIGHT4,
	ELITES_SHOOTRIGHT5,
	ELITES_SHOOTRIGHTLAST,
	ELITES_RELOAD,
	ELITES_DRAW
};

const int ELITES_DEFAULT_GIVE	= 60;
const int ELITES_MAX_CLIP		= 30;
const int ELITES_WEIGHT			= 5;

class weapon_dualelites : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iShell;
	int m_iShotsFired;
	bool leftright = false;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/dualelites/w_elite.mdl" );
		
		self.m_iDefaultAmmo = ELITES_DEFAULT_GIVE;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/dualelites/v_elite.mdl" );
		g_Game.PrecacheModel( "models/cs16/dualelites/w_elite.mdl" );
		g_Game.PrecacheModel( "models/cs16/dualelites/p_elite.mdl" );
		
		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/pshell.mdl" );

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud14.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud15.spr" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_pistol.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/elite_fire.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/elite_deploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/elite_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/elite_leftclipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/elite_reloadstart.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/elite_twirl.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/elite_rightclipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/elite_sliderelease.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_pistol.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/elite_fire.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/elite_sliderelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/elite_twirl.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/elite_leftclipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/elite_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/elite_reloadstart.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/elite_sliderelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/elite_rightclipin.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud14.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud15.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_dualelites.txt" );
		
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= CS_9mm_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= ELITES_MAX_CLIP;
		info.iSlot 		= 1;
		info.iPosition 	= 4;
		info.iFlags 	= 0;
		info.iWeight 	= ELITES_WEIGHT;

		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) == true )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csdualelites( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csdualelites.WriteLong( g_ItemRegistry.GetIdForName("weapon_dualelites") );
			csdualelites.End();
			return true;
		}
		
		return false;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, "weapons/cs16/dryfire_pistol.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/cs16/dualelites/v_elite.mdl" ), self.GetP_Model( "models/cs16/dualelites/p_elite.mdl" ), ELITES_DRAW, "uzis" );
		
			float deployTime = 1.1f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
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

		m_iShotsFired++;
		if( m_iShotsFired > 1 )
		{
			return;
		}
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.122;

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		if( leftright == true )
		{
			m_pPlayer.m_szAnimExtension = "uzis_right";
			leftright = false;
		}
		else
		{
			m_pPlayer.m_szAnimExtension = "uzis_left";
			leftright = true;
		}

		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.28;

		int iAnimation;

		if( self.m_iClip == 1 )
		{
			iAnimation = ELITES_SHOOTLEFTLAST;
		}
		else if( self.m_iClip == 0 )
		{
			iAnimation = ELITES_SHOOTRIGHTLAST;
		}
		else
		{
			iAnimation = ( ( self.m_iClip % 2 ) == 0 ) ? ELITES_SHOOTRIGHT1 : ELITES_SHOOTLEFT1;

			iAnimation += g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 4 );
		}
		
		self.SendWeaponAnim( iAnimation, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/elite_fire.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 22;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
			
		m_pPlayer.pev.punchangle.x = Math.RandomLong( -2, -1 );
		m_pPlayer.pev.punchangle.y = Math.RandomFloat( -0.2f, 0.2f );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
		Vector vecEnd = vecSrc + vecDir * 4096;
		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() == true )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
			}
		}
		
		Vector vecShellVelocity, vecShellOrigin;
		
		if( iAnimation == ELITES_SHOOTRIGHT1 )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7, true, false );
		else if( iAnimation == ELITES_SHOOTRIGHT2 )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7, true, false );
		else if( iAnimation == ELITES_SHOOTRIGHT3 )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7, true, false );
		else if( iAnimation == ELITES_SHOOTRIGHT4 )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7, true, false );
		else if( iAnimation == ELITES_SHOOTRIGHT5 )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7, true, false );
		else if( iAnimation == ELITES_SHOOTRIGHTLAST )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, -9, -7, true, false );
		else if ( iAnimation == ELITES_SHOOTLEFT1 )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7, false, false );
		else if ( iAnimation == ELITES_SHOOTLEFT2 )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7, false, false );
		else if ( iAnimation == ELITES_SHOOTLEFT3 )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7, false, false );
		else if ( iAnimation == ELITES_SHOOTLEFT4 )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7, false, false );
		else if ( iAnimation == ELITES_SHOOTLEFT5 )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7, false, false );
		else if ( iAnimation == ELITES_SHOOTLEFTLAST )
			CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 21, 9, -7, false, false );

		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;

		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip == ELITES_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;

		switch( Math.RandomLong( 0, 1 ) )
		{
			case 0: m_pPlayer.m_szAnimExtension = "uzis_right"; break;
			case 1: m_pPlayer.m_szAnimExtension = "uzis_left"; break;
		}
		
		BaseClass.Reload();
		
		self.DefaultReload( ELITES_MAX_CLIP, ELITES_RELOAD, 4.6, 0 );
	}
	
	void WeaponIdle()
	{
		// Can we fire?
		if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
		// If the player is still holding the attack button, m_iShotsFired won't reset to 0
		// Preventing the automatic firing of the weapon
			if ( !( ( m_pPlayer.pev.button & IN_ATTACK ) != 0 ) )
			{
				// Player released the button, reset now
				m_iShotsFired = 0;
			}
		}

		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() || self.m_flTimeWeaponIdle == 0.28f )
		{
			m_pPlayer.m_szAnimExtension = "uzis";
			return;
		}
		
		self.SendWeaponAnim( ELITES_IDLE );
		
		if( self.m_iClip == 1 )
		{
			self.SendWeaponAnim( ELITES_IDLE_LEFTEMPTY );
		}
		
		if( leftright == true )
		{
			self.m_flTimeWeaponIdle = 0.28;
			m_pPlayer.m_szAnimExtension = "uzis";
		}
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.28;
		
		m_pPlayer.m_szAnimExtension = "uzis";
	}
}	

string GetELITESName()
{
	return "weapon_dualelites";
}

void RegisterELITES()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetELITESName(), GetELITESName() );
	g_ItemRegistry.RegisterWeapon( GetELITESName(), "cs16", "ammo_cs_9mm" );
}