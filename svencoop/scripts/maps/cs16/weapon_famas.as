enum FAMASAnimation
{
	FAMAS_IDLE = 0,
	FAMAS_RELOAD,
	FAMAS_DRAW,
	FAMAS_SHOOT1,
	FAMAS_SHOOT2,
	FAMAS_SHOOT3
};

const int FAMAS_DEFAULT_GIVE    	= 120;
const int FAMAS_MAX_CLIP        	= 25;
const int FAMAS_WEIGHT          	= 5;

class weapon_famas : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;
	int m_iBurstLeft = 0;
	/**
	*   The total number of shots in the last burst.
	*/
	int m_iBurstCount = 0;

	/**
	*   The time at which another burst should be fired.
	*/
	float m_flNextBurstFireTime = 0;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/famas/w_famas.mdl" );

		self.m_iDefaultAmmo = FAMAS_DEFAULT_GIVE;
		g_iCurrentMode = CS16_MODE_NOBURST;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/famas/v_famas.mdl" );
		g_Game.PrecacheModel( "models/cs16/famas/w_famas.mdl" );
		g_Game.PrecacheModel( "models/cs16/famas/p_famas.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/rshell.mdl" );

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud17.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud18.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );

		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/famas-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/famas-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/famas_forearm.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/famas_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/famas_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/famas-burst.wav" );

		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/famas-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/famas-2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/famas_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/famas_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/famas_forearm.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/famas-burst.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud17.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud18.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_famas.txt" );
	}
   
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= CS_556_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= FAMAS_MAX_CLIP;
		info.iSlot  	= 3;
		info.iPosition	= 5;
		info.iFlags 	= 0;
		info.iWeight	= FAMAS_WEIGHT;
	
		return true;
	}
   
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csfamas( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csfamas.WriteLong( g_ItemRegistry.GetIdForName("weapon_famas") );
			csfamas.End();
			return true;
		}

		return false;
	}

	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, "weapons/cs16/dryfire_rifle.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
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
			bResult = self.DefaultDeploy( self.GetV_Model( "models/cs16/famas/v_famas.mdl" ), self.GetP_Model( "models/cs16/famas/p_famas.mdl" ), FAMAS_DRAW, "m16" );

			float deployTime = 1.03;
			g_iCurrentMode = CS16_MODE_NOBURST;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}

	void Holster( int skipLocal = 0 )
	{
		self.m_fInReload = false;
		//Cancel burst.

		g_iCurrentMode = CS16_MODE_NOBURST;
		m_iBurstLeft = 0;

		BaseClass.Holster( skipLocal );
	}

	/**
	*   Fires a single bullet, sets correct effects and settings.
	*/
	void FireABullet()
	{
		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;

		--self.m_iClip;

		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( FAMAS_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( FAMAS_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( FAMAS_SHOOT3, 0, 0 ); break;
		}

		m_pPlayer.FireBullets( 1, m_pPlayer.GetGunPosition(), m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES ), VECTOR_CONE_2DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, 32 );

		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );	

		int m_iBulletDamage = 22;

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x = Math.RandomLong( -2, -1 );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

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

		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 19, 15, -12, false, false );

		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;

		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}

	/**
	*   Plays a single famas weapon fire sound.
	*/
	
	private void PlayFireSound()
	{
		switch ( g_PlayerFuncs.SharedRandomLong(m_pPlayer.random_seed, 0, 2) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/famas-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/famas-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			case 2: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/famas-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
		}
	}

	void PrimaryAttack()
	{
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		//Burst fire is 3 rounds, we fire one now, the other 2 later.

		if( g_iCurrentMode == CS16_MODE_BURST )
		{
			//Fire at most 3 bullets.
			m_iBurstCount = Math.min( 3, self.m_iClip );
			m_iBurstLeft = m_iBurstCount - 1;
 
			m_flNextBurstFireTime = WeaponTimeBase() + 0.066;
			//Prevent primary attack before burst finishes. Might need to be finetuned.
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
		
			if( m_iBurstCount == 3 )
			{
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/famas-burst.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
			}
			else
			{
				//Fewer than 3 bullets left, play individual fire sounds.
				PlayFireSound();
			}
		}
		else if (g_iCurrentMode == CS16_MODE_NOBURST)
		{
			self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.095;

			PlayFireSound();
		}

		FireABullet();
	}

	void SecondaryAttack()
	{
		switch( g_iCurrentMode )
		{
			case CS16_MODE_NOBURST:
			{
				g_iCurrentMode = CS16_MODE_BURST;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, " Switched to Burst Fire \n" );
				break;
			}
			case CS16_MODE_BURST:
			{
				g_iCurrentMode = CS16_MODE_NOBURST;
				g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, " Switched to Full Auto \n" );
				break;
			}
		}
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
	}

	void Reload()
	{	   
		if( self.m_iClip == FAMAS_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;
		
		BaseClass.Reload();
		m_iBurstLeft = 0;
		self.DefaultReload( FAMAS_MAX_CLIP, FAMAS_RELOAD, 3.03, 0 );
	}

	//Overridden to prevent WeaponIdle from being blocked by holding down buttons.
	void ItemPostFrame()
	{
		//If firing bursts, handle next shot.
		if( m_iBurstLeft > 0 )
		{
			if( m_flNextBurstFireTime < WeaponTimeBase() )
			{
				if( self.m_iClip <= 0 )
				{
					m_iBurstLeft = 0;
					return;
				}
				else
				{
					--m_iBurstLeft;
				}

				if( m_iBurstCount < 3 )
				{
					PlayFireSound();
				}

				FireABullet();

				if( m_iBurstLeft > 0 )
					m_flNextBurstFireTime = WeaponTimeBase() + 0.1;
				else
					m_flNextBurstFireTime = 0;
			}

			//While firing a burst, don't allow reload or any other weapon actions. Might be best to let some things run though.
			return;
		}

		BaseClass.ItemPostFrame();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( FAMAS_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetFAMASName()
{
	return "weapon_famas";
}

void RegisterFAMAS()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetFAMASName(), GetFAMASName() );
	g_ItemRegistry.RegisterWeapon( GetFAMASName(), "cs16", "ammo_cs_556" );
}