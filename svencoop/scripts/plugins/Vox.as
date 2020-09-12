void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Sven Co-op Team" );
	g_Module.ScriptInfo.SetContactInfo( "www.svencoop.com" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

CScheduledFunction@ g_pVoxThink = null;

void MapInit()
{
	@g_pVoxThink = g_Scheduler.SetInterval( "VoxThink", 1 );
	
	g_SoundSystem.PrecacheSound( "vox/foxtrot.wav" );
	g_SoundSystem.PrecacheSound( "vox/uniform.wav" );
	g_SoundSystem.PrecacheSound( "vox/charlie.wav" );
	g_SoundSystem.PrecacheSound( "vox/kilo.wav" );
}

array<string> g_arrVox;

void VoxThink()
{
	if( g_arrVox.length() > 0 )
	{
		const string szSound = g_arrVox[0];
		
		//Use the world as the owning entity
		CBaseEntity@ pWorld = g_EntityFuncs.Instance( 0 );
		
		g_SoundSystem.PlaySound( pWorld.edict(), CHAN_STATIC, "vox/" + szSound + ".wav", 1.0, ATTN_NONE, 0, 100 );
		
		g_arrVox.removeAt(0);
	}
}

HookReturnCode MapChange()
{
	g_arrVox.resize(0);//Clear array
	
	g_Scheduler.RemoveTimer( g_pVoxThink );
	@g_pVoxThink = null;
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	const CCommand@ pArguments = pParams.GetArguments();
	
	if( pArguments.ArgC() >= 1 )
	{
		if( pArguments[ 0 ] == "!vox" )
		{
			//Interpret all that follows as individual words
			for( int iIndex = 1; iIndex < pArguments.ArgC(); ++iIndex )
			{
				g_arrVox.insertLast( pArguments[ iIndex ] );
			}
			
			pParams.ShouldHide = true;
			
			return HOOK_HANDLED;
		}
	}
	
	return HOOK_CONTINUE;
}