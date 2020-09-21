CScheduledFunction@ g_pThinkFunc = null;

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");
  g_Module.ScriptInfo.SetMinimumAdminLevel(ADMIN_YES);
}

const string nope = '%';

void MapInit() {
  if (g_pThinkFunc !is null) 
    g_Scheduler.RemoveTimer(g_pThinkFunc);
  
  @g_pThinkFunc = g_Scheduler.SetInterval("NamePolice", 0.1f);
}

void NamePolice() {
  for (int i = 1; i <= g_Engine.maxClients; ++i) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    
    if (pPlayer !is null && g_PlayerFuncs.AdminLevel(pPlayer) < ADMIN_YES && string(pPlayer.pev.netname).findFirstOf(nope) >= 0) {
      g_EngineFuncs.ServerCommand("kick \"#" + g_EngineFuncs.GetPlayerUserId(pPlayer.edict()) + "\" \"Protected nickname. Change your nick.\"\n");
      g_EngineFuncs.ServerExecute();
    }
  }
}
