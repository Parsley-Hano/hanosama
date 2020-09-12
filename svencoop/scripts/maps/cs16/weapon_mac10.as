enum MAC10Animation
{
	MAC10_IDLE = 0,
	MAC10_RELOAD,
	MAC10_DRAW,
	MAC10_SHOOT1,
	MAC10_SHOOT2,
	MAC10_SHOOT3
};

const int MAC10_DEFAULT_GIVE    	= 130;
const int MAC10_MAX_CLIP        	= 30;
const int MAC10_WEIGHT          	= 25;

class weapon_mac10 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/mac10/w_mac10.mdl" );
		
		self.m_iDefaultAmmo = MAC10_DEFAULT_GIVE;
		
		self.FallInit();
	}
						
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/mac10/v_mac10.mdl" );
		g_Game.PrecacheModel( "models/cs16/mac10/w_mac10.mdl" );
		g_Game.PrecacheModel( "models/cs16/mac10/p_mac10.mdl" );

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud14.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud15.spr" );
		
		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/pshell.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/mac10-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/mac10_boltpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/mac10_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/mac10_clipout.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_rifle.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/mac10-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/mac10_boltpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/mac10_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/mac10_clipout.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/items/cliprelease1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud14.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud15.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_mac10.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= CS_45acp_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= MAC10_MAX_CLIP;
		info.iSlot		= 2;
		info.iPosition	= 6;
		info.iFlags		= 0;
		info.iWeight	= MAC10_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csmac10( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csmac10.WriteLong( g_ItemRegistry.GetIdForName("weapon_mac10") );
			csmac10.End();
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
			bResult = self.DefaultDeploy ( self.GetV_Model( "models/cs16/mac10/v_mac10.mdl" ), self.GetP_Model( "models/cs16/mac10/p_mac10.mdl" ), MAC10_DRAW, "onehanded" );
		
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
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.07f;
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;

		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) )
		{
			case 0: self.SendWeaponAnim( MAC10_SHOOT1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( MAC10_SHOOT2, 0, 0 ); break;
			case 2: self.SendWeaponAnim( MAC10_SHOOT3, 0, 0 ); break;
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/mac10-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 17;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

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
		CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 13, 7, -5, true, false );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip == MAC10_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;
		
		self.DefaultReload( MAC10_MAX_CLIP, MAC10_RELOAD, 3.17, 0 );
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( MAC10_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetMAC10Name()
{
	return "weapon_mac10";
}

void RegisterMAC10()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetMAC10Name(), GetMAC10Name() );
	g_ItemRegistry.RegisterWeapon( GetMAC10Name(), "cs16", "ammo_cs_45acp" );
}