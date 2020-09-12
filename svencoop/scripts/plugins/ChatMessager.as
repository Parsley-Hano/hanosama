final class CooldownTimes {
	float m_flStuckMessageTime;
	float m_flClassicMessageTime;
	float m_flMotdMessageTime;
	float m_flGlowMessageTime;
	float m_flMuteMessageTime;
	float m_flVoteMessageTime;
	float m_flAdminMessageTime;
	float m_flPrivateMessageTime;
	float m_flFlashlightMessageTime;
	float m_flJoinMessageTime;
	float m_flLongJumpMessageTime;
	float m_flRespectMessageTime;
	float m_flDropperMessageTime;
	float m_flDonationMessageTime;
	
	CooldownTimes(){
		ResetData();
	}
	
	void ResetData(){
		m_flStuckMessageTime = g_Engine.time;
		m_flClassicMessageTime = g_Engine.time;
		m_flMotdMessageTime = g_Engine.time;
		m_flGlowMessageTime = g_Engine.time;
		m_flMuteMessageTime = g_Engine.time;
		m_flVoteMessageTime = g_Engine.time;
		m_flAdminMessageTime = g_Engine.time;
		m_flPrivateMessageTime = g_Engine.time;
		m_flFlashlightMessageTime = g_Engine.time;
		m_flJoinMessageTime = g_Engine.time;
		m_flLongJumpMessageTime = g_Engine.time;
		m_flRespectMessageTime = g_Engine.time;
		m_flDropperMessageTime = g_Engine.time;
		m_flDonationMessageTime = g_Engine.time;
	}
}

CooldownTimes@ g_CooldownTimes;

void PluginInit() {
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath/" );
	
	CooldownTimes ctimes();
	@g_CooldownTimes = @ctimes;
	
	Initialize();
}

void MapInit() {
	g_CooldownTimes.ResetData();
}

void Initialize() {
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

void ChatCheck( SayParameters@ m_pArgs ) {
	string str = m_pArgs.GetCommand();
	str.ToUppercase();
	bool strTest = false;
	bool readyPrint = true;
	
	if (str.Find("ADMIN_") == 0) return;
	
	strTest = (str.Find("STUCK") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("CANT MOVE") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("CAN'T MOVE") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("UNABLE TO MOVE") < String::INVALID_INDEX);
	strTest = strTest && (g_CooldownTimes.m_flStuckMessageTime < g_Engine.time);
	
	if (strTest && readyPrint) {
		g_CooldownTimes.m_flStuckMessageTime = g_Engine.time + 30.0f;
		string aStr = "SERVER: Press L-Key in case you are stuck.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"Press L-Key in case you are stuck.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}
	
	strTest = (str.Find("JOIN") < String::INVALID_INDEX);
	strTest = strTest || ((str.Find("PLAY") < String::INVALID_INDEX) && !(str.Find("PLAYER") < String::INVALID_INDEX));
	strTest = strTest || (str.Find("SPAWN") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("SPECTA") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("OBSERVER") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("ENTER") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("ROAM") < String::INVALID_INDEX);
	strTest = strTest && (g_CooldownTimes.m_flJoinMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flJoinMessageTime = g_Engine.time + 60.0f;
		string aStr = "SERVER: People will join the game as soon somebody gets the Respawn-Point / Level Change.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"People will join the game as soon somebody gets the Respawn-Point / Level Change.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}

	strTest = (str.Find("PRIVATE") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("LEAVE") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("PLEASE LEFT") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("GET OUT") < String::INVALID_INDEX);
	strTest = strTest || ((str.Find("QUIT") < String::INVALID_INDEX) && !(str.Find("QUITE") < String::INVALID_INDEX));
	strTest = strTest || (str.Find("DISCONNECT") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("ALONE") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("SOLO") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("DONT WANT YOU") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("DON'T WANT YOU") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("DO NOT WANT YOU") < String::INVALID_INDEX);
	strTest = strTest && (g_CooldownTimes.m_flPrivateMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flPrivateMessageTime = g_Engine.time + 30.0f;
		string aStr = "SERVER: This is a Public-Server. Privatising is ban-able.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"This is a Public-Server. Privatising is ban-able.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}
	
	strTest = (str.Find("LIGHT") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("FLASH") < String::INVALID_INDEX);
	strTest = strTest && (g_CooldownTimes.m_flFlashlightMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flFlashlightMessageTime = g_Engine.time + 90.0f;
		string aStr = "SERVER: Enter \"r_dynamic 0\" in your console to disable flashlight.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"Enter \"r_dynamic 0\" in your console to disable flashlight.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}

	strTest = (str.Find("MUTE") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("MUTING") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("SHUT UP") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("STFU") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("TURN OFF") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("MY EARS") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("BE QUIET") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("ANNOYING") < String::INVALID_INDEX);
	strTest = strTest && (g_CooldownTimes.m_flMuteMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flMuteMessageTime = g_Engine.time + 30.0f;
		string aStr = "SERVER: Click on Scoreboard to make a Cursor appear then click on the Person to mute.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"Click on Scoreboard to make a Cursor appear then click on the Person to mute.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}

	strTest = (str.Find("VOTE") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("VOTIN") < String::INVALID_INDEX);

	strTest = strTest && (g_CooldownTimes.m_flVoteMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flVoteMessageTime = g_Engine.time + 60.0f;
		string aStr = "SERVER: Voting disabled, due to high amount of Randomvoting.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"Voting disabled, due to high amount of Randomvoting.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}

	strTest = (str.Find("KICK") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("BAN") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("REPORT") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("ADMIN") < String::INVALID_INDEX);
	strTest = strTest && (g_CooldownTimes.m_flAdminMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flAdminMessageTime = g_Engine.time + 60.0f;
		string aStr = "SERVER: Admin-Contact Information can you find on the Server-Rules.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"Admin-Contact Information can you find on the Server-Rules.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}

	strTest = (str.Find("JUMP") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("LONG") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("ROCKET") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("JETPACK") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("JET-PACK") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("JET PACK") < String::INVALID_INDEX);
	strTest = strTest && (g_CooldownTimes.m_flLongJumpMessageTime < g_Engine.time);

	string mapname = g_Engine.mapname.opImplConv();
	bool mapTest = mapname.opEquals("hl_c13_a4");
	mapTest = mapTest || mapname.opEquals("hl_c14");
	mapTest = mapTest || mapname.opEquals("hl_c15");
	mapTest = mapTest || mapname.opEquals("hl_c16_a1");
	mapTest = mapTest || mapname.opEquals("hl_c16_a2");
	mapTest = mapTest || mapname.opEquals("hl_c16_a3");
	mapTest = mapTest || mapname.opEquals("hl_c16_a4");
	mapTest = mapTest || mapname.opEquals("hl_c17");

	if (strTest && mapTest && readyPrint) {
		g_CooldownTimes.m_flLongJumpMessageTime = g_Engine.time + 30.0f;
		string aStr = "SERVER: To use long jump, crouch then quickly jump while in motion.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"To use long jump, crouch then quickly jump while in motion.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}

	strTest = (str.Find("CLASSIC") < String::INVALID_INDEX);
	strTest = strTest && (g_CooldownTimes.m_flClassicMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flClassicMessageTime = g_Engine.time + 60.0f;
		string aStr = "SERVER: More Information about Classic-Mode can you find in Rules.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"More Information about Classic-Mode can you find in Rules.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}

	strTest = (str.Find("RULE") < String::INVALID_INDEX);
	strTest = strTest || ((str.Find("MENU") < String::INVALID_INDEX) && !(str.Find("TRAIL MENU") < 2) && !(str.Find("GLOW MENU") < 2));
	strTest = strTest || (str.Find("MOTD") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("INFO") < String::INVALID_INDEX);
	strTest = strTest && (g_CooldownTimes.m_flMotdMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flMotdMessageTime = g_Engine.time + 60.0f;
		string aStr = "SERVER: Press F2-Key to open the Server-Rules.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"Press F2-Key to open the Server-Rules.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}

	strTest = (str.Find("TRAIL ") < 2);
	strTest = strTest || (str.Find("GLOW ") < 2);
	strTest = strTest || (str.Find("SHOP") < 2);
	strTest = strTest || (str.Find("STORE") < 2);
	strTest = strTest || (str.Find("BUY") < 2);
	strTest = strTest && (g_CooldownTimes.m_flGlowMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flGlowMessageTime = g_Engine.time + 120.0f;
		string aStr = "SERVER: Nope.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"Nope.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}

	strTest = (str.Find("DROP") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("AMMO") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("STEAL") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("STOLE") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("THIEF") < String::INVALID_INDEX);
	strTest = strTest && (g_CooldownTimes.m_flDropperMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flDropperMessageTime = g_Engine.time + 60.0f;
		string aStr = "SERVER: Write: Dropammo <primary-count> <secondary-count> to drop ammo.\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"Write: Dropammo <primary-count> <secondary-count> to drop ammo.\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}

	strTest = (str.Find("DONATE") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("DONATION") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("MONEY") < String::INVALID_INDEX);
	strTest = strTest || (str.Find("DOLLAR") < String::INVALID_INDEX);
	strTest = strTest || ((str.Find("EURO") < String::INVALID_INDEX) && !(str.Find("EUROP") < String::INVALID_INDEX));
	strTest = strTest && (g_CooldownTimes.m_flDonationMessageTime < g_Engine.time);

	if (strTest && readyPrint) {
		g_CooldownTimes.m_flDonationMessageTime = g_Engine.time + 100.0f;
		string aStr = "SERVER: Donate to CubeMath via PayPal: BrianLessmann@gmail.com\n";
		g_Game.AlertMessage( at_logged, "\"SERVER\" says \"Donate to CubeMath via PayPal: BrianLessmann@gmail.com\"\n" );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr ); 
		readyPrint = false;
	}
}

HookReturnCode ClientSay( SayParameters@ pParams ) {
	ChatCheck( pParams );
	
	return HOOK_CONTINUE;
}
