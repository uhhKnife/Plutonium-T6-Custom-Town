#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weap_riotshield;
#include codescripts\struct;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\_zm_transit_bus;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_ai_avogadro;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_devgui;
#include maps\mp\zombies\_zm_weap_jetgun;
#include maps\mp\zombies\_zm_ai_dogs;
#include maps\mp\zombies\_zm_ai_screecher;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\zm_transit_lava;
#include maps\mp\zm_transit_buildables;
#include maps\mp\_visionset_mgr;

init()
{
    if( getdvar( "mapname" ) == "zm_transit" && getdvar ( "g_gametype")  == "zstandard" )
	{
	    vault_doors = getentarray( "town_bunker_door", "targetname" );
        array_thread( vault_doors, ::transit_vault_breach );
		level._effect["fx_zmb_wall_buy_m16"] = loadfx( "maps/zombie/fx_zmb_wall_buy_m16" ); 
	    level._effect["fx_zmb_wall_buy_taseknuck"] = loadfx( "maps/zombie/fx_zmb_wall_buy_taseknuck" );
		level._effect[ "wall_m16" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_m16" );
		level._effect[ "wall_claymore" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_claymore" );
        level thread onPlayerConnect();
		init_custom_map(); 
	    level.custom_vending_precaching = ::default_precaching;
		foreach( weapon in level.zombie_weapons) 
		{
			weapon.is_in_box = 1;
		}
    }
    else
	{

	}
}

onPlayerConnect()
{
	while( 1 )
	{
		level waittill( "connected", player );
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self waittill( "spawned_player" );
	self thread init_wall_fx();
	wait 3;
	self iprintln( "^6Bank door openable with a surprise behind it!" );
}

init_custom_map()
{
	wallweapons( "riotshield_zm", ( 1983.69, 137, -30.551 ), ( 0, 105, 0 ), 2000 );
	wallweapons( "m16_zm", ( 2273.641, 167.5, 140.125 ), ( 0, 130, 0 ), 1200, 600 );
	//wallweapons( "emp_grenade_zm", ( 969.69, 280.402, 6.901 ), ( 0, 45, 0 ), 750 );
	//pile_of_emp( "emp_grenade_zm", ( 969.69, 284.402, 4.525 ), ( 0, 15, 90 ));
	wallweapons( "claymore_zm", ( 629.01, 441.01, 14.302 ), ( 90, -45, 0 ), 2000 );
}

play_fx( fx )
{
	playfxontag( level._effect[ fx ], self, "tag_origin" );
}

default_precaching()
{
	level._effect[ "wall_m16" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_m16" );
	level._effect[ "wall_claymore" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_claymore" );
	level._effect[ "wall_taseknuck" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_taseknuck" );
}

init_wall_fx()
{
    self thread playchalkfx("wall_m16", ( 2274.641, 168, 140.125 ), ( 0, 180, 0 ));
    self thread playchalkfx("wall_claymore", ( 629.01, 441.01, 10.902 ), ( 0, -90, 0 ));
}

playchalkfx(effect, origin, angles)
{
    fx = SpawnFX(level._effect[ effect ], origin,AnglesToForward(angles),AnglesToUp(angles));
    TriggerFX(fx);
    level waittill("connected", player);
    fx Delete();
}

wallweapons( weapon, origin, angles, cost, ammo )
{
	wallweap = spawnentity( "script_model", getweaponmodel( weapon ), origin, angles + ( 0, 50, 0 ) );
	wallweap thread wallweaponmonitor( weapon, cost, ammo );
}

spawnentity( class, model, origin, angle )
{
	entity = spawn( class, origin );
	entity.angles = angle;
	entity setmodel( model );
	return entity;
}

wallweaponmonitor( weapon, cost, ammo ) 
{
	self endon( "game_ended" );
	weap = get_weapon_display_name( weapon );
	upgradedammocost = 4500;
	self.in_use_weap = 0;
	while( 1 )
	{
		foreach( player in level.players )
		{
			if( distance( self.origin, player.origin ) <= 70 )
			{
				if(weapon == "m16_zm")
				{
                	player thread SpawnHint( self.origin, 30, 30, "HINT_ACTIVATE", "Hold ^3&&1^7 for M16A1 [Cost: " + cost + "] Ammo [Cost: 600] Upgraded Ammo [Cost: 4500]" );				
				}
				else if(weapon == "claymore_zm")
				{
                	player thread SpawnHint( self.origin, 30, 30, "HINT_ACTIVATE", "Hold ^3&&1^7 for Claymore [Cost: " + cost + "]" );
				}
				else if(weapon == "riotshield_zm")
				{
                	player thread SpawnHint( self.origin, 30, 30, "HINT_ACTIVATE", "Hold ^3&&1^7 for Riotshield  [Cost: " + cost + "]" );
				}
				if( player usebuttonpressed() && weapon != "m16_zm" && !(player hasWeapon(weapon)) && !(self.in_use_weap) && player.score >= cost  && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand())
				{
					player playsound( "zmb_cha_ching" );
					self.in_use_weap = 1;
					player.score -= cost;
					player thread weapon_give( weapon, 0, 1 );
					//player iprintln( "^2" + ( weap + " Buy" ) );
                    wait 3;
			        self.in_use_weap = 0;
				}
				if(weapon == "m16_zm") 
				{
					if( player usebuttonpressed() && !(player hasWeapon("m16_gl_upgraded_zm")) && !(player hasWeapon(weapon)) && !(self.in_use_weap) && player.score >= cost  && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand())
					{
						player playsound( "zmb_cha_ching" );
						self.in_use_weap = 1;
						player.score -= cost;
						player thread weapon_give( weapon, 0, 1 );
						//player iprintln( "^2" + ( weap + " Buy" ) );
                   	 	wait 3;
			       	 	self.in_use_weap = 0;
					}
					if( player usebuttonpressed() && (player hasWeapon(weapon)) && weapon != "riotshield_zm" && weapon != "claymore_zm" && !(self.in_use_weap) && player.score >= ammocost && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand())
					{
						player playsound( "zmb_cha_ching" );
						self.in_use_weap = 1;
						player.score -= ammocost;
						player setweaponammoclip(weapon, 150);
						player setWeaponAmmostock(weapon, 900 );
						//player iprintln( "^2" + ( weap + " Ammo Buy" ) );
                    	wait 3;
			        	self.in_use_weap = 0;
					}	
					if( player usebuttonpressed() && (player hasWeapon("m16_gl_upgraded_zm")) && weapon != "riotshield_zm" && weapon != "claymore_zm" && !(self.in_use_weap) && player.score >= upgradedammocost  && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand())
					{
						player playsound( "zmb_cha_ching" );
						self.in_use_weap = 1;
						player.score -= upgradedammocost;
						player setweaponammoclip("m16_gl_upgraded_zm", 150);
						player setWeaponAmmostock("m16_gl_upgraded_zm", 900 );
						//player iprintln( "^2" + ( weap + " Upgraded Ammo Buy" ) );
                   		wait 3;
			       		self.in_use_weap = 0;
					}
				}
				else
				{
					if( player usebuttonpressed() && player.score < cost && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand())
					{
						player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_weapon" );
					}
				}
			}
		}
		wait 0.1;
	}
}

SpawnHint( origin, width, height, cursorhint, string )
{
	hint = spawn( "trigger_radius", origin, 1, width, height );
	hint setcursorhint( cursorhint, hint );
	hint sethintstring( string );
	hint setvisibletoall();
	wait 0.2;
	hint delete();
}

transit_vault_breach() 
{
	self.damage_state = 0;
	clip = getent( self.target, "targetname" );
    self.clip = clip;
    if(self.target == "pf30_auto2434")
    	self thread vault_breach_think();
}

vault_breach_think() 
{
	self.health = 9;
	self setcandamage( 1 );
	self.damage_state = 0;
	self.clip.health = 9;
	self.clip setcandamage( 1 );
	for( ;; ) 
	{
		self waittill( "damage", amount, attacker, direction, point, dmg_type, modelname, tagname, partname, weaponname );
		if( isplayer( attacker ) )
        {
            if( dmg_type == "MOD_PROJECTILE" || dmg_type == "MOD_PROJECTILE_SPLASH" || dmg_type == "MOD_EXPLOSIVE" || dmg_type == "MOD_EXPLOSIVE_SPLASH" || dmg_type == "MOD_GRENADE" || dmg_type == "MOD_GRENADE_SPLASH" )
            {
                if ( self.damage_state == 0 )
                    self.damage_state = 1;
                playfxontag( level._effect[ "def_explosion" ], self, "tag_origin" );
                self playsound( "exp_vault_explode" );
                self bunkerdoorrotate( 1 );
                if ( isDefined( self.script_flag ) )
                    flag_set( self.script_flag );
                if ( isDefined( self.clip ) )
                    self.clip connectpaths();
                wait 1;
                playsoundatposition( "zmb_cha_ching_loud", self.origin );
                break;
            }
		}
	}
}

bunkerdoorrotate( open, time ) 
{
	if ( !isDefined( time ) )
		time = 0.2;
	rotate = self.script_float;
	if ( !open )
		rotate *= -1;
	if ( isDefined( self.script_angles ) ) 
	{
		self notsolid();
		self.clip delete();
		self rotateto( self.script_angles, time, 0, 0 );
		self thread maps\mp\zombies\_zm_blockers::door_solid_thread();
	}
}