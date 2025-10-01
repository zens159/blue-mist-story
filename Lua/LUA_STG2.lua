-- DAMN

---------- BATTLE -------------

---------- Stage 2: Shadow -------------

/*Shadow has a METER system; when he has enough 'bar', he can use it for powerful moves. Unlike Silver or
Blaze, he doesn't have any stat debuff counters, but his Supercharge move unlocks when he's below a certain
hp and is a close second. His meter skills, Ultimate chaos spear and Chaos control let him deal big damage.
On the other hand, his overall stats are low and he won't be able to exploit the team's weaknesses.*/

/*local shadowhud = false
local spearset = false
local metermax = 500 //125 on display
local meterdisplay = 0 //also known as the meter percentage
local meter = 0
local barcolor = 7
local metercolor = 132
local meterlevel = 0
local fullmeter = false
local meterskill = false
local timeresume = false
local oop = nil
local function metergain(gain)
	meter = meter + gain
end*/

enemyList["b_shadow"] = {
		name = "Shadow",
		skillchance = 100,	-- /100, probability of using a skill
		level = 100,
		hp = 7600,
		sp = 1000,
		strength = 100,
		magic = 70,
		endurance = 75,
		luck = 30,
		agility = 100,
		boss = true,
		turns = 2,
		weak = ATK_WIND,
		resist = ATK_FIRE|ATK_SLASH,
		r_exp = 0,

		persona = "hermes",
		skin = "shadow",			-- for "player" fights.
		color = SKINCOLOR_BLACK,	-- for colormapping
		hudcutin = "SHAD_A",	-- cut in
		hudspr = "SHAD",

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, A, 30, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, I, J, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, 2, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, F, E, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_SHIT"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},		-- gets revived

		anim_stand_hurt_super = 	{SPR_PLAY, A, B, 4, "SPR2_STND"},		-- standing
		anim_stand_bored_super = 	{SPR_PLAY, A, B, 4, "SPR2_STND"},		-- standing
		anim_run_super = 	{SPR_PLAY, A, B, 2, "SPR2_RUN_"},	-- run
		anim_evoker_super = 	{SPR_PLAY, A, B, 4, "SPR2_STND"},
		anim_evoker_shoot_super = 	{SPR_PLAY, A, B, 4, "SPR2_STND"},

		-- chaos control still frame
		anim_special1 = 		{SPR_SHDW, A, B, 2},
		anim_special2 =			{SPR_PLAY, G, F, E, D, C, B, A, 2, "SPR2_SNAP"},
		anim_special3 = 		{SPR_PLAY, C, 1, "SPR2_TRNS"}, -- transform charge
		anim_special4 = 		{SPR_PLAY, G, 1, "SPR2_TRNS"}, -- transform release
		anim_special5 = 		{SPR_PLAY, A, 1, "SPR2_FALL"}, -- fall anim for ultimate chaos spear 

		vfx_summon = {"sfx_shsum1", "sfx_shsum2", "sfx_shsum3", "sfx_shsum4", "sfx_shsum5"},
        vfx_skill = {"sfx_shskl1", "sfx_shskl2", "sfx_shskl3", "sfx_shskl4"},
        vfx_item = {"sfx_shuse1", "sfx_shdge1", "sfx_shdge2", "sfx_shdge3"},
        vfx_hurt = {"sfx_shhrt1", "sfx_shhrt2", "sfx_shhrt3"},
        vfx_hurtx = {"sfx_shhrx1"},
        vfx_die = {"sfx_shdie1"},
        vfx_heal = {"sfx_shhel1", "sfx_shdge1", "sfx_shdge2", "sfx_shdge3"},
        vfx_healself = {"sfx_shhes1", "sfx_shdge1", "sfx_shdge2", "sfx_shdge3"},
        vfx_kill = {"sfx_shkll1", "sfx_shkll2", "sfx_shkll3", "sfx_shkll4"},
        vfx_1more = {"sfx_sh1mr1", "sfx_sh1mr2", "sfx_sh1mr3"},
        vfx_crit = {"sfx_shcrt1", "sfx_shcrt2", "sfx_shcrt3", "sfx_shcrt4"},
        vfx_aoaask = {"sfx_shaoi1", "sfx_shaoi2"},
        vfx_aoado = {"sfx_shaoa1", "sfx_shaoa2", "sfx_shaoa3"},
        vfx_aoarelent = {"sfx_shaor1"},
        vfx_miss = {"sfx_shmis1", "sfx_shmis2", "sfx_shmis3"},
        vfx_dodge = {"sfx_shdge1", "sfx_shdge2", "sfx_shdge3"},
        vfx_win = {"sfx_shwin1", "sfx_shwin2", "sfx_shwin3", "sfx_shwin4", "sfx_shwin5"},
        vfx_levelup = {"sfx_shlvl1", "sfx_shkll1", "sfx_sh1mr2", "sfx_sh1mr3", "sfx_shhes1"},

		icon = "ICO_SHAD",		-- icon for net select and other menus
		hudbust = "SHAD_H",			-- patch to draw on the stat hud
		hudbustlayer = "",		-- transparent patch to draw for status conditions
		hudaoa = "H_SHDAOA",	-- patch for all out attack hud
		hudcutin = "SHAD_A",	-- cut in
		hudspr = "SHAD",	-- sprite prefix since hud can't retrieve it. yikes
		
		skills = {"spear set", "agidyne", "brave blade", "blade of fury"},
		
		deathanim = function(mo)

						mo.deathtimer = $ and $+1 or 1
						cutscene = true
						local btl = server.P_BattleStatus[mo.battlen]
						local cam = btl.cam
						CAM_stop(cam)
						local tgtx = mo.x + 128*cos(mo.angle)
						local tgty = mo.y + 128*sin(mo.angle)
						
						if mo.deathtimer == 1
							for k,v in ipairs(server.plentities[1])
								--resetHyperStats(v)
								cureStatus(v)
								BTL_setupstats(v)	-- reset the stats from hyper mode
							end
							for p in players.iterate do
								if p and p.control and p.control.valid and p.control.battlen == mo.battlen
									S_FadeOutStopMusic(100, p)
								end
							end
							mo.defeated = true
							P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
							ANIM_set(mo, mo.anim_hurt, true)
							for k,v in ipairs(mo.enemies)
								if v and v.control and v.control.valid
									P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
								end
							end
							P_InstaThrust(mo, mo.angle, -30*FRACUNIT)
							playSound(mo.battlen, sfx_bbreak)
							mo.shake = $ or 3*FRACUNIT
						end
						
						if mo.deathtimer < 59
							cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
							mo.momx = $*90/100
							mo.momy = $*90/100
							if not (leveltime%P_RandomRange(6, 8))
								local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height/2, MT_DUMMY)
								elec.sprite = SPR_DELK
								elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
								elec.destscale = FRACUNIT*4
								elec.scalespeed = FRACUNIT/4
								elec.tics = TICRATE/8
								elec.color = SKINCOLOR_COBALT
							end
							if leveltime%P_RandomRange(6, 8) == 0
								mo.color = SKINCOLOR_COBALT
							else
								mo.color = SKINCOLOR_BLACK
							end
						end
						
						if mo.deathtimer == 60
							mo.color = SKINCOLOR_BLACK
							mo.hp = 1
							ANIM_set(mo, mo.anim_downloop, true)
							playSound(mo.battlen, sfx_s3k5d)
							P_StartQuake(2*FRACUNIT, 2)
							for i = 1,16
								local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (22*(i-1))
								dust.state = S_CDUST1
								P_InstaThrust(dust, dust.angle, 10*FRACUNIT)
								dust.color = SKINCOLOR_WHITE
								dust.scale = FRACUNIT/2
							end
							D_startEvent(1, "shadow_defeat")
							mo.defeated = false
							mo.flags2 = $ & ~MF2_DONTDRAW
							mo.deathanim = nil
							return
						end
					end,
		
		thinker = function(mo)
			local btl = server.P_BattleStatus[mo.battlen]
			if mo.chargecooldown > 0
				mo.chargecooldown = $ - 1
			end
			if timestop 
				if btl.meterlevel == 0 and btl.meterdisplay <= 45
					D_startEvent(mo.battlen, "ev_shadow_timeresume")
					return generalEnemyThinker(mo)
				else
					local attack = P_RandomRange(1, 4)
					if attack == 1 and not btl.spearset
						return attackDefs["spear set"], mo.enemies
					end
					if (attack == 1 or attack == 2) and btl.spearset
						return attackDefs["spear release"], mo.enemies
					end
					return generalEnemyThinker(mo)
				end
			end
			if btl.meterlevel >= 3
				playSound(mo.battlen, sfx_alarm)
				return attackDefs["b_chaos control"], mo.enemies
			end
			if mo.hp < 4000 and btl.meterlevel < 3 and mo.pls == nil and mo.chargecooldown == 0
				return attackDefs["supercharge"], {mo}
			end
			local attack = P_RandomRange(1, 5)
			if mo.hp < 4000
				attack = P_RandomRange(1, 7)
			end
			if attack == 1 and not btl.spearset
				if btl.spearcount < 2
					return attackDefs["spear set"], mo.enemies
				else
					return attackDefs["spear release"], mo.enemies
				end
			end
			if attack == 5 and btl.spearset
				return attackDefs["spear release"], mo.enemies
			end
			if (attack == 2 or attack == 6) and btl.meterlevel >= 1 and mo.hp < 6000
				playSound(mo.battlen, sfx_alarm)
				if btl.meterlevel >= 3
					btl.fullmeter = false
					btl.meterlevel = 2
					btl.meterdisplay = 0
					btl.meter = 0
				else
					btl.meterlevel = btl.meterlevel - 1
				end
				return attackDefs["ultimate chaos spear"], mo.enemies
			end
			if attack == 3 and btl.meterlevel >= 3
				playSound(mo.battlen, sfx_alarm)
				return attackDefs["b_chaos control"], mo.enemies
			end
			if (attack == 4 or attack == 7) and mo.hp < 6000 and mo.chargecooldown == 0
				return attackDefs["supercharge"], {mo}
			end
			return generalEnemyThinker(mo)
		end,
}

attackDefs["spear set"] = {
		name = "Spear Set",
		type = ATK_ALMIGHTY,
		power = 200,
		costtype = CST_SP,
		cost = 20,
		desc = "Set a spear field surrounding\nthe opponent.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					local btl = server.P_BattleStatus[mo.battlen]
					if timer >= 1
						if timer == 1 
							mo.spearset = $ or {} 
							target.doomspears = $ or 0
							mo.camdist = 256
						elseif timer == 40
							mo.camdist = 400
						end
						local cam = server.P_BattleStatus[mo.battlen].cam
						local tgtx = target.x - mo.camdist*cos(target.angle)
						local tgty = target.y - mo.camdist*sin(target.angle)
						cam.angle = (R_PointToAngle(target.x, target.y))
						CAM_goto(cam, tgtx, tgty, target.z + 50*FRACUNIT)
					end
					if timer >= 40 and timer <= 47
						playSound(mo.battlen, sfx_prloop)
						for i = 1, 2
							local ang = ANGLE_90 + ANG1* (47*((timer-40)-2+i*20))
							local tgtx = target.x + P_RandomRange(30, 80)*cos(ang)
							local tgty = target.y + P_RandomRange(30, 80)*sin(ang)
							local spear = P_SpawnMobj(tgtx, tgty, target.z+((i*3)*P_RandomRange(1, 20)*FRACUNIT), MT_DUMMY)
							spear.sprite = SPR_CSPP
							spear.angle = ang
							spear.scale = FRACUNIT/2
							spear.frame = FF_FULLBRIGHT|A
							spear.tics = -1
							spear.target = target
							target.doomspears = $+1
							P_InstaThrust(spear, spear.angle, 10*FRACUNIT)
							mo.spearset[#mo.spearset+1] = spear
							local warp = P_SpawnMobj(spear.x, spear.y, spear.z, MT_DUMMY)
							warp.state = S_CHAOSCONTROL1
							warp.scale = FRACUNIT/2
							warp.destscale = FRACUNIT
						end
					end
					if mo.spearset and #mo.spearset
						for i = 1, #mo.spearset do
							if mo.spearset[i] and mo.spearset[i].valid
								local spear = mo.spearset[i]
								if not spear.thatscrazy --dont let already existing spears aim at the added target
									spear.angle = (R_PointToAngle2(spear.x, spear.y, target.x, target.y))
								end
								spear.momx = $*80/100
								spear.momy = $*80/100
								spear.momz = $*80/100
							end
						end
					end
					if timer == 80
						if mo.spearset and #mo.spearset
							for i = 1, #mo.spearset do
								if mo.spearset[i] and mo.spearset[i].valid
									mo.spearset[i].thatscrazy = true
								end
							end
						end
						btl.spearset = true
						btl.spearcount = $+1
						return true
					end
				end,
}

attackDefs["spear release"] = {
		name = "Spear Release",
		type = ATK_ALMIGHTY,
		power = 200,
		accuracy = 999,
		costtype = CST_SP,
		cost = 0,
		desc = "Release an existing spear\nfield, damaging the enemy.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					if timer == 1
						if not timestop
							mo.speartargets = {}
						else
							if not mo.speartargets
								mo.speartargets = {}
							end
						end
						playSound(mo.battlen, sfx_s3k5a)
					end
					if timer == 20
						playSound(mo.battlen, sfx_thok)
						if mo.spearset and #mo.spearset
							for i = 1, #mo.spearset do
								if mo.spearset[i] and mo.spearset[i].valid
									local spear = mo.spearset[i]
									local target = spear.target
									if not timestop
										local tgtx = spear.x - 100*cos(spear.angle)
										local tgty = spear.y - 100*sin(spear.angle)
										if mo.speartargets and #mo.speartargets
											for k,v in ipairs(mo.speartargets)
												if v == target
													break
												end
												if k == #mo.speartargets and v != target
													mo.speartargets[#mo.speartargets+1] = target
												end
											end
										else
											mo.speartargets[#mo.speartargets+1] = target
										end
										spear.momx = (target.x - spear.x)/5
										spear.momy = (target.y - spear.y)/5
										spear.momz = (target.z - spear.z)/5
									else
										if mo.speartargets and #mo.speartargets
											for k,v in ipairs(mo.speartargets)
												if v == target
													break
												end
												if k == #mo.speartargets and v != target
													mo.speartargets[#mo.speartargets+1] = target
												end
											end
										else
											mo.speartargets[#mo.speartargets+1] = target
										end
										spear.zamn = true
									end
								end
							end
						end
					end
					if timer == 23
						if not timestop
							playSound(mo.battlen, sfx_sprxpl)
							if mo.spearset and #mo.spearset
								for i = 1, #mo.spearset do
									if mo.spearset[i] and mo.spearset[i].valid
										local spear = mo.spearset[i]
										local s = P_SpawnMobj(spear.x, spear.y, spear.z, MT_DUMMY)
										s.state = S_CHAOSSPEAREXPLOSION1
										P_RemoveMobj(spear)
									end
								end
							end
							for i = 1, #mo.speartargets
								local target = mo.speartargets[i]
								local damage = getDamage(target, mo, nil)
								damageObject(target, (damage*target.doomspears)/6)
								target.doomspears = 0
							end
						else
							for i = 1, #mo.speartargets
								local target = mo.speartargets[i]
								target.speardamage = getDamage(target, mo, nil)
							end
						end
					end
					if timer == 45
						btl.spearset = false
						btl.spearcount = 0
						return true
					end
				end,
}

attackDefs["supercharge"] = {
		name = "Supercharge",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 24,
		desc = "Release an existing spear\nfield, damaging the enemy.",
		target = TGT_CASTER,
		buff = true,
		anim = function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					local btl = server.P_BattleStatus[mo.battlen]
					if timer < 100
						mo.chargecooldown = 2
						ANIM_set(mo, mo.anim_special3, true)
					else
						summonAura(mo, SKINCOLOR_RED)
						ANIM_set(mo, mo.anim_special4, true)
					end
					if timer == 20 or timer == 60 or timer == 80 or timer == 90
						P_LinedefExecute(1001)
						playSound(mo.battlen, sfx_zio2)
						for i = 1,15
							local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							dust.angle = ANGLE_90 + ANG1* (22*(i-1))
							dust.state = S_CDUST1
							P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
							dust.color = SKINCOLOR_WHITE
							dust.scale = FRACUNIT*2
						end
						localquake(mo.battlen, FRACUNIT*5, 5)
					elseif timer == 100
						localquake(mo.battlen, FRACUNIT*20, TICRATE/2)
						btl.meter = btl.meter + 500
						P_LinedefExecute(1001)
						playSound(mo.battlen, sfx_buff2)
						playSound(mo.battlen, sfx_zio3)
						buffStat(target, "atk")
						buffStat(target, "mag")
						buffStat(target, "def")
						buffStat(target, "agi")
						buffStat(target, "crit")

						BTL_logMessage(targets[1].battlen, "All stats increased!")
						for i = 1,15
							local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							dust.angle = ANGLE_90 + ANG1* (22*(i-1))
							dust.state = S_CDUST1
							P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
							dust.color = SKINCOLOR_WHITE
							dust.scale = FRACUNIT*3
						end
					end
					if timer >= 100 and timer < 130
						for i = 1,15

							local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
							thok.state = S_CDUST1
							thok.momz = P_RandomRange(20, 30)*FRACUNIT
							thok.color = SKINCOLOR_PURPLE
							thok.tics = P_RandomRange(10, 35)
							thok.scale = FRACUNIT*3/2
						end

						for i = 1, 10
							local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
							thok.sprite = SPR_SUMN
							thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
							thok.momz = P_RandomRange(26, 36)*FRACUNIT
							thok.color = SKINCOLOR_PURPLE
							thok.tics = P_RandomRange(10, 35)
						end
					end
					if timer == 160
						return true
					end
				end,
}

//BRO THINKS HE'S GILGAMESH!!!!!!
attackDefs["ultimate chaos spear"] = {
		name = "Ultimate Chaos Spear",
		type = ATK_ALMIGHTY,
		power = 2200,
		costtype = CST_SP,
		hits = 28,
		cost = 50,
		desc = "Release an existing spear\nfield, damaging the enemy.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
					//this whole thing is a mess
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					if timer == 1
						btl.meterskill = true
						mo.spears = {}
						mo.campointy = nil
						mo.campointx = nil
						mo.damn = 0
						//probably a better way to do this
						mo.spearnum = {0,1,2,3,4,5,6,7,8,9,10,11,12,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14}
						mo.spearnum2 = {0,1,2,3,4,5,6,7,8,9,10,11,12,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14}
						mo.spearnum3 = {0,1,2,3,4,5,6,7,8,9,10,11,12,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14}
						mo.spearnum4 = {0,1,2,3,4,5,6,7,8,9,10,11,12,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14}
						mo.spearnum5 = {0,1,2,3,4,5,6,7,8,9,10,11,12,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14}
						mo.spearlist = {mo.spearnum, mo.spearnum2, mo.spearnum3, mo.spearnum4, mo.spearnum5}
						mo.flags = $|MF_NOGRAVITY
						mo.airpoint = mo.z + 75*FRACUNIT
						local tgtx = mo.x + 200*cos(mo.angle)
						local tgty = mo.y + 200*sin(mo.angle)
						cam.angle = (R_PointToAngle(mo.x, mo.y))
						CAM_stop(cam)
						P_TeleportMove(cam, tgtx, tgty, mo.z)
					end
					if timer > 1 and timer < 30
						local tgtx = mo.x + 200*cos(mo.angle)
						local tgty = mo.y + 200*sin(mo.angle)
						cam.angle = (R_PointToAngle(mo.x, mo.y))
						CAM_stop(cam)
						P_TeleportMove(cam, tgtx, tgty, mo.z)
						mo.momz = (mo.airpoint - mo.z)/8
						ANIM_set(mo, mo.anim_special5, true)
					elseif timer == 30
						mo.sh_snaptime = 6
						local e = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						e.skin = mo.skin
						e.sprite = mo.sprite
						e.angle = mo.angle
						e.frame = mo.frame & FF_FRAMEMASK | FF_TRANS60
						e.fuse = TICRATE/7
						e.scale = mo.scale
						e.destscale = mo.scale*6
						e.scalespeed = mo.scale/2
						e.sprite2 = mo.sprite2
						e.tics = -1
						playSound(mo.battlen, sfx_csnap)
						mo.airpoint = mo.z + 300*FRACUNIT
					end
					if (mo.sh_snaptime)
						mo.sh_snaptime = $-1
						mo.flags2 = $|MF2_DONTDRAW
					else
						if timer > 30 and timer < 70
							mo.flags = $|MF_NOGRAVITY
							P_TeleportMove(mo, mo.x, mo.y, mo.airpoint)
						elseif timer >= 70 and timer < 200
							mo.momz = 0
							mo.flags2 = $ & ~MF2_DONTDRAW
							ANIM_set(mo, mo.anim_special1, true)
						elseif timer >= 200 and mo.damn > 15
							P_TeleportMove(mo, mo.x, mo.y, mo.floorz)
							mo.flags2 = $ & ~MF2_DONTDRAW
							ANIM_set(mo, mo.anim_stand_bored, true)
						end
					end
						
					if timer >= 40 and timer < 90
						local tgtx = mo.x + 200*cos(mo.angle)
						local tgty = mo.y + 200*sin(mo.angle)
						cam.momz = (mo.airpoint - cam.z)/5
					end
					if timer == 70
						mo.sh_snaptime = 6
						local e = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						e.skin = mo.skin
						e.sprite = mo.sprite
						e.angle = mo.angle
						e.frame = mo.frame & FF_FRAMEMASK | FF_TRANS60
						e.fuse = TICRATE/7
						e.scale = mo.scale
						e.destscale = mo.scale*6
						e.scalespeed = mo.scale/2
						e.sprite2 = mo.sprite2
						e.tics = -1
						playSound(mo.battlen, sfx_csnap)
					end
					if timer == 90
						playSound(mo.battlen, sfx_bchaos)
					end
					if timer == 110
						local tgtx = mo.x + 500*cos(mo.angle)
						local tgty = mo.y + 500*sin(mo.angle)
						cam.angle = (R_PointToAngle(mo.x, mo.y))
						CAM_goto(cam, tgtx, tgty, cam.z)
					end
					if timer >= 110
						if #mo.spearnum >= 1 and #mo.spearnum2 >= 1 and #mo.spearnum3 >= 1 and #mo.spearnum4 >= 1 and #mo.spearnum5 >= 1 
							for i = 1, #mo.spearlist
								local num = mo.spearlist[i][P_RandomRange(1, #mo.spearlist[i])]
								//help
								local tgtx = (mo.x - 150*cos(mo.angle)) + (((mo.x-25*i)*cos(mo.angle + ANG1*90)) - (50*num)*cos(mo.angle + ANG1*90))
								local tgty = (mo.y - 150*sin(mo.angle)) + (((mo.y-25*i)*sin(mo.angle + ANG1*90)) - (50*num)*sin(mo.angle + ANG1*90))
								local spear = P_SpawnMobj(tgtx, tgty, (mo.z - 175*FRACUNIT) + ((75*i)*FRACUNIT), MT_DUMMY)
								spear.sprite = SPR_CSPP
								spear.angle = mo.angle
								spear.scale = FRACUNIT
								spear.frame = FF_FULLBRIGHT|A
								spear.tics = -1
								spear.awesome = false
								if num == -14
									mo.campointx = spear.x + 350*cos(spear.angle)
									mo.campointy = spear.y + 350*sin(spear.angle)
								end
								mo.spears[#mo.spears+1] = spear
								local warp = P_SpawnMobj(spear.x, spear.y, spear.z, MT_DUMMY)
								warp.state = S_CHAOSCONTROL1
								warp.scale = FRACUNIT
								warp.destscale = FRACUNIT
								for k,v in ipairs(mo.spearlist[i])
									if v == num then table.remove(mo.spearlist[i], k) end
								end
							end
							playSound(mo.battlen, sfx_prloop)
						end
					end
					if timer == 160
						P_TeleportMove(cam, mo.campointx, mo.campointy, mo.z)
						cam.angle = (R_PointToAngle2(mo.campointx, mo.campointy, mo.x, mo.y))
						CAM_stop(cam)
					end
					if timer == 167
						playSound(mo.battlen, sfx_bspear)
						playSound(mo.battlen, sfx_cspear)
					end
					if timer == 170
						local tgtx = mo.campointx + 300*cos(mo.angle)
						local tgty = mo.campointy + 300*sin(mo.angle)
						CAM_goto(cam, tgtx, tgty, cam.z - 200*FRACUNIT)
						if mo.spears and #mo.spears
							for i = 1, #mo.spears
								local spear = mo.spears[i]
								local avgx, avgy = 0, 0
								for i = 1, #hittargets
									avgx = $ + hittargets[i].x/FRACUNIT
									avgy = $ + hittargets[i].y/FRACUNIT
								end
								avgx = ($/#hittargets)	*FRACUNIT
								avgy = ($/#hittargets)	*FRACUNIT
								local direction = P_RandomRange(200, -200)*FRACUNIT
								spear.savemomx = ((avgx + direction) - spear.x)
								spear.savemomy = ((avgy + direction) - spear.y)
								spear.savemomz = P_RandomRange(-80, -100)*FRACUNIT
							end
						end
					end
					if timer > 170
						if mo.spears and #mo.spears
							local time = abs(170 - timer)
							local spear = mo.spears[time]
							if spear and spear.valid
								spear.momx = spear.savemomx/4
								spear.momy = spear.savemomy/4
								spear.momz = spear.savemomz
								spear.awesome = true
							end
						end
					end
					for i = 1, #mo.spears
						if mo.spears[i] and mo.spears[i].valid and mo.spears[i].awesome
							local spear = mo.spears[i]
							P_SpawnGhostMobj(spear)
							if spear.z <= mo.floorz
								local s = P_SpawnMobj(spear.x, spear.y, spear.z, MT_DUMMY)
								s.state = S_CHAOSSPEAREXPLOSION1
								playSound(mo.battlen, sfx_hit)
								P_RemoveMobj(spear)
							end
						end
					end
					if timer >= 175 and timer%5 == 0 and mo.spears[#mo.spears] and mo.spears[#mo.spears].valid
						for i = 1, #hittargets
							if hittargets[i].hp > 0
								damageObject(hittargets[i])
							end
						end
					end
					if timer >= 180 and not mo.spears[#mo.spears].valid
						mo.damn = $+1
						if mo.damn == 15
							playSound(mo.battlen, sfx_csnap)
							mo.sh_snaptime = 6
							local e = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							e.skin = mo.skin
							e.sprite = mo.sprite
							e.angle = mo.angle
							e.frame = mo.frame & FF_FRAMEMASK | FF_TRANS60
							e.fuse = TICRATE/7
							e.scale = mo.scale
							e.destscale = mo.scale*6
							e.scalespeed = mo.scale/2
							e.sprite2 = mo.sprite2
							e.tics = -1
							local b = P_SpawnMobj(mo.x, mo.y, mo.floorz, MT_DUMMY)
							b.skin = mo.skin
							b.sprite = mo.sprite
							b.angle = mo.angle
							b.frame = mo.frame & FF_FRAMEMASK | FF_TRANS60
							b.fuse = TICRATE/7
							b.scale = mo.scale
							b.destscale = mo.scale*6
							b.scalespeed = mo.scale/2
							b.sprite2 = mo.sprite2
							b.tics = -1
						elseif mo.damn == 50
							btl.meterskill = false
							mo.flags = $ & ~MF_NOGRAVITY
							return true
						end
					end
				end,
}

attackDefs["b_chaos control"] = {
		name = "Chaos Control",
		type = ATK_ALMIGHTY,
		power = 800,
		costtype = CST_SP,
		cost = 20,
		desc = "Set a spear field surrounding\nthe opponent.",
		target = TGT_ALLENEMIES,
		nocast = function(targets, n)
			BTL_logMessage(targets[1].battlen, "Doesn't work in PVP!")
			return true
		end,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam
					if timer < 175
						summonAura(mo, SKINCOLOR_RED)
						local tgtx = mo.x + 175*cos(mo.angle)
						local tgty = mo.y + 175*sin(mo.angle)
						cam.angle = (R_PointToAngle(mo.x, mo.y))
						CAM_goto(cam, tgtx, tgty, mo.z + 25*FRACUNIT)
					end
					if timer == 20
						mo.pls = true
						mo.saveturnorder = btl.turnorder
						btl.meterskill = true
						mo.effect = {}
						mo.powerspeed = 1
						ANIM_set(mo, mo.anim_bored, true)
						playSound(mo.battlen, sfx_shaoa3)
						mo.saveagility = mo.agility
						for i = 1, #hittargets
							local target = hittargets[i]
							target.saveagility = target.agility
						end
					end
					if timer >= 50 and timer < 175
						if timer < 100
							local thok = P_SpawnMobj(mo.x+P_RandomRange(-100, 100)*FRACUNIT, mo.y+P_RandomRange(-100, 100)*FRACUNIT, mo.z, MT_DUMMY)
							thok.sprite = SPR_SUMN
							thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
							thok.momz = P_RandomRange(mo.powerspeed, mo.powerspeed+4)*FRACUNIT
							thok.color = SKINCOLOR_RED
							thok.tics = P_RandomRange(10, 35)
							thok.scale = FRACUNIT/2
							mo.effect[#mo.effect+1] = thok
						else
							for i = 1, 4
								local thok = P_SpawnMobj(mo.x+P_RandomRange(-100, 100)*FRACUNIT, mo.y+P_RandomRange(-100, 100)*FRACUNIT, mo.z, MT_DUMMY)
								thok.sprite = SPR_SUMN
								thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
								thok.momz = P_RandomRange(mo.powerspeed, mo.powerspeed+4)*FRACUNIT
								thok.color = SKINCOLOR_RED
								thok.tics = P_RandomRange(10, 35)
								thok.scale = FRACUNIT/2
								thok.savemomz = $ or thok.momz
								mo.effect[#mo.effect+1] = thok
							end
						end
						if leveltime%2 == 0
							mo.powerspeed = $+1
						end
					end
					if mo.effect and #mo.effect
						for i = 1, #mo.effect
							if mo.effect[i] and mo.effect[i].valid
								local effect = mo.effect[i]
								if timer < 175
									effect.momz = $+1*FRACUNIT
									effect.savemomz = effect.momz
								elseif timer == 175
									effect.tics = -1
									effect.momz = 0
									effect.color = SKINCOLOR_GREY
								end
							end
						end
					end
					if timer == 120
						ANIM_set(mo, mo.anim_special3, true)
						playSound(mo.battlen, sfx_bchaos)
					end
					if timer == 160
						playSound(mo.battlen, sfx_bcntrl)
					end
					if timer == 175
						mo.status_condition = COND_NORMAL
						mo.renderflags = $|RF_NOCOLORMAPS|RF_FULLBRIGHT
						P_LinedefExecute(1002)
						ANIM_set(mo, mo.anim_special4, true)
						playSound(mo.battlen, sfx_tmstop)
						S_PauseMusic()
						timestop = true
						local g = P_SpawnGhostMobj(mo)
						g.colorized = true
						g.destscale = FRACUNIT*4
						btl.meterlevel = 2
						mo.agility = 999
						for i = 1, #hittargets
							local target = hittargets[i]
							target.agility = 1
							target.tetrakarn = false
							target.makarakarn = false
						end
					end
					if timer == 230
						local avgx, avgy = 0, 0
						for i = 1, #hittargets
							avgx = $ + hittargets[i].x/FRACUNIT
							avgy = $ + hittargets[i].y/FRACUNIT
						end
						avgx = ($/#hittargets)	*FRACUNIT
						avgy = ($/#hittargets)	*FRACUNIT
						CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, avgx, avgy))
						--CAM_goto(cam, mo.camx, mo.camy, mo.camz)
					end
					if timer == 315
						return true
					end
				end,
}

//main thinker
addHook("MobjThinker", function(mo)
	if mo.cutscene return end --make sure cutscene MT_PFIGHTERs arent affected
	if gamemap != 08 return end
	local btl = server.P_BattleStatus[mo.battlen]
	if not btl return end
	if btl.battlestate == 0 return end
	
	if btl.battlestate == BS_START
		btl.shadowhud = false
		btl.spearset = false
		btl.metermax = 500 //125 on display
		btl.meterdisplay = 0 //also known as the meter percentage
		btl.meter = 0
		btl.barcolor = 7
		btl.metercolor = 132
		btl.meterlevel = 0
		btl.fullmeter = false
		btl.meterskill = false
		btl.timeresume = false
		btl.oop = nil
		btl.spearcount = 0
		
		/*if not mo.enemy --and mo.skin != "amy"
			if mo.hp > 0
				damageObject(mo, mo.hp, DMG_NORMAL)
				BTL_deadEnemiescleanse(btl)
			end
		end*/
	end
	
	//MAIN SHADOW THINKER
	if mo.enemy == "b_shadow"
		if btl.battlestate != BS_START then btl.shadowhud = true end
		btl.oop = mo
		mo.counter = $ or false
		mo.countercooldown = $ or 0
		mo.prevhp = $ or mo.hp
		mo.chargecooldown = $ or 0
		
		//shadow's super meter
		if (btl.meter*100)/btl.metermax > btl.meterdisplay and btl.meterdisplay*5/4 < btl.metermax/4
			btl.meterdisplay = btl.meterdisplay+1
		end
		if btl.meterdisplay*5/4 >= btl.metermax/4 and btl.meterlevel < 2
			for i = 1,2
				playSound(mo.battlen, sfx_s3kcas)
			end
			btl.meter = btl.meter - btl.metermax
			btl.meterdisplay = 0
			btl.meterlevel = $+1
		elseif btl.meterdisplay*5/4 >= btl.metermax/4 and btl.meterlevel >= 2 and not btl.fullmeter
			for i = 1,2
				playSound(mo.battlen, sfx_s3kcas)
			end
			btl.meterlevel = 3
			btl.metercolor = 47
			btl.meter = btl.metermax
			btl.fullmeter = true
		end
		if timestop and btl.meterdisplay == 0 and btl.meterlevel > 0
			btl.meterdisplay = 99
			btl.meterlevel = $-1
		end
		if btl.meterlevel == 0
			btl.barcolor = 7
			btl.metercolor = 98
		elseif btl.meterlevel == 1
			btl.barcolor = 98
			btl.metercolor = 73
		elseif btl.meterlevel == 2
			btl.barcolor = 73
			btl.metercolor = 38
		elseif btl.meterlevel == 3
			if btl.metercolor > 38 and leveltime%2 == 0
				btl.barcolor = 73
				btl.metercolor = $-1
			end
		end
		
		//meter build when you're hit
		if mo.hp < mo.prevhp
			btl.meter = btl.meter + (20 + (mo.prevhp - mo.hp)/10)
			mo.prevhp = mo.hp
		end
		
		//ZA WARUDO!! TOKI WO TOMORE!!!!
		if timestop
			btl.turnorder[1] = mo
			if leveltime%TICRATE == 0
				S_StartSound(nil, sfx_ctic)
			end
			btl.meter = 0
			if btl.meterdisplay != 0 or btl.meterlevel != 0
				if leveltime%3 == 0
					btl.meterdisplay = $-1
					btl.fullmeter = false
				end
			end
			S_PauseMusic()
		end

		//despawn spears if spear target dies
		if mo.spearset and #mo.spearset
			for i = 1, #mo.spearset do
				if mo.spearset[i] and mo.spearset[i].valid
					local spear = mo.spearset[i]
					local target = mo.spearset[i].target
					if target.hp <= 0
						local s = P_SpawnMobj(spear.x, spear.y, spear.z, MT_DUMMY)
						s.state = S_CHAOSSPEAREXPLOSION1
						P_RemoveMobj(spear)
						btl.spearcount = $ - target.doomspears
					end
				end
			end
		end
		
		//im am dead
		if mo.defeated
			if leveltime%2 == 0
				mo.shake = -1*FRACUNIT
			else
				mo.shake = 1*FRACUNIT
			end
			mo.flags2 = $|MF2_DONTDRAW
			local dummy = P_SpawnMobj(mo.x + mo.shake, mo.y + mo.shake, mo.z, MT_DUMMY)
			if mo.skin
				dummy.skin = mo.skin
			end
			dummy.state = mo.state
			dummy.sprite = mo.sprite
			dummy.sprite2 = mo.sprite2
			dummy.frame = mo.frame
			dummy.angle = mo.angle
			dummy.scale = mo.scale
			dummy.color = mo.color
			dummy.fuse = 2
		end
		
	else //thinker for everyone other than shadow
		mo.prevhp = $ or mo.hp
		mo.timestopdamage = $ or 0
		
		//testing hack: check stats
		/*if mo.skin == "sonic"
			print(mo.magic)
		end*/
		
		if timestop
			--mo.guard = false
			if mo.hp > 0
				mo.flags = $|MF_NOTHINK
			end
		else
			mo.flags = $ & ~MF_NOTHINK
		end
		
		//if we're damaged, that means he landed a hit, and if he lands a hit, HE GAINS METER!!1!!!1!1
		if mo.hp < mo.prevhp and not btl.meterskill 
			if mo.damaged
				local d = mo.damagestate		
				if d == DMG_WEAK or d == DMG_TECHNICAL or d == DMG_CRITICAL --wait but he's never gonna
					btl.meter = btl.meter + (40 + (mo.prevhp - mo.hp)/4)
				elseif d == DMG_NORMAL or d == DMG_RESIST
					btl.meter = btl.meter + (20 + (mo.prevhp - mo.hp)/5)
				end
				mo.prevhp = mo.hp
			else
				mo.prevhp = mo.hp
			end
		elseif mo.hp < mo.prevhp and btl.meterskill
			mo.prevhp = mo.hp
		end
		if mo.hp > mo.prevhp --if we heal
			mo.prevhp = mo.hp
		end
	end
end, MT_PFIGHTER)

//shut up fog, you're timestopped!
addHook("MobjThinker", function(mo)
	if mo.state != S_TNTDUST_7 return end
	if not server return end
	local btl = server.P_BattleStatus[1]
	if timestop
		mo.tics = -1
		mo.momx = 0
		mo.momy = 0
	elseif btl.timeresume
		mo.tics = 300
		mo.momx = P_RandomRange(2, -2)*FRACUNIT
		mo.momy = P_RandomRange(2, -2)*FRACUNIT
	end
end)

/*addHook("MapLoad", function()
	if not server return end
	shadowhud = false
	spearset = false
	metermax = 500 //125 on display
	meterdisplay = 0 //also know as the meter percentage
	meter = 0
	barcolor = 7
	metercolor = 132
	meterlevel = 0
	fullmeter = false
	meterskill = false
	timeresume = false
	oop = nil
	timestop = false
end)*/

hud.add(function(v)
	local btl = server.P_BattleStatus[1]
	if not btl return end
	local shadow = v.cachePatch("H_SMETER")
	if btl.battlestate == 0
		btl.shadowhud = false
	end
	if not btl.shadowhud return end
	if gamemap != 08 return end
	v.drawScaled(35*FRACUNIT, 47*FRACUNIT, FRACUNIT*3/4, shadow, V_SNAPTOLEFT|V_SNAPTOTOP)
	v.drawFill(18, 49, btl.metermax/4, 10, 15|V_SNAPTOLEFT|V_SNAPTOTOP) //background layer
	v.drawFill(20, 47, btl.metermax/4, 10, btl.barcolor|V_SNAPTOLEFT|V_SNAPTOTOP)
	v.drawFill(20, 47, btl.meterdisplay*5/4, 10, btl.metercolor|V_SNAPTOLEFT|V_SNAPTOTOP)
	v.drawString(140, 36, "Meter level: " + btl.meterlevel, V_REDMAP|V_SNAPTOLEFT|V_SNAPTOTOP, "thin-right")
end)

//event for resuming time
eventList["ev_shadow_timeresume"] = {
	[1] = {"function",
				function(evt, btl)
					local btl = server.P_BattleStatus[1]
					local oop = btl.oop
					if evt.ftimer == 10
						oop.speartargets = {}
						evt.speared = false
						playSound(oop.battlen, sfx_shaoa2)
					end
					
					if evt.ftimer == 60
						oop.renderflags = $ & ~RF_NOCOLORMAPS & ~RF_FULLBRIGHT
						timestop = false
						btl.timeresume = true
						S_ResumeMusic()
						P_LinedefExecute(1003)
						if oop.spearset and #oop.spearset
							for i = 1, #oop.spearset do
								if oop.spearset[i] and oop.spearset[i].valid
									local spear = oop.spearset[i]
									if spear.zamn --did spear get released during time stop?
										local target = spear.target
										evt.speared = true
										local tgtx = spear.x - 100*cos(spear.angle)
										local tgty = spear.y - 100*sin(spear.angle)
										if oop.speartargets and #oop.speartargets
											for k,v in ipairs(oop.speartargets)
												if v == target
													break
												end
												if k == #oop.speartargets and v != target
													oop.speartargets[#oop.speartargets+1] = target
												end
											end
										else
											oop.speartargets[#oop.speartargets+1] = target
										end
										spear.momx = (target.x - spear.x)/5
										spear.momy = (target.y - spear.y)/5
										spear.momz = (target.z - spear.z)/5
									end
								end
							end
						end
						if oop.effect and #oop.effect
							for i = 1, #oop.effect
								if oop.effect[i] and oop.effect[i].valid
									local effect = oop.effect[i]
									effect.tics = P_RandomRange(10, 35)
									effect.momz = effect.savemomz
									effect.color = SKINCOLOR_RED
								end
							end
						end
						for i = 1, #oop.enemies
							local target = oop.enemies[i]
							target.flags = $ & ~MF_NOTHINK
							if target.timestopdamage > 0 and target.timestopdamage != nil
								//cheating hwehehe
								if target.guard
									damageObject(target, target.timestopdamage*2)
								else
									damageObject(target, target.timestopdamage)
								end
								target.timestopdamage = 0
							end
						end
					end
					if evt.ftimer == 63
						playSound(oop.battlen, sfx_sprxpl)
						if oop.spearset and #oop.spearset
							for i = 1, #oop.spearset do
								if oop.spearset[i] and oop.spearset[i].valid
									local spear = oop.spearset[i]
									if spear.zamn
										local s = P_SpawnMobj(spear.x, spear.y, spear.z, MT_DUMMY)
										s.state = S_CHAOSSPEAREXPLOSION1
										P_RemoveMobj(spear)
									end
								end
							end
						end
						if evt.speared
							for i = 1, #oop.speartargets
								local target = oop.speartargets[i]
								damageObject(target, (target.speardamage*target.doomspears)/6)
								target.doomspears = 0
								target.speardamage = 0
							end
						end
					end
					if evt.ftimer > 80
						if btl.turnorder and #btl.turnorder
							for k,v in ipairs(btl.turnorder)
								if v.name == "Shadow"
									table.remove(btl.turnorder, k)
								end
							end
						end
					end
					if evt.ftimer == 105
						for i = 1, #oop.enemies
							local target = oop.enemies[i]
							if target and target.valid
								if target.saveagility
									target.agility = target.saveagility
								end
							end
						end
						oop.agility = oop.saveagility
						BTL_deadEnemiescleanse(btl)
						btl.timeresume = false
						btl.spearset = false
						btl.meterskill = false
						return true
					end
				end
			},
}