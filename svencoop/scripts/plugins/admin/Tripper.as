const int snarkcount = 200;

CClientCommand g_tp1("tp1", "trip", @trip);
CClientCommand g_tp2("tp2", "tripcross", @FunTripmineSpam2);

array<CBaseEntity@> pSpot;
array<CBaseEntity@> pBeam;

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Module.ScriptInfo.SetMinimumAdminLevel(ADMIN_YES);
}

void trip(const CCommand@ pArgs) {
  CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

  array<CBaseEntity@> pSnarks(snarkcount);

  for (int i = 0; i < snarkcount; ++i) {
    @pSnarks[i] = g_EntityFuncs.Create("monster_tripmine", pPlayer.pev.origin + Vector(0, 0, 0), Vector(90, 0, 0), false, pPlayer.edict());
  }
}

void CreateSpot( Vector vecSrc, int iSpotNumber )
{
        @pSpot[iSpotNumber] = g_EntityFuncs.Create( "env_sprite", vecSrc, g_vecZero, true );
        pSpot[iSpotNumber].pev.movetype = MOVETYPE_NONE;
        pSpot[iSpotNumber].pev.solid = SOLID_NOT;
        pSpot[iSpotNumber].pev.rendermode = kRenderGlow;
        pSpot[iSpotNumber].pev.renderfx = kRenderFxNoDissipation;
        pSpot[iSpotNumber].pev.renderamt = 255;
        g_EntityFuncs.SetModel( pSpot[iSpotNumber], "sprites/laserdot.spr" );
        g_EntityFuncs.DispatchSpawn( pSpot[iSpotNumber].edict() );
}
 
void FunTripmineSpam2( const CCommand@ args )
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    TraceResult tr,tr2,tr3,tr4,tr5;
    int iMaxTripmines, iAreaSize, iMineCount = 0;
    Vector trStart = pPlayer.GetGunPosition();
    Vector vecOffset = Vector(0,0,0);
    Math.MakeVectors( pPlayer.pev.v_angle );
    g_Utility.TraceLine( trStart, trStart + g_Engine.v_forward * 8192, dont_ignore_monsters, pPlayer.edict(), tr );
    Vector angles = Math.VecToAngles( tr.vecPlaneNormal );
 
    CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
    if( tr.fStartSolid != 1 || tr.fAllSolid != 1 && pHit.IsBSPModel() == true )
    {
        if( tr.vecPlaneNormal.z >= 1.0 || tr.vecPlaneNormal.z <= -1.0 )
        {
            //g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Trace length1: " + (trStart-tr.vecEndPos).Length() + "\n" );
            //CreateSpot( tr.vecEndPos, 1 );
            //CreateBeam( trStart, tr.vecEndPos, 1 );
           
            trStart = tr.vecEndPos;
            g_Utility.TraceLine( trStart, trStart + Vector(1,0,0) * 8192, dont_ignore_monsters, pPlayer.edict(), tr2 );
            //CreateSpot( tr2.vecEndPos, 2 );
            //CreateBeam( trStart, tr2.vecEndPos, 2 );
            //g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Trace length2: " + int((trStart-tr2.vecEndPos).Length()) + "\n" );
            iMaxTripmines = int(int((trStart-tr2.vecEndPos).Length())/8);
            for( int i = 0; i < iMaxTripmines; i++ )
            {
                CBaseEntity@ pEnt = g_EntityFuncs.Create( "monster_tripmine", tr.vecEndPos + vecOffset + tr.vecPlaneNormal * 8, angles, false, null );
                vecOffset.x += 8;
                iMineCount++;
            }
            vecOffset = g_vecZero;
           
            g_Utility.TraceLine( trStart, trStart + Vector(-1,0,0) * 8192, dont_ignore_monsters, pPlayer.edict(), tr3 );
            //CreateSpot( tr3.vecEndPos, 2 );
            //CreateBeam( trStart, tr3.vecEndPos, 3 );
            //g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Trace length3: " + int((trStart-tr3.vecEndPos).Length()) + "\n" );
            iMaxTripmines = int(int((trStart-tr3.vecEndPos).Length())/8);
            for( int i = 0; i < iMaxTripmines; i++ )
            {
                CBaseEntity@ pEnt = g_EntityFuncs.Create( "monster_tripmine", tr.vecEndPos + vecOffset + tr.vecPlaneNormal * 8, angles, false, null );
                vecOffset.x -= 8;
                iMineCount++;
            }
            vecOffset = g_vecZero;
 
            g_Utility.TraceLine( trStart, trStart + Vector(0,1,0) * 8192, dont_ignore_monsters, pPlayer.edict(), tr4 );
            //CreateSpot( tr4.vecEndPos, 2 );
            //CreateBeam( trStart, tr4.vecEndPos, 3 );
            //g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Trace length4: " + int((trStart-tr4.vecEndPos).Length()) + "\n" );
            iMaxTripmines = int(int((trStart-tr4.vecEndPos).Length())/16);
            for( int i = 0; i < iMaxTripmines; i++ )
            {
                CBaseEntity@ pEnt = g_EntityFuncs.Create( "monster_tripmine", tr.vecEndPos + vecOffset + tr.vecPlaneNormal * 8, angles, false, null );
                vecOffset.y += 16;
                iMineCount++;
            }
            vecOffset = g_vecZero;
 
            g_Utility.TraceLine( trStart, trStart + Vector(0,-1,0) * 8192, dont_ignore_monsters, pPlayer.edict(), tr5 );
            //CreateSpot( tr5.vecEndPos, 2 );
            //CreateBeam( trStart, tr5.vecEndPos, 3 );
            //g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Trace length5: " + int((trStart-tr5.vecEndPos).Length()) + "\n" );
            iMaxTripmines = int(int((trStart-tr5.vecEndPos).Length())/16);
            for( int i = 0; i < iMaxTripmines; i++ )
            {
                CBaseEntity@ pEnt = g_EntityFuncs.Create( "monster_tripmine", tr.vecEndPos + vecOffset + tr.vecPlaneNormal * 8, angles, false, null );
                vecOffset.y -= 16;
                iMineCount++;
            }
            vecOffset = g_vecZero;
           
            iAreaSize = int((trStart-tr2.vecEndPos).Length()+(trStart-tr3.vecEndPos).Length()+(trStart-tr4.vecEndPos).Length()+(trStart-tr5.vecEndPos).Length());
            //g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Size of Area: " + iAreaSize + "\n" );
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Mines spawned: " + iMineCount + "\n" );
        }
    }
    else
        return;
}

