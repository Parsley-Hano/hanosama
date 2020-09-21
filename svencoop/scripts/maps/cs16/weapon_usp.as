enum USPAnimation
{
	USP_IDLE = 0,
	USP_SHOOT1,
	USP_SHOOT2,
	USP_SHOOT3,
	USP_SHOOTLAST,
	USP_RELOAD,
	USP_DRAW,
	USP_ADD_SILENCER,
	USP_IDLE_UNSIL,
	USP_SHOOT1_UNSIL,
	USP_SHOOT2_UNSIL,
	USP_SHOOT3_UNSIL,
	USP_SHOOTLAST_UNSIL,
	USP_RELOAD_UNSIL,
	USP_DRAW_UNSIL,
	USP_DETACH_SILENCER
};

const int USP_DEFAULT_GIVE	= 112;
const int USP_MAX_CLIP  	= 12;
const int USP_WEIGHT    	= 5;

class weapon_usp : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	int m_iShotsFired;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/usp/w_usp.mdl" );
		
		self.m_iDefaultAmmo = USP_DEFAULT_GIVE;
		m_iShotsFired = 0;
		g_iCurrentMode = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/usp/v_usp.mdl");
		g_Game.PrecacheModel( "models/cs16/usp/w_usp.mdl");
		g_Game.PrecacheModel( "models/cs16/usp/p_usp.mdl");

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud1.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud4.spr" );
		
		m_iShell = g_Game.PrecacheModel( "models/cs16/shells/pshell.mdl");
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/dryfire_pistol.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/usp_unsil-1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/usp2.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/usp1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/usp_silencer_off.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/usp_silencer_on.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/usp_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/usp_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/usp_slideback.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/usp_sliderelease.wav" );
		
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/cs16/dryfire_pistol.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/usp_unsil-1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/usp2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/usp1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/usp_silencer_off.wav");
		g_SoundSystem.PrecacheSound( "weapons/cs16/usp_silencer_on.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/usp_slideback.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/usp_sliderelease.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/usp_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/usp_clipin.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud4.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_usp.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= CS_45acp_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= USP_MAX_CLIP;
		info.iSlot		= 1;
		info.iPosition	= 7;
		info.iFlags		= 0;
		info.iWeight	= USP_WEIGHT;
		
		return true;
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
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csusp( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csusp.WriteLong( g_ItemRegistry.GetIdForName("weapon_usp") );
			csusp.End();
			return true;
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
			bResult = self.DefaultDeploy( self.GetV_Model( "models/cs16/usp/v_usp.mdl" ), self.GetP_Model( "models/cs16/usp/p_usp.mdl" ), (g_iCurrentMode == CS16_MODE_SILENCER) ? USP_DRAW : USP_DRAW_UNSIL, "onehanded" );
		
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

		m_iShotsFired++;
		if( m_iShotsFired > 1 )
		{
			return;
		}
		
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.11;
		
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
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( g_iCurrentMode == CS16_MODE_SILENCER )
		{
			if( self.m_iClip <= 0 )
			{
				self.SendWeaponAnim( USP_SHOOTLAST, 0, 0 );
			}
			else
			{
				self.SendWeaponAnim( USP_SHOOT1 + Math.RandomLong( 0, 2 ), 0, 0 );
			}
		}
		else if( g_iCurrentMode == CS16_MODE_NOSILENCER )
		{
			if( self.m_iClip <= 0 )
			{
				self.SendWeaponAnim( USP_SHOOTLAST_UNSIL, 0, 0 );
			}
			else
			{
				self.SendWeaponAnim( USP_SHOOT1_UNSIL + Math.RandomLong( 0, 2 ), 0, 0 ); 
			}
		}

		int m_iBulletDamage;
		
		if( g_iCurrentMode == CS16_MODE_SILENCER )
		{
			switch ( Math.RandomLong (0, 1) )
			{
				case 0: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/usp1.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
				case 1: g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/usp2.wav", 0.9, ATTN_NORM, 0, PITCH_NORM ); break;
			}
			m_iBulletDamage = 18;
		}
		else if ( g_iCurrentMode == CS16_MODE_NOSILENCER )
		{
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/usp_unsil-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
			m_iBulletDamage = 21;
		}
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
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
		CS16GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 16, 7, -6, true, false );
       
		//Lefthanded weapon, so invert the Y axis velocity to match.
		vecShellVelocity.y *= 1;
       
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}

	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 3.135f;
		switch ( g_iCurrentMode )
		{
			case CS16_MODE_NOSILENCER:
			{
				g_iCurrentMode = CS16_MODE_SILENCER;
				self.SendWeaponAnim( USP_ADD_SILENCER, 0, 0 );
				break;
			}
			case CS16_MODE_SILENCER:
			{
				g_iCurrentMode = CS16_MODE_NOSILENCER;
				self.SendWeaponAnim( USP_DETACH_SILENCER, 0, 0 );
				break;
			}
		}
		
	}
	
	void Reload()
	{
		if( self.m_iClip == USP_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			return;

		if ( g_iCurrentMode == CS16_MODE_SILENCER )
		{
			self.DefaultReload( USP_MAX_CLIP, USP_RELOAD, 2.73, 0 );
		}
		else
		{
			self.DefaultReload( USP_MAX_CLIP, USP_RELOAD_UNSIL, 2.73, 0 );
		}
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
		{
			return;
		}

		self.SendWeaponAnim( (g_iCurrentMode == CS16_MODE_SILENCER) ? USP_IDLE : USP_IDLE_UNSIL );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
	}
}

string GetUSPName()
{
	return "weapon_usp";
}

void RegisterUSP()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetUSPName(), GetUSPName() );
	g_ItemRegistry.RegisterWeapon( GetUSPName(), "cs16", "ammo_cs_45acp" );
}