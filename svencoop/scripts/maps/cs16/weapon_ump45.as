enum UMP45Animation
{
	UMP45_IDLE = 0,
	UMP45_RELOAD,
	UMP45_DRAW,
	UMP45_SHOOT1,
	UMP45_SHOOT2,
	UMP45_SHOOT3
};

const int UMP45_DEFAULT_GIVE    	= 125;
const int UMP45_MAX_CLIP        	= 25;
const int UMP45_WEIGHT          	= 25;

class weapon_ump45 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/ump45/w_ump45.mdl" );
		
		self.m_iDefaultAmmo = UMP45_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/ump45/v_ump45.mdl" );
		g_Game.PrecacheModel( "models/cs16/ump45/w_ump45.mdl" );
		g_Game.PrecacheModel( "models/cs16/ump45/p_ump45.mdl" );

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud16.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		
		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/pshell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/ump45-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/ump45_boltslap.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/ump45_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/ump45_clipout.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/ump45-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/ump45_boltslap.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/ump45_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/ump45_clipout.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud16.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_ump45.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= CS_45acp_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= UMP45_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 9;
		info.iFlags		= 0;
		info.iWeight	= UMP45_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer ( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csump( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csump.WriteLong( g_ItemRegistry.GetIdForName("weapon_ump45") );
			csump.End();
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
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/cs16/ump45/v_ump45.mdl" ), self.GetP_Model( "models/cs16/ump45/p_ump45.mdl" ), UMP45_DRAW, "mp5" );
		
			float deployTime = 1;
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
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.099;
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( UMP45_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( UMP45_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( UMP45_SHOOT3, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/ump45-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 21;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

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
		CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 7, -6, true, false );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip == UMP45_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;
			
		self.DefaultReload( UMP45_MAX_CLIP, UMP45_RELOAD, 3.51, 0 );
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( UMP45_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetUMP45Name()
{
	return "weapon_ump45";
}

void RegisterUMP45()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetUMP45Name(), GetUMP45Name() );
	g_ItemRegistry.RegisterWeapon( GetUMP45Name(), "cs16", "ammo_cs_45acp" );
}