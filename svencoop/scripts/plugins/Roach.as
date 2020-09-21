const string g_roachmodel = "models/twlz/troach.mdl";

void PluginInit() {
    g_Module.ScriptInfo.SetAuthor( "incognico" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/qfZxWAd" );

    g_Hooks.RegisterHook( Hooks::Game::EntityCreated, @EntityCreated );
}

void MapInit() {
    g_Game.PrecacheModel( g_roachmodel );
    g_Game.PrecacheMonster( "monster_cockroach", false );
}

HookReturnCode EntityCreated( CBaseEntity@ pEnt ) {
    if ( pEnt !is null && pEnt.GetClassname() == "monster_cockroach" && Math.RandomLong(0, 2) == 0 )
        g_Scheduler.SetTimeout( "DelaySetModel", 0.1, EHandle( pEnt ) );

    return HOOK_CONTINUE;
}

void DelaySetModel( EHandle pEh ) {
    if ( pEh.IsValid() )
       g_EntityFuncs.SetModel( pEh.GetEntity(), g_roachmodel );
}
