void KillInRadius(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue) {
	@pCaller = g_EntityFuncs.FindEntityByTargetname(null, "sil_kill_train");
	CBaseEntity@ ent = null;
	while ( ( @ent = g_EntityFuncs.FindEntityByClassname(ent, "func_train") ) !is null ) {
		Vector o = ent.pev.origin - pCaller.pev.origin;
		if (o.Length() <= 64) {
			//g_Game.AlertMessage( at_console, "Killing a func_train!\n");
			g_EntityFuncs.Remove(ent);
		}
	}
}
