-- WHO POSTED MY NUDES ON TWITTER DOT COM!?!?

---------- BATTLE -------------

---------- Final Stage: Eggman -------------

/*Having stored all 7 chaos emeralds onto their own separate platform, his not at all lazily constructed mech
(im bad at zonebuilder) is armed with a powerful barrier that can only be weakened by removing the chaos 
emerald of each chaos emerald platform connected to his mech. To traverse to another platform, a fighter will 
have to abandon the ongoing battle at their current platform to jump to another emerald platform. Badniks are
stationed at each platform, protecting the emerald while simultaneously recieving a power up respective to
the chaos emerald on their platform. During the fight, a weakened Metal Sonic will appear and steal the 4th 
chaos emerald retrieved and fight back alongside Eggman.*/


//badnik affinities
local enemies = {"jetty gunner", "jetty bomber", "robo hood", "facestabber", "crawla commander", "cacolantern"}
local atk_constants = {
	ATK_STRIKE,
	ATK_PIERCE,
	ATK_FIRE,
	ATK_WIND,
	ATK_ELEC,
	ATK_PSY,
	ATK_BLESS,
}

//hud things
local yellowbar = 0
local bluebar = 180
local bluefade = SKINCOLOR_SUPERSKY5
local rubyfade = 179
local fadenum = 1
local color = 0
local emeraldselect = 4
local mapy = -50
local rubyx = -70
local linex = {}
local liney = {}
local linelength = {}
local linespeed = {}
local speeding = false
local flying = false
--local falling = false
local rubydisplay = false

addHook("MapLoad", function()
	if not server return end
	--eggdude = nil
	/*btl.eggdude = nil
	menudisplay = false
	mapdisplay = false
	showmap = false
	rubycooldown = 0
	rubytimer = 0
	rubyactivate = 0
	hideleft = false
	hideright = false
	emeralds = {}
	lockplatform = 0
	locktimer = 0
	metalsonicfight = false*/
	
	//badnik affinities
	/*weaknesses = {}
	resistances = {}
	for i = 1, #enemies
		weaknesses[#weaknesses+1] = atk_constants[P_RandomRange(1, #atk_constants)]
		resistances[#resistances+1] = atk_constants[P_RandomRange(1, #atk_constants)]
	end*/

	//hud things
	yellowbar = 0
	bluebar = 180
	bluefade = SKINCOLOR_SUPERSKY5
	rubyfade = 179
	fadenum = 1
	color = 0
	emeraldselect = 4
	mapy = -50
	rubyx = -70
	linex = {}
	liney = {}
	linelength = {}
	linespeed = {}
	speeding = false
	flying = false
	--falling = false
	rubydisplay = false
end)

rawset(_G, "badnikDeath", function(mo) //is for stage 4 too
	mo.deathtimer = $ and $+1 or 1
	local btl = server.P_BattleStatus[mo.battlen]
	local cam = btl.cam
	CAM_stop(cam)
	local tgtx = mo.x + 450*cos(mo.angle + ANG1*45)
	local tgty = mo.y + 450*sin(mo.angle + ANG1*45)
	//gib emerald
	if mo.enemy != "b_metalsonic_weak"
		if mo.deathtimer == 2
			mo.emeraldmode = 0
			P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*25)
			for k,v in ipairs(mo.enemies)
				if v and v.control and v.control.valid
					P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
				end
			end
			P_InstaThrust(mo, mo.angle, -30*FRACUNIT)
			playSound(mo.battlen, sfx_bbreak)
			local dude = btl.turnorder[1]
			P_TeleportMove(dude, dude.defaultcoords[1], dude.defaultcoords[2], dude.defaultcoords[3])
			dude.momx = 0
			dude.momy = 0
			dude.momz = 0
			
			//if it's the last emerald...
			if btl.emeralds and #btl.emeralds == 1
				for p in players.iterate do
					if p and p.control and p.control.valid and p.control.battlen == mo.battlen
						COM_BufInsertText(p, "hu_partystatus off")
					end
				end
				btl.eggdude.cannoncharge = false
				btl.eggdude.cannontimer = 1050
				btl.eggdude.cannontarget = 0
				btl.eggdude.cannonprepare = false
			end
		end
		
		if mo.deathtimer < 39
			cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
			mo.momx = $*80/100
			mo.momy = $*80/100
			if not (leveltime%P_RandomRange(6, 8))
				local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height/2, MT_DUMMY)
				elec.sprite = SPR_DELK
				elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
				elec.destscale = FRACUNIT*4
				elec.scalespeed = FRACUNIT/4
				elec.tics = TICRATE/8
				elec.color = SKINCOLOR_YELLOW
			end
		end
		
		if mo.deathtimer == 40
			playSound(mo.battlen, sfx_pop)
			local pop = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
			pop.state = S_XPLD1
			pop.scale = mo.scale
			mo.sprite = SPR_NULL
			mo.flags2 = $|MF2_DONTDRAW
		end
		//break the glass
		if mo.deathtimer == 60
			local num = 100 + mo.platform
			P_LinedefExecute(num)
			playSound(mo.battlen, sfx_crumbl)
		end
		//remove link stuff
		if mo.deathtimer == 80
			for m in mobjs.iterate() do
				if m and m.valid and m.type == MT_DUMMY and m.emeraldlink
					if m.emeraldnum == mo.platform
						P_RemoveMobj(m)
					end
				end
			end
		end
		for k,v in ipairs(btl.fighters)
			if v.enemy == "b_emerald"
				if v.emeraldtype == mo.platform
					local dude = btl.turnorder[1]
					if btl.emeralds and (#btl.emeralds != 3 or btl.metalsonicfight)
						if mo.deathtimer == 80
							v.momz = 10*FRACUNIT
							v.flags = $ & ~MF_NOGRAVITY
						end
						if mo.deathtimer >= 80 and mo.deathtimer < 200 and v.z > dude.z + 10*FRACUNIT and not v.changedaworl
							v.momx = (dude.x - v.x)/10
							v.momy = (dude.y - v.y)/10
							cam.momx = (dude.x - v.x)/10
							cam.momy = (dude.y - v.y)/10
						elseif v.changedaworl
							CAM_stop(cam)
						end
						if v.z <= dude.z + 10*FRACUNIT and not v.changedaworl
							playSound(mo.battlen, sfx_cgot)
							playSound(mo.battlen, sfx_buff)
							local g = P_SpawnGhostMobj(dude)
							g.color = dude.color
							g.colorized = true
							g.destscale = FRACUNIT*4
							local pop = P_SpawnMobj(v.x, v.y, v.z, MT_DUMMY)
							pop.state = S_SPRK1
							pop.scale = v.scale
							v.sprite = SPR_NULL
							v.flags = $|MF_NOGRAVITY
							v.flags2 = $|MF2_DONTDRAW
							v.momx = 0
							v.momy = 0
							v.momz = 0
							P_TeleportMove(v, v.emeraldx, v.emeraldy, v.emeraldz)
							v.changedaworl = true
							local emeraldskills = {"emerald leech2", "hyper soul leech", "status infliction", "total neutralization", "zioverse", "platform warp", "platform lock"}
							table.insert(dude.skills, emeraldskills[v.emeraldtype])
							//if 5th is retrieved you get TWO skills omg
							if v.emeraldtype == 5
								table.insert(dude.skills, "garuverse")
							end
							BTL_logMessage(mo.battlen, "All stats slightly increased!")
							local stats = {"strength", "magic", "endurance", "agility", "luck"}
							for i = 1, #stats do
								dude[stats[i]] = $+10
							end
						end
					elseif btl.emeralds and #btl.emeralds == 3 and not btl.metalsonicfight
						//I CANT BELIEVE METAL CAME IN AND SAID "IT'S METALING TIME" AND METALED ALL OVER US
						
						//falls down like normal... until...
						if mo.deathtimer == 80
							v.stolen = true
							v.momz = 10*FRACUNIT
							v.flags = $ & ~MF_NOGRAVITY
						end
						if mo.deathtimer >= 80 and mo.deathtimer < 120
							v.momx = (dude.x - v.x)/10
							v.momy = (dude.y - v.y)/10
							cam.momx = (dude.x - v.x)/10
							cam.momy = (dude.y - v.y)/10
						elseif mo.deathtimer == 120
							CAM_stop(cam)
						end
						
						//POW
						if mo.deathtimer == 120
							playSound(mo.battlen, sfx_slash)
							playSound(mo.battlen, sfx_steal)
							ANIM_set(dude, dude.anim_hurt, true)
							VFX_Play(dude, VFX_HURT)
							for k,v in ipairs(mo.enemies)
								if v and v.control and v.control.valid
									P_FlashPal(v.control, 6, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
								end
							end
							for i = 1, 26
								local tgtx = dude.x + (i*30)*cos(cam.angle+(ANG1*90))
								local tgty = dude.y + (i*30)*sin(cam.angle+(ANG1*90))
								if i <= 25
									local e = P_SpawnMobj(tgtx-500*cos(cam.angle+(ANG1*90)), tgty-500*sin(cam.angle+(ANG1*90)), dude.z + (i*2*FRACUNIT), MT_THOK)
									e.state = S_THOK
									e.tics = 30
									e.color = SKINCOLOR_WHITE
									e.frame = FF_FULLBRIGHT
									e.scale = FRACUNIT*3/2
									e.destscale = 0
									e.scalespeed = e.scale/30
								else
									mo.metal = BTL_spawnEnemy(mo, "b_metalsonic_weak")
									mo.metal.angle = ANG1*90
									mo.metal.flags = $|MF_NOGRAVITY
									ANIM_set(mo.metal, mo.metal.anim_special2, true)
									P_TeleportMove(mo.metal, tgtx-500*cos(cam.angle+(ANG1*90)), tgty-500*sin(cam.angle+(ANG1*90)), dude.z + (i*2*FRACUNIT)+10*FRACUNIT)
									//spawning an enemy does something weird with our teams so we add again
									
								end
							end
							//move camera closer
							local cx = cam.x + 200*cos(cam.angle)
							local cy = cam.y + 200*sin(cam.angle)
							P_TeleportMove(cam, cx, cy, cam.z)
							localquake(mo.battlen, 5*FRACUNIT, 10)
						end
						
						//dramatic slowdown: the emerald
						if mo.deathtimer >= 120 and v.stolen
							if mo.deathtimer < 170
								P_InstaThrust(v, ANG1*270, 3*FRACUNIT)
								v.momz = 3*FRACUNIT
								v.rollangle = $+ANG1*3
							elseif mo.deathtimer >= 170 and not v.changedaworl
								if mo.deathtimer == 170
									P_InstaThrust(v, ANG1*270, 10*FRACUNIT)
									v.momz = 10*FRACUNIT
								end
								v.rollangle = $+ANG1*50
								local tgtx = v.x + 200*cos(ANG1*90)
								local tgty = v.y + 200*sin(ANG1*90)
								cam.angle = R_PointToAngle2(cam.x, cam.y, v.x, v.y)
								CAM_goto(cam, tgtx, tgty, v.z)
							end
						end
						//dramatic slowdown: the metal sonic
						if mo.metal and mo.metal.valid and mo.deathtimer >= 120 and v.stolen
							if mo.deathtimer < 170
								P_InstaThrust(mo.metal, ANG1*90, 2*FRACUNIT)
								mo.metal.momz = FRACUNIT
							end
						end
						
						//metal sonic picks up the thing
						if mo.metal and mo.metal.valid
							local metal = mo.metal
							if mo.deathtimer == 200
								local tgtx = v.x + 400*cos(cam.angle + ANG1*90)
								local tgty = v.y + 400*sin(cam.angle + ANG1*90)
								metal.momx = v.momx
								metal.momy = v.momy
								metal.momz = v.momz
								metal.flags = $ & ~MF_NOGRAVITY
								P_TeleportMove(metal, tgtx, tgty, v.z)
								metal.angle = R_PointToAngle2(metal.x, metal.y, v.x, v.y)
								P_Thrust(metal, metal.angle, 80*FRACUNIT)
							end
							if R_PointToDist2(metal.x, metal.y, v.x, v.y) < 10*FRACUNIT
								playSound(mo.battlen, sfx_cgot)
								local pop = P_SpawnMobj(v.x, v.y, v.z, MT_DUMMY)
								pop.state = S_SPRK1
								pop.scale = v.scale
								v.sprite = SPR_NULL
								v.flags2 = $|MF2_DONTDRAW|MF_NOGRAVITY
								v.momx = 0
								v.momy = 0
								v.momz = 0
								v.rollangle = 0
								P_TeleportMove(v, v.emeraldx, v.emeraldy, v.emeraldz)
								v.changedaworl = true
								metal.flags = $|MF_NOGRAVITY
								metal.momz = 0
								ANIM_set(metal, metal.anim_move, true)
								CAM_stop(cam)
								metal.tx = metal.x + 200*cos(metal.angle)
								metal.ty = metal.y + 200*sin(metal.angle)
								/*metal.cx = metal.x + 450*cos(ANG1*90)
								metal.cy = metal.y + 450*sin(ANG1*90)*/
							end
							//and then he slows down after he picks up the thing
							if v.changedaworl and mo.deathtimer < 250
								local cx = metal.x + 400*cos(ANG1*90)
								local cy = metal.y + 400*sin(ANG1*90)
								cam.angle = R_PointToAngle2(cam.x, cam.y, metal.x, metal.y)
								CAM_goto(cam, cx, cy, metal.z)
								metal.momx = (metal.tx - metal.x)/10
								metal.momy = (metal.ty - metal.y)/10
							end
							//metal jumps to new platform but lowers down a bit before he does
							if mo.deathtimer == 250
								metal.momz = -2*FRACUNIT
							end
							if mo.deathtimer == 260
								playSound(mo.battlen, sfx_beflap)
								metal.momz = 15*FRACUNIT
								ANIM_set(metal, metal.anim_special1, true)
								metal.platform = btl.emeralds[P_RandomRange(1, #btl.emeralds)].platform
							end
							//move camera to new spot and bring metal down
							if mo.deathtimer >= 300
								for k,v in ipairs(btl.fighters)
									if v.enemy == "b_emerald"
										if v.emeraldtype == metal.platform
											local x = v.x + 250*cos(ANG1*180)
											local y = v.y + 250*sin(ANG1*180)
											local cx = x + 350*cos(ANG1*90)
											local cy = y + 350*sin(ANG1*90)
											CAM_goto(cam, cx, cy, v.z)
											if mo.deathtimer == 340
												P_TeleportMove(metal, x, y, v.z + 200*FRACUNIT)
												metal.momx = 0
												metal.momy = 0
											end
											if mo.deathtimer >= 340
												metal.angle = ANG1*90
												metal.momz = (v.z - metal.z)/5
											end
										end
									end
								end
							end
							if mo.deathtimer == 380
								for m in mobjs.iterate() do
									if m and m.valid and m.type == MT_PFIGHTER
										if not m.enemy
											for k,v in ipairs(btl.fighters)
												if v.enemy and m.platform == v.platform and v.enemy != "b_eggman" and v.hp > 0
													m.enemies[#m.enemies+1] = v
													--mo.enemies_noupdate[#mo.enemies_noupdate+1] = v
													v.enemies[#v.enemies+1] = m
													--v.enemies_noupdate[#v.enemies_noupdate+1] = mo
												end
											end
											if m.enemies and #m.enemies
												m.enemies[#m.enemies+1] = btl.eggdude
												--btl.eggdude.enemies[#btl.eggdude.enemies+1] = m
											end
										/*else -- give the enemies their allies
											for k,v in ipairs(btl.fighters)
												//add allies
												if v.enemy and m.platform == v.platform and v != m
													m.allies[#m.allies+1] = v
												end
											end*/
										end
									end
								end
								btl.metalsonicfight = true
								mo.deathanim = nil
								metal.floatz = metal.z
								return
							end
						end
					end
					//no more emeralds, trigger finishing blow cutscene!
					if mo.deathtimer == 130 and not v.stolen
						if btl.emeralds and not #btl.emeralds
							cutscene = true
							for k,v in ipairs(btl.fighters)
								cureStatus(v)
							end
							for p in players.iterate do
								if p and p.control and p.control.valid and p.control.battlen == mo.battlen
									S_FadeOutStopMusic(2*MUSICRATE, p)
								end
							end
							btl.superman = dude
							if dude.skin == "sonic"
								D_startEvent(mo.battlen, "ev_stage6_eggman_dies_s")
							elseif dude.skin == "tails"
								D_startEvent(mo.battlen, "ev_stage6_eggman_dies_t")
							elseif dude.skin == "knuckles"
								D_startEvent(mo.battlen, "ev_stage6_eggman_dies_k")
							elseif dude.skin == "amy"
								D_startEvent(mo.battlen, "ev_stage6_eggman_dies_a")
							elseif dude.skin != "sonic" and dude.skin != "tails" and dude.skin != "knuckles" and dude.skin != "amy"
								D_startEvent(mo.battlen, "ev_stage6_eggman_dies")
							end
						end
						mo.deathanim = nil
					end
					if mo.deathtimer == 221 and not v.stolen
						mo.deathanim = nil
						return
					end
				end
			end
		end
		
		if mo.deathtimer == 701
			mo.deathanim = nil
			return
		end
		
		//the stage 4 part
		if gamemap == 10 and mo.deathtimer == 71
			mo.deathanim = nil
			return
		end
	else //METAL SONIC DEATH CUTSCENE
		if mo.deathtimer == 2
			P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*25)
			for k,v in ipairs(mo.enemies)
				if v and v.control and v.control.valid
					P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
				end
			end
			P_InstaThrust(mo, mo.angle, -5*FRACUNIT)
			mo.momz = 10*FRACUNIT
			mo.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT & ~MF_NOGRAVITY
			mo.floatz = nil
			playSound(mo.battlen, sfx_bbreak)
			ANIM_set(mo, mo.anim_hurt, true)
			cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
			
			//if it's the last emerald...
			if btl.emeralds and #btl.emeralds == 1
				for p in players.iterate do
					if p and p.control and p.control.valid and p.control.battlen == mo.battlen
						COM_BufInsertText(p, "hu_partystatus off")
					end
				end
				btl.eggdude.cannoncharge = false
				btl.eggdude.cannontimer = 1050
				btl.eggdude.cannontarget = 0
				btl.eggdude.cannonprepare = false
			end
		end
		
		if mo and mo.valid
			if not (leveltime%P_RandomRange(2, 6))
				local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height/2, MT_DUMMY)
				elec.sprite = SPR_DELK
				elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
				elec.destscale = FRACUNIT*4
				elec.scalespeed = FRACUNIT/4
				elec.tics = TICRATE/8
				elec.color = SKINCOLOR_YELLOW
			end
		end
		
		for k,v in ipairs(btl.fighters)
			if v.enemy == "b_emerald"
				local dude = btl.turnorder[1]
				if v.stolen
					if mo.deathtimer == 40
						playSound(mo.battlen, sfx_s3k51)
						v.momz = 10*FRACUNIT
						v.flags = $ & ~MF_NOGRAVITY
						v.flags2 = $ & ~MF2_DONTDRAW
						v.sprite = SPR_CEMG
						P_TeleportMove(v, mo.x, mo.y, mo.z)
						v.changedaworl = false
					end
					if mo.deathtimer >= 40 and mo.deathtimer < 200 and v.z > dude.z + 10*FRACUNIT and not v.changedaworl
						v.momx = (dude.x - v.x)/10
						v.momy = (dude.y - v.y)/10
						cam.momx = (dude.x - v.x)/10
						cam.momy = (dude.y - v.y)/10
					elseif v.changedaworl
						CAM_stop(cam)
					end
					if v.z <= dude.z + 10*FRACUNIT and not v.changedaworl and R_PointToDist2(dude.x, dude.y, v.x, v.y) < 10*FRACUNIT
						playSound(mo.battlen, sfx_cgot)
						playSound(mo.battlen, sfx_buff)
						local g = P_SpawnGhostMobj(dude)
						g.color = dude.color
						g.colorized = true
						g.destscale = FRACUNIT*4
						local pop = P_SpawnMobj(v.x, v.y, v.z, MT_DUMMY)
						pop.state = S_SPRK1
						pop.scale = v.scale
						v.sprite = SPR_NULL
						v.flags = $|MF_NOGRAVITY
						v.flags2 = $|MF2_DONTDRAW
						v.momx = 0
						v.momy = 0
						v.momz = 0
						P_TeleportMove(v, v.emeraldx, v.emeraldy, v.emeraldz)
						v.changedaworl = true
						local emeraldskills = {"emerald leech2", "hyper soul leech", "status infliction", "total neutralization", "zioverse", "platform warp", "platform lock"}
						table.insert(dude.skills, emeraldskills[v.emeraldtype])
						//if 5th is retrieved you get TWO skills omg
						if v.emeraldtype == 5
							table.insert(dude.skills, "garuverse")
						end
						BTL_logMessage(mo.battlen, "All stats slightly increased!")
						local stats = {"strength", "magic", "endurance", "agility", "luck"}
						for i = 1, #stats do
							dude[stats[i]] = $+10
						end
						v.stolen = false
					end
				end
				
				//no more emeralds, trigger finishing blow cutscene!
				if btl.emeralds and not #btl.emeralds
					cutscene = true
					for k,v in ipairs(btl.fighters)
						cureStatus(v)
					end
					for p in players.iterate do
						if p and p.control and p.control.valid and p.control.battlen == mo.battlen
							S_FadeOutStopMusic(2*MUSICRATE, p)
						end
					end
					btl.superman = dude
					if dude.skin == "sonic"
						D_startEvent(mo.battlen, "ev_stage6_eggman_dies_s")
					elseif dude.skin == "tails"
						D_startEvent(mo.battlen, "ev_stage6_eggman_dies_t")
					elseif dude.skin == "knuckles"
						D_startEvent(mo.battlen, "ev_stage6_eggman_dies_k")
					elseif dude.skin == "amy"
						D_startEvent(mo.battlen, "ev_stage6_eggman_dies_a")
					elseif dude.skin != "sonic" and dude.skin != "tails" and dude.skin != "knuckles" and dude.skin != "amy"
						D_startEvent(mo.battlen, "ev_stage6_eggman_dies")
					end
				end
				if mo.deathtimer == 140
					mo.deathanim = nil
					mo.sprite = SPR_NULL
					mo.flags2 = $|MF2_DONTDRAW
					return
				end
			end
		end
	end
end)

enemyList["b_metalsonic_weak"] = {
		name = "Metal Sonic (Weakened)",
		skillchance = 100,	-- /100, probability of using a skill
		level = 100,
		hp = 2000,
		sp = 1000,
		strength = 75,
		magic = 75,
		endurance = 40,
		luck = 25,
		agility = 35,
		boss = true,
		weak = ATK_ELEC,
		resist = ATK_STRIKE|ATK_NUCLEAR,
		r_exp = 0,
		turns = 2,
		thinker = generalEnemyThinker,
		
		skin = "metalsonic",			-- for "player" fights.
		color = SKINCOLOR_BLUE,	-- for colormapping
		hudcutin = "MSON_A",	-- cut in
		hudspr = "MSON",	-- sprite prefix since hud can't retrieve it. yikes
		
		overlay = MT_SRB2P_METALJETFUME, -- doesnt work :(
		--overlaythink = spr2_dotails, 

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_WALK"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_WALK"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, B, A, B, A, B, A, B, 10, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, 2, "SPR2_RUN"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, E, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, E, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_SHIT"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_DEAD"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},		-- gets revived
		anim_evoker = 		{SPR_PLAY, A, 8, "SPR2_SPNG"},

		anim_special1 =		{SPR_PLAY, A, 2, "SPR2_SPNG"},	-- spring
		anim_special2 =		{SPR_PLAY, A, 2, "SPR2_DASH"},	-- dash
		anim_special3 =		{SPR_PLAY, A, 1, "SPR2_FALL"},	-- falling
		

		vfx_summon = {"sfx_mssum1", "sfx_mssum2"},
        vfx_skill = {"sfx_msskl1", "sfx_msskl2"},
        vfx_item = {"sfx_mssum1", "sfx_mssum2"},
        vfx_hurt = {"sfx_mshrt1", "sfx_mshrt2"},
        vfx_hurtx = {"sfx_msskl2"},
        vfx_die = {"sfx_msmis1"},
        vfx_heal = {"sfx_mssum1", "sfx_mssum2"},
        vfx_healself = {"sfx_mssum1", "sfx_mssum2"},
        vfx_kill = {"sfx_mssum1", "sfx_mssum2"},
        vfx_1more = {"sfx_msdge1"},
        vfx_crit = {"sfx_msskl2"},
        vfx_aoaask = {"sfx_msaoi1"},
        vfx_aoado = {"sfx_msskl2"},
        vfx_aoarelent = {"sfx_msmis1"},
        vfx_miss = {"sfx_msmis1"},
        vfx_dodge = {"sfx_msdge1"},
        vfx_win = {"sfx_mswin1"},
        vfx_levelup = {"sfx_mswin1"},
					
		skills = {"pralaya", "mafreidyne", "vicious strike", "swordbreaker", "freidyne"},
		
		deathanim = function(mo)
						badnikDeath(mo)
					end,
	}		

enemyList["b_eggman"] = {
		name = "Eggman",
		skillchance = 100,	
		level = 100,
		hp = 69,
		sp = 9999,
		strength = 120,
		magic = 120,
		endurance = 20,
		luck = 60,
		agility = 80,
		boss = true,
		turns = 2, -- probably?
		
		skin = "eggman",			-- for "player" fights.
		color = SKINCOLOR_RED,	-- for colormapping
		hudcutin = "EGGM_A",
		
		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, B, A, B, A, B, A, B, 10, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, 2, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, 1, "SPR2_RUN_"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, B, A, B, A, B, A, B, 10, "SPR2_WAIT"},	-- taking damage (not actually)
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_CNT1"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_RUN_"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, 1, "SPR2_RUN_"},		-- gets revived
		anim_evoker = 		{SPR_PLAY, A, 8},
		anim_evoker_shoot = 		{SPR_PLAY, A, 8},

		anim_special1 = {SPR_PLAY, A, 35, "SPR2_PAIN"}, --the actual taking damage anim

		vfx_summon = {"sfx_egsum1", "sfx_egsum2", "sfx_egsum3"},
		vfx_skill = {"sfx_egskl1", "sfx_egskl2", "sfx_egskl3"},
		vfx_item = {"sfx_egskl2"},
		vfx_heal = {"sfx_eghel1"},
		vfx_healself = {"sfx_eghel1"},
		vfx_1more = {"sfx_eg1mr1", "sfx_eg1mr2", "sfx_eg1mr3", "sfx_eg1mr4"},
		vfx_crit = {"sfx_egcrt1", "sfx_egcrt2", "sfx_egcrt3"},
		vfx_aoaask = {"sfx_egaoi1"},
		vfx_aoado = {"sfx_egaoa1", "sfx_egaoa2"},
		vfx_aoarelent = {"sfx_egdge1"},
		vfx_miss = {"sfx_egmis1", "sfx_egmis2"},
		vfx_dodge = {"sfx_egdge1"},
		vfx_win = {"sfx_egwin1"},
		vfx_levelup = {"sfx_eg1mr2", "sfx_eghel1"},
																	
		skills = {"egg missiles", "direct combustion"},
		
		thinker = function(mo)
			local btl = server.P_BattleStatus[mo.battlen]
			if mo.cannoncooldown > 0
				mo.cannoncooldown = mo.cannoncooldown - 1
			end
			local attack = P_RandomRange(1, 4)
			if attack == 1 and not mo.cannoncharge and mo.cannoncooldown == 0
				return attackDefs["hyper cannon"], mo.enemies
			end
			if attack == 2 or attack == 3
				//dont pull out the ep steal one if theres no ep to steal you idiot
				//oh yeah and also dont platform lock if theres already a platform locked you moron
				mo.randomemerald = btl.emeralds[P_RandomRange(1, #btl.emeralds)]
				if mo.randomemerald.stolen
					return generalEnemyThinker(mo)
				end
				if mo.randomemerald.emeraldtype == 1 and btl.emeraldpow < 100
					if #btl.emeralds == 1
						return generalEnemyThinker(mo)
					end
					if btl.lockplatform != 0
						mo.randomemerald = btl.emeralds[P_RandomRange(2, #btl.emeralds-1)]
					else
						mo.randomemerald = btl.emeralds[P_RandomRange(2, #btl.emeralds)]
					end
				end
				if mo.randomemerald.emeraldtype == 7 and btl.lockplatform != 0
					return generalEnemyThinker(mo)
				end
				return attackDefs["chaos harness"], mo.enemies
			end
			return generalEnemyThinker(mo)
		end,
}

enemyList["b_emerald"] = {
		name = "Chaos Emerald",
		skillchance = 100,	
		level = 1,
		hp = 1000,
		sp = 9999,
		strength = 100,
		magic = 100,
		endurance = 50,
		luck = 10,
		agility = 60,
		thinker = generalEnemyThinker,
		boss = true,
		
		anim_stand = 		{SPR_CEMG, A, 4},
		anim_stand_hurt =	{SPR_CEMG, A, 4},
		anim_move =			{SPR_CEMG, A, 4},
		anim_run =			{SPR_CEMG, A, 4},
		anim_hurt =			{SPR_CEMG, A, 4},
		anim_getdown =		{SPR_CEMG, A, 4},
		anim_downloop =		{SPR_CEMG, A, 4},
		anim_getup =		{SPR_CEMG, A, 4},
																	
		skills = {"chaos emission"},
}

attackDefs["platform switch"] = {
		name = "Platform Switch",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 0,
		desc = "if you're reading this\nthis is a cry for help",
		target = TGT_CASTER,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					if timer == 1
						table.insert(btl.turnorder, 1, mo)
						mo.platformjumped = true
						mo.position = 0
					end
					for k,v in ipairs(btl.fighters)
						if timer == 1
							//detect players already in the platform
							if not v.enemy and v != mo and v.platform == mo.targetplatform
								mo.position = $+1
							end
						end
						if v.enemy == "b_emerald"
							if v.emeraldtype == mo.targetplatform
								if timer == 1
									ANIM_set(mo, mo.anim_aoa_end, true)
									playSound(mo.battlen, sfx_jump)
									mo.momz = 15*FRACUNIT
									mo.platform = mo.targetplatform
								end
								local tgtx = v.x + 350*cos(ANG1*90) - 70*cos(ANG1*180)
								local tgty = v.y + 350*sin(ANG1*90) - 70*sin(ANG1*180)
								local x = tgtx + (50*cos(ANG1*180))*mo.position
								local y = tgty + (50*sin(ANG1*180))*mo.position
								if not P_IsObjectOnGround(mo)
									if mo.targetplatform == 4
										mo.momx = (mo.startx - mo.x)/12
										mo.momy = (mo.starty - mo.y)/12
									else
										mo.momx = (x - mo.x)/12
										mo.momy = (y - mo.y)/12
									end
								end
								local cx = v.x + 1000*cos(ANG1*90)
								local cy = v.y + 1000*sin(ANG1*90)
								local cam = btl.cam
								cam.momx = mo.momx
								cam.momy = mo.momy
								cam.momz = (v.z - cam.z)/12
								mo.angle = R_PointToAngle2(mo.x, mo.y, v.x, v.y)
								/*CAM_goto(cam, cx, cy, v.z, R_PointToDist2(cam.x, cam.y, cx, cy)/6)
								CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, v.x, v.y))*/
							end
						end
					end
					if P_IsObjectOnGround(mo) and timer > 10
						mo.momx = 0
						mo.momy = 0
						ANIM_set(mo, mo.anim_stand, true)
					end
					if timer == 80
						mo.defaultcoords = {mo.x, mo.y, mo.z}
						for k,v in ipairs(btl.fighters)
							//add enemies
							if v.enemy and mo.platform == v.platform and v.enemy != "b_eggman"
								mo.enemies[#mo.enemies+1] = v
								v.enemies[#v.enemies+1] = mo
							end
							//add allies
							if not v.enemy and mo.platform == v.platform and v != mo
								mo.allies[#mo.allies+1] = v
								v.allies[#v.allies+1] = mo
							end
						end
						return true
					end
				end,
}

//this is peak of messy i never fail to disappoint 
//   (hi, future zens here. this was, in fact, not the peak of messy.)
attackDefs["phantom warp"] = {
		name = "Phantom Warp",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 0,
		desc = "who was in paris?",
		target = TGT_CASTER,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					if timer < 40
						cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
					end
					if timer == 1
						btl.rubyactivate = 0
						btl.rubytimer = btl.turn + 3
						table.insert(btl.turnorder, 1, mo)
						mo.platformjumped = true
						mo.position = 0
					end
					for k,v in ipairs(btl.fighters)
						if timer == 1
							//detect players already in the platform
							if not v.enemy and v != mo and v.platform == mo.targetplatform
								mo.position = $+1
							end
						end
						if v.enemy == "b_emerald"
							if v.emeraldtype == mo.targetplatform
								if timer == 1
									ANIM_set(mo, mo.anim_evoker, true)
									playSound(mo.battlen, sfx_s3ka8)
									mo.ruby = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
									mo.ruby.sprite = SPR_RUBY
									mo.ruby.scale = FRACUNIT*3/2
									mo.ruby.frame = FF_FULLBRIGHT
									mo.ruby.tics = -1
									mo.ruby.fuse = -1
								end
								if mo.ruby and mo.ruby.valid
									mo.ruby.momz = ((mo.z + 100*FRACUNIT) - mo.ruby.z)/5
								end
								if timer < 4
									CAM_stop(cam)
									local cx = mo.x + 150*cos(mo.angle)
									local cy = mo.y + 150*sin(mo.angle)
									P_TeleportMove(cam, cx, cy, mo.z + FRACUNIT*40)
								elseif timer >= 4 and timer < 40
									local cx = mo.x + 200*cos(mo.angle)
									local cy = mo.y + 200*sin(mo.angle)
									CAM_goto(cam, cx, cy, cam.z)
								end
								if timer < 40
									summonAura(mo, SKINCOLOR_MAGENTA)
								end
								if timer == 40
									playSound(mo.battlen, sfx_portal)
								end
								if timer >= 40 and timer < 50
									mo.momz = 10*FRACUNIT
									mo.spritexscale = $ - FRACUNIT/10
									mo.spriteyscale = $ + FRACUNIT/10
									mo.ruby.spritexscale = $ - FRACUNIT/10
									mo.ruby.spriteyscale = $ + FRACUNIT/10
								end
								//kill any followitem
								if timer == 50
									mo.flags2 = $|MF2_DONTDRAW
								end
									
								local tgtx = v.x + 350*cos(ANG1*90) - 70*cos(ANG1*180)
								local tgty = v.y + 350*sin(ANG1*90) - 70*sin(ANG1*180)
								local x = tgtx + (50*cos(ANG1*180))*mo.position
								local y = tgty + (50*sin(ANG1*180))*mo.position
								
								//move camera to new spot
								if timer >= 60
									local cx = x + 150*cos(mo.angle)
									local cy = y + 150*sin(mo.angle)
									local sx = mo.startx + 150*cos(mo.angle)
									local sy = mo.starty + 150*sin(mo.angle)
									if mo.targetplatform == 4
										CAM_goto(cam, sx, sy, v.floorz - 10*FRACUNIT)
									else
										CAM_goto(cam, cx, cy, v.floorz - 10*FRACUNIT)
									end
								end
								
								if timer == 100
									ANIM_set(mo, mo.anim_aoa_end, true)
									mo.platform = mo.targetplatform
									playSound(mo.battlen, sfx_portal)
									if mo.targetplatform == 4
										P_TeleportMove(mo, mo.startx, mo.starty, v.floorz - 5*FRACUNIT)
									else
										P_TeleportMove(mo, x, y, v.floorz - 5*FRACUNIT)
									end
									mo.momz = 8*FRACUNIT
								end
								if timer >= 100 and timer < 110
									mo.spritexscale = $ + FRACUNIT/10
									mo.spriteyscale = $ - FRACUNIT/10
								end
								//revive any followitem
								if timer == 100
									mo.flags2 = $ & ~MF2_DONTDRAW
								end
								if timer > 100 and P_IsObjectOnGround(mo)
									ANIM_set(mo, mo.anim_stand, true)
								end
							end
						end
					end
					if timer == 160
						mo.defaultcoords = {mo.x, mo.y, mo.z}
						for k,v in ipairs(btl.fighters)
							//add enemies
							if v.enemy and mo.platform == v.platform and v.enemy != "b_eggman"
								mo.enemies[#mo.enemies+1] = v
								v.enemies[#v.enemies+1] = mo
							end
							//add allies
							if not v.enemy and mo.platform == v.platform and v != mo
								mo.allies[#mo.allies+1] = v
								v.allies[#v.allies+1] = mo
							end
						end
						return true
					end
				end,
}

attackDefs["egg missiles"] = {
		name = "Egg Missiles",
		type = ATK_ALMIGHTY,
		costtype = CST_HP,
		cost = 20,
		hits = 4,
		desc = "Missiles. 4 of them. Yeah.",
		target = TGT_ALLENEMIES,
		accuracy = 95,
		power = 1200,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					local x = mo.x - 200*cos(mo.angle)
					local y = mo.y - 200*sin(mo.angle)
					local cx = mo.x + 2200*cos(mo.angle)
					local cy = mo.y + 2200*sin(mo.angle)
					CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, mo.x, mo.y))
					CAM_goto(cam, cx, cy, cam.z)
					if timer == 1
						mo.slowdown = 60
						mo.missiles = {}
					end
					if timer == 2 or timer == 7 or timer == 12 or timer == 17
						playSound(mo.battlen, sfx_cannon)
						local missile = P_SpawnMobj(x, y, mo.z, MT_DUMMY)
						missile.state = S_CYBRAKDEMONMISSILE
						missile.tics = -1
						missile.scale = FRACUNIT*4
						missile.target = hittargets[P_RandomRange(1, #hittargets)]
						mo.missiles[#mo.missiles+1] = missile
						local reticule = P_SpawnMobj(missile.target.x, missile.target.y, missile.target.z - 10*FRACUNIT, MT_DUMMY)
						reticule.state = S_CYBRAKDEMONTARGETRETICULE1
						reticule.fuse = -1
						reticule.scale = FRACUNIT*3/2
					end
					if timer >= 40
						if mo.slowdown > 3
							mo.slowdown = $-3
						end
					end
					if mo.missiles and #mo.missiles
						for i = 1, #mo.missiles do
							if mo.missiles[i] and mo.missiles[i].valid
								local m = mo.missiles[i]
								m.angle = R_PointToAngle2(m.x, m.y, m.target.x, m.target.y)
								local tgtx
								local tgtz
								if i == 1
									tgtx = x + 1000*FRACUNIT
									tgtz = mo.z + 650*FRACUNIT
								end
								if i == 2
									tgtx = x - 1000*FRACUNIT
									tgtz = mo.z + 650*FRACUNIT
								end
								if i == 3
									tgtx = x + 700*FRACUNIT
									tgtz = mo.z + 350*FRACUNIT
								end
								if i == 4
									tgtx = x - 700*FRACUNIT
									tgtz = mo.z + 350*FRACUNIT
								end
								
								if timer < 40
									m.momx = (tgtx - m.x)/4
									m.momz = (tgtz - m.z)/4
								else
									if mo.slowdown <= 10
										P_SpawnGhostMobj(m)
									end
									m.momx = (m.target.x - m.x)/mo.slowdown
									m.momy = (m.target.y - m.y)/mo.slowdown
									m.momz = (m.target.z - m.z)/mo.slowdown
								end
								
								if R_PointToDist2(m.x, m.y, m.target.x, m.target.y) < 100*FRACUNIT or m.target.hp <= 0
									local boom = P_SpawnMobj(m.target.x, m.target.y, m.target.z+20*FRACUNIT, MT_BOSSEXPLODE)
									boom.scale = FRACUNIT*4
									boom.state = S_PFIRE1
									playSound(mo.battlen, sfx_fire2)
									playSound(mo.battlen, sfx_fire1)
									if m.target.hp > 0
										damageObject(m.target)
									end

									localquake(mo.battlen, FRACUNIT*32, 8)

									for i = 1, 8
										local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
										smoke.scale = FRACUNIT*6
										smoke.momx = P_RandomRange(-5, 5)*FRACUNIT
										smoke.momy = P_RandomRange(-5, 5)*FRACUNIT
										smoke.momz = P_RandomRange(3, 6)*FRACUNIT
									end

									local sm = P_SpawnMobj(m.target.x, m.target.y, m.target.z, MT_SMOLDERING)
									sm.fuse = TICRATE/2
									sm.scale = m.target.scale*3/2
									P_RemoveMobj(m)
								end
							end
						end
					end
					if timer == 90
						return true
					end
				end,
}

attackDefs["hyper cannon"] = {
		name = "Hyper Cannon",
		type = ATK_ALMIGHTY,
		power = 1,
		accuracy = 999,
		costtype = CST_SP,
		cost = 0,
		desc = "beam",
		target = TGT_ALLENEMIES,
		norepel = true,
		
		hudfunc = 	function(v, mo, timer)
						
						local btl = server.P_BattleStatus[mo.battlen]
						if leveltime%2 == 0
							v.drawString(160, 60, G_TicsToMinutes(btl.eggdude.cannontimer, true) + ":" + G_TicsToSeconds(btl.eggdude.cannontimer) + ":0" + G_TicsToCentiseconds(btl.eggdude.cannontimer), V_REDMAP|V_SNAPTOTOP, "center")
						end
					end,
					
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					if timer == 1
						btl.eggdude.cannoncooldown = 6
						mo.warning = {}
						btl.eggdude.cannontarget = hittargets[P_RandomRange(1, #hittargets)].platform
						local tgtx = mo.x + 128*cos(mo.angle)
						local tgty = mo.y + 128*sin(mo.angle)
						mo.energypoint = P_SpawnMobj(tgtx, tgty, mo.z - 15*FRACUNIT, MT_DUMMY)
						mo.energypoint.state = S_THOK
						mo.energypoint.scale = FRACUNIT/16
						mo.energypoint.color = SKINCOLOR_WHITE
						mo.energypoint.frame = FF_FULLBRIGHT
						mo.energypoint.tics = -1
						mo.energypoint.destscale = FRACUNIT*3
						for i = 1, #hittargets
							hittargets[i].cannondamage = getDamage(hittargets[i], mo, nil, 100)
						end
						playSound(mo.battlen, sfx_s3kcas)
						playSound(mo.battlen, sfx_s3kd9l)
					end
					if timer > 1
						if mo.energypoint and mo.energypoint.valid
							local en = mo.energypoint
							if leveltime%3
								local energy = P_SpawnMobj(en.x-P_RandomRange(140,-140)*FRACUNIT, en.y-P_RandomRange(140,-140)*FRACUNIT, en.z-P_RandomRange(140,-140)*FRACUNIT, MT_DUMMY)
								energy.state = S_THOK
								energy.color = SKINCOLOR_WHITE
								energy.scale = FRACUNIT/2
								energy.tics = 15
								energy.fuse = 15
								energy.momx = (en.x - energy.x)/15
								energy.momy = (en.y - energy.y)/15
								energy.momz = ((en.z+60*FRACUNIT) - energy.z)/15
							end
							if leveltime%8 == 0
								local g = P_SpawnGhostMobj(en)
								g.color = SKINCOLOR_EMERALD
								g.colorized = true
								g.scalespeed = FRACUNIT/2
								g.destscale = FRACUNIT*10
								g.frame = $|FF_FULLBRIGHT
							end
						end
					end
					if timer < 40
						local cx = mo.x + 500*cos(mo.angle)
						local cy = mo.y + 500*sin(mo.angle)
						CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, mo.x, mo.y))
						CAM_goto(cam, cx, cy, cam.z)
					end
					if timer >= 40
						local en = mo.energypoint
						for mt in mapthings.iterate do
							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_BOSS3WAYPOINT
							and mt.extrainfo == btl.eggdude.cannontarget
								en.momz = (m.z - en.z)/10
								CAM_stop(cam)
								cam.momz = (m.z - en.z)/10
								break
							end
						end
					end
					if timer >= 90
						local en = mo.energypoint
						for mt in mapthings.iterate do
							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_BOSS3WAYPOINT
							and mt.extrainfo == btl.eggdude.cannontarget
								if timer == 90
									for i = 1, 40
										local tgtx = en.x + (i*80)*cos(R_PointToAngle2(en.x, en.y, m.x, m.y))
										local tgty = en.y + (i*80)*sin(R_PointToAngle2(en.x, en.y, m.x, m.y))
										local e = P_SpawnMobj(tgtx, tgty, en.z, MT_DUMMY)
										e.state = S_THOK
										e.color = SKINCOLOR_RED
										e.frame = FF_FULLBRIGHT
										e.scale = FRACUNIT*4
										e.tics = -1
										e.emeraldlink = true
										mo.warning[#mo.warning+1] = e
									end
								end
								CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, mo.x, mo.y))
								local cx = m.x + 400*cos(R_PointToAngle2(mo.x, mo.y, m.x, m.y))
								local cy = m.y + 400*sin(R_PointToAngle2(mo.x, mo.y, m.x, m.y))
								CAM_goto(cam, cx, cy, m.z + 50*FRACUNIT)
								break
							end
						end
					end
					if timer == 140
						btl.eggdude.cannonprepare = true
						return true
					end
				end,
}

attackDefs["direct combustion"] = {
		name = "Direct Combustion",
		type = ATK_ALMIGHTY,
		costtype = CST_SP,
		cost = 20,
		desc = "kaboom",
		target = TGT_ENEMY,
		accuracy = 999,
		power = 500,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					local target = hittargets[1]
					cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
					if timer == 1
						//camera stuff
						local cx = target.x - 300*cos(R_PointToAngle2(target.x, target.y, mo.x, mo.y))
						local cy = target.y - 300*sin(R_PointToAngle2(target.x, target.y, mo.x, mo.y))
						CAM_goto(cam, cx, cy, target.z + 100*FRACUNIT)
						
						//spawn the invisible thing that will spawn the dots
						local aight = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						aight.target = target
						aight.state = S_EGGMANRETICULE
						aight.tics = -1
						
						//record targets position
						target.recordx = target.x
						target.recordy = target.y
						target.recordz = target.z
						
						playSound(mo.battlen, sfx_s3k9d)
					end
					//kaboom
					if timer == 72
						damageObject(target)
						playSound(mo.battlen, sfx_brakrx)
						playSound(mo.battlen, sfx_s3kb4)
						local boom = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_BOSSEXPLODE)
						boom.scale = FRACUNIT*3
						boom.state = S_PFIRE1
						localquake(mo.battlen, FRACUNIT*32, 8)
						target.momz = 20*FRACUNIT
						P_InstaThrust(target, R_PointToAngle2(mo.x, mo.y, target.x, target.y), 5*FRACUNIT)
					end
					//spawn the after explosions like the actual brak move
					if timer >= 72
						ANIM_set(target, target.anim_hurt, true)
						if timer < 100
							P_SpawnMobj(target.recordx+P_RandomRange(-50, 50)*FRACUNIT, target.recordy+P_RandomRange(-50, 50)*FRACUNIT, target.recordz+P_RandomRange(-50, 50)*FRACUNIT, MT_CYBRAKDEMON_VILE_EXPLOSION)
						end
					end
					if timer == 130
						P_TeleportMove(target, target.defaultcoords[1], target.defaultcoords[2], target.defaultcoords[3])
						return true
					end
				end,
}

//stats are based off the zioverse and garuverse moves it uses
//...also this sucks
attackDefs["chaos harness"] = {
		name = "Chaos Harness",
		type = ATK_ALMIGHTY,
		costtype = CST_SP,
		cost = 0,
		power = 100,
		accuracy = 999,
		desc = "Uses emeralds. If only you had them.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					if timer == 1
						local cx = mo.x + 400*cos(mo.angle)
						local cy = mo.y + 400*sin(mo.angle)
						CAM_goto(cam, cx, cy, mo.z+20*FRACUNIT)
						playSound(mo.battlen, sfx_epower)
						mo.versenum = P_RandomRange(1, 2)
					end
					cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
					for k,v in ipairs(btl.fighters)
						if v.enemy == "b_emerald"
							if v == mo.randomemerald
							
								//flashy thing
								if timer == 23
									v.g = P_SpawnGhostMobj(v)
									v.g.color = v.color
									v.g.colorized = true
									v.g.destscale = FRACUNIT*4
									v.g.frame = $|FF_TRANS10
									local thok = P_SpawnMobj(v.x, v.y, v.z+5*FRACUNIT, MT_DUMMY)
									thok.state = S_INVISIBLE
									thok.tics = 1
									thok.scale = FRACUNIT
									A_OldRingExplode(thok, MT_SUPERSPARK)
									for k,v in ipairs(mo.enemies)
										if v and v.control and v.control.valid
											P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
										end
									end
								end
								if v.g and v.g.valid
									local x = cam.x + 50*cos(cam.angle)
									local y = cam.y + 50*sin(cam.angle)
									P_TeleportMove(v.g, x, y, cam.z)
								end
								
								//move the selected emerald to the eggman
								local tgtx = mo.x + 100*cos(mo.angle)
								local tgty = mo.y + 100*sin(mo.angle)
								v.momx = (tgtx - v.x)/4
								v.momy = (tgty - v.y)/4
								v.momz = (mo.z - v.z)/4
								P_SpawnGhostMobj(v)
								if timer >= 23
									local emeraldcolors = {SKINCOLOR_EMERALD, SKINCOLOR_PURPLE, SKINCOLOR_BLUE, SKINCOLOR_CYAN, SKINCOLOR_ORANGE, SKINCOLOR_RED, SKINCOLOR_GREY}
									summonAura(v, emeraldcolors[v.emeraldtype])
								end
								
								if timer == 60 and mo.randomemerald != btl.emeralds[7] --camera moves a different way in platform lock
									local cx = mo.x + 2200*cos(mo.angle)
									local cy = mo.y + 2200*sin(mo.angle)
									CAM_goto(cam, cx, cy, cam.z)
								end
								
								//CHAOS EMERALD EFFECTS
								
								if timer >= 80
								
									//GREEN EMERALD: EP STEAL
									if v.emeraldtype == 1
										local emeraldcolors = {SKINCOLOR_MINT, SKINCOLOR_EMERALD, SKINCOLOR_FOREST}
										if timer == 101
											mo.thokstuff = {}
											if btl.emeraldpow >= 100 and btl.emeraldpow < 200
												mo.eplevel = 1
											elseif btl.emeraldpow >= 200 and btl.emeraldpow < 300
												mo.eplevel = 2
											elseif btl.emeraldpow >= 300
												mo.eplevel = 3
											end
											S_StartSound(cam, sfx_s3kcal)
										end
										if timer < 120
											for i = 1, #hittargets
												local target = hittargets[i]
												for i = 1,2
													local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
													thok.color = SKINCOLOR_MINT
													thok.momx = P_RandomRange(-10, 10)*FRACUNIT
													thok.momy = P_RandomRange(-10, 10)*FRACUNIT
													thok.momz = P_RandomRange(-10, 10)*FRACUNIT
													thok.scale = FRACUNIT/10
													thok.destscale = FRACUNIT*2
												end
											end
										end
										if timer == 120
											S_StopSound(cam, sfx_s3kcal)
											localquake(mo.battlen, 1*FRACUNIT*mo.eplevel, 40)
											playSound(mo.battlen, sfx_debuff)
										end
										if timer >= 120
											btl.emeraldpow = $ - min(btl.emeraldpow, 100)
										end
										if timer >= 120 and timer < 160
											for i = 1, #hittargets
												local target = hittargets[i]
												if leveltime%6 == 0
													local g = P_SpawnGhostMobj(target)
													g.color = SKINCOLOR_EMERALD
													g.colorized = true
													g.destscale = FRACUNIT*4
													g.frame = $|FF_FULLBRIGHT
												end
												ANIM_set(target, target.anim_hurt, true)
												local h_angle = P_RandomRange(1, 359)*ANG1
												local v_angle = P_RandomRange(1, 359)*ANG1
												local dist = P_RandomRange(0, 50)
												local spd = P_RandomRange(40, 50)

												local s_x = target.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
												local s_y = target.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
												local s_z = (target.z+mo.height/2)+ dist* sin(v_angle)

												local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

												s.frame = A
												if mo.eplevel == 1
													s.color = emeraldcolors[1]
												elseif mo.eplevel == 2
													s.color = emeraldcolors[P_RandomRange(1, 2)]
												elseif mo.eplevel == 3
													s.color = emeraldcolors[P_RandomRange(1, #emeraldcolors)]
												end
												s.scale = FRACUNIT/2
												s.destscale = FRACUNIT/5
												s.target = target
												s.tics = 20
												s.momx = (mo.x - s.x)/20
												s.momy = (mo.y - s.y)/20
												s.momz = (mo.z - s.z)/20
												mo.thokstuff[#mo.thokstuff+1] = s
											end
										end
										
										//damn all this for just some afterimages
										if mo.thokstuff and #mo.thokstuff
											for i = 1, #mo.thokstuff
												if mo.thokstuff[i] and mo.thokstuff[i].valid
													local t = mo.thokstuff[i]
													P_SpawnGhostMobj(t)
												end
											end
										end
										
										if timer == 180
											local g = P_SpawnGhostMobj(mo)
											g.color = SKINCOLOR_EMERALD
											g.colorized = true
											g.destscale = FRACUNIT*4
											g.frame = $|FF_FULLBRIGHT
											local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
											thok.state = S_INVISIBLE
											thok.tics = 1
											thok.scale = FRACUNIT*4
											A_OldRingExplode(thok, MT_SUPERSPARK)
											playSound(mo.battlen, sfx_hamas2)
											playSound(mo.battlen, sfx_supert)
											cureStatus(mo)	-- clear previous status. Especially useful for hunger and its half-stats
											mo.status_condition = COND_HYPER
											buffStat(mo, "atk", 25) --used to be 25*mo.eplevel
											buffStat(mo, "mag", 25)
											buffStat(mo, "def", 25)
											buffStat(mo, "agi", 25)
											BTL_logMessage(targets[1].battlen, "All stats increased!")

											-- increase all stats
											local stats = {"strength", "magic", "endurance", "agility", "luck"}
											for i = 1, #stats do
												mo[stats[i]] = $+10
											end
											for i = 1,16
												local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
												dust.angle = ANGLE_90 + ANG1* (22*(i-1))
												dust.state = S_CDUST1
												P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
												dust.color = SKINCOLOR_WHITE
												dust.scale = FRACUNIT*2
											end
										end
										
										if timer == 210
											P_TeleportMove(v, v.emeraldx, v.emeraldy, v.emeraldz)
											return true
										end
										
									//PURPLE EMERALD: SP STEAL
									elseif v.emeraldtype == 2
										for i = 1, #hittargets
											local target = hittargets[i]
											ANIM_set(target, target.anim_hurt)
											if timer >= 81 and timer <= 120
												if timer == 81 then S_StartSound(cam, sfx_s3kcal) end
												for i = 1,2
													local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
													thok.color = SKINCOLOR_PURPLE
													thok.momx = P_RandomRange(-10, 10)*FRACUNIT
													thok.momy = P_RandomRange(-10, 10)*FRACUNIT
													thok.momz = P_RandomRange(-10, 10)*FRACUNIT
													thok.scale = FRACUNIT/10
													thok.destscale = FRACUNIT/5
												end
												localquake(mo.battlen, FRACUNIT*2, 1)
											end
											if timer == 120
												S_StopSound(cam, sfx_s3kcal)
												localquake(mo.battlen, FRACUNIT*20, 5)
												target.psiodyne = {}
												buffStat(target, "mag", -25)
												damageSP(target, 100)
												-- spawn all the particles
												for i = 1, 8 do
													local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
													ol.sprite = SPR_NTHK
													ol.color = SKINCOLOR_PURPLE
													ol.scale = 1/2
													ol.destscale = FRACUNIT/2
													ol.frame = A|FF_FULLBRIGHT
													ol.tics = -1
													ol.angle = P_RandomRange(0, 359)*ANG1

													local hthrust = P_RandomRange(0, 64)
													local vthrust = 64-hthrust
													P_InstaThrust(ol, ol.angle, hthrust*FRACUNIT)
													ol.momz = vthrust*FRACUNIT
													target.psiodyne[#target.psiodyne+1] = ol
												end
											end
											if target.psiodyne and #target.psiodyne
												-- slow all of these down
												for i = 1, #target.psiodyne do
													local f = target.psiodyne[i]
													if not f or not f.valid continue end
													local g = P_SpawnGhostMobj(f)
													g.destscale = 1
													if timer < 150
														f.momx = $*80/100
														f.momy = $*80/100
														f.momz = $*80/100
													end
													if timer == 150
														f.destscale = FRACUNIT/5
														f.scalespeed = $/2
														f.tics = 15
														f.momx = (mo.x - f.x)/15
														f.momy = (mo.y - f.y)/15
														f.momz = (mo.z - f.z)/15
													end
													for i = 1,2
														local thok = P_SpawnMobj(f.x, f.y, f.z+f.height/2, MT_DUMMY)
														thok.color = SKINCOLOR_BLUE
														thok.momx = P_RandomRange(-10, 10)*FRACUNIT
														thok.momy = P_RandomRange(-10, 10)*FRACUNIT
														thok.momz = P_RandomRange(-10, 10)*FRACUNIT
														thok.scale = FRACUNIT/15
														thok.destscale = FRACUNIT/10
													end
												end
											end
											if timer == 165
											and target ~= mo
												localquake(mo.battlen, FRACUNIT*10, 5)
												mo.atk_attacker = mo
												local g = P_SpawnGhostMobj(mo)
												g.colorized = true
												g.destscale = mo.scale*4
												g.scalespeed = mo.scale/8
												for i = 1,16
													local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
													dust.angle = ANGLE_90 + ANG1* (22*(i-1))
													dust.state = S_CDUST1
													P_InstaThrust(dust, dust.angle, 15*FRACUNIT)
													dust.color = SKINCOLOR_WHITE
													dust.scale = FRACUNIT*2
												end
											end
											if timer >= 165
												if leveltime%2 == 0
													for i = 1, 4
														local thok = P_SpawnMobj(mo.x+P_RandomRange(-70, 70)*FRACUNIT, mo.y+P_RandomRange(-70, 70)*FRACUNIT, mo.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
														thok.sprite = SPR_SUMN
														thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
														thok.momz = P_RandomRange(6, 16)*FRACUNIT
														thok.color = SKINCOLOR_TEAL
														thok.tics = P_RandomRange(10, 35)
													end
												end
												summonAura(mo, SKINCOLOR_TEAL)
											end
											if timer == 220
												P_TeleportMove(v, v.emeraldx, v.emeraldy, v.emeraldz)
												return true 
											end
										end
										//some stuff is moved down here so it doesnt happen four times
										if timer == 120
											playSound(mo.battlen, sfx_absorb)
											playSound(mo.battlen, sfx_s3ka8)
										end
										if timer == 165
											playSound(mo.battlen, sfx_hamas2)
											playSound(mo.battlen, sfx_buff)
											buffStat(mo, "mag", 25)
										end
									
									//BLUE EMERALD: RANDOM STATUS
									elseif v.emeraldtype == 3
										local colors = {SKINCOLOR_ORANGE, SKINCOLOR_GREEN, SKINCOLOR_LAVENDER, SKINCOLOR_TEAL, SKINCOLOR_RED}
										if timer == 81
											mo.fields = {}
											mo.sparkles = {}
											mo.angspeed = 3
											playSound(mo.battlen, sfx_kc59)
											for i = 1, #hittargets
												local field = P_SpawnMobj(mo.x, mo.y, mo.z - 5*FRACUNIT, MT_DUMMY)
												field.state = S_INVISIBLE
												field.tics = -1
												field.target = hittargets[i]
												mo.fields[#mo.fields+1] = field
												for i = 1, 20
													local ang = ANG1*(18*(i-1))
													local tgtx = mo.x + 60*cos(mo.angle + ang)
													local tgty = mo.y + 60*sin(mo.angle + ang)
													local sparkle = P_SpawnMobj(tgtx, tgty, mo.z - 5*FRACUNIT, MT_DUMMY)
													sparkle.rotate = ang
													sparkle.scale = FRACUNIT/2
													sparkle.tics = -1
													sparkle.sprite = SPR_FILD
													sparkle.frame = FF_FULLBRIGHT
													sparkle.colorized = true
													sparkle.target = field
													mo.sparkles[#mo.sparkles+1] = sparkle
												end
											end
										end
										if timer >= 140 and timer < 180
											for i = 1, #hittargets
												if leveltime%4 == 0
													local g = P_SpawnGhostMobj(hittargets[i])
													g.color = colors[P_RandomRange(1, #colors)]
													g.colorized = true
													g.destscale = FRACUNIT*4
													g.frame = $|FF_FULLBRIGHT
												end
											end
											if leveltime%2 == 0
												mo.angspeed = $+1
											end
										end
										if timer >= 180
											if mo.angspeed > 0
												if leveltime%2 == 0
													mo.angspeed = $-1
												end
											end
											if timer == 180
												for i = 1, #hittargets
													local target = hittargets[i]
													cureStatus(target)
													//burn, freeze, poison, or dizzy
													local statuses = {COND_BURN, COND_FREEZE, COND_POISON, COND_DIZZY}
													inflictStatus(target, statuses[P_RandomRange(1, #statuses)])
													BTL_logMessage(targets[1].battlen, "Status effects inflicted!")
													local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
													thok.state = S_INVISIBLE
													thok.tics = 1
													thok.scale = FRACUNIT
													A_OldRingExplode(thok, MT_SUPERSPARK)
												end
												playSound(mo.battlen, sfx_psi)
												playSound(mo.battlen, sfx_kc34)
											end
										end
										
										if mo.fields and #mo.fields
											for i = 1, #mo.fields
												if mo.fields[i] and mo.fields[i].valid
													local f = mo.fields[i]
													if timer >= 81
														f.momx = (f.target.x - f.x)/10
														f.momy = (f.target.y - f.y)/10
														f.momz = ((f.target.z-5*FRACUNIT) - f.z)/10
													end
													if timer >= 130
														if timer == 130
															ANIM_set(f.target, f.target.anim_hurt, true)
														end
														f.target.angle = $ + ANG1*5*mo.angspeed
													end
													if timer == 230
														P_RemoveMobj(f)
													end
												end
											end
										end
										if mo.sparkles and #mo.sparkles
											for i = 1, #mo.sparkles
												if mo.sparkles[i] and mo.sparkles[i].valid
													local s = mo.sparkles[i]
													if s.target
														local tgtx = s.target.x + 60*cos(mo.angle + s.rotate)
														local tgty = s.target.y + 60*sin(mo.angle + s.rotate)
														P_TeleportMove(s, tgtx, tgty, s.target.z)
													end
													s.rotate = $ + ANG1*2
													if timer == 230
														P_RemoveMobj(s)
													end
												end
											end
										end
										if timer == 230
											P_TeleportMove(v, v.emeraldx, v.emeraldy, v.emeraldz)
											return true
										end
									
									//LIGHT BLUE EMERALD: TOTAL NEUTRALIZATION
									elseif v.emeraldtype == 4
										local centerx = btl.arena_coords[1]
										local centery = btl.arena_coords[2]
										local strs = {"atk", "mag", "def", "agi", "crit"}
										if timer == 81
											playSound(mo.battlen, sfx_buzz2)
											playSound(mo.battlen, sfx_buzz3)
										end
										if timer >= 81 and timer < 130
											if not (timer%4)
												local elec = P_SpawnMobj(centerx, centery, hittargets[1].z + 32*FRACUNIT, MT_DUMMY)
												elec.sprite = SPR_DELK
												elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
												elec.destscale = FRACUNIT*4
												elec.scalespeed = FRACUNIT/4
												elec.tics = TICRATE/8
												elec.color = SKINCOLOR_WHITE
											end
											if timer & 1
												local g = P_SpawnMobj(centerx, centery, hittargets[1].z + 5*FRACUNIT, MT_DUMMY)
												g.frame = FF_FULLBRIGHT
												g.color = SKINCOLOR_GREY
												g.scale = FRACUNIT*3/2
												g.tics = 1
											end
										end
										if timer == 130
											playSound(mo.battlen, sfx_megi6)
											playSound(mo.battlen, sfx_status)
											P_LinedefExecute(1002)
											
											local an = 0
											for i = 1, 32

												local s = P_SpawnMobj(centerx, centery, hittargets[1].z + FRACUNIT*32, MT_DUMMY)
												s.color = SKINCOLOR_WHITE
												s.state = S_MEGITHOK
												s.scale = $/2
												s.fuse = TICRATE*2
												P_InstaThrust(s, an*ANG1, 50<<FRACBITS)

												s = P_SpawnMobj(centerx, centery, hittargets[1].z + FRACUNIT*32, MT_DUMMY)
												s.color = SKINCOLOR_WHITE
												s.state = S_MEGITHOK
												s.scale = $/4
												s.fuse = TICRATE*2
												P_InstaThrust(s, an*ANG1, 30<<FRACBITS)

												an = $ + (360/32)
											end

											for i = 1, #hittargets
												for j = 1, #strs
													local t = hittargets[i]
													local s = strs[j]
													t.buffs[s][1] = 0
													t.buffs[s][2] = 0
													cureStatus(t)
													t.powercharge = false
													t.mindcharge = false
												end
											end
											
											BTL_logMessage(targets[1].battlen, "All statuses nullified")
										end
										if timer == 160
											P_TeleportMove(v, v.emeraldx, v.emeraldy, v.emeraldz)
											return true
										end
										
									//ORANGE EMERALD: ZIOVERSE/GARUVERSE
									elseif v.emeraldtype == 5
										if mo.versenum == 1
											for k, e in ipairs(hittargets)
												local time = timer - 10*(k-1)
												local target = e
												if (time == 100)
													-- first one, the one behind
													local z1 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
													z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_TEAL
													z1.destscale = target.scale    -- this probably looks retarded at smaller scales from afar lmao
													-- second, the dominant in front
													local z2 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
													z2.state, z2.scale, z2.color = S_LZIO21, target.scale*9/4, SKINCOLOR_GOLD
													z2.destscale = target.scale

													playSound(mo.battlen, sfx_zio1)
													damageObject(target)

													if target.damagestate ~= DMG_MISS
													and target.damagestate ~= DMG_BLOCK
													and target.damagestate ~= DMG_DRAIN
														startField(target, FLD_ZIOVERSE, 4)
													end

												end
											end
											if (timer == 140 + (#targets-1)*10)
												return true
											end
										else
											for k,e in ipairs(hittargets)
												local target = e
												local time = timer - 5*(k-1)

												if time == 100
													playSound(mo.battlen, sfx_wind2)
													for i = 1, 10
														local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 120)*FRACUNIT, MT_GARU)
														g.target = target
														g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
														if i == 1 or i == 8
															g.jizzcolor = true
														end
														if i%2
															g.invertrotation = true
														end
														g.dist = P_RandomRange(45, 140)
														g.tics = 25
														g.lowquality = true
													end

												elseif time == 110
												or time == 113
												or time == 116
												or time == 119
													local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
													s.scale = FRACUNIT/4
													s.sprite = SPR_SLAS
													s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
													s.destscale = FRACUNIT*9
													s.scalespeed = FRACUNIT
													s.tics = TICRATE/3

												elseif time == 120
													damageObject(target)
													if target.damagestate ~= DMG_MISS
													and target.damagestate ~= DMG_BLOCK
													and target.damagestate ~= DMG_DRAIN
														startField(target, FLD_GARUVERSE, 4)
													end
												end
												if timer == 155 + 5*(#hittargets-1)
													P_TeleportMove(v, v.emeraldx, v.emeraldy, v.emeraldz)
													return true
												end
											end
										end
									
									//RED EMERALD: PLATFORM WARP
									elseif v.emeraldtype == 6
										v.momx = (v.emeraldx - v.x)/4
										v.momy = (v.emeraldy - v.y)/4
										v.momz = (v.emeraldz - v.z)/4
										for i = 1, #hittargets
											local target = hittargets[i]
											if timer == 81
												target.warpz = target.z
												target.position = 0
												target.platform = 0
											end
											if timer == 81+i*2
												target.platform = P_RandomRange(1, 7)
											end
										end
										for i = 1, #hittargets
											local target = hittargets[i]
											for k,v in ipairs(btl.fighters)
												if timer == 81+i*2
													//detect players already in the platform
													if not v.enemy and v != target and v.platform == target.platform
														target.position = $+1
													end
												end
												if v.enemy == "b_emerald"
													if v.emeraldtype == target.platform
														if timer == 90
															ANIM_set(target, target.anim_hurt, true)
														end
														if timer >= 90 and timer < 120
															target.momz = (target.warpz+100*FRACUNIT - target.z)/5
														end
														if timer >= 120 and timer < 130
															target.momz = 10*FRACUNIT
															target.spritexscale = $ - FRACUNIT/10
															target.spriteyscale = $ + FRACUNIT/10
															/*if target.followmobj and target.followmobj.valid
																target.followmobj.spritexscale = $ - FRACUNIT/10
																target.followmobj.spriteyscale = $ + FRACUNIT/10
															end*/
														end
														//kill any followitem
														if timer == 130
															target.flags2 = $|MF2_DONTDRAW
														end
															
														if timer > 120
															local tgtx = v.x + 350*cos(ANG1*90) - 70*cos(ANG1*180)
															local tgty = v.y + 350*sin(ANG1*90) - 70*sin(ANG1*180)
															local x = tgtx + (50*cos(ANG1*180))*target.position
															local y = tgty + (50*sin(ANG1*180))*target.position
															
															if timer == 180
																ANIM_set(target, target.anim_hurt, true)
																if target.platform == 4
																	P_TeleportMove(target, target.startx, target.starty, v.floorz - 5*FRACUNIT)
																else
																	P_TeleportMove(target, x, y, v.floorz - 5*FRACUNIT)
																end
																target.momz = 8*FRACUNIT
															end
															//revive any followitem
															if timer == 180
																target.flags2 = $ & ~MF2_DONTDRAW
															end
															if timer >= 180 and timer < 190
																target.spritexscale = $ + FRACUNIT/10
																target.spriteyscale = $ - FRACUNIT/10
																/*if target.followmobj and target.followmobj.valid
																	target.followmobj.spritexscale = $ + FRACUNIT/10
																	target.followmobj.spriteyscale = $ - FRACUNIT/10
																end*/
															end
															if timer > 180 and P_IsObjectOnGround(target)
																ANIM_set(target, target.anim_stand, true)
															end
														end
													end
												end
											end
											if timer >= 230
												target.defaultcoords = {target.x, target.y, target.z}
											end
											if timer == 200+i*5
												for k,v in ipairs(btl.fighters)
													//add enemies
													if v.enemy and target.platform == v.platform and v.enemy != "b_eggman"
														target.enemies[#target.enemies+1] = v
														v.enemies[#v.enemies+1] = target
													end
													//add allies
													if not v.enemy and target.platform == v.platform and v != target
														target.allies[#target.allies+1] = v
														v.allies[#v.allies+1] = target
													end
												end
											end
										end
										//sound effects but over here so they dont happen quadruple times
										if timer == 90
											playSound(mo.battlen, sfx_s3ka8)
										end
										if timer == 120 or timer == 180
											playSound(mo.battlen, sfx_portal)
										end
										if timer == 240
											return true
										end
										
									//GREY EMERALD: PLATFORM LOCK + HEAT RISE BADNIKS
									elseif v.emeraldtype == 7
										local platformtags = {31, 30, 29, 28, 8, 9, 10}
										local platformtags2 = {20, 19, 17, 15, 11, 12, 13}
										local colors = {SKINCOLOR_ORANGE, SKINCOLOR_TEAL, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD}
										//camera thing first
										if timer >= 81
											if timer == 81
												btl.lockplatform = hittargets[P_RandomRange(1, #hittargets)].platform
											end
											for mt in mapthings.iterate do
												local m = mt.mobj
												if not m or not m.valid continue end

												if m and m.valid and m.type == MT_BOSS3WAYPOINT
												and mt.extrainfo == btl.lockplatform
													CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, mo.x, mo.y))
													local cx = m.x + 400*cos(R_PointToAngle2(mo.x, mo.y, m.x, m.y))
													local cy = m.y + 400*sin(R_PointToAngle2(mo.x, mo.y, m.x, m.y))
													CAM_goto(cam, cx, cy, m.z + 50*FRACUNIT)
													break
												end
											end
										end
										
										//MY EYEEEEES
										if timer == 120
											btl.locktimer = btl.turn
											btl.lockrelease = btl.turn + 2
											for k,v in ipairs(mo.enemies)
												if v and v.control and v.control.valid
													P_FlashPal(v.control, 1, 5) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
												end
											end
											for s in sectors.iterate
												//for walls
												if s.tag == 53 or s.tag == 54
													for i = 0, 2 --why is it like this im crying
														if s.lines[i].tag == platformtags[btl.lockplatform]
															local tag = btl.lockplatform
															if tag == 3 or tag == 5
																s.ceilingheight = -1556*FRACUNIT
																s.floorheight = -1856*FRACUNIT
															end
															if tag == 2 or tag == 6
																s.ceilingheight = -1436*FRACUNIT
																s.floorheight = -1736*FRACUNIT
															end
															if tag == 1 or tag == 7
																s.ceilingheight = -1260*FRACUNIT
																s.floorheight = -1560*FRACUNIT
															end
															if tag == 4
																s.floorheight = -6000*FRACUNIT
															end
														end
													end
												end
												//for ceiling
												if s.tag == 41 or s.tag == 42
													for i = 0, 2 --why is it like this im crying
														if s.lines[i].tag == platformtags2[btl.lockplatform]
															local tag = btl.lockplatform
															if tag == 3 or tag == 5
																s.ceilingheight = -1556*FRACUNIT
																s.floorheight = -1592*FRACUNIT
															end
															if tag == 2 or tag == 6
																s.ceilingheight = -1436*FRACUNIT
																s.floorheight = -1472*FRACUNIT
															end
															if tag == 1 or tag == 7
																s.ceilingheight = -1260*FRACUNIT
																s.floorheight = -1296*FRACUNIT
															end
														end
													end
												end
												if s.tag == platformtags[btl.lockplatform]
													for i = 0, 3
														s.lines[i].frontside.midtexture = 3737
														s.lines[i].backside.midtexture = 3737
													end
												end
											end
											P_LinedefExecute(1002)
											playSound(mo.battlen, sfx_s3k9f)
											playSound(mo.battlen, sfx_hamas2)
										end
										
										//heat rise the badniks on the same platform
										for k,v in ipairs(btl.fighters)
											if v.platform == btl.lockplatform and v.enemy and v != mo
												if timer == 150
													playSound(mo.battlen, sfx_buff)
													buffStat(v, "atk")
													buffStat(v, "mag")
													buffStat(v, "def")
													buffStat(v, "agi")

													BTL_logMessage(targets[1].battlen, "All stats increased!")

													for i = 1,16
														local dust = P_SpawnMobj(v.x, v.y, v.z, MT_DUMMY)
														dust.angle = ANGLE_90 + ANG1* (22*(i-1))
														dust.state = S_CDUST1
														P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
														dust.color = SKINCOLOR_WHITE
														dust.scale = FRACUNIT*2
													end

												elseif timer > 150 and timer <= 180

													if leveltime%2 == 0
														for i = 1,16

															local thok = P_SpawnMobj(v.x+P_RandomRange(-70, 70)*FRACUNIT, v.y+P_RandomRange(-70, 70)*FRACUNIT, v.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
															thok.state = S_CDUST1
															thok.momz = P_RandomRange(3, 10)*FRACUNIT
															thok.color = SKINCOLOR_WHITE
															thok.tics = P_RandomRange(10, 35)
															thok.scale = FRACUNIT*3/2
														end
													end

													for i = 1, 8
														local thok = P_SpawnMobj(v.x+P_RandomRange(-70, 70)*FRACUNIT, v.y+P_RandomRange(-70, 70)*FRACUNIT, v.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
														thok.sprite = SPR_SUMN
														thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
														thok.momz = P_RandomRange(6, 16)*FRACUNIT
														thok.color = colors[P_RandomRange(1, #colors)]
														thok.tics = P_RandomRange(10, 35)
													end
												end
											end
										end
										if timer == 190
											--v.flags = $ & ~MF_NOCLIP
											P_TeleportMove(v, v.emeraldx, v.emeraldy, v.emeraldz)
											return true
										end
									end
								end
							end
						end
					end
				end,
}	//...longest damn move in the entire mod...

//the emerald enemies will have the same effects as their moves
attackDefs["chaos emission"] = {
		name = "Chaos Emission",
		type = ATK_ALMIGHTY,
		costtype = CST_SP,
		cost = 0,
		power = 100,
		accuracy = 999,
		desc = "Emeralds doing emerald things",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					//GREEN EMERALD: EP STEAL
					if mo.emeraldtype == 1
						local emeraldcolors = {SKINCOLOR_MINT, SKINCOLOR_EMERALD, SKINCOLOR_FOREST}
						if timer == 1
							mo.thokstuff = {}
							if btl.emeraldpow < 100
								mo.eplevel = 0
							elseif btl.emeraldpow >= 100 and btl.emeraldpow < 200
								mo.eplevel = 1
							elseif btl.emeraldpow >= 200 and btl.emeraldpow < 300
								mo.eplevel = 2
							elseif btl.emeraldpow >= 300
								mo.eplevel = 3
							end
							S_StartSound(cam, sfx_s3kcal)
						end
						if timer < 40
							for i = 1, #hittargets
								local target = hittargets[i]
								for i = 1,2
									local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
									thok.color = SKINCOLOR_MINT
									thok.momx = P_RandomRange(-10, 10)*FRACUNIT
									thok.momy = P_RandomRange(-10, 10)*FRACUNIT
									thok.momz = P_RandomRange(-10, 10)*FRACUNIT
									thok.scale = FRACUNIT/10
									thok.destscale = FRACUNIT*2
								end
							end
						end
						if timer == 40
							S_StopSound(cam, sfx_s3kcal)
							localquake(mo.battlen, 1*FRACUNIT*mo.eplevel, 40)
							playSound(mo.battlen, sfx_debuff)
						end
						if timer >= 40
							btl.emeraldpow = $ - min(btl.emeraldpow, 100)
						end
						if timer >= 40 and timer < 80
							for i = 1, #hittargets
								local target = hittargets[i]
								if leveltime%6 == 0
									local g = P_SpawnGhostMobj(target)
									g.color = SKINCOLOR_EMERALD
									g.colorized = true
									g.destscale = FRACUNIT*4
									g.frame = $|FF_FULLBRIGHT
								end
								ANIM_set(target, target.anim_hurt, true)
								local h_angle = P_RandomRange(1, 359)*ANG1
								local v_angle = P_RandomRange(1, 359)*ANG1
								local dist = P_RandomRange(0, 50)
								local spd = P_RandomRange(40, 50)

								local s_x = target.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
								local s_y = target.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
								local s_z = (target.z+mo.height/2)+ dist* sin(v_angle)

								local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

								s.frame = A
								if mo.eplevel == 1 or mo.eplevel == 0
									s.color = emeraldcolors[1]
								elseif mo.eplevel == 2
									s.color = emeraldcolors[P_RandomRange(1, 2)]
								elseif mo.eplevel == 3
									s.color = emeraldcolors[P_RandomRange(1, #emeraldcolors)]
								end
								s.scale = FRACUNIT/2
								s.destscale = FRACUNIT/5
								s.target = target
								s.tics = 20
								s.momx = (mo.x - s.x)/20
								s.momy = (mo.y - s.y)/20
								s.momz = (mo.z - s.z)/20
								mo.thokstuff[#mo.thokstuff+1] = s
							end
						end
						
						//damn all this for just some afterimages
						if mo.thokstuff and #mo.thokstuff
							for i = 1, #mo.thokstuff
								if mo.thokstuff[i] and mo.thokstuff[i].valid
									local t = mo.thokstuff[i]
									P_SpawnGhostMobj(t)
								end
							end
						end
						
						if timer == 100
							local g = P_SpawnGhostMobj(mo)
							g.color = SKINCOLOR_EMERALD
							g.colorized = true
							g.destscale = FRACUNIT*4
							g.frame = $|FF_FULLBRIGHT
							playSound(mo.battlen, sfx_s3kcas)
						end
						
						if timer == 130
							return true
						end
						
					//PURPLE EMERALD: SP STEAL
					elseif mo.emeraldtype == 2
						for i = 1, #hittargets
							local target = hittargets[i]
							ANIM_set(target, target.anim_hurt)
							if timer >= 1 and timer <= 40
								if timer == 1 then S_StartSound(cam, sfx_s3kcal) end
								for i = 1,2
									local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
									thok.color = SKINCOLOR_PURPLE
									thok.momx = P_RandomRange(-10, 10)*FRACUNIT
									thok.momy = P_RandomRange(-10, 10)*FRACUNIT
									thok.momz = P_RandomRange(-10, 10)*FRACUNIT
									thok.scale = FRACUNIT/10
									thok.destscale = FRACUNIT/5
								end
								localquake(mo.battlen, FRACUNIT*2, 1)
							end
							if timer == 40
								S_StopSound(cam, sfx_s3kcal)
								localquake(mo.battlen, FRACUNIT*20, 5)
								target.psiodyne = {}
								buffStat(target, "mag", -25)
								damageSP(target, 100)
								-- spawn all the particles
								for i = 1, 8 do
									local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
									ol.sprite = SPR_NTHK
									ol.color = SKINCOLOR_PURPLE
									ol.scale = 1/2
									ol.destscale = FRACUNIT/2
									ol.frame = A|FF_FULLBRIGHT
									ol.tics = -1
									ol.angle = P_RandomRange(0, 359)*ANG1

									local hthrust = P_RandomRange(0, 64)
									local vthrust = 64-hthrust
									P_InstaThrust(ol, ol.angle, hthrust*FRACUNIT)
									ol.momz = vthrust*FRACUNIT
									target.psiodyne[#target.psiodyne+1] = ol
								end
							end
							if target.psiodyne and #target.psiodyne
								-- slow all of these down
								for i = 1, #target.psiodyne do
									local f = target.psiodyne[i]
									if not f or not f.valid continue end
									local g = P_SpawnGhostMobj(f)
									g.destscale = 1
									if timer < 70
										f.momx = $*80/100
										f.momy = $*80/100
										f.momz = $*80/100
									end
									if timer == 70
										f.destscale = FRACUNIT/5
										f.scalespeed = $/2
										f.tics = 15
										f.momx = (mo.x - f.x)/15
										f.momy = (mo.y - f.y)/15
										f.momz = (mo.z - f.z)/15
									end
									for i = 1,2
										local thok = P_SpawnMobj(f.x, f.y, f.z+f.height/2, MT_DUMMY)
										thok.color = SKINCOLOR_BLUE
										thok.momx = P_RandomRange(-10, 10)*FRACUNIT
										thok.momy = P_RandomRange(-10, 10)*FRACUNIT
										thok.momz = P_RandomRange(-10, 10)*FRACUNIT
										thok.scale = FRACUNIT/15
										thok.destscale = FRACUNIT/10
									end
								end
							end
							if timer == 85
							and target ~= mo
								localquake(mo.battlen, FRACUNIT*10, 5)
								mo.atk_attacker = mo
								local g = P_SpawnGhostMobj(mo)
								g.colorized = true
								g.destscale = mo.scale*4
								g.scalespeed = mo.scale/8
								for i = 1,16
									local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
									dust.angle = ANGLE_90 + ANG1* (22*(i-1))
									dust.state = S_CDUST1
									P_InstaThrust(dust, dust.angle, 15*FRACUNIT)
									dust.color = SKINCOLOR_WHITE
									dust.scale = FRACUNIT*2
								end
							end
							if timer >= 85
								if leveltime%2 == 0
									for i = 1, 4
										local thok = P_SpawnMobj(mo.x+P_RandomRange(-70, 70)*FRACUNIT, mo.y+P_RandomRange(-70, 70)*FRACUNIT, mo.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
										thok.sprite = SPR_SUMN
										thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
										thok.momz = P_RandomRange(6, 16)*FRACUNIT
										thok.color = SKINCOLOR_TEAL
										thok.tics = P_RandomRange(10, 35)
									end
								end
								summonAura(mo, SKINCOLOR_TEAL)
							end
							if timer == 140
								return true 
							end
						end
						//some stuff is moved down here so it doesnt happen four times
						if timer == 40
							playSound(mo.battlen, sfx_absorb)
							playSound(mo.battlen, sfx_s3ka8)
						end
						if timer == 85
							playSound(mo.battlen, sfx_hamas2)
							playSound(mo.battlen, sfx_buff)
							buffStat(mo, "mag", 25)
						end
					
					//BLUE EMERALD: RANDOM STATUS
					elseif mo.emeraldtype == 3
						local colors = {SKINCOLOR_ORANGE, SKINCOLOR_GREEN, SKINCOLOR_LAVENDER, SKINCOLOR_TEAL, SKINCOLOR_RED}
						if timer == 1
							mo.fields = {}
							mo.sparkles = {}
							mo.angspeed = 3
							playSound(mo.battlen, sfx_kc59)
							for i = 1, #hittargets
								local field = P_SpawnMobj(mo.x, mo.y, mo.z - 5*FRACUNIT, MT_DUMMY)
								field.state = S_INVISIBLE
								field.tics = -1
								field.target = hittargets[i]
								mo.fields[#mo.fields+1] = field
								for i = 1, 20
									local ang = ANG1*(18*(i-1))
									local tgtx = mo.x + 60*cos(mo.angle + ang)
									local tgty = mo.y + 60*sin(mo.angle + ang)
									local sparkle = P_SpawnMobj(tgtx, tgty, mo.z - 5*FRACUNIT, MT_DUMMY)
									sparkle.rotate = ang
									sparkle.scale = FRACUNIT/2
									sparkle.tics = -1
									sparkle.sprite = SPR_FILD
									sparkle.frame = FF_FULLBRIGHT
									sparkle.colorized = true
									sparkle.target = field
									mo.sparkles[#mo.sparkles+1] = sparkle
								end
							end
						end
						if timer >= 60 and timer < 100
							for i = 1, #hittargets
								if leveltime%4 == 0
									local g = P_SpawnGhostMobj(hittargets[i])
									g.color = colors[P_RandomRange(1, #colors)]
									g.colorized = true
									g.destscale = FRACUNIT*4
									g.frame = $|FF_FULLBRIGHT
								end
							end
							if leveltime%2 == 0
								mo.angspeed = $+1
							end
						end
						if timer >= 100
							if mo.angspeed > 0
								if leveltime%2 == 0
									mo.angspeed = $-1
								end
							end
							if timer == 100
								for i = 1, #hittargets
									local target = hittargets[i]
									cureStatus(target)
									//burn, freeze, poison, or dizzy
									local statuses = {COND_BURN, COND_FREEZE, COND_POISON, COND_DIZZY}
									inflictStatus(target, statuses[P_RandomRange(1, #statuses)])
									BTL_logMessage(targets[1].battlen, "Status effects inflicted!")
									local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
									thok.state = S_INVISIBLE
									thok.tics = 1
									thok.scale = FRACUNIT
									A_OldRingExplode(thok, MT_SUPERSPARK)
								end
								playSound(mo.battlen, sfx_psi)
								playSound(mo.battlen, sfx_kc34)
							end
						end
						
						if mo.fields and #mo.fields
							for i = 1, #mo.fields
								if mo.fields[i] and mo.fields[i].valid
									local f = mo.fields[i]
									if timer >= 1
										f.momx = (f.target.x - f.x)/10
										f.momy = (f.target.y - f.y)/10
										f.momz = ((f.target.z-5*FRACUNIT) - f.z)/10
									end
									if timer >= 50
										if timer == 50
											ANIM_set(f.target, f.target.anim_hurt, true)
										end
										f.target.angle = $ + ANG1*5*mo.angspeed
									end
									if timer == 150
										P_RemoveMobj(f)
									end
								end
							end
						end
						if mo.sparkles and #mo.sparkles
							for i = 1, #mo.sparkles
								if mo.sparkles[i] and mo.sparkles[i].valid
									local s = mo.sparkles[i]
									if s.target
										local tgtx = s.target.x + 60*cos(mo.angle + s.rotate)
										local tgty = s.target.y + 60*sin(mo.angle + s.rotate)
										P_TeleportMove(s, tgtx, tgty, s.target.z)
									end
									s.rotate = $ + ANG1*2
									if timer == 150
										P_RemoveMobj(s)
									end
								end
							end
						end
						if timer == 150
							return true
						end
					
					//LIGHT BLUE EMERALD: TOTAL NEUTRALIZATION
					elseif mo.emeraldtype == 4
						local strs = {"atk", "mag", "def", "agi", "crit"}
						local centerx = btl.arena_coords[1]
						local centery = btl.arena_coords[2]
						if timer == 1
							playSound(mo.battlen, sfx_buzz2)
							playSound(mo.battlen, sfx_buzz3)
						end
						if timer >= 1 and timer < 50
							if not (timer%4)
								local elec = P_SpawnMobj(centerx, centery, hittargets[1].z + 32*FRACUNIT, MT_DUMMY)
								elec.sprite = SPR_DELK
								elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
								elec.destscale = FRACUNIT*4
								elec.scalespeed = FRACUNIT/4
								elec.tics = TICRATE/8
								elec.color = SKINCOLOR_WHITE
							end
							if timer & 1
								local g = P_SpawnMobj(centerx, centery, hittargets[1].z + 5*FRACUNIT, MT_DUMMY)
								g.frame = FF_FULLBRIGHT
								g.color = SKINCOLOR_GREY
								g.scale = FRACUNIT*3/2
								g.tics = 1
							end
						end
						if timer == 50
							playSound(mo.battlen, sfx_megi6)
							playSound(mo.battlen, sfx_status)
							P_LinedefExecute(1002)
							
							local an = 0
							for i = 1, 32

								local s = P_SpawnMobj(centerx, centery, hittargets[1].z + FRACUNIT*32, MT_DUMMY)
								s.color = SKINCOLOR_WHITE
								s.state = S_MEGITHOK
								s.scale = $/2
								s.fuse = TICRATE*2
								P_InstaThrust(s, an*ANG1, 50<<FRACBITS)

								s = P_SpawnMobj(centerx, centery, hittargets[1].z + FRACUNIT*32, MT_DUMMY)
								s.color = SKINCOLOR_WHITE
								s.state = S_MEGITHOK
								s.scale = $/4
								s.fuse = TICRATE*2
								P_InstaThrust(s, an*ANG1, 30<<FRACBITS)

								an = $ + (360/32)
							end

							for i = 1, #hittargets
								for j = 1, #strs
									local t = hittargets[i]
									local s = strs[j]
									t.buffs[s][1] = 0
									t.buffs[s][2] = 0
									cureStatus(t)
									t.powercharge = false
									t.mindcharge = false
								end
							end
							
							BTL_logMessage(targets[1].battlen, "All statuses nullified")
						end
						if timer == 80
							return true
						end
						
					//ORANGE EMERALD: ZIOVERSE/GARUVERSE
					elseif mo.emeraldtype == 5
						if mo.versenum == 1
							for k, e in ipairs(hittargets)
								local time = timer - 10*(k-1)
								local target = e
								if (time == 20)
									-- first one, the one behind
									local z1 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
									z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_TEAL
									z1.destscale = target.scale    -- this probably looks retarded at smaller scales from afar lmao
									-- second, the dominant in front
									local z2 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
									z2.state, z2.scale, z2.color = S_LZIO21, target.scale*9/4, SKINCOLOR_GOLD
									z2.destscale = target.scale

									playSound(mo.battlen, sfx_zio1)
									damageObject(target)

									if target.damagestate ~= DMG_MISS
									and target.damagestate ~= DMG_BLOCK
									and target.damagestate ~= DMG_DRAIN
										startField(target, FLD_ZIOVERSE, 4)
									end

								end
							end
							if (timer == 60 + (#targets-1)*10)
								return true
							end
						else
							for k,e in ipairs(hittargets)
								local target = e
								local time = timer - 5*(k-1)

								if time == 20
									playSound(mo.battlen, sfx_wind2)
									for i = 1, 10
										local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 120)*FRACUNIT, MT_GARU)
										g.target = target
										g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
										if i == 1 or i == 8
											g.jizzcolor = true
										end
										if i%2
											g.invertrotation = true
										end
										g.dist = P_RandomRange(45, 140)
										g.tics = 25
										g.lowquality = true
									end

								elseif time == 30
								or time == 33
								or time == 36
								or time == 39
									local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
									s.scale = FRACUNIT/4
									s.sprite = SPR_SLAS
									s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
									s.destscale = FRACUNIT*9
									s.scalespeed = FRACUNIT
									s.tics = TICRATE/3

								elseif time == 40
									damageObject(target)
									if target.damagestate ~= DMG_MISS
									and target.damagestate ~= DMG_BLOCK
									and target.damagestate ~= DMG_DRAIN
										startField(target, FLD_GARUVERSE, 4)
									end
								end
								if timer == 75 + 5*(#hittargets-1)
									return true
								end
							end
						end
					
					//RED EMERALD: PLATFORM WARP
					elseif mo.emeraldtype == 6
						if timer == 1
							mo.warptarget = hittargets[P_RandomRange(1, #hittargets)]
							local target = mo.warptarget
							target.warpz = target.z
							target.position = 0
							target.platform = P_RandomRange(1, 7)
						end
						for k,v in ipairs(btl.fighters)
							local target = mo.warptarget
							if timer == 1
								//detect players already in the platform
								if not v.enemy and v != target and v.platform == target.platform
									target.position = $+1
								end
							end
							if v.enemy == "b_emerald"
								if v.emeraldtype == target.platform
									if timer == 10
										ANIM_set(target, target.anim_hurt, true)
									end
									if timer >= 10 and timer < 40
										target.momz = (target.warpz+100*FRACUNIT - target.z)/5
									end
									if timer >= 40 and timer < 50
										target.momz = 10*FRACUNIT
										target.spritexscale = $ - FRACUNIT/10
										target.spriteyscale = $ + FRACUNIT/10
										/*if target.followmobj and target.followmobj.valid
											target.followmobj.spritexscale = $ - FRACUNIT/10
											target.followmobj.spriteyscale = $ + FRACUNIT/10
										end*/
									end
									//kill any followitem
									if timer == 50
										target.flags2 = $|MF2_DONTDRAW
									end
										
									if timer > 40
										local tgtx = v.x + 350*cos(ANG1*90) - 70*cos(ANG1*180)
										local tgty = v.y + 350*sin(ANG1*90) - 70*sin(ANG1*180)
										local x = tgtx + (50*cos(ANG1*180))*target.position
										local y = tgty + (50*sin(ANG1*180))*target.position
										
										//move camera to new spot
										if timer >= 60
											local cx = x - 200*cos(cam.angle)
											local cy = y - 200*sin(cam.angle)
											local sx = target.startx - 200*cos(cam.angle)
											local sy = target.starty - 200*sin(cam.angle)
											if target.platform == 4
												CAM_goto(cam, sx, sy, v.floorz - 10*FRACUNIT)
											else
												CAM_goto(cam, cx, cy, v.floorz - 10*FRACUNIT)
											end
										end
										
										if timer == 100
											ANIM_set(target, target.anim_hurt, true)
											if target.platform == 4
												P_TeleportMove(target, target.startx, target.starty, v.floorz - 5*FRACUNIT)
											else
												P_TeleportMove(target, x, y, v.floorz - 5*FRACUNIT)
											end
											target.momz = 8*FRACUNIT
										end
										//revive any followitem
										if timer == 100
											target.flags2 = $ & ~MF2_DONTDRAW
										end
										if timer >= 100 and timer < 110
											target.spritexscale = $ + FRACUNIT/10
											target.spriteyscale = $ - FRACUNIT/10
											/*if target.followmobj and target.followmobj.valid
												target.followmobj.spritexscale = $ + FRACUNIT/10
												target.followmobj.spriteyscale = $ - FRACUNIT/10
											end*/
										end
										if timer > 100 and P_IsObjectOnGround(target)
											ANIM_set(target, target.anim_stand, true)
										end
									end
								end
							end
							if timer >= 150
								target.defaultcoords = {target.x, target.y, target.z}
							end
							if timer == 120
								for k,v in ipairs(btl.fighters)
									//add enemies
									if v.enemy and target.platform == v.platform and v.enemy != "b_eggman"
										target.enemies[#target.enemies+1] = v
										v.enemies[#v.enemies+1] = target
									end
									//add allies
									if not v.enemy and target.platform == v.platform and v != target
										target.allies[#target.allies+1] = v
										v.allies[#v.allies+1] = target
									end
								end
							end
						end
						//sound effects but over here so they dont happen quadruple times
						if timer == 10
							playSound(mo.battlen, sfx_s3ka8)
						end
						if timer == 40 or timer == 100
							playSound(mo.battlen, sfx_portal)
						end
						if timer == 160
							return true
						end
						
					//GREY EMERALD: PLATFORM LOCK + HEAT RISE BADNIKS
					elseif mo.emeraldtype == 7
						--local platformtags = {31, 30, 29, 28, 8, 9, 10}
						--local platformtags2 = {20, 19, 17, 15, 11, 12, 13}
						local colors = {SKINCOLOR_ORANGE, SKINCOLOR_TEAL, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD}
						
						//MY EYEEEEES
						if timer == 40
							btl.locktimer = btl.turn
							btl.lockrelease = btl.turn + 2
							for k,v in ipairs(mo.enemies)
								if v and v.control and v.control.valid
									P_FlashPal(v.control, 1, 5) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
								end
							end
							for s in sectors.iterate
								//for walls
								if s.tag == 53 or s.tag == 54
									for i = 0, 2 --why is it like this im crying
										if s.lines[i].tag == 10
											s.ceilingheight = -1260*FRACUNIT
											s.floorheight = -1560*FRACUNIT
										end
									end
								end
								//for ceiling
								if s.tag == 41 or s.tag == 42
									for i = 0, 2 --why is it like this im crying
										if s.lines[i].tag == 13
											s.ceilingheight = -1260*FRACUNIT
											s.floorheight = -1296*FRACUNIT
										end
									end
								end
								if s.tag == 10 --platformtags[btl.lockplatform]
									for i = 0, 3
										s.lines[i].frontside.midtexture = 3737
										s.lines[i].backside.midtexture = 3737
									end
								end
							end
							P_LinedefExecute(1002)
							playSound(mo.battlen, sfx_s3k9f)
							playSound(mo.battlen, sfx_hamas2)
						end
						
						//heat rise the badniks on the same platform
						for k,v in ipairs(btl.fighters)
							if v.platform == 7 and v.enemy and v != mo
								if timer == 70
									playSound(mo.battlen, sfx_buff)
									buffStat(v, "atk")
									buffStat(v, "mag")
									buffStat(v, "def")
									buffStat(v, "agi")

									BTL_logMessage(targets[1].battlen, "All stats increased!")

									for i = 1,16
										local dust = P_SpawnMobj(v.x, v.y, v.z, MT_DUMMY)
										dust.angle = ANGLE_90 + ANG1* (22*(i-1))
										dust.state = S_CDUST1
										P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
										dust.color = SKINCOLOR_WHITE
										dust.scale = FRACUNIT*2
									end

								elseif timer > 70 and timer <= 100

									if leveltime%2 == 0
										for i = 1,16

											local thok = P_SpawnMobj(v.x+P_RandomRange(-70, 70)*FRACUNIT, v.y+P_RandomRange(-70, 70)*FRACUNIT, v.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
											thok.state = S_CDUST1
											thok.momz = P_RandomRange(3, 10)*FRACUNIT
											thok.color = SKINCOLOR_WHITE
											thok.tics = P_RandomRange(10, 35)
											thok.scale = FRACUNIT*3/2
										end
									end

									for i = 1, 8
										local thok = P_SpawnMobj(v.x+P_RandomRange(-70, 70)*FRACUNIT, v.y+P_RandomRange(-70, 70)*FRACUNIT, v.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
										thok.sprite = SPR_SUMN
										thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
										thok.momz = P_RandomRange(6, 16)*FRACUNIT
										thok.color = colors[P_RandomRange(1, #colors)]
										thok.tics = P_RandomRange(10, 35)
									end
								end
							end
						end
						if timer == 110
							return true
						end
					end
					
					//failsafe timer
					if timer == 210
						return true
					end
				end,
}

//god damn it
attackDefs["emerald leech2"] = {
		name = "Emerald leech",
		type = ATK_ALMIGHTY,
		costtype = CST_SP,
		cost = 0,
		power = 0,
		accuracy = 999,
		desc = "Gain 1/3 of your emerald\nmeter from each enemy affected and\ngain hyper status.",
		target = TGT_ALLENEMIES,
		nocast = 	function(targets, n)	//dont activate if only remaining enemy is eggman
						local bruh = 0
						for i = 1, #targets
							if targets[i].enemy != "b_eggman"
								bruh = $+1
							end
						end
						if bruh == 0
							BTL_logMessage(targets[1].battlen, "No effect.")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					local emeraldcolors = {SKINCOLOR_MINT, SKINCOLOR_EMERALD, SKINCOLOR_FOREST}
						if timer == 1
							mo.thokstuff = {}
							S_StartSound(cam, sfx_s3kcal)
						end
						if timer < 40
							for i = 1, #hittargets
								local target = hittargets[i]
								//dont drain from eggman
								if target.enemy != "b_eggman"
									for i = 1,2
										local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
										thok.color = SKINCOLOR_MINT
										thok.momx = P_RandomRange(-10, 10)*FRACUNIT
										thok.momy = P_RandomRange(-10, 10)*FRACUNIT
										thok.momz = P_RandomRange(-10, 10)*FRACUNIT
										thok.scale = FRACUNIT/10
										thok.destscale = FRACUNIT*2
									end
								end
							end
						end
						if timer == 40
							mo.eplevel = #hittargets-1
							S_StopSound(cam, sfx_s3kcal)
							localquake(mo.battlen, 1*FRACUNIT*mo.eplevel, 40)
							playSound(mo.battlen, sfx_debuff)
						end
						if timer >= 40 and timer < 80
							for i = 1, #hittargets
								local target = hittargets[i]
								//dont drain from eggman
								if target.enemy != "b_eggman"
									if leveltime%6 == 0
										local g = P_SpawnGhostMobj(target)
										g.color = SKINCOLOR_EMERALD
										g.colorized = true
										g.destscale = FRACUNIT*4
										g.frame = $|FF_FULLBRIGHT
									end
									ANIM_set(target, target.anim_hurt, true)
									local h_angle = P_RandomRange(1, 359)*ANG1
									local v_angle = P_RandomRange(1, 359)*ANG1
									local dist = P_RandomRange(0, 50)
									local spd = P_RandomRange(40, 50)

									local s_x = target.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
									local s_y = target.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
									local s_z = (target.z+mo.height/2)+ dist* sin(v_angle)

									local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

									s.frame = A
									if mo.eplevel == 1 or mo.eplevel == 0
										s.color = emeraldcolors[1]
									elseif mo.eplevel == 2
										s.color = emeraldcolors[P_RandomRange(1, 2)]
									elseif mo.eplevel == 3
										s.color = emeraldcolors[P_RandomRange(1, #emeraldcolors)]
									end
									s.scale = FRACUNIT/2
									s.destscale = FRACUNIT/5
									s.target = target
									s.tics = 20
									s.momx = (mo.x - s.x)/20
									s.momy = (mo.y - s.y)/20
									s.momz = (mo.z - s.z)/20
									mo.thokstuff[#mo.thokstuff+1] = s
								end
							end
						end
						
						//damn all this for just some afterimages
						if mo.thokstuff and #mo.thokstuff
							for i = 1, #mo.thokstuff
								if mo.thokstuff[i] and mo.thokstuff[i].valid
									local t = mo.thokstuff[i]
									P_SpawnGhostMobj(t)
								end
							end
						end
						
						if timer == 100
							local g = P_SpawnGhostMobj(mo)
							g.color = SKINCOLOR_EMERALD
							g.colorized = true
							g.destscale = FRACUNIT*4
							g.frame = $|FF_FULLBRIGHT
							playSound(mo.battlen, sfx_bufu6)
							//dont drain from eggman
							btl.emeraldpow = $ + ((33*(#hittargets-1))+2)
							mo.status_condition = COND_HYPER
							BTL_logMessage(mo.battlen, "Hyper Mode activated!")
							local stats = {"strength", "magic", "endurance", "agility", "luck"}
							for i = 1, #stats do
								mo[stats[i]] = $+10
							end
						end
						
						if timer == 130
							return true
						end
					end,
}

attackDefs["hyper soul leech"] = {
		name = "Hyper soul leech",
		type = ATK_ALMIGHTY,
		costtype = CST_SP,
		cost = 0,
		power = 0,
		accuracy = 999,
		showsp = true,
		desc = "Drain 100 SP from enemies\nand lower their magic by\n1 stage, buffing your own by the\nnumber of affected enemies.",
		target = TGT_ALLENEMIES,
		nocast = 	function(targets, n)	//dont activate if only remaining enemy is eggman
						local bruh = 0
						for i = 1, #targets
							if targets[i].enemy != "b_eggman"
								bruh = $+1
							end
						end
						if bruh == 0
							BTL_logMessage(targets[1].battlen, "No effect.")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					for i = 1, #hittargets
						local target = hittargets[i]
						//dont drain eggman
						if target.enemy != "b_eggman"
							ANIM_set(target, target.anim_hurt)
							if timer >= 1 and timer <= 40
								if timer == 1 then S_StartSound(cam, sfx_s3kcal) end
								for i = 1,2
									local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
									thok.color = SKINCOLOR_PURPLE
									thok.momx = P_RandomRange(-10, 10)*FRACUNIT
									thok.momy = P_RandomRange(-10, 10)*FRACUNIT
									thok.momz = P_RandomRange(-10, 10)*FRACUNIT
									thok.scale = FRACUNIT/10
									thok.destscale = FRACUNIT/5
								end
								localquake(mo.battlen, FRACUNIT*2, 1)
							end
							if timer == 40
								S_StopSound(cam, sfx_s3kcal)
								localquake(mo.battlen, FRACUNIT*20, 5)
								target.psiodyne = {}
								buffStat(target, "mag", -25)
								damageSP(target, 100)
								-- spawn all the particles
								for i = 1, 8 do
									local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
									ol.sprite = SPR_NTHK
									ol.color = SKINCOLOR_PURPLE
									ol.scale = 1/2
									ol.destscale = FRACUNIT/2
									ol.frame = A|FF_FULLBRIGHT
									ol.tics = -1
									ol.angle = P_RandomRange(0, 359)*ANG1

									local hthrust = P_RandomRange(0, 64)
									local vthrust = 64-hthrust
									P_InstaThrust(ol, ol.angle, hthrust*FRACUNIT)
									ol.momz = vthrust*FRACUNIT
									target.psiodyne[#target.psiodyne+1] = ol
								end
							end
							if target.psiodyne and #target.psiodyne
								-- slow all of these down
								for i = 1, #target.psiodyne do
									local f = target.psiodyne[i]
									if not f or not f.valid continue end
									local g = P_SpawnGhostMobj(f)
									g.destscale = 1
									if timer < 70
										f.momx = $*80/100
										f.momy = $*80/100
										f.momz = $*80/100
									end
									if timer == 70
										f.destscale = FRACUNIT/5
										f.scalespeed = $/2
										f.tics = 15
										f.momx = (mo.x - f.x)/15
										f.momy = (mo.y - f.y)/15
										f.momz = (mo.z - f.z)/15
									end
									for i = 1,2
										local thok = P_SpawnMobj(f.x, f.y, f.z+f.height/2, MT_DUMMY)
										thok.color = SKINCOLOR_BLUE
										thok.momx = P_RandomRange(-10, 10)*FRACUNIT
										thok.momy = P_RandomRange(-10, 10)*FRACUNIT
										thok.momz = P_RandomRange(-10, 10)*FRACUNIT
										thok.scale = FRACUNIT/15
										thok.destscale = FRACUNIT/10
									end
								end
							end
							if timer == 85
							and target ~= mo
								localquake(mo.battlen, FRACUNIT*10, 5)
								mo.atk_attacker = mo
								local g = P_SpawnGhostMobj(mo)
								g.colorized = true
								g.destscale = mo.scale*4
								g.scalespeed = mo.scale/8
								for i = 1,16
									local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
									dust.angle = ANGLE_90 + ANG1* (22*(i-1))
									dust.state = S_CDUST1
									P_InstaThrust(dust, dust.angle, 15*FRACUNIT)
									dust.color = SKINCOLOR_WHITE
									dust.scale = FRACUNIT*2
								end
							end
							if timer >= 85
								if leveltime%2 == 0
									for i = 1, 4
										local thok = P_SpawnMobj(mo.x+P_RandomRange(-70, 70)*FRACUNIT, mo.y+P_RandomRange(-70, 70)*FRACUNIT, mo.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
										thok.sprite = SPR_SUMN
										thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
										thok.momz = P_RandomRange(6, 16)*FRACUNIT
										thok.color = SKINCOLOR_TEAL
										thok.tics = P_RandomRange(10, 35)
									end
								end
								summonAura(mo, SKINCOLOR_TEAL)
							end
							if timer == 140
								return true 
							end
						end
					end
					//some stuff is moved down here so it doesnt happen four times
					if timer == 40
						playSound(mo.battlen, sfx_absorb)
						playSound(mo.battlen, sfx_s3ka8)
					end
					if timer == 85
						playSound(mo.battlen, sfx_hamas2)
						playSound(mo.battlen, sfx_buff)
						buffStat(mo, "mag", 25*(#hittargets-1))
						damageSP(mo, -100)
					end
				end,
}

attackDefs["status infliction"] = {
		name = "Status infliction",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 999,
		costtype = CST_SP,
		cost = 0,
		desc = "Inflicts burn, poison, freeze,\nor dizzy status to each enemy.",
		target = TGT_ALLENEMIES,
		nocast = 	function(targets, n)	//dont activate if only remaining enemy is eggman
						local bruh = 0
						for i = 1, #targets
							if targets[i].enemy != "b_eggman"
								bruh = $+1
							end
						end
						if bruh == 0
							BTL_logMessage(targets[1].battlen, "No effect.")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					local colors = {SKINCOLOR_ORANGE, SKINCOLOR_GREEN, SKINCOLOR_LAVENDER, SKINCOLOR_TEAL, SKINCOLOR_RED}
					if timer == 1
						mo.fields = {}
						mo.sparkles = {}
						mo.angspeed = 3
						playSound(mo.battlen, sfx_kc59)
						for i = 1, #hittargets
							//dont affect eggman
							if hittargets[i].enemy != "b_eggman"
								local field = P_SpawnMobj(mo.x, mo.y, mo.z - 5*FRACUNIT, MT_DUMMY)
								field.state = S_INVISIBLE
								field.tics = -1
								field.target = hittargets[i]
								mo.fields[#mo.fields+1] = field
								for i = 1, 20
									local ang = ANG1*(18*(i-1))
									local tgtx = mo.x + 60*cos(mo.angle + ang)
									local tgty = mo.y + 60*sin(mo.angle + ang)
									local sparkle = P_SpawnMobj(tgtx, tgty, mo.z - 5*FRACUNIT, MT_DUMMY)
									sparkle.rotate = ang
									sparkle.scale = FRACUNIT/2
									sparkle.tics = -1
									sparkle.sprite = SPR_FILD
									sparkle.frame = FF_FULLBRIGHT
									sparkle.colorized = true
									sparkle.target = field
									mo.sparkles[#mo.sparkles+1] = sparkle
								end
							end
						end
					end
					if timer >= 60 and timer < 100
						for i = 1, #hittargets
							//dont affect eggman
							if hittargets[i].enemy != "b_eggman"
								if leveltime%4 == 0
									local g = P_SpawnGhostMobj(hittargets[i])
									g.color = colors[P_RandomRange(1, #colors)]
									g.colorized = true
									g.destscale = FRACUNIT*4
									g.frame = $|FF_FULLBRIGHT
								end
							end
						end
						if leveltime%2 == 0
							mo.angspeed = $+1
						end
					end
					if timer >= 100
						if mo.angspeed > 0
							if leveltime%2 == 0
								mo.angspeed = $-1
							end
						end
						if timer == 100
							for i = 1, #hittargets
								local target = hittargets[i]
								//dont affect eggman
								if target.enemy != "b_eggman"
									cureStatus(target)
									//burn, freeze, poison, or dizzy
									local statuses = {COND_BURN, COND_FREEZE, COND_POISON, COND_DIZZY}
									inflictStatus(target, statuses[P_RandomRange(1, #statuses)])
									BTL_logMessage(targets[1].battlen, "Status effects inflicted!")
									local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
									thok.state = S_INVISIBLE
									thok.tics = 1
									thok.scale = FRACUNIT
									A_OldRingExplode(thok, MT_SUPERSPARK)
								end
							end
							playSound(mo.battlen, sfx_psi)
							playSound(mo.battlen, sfx_kc34)
						end
					end
					
					if mo.fields and #mo.fields
						for i = 1, #mo.fields
							if mo.fields[i] and mo.fields[i].valid
								local f = mo.fields[i]
								if timer >= 1
									f.momx = (f.target.x - f.x)/10
									f.momy = (f.target.y - f.y)/10
									f.momz = ((f.target.z-5*FRACUNIT) - f.z)/10
								end
								if timer >= 50
									if timer == 50
										ANIM_set(f.target, f.target.anim_hurt, true)
									end
									f.target.angle = $ + ANG1*5*mo.angspeed
								end
								if timer == 150
									P_RemoveMobj(f)
								end
							end
						end
					end
					if mo.sparkles and #mo.sparkles
						for i = 1, #mo.sparkles
							if mo.sparkles[i] and mo.sparkles[i].valid
								local s = mo.sparkles[i]
								if s.target
									local tgtx = s.target.x + 60*cos(mo.angle + s.rotate)
									local tgty = s.target.y + 60*sin(mo.angle + s.rotate)
									P_TeleportMove(s, tgtx, tgty, s.target.z)
								end
								s.rotate = $ + ANG1*2
								if timer == 150
									P_RemoveMobj(s)
								end
							end
						end
					end
					if timer == 150
						return true
					end
				end,
}

attackDefs["total neutralization"] = {
		name = "Total neutralization",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 999,
		costtype = CST_SP,
		cost = 0,
		desc = "Nullifies all stat buffs, debuffs,\nand status ailments for everyone.",
		target = TGT_EVERYONE,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					local centerx = btl.arena_coords[1]
					local centery = btl.arena_coords[2]
					local strs = {"atk", "mag", "def", "agi", "crit"}
					if timer == 1
						playSound(mo.battlen, sfx_buzz2)
						playSound(mo.battlen, sfx_buzz3)
					end
					if timer >= 1 and timer < 50
						if not (timer%4)
							local elec = P_SpawnMobj(centerx, centery, mo.z + 32*FRACUNIT, MT_DUMMY)
							elec.sprite = SPR_DELK
							elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
							elec.destscale = FRACUNIT*4
							elec.scalespeed = FRACUNIT/4
							elec.tics = TICRATE/8
							elec.color = SKINCOLOR_WHITE
						end
						if timer & 1
							local g = P_SpawnMobj(centerx, centery, mo.z + 5*FRACUNIT, MT_DUMMY)
							g.frame = FF_FULLBRIGHT
							g.color = SKINCOLOR_GREY
							g.scale = FRACUNIT*3/2
							g.tics = 1
						end
					end
					if timer == 50
						playSound(mo.battlen, sfx_megi6)
						playSound(mo.battlen, sfx_status)
						P_LinedefExecute(1002)
						
						local an = 0
						for i = 1, 32

							local s = P_SpawnMobj(centerx, centery, mo.z + FRACUNIT*32, MT_DUMMY)
							s.color = SKINCOLOR_WHITE
							s.state = S_MEGITHOK
							s.scale = $/2
							s.fuse = TICRATE*2
							P_InstaThrust(s, an*ANG1, 50<<FRACBITS)

							s = P_SpawnMobj(centerx, centery, mo.z + FRACUNIT*32, MT_DUMMY)
							s.color = SKINCOLOR_WHITE
							s.state = S_MEGITHOK
							s.scale = $/4
							s.fuse = TICRATE*2
							P_InstaThrust(s, an*ANG1, 30<<FRACBITS)

							an = $ + (360/32)
						end

						for i = 1, #hittargets
							for j = 1, #strs
								local t = hittargets[i]
								local s = strs[j]
								t.buffs[s][1] = 0
								t.buffs[s][2] = 0
								cureStatus(t)
								t.powercharge = false
								t.mindcharge = false
							end
						end
						
						BTL_logMessage(targets[1].battlen, "All statuses nullified")
					end
					if timer == 80
						return true
					end
				end,
}

attackDefs["platform warp"] = {
		name = "Platform warp",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 0,
		costtype = CST_SP,
		cost = 0,
		desc = "Warp to either the previous\nplatform or the next platform.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					if timer == 1
						btl.menudisplay = true
						btl.mapdisplay = false
						mo.targetplatform = mo.platform
						mo.warptimer = 0
					end
					if mo.warptimer >= 1
						--local timer = mo.warptimer
						if mo.warptimer == 2
							table.insert(btl.turnorder, 1, mo)
							mo.platformjumped = true
							mo.position = 0
							btl.menudisplay = false
						end
						for k,v in ipairs(btl.fighters)
							if mo.warptimer == 1
								//detect players already in the platform
								if not v.enemy and v != mo and v.platform == mo.targetplatform
									mo.position = $+1
								end
							end
							if v.enemy == "b_emerald"
								if v.emeraldtype == mo.targetplatform
									local tgtx = v.x + 350*cos(ANG1*90) - 70*cos(ANG1*180)
									local tgty = v.y + 350*sin(ANG1*90) - 70*sin(ANG1*180)
									local x = tgtx + (50*cos(ANG1*180))*mo.position
									local y = tgty + (50*sin(ANG1*180))*mo.position
									if mo.warptimer == 1
										ANIM_set(mo, mo.anim_aoa_end, true)
										playSound(mo.battlen, sfx_portal)
										mo.platform = mo.targetplatform
										mo.momz = 10*FRACUNIT
									end
									if mo.warptimer <= 10
										mo.spritexscale = $ + FRACUNIT/10
										mo.spriteyscale = $ - FRACUNIT/10
									end
									//kill any followitem
									if mo.warptimer == 10
										mo.flags2 = $|MF2_DONTDRAW
									end
									local cx = v.x + 1000*cos(ANG1*90)
									local cy = v.y + 1000*sin(ANG1*90)
									local cam = btl.cam
									if mo.warptimer >= 15
										CAM_goto(cam, cx, cy, v.z)
										CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, v.x, v.y))
									end
									if mo.warptimer >= 30 and mo.warptimer < 40
										if mo.warptimer == 30
											mo.momz = 10*FRACUNIT
											playSound(mo.battlen, sfx_portal)
											if mo.targetplatform == 4
												P_TeleportMove(mo, mo.startx, mo.starty, v.floorz - 5*FRACUNIT)
											else
												P_TeleportMove(mo, x, y, v.floorz - 5*FRACUNIT)
											end
										end
										mo.spritexscale = $ - FRACUNIT/10
										mo.spriteyscale = $ + FRACUNIT/10
									end
									//revive any followitem
									if mo.warptimer == 30
										mo.flags2 = $ & ~MF2_DONTDRAW
									end
									mo.angle = R_PointToAngle2(mo.x, mo.y, v.x, v.y)
								end
							end
						end
						if P_IsObjectOnGround(mo) and mo.warptimer > 10
							ANIM_set(mo, mo.anim_stand, true)
						end
						if mo.warptimer == 80
							mo.defaultcoords = {mo.x, mo.y, mo.z}
							for k,v in ipairs(btl.fighters)
								//add enemies
								if v.enemy and mo.platform == v.platform and v.enemy != "b_eggman"
									mo.enemies[#mo.enemies+1] = v
									v.enemies[#v.enemies+1] = mo
								end
								//add allies
								if not v.enemy and mo.platform == v.platform and v != mo
									mo.allies[#mo.allies+1] = v
									v.allies[#v.allies+1] = mo
								end
							end
							mo.warptimer = 0
							for k,v in ipairs(mo.skills)
								if v == "platform warp"
									table.remove(mo.skills, k)
								end
							end
							mo.giveitback = true
							return true
						end
						mo.warptimer = $+1
					end
				end,
}

attackDefs["platform lock"] = {
		name = "Platform lock",
		type = ATK_ALMIGHTY,
		power = 0,
		accuracy = 999,
		costtype = CST_SP,
		cost = 0,
		desc = "Locks your own platform, but\ntemporarily max out all stats and\nboost skill damage by x2.5 next turn.",
		target = TGT_ALLENEMIES,
		mindcharge = true,
		powercharge = true,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					local platformtags = {31, 30, 29, 28, 8, 9, 10}
					local platformtags2 = {20, 19, 17, 15, 11, 12, 13}
					local colors = {SKINCOLOR_ORANGE, SKINCOLOR_TEAL, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD, SKINCOLOR_RED}
					//camera thing first
					if timer >= 1
						if timer == 1
							btl.lockplatform = mo.platform
						end
						for mt in mapthings.iterate do
							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_BOSS3WAYPOINT
							and mt.extrainfo == btl.lockplatform
								CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, mo.x, mo.y))
								local cx = m.x + 400*cos(R_PointToAngle2(mo.x, mo.y, m.x, m.y))
								local cy = m.y + 400*sin(R_PointToAngle2(mo.x, mo.y, m.x, m.y))
								CAM_goto(cam, cx, cy, m.z + 50*FRACUNIT)
								break
							end
						end
					end
					
					//MY EYEEEEES
					if timer == 40
						btl.locktimer = btl.turn
						btl.lockrelease = btl.turn + 2
						for k,v in ipairs(mo.allies)
							if v and v.control and v.control.valid
								P_FlashPal(v.control, 1, 5) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
							end
						end
						for s in sectors.iterate
							//for walls
							if s.tag == 53 or s.tag == 54
								for i = 0, 2 --why is it like this im crying
									if s.lines[i].tag == platformtags[btl.lockplatform]
										local tag = btl.lockplatform
										if tag == 3 or tag == 5
											s.ceilingheight = -1556*FRACUNIT
											s.floorheight = -1856*FRACUNIT
										end
										if tag == 2 or tag == 6
											s.ceilingheight = -1436*FRACUNIT
											s.floorheight = -1736*FRACUNIT
										end
										if tag == 1 or tag == 7
											s.ceilingheight = -1260*FRACUNIT
											s.floorheight = -1560*FRACUNIT
										end
										if tag == 4
											s.floorheight = -6000*FRACUNIT
										end
									end
								end
							end
							//for ceiling
							if s.tag == 41 or s.tag == 42
								for i = 0, 2 --why is it like this im crying
									if s.lines[i].tag == platformtags2[btl.lockplatform]
										local tag = btl.lockplatform
										if tag == 3 or tag == 5
											s.ceilingheight = -1556*FRACUNIT
											s.floorheight = -1592*FRACUNIT
										end
										if tag == 2 or tag == 6
											s.ceilingheight = -1436*FRACUNIT
											s.floorheight = -1472*FRACUNIT
										end
										if tag == 1 or tag == 7
											s.ceilingheight = -1260*FRACUNIT
											s.floorheight = -1296*FRACUNIT
										end
									end
								end
							end
							if s.tag == platformtags[btl.lockplatform]
								for i = 0, 3
									s.lines[i].frontside.midtexture = 3737
									s.lines[i].backside.midtexture = 3737
								end
							end
						end
						P_LinedefExecute(1002)
						playSound(mo.battlen, sfx_s3k9f)
						playSound(mo.battlen, sfx_hamas2)
					end
					
					//temporarily boost the players on the same platform
					for k,v in ipairs(mo.allies)
						if v.platform == btl.lockplatform
							if timer == 1
								//record the previous stats, there's probably a better way of doing this but im tired and my brain is tired
								v.prevbuffs = {v.buffs["atk"][1], v.buffs["mag"][1], v.buffs["def"][1], v.buffs["agi"][1], v.buffs["crit"][1]}
							end
							if timer == 70
								playSound(mo.battlen, sfx_buff2)
								v.buffs["atk"][1] = 75
								v.buffs["mag"][1] = 75
								v.buffs["def"][1] = 75
								v.buffs["agi"][1] = 75
								v.buffs["crit"][1] = 75
								v.powercharge = true
								v.mindcharge = true

								BTL_logMessage(targets[1].battlen, "All stats maximized!")

								for i = 1,16
									local dust = P_SpawnMobj(v.x, v.y, v.z, MT_DUMMY)
									dust.angle = ANGLE_90 + ANG1* (22*(i-1))
									dust.state = S_CDUST1
									P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
									dust.color = SKINCOLOR_WHITE
									dust.scale = FRACUNIT*2
								end

							elseif timer > 70 and timer <= 100

								if leveltime%2 == 0
									for i = 1,16

										local thok = P_SpawnMobj(v.x+P_RandomRange(-70, 70)*FRACUNIT, v.y+P_RandomRange(-70, 70)*FRACUNIT, v.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
										thok.state = S_CDUST1
										thok.momz = P_RandomRange(3, 10)*FRACUNIT
										thok.color = SKINCOLOR_WHITE
										thok.tics = P_RandomRange(10, 35)
										thok.scale = FRACUNIT*3/2
									end
								end

								for i = 1, 8
									local thok = P_SpawnMobj(v.x+P_RandomRange(-70, 70)*FRACUNIT, v.y+P_RandomRange(-70, 70)*FRACUNIT, v.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
									thok.sprite = SPR_SUMN
									thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
									thok.momz = P_RandomRange(6, 16)*FRACUNIT
									thok.color = colors[P_RandomRange(1, #colors)]
									thok.tics = P_RandomRange(10, 35)
								end
							end
						end
					end
					if timer == 110
						return true
					end
				end,
}

attackDefs["ruby analysis"] = {
		name = "Ruby Analysis",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 0,
		desc = "Analyze 1 target, revealing\ntheir affinities. Uses up the\nPhantom Ruby, putting it on cooldown.",
		target = TGT_ENEMY,
		norepel = true,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			local btl = server.P_BattleStatus[mo.battlen]

			if mo.enemy
			or not target.enemy
				return true	-- NO.
			end

			if timer == 15

				if not btl.saved_affs[target.enemy]
					btl.saved_affs[target.enemy] = {0, 0, false}	-- failsafe?
				end
				btl.saved_affs[target.enemy][1] = 2147483647	-- INT32_MAX
				btl.saved_affs[target.enemy][2] = 2147483647	-- INT32_MAX
				btl.saved_affs[target.enemy][3] = true	-- stats

				local t = P_SpawnMobj(target.x, target.y, target.z + target.height/2, MT_THOK)
				t.tics = -1
				t.sprite = SPR_ANLY
				t.frame = FF_FULLBRIGHT
				t.scale = FRACUNIT*5/2
				t.fuse = TICRATE*2


				local g = P_SpawnGhostMobj(t)
				t.destscale = $*4
				t.scalespeed = $*4
				t.momz = FRACUNIT*4
				t.fuse = TICRATE/2
				btl.rubytimer = btl.turn + 3
			end

			if timer >= 30
				if mo.control.mo.P_inputs[BT_JUMP] == 1
				and not mo.anl_closetimer

					mo.anl_closetimer = TICRATE

				end

				if mo.anl_closetimer
					mo.anl_closetimer = $-1
					if not mo.anl_closetimer

						mo.anl_closetimer = nil
						-- give me another turn
						local i = #btl.turnorder+1
						while i > 1
							btl.turnorder[i] = btl.turnorder[i-1]
							i = $-1
						end
						return true
					end
				end
			end

		end,

		-- hudfunc2 is layered above the regular UI
		hudfunc2 = function(v, mo, timer)

			local target = mo.targets[1]
			if timer > TICRATE and target.enemy

					local cmd = {
						{BUTT_A, "Close"},
					}

				if mo.anl_closetimer
					local t = mo.anl_closetimer - TICRATE/2
					if t > 0
						v.drawScaled(160<<FRACBITS, 100<<FRACBITS, max(0, min(64, t))*FRACUNIT/2, v.cachePatch("H_1M_B"), V_50TRANS)
						drawStats(v, target, max(t, -8), 1, 0, cmd)
					end
				else
					local t = timer - TICRATE
					v.drawScaled(160<<FRACBITS, 100<<FRACBITS, max(0, min(64, t))*FRACUNIT/2, v.cachePatch("H_1M_B"), V_50TRANS)
					drawStats(v, target, max(t, -8), 1, 0, cmd)
				end
			end
		end,

	},
					

//main thinker
addHook("MobjThinker", function(mo)
	if gamemap != 12 return end
	if mo.cutscene return end
	local btl = server.P_BattleStatus[mo.battlen]
	local cam = btl.cam
	if btl.battlestate != 0
		mo.emeraldenemy = $ or false
		mo.platform = $ or 4
		mo.warptimer = $ or 0
		
		btl.eggdude = $ or nil -- eggman player
		btl.menudisplay = $ or false -- for displaying the platform options [FALSE]
		btl.mapdisplay = $ or false -- for displaying the map [FALSE]
		btl.showmap = $ or false -- for when the map is selected [FALSE]
		btl.rubycooldown = $ or 0 -- for phantom ruby warp cooldown
		btl.rubytimer = $ or 0 -- also for phantom ruby warp cooldown
		btl.rubyactivate = $ or 0 -- for ruby activation flash/fade
		btl.hideleft = $ or false -- for preventing jumping to left platform for cases like being in platform 1
		btl.hideright = $ or false -- for preventing jumping to right platform for cases like being in platform 7
		btl.emeralds = $ or {} -- emerald table, removes an entry once it is retrieved by players
		btl.lockplatform = $ or 0 -- locked platform
		btl.locktimer = $ or 0 -- lock timer
		btl.lockrelease = $ or 0 -- releases lock platform when locktimer reaches this 
		btl.metalsonicfight = $ or false -- thing for if metal sonic has joined the fight or not
		btl.superman = $ or nil -- the player that triggers the super form cutscene
		btl.rubyanalysis = $ or false
		
		if not mo.enemy
			mo.imdied = $ or false
			//alternate normal attacks
			if mo.skin == "sonic"
				mo.melee = "lunge" --mo.melee = "agi"
			elseif mo.skin == "tails"
				mo.melee = "lunge" --mo.melee = "kouha"
			elseif mo.skin == "knuckles"
				if mo.demon
					mo.melee = "megaton raid"
				else
					mo.melee = "lunge"
				end
			elseif mo.skin == "amy"
				mo.melee = "lunge" --mo.melee = "garu"
			end
			/*if mo.enemies and #mo.enemies
				for i = 1, #mo.enemies
					print(#mo.enemies[i].allies)
				end
			end*/
			//testing hack: player superpowers
			/*if mo.skin == "sonic"
				local stats = {"strength", "magic", "endurance", "agility", "luck"}
				for i = 1, #stats do
					mo[stats[i]] = 15000
				end
				btl.emeraldpow = 300
				--btl.superman = mo
			end*/
			
			if not mo.imdied and mo.hp <= 0
				playersdead = playersdead + 1
				mo.imdied = true
			end
			
			if mo.imdied and mo.hp > 0
				playersdead = playersdead - 1
				mo.imdied = false
			end
			
			/*for k,v in ipairs(btl.fighters)
				if not v.enemy
					print(#v.allies)
				end
			end*/
		else
			//random enemy affinities just like stage 4
			for i = 1, #enemies
				if mo.enemy == enemies[i]
					mo.weak = btl.weaknesses[i]
					mo.resist = btl.resistances[i]
					if btl.weaknesses[i] == btl.resistances[i]
						mo.resist = 0
					end
				end
			end
			
			//obtain chaos emerald after last badnik on the platform is defeated
			if (btl.battlestate == BS_DOTURN or btl.battlestate == BS_ACTION) and mo.platform == btl.turnorder[1].platform and mo.enemy != "b_eggman" and mo.enemy != "b_emerald" and mo.enemy != "b_metalsonic_weak"
				if mo.enemy == "platform shield" return end
				if mo.allies and #mo.allies
					if #mo.allies == 1 or (#mo.allies == 2 and (mo.allies[1].enemy == "b_metalsonic_weak" or mo.allies[2].enemy == "b_metalsonic_weak"))
						if mo.hp > 0
							mo.deathtimer = 1
						end
					else
						//amount of allies doesnt update until after a move is finished so multi targets wont trigger a last badnik cutscene, so...
						for k,v in ipairs(mo.allies)
							if v and v.valid and v != mo
								if v.hp <= 0
									table.remove(mo.allies, k)
								end
							end
						end
						mo.deathtimer = 700
					end
				end
				//metal sonic has his defeat cutscene automatically regardless of ally number
				if mo.enemy == "b_metalsonic_weak"
					mo.deathtimer = 1
				end
			end
		end
		
		//change arena center to suit the acting player's platform (mostly for checking turnorder (which still kinda doesnt help))
		if btl.turnorder[1] == mo
			for mt in mapthings.iterate do
				local m = mt.mobj
				if not m or not m.valid continue end

				if m and m.valid and m.type == MT_BOSS3WAYPOINT
				and mt.extrainfo == mo.platform
					btl.arena_coords[1] = m.x
					btl.arena_coords[2] = m.y
					btl.arena_coords[4] = ANG1*90
					break
				end
			end
		end
		
		//eggman's CANNON
		if mo.energypoint and mo.energypoint.valid and btl.eggdude and btl.eggdude.valid and btl.eggdude.cannoncharge
			local en = mo.energypoint
			if leveltime%3
				local energy = P_SpawnMobj(en.x-P_RandomRange(140,-140)*FRACUNIT, en.y-P_RandomRange(140,-140)*FRACUNIT, en.z-P_RandomRange(140,-140)*FRACUNIT, MT_DUMMY)
				energy.state = S_THOK
				energy.color = SKINCOLOR_WHITE
				energy.scale = FRACUNIT/2
				energy.tics = 15
				energy.fuse = 15
				energy.momx = (en.x - energy.x)/15
				energy.momy = (en.y - energy.y)/15
				energy.momz = ((en.z+60*FRACUNIT) - energy.z)/15
			end
			if leveltime%8 == 0
				local g = P_SpawnGhostMobj(en)
				g.color = SKINCOLOR_EMERALD
				g.colorized = true
				g.scalespeed = FRACUNIT/2
				g.destscale = FRACUNIT*10
				g.frame = $|FF_FULLBRIGHT
			end
		end
		if btl.eggdude and btl.eggdude.valid and btl.eggdude.cannoncharge and btl.eggdude.cannontimer == 0 and btl.battlestate == BS_ENDTURN
			D_startEvent(1, "ev_stage6_hyper_cannon")
		end
		if btl.eggdude and btl.eggdude == mo and btl.eggdude.cannoncharge
			if btl.eggdude.cannontimer > 0
				btl.eggdude.cannontimer = btl.eggdude.cannontimer - 1
			end
		end
		
		//kill any garuverse fields on eggman
		if mo.enemy == "b_eggman" and mo.fieldstate
			clearField(mo)
		end
		
		//make eggman immune to debuffs
		if mo.enemy == "b_eggman"
			if mo.buffs["atk"][1] < 0
			or mo.buffs["mag"][1] < 0
			or mo.buffs["agi"][1] < 0
			or mo.buffs["def"][1] < 0
				BTL_logMessage(mo.battlen, "No effect.")
				playSound(mo.battlen, sfx_s1b4)
				mo.buffs["atk"][1] = 0
				mo.buffs["mag"][1] = 0
				mo.buffs["agi"][1] = 0
				mo.buffs["def"][1] = 0
			end
		end
		
		//testing hack: kill eggman's turns (oh yeah and the emeralds)
		/*for k,v in ipairs(btl.turnorder)
			if v.enemy == "b_eggman" --or v.enemy == "b_emerald"
				table.remove(btl.turnorder, k)
			end
		end*/
		
		//testing hack: kill badnik turns
		/*for k,v in ipairs(btl.turnorder)
			if v.enemy and v.enemy != "b_eggman" and v.enemy != "b_emerald"
				table.remove(btl.turnorder, k)
			end
		end*/
		
		//testing hack: kill player turns
		/*for k,v in ipairs(btl.turnorder)
			if v.plyr
				if v.skin == "amy" or v.skin == "knuckles" or v.skin == "tails"
					table.remove(btl.turnorder, k)
				end
			end
		end*/
			
		//emerald color things
		if mo.enemy == "b_emerald" and mo.emeraldtype
			local emeraldstates = {S_CEMG1, S_CEMG2, S_CEMG3, S_CEMG4, S_CEMG5, S_CEMG6, S_CEMG7}
			mo.state = emeraldstates[mo.emeraldtype]
			/*if mo.emeraldtype == 7
				btl.turnorder[1] = mo --kill
			end*/
		end
		
		//for removing emeralds from the emerald table once obtained, cant have eggman harnessing oxygen
		for k,v in ipairs(btl.emeralds)
			if v and v.valid
				if v.changedaworl and not v.stolen
					table.remove(btl.emeralds, k)
				end
			end
		end
		
		//badnik float
		if mo.enemy == "jetty bomber" or mo.enemy == "jetty gunner" or mo.enemy == "cacolantern" or mo.enemy == "crawla commander" or mo.enemy == "crawla commander final" or mo.enemy == "b_metalsonic_weak"
			if mo.floatz
				mo.z = mo.floatz
				mo.flags = $|MF_NOGRAVITY
			end
		elseif mo.enemy == "facestabber" or mo.enemy == "robo hood"
			//KEEP THEM ON THE GROUND DAMMIT
			mo.flags = $ & ~MF_NOGRAVITY
		end
		
		//make a random enemy have a turn
		/*if btl.battlestate != BS_START
			for k,v in ipairs(btl.turnorder)
				local count = 0
				for i = 1, k
					if btl.turnorder[i].enemy
						count = count + 1
					end
				end
				print(v.name)
				if not mo.enemy and btl.battlestate == BS_ENDTURN and btl.turnorder[1] == mo and mo.enemies and #mo.enemies and #mo.enemies > 1 --and count < 5
					local num = P_RandomRange(2, #mo.enemies)
					if mo.enemies[num] and mo.enemies[num].valid
						mo.enemies[num].hi = true
					end
				end
				if mo.enemy and btl.turnorder[1] == mo and mo.hi
					if btl.battlestate == BS_ENDTURN
						mo.hi = false
					end
				end
			end
		end*/
		
		if not mo.enemy and btl.battlestate == BS_ENDTURN and btl.turnorder[1] == mo and mo.enemies and #mo.enemies and #mo.enemies > 1 --and count < 5
			local num = P_RandomRange(2, #mo.enemies)
			if mo.enemies[num] and mo.enemies[num].valid
				mo.enemies[num].hi = true
			end
		end
		if mo.enemy and btl.turnorder[1] == mo and mo.hi
			if btl.battlestate == BS_ENDTURN
				mo.hi = false
			end
		end
		if mo.enemy and not #mo.enemies
			mo.hi = false
		end
		
		//remove enemies without enemies from the turn order
		for k,v in ipairs(btl.turnorder)
			if not #v.enemies
				table.remove(btl.turnorder, k)
			else
				if v.enemy and not v.hi and v.enemy != "b_eggman" and k != 1 and not v.emeraldenemy
					table.remove(btl.turnorder, k)
				end
			end
			//emeralds dont actually disappear when retrieved, just turned invisible, so remove turns manually
			if v.emeraldenemy
				if v.changedaworl or v.stolen or (btl.lockplatform != 0 and v.emeraldtype == 7)
					table.remove(btl.turnorder, k)
				else
					if btl.turn%3 != 0
						table.remove(btl.turnorder, k)
					end
				end
			end
		end
		
		//emerald modes! giving emerald effects to enemies! this'll switch every time a badnik ends its turn
		if mo.emeraldmode
			local mode = mo.emeraldmode
			//trigger the event that will randomize the badnik's mode at the end of their turn
			if btl.turnorder[1] == mo and btl.battlestate == BS_ACTION
				mo.modeswitch = true
				D_startEvent(mo.battlen, "ev_stage6_badnik_emeraldmode") --i hate these event names im creating for myself
			end
			//coat the badnik in the mode color
			local thecolors = {SKINCOLOR_EMERALD, SKINCOLOR_MAGENTA, SKINCOLOR_BLUE, SKINCOLOR_CYAN, SKINCOLOR_YELLOW, SKINCOLOR_RED, SKINCOLOR_SILVER}
			if leveltime & 2
				local g = P_SpawnGhostMobj(mo)
				g.color = thecolors[mode]
				g.colorized = true
				g.scale = mo.scale
				g.frame = $|FF_TRANS40
			end
			if mo.hp <= 0
				mo.emeraldmode = 0
			end
		end
		
		//getting locked by a grey powered emerald
		if mo.locked
			if leveltime & 2
				local g = P_SpawnGhostMobj(mo)
				g.color = SKINCOLOR_GREY
				g.colorized = true
				g.scale = mo.scale
				g.frame = $|FF_TRANS60
			end
			if not (leveltime%6)
				local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height, MT_DUMMY)
				elec.sprite = SPR_DELK
				elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
				elec.destscale = FRACUNIT*4
				elec.scalespeed = FRACUNIT/4
				elec.tics = TICRATE/8
				elec.color = SKINCOLOR_GREY
			end
		end
		
		//lock timer increment
		if #btl.turnorder == 0 and btl.eggdude == mo
			btl.locktimer = $+1
		end
		
		//the warp dodge effect from the red emerald (activates in rewritten damage script)
		if mo.warpdodge
			if btl.battlestate == BS_ACTION or btl.battlestate == BS_PRETURN
				if leveltime & 1
					mo.flags2 = $ & ~MF2_DONTDRAW
					local g = P_SpawnGhostMobj(mo)
					g.frame = $|FF_FULLBRIGHT
					mo.flags2 = $|MF2_DONTDRAW
					g.fuse = 2
				end
			else
				mo.flags2 = $ & ~MF2_DONTDRAW
				mo.warpdodge = false
			end
		end
		
		//platform switching! oh yeah and map too i guess
		if (btl.battlestate == BS_DOTURN and not btl.turnorder[1].enemy)
		or (btl.battlestate == BS_ACTION and not btl.turnorder[1].enemy and btl.turnorder[1].attack and btl.turnorder[1].attack.name == "Platform warp") //red emerald
			//if you're super, screw you no menu for you
			if btl.turnorder[1].status_condition == COND_SUPER then btl.mapdisplay = false return end
			
			//start the hyper cannon countdown
			if btl.eggdude.cannonprepare
				btl.eggdude.cannoncharge = true
				btl.eggdude.cannonprepare = false
			end
			
			//remove options if your platform is locked, and remove map in "platform warp" move
			if btl.turnorder[1].platform != btl.lockplatform and btl.battlestate != BS_ACTION and not btl.turnorder[1].locked
				btl.mapdisplay = true
			else
				btl.mapdisplay = false
			end
			if not btl.turnorder[1].platformjumped and btl.turnorder[1].platform != btl.lockplatform and not btl.turnorder[1].locked
				btl.menudisplay = true
			else
				//dont prevent switching if you're using platform warp (red emerald)
				if not (btl.turnorder[1].attack and btl.turnorder[1].attack.name == "Platform warp")
					btl.menudisplay = false
				end
			end
			
			if btl.turnorder[1] == mo
				
				//ruby analysis thinker
				if not btl.showmap
					if mo.attack and (mo.attack.name == "Analysis" or mo.attack.name == "Ruby Analysis")
						rubydisplay = true
						
						//trace on
						if mo.control.mo.P_inputs[BT_CUSTOM1] == 1 and btl.rubycooldown == 0 and not btl.rubyanalysis
							playSound(mo.battlen, sfx_s3k9f)
							btl.rubyactivate = 12
							btl.rubyanalysis = true
							for k,v in ipairs(mo.skills)
								if v == "analysis" 
									table.remove(mo.skills, k)
									table.insert(mo.skills, "ruby analysis")
								end
							end
							BTL_setAttack(mo, "ruby analysis")
						end
						
						//trace off
						if mo.control.mo.P_inputs[BT_CUSTOM1] == 1 and btl.rubycooldown == 0 and btl.rubyanalysis and btl.rubyactivate <= 10
							playSound(mo.battlen, sfx_kc65)
							btl.rubyactivate = 0
							btl.rubyanalysis = false
							for k,v in ipairs(mo.skills)
								if v == "ruby analysis" 
									table.remove(mo.skills, k)
									table.insert(mo.skills, "analysis")
								end
							end
							BTL_setAttack(mo, "analysis")
						end
					else
						rubydisplay = false
						if btl.rubyanalysis
							playSound(mo.battlen, sfx_kc65)
							btl.rubyactivate = 0
							btl.rubyanalysis = false
							for k,v in ipairs(mo.skills)
								if v == "ruby analysis" 
									table.remove(mo.skills, k)
									table.insert(mo.skills, "analysis")
								end
							end
						end
					end
				end
				
				if btl.battlestate != BS_DOTURN
					btl.rubyactivate = 0
					btl.rubyanalysis = false
					rubydisplay = false
					for k,v in ipairs(mo.skills)
						if v == "ruby analysis" 
							table.remove(mo.skills, k)
							table.insert(mo.skills, "analysis")
						end
					end
				end
			
				//reduce ruby cooldown (note: ruby timer becomes btl.turn + 3 when cooldown is reactivated)
				if btl.turn <= btl.rubytimer
					btl.rubycooldown = btl.rubytimer - btl.turn
				else
					btl.rubytimer = 0
				end
				
				//kill the locked platform if enough turns pass since it activated
				if btl.lockplatform != 0
					if btl.locktimer >= btl.lockrelease
						local platformtags = {31, 30, 29, 28, 8, 9, 10}
						for s in sectors.iterate
							if s.tag == 53 or s.tag == 54 or s.tag == 41 or s.tag == 42
								for i = 0, 2 --why is it like this im crying
									if s.lines[i].tag != 16
										s.ceilingheight = 0
										s.floorheight = 0
									end
								end
							end
							if s.tag == platformtags[btl.lockplatform]
								for i = 0, 3
									s.lines[i].frontside.midtexture = 0
									s.lines[i].backside.midtexture = 0
								end
							end
						end
						P_LinedefExecute(1002)
						playSound(mo.battlen, sfx_kc65)
						playSound(mo.battlen, sfx_status)
						btl.lockplatform = 0
						for k,v in ipairs(btl.fighters)
							if v.prevbuffs
								local stats = {"atk", "mag", "def", "agi", "crit"}
								for i = 1, #stats
									v.buffs[stats[i]][1] = v.prevbuffs[i]
								end
							end
						end
					end
				end
				
				//do this so that mo.locked will become false when it is not your turn anymore
				if mo.locked
					mo.helpme = true
				end
				
				//THE MAP
				if btl.mapdisplay
					if mo.control.mo.P_inputs[BT_CUSTOM2] == 1 and not btl.showmap
						btl.showmap = true
						mo.saveact = mo.t_act
						mo.t_act = nil
						playSound(mo.battlen, sfx_select)
						if btl.rubyanalysis
							playSound(mo.battlen, sfx_kc65)
							btl.rubyactivate = 0
							btl.rubyanalysis = false
							for k,v in ipairs(mo.skills)
								if v == "ruby analysis" 
									table.remove(mo.skills, k)
									table.insert(mo.skills, "analysis")
								end
							end
						end
					elseif (mo.control.mo.P_inputs[BT_CUSTOM2] == 1 or mo.control.mo.P_inputs[BT_USE] == 1) and btl.showmap
						btl.showmap = false
						mo.t_act = mo.saveact
						if btl.rubyactivate > 0
							playSound(mo.battlen, sfx_kc65)
							btl.rubyactivate = 0
						end
					end
				end
				
				
				if btl.showmap
				
					//emerald label switching in said map and taking away control
					if mo.control.mo.P_inputs["left"] == 1 and emeraldselect > 1
						emeraldselect = emeraldselect - 1
						playSound(mo.battlen, sfx_hover)
					end
					if mo.control.mo.P_inputs["right"] == 1 and emeraldselect < 7
						emeraldselect = emeraldselect + 1
						playSound(mo.battlen, sfx_hover)
					end
					
					//THE RUBY OF PHANTOMS
					
					//activation
					if mo.control.mo.P_inputs[BT_CUSTOM1] == 1 and btl.rubyactivate == 0 and btl.rubycooldown == 0
						playSound(mo.battlen, sfx_s3k9f)
						btl.rubyactivate = 12
					end
					
					//deactivation
					if mo.control.mo.P_inputs[BT_CUSTOM1] == 1 and btl.rubyactivate > 0 and btl.rubyactivate < 9
						playSound(mo.battlen, sfx_kc65)
						btl.rubyactivate = 0
					end
					
					//go there
					if mo.control.mo.P_inputs[BT_JUMP] == 1 and btl.rubyactivate > 0
						if emeraldselect != mo.platform
							btl.battlestate = BS_ACTION
							BTL_setAttack(mo, "phantom warp")
							mo.targetplatform = emeraldselect
							rubydisplay = false
						else
							playSound(mo.battlen, sfx_not)
						end
					end
				end
				
				//ruby aura
				if btl.rubyactivate > 0 or btl.rubyanalysis
					summonAura(mo, SKINCOLOR_MAGENTA)
				end
				
				//everything else
				if btl.menudisplay
					//max platform limit. as much as you want to, prevent jumping off a platform
					if mo.platform == 1 or ((mo.platform - 1) == btl.lockplatform and btl.battlestate != BS_ACTION)
						btl.hideleft = true
					else
						btl.hideleft = false
					end
					if mo.platform == 7 or ((mo.platform + 1) == btl.lockplatform and btl.battlestate != BS_ACTION)
						btl.hideright = true
					else
						btl.hideright = false
					end	
					
					//inputs
					//left platform arrow
					if not btl.hideleft
						if mo.control.cmd.buttons & BT_CUSTOM1 and not (mo.attack and (mo.attack.name == "Analysis" or mo.attack.name == "Ruby Analysis"))
							if not btl.showmap
								if bluebar > 0
									bluebar = bluebar - 10
								end
							end
						else
							if bluebar < 180
								bluebar = bluebar + 10
							end
						end
					end
					//right platform arrow
					if not btl.hideright
						if mo.control.cmd.buttons & BT_CUSTOM3
							if not btl.showmap
								if yellowbar < 180
									yellowbar = yellowbar + 10
								end
							end
						else
							if yellowbar > 0
								yellowbar = yellowbar - 10
							end
						end
					end
					
					//the switching platforms part. remember, if bluebar becomes 0, the left arrow has been held. if yellow bar is 180, right arrow has been held
					if bluebar == 0 and mo.warptimer == 0
						mo.targetplatform = mo.platform - 1
						if not (mo.attack and mo.attack.name == "Platform warp") and btl.battlestate != BS_ACTION
							btl.battlestate = BS_ACTION
							BTL_setAttack(mo, "platform switch")
						else
							mo.position = 0
							mo.warptimer = 1
						end
					end
					if yellowbar == 180 and mo.warptimer == 0
						mo.targetplatform = mo.platform + 1
						if not (mo.attack and mo.attack.name == "Platform warp") and btl.battlestate != BS_ACTION
							btl.battlestate = BS_ACTION
							BTL_setAttack(mo, "platform switch")
						else
							mo.position = 0
							mo.warptimer = 1
						end
					end
				end
			end
		else
			btl.menudisplay = false
			btl.mapdisplay = false
			btl.showmap = false
		end
		
		//for the player icon display in the map
		if not mo.enemy
			for k,v in ipairs(mo.allies)
				v.hudposition = k
			end
		end
		
		//return menu availability if actor has not platformjumped
		if btl.turnorder[1] != mo
			if mo.platformjumped	
				btl.menudisplay = true
				mo.platformjumped = false
				//give back the platform warp skill too if you used it
				if mo.giveitback
					table.insert(mo.skills, "platform warp")
					mo.giveitback = false
				end
			end
			//and also remove the grey powered badnik locked effect if you have it
			if mo.helpme
				mo.locked = false
				mo.helpme = false
			end
		end
		
		//team jank and stuff
		if btl.battlestate != BS_START
		
			//remove an enemy if it isn't in our platform. for emeralds, remove it entirely
			if btl.battlestate != BS_ACTION
				if mo.enemy != "b_eggman"
					for k,v in ipairs(mo.enemies)
						if v.enemy != "b_eggman" and v.enemy != "platform shield"
							if not v.emeraldenemy
								if mo.platform != v.platform
									table.remove(mo.enemies, k)
								end
							else
								table.remove(mo.enemies, k)
							end
						end
					end
				end
			end
			
			//same for allies
			if btl.battlestate != BS_ACTION
				for k,v in ipairs(mo.allies)
					if v != mo and mo.platform != v.platform or v.enemy == "b_eggman"
						table.remove(mo.allies, k)
					end
					if mo.enemy == "b_eggman" --remove eggman's allies
						if v.enemy != "b_eggman"
							table.remove(mo.allies, k)
						end
					end
				end
			end
			
			//remove eggman from player enemies to prevent accidental targeting?
			/*if not mo.enemy and not cutscene
				for k,v in ipairs(mo.enemies)
					if v.enemy and v.enemy == "b_eggman"
						table.remove(mo.enemies, k)
					end
				end
			end*/
			
			/*if btl.battlestate == BS_ACTION and not btl.superman
				if mo.skin == "amy"
					btl.superman = mo
					cutscene = true
				end
				D_startEvent(mo.battlen, "ev_stage6_eggman_dies_a")
			end*/
			
		else  //battle start stuff
			
			//point camera to eggman all the time
			if btl.cam	
				local x = -3904*FRACUNIT
				local y = -576*FRACUNIT
				btl.cam.angle = R_PointToAngle2(btl.cam.x, btl.cam.y, x, y)
			end
			
			//teleport eggman to his mech instead of the default battle coordinates
			if mo.enemy == "b_eggman"
				P_TeleportMove(mo, -3904*FRACUNIT, -576*FRACUNIT, -1776*FRACUNIT)
				mo.angle = ANG1*90
				mo.barrier = true
				btl.eggdude = mo
				mo.platform = 0
				mo.cannoncharge = false -- hyper cannon charging boolean
				mo.cannontimer = 1050 -- hyper cannon timer, is 30 seconds
				mo.cannontarget = 0 -- hyper cannon's target platform
				mo.cannonprepare = false
				mo.cannoncooldown = 4 //don't throw out hyper cannon roundstart!!!! please!!!!!
			end
			
			//teleport player team to appropriate positions
			if not mo.enemy and mo == mo.allies_noupdate[1]
				P_TeleportMove(mo, -3712*FRACUNIT, 1200*FRACUNIT, -1920*FRACUNIT)
				for i = 1, #mo.allies_noupdate
					local ally = mo.allies_noupdate[i]
					ally.angle = ANG1*270
					local tgtx = mo.x + (i-1)*100*cos(ANG1*180)
					local tgty = mo.y + (i-1)*100*sin(ANG1*180)
					if mo != ally
						P_TeleportMove(ally, tgtx, tgty, -1920*FRACUNIT)
					end
					ally.startx = ally.x
					ally.starty = ally.y
					ally.startz = ally.z
					//TESTING HACK: we will die
					--ally.hp = 1
				end
			end
			
			//sort out emerald enemies
			if mo.enemy == "b_emerald"
				mo.emeraldenemy = true
				mo.flags = $|MF_NOGRAVITY
				for i = 1, #mo.allies_noupdate
					local ally = mo.allies_noupdate[i]
					if mo == ally
						mo.emeraldtype = i
						if mo.emeraldtype == 1
							P_TeleportMove(mo, -2784*FRACUNIT, -800*FRACUNIT, -1416*FRACUNIT)
						elseif mo.emeraldtype == 2
							P_TeleportMove(mo, -2432*FRACUNIT, -224*FRACUNIT, -1592*FRACUNIT)
						elseif mo.emeraldtype == 3
							P_TeleportMove(mo, -3104*FRACUNIT, -64*FRACUNIT, -1712*FRACUNIT)
						elseif mo.emeraldtype == 4
							P_TeleportMove(mo, -3887*FRACUNIT, 480*FRACUNIT, -1824*FRACUNIT)
						elseif mo.emeraldtype == 5
							P_TeleportMove(mo, -4704*FRACUNIT, -64*FRACUNIT, -1712*FRACUNIT)
						elseif mo.emeraldtype == 6
							P_TeleportMove(mo, -5376*FRACUNIT, -224*FRACUNIT, -1592*FRACUNIT)
						elseif mo.emeraldtype == 7
							P_TeleportMove(mo, -5024*FRACUNIT, -800*FRACUNIT, -1416*FRACUNIT)
						end
						mo.platform = mo.emeraldtype
						mo.emeraldx = mo.x
						mo.emeraldy = mo.y
						mo.emeraldz = mo.z
					end
				end
			end
			
			//opening eggman dialogue
			D_startEvent(mo.battlen, "ev_stage6_battlestart")
			--D_startEvent(mo.battlen, "ev_stage6_eggman_dies_k")
		end
	else //if battlestate == 0
		btl.eggdude = nil
		btl.menudisplay = false
		btl.mapdisplay = false
		btl.showmap = false
		btl.rubycooldown = 0
		btl.rubytimer = 0
		btl.rubyactivate = 0
		btl.hideleft = false
		btl.hideright = false
		btl.emeralds = {}
		btl.lockplatform = 0
		btl.locktimer = 0 
		btl.metalsonicfight = false
		btl.superman = nil
		btl.rubyanalysis = false
		if btl.eggdude and btl.eggdude.valid
			btl.eggdude.cannoncharge = false
		end
	end
end, MT_PFIGHTER)

//emerald link object thinkers
addHook("MobjThinker", function(mo)
	if not mo.emeraldlink return end
	if leveltime & 1
		mo.flags2 = $ & ~MF2_DONTDRAW
		local g = P_SpawnGhostMobj(mo)
		mo.flags2 = $|MF2_DONTDRAW
		g.frame = FF_FULLBRIGHT
		g.fuse = 2
	end
end, MT_DUMMY)

//hud stuff, mainly platform options and map                               i hate graphic design
hud.add(function(v)
	if gamemap != 12 return end
	local btl = server.P_BattleStatus[1]
	if not btl return end
	
	//the platform switch options
	if btl.menudisplay
		if leveltime%4 == 0
			if fadenum >= 1 and fadenum < 4
				bluefade = SKINCOLOR_SUPERSKY5
				rubyfade = 179
				fadenum = fadenum + 1
			elseif fadenum == 4
				bluefade = SKINCOLOR_SUPERSKY4
				rubyfade = 178
				fadenum = fadenum + 1
			elseif fadenum == 5
				bluefade = SKINCOLOR_SUPERSKY3
				rubyfade = 177
				fadenum = fadenum + 1
			elseif fadenum == 6
				bluefade = SKINCOLOR_SUPERSKY4
				rubyfade = 178
				fadenum = 1
			end
		end
		
		local bluecolor = v.getColormap(TC_DEFAULT, bluefade)
		local yellowcolor = v.getColormap(TC_DEFAULT, SKINCOLOR_YELLOW)
		
		//patches, bar1 is left arrow, bar2 is right
		local bar1 = v.cachePatch("H_6MENU1")
		local bar2 = v.cachePatch("H_6MENU2")
		
		if not btl.hideleft
			v.drawCropped(48*FRACUNIT, 0*FRACUNIT, FRACUNIT*3/5, FRACUNIT*3/5, bar1, V_SNAPTOTOP, yellowcolor, 0, 0, 180*FRACUNIT, 66*FRACUNIT)
			v.drawCropped(48*FRACUNIT, 0*FRACUNIT, FRACUNIT*3/5, FRACUNIT*3/5, bar1, V_SNAPTOTOP, bluecolor, 0, 0, bluebar*FRACUNIT, 66*FRACUNIT)
		end
		if not btl.hideright
			v.drawScaled(168*FRACUNIT, 0*FRACUNIT, FRACUNIT*3/5, bar2, V_SNAPTOTOP, bluecolor)
			v.drawCropped(168*FRACUNIT, 0*FRACUNIT, FRACUNIT*3/5, FRACUNIT*3/5, bar2, V_SNAPTOTOP, yellowcolor, 0, 0, yellowbar*FRACUNIT, 66*FRACUNIT)
		end
		
		//text stuffs
		if not btl.hideleft
			v.drawString(85, 10, "Jump to", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
			v.drawString(73, 25, "left platform", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
			v.drawString(87, 45, "CUSTOM 1", V_BLUEMAP|V_SNAPTOTOP, "thin")
		end
		if not btl.hideright
			v.drawString(242, 10, "Jump to", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin-right")
			v.drawString(254, 25, "right platform", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin-right")
			v.drawString(207, 45, "CUSTOM 3", V_BLUEMAP|V_SNAPTOTOP, "thin")
		end
	else
		yellowbar = 0
		bluebar = 180
		bluefade = SKINCOLOR_SUPERSKY5
	end
	
	if btl.mapdisplay
		local greencolor = v.getColormap(TC_DEFAULT, greenfade)
		local maptriangle = v.cachePatch("H_6MENU3")
		v.drawScaled(123*FRACUNIT, 0*FRACUNIT, FRACUNIT*3/5, maptriangle, V_SNAPTOTOP, greencolor)
		v.drawString(154, 15, "Map", V_YELLOWMAP|V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
		v.drawString(145, 45, "CUSTOM 2", V_BLUEMAP|V_SNAPTOTOP, "thin")
	end
	
	//THE MAP
	
	//scroll it down when opened
	if btl.showmap
	
		//faded background, can't get drawfill to be transparent so i have to put a black graphic in here :(
		local bruh = v.cachePatch("H_BRUH")
		v.drawScaled(0, 0, FRACUNIT*5, bruh, V_SNAPTOTOP|V_SNAPTOLEFT|V_40TRANS)
		
		//bring down le map!
		if mapy <= 120
			mapy = mapy + 18
		elseif mapy <= 140
			mapy = mapy + 13
		elseif mapy <= 150
			mapy = mapy + 10
		elseif mapy <= 160
			mapy = mapy + 7
		elseif mapy <= 165
			mapy = mapy + 5
		elseif mapy <= 170
			mapy = mapy + 3
		elseif mapy <= 175
			mapy = mapy + 2
		elseif mapy < 180
			mapy = mapy + 1
		end
	else
		if mapy > -50
			mapy = mapy - 20
		end
	end
	
	//THE PHANTOM RUBY FLASH AHHHH
	if btl.battlestate == BS_DOTURN
		local bruh2 = v.cachePatch("H_BRUH2")
		if btl.showmap
			if btl.rubyactivate > 1
				btl.rubyactivate = btl.rubyactivate - 1
			end
		else
			if btl.rubyactivate > 0
				btl.rubyactivate = btl.rubyactivate - 1
			end
		end
		if btl.rubyactivate > 10
			v.drawScaled(0, 0, FRACUNIT*5, bruh2, V_SNAPTOTOP|V_SNAPTOLEFT)
		elseif btl.rubyactivate > 8 and btl.rubyactivate <= 10
			v.drawScaled(0, 0, FRACUNIT*5, bruh2, V_SNAPTOTOP|V_SNAPTOLEFT|V_10TRANS)
		elseif btl.rubyactivate > 6 and btl.rubyactivate <= 8
			v.drawScaled(0, 0, FRACUNIT*5, bruh2, V_SNAPTOTOP|V_SNAPTOLEFT|V_20TRANS)
		elseif btl.rubyactivate > 4 and btl.rubyactivate <= 6
			v.drawScaled(0, 0, FRACUNIT*5, bruh2, V_SNAPTOTOP|V_SNAPTOLEFT|V_30TRANS)
		elseif btl.rubyactivate > 2 and btl.rubyactivate <= 4
			v.drawScaled(0, 0, FRACUNIT*5, bruh2, V_SNAPTOTOP|V_SNAPTOLEFT|V_40TRANS)
		elseif btl.rubyactivate > 0 and btl.rubyactivate <= 2
			v.drawScaled(0, 0, FRACUNIT*5, bruh2, V_SNAPTOTOP|V_SNAPTOLEFT|V_50TRANS)
		end
	end
	
	//display ruby when either hovering over analyze or map is displayed
	if btl.showmap or rubydisplay
		if rubyx <= -55
			rubyx = rubyx + 7
		elseif rubyx <= -35
			rubyx = rubyx + 5
		elseif rubyx <= -25
			rubyx = rubyx + 4
		elseif rubyx <= -15
			rubyx = rubyx + 3
		elseif rubyx < -5
			rubyx = rubyx + 1
		end
	elseif not btl.showmap and not rubydisplay
		if rubyx > -70
			rubyx = rubyx - 10
		end
	end
	
	//display the actual map
	local y = mapy
	//this looks stupid theres definitely a faster way to do this
	if leveltime%5 == 0 and leveltime%10 != 0
		color = 0
	end
	if leveltime%10 == 0
		color = 31
	end
	
	//display the player icons
	for m in mobjs.iterate() do
		if m and m.valid and m.type == MT_PFIGHTER
			if not m.enemy and m.allies and #m.allies
				local btl = server.P_BattleStatus[1]
				if btl.battlestate != BS_START
					local iconx
					local icony
					if m.platform == 0 --just in case
						iconx = 0
						icony = 0
					end
					if m.platform == 1
						iconx = 68 + (m.hudposition-1)*20
						icony = y - 110
					end
					if m.platform == 2
						iconx = 28 + (m.hudposition-1)*20
						icony = y - 70
					end
					if m.platform == 3
						iconx = 88 + (m.hudposition-1)*20
						icony = y - 20
					end
					if m.platform == 4
						iconx = 160 + (m.hudposition-1)*20
						icony = y + 30
					end
					if m.platform == 5
						iconx = 238 + (m.hudposition-1)*20
						icony = y - 20
					end
					if m.platform == 6
						iconx = 298 + (m.hudposition-1)*20
						icony = y - 70
					end
					if m.platform == 7
						iconx = 258 + (m.hudposition-1)*20
						icony = y - 110
					end
					v.draw(iconx - (#m.allies-1)*10, icony, v.getSprite2Patch(m.skin, SPR2_LIFE), V_SNAPTOTOP, v.getColormap(nil, m.color))
				end
			end
		end
	end
	
	//EMERALD 4
	if emeraldselect == 4
		v.drawFill(151, y - 14, 21, 21, color|V_SNAPTOTOP)
		v.drawStretched(220*FRACUNIT, y*FRACUNIT - 60*FRACUNIT, FRACUNIT/6, FRACUNIT/3, v.cachePatch("H_BOX_DB"), V_SNAPTOTOP|V_FLIP)
		if btl.rubyactivate == 0
			v.drawString(123, y - 50, "Total Neutralization", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "thin")
			v.drawString(123, y - 38, "Removes buffs, debuffs,", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
			v.drawString(123, y - 33, "and status ailments.", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
		else
			v.drawString(150, y - 50, "Warp", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "left")
			v.drawString(138, y - 38, "A to confirm", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
		end
	else
		v.drawFill(151, y - 14, 21, 21, 31|V_SNAPTOTOP)
	end
	v.drawScaled(155*FRACUNIT, y*FRACUNIT - 10*FRACUNIT, FRACUNIT*3/5, v.cachePatch("H_CEMG4"), V_SNAPTOTOP)
	
	//EMERALD 3
	if emeraldselect == 3
		v.drawFill(76, y - 64, 21, 21, color|V_SNAPTOTOP)
		v.drawStretched(210*FRACUNIT, y*FRACUNIT - 80*FRACUNIT, FRACUNIT/6, FRACUNIT/3, v.cachePatch("H_BOX_DB"), V_SNAPTOTOP|V_FLIP)
		if btl.rubyactivate == 0
			v.drawString(113, y - 70, "Status infliction", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "thin")
			v.drawString(113, y - 58, "Inflicts burn, poison,", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
			v.drawString(113, y - 53, "freeze, or dizzy", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
		else
			v.drawString(140, y - 70, "Warp", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "left")
			v.drawString(128, y - 58, "A to confirm", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
		end
	else
		v.drawFill(76, y - 64, 21, 21, 31|V_SNAPTOTOP)
	end
	v.drawScaled(80*FRACUNIT, y*FRACUNIT - 60*FRACUNIT, FRACUNIT*3/5, v.cachePatch("H_CEMG3"), V_SNAPTOTOP)
	
	//EMERALD 2
	if emeraldselect == 2
		v.drawFill(16, y - 114, 21, 21, color|V_SNAPTOTOP)
		v.drawStretched(150*FRACUNIT, y*FRACUNIT - 125*FRACUNIT, FRACUNIT/6, FRACUNIT/3, v.cachePatch("H_BOX_DB"), V_SNAPTOTOP|V_FLIP)
		if btl.rubyactivate == 0
			v.drawString(53, y - 115, "Hyper soul leech", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "thin")
			v.drawString(53, y - 103, "Drain 100 SP from enemies", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
			v.drawString(53, y - 98, "and lower magic by 1 stage", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
		else
			v.drawString(80, y - 115, "Warp", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "left")
			v.drawString(68, y - 103, "A to confirm", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
		end
	else
		v.drawFill(16, y - 114, 21, 21, 31|V_SNAPTOTOP)
	end
	v.drawScaled(20*FRACUNIT, y*FRACUNIT - 110*FRACUNIT, FRACUNIT*3/5, v.cachePatch("H_CEMG2"), V_SNAPTOTOP)
	
	//EMERALD 1
	if emeraldselect == 1
		v.drawFill(56, y - 154, 21, 21, color|V_SNAPTOTOP)
		v.drawStretched(190*FRACUNIT, y*FRACUNIT - 165*FRACUNIT, FRACUNIT/6, FRACUNIT/3, v.cachePatch("H_BOX_DB"), V_SNAPTOTOP|V_FLIP)
		if btl.rubyactivate == 0
			v.drawString(93, y - 155, "Emerald leech", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "thin")
			v.drawString(93, y - 143, "Drain full emerald gauge", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
			v.drawString(93, y - 138, "and gain hyper condition", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
		else
			v.drawString(120, y - 155, "Warp", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "left")
			v.drawString(108, y - 143, "A to confirm", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
		end
	else
		v.drawFill(56, y - 154, 21, 21, 31|V_SNAPTOTOP)
	end
	v.drawScaled(60*FRACUNIT, y*FRACUNIT - 150*FRACUNIT, FRACUNIT*3/5, v.cachePatch("H_CEMG1"), V_SNAPTOTOP)
	
	//EMERALD 5
	if emeraldselect == 5
		v.drawFill(226, y - 64, 21, 21, color|V_SNAPTOTOP)
		v.drawStretched(112*FRACUNIT, y*FRACUNIT - 80*FRACUNIT, FRACUNIT/6, FRACUNIT/3, v.cachePatch("H_BOX_DB"), V_SNAPTOTOP)
		if btl.rubyactivate == 0
			v.drawString(120, y - 70, "Zioverse", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "thin")
			v.drawString(120, y - 58, "Deploys a zioverse field", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
			v.drawString(120, y - 53, "to all enemies", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
		else
			v.drawString(147, y - 70, "Warp", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "left")
			v.drawString(135, y - 58, "A to confirm", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
		end
	else
		v.drawFill(226, y - 64, 21, 21, 31|V_SNAPTOTOP)
	end
	v.drawScaled(230*FRACUNIT, y*FRACUNIT - 60*FRACUNIT, FRACUNIT*3/5, v.cachePatch("H_CEMG5"), V_SNAPTOTOP)
	
	//EMERALD 6
	if emeraldselect == 6
		v.drawFill(286, y - 114, 21, 21, color|V_SNAPTOTOP)
		v.drawStretched(172*FRACUNIT, y*FRACUNIT - 125*FRACUNIT, FRACUNIT/6, FRACUNIT/3, v.cachePatch("H_BOX_DB"), V_SNAPTOTOP)
		if btl.rubyactivate == 0
			v.drawString(180, y - 115, "Warp shuffle", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "thin")
			v.drawString(180, y - 103, "Teleport one enemy to a", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
			v.drawString(180, y - 98, "random platform", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
		else
			v.drawString(207, y - 115, "Warp", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "left")
			v.drawString(195, y - 103, "A to confirm", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
		end
	else
		v.drawFill(286, y - 114, 21, 21, 31|V_SNAPTOTOP)
	end
	v.drawScaled(290*FRACUNIT, y*FRACUNIT - 110*FRACUNIT, FRACUNIT*3/5, v.cachePatch("H_CEMG6"), V_SNAPTOTOP)
	
	//EMERALD 7
	if emeraldselect == 7
		v.drawFill(246, y - 154, 21, 21, color|V_SNAPTOTOP)
		v.drawStretched(132*FRACUNIT, y*FRACUNIT - 165*FRACUNIT, FRACUNIT/6, FRACUNIT/3, v.cachePatch("H_BOX_DB"), V_SNAPTOTOP)
		if btl.rubyactivate == 0
			v.drawString(140, y - 155, "Platform lock", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "thin")
			v.drawString(140, y - 143, "Prevent platform entry or", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
			v.drawString(140, y - 138, "exit and buff nearby badniks", V_SNAPTOTOP|V_ALLOWLOWERCASE, "small")
		else
			v.drawString(167, y - 155, "Warp", V_SNAPTOTOP|V_ALLOWLOWERCASE|V_YELLOWMAP, "left")
			v.drawString(155, y - 143, "A to confirm", V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
		end
	else
		v.drawFill(246, y - 154, 21, 21, 31|V_SNAPTOTOP)
	end
	v.drawScaled(250*FRACUNIT, y*FRACUNIT - 150*FRACUNIT, FRACUNIT*3/5, v.cachePatch("H_CEMG7"), V_SNAPTOTOP)
	
	//za phantom ruby gimmick!!!
	local ruby = v.cachePatch("H_RUBY")
	if btl.showmap
		v.drawFill(rubyx, 33, 52, 29, 31|V_SNAPTOTOP|V_SNAPTOLEFT)
	else
		--v.drawFill(rubyx, 33, 28, 29, 31|V_SNAPTOTOP|V_SNAPTOLEFT)
		v.drawFill(rubyx, 33, 52, 29, 31|V_SNAPTOTOP|V_SNAPTOLEFT)
	end
	if btl.rubycooldown == 0
		if btl.showmap
			v.drawFill(rubyx, 35, 50, 25, rubyfade|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawString(rubyx + 30, 43, "C1", V_SNAPTOTOP|V_SNAPTOLEFT|V_YELLOWMAP, "left")
		else
			--v.drawFill(rubyx, 35, 26, 25, rubyfade|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawFill(rubyx, 35, 50, 25, rubyfade|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawString(rubyx + 30, 43, "C1", V_SNAPTOTOP|V_SNAPTOLEFT|V_YELLOWMAP, "left")
		end
	else
		if btl.showmap
			v.drawFill(rubyx, 35, 50, 25, 6|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawString(rubyx + 30, 43, "C1", V_SNAPTOTOP|V_SNAPTOLEFT|V_GRAYMAP, "left")
		else
			--v.drawFill(rubyx, 35, 26, 25, 6|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawFill(rubyx, 35, 50, 25, 6|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawString(rubyx + 30, 43, "C1", V_SNAPTOTOP|V_SNAPTOLEFT|V_GRAYMAP, "left")
		end
		v.drawString(rubyx + 6, 63, "Cooldown: " + btl.rubycooldown, V_SNAPTOTOP|V_SNAPTOLEFT|V_BLUEMAP, "thin")
	end
	v.draw(rubyx + 15, 50, ruby, V_SNAPTOTOP|V_SNAPTOLEFT)
	
	//hyper cannon timer display
	if btl.eggdude and btl.eggdude.valid and btl.eggdude.cannoncharge
		if btl.eggdude.cannontimer > 0
			local btl = server.P_BattleStatus[1]
			--btl.eggdude.cannontimer = btl.eggdude.cannontimer - 1
			if G_TicsToSeconds(btl.eggdude.cannontimer) > 9
				if G_TicsToCentiseconds(btl.eggdude.cannontimer) > 9
					v.drawString(160, 60, G_TicsToMinutes(btl.eggdude.cannontimer, true) + ":" + G_TicsToSeconds(btl.eggdude.cannontimer) + ":" + G_TicsToCentiseconds(btl.eggdude.cannontimer), V_REDMAP|V_SNAPTOTOP, "center")
				else
					v.drawString(160, 60, G_TicsToMinutes(btl.eggdude.cannontimer, true) + ":" + G_TicsToSeconds(btl.eggdude.cannontimer) + ":0" + G_TicsToCentiseconds(btl.eggdude.cannontimer), V_REDMAP|V_SNAPTOTOP, "center")
				end
			else
				if G_TicsToCentiseconds(btl.eggdude.cannontimer) > 9
					v.drawString(160, 60, G_TicsToMinutes(btl.eggdude.cannontimer, true) + ":0" + G_TicsToSeconds(btl.eggdude.cannontimer) + ":" + G_TicsToCentiseconds(btl.eggdude.cannontimer), V_REDMAP|V_SNAPTOTOP, "center")
				else
					v.drawString(160, 60, G_TicsToMinutes(btl.eggdude.cannontimer, true) + ":0" + G_TicsToSeconds(btl.eggdude.cannontimer) + ":0" + G_TicsToCentiseconds(btl.eggdude.cannontimer), V_REDMAP|V_SNAPTOTOP, "center")
				end
			end
		else
			if leveltime%2 == 0
				v.drawString(160, 60, G_TicsToMinutes(btl.eggdude.cannontimer, true) + ":0" + G_TicsToSeconds(btl.eggdude.cannontimer) + ":0" + G_TicsToCentiseconds(btl.eggdude.cannontimer), V_REDMAP|V_SNAPTOTOP, "center")
			end
		end
	end
	
	if btl.eggdude and btl.eggdude.valid and btl.eggdude.cannonprepare
		if leveltime%2 == 0
			v.drawString(160, 60, G_TicsToMinutes(btl.eggdude.cannontimer, true) + ":" + G_TicsToSeconds(btl.eggdude.cannontimer) + ":0" + G_TicsToCentiseconds(btl.eggdude.cannontimer), V_REDMAP|V_SNAPTOTOP, "center")
		end
	end
	
	//super sonic finisher cutscene: speed lines
	if speeding
		for i = 1, #linex
			if linex[i]
				v.drawFill(linex[i], liney[i], linelength[i], 1, 0|V_SNAPTORIGHT)
				linex[i] = linex[i] - linespeed[i]
				if linex[i] < -500
					table.remove(linex, i)
					table.remove(liney, i)
					table.remove(linelength, i)
					table.remove(linespeed, i)
				end
			end
		end
	end
	
	//super tails/amy finisher cutscene: speed lines but VERTICALLLLL
	if flying
		for i = 1, #liney
			if liney[i]
				v.drawFill(linex[i], liney[i], 1, linelength[i], 0|V_SNAPTORIGHT)
				liney[i] = liney[i] - linespeed[i]
				if liney[i] < -200
					table.remove(linex, i)
					table.remove(liney, i)
					table.remove(linelength, i)
					table.remove(linespeed, i)
				end
			end
		end
	end
	
	//amy finisher cutscene: okay speedline but vertical but the other way
	/*if falling
		for i = 1, #liney
			if liney[i]
				v.drawFill(linex[i], liney[i], 1, linelength[i], 0|V_SNAPTORIGHT)
				liney[i] = liney[i] + linespeed[i]
				if liney[i] > 400
					table.remove(linex, i)
					table.remove(liney, i)
					table.remove(linelength, i)
					table.remove(linespeed, i)
				end
			end
		end
	end*/
end)

//cutscene thinkers
addHook("ThinkFrame", function()
	//thinkers for super sonic cutscene to occur during dialogue too
	if gamemap != 12 return end
	local btl = server.P_BattleStatus[1]
	if btl.superman and btl.superman.valid
		local mo = btl.superman
		local cam = btl.cam
		
		//primarily for super sonic's movement
		if mo.superspeen
			mo.angle = R_PointToAngle2(mo.x, mo.y, btl.eggdude.x, btl.eggdude.y) + ANG1*270
			cam.angle = R_PointToAngle2(cam.x, cam.y, btl.eggdude.x, btl.eggdude.y)
			if leveltime%15 == 0 and mo.anglespeed < 30 and not speeding
				mo.anglespeed = $+2
				mo.anglespeed2 = $+2
			end
			mo.spinangle = $+mo.anglespeed
			mo.spinangle2 = $+mo.anglespeed2
			
			if not mo.speedup
				local spinx = btl.eggdude.x + 1000*cos(ANG1*mo.spinangle)
				local spiny = btl.eggdude.y + 1000*sin(ANG1*mo.spinangle)
				P_TeleportMove(mo, spinx, spiny, mo.z)
			else
				local spinx = btl.eggdude.x + 1000*cos(ANG1*mo.spinangle2)
				local spiny = btl.eggdude.y + 1000*sin(ANG1*mo.spinangle2)
				P_TeleportMove(mo, spinx, spiny, mo.z)
			end
			mo.angle = R_PointToAngle2(mo.x, mo.y, btl.eggdude.x, btl.eggdude.y) + ANG1*270
			
			local g = P_SpawnGhostMobj(mo)
			
			//make more ghost frames in between
			if not mo.speedup
				local spinx2 = btl.eggdude.x + 1000*cos(ANG1*(mo.spinangle-(mo.anglespeed/2)))
				local spiny2 = btl.eggdude.y + 1000*sin(ANG1*(mo.spinangle-(mo.anglespeed/2)))
				local g2 = P_SpawnGhostMobj(mo)
				P_TeleportMove(g2, spinx2, spiny2, mo.z)
			else
				local spinx2 = btl.eggdude.x + 1000*cos(ANG1*(mo.spinangle2-(mo.anglespeed2/2)))
				local spiny2 = btl.eggdude.y + 1000*sin(ANG1*(mo.spinangle2-(mo.anglespeed2/2)))
				local g2 = P_SpawnGhostMobj(mo)
				P_TeleportMove(g2, spinx2, spiny2, mo.z)
			end
			
			//make more ghost frames in between
			if not mo.speedup
				local spinx3 = btl.eggdude.x + 1000*cos(ANG1*(mo.spinangle-(mo.anglespeed/(3/2))))
				local spiny3 = btl.eggdude.y + 1000*sin(ANG1*(mo.spinangle-(mo.anglespeed/(3/2))))
				local g3 = P_SpawnGhostMobj(mo)
				P_TeleportMove(g3, spinx3, spiny3, mo.z)
			else
				local spinx3 = btl.eggdude.x + 1000*cos(ANG1*(mo.spinangle2-(mo.anglespeed2/(3/2))))
				local spiny3 = btl.eggdude.y + 1000*sin(ANG1*(mo.spinangle2-(mo.anglespeed2/(3/2))))
				local g3 = P_SpawnGhostMobj(mo)
				P_TeleportMove(g3, spinx3, spiny3, mo.z)
			end
			
			/*if mo.spinangle%365 == 0
				playSound(mo.battlen, sfx_mswing)
			end*/
			
			if mo.speedup
				mo.anglespeed2 = 22
			end
			
			//fire effects
			for i = 1, 2
				local x = btl.eggdude.x + P_RandomRange(2000, -2000)*FRACUNIT
				local y = btl.eggdude.y + P_RandomRange(2000, -2000)*FRACUNIT
				local z = btl.eggdude.z + P_RandomRange(700, -1200)*FRACUNIT
				local fire = P_SpawnMobj(x, y, z, MT_DUMMY)
				fire.sprite = SPR_FPRT
				fire.frame = $ & ~FF_TRANSMASK
				fire.frame = $|FF_FULLBRIGHT|TR_TRANS20
				fire.scale = mo.scale*6
				fire.momz = P_RandomRange(30, 70)*mo.scale
				fire.scalespeed = mo.scale/6
				fire.destscale = 1
				fire.tics = TICRATE
			end
			
			if leveltime%2 == 0
				local effect = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
				effect.tics = 1
				effect.sprite = SPR_FIRS
				effect.frame = S|FF_TRANS20
				effect.angle = mo.angle
				effect.scale = mo.scale*3/2
			end
			
			for i = 1,10
				local thok = P_SpawnMobj(btl.eggdude.x + P_RandomRange(-800, 800)*FRACUNIT, btl.eggdude.y + P_RandomRange(-800, 800)*FRACUNIT, btl.eggdude.z - 200*FRACUNIT, MT_DUMMY)
				thok.flags = MF_NOBLOCKMAP
				thok.color = SKINCOLOR_RED
				if leveltime%2 then thok.color = SKINCOLOR_ORANGE end
				thok.frame = A
				thok.tics = 70
				thok.scale = FRACUNIT/2
				thok.scalespeed = FRACUNIT/32
				thok.destscale = 1
				thok.momz = P_RandomRange(4, 10)*FRACUNIT
				thok.momx = P_RandomRange(-3, 3)*FRACUNIT
				thok.momy = P_RandomRange(-3, 3)*FRACUNIT
			end
		end
		
		//primarily for speed lines and camera
		if speeding
			local btl = server.P_BattleStatus[mo.battlen]
			local cam = btl.cam
			local cx = btl.eggdude.x + 1300*cos(ANG1*mo.spinangle)
			local cy = btl.eggdude.y + 1300*sin(ANG1*mo.spinangle)
			P_TeleportMove(cam, cx, cy, cam.z)
			cam.momz = (mo.z - cam.z)/20
			cam.aiming = 0
			if leveltime%3 == 0
				local x = P_RandomRange(300, 500)
				linex[#linex+1] = x
				local y = P_RandomRange(-100, 300)
				liney[#liney+1] = y
				local length = P_RandomRange(30, 50)
				linelength[#linelength+1] = length
				local speed = P_RandomRange(20, 40)
				linespeed[#linespeed+1] = speed
			end
		end
		
		//and now we have thinkers for super tails during dialogue
		if btl.eggdude.launch
			btl.eggdude.rollangle = $ + 40*ANG1
			btl.eggdude.state = S_PLAY_FLY_TIRED
		end
		
		if mo.goingup
			if not (leveltime%10)
				playSound(mo.battlen, sfx_putput)
			end
			if mo.z >= -1440*FRACUNIT
				mo.momz = 0
			end
			if mo.tails and mo.tails.valid
				P_TeleportMove(mo.tails, mo.x, mo.y, mo.z+4*FRACUNIT)
			end
		end
		
		//also for speed lines but also other stuff too
		if flying
			if btl.eggdude.z >= -1440*FRACUNIT and mo.damagetime
				btl.eggdude.momz = 0
			end
			if leveltime%2 == 0
				local x = P_RandomRange(-300, 300)
				linex[#linex+1] = x
				local y = P_RandomRange(400, 500)
				liney[#liney+1] = y
				local length = P_RandomRange(30, 50)
				linelength[#linelength+1] = length
				local speed = P_RandomRange(20, 40)
				linespeed[#linespeed+1] = speed
			end
		end
		
		//same as last one but reversed
		/*if falling
			if leveltime%2 == 0
				local x = P_RandomRange(-300, 300)
				linex[#linex+1] = x
				local y = P_RandomRange(-200, -300)
				liney[#liney+1] = y
				local length = P_RandomRange(30, 50)
				linelength[#linelength+1] = length
				local speed = P_RandomRange(20, 40)
				linespeed[#linespeed+1] = speed
			end
		end*/
		
		//for knuckles aura particles and environment effects
		if mo.demon
			for i = 1, 2
				local elec = P_SpawnMobj(mo.x + P_RandomRange(-15, 15)*FRACUNIT, mo.y + P_RandomRange(-15, 15)*FRACUNIT, (mo.z + mo.height/2) + P_RandomRange(-30, 30)*FRACUNIT, MT_DUMMY)
				elec.state = S_WATERZAP
				elec.frame = $|FF_FULLBRIGHT
				elec.scale = FRACUNIT*3/2
				elec.tics = 2
			end
			if btl.battlestate == BS_DOTURN
				mo.momx = 0
				mo.momy = 0
				mo.momz = 0
				if mo.avatar and mo.avatar.valid
					mo.avatar.momx = 0
					mo.avatar.momy = 0
					mo.avatar.momz = 0
				end
			end
			if leveltime%P_RandomRange(5, 15) == 0
				local l = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
				l.state = S_KSPK1
				l.tics = P_RandomRange(2, 10)
				l.flags = MF_NOCLIPHEIGHT|MF_NOCLIPTHING
				l.destscale = 1
				l.scale = FRACUNIT
				l.scalespeed = l.scale/24
				l.color = SKINCOLOR_YELLOW
			end
			summonAura(mo, mo.color)
			
			if mo.superfall
				mo.anim = nil
				mo.state = S_PLAY_FALL
				mo.avatar.state = S_PLAY_FALL
			end
			
			if mo.avatar and mo.avatar.valid
				local a = mo.avatar
				if not (leveltime%4)
					local elec = P_SpawnMobj(a.x, a.y, a.z + a.height/2, MT_DUMMY)
					elec.sprite = SPR_DELK
					elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
					elec.scale = FRACUNIT*5
					elec.destscale = FRACUNIT*20
					elec.scalespeed = FRACUNIT/4
					elec.tics = TICRATE/8
					elec.color = a.color
				end
				if leveltime%4 == 0
					local g = P_SpawnGhostMobj(a)
					g.color = a.color
					g.colorized = true
					g.scalespeed = FRACUNIT/6
					g.destscale = FRACUNIT*6
				end
			end
			
			if mo.sectorstuff and #mo.sectorstuff
				for i = 1, #mo.sectorstuff
					if mo.sectorstuff[i]
						local sector = mo.sectorstuff[i]
						local light = sector.lightlevel
						
						if mo.lightup
							if light < mo.lights[i]
								sector.lightlevel = sector.lightlevel + 2
							end
						end
					end
				end
			end
			
			//thunderstorm effects dependent on emerald power
			if btl.emeraldpow >= 200 and btl.emeraldpow < 300
				localquake(mo.battlen, 1*FRACUNIT, 1)
				//random time 1, random time 2, frequency, random anglespeed 1, random anglespeed 2
				mo.miststuff = {8, 16, 1, 2, 4}
			elseif btl.emeraldpow >= 300 and btl.emeraldpow < 400
				localquake(mo.battlen, 1*FRACUNIT, 1)
				mo.miststuff = {6, 12, 2, 3, 6}
			elseif btl.emeraldpow >= 400 and btl.emeraldpow < 500
				localquake(mo.battlen, 2*FRACUNIT, 1)
				mo.miststuff = {4, 10, 3, 4, 7}
			elseif btl.emeraldpow >= 500 and btl.emeraldpow < 600
				localquake(mo.battlen, 2*FRACUNIT, 1)
				mo.miststuff = {4, 8, 4, 5, 8}
			elseif btl.emeraldpow >= 600 and btl.emeraldpow < 700
				localquake(mo.battlen, 3*FRACUNIT, 1)
				mo.miststuff = {3, 6, 5, 6, 9}
			elseif btl.emeraldpow >= 700
				localquake(mo.battlen, 4*FRACUNIT, 1)
				mo.miststuff = {2, 4, 6, 7, 10}
			end
			
			if btl.emeraldpow >= 400
				if leveltime%P_RandomRange(80, 120) == 0
					local randx = mo.x + P_RandomRange(-300, 300)*FRACUNIT
					local randy = mo.y + P_RandomRange(-800, 50)*FRACUNIT
					local z1 = P_SpawnMobj(randx, randy, mo.z - 500*FRACUNIT, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, FRACUNIT*5, SKINCOLOR_TEAL
					z1.destscale = FRACUNIT*4    -- this probably looks retarded at smaller scales from afar lmao
					-- second, the dominant in front
					local z2 = P_SpawnMobj(randx, randy, mo.z - 200*FRACUNIT, MT_DUMMY)
					z2.state, z2.scale, z2.color = S_LZIO21, FRACUNIT*5, SKINCOLOR_GOLD
					z2.destscale = FRACUNIT*4
					playSound(mo.battlen, sfx_litng1)
					playSound(mo.battlen, sfx_litng2)
					playSound(mo.battlen, sfx_litng3)
					playSound(mo.battlen, sfx_litng4)
					P_StartQuake(50*FRACUNIT, 15)
				end
			end
			
			if btl.emeraldpow >= 200
				if leveltime%P_RandomRange(mo.miststuff[1], mo.miststuff[2]) == 0
					for i = 1, mo.miststuff[3]
						local ang = ANG1*P_RandomRange(1, 359)
						local tgtx = mo.x + P_RandomRange(100, 2000)*cos(mo.angle + ang)
						local tgty = mo.y + P_RandomRange(100, 2000)*sin(mo.angle + ang)
						local mist = P_SpawnMobj(tgtx, tgty, mo.z + P_RandomRange(-50, -150)*FRACUNIT, MT_DUMMY)
						mist.state = S_TNTDUST_1
						mist.spriteyscale = FRACUNIT*2
						mist.spritexscale = FRACUNIT*4
						mist.frame = $|TR_TRANS60
						mist.momx = P_RandomRange(10, -10)*FRACUNIT
						mist.momy = P_RandomRange(10, -10)*FRACUNIT
						mist.angspeed = P_RandomRange(mo.miststuff[4], mo.miststuff[5])
						mist.target = mo
						mist.rotate = ang
						mo.mistorbit[#mo.mistorbit+1] = mist
					end
				end
			end
			
			if mo.mistorbit and #mo.mistorbit
				for i = 1, #mo.mistorbit
					if mo.mistorbit[i] and mo.mistorbit[i].valid
						local s = mo.mistorbit[i]
						if s.target
							local dist = R_PointToDist2(s.x, s.y, mo.x, mo.y)/FRACUNIT
							local tgtx = mo.x + dist*cos(mo.angle + s.rotate)
							local tgty = mo.y + dist*sin(mo.angle + s.rotate)
							P_TeleportMove(s, tgtx, tgty, s.z)
						end
						s.rotate = $ + ANG1*s.angspeed
					end
				end
			end
		end
	end
end)

eventList["ev_stage6_hyper_cannon"] = {
	[1] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						evt.usecam = true
						S_StartSound(nil, sfx_s3k5a)
						for mo in mobjs.iterate() do
							if mo and mo.valid and mo.type == MT_PFIGHTER
								if not mo.enemy and mo.platform == btl.eggdude.cannontarget
									mo.deathtimer = 0
									mo.dying = false
								end
							end
						end
					end
					if evt.ftimer < 150
						for mt in mapthings.iterate do
							local m = mt.mobj
							if not m or not m.valid continue end
							if m and m.valid and m.type == MT_BOSS3WAYPOINT
							and mt.extrainfo == btl.eggdude.cannontarget
								local cam = btl.cam
								if evt.ftimer < 40
									local cx = m.x + 400*cos(btl.eggdude.angle)
									local cy = m.y + 400*sin(btl.eggdude.angle)
									CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, btl.eggdude.x, btl.eggdude.y))
									CAM_goto(cam, cx, cy, m.z + 150*FRACUNIT)
								else
									if evt.ftimer == 40
										S_StartSound(nil, sfx_s3k54)
										S_StartSound(m, sfx_beam)
									end
									local cx = m.x + 1000*cos(btl.eggdude.angle)
									local cy = m.y + 1000*sin(btl.eggdude.angle)
									CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, btl.eggdude.x, btl.eggdude.y))
									CAM_goto(cam, cx, cy, m.z + 200*FRACUNIT)
									
									//FIRE
									P_StartQuake(FRACUNIT*12, 1)
									for mo in mobjs.iterate() do
										if mo and mo.valid and mo.type == MT_PFIGHTER
											if mo.enemy and mo.enemy == "b_eggman"
												local en = mo.energypoint
												for i = 1,4
													local beam = P_SpawnMobj(en.x-P_RandomRange(200,-200)*FRACUNIT, en.y-P_RandomRange(60,-60)*FRACUNIT, en.z-P_RandomRange(100,-100)*FRACUNIT, MT_DUMMY)
													beam.scale = FRACUNIT*3/2
													beam.fuse = 30
													beam.state = S_MEGITHOK
													beam.angle = R_PointToAngle2(en.x, en.y, m.x, m.y)
													P_InstaThrust(beam, beam.angle, 150*FRACUNIT)
												end
												//remove warning thoks
												if mo.warning and #mo.warning
													for i = 1, #mo.warning
														if mo.warning[i] and mo.warning[i].valid
															P_RemoveMobj(mo.warning[i])
														end
													end
												end
											end
										end
									end
									//we die!!!
									for mo in mobjs.iterate() do
										if mo and mo.valid and mo.type == MT_PFIGHTER
											if not mo.enemy and mo.platform == btl.eggdude.cannontarget
												if mo.cannondamage != nil and mo.hp <= mo.cannondamage and not mo.dying
													--S_StartSound(nil, sfx_yikes) //lmao
													mo.dying = true
												elseif mo.cannondamage != nil and not mo.dying
													if evt.ftimer > 45
														damageObject(mo, mo.cannondamage)
													end
												end
												if mo.dying and mo.hp > 0
													P_InstaThrust(mo, mo.angle, -20*FRACUNIT)
													mo.momz = 30*FRACUNIT
													mo.deathtimer = $+1
													--mo.rollangle = $+ANG1*80
												end
												if mo.deathtimer >= 15 and mo.hp > 0
													damageObject(mo, mo.cannondamage*100)
												end
											end
										end
									end
								end	
							end
						end
					end
					if evt.ftimer >= 150
						btl.eggdude.cannoncharge = false
						for mt in mapthings.iterate do
							local m = mt.mobj
							if not m or not m.valid continue end
							if m and m.valid and m.type == MT_BOSS3WAYPOINT
							and mt.extrainfo == btl.eggdude.cannontarget
								S_StopSound(m)
							end
						end
						for mo in mobjs.iterate() do
							if mo and mo.valid and mo.type == MT_PFIGHTER
								if mo.enemy and mo.enemy == "b_eggman"
									//despawn energypoint when finished
									if mo.energypoint and mo.energypoint.valid
										local en = mo.energypoint
										en.destscale = FRACUNIT/50
										if evt.ftimer == 210
											P_RemoveMobj(en)
											mo.energypoint = nil
										end
									end
									for i = 1, 2
										local cx = mo.x + 50*cos(btl.eggdude.angle)
										local cy = mo.y + 50*sin(btl.eggdude.angle)
										local smoke = P_SpawnMobj(cx + P_RandomRange(-20, 20)*FRACUNIT, cy + P_RandomRange(-20, 20)*FRACUNIT, mo.z + P_RandomRange(0, 128)*FRACUNIT, MT_SMOKE)
										smoke.scale = FRACUNIT
										smoke.momz = P_RandomRange(3, 10)*FRACUNIT
									end
								end
							end
						end
					end
					if evt.ftimer == 200
						btl.eggdude.cannontimer = 1050
						btl.eggdude.cannontarget = 0
						BTL_deadEnemiescleanse(btl)
						btl.battlestate = BS_ENDTURN
						return true
					end
				end
			},
}

eventList["ev_stage6_battlestart"] = {
	[1] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						local x = -3904*FRACUNIT
						local y = -576*FRACUNIT
						boxflip = true
						evt.usecam = true
						local tgtx = x + 150*cos(ANG1*90)
						local tgty = y + 150*sin(ANG1*90)
						local cam = btl.cam
						cam.angle = ANG1*270
						CAM_goto(cam, tgtx, tgty, -1760*FRACUNIT)
						CAM_angle(cam, cam.angle)
						CAM_aiming(cam, cam.aiming)
					end
					if evt.ftimer == 30
						return true
					end
				end
			},
	[2] = {"text", "Eggman", "Behold, vermins! Take my genius combined with the unlimited power of the emeralds, and you have an unstoppable force!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[3] = {"text", "Eggman", "Not only that, but take a good look at this!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[4] = {"function", -- vegito 214S
				function(evt, btl)
					local x = -3904*FRACUNIT
					local y = -576*FRACUNIT
					local z = -1776*FRACUNIT
					//zoom out and show emeralds putting energy into mech
					if evt.ftimer == 1
						evt.emeraldball = {}
						evt.thokstuff = {}
						evt.usecam = true
						local tgtx = x + 1700*cos(ANG1*90)
						local tgty = y + 1700*sin(ANG1*90)
						local cam = btl.cam
						cam.angle = ANG1*270
						CAM_goto(cam, tgtx, tgty, -1700*FRACUNIT)
						CAM_angle(cam, cam.angle)
						CAM_aiming(cam, cam.aiming)
					end
					
					if evt.ftimer == 35
						S_StartSound(nil, sfx_s3ka8)
						for mo in mobjs.iterate() do
							if mo and mo.valid and mo.type == MT_PFIGHTER
								if mo.enemy == "b_emerald"
									local tgtx = x + 100*cos(ANG1*90)
									local tgty = y + 100*sin(ANG1*90)
									local thok = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
									thok.color = SKINCOLOR_WHITE
									thok.momx = (tgtx - thok.x)/50
									thok.momy = (tgty - thok.y)/50
									thok.momz = (z - thok.z)/50
									thok.scale = FRACUNIT
									thok.frame = A|FF_FULLBRIGHT
									thok.tics = -1
									thok.emeraldnum = mo.emeraldtyoe
									evt.emeraldball[#evt.emeraldball+1] = thok
									local poof = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
									poof.state = S_INVISIBLE
									poof.tics = 1
									poof.scale = FRACUNIT/2
									A_OldRingExplode(poof, MT_SUPERSPARK)
								end
							end
						end
					end
					
					//somebody help me
					if evt.emeraldball and #evt.emeraldball
						for i = 1, #evt.emeraldball
							if evt.emeraldball[i] and evt.emeraldball[i].valid
								local ball = evt.emeraldball[i]
								P_SpawnGhostMobj(ball)
								local tgtx = x + 100*cos(ANG1*90)
								local tgty = y + 100*sin(ANG1*90)
								if R_PointToDist2(ball.x, ball.y, tgtx, tgty) < 5*FRACUNIT
									P_RemoveMobj(ball)
								end
								
								//spawn tiny link bols
								if (evt.ftimer-35)%4 == 0
									local thok = P_SpawnMobj(ball.x, ball.y, ball.z, MT_DUMMY)
									thok.color = SKINCOLOR_WHITE
									thok.scale = FRACUNIT/3
									thok.frame = FF_FULLBRIGHT
									thok.tics = -1
									thok.emeraldnum = ball.emeraldnum
									thok.emeraldlink = true
								end
							end
						end
					end
					
					if evt.ftimer >= 70 and evt.ftimer < 150
						local emeraldcolors = {SKINCOLOR_GREEN, SKINCOLOR_PURPLE, SKINCOLOR_BLUE, SKINCOLOR_CYAN, SKINCOLOR_ORANGE, SKINCOLOR_RED, SKINCOLOR_GREY}
						for mo in mobjs.iterate() do
							if mo and mo.valid and mo.type == MT_PFIGHTER
								if mo.enemy == "b_emerald"
									for i = 1,2
										local thok = P_SpawnMobj(mo.x, mo.y, mo.z+mo.height/2, MT_SUPERSPARK)
										thok.color = emeraldcolors[P_RandomRange(1, #emeraldcolors)]
										thok.momx = P_RandomRange(-5, 5)*FRACUNIT
										thok.momy = P_RandomRange(-5, 5)*FRACUNIT
										thok.momz = P_RandomRange(-5, 5)*FRACUNIT
										thok.scale = FRACUNIT/8
										thok.destscale = FRACUNIT/5
										thok.frame = A|FF_FULLBRIGHT
									end
								end
							end
						end
					end
					if evt.ftimer == 90
						S_StartSound(nil, sfx_debuff)
					end
					if evt.ftimer >= 90 and evt.ftimer < 150
						P_StartQuake(2*FRACUNIT, 1)
						for mo in mobjs.iterate() do
							if mo and mo.valid and mo.type == MT_PFIGHTER
								if mo.enemy == "b_emerald"
									--local emeraldcolors = {SKINCOLOR_EMERALD, SKINCOLOR_PURPLE, SKINCOLOR_BLUE, SKINCOLOR_CYAN, SKINCOLOR_ORANGE, SKINCOLOR_RED, SKINCOLOR_GREY}
									if leveltime%6 == 0
										local g = P_SpawnGhostMobj(mo)
										g.colorized = true
										g.destscale = FRACUNIT*4
										g.frame = $|FF_FULLBRIGHT
									end
									if leveltime%2 == 0
										local h_angle = P_RandomRange(1, 359)*ANG1
										local v_angle = P_RandomRange(1, 359)*ANG1
										local dist = P_RandomRange(0, 50)
										local spd = P_RandomRange(40, 50)

										local s_x = mo.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
										local s_y = mo.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
										local s_z = mo.z + dist* sin(v_angle)

										local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

										s.frame = A|FF_TRANS60
										s.color = SKINCOLOR_CYAN --emeraldcolors[P_RandomRange(1, #emeraldcolors)]
										s.scale = FRACUNIT/2
										s.tics = 20
										local tgtx = x + 100*cos(ANG1*90)
										local tgty = y + 100*sin(ANG1*90)
										s.momx = (tgtx - s.x)/20
										s.momy = (tgty - s.y)/20
										s.momz = (z - s.z)/20
										evt.thokstuff[#evt.thokstuff+1] = s
									end
								end
							end
						end
					end
					//damn all this for just some afterimages
					if evt.thokstuff and #evt.thokstuff
						for i = 1, #evt.thokstuff
							if evt.thokstuff[i] and evt.thokstuff[i].valid
								local t = evt.thokstuff[i]
								P_SpawnGhostMobj(t)
							end
						end
					end
					if evt.ftimer == 180
						//colormap flash
						P_LinedefExecute(1002)
						for s in sectors.iterate
							if s.tag == 53 or s.tag == 54
								for i = 0, 2 --why is it like this im crying
									if s.lines[i].tag == 16
										s.ceilingheight = -1392*FRACUNIT
										s.floorheight = -1980*FRACUNIT
									end
								end
							end
						end
						S_StartSound(nil, sfx_s3k9f)
					end
					if evt.ftimer == 230
						return true
					end
				end
			},
	[5] = {"text", "Eggman", "Not just an unstoppable force, but an immovable object!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[6] = {"text", "Eggman", "It's a shame that I have to play all my cards in this plan, but with this, there's no chance for you!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[7] = {"text", "Eggman", "Just try to penetrate this master plan! Muwahahahahahahahahaha!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[8] = {"function", -- here com badnik
				function(evt, btl)
					if evt.ftimer == 1
						evt.usecam = true
						for mo in mobjs.iterate() do
							if mo and mo.valid and mo.type == MT_PFIGHTER
								if mo.enemy == "b_emerald"
									if mo.emeraldtype == 4
										local tgtx = mo.x + 500*cos(ANG1*90)
										local tgty = mo.y + 500*sin(ANG1*90)
										local cam = btl.cam
										cam.angle = ANG1*270
										CAM_goto(cam, tgtx, tgty, mo.z)
										CAM_angle(cam, cam.angle)
										CAM_aiming(cam, cam.aiming)
										--emeralds[#emeralds+1] = mo --kill
									end
									btl.emeralds[#btl.emeralds+1] = mo
								end
							end
						end
						//testing hack
						/*for mo in mobjs.iterate() do
							if mo and mo.valid and mo.type == MT_PFIGHTER
								if mo.enemy == "b_emerald"
									btl.emeralds[#btl.emeralds+1] = mo
								end
								local stats = {"strength", "magic", "endurance", "agility", "luck"}
								for i = 1, #stats do
									mo[stats[i]] = 1000
								end
								btl.emeraldpow = 700
							end
						end*/
					end
					for i = 1, 7
						local num = i
						if evt.ftimer == 35+(num*5)
							for mo in mobjs.iterate() do
								if mo and mo.valid and mo.type == MT_PFIGHTER
									if mo.emeraldenemy
										if mo.emeraldtype == num
											for i = 1, 1 --3
												local tgtx = (mo.x + 200*cos(ANG1*90)) + (((mo.x+75*i)*cos(ANG1*180)) - 150*cos(ANG1*180))
												local tgty = (mo.y + 200*sin(ANG1*90)) + (((mo.y+75*i)*sin(ANG1*180)) - 150*sin(ANG1*180))
												local e = BTL_spawnEnemy(btl.eggdude, enemies[P_RandomRange(1, #enemies)], true, tgtx, tgty, mo.floorz)
												P_TeleportMove(e, tgtx, tgty, e.z)
												e.angle = ANG1*90
												e.floatz = e.z
												e.platform = mo.emeraldtype
												e.hp = $+100
												e.maxhp = $+100
												e.flags = $ & ~MF_NOGRAVITY
												local stats = {"strength", "magic", "endurance", "agility", "luck"}
												for j = 1, #stats do
													e[stats[j]] = $-10
												end
												for i = 1, 64
													local color = SKINCOLOR_RED
													if i%2 color = SKINCOLOR_BLACK end

													local x, y, z = e.x+P_RandomRange(-50, 50)*FRACUNIT, e.y+P_RandomRange(-50, 50)*FRACUNIT, e.z+P_RandomRange(-50, 50)*FRACUNIT
													local particle = P_SpawnMobj(x, y, z, MT_DUMMY)
													particle.color = color
													particle.frame = A
													particle.tics = 100
													particle.destscale = 0
													particle.momz = P_RandomRange(1, 10)*FRACUNIT
												end
											end
										end
									end
								end
							end
						end
					end
					if evt.ftimer >= 90
						for mo in mobjs.iterate() do
							if mo and mo.valid and mo.type == MT_PFIGHTER
								if mo.emeraldenemy
									if mo.emeraldtype == 4
										local tgtx = mo.x + 900*cos(ANG1*90)
										local tgty = mo.y + 900*sin(ANG1*90)
										local cam = btl.cam
										CAM_goto(cam, tgtx, tgty, mo.z+75*FRACUNIT)
									end
								end
							end
						end
						for mo in mobjs.iterate() do
							if mo and mo.valid and mo.type == MT_PFIGHTER
								if mo.enemy and mo.enemy != "b_eggman"
									if mo.emeraldenemy
										if mo.emeraldtype == 1
											summonAura(mo, SKINCOLOR_EMERALD)
										elseif mo.emeraldtype == 2
											summonAura(mo, SKINCOLOR_MAGENTA)
										elseif mo.emeraldtype == 3
											summonAura(mo, SKINCOLOR_BLUE)
										elseif mo.emeraldtype == 4
											summonAura(mo, SKINCOLOR_CYAN)
										elseif mo.emeraldtype == 5
											summonAura(mo, SKINCOLOR_ORANGE)
										elseif mo.emeraldtype == 6
											summonAura(mo, SKINCOLOR_RED)
										elseif mo.emeraldtype == 7
											summonAura(mo, SKINCOLOR_GREY)
										end
										if evt.ftimer == 120
											local emeraldcolors = {SKINCOLOR_MINT, SKINCOLOR_EMERALD, SKINCOLOR_FOREST}
											for i = 1,5
												local energy = P_SpawnMobj(mo.x-P_RandomRange(100,-100)*FRACUNIT, mo.y-P_RandomRange(100,-100)*FRACUNIT, mo.z+P_RandomRange(75,-75)*FRACUNIT, MT_DUMMY)
												energy.sprite = SPR_THOK
												energy.frame = FF_FULLBRIGHT
												energy.color = emeraldcolors[P_RandomRange(1, #emeraldcolors)]
												energy.scale = FRACUNIT/P_RandomRange(3, 6)
												energy.tics = 20
												energy.momx = (mo.x - energy.x)/20
												energy.momy = (mo.y - energy.y)/20
												energy.momz = ((mo.z+10*FRACUNIT) - energy.z)/20
											end
										end
									else
										if evt.ftimer == 140
											mo.flags = $|MF_NOGRAVITY
											mo.emeraldmode = mo.platform
											local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
											thok.state = S_INVISIBLE
											thok.tics = 1
											thok.scale = FRACUNIT*2
											A_OldRingExplode(thok, MT_SUPERSPARK)
										end
									end
								end
							end
						end
						if evt.ftimer == 90
							S_StartSound(nil, sfx_pcan)
						end
						if evt.ftimer == 120
							S_StartSound(nil, sfx_bufu1)
						end
						if evt.ftimer == 140
							S_StartSound(nil, sfx_hamas2)
							S_StartSound(nil, sfx_bufu6)
						end
					end
					if evt.ftimer == 190
						//testing hack: immediately give all emerald skills 
						/*for k,v in ipairs(btl.fighters)
							if not v.enemy
								table.insert(v.skills, "analysis")
								btl.emeraldpow = 700
								local emeraldskills = {"emerald leech2", "hyper soul leech", "status infliction", "total neutralization", "zioverse", "platform warp", "platform lock"}
								for i = 1, #emeraldskills
									table.insert(v.skills, emeraldskills[i])
									//if 5th is retrieved you get TWO skills omg
									if i == 5
										table.insert(v.skills, "garuverse")
									end
								end
							end
						end*/
						for k,v in ipairs(btl.fighters)
							if not v.enemy
								table.insert(v.skills, "analysis")
							end
						end
						for mo in mobjs.iterate() do
							if mo and mo.valid and mo.type == MT_PFIGHTER
								if not mo.enemy
									for k,v in ipairs(btl.fighters)
										if v.enemy and mo.platform == v.platform
											mo.enemies[#mo.enemies+1] = v
											if v.platform != 4
												v.enemies[#v.enemies+1] = mo
											end
										end
									end
								else -- give the enemies their allies
									for k,v in ipairs(btl.fighters)
										//add allies
										if v.enemy and mo.platform == v.platform and v != mo
											mo.allies[#mo.allies+1] = v
										end
									end
								end
							end
						end
						
						for k,v in ipairs(btl.turnorder)
							if v.enemy and v.enemy == "b_eggman"
								for i = 1, 2
									table.remove(btl.turnorder, k)
								end
							end
						end
						
						return true
					end
				end
			},
}

eventList["ev_stage6_badnik_emeraldmode"] = {	
	[1] = {"function",
			function(evt, btl) 
				for k,v in ipairs(btl.fighters)
					if v.modeswitch
						if evt.ftimer == 1
							local thecolor = SKINCOLOR_GREEN
							local randomemerald = btl.emeralds[P_RandomRange(1, #btl.emeralds)]
							v.emeraldmode = randomemerald.platform
							local e = v.emeraldmode
							if e == 1
								thecolor = SKINCOLOR_EMERALD
							elseif e == 2
								thecolor = SKINCOLOR_MAGENTA
							elseif e == 3
								thecolor = SKINCOLOR_BLUE
							elseif e == 4
								thecolor = SKINCOLOR_CYAN
							elseif e == 5
								thecolor = SKINCOLOR_YELLOW
							elseif e == 6
								thecolor = SKINCOLOR_RED
							elseif e == 7
								thecolor = SKINCOLOR_SILVER
							end
							local g = P_SpawnGhostMobj(v)
							g.color = thecolor
							g.colorized = true
							g.destscale = FRACUNIT*6
							g.frame = $|FF_FULLBRIGHT
							S_StartSound(nil, sfx_kc3d)
						end
						if evt.ftimer == 20
							v.modeswitch = false
							return true
						end
					end
				end
			end
		},
}

eventList["ev_stage6_eggman_dies"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"text", "Eggman", "Man.", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[2] = {"function",
			function(evt, btl) 
				if evt.ftimer == 1
					for k,v in ipairs(btl.fighters)
						local boom = P_SpawnMobj(v.x, v.y, v.z+20*FRACUNIT, MT_BOSSEXPLODE)
						boom.scale = FRACUNIT*4
						boom.state = S_PFIRE1
						S_StartSound(nil, sfx_fire2)
						S_StartSound(nil, sfx_fire1)
						damageObject(v, 6969)

						P_StartQuake(FRACUNIT*40, 10)

						for i = 1, 8
							local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
							smoke.scale = FRACUNIT*6
							smoke.momx = P_RandomRange(-5, 5)*FRACUNIT
							smoke.momy = P_RandomRange(-5, 5)*FRACUNIT
							smoke.momz = P_RandomRange(3, 6)*FRACUNIT
						end

						local sm = P_SpawnMobj(v.x, v.y, v.z, MT_SMOLDERING)
						sm.fuse = TICRATE/2
						sm.scale = v.scale*3/2
					end
				end
				if evt.ftimer == 10
					G_ExitLevel(1, 1)
					return true
				end
			end
		},
}

//super sonic finisher cutscene
eventList["ev_stage6_eggman_dies_s"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"function",
			function(evt, btl) 
				boxflip = true
				return true
			end
		},
	[2] = {"text", "Eggman", "!!!", nil, nil, nil, {"H_EGG2", SKINCOLOR_RED}},
	[3] = {"function",
			function(evt, btl) 
				if evt.ftimer == 1
					local x = -3904*FRACUNIT
					local y = -576*FRACUNIT
					local z = -1776*FRACUNIT
					//zoom back out
					if evt.ftimer == 1
						local tgtx = x + 700*cos(ANG1*90)
						local tgty = y + 700*sin(ANG1*90)
						local cam = btl.cam
						cam.angle = ANG1*270
						CAM_goto(cam, tgtx, tgty, -1700*FRACUNIT)
						CAM_angle(cam, cam.angle)
						CAM_aiming(cam, cam.aiming)
					end
				end
				if evt.ftimer == 35
					P_LinedefExecute(1002)
					for s in sectors.iterate
						if s.tag == 53 or s.tag == 54
							for i = 0, 2 --why is it like this im crying
								if s.lines[i].tag == 16
									s.ceilingheight = -6000*FRACUNIT
									s.floorheight = -6000*FRACUNIT
								end
							end
						end
					end
					S_StartSound(nil, sfx_kc65)
					S_StartSound(nil, sfx_status)
					local platformtags = {31, 30, 29, 28, 8, 9, 10}
					for s in sectors.iterate
						if s.tag == 53 or s.tag == 54 or s.tag == 41 or s.tag == 42
							for i = 0, 2 --why is it like this im crying
								if s.lines[i].tag != 16
									s.ceilingheight = 0
									s.floorheight = 0
								end
							end
						end
						if s.tag == platformtags[btl.lockplatform]
							for i = 0, 3
								s.lines[i].frontside.midtexture = 0
								s.lines[i].backside.midtexture = 0
							end
						end
					end
					//remove eggman hyper cannon if it exists
					if btl.eggdude.energypoint and btl.eggdude.energypoint.valid
						P_RemoveMobj(btl.eggdude.energypoint)
					end
					btl.eggdude.cannoncharge = false
					btl.eggdude.cannonprepare = false
					//remove emerald link objects
					for m in mobjs.iterate() do
						if m and m.valid and m.type == MT_DUMMY
							if m.emeraldlink
								P_RemoveMobj(m)
							end
						end
					end
					//remove warning thoks
					if btl.eggdude.warning and #btl.eggdude.warning
						for i = 1, #btl.eggdude.warning
							if btl.eggdude.warning[i] and btl.eggdude.warning[i].valid
								P_RemoveMobj(btl.eggdude.warning[i])
							end
						end
					end
				end
				if evt.ftimer == 70
					return true
				end
			end
		},
	[4] = {"function",
			function(evt, btl) 
				boxflip = false
				return true
			end
		},
	[5] = {"text", "Sonic", "Would ya look at that! There goes your immovable object, Eggman! Run outta backup plans?", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[6] = {"text", "Sonic", "'Cause if so, then it's finally showtime!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[7] = {"function", //super transformation (basically taken from the base code super transformation but a little different)
			function(evt, btl)
				local mo = btl.superman
				//im too stupid to deal with ticrate in lats anims so im just gonna
				if evt.ftimer >= TICRATE*2/3 + 10
					mo.momz = $*90/100
				elseif evt.ftimer >= 1
					mo.momz = FRACUNIT
					mo.flags = $|MF_NOGRAVITY	-- lol
				end

				if evt.ftimer == 1

					local cx = mo.x + 256*cos(mo.angle/* + ANG1*20*/)
					local cy = mo.y + 256*sin(mo.angle/* + ANG1*20*/)
					CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, mo.z + FRACUNIT*30, 70*FRACUNIT)
					CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, mo.x, mo.y))

					mo.anim = nil	-- kind of a hack
					mo.state = S_PLAY_FALL
				end

				-- spawn the emeralds:
				if evt.ftimer == TICRATE/2 + 10
					mo.emeralds = {}
					mo.em_rotspeed = 1
					mo.em_ang = 0
					mo.em_dist = 1024

					for i = 1, 7
						mo.emeralds[i] = P_SpawnMobj(0, 0, 0, MT_EMERALD1+(i-1))
						mo.emeralds[i].scale = $*3/2
					end
				end

				if evt.ftimer >= TICRATE/2 + 10
				and mo.emeralds and mo.emeralds[1] and mo.emeralds[1].valid


					local ang = mo.em_ang
					for i = 1, 7
						local x = mo.x + mo.em_dist*cos(ang)
						local y = mo.y + mo.em_dist*sin(ang)
						local z = mo.z + 32*cos(leveltime*ANG1*2 + (360/7)*ANG1*i)	-- funny z axis variation

						P_TeleportMove(mo.emeralds[i], x, y, z)
						ang = $ + (360/7)*ANG1
					end

					mo.em_ang = $+ mo.em_rotspeed*ANG1
					mo.em_rotspeed = min(32, $+1)
					mo.em_dist = max(64, $-24)
				end

				if evt.ftimer == TICRATE*2 + 10
					for i = 1, 7 do
						P_RemoveMobj(mo.emeralds[i])
					end
					mo.emeralds = nil

					mo.state = S_PLAY_SUPER_TRANS1
					for k,v in ipairs(mo.allies)
						if v and v.control and v.control.valid
							P_FlashPal(v.control, 1, 8)
						end
					end
					S_StartSound(mo, sfx_s3k9f)
					mo.status_condition = COND_SUPER	-- direct affectation
					S_ChangeMusic("stg6d")
					//testing hack(?): kill the glass in the way during the cutscene
					for i = 1, 7
						P_LinedefExecute(100 + i) --kill
					end
				end

				if evt.ftimer >= TICRATE*2 + 10
					if mo.state == S_PLAY_SUPER_TRANS6
						mo.tics = -1
					end
					if evt.ftimer < (TICRATE*3 + TICRATE/2)
						summonAura(mo, SKINCOLOR_SUPERGOLD3)
					end
				end

				if evt.ftimer == TICRATE*3 + TICRATE/2 + 10
					mo.momz = -4*FRACUNIT
					mo.frame = A
					mo.sprite = SPR_WHY1 //I HAVE TO DO THIS BECAUSE CHANGING STATE WON'T CALL THE SUPER SONIC VERSIONAGF#YUEF@&##YGF
				end
				if evt.ftimer == (TICRATE*3 + TICRATE/2) + 20
					playSound(mo.battlen, sfx_s3k81)
					mo.momz = 50*FRACUNIT
					mo.frame = A
					mo.sprite = SPR_WHY2
				end
				if evt.ftimer >= (TICRATE*3 + TICRATE/2) + 20
					P_SpawnGhostMobj(mo)
				end
				if evt.ftimer >= (TICRATE*3 + TICRATE/2) + 40
					return true
				end
			end
		},
	[8] = {"function", //and now we descend
			function(evt, btl)
				local mo = btl.superman
				local cam = btl.cam
				local tgtx = btl.eggdude.x + 1000*cos(ANG1*35)
				local tgty = btl.eggdude.y + 1000*sin(ANG1*35)
				local cx = btl.eggdude.x + 1400*cos(ANG1*35)
				local cy = btl.eggdude.y + 1400*sin(ANG1*35)
				if evt.ftimer == 1 //teleport the platforms and players out of the way too
					mo.spinangle = 35
					mo.anglespeed = 10
					mo.spinangle2 = 35
					mo.anglespeed2 = 10
					for s in sectors.iterate
						if s.tag == 32
							s.floorheight = -6000*FRACUNIT
							s.ceilingheight = -6000*FRACUNIT
						end
					end
					for k,v in ipairs(btl.fighters)
						if v.enemy != "b_eggman" and v != mo
							P_TeleportMove(v, -8130*FRACUNIT, 1730*FRACUNIT, -1900*FRACUNIT)
						end
					end
					P_TeleportMove(cam, cx, cy, btl.eggdude.z)
					P_TeleportMove(mo, tgtx, tgty, btl.eggdude.z + 200*FRACUNIT)
					CAM_stop(cam)
					mo.sprite = SPR_WHY3
				end
				if evt.ftimer >= 1
					mo.momz = (btl.eggdude.z - mo.z)/10
					mo.angle = R_PointToAngle2(mo.x, mo.y, btl.eggdude.x, btl.eggdude.y) + ANG1*270
					cam.angle = R_PointToAngle2(cam.x, cam.y, btl.eggdude.x, btl.eggdude.y)
				end
				//effects
				if evt.ftimer < 85
					summonAura(mo, SKINCOLOR_SUPERGOLD3)
				end
				if evt.ftimer == 25
					mo.sprite = SPR_WHY4
				end
				if evt.ftimer == 50
					localquake(mo.battlen, 2*FRACUNIT, 2)
					P_InstaThrust(mo, mo.angle + ANG1*180, FRACUNIT) 
					mo.sprite = SPR_WHY5
					playSound(mo.battlen, sfx_spndsh)
					local g = P_SpawnGhostMobj(mo)
					g.color = mo.color
					g.colorized = true
					g.destscale = FRACUNIT*4
				end
				if evt.ftimer == 60
					localquake(mo.battlen, 2*FRACUNIT, 2)
					playSound(mo.battlen, sfx_spndsh)
					local g = P_SpawnGhostMobj(mo)
					g.color = mo.color
					g.colorized = true
					g.destscale = FRACUNIT*4
				end
				if evt.ftimer == 70 or evt.ftimer == 75 or evt.ftimer == 80
					localquake(mo.battlen, 2*FRACUNIT, 2)
					playSound(mo.battlen, sfx_spndsh)
					local g = P_SpawnGhostMobj(mo)
					g.color = mo.color
					g.colorized = true
					g.destscale = FRACUNIT*5
					g.scalespeed = FRACUNIT/4
				end
				if evt.ftimer == 85
					btl.eggdude.state = S_PLAY_FLY_TIRED
					localquake(mo.battlen, 10*FRACUNIT, 5)
					playSound(mo.battlen, sfx_s3k81)
					playSound(mo.battlen, sfx_boost1) //louds
					playSound(mo.battlen, sfx_boost1)
					mo.sprite = SPR_WHY6
					mo.momx = 0
					mo.momy = 0
					mo.superspeen = true
					for k,v in ipairs(mo.allies)
						if v and v.control and v.control.valid
							P_FlashPal(v.control, 4, 4)
						end
					end
				end
				if evt.ftimer == 100
				or evt.ftimer == 130
				or evt.ftimer == 150
				or evt.ftimer == 165
				or evt.ftimer == 180
				or evt.ftimer == 195
				or evt.ftimer == 210
				or evt.ftimer == 220
					playSound(mo.battlen, sfx_mswing)
				end
				if evt.ftimer == 150
					local cx2 = btl.eggdude.x + 1400*cos(ANG1*215)
					local cy2 = btl.eggdude.y + 1400*sin(ANG1*215)
					P_TeleportMove(cam, cx2, cy2, btl.eggdude.z + 400*FRACUNIT)
					cam.aiming = -ANG1*20
					CAM_stop(cam)
				end
				if evt.ftimer == 230
					playSound(mo.battlen, sfx_boost2)
					P_TeleportMove(cam, cam.x, cam.y, mo.z + 200*FRACUNIT)
					speeding = true
					mo.anglespeed = 20
					mo.anglespeed2 = 20
				end
				if evt.ftimer == 250
					boxflip = true
					return true
				end
			end
		},
	[9] = {"text", "Eggman", "Blast it all!!! You're always a pain in my side, aren't you?!", nil, nil, nil, {"H_EGG2", SKINCOLOR_RED}},
	[10] = {"function",
			function(evt, btl) 
				boxflip = false
				return true
			end
		},
	[11] = {"text", "Sonic", "Watch and learn, Eggman! THIS is how you use Chaos Emeralds!", nil, nil, nil, {"H_SON5", SKINCOLOR_SUPERGOLD3}},
	[12] = {"function", //SPEED UP
			function(evt, btl)
				local mo = btl.superman
				local cam = btl.cam
				if evt.ftimer == 1
					btl.eggdude.barrier = false
					localquake(mo.battlen, 15*FRACUNIT, 5)
					mo.speedup = true
					playSound(mo.battlen, sfx_s3k81)
					mo.state = S_SUPERSONICDRILL1
					mo.angles = {36, 72, 108, 144, 180, 216, 252, 288, 324, 360}
				end
				if evt.ftimer == 25
					local cx2 = btl.eggdude.x + 1400*cos(ANG1*140)
					local cy2 = btl.eggdude.y + 1400*sin(ANG1*140)
					P_TeleportMove(cam, cx2, cy2, btl.eggdude.z + 400*FRACUNIT)
					cam.aiming = -ANG1*20
					CAM_stop(cam)
					speeding = false
					mo.speedup = false
					mo.tics = -1
					mo.sprite = SPR_WHY6
					mo.anglespeed = 30
				end
				if evt.ftimer >= 25 and evt.ftimer < 80
					if evt.ftimer%10 == 0
						playSound(mo.battlen, sfx_mswing)
					end
				end
				if evt.ftimer == 80
					localquake(mo.battlen, 15*FRACUNIT, 5)
					mo.superspeen = false
					playSound(mo.battlen, sfx_zoom)
					P_InstaThrust(mo, mo.angle, 2000*FRACUNIT)
					mo.flags = $|MF_NOCLIP
					for i = 1, 50
						local dist = i*75
						local tgtx = mo.x + dist*cos(mo.angle)
						local tgty = mo.y + dist*sin(mo.angle)
						local e = P_SpawnGhostMobj(mo)
						P_TeleportMove(e, tgtx, tgty, btl.eggdude.z)
						e.tics = 30
						e.color = mo.color
						e.frame = FF_TRANS50|FF_FULLBRIGHT
						e.scale = FRACUNIT*2
						e.destscale = 0
						e.scalespeed = e.scale/12
					end
				end
				for i = 1, 10
					if evt.ftimer == 110+(i*4)
						ANIM_set(btl.eggdude, btl.eggdude.anim_special1, true)
						local num = P_RandomRange(1, #mo.angles)
						local ang = mo.angles[num]*ANG1
						for j = 1, 100
							mo.angle = ang
							local dist = 3000 - (j*75)
							local tgtx = btl.eggdude.x + dist*cos(ang)
							local tgty = btl.eggdude.y + dist*sin(ang)
							local e = P_SpawnGhostMobj(mo)
							P_TeleportMove(e, tgtx, tgty, btl.eggdude.z)
							e.tics = 30
							e.color = mo.color
							e.frame = FF_TRANS50|FF_FULLBRIGHT
							e.scale = FRACUNIT*2
							e.destscale = 0
							e.scalespeed = e.scale/12
						end
						local s = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z+1*FRACUNIT, MT_DUMMY)
						s.state = S_SLASHING_1_1
						s.color = SKINCOLOR_RED
						s.frame = FF_FULLBRIGHT
						s.scale = FRACUNIT*6
						local s2 = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z, MT_DUMMY)
						s2.state = S_SLASHING_2_1
						s2.color = SKINCOLOR_RED
						s2.frame = FF_FULLBRIGHT
						s2.scale = FRACUNIT*6
						playSound(mo.battlen, sfx_slash)
						localquake(mo.battlen, FRACUNIT*10, 4)
						table.remove(mo.angles, num)
					end
				end
				if evt.ftimer < 170
					//fire effects cont.
					for i = 1, 2
						local x = btl.eggdude.x + P_RandomRange(2000, -2000)*FRACUNIT
						local y = btl.eggdude.y + P_RandomRange(2000, -2000)*FRACUNIT
						local z = btl.eggdude.z + P_RandomRange(700, -1200)*FRACUNIT
						local fire = P_SpawnMobj(x, y, z, MT_DUMMY)
						fire.sprite = SPR_FPRT
						fire.frame = $ & ~FF_TRANSMASK
						fire.frame = $|FF_FULLBRIGHT|TR_TRANS20
						fire.scale = mo.scale*6
						fire.momz = P_RandomRange(30, 70)*mo.scale
						fire.scalespeed = mo.scale/6
						fire.destscale = 1
						fire.tics = TICRATE
					end
					
					for i = 1,10
						local thok = P_SpawnMobj(btl.eggdude.x + P_RandomRange(-800, 800)*FRACUNIT, btl.eggdude.y + P_RandomRange(-800, 800)*FRACUNIT, btl.eggdude.z - 200*FRACUNIT, MT_DUMMY)
						thok.flags = MF_NOBLOCKMAP
						thok.color = SKINCOLOR_RED
						if leveltime%2 then thok.color = SKINCOLOR_ORANGE end
						thok.frame = A
						thok.tics = 70
						thok.scale = FRACUNIT/2
						thok.scalespeed = FRACUNIT/32
						thok.destscale = 1
						thok.momz = P_RandomRange(4, 10)*FRACUNIT
						thok.momx = P_RandomRange(-3, 3)*FRACUNIT
						thok.momy = P_RandomRange(-3, 3)*FRACUNIT
					end
				end
				if evt.ftimer == 170
					playSound(mo.battlen, sfx_spndsh)
					local tgtx = btl.eggdude.x + 1500*cos(ANG1*90)
					local tgty = btl.eggdude.y + 1500*sin(ANG1*90)
					P_TeleportMove(mo, tgtx, tgty, btl.eggdude.z + 150*FRACUNIT)
					P_InstaThrust(mo, ANG1*90, 8*FRACUNIT)
					mo.momz = 8*FRACUNIT
					mo.angle = ANG1*270
					mo.state = S_PLAY_JUMP
				end
				if evt.ftimer >= 170 and evt.ftimer < 210
					local cx2 = mo.x + 100*cos(mo.angle + 270*ANG1)
					local cy2 = mo.y + 100*sin(mo.angle + 270*ANG1)
					CAM_goto(cam, cx2, cy2, mo.z + 70*FRACUNIT)
					CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, mo.x, mo.y))
					if leveltime%5 == 0
						mo.momz = $ - 1*FRACUNIT
					end
					summonAura(mo, SKINCOLOR_SUPERGOLD3)
				end
				if evt.ftimer == 210
					playSound(mo.battlen, sfx_zoom)
					playSound(mo.battlen, sfx_cspear)
					mo.momx = (btl.eggdude.x - mo.x)/10
					mo.momy = (btl.eggdude.y - mo.y)/10
					mo.momz = (btl.eggdude.z - mo.z)/10
				end
				if evt.ftimer >= 210 and evt.ftimer < 220
					local effect = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					effect.tics = 1
					effect.sprite = SPR_FIRS
					effect.frame = S|FF_TRANS20
					effect.angle = mo.angle
					effect.scale = mo.scale*3/2
					P_SpawnGhostMobj(mo)
					local cx = mo.x + 150*cos(75*ANG1)
					local cy = mo.y + 150*sin(75*ANG1)
					CAM_goto(cam, cx, cy, mo.z)
					cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
				end
				//KABLOOEY
				if evt.ftimer == 220
					local cx = btl.eggdude.x - 200*cos(ANG1*90)
					local cy = btl.eggdude.y - 200*sin(ANG1*90)
					P_TeleportMove(cam, cx, cy, mo.z - 70*FRACUNIT)
					cam.angle = R_PointToAngle2(cam.x, cam.y, btl.eggdude.x, btl.eggdude.y)
					cam.aiming = ANG1*5
					CAM_stop(cam)
					local cx2 = btl.eggdude.x - 400*cos(ANG1*90)
					local cy2 = btl.eggdude.y - 400*sin(ANG1*90)
					CAM_goto(cam, cx2, cy2, cam.z)
					/*mo.momx = $/20
					mo.momy = $/20
					mo.momz = $/23*/
					btl.eggdude.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
					S_StopMusic(nil)
					localquake(mo.battlen, FRACUNIT*40, 20)
					for i = 1, 2
						playSound(mo.battlen, sfx_megi5)
						playSound(mo.battlen, sfx_s3k4e)
						playSound(mo.battlen, sfx_fire1)
						playSound(mo.battlen, sfx_fire2)
					end
					playSound(mo.battlen, sfx_egdie1)
					
					local boom = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z-20*FRACUNIT, MT_BOSSEXPLODE)
					boom.scale = FRACUNIT*10
					boom.state = S_PFIRE1
					boom.frame = $|FF_FULLBRIGHT
					for i = 1, 8
						local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
						smoke.scale = FRACUNIT*6
						smoke.momx = P_RandomRange(-5, 5)*FRACUNIT
						smoke.momy = P_RandomRange(-5, 5)*FRACUNIT
						smoke.momz = P_RandomRange(3, 6)*FRACUNIT
					end
					local sm = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z, MT_SMOLDERING)
					sm.fuse = TICRATE/2
					sm.scale = btl.eggdude.scale*3/2
					
					for j = 1, 80
						local st = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z, MT_DUMMY)
						st.state = S_MEGITHOK
						st.flags = $ & ~MF_NOGRAVITY
						st.momx = P_RandomRange(-128, 128)*FRACUNIT
						st.momy = P_RandomRange(-128, 128)*FRACUNIT
						st.momz = P_RandomRange(-128, 128)*FRACUNIT
						st.fuse = 20
						st.scale = FRACUNIT*3/2
					end
					
					for s in sectors.iterate
						if s.tag == 33 or s.tag == 60
							s.ceilingheight = -6000*FRACUNIT
							s.floorheight = -6000*FRACUNIT
						end
					end
					
					mo.eggman = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z+300*FRACUNIT, MT_DUMMY)
					mo.eggman.skin = btl.eggdude.skin
					mo.eggman.sprite = btl.eggdude.sprite
					mo.eggman.sprite2 = btl.eggdude.sprite2
					mo.eggman.frame = btl.eggdude.frame
					mo.eggman.scale = btl.eggdude.scale*3/2
					mo.eggman.fuse = -1
					mo.eggman.flags = MF_NOCLIP|MF_NOCLIPHEIGHT & ~MF_NOGRAVITY
					mo.eggman.color = btl.eggdude.color
					--P_InstaThrust(mo.eggman, ANG1*180, 10*FRACUNIT)
					mo.eggman.momz = 30*FRACUNIT
					damageObject(btl.eggdude, P_RandomRange(5000, 9001)*3)
				end
				if evt.ftimer >= 220 and mo.eggman and mo.eggman.valid
					mo.eggman.rollangle = $+ANG1*60
					mo.eggman.state = S_PLAY_PAIN
				end
				if evt.ftimer == 290
					playSound(mo.battlen, sfx_s3k51)
				end
				if evt.ftimer == 340
					return true
				end
			end
		},
	[13] = {"function", //results screen (BUT AWESOME)
			function(evt, btl)
				local mo = btl.superman
				local cam = btl.cam
				local y = 2500*FRACUNIT
				if evt.ftimer == 1
					P_TeleportMove(mo, -4160*FRACUNIT, 600*FRACUNIT, -1000*FRACUNIT)
					mo.momz = -60*FRACUNIT
					mo.sprite = SPR_WHY6
					mo.frame = A
					mo.tics = -1
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 2

							local cam = btl.cam
							P_TeleportMove(cam, m.x, m.y, m.z)
							cam.angle = m.angle
							cam.aiming = -ANG1*2
							CAM_goto(cam, cam.x, cam.y, cam.z)
							CAM_angle(cam, cam.angle)
							CAM_aiming(cam, cam.aiming)
							break
						end
					end
					//spawn stage clear sign
					mo.sign = P_SpawnMobj(-3904*FRACUNIT, 1856*FRACUNIT, cam.floorz, MT_SIGN)
					mo.sign.spin = false
					mo.sign.angle = ANG1*90
				end
				mo.momy = (y - mo.y)/55
				mo.angle = ANG1*90
				if evt.ftimer < 38
					mo.momz = $+2*FRACUNIT
					P_SpawnGhostMobj(mo)
				end
				if evt.ftimer == 38
					playSound(mo.battlen, sfx_poof)
					mo.status_condition = COND_NORMAL
					mo.color = SKINCOLOR_BLUE
					mo.flags = $ & ~MF_NOGRAVITY
					mo.state = S_PLAY_FALL //S_PLAY_JUMP?
					local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT
					A_OldRingExplode(thok, MT_SUPERSPARK)
				end
				if mo.sign and mo.sign.valid and mo.y >= mo.sign.y and not mo.sign.spin and evt.ftimer < 180
					playSound(mo.battlen, sfx_lvpass)
					mo.sign.spin = true
				end
				if mo.sign.spin
					if leveltime%3 == 0
						A_SignPlayer(mo.sign, P_RandomRange(0, 3))
					end
					mo.sign.angle = $ + 40*ANG1
				end
				if evt.ftimer >= 90 and evt.ftimer < 180
					local cx = mo.sign.x + 200*cos(ANG1*90)
					local cy = mo.sign.y + 200*sin(ANG1*90)
					CAM_goto(cam, cx, cy, mo.sign.z + 25*FRACUNIT)
				end
				if evt.ftimer == 120
					S_ChangeMusic("fclear")
				end
				if evt.ftimer == 180
					mo.sign.spin = false
					local cx = mo.sign.x + 100*cos(ANG1*90)
					local cy = mo.sign.y + 100*sin(ANG1*90)
					P_TeleportMove(cam, cx, cy, cam.z)
					CAM_stop(cam)
					localquake(mo.battlen, FRACUNIT*10, 4)
					A_SignPlayer(mo.sign, 0)
					mo.sign.angle = 90*ANG1
					playSound(mo.battlen, sfx_nxbump) //louds
					playSound(mo.battlen, sfx_nxbump)
					local thok = P_SpawnMobj(mo.sign.x, mo.sign.y, mo.sign.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT
					A_OldRingExplode(thok, MT_NIGHTSPARKLE)
				end
				if evt.ftimer == 220
					stagecleared = true
				end
			end
		},
}

//super tails finisher cutscene
eventList["ev_stage6_eggman_dies_t"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"function",
			function(evt, btl)
				boxflip = true
				return true
			end
		},
	[2] = {"text", "Eggman", "!!!", nil, nil, nil, {"H_EGG2", SKINCOLOR_RED}},
	[3] = {"function",
			function(evt, btl) 
				if evt.ftimer == 1
					local x = -3904*FRACUNIT
					local y = -576*FRACUNIT
					local z = -1776*FRACUNIT
					//zoom back out
					if evt.ftimer == 1
						local tgtx = x + 700*cos(ANG1*90)
						local tgty = y + 700*sin(ANG1*90)
						local cam = btl.cam
						cam.angle = ANG1*270
						CAM_goto(cam, tgtx, tgty, -1700*FRACUNIT)
						CAM_angle(cam, cam.angle)
						CAM_aiming(cam, cam.aiming)
					end
				end
				if evt.ftimer == 35
					P_LinedefExecute(1002)
					for s in sectors.iterate
						if s.tag == 53 or s.tag == 54
							for i = 0, 2 --why is it like this im crying
								if s.lines[i].tag == 16
									s.ceilingheight = -6000*FRACUNIT
									s.floorheight = -6000*FRACUNIT
								end
							end
						end
					end
					S_StartSound(nil, sfx_kc65)
					S_StartSound(nil, sfx_status)
					local platformtags = {31, 30, 29, 28, 8, 9, 10}
					for s in sectors.iterate
						if s.tag == 53 or s.tag == 54 or s.tag == 41 or s.tag == 42
							for i = 0, 2 --why is it like this im crying
								if s.lines[i].tag != 16
									s.ceilingheight = 0
									s.floorheight = 0
								end
							end
						end
						if s.tag == platformtags[btl.lockplatform]
							for i = 0, 3
								s.lines[i].frontside.midtexture = 0
								s.lines[i].backside.midtexture = 0
							end
						end
					end
					//remove eggman hyper cannon if it exists
					if btl.eggdude.energypoint and btl.eggdude.energypoint.valid
						P_RemoveMobj(btl.eggdude.energypoint)
					end
					btl.eggdude.cannoncharge = false
					btl.eggdude.cannonprepare = false
					//remove emerald link objects
					for m in mobjs.iterate() do
						if m and m.valid and m.type == MT_DUMMY
							if m.emeraldlink
								P_RemoveMobj(m)
							end
						end
					end
					//remove warning thoks
					if btl.eggdude.warning and #btl.eggdude.warning
						for i = 1, #btl.eggdude.warning
							if btl.eggdude.warning[i] and btl.eggdude.warning[i].valid
								P_RemoveMobj(btl.eggdude.warning[i])
							end
						end
					end
				end
				if evt.ftimer == 70
					return true
				end
			end
		},
	[4] = {"function",
			function(evt, btl) 
				boxflip = false
				return true
			end
		},
	[5] = {"text", "Tails", "Aha! So without the power of the emeralds, the barrier's been nullified! This is perfect!", nil, nil, nil, {"H_TAILS2", SKINCOLOR_ORANGE}},
	[6] = {"text", "Tails", "And speaking of the emeralds, I suppose there's no better time than now!", nil, nil, nil, {"H_TAILS2", SKINCOLOR_ORANGE}},
	[7] = {"function", //super transformation + snatch eggman
			function(evt, btl)
				local mo = btl.superman
				local cam = server.P_BattleStatus[mo.battlen].cam
				//okay dont listen to super sonic anim's rant about ticrate i got confused so im changing it
				if evt.ftimer >= 33
					if not mo.damagetime or mo.damagetime < 370
						mo.momz = $*90/100
					end
				else
					mo.momz = FRACUNIT
					mo.flags = $|MF_NOGRAVITY	-- lol
				end
				

				if evt.ftimer == 1

					local cx = mo.x + 256*cos(mo.angle/* + ANG1*20*/)
					local cy = mo.y + 256*sin(mo.angle/* + ANG1*20*/)
					CAM_goto(cam, cx, cy, mo.z + FRACUNIT*30, 70*FRACUNIT)
					CAM_angle(cam, R_PointToAngle2(cx, cy, mo.x, mo.y))

					mo.anim = nil	-- kind of a hack
					mo.state = S_PLAY_FALL
					mo.hp = 0 //the tails followmobj goes away if hp is at 0 so since i cant find any other way of killing it
					btl.eggdude.barrier = false
				end

				-- spawn the emeralds:
				if evt.ftimer == 28
					mo.emeralds = {}
					mo.em_rotspeed = 1
					mo.em_ang = 0
					mo.em_dist = 1024

					for i = 1, 7
						mo.emeralds[i] = P_SpawnMobj(0, 0, 0, MT_EMERALD1+(i-1))
						mo.emeralds[i].scale = $*3/2
					end
				end

				if evt.ftimer >= 28
				and mo.emeralds and mo.emeralds[1] and mo.emeralds[1].valid


					local ang = mo.em_ang
					for i = 1, 7
						local x = mo.x + mo.em_dist*cos(ang)
						local y = mo.y + mo.em_dist*sin(ang)
						local z = mo.z + 32*cos(leveltime*ANG1*2 + (360/7)*ANG1*i)	-- funny z axis variation

						P_TeleportMove(mo.emeralds[i], x, y, z)
						ang = $ + (360/7)*ANG1
					end

					mo.em_ang = $+ mo.em_rotspeed*ANG1
					mo.em_rotspeed = min(32, $+1)
					mo.em_dist = max(64, $-24)
				end

				if evt.ftimer == 80
					for i = 1, 7 do
						P_RemoveMobj(mo.emeralds[i])
					end
					mo.emeralds = nil

					mo.state = S_PLAY_SUPER_TRANS1
					for k,v in ipairs(mo.allies)
						if v and v.control and v.control.valid
							P_FlashPal(v.control, 1, 8)
						end
					end
					S_StartSound(mo, sfx_s3k9f)
					mo.status_condition = COND_SUPER	-- direct affectation
					S_ChangeMusic("stg6d")
					CAM_stop(cam)
				end

				if evt.ftimer >= 80
					if mo.state == S_PLAY_SUPER_TRANS6
						mo.tics = -1
					end
					if evt.ftimer < 123
						summonAura(mo, SKINCOLOR_SUPERGOLD3)
					end
				end
								
				
				
				//other platform version
				if mo.platform != 4
					if evt.ftimer == 133
						playSound(mo.battlen, sfx_portal)
						mo.state = S_PLAY_JUMP
					end
					if evt.ftimer >= 133 and evt.ftimer < 143
						mo.momz = 8*FRACUNIT
						mo.spritexscale = $ - FRACUNIT/10
						mo.spriteyscale = $ + FRACUNIT/10
					end
					
					//move camera to new spot
					if evt.ftimer >= 153 and evt.ftimer < 193
						local sx = mo.startx + 256*cos(mo.angle)
						local sy = mo.starty + 256*sin(mo.angle)
						CAM_goto(cam, sx, sy, mo.startz + 60*FRACUNIT)
					end
					if evt.ftimer == 193
						playSound(mo.battlen, sfx_portal)
						playSound(mo.battlen, sfx_jump)
						mo.momz = 20*FRACUNIT
						P_InstaThrust(mo, mo.angle + ANG1*180, 12*FRACUNIT)
						mo.state = S_PLAY_JUMP
						mo.flags = $ & ~MF_NOGRAVITY
						mo.hp = mo.maxhp
						P_TeleportMove(mo, mo.startx, mo.starty, mo.startz + 60*FRACUNIT)
					end
					if evt.ftimer >= 193 and evt.ftimer < 203
						mo.spritexscale = $ + FRACUNIT/10
						mo.spriteyscale = $ - FRACUNIT/10
					end
					
					if evt.ftimer >= 193 and not mo.damagetime
						local cx = mo.x + 256*cos(mo.angle - 40*ANG1)
						local cy = mo.y + 256*sin(mo.angle - 40*ANG1)
						CAM_goto(cam, cx, cy, cam.z)
						--P_TeleportMove(cam, cx, cy, cam.z)
						cam.momz = mo.momz
						cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
						if not P_IsObjectOnGround(mo)
							mo.momz = $-1*FRACUNIT
						else
							mo.momz = 0
						end
					end
				else	//platform 4 version
					if evt.ftimer == 133
						playSound(mo.battlen, sfx_jump)
						mo.momz = 20*FRACUNIT
						P_InstaThrust(mo, mo.angle + ANG1*180, 12*FRACUNIT)
						mo.state = S_PLAY_JUMP
						mo.flags = $ & ~MF_NOGRAVITY
						mo.hp = mo.maxhp
					end
					
					if evt.ftimer >= 133 and not mo.damagetime
						local cx = mo.x + 256*cos(mo.angle - 40*ANG1)
						local cy = mo.y + 256*sin(mo.angle - 40*ANG1)
						CAM_goto(cam, cx, cy, cam.z)
						--P_TeleportMove(cam, cx, cy, cam.z)
						cam.momz = mo.momz
						cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
						if not P_IsObjectOnGround(mo)
							mo.momz = $-1*FRACUNIT
						else
							mo.momz = 0
						end
					end
				end
					
				if P_IsObjectOnGround(mo)
				and not mo.momz
				and not mo.damagetime

					-- now make it zoom out a little
					CAM_goto(cam, cam.x-24*cos(cam.angle), cam.y-24*sin(cam.angle), cam.z+FRACUNIT*5, 1*FRACUNIT)

					mo.damagetime = 1
					mo.momx, mo.momy, mo.momz = 0, 0, 0 -- stop momentum, start spindash
					mo.state = S_PLAY_SPINDASH
					mo.angle = R_PointToAngle2(mo.x, mo.y, btl.eggdude.x, btl.eggdude.y)
					playSound(mo.battlen, sfx_spndsh)
				elseif mo.damagetime
					mo.damagetime = $+1
					-- rev animation
					if mo.damagetime == 13 or mo.damagetime == 21 or mo.damagetime == 28

						mo.rev = $ and $+1 or 1
						playSound(mo.battlen, sfx_spndsh)
						mo.state = S_PLAY_SPINDASH
					end
					-- start spindash
					if mo.damagetime >= 35 and mo.damagetime < 410
						cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
						--CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, mo.x, mo.y))
						if mo.damagetime == 35 -- nyoom
							playSound(mo.battlen, sfx_zoom)
							playSound(mo.battlen, sfx_jump)
							P_InstaThrust(mo, mo.angle, FRACUNIT*80)
							mo.momz = 25*FRACUNIT
							mo.state = S_PLAY_JUMP
						else
							if mo.damagetime >= 44 and mo.damagetime < 300
								cam.momx = mo.momx
								cam.momy = mo.momy
							end
							if mo.damagetime < 300
								cam.momz = mo.momz
								local trail = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
								trail.color = mo.color
							end
							
							if R_PointToDist2(mo.x, mo.y, btl.eggdude.x, btl.eggdude.y) < 50*FRACUNIT and mo.damagetime < 300
								mo.rev = nil
								ANIM_set(mo, mo.anim_special1, true)
								--mo.state = S_PLAY_FLY
								mo.flags = $|MF_NOGRAVITY
								local x = btl.eggdude.x + 50*cos(mo.angle)
								local y = btl.eggdude.y + 50*sin(mo.angle)
								P_TeleportMove(mo, x, y, btl.eggdude.z)
								local cx2 = btl.eggdude.x + 500*cos(ANG1*230)
								local cy2 = btl.eggdude.y + 500*sin(ANG1*230)
								P_TeleportMove(cam, cx2, cy2, btl.eggdude.z + 100*FRACUNIT)
								cam.aiming = -ANG1*10
								CAM_stop(cam)
								playSound(mo.battlen, sfx_crumbl)
								mo.carry = true
								localquake(mo.battlen, FRACUNIT*30, 8)
								
								//make da hole
								for s in sectors.iterate
									if s.tag == 44
										s.ceilingheight = -1600*FRACUNIT
										s.floorheight = -1776*FRACUNIT
									end
								end
								
								//metal things flying out
								local mx = btl.eggdude.x + 50*cos(ANG1*270)
								local my = btl.eggdude.y + 50*sin(ANG1*270)
								local dx = btl.eggdude.x + 300*cos(ANG1*270)
								local dy = btl.eggdude.y + 300*sin(ANG1*270)
								for i = 1, 16
									local st = P_SpawnMobj(mx, my, btl.eggdude.z, MT_DUMMY)
									--local st = P_SpawnMobj(mo.x, mo.y, btl.eggdude.z, MT_DUMMY)
									st.state = S_BRICKDEBRIS
									st.flags = $ & ~MF_NOGRAVITY
									--st.scale = FRACUNIT/2
									st.momx = P_RandomRange(-30, 50)*FRACUNIT
									st.momy = P_RandomRange(-10, -50)*FRACUNIT
									st.momz = P_RandomRange(-8, 20)*FRACUNIT
									st.fuse = 60
								end
								mo.damagetime = 300
							end
						end
					end
				end
				
				//picking up eggman after crashing into the thingy
				if mo.damagetime and mo.damagetime >= 300
					if mo.carry
						mo.momx = $*80/100
						mo.momy = $*80/100
						mo.momz = 0
						P_TeleportMove(btl.eggdude, mo.x, mo.y, mo.z - 65*FRACUNIT)
						btl.eggdude.state = S_PLAY_FLY_TIRED
						btl.eggdude.angle = ANG1*270
					end
					
					//descend before launch
					if mo.damagetime >= 350 and mo.damagetime < 370
						mo.momz = -2*FRACUNIT
					end
					
					//garu particles before launch
					if mo.damagetime == 350
						playSound(mo.battlen, sfx_wind2)
						for i = 1, 12
							local g = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, mo.z + P_RandomRange(20, 120)*FRACUNIT, MT_GARU)
							g.target = mo
							g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
							if i == 1 or i == 12
								g.jizzcolor = true
							end
							if i%2
								g.invertrotation = true
							end
							g.dist = P_RandomRange(45, 140)
							g.tics = 20
						end
					end
					
					//LAUNCH
					if mo.damagetime == 370
						playSound(mo.battlen, sfx_s3k81)
						playSound(mo.battlen, sfx_wind1)
						localquake(mo.battlen, 20*FRACUNIT, 3)
						mo.momz = 12*FRACUNIT
						btl.eggdude.momz = 50*FRACUNIT
						mo.anim = nil
						mo.state = S_PLAY_SPRING
						mo.carry = false
						mo.flags = $ & ~MF_NOGRAVITY
						btl.eggdude.launch = true
						btl.eggdude.flags = $|MF_NOGRAVITY
						P_InstaThrust(mo, mo.angle + ANG1*180, 2*FRACUNIT)
						for i = 1, 32
							local g = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z, MT_DUMMY)
							g.scale = FRACUNIT
							g.destscale = 1
							g.color = SKINCOLOR_EMERALD
							g.frame = A
							if i%2 then g.color = SKINCOLOR_WHITE end
							g.momx = P_RandomRange(-15, 15)*FRACUNIT
							g.momy = P_RandomRange(-15, 15)*FRACUNIT
							g.momz = P_RandomRange(-15, 15)*FRACUNIT
						end
					end
					
					if mo.damagetime == 395
						mo.state = S_PLAY_FALL
					end
					
					if mo.damagetime >= 360 and mo.damagetime < 410
						P_SpawnGhostMobj(btl.eggdude)
					end
					
					//change scenes to flying eggman
					if mo.damagetime == 410
						flying = true
						P_TeleportMove(btl.eggdude, -554*FRACUNIT, -1056*FRACUNIT, -1650*FRACUNIT)
						btl.eggdude.momz = 2*FRACUNIT
						btl.eggdude.angle = ANG1*225
						
						//camera
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 3
							
								P_TeleportMove(cam, m.x, m.y, m.z)
								cam.angle = m.angle
								cam.aiming = 0
								CAM_goto(cam, cam.x, cam.y, cam.z)
								CAM_angle(cam, cam.angle)
								CAM_aiming(cam, cam.aiming)
								CAM_stop(cam)
								break
							end
						end
						
						//wind effect thingies (too bad i cant adjust a lot in terms of garu effects)
						/*for i = 1, 6
							local ghost = P_SpawnMobj(-650*FRACUNIT, -1056*FRACUNIT, (-1600 + i*60)*FRACUNIT, MT_PFIGHTER)
							ghost.cutscene = true
							ghost.hp = mo.hp
							ghost.flags = MF_NOGRAVITY|MF_NOTHINK
							ghost.flags2 = MF2_DONTDRAW
							for i = 1, 4
								local g = P_SpawnMobj(-650*FRACUNIT, -1056*FRACUNIT, -1440*FRACUNIT + P_RandomRange(-500, 500)*FRACUNIT, MT_GARU)
								g.target = ghost
								g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
								if i == 1 or i == 4
									g.jizzcolor = true
								end
								if i%2
									g.invertrotation = true
								end
								g.dist = P_RandomRange(200, 300)
								g.tics = -1
							end
						end*/
					end
					
					if mo.damagetime == 460
						P_TeleportMove(mo, -554*FRACUNIT, -1150*FRACUNIT, -1700*FRACUNIT)
						mo.goingup = true
						mo.momx = 0
						mo.momy = 0
						mo.momz = 2*FRACUNIT
						mo.rollangle = ANG1*90
						mo.flags = $|MF_NOGRAVITY
						
						//tails arent usually affected by roll angle here so create our own
						mo.hp = 0
						mo.state = S_PLAY_RUN
						mo.tails = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_DUMMY)
						mo.tails.skin = "tails"
						mo.tails.color = SKINCOLOR_ORANGE
						mo.tails.scale = mo.scale
						mo.tails.state = S_TAILSFLY
						mo.tails.angle = mo.angle
						mo.tails.eflags = $|MFE_VERTICALFLIP
						mo.tails.flags2 = $|MF2_OBJECTFLIP
						
						//move platforms and other players out of the way
						for s in sectors.iterate
							if s.tag == 32 or s.tag == 33 or s.tag == 60
								s.floorheight = -6000*FRACUNIT
								s.ceilingheight = -6000*FRACUNIT
							end
						end
						for k,v in ipairs(btl.fighters)
							if v.enemy != "b_eggman" and v != mo
								P_TeleportMove(v, -8130*FRACUNIT, 1730*FRACUNIT, -1900*FRACUNIT)
							end
						end
						//testing hack(?): kill the glass in the way during the cutscene
						for i = 1, 7
							P_LinedefExecute(100 + i) --kill
						end
					end
					
					if mo.damagetime == 520
						mo.damagetime = nil
						return true
					end
				end
			end
		},
	[8] = {"text", "Tails", "If you're so smart, then tell me something, Eggman!", nil, nil, nil, {"H_TAILS2", SKINCOLOR_ORANGE}},
	[9] = {"text", "Tails", "It's been a while, but do you remember what element Curse is weak to?", nil, nil, nil, {"H_TAILS2", SKINCOLOR_ORANGE}},
	[10] = {"function", //speen and make pretty lights around eggman
			function(evt, btl)
				local mo = btl.superman
				local cam = server.P_BattleStatus[mo.battlen].cam
				if mo.z == btl.eggdude.z and evt.ftimer < 200
					evt.ftimer = 200
				end
				if evt.ftimer == 200
					mo.spinangle = 0
					mo.sparkles = {}
					mo.fangle = R_PointToAngle2(btl.eggdude.x, btl.eggdude.y, mo.x, mo.y)
					playSound(mo.battlen, sfx_jump)
					mo.momy = (mo.y - btl.eggdude.y)/18
					mo.momz = 16*FRACUNIT
					mo.rollangle = 0
					mo.flags = $ & ~MF_NOGRAVITY
					mo.state = S_PLAY_SPRING
					mo.angle = R_PointToAngle2(mo.x, mo.y, btl.eggdude.x, btl.eggdude.y)
					mo.hp = mo.maxhp
					mo.goingup = false
					P_RemoveMobj(mo.tails)
				end
				if evt.ftimer == 218
					mo.state = S_PLAY_FALL
				end
				if evt.ftimer > 200 and mo.spinangle == 0
					mo.momz = $-1*FRACUNIT
					if mo.z <= btl.eggdude.z and not mo.nyoom
						mo.nyoom = true
						mo.state = S_PLAY_ROLL
						playSound(mo.battlen, sfx_cdfm01)
					end
				end
				if mo.nyoom
					local dist = R_PointToDist2(mo.x, mo.y, btl.eggdude.x, btl.eggdude.y)/FRACUNIT
					local x = btl.eggdude.x + dist*cos(mo.fangle + ANG1*mo.spinangle)
					local y = btl.eggdude.y + dist*sin(mo.fangle + ANG1*mo.spinangle)
					P_TeleportMove(mo, x, y, btl.eggdude.z)
					mo.momx = 0
					mo.momy = 0
					mo.momz = 0
					mo.angle = R_PointToAngle2(mo.x, mo.y, btl.eggdude.x, btl.eggdude.y) + ANG1*270
					mo.spinangle = $ + 18
					local sparkle = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					sparkle.rotate = R_PointToAngle2(btl.eggdude.x, btl.eggdude.y, sparkle.x, sparkle.y)
					sparkle.scale = FRACUNIT/2
					sparkle.tics = -1
					sparkle.sprite = SPR_FILD
					sparkle.frame = FF_FULLBRIGHT
					sparkle.colorized = true
					sparkle.angle = ANG1*180
					mo.sparkles[#mo.sparkles+1] = sparkle
					if mo.spinangle == 360
						mo.momz = 15*FRACUNIT
						mo.state = S_PLAY_SPRING
						mo.angle = ANG1*270
						P_InstaThrust(mo, mo.angle, 30*FRACUNIT)
						mo.flags = $ & ~MF_NOGRAVITY
						mo.nyoom = false
					end
				end
				
				if evt.ftimer == 280
					playSound(mo.battlen, sfx_aoaask)
				end
				
				if mo.sparkles and #mo.sparkles
					for i = 1, #mo.sparkles
						local sparkle = mo.sparkles[i]
						if leveltime%6 == 0
							local g = P_SpawnGhostMobj(sparkle)
							g.destscale = FRACUNIT*2
							g.scalespeed = FRACUNIT/16
						end
						if evt.ftimer >= 280
							local dist = R_PointToDist2(sparkle.x, sparkle.y, btl.eggdude.x, btl.eggdude.y)/FRACUNIT
							local x = btl.eggdude.x + dist*cos(sparkle.rotate)
							local y = btl.eggdude.y + dist*sin(sparkle.rotate)
							local tgtx = btl.eggdude.x + 60*cos(sparkle.rotate)
							local tgty = btl.eggdude.y + 60*sin(sparkle.rotate)
							sparkle.momx = (tgtx - sparkle.x)/20
							sparkle.momy = (tgty - sparkle.y)/20
							sparkle.rotate = $ + ANG1*2
							P_TeleportMove(sparkle, x, y, btl.eggdude.z)
						end
					end
				end
				
				if evt.ftimer == 350
					btl.eggdude.momz = 2*FRACUNIT
				end
				
				if evt.ftimer == 420
					return true
				end
			end
		},
	[11] = {"function", //cut to non scrolling bg and eggman rises up from bottom and then we KILL HIM
			function(evt, btl)
				local mo = btl.superman
				local cam = server.P_BattleStatus[mo.battlen].cam
				if evt.ftimer == 1
					flying = false
					//camera
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 4
						
							P_TeleportMove(cam, m.x, m.y, m.z)
							cam.angle = m.angle
							cam.aiming = 0
							CAM_goto(cam, cam.x, cam.y, cam.z)
							CAM_angle(cam, cam.angle)
							CAM_aiming(cam, cam.aiming)
							CAM_stop(cam)
							break
						end
					end
				end
				
				if evt.ftimer == 30
					P_TeleportMove(btl.eggdude, 1152*FRACUNIT, -1056*FRACUNIT, -1650*FRACUNIT)
					btl.eggdude.momz = 20*FRACUNIT
					btl.eggdude.angle = ANG1*225
					btl.eggdude.state = S_PLAY_FLY_TIRED
				end
				
				if evt.ftimer > 30
					if btl.eggdude.launch and btl.eggdude.z >= -1350*FRACUNIT
						playSound(mo.battlen, sfx_wind1)
						for i = 1, 32
							local g = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z, MT_DUMMY)
							g.scale = FRACUNIT/2
							g.destscale = 1
							g.color = SKINCOLOR_EMERALD
							g.frame = A
							if i%2 then g.color = SKINCOLOR_WHITE end
							g.momx = P_RandomRange(-15, 15)*FRACUNIT
							g.momy = P_RandomRange(-15, 15)*FRACUNIT
							g.momz = P_RandomRange(-15, 15)*FRACUNIT
						end
						btl.eggdude.uhoh = true
						btl.eggdude.momz = 2*FRACUNIT
						localquake(mo.battlen, 10*FRACUNIT, 3)
						btl.eggdude.launch = false
					end
				end
				
				if btl.eggdude.uhoh
					btl.eggdude.state = S_PLAY_FLY_TIRED
					btl.eggdude.rollangle = $ + ANG1*2
					if btl.eggdude.momz > 0
						btl.eggdude.momz = $ - FRACUNIT/20
					else
						btl.eggdude.momz = 0
					end
				end
				
				if mo.sparkles and #mo.sparkles
					for i = 1, #mo.sparkles
						local sparkle = mo.sparkles[i]
						if leveltime%6 == 0
							local g = P_SpawnGhostMobj(sparkle)
							g.destscale = FRACUNIT*2
							g.scalespeed = FRACUNIT/16
						end
						
						if evt.ftimer < 100
							local dist = R_PointToDist2(sparkle.x, sparkle.y, btl.eggdude.x, btl.eggdude.y)/FRACUNIT
							local tgtx = btl.eggdude.x + 60*cos(sparkle.rotate)
							local tgty = btl.eggdude.y + 60*sin(sparkle.rotate)
							sparkle.rotate = $ + ANG1*2
							P_TeleportMove(sparkle, tgtx, tgty, btl.eggdude.z)
						end
						
						if evt.ftimer == 100
							sparkle.randx = btl.eggdude.x + P_RandomRange(-200, 200)*FRACUNIT
							sparkle.randy = btl.eggdude.y + P_RandomRange(-300, 300)*FRACUNIT
							sparkle.randz = btl.eggdude.z + P_RandomRange(-200, 200)*FRACUNIT
						end
						if evt.ftimer >= 100
							sparkle.momx = (sparkle.randx - sparkle.x)/10
							sparkle.momy = (sparkle.randy - sparkle.y)/10
							sparkle.momz = (sparkle.randz - sparkle.z)/10
						end
						
						if evt.ftimer == 150 + (i*2)
							playSound(mo.battlen, sfx_hamas1)
							local speeds = {FRACUNIT/16, FRACUNIT/10, FRACUNIT/3, FRACUNIT/8}
							local fuses = {20, 16, 8, 16}

							for i = 1, 2
								local l = P_SpawnMobj(sparkle.x, sparkle.y, sparkle.z, MT_THOK)	-- mt_thok for auto fadeout
								l.tics = -1
								l.sprite = SPR_CARD
								l.color = SKINCOLOR_YELLOW
								l.frame = L|(i== 2 and TR_TRANS40 or TR_TRANS70)|FF_FULLBRIGHT
								l.scale = FRACUNIT/2
								l.destscale = FRACUNIT*6
								l.scalespeed = speeds[i]
								l.fuse = fuses[i]
							end
							sparkle.targeting = true
							sparkle.sprite = SPR_ANLY
							sparkle.frame = A|FF_FULLBRIGHT
							sparkle.scale = FRACUNIT
							//this is funny
							sparkle.smallballs = {}
							
							//this is incredibly scrubby but im too stupid to figure out how to aim all these sparkles to eggman vertically
							sparkle.ball = P_SpawnMobj(sparkle.x, sparkle.y, sparkle.z, MT_DUMMY)
							sparkle.ball.momx = (btl.eggdude.x - sparkle.ball.x)/40
							sparkle.ball.momy = (btl.eggdude.y - sparkle.ball.y)/40
							sparkle.ball.momz = ((btl.eggdude.z+10*FRACUNIT) - sparkle.ball.z)/40
							sparkle.ball.sprite = SPR_NULL
							sparkle.ball.tics = -1
						end
						
						if sparkle.ball and sparkle.ball.valid
							local ball = sparkle.ball
							
							
							//spawn tiny link bols
							if evt.ftimer%4 == 0 and evt.ftimer < 230
								local thok = P_SpawnMobj(ball.x, ball.y, ball.z, MT_DUMMY)
								thok.color = SKINCOLOR_WHITE
								thok.sprite = SPR_NULL
								thok.scale = FRACUNIT/3
								thok.frame = FF_FULLBRIGHT
								thok.tics = -1
								sparkle.smallballs[#sparkle.smallballs+1] = thok
							end
							
							//despawn when reach eggman
							if R_PointToDist2(ball.x, ball.y, btl.eggdude.x, btl.eggdude.y) < FRACUNIT
								P_RemoveMobj(ball)
							end
						end
						
						if sparkle.smallballs and #sparkle.smallballs
							for i = 1, #sparkle.smallballs
								if sparkle.smallballs[i] and sparkle.smallballs[i].valid
									local boll = sparkle.smallballs[i]
									
									if evt.ftimer == 230
										boll.sprite = SPR_THOK
									end
									if evt.ftimer >= 230
										if leveltime & 1
											boll.flags2 = $ & ~MF2_DONTDRAW
											local g = P_SpawnGhostMobj(boll)
											g.frame = $|FF_FULLBRIGHT
											boll.flags2 = $|MF2_DONTDRAW
											g.fuse = 2
										end
									end
									
									if evt.ftimer >= 289 + i
										boll.color = SKINCOLOR_YELLOW
									end
								end
							end
						end
					end
				end
				
				if evt.ftimer == 100
					--playSound(mo.battlen, sfx_aoaask)
					playSound(mo.battlen, sfx_nskill)
					
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 4
						
							local cx = m.x - 250*cos(m.angle)
							local cy = m.y - 250*sin(m.angle)
							CAM_goto(cam, cx, cy, cam.z)
							break
						end
					end
				end
				
				if evt.ftimer == 230
					playSound(mo.battlen, sfx_megi4)
					
					for k,v in ipairs(btl.fighters)
						if v and v.control and v.control.valid
							P_FlashPal(v.control, 1, 3) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
					end
					
					btl.eggdude.uhoh = false
				end
				
				if evt.ftimer >= 230
					btl.eggdude.state = S_PLAY_FLY_TIRED
				end
				
				if evt.ftimer == 290
					playSound(mo.battlen, sfx_s3k84)
				end
				
				if evt.ftimer >= 345
					if evt.ftimer < 520
						btl.eggdude.maxhp = -1
						btl.eggdude.hp = 99999
					end
					if btl.eggdude.hp > 0
						if leveltime%3 == 0
							local thok = P_SpawnMobj(btl.eggdude.x + P_RandomRange(-200, 200)*FRACUNIT, btl.eggdude.y + P_RandomRange(-200, 200)*FRACUNIT, btl.eggdude.z + P_RandomRange(-100, 200)<<FRACBITS, MT_DUMMY)
							thok.scale = FRACUNIT*3/2
							A_OldRingExplode(thok, MT_SUPERSPARK)
							thok.flags2 = $|MF2_DONTDRAW
							playSound(mo.battlen, sfx_hamas2)

							local speeds = {FRACUNIT/16, FRACUNIT/10, FRACUNIT/3, FRACUNIT/8}
							local fuses = {20, 16, 8, 16}

							for i = 1, 2
								local l = P_SpawnMobj(thok.x, thok.y, thok.z + FRACUNIT*32, MT_THOK)	-- mt_thok for auto fadeout
								l.tics = -1
								l.sprite = SPR_CARD
								l.color = SKINCOLOR_YELLOW
								l.frame = L|(i== 2 and TR_TRANS40 or TR_TRANS70)|FF_FULLBRIGHT
								l.scale = FRACUNIT/2
								l.destscale = FRACUNIT*6
								l.scalespeed = speeds[i]
								l.fuse = fuses[i]
							end

						end

						if evt.ftimer >= 355
							if evt.ftimer == 355
								btl.eggdude.exorcised = true
								playSound(mo.battlen, sfx_egdie2)
								playSound(mo.battlen, sfx_egdie2)
							end
							if evt.ftimer%3 == 0
								localquake(mo.battlen, 10*FRACUNIT, 1)
								playSound(mo.battlen, sfx_crit)
								damageObject(btl.eggdude, 69*(P_RandomRange(100, 300)), DMG_WEAK)
							end
						end
						
						for i = 1,8
							local thok = P_SpawnMobj(btl.eggdude.x + P_RandomRange(-40, 40)*FRACUNIT, btl.eggdude.y + P_RandomRange(-40, 40)*FRACUNIT, btl.eggdude.z, MT_DUMMY)
							thok.state = S_SSPK1
							thok.momz = P_RandomRange(15, 30)*FRACUNIT
							thok.momx = P_RandomRange(-6, 6)*FRACUNIT
							thok.momy = P_RandomRange(-6, 6)*FRACUNIT
						end
					end
				end
				
				if btl.eggdude.exorcised
					btl.eggdude.state = S_PLAY_FLY_TIRED
					btl.eggdude.rollangle = $ + ANG1*50
				end
				
				if evt.ftimer == 450
					//i cant fade entire screen to white without it sucking so because im lazy im just gonna spawn transparant thoks in front of the cam
					local x = cam.x + 20*cos(cam.angle)
					local y = cam.y + 20*sin(cam.angle)
					mo.fade = P_SpawnMobj(x, y, cam.z - 20*FRACUNIT, MT_DUMMY)
					mo.fade.color = SKINCOLOR_WHITE
					mo.fade.sprite = SPR_THOK
					mo.fade.scale = FRACUNIT*2
					mo.fade.frame = $|FF_TRANS90
					mo.fade.tics = -1
				end
				
				if mo.fade and mo.fade.valid
					local fade = mo.fade
					//all this time and i still dont know a good way to fade something in
					if evt.ftimer == 455
						fade.frame = TR_TRANS80
					elseif evt.ftimer == 460
						fade.frame = TR_TRANS70
					elseif evt.ftimer == 465
						fade.frame = TR_TRANS60
					elseif evt.ftimer == 470
						fade.frame = TR_TRANS50
					elseif evt.ftimer == 475
						fade.frame = TR_TRANS40
					elseif evt.ftimer == 480
						fade.frame = TR_TRANS30
					elseif evt.ftimer == 485
						fade.frame = TR_TRANS20
					elseif evt.ftimer == 490
						fade.frame = TR_TRANS10
					elseif evt.ftimer == 495
						fade.frame = A|FF_FULLBRIGHT
					end
				end
				
				if evt.ftimer == 520
					btl.eggdude.hp = 1
					playSound(mo.battlen, sfx_egdie1)
					for p in players.iterate do
						if p and p.control and p.control.valid and p.control.battlen == mo.battlen
							S_FadeOutStopMusic(3*MUSICRATE, p)
						end
					end
				end
				
				if evt.ftimer == 640
					return true
				end
			end
		}, 
	[12] = {"function", //results screen (BUT AWESOME)
			function(evt, btl)
				local mo = btl.superman
				local cam = btl.cam
				local y = 2500*FRACUNIT
				if evt.ftimer == 1
					P_TeleportMove(mo, -4160*FRACUNIT, 600*FRACUNIT, -1000*FRACUNIT)
					mo.momz = -60*FRACUNIT
					mo.state = S_PLAY_JUMP
					mo.flags = $|MF_NOGRAVITY
					mo.hp = 0
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 2

							local cam = btl.cam
							P_TeleportMove(cam, m.x, m.y, m.z)
							cam.angle = m.angle
							cam.aiming = -ANG1*2
							CAM_goto(cam, cam.x, cam.y, cam.z)
							CAM_angle(cam, cam.angle)
							CAM_aiming(cam, cam.aiming)
							break
						end
					end
					//spawn stage clear sign
					mo.sign = P_SpawnMobj(-3904*FRACUNIT, 1856*FRACUNIT, cam.floorz, MT_SIGN)
					mo.sign.spin = false
					mo.sign.angle = ANG1*90
				end
				mo.momy = (y - mo.y)/55
				mo.angle = ANG1*90
				if evt.ftimer < 38
					mo.momz = $+2*FRACUNIT
					P_SpawnGhostMobj(mo)
				end
				if evt.ftimer == 38
					playSound(mo.battlen, sfx_poof)
					mo.status_condition = COND_NORMAL
					mo.color = SKINCOLOR_ORANGE
					mo.flags = $ & ~MF_NOGRAVITY
					mo.state = S_PLAY_FALL //S_PLAY_JUMP?
					local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT
					A_OldRingExplode(thok, MT_SUPERSPARK)
				end
				if mo.sign and mo.sign.valid and mo.y >= mo.sign.y and not mo.sign.spin and evt.ftimer < 180
					playSound(mo.battlen, sfx_lvpass)
					mo.sign.spin = true
				end
				if mo.sign.spin
					if leveltime%3 == 0
						A_SignPlayer(mo.sign, P_RandomRange(0, 3))
					end
					mo.sign.angle = $ + 40*ANG1
				end
				if evt.ftimer >= 90 and evt.ftimer < 180
					local cx = mo.sign.x + 200*cos(ANG1*90)
					local cy = mo.sign.y + 200*sin(ANG1*90)
					CAM_goto(cam, cx, cy, mo.sign.z + 25*FRACUNIT)
				end
				if evt.ftimer == 120
					S_ChangeMusic("fclear")
				end
				if evt.ftimer == 180
					mo.sign.spin = false
					local cx = mo.sign.x + 100*cos(ANG1*90)
					local cy = mo.sign.y + 100*sin(ANG1*90)
					P_TeleportMove(cam, cx, cy, cam.z)
					CAM_stop(cam)
					localquake(mo.battlen, FRACUNIT*10, 4)
					A_SignPlayer(mo.sign, 1)
					mo.sign.angle = 90*ANG1
					playSound(mo.battlen, sfx_nxbump) //louds
					playSound(mo.battlen, sfx_nxbump)
					local thok = P_SpawnMobj(mo.sign.x, mo.sign.y, mo.sign.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT
					A_OldRingExplode(thok, MT_NIGHTSPARKLE)
				end
				if evt.ftimer == 220
					stagecleared = true
				end
			end
		},
}

//super knuckles finisher cutscene
eventList["ev_stage6_eggman_dies_k"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"function",
			function(evt, btl) 
				boxflip = true
				return true
			end
		},
	[2] = {"text", "Eggman", "!!!", nil, nil, nil, {"H_EGG2", SKINCOLOR_RED}},
	[3] = {"function",
			function(evt, btl) 
				if evt.ftimer == 1
					local x = -3904*FRACUNIT
					local y = -576*FRACUNIT
					local z = -1776*FRACUNIT
					//zoom back out
					if evt.ftimer == 1
						local tgtx = x + 700*cos(ANG1*90)
						local tgty = y + 700*sin(ANG1*90)
						local cam = btl.cam
						cam.angle = ANG1*270
						CAM_goto(cam, tgtx, tgty, -1700*FRACUNIT)
						CAM_angle(cam, cam.angle)
						CAM_aiming(cam, cam.aiming)
					end
				end
				if evt.ftimer == 35
					P_LinedefExecute(1002)
					for s in sectors.iterate
						if s.tag == 53 or s.tag == 54
							for i = 0, 2 --why is it like this im crying
								if s.lines[i].tag == 16
									s.ceilingheight = -6000*FRACUNIT
									s.floorheight = -6000*FRACUNIT
								end
							end
						end
					end
					S_StartSound(nil, sfx_kc65)
					S_StartSound(nil, sfx_status)
					local platformtags = {31, 30, 29, 28, 8, 9, 10}
					for s in sectors.iterate
						if s.tag == 53 or s.tag == 54 or s.tag == 41 or s.tag == 42
							for i = 0, 2 --why is it like this im crying
								if s.lines[i].tag != 16
									s.ceilingheight = 0
									s.floorheight = 0
								end
							end
						end
						if s.tag == platformtags[btl.lockplatform]
							for i = 0, 3
								s.lines[i].frontside.midtexture = 0
								s.lines[i].backside.midtexture = 0
							end
						end
					end
					
					//move platforms and other players out of the way
					for s in sectors.iterate
						for i = 0, 2
							if s.lines[i].tag == 14 or s.lines[i].tag == 15
								s.floorheight = -6000*FRACUNIT
								s.ceilingheight = -6000*FRACUNIT
							end
						end
					end
					for k,v in ipairs(btl.fighters)
						if v.enemy != "b_eggman" and v != btl.superman
							P_TeleportMove(v, -8130*FRACUNIT, 1730*FRACUNIT, -1900*FRACUNIT)
						end
					end
					
					//remove eggman hyper cannon if it exists
					if btl.eggdude.energypoint and btl.eggdude.energypoint.valid
						P_RemoveMobj(btl.eggdude.energypoint)
					end
					btl.eggdude.cannoncharge = false
					btl.eggdude.cannonprepare = false
					//remove emerald link objects
					for m in mobjs.iterate() do
						if m and m.valid and m.type == MT_DUMMY
							if m.emeraldlink
								P_RemoveMobj(m)
							end
						end
					end
					//remove warning thoks
					if btl.eggdude.warning and #btl.eggdude.warning
						for i = 1, #btl.eggdude.warning
							if btl.eggdude.warning[i] and btl.eggdude.warning[i].valid
								P_RemoveMobj(btl.eggdude.warning[i])
							end
						end
					end
				end
				if evt.ftimer == 70
					return true
				end
			end
		},
	[4] = {"function",
			function(evt, btl) 
				boxflip = false
				return true
			end
		},
	[5] = {"text", "Knuckles", "I'm getting sick of being tricked and tossed around! It's about time I shut down this annoying lightshow!", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[6] = {"text", "Knuckles", "Chaos Emeralds, lend me your power!", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[7] = {"function",
			function(evt, btl)
				local mo = btl.superman
				local cam = server.P_BattleStatus[mo.battlen].cam
				//okay dont listen to super sonic anim's rant about ticrate i got confused so im changing it
				if evt.ftimer >= 33
					if not mo.damagetime or mo.damagetime < 370
						mo.momz = $*90/100
					end
				else
					mo.momz = FRACUNIT
					mo.flags = $|MF_NOGRAVITY	-- lol
				end
				

				if evt.ftimer == 1

					local cx = mo.x + 256*cos(mo.angle)
					local cy = mo.y + 256*sin(mo.angle)
					CAM_goto(cam, cx, cy, mo.z + FRACUNIT*30, 70*FRACUNIT)
					CAM_angle(cam, R_PointToAngle2(cx, cy, mo.x, mo.y))

					mo.anim = nil	-- kind of a hack
					mo.state = S_PLAY_FALL
					btl.eggdude.barrier = false
					server.P_BattleStatus[mo.battlen].emeraldpow = 0
				end
				

				-- spawn the emeralds:
				if evt.ftimer == 28
					mo.emeralds = {}
					mo.em_rotspeed = 1
					mo.em_ang = 0
					mo.em_dist = 1024

					for i = 1, 7
						mo.emeralds[i] = P_SpawnMobj(0, 0, 0, MT_EMERALD1+(i-1))
						mo.emeralds[i].scale = $*3/2
					end
				end

				if evt.ftimer >= 28
				and mo.emeralds and mo.emeralds[1] and mo.emeralds[1].valid


					local ang = mo.em_ang
					for i = 1, 7
						local x = mo.x + mo.em_dist*cos(ang)
						local y = mo.y + mo.em_dist*sin(ang)
						local z = mo.z + 32*cos(leveltime*ANG1*2 + (360/7)*ANG1*i)	-- funny z axis variation

						P_TeleportMove(mo.emeralds[i], x, y, z)
						ang = $ + (360/7)*ANG1
					end

					mo.em_ang = $+ mo.em_rotspeed*ANG1
					mo.em_rotspeed = min(32, $+1)
					mo.em_dist = max(64, $-24)
				end

				if evt.ftimer == 80
					for i = 1, 7 do
						P_RemoveMobj(mo.emeralds[i])
					end
					mo.emeralds = nil

					mo.state = S_PLAY_SUPER_TRANS1
					for k,v in ipairs(mo.allies)
						if v and v.control and v.control.valid
							P_FlashPal(v.control, 1, 8)
						end
					end
					S_StartSound(mo, sfx_s3k9f)
					mo.status_condition = COND_SUPER	-- direct affectation
					S_ChangeMusic("stg6d")
					CAM_stop(cam)
				end

				if evt.ftimer >= 80
					if mo.state == S_PLAY_SUPER_TRANS6
						mo.tics = -1
					end
					if evt.ftimer < 123
						summonAura(mo, SKINCOLOR_SUPERGOLD3)
					end
				end
				
				if evt.ftimer >= 123 and evt.ftimer < 150
					if leveltime & 1
						mo.flags2 = $ & ~MF2_DONTDRAW
						local g = P_SpawnGhostMobj(mo)
						g.frame = $|FF_FULLBRIGHT
						mo.flags2 = $|MF2_DONTDRAW
						g.fuse = 2
					end
				end
				
				if evt.ftimer == 150
					mo.flags2 = $|MF2_DONTDRAW
				end
				
				if evt.ftimer == 185
					return true
				end
			end
		},
	[8] = {"function",
			function(evt, btl)
				local mo = btl.superman
				local cam = server.P_BattleStatus[mo.battlen].cam
				if evt.ftimer == 1
					mo.sectorstuff = {}
					mo.lights = {}
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 5
							
							mo.destx = m.x + 300*cos(m.angle)
							mo.desty = m.y + 300*sin(m.angle)
							CAM_goto(cam, m.x, m.y, m.z)
							cam.angle = m.angle
							cam.aiming = 0
							CAM_angle(cam, cam.angle)
							CAM_aiming(cam, cam.aiming)
							break
						end
					end
					for s in sectors.iterate
						mo.sectorstuff[#mo.sectorstuff+1] = s
					end
				end
				
				if evt.ftimer == 140
					playSound(mo.battlen, sfx_zio4)
					playSound(mo.battlen, sfx_zio4)
					local part = P_SpawnMobj(mo.destx, mo.desty, cam.z + 40*FRACUNIT, MT_THOK)
					part.state = S_KNUXSPARK1
					part.scale = FRACUNIT/2
					part.destscale = FRACUNIT*2
					part.scalespeed = FRACUNIT/16
					part.color = SKINCOLOR_YELLOW
					part.fuse = 40
				end
				
				if evt.ftimer >= 140 and evt.ftimer < 180
					local l = P_SpawnMobj(mo.destx, mo.desty, cam.z + 20*FRACUNIT, MT_THOK)
					l.state = S_KSPK1
					l.tics = P_RandomRange(2, 10)
					l.flags = MF_NOCLIPHEIGHT|MF_NOCLIPTHING
					l.destscale = 1
					l.scale = FRACUNIT
					l.scalespeed = l.scale/24
					l.color = SKINCOLOR_YELLOW
					localquake(mo.battlen, 3*FRACUNIT, 1)
				end
				
				if evt.ftimer == 70 or evt.ftimer == 120
					
					P_LinedefExecute(1004)
					playSound(mo.battlen, sfx_zio3)
					localquake(mo.battlen, FRACUNIT*10, 5)
					local randx = 0
					local randy = 0
					if evt.ftimer == 70
						randx = mo.destx + -200*FRACUNIT
						randy = mo.desty + 400*FRACUNIT
					else
						randx = mo.destx + 200*FRACUNIT
						randy = mo.desty + 200*FRACUNIT
					end
					local z1 = P_SpawnMobj(randx, randy, cam.z - 400*FRACUNIT, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, FRACUNIT*4, SKINCOLOR_TEAL
					z1.destscale = FRACUNIT*3    -- this probably looks retarded at smaller scales from afar lmao
					-- second, the dominant in front
					local z2 = P_SpawnMobj(randx, randy, cam.z - 400*FRACUNIT, MT_DUMMY)
					z2.state, z2.scale, z2.color = S_LZIO21, FRACUNIT*4, SKINCOLOR_GOLD
					z2.destscale = FRACUNIT*3
				elseif evt.ftimer == 180
				
					localquake(mo.battlen, FRACUNIT*20, TICRATE)
					P_LinedefExecute(1004)
					playSound(mo.battlen, sfx_buff2)
					playSound(mo.battlen, sfx_zio3)
					
					P_TeleportMove(mo, mo.destx, mo.desty, cam.z)
					mo.renderflags = $|RF_FULLBRIGHT
					mo.flags2 = $ & ~MF2_DONTDRAW
					local x = mo.destx + 200*cos(cam.angle)
					local y = mo.desty + 200*sin(cam.angle)
					mo.avatar = P_SpawnMobj(x, y, mo.z - 100*FRACUNIT, MT_DUMMY)
					mo.avatar.skin = mo.skin
					mo.avatar.state = mo.state
					mo.avatar.sprite = mo.sprite
					mo.avatar.sprite2 = mo.sprite2
					mo.avatar.frame = mo.frame|FF_TRANS60
					mo.avatar.angle = mo.angle
					mo.avatar.scale = FRACUNIT*5
					mo.avatar.colorized = true
					mo.avatar.color = SKINCOLOR_SUPERRED5
					mo.avatar.tics = mo.tics
					mo.avatar.fuse = -1
					mo.avatar.renderflags = $|RF_FULLBRIGHT
					lightningblast(mo, SKINCOLOR_GOLD, FRACUNIT*3/2)
					lightningblast(mo.avatar, SKINCOLOR_GOLD, FRACUNIT*6)
					mo.demon = true
					mo.mistorbit = {}
					
					mo.buffs["atk"][1] = 75
					mo.buffs["mag"][1] = 75
					mo.buffs["agi"][1] = 75
					mo.buffs["def"][1] = 75
					mo.buffs["crit"][1] = 75
				end
				
				if mo.sectorstuff and #mo.sectorstuff
					for i = 1, #mo.sectorstuff
						if mo.sectorstuff[i]
							local sector = mo.sectorstuff[i]
							local light = sector.lightlevel
							
							if evt.ftimer == 1
								mo.lights[#mo.lights+1] = light
							end
							
							if evt.ftimer > 1
								if evt.ftimer < 180
									if light > 150
										sector.lightlevel = sector.lightlevel - 2
									end
								else
									if light > 190
										sector.lightlevel = sector.lightlevel - 2
									end
								end
							end
							
							if evt.ftimer == 70 and sector.tag == 46
								sector.ceilingheight = 3000*FRACUNIT
							end
							if evt.ftimer == 250 and sector.tag == 46
								sector.ceilingheight = -6000*FRACUNIT
							end
							
							if evt.ftimer == 70 or evt.ftimer == 120 or evt.ftimer == 180
								sector.lightlevel = mo.lights[i]
							end
						end
					end
				end
				
				if evt.ftimer == 280
					CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, btl.eggdude.x, btl.eggdude.y))
					mo.lightup = true
					boxflip = true
					mo.eggman = P_SpawnMobj(-8128*FRACUNIT, -4736*FRACUNIT, -1776*FRACUNIT, MT_DUMMY)
					mo.eggman.skin = btl.eggdude.skin
					mo.eggman.sprite = btl.eggdude.sprite
					mo.eggman.sprite2 = btl.eggdude.sprite2
					mo.eggman.frame = btl.eggdude.frame
					mo.eggman.fuse = -1
					mo.eggman.color = btl.eggdude.color
					mo.eggman.state = S_PLAY_STND
					mo.eggman.angle = btl.eggdude.angle
					mo.eggman.noidle = true
					return true
				end
			end
		},
	[9] = {"text", "Eggman", "Accursed echidna! This is no good! All platforms, engage defensive formation!", nil, nil, nil, {"H_EGG2", SKINCOLOR_RED}},
	[10] = {"function", //scene change but make it look like nothing teleported at all
			function(evt, btl)
				local mo = btl.superman
				local cam = btl.cam
				if evt.ftimer == 1
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 6

							P_TeleportMove(cam, m.x, m.y, cam.z) //keep everything about the camera the same
							break
						end
					end
					
					//dash the camera back to make it look like eggman's retreating (I HATE TRYING TO MOVE FOFS I HATE POLYOBJECTS GRAHHH)
					playSound(mo.battlen, sfx_s3k81)
					playSound(mo.battlen, sfx_s3k60)
					local x = mo.eggman.x + 2350*cos(ANG1*88)
					local y = mo.eggman.y + 2350*sin(ANG1*88)
					local x2 = mo.eggman.x + 2450*cos(ANG1*86)
					local y2 = mo.eggman.y + 2450*sin(ANG1*86)
					P_TeleportMove(mo, x, y, mo.z - 40*FRACUNIT)
					P_TeleportMove(mo.avatar, x2, y2, mo.avatar.z - 90*FRACUNIT)
					local cx = mo.eggman.x + 2600*cos(ANG1*90)
					local cy = mo.eggman.y + 2600*sin(ANG1*90)
					CAM_goto(cam, cx, cy, cam.z)
					mo.state = S_PLAY_STND
					mo.avatar.state = S_PLAY_STND
					
					//add platforms to table so you can move them to your hearts content
					mo.platformstuff = {}
					mo.stopplatform = {0, 0, 0, 0, 0, 0}
					mo.elecplatform = {59, 58, 57, 56, 43}
					mo.superfall = true
					for s in sectors.iterate
						for i = 0, 2 --why is it like this im crying
							if s.lines[i].tag >= 47 and s.lines[i].tag <= 52 
								mo.platformstuff[#mo.platformstuff+1] = s
							end
						end	
					end
				end
				if evt.ftimer >= 1
					cam.angle = R_PointToAngle2(cam.x, cam.y, mo.eggman.x, mo.eggman.y)
					mo.angle = R_PointToAngle2(mo.x, mo.y, mo.eggman.x, mo.eggman.y)
					mo.avatar.angle = R_PointToAngle2(mo.avatar.x, mo.avatar.y, mo.eggman.x, mo.eggman.y)
				end
				
				//move platforms
				if mo.platformstuff and #mo.platformstuff
					for i = 1, #mo.platformstuff
						if mo.platformstuff[i]
							local platform = mo.platformstuff[i]
							if evt.ftimer >= 50 + (i*10)
								//teleport them first
								if evt.ftimer == 50 + (i*10)
									if i%2 != 0
										platform.ceilingheight = 500*FRACUNIT
										platform.floorheight = 116*FRACUNIT
									end
								end
								if mo.stopplatform[i] == 0
									if i%2 == 0
										platform.ceilingheight = $+200*FRACUNIT
										platform.floorheight = $+200*FRACUNIT
									else
										platform.ceilingheight = $-200*FRACUNIT
										platform.floorheight = $-200*FRACUNIT
									end
								end
							end
							
							if evt.ftimer > 50 + (i*10)
								if i%2 == 0
									if mo.stopplatform[i] == 0
										if platform.ceilingheight >= -1500*FRACUNIT
											localquake(mo.battlen, FRACUNIT*10, 4)
											playSound(mo.battlen, sfx_doorc2)
											playSound(mo.battlen, sfx_pstop)
											mo.stopplatform[i] = 1
											if i == 6
												for mt in mapthings.iterate do	-- fetch awayviewmobj

													local m = mt.mobj
													if not m or not m.valid continue end

													if m and m.valid and m.type == MT_TELEPORTMAN
													and mt.extrainfo == i
														local e = BTL_spawnEnemy(btl.eggdude, "platform shield")
														e.flags = $|MF_NOGRAVITY
														P_TeleportMove(e, m.x, m.y, mo.eggman.z)
														for k,v in ipairs(btl.fighters)
															if not v.enemy
																table.insert(v.enemies, e)
															end
														end
													end
												end
											end
										end
									end
								else
									if mo.stopplatform[i] == 0
										if platform.ceilingheight <= -1500*FRACUNIT
											localquake(mo.battlen, FRACUNIT*10, 4)
											playSound(mo.battlen, sfx_doorc2)
											playSound(mo.battlen, sfx_pstop)
											mo.stopplatform[i] = 1
										end
									end
								end
							end
						end
					end
				end
				
				//adjust camera angle and connect platforms with cool electric thingies
				if evt.ftimer == 140
					local cx = mo.eggman.x + 2600*cos(ANG1*105)
					local cy = mo.eggman.y + 2600*sin(ANG1*105)
					CAM_goto(cam, cx, cy, cam.z)
				end
				
				if evt.ftimer == 170
					for s in sectors.iterate
						if s.tag == 55
							s.ceilingheight = $+2000*FRACUNIT
							s.floorheight = $+2000*FRACUNIT
						end
					end
					for k,v in ipairs(btl.fighters)
						if v and v.control and v.control.valid
							P_FlashPal(v.control, 1, 5) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
					end
					playSound(mo.battlen, sfx_s3k9f)
					playSound(mo.battlen, sfx_hamas2)
					table.insert(btl.turnorder, 1, mo)
				end
				
				if evt.ftimer == 230
					//bring back hud temporarily
					for p in players.iterate do
						if p and p.control and p.control.valid and p.control.battlen == mo.battlen
							COM_BufInsertText(p, "hu_partystatus on")
						end
					end
					mo.skills = {"god hand", "pralaya", "thunder reign", "final judgement"}
					mo.defaultcoords = {mo.x, mo.y, mo.z}
					btl.emeraldpow = 100
					btl.emeraldpow_max = 7
					local stats = {"strength", "magic", "endurance", "agility", "luck"}
					for i = 1, #stats do
						mo[stats[i]] = 9999
					end
					mo.commandflags = $|CDENY_TACTICS|CDENY_ITEM|CDENY_PERSONA|CDENY_TACTICS|CDENY_GUARD
					for k,v in ipairs(btl.superman.enemies)
						if v.enemy == "b_eggman"
							table.remove(btl.superman.enemies, k)
						end
					end
					mo.angle = R_PointToAngle2(mo.x, mo.y, mo.eggman.x, mo.eggman.y)
					return true
				end
			end
		},
}

//for knuckles super cinematic
enemyList["platform shield"] = {
		name = "Platform shield",
		skillchance = 100,	-- /100, probability of using a skill
		level = 60,
		hp = 1,
		sp = 1,
		strength = 1,
		magic = 1,
		endurance = 1,
		luck = 1,
		agility = 1,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_STRIKE|ATK_PIERCE|ATK_ELEC,

		anim_stand = 		{SPR_NULL, A, 4},
		
		skills = {},
		deathanim = function(mo)
						mo.deathtimer = $ and $+1 or 1
						local btl = server.P_BattleStatus[mo.battlen]
						local superman = btl.superman
						local cam = btl.cam
						mo.momz = 0
						if mo.deathtimer == 2
							mo.spark = {}
							localquake(mo.battlen, 20*FRACUNIT, 5)
							playSound(mo.battlen, sfx_bkpoof)
							playSound(mo.battlen, sfx_bgxpld)
							playSound(mo.battlen, sfx_bkpoof)
							playSound(mo.battlen, sfx_bgxpld)
							for j = 1, 60
								local st = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
								if j%2 == 0
									st.state = S_MEGITHOK
								else
									st.state = S_BRICKDEBRIS
								end
								st.flags = $ & ~MF_NOGRAVITY
								st.momx = P_RandomRange(-128, 128)*FRACUNIT
								st.momy = P_RandomRange(-128, 128)*FRACUNIT
								st.momz = P_RandomRange(-128, 128)*FRACUNIT
								st.fuse = 20
								st.scale = FRACUNIT*3/2
							end
							for i = 1, 16
								local ol = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
								ol.state = S_SSPK3
								ol.scale = FRACUNIT*3
								ol.frame = A|FF_FULLBRIGHT
								ol.tics = -1
								ol.angle = P_RandomRange(0, 359)*ANG1

								ol.momx = P_RandomRange(-200, 200)*FRACUNIT
								ol.momy = P_RandomRange(-25, 25)*FRACUNIT
								ol.momz = P_RandomRange(-50, 50)*FRACUNIT
								mo.spark[#mo.spark+1] = ol
							end
						end
						//kill platform
						if superman.platformstuff and #superman.platformstuff
							local platform = superman.platformstuff[#superman.platformstuff]
							if mo.deathtimer == 2
								platform.ceilingheight = -6000*FRACUNIT
								platform.floorheight = -6000*FRACUNIT
								table.remove(superman.platformstuff, #superman.platformstuff)
							end
						end
						for s in sectors.iterate
							for i = 0, 2
								if s.lines[i].tag == superman.elecplatform[#superman.elecplatform]
									s.ceilingheight = -6000*FRACUNIT
									s.floorheight = -6000*FRACUNIT
								end
							end
						end
						if mo.spark and #mo.spark
							-- slow all of these down
							for i = 1, #mo.spark do
								local f = mo.spark[i]
								if not f or not f.valid continue end
								if mo.deathtimer < 60
									f.momx = $*90/100
									f.momy = $*90/100
									f.momz = $*90/100
								end
								if mo.deathtimer == 60
									f.destscale = FRACUNIT/5
									f.scalespeed = $/2
									f.tics = 15
									f.momx = (superman.x - f.x)/15
									f.momy = (superman.y - f.y)/15
									f.momz = (superman.z - f.z)/15
								end
							end
						end
						if mo.deathtimer == 75
							localquake(mo.battlen, FRACUNIT*10, 5)
							playSound(mo.battlen, sfx_hamas2)
							playSound(mo.battlen, sfx_buff)
							playSound(mo.battlen, sfx_bufu6)
							btl.emeraldpow = 100 + (6-#superman.platformstuff)*100
							local g = P_SpawnGhostMobj(mo)
							g.colorized = true
							g.destscale = superman.scale*4
							g.scalespeed = superman.scale/8
							local g = P_SpawnGhostMobj(mo)
							g.color = SKINCOLOR_EMERALD
							g.colorized = true
							g.destscale = FRACUNIT*4
							g.frame = $|FF_FULLBRIGHT
							local thok = P_SpawnMobj(superman.x, superman.y, superman.z+5*FRACUNIT, MT_DUMMY)
							thok.state = S_INVISIBLE
							thok.tics = 1
							thok.scale = FRACUNIT*4
							A_OldRingExplode(thok, MT_SUPERSPARK)
						end
						
						if mo.deathtimer == 125
							playSound(mo.battlen, sfx_aoaask)
							for mt in mapthings.iterate do	-- fetch awayviewmobj

								local m = mt.mobj
								if not m or not m.valid continue end

								if m and m.valid and m.type == MT_TELEPORTMAN
								and mt.extrainfo == #superman.platformstuff
								
									local e = BTL_spawnEnemy(btl.eggdude, "platform shield")
									e.flags = $|MF_NOGRAVITY
									P_TeleportMove(e, m.x, m.y, btl.eggdude.z)
									for k,v in ipairs(btl.fighters)
										if not v.enemy
											table.insert(v.enemies, e)
										end
									end
									
								end
							end
							superman.destx = superman.x + 320*cos(ANG1*270)
							superman.desty = superman.y + 320*sin(ANG1*270)
						end
						
						if mo.deathtimer >= 125
							superman.momx = (superman.destx - superman.x)/10
							superman.momy = (superman.desty - superman.y)/10
							superman.avatar.momx = superman.momx
							superman.avatar.momy = superman.momy
							cam.momx = superman.momx
							cam.momy = superman.momy
						end
						
						if mo.deathtimer == 180
							//no platforms? *megamind face*
							if not #superman.platformstuff
								superman.skills = {"final judgement"}
								P_TeleportMove(btl.eggdude, superman.eggman.x, superman.eggman.y, superman.eggman.z)
								btl.eggdude.defaultcoords = {superman.eggman.x, superman.eggman.y, superman.eggman.z}
								P_RemoveMobj(superman.eggman)
								superman.commandflags = $|CDENY_ATTACK
								for k,v in ipairs(btl.fighters)
									if not v.enemy
										table.insert(v.enemies, btl.eggdude)
									end
								end
							end
							superman.defaultcoords = {superman.x, superman.y, superman.z}
							superman.setonemore = 0
							table.insert(btl.turnorder, 1, superman)
							for k,v in ipairs(btl.turnorder)
								if v.enemy and v.enemy == "b_eggman"
									table.remove(btl.turnorder, k)
								end
							end
							table.remove(superman.elecplatform, #superman.elecplatform)
							mo.deathanim = nil
							return
						end
					end,
					
		thinker = function(mo)
						return attackDefs["guard"], {mo}
					end,
	}

//always make it the super players turn for knux
addHook("MobjThinker", function(mo)
	if gamemap != 12 return end
	if mo.cutscene return end
	local btl = server.P_BattleStatus[mo.battlen]
	if btl.battlestate != 0
		if mo and mo.valid
			if mo == btl.superman and mo.skin == "knuckles"
				btl.turnorder[1] = mo
			end
		end
	end
end, MT_PFIGHTER)
	
attackDefs["final judgement"] = {
		name = "Final Judgement",
		type = ATK_STRIKE,
		power = 9999,
		accuracy = 999,
		costtype = CST_EP,
		cost = 7,
		desc = "Unleash the power of all 7 Chaos\nEmeralds and deal astronomical Strike damage\nto one enemy. Guaranteed critical rate.",
		target = TGT_ENEMY,
		critical = 999,
		hudfunc = 	function(v, mo, timer)

						//fade to black when knux grabs eggman
						local bruh = v.cachePatch("H_BRUH")
						local hi = V_90TRANS
						if timer >= 430 and timer <= 433
							hi = V_90TRANS
						elseif timer > 433 and timer <= 436
							hi = V_80TRANS
						elseif timer > 436 and timer <= 439
							hi = V_70TRANS
						elseif timer > 439 and timer <= 442
							hi = V_60TRANS
						elseif timer > 442 and timer <= 445
							hi = V_50TRANS
						elseif timer > 445 and timer <= 448
							hi = V_40TRANS
						elseif timer > 448 and timer <= 451
							hi = V_30TRANS
						elseif timer > 451 and timer <= 454
							hi = V_20TRANS
						elseif timer > 454 and timer <= 457
							hi = V_10TRANS
						elseif timer > 457
							hi = V_SNAPTOTOP
						end
						if timer >= 430 and timer < 480
							v.drawScaled(0, 0, FRACUNIT*5, bruh, V_SNAPTOTOP|V_SNAPTOLEFT|hi)
						end
						
						//fade to black again
						if timer >= 830
							local bruh = v.cachePatch("H_BRUH")
							local hi = V_90TRANS
							if timer >= 830 and timer <= 833
								hi = V_90TRANS
							elseif timer > 833 and timer <= 836
								hi = V_80TRANS
							elseif timer > 836 and timer <= 839
								hi = V_70TRANS
							elseif timer > 839 and timer <= 842
								hi = V_60TRANS
							elseif timer > 842 and timer <= 845
								hi = V_50TRANS
							elseif timer > 845 and timer <= 848
								hi = V_40TRANS
							elseif timer > 848 and timer <= 851
								hi = V_30TRANS
							elseif timer > 851 and timer <= 854
								hi = V_20TRANS
							elseif timer > 854 and timer <= 857
								hi = V_10TRANS
							elseif timer > 857
								hi = V_SNAPTOTOP
							end
							if timer >= 830 and timer < 890
								v.drawScaled(0, 0, FRACUNIT*5, bruh, V_SNAPTOTOP|V_SNAPTOLEFT|hi)
							end
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local btl = server.P_BattleStatus[mo.battlen]
			local cam = btl.cam
			local target = hittargets[1]
			if timer == 1
			
				mo.superfall = false
				mo.state = S_PLAY_SUPER_TRANS3
				mo.tics = -1
				mo.frame = C
				mo.rotate = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
				playSound(mo.battlen, sfx_bufu1)
				localquake(mo.battlen, 10*FRACUNIT, 10)
				P_RemoveMobj(mo.avatar)
				for p in players.iterate do
					if p and p.control and p.control.valid and p.control.battlen == mo.battlen
						S_FadeOutStopMusic(MUSICRATE, p)
						COM_BufInsertText(p, "hu_partystatus off")
					end
				end
				CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, mo.x, mo.y))
			end
			if timer >= 1 and timer < 260
				mo.momz = (target.z - mo.z)/20
			end
			if timer == 50
				playSound(mo.battlen, sfx_debuff)
			end
			if timer >= 50 and timer < 165
				if leveltime%2 == 0
					for i = 1,2
						local energy = P_SpawnMobj(mo.x-P_RandomRange(140,-140)*FRACUNIT, mo.y-P_RandomRange(140,-140)*FRACUNIT, mo.z-P_RandomRange(140,-140)*FRACUNIT, MT_SUPERSPARK)
						energy.scale = FRACUNIT/2
						energy.tics = 15
						energy.momx = (mo.x - energy.x)/15
						energy.momy = (mo.y - energy.y)/15
						energy.momz = (mo.z - energy.z)/15
					end
				end
				
				//rotate camera around player
				local dist = R_PointToDist2(cam.x, cam.y, mo.x, mo.y)/FRACUNIT
				local x = mo.x - dist*cos(mo.rotate)
				local y = mo.y - dist*sin(mo.rotate)
				local tgtx = mo.x - 150*cos(mo.rotate)
				local tgty = mo.y - 150*sin(mo.rotate)
				cam.momx = (tgtx - cam.x)/100
				cam.momy = (tgty - cam.y)/100
				cam.momz = (mo.z - cam.z)/100
				mo.rotate = $ + ANG1*3
				cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
				P_TeleportMove(cam, x, y, cam.z)
			elseif timer >= 165 and timer < 260
				cam.momx = 0
				cam.momy = 0
				cam.momz = 0
				cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
			end
			
			if timer == 170 or timer == 190 or timer == 206 or timer == 216 or timer == 226 or timer == 230 or timer == 234 or timer == 236 or timer == 238 or timer == 240 or timer >= 242 and timer < 260
				playSound(mo.battlen, sfx_hamas1) -- i hope this doesn't hurt anyone's ears
				local thok = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
				thok.state = S_INVISIBLE
				thok.tics = 1
				thok.scale = FRACUNIT*2
				A_OldRingExplode(thok, MT_SUPERSPARK)
				localquake(mo.battlen, 10*FRACUNIT, 5)
			end
			
			if timer == 260
				playSound(mo.battlen, sfx_megi5)
				playSound(mo.battlen, sfx_buff)
				playSound(mo.battlen, sfx_buff2)
				playSound(mo.battlen, sfx_s3k59)
				BTL_logMessage(targets[1].battlen, "Physical Attack maxed out!")
				mo.tics = -1
				mo.frame = G
				localquake(mo.battlen, 25*FRACUNIT, 30)
				
				local cx = cam.x - 300*cos(cam.angle)
				local cy = cam.y - 300*sin(cam.angle)
				CAM_goto(cam, cx, cy, cam.z + 75*FRACUNIT)
				P_LinedefExecute(1005)
				
				target.anim = nil
				target.state = S_PLAY_FLY_TIRED
				target.defeated = true //shake him up a bit
			end
			
			if timer >= 260 and timer < 320
				if leveltime%2 == 0
					local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height, MT_DUMMY)
					elec.sprite = SPR_DELK
					elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
					elec.destscale = FRACUNIT*6
					elec.scalespeed = FRACUNIT/4
					elec.tics = TICRATE/16
					elec.color = SKINCOLOR_CRIMSON
				end
				if leveltime%4 == 0
					local g = P_SpawnGhostMobj(mo)
					g.color = SKINCOLOR_RED
					g.colorized = true
					g.destscale = FRACUNIT*6
					g.frame = $|FF_FULLBRIGHT
					for i = 1,16
						local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_RED
						dust.scale = FRACUNIT*3
						dust.frame = $|FF_FULLBRIGHT
						dust.renderflags = $|RF_NOCOLORMAPS
					end
				end
			end
			if timer == 350
				local an = target.angle + 45*ANG1
				local cx = target.x + 300*cos(an)
				local cy = target.y + 300*sin(an)
				CAM_goto(cam, cx, cy, cam.z - 40*FRACUNIT, 70*FRACUNIT)
				CAM_angle(cam, R_PointToAngle2(cx, cy, target.x, target.y), ANG1*4)
			end
			if timer == 360
				mo.state = S_PLAY_WALK
				mo.tics = -1
				mo.frame = A
				mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
				mo.savemomx = (target.x - mo.x)/60
				mo.savemomy = (target.y - mo.y)/60
				playSound(mo.battlen, sfx_belnch)
			end
			if timer >= 360 and timer < 418
				local g = P_SpawnGhostMobj(mo)
				g.color = SKINCOLOR_COBALT
				g.colorized = true
				g.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
				mo.momx = mo.savemomx
				mo.momy = mo.savemomy
			end
			if timer == 418
				playSound(mo.battlen, sfx_s3k4a)
				mo.momx = 0
				mo.momy = 0
				localquake(mo.battlen, 6*FRACUNIT, 8)
			end
			
			//teleport cam
			if timer == 460
				for mt in mapthings.iterate do	-- fetch awayviewmobj

					local m = mt.mobj
					if not m or not m.valid continue end

					if m and m.valid and m.type == MT_TELEPORTMAN
					and mt.extrainfo == 7
					
						P_TeleportMove(cam, m.x, m.y, m.z)
						cam.angle = ANG1*90
						cam.aiming = m.aiming
						CAM_stop(cam)
					end
				end
			end
			
			//MURDER
			if timer >= 480 and timer < 620
				if timer < 550
					if leveltime%2 == 0
						playSound(mo.battlen, sfx_hit1)
						playSound(mo.battlen, sfx_pstop)
						localquake(mo.battlen, 20*FRACUNIT, 2)
						local b = P_SpawnMobj(P_RandomRange(-11000, -10000)*FRACUNIT, P_RandomRange(-4500, -5100)*FRACUNIT, cam.z + P_RandomRange(200, -200)*FRACUNIT, MT_DUMMY)
						b.state = S_HURTC1
						b.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
						b.scale = FRACUNIT*P_RandomRange(1, 4)
					end
				else
					for i = 1, 2
						playSound(mo.battlen, sfx_hit1)
						playSound(mo.battlen, sfx_pstop)
						localquake(mo.battlen, 20*FRACUNIT, 2)
						local b = P_SpawnMobj(P_RandomRange(-11000, -10000)*FRACUNIT, P_RandomRange(-4500, -5100)*FRACUNIT, cam.z + P_RandomRange(200, -200)*FRACUNIT, MT_DUMMY)
						b.state = S_HURTC1
						b.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
						b.scale = FRACUNIT*P_RandomRange(2, 6)
					end
				end
			end
			
			if timer == 622
				playSound(mo.battlen, sfx_phys)
				playSound(mo.battlen, sfx_phys)
			end
			
			//this is the best idea ive ever had
			if timer == 680
				target.defeated = false
				target.flags2 = $ & ~MF2_DONTDRAW
				P_TeleportMove(cam, cam.x, cam.y, -3880*FRACUNIT)
				P_LinedefExecute(1006)
				for mt in mapthings.iterate do	-- fetch awayviewmobj
					local m = mt.mobj
					if not m or not m.valid continue end
					if m and m.valid and m.type == MT_TELEPORTMAN
					and mt.extrainfo == 8
						P_TeleportMove(target, m.x, m.y, m.z)
					end
				end
				playSound(mo.battlen, sfx_light)
				playSound(mo.battlen, sfx_light)
				ANIM_set(target, target.anim_downloop, true)
				target.scale = FRACUNIT*3/2
				target.shadowscale = 0
				target.flags = $|MF_NOGRAVITY
			end
			
			if timer == 750
				local b = P_SpawnMobj(target.x, target.y, target.z + 100*FRACUNIT, MT_DUMMY)
				b.sprite = SPR_KILL
				b.tics = -1
				b.frame = $|FF_FULLBRIGHT
				b.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
				b.scale = FRACUNIT*3
				local g = P_SpawnGhostMobj(b)
				g.scale = b.scale
				g.destscale = FRACUNIT*8
				g.frame = $|FF_FULLBRIGHT
				g.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
				playSound(mo.battlen, sfx_perish)
				playSound(mo.battlen, sfx_perish)
				playSound(mo.battlen, sfx_perish)
				playSound(mo.battlen, sfx_perish)
			end
			
			if timer == 860
				cam.angle = $ + ANG1*180 //hard to explain but just trust me on this
			end
			
			if timer == 890
				//remove stuff
				for s in sectors.iterate
					if s.tag == 32
						s.floorheight = -6000*FRACUNIT
						s.ceilingheight = -6000*FRACUNIT
					end
				end
				for k,v in ipairs(btl.fighters)
					if v.enemy != "b_eggman" and v != mo
						P_TeleportMove(v, -8130*FRACUNIT, 1730*FRACUNIT, -1900*FRACUNIT)
					end
				end
				table.insert(btl.turnorder, 1, mo)
				for s in sectors.iterate
					if s.tag == 33 or s.tag == 60
						s.ceilingheight = -6000*FRACUNIT
						s.floorheight = -6000*FRACUNIT
					end
				end
				D_startEvent(mo.battlen, "ev_stage6_knuckles_win")
				return true
			end
		end,
}

//results screen event for knuckles after final judgement move
eventList["ev_stage6_knuckles_win"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"function",
			function(evt, btl)
				local mo = btl.superman
				local cam = btl.cam
				local y = 2500*FRACUNIT
				if evt.ftimer == 1
					P_TeleportMove(mo, -4160*FRACUNIT, 600*FRACUNIT, -1000*FRACUNIT)
					mo.momz = -60*FRACUNIT
					mo.anim = nil
					mo.state = S_PLAY_GLIDE
					mo.flags = $|MF_NOGRAVITY
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 2

							local cam = btl.cam
							P_TeleportMove(cam, m.x, m.y, m.z)
							cam.angle = m.angle
							cam.aiming = -ANG1*2
							CAM_goto(cam, cam.x, cam.y, cam.z)
							CAM_angle(cam, cam.angle)
							CAM_aiming(cam, cam.aiming)
							break
						end
					end
					//spawn stage clear sign
					mo.sign = P_SpawnMobj(-3904*FRACUNIT, 1856*FRACUNIT, cam.floorz, MT_SIGN)
					mo.sign.spin = false
					mo.sign.angle = ANG1*90
				end
				mo.momy = (y - mo.y)/55
				mo.angle = ANG1*90
				if evt.ftimer < 38
					mo.momz = $+2*FRACUNIT
					P_SpawnGhostMobj(mo)
				end
				if evt.ftimer == 38
					playSound(mo.battlen, sfx_poof)
					mo.status_condition = COND_NORMAL
					mo.color = SKINCOLOR_RED
					mo.flags = $ & ~MF_NOGRAVITY
					mo.state = S_PLAY_FALL //S_PLAY_JUMP?
					local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT
					A_OldRingExplode(thok, MT_SUPERSPARK)
					mo.demon = false
				end
				if mo.sign and mo.sign.valid and mo.y >= mo.sign.y and not mo.sign.spin and evt.ftimer < 180
					playSound(mo.battlen, sfx_lvpass)
					mo.sign.spin = true
				end
				if mo.sign.spin
					if leveltime%3 == 0
						A_SignPlayer(mo.sign, P_RandomRange(0, 3))
					end
					mo.sign.angle = $ + 40*ANG1
				end
				if evt.ftimer >= 90 and evt.ftimer < 180
					local cx = mo.sign.x + 200*cos(ANG1*90)
					local cy = mo.sign.y + 200*sin(ANG1*90)
					CAM_goto(cam, cx, cy, mo.sign.z + 25*FRACUNIT)
				end
				if evt.ftimer == 120
					S_ChangeMusic("fclear")
				end
				if evt.ftimer == 180
					mo.sign.spin = false
					local cx = mo.sign.x + 100*cos(ANG1*90)
					local cy = mo.sign.y + 100*sin(ANG1*90)
					P_TeleportMove(cam, cx, cy, cam.z)
					CAM_stop(cam)
					localquake(mo.battlen, FRACUNIT*10, 4)
					A_SignPlayer(mo.sign, 2)
					mo.sign.angle = 90*ANG1
					playSound(mo.battlen, sfx_nxbump) //louds
					playSound(mo.battlen, sfx_nxbump)
					local thok = P_SpawnMobj(mo.sign.x, mo.sign.y, mo.sign.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT
					A_OldRingExplode(thok, MT_NIGHTSPARKLE)
				end
				if evt.ftimer == 220
					stagecleared = true
				end
			end
		},
}

//super amy finisher cutscene, thank god this isn't as long as the knuckles one
eventList["ev_stage6_eggman_dies_a"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"function",
			function(evt, btl) 
				boxflip = true
				return true
			end
		},
	[2] = {"text", "Eggman", "!!!", nil, nil, nil, {"H_EGG2", SKINCOLOR_RED}},
	[3] = {"function",
			function(evt, btl) 
				if evt.ftimer == 1
					local x = -3904*FRACUNIT
					local y = -576*FRACUNIT
					local z = -1776*FRACUNIT
					//zoom back out
					if evt.ftimer == 1
						local tgtx = x + 700*cos(ANG1*90)
						local tgty = y + 700*sin(ANG1*90)
						local cam = btl.cam
						cam.angle = ANG1*270
						CAM_goto(cam, tgtx, tgty, -1700*FRACUNIT)
						CAM_angle(cam, cam.angle)
						CAM_aiming(cam, cam.aiming)
					end
				end
				if evt.ftimer == 35
					P_LinedefExecute(1002)
					for s in sectors.iterate
						if s.tag == 53 or s.tag == 54
							for i = 0, 2 --why is it like this im crying
								if s.lines[i].tag == 16
									s.ceilingheight = -6000*FRACUNIT
									s.floorheight = -6000*FRACUNIT
								end
							end
						end
					end
					S_StartSound(nil, sfx_kc65)
					S_StartSound(nil, sfx_status)
					local platformtags = {31, 30, 29, 28, 8, 9, 10}
					for s in sectors.iterate
						if s.tag == 53 or s.tag == 54 or s.tag == 41 or s.tag == 42
							for i = 0, 2 --why is it like this im crying
								if s.lines[i].tag != 16
									s.ceilingheight = 0
									s.floorheight = 0
								end
							end
						end
						if s.tag == platformtags[btl.lockplatform]
							for i = 0, 3
								s.lines[i].frontside.midtexture = 0
								s.lines[i].backside.midtexture = 0
							end
						end
					end
					//remove eggman hyper cannon if it exists
					if btl.eggdude.energypoint and btl.eggdude.energypoint.valid
						P_RemoveMobj(btl.eggdude.energypoint)
					end
					btl.eggdude.cannoncharge = false
					btl.eggdude.cannonprepare = false
					//remove emerald link objects
					for m in mobjs.iterate() do
						if m and m.valid and m.type == MT_DUMMY
							if m.emeraldlink
								P_RemoveMobj(m)
							end
						end
					end
					//remove warning thoks
					if btl.eggdude.warning and #btl.eggdude.warning
						for i = 1, #btl.eggdude.warning
							if btl.eggdude.warning[i] and btl.eggdude.warning[i].valid
								P_RemoveMobj(btl.eggdude.warning[i])
							end
						end
					end
				end
				if evt.ftimer == 70
					return true
				end
			end
		},
	[4] = {"function",
			function(evt, btl) 
				boxflip = false
				return true
			end
		},
	[5] = {"text", "Amy", "Oooh! Do I see a helpless Eggman out in the open?", nil, nil, nil, {"H_AMY2", SKINCOLOR_ROSY}},
	[6] = {"text", "Amy", "I'll be using these Chaos Emeralds, don't mind if I do!", nil, nil, nil, {"H_AMY2", SKINCOLOR_ROSY}},
	[7] = {"function", //super transformation (basically taken from the base code super transformation but a little different)
			function(evt, btl)
				local mo = btl.superman
				//dont listen to the tails anim im going back to ticrate cause this is taken directly from sonics anim
				if evt.ftimer >= TICRATE*2/3 + 10
					mo.momz = $*90/100
				elseif evt.ftimer >= 1
					mo.momz = FRACUNIT
					mo.flags = $|MF_NOGRAVITY	-- lol
				end

				if evt.ftimer == 1

					local cx = mo.x + 256*cos(mo.angle/* + ANG1*20*/)
					local cy = mo.y + 256*sin(mo.angle/* + ANG1*20*/)
					CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, mo.z + FRACUNIT*30, 70*FRACUNIT)
					CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, mo.x, mo.y))

					mo.anim = nil	-- kind of a hack
					mo.state = S_PLAY_FALL
				end

				-- spawn the emeralds:
				if evt.ftimer == TICRATE/2 + 10
					mo.emeralds = {}
					mo.em_rotspeed = 1
					mo.em_ang = 0
					mo.em_dist = 1024

					for i = 1, 7
						mo.emeralds[i] = P_SpawnMobj(0, 0, 0, MT_EMERALD1+(i-1))
						mo.emeralds[i].scale = $*3/2
					end
				end

				if evt.ftimer >= TICRATE/2 + 10
				and mo.emeralds and mo.emeralds[1] and mo.emeralds[1].valid


					local ang = mo.em_ang
					for i = 1, 7
						local x = mo.x + mo.em_dist*cos(ang)
						local y = mo.y + mo.em_dist*sin(ang)
						local z = mo.z + 32*cos(leveltime*ANG1*2 + (360/7)*ANG1*i)	-- funny z axis variation

						P_TeleportMove(mo.emeralds[i], x, y, z)
						ang = $ + (360/7)*ANG1
					end

					mo.em_ang = $+ mo.em_rotspeed*ANG1
					mo.em_rotspeed = min(32, $+1)
					mo.em_dist = max(64, $-24)
				end

				/*if evt.ftimer == TICRATE*2 + 10
					for i = 1, 7 do
						P_RemoveMobj(mo.emeralds[i])
					end
					mo.emeralds = nil

					mo.state = S_PLAY_SUPER_TRANS1
					for k,v in ipairs(mo.allies)
						if v and v.control and v.control.valid
							P_FlashPal(v.control, 1, 8)
						end
					end
					S_StartSound(mo, sfx_s3k9f)
					mo.status_condition = COND_SUPER	-- direct affectation
				end*/

				/*if evt.ftimer >= TICRATE*2 + 10
					if mo.state == S_PLAY_SUPER_TRANS6
						mo.tics = -1
					end
					if evt.ftimer < (TICRATE*3 + TICRATE/2)
						summonAura(mo, SKINCOLOR_SUPERGOLD3)
					end
				end*/

				if evt.ftimer == TICRATE*2 + 10
					mo.momz = -4*FRACUNIT
					mo.state = S_PLAY_FALL
				end
				if evt.ftimer == TICRATE*2 + 20
					playSound(mo.battlen, sfx_s3k81)
					playSound(mo.battlen, sfx_boost1)
					mo.momz = 60*FRACUNIT
					mo.state = S_PLAY_SPRING
					S_ChangeMusic("stg6d")
					localquake(mo.battlen, 20*FRACUNIT, 5)
					for i = 1,16
						local dust = P_SpawnMobj(mo.x, mo.y, mo.floorz + 10*FRACUNIT, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.scale = FRACUNIT
						dust.destscale = FRACUNIT*10
						dust.state = S_AOADUST1
						dust.frame = A|FF_FULLBRIGHT
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					end
				end
				if evt.ftimer >= TICRATE*2 + 20
					P_SpawnGhostMobj(mo)
				end
				if evt.ftimer >= TICRATE*2 + 60
					return true
				end
			end
		},
	[8] = {"function", //MAGICAL GIRL SCENE
			function(evt, btl)
				local mo = btl.superman
				local cam = btl.cam
				//change camera
				if evt.ftimer == 1
					flying = true
					P_TeleportMove(mo, -1632*FRACUNIT, -3936*FRACUNIT, -1300*FRACUNIT)
					mo.momz = 4*FRACUNIT
					mo.angle = ANG1*180
					
					//camera
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 7
						
							P_TeleportMove(cam, m.x, m.y, m.z)
							cam.angle = m.angle
							cam.aiming = 0
							CAM_stop(cam)
							break
						end
					end
				end
				
				//rotating emeralds
				if mo.emeralds and mo.emeralds[1] and mo.emeralds[1].valid

					if evt.ftimer < 100
						local ang = mo.em_ang
						for i = 1, 7
							local x = mo.x + mo.em_dist*cos(ang)
							local y = mo.y + mo.em_dist*sin(ang)
							local z = mo.z + 32*cos(leveltime*ANG1*2 + (360/7)*ANG1*i)	-- funny z axis variation

							P_TeleportMove(mo.emeralds[i], x, y, z)
							ang = $ + (360/7)*ANG1
							mo.emeralds[i].scale = FRACUNIT
						end

						mo.em_ang = $+ mo.em_rotspeed*ANG1
						mo.em_rotspeed = min(20, $+1)
						mo.em_dist = max(64, $-24)
						mo.em_distz = 32
					else
						if mo.hammer and mo.hammer.valid
							local ang = mo.em_ang
							for i = 1, 7
								local x = mo.hammer.x + mo.em_dist*cos(ang)
								local y = mo.hammer.y + mo.em_dist*sin(ang)
								local z = mo.hammer.z + mo.em_distz*cos(leveltime*ANG1*2 + (360/7)*ANG1*i)

								
								ang = $ + (360/7)*ANG1
								if evt.ftimer == 100
									mo.emeralds[i].destscale = FRACUNIT*2
								end
								if evt.ftimer == 160
									mo.emeralds[i].destscale = 1
									mo.emeralds[i].scalespeed = FRACUNIT/32
								end
								if evt.ftimer >= 160
									P_SpawnGhostMobj(mo.emeralds[i])
									P_TeleportMove(mo.emeralds[i], x, y, z+15*FRACUNIT)
								else
									P_TeleportMove(mo.emeralds[i], x, y, z)
								end
							end

							mo.em_ang = $+ mo.em_rotspeed*ANG1
							mo.em_rotspeed = min(20, $+1)
							if evt.ftimer < 160
								mo.em_dist = max(64, $-24)
							else
								mo.em_dist = max(0, $-2)
								mo.em_distz = max(0, $-1)
							end
						end
					end
				end
				
				if evt.ftimer >= 1
					if evt.ftimer < 410
						mo.angle = $+ANG1*25
					end
					for i = 1, 2
						local thok = P_SpawnMobj(mo.x+P_RandomRange(-50, 700)*FRACUNIT, mo.y+P_RandomRange(-450, 450)*FRACUNIT, mo.z+P_RandomRange(-200, -500)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_LHRT
						thok.frame = A|FF_FULLBRIGHT
						thok.momz = P_RandomRange(6, 30)*FRACUNIT
						thok.scale = FRACUNIT*P_RandomRange(1/2,2)
						thok.tics = 200
					end
				end
				
				if mo.z >= -1065*FRACUNIT and evt.ftimer < 100
					mo.momz = 0
				end
				
				if evt.ftimer == 100
					mo.hammer = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
					mo.hammer.sprite = SPR_HAMR
					mo.hammer.frame = A|FF_FULLBRIGHT
					mo.hammer.scale = FRACUNIT/4
					mo.hammer.destscale = FRACUNIT*2
					mo.hammer.tics = -1
					mo.hammer.angspeed = 30
					mo.momz = -16*FRACUNIT
					mo.state = S_PLAY_SUPER_TRANS3
					mo.frame = G
					mo.tics = -1
					playSound(mo.battlen, sfx_thok)
					playSound(mo.battlen, sfx_s3k81)
					local cx = cam.x - 120*cos(cam.angle)
					local cy = cam.y - 120*sin(cam.angle)
					CAM_goto(cam, cx, cy, cam.z)
				end
				
				if evt.ftimer == 160
					playSound(mo.battlen, sfx_bufu1)
				end
				
				if evt.ftimer == 190
					playSound(mo.battlen, sfx_buff)
					playSound(mo.battlen, sfx_hamas2)
					playSound(mo.battlen, sfx_s3k9f)
					mo.hammer.cool = true
					local thok = P_SpawnMobj(mo.hammer.x, mo.hammer.y, mo.hammer.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT
					A_OldRingExplode(thok, MT_SUPERSPARK)
				end
				
				if mo.hammer and mo.hammer.valid
					local hammer = mo.hammer
					local g = P_SpawnGhostMobj(hammer)
					g.momz = -8*FRACUNIT
					hammer.rollangle = $ + ANG1*hammer.angspeed
					
					if hammer.cool
						summonAura(hammer, SKINCOLOR_SUPERGOLD3)
						if leveltime%5 == 0
							local g = P_SpawnGhostMobj(hammer)
							g.destscale = FRACUNIT*4
							g.scalespeed = FRACUNIT/8
							g.rollangle = hammer.rollangle
						end
						
						if leveltime%10 == 0
							local s = P_SpawnMobj(hammer.x + P_RandomRange(-40, 40)*FRACUNIT, hammer.y + P_RandomRange(-40, 40)*FRACUNIT, hammer.z + P_RandomRange(-30, 30)*FRACUNIT, MT_DUMMY)
							s.state = S_MEGISTAR1
							s.scale = FRACUNIT/3
						end
					end
					
					if evt.ftimer == 230
						mo.orbitx = -1632*FRACUNIT
						mo.orbity = -3936*FRACUNIT
						P_TeleportMove(mo, mo.x, mo.y, cam.z - 200*FRACUNIT)
						hammer.destscale = FRACUNIT
						mo.rotate = ANG1*90
						mo.angspeed = 0
						mo.dist = 150
						mo.state = S_PLAY_SPRING
					end
					
					if evt.ftimer >= 230
						local x = mo.orbitx + mo.dist*cos(mo.rotate)
						local y = mo.orbity + mo.dist*sin(mo.rotate)
						local x2 = mo.orbitx - mo.dist*cos(mo.rotate)
						local y2 = mo.orbity - mo.dist*sin(mo.rotate)
						if evt.ftimer < 350
							hammer.momx = (x - hammer.x)/3
							hammer.momy = (y - hammer.y)/3
							mo.momx = (x2 - mo.x)/3
							mo.momy = (y2 - mo.y)/3
						else
							hammer.momx = (x - hammer.x)/2
							hammer.momy = (y - hammer.y)/2
							mo.momx = (x2 - mo.x)/2
							mo.momy = (y2 - mo.y)/2
						end
						if evt.ftimer < 440
							mo.momz = (hammer.z - mo.z)/10
						end
						
						mo.rotate = $ + ANG1*mo.angspeed
						if evt.ftimer < 410
							mo.angle = $+ANG1*15
						end
						
						if evt.ftimer < 330
							if leveltime%8 == 0
								mo.angspeed = min($+1, 30)
							end
						else
							if leveltime%4 == 0
								mo.angspeed = min($+2, 35)
							end
						end
						if evt.ftimer < 350
							if leveltime%4 == 0
								mo.dist = max($-1, 0)
								hammer.angspeed = min(70, $+2)
							end
						else
							if leveltime%2 == 0
								mo.dist = max($-3, 0)
							end
						end
						
						local g = P_SpawnGhostMobj(mo)
						g.momz = -8*FRACUNIT
					end
					
					if evt.ftimer == 410
						mo.state = S_ETERNALTWINSPIN
						mo.angle = 0
						hammer.sprite = SPR_NULL
					end
				end
				
				if evt.ftimer == 440
					playSound(mo.battlen, sfx_wind4)
					playSound(mo.battlen, sfx_wind4)
					local man = P_SpawnMobj(mo.x, mo.y, mo.z, MT_PFIGHTER)
					man.hp = 69
					man.flags = $|MF_NOGRAVITY
					man.flags2 = $|MF2_DONTDRAW
					man.tics = -1
					man.cutscene = true
					for i = 1, 6
						local g = P_SpawnMobj(mo.x, mo.y, mo.z, MT_GARU)
						g.target = man
						g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
						if i == 1 or i == 12
							g.jizzcolor = true
						end
						if i%2
							g.invertrotation = true
						end
						g.dist = P_RandomRange(45, 140)
						g.tics = 75
					end
				end
				
				if evt.ftimer == 500
					mo.momz = -4*FRACUNIT
					mo.hammer.momz = -4*FRACUNIT
				end
				
				if evt.ftimer == 515
					playSound(mo.battlen, sfx_s3k81)
					mo.momz = 60*FRACUNIT
					mo.hammer.momz = 60*FRACUNIT
					for i = 1,16
						local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.destscale = FRACUNIT*10
						dust.state = S_AOADUST1
						dust.frame = A|FF_FULLBRIGHT
						P_InstaThrust(dust, dust.angle, 20*FRACUNIT)
					end
				end
				
				if evt.ftimer == 560
					//change the sky to space for next scene real quick
					P_SetupLevelSky(22, nil)
					return true
				end
			end
		},
	[9] = {"function", //cut to non scrolling bg
			function(evt, btl)
				local mo = btl.superman
				local cam = server.P_BattleStatus[mo.battlen].cam
				if evt.ftimer == 1
					flying = false
					//camera
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 4
							
							local cx = m.x - 500*cos(m.angle)
							local cy = m.y - 500*sin(m.angle)
							P_TeleportMove(cam, cx, cy, m.z)
							cam.angle = ANG1*230
							cam.aiming = 0
							CAM_stop(cam)
							break
						end
					end
				end
				
				if evt.ftimer == 40
					mo.scale = 1
					mo.destscale = FRACUNIT
					mo.scalespeed = FRACUNIT/16
					mo.angle = cam.angle + ANG1*90
					local x = cam.x + 200*cos(cam.angle + ANG1*10)
					local y = cam.y + 200*sin(cam.angle + ANG1*10)
					P_TeleportMove(mo, x, y, cam.z)
					P_InstaThrust(mo, cam.angle + ANG1*270, 4*FRACUNIT)
				end
				
				if evt.ftimer == 56
					playSound(mo.battlen, sfx_wind1)
					for i = 1, 32
						local g = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						g.scale = FRACUNIT/2
						g.destscale = 1
						g.color = SKINCOLOR_EMERALD
						g.frame = A
						if i%2 then g.color = SKINCOLOR_WHITE end
						g.momx = P_RandomRange(-15, 15)*FRACUNIT
						g.momy = P_RandomRange(-15, 15)*FRACUNIT
						g.momz = P_RandomRange(-15, 15)*FRACUNIT
					end
					mo.state = S_PLAY_FALL
					P_InstaThrust(mo, cam.angle + ANG1*270, FRACUNIT/2)
					localquake(mo.battlen, 10*FRACUNIT, 5)
				end
				
				if evt.ftimer == 80
					playSound(mo.battlen, sfx_arcrt1)
				end
				
				if evt.ftimer == 110
					mo.state = S_PLAY_SUPER_TRANS3
					mo.frame = G
					mo.tics = -1
					playSound(mo.battlen, sfx_summon)
					local g = P_SpawnGhostMobj(mo)
					g.color = SKINCOLOR_EMERALD
					g.colorized = true
					g.destscale = FRACUNIT*4
					g.frame = $|FF_FULLBRIGHT
					
					//prepare the panta rhei spindash
					mo.blades = {}
					-- blades have an addtional vangle property.
					-- extravalue1 determines whether they spin forward or backwards
				end
				
				if evt.ftimer == 130

					-- spawn blades:

					local an = mo.angle + ANG1*90
					playSound(mo.battlen, sfx_wind4)

					local b = P_SpawnMobj(mo.x + 1024*cos(an), mo.y + 1024*sin(an), mo.z + 512*FRACUNIT, MT_DUMMY)
					b.vangle = ANG1*60
					b.state = S_INVISIBLE
					b.extravalue1 = 1
					b.extravalue2 = 16
					mo.blades[#mo.blades+1] = b
					b.momx = -(b.x - mo.x)/b.extravalue2
					b.momy = -(b.y - mo.y)/b.extravalue2
					b.momz = -(b.z - (mo.z + 96*FRACUNIT))/b.extravalue2
					b.fuse = TICRATE*3

					b = P_SpawnMobj(mo.x - 1024*cos(an), mo.y - 1024*sin(an), mo.z + 320*FRACUNIT, MT_DUMMY)
					b.vangle = -ANG1*30
					b.state = S_INVISIBLE
					b.extravalue1 = -1
					b.extravalue2 = 16
					mo.blades[#mo.blades+1] = b
					b.momx = -(b.x - mo.x)/b.extravalue2
					b.momy = -(b.y - mo.y)/b.extravalue2
					b.momz = -(b.z - (mo.z + 96*FRACUNIT))/b.extravalue2
					b.fuse = TICRATE*3
				end
				
				if evt.ftimer == 146
					mo.state = S_ETERNALTWINSPIN
					mo.momx = 0
					mo.momy = 0
				end
				
				if evt.ftimer >= 130
					local i = #mo.blades
					while i
						local b = mo.blades[i]
						if not b or not b.valid
							table.remove(mo.blades, i)
							i = $-1
							continue
						end

						if R_PointToDist2(b.x, b.y, mo.x, mo.y) < 192*FRACUNIT
							b.momx = 0
							b.momy = 0
							b.momz = 0

							localquake(mo.battlen, FRACUNIT*10, 2)

							if leveltime%2 and i == 1

								for i=1,10
									local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
									b.momx = P_RandomRange(-35, 35)*FRACUNIT
									b.momy = P_RandomRange(-35, 35)*FRACUNIT
									b.momz = P_RandomRange(-35, 35)*FRACUNIT
									b.color = SKINCOLOR_RED
									b.frame = A|FF_FULLBRIGHT
									b.scale = FRACUNIT/2
									b.destscale = FRACUNIT/12
									b.tics = TICRATE/4
								end

								local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
								s.scale = FRACUNIT/4
								s.sprite = SPR_SLAS
								s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
								s.destscale = FRACUNIT*9
								s.scalespeed = FRACUNIT
								s.tics = TICRATE/3

							end
							if leveltime%8 == 0
								playSound(mo.battlen, sfx_hit2)
								localquake(mo.battlen, FRACUNIT*32, 8)
							end
						end
						b.angle = $ + ANG1*24*b.extravalue1
						local addang = 360/6
						for j = 1, 6
							local sang = b.angle
							for k = 1, 4

								local sx = b.x + (k-1)*8*cos(sang + (j-1)*addang*ANG1)
								local sy = b.y + (k-1)*8*sin(sang + (j-1)*addang*ANG1)
								local sz = b.z + (k-1)*8*FixedMul(cos(sang + (j-1)*addang*ANG1), sin(b.vangle))

								local p = P_SpawnMobj(sx, sy, sz, MT_DUMMY)
								p.tics = TICRATE
								p.scale = FRACUNIT*3/4
								p.destscale = 1
								p.frame = FF_FULLBRIGHT
								p.color = j%2 and SKINCOLOR_EMERALD or SKINCOLOR_WHITE

								p.angle = sang + (j-1)*addang*ANG1
								P_InstaThrust(p, p.angle, 32*FRACUNIT)
								p.momz = 32*FixedMul(cos(p.angle), sin(b.vangle))

								sang = $-(ANG1*6)

							end
						end
						i = $-1
					end
				end
				
				if evt.ftimer == 235
					mo.destscale = 0
					mo.scalespeed = FRACUNIT/14
					P_InstaThrust(mo, mo.angle, 8*FRACUNIT)
					localquake(mo.battlen, 10*FRACUNIT, 5)
					for i = 1, 32
						local g = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						g.scale = FRACUNIT/2
						g.destscale = 1
						g.color = SKINCOLOR_EMERALD
						g.frame = A
						if i%2 then g.color = SKINCOLOR_WHITE end
						g.momx = P_RandomRange(-15, 15)*FRACUNIT
						g.momy = P_RandomRange(-15, 15)*FRACUNIT
						g.momz = P_RandomRange(-15, 15)*FRACUNIT
					end
				end
				
				if evt.ftimer == 236
					playSound(mo.battlen, sfx_s3k81)
					playSound(mo.battlen, sfx_s3k81)
					playSound(mo.battlen, sfx_s3k81)
					playSound(mo.battlen, sfx_wind1)
				end
				
				if evt.ftimer >= 235
					P_SpawnGhostMobj(mo)
				end
				
				if evt.ftimer == 290
					return true
				end
			end
		},
	[10] = {"function", //cut to reverse scrolling bg, woah so fancy
			function(evt, btl)
				local mo = btl.superman
				local cam = btl.cam
				//change camera
				if evt.ftimer == 1
				
					//testing hack(?): kill the glass in the way during the cutscene
					for i = 1, 7
						P_LinedefExecute(100 + i) --kill
					end
					
					//camera
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 8
						
							P_TeleportMove(cam, m.x, m.y, m.z)
							cam.angle = m.angle
							cam.aiming = 0
							CAM_stop(cam)
							break
						end
					end
					
					flying = true
					P_TeleportMove(mo, -554*FRACUNIT, 1088*FRACUNIT, cam.z + 200*FRACUNIT)
					mo.angle = ANG1*90
					mo.scale = FRACUNIT*2
					mo.momx = 0
					mo.momy = 0
					playSound(mo.battlen, sfx_boost2)
				end
				
				if evt.ftimer >= 1
				
					if evt.ftimer < 163
						summonAura(mo, SKINCOLOR_SUPERGOLD3)
						if leveltime%10 == 0
							local s = P_SpawnMobj(mo.x + P_RandomRange(-40, 40)*FRACUNIT, mo.y + P_RandomRange(-40, 40)*FRACUNIT, mo.z + P_RandomRange(-30, 30)*FRACUNIT, MT_DUMMY)
							s.state = S_MEGISTAR1
							s.scale = FRACUNIT/3
						end
						mo.momz = ((cam.z-50*FRACUNIT) - mo.z)/15
					end
					
					for i = 1, 2
						local thok = P_SpawnMobj(mo.x+P_RandomRange(-50, 700)*FRACUNIT, mo.y+P_RandomRange(-450, 450)*FRACUNIT, mo.z+P_RandomRange(-400, -500)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_LHRT
						thok.frame = A|FF_FULLBRIGHT
						thok.momz = P_RandomRange(40, 120)*FRACUNIT
						thok.scale = FRACUNIT*P_RandomRange(1/2,1)
						thok.tics = 20
					end
					for i = 1, 2
						local thok = P_SpawnMobj(mo.x+P_RandomRange(-50, 700)*FRACUNIT, mo.y+P_RandomRange(-450, 450)*FRACUNIT, mo.z+P_RandomRange(-400, -500)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_SUMN
						thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
						thok.momz = P_RandomRange(40, 120)*FRACUNIT
						thok.color = SKINCOLOR_WHITE
						thok.tics = 20
					end
				end
				
				if evt.ftimer == 80 or evt.ftimer == 95 or evt.ftimer == 110
					playSound(mo.battlen, sfx_s3kab1)
					local g = P_SpawnGhostMobj(mo)
					g.destscale = FRACUNIT*8
					g.scalespeed = FRACUNIT/6
					g.color = SKINCOLOR_YELLOW
					g.colorized = true
					for i = 1, 16
						local g = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						g.scale = FRACUNIT
						g.destscale = 1
						g.color = SKINCOLOR_EMERALD
						g.frame = A
						if i%2 then g.color = SKINCOLOR_WHITE end
						g.momx = P_RandomRange(-30, 30)*FRACUNIT
						g.momy = P_RandomRange(-30, 30)*FRACUNIT
						g.momz = P_RandomRange(-30, 30)*FRACUNIT
					end
				end
				
				if evt.ftimer == 120 or evt.ftimer == 130 or evt.ftimer == 140
					playSound(mo.battlen, sfx_s3kab3)
					local g = P_SpawnGhostMobj(mo)
					g.destscale = FRACUNIT*8
					g.scalespeed = FRACUNIT/6
					g.color = SKINCOLOR_YELLOW
					g.colorized = true
					for i = 1, 16
						local g = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						g.scale = FRACUNIT
						g.destscale = 1
						g.color = SKINCOLOR_EMERALD
						g.frame = A
						if i%2 then g.color = SKINCOLOR_WHITE end
						g.momx = P_RandomRange(-30, 30)*FRACUNIT
						g.momy = P_RandomRange(-30, 30)*FRACUNIT
						g.momz = P_RandomRange(-30, 30)*FRACUNIT
					end
				end
				
				if evt.ftimer == 145 or evt.ftimer == 150 or evt.ftimer == 155
					playSound(mo.battlen, sfx_s3kab5)
					local g = P_SpawnGhostMobj(mo)
					g.destscale = FRACUNIT*8
					g.scalespeed = FRACUNIT/4
					g.color = SKINCOLOR_YELLOW
					g.colorized = true
					for i = 1, 16
						local g = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						g.scale = FRACUNIT
						g.destscale = 1
						g.color = SKINCOLOR_EMERALD
						g.frame = A
						if i%2 then g.color = SKINCOLOR_WHITE end
						g.momx = P_RandomRange(-30, 30)*FRACUNIT
						g.momy = P_RandomRange(-30, 30)*FRACUNIT
						g.momz = P_RandomRange(-30, 30)*FRACUNIT
					end
				end
				
				if evt.ftimer == 157 or evt.ftimer == 159 or evt.ftimer == 161
					playSound(mo.battlen, sfx_s3kab7)
					local g = P_SpawnGhostMobj(mo)
					g.destscale = FRACUNIT*8
					g.scalespeed = FRACUNIT/4
					g.color = SKINCOLOR_YELLOW
					g.colorized = true
					for i = 1, 16
						local g = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						g.scale = FRACUNIT
						g.destscale = 1
						g.color = SKINCOLOR_EMERALD
						g.frame = A
						if i%2 then g.color = SKINCOLOR_WHITE end
						g.momx = P_RandomRange(-30, 30)*FRACUNIT
						g.momy = P_RandomRange(-30, 30)*FRACUNIT
						g.momz = P_RandomRange(-30, 30)*FRACUNIT
					end
				end
				
				if evt.ftimer == 163
					for i = 1, 32
						local g = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						g.scale = FRACUNIT
						g.destscale = 1
						g.color = SKINCOLOR_EMERALD
						g.frame = A
						if i%2 then g.color = SKINCOLOR_WHITE end
						g.momx = P_RandomRange(-30, 30)*FRACUNIT
						g.momy = P_RandomRange(-30, 30)*FRACUNIT
						g.momz = P_RandomRange(-30, 30)*FRACUNIT
					end
					for i = 1,16
						local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.destscale = FRACUNIT*10
						dust.state = S_AOADUST1
						dust.frame = A|FF_FULLBRIGHT
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.momz = FRACUNIT*20
					end
					for i = 1, 8
						local dist = i*20
						local e = P_SpawnMobj(mo.x, mo.y, mo.z-dist*FRACUNIT, MT_DUMMY)
						e.color = SKINCOLOR_WHITE
						e.tics = 30
						e.frame = FF_FULLBRIGHT
						e.scale = FRACUNIT*3/2
						e.destscale = 0
						e.scalespeed = FRACUNIT/6
					end
					playSound(mo.battlen, sfx_boost1)
					playSound(mo.battlen, sfx_s3k81)
					mo.flags2 = $|MF2_DONTDRAW
				end
				
				if evt.ftimer == 190
					P_SetupLevelSky(7, nil)
					//remove stuff
					for s in sectors.iterate
						if s.tag == 32
							s.floorheight = -6000*FRACUNIT
							s.ceilingheight = -6000*FRACUNIT
						end
					end
					for k,v in ipairs(btl.fighters)
						if v.enemy != "b_eggman" and v != mo
							P_TeleportMove(v, -8130*FRACUNIT, 1730*FRACUNIT, -1900*FRACUNIT)
						end
					end
					return true
				end
			end
		},
	[11] = {"function", //cut back to (clueless) eggman
			function(evt, btl)
				local mo = btl.superman
				local cam = btl.cam
				//change camera
				if evt.ftimer == 1
					flying = false
					local cx = btl.eggdude.x + 1200*cos(ANG1*120)
					local cy = btl.eggdude.y + 1200*sin(ANG1*120)
					P_TeleportMove(cam, cx, cy, btl.eggdude.z + 200*FRACUNIT)
					cam.angle = R_PointToAngle2(cam.x, cam.y, btl.eggdude.x, btl.eggdude.y)
					cam.aiming = -ANG1*10
					CAM_stop(cam)
				end
				
				if evt.ftimer >= 30 and evt.ftimer < 60
					localquake(mo.battlen, 2*FRACUNIT, 1)
				end
				
				if evt.ftimer == 60
					localquake(mo.battlen, 20*FRACUNIT, 10)
					for k,v in ipairs(btl.fighters)
						if v and v.control and v.control.valid
							P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
					end
					playSound(mo.battlen, sfx_steal)
					playSound(mo.battlen, sfx_slash)
					
					for i = 1, 50
						local dist = 1500 - i*60
						local e = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z+dist*FRACUNIT, MT_DUMMY)
						e.color = SKINCOLOR_WHITE
						e.tics = 30
						e.frame = FF_FULLBRIGHT
						e.scale = FRACUNIT*3
						e.destscale = 0
						e.scalespeed = FRACUNIT/6
					end
					
					for i = 1, 30
						local st = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z, MT_DUMMY)
						st.state = S_BRICKDEBRIS
						st.flags = $ & ~MF_NOGRAVITY
						st.scale = FRACUNIT*4
						st.momx = P_RandomRange(100, -100)*FRACUNIT
						st.momy = P_RandomRange(100, -100)*FRACUNIT
						st.momz = P_RandomRange(-50, -100)*FRACUNIT
						st.fuse = 30
					end
					
					btl.eggdude.anim = nil
					btl.eggdude.state = S_PLAY_FLY_TIRED
					S_StopMusic(nil)
				end
				
				if evt.ftimer >= 80 and evt.ftimer < 100
					if leveltime%2 == 0
						local elec = P_SpawnMobj(btl.eggdude.x + P_RandomRange(500, -500)*FRACUNIT, btl.eggdude.y + 50*FRACUNIT, btl.eggdude.z + P_RandomRange(300, -300)*FRACUNIT, MT_DUMMY)
						elec.sprite = SPR_DELK
						elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
						elec.scale = FRACUNIT*3
						elec.destscale = FRACUNIT*6
						elec.tics = 1
						elec.color = SKINCOLOR_YELLOW
					end
				elseif evt.ftimer >= 100 and evt.ftimer < 120
					local elec = P_SpawnMobj(btl.eggdude.x + P_RandomRange(500, -500)*FRACUNIT, btl.eggdude.y + 50*FRACUNIT, btl.eggdude.z + P_RandomRange(300, -300)*FRACUNIT, MT_DUMMY)
					elec.sprite = SPR_DELK
					elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
					elec.scale = FRACUNIT*3
					elec.destscale = FRACUNIT*6
					elec.tics = 1
					elec.color = SKINCOLOR_YELLOW
				elseif evt.ftimer >= 120 and evt.ftimer < 220
					localquake(mo.battlen, 4*FRACUNIT, 1)
					for i = 1, 2
						local elec = P_SpawnMobj(btl.eggdude.x + P_RandomRange(500, -500)*FRACUNIT, btl.eggdude.y + 50*FRACUNIT, btl.eggdude.z + P_RandomRange(300, -300)*FRACUNIT, MT_DUMMY)
						elec.sprite = SPR_DELK
						elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
						elec.scale = FRACUNIT*3
						elec.destscale = FRACUNIT*6
						elec.tics = 1
						elec.color = SKINCOLOR_YELLOW
					end
				end
				
				if evt.ftimer == 170
				or evt.ftimer == 178
				or evt.ftimer == 186
				or evt.ftimer == 182
				or evt.ftimer == 188
				or evt.ftimer == 194
				or evt.ftimer == 198
				or evt.ftimer == 202
				or evt.ftimer == 206
				or evt.ftimer == 208
				or evt.ftimer == 210
				or evt.ftimer == 212
				or evt.ftimer > 212 and evt.ftimer < 220
					playSound(mo.battlen, sfx_hamas1)
					local s = P_SpawnMobj(btl.eggdude.x + P_RandomRange(500, -500)*FRACUNIT, btl.eggdude.y + 100*FRACUNIT, btl.eggdude.z + P_RandomRange(300, -300)*FRACUNIT, MT_DUMMY)
					s.color = SKINCOLOR_WHITE
					s.state = S_MEGISTAR1
					s.scale = FRACUNIT*4
					s.frame = $|FF_FULLBRIGHT
				end
				
				//BOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOM
				if evt.ftimer == 220
					localquake(mo.battlen, FRACUNIT*40, 20)
					for i = 1, 2
						playSound(mo.battlen, sfx_megi5)
						playSound(mo.battlen, sfx_s3k4e)
						playSound(mo.battlen, sfx_fire1)
						playSound(mo.battlen, sfx_fire2)
					end
					playSound(mo.battlen, sfx_egdie1)
					
					local boom = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z-20*FRACUNIT, MT_BOSSEXPLODE)
					boom.scale = FRACUNIT*10
					boom.state = S_PFIRE1
					boom.frame = $|FF_FULLBRIGHT
					for i = 1, 6
						local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_DUMMY)
						smoke.scale = FRACUNIT*10
						smoke.state = S_TNTDUST_1
						smoke.momx = P_RandomRange(-5, 5)*FRACUNIT
						smoke.momy = P_RandomRange(-5, 5)*FRACUNIT
						smoke.momz = P_RandomRange(-6, 6)*FRACUNIT
					end
					for i = 1, 12
						local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_DUMMY)
						smoke.scale = FRACUNIT*10
						smoke.state = S_TNTDUST_1
						smoke.momx = P_RandomRange(-20, 20)*FRACUNIT
						smoke.momy = P_RandomRange(-20, 20)*FRACUNIT
						smoke.momz = P_RandomRange(-20, 20)*FRACUNIT
					end
					
					for j = 1, 80
						local st = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, btl.eggdude.z, MT_DUMMY)
						if j%2 == 0
							st.state = S_MEGITHOK
						else
							st.sprite = SPR_LHRT
						end
						st.flags = $ & ~MF_NOGRAVITY
						st.momx = P_RandomRange(-128, 128)*FRACUNIT
						st.momy = P_RandomRange(-128, 128)*FRACUNIT
						st.momz = P_RandomRange(-128, 128)*FRACUNIT
						st.fuse = 140
						st.scale = FRACUNIT*3/2
					end
					
					for s in sectors.iterate
						if s.tag == 33 or s.tag == 60
							s.ceilingheight = -6000*FRACUNIT
							s.floorheight = -6000*FRACUNIT
						end
					end
					btl.eggdude.flags = $|MF_NOGRAVITY
					btl.eggdude.flags2 = $|MF2_DONTDRAW
				end
				
				if evt.ftimer == 240
					mo.stars = P_SpawnMobj(btl.eggdude.x, btl.eggdude.y, -1740*FRACUNIT, MT_DUMMY)
					mo.stars.scale = FRACUNIT*5
					mo.stars.state = S_AMYSTARS1
					mo.stars.frame = $|FF_FULLBRIGHT
					mo.stars.destscale = 0
					mo.stars.scalespeed = FRACUNIT/80
					playSound(mo.battlen, sfx_s3kb8)
					playSound(mo.battlen, sfx_ideya)
				end
				
				if evt.ftimer == 320
					mo.stars.state = S_AMYSTARS2
				elseif evt.ftimer == 340
					mo.stars.state = S_AMYSTARS3
				elseif evt.ftimer == 360
					P_RemoveMobj(mo.stars)
				end
				
				if evt.ftimer == 390
					return true
				end
			end
		},
	[12] = {"function", //results screen (BUT AWESOME)
			function(evt, btl)
				local mo = btl.superman
				local cam = btl.cam
				local y = 2500*FRACUNIT
				if evt.ftimer == 1
					P_TeleportMove(mo, -4160*FRACUNIT, 600*FRACUNIT, -2000*FRACUNIT)
					mo.scale = FRACUNIT
					mo.momz = 20*FRACUNIT
					mo.state = S_PLAY_ROLL
					mo.flags = $ & ~MF_NOGRAVITY
					mo.flags2 = $ & ~MF2_DONTDRAW
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 2

							local cam = btl.cam
							P_TeleportMove(cam, m.x, m.y, m.z)
							cam.angle = m.angle
							cam.aiming = -ANG1*2
							CAM_goto(cam, cam.x, cam.y, cam.z)
							CAM_angle(cam, cam.angle)
							CAM_aiming(cam, cam.aiming)
							break
						end
					end
					//spawn stage clear sign
					mo.sign = P_SpawnMobj(-3904*FRACUNIT, 1856*FRACUNIT, cam.floorz, MT_SIGN)
					mo.sign.spin = false
					mo.sign.angle = ANG1*90
				end
				mo.momy = (y - mo.y)/55
				mo.angle = ANG1*90
				if evt.ftimer < 38
					P_SpawnGhostMobj(mo)
				end
				if evt.ftimer == 38
					playSound(mo.battlen, sfx_poof)
					mo.color = SKINCOLOR_ROSY
					mo.state = S_PLAY_FALL //S_PLAY_JUMP?
					local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT
					A_OldRingExplode(thok, MT_SUPERSPARK)
				end
				if mo.momz <= -8*FRACUNIT
					mo.momz = -8*FRACUNIT
				end
				if mo.sign and mo.sign.valid and mo.y >= mo.sign.y and not mo.sign.spin and evt.ftimer < 180
					playSound(mo.battlen, sfx_lvpass)
					mo.sign.spin = true
				end
				if mo.sign.spin
					if leveltime%3 == 0
						A_SignPlayer(mo.sign, P_RandomRange(0, 3))
					end
					mo.sign.angle = $ + 40*ANG1
				end
				if evt.ftimer >= 90 and evt.ftimer < 180
					local cx = mo.sign.x + 200*cos(ANG1*90)
					local cy = mo.sign.y + 200*sin(ANG1*90)
					CAM_goto(cam, cx, cy, mo.sign.z + 25*FRACUNIT)
				end
				if evt.ftimer == 120
					S_ChangeMusic("fclear")
				end
				if evt.ftimer == 180
					mo.sign.spin = false
					local cx = mo.sign.x + 100*cos(ANG1*90)
					local cy = mo.sign.y + 100*sin(ANG1*90)
					P_TeleportMove(cam, cx, cy, cam.z)
					CAM_stop(cam)
					localquake(mo.battlen, FRACUNIT*10, 4)
					A_SignPlayer(mo.sign, 3)
					mo.sign.angle = 90*ANG1
					playSound(mo.battlen, sfx_nxbump) //louds
					playSound(mo.battlen, sfx_nxbump)
					local thok = P_SpawnMobj(mo.sign.x, mo.sign.y, mo.sign.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT
					A_OldRingExplode(thok, MT_NIGHTSPARKLE)
				end
				if evt.ftimer == 220
					stagecleared = true
				end
			end
		},
}