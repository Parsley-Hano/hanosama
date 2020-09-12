int dropper_weapon_box_counter = 0;
int dropper_weapon_box_counter_max = 300;

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSayDropper );
}

HookReturnCode ClientSayDropper(SayParameters@ pParams){
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	
	const CCommand@ pArguments = pParams.GetArguments();
	string str = pArguments[0];
	str.ToUppercase();
	
	if( str == "DROPAMMO" ){
		pParams.ShouldHide = true;
		
		int ammoIndex = -1;
		int ammoIndex2 = -1;
		
		//Default
		if ( pPlayer.pev.viewmodel == "models/v_medkit.mdl" ) ammoIndex = 2;
		if ( pPlayer.pev.viewmodel == "models/v_9mmhandgun.mdl" ) ammoIndex = 7;
		if ( pPlayer.pev.viewmodel == "models/v_357.mdl" ) ammoIndex = 6;
		if ( pPlayer.pev.viewmodel == "models/v_desert_eagle.mdl" ) ammoIndex = 6;
		if ( pPlayer.pev.viewmodel == "models/v_uzi.mdl" ) ammoIndex = 7;
		if ( pPlayer.pev.viewmodel == "models/v_9mmAR.mdl" ) {ammoIndex = 7; ammoIndex2 = 5;}
		if ( pPlayer.pev.viewmodel == "models/v_shotgun.mdl" ) ammoIndex = 1;
		if ( pPlayer.pev.viewmodel == "models/v_crossbow.mdl" ) ammoIndex = 12;
		if ( pPlayer.pev.viewmodel == "models/v_m16a2.mdl" ) {ammoIndex = 3; ammoIndex2 = 5;}
		if ( pPlayer.pev.viewmodel == "models/v_rpg.mdl" ) ammoIndex = 11;
		if ( pPlayer.pev.viewmodel == "models/v_gauss.mdl" ) ammoIndex = 10;
		if ( pPlayer.pev.viewmodel == "models/v_egon.mdl" ) ammoIndex = 10;
		if ( pPlayer.pev.viewmodel == "models/v_grenade.mdl" ) ammoIndex = 15;
		if ( pPlayer.pev.viewmodel == "models/v_satchel.mdl" ) ammoIndex = 14;
		if ( pPlayer.pev.viewmodel == "models/v_satchel_radio.mdl" ) ammoIndex = 14;
		if ( pPlayer.pev.viewmodel == "models/v_tripmine.mdl" ) ammoIndex = 13;
		if ( pPlayer.pev.viewmodel == "models/v_squeak.mdl" ) ammoIndex = 16;
		if ( pPlayer.pev.viewmodel == "models/v_m40a1.mdl" ) ammoIndex = 4;
		if ( pPlayer.pev.viewmodel == "models/v_saw.mdl" ) ammoIndex = 3;
		if ( pPlayer.pev.viewmodel == "models/v_spore_launcher.mdl" ) ammoIndex = 9;
		if ( pPlayer.pev.viewmodel == "models/v_displacer.mdl" ) ammoIndex = 10;
		
		//ClassicMode
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_medkit.mdl" ) ammoIndex = 2;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_9mmhandgun.mdl" ) ammoIndex = 7;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_357.mdl" ) ammoIndex = 6;
		if ( pPlayer.pev.viewmodel == "models/hl/v_357.mdl" ) ammoIndex = 6;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_9mmAR.mdl" ) {ammoIndex = 7; ammoIndex2 = 5;}
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_shotgun.mdl" ) ammoIndex = 1;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_crossbow.mdl" ) ammoIndex = 12;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_rpg.mdl" ) ammoIndex = 11;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_gauss.mdl" ) ammoIndex = 10;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_egon.mdl" ) ammoIndex = 10;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_grenade.mdl" ) ammoIndex = 15;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_satchel.mdl" ) ammoIndex = 14;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_satchel_radio.mdl" ) ammoIndex = 14;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_tripmine.mdl" ) ammoIndex = 13;
		if ( pPlayer.pev.viewmodel == "models/hlclassic/v_squeak.mdl" ) ammoIndex = 16;
		
		//Blue Shift
		if ( pPlayer.pev.viewmodel == "models/bshift/v_9mmhandgun.mdl" ) ammoIndex = 7;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_357.mdl" ) ammoIndex = 6;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_9mmar.mdl" ) {ammoIndex = 7; ammoIndex2 = 5;}
		if ( pPlayer.pev.viewmodel == "models/bshift/v_shotgun.mdl" ) ammoIndex = 1;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_crossbow.mdl" ) ammoIndex = 12;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_m16a2.mdl" ) {ammoIndex = 3; ammoIndex2 = 5;}
		if ( pPlayer.pev.viewmodel == "models/bshift/v_rpg.mdl" ) ammoIndex = 11;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_gauss.mdl" ) ammoIndex = 10;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_egon.mdl" ) ammoIndex = 10;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_grenade.mdl" ) ammoIndex = 15;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_satchel.mdl" ) ammoIndex = 14;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_satchel_radio.mdl" ) ammoIndex = 14;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_tripmine.mdl" ) ammoIndex = 13;
		if ( pPlayer.pev.viewmodel == "models/bshift/v_squeak.mdl" ) ammoIndex = 16;
		
		//Opposing Force
		if ( pPlayer.pev.viewmodel == "models/opfor/v_medkit.mdl" ) ammoIndex = 2;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_9mmhandgun.mdl" ) ammoIndex = 7;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_357.mdl" ) ammoIndex = 6;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_desert_eagle.mdl" ) ammoIndex = 6;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_uzi.mdl" ) ammoIndex = 7;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_9mmar.mdl" ) {ammoIndex = 7; ammoIndex2 = 5;}
		if ( pPlayer.pev.viewmodel == "models/opfor/v_shotgun.mdl" ) ammoIndex = 1;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_crossbow.mdl" ) ammoIndex = 12;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_m16a2.mdl" ) {ammoIndex = 3; ammoIndex2 = 5;}
		if ( pPlayer.pev.viewmodel == "models/opfor/v_rpg.mdl" ) ammoIndex = 11;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_gauss.mdl" ) ammoIndex = 10;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_egon.mdl" ) ammoIndex = 10;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_grenade.mdl" ) ammoIndex = 15;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_satchel.mdl" ) ammoIndex = 14;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_satchel_radio.mdl" ) ammoIndex = 14;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_tripmine.mdl" ) ammoIndex = 13;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_squeak.mdl" ) ammoIndex = 16;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_m40a1.mdl" ) ammoIndex = 4;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_saw.mdl" ) ammoIndex = 3;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_spore_launcher.mdl" ) ammoIndex = 9;
		if ( pPlayer.pev.viewmodel == "models/opfor/v_displacer.mdl" ) ammoIndex = 10;
		
		array<int> ammoIndexTable(19);
		for(int i = 1; i < 19;i++){
			ammoIndexTable[i] = i;
		}
		
		ammoIndexTable[2] = 3;
		ammoIndexTable[1] = 2;
		ammoIndexTable[6] = 1;
		ammoIndexTable[5] = 6;
		ammoIndexTable[4] = 5;
		ammoIndexTable[3] = 4;
		
		ammoIndexTable[0] = -1;
		
		if(ammoIndex < 0)ammoIndex=0;
		if(ammoIndex2 < 0)ammoIndex2=0;
		
		int ammoInv = 0;
		int ammoInv2 = 0;
		int ammoInvOld = pPlayer.AmmoInventory(ammoIndexTable[ammoIndex]);
		int ammoInvOld2 = pPlayer.AmmoInventory(ammoIndexTable[ammoIndex2]);
		
		str = pArguments[1];
		str.ToUppercase();
		
		if(str == "ALL"){
			
			int totalAmmo = 0;
			array<int> ammo2(19);
			for(int i = 0; i < 19; i++){
				if(i == 2)
					i++;
				
				ammo2[i] = pPlayer.AmmoInventory(ammoIndexTable[i]);
				totalAmmo = totalAmmo + ammo2[i];
				
				if(ammoIndexTable[i] > 0){
					pPlayer.m_rgAmmo(ammoIndexTable[i], 0);
				}
			}
			
			if(ammoInv > 0 || ammoInv2 > 0) {
				
				string tarName = "dropper_weaponbox_"+dropper_weapon_box_counter;
				
				CBaseEntity@ pEntity = null;
				@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, tarName);
				if( !(pEntity is null) )
					g_EntityFuncs.Remove(pEntity);
				
				CBaseEntity@ pWeaponBox = g_EntityFuncs.Create("weaponbox", pPlayer.pev.origin, pPlayer.pev.angles, false);
				
				pWeaponBox.pev.targetname = tarName;
				pWeaponBox.pev.spawnflags = 1024;
				pWeaponBox.pev.origin.z = pWeaponBox.pev.origin.z - 16.0f;
				pWeaponBox.pev.velocity.x = cos(pPlayer.pev.angles.y/180.0f*3.1415927f) * cos(pPlayer.pev.angles.x/60.0f*3.1415927f) * 160.0f;
				pWeaponBox.pev.velocity.y = sin(pPlayer.pev.angles.y/180.0f*3.1415927f) * cos(pPlayer.pev.angles.x/60.0f*3.1415927f) * 160.0f;
				pWeaponBox.pev.velocity.z = sin(pPlayer.pev.angles.x/60.0f*3.1415927f) * 160.0f + 160.0f ;

				array<string> strArr(1);
				strArr[0] = tarName;
				array<int> intArr(4);
				intArr[0] = ammoIndex;
				intArr[1] = ammoIndex2;
				intArr[2] = ammoInv;
				intArr[3] = ammoInv2;
				
				g_Scheduler.SetTimeout( "AmmoHandling", 0.01, strArr, intArr );
				
				dropper_weapon_box_counter++;
				if ( dropper_weapon_box_counter >= dropper_weapon_box_counter_max ) dropper_weapon_box_counter = 0;
				
			}else if(ammoIndex != 2){
				string str1 = "AMMO-DROPPER: Couldn't drop Ammo!\n";
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, str1);
			}
			
			
			
			
			
		}else{
			
			int customDrop = atoi(pArguments[1]);
			int customDrop2 = atoi(pArguments[2]);
			
			if (ammoIndexTable[ammoIndex] == 16){
				if(customDrop<1){
					ammoInv = 1;
				}else{
					if (customDrop>ammoInvOld) customDrop=ammoInvOld;
					ammoInv = customDrop;
				}
				pPlayer.m_rgAmmo(ammoIndexTable[ammoIndex], ammoInvOld-ammoInv);
			}else if(ammoIndex == 2){
				string str1 = "AMMO-DROPPER: CubeMath doesn't know the Ammoname of weapon_medkit. Sorry\n";
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, str1);
			}else if(ammoIndexTable[ammoIndex] > 0){
				if(customDrop<1){
					ammoInv = pPlayer.AmmoInventory(ammoIndexTable[ammoIndex]);
					ammoInv = ammoInv-ammoInv*9/10;
				}else{
					if (customDrop>ammoInvOld) customDrop=ammoInvOld;
					ammoInv = customDrop;
				}
				pPlayer.m_rgAmmo(ammoIndexTable[ammoIndex], ammoInvOld-ammoInv);
			}
			if(ammoIndexTable[ammoIndex2] > 0){
				if(customDrop2<1){
					ammoInv2 = pPlayer.AmmoInventory(ammoIndexTable[ammoIndex2]);
					ammoInv2 = ammoInv2-ammoInv2*9/10;
				}else{
					if (customDrop2>ammoInvOld2) customDrop2=ammoInvOld2;
					ammoInv2 = customDrop2;
				}
				pPlayer.m_rgAmmo(ammoIndexTable[ammoIndex2], ammoInvOld2-ammoInv2);
			}
			
			if(ammoInv > 0 || ammoInv2 > 0) {
				
				string tarName = "dropper_weaponbox_"+dropper_weapon_box_counter;
				
				CBaseEntity@ pEntity = null;
				@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, tarName);
				if( !(pEntity is null) )
					g_EntityFuncs.Remove(pEntity);
				
				CBaseEntity@ pWeaponBox = g_EntityFuncs.Create("weaponbox", pPlayer.pev.origin, pPlayer.pev.angles, false);
				
				pWeaponBox.pev.targetname = tarName;
				pWeaponBox.pev.spawnflags = 1024;
				pWeaponBox.pev.origin.z = pWeaponBox.pev.origin.z - 16.0f;
				pWeaponBox.pev.velocity.x = cos(pPlayer.pev.angles.y/180.0f*3.1415927f) * cos(pPlayer.pev.angles.x/60.0f*3.1415927f) * 160.0f;
				pWeaponBox.pev.velocity.y = sin(pPlayer.pev.angles.y/180.0f*3.1415927f) * cos(pPlayer.pev.angles.x/60.0f*3.1415927f) * 160.0f;
				pWeaponBox.pev.velocity.z = sin(pPlayer.pev.angles.x/60.0f*3.1415927f) * 160.0f + 160.0f ;

				array<string> strArr(1);
				strArr[0] = tarName;
				array<int> intArr(4);
				intArr[0] = ammoIndex;
				intArr[1] = ammoIndex2;
				intArr[2] = ammoInv;
				intArr[3] = ammoInv2;
				
				g_Scheduler.SetTimeout( "AmmoHandling", 0.01, strArr, intArr );
				
				dropper_weapon_box_counter++;
				if ( dropper_weapon_box_counter >= dropper_weapon_box_counter_max ) dropper_weapon_box_counter = 0;
				
			}else if(ammoIndex != 2){
				string str1 = "AMMO-DROPPER: Couldn't drop Ammo!\n";
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, str1);
			}
		}
		
		return HOOK_HANDLED;
	}
	
	return HOOK_CONTINUE;
}

void AmmoHandling(array<string>@ strArr, array<int>@ intArr){
	CBaseEntity@ pWeaponBox = null;
	@pWeaponBox = g_EntityFuncs.FindEntityByTargetname(pWeaponBox, strArr[0]);

	if( pWeaponBox !is null ) {
		if(intArr[0]==1 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "buckshot", intArr[2] );
		if(intArr[0]==2 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "Health points", intArr[2] );
		if(intArr[0]==3 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "556", intArr[2] );
		if(intArr[0]==4 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "m40a1", intArr[2] );
		if(intArr[1]==5 && intArr[3]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "ARgrenades", intArr[3] );
		if(intArr[0]==6 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "357", intArr[2] );
		if(intArr[0]==7 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "9mm", intArr[2] );
		if(intArr[0]==9 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "sporeclip", intArr[2] );
		if(intArr[0]==10 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "uranium", intArr[2] );
		if(intArr[0]==11 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "rockets", intArr[2] );
		if(intArr[0]==12 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "bolts", intArr[2] );
		if(intArr[0]==13 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "Trip Mine", intArr[2] );
		if(intArr[0]==14 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "Satchel Charge", intArr[2] );
		if(intArr[0]==15 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "Hand Grenade", intArr[2] );
		if(intArr[0]==16 && intArr[2]>0)
			g_EntityFuncs.DispatchKeyValue( pWeaponBox.edict(), "Snarks", intArr[2] );
	}
}
