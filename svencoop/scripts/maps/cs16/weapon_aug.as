enum AUGAnimation
{
	AUG_IDLE = 0,
	AUG_RELOAD,
	AUG_DRAW,
	AUG_SHOOT1,
	AUG_SHOOT2,
	AUG_SHOOT3
};

const int AUG_DEFAULT_GIVE  	= 120;
const int AUG_MAX_CLIP      	= 30;
const int AUG_WEIGHT        	= 25;

class weapon_aug : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/aug/w_aug.mdl" );
		
		self.m_iDefaultAmmo = AUG_DEFAULT_GIVE;
		g_iCurrentMode = CS16_MODE_UNSCOPE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/aug/v_aug.mdl");
		g_Game.PrecacheModel( "models/cs16/aug/w_aug.mdl");
		g_Game.PrecacheModel( "models/cs16/aug/p_aug.mdl");
		
		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/rshell.mdl");

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud14.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud15.spr" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/aug-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/aug_forearm.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/aug_clipout.wav");
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/aug_clipin.wav");
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/aug_boltslap.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/aug_boltpull.wav");
		
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_rifle.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/aug-1.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/aug_forearm.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/aug_clipout.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/aug_clipin.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/aug_boltpull.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/aug_boltslap.wav");
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud14.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud15.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_aug.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= CS_556_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= AUG_MAX_CLIP;
		info.iSlot   	= 3;
		info.iPosition 	= 7;
		info.iFlags  	= 0;
		info.iWeight 	= AUG_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csaug( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csaug.WriteLong( g_ItemRegistry.GetIdForName("weapon_aug") );
			csaug.End();
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
	
	void Holster( int skipLocal = 0 )
	{
		self.m_fInReload = false;
		g_iCurrentMode = CS16_MODE_UNSCOPE;
		ToggleZoom( 0 );
		
		BaseClass.Holster( skipLocal );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	void SetFOV( int fov )
	{
		m_pPlayer.pev.fov = m_pPlayer.m_iFOV = fov;
	}
	
	void ToggleZoom( int zoomedFOV )
	{
		if ( self.m_fInZoom == true )
		{
			SetFOV( 0 ); // 0 means reset to default fov
		}
		else if ( self.m_fInZoom == false )
		{
			SetFOV( zoomedFOV );
		}
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/cs16/aug/v_aug.mdl" ), self.GetP_Model( "models/cs16/aug/p_aug.mdl" ), AUG_DRAW, "m16" );
		
			g_iCurrentMode = 0;
			ToggleZoom( 0 );
			float deployTime = 1;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
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
		
		if ( g_iCurrentMode == CS16_MODE_UNSCOPE )
		{
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.0875;
		}
		else
		{
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.135;
		}
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( AUG_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( AUG_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( AUG_SHOOT3, 0, 0 ); break;
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/aug-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 23;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_2DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x = Math.RandomLong( -3, -1 );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );

		TraceResult tr;
		float x, y;
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming + x * VECTOR_CONE_1DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_1DEGREES.y * g_Engine.v_up;
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
		CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 17, 12, -10, false, false );
	   
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
	   
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
		switch ( g_iCurrentMode )
		{
			case CS16_MODE_UNSCOPE:
			{
				g_iCurrentMode = CS16_MODE_SCOPE;
				ToggleZoom( 55 );
				break;
			}
		
			case CS16_MODE_SCOPE:
			{
				g_iCurrentMode = CS16_MODE_UNSCOPE;
				ToggleZoom( 0 );
				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip == AUG_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;

		BaseClass.Reload();
		g_iCurrentMode = 0;
		ToggleZoom( 0 );

		self.DefaultReload( AUG_MAX_CLIP, AUG_RELOAD, 3.325, 0 );
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( AUG_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetAUGName()
{
	return "weapon_aug";
}

void RegisterAUG()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetAUGName(), GetAUGName() );
	g_ItemRegistry.RegisterWeapon( GetAUGName(), "cs16", "ammo_cs_556" );
}