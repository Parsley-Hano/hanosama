const array<string> g_AdditionalModelList = {
'partybear'
};

const array<string> g_ClimateChangeModelList = {
'greta_thunberg'
};

const array<string> g_CrashModelList = {
'apacheshit',
'axis2_s5',
'big_mom',
'friendlygarg',
'garg',
'gargantua',
'onos',
'owatarobo',
'owatarobo_s',
'tomb_raider',
'vehicleshit_submarine'
};

const int g_MaxVotes = 3;
bool g_ClimateChange = false;
bool g_ClimateChangePrev = false;
int g_VoteCount = 0;

dictionary g_OriginalModelList;

CScheduledFunction@ g_pThinkFunc = null;

CClientCommand g_ListModels("listmodels", "List model names and colors of the current players", @ListModels);
CClientCommand g_ListPrecachedModels("listprecachedmodels", "List model names who are currently precached by the server (admin only)", @ListPrecachedModels, ConCommandFlag::AdminOnly);

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
  g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);

  g_Scheduler.SetInterval("CrashModelCheck", 1.5f);
}

void MapInit() {
  for (uint i = 0; i < g_AdditionalModelList.length(); ++i) {
    g_Game.PrecacheGeneric("models/player/" + g_AdditionalModelList[i] + "/" + g_AdditionalModelList[i] + ".mdl");
  }

  if ( g_MaxVotes > 0 ) {
    for (uint i = 0; i < g_ClimateChangeModelList.length(); ++i) {
      g_Game.PrecacheGeneric("models/player/" + g_ClimateChangeModelList[i] + "/" + g_ClimateChangeModelList[i] + ".mdl");
    }
  }

  g_ClimateChange = false;
  g_VoteCount = 0;

  if (g_pThinkFunc !is null)
    g_Scheduler.RemoveTimer(g_pThinkFunc);
}

HookReturnCode MapChange() {
  if (g_ClimateChangePrev && !g_ClimateChange)
    g_ClimateChangePrev = false;

  if (g_ClimateChange)
    g_ClimateChangePrev = true;

  return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer) {
   const string SteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
   g_OriginalModelList.delete(SteamId);
   
   return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer) {
  KeyValueBuffer@ pInfos = g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict());
  const string SteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

  if (!g_Map.HasForcedPlayerModels()) {
    if (g_ClimateChange) {
      if (!g_OriginalModelList.exists(SteamId))
        g_OriginalModelList.set(SteamId, pInfos.GetValue("model"));

      pInfos.SetValue("model", g_ClimateChangeModelList[Math.RandomLong(0, g_ClimateChangeModelList.length()-1)]);
    }
    else {
      if (g_ClimateChangePrev && g_OriginalModelList.exists(SteamId)) {
        pInfos.SetValue("model", string(g_OriginalModelList[SteamId]));
        g_OriginalModelList.delete(SteamId);
      }
    }
    return HOOK_CONTINUE;
  }
  return HOOK_CONTINUE;
}

HookReturnCode ClientSay(SayParameters@ pParams) {
  const CCommand@ pArguments = pParams.GetArguments();

  if (pArguments.ArgC() > 0 && (pArguments.Arg(0).ToLowercase() == "climatechange?" || pArguments.Arg(0).ToLowercase() == "climatechange" || pArguments.Arg(0).ToLowercase() == "climate?")) {
    if (g_ClimateChange) {
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] Climate change is already in progress.\n");
    }
    else if (g_VoteCount >= g_MaxVotes) {
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] Maximum tries to toggle climate change reached or not allowed.\n");
    }
    else if (g_Map.HasForcedPlayerModels()) {
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] Climate changes is not available on this map.\n");
    }
    else {
      Vote@ WCVote = Vote('ClimateChange?', 'Change the climate until the end of the map?', 15.0f, 60.0f);
      WCVote.SetYesText('Yes, there\'s no planet B');
      WCVote.SetNoText('No, climate change is a lie');
      WCVote.SetVoteBlockedCallback(@WCVoteBlocked);
      WCVote.SetVoteEndCallback(@WCVoteEnd);
      WCVote.Start();
      g_VoteCount++;
    }
    return HOOK_HANDLED;
  }
  return HOOK_CONTINUE;
}

void WCVoteBlocked(Vote@ pVote, float flTime) {
  g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] Another vote is currently active, try again in " + ceil(flTime) + " seconds.\n");
}

void WCVoteEnd(Vote@ pVote, bool fResult, int iVoters) {
  if (fResult) {
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] Climate change is now in progress.\n");
    g_ClimateChange = true;
    ForceClimateChange(false);
    @g_pThinkFunc = g_Scheduler.SetInterval("ForceClimateChange", 15.0f, g_Scheduler.REPEAT_INFINITE_TIMES, true);
  }
  else {
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] Shame! The players are climate change deniers!\n");
  }
}

void ForceClimateChange(bool msg) {
  for (int i = 1; i <= g_Engine.maxClients; ++i) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

    if (pPlayer !is null) {
      KeyValueBuffer@ pInfos = g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict());
      const string SteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

      if (!g_OriginalModelList.exists(SteamId))
        g_OriginalModelList.set(SteamId, pInfos.GetValue("model"));

      if (g_ClimateChangeModelList.find(pInfos.GetValue("model")) < 0) {
        pInfos.SetValue("model", g_ClimateChangeModelList[Math.RandomLong(0, g_ClimateChangeModelList.length()-1)]);
 
        if (msg)
          g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Info] You can not deny the climate change!\n");
      }
    }
  }
}

void ListModels(const CCommand@ pArgs) {
  CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

  if (g_ClimateChange) {
    g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "CLIMATE CHANGE MODE IS ENABLED! YOU MAY CHOOSE FROM:\n");
    g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "----------------------------------------------------\n");

    for (uint i = 0; i < g_ClimateChangeModelList.length(); ++i) {
      g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, g_ClimateChangeModelList[i] + "\n");
    }

    g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "------------------------------------------------\n");
  }

  g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "PLAYERNAME ==> MODELNAME (TOPCOLOR, BOTTOMCOLOR)\n");
  g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "------------------------------------------------\n");

  for (int i = 1; i <= g_Engine.maxClients; ++i) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

    if (pPlayer !is null && pPlayer.IsConnected()) {
      KeyValueBuffer@ pInfos = g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict());
      g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, string(pPlayer.pev.netname) + " ==> " + pInfos.GetValue("model") + " (" + pInfos.GetValue("topcolor") + ", " + pInfos.GetValue("bottomcolor") + ")\n");
    }
  }
}

void CrashModelCheck() {
  for (int i = 1; i <= g_Engine.maxClients; ++i) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

    if (pPlayer !is null) {
      KeyValueBuffer@ pInfos = g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict());

      if (g_CrashModelList.find(pInfos.GetValue("model").ToLowercase()) >= 0) {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Warning] Don\'t use player model \'" + pInfos.GetValue("model") + "\', it is prone to crash or obscures views!\n");
        pInfos.SetValue("model", g_ClimateChangeModelList[Math.RandomLong(0, g_ClimateChangeModelList.length()-1)]);
      }
    }
  }
}

void ListPrecachedModels(const CCommand@ pArgs) {
  CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

  g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "CURRENTLY PRECACHED MODELS\n");
  if ( g_MaxVotes > 0 ) {
    g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "--ClimateChange-----------\n");

    for (uint i = 0; i < g_ClimateChangeModelList.length(); ++i) {
      g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, g_ClimateChangeModelList[i] + "\n");
    }
  }

  g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "--Additional--------------\n");

  for (uint i = 0; i < g_AdditionalModelList.length(); ++i) {
    g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, g_AdditionalModelList[i] + "\n");
  }

}
