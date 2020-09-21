// lol no time anymore to port https://www.youtube.com/watch?v=bj1XxUBc1G0
// so just enjoy this shitty plugin kek

const string g_Sprite1s = "sprites/txas/fireworks.spr";
const string g_Sprite2s = "sprites/txas/exp_red.spr";
const string g_Sprite3s = "sprites/txas/zerogxplode.spr";
const string g_SoundLong = "egyptesc/fireworks.wav";
const string g_SoundShort = "weapons/fireworks.wav";

const float from = 1577833199.0f;
const float to = 1577836891.0f;

bool bg = false;

CScheduledFunction@ g_pSpeedThinkFunc = null;

int g_Sprite1;
int g_Sprite2;
int g_Sprite3;

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");
  
  if(g_pSpeedThinkFunc !is null)
    g_Scheduler.RemoveTimer(g_pSpeedThinkFunc);

  @g_pSpeedThinkFunc = g_Scheduler.SetInterval("Fireworks", 3.6f);
}

void MapInit() {
  g_Game.PrecacheGeneric('sound/' + g_SoundLong);
  g_Game.PrecacheGeneric('sound/' + g_SoundShort);
  g_SoundSystem.PrecacheSound(g_SoundLong);
  g_SoundSystem.PrecacheSound(g_SoundShort);
  g_Game.PrecacheGeneric(g_Sprite1s);
  g_Game.PrecacheGeneric(g_Sprite2s);
  g_Game.PrecacheGeneric(g_Sprite3s);
  g_Sprite1 = g_Game.PrecacheModel(g_Sprite1s);
  g_Sprite2 = g_Game.PrecacheModel(g_Sprite2s);
  g_Sprite3 = g_Game.PrecacheModel(g_Sprite3s);
}

void Fireworks() {
  //if (!(g_EngineFuncs.Time() >= from && g_EngineFuncs.Time() <= to))
  if (g_Engine.mapname != "road_to_shinnen")
    return;

  if (!bg) {
    g_SoundSystem.PlaySound(g_EntityFuncs.IndexEnt(0), CHAN_STATIC, g_SoundLong, 1.0f, 0.0f, 0, 100, 0);
    bg = true;
  }

  for (int i = 1; i <= g_Engine.maxClients; ++i) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
  
    if (pPlayer !is null && pPlayer.IsConnected()) {
      if(Math.RandomLong(0, 3) == 0) {
        OverheadSprite(pPlayer.pev.origin, g_Sprite3);
      }
      else {
        OverheadSprite(pPlayer.pev.origin, Math.RandomLong(0, 1) == 0 ? g_Sprite1 : g_Sprite2);
        g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, g_SoundShort, 0.5f, 0.2f, 0, Math.RandomLong(45, 255), 0, true, pPlayer.pev.origin);
      }
    }
  }
}

void OverheadSprite(Vector origin, int sprite) {
  NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
  m.WriteByte(TE_SPRITE);
  m.WriteCoord(origin.x + Math.RandomLong(0, 50));
  m.WriteCoord(origin.y + Math.RandomLong(0, 50));
  m.WriteCoord(origin.z + Math.RandomLong(50, 100));
  m.WriteShort(sprite);
  m.WriteByte(Math.RandomLong(1, 30));
  m.WriteByte(255);
  m.End();
  
  NetworkMessage m2(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
  m2.WriteByte(TE_SPARKS);
  m2.WriteCoord(origin.x + Math.RandomLong(0, 50));
  m2.WriteCoord(origin.y + Math.RandomLong(0, 50));
  m2.WriteCoord(origin.z + Math.RandomLong(50, 100));
  m2.End();
}
