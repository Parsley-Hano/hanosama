enum AWPAnimation
{
	AWP_IDLE1 = 0,
	AWP_SHOOT1,
	AWP_SHOOT2,
	AWP_SHOOT3,
	AWP_RELOAD,
	AWP_DRAW
};

const int AWP_DEFAULT_GIVE		= 40;
const int AWP_MAX_CARRY			= 30;
const int AWP_MAX_CLIP			= 10;
const int AWP_WEIGHT			= 30;

class weapon_awp : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/awp/w_awp.mdl" );

		self.m_iDefaultAmmo = AWP_DEFAULT_GIVE;
		g_iCurrentMode = CS16_MODE_NOSCOPE;

		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/awp/v_awp.mdl" );
		g_Game.PrecacheModel( "models/cs16/awp/w_awp.mdl" );
		g_Game.PrecacheModel( "models/cs16/awp/p_awp.mdl" );
		
		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/rshell_big.mdl" );

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud2.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud5.spr" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/awp1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/boltdown.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/boltpull1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/awp_deploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/boltup.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/awp_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/awp_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/zoom.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/awp_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/awp_clipin.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/awp1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/boltup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/boltdown.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/boltpull1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/zoom.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud2.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud5.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs16/ch_sniper.spr");
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_awp.txt");
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= AWP_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= AWP_MAX_CLIP;
		info.iSlot		= 5;
		info.iPosition	= 6;
		info.iFlags		= 0;
		info.iWeight	= AWP_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csawp( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csawp.WriteLong( g_ItemRegistry.GetIdForName("weapon_awp") );
			csawp.End();
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
		SetThink( null );
		ToggleZoom( 0 );

		BaseClass.Holster( skipLocal );
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
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/cs16/awp/v_awp.mdl" ), self.GetP_Model( "models/cs16/awp/p_awp.mdl" ), AWP_DRAW, "sniper" );
		
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
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.2f;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 1.2f;
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( AWP_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( AWP_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( AWP_SHOOT3, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/awp1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 85;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, ( g_iCurrentMode == CS16_MODE_NOSCOPE ) ? VECTOR_CONE_8DEGREES : g_vecZero, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		
		m_pPlayer.pev.punchangle.x = Math.RandomLong( -5, -3 );

		//self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.15f;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir;
		
		vecDir = (g_iCurrentMode == CS16_MODE_NOSCOPE) ? 
					vecAiming + x * VECTOR_CONE_8DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_8DEGREES.y * g_Engine.v_up : 
					vecAiming + x * VECTOR_CONE_1DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_1DEGREES.y * g_Engine.v_up;

		Vector vecEnd = vecSrc + vecDir * 8192;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

		SetThink( ThinkFunction( EjectBrassThink ) );
		self.pev.nextthink = WeaponTimeBase() + 0.68;
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() == true )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
			}
		}
	}

	void EjectBrassThink()
	{
		Vector vecShellVelocity, vecShellOrigin;
		//The last 3 parameters are unique for each weapon (this should be using an attachment in the model to get the correct position, but most models don't have that).
		CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 13, 9, -8, true, false );
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;

		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.3f;
		switch ( g_iCurrentMode )
		{
			case CS16_MODE_NOSCOPE:
			{
				g_iCurrentMode = CS16_MODE_SCOPED;
				m_pPlayer.pev.maxspeed = 150;
				ToggleZoom( 40 );
				m_pPlayer.m_szAnimExtension = "sniperscope";
				break;
			}
		
			case CS16_MODE_SCOPED:
			{
				g_iCurrentMode = CS16_MODE_MORESCOPE;
				m_pPlayer.pev.maxspeed = 150;
				ToggleZoom( 10 );
				m_pPlayer.m_szAnimExtension = "sniperscope";
				break;
			}
			
			case CS16_MODE_MORESCOPE:
			{
				g_iCurrentMode = CS16_MODE_NOSCOPE;
				m_pPlayer.pev.maxspeed = 0;
				ToggleZoom( 0 );
				m_pPlayer.m_szAnimExtension = "sniper";
				break;
			}
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, "weapons/cs16/zoom.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
	}
	
	void Reload()
	{
		if( self.m_iClip == AWP_MAX_CLIP ) //Can't reload if the magazine is 10
			return;
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 ) //Can't reload if the reserve ammo is 0
			return;

		m_pPlayer.m_szAnimExtension = "sniper";
		m_pPlayer.pev.maxspeed = 0;
		BaseClass.Reload();
		g_iCurrentMode = 0;
		ToggleZoom( 0 );

		self.DefaultReload( AWP_MAX_CLIP, AWP_RELOAD, 2.94, 0 );
	}
	
	void WeaponIdle()
	{

		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( AWP_IDLE1 );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetAWPName()
{
	return "weapon_awp";
}

void RegisterAWP()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetAWPName(), GetAWPName() );
	g_ItemRegistry.RegisterWeapon( GetAWPName(), "cs16", "ammo_cs_338lapua" );
}