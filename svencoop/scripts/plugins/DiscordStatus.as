// to use with misc/scdiscordbridge.pl

const string g_BridgeFile = "scripts/plugins/store/discordbridge.txt";

string lastMap = "";

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");
}

void MapStart() {
  if( g_Scheduler.GetCurrentFunction() !is null )
    g_Scheduler.ClearTimerList();

  g_Scheduler.SetTimeout( "AnnounceMap", 25 ); // will be 0 at MapStart() otherwise
}

void AnnounceMap() {
  if( g_PlayerFuncs.GetNumPlayers() == 0 || g_Engine.mapname == lastMap )
    return;

  lastMap = g_Engine.mapname;

  string append = "" + g_Engine.mapname + " " + g_PlayerFuncs.GetNumPlayers() + "\n";
  AppendFile( append );
}

void AppendFile( string append ) {
  File@ pFile = g_FileSystem.OpenFile( g_BridgeFile, OpenFile::APPEND );

  if ( pFile !is null && pFile.IsOpen() ) {
    pFile.Write( append );
    pFile.Close();
  }
}
