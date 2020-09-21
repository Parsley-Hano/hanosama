enum M4A1Animation
{
	M4A1_IDLE = 0,
	M4A1_SHOOT1,
	M4A1_SHOOT2,
	M4A1_SHOOT3,
	M4A1_RELOAD,
	M4A1_DRAW,
	M4A1_ADD_SILENCER,
	M4A1_IDLE_UNSIL,
	M4A1_SHOOT1_UNSIL,
	M4A1_SHOOT2_UNSIL,
	M4A1_SHOOT3_UNSIL,
	M4A1_RELOAD_UNSIL,
	M4A1_DRAW_UNSIL,
	M4A1_DETACH_SILENCER
};

const int M4A1_DEFAULT_GIVE 	= 120;
const int M4A1_MAX_CLIP     	= 30;
const int M4A1_WEIGHT       	= 25;

class weapon_m4a1 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/m4a1/w_m4a1.mdl" );
		
		self.m_iDefaultAmmo = M4A1_DEFAULT_GIVE;
		g_iCurrentMode = CS16_MODE_NOSILENCER;
		
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/m4a1/v_m4a1.mdl");
		g_Game.PrecacheModel( "models/cs16/m4a1/w_m4a1.mdl");
		g_Game.PrecacheModel( "models/cs16/m4a1/p_m4a1.mdl");

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud2.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud5.spr" );
		
		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/rshell.mdl");
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_rifle.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/m4a1_unsil-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/m4a1_unsil-2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/m4a1-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/m4a1_silencer_off.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/m4a1_silencer_on.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/m4a1_deploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/m4a1_clipout.wav");
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/m4a1_clipin.wav");
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/m4a1_boltpull.wav");
		
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav");
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_rifle.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/m4a1_unsil-1.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/m4a1_unsil-2.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/m4a1-1.wav");
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/m4a1_silencer_off.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/m4a1_silencer_on.wav");
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/m4a1_deploy.wav");
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/m4a1_clipout.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/m4a1_clipin.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/m4a1_boltpull.wav");
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud2.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud5.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_m4a1.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= CS_556_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= M4A1_MAX_CLIP;
		info.iSlot		= 3;
		info.iPosition	= 6;
		info.iFlags		= 0;
		info.iWeight	= M4A1_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csm4a1( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csm4a1.WriteLong( g_ItemRegistry.GetIdForName("weapon_m4a1") );
			csm4a1.End();
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
		return g_Engine.time; //g_weaponFuncs.WeaponTimeBase();
	}
	
	bool Deploy()
	{//this fixes the draw anim getting cut off by the idle animation
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/cs16/m4a1/v_m4a1.mdl" ), self.GetP_Model( "models/cs16/m4a1/p_m4a1.mdl" ), (g_iCurrentMode == CS16_MODE_SILENCER) ? M4A1_DRAW : M4A1_DRAW_UNSIL, "m16" );
			
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
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.085;
		
		if( g_iCurrentMode == CS16_MODE_NOSILENCER )
		{
			m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
			m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		}
		else if ( g_iCurrentMode == CS16_MODE_SILENCER )
		{
			m_pPlayer.m_iWeaponVolume = 0;
			m_pPlayer.m_iWeaponFlash = 0;
		}
		
		--self.m_iClip;
		
		self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		self.SendWeaponAnim( (g_iCurrentMode == CS16_MODE_SILENCER) ? M4A1_SHOOT1 + Math.RandomLong( 0, 2 ) : M4A1_SHOOT1_UNSIL + Math.RandomLong( 0, 2 ), 0, 0 );

		int m_iBulletDamage;
		
		if ( g_iCurrentMode == CS16_MODE_NOSILENCER )
		{
			switch( Math.RandomLong( 0, 1 ) )
			{
				case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/m4a1_unsil-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
				case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/m4a1_unsil-2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			}
			m_iBulletDamage = 24;
		}
		else if ( g_iCurrentMode == CS16_MODE_SILENCER )
		{
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/m4a1-1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM );
			m_iBulletDamage = 23;
		}
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
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
		CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 15, 10, -5, true, false );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}

	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 2.0f;
		switch ( g_iCurrentMode )
		{
			case CS16_MODE_NOSILENCER:
			{
				g_iCurrentMode = CS16_MODE_SILENCER;
				self.SendWeaponAnim( M4A1_ADD_SILENCER, 0, 0 );
				break; 
			}
			case CS16_MODE_SILENCER:
			{
				g_iCurrentMode = CS16_MODE_NOSILENCER;
				self.SendWeaponAnim( M4A1_DETACH_SILENCER, 0, 0 );
				break;
			}
		}
	}
	void Reload()
	{
		if( self.m_iClip == M4A1_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;

		self.DefaultReload( M4A1_MAX_CLIP, (g_iCurrentMode == CS16_MODE_SILENCER) ? M4A1_RELOAD : M4A1_RELOAD_UNSIL, 3.08, 0 );
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		
		self.SendWeaponAnim( (g_iCurrentMode == CS16_MODE_SILENCER) ? M4A1_IDLE : M4A1_IDLE_UNSIL );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetM4A1Name()
{
	return "weapon_m4a1";
}

void RegisterM4A1()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetM4A1Name(), GetM4A1Name() );
	g_ItemRegistry.RegisterWeapon( GetM4A1Name(), "cs16", "ammo_cs_556" );
}