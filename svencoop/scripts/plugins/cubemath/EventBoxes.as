
final class EventBox {
	//Position of Object
	Vector ori;
	
	//Yaw of Object
	float ang;
	
	//ammoArray[0]: Positive number = Item
	//ammoArray[0]: Minus one = Headcrab
	// Battery, 9mm, 357, Shell, Armburst-Bolt, M16-Bullet, AR-Grenade, RPG, Uranium, Grenade, Satchel, Tripmine and Snarks
	array<int> ammoArray = {0,0,0,0,0,0,0,0,0,0,0,0,0};
	
	int classify;
	
	bool useFirst;
	
	EventBox(Vector o, float a, int idx, int c){
		ori = o;
		ang = a;
		ammoArray[0] = idx;
		useFirst = true;
		classify = c;
	}
}

int numberPeople;

void loadFiles(){
	File@ pFile = g_FileSystem.OpenFile( "scripts/plugins/store/EventItemList.txt", OpenFile::READ );
	File@ pFile2 = g_FileSystem.OpenFile( "scripts/plugins/store/EventAmmoList.txt", OpenFile::READ );
	
	if( pFile is null || !pFile.IsOpen() ) return;
	if( pFile2 is null || !pFile2.IsOpen() ) return;
	
	//Step 1: Set Positions and Angles from 1st File
	string line;
	string mapname = g_Engine.mapname;
	int arrSize = 0;
	
	array<EventBox@> boxes;
	
	while( !pFile.EOFReached() ){
		pFile.ReadLine( line );
		
		if(line.Length() < 13) continue;
		if(line.Find("//") != String::INVALID_INDEX) continue;
		
		array<string> subLines = line.Split(",");
		
		if(subLines.length < 5) continue;
		if(subLines[1].Length() < 5) continue;
		if(mapname != subLines[0]) continue;
		
		float randomNumber = Math.RandomFloat(0.0f, 100.0f);
		float itemChance = atof( subLines[3] );
		float monsterChance = atof( subLines[4] );
		
		if(randomNumber >= itemChance + monsterChance) continue;
		
		array<string> sub1subLines = subLines[1].Split(" ");
		if(sub1subLines.length != 3) continue;
		
		Vector originPos = Vector(atof( sub1subLines[0] ), atof( sub1subLines[1] ), atof( sub1subLines[2] ));
		
		++arrSize;
		boxes.resize( arrSize );
		
		if(randomNumber < itemChance){
			//Create Weaponbox
			float maxRandom = 0.0f;
			for(uint i = 6; i < subLines.length; i+=2){
				maxRandom += atof( subLines[i] );
			}
			
			randomNumber = Math.RandomFloat(0.0f, maxRandom);
			
			for(uint i = 6; i < subLines.length; i+=2){
				float currRandom = atof( subLines[i] );
				if(randomNumber <= currRandom){
					EventBox data(originPos, atof( subLines[2] ), atoi( subLines[i-1] ), 0);
					@boxes[ arrSize-1 ] = @data;
					break;
				}
				randomNumber -= currRandom;
			}
		}else{
			//Create Headcrab
			if(subLines.length%2 == 0){
				EventBox data(originPos, atof( subLines[2] ), -1, atoi( subLines[subLines.length-1] ));
				@boxes[ arrSize-1 ] = @data;
			}else{
				EventBox data(originPos, atof( subLines[2] ), -1, 0);
				@boxes[ arrSize-1 ] = @data;
			}
		}
	}

	pFile.Close();
	
	//Step 2: Insert Ammo-Data into Weaponboxes using 2nd File
	int validCounter = 0;
	
	while( !pFile2.EOFReached() ){
		pFile2.ReadLine( line );
		
		if(line.Length() < 25) continue;
		if(line.Find("//") != String::INVALID_INDEX) continue;
		
		array<string> subLines = line.Split(" ");
		
		if(subLines.length != 13) continue;
		
		for(int i = 0; i < arrSize; i++){
			EventBox@ eBox = boxes[i];
			
			if(eBox.ammoArray[0] != validCounter) continue;
			if(!eBox.useFirst) continue;
			
			for(uint j = 0; j < 13; j++){
				eBox.ammoArray[j] = atoi( subLines[j] );
			}
			eBox.useFirst = false;
		}
		++validCounter;
	}
	pFile2.Close();
	
	//Step 3: Create actual Entities
	for(int i = 0; i < arrSize; ++i){
		
		EventBox@ eBox = boxes[i];
		
		string angStr = "0 " + eBox.ang + " 0";
		
		if(eBox.ammoArray[0] == -1){
			string posStr = "" + eBox.ori.x + " " + eBox.ori.y + " " + eBox.ori.z;
			string claStr = "" + eBox.classify;
			string dmgStr = "10";
			if(numberPeople > 15){
				dmgStr = "0";
			}
			dictionary keyvalues = {
				{ "model", "models/cubemath/pumpkinheadcrab.mdl" },
				{ "soundlist", "../headcrabpumpkin/replace.txt" },
				{ "health", "75" },
				{ "gag", "-1" },
				{ "dmg", dmgStr },
				{ "origin", posStr },
				{ "angles", angStr },
				{ "classify", claStr },
				{ "displayname", "Pumpkin" },
				{ "spawnflags", "4" }
			};
			g_EntityFuncs.CreateEntity("monster_headcrab", keyvalues);
			
			// string outStr = "EVIL: " + posStr + "\n";
			// g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, outStr ); 
		}else{
			if(eBox.ammoArray[0] == 0){
				string posStr = "" + eBox.ori.x + " " + eBox.ori.y + " " + (1+eBox.ori.z);
				string str01 = "" + eBox.ammoArray[1];
				string str02 = "" + eBox.ammoArray[2];
				string str03 = "" + eBox.ammoArray[3];
				string str04 = "" + eBox.ammoArray[4];
				string str05 = "" + eBox.ammoArray[5];
				string str06 = "" + eBox.ammoArray[6];
				string str07 = "" + eBox.ammoArray[7];
				string str08 = "" + eBox.ammoArray[8];
				string str09 = "" + eBox.ammoArray[9];
				string str10 = "" + eBox.ammoArray[10];
				string str11 = "" + eBox.ammoArray[11];
				string str12 = "" + eBox.ammoArray[12];
				dictionary keyvalues = {
					{ "model", "models/cubemath/pumpkinheadcrab.mdl" },
					{ "sequencename", "idle" },
					{ "sequence", "0" },
					{ "movetype", "0" },
					{ "origin", posStr },
					{ "angles", angStr },
					{ "m_flCustomRespawnTime", "-1" },
					{ "bullet9mm", str01 },
					{ "bullet357", str02 },
					{ "buckshot", str03 },
					{ "bolts", str04 },
					{ "bullet556", str05 },
					{ "ARgrenades", str06 },
					{ "rockets", str07 },
					{ "uranium", str08 },
					{ "handgrenade", str09 },
					{ "satchelcharge", str10 },
					{ "tripmine", str11 },
					{ "Snarks", str12 },
					{ "spawnflags", "1152" }
				};
				g_EntityFuncs.CreateEntity("weaponbox", keyvalues);
				
				// string outStr = "AMMO: " + posStr + "\n";
				// g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, outStr ); 
			}else{
				string posStr = "" + eBox.ori.x + " " + eBox.ori.y + " " + eBox.ori.z;
				string str01 = "" + eBox.ammoArray[0];
				dictionary keyvalues = {
					{ "model", "models/cubemath/pumpkinheadcrab.mdl" },
					{ "health", str01 },
					{ "sequencename", "idle" },
					{ "sequence", "0" },
					{ "movetype", "5" },
					{ "origin", posStr },
					{ "angles", angStr },
					{ "m_flCustomRespawnTime", "-1" },
					{ "spawnflags", "1152" }
				};
				g_EntityFuncs.CreateEntity("item_battery", keyvalues);
				
				// string outStr = "HEV : " + posStr + "\n";
				// g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, outStr ); 
			}
		}
	}
	countPeople();
}

void countPeople(){
	numberPeople = 0;
	CBasePlayer@ pPlayer = null;
	
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		
		if(!( pPlayer is null || !pPlayer.IsConnected() ))
			++numberPeople;
	}
}

void EBPrecache(){
	g_Game.PrecacheModel( "models/cubemath/pumpkinheadcrab.mdl" );
	g_SoundSystem.PrecacheSound( "headcrabpumpkin/hc_attack1.wav" );
	g_SoundSystem.PrecacheSound( "headcrabpumpkin/hc_attack2.wav" );
	g_SoundSystem.PrecacheSound( "headcrabpumpkin/hc_attack3.wav" );
	g_SoundSystem.PrecacheSound( "headcrabpumpkin/hc_die1.wav" );
	g_SoundSystem.PrecacheSound( "headcrabpumpkin/hc_die2.wav" );
	g_SoundSystem.PrecacheSound( "headcrabpumpkin/hc_headbite.wav" );
	g_SoundSystem.PrecacheSound( "null.wav" );
}

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	
	countPeople();
}

void MapInit() {
	EBPrecache();
	g_Scheduler.SetTimeout( "loadFiles", 2.0 );
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ){

	if (g_Engine.time > 3.0) countPeople();
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){

	if (g_Engine.time > 3.0) countPeople();
	
	return HOOK_CONTINUE;
}
