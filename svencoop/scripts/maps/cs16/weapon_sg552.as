enum SG552Animation
{
	SG552_IDLE = 0,
	SG552_RELOAD,
	SG552_DRAW,
	SG552_SHOOT1,
	SG552_SHOOT2,
	SG552_SHOOT3
};

const int SG552_DEFAULT_GIVE    	= 120;
const int SG552_MAX_CLIP        	= 30;
const int SG552_WEIGHT          	= 25;

class weapon_sg552 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/sg552/w_sg552.mdl" );
		
		self.m_iDefaultAmmo = SG552_DEFAULT_GIVE;
		g_iCurrentMode = CS16_MODE_UNSCOPE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/sg552/v_sg552.mdl");
		g_Game.PrecacheModel( "models/cs16/sg552/w_sg552.mdl");
		g_Game.PrecacheModel( "models/cs16/sg552/p_sg552.mdl");

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud10.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud11.spr" );
		
		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/rshell.mdl");
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/sg552-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/sg552-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/sg552_clipout.wav");
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/sg552_clipin.wav");
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/sg552_boltpull.wav");
		
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav");
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_rifle.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/sg552-1.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/sg552-2.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/sg552_clipout.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/sg552_clipin.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/sg552_boltpull.wav");
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud10.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud11.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_sg552.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= CS_556_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= SG552_MAX_CLIP;
		info.iSlot		= 3;
		info.iPosition	= 10;
		info.iFlags		= 0;
		info.iWeight	= SG552_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage cssg552( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cssg552.WriteLong( g_ItemRegistry.GetIdForName("weapon_sg552") );
			cssg552.End();
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
		m_pPlayer.pev.maxspeed = 0;
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
		bResult = self.DefaultDeploy ( self.GetV_Model( "models/cs16/sg552/v_sg552.mdl" ), self.GetP_Model( "models/cs16/sg552/p_sg552.mdl" ), SG552_DRAW, "m16" );
		
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
			case 0: self.SendWeaponAnim( SG552_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( SG552_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( SG552_SHOOT3, 0, 0 ); break;
		}
		
		switch ( Math.RandomLong (0, 1) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/sg552-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/sg552-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
		}
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 24;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

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
		CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 18, 13, -5, true, false );

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
				m_pPlayer.pev.maxspeed = 200;
				ToggleZoom( 55 );
				break;
			}
		
			case CS16_MODE_SCOPE:
			{
				g_iCurrentMode = CS16_MODE_UNSCOPE;
				m_pPlayer.pev.maxspeed = 0;
				ToggleZoom( 0 );
				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip == SG552_MAX_CLIP )
			return;
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;

		BaseClass.Reload();
		m_pPlayer.pev.maxspeed = 0;
		g_iCurrentMode = 0;
		ToggleZoom( 0 );
		
		self.DefaultReload( SG552_MAX_CLIP, SG552_RELOAD, 3.325, 0 );
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( SG552_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetSG552Name()
{
	return "weapon_sg552";
}

void RegisterSG552()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetSG552Name(), GetSG552Name() );
	g_ItemRegistry.RegisterWeapon( GetSG552Name(), "cs16", "ammo_cs_556" );
}