class rage5_block : ScriptBaseMonsterEntity
{
		
	string sprite = "";
		
	void Spawn()
	{ 
		Precache();
		
		g_EntityFuncs.SetModel( self, "models/ragemap2018/rc_block.mdl" );
		self.pev.movetype		= MOVETYPE_FLY;
		self.pev.health			= 10;
		self.pev.sequence		= 0;
		self.pev.frame			= 0;
		self.pev.solid			= SOLID_SLIDEBOX;
		self.pev.takedamage		= DAMAGE_AIM;
		self.m_bloodColor		= DONT_BLEED;
		self.m_iClassSelection = CLASS_HUMAN_MILITARY;
		self.SetPlayerAlly(false);
		self.pev.flags |= FL_MONSTER;
		//g_EntityFuncs.DispatchKeyValue( self.edict(), "displayname", "RAGECUBE 2 \n" );
		g_EntityFuncs.SetSize( pev, Vector(-16, -16, -16), Vector(16, 16, 16));
		
	}
	
	
	void Precache()
	{
		g_Game.PrecacheModel( "models/ragemap2018/rc_block.mdl" );
	}
	
	
	int TakeDamage(entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
	{
	
		self.pev.health -= flDamage;
		
		if ( self.pev.health <= 0 )
		{
			self.pev.health = 0;
			self.pev.takedamage = DAMAGE_NO;
			self.pev.dmgtime = g_Engine.time;
			self.pev.flags &= ~FL_MONSTER;
			
			string szScorer = "rc_score";
			int score;
			
			if(self.pev.skin == 7){ self.pev.skin = Math.RandomLong(0,7); }
			if(self.pev.skin == 7){ self.pev.skin = 8; }
			
			if(self.pev.skin == 0)
			{
				sprite = "sprites/ragemap2018/rc/yellow.spr";
				score = 5;
				//g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, szScorer).edict(), "m_iszNewValue", score );
				
			}
			else if(self.pev.skin == 1)
			{
				sprite = "sprites/ragemap2018/rc/orange.spr";
				score = 10;
				//g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, szScorer).edict(), "m_iszNewValue", score );
				
			}
			else if(self.pev.skin == 2)
			{
				sprite = "sprites/ragemap2018/rc/red.spr";
				score = 20;
				//g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, szScorer).edict(), "m_iszNewValue", score );
				
			}
			else if(self.pev.skin == 3)
			{
				sprite = "sprites/ragemap2018/rc/pink.spr";
				score = 50;
				//g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, szScorer).edict(), "m_iszNewValue", score );
				
			}
			else if(self.pev.skin == 4)
			{
				sprite = "sprites/ragemap2018/rc/purple.spr";
				score = -50;
				string sPurple = "rc_purple";
				g_EntityFuncs.FireTargets( sPurple, @self, @self, USE_TOGGLE);
				
			}
			else if(self.pev.skin == 5)
			{
				sprite = "sprites/ragemap2018/rc/green.spr";
				score = 0;
				string sMonster = "rc_monster";
				g_EntityFuncs.FireTargets( sMonster, @self, @self, USE_TOGGLE);
				
			}
			else if(self.pev.skin == 6)
			{
				sprite = "sprites/ragemap2018/rc/blue.spr";
				score = 0;
				string sAmmo = "rc_ammo";
				g_EntityFuncs.FireTargets( sAmmo, @self, @self, USE_TOGGLE);
				
			}
			else if(self.pev.skin == 7)
			{
				sprite = "sprites/ragemap2018/rc/random.spr";
				
				
			}
			else if(self.pev.skin == 8)
			{
				sprite = "sprites/ragemap2018/rc/explosive.spr";
				rc_explosion(self.pev, self.pev, 10);
				score = 0;
				//g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, szScorer).edict(), "m_iszNewValue", score );
			}
			
			//g_EntityFuncs.FireTargets( szScorer, @self, @self, USE_TOGGLE);
			
			rc_numbersprites(self.pev.origin, sprite);
			rc_gibs(self.pev.origin, 10);
			
			// Tell manager a block in lane has been killed
			CustomKeyvalues@ cks = self.GetCustomKeyvalues();
			string laneKV = "szLane";
			string manager = "rc_manager";
			CustomKeyvalue ck = cks.GetKeyvalue(laneKV);
			int lane = ck.GetInteger() + 1;
			g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, manager).edict(), "action", lane );
			g_EntityFuncs.FireTargets( manager, @self, @self, USE_TOGGLE);
			
			// add/remove points
			
			CBaseEntity@ eManager = g_EntityFuncs.FindEntityByTargetname(null, manager);
			float currentScore = eManager.pev.frags;
			currentScore += score;
			eManager.pev.frags = currentScore;
			
			/*
			CustomKeyvalues@ cks2 = eManager.GetCustomKeyvalues();
			string scoreKV = "points";
			CustomKeyvalue ck2 = cks2.GetKeyvalue(scoreKV);
			int currentScore = ck2.GetInteger();
			currentScore += score;
			g_EntityFuncs.DispatchKeyValue( g_EntityFuncs.FindEntityByTargetname(null, manager).edict(), "points", currentScore );
			g_Game.AlertMessage( at_console, "currentScore: " + currentScore + " \n" );
			*/
			
			self.pev.framerate = 0;
			g_EntityFuncs.Remove( self );
			return 0;
		}			
			
		return 1;
	
	}
	
}