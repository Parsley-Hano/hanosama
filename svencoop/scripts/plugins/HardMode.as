//const array<string> g_RemoveEnts = {'func_healthcharger', 'func_recharge', 'item_healthkit', 'item_armorvest', 'item_battery' };
const array<string> g_RemoveEnts = {'func_healthcharger', 'item_healthkit' };
dictionary g_Frags;

CClientCommand g_HardModeOn("hardmodeon", "Turn on Hard Mode (admin only)", @StartHardModeCmd);
//CClientCommand g_HardModeOff("hardmodeoff", "Turn off Hard Mode (admin only)", @StopHardModeCmd);

CScheduledFunction@ g_pThinkFunc = null;

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

//  g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
  g_Hooks.RegisterHook(Hooks::Player::PlayerPostThink, @PlayerPostThink);
}

void MapInit() {
   g_Frags.deleteAll();
   g_Scheduler.RemoveTimer(g_pThinkFunc);
}

void StartHardMode() {
   CBaseEntity@ pEnt = null;

   for (uint i = 0; i < g_RemoveEnts.length(); ++i) {
      while( ( @pEnt = g_EntityFuncs.FindEntityByClassname( pEnt, g_RemoveEnts[i] ) ) !is null ) {
         g_EntityFuncs.Remove(pEnt);
      }
   }

   if (g_pThinkFunc is null)
      @g_pThinkFunc = g_Scheduler.SetInterval("TakeHealth", 3.0f);
}

void TakeHealth() {
   for (int i = 1; i <= g_Engine.maxClients; ++i) {
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

      if (pPlayer !is null && pPlayer.IsAlive()) {
         if (pPlayer.pev.health <= 1.0)
            return;
 
         pPlayer.TakeHealth(-1.0f, DMG_GENERIC, pPlayer.m_iMaxHealth < 150 ? 150 : pPlayer.m_iMaxHealth);
      }
   }
}

HookReturnCode PlayerPostThink(CBasePlayer@ pPlayer) {
   if ((pPlayer !is null && pPlayer.IsAlive()) {
      const int ePlayerIndex = g_EntityFuncs.EntIndex(pPlayer.edict());

      if (g_Frags.exists(ePlayerIndex) && pPlayer.pev.frags > float(g_Frags[ePlayerIndex]))
        pPlayer.TakeHealth( (pPlayer.pev.frags - float(g_Frags[ePlayerIndex]))*1.75f, DMG_MEDKITHEAL, pPlayer.m_iMaxHealth < 150 ? 150 : pPlayer.m_iMaxHealth );

      g_Frags[ePlayerIndex] = pPlayer.pev.frags;
   }
   return HOOK_CONTINUE;
}

void StartHardModeCmd(const CCommand@ pArgs) {
   CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

   if (g_PlayerFuncs.AdminLevel(pCaller) < ADMIN_YES)
      g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "You have no access to this command.\n");
   else
      StartHardMode();
}

/* void StopHardModeCmd(const CCommand@ pArgs) {
  CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

  if (g_PlayerFuncs.AdminLevel(pCaller) < ADMIN_YES)
    g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "You have no access to this command.\n");
  else
    StopHardMode();
} */

void ClientDisconnect(CBasePlayer@ pPlayer) {
   const int ePlayerIndex = g_EntityFuncs.EntIndex(pPlayer.edict());

   g_Frags.delete(ePlayerIndex);
}
