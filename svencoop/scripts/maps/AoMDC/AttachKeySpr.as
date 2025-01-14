// Afraid of Monsters: Director's Cut Script
// Misc Script: item_inventory Sprite Manager
// Author: Zorbos

void AttachPlayerKeySprite(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{	
	if(pActivator is null || !pActivator.IsPlayer())
		return;
	
	CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
	
	pPlayer.pev.targetname = "pKey_holder";
	
	CBaseEntity@ pSprite = null, pAttach = null;
	
	string pSprOffset = "0 0 44";
	string pOrigin = "" + pPlayer.pev.origin.x + " " + 
							 pPlayer.pev.origin.y + " " + 
							 pPlayer.pev.origin.z;
	

	dictionary@ pAttachValues = {{"targetname", "pKey_spr_attach"}, {"origin", pOrigin}, {"target", "pKey_spr"}, {"offset", pSprOffset}, {"copypointer", "pKey_holder"}, {"spawnflags", "1011"}};
	@pAttach = g_EntityFuncs.CreateEntity("trigger_setorigin", @pAttachValues, true);

	if(pAttach !is null)
	{
		dictionary@ pSprValues = {{"targetname", "pKey_spr"}, {"origin", pOrigin}, {"model", "sprites/AoMDC/keyicon.spr"}, {"framerate", "10"}, {"rendermode", "5"}, {"renderamt", "255"}, {"scale", "0.12"}, {"spawnflags", "1"}};
		@pSprite = g_EntityFuncs.CreateEntity("env_sprite", @pSprValues, true);
		g_EntityFuncs.FireTargets("pKey_spr_attach", null, null, USE_ON, 0, 0);
	}
	
	RemoveDroppedKeySprite();
}

void AttachDroppedKeySprite()
{
	edict_t@ pEdict = null;
	CBaseEntity@ pEntity = null, pSprite = null, pAttach = null;
	
	for(int pIndex = 0; pIndex < g_Engine.maxEntities; ++pIndex)
	{
		@pEdict = @g_EntityFuncs.IndexEnt(pIndex);
		@pEntity = g_EntityFuncs.Instance(pEdict);

		if(pEntity !is null)
		{
			if(pEntity.pev.targetname == "pKey" && pEntity.GetClassname() == "item_inventory")
			{	
				string pSprOffset = "0 0 14";
				string pOrigin = "" + pEntity.pev.origin.x + " " + 
									  pEntity.pev.origin.y + " " + 
									  pEntity.pev.origin.z;
				
				dictionary@ pAttachValues = {{"targetname", "pKey_droppedspr_attach"}, {"origin", pOrigin}, {"target", "pKey_droppedspr"}, {"offset", pSprOffset}, {"copypointer", "pKey"}, {"spawnflags", "1011"}};
				@pAttach = g_EntityFuncs.CreateEntity("trigger_setorigin", @pAttachValues, true);
				
				if(pAttach !is null)
				{
					dictionary@ pSprValues = {{"targetname", "pKey_droppedspr"}, {"origin", pOrigin}, {"model", "sprites/AoMDC/keyicon.spr"}, {"framerate", "10"}, {"rendermode", "5"}, {"renderamt", "255"}, {"scale", "0.13"}, {"spawnflags", "1"}};	
					@pSprite = g_EntityFuncs.CreateEntity("env_sprite", @pSprValues, true);
					g_EntityFuncs.FireTargets("pKey_droppedspr_attach", null, null, USE_ON, 0, 0);
				}
			}
		}
	}
}

void RemoveDroppedKeySprite()
{
	edict_t@ pEdict = null;
	CBaseEntity@ pEntity = null;
	
	for(int pIndex = 0; pIndex < g_Engine.maxEntities; ++pIndex)
	{
		@pEdict = @g_EntityFuncs.IndexEnt(pIndex);
		@pEntity = g_EntityFuncs.Instance(pEdict);
		
		if(pEntity !is null)
			if(pEntity.pev.targetname == "pKey_droppedspr" || pEntity.pev.targetname == "pKey_droppedspr_attach")
				g_EntityFuncs.Remove(pEntity);
	}
}

void KeyDropped(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	if(pActivator is null || !pActivator.IsPlayer())
		return;
		
	CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);	
	pPlayer.pev.targetname = ""; // Reset the targetname

	RemovePlayerKeySprite();
	AttachDroppedKeySprite();
}

void RemovePlayerKeySprite()
{
	edict_t@ pEdict = null;
	CBaseEntity@ pEntity = null;
	
	for(int pIndex = 0; pIndex < g_Engine.maxEntities; ++pIndex)
	{
		@pEdict = @g_EntityFuncs.IndexEnt(pIndex);
		@pEntity = g_EntityFuncs.Instance(pEdict);
		
		if(pEntity !is null)
			if(pEntity.pev.targetname == "pKey_spr" || pEntity.pev.targetname == "pKey_spr_attach")
				g_EntityFuncs.Remove(pEntity);
	}
}

void AttachPlayerRopeSprite(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{	
	if(pActivator is null || !pActivator.IsPlayer())
		return;
	
	CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
	
	pPlayer.pev.targetname = "pRope_holder";
	
	CBaseEntity@ pSprite = null, pAttach = null;
	
	string pSprOffset = "0 0 48";
	string pOrigin = "" + pPlayer.pev.origin.x + " " + 
							 pPlayer.pev.origin.y + " " + 
							 pPlayer.pev.origin.z;
	

	dictionary@ pAttachValues = {{"targetname", "pRope_spr_attach"}, {"origin", pOrigin}, {"target", "pRope_spr"}, {"offset", pSprOffset}, {"copypointer", "pRope_holder"}, {"spawnflags", "1011"}};
	@pAttach = g_EntityFuncs.CreateEntity("trigger_setorigin", @pAttachValues, true);

	if(pAttach !is null)
	{
		dictionary@ pSprValues = {{"targetname", "pRope_spr"}, {"origin", pOrigin}, {"model", "sprites/AoMDC/ropeicon.spr"}, {"framerate", "10"}, {"rendermode", "5"}, {"renderamt", "255"}, {"scale", "0.14"}, {"spawnflags", "1"}};
		@pSprite = g_EntityFuncs.CreateEntity("env_sprite", @pSprValues, true);
		g_EntityFuncs.FireTargets("pRope_spr_attach", null, null, USE_ON, 0, 0);
	}
	
	RemoveDroppedRopeSprite();
}

void AttachDroppedRopeSprite()
{
	edict_t@ pEdict = null;
	CBaseEntity@ pEntity = null, pSprite = null, pAttach = null;
	
	for(int pIndex = 0; pIndex < g_Engine.maxEntities; ++pIndex)
	{
		@pEdict = @g_EntityFuncs.IndexEnt(pIndex);
		@pEntity = g_EntityFuncs.Instance(pEdict);

		if(pEntity !is null)
		{
			if(pEntity.pev.targetname == "pRope" && pEntity.GetClassname() == "item_inventory")
			{	
				string pSprOffset = "0 0 22";
				string pOrigin = "" + pEntity.pev.origin.x + " " + 
									  pEntity.pev.origin.y + " " + 
									  pEntity.pev.origin.z;
				
				dictionary@ pAttachValues = {{"targetname", "pRope_droppedspr_attach"}, {"origin", pOrigin}, {"target", "pRope_droppedspr"}, {"offset", pSprOffset}, {"copypointer", "pRope"}, {"spawnflags", "1011"}};
				@pAttach = g_EntityFuncs.CreateEntity("trigger_setorigin", @pAttachValues, true);
				
				if(pAttach !is null)
				{
					dictionary@ pSprValues = {{"targetname", "pRope_droppedspr"}, {"origin", pOrigin}, {"model", "sprites/AoMDC/ropeicon.spr"}, {"framerate", "10"}, {"rendermode", "5"}, {"renderamt", "255"}, {"scale", "0.18"}, {"spawnflags", "1"}};	
					@pSprite = g_EntityFuncs.CreateEntity("env_sprite", @pSprValues, true);
					g_EntityFuncs.FireTargets("pRope_droppedspr_attach", null, null, USE_ON, 0, 0);
				}
			}
		}
	}
}

void RemoveDroppedRopeSprite()
{
	edict_t@ pEdict = null;
	CBaseEntity@ pEntity = null;
	
	for(int pIndex = 0; pIndex < g_Engine.maxEntities; ++pIndex)
	{
		@pEdict = @g_EntityFuncs.IndexEnt(pIndex);
		@pEntity = g_EntityFuncs.Instance(pEdict);
		
		if(pEntity !is null)
			if(pEntity.pev.targetname == "pRope_droppedspr" || pEntity.pev.targetname == "pRope_droppedspr_attach")
				g_EntityFuncs.Remove(pEntity);
	}
}

void RopeDropped(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	if(pActivator is null || !pActivator.IsPlayer())
		return;
		
	CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);	
	pPlayer.pev.targetname = ""; // Reset the targetname

	RemovePlayerRopeSprite();
	AttachDroppedRopeSprite();
}

void RemovePlayerRopeSprite()
{
	edict_t@ pEdict = null;
	CBaseEntity@ pEntity = null;
	
	for(int pIndex = 0; pIndex < g_Engine.maxEntities; ++pIndex)
	{
		@pEdict = @g_EntityFuncs.IndexEnt(pIndex);
		@pEntity = g_EntityFuncs.Instance(pEdict);
		
		if(pEntity !is null)
			if(pEntity.pev.targetname == "pRope_spr" || pEntity.pev.targetname == "pRope_spr_attach")
				g_EntityFuncs.Remove(pEntity);
	}
}