// Afraid of Monsters: Director's Cut Script
// Misc Script: Glock Ammo
// Author: Zorbos

const int AMMO_GLOCK_GIVE = 20;
const int AMMO_GLOCK_MAX_CARRY = 130;

class ammo_dcglock : ScriptBasePlayerAmmoEntity
{
	private bool bSurvivalEnabled = g_EngineFuncs.CVarGetFloat("mp_survival_starton") == 1 && g_EngineFuncs.CVarGetFloat("mp_survival_supported") == 1;
	
	void Spawn()
	{ 
		Precache();

		if( self.SetupModel() == false )
		{
			g_EntityFuncs.SetModel( self, "models/AoMDC/items/w_glockclip.mdl" );
		}
		else	//Custom model
			g_EntityFuncs.SetModel( self, self.pev.model );

		BaseClass.Spawn();
		
		if(bSurvivalEnabled)
			self.pev.spawnflags = 1280;// +USE only AND Never Respawn
		else
			self.pev.spawnflags = 256; // +USE only
		
		// Makes it slightly easier to pickup
		g_EntityFuncs.SetSize(self.pev, Vector( -4, -4, -1 ), Vector( 4, 4, 1 ));
	}
	
	void Precache()
	{
		BaseClass.Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel("models/AoMDC/items/w_glockclip.mdl");
		else	//Custom model
			g_Game.PrecacheModel( self.pev.model );

		g_SoundSystem.PrecacheSound("items/9mmclip1.wav");
	}
	
	bool AddAmmo( CBaseEntity@ pOther ) 
	{ 
		if (pOther.GiveAmmo( AMMO_GLOCK_GIVE, "9mm", AMMO_GLOCK_MAX_CARRY ) != -1)
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
			return true;
		}
		return false;
	}
}