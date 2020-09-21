enum FiveSevenAnimation
{
	FIVE7_IDLE = 0,
	FIVE7_SHOOT1,
	FIVE7_SHOOT2,
	FIVE7_SHOOTLAST,
	FIVE7_RELOAD,
	FIVE7_DRAW
};

const int FIVE7_DEFAULT_GIVE	= 120;
const int FIVE7_MAX_CLIP    	= 20;
const int FIVE7_WEIGHT      	= 5;

class weapon_fiveseven : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iShell;
	int m_iShotsFired;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/five7/w_fiveseven.mdl" );
		
		self.m_iDefaultAmmo = FIVE7_DEFAULT_GIVE;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/five7/v_fiveseven.mdl" );
		g_Game.PrecacheModel( "models/cs16/five7/w_fiveseven.mdl" );
		g_Game.PrecacheModel( "models/cs16/five7/p_fiveseven.mdl" );
		
		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/pshell.mdl" );

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud14.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud15.spr" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_pistol.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/fiveseven-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/fiveseven_sliderelease.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/fiveseven_slidepull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/fiveseven_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/fiveseven_clipin.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_pistol.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/fiveseven-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/fiveseven_sliderelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/fiveseven_slidepull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/fiveseven_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/fiveseven_clipout.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud14.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud15.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_fiveseven.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= CS_57_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= FIVE7_MAX_CLIP;
		info.iSlot 		= 1;
		info.iPosition 	= 9;
		info.iFlags 	= 0;
		info.iWeight 	= FIVE7_WEIGHT;

		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) == true )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csfiveseven( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csfiveseven.WriteLong( g_ItemRegistry.GetIdForName("weapon_fiveseven") );
			csfiveseven.End();
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
			bResult = self.DefaultDeploy( self.GetV_Model( "models/cs16/five7/v_fiveseven.mdl" ), self.GetP_Model( "models/cs16/five7/p_fiveseven.mdl" ), FIVE7_DRAW, "onehanded" );

			float deployTime = 1;
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
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.125;
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if ( self.m_iClip <= 0 )
		{
			self.SendWeaponAnim( FIVE7_SHOOTLAST, 0, 0 );
		}
		else
		{
			switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
			{
				case 0: self.SendWeaponAnim( FIVE7_SHOOT1, 0, 0 ); break;
				case 1: self.SendWeaponAnim( FIVE7_SHOOT2, 0, 0 ); break;
			}
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/fiveseven-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 17;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
			
		m_pPlayer.pev.punchangle.x = Math.RandomLong( -2, -1 );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

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
       
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 8, -6, true, false );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip == FIVE7_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;
		
		self.DefaultReload( FIVE7_MAX_CLIP, FIVE7_RELOAD, 3.24, 0 );
		BaseClass.Reload();
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
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( FIVE7_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetFIVESEVENName()
{
	return "weapon_fiveseven";
}

void RegisterFIVESEVEN()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetFIVESEVENName(), GetFIVESEVENName() );
	g_ItemRegistry.RegisterWeapon( GetFIVESEVENName(), "cs16", "ammo_cs_fn57" );
}