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
init()
{
    if( getdvar( "mapname" ) == "zm_transit" && getdvar ( "g_gametype")  == "zstandard" )
	{
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
}

init_custom_map()
{
	wallweapons( "riotshield_zm", ( 1983.69, 137, -30.551 ), ( 0, 105, 0 ), 1000 );
	wallweapons( "m16_zm", ( 2273.641, 167.5, 140.125 ), ( 0, 130, 0 ), 1200, 600 );
	//wallweapons( "emp_grenade_zm", ( 969.69, 280.402, 6.901 ), ( 0, 45, 0 ), 750 );
	//pile_of_emp( "emp_grenade_zm", ( 969.69, 284.402, 4.525 ), ( 0, 15, 90 ));
	wallweapons( "claymore_zm", ( 629.01, 441.01, 14.302 ), ( 90, -45, 0 ), 1000 );
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
                	player thread SpawnHint( self.origin, 30, 30, "HINT_ACTIVATE", "Hold &&1 For Buy " + weap + " [Cost: " + cost + "] Ammo [Cost: 600] Upgraded Ammo [Cost: 4500]" );				
				}
				else
				{
                	player thread SpawnHint( self.origin, 30, 30, "HINT_ACTIVATE", "Hold &&1 For Buy " + weap + " [Cost: " + cost + "]" );
				}
				if( player usebuttonpressed() && weapon != "m16_zm" && !(player hasWeapon(weapon)) && !(self.in_use_weap) && player.score >= cost  && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand())
				{
					player playsound( "zmb_cha_ching" );
					self.in_use_weap = 1;
					player.score -= cost;
					player thread weapon_give( weapon, 0, 1 );
					player iprintln( "^2" + ( weap + " Buy" ) );
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
						player iprintln( "^2" + ( weap + " Buy" ) );
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
						player iprintln( "^2" + ( weap + " Ammo Buy" ) );
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
						player iprintln( "^2" + ( weap + " Upgraded Ammo Buy" ) );
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