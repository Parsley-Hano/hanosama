enum SG550Animation
{
	SG550_IDLE = 0,
	SG550_SHOOT1,
	SG550_SHOOT2,
	SG550_RELOAD,
	SG550_DRAW
};

const int SG550_DEFAULT_GIVE    	= 120;
const int SG550_MAX_CLIP        	= 30;
const int SG550_WEIGHT          	= 20;

class weapon_sg550 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/sg550/w_sg550.mdl" );
		
		self.m_iDefaultAmmo = SG550_DEFAULT_GIVE;
		g_iCurrentMode = CS16_MODE_NOSCOPE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/sg550/v_sg550.mdl");
		g_Game.PrecacheModel( "models/cs16/sg550/w_sg550.mdl");
		g_Game.PrecacheModel( "models/cs16/sg550/p_sg550.mdl");

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud14.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud15.spr" );
		
		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/rshell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/sg550-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/sg550_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/sg550_boltpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/sg550_clipin.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_rifle.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/sg550_clipout.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/sg550_clipin.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/sg550_boltpull.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/sg550-1.wav");
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud14.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud15.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_sg550.txt" );
		
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= CS_556_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= SG550_MAX_CLIP;
		info.iSlot		= 5;
		info.iPosition	= 9;
		info.iFlags		= 0;
		info.iWeight	= SG550_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage cssg550( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cssg550.WriteLong( g_ItemRegistry.GetIdForName("weapon_sg550") );
			cssg550.End();
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

		g_iCurrentMode = CS16_MODE_NOSCOPE;
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
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/cs16/sg550/v_sg550.mdl" ), self.GetP_Model( "models/cs16/sg550/p_sg550.mdl" ), SG550_DRAW, "m16" );
		
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
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.25;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.25f;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( SG550_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( SG550_SHOOT2, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/sg550-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 52;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, ( g_iCurrentMode == CS16_MODE_NOSCOPE ) ? VECTOR_CONE_5DEGREES : VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
			
		m_pPlayer.pev.punchangle.x = Math.RandomLong( -4, -1 );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir;
		
		vecDir = ( g_iCurrentMode == CS16_MODE_NOSCOPE ) ? 
					vecAiming + x * VECTOR_CONE_5DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_5DEGREES.y * g_Engine.v_up : 
					vecAiming + x * VECTOR_CONE_1DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_1DEGREES.y * g_Engine.v_up;

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
		CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 17, 11, -8, true, false );
	   
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
	   
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.3f;
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1f;
		switch ( g_iCurrentMode )
		{
			case CS16_MODE_NOSCOPE:
			{
				g_iCurrentMode = CS16_MODE_SCOPED;
				m_pPlayer.pev.maxspeed = 150;
				ToggleZoom( 40 );
				break;
			}
		
			case CS16_MODE_SCOPED:
			{
				g_iCurrentMode = CS16_MODE_MORESCOPE;
				m_pPlayer.pev.maxspeed = 150;
				ToggleZoom( 10 );
				break;
			}
			
			case CS16_MODE_MORESCOPE:
			{
				g_iCurrentMode = CS16_MODE_NOSCOPE;
				m_pPlayer.pev.maxspeed = 0;
				ToggleZoom( 0 );
				break;
			}
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, "weapons/cs16/zoom.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
	}
	
	void Reload()
	{
		if( self.m_iClip == SG550_MAX_CLIP )
			return;
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;

		BaseClass.Reload();
		m_pPlayer.pev.maxspeed = 0;
		g_iCurrentMode = 0;
		ToggleZoom( 0 );
		self.DefaultReload( SG550_MAX_CLIP, SG550_RELOAD, 3.82, 0 );
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( SG550_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetSG550Name()
{
	return "weapon_sg550";
}

void RegisterSG550()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetSG550Name(), GetSG550Name() );
	g_ItemRegistry.RegisterWeapon( GetSG550Name(), "cs16", "ammo_cs_556" );
}