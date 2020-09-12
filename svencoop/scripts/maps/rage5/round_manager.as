class round_manager : ScriptBaseEntity
{
	int szRounds = 5;
	int szRound = 0;
	int szRoundTime = 120;
	int szRoundTimer = 120;
	
	int warmUpTime = 30;
	int betweenRoundsTime = 15;
	bool roundActive = false;
	
	string texterTime = "";
	string szTexterTime = "rc_timer";
	string szDoor = "rc_door";	
			
	void Spawn()
	{
		SetThink( ThinkFunction( this.Think ) );		
	}
	
	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		szRoundTimer = warmUpTime;
		self.pev.nextthink = g_Engine.time + 1;
	}
	
	void Think()
	{
		
		if(szRound <= szRounds)
		{
			szRoundTimer--;
			DisplayRoundTime();
		}
		
		if(szRoundTimer == 0)
		{
			// Warm up ends
			if(szRound == 0)
			{
				roundActive = true;
				szRound++;
				szRoundTimer = szRoundTime;
				string szStartManager = "rc_manager";
				g_EntityFuncs.FireTargets( szStartManager, @self, @self, USE_TOGGLE);
				g_EntityFuncs.FireTargets( szDoor, @self, @self, USE_TOGGLE);
				
				string sound1 = "rc_music1";
				g_EntityFuncs.FireTargets( sound1, @self, @self, USE_TOGGLE);
			}
			else
			{
				// Round ends
				if(roundActive)
				{
					roundActive = false;					
					szRound++;
					szRoundTimer = betweenRoundsTime;
					if(szRound == (szRounds + 1)){ EndGame(); }
					g_EntityFuncs.FireTargets( szDoor, @self, @self, USE_TOGGLE);
					
					if(szRound == 2)
					{
						string sound1 = "rc_music1";
						g_EntityFuncs.FireTargets( sound1, @self, @self, USE_TOGGLE);
					}
					else if(szRound == 3)
					{
						string sound1 = "rc_music1";
						g_EntityFuncs.FireTargets( sound1, @self, @self, USE_TOGGLE);
					}
					else if(szRound == 4)
					{
						string sound1 = "rc_music2";
						g_EntityFuncs.FireTargets( sound1, @self, @self, USE_TOGGLE);
					}
					else if(szRound == 5)
					{
						string sound1 = "rc_music2";
						g_EntityFuncs.FireTargets( sound1, @self, @self, USE_TOGGLE);
					}
					else if(szRound == 6)
					{
						string sound1 = "rc_music3";
						g_EntityFuncs.FireTargets( sound1, @self, @self, USE_TOGGLE);
					}
					
					int actionPause = 100 + szRound - 1;
					string manager = "rc_manager";
					g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, manager).edict(), "action", actionPause );
					g_EntityFuncs.FireTargets( manager, @self, @self, USE_TOGGLE);
				}
				// Between round ends
				else
				{
					roundActive = true;
					szRoundTimer = szRoundTime;
					
					string nextRound = "rc_round" + szRound;
					g_EntityFuncs.FireTargets( nextRound, @self, @self, USE_TOGGLE);
					g_EntityFuncs.FireTargets( szDoor, @self, @self, USE_TOGGLE);
					
					if(szRound == 2)
					{
						string sound1 = "rc_music1";
						g_EntityFuncs.FireTargets( sound1, @self, @self, USE_TOGGLE);
					}
					else if(szRound == 3)
					{
						string sound1 = "rc_music2";
						g_EntityFuncs.FireTargets( sound1, @self, @self, USE_TOGGLE);
					}
					else if(szRound == 4)
					{
						string sound1 = "rc_music2";
						g_EntityFuncs.FireTargets( sound1, @self, @self, USE_TOGGLE);
					}
					else if(szRound == 5)
					{
						string sound1 = "rc_music3";
						g_EntityFuncs.FireTargets( sound1, @self, @self, USE_TOGGLE);
					}
				}
			}
			
			
		}
		
		self.pev.nextthink = g_Engine.time + 1;
	}
	
	
	void DisplayRoundTime()
	{
	
		int roundMinutes = 0;
		int roundSeconds = szRoundTimer;
		string roundZero = "0";
			
		if(roundSeconds >= 60){	roundSeconds -= 60; roundMinutes++; }
		if(roundSeconds >= 60){	roundSeconds -= 60; roundMinutes++; }
		if(roundSeconds >= 60){	roundSeconds -= 60; roundMinutes++; }
		if(roundSeconds >= 60){	roundSeconds -= 60; roundMinutes++; }
		if(roundSeconds >= 60){	roundSeconds -= 60; roundMinutes++; }		
			
		if(roundSeconds >= 10){	roundZero = ""; }
		
		if(roundActive){		texterTime = "[" + szRound + "/" + szRounds + "] " + "Round time left: " + roundMinutes + ":" + roundZero + roundSeconds; }
		else if(szRound == 0){	texterTime = "[" + szRound + "/" + szRounds + "] " + "Game begins in: " + roundMinutes + ":" + roundZero + roundSeconds; }
		else if(szRound > 0){	texterTime = "[" + szRound + "/" + szRounds + "] " + "Next round begins in: " + roundMinutes + ":" + roundZero + roundSeconds; }		
		
		g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, szTexterTime).edict(), "message", texterTime );
		g_EntityFuncs.FireTargets( szTexterTime, @self, @self, USE_TOGGLE);
		
	}
	
	void EndGame()
	{
		g_Game.AlertMessage( at_console, "Ending game \n" );
	
		g_Scheduler.SetTimeout( @this, "HideScore", 10.0);
		string gameEndTexter = "rc_text_end";
		g_EntityFuncs.FireTargets( gameEndTexter, @self, @self, USE_TOGGLE);
		
	}
	
	
	void HideScore()
	{
		string manager = "rc_manager";
		g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname(null, manager) );
	}
	
	
}

