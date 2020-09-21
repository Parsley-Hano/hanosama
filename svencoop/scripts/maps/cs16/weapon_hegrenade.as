const int DAMAGE_HEGRENADE			= 150;
const int HEGRENADE_DEFAULT_GIVE	= 5;
const int HEGRENADE_WEIGHT			= 5;
const int HEGRENADE_MAX_CARRY		= 10;

enum HEGRENADEAnimation 
{
	HEGRENADE_IDLE = 0,
	HEGRENADE_PULLPIN,
	HEGRENADE_THROW,
	HEGRENADE_DEPLOY
};

class weapon_hegrenade : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	float m_flStartThrow;
	float m_flReleaseThrow;
	float time;
	CBaseEntity@ pGrenade;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/cs16/hegrenade/w_hegrenade.mdl" );
		self.pev.dmg = DAMAGE_HEGRENADE;
		self.m_iDefaultAmmo = HEGRENADE_DEFAULT_GIVE;

		self.KeyValue( "m_flCustomRespawnTime", 1 ); //fgsfds

		m_flReleaseThrow = -1.0f;
		time = 0;
		m_flStartThrow = 0;
		
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/cs16/hegrenade/w_hegrenade.mdl" );
		g_Game.PrecacheModel( "models/cs16/hegrenade/v_hegrenade.mdl" );
		g_Game.PrecacheModel( "models/cs16/hegrenade/p_hegrenade.mdl" );

		//Precache the Sprites as well
		g_Game.PrecacheModel( "sprites/cs16/640hud7.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud3.spr" );
		g_Game.PrecacheModel( "sprites/cs16/640hud6.spr" );

		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/pinpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/cs16/ct_fireinhole.wav" );

		g_SoundSystem.PrecacheSound( "weapons/cs16/pinpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/cs16/ct_fireinhole.wav" );

		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud7.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud3.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/640hud6.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/crosshairs.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "cs16/weapon_hegrenade.txt" );
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage cshegrenade( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				cshegrenade.WriteLong( g_ItemRegistry.GetIdForName("weapon_hegrenade") );
			cshegrenade.End();
			return true;
		}

		return false;
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= HEGRENADE_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= WEAPON_NOCLIP;
		info.iSlot  	= 4;
		info.iPosition	= 6;
		info.iWeight	= HEGRENADE_WEIGHT;
		info.iFlags 	= ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;

		return true;
	}

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}

	bool Deploy()
	{
		bool bResult;
		{
			m_flReleaseThrow = -1;
			bResult = self.DefaultDeploy( self.GetV_Model( "models/cs16/hegrenade/v_hegrenade.mdl" ), self.GetP_Model( "models/cs16/hegrenade/p_hegrenade.mdl" ), HEGRENADE_DEPLOY, "crowbar" );

			float deployTime = 0.7;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}

	//fgsfds
	void Materialize()
	{
		BaseClass.Materialize();
		
		SetTouch( TouchFunction( CustomTouch ) );
	}

	void CustomTouch( CBaseEntity@ pOther )
	{
		if( !pOther.IsPlayer() )
			return;

		CBasePlayer@ pPlayer = cast<CBasePlayer@> (pOther);

		if( pPlayer.HasNamedPlayerItem( "weapon_hegrenade" ) !is null ) 
		{
			if( pPlayer.GiveAmmo( HEGRENADE_DEFAULT_GIVE, "weapon_hegrenade", HEGRENADE_MAX_CARRY ) != -1 )
			{
				self.CheckRespawn();
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
				g_EntityFuncs.Remove( self );
			}
			return;
		}
		else if( pPlayer.AddPlayerItem( self ) != APIR_NotAdded )
		{
			self.AttachToPlayer( pPlayer );
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
		}
	}
	//fgsfds

	bool CanHolster()
	{
		// can only holster hand grenades when not primed!
		return m_flStartThrow == 0;
	}

	bool CanDeploy()
	{
		return m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType) != 0;
	}

	void DestroyThink()
	{
		self.DestroyItem();
	}

	void Holster( int skiplocal )
	{
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5f;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5f;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.5f;

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
		{
			m_pPlayer.pev.weapons &= ~( 0 << g_ItemRegistry.GetIdForName("weapon_hegrenade") );
			SetThink( ThinkFunction( DestroyThink ) );
			self.pev.nextthink = g_Engine.time + 0.1;
		}

		m_flStartThrow = 0;
		m_flReleaseThrow = -1.0f;
		BaseClass.Holster( skiplocal );
	}

	void PrimaryAttack()
	{
		if( m_flStartThrow == 0 && m_pPlayer.m_rgAmmo ( self.m_iPrimaryAmmoType ) > 0 )
		{
			m_flReleaseThrow = 0;
			m_flStartThrow = g_Engine.time;
		
			self.SendWeaponAnim( HEGRENADE_PULLPIN );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.75;
		}
	}

	void WeaponIdle()
	{
		if ( m_flReleaseThrow == 0 && m_flStartThrow > 0.0 )
			m_flReleaseThrow = g_Engine.time;

		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if ( m_flStartThrow > 0.0 )
		{
			Vector angThrow = m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle;

			if ( angThrow.x < 0 )
				angThrow.x = -10 + angThrow.x * ( ( 90 - 10 ) / 90.0 );
			else
				angThrow.x = -10 + angThrow.x * ( ( 90 + 10 ) / 90.0 );

			float flVel = ( 90.0f - angThrow.x ) * 6;

			if ( flVel > 750.0f )
				flVel = 750.0f;

			Math.MakeVectors ( angThrow );

			Vector vecSrc = m_pPlayer.pev.origin + m_pPlayer.pev.view_ofs + g_Engine.v_forward * 16;
			Vector vecThrow = g_Engine.v_forward * flVel + m_pPlayer.pev.velocity;

			// always explode 2 seconds after the grenade was thrown
			time = m_flStartThrow - g_Engine.time + 2.0;
			if( time < 2.0 )
				time = 2.0;

			@pGrenade = g_EntityFuncs.ShootTimed( m_pPlayer.pev, vecSrc, vecThrow, time );
			g_EntityFuncs.SetModel( pGrenade, "models/cs16/hegrenade/w_hegrenade.mdl" );

			self.SendWeaponAnim( HEGRENADE_THROW );

			if( m_flReleaseThrow < g_Engine.time )
				g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/cs16/ct_fireinhole.wav", VOL_NORM, ATTN_NORM );

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

			m_flReleaseThrow = g_Engine.time;
			m_flStartThrow = 0;
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 1.31;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.75;

			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );

			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			{
				// just threw last grenade
				// set attack times in the future, and weapon idle in the future so we can see the whole throw
				// animation, weapon idle will automatically retire the weapon for us.
				self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.75;
			}
			return;
		}
		else if( m_flReleaseThrow > 0 )
		{
			m_flStartThrow = 0;

			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
			{
				self.SendWeaponAnim( HEGRENADE_DEPLOY );
			}
			else
			{
				self.RetireWeapon();
				return;
			}

			self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			m_flReleaseThrow = -1;
			return;
		}

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			int iAnim;
			float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
			if( flRand <= 1.0 )
			{
				iAnim = HEGRENADE_IDLE;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			}
			else
			{
				iAnim = HEGRENADE_IDLE;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 2.5;
			}

			self.SendWeaponAnim( iAnim );
		}
	}
}

string GetHEGRENADEName()
{
	return "weapon_hegrenade";
}

void RegisterHEGRENADE()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetHEGRENADEName(), GetHEGRENADEName() );
	g_ItemRegistry.RegisterWeapon( GetHEGRENADEName(), "cs16", "weapon_hegrenade" );
	g_ItemRegistry.RegisterItem( GetHEGRENADEName(), "cs16", "weapon_hegrenade" );
}