// IMPORTANT:
// You need to create a symlink: svencoop_addon/models/player -> svencoop_addon/scripts/plugins/store/playermodelfolder
// LOL SECURITY VIOLATION USE AT OWN RISK LOL

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor( "incognico" );
  g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/qfZxWAd" );
  g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

CClientCommand g_ListPrecacheModels( "listprecachedplayermodels", "List precached player model list", @ListPrecachePlayerModels );

array<string> g_ModelList;

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ) {
  KeyValueBuffer@ p_PlayerInfo = g_EngineFuncs.GetInfoKeyBuffer( pPlayer.edict() );

  if ( g_ModelList.find( p_PlayerInfo.GetValue( "model" ) ) < 0 ) {
    int res = p_PlayerInfo.GetValue( "model" ).FindFirstOf( "/" );

    if ( res < 0 ) {
      string lowermodel = p_PlayerInfo.GetValue( "model" ).ToLowercase();
      g_ModelList.insertLast( lowermodel );
    }
  }

  return HOOK_HANDLED;
}

void MapInit() {
  array<string> precachedModels;

  for ( uint i = 0; i < g_ModelList.length(); i++ ) {
    File@ pFileT = g_FileSystem.OpenFile( "scripts/plugins/store/playermodelfolder/" + g_ModelList[i] + "/" + g_ModelList[i] + "t.mdl", OpenFile::READ );

    if ( pFileT !is null && pFileT.IsOpen() ) {
      pFileT.Close();
      g_Game.PrecacheGeneric( "models/player/" + g_ModelList[i] + "/" + g_ModelList[i] + "t.mdl" );
    }

    File@ pFile = g_FileSystem.OpenFile( "scripts/plugins/store/playermodelfolder/" + g_ModelList[i] + "/" + g_ModelList[i] + ".mdl", OpenFile::READ );

    if ( pFile !is null && pFile.IsOpen() ) {
      pFile.Close();
      g_Game.PrecacheModel( "models/player/" + g_ModelList[i] + "/" + g_ModelList[i] + ".mdl" );
      precachedModels.insertLast(g_ModelList[i]);
    }

    File@ pFileP = g_FileSystem.OpenFile( "scripts/plugins/store/playermodelfolder/" + g_ModelList[i] + "/" + g_ModelList[i] + ".bmp", OpenFile::READ );

    if ( pFileP !is null && pFileP.IsOpen() ) {
      pFileP.Close();
      g_Game.PrecacheGeneric( "models/player/" + g_ModelList[i] + "/" + g_ModelList[i] + ".bmp" );
    }
  }

  // share the list of precached models with other plugins
  dictionary keys;
  keys["targetname"] = "PlayerModelPrecacheDyn";
  for (uint i = 0; i < precachedModels.size(); i++) {
    keys["$s_model" + i] = precachedModels[i];
  }
  g_EntityFuncs.CreateEntity("info_target", keys, true);

  g_ModelList.resize( 0 );
}

void ListPrecachePlayerModels( const CCommand@ pArgs ) {
  CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

  g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, "Currently dynamically precached playermodels:\n---------------------------------------------\n" );

  for ( uint i = 0; i < g_ModelList.length(); i++ ) {
    g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, g_ModelList[i] + "\n" );
  }
}
