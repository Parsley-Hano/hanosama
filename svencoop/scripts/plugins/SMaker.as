void PluginInit()
{
   g_Module.ScriptInfo.SetAuthor( "Julian \"Giegue\" Rodriguez" );
   g_Module.ScriptInfo.SetContactInfo( "www.steamcommunity.com/id/ngiegue" );
}

void MapInit()
{
//   if ( g_SurvivalMode.IsActive() )
//      return;

   g_Game.PrecacheModel( "sprites/exit1.spr" );
   g_Game.PrecacheModel( "models/common/lambda.mdl" );
   g_SoundSystem.PrecacheSound( "../media/valve.mp3" );
   g_SoundSystem.PrecacheSound( "debris/beamstart7.wav" );
   g_SoundSystem.PrecacheSound( "debris/beamstart4.wav" );
   g_SoundSystem.PrecacheSound( "ambience/port_suckout1.wav" );

   string map = string( g_Engine.mapname ).ToLowercase;
   string path = "scripts/plugins/cfg/smaker/";
   path += map + ".ini";
   File@ spoints = g_FileSystem.OpenFile( path, OpenFile::READ );

   if ( spoints !is null && spoints.IsOpen() )
   {
      int checkpoints = 0;
      string line;

      while ( !spoints.EOFReached() )
      {
         spoints.ReadLine( line );
         if ( line.Length() == 0 )
            continue;

         line.Trim();
         Vector pOrigin;
         g_Utility.StringToVector( pOrigin, line );
         g_Scheduler.SetTimeout( "create_checkpoint", 1.0, pOrigin ); // Wait a short while so point_checkpoint can fully register.
         checkpoints++;
      }

      if ( checkpoints > 0 ) {
         g_EngineFuncs.CVarSetFloat( "mp_survival_supported", 1 );
         g_Game.AlertMessage( at_console, "[Survival Maker] " + checkpoints + " checkpoint(s) successfully loaded.\n" );
      }
      else
         g_Game.AlertMessage( at_console, "[Survival Maker] WARNING: Map " + map + " has no checkpoints specified.\n" );
   }
   else
      g_Game.AlertMessage( at_console, "[Survival Maker] WARNING: Couldn't open file " + path + "\n" );
}

void create_checkpoint( const Vector& in pOrigin )
{
   g_EntityFuncs.Create( "point_checkpoint", pOrigin, g_vecZero, false );
}

