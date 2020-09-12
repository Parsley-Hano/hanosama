/*
*	Network-Banhammer
*	Enter in Chat: admin_netban <Name or SteamID> <Time in minutes>
*	To Ban and Network-Ban the Target
*	If time is empty then the duration is permanent
*	
*	Plugin by CubeMath with some help of friends.
*/


final class IPAddressPlayerData {
	private string address;
	private CBasePlayer@ pPlayer;
	
	IPAddressPlayerData( string network_address ){
		address = network_address;
	}
	
	IPAddressPlayerData( CBasePlayer@ ply, string network_address ){
		address = network_address;
		@pPlayer = ply;
	}
	
	CBasePlayer@ Player{
		get const { return pPlayer; }
	}
	
	void setBasePlayer(CBasePlayer@ ply){
		@pPlayer = ply;
	}
	
	string getIPAddress(){
		return address;
	}
}

array<IPAddressPlayerData@> g_IPAddressPlayerData;

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath/" );
	
	//Only admins can use this
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_YES );
	
	g_IPAddressPlayerData.resize( g_Engine.maxClients );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientConnected, @ClientConnected );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSayBanHam );
	
	CBasePlayer@ pPlayer = null;
	
	//In case the plugin is being reloaded, fill in the list manually to account for it. Saves a lot of console output.
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
		@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
	   
		if( pPlayer is null || !pPlayer.IsConnected() )
			continue;
		
		IPAddressPlayerData data( pPlayer, "" );
		@g_IPAddressPlayerData[ pPlayer.entindex() - 1 ] = @data;
	}
}

void MapInit() {
}


/*
* Gets the formatted Time in the console
*/
string getFormattedMinutes(float minutes){
	if(minutes == 0.0f){
		return "Permanent";
	}
	
	int minutesI;
	if(minutes < 1.0f){
		minutesI = int(minutes*6000.0f);
		if(minutesI == 100){
			return "1.00 Second";
		}else if(minutesI < 1000){
			return "" + (minutesI/100) + "." + (minutesI%100/10) + (minutesI%10) + " Seconds";
		}else{
			return "" + (minutesI/1000) + (minutesI%1000/100) + "." + (minutesI%100/10) + " Seconds";
		}
	}
	
	if(minutes < 60.0f){
		minutesI = int(minutes*100.0f);
		if(minutesI == 100){
			return "1.00 Minute";
		}else if(minutesI < 1000){
			return "" + (minutesI/100) + "." + (minutesI%100/10) + (minutesI%10) + " Minutes";
		}else{
			return "" + (minutesI/1000) + (minutesI%1000/100) + "." + (minutesI%100/10) + " Minutes";
		}
	}
	
	minutes = minutes / 60.0f;
	
	if(minutes < 24.0f){
		minutesI = int(minutes*100.0f);
		if(minutesI == 100){
			return "1.00 Hour";
		}else if(minutesI < 1000){
			return "" + (minutesI/100) + "." + (minutesI%100/10) + (minutesI%10) + " Hours";
		}else{
			return "" + (minutesI/1000) + (minutesI%1000/100) + "." + (minutesI%100/10) + " Hours";
		}
	}
	
	minutes = minutes / 24.0f;
	
	if(minutes < 7.0f){
		minutesI = int(minutes*100.0f);
		if(minutesI == 100){
			return "1.00 Day";
		}else{
			return "" + (minutesI/100) + "." + (minutesI%100/10) + (minutesI%10) + " Days";
		}
	}
	
	minutes = minutes / 7.0f;
	
	if(minutes < 4.348125f){
		minutesI = int(minutes*100.0f);
		if(minutesI == 100){
			return "1.00 Week";
		}else{
			return "" + (minutesI/100) + "." + (minutesI%100/10) + (minutesI%10) + " Weeks";
		}
	}
	
	minutes = minutes / 4.348125f;
	
	if(minutes < 12.0f){
		minutesI = int(minutes*100.0f);
		if(minutesI == 100){
			return "1.00 Month";
		}else if(minutesI < 1000){
			return "" + (minutesI/100) + "." + (minutesI%100/10) + (minutesI%10) + " Months";
		}else{
			return "" + (minutesI/1000) + (minutesI%1000/100) + "." + (minutesI%100/10) + " Months";
		}
	}
	
	minutes = minutes / 12.0f;
	
	if(minutes < 100.0f){
		minutesI = int(minutes*100.0f);
		if(minutesI == 100){
			return "1.00 Year";
		}else if(minutesI < 1000){
			return "" + (minutesI/100) + "." + (minutesI%100/10) + (minutesI%10) + " Years";
		}else{
			return "" + (minutesI/1000) + (minutesI%1000/100) + "." + (minutesI%100/10) + " Years";
		}
	}
	
	return "Permanent";
}


bool adminNetBan( SayParameters@ pParams ) {
	
	const CCommand@ args = pParams.GetArguments();
	if ( g_PlayerFuncs.AdminLevel( pParams.GetPlayer() ) >= ADMIN_YES && args[0] == "admin_netban" ){
		pParams.ShouldHide = true;
		
		string s = "Permanent";
		string s2 = "Breaking Rules";
		float flBanTime = 0.0f;
		
		if( args.ArgC() == 3 ) {
			flBanTime = atof( args[ 2 ] );
			s = getFormattedMinutes(flBanTime);
			
			if( args.ArgC() >= 4 ){
				for(int i = 3; i < args.ArgC(); i++){
					if(i > 3){
						s2 = s2+" "+args[i];
					}else{
						s2 = args[i];
					}
				}
			}
		}
		
		CBasePlayer@ ply1 = GetTargetPlayer( args[ 1 ] );
		
		if( g_PlayerFuncs.AdminLevel( ply1 ) >= ADMIN_YES ) {
			g_PlayerFuncs.ClientPrint( pParams.GetPlayer(), HUD_PRINTTALK, "Can not Network-Ban Admins!\n" ); 
			
			return true;
		}
		
		if( args.ArgC() > 1 && ply1 !is null ) {
			
			string aStr = g_EngineFuncs.GetPlayerUserId( ply1.edict() );
			string cStr = ply1.pev.netname;
			
			IPAddressPlayerData@ ipPly = g_IPAddressPlayerData[ ply1.entindex() - 1 ];
			
			string bStr = "";
			if(ipPly !is null){
				bStr = ipPly.getIPAddress();
				bStr = bStr.SubString(0, bStr.Length()-6);
			}
			
			g_Game.AlertMessage( at_logged, "NETWORK-BANNED( "+s+" ): \"" + cStr + "\" Reason: " + s2 + "\n" );
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "NETWORK-BANNED( "+s+" ): \"" + cStr + "\" Reason: " + s2 + "\n" );
			g_EngineFuncs.ServerCommand("kick \"#" + aStr + "\" \"NETWORK-BANNED( "+s+" ): "+s2+"\"\n");
			g_EngineFuncs.ServerCommand("banid "+flBanTime+" " + g_EngineFuncs.GetPlayerAuthId(ply1.edict()) + "\n");
			
			if(bStr.Length()>6){
				string ipStr = "addip "+flBanTime+" "+bStr+"\n";
				g_EngineFuncs.ServerCommand(ipStr);
			}else{
				g_PlayerFuncs.ClientPrint( pParams.GetPlayer(), HUD_PRINTTALK, "WARNING: Invalid IP-Address!\n" ); 
			}
			
			g_EngineFuncs.ServerExecute();
		}else{
			g_PlayerFuncs.ClientPrint( pParams.GetPlayer(), HUD_PRINTTALK, "Usage: admin_netban <name or steamID> <time in minutes> <ban reason>.\n" ); 
		}
		return true;
	}
	
	return false;
}

/*
* Helper function to get a player by Steam Id
* Stolen by CubeMath from PlayerManagement
*/
CBasePlayer@ GetPlayerBySteamId( const string& in szTargetSteamId ) {
	CBasePlayer@ pTarget;
	
	for( int iIndex = 1; iIndex <= g_Engine.maxClients; ++iIndex ) {
		@pTarget = g_PlayerFuncs.FindPlayerByIndex( iIndex );
		
		if( pTarget !is null ) {
			const string szSteamId = g_EngineFuncs.GetPlayerAuthId( pTarget.edict() );
			
			if( szSteamId == szTargetSteamId )
				return pTarget;
		}
	}
	
	return null;
}

/*
* Helper function to get a player either by name or Steam Id
* Stolen by CubeMath from PlayerManagement
*/
CBasePlayer@ GetTargetPlayer( const string& in szNameOrSteamId ) {
	CBasePlayer@ pTarget = g_PlayerFuncs.FindPlayerByName( szNameOrSteamId, false );
		
	if( pTarget !is null )
		return pTarget;
		
	return GetPlayerBySteamId( szNameOrSteamId );
}

HookReturnCode ClientConnected( edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason ) {
	
	IPAddressPlayerData data( szIPAddress );
	@g_IPAddressPlayerData[ g_EntityFuncs.Instance(pEntity).entindex() - 1 ] = @data;
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){

	@g_IPAddressPlayerData[ pPlayer.entindex() - 1 ] = null;
	
	return HOOK_CONTINUE;
}

HookReturnCode ClientSayBanHam( SayParameters@ pParams ) {
	if( adminNetBan( pParams ) )
		return HOOK_HANDLED;
		
	return HOOK_CONTINUE;
}
