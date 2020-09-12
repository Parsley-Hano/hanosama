//Small(Grenade) 	= 5;
//Medium			= 10;
//Big				= 20;
void rc_explosion(entvars_t@ eInflictor = null, entvars_t@ eAttacker = null, int amount = 10)
{
	g_WeaponFuncs.RadiusDamage(eInflictor.origin, eInflictor, eAttacker, 25 * amount, 50 * amount, CLASS_NONE, DMG_BLAST);
	
	string explosionSprite = "sprites/rc/rc_explosionHD.spr";
	string explosionSprite2 = "sprites/rc/rc_explosion2HD.spr";
	
	Vector explosionPos1 = eInflictor.origin + (g_Engine.v_up * 3.2 * amount);
	Vector explosionPos2 = eInflictor.origin;
	
	te_explosion(explosionPos1, explosionSprite, amount, 20, 0);
	te_explosion(explosionPos2, explosionSprite2, amount, 20, 0);
}


void rc_gibs(Vector pos, int amount = 10)
{
	Vector gibSize = Vector(2,2,2) * amount;
	Vector vel = Vector(0,0,20) * amount;
	string model = "models/computergibs.mdl";
	uint8 count = amount;
	uint8 life = amount / 2;

	te_breakmodel(pos, gibSize, vel, 20, model, count, life, BREAK_METAL + 16);

}

void rc_smoke(Vector pos)
{
	string smokeSprite = "sprites/steam1.spr";

	te_smoke(pos, smokeSprite, 25, 25);

}

void rc_numbersprites(Vector pos, string sprite)
{
	Vector mins = pos - Vector(-32,-32,-32);
	Vector maxs = pos - Vector(32,32,32);
	float height = 256;
	string sSprite = sprite;
	uint8 count = 8;

	te_bubbles(mins, maxs, height, sSprite, count);
	
}

void rc_splattersprites(Vector pos, int amount = 10)
{
	Vector gibSize = Vector(2,2,2) * amount;
	Vector vel = Vector(0,0,20) * amount;
	string model = "sprites/ragemap2018/rc/flare.spr";
	uint8 count = amount;
	uint8 life = amount / 2;

	te_breakmodel(pos, gibSize, vel, 20, model, count, life, BREAK_METAL + 16);

}



// Converts floating-point number to unsigned 16-bit fixed-point representation
uint16 FixedUnsigned16( float value, float scale )
{
	float scaled = value * scale;
	int output = int( scaled );
	
	if ( output < 0 )
		output = 0;
	if ( output > 0xFFFF )
		output = 0xFFFF;

	return uint16( output );
}

// Converts floating-point number to signed 16-bit fixed-point representation
int16 FixedSigned16( float value, float scale )
{
	float scaled = value * scale;
	int output = int( scaled );

	if ( output > 32767 )
		output = 32767;
	if ( output < -32768 )
		output = -32768;

	return int16( output );
}


class Color
{ 
	uint8 r, g, b, a;
	
	Color() { r = g = b = a = 0; }
	Color(uint8 _r, uint8 _g, uint8 _b, uint8 _a = 255 ) { r = _r; g = _g; b = _b; a = _a; }
	Color (Vector v) { r = int(v.x); g = int(v.y); b = int(v.z); a = 255; }
	string ToString() { return "" + r + " " + g + " " + b + " " + a; }
}

const Color RED(255,0,0);
const Color GREEN(0,255,0);
const Color BLUE(0,0,255);
const Color YELLOW(255,255,0);
const Color ORANGE(255,127,0);
const Color PURPLE(127,0,255);
const Color PINK(255,0,127);
const Color TEAL(0,255,255);
const Color WHITE(255,255,255);
const Color BLACK(0,0,0);
const Color GRAY(127,127,127);


NetworkMessageDest msgType = MSG_BROADCAST;
edict_t@ dest = null;

// Beam effect between two points
void te_beampoints(Vector start, Vector end, 
	string sprite="sprites/laserbeam.spr", uint8 frameStart=0, 
	uint8 frameRate=100, uint8 life=0, uint8 width=1, uint8 noise=2, 
	Color c=GREEN, uint8 scroll=32)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BEAMPOINTS);
	m.WriteCoord(start.x);
	m.WriteCoord(start.y);
	m.WriteCoord(start.z);
	m.WriteCoord(end.x);
	m.WriteCoord(end.y);
	m.WriteCoord(end.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(frameStart);
	m.WriteByte(frameRate);
	m.WriteByte(life);
	m.WriteByte(width);
	m.WriteByte(noise);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.WriteByte(c.a); // actually brightness
	m.WriteByte(scroll);
	m.End();
}

// Beam effect between point and entity
void te_beamentpoint(CBaseEntity@ target, Vector end, 
	string sprite="sprites/laserbeam.spr", int frameStart=0, 
	int frameRate=100, int life=255, int width=32, int noise=1, 
	Color c=PURPLE, int scroll=32)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BEAMENTPOINT);
	m.WriteShort(target.entindex());
	m.WriteCoord(end.x);
	m.WriteCoord(end.y);
	m.WriteCoord(end.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(frameStart);
	m.WriteByte(frameRate);
	m.WriteByte(life);
	m.WriteByte(width);
	m.WriteByte(noise);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.WriteByte(c.a); // actually brightness
	m.WriteByte(scroll);
	m.End();
}

// Beam effect between two entities
void te_beaments(CBaseEntity@ start, CBaseEntity@ end, 
	string sprite="sprites/laserbeam.spr", int frameStart=0, 
	int frameRate=100, int life=255, int width=32, int noise=1, 
	Color c=PURPLE, int scroll=32)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BEAMENTS);
	m.WriteShort(start.entindex());
	m.WriteShort(end.entindex());
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(frameStart);
	m.WriteByte(frameRate);
	m.WriteByte(life);
	m.WriteByte(width);
	m.WriteByte(noise);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.WriteByte(c.a); // actually brightness
	m.WriteByte(scroll);
	m.End();
}

// A simpler version of te_beampoints
void te_lightning(Vector start, Vector end, 
	string sprite="sprites/laserbeam.spr", int life=20, int width=32, 
	int noise=10)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_LIGHTNING);
	m.WriteCoord(start.x);
	m.WriteCoord(start.y);
	m.WriteCoord(start.z);
	m.WriteCoord(end.x);
	m.WriteCoord(end.y);
	m.WriteCoord(end.z);
	m.WriteByte(life);
	m.WriteByte(width);
	m.WriteByte(noise);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.End();
}

// Useless effect? No way to make it last longer than 1 frame it seems.
void te_beamsprite(Vector start, Vector end,
	string beamSprite="sprites/laserbeam.spr", string endSprite="sprites/glow01.spr")
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BEAMSPRITE);
	m.WriteCoord(start.x);
	m.WriteCoord(start.y);
	m.WriteCoord(start.z);
	m.WriteCoord(end.x);
	m.WriteCoord(end.y);
	m.WriteCoord(end.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(beamSprite));
	m.WriteShort(g_EngineFuncs.ModelIndex(endSprite));
	m.End();
}

void _te_beamcircle(Vector pos, float velocity, string sprite, uint8 startFrame,
	uint8 frameRate, uint8 life, uint8 width, uint8 noise, Color c,
	uint8 scrollSpeed, int beamType)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(beamType);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z + velocity);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(startFrame);
	m.WriteByte(frameRate);
	m.WriteByte(life);
	m.WriteByte(width);
	m.WriteByte(noise);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.WriteByte(c.a);
	m.WriteByte(scrollSpeed);
	m.End();
}


// Like torus but with a filled center
void te_beamdisk(Vector pos, float velocity, 
	string sprite="sprites/laserbeam.spr", uint8 startFrame=0, 
	uint8 frameRate=16, uint8 life=8, 
	Color c=PURPLE, uint8 scrollSpeed=10)
{
	// width has no effect.
	_te_beamcircle(pos, velocity, sprite, startFrame, frameRate, life, 1, 0, c, scrollSpeed, TE_BEAMDISK);
}

// Like torus but without the weird sprite rotation
void te_beamcylinder(Vector pos, float velocity, string sprite="sprites/laserbeam.spr", uint8 startFrame=0, 
	uint8 frameRate=16, uint8 life=8, uint8 width=8, uint8 noise=0,
	Color c=PURPLE, uint8 scrollSpeed=0)
{
	_te_beamcircle(pos, velocity, sprite, startFrame, frameRate, life,
		width, noise, c, scrollSpeed, TE_BEAMCYLINDER);
}

// Creates a flat expanding circle. There seems to be no way to change the axis
void te_beamtorus(Vector pos, float velocity, 
	string sprite="sprites/laserbeam.spr", uint8 startFrame=0, 
	uint8 frameRate=16, uint8 life=8, uint8 width=8, uint8 noise=0,
	Color c=PURPLE, uint8 scrollSpeed=0)
{
	_te_beamcircle(pos, velocity, sprite, startFrame, frameRate, life,
		width, noise, c, scrollSpeed, TE_BEAMTORUS);
}

// Draws a beam ring between two entities
void te_beamring(CBaseEntity@ start, CBaseEntity@ end, 
	string sprite="sprites/laserbeam.spr", uint8 startFrame=0, 
	uint8 frameRate=16, uint8 life=255, uint8 width=16, uint8 noise=0, 
	Color c=PURPLE, uint8 scrollSpeed=0)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BEAMRING);
	m.WriteShort(start.entindex());
	m.WriteShort(end.entindex());
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(startFrame);
	m.WriteByte(frameRate);
	m.WriteByte(life);
	m.WriteByte(width);
	m.WriteByte(noise);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.WriteByte(c.a);
	m.WriteByte(scrollSpeed);
	m.End();
}


// ricochet sound with weird particle effect
void te_gunshot(Vector pos)
{
	_te_pointeffect(pos, TE_GUNSHOT);
}


// You've seen it a million times. Possible flags:
// 1 = Sprite will be drawn opaque
// 2 = Do not render the dynamic lights
// 4 = Do not play the explosion sound
// 8 = Do not draw the particles
void te_explosion(Vector pos, string sprite, int scale, int frameRate, int flags)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_EXPLOSION);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(scale);
	m.WriteByte(frameRate);
	m.WriteByte(flags);
	m.End();
}

// Quake particle effect. Looks like confetti or dust. Would be nice if it didn't play the explosion sound.
void te_tarexplosion(Vector pos)
{
	_te_pointeffect(pos, TE_TAREXPLOSION);
}

// Alphablend sprite rising at 30 pps
void te_smoke(Vector pos, string sprite="sprites/steam1.spr", 
	int scale=10, int frameRate=15)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_SMOKE);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(scale);
	m.WriteByte(frameRate);
	m.End();
}

// Bullet tracer effect. Its speed is constant.
void te_tracer(Vector start, Vector end)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_TRACER);
	m.WriteCoord(start.x);
	m.WriteCoord(start.y);
	m.WriteCoord(start.z);
	m.WriteCoord(end.x);
	m.WriteCoord(end.y);
	m.WriteCoord(end.z);
	m.End();
}

void _te_pointeffect(Vector pos, int effect=TE_SPARKS)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(effect);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.End();
}

// Sound effects sold separately
void te_sparks(Vector pos)
{
	_te_pointeffect(pos, TE_SPARKS);
}

// Another weird quake particle effect. Apparently red dots == lava
void te_lavasplash(Vector pos)
{
	_te_pointeffect(pos, TE_LAVASPLASH);
}

// Quake particle effect. This one is pretty cool.
void te_teleport(Vector pos)
{
	_te_pointeffect(pos, TE_TELEPORT);
}

// A faster version of te_tarexplosion. Also spawns a dlight. Color args do literally nothing?
void te_explosion2(Vector pos)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_EXPLOSION2);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteByte(0); // "start color" - has no effect
	m.WriteByte(127); // "number of colors" - has no effect
	m.End();
}

// used by the game when infodecals with targetnames are used/fired
// the implementation bellow emulates this behaviour
void te_bspdecal( CBaseEntity@ ent)
{
	Vector pos = ent.pev.origin;
	
	TraceResult tr;
	g_Utility.TraceLine( pos - Vector(5,5,5), pos + Vector(5,5,5),
		ignore_monsters, ent.edict(), tr );
	
	int entIdx = g_EntityFuncs.EntIndex( tr.pHit );

	// create the message
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BSPDECAL);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteShort(ent.pev.skin);
	m.WriteShort(entIdx);
	if ( entIdx != 0 )
		m.WriteShort( g_EntityFuncs.Instance( tr.pHit ).pev.modelindex );
	m.End();
}


void _te_decal( int decalType, Vector pos, CBaseEntity@ brushEnt, string decal, CBaseEntity@ plr )
{
	int entIdx = brushEnt is null ? 0 : brushEnt.entindex();
	int decalIdx = -1;
	
	if ( decalType == TE_PLAYERDECAL )
	{
		if ( plr is null )
		{
			g_Game.AlertMessage( at_console, "Error: TE_PLAYERDECAL with no player entity specified\n" );
			return;
		}
		
		decalIdx = 0;
	}
	else
	{
		decalIdx = g_EngineFuncs.DecalIndex(decal);
		if (decalIdx == -1)
		{
			g_Game.AlertMessage( at_console, "Error: Invalid decal: \"" + decalIdx + "\"\n" );
			return;
		}
		if (decalIdx > 511)
		{
			g_Game.AlertMessage( at_console, "Error: Decal index too high (" + decalIdx +
				")! Max decal index is 511.\n" );
			return;
		}
		if (decalIdx > 255)
		{
			decalIdx -= 255;
			if (decalType == TE_DECAL)
				decalType = TE_DECALHIGH;
			else if (decalType == TE_WORLDDECAL)
				decalType = TE_WORLDDECALHIGH;
			else
				g_Game.AlertMessage( at_console, "Error: Decal type " + decalType + " doesn't support indicies > 255" );
		}
	
		// save a little bandwidth if possible
		if (decalType == TE_DECAL && entIdx == 0)
			decalType = TE_WORLDDECAL;
		if (decalType == TE_DECALHIGH && entIdx == 0)
			decalType = TE_WORLDDECALHIGH; 
	}
	
	// create the message
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(decalType);
	if ( decalType == TE_PLAYERDECAL )
	{
		m.WriteByte(plr.entindex());
	}
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	switch(decalType)
	{
	case TE_DECAL:
	case TE_DECALHIGH:
		m.WriteByte(decalIdx);
		m.WriteShort(entIdx);
		break;
	case TE_GUNSHOTDECAL:
	case TE_PLAYERDECAL:
		m.WriteShort(entIdx);
		m.WriteByte(decalIdx);
		break;
	default:
		m.WriteByte(decalIdx);
		break;
	}
	m.End();
}

// Creates a decal if the specified point is close enough to a world or brush surface
void te_decal(Vector pos, CBaseEntity@ brushEnt=null, string decal="{handi")
{
	_te_decal( TE_DECAL, pos, brushEnt, decal, null);
}

// Applies a decal if the position is close enough to a surface.
// Also creates a bullet spark/particle effect and sometimes a sound.
void te_gunshotdecal(Vector pos, CBaseEntity@ brushEnt=null, string decal="{handi")
{
	_te_decal( TE_GUNSHOTDECAL, pos, brushEnt, decal, null );
}

// Applies the target player's spray if the position is close enough to a surface
void te_playerdecal(Vector pos, CBaseEntity@ plr, CBaseEntity@ brushEnt=null)
{
	_te_decal( TE_PLAYERDECAL, pos, brushEnt, "", plr);
}

// Tracers moving toward a point
void te_implosion(Vector pos, uint8 radius=255, uint8 count=32, uint8 life=5)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_IMPLOSION);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteByte(radius);
	m.WriteByte(count);
	m.WriteByte(life);
	m.End();
}

// Line of glow sprites with gravity, fadeout, and collisions. Lots of possibilities with this one
void te_spritetrail(Vector start, Vector end, 
	string sprite="sprites/hotglow.spr", uint8 count=2, uint8 life=0, 
	uint8 scale=1, uint8 speed=16, uint8 speedNoise=8)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_SPRITETRAIL);
	m.WriteCoord(start.x);
	m.WriteCoord(start.y);
	m.WriteCoord(start.z);
	m.WriteCoord(end.x);
	m.WriteCoord(end.y);
	m.WriteCoord(end.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(count);
	m.WriteByte(life);
	m.WriteByte(scale);
	m.WriteByte(speedNoise);
	m.WriteByte(speed);
	m.End();
}

// Line of alpha sprites floating upwards (shooting underwater effect)
void te_bubbletrail(Vector start, Vector end, 
	string sprite="sprites/bubble.spr", float height=128.0f,
	uint8 count=16, float speed=16.0f)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BUBBLETRAIL);
	m.WriteCoord(start.x);
	m.WriteCoord(start.y);
	m.WriteCoord(start.z);
	m.WriteCoord(end.x);
	m.WriteCoord(end.y);
	m.WriteCoord(end.z);
	m.WriteCoord(height);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(count);
	m.WriteCoord(speed);
	m.End();
}

// Plays additive sprite once.
void te_sprite(Vector pos, string sprite="sprites/zerogxplode.spr", 
	uint8 scale=10, uint8 alpha=200)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_SPRITE);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(scale);
	m.WriteByte(alpha);
	m.End();
}

// Places an additive sprite that fades out
void te_glowsprite(Vector pos, string sprite="sprites/glow01.spr", 
	uint8 life=1, uint8 scale=10, uint8 alpha=255)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_GLOWSPRITE);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(life);
	m.WriteByte(scale);
	m.WriteByte(alpha);
	m.End();
}


// Will kill itself if target stays still for too long
void te_beamfollow(CBaseEntity@ target, string sprite="sprites/laserbeam.spr", 
	uint8 life=100, uint8 width=2, Color c=PURPLE)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BEAMFOLLOW);
	m.WriteShort(target.entindex());
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(life);
	m.WriteByte(width);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.WriteByte(c.a);
	m.End();
}

// Shoot group of tracers in some direction. These have a slight gravity effect
void te_streak_splash(Vector start, Vector dir, uint8 color=4, 
	uint16 count=256, uint16 speed=2048, uint16 speedNoise=128)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_STREAK_SPLASH);
	m.WriteCoord(start.x);
	m.WriteCoord(start.y);
	m.WriteCoord(start.z);
	m.WriteCoord(dir.x);
	m.WriteCoord(dir.y);
	m.WriteCoord(dir.z);
	m.WriteByte(color);
	m.WriteShort(count);
	m.WriteShort(speed);
	m.WriteShort(speedNoise);
	m.End();
}

// Dynamic light.
void te_dlight(Vector pos, uint8 radius=14, Color c=GREEN, 
	uint8 life=8, uint16 decayRate=4)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_DLIGHT);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteByte(radius);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.WriteByte(life);
	m.WriteByte(decayRate);
	m.End();
}

// Dynamic light that only affects point entities. Seems pretty useless.
// It does a pretty crappy job of lighting my model if that's what it's supposed to do.
void te_elight(CBaseEntity@ target, Vector pos, float radius=1024.0f, 
	Color c=PURPLE, uint8 life=16, float decayRate=2000.0f)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_ELIGHT);
	m.WriteShort(target.entindex());
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(radius);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.WriteByte(life);
	m.WriteCoord(decayRate);
	m.End();
}

// Draws a dotted line. Uses tons of TE slots, so just use beams inastead.
void te_line(Vector start, Vector end, uint16 life=32, Color c=PURPLE)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_LINE);
	m.WriteCoord(start.x);
	m.WriteCoord(start.y);
	m.WriteCoord(start.z);
	m.WriteCoord(end.x);
	m.WriteCoord(end.y);
	m.WriteCoord(end.z);
	m.WriteShort(life);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.End();
}

// Draws a red dotted line. Dies in 30 seconds
void te_showline(Vector start, Vector end, Color c=PURPLE)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_SHOWLINE);
	m.WriteCoord(start.x);
	m.WriteCoord(start.y);
	m.WriteCoord(start.z);
	m.WriteCoord(end.x);
	m.WriteCoord(end.y);
	m.WriteCoord(end.z);
	m.End();
}

// Draws a axis-aligned box made up of dotted lines.
void te_box(Vector mins, Vector maxs, uint16 life=16, Color c=PURPLE)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BOX);
	m.WriteCoord(mins.x);
	m.WriteCoord(mins.y);
	m.WriteCoord(mins.z);
	m.WriteCoord(maxs.x);
	m.WriteCoord(maxs.y);
	m.WriteCoord(maxs.z);
	m.WriteShort(life);
	m.WriteByte(c.r);
	m.WriteByte(c.g);
	m.WriteByte(c.b);
	m.End();
}

// Kill all beams originating from the target entity
void te_killbeam(CBaseEntity@ target)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_KILLBEAM);
	m.WriteShort(target.entindex());
	m.End();
}

// Same thing as env_funnel. Set flags to 1 for reverse funnel
void te_largefunnel(Vector pos, string sprite="sprites/glow01.spr", uint16 flags=0)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_LARGEFUNNEL);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteShort(flags);
	m.End();
}

// Quake-style blood stream
void te_bloodstream(Vector pos, Vector dir, uint8 color=70, uint8 speed=64)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BLOODSTREAM);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(dir.x);
	m.WriteCoord(dir.y);
	m.WriteCoord(dir.z);
	m.WriteByte(color);
	m.WriteByte(speed);
	m.End();
}

// Another Quake-style blood stream
void te_blood(Vector pos, Vector dir, uint8 color=70, uint8 speed=16)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BLOOD);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(dir.x);
	m.WriteCoord(dir.y);
	m.WriteCoord(dir.z);
	m.WriteByte(color);
	m.WriteByte(speed);
	m.End();
}

// Creates alpha-transparency sprites inside of a brush entity (can't be world)
void te_fizz(CBaseEntity@ brushEnt, 
	string sprite="sprites/bubble.spr", uint8 density=100)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_FIZZ);
	m.WriteShort(brushEnt.entindex());
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(density);
	m.End();
}

// Creates alpha-transparency sprites inside of a box
void te_bubbles(Vector mins, Vector maxs, float height=256.0f, 
	string sprite="sprites/bubble.spr", uint8 count=64, float speed=16.0f)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BUBBLES);
	m.WriteCoord(mins.x);
	m.WriteCoord(mins.y);
	m.WriteCoord(mins.z);
	m.WriteCoord(maxs.x);
	m.WriteCoord(maxs.y);
	m.WriteCoord(maxs.z);
	m.WriteCoord(height);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(count);
	m.WriteCoord(speed);
	m.End();
}

// Throw model with gravity and collisions.
void te_model(Vector pos, Vector velocity, float yaw=0, 
	string model="models/agibs.mdl", uint8 bounceSound=2, uint8 life=32)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_MODEL);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(velocity.x);
	m.WriteCoord(velocity.y);
	m.WriteCoord(velocity.z);
	m.WriteAngle(yaw);
	m.WriteShort(g_EngineFuncs.ModelIndex(model));
	m.WriteByte(bounceSound);
	m.WriteByte(life);
	m.End();
}

// Quake-style model explosion. Dynamic light created for each gib
void te_explodemodel(Vector pos, float velocity, 
	string model="models/hgibs.mdl", uint16 count=8, uint8 life=32)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_EXPLODEMODEL);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(velocity);
	m.WriteShort(g_EngineFuncs.ModelIndex(model));
	m.WriteShort(count);
	m.WriteByte(life);
	m.End();
}

// func_breakable effect without sounds. Flags:
// 1 : Glass sounds and models 50% opacity
// 2 : Metal sounds.
// 4 : Flesh sounds.
// 8 : Wood sounds
// 16 : Quake particle trail on some gibs (combinable)
// 32: 50% opacity (combinable)
// 64 : Rock sounds.
void te_breakmodel(Vector pos, Vector size, Vector velocity, 
	uint8 speedNoise=16, string model="models/hgibs.mdl", 
	uint8 count=8, uint8 life=0, uint8 flags=20)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BREAKMODEL);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(size.x);
	m.WriteCoord(size.y);
	m.WriteCoord(size.z);
	m.WriteCoord(velocity.x);
	m.WriteCoord(velocity.y);
	m.WriteCoord(velocity.z);
	m.WriteByte(speedNoise);
	m.WriteShort(g_EngineFuncs.ModelIndex(model));
	m.WriteByte(count);
	m.WriteByte(life);
	m.WriteByte(flags);
	m.End();
}

// Spray fading alpha sprites in some direction (bullsquid spit effect)
void te_sprite_spray(Vector pos, Vector velocity, 
	string sprite="sprites/bubble.spr", uint8 count=8, 
	uint8 speed=16, uint8 noise=255)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_SPRITE_SPRAY);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(velocity.x);
	m.WriteCoord(velocity.y);
	m.WriteCoord(velocity.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(count);
	m.WriteByte(speed);
	m.WriteByte(noise);
	m.End();
}

// Like sprite_spray but with a custom rendermode and no fading
// Rendermodes:
// 0 : Normal
// 1 : Color
// 2 : Texture
// 3 : Glow
// 4 : Solid
// 5 : Additive
void te_spray(Vector pos, Vector dir, string sprite="models/hgibs.mdl", 
	uint8 count=8, uint8 speed=127, uint8 noise=255, uint8 rendermode=9)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_SPRAY);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(dir.x);
	m.WriteCoord(dir.y);
	m.WriteCoord(dir.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(count);
	m.WriteByte(speed);
	m.WriteByte(noise);
	m.WriteByte(rendermode);
	m.End();
}

// Armor ricochet effect
void te_armor_ricochet(Vector pos, uint8 scale=10)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_ARMOR_RICOCHET);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteByte(scale);
	m.End();
}

// Bullet hitting monster effect
void te_bloodsprite(Vector pos, string sprite1="sprites/bloodspray.spr",
	string sprite2="sprites/blood.spr", uint8 color=244, uint8 scale=3)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_BLOODSPRITE);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite1));
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite2));
	m.WriteByte(color);
	m.WriteByte(scale);
	m.End();
}

// Projectile with no gravity, explosion, or sound.
void te_projectile(Vector pos, Vector velocity, CBaseEntity@ owner=null, 
	string model="models/grenade.mdl", uint8 life=255)
{
	int ownerId = (owner is null) ? 0 : owner.entindex();
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_PROJECTILE);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(velocity.x);
	m.WriteCoord(velocity.y);
	m.WriteCoord(velocity.z);
	m.WriteShort(g_EngineFuncs.ModelIndex(model));
	m.WriteByte(life);
	m.WriteByte(ownerId);
	m.End();
}


// Surround player with sprites with 1 falling off (looks like getting attacked by bubbles)
void te_playersprites(CBasePlayer@ target, 
	string sprite="sprites/bubble.spr", uint8 count=16)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_PLAYERSPRITES);
	m.WriteShort(target.entindex());
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(count);
	m.WriteByte(0); // "size variation" - has no effect
	m.End();
}

// Quake-style particle explosion
void te_particleburst(Vector pos, uint16 radius=128, 
	uint8 color=250, uint8 life=5)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_PARTICLEBURST);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteShort(radius);
	m.WriteByte(color);
	m.WriteByte(life);
	m.End();
}

// Flags:
// 1: All sprites will drift upwards
// 2: 50% of the sprites will drift upwards
// 4: Sprites loop at 15fps instead of being controlled by "life"
// 8: Show sprites at 50% opacity
// 16: Spawn sprites on flat plane instead of in cube
void te_firefield(Vector pos, uint16 radius=128, 
	string sprite="sprites/zerogxplode.spr", uint8 count=128, 
	uint8 flags=30, uint8 life=5) 
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_FIREFIELD);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteShort(radius);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteByte(count);
	m.WriteByte(flags);
	m.WriteByte(life);
	m.End();
}

// Show sprite at vertical offset from player position ("Take Cover!" alert)
void te_playerattachment(CBasePlayer@ target, float vOffset=51.0f, 
	string sprite="sprites/bubble.spr", uint16 life=16)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_PLAYERATTACHMENT);
	m.WriteByte(target.entindex());
	m.WriteCoord(vOffset);
	m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
	m.WriteShort(life);
	m.End();
}

// Removes player attachements created with te_playerattachment()
void te_killplayerattachments(CBasePlayer@ plr)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_KILLPLAYERATTACHMENTS);
	m.WriteByte(plr.entindex());
	m.End();
}

// Creates a shotgun effect on the target surface. Shows no tracers, and the effect ignores monsters.
void te_multigunshot(Vector pos, Vector dir, float spreadX=512.0f, 
	float spreadY=512.0f, uint8 count=3, string decal="{shot4")
{
	int decalIdx = g_EngineFuncs.DecalIndex(decal);	
	// validate inputs
	if (decalIdx == -1)
	{
		g_Game.AlertMessage( at_console, "Invalid decal: \"" + decal + "\"\n" );
		return;
	}
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_MULTIGUNSHOT);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(dir.x);
	m.WriteCoord(dir.y);
	m.WriteCoord(dir.z);
	m.WriteCoord(spreadX);
	m.WriteCoord(spreadY);
	m.WriteByte(count);
	m.WriteByte(decalIdx);
	m.End();
}

// cUsToM tracers!
void te_usertracer(Vector pos, Vector dir, float speed=6000.0f, 
	uint8 life=32, uint color=4, uint8 length=12)
{
	Vector velocity = dir*speed;
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_USERTRACER);
	m.WriteCoord(pos.x);
	m.WriteCoord(pos.y);
	m.WriteCoord(pos.z);
	m.WriteCoord(velocity.x);
	m.WriteCoord(velocity.y);
	m.WriteCoord(velocity.z);
	m.WriteByte(life);
	m.WriteByte(color);
	m.WriteByte(length);
	m.End();
}

// Max 512 characters
// channel range = 0-3 ???
// Effects:
// 0 : fade in/out
// 1 : flickery credits
// 2 : write out characeter by character
void te_textmessage(string text, uint8 channel=1, float x=1, float y=-1,
	uint8 effect=0, Color textColor=WHITE, Color effectColor=PURPLE,
	float fadeInTime=1.5, float fadeOutTime=0.5, float holdTime=1.2, float scanTime=0.25)
{
	NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
	m.WriteByte(TE_TEXTMESSAGE);
	m.WriteByte(channel);
	m.WriteShort(FixedSigned16(x,1<<13));
	m.WriteShort(FixedSigned16(y,1<<13));
	m.WriteByte(effect);
	m.WriteByte(textColor.r);
	m.WriteByte(textColor.g);
	m.WriteByte(textColor.b);
	m.WriteByte(textColor.a);
	m.WriteByte(effectColor.r);
	m.WriteByte(effectColor.g);
	m.WriteByte(effectColor.b);
	m.WriteByte(effectColor.a);
	m.WriteShort(FixedUnsigned16(fadeInTime,1<<8));
	m.WriteShort(FixedUnsigned16(fadeOutTime,1<<8));
	m.WriteShort(FixedUnsigned16(holdTime,1<<8));
	if (effect == 2) 
		m.WriteShort(FixedUnsigned16(scanTime,1<<8));
	m.WriteString(text);
	m.End();
}