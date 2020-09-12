class rage5_manager : ScriptBaseEntity
{
	//difficulty
	float perPlayerSpeed =		0.1;
	float perPlayerHealth =		1.0;
	
	//
	float spawnInterval = 0.4;
	float speed = 150.0;
	int lastLane = 100;
	array<float> laneSpeed = 		{1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 };
	array<int> laneDirection = 		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	array<int> laneObjectCount = 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	int maxObjectsPerLane = 8;
	
	// 								0yellow,	1orange,	2red,	3pink,	4purple,	5green,	6blue,	7random,	8explosive
	array<float> probability =		{10.0,		10.0,		5.0,	1.0,	1.0,		1.0,	2.0,	0.2,		1.0};
	array<float> health =			{1.0,		1.0,		1.0,	1.0,	1.0,		1.0,	1.0,	1.0,		1.0};
	
	string blockEntity = "rage5_block";
	int szAction = 100;
	int szScore = 0;
	int maxScore = 10000;
	float paused = 1;
	
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
	
		if(szKey == "action") // 
		{
			szAction = atoi( szValue );
			return true;
		}
		/*else if(szKey == "points") // 
		{
			szScore = atoi( szValue );
			return true;
		}*/
		else
			return BaseClass.KeyValue( szKey, szValue );
		
	}
	
			
	void Spawn()
	{ 		
		SetLaneSpeed();
		SetLaneDirections();
	
		SetThink( ThinkFunction( this.Think ) );
		
	}
	
	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		//g_Game.AlertMessage( at_console, "Use(); \n" );
	
		if(szAction >= 0 && szAction <= 15){ laneObjectCount[szAction-1]--; }
		else if(szAction == 100)
		{
			UpdateDifficulty(szAction);
			self.pev.nextthink = g_Engine.time + 0.1;			
		}
		else if(szAction >= 101 && szAction <= 105)
		{
			paused = 10.0;
			UpdateDifficulty(szAction);		
		}
		
		if(self.pev.frags >= maxScore)
		{
			string gameEndTexter = "rc_text_end";
			string wintext = "YOU WIN!";
			g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, gameEndTexter).edict(), "message", wintext );
		}
		
		szAction = 99;
	}
	
	void Think()
	{
		paused -= spawnInterval;
		if(paused <= 0){ SpawnBlock(); }
	
		string markedForKill = "rc_delete";
		CBaseEntity@ eKillEntity = g_EntityFuncs.FindEntityByTargetname(null, markedForKill);
		g_EntityFuncs.Remove( eKillEntity );
		
		//display score
		string szTexter = "rc_text";
		string currentText = "[ - Score: " + atoi(self.pev.frags) + " / " + maxScore + " - ]";
		g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, szTexter).edict(), "message", currentText );
		g_EntityFuncs.FireTargets( szTexter, @self, @self, USE_TOGGLE);
		
		self.pev.nextthink = g_Engine.time + spawnInterval;
	}
	
	
	void SetLaneSpeed()
	{
		// lower speed
		for( int i = 0; i < 5; i++ )
		{
			int lane = Math.RandomLong(0,14);
			if(laneSpeed[lane] == 1.0){ laneSpeed[lane] = 0.75; }
			else{ i--; }	
		}
		// higher speed
		for( int j = 0; j < 5; j++ )
		{
			int lane = Math.RandomLong(0,14);
			if(laneSpeed[lane] == 1.0){ laneSpeed[lane] = 1.25; }
			else{ j--; }	
		}
	}
	
	
	void SetLaneDirections()
	{
		for( int i = 0; i < 7; i++ )
		{
			int lane = Math.RandomLong(0,14);
			if(laneDirection[lane] == 0){ laneDirection[lane] = 1; }
			else{ i--; }
		}
	}
	
	
	int randomBlock()
	{
		float totalProbability =		probability[0] + probability[1]
									+	probability[2] + probability[3]
									+	probability[4] + probability[5]
									+	probability[6] + probability[7]
									+	probability[8];
									
		float randomFloat = Math.RandomFloat(0, totalProbability);
		float currentProbability = 0;
		
		currentProbability = probability[0];
		if(randomFloat <= currentProbability){	return 0; }
		
		currentProbability += probability[1];
		if(randomFloat <= currentProbability){	return 1; }
		
		currentProbability += probability[2];
		if(randomFloat <= currentProbability){	return 2; }
		
		currentProbability += probability[3];
		if(randomFloat <= currentProbability){	return 3; }
		
		currentProbability += probability[4];
		if(randomFloat <= currentProbability){	return 4; }
		
		currentProbability += probability[5];
		if(randomFloat <= currentProbability){	return 5; }
		
		currentProbability += probability[6];
		if(randomFloat <= currentProbability){	return 6; }
		
		currentProbability += probability[7];
		if(randomFloat <= currentProbability){	return 7; }
		
		return 8;

	}
	
	
	int RandomLane()
	{
		int lane;
	
		for( int i = 0; i < 8; i++ )
		{
			lane = Math.RandomLong(0,14);
			if(laneObjectCount[lane] < maxObjectsPerLane)
			{
				if(lane != lastLane)
				{
					lastLane = lane;
					return lane;
				}
			}
		}
		
		return 100;
		
	}
	
	
	void SpawnBlock()
	{
		int lane = RandomLane();
				
		if(lane <= 14)
		{
			int direction = laneDirection[lane] + 1;
			int velocity = 1;
			if(direction == 1){ velocity = -1; }
			int blockType = randomBlock();
			string laneKV = "szLane";
		
			laneObjectCount[lane]++;
			string startEntity = "rc_corner" + (lane+1) + "_" + direction;
			CBaseEntity@ eStartEntity = g_EntityFuncs.FindEntityByTargetname(null, startEntity);
			
			CBaseEntity@ eBlock = g_EntityFuncs.CreateEntity(blockEntity, null, true);
			eBlock.pev.skin = blockType;
			eBlock.pev.health = health[blockType];			
			eBlock.pev.origin = eStartEntity.pev.origin;
			
			CustomKeyvalues@ cks = eBlock.GetCustomKeyvalues();
			cks.SetKeyvalue(laneKV, lane);
			
			if(lane <= 8){	eBlock.pev.basevelocity = Vector(velocity,0,0) * speed * laneSpeed[lane]; }
			else{			eBlock.pev.basevelocity = Vector(0,0,velocity) * speed * laneSpeed[lane]; }
			
			//g_Game.AlertMessage( at_console, "Spawnblock: " + blockType + ", Lane: " + lane + "\n" );
			
		}
	}
	
	void UpdateDifficulty(int action)
	{
		int playerCount = 0;
		int currentRound = action - 100;
	
		for(int playerID = 0; playerID <= g_Engine.maxClients; playerID++ )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( playerID );
			if(pPlayer !is null && pPlayer.IsConnected()){ playerCount++; }
		}
								
		//speed
		speed = 100 + (10 * currentRound) + (3 * playerCount);
		
		//objectCount
		maxObjectsPerLane = atoi( 5 + (1 * currentRound) + ( 0.3 * playerCount) );
		
		//probability
		probability[0] = 20 - (2 * currentRound);
		probability[1] = 20 - (2 * currentRound);
		probability[2] = 10 - (currentRound);
		probability[3] = 3 - (currentRound * 0.5) + (0.1 * playerCount);
		
		probability[4] = 1 + (0.4 * currentRound) + (0.2 * playerCount);
		probability[5] = 0 + (0.2 * currentRound);
		
		probability[6] = 6 - (currentRound);
		probability[7] = 0 + (currentRound * 0.2);
		probability[8] = 6 - (currentRound);
	
	}
	
	
}

