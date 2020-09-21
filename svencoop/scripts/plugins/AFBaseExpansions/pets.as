Pets pets;

void Pets_Call()
{
	pets.RegisterExpansion(pets);
}

class Pets : AFBaseClass
{
	void ExpansionInfo()
	{
		this.AuthorName = "Nero";
		this.ExpansionName = "Pets 1.3";
		this.ShortName = "PETS";
	}

	void ExpansionInit()
	{
		RegisterCommand( "say pet", "s!f", "(petname/menu/off) <scale, up to 0.9> - summon pet, show menu, or remove pet.", ACCESS_Z, @Pets::pet_cmd_handle, true, true );
		RegisterCommand( "pet_force", "ss!f", "(target(s)) (petname/off) <scale, up to 0.9> - force pet.. or take it away!", ACCESS_U, @Pets::forcepet, true );
		g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @Pets::PlayerSpawn );
		g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @Pets::PlayerKilled );
		@Pets::g_cvarHideChat = CCVar( "pets_hidechat", 0, "0/1 Suppress player chat when using plugin.", ConCommandFlag::AdminOnly );
		@Pets::g_cvarHideInfo = CCVar( "pets_hideinfo", 0, "0/1 Suppress info chat from plugin.", ConCommandFlag::AdminOnly );
	}

	void MapInit()
	{
		Pets::g_petModels.deleteAll();
		Pets::ReadPets();
		array<string> petNames = Pets::g_petModels.getKeys();

		for( uint i = 0; i < petNames.length(); ++i )
		{
			Pets::PetData@ pData = cast<Pets::PetData@>(Pets::g_petModels[petNames[i]]);
			g_Game.PrecacheModel( "models/" + pData.sModelPath + ".mdl" );
		}

		Pets::g_petUsers.deleteAll();
		Pets::g_petUserPets.deleteAll();

		if( @Pets::petMenu !is null )
		{
			Pets::petMenu.Unregister();
			@Pets::petMenu = null;
		}

		array<string> petUsers = Pets::g_petCrossover.getKeys();

		for( uint i = 0; i < petUsers.length(); ++i )
		{
			Pets::PetCrossover@ cData = cast<Pets::PetCrossover@>(Pets::g_petCrossover[petUsers[i]]);
			cData.iCount = cData.iCount + 1;
			cData.bCounted = false;
			Pets::g_petCrossover[petUsers[i]] = cData;

			if( cData.iCount >= 3 )
				Pets::g_petCrossover.delete(petUsers[i]);
		}

		if( Pets::g_petThink !is null )
			g_Scheduler.RemoveTimer( Pets::g_petThink );

		@Pets::g_petThink = g_Scheduler.SetInterval( "PetThink", Pets::m_flThinkRate );
	}

	void PlayerDisconnectEvent( CBasePlayer@ pPlayer )
	{
		Pets::removepet( pPlayer, true );
	}

	void StopEvent()
	{
		if( Pets::g_petThink !is null )
			g_Scheduler.RemoveTimer( Pets::g_petThink );

		CBasePlayer@ pSearch = null;

		for( int i = 1; i <= g_Engine.maxClients; ++i )
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);

			if( pSearch !is null )
			{
				string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pSearch));

				if(sFixId == "") continue;

				if( Pets::g_petUsers.exists(sFixId) )
					Pets::removepet( pSearch, true );
			}
		}
	}

	void StartEvent()
	{
		if( Pets::g_petThink !is null )
			g_Scheduler.RemoveTimer( Pets::g_petThink );

		@Pets::g_petThink = g_Scheduler.SetInterval( "PetThink", Pets::m_flThinkRate );
	}
}

namespace Pets
{
	dictionary g_petUsers;
	dictionary g_petUserPets;
	dictionary g_petModels;
	string g_petsFile = "scripts/plugins/AFBaseExpansions/pets.txt";
	CTextMenu@ petMenu = null;
	dictionary g_petCrossover;
	CCVar@ g_cvarHideChat;
	CCVar@ g_cvarHideInfo;
	const float m_flThinkRate = 0.1f;
	CScheduledFunction@ g_petThink = null;
	array<float> flTimeToDie(33);
	array<bool> bRemovePet(33);

	class PetData
	{
		string sName;
		string sModelPath;
		float flScale;
		int iIdleAnim;
		float flIdleSpeed;
		int iRunAnim;
		float flRunSpeed;
		int iDeathAnim;
		float flDeathLength;
		float flMinusZStanding;
		float flMinusZCrouching;
		float flMaxDistance;
		float flMinDistance;
		string sBoneControllers;
		//bool bDynamic;
	}

	class PetCrossover
	{
		string sPet;
		float flScale;
		int iCount;
		bool bCounted;
	}

	HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
	{
		string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pPlayer));
		int id = pPlayer.entindex();
		flTimeToDie[id] = 0;
		bRemovePet[id] = false;

		if( g_petCrossover.exists(sFixId) && pets.Running )
			g_Scheduler.SetTimeout( "playerPostSpawn", 1.5f, id, sFixId );

		return HOOK_CONTINUE;
	}

	HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
	{
		handle_death( pPlayer, false );

		return HOOK_CONTINUE;
	}

	void playerPostSpawn( int &in iIndex, string &in sFixId )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(iIndex);
		if( pPlayer is null ) return;

		PetCrossover@ cData = cast<PetCrossover@>(g_petCrossover[sFixId]);

		if( !cData.bCounted )
			setpet( pPlayer, cData.sPet, true, cData.flScale );
	}

	void ReadPets()
	{
		File@ file = g_FileSystem.OpenFile( g_petsFile, OpenFile::READ );

		if( file !is null && file.IsOpen() )
		{
			while( !file.EOFReached() )
			{
				string sLine;
				file.ReadLine(sLine);
				//fix for linux
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);

				if( sLine.SubString(0,1) == "#" || sLine.IsEmpty() )
					continue;

				array<string> parsed = sLine.Split(" ");

				if( parsed.length() < 13 )
					continue;

				PetData pData;
				string sName = "";
				string sModelPath = "";
				float flScale = 1.0f;
				int iIdleAnim = 0;
				float flIdleSpeed = 1.0f;
				int iRunAnim = 0;
				float flRunSpeed = 1.0f;
				int iDeathAnim = 0;
				float flDeathLength = 1.0f;
				float flMinusZStanding = 0.0f;
				float flMinusZCrouching = 0.0f;
				float flMaxDistance = 0.0f;
				float flMinDistance = 0.0f;
				string sBoneControllers = "";

				sName = parsed[0];
				sModelPath = parsed[1];
				flScale = atof(parsed[2]);
				iIdleAnim = atoi(parsed[3]);
				flIdleSpeed = atof(parsed[4]);
				iRunAnim = atoi(parsed[5]);
				flRunSpeed = atof(parsed[6]);
				iDeathAnim = atoi(parsed[7]);
				flDeathLength = atof(parsed[8]);
				flMinusZStanding = atof(parsed[9]);
				flMinusZCrouching = atof(parsed[10]);
				flMaxDistance = atof(parsed[11]);
				flMinDistance = atof(parsed[12]);
				if( parsed.length() > 13 ) sBoneControllers = parsed[13];

				pData.sName = sName;
				pData.sModelPath = sModelPath;
				pData.flScale = flScale;
				pData.iIdleAnim = iIdleAnim;
				pData.flIdleSpeed = flIdleSpeed;
				pData.iRunAnim = iRunAnim;
				pData.flRunSpeed = flRunSpeed;
				pData.iDeathAnim = iDeathAnim;
				pData.flDeathLength = flDeathLength;
				pData.flMinusZStanding = flMinusZStanding;
				pData.flMinusZCrouching = flMinusZCrouching;
				pData.flMaxDistance = flMaxDistance;
				pData.flMinDistance = flMinDistance;
				pData.sBoneControllers = sBoneControllers;

				g_petModels[sName] = pData; 
			}

			file.Close();
		}
	}

	void pet_cmd_handle( AFBaseArguments@ args )
	{
		float flScale = args.GetCount() >= 2 ? args.GetFloat(1) : 0.0f;

		if( g_cvarHideChat.GetInt() <= 0 )
		{
			string sOutput = "";
			for( uint i = 0; i < args.RawArgs.length(); ++i )
			{
				if( i > 0 ) sOutput += " ";

				sOutput += args.RawArgs[i];
			}

			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, " " + args.User.pev.netname + ": " + sOutput );
		}

		if( args.GetString(0) == "off" )
			removepet( args.User, false );
		else if( args.GetString(0) == "menu" )
		{
			if( @petMenu is null )
			{
				@petMenu = CTextMenu(petMenuCallback);
				petMenu.SetTitle("Pet Menu: ");
				petMenu.AddItem( "<off>", null );
				array<string> petNames = g_petModels.getKeys();
				petNames.sortAsc();

				for( uint i = 0; i < petNames.length(); ++i )
					petMenu.AddItem( petNames[i].ToLowercase(), null );

				petMenu.Register();
			}

			petMenu.Open( 0, 0, args.User );
		}
		else
		{
			if( g_petModels.exists(args.GetString(0)) )
				setpet( args.User, args.GetString(0), false, flScale );
			else
			{
				if( g_cvarHideInfo.GetInt() <= 0 )
					pets.TellAll( "Unknown pet. Try using \"pet menu\"?\n", HUD_PRINTTALK );
				else
					pets.Tell( "Unknown pet. Try using \"pet menu\"?\n", args.User, HUD_PRINTTALK );
			}
		}
	}

	void setpet( CBasePlayer@ pPlayer, string sPet, bool bSilent, float flScale = 0.0f )
	{
		string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pPlayer));

		if( g_petUsers.exists(sFixId) )
		{
			CBaseEntity@ pPet2 = cast<CBaseEntity@>(g_petUsers[sFixId]);

			if( pPet2 !is null ) g_EntityFuncs.Remove(pPet2);
		}

		CBaseEntity@ pPet = g_EntityFuncs.Create( "info_target", pPlayer.pev.origin, pPlayer.pev.angles, true );
		g_EntityFuncs.DispatchSpawn(pPet.edict());
		PetData@ pData = cast<PetData@>(g_petModels[sPet]);
		PetCrossover cData;
		cData.sPet = sPet;
		cData.iCount = 0;
		cData.bCounted = true;
		g_EntityFuncs.SetModel( pPet, "models/" + pData.sModelPath + ".mdl" );

		Vector origin = pPlayer.pev.origin;
		if( IsUserCrouching(pPlayer) ) origin.z -= pData.flMinusZCrouching;
		else origin.z -= pData.flMinusZStanding;

		pPet.pev.origin = origin;

		if( flScale > 0.0f )
		{
			if( flScale > pData.flScale )
			{
				pPet.pev.scale = pData.flScale;
				pets.Tell( "ERROR: scale must be between 0.1 and " + pData.flScale + " for this pet. Using default.\n", pPlayer, HUD_PRINTTALK );
			}
			else pPet.pev.scale = flScale;
		}
		else pPet.pev.scale = pData.flScale;

		pPet.pev.solid = SOLID_NOT;
		pPet.pev.movetype = MOVETYPE_NOCLIP;
		//@pPet.pev.owner = pPlayer.edict();
		pPet.pev.nextthink = 1.0f;
		pPet.pev.sequence = 0;
		pPet.pev.gaitsequence = 0;
		pPet.pev.framerate = 1.0f;

		if( !pData.sBoneControllers.IsEmpty() )
		{
			array<string> parsed = pData.sBoneControllers.Split(":");

			for( uint i = 0; i < parsed.length() - 1; ++i )
				pPet.pev.set_controller(atoi(parsed[i]), atoi(parsed[i+1]));
		}

		cData.flScale = pPet.pev.scale;

		EHandle ePet = pPet;
		g_petUsers[sFixId] = ePet;
		g_petUserPets[sFixId] = pData.sName;
		g_petCrossover[sFixId] = cData;

		if(!bSilent)
		{
			if(g_cvarHideInfo.GetInt() <= 0)
			{
				if( flScale > 0.0f && flScale < pData.flScale )
					pets.TellAll( string(pPlayer.pev.netname) + " summoned a pet! (name: " + sPet + " - scale: " + flScale + ")\n", HUD_PRINTTALK );
				else pets.TellAll( string(pPlayer.pev.netname) + " summoned a pet! (name: " + sPet + ")\n", HUD_PRINTTALK );
			}
			else
				pets.Tell( "You summoned a pet! (name: " + sPet + ")\n", pPlayer, HUD_PRINTTALK );
		}
	}

	bool removepet( CBasePlayer@ pPlayer, bool bSilent )
	{
		if( pPlayer is null ) return false;

		string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pPlayer));

		if( g_petUsers.exists(sFixId) )
		{
			CBaseEntity@ pPet = cast<CBaseEntity@>(g_petUsers[sFixId]);

			if( pPet !is null )
			{
				g_EntityFuncs.Remove(pPet);
				g_petUsers.delete(sFixId);
				g_petUserPets.delete(sFixId);

				if( g_petCrossover.exists(sFixId) )
					g_petCrossover.delete(sFixId);

				if(!bSilent)
				{
					if( g_cvarHideInfo.GetInt() <= 0 )
						pets.TellAll( string(pPlayer.pev.netname) + "'s pet has returned home.\n", HUD_PRINTTALK );
					else
						pets.Tell( "Your pet has returned home.\n", pPlayer, HUD_PRINTTALK );
				}

				return true;
			}
			else
			{
				if(!bSilent) pets.Tell( "Error: pet registered, but has invalid pet entity?\n", pPlayer, HUD_PRINTTALK );

				return false;
			}
		}
		else
		{
			if(!bSilent) pets.Tell( "You don't have a pet!\n", pPlayer, HUD_PRINTTALK );

			return false;
		}
	}
	
	void petMenuCallback( CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem )
	{
		if( mItem !is null && pPlayer !is null )
		{
			if( mItem.m_szName == "<off>" )
				removepet( pPlayer, false );
			else
				setpet( pPlayer, mItem.m_szName, false );
		}
	}

	void forcepet( AFBaseArguments@ args )
	{
		if( args.GetString(1) != "off" && !g_petModels.exists(args.GetString(1)) )
		{
			pets.Tell( "Invalid pet!", args.User, HUD_PRINTCONSOLE );
			return;
		}

		array<CBasePlayer@> pTargets;
		if( AFBase::GetTargetPlayers(args.User, HUD_PRINTCONSOLE, args.GetString(0), 0, pTargets) )
		{
			CBasePlayer@ pTarget = null;
			for( uint i = 0; i < pTargets.length(); ++i )
			{
				@pTarget = pTargets[i];

				if( args.GetString(1) == "off" )
				{
					removepet( args.User, true );
					pets.Tell( "Removed pet from " + pTarget.pev.netname, args.User, HUD_PRINTCONSOLE );
				}
				else
				{
					setpet( pTarget, args.GetString(1), true );
					pets.Tell( "Set " + pTarget.pev.netname + " pet to \"" + args.GetString(1) + "\"", args.User, HUD_PRINTCONSOLE );
				}
			}
		}
	}

	void PetThink()
	{
		CBasePlayer@ pPlayer = null;

		for( int i = 1; i <= g_Engine.maxClients; ++i )
		{
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

			if( pPlayer !is null )
			{
				string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pPlayer));

				if( sFixId == "" ) continue;

				if( g_petUsers.exists(sFixId) )
				{
					CBaseEntity@ pPet = cast<CBaseEntity@>(g_petUsers[sFixId]);

					if( pPet !is null )
					{
						int id = pPlayer.entindex();
						if( flTimeToDie[id] > 0 && g_Engine.time > flTimeToDie[id] )
						{
							flTimeToDie[id] = 0;
							if( bRemovePet[id] )
							{
								bRemovePet[id] = false;
								removepet( pPlayer, true );
							}

							continue;
						}

						string sPet = string(g_petUserPets[sFixId]);
						PetData@ pData = cast<PetData@>(g_petModels[sPet]);

						Vector origin, origin2, velocity;

						origin2 = pPet.pev.origin;

						origin = get_offset_origin_body( pPlayer, Vector(50.0f, 0.0f, 0.0f) );

						if( IsUserCrouching(pPlayer) ) origin.z -= pData.flMinusZCrouching;
						else origin.z -= pData.flMinusZStanding;

						if( (origin - origin2).Length() > pData.flMaxDistance )
							pPet.pev.origin = origin;
						else if( (origin - origin2).Length() > pData.flMinDistance )
						{
							velocity = get_speed_vector( origin2, origin, 250.0f );
							pPet.pev.velocity = velocity;

							if( (pPet.pev.sequence != pData.iRunAnim || pPet.pev.framerate != pData.flRunSpeed) && pPlayer.IsAlive() )
							{
								pPet.pev.frame = 1;
								pPet.pev.sequence = pData.iRunAnim;
								pPet.pev.gaitsequence = pData.iRunAnim;
								pPet.pev.framerate = pData.flRunSpeed;
							}
						}
						else if( (origin - origin2).Length() < pData.flMinDistance - 5.0f )
						{
							if( (pPet.pev.sequence != pData.iIdleAnim || pPet.pev.framerate != pData.flIdleSpeed) && pPlayer.IsAlive() )
							{
								pPet.pev.frame = 1;
								pPet.pev.sequence = pData.iIdleAnim;
								pPet.pev.gaitsequence = pData.iIdleAnim;
								pPet.pev.framerate = pData.flIdleSpeed;
							}

							pPet.pev.velocity = g_vecZero;
						}

						EHandle ePet = pPet;

						origin = pPlayer.pev.origin;
						origin.z = origin2.z;
						entity_set_aim( ePet, origin );

						pPet.pev.nextthink = g_Engine.time + 1.0f;
					}
				}
			}
		}
	}

	void handle_death( CBasePlayer@ pPlayer, bool bDeletePet )
	{
		string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pPlayer));

		if( g_petUsers.exists(sFixId) )
		{
			CBaseEntity@ pPet = cast<CBaseEntity@>(g_petUsers[sFixId]);

			if( pPet !is null )
			{
				string sPet = string(g_petUserPets[sFixId]);
				PetData@ pData = cast<PetData@>(g_petModels[sPet]);
				int id = pPlayer.entindex();

				pPet.pev.frame = 1;
				pPet.pev.animtime = 100.0f;
				pPet.pev.sequence = pData.iDeathAnim;
				pPet.pev.gaitsequence = pData.iDeathAnim;

				flTimeToDie[id] = g_Engine.time + pData.flDeathLength;
				if( bDeletePet ) bRemovePet[id] = true;
			}
		}
	}

	bool IsUserCrouching( CBasePlayer@ pPlayer )
	{
		if( pPlayer !is null ) return (pPlayer.pev.flags & FL_DUCKING != 0);

		return false;
	}

	Vector get_offset_origin_body( CBasePlayer@ pPlayer, const Vector &in offset )
	{
		if( pPlayer is null ) return g_vecZero;

		Vector origin;

		Vector angles;
		angles = pPlayer.pev.angles;

		origin = pPlayer.pev.origin;

		origin.x += cos(angles.y * Math.PI / 180.0f) * offset.x;
		origin.y += sin(angles.y * Math.PI / 180.0f) * offset.x;

		origin.y += cos(angles.y * Math.PI / 180.0f) * offset.y;
		origin.x += sin(angles.y * Math.PI / 180.0f) * offset.y;

		return origin;
	}

	Vector get_speed_vector( const Vector &in origin1, const Vector &in origin2, const float &in speed )
	{
		Vector new_velocity;

		new_velocity.y = origin2.y - origin1.y;
		new_velocity.x = origin2.x - origin1.x;
		new_velocity.z = origin2.z - origin1.z;

		float num = sqrt( speed*speed / (new_velocity.y*new_velocity.y + new_velocity.x*new_velocity.x + new_velocity.z*new_velocity.z) );
		new_velocity.y *= num;
		new_velocity.x *= num;
		new_velocity.z *= num;

		return new_velocity;
	}

	void entity_set_aim( EHandle &in eEnt, const Vector &in origin2, int bone = 0 )
	{
		if( !eEnt.IsValid() ) return;

		CBaseEntity@ pEnt = eEnt.GetEntity();
		Vector origin, ent_origin, angles;

		origin = origin2;

		if( bone > 0 )
			g_EngineFuncs.GetBonePosition( pEnt.edict(), bone, ent_origin, angles );
		else
			ent_origin = pEnt.pev.origin;

		origin.x -= ent_origin.x;
		origin.y -= ent_origin.y;
		origin.z -= ent_origin.z;

		float v_length;
		v_length = origin.Length();

		Vector aim_vector;

		if( v_length > 0.0f )
		{
			aim_vector.x = origin.x / v_length;
			aim_vector.y = origin.y / v_length;
			aim_vector.z = origin.z / v_length;
		}
		else
			aim_vector = Vector(0, 90, 0);

		Vector new_angles;
		g_EngineFuncs.VecToAngles( aim_vector, new_angles );

		new_angles.x *= -1;

		if( new_angles.y > 180.0f ) new_angles.y -= 360;
		if( new_angles.y < -180.0f ) new_angles.y += 360;
		if( new_angles.y == 180.0f || new_angles.y == -180.0f ) new_angles.y = -179.999999f;

		pEnt.pev.angles = new_angles;
		pEnt.pev.fixangle = 1;
	}
}

/*
*	Changelog
*
*	Version: 	1.0
*	Date: 		November 08 2017
*	-------------------------
*	- First release
*	-------------------------
*
*	Version: 	1.2
*	Date: 		November 22 2017
*	-------------------------
*	- Players can now specify the scale of their pet (up to the number specified in the config-file)
*	- Bone controllers can now be configured in pets.txt (for models that don't face the right way)
*	- Changed CVars to .pet_hidechat and .pet_hideinfo
*	-------------------------
*
*	Version: 	1.3
*	Date: 		November 24 2017
*	-------------------------
*	- Pet scale is now saved to crossover data (for custom pet scaling)
*	-------------------------
*/