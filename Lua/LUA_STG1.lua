-- IT'S NO USE

---------- BATTLE -------------

---------- Stage 1: Silver -------------

/*Silver has very few gimmicks as a stage 1 boss, but he can drastically drain SP, as well as harness an 
element that Sonic is weak to. Additionally, when he's in a pinch, he'll gain maxed out defense and manifest 
his persona into a separate entity, assisting in battle. How can he do this? Because he's got awesome psychic
powers. Deal with it.*/

/*local phase = 1

addHook("MapLoad", function()
	if not server return end
	phase = 1
end)*/

enemyList["b_silver"] = {
		name = "Silver",
		skillchance = 100,	-- /100, probability of using a skill
		level = 100,
		hp = 5000,
		sp = 1200,
		strength = 50,
		magic = 130,
		endurance = 75,
		luck = 50,
		agility = 90,
		boss = true,
		turns = 2,
		weak = ATK_NUKE,
		resist = ATK_PSY,
		r_exp = 0,

		persona = "omoikane",
		skin = "silver",			-- for "player" fights.
		color = SKINCOLOR_AETHER,	-- for colormapping
		hudcutin = "SILV_A",	-- cut in
		hudspr = "SILV",

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, A, 30, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},
		anim_atk =			{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, F, E, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_CNT1"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},		-- gets revived
		anim_evoker =		{SPR_PLAY, A, 2, "SPR2_CSMN"},	-- uses evoker
		anim_evoker_shoot = {SPR_PLAY, B, A, 2, "SPR2_CSMN"},
		anim_special1 = {SPR_PLAY, C, 1, "SPR2_TRNS"}, -- transform charge
		anim_special2 = {SPR_PLAY, G, 1, "SPR2_TRNS"}, -- transform release

		vfx_summon = {"sfx_sisum1", "sfx_sisum2", "sfx_sisum3", "sfx_sisum4", "sfx_sisum5"},
		vfx_skill = {"sfx_siskl1", "sfx_siskl2", "sfx_siskl3"},
		vfx_item = {"sfx_siskl3"},
		vfx_hurt = {"sfx_sihrt1"},
		vfx_xhurt = {"sfx_sidie1"},
		vfx_die = {"sfx_sidie1"},
		vfx_heal = {"sfx_sikll3"},
		vfx_healself = {"sfx_sikll3"},
		vfx_kill = {"sfx_sikll1", "sfx_sikll2", "sfx_sikll3", "sfx_sikll4"},
		vfx_1more = {"sfx_si1mr1", "sfx_si1mr2"},
		vfx_crit = {"sfx_sicrt1", "sfx_sicrt2"},
		vfx_miss = {"sfx_simis1", "sfx_simis2", "sfx_simis3"},
		vfx_dodge = {"sfx_si1mr1", "sfx_sikll4"},
		vfx_win = {"sfx_siwin1", "sfx_siwin2"},
					
		//notta whole lotta skills HERE because his other skills need to be used under certain conditions
		skills = {"mapsio", "psiodyne"},
		
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
									COM_BufInsertText(p, "hu_partystatus off")
								end
							end
							mo.defeated = true
							P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
							if mo.allies[2] and mo.allies[2].valid and mo.allies[2].hp >= 0 
								damageObject(mo.allies[2], mo.allies[2].hp, DMG_NORMAL)
							end
							ANIM_set(mo, mo.anim_hurt, true)
							for k,v in ipairs(mo.enemies)
								if v and v.control and v.control.valid
									P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
								end
							end
							P_InstaThrust(mo, mo.angle, -30*FRACUNIT)
							playSound(mo.battlen, sfx_bbreak)
							mo.shake = $ or 2*FRACUNIT
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
								mo.color = SKINCOLOR_AETHER
							end
						end
						
						if mo.deathtimer == 60
							mo.color = SKINCOLOR_AETHER
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
							mo.defeated = false
							mo.flags2 = $ & ~MF2_DONTDRAW
							mo.deathanim = nil
							D_startEvent(1, "silver_defeat")
							return
						end
					end,
		
		thinker = function(mo)
			local btl = server.P_BattleStatus[mo.battlen]
			local attack = P_RandomRange(1, 4)
			if mo.hp <= 2500 and #mo.allies == 1
				return attackDefs["persona desync"], {mo}
			end
			if not mo.soullock and attack == 1
				return attackDefs["soul lock"], mo.enemies
			end
			if mo.soullock and attack == 1
				return attackDefs["soul drain"], mo.enemies
			end
			if table.maxn(mo.enemies) > 1 and attack == 2
				return attackDefs["telekinetic disorder"], mo.enemies
			end
			return generalEnemyThinker(mo)
		end,
}

enemyList["b_omoikane"] = {
		name = "Omoikane",
		skillchance = 100,	-- /100, probability of using a skill
		level = 100,
		hp = 5000,
		sp = 1200,
		strength = 50,
		magic = 150,
		endurance = 60,
		luck = 1,
		agility = 90,
		boss = true,
		turns = 1,
		weak = ATK_NUKE,
		resist = ATK_PSY,
		r_exp = 0,

		anim_stand = 		{SPR_PSNC, A, B, C, B, 8},
		anim_stand_hurt =	{SPR_PSNC, A, B, C, B, 8},
		anim_move =			{SPR_PSNC, A, B, C, B, 8},
		anim_run =			{SPR_PSNC, A, B, C, B, 8},
		anim_hurt =			{SPR_PSNC, A, B, C, B, 8},
		anim_getdown =		{SPR_PSNC, A, B, C, B, 8},
		anim_downloop =		{SPR_PSNC, A, B, C, B, 8},
		anim_getup =		{SPR_PSNC, A, B, C, B, 8},
																	
		skills = {"psycho force", "mapsiodyne", "empowering injury"},
		
		thinker = function(mo)
			local btl = server.P_BattleStatus[mo.battlen]
			for k,v in ipairs(mo.allies)
				if v.skin == "silver"
					mo.bufftarget = v
				end
			end
			if mo.timetobuff
				return attackDefs["hyper mamakakaja"], {mo.bufftarget}
			end
			return generalEnemyThinker(mo)
		end,
}

attackDefs["empowering injury"] = {
		name = "Empowering injury",
		type = ATK_PASSIVE,
		desc = "Buffs magic by 1 stage\nfor each hit you take.",
		passive = PSV_ONDAMAGE_RECEIVED,
		anim = 	function(mo, attacker)
					if mo.hp
						playSound(mo.battlen, sfx_buff)
						buffStat(mo, "mag")
						for i = 1,16
							local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							dust.angle = ANGLE_90 + ANG1* (22*(i-1))
							dust.state = S_CDUST1
							P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
							dust.color = SKINCOLOR_TEAL
							dust.scale = FRACUNIT*2
						end
					end
				end,
	}

attackDefs["hyper mamakakaja"] = {
		name = "Hyper Mamakakaja",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 40,
		desc = "Raise ally's magic \nattack to max.",
		target = TGT_ALLY, --formerly all allies
		buff = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["mag"][1] >= 75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			--for i = 1, #targets do
				local target = targets[1]
				if timer == 1
					mo.timetobuff = false
					target.dbs = {}
					playSound(mo.battlen, sfx_debuff)
					for i = 1, 20
						local energy = P_SpawnMobj(target.x-P_RandomRange(140,-140)*FRACUNIT, target.y-P_RandomRange(140,-140)*FRACUNIT, target.z+P_RandomRange(140, 0)*FRACUNIT, MT_SUPERSPARK)
						energy.scale = FRACUNIT/2
						energy.tics = 200
						energy.momx = (target.x - energy.x)/190
						energy.momy = (target.y - energy.y)/190
						energy.momz = (target.z - energy.z)/190
						target.dbs[#target.dbs+1] = energy
					end
				end
				if timer == 100
					if target.dbs and #target.dbs
						for i = 1, #target.dbs do
							local energy = target.dbs[i]
							if not energy or not energy.valid continue end	-- don't care
							energy.momz = FRACUNIT*20
						end
					end
					localquake(mo.battlen, FRACUNIT*20, TICRATE/2)
					for k,v in ipairs(mo.enemies)
						if v and v.control and v.control.valid
							P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
					end
					playSound(mo.battlen, sfx_buff2)
					playSound(mo.battlen, sfx_hamas2)
					buffStat(target, "mag", 150)
					for i = 1,15
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_WHITE
						dust.scale = FRACUNIT*3
					end

				elseif timer > 100 and timer <= 150
					
					if leveltime%2 == 0
						for i = 1,20
							local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							dust.angle = ANGLE_90 + ANG1* (22*(i-1))
							dust.state = S_CDUST1
							P_InstaThrust(dust, dust.angle, 40*FRACUNIT)
							dust.color = SKINCOLOR_WHITE
							dust.scale = FRACUNIT
						end
					end

					for i = 1,4

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
				elseif timer == 175
					return true
				end
			--end
		end,
}

attackDefs["soul lock"] = {
		name = "Soul Lock",
		type = ATK_ALMIGHTY,
		power = 1,
		accuracy = 999,
		costtype = CST_SP,
		cost = 30,
		showsp = true,
		desc = "Set a link that drains 200 SP\nfrom 1 enemy and lowers magic\nstat upon activation.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					if timer >= 1 and timer < 30
						if timer == 1
							mo.lock = {}
							playSound(mo.battlen, sfx_s3k8c)
						end
						if leveltime%3 == 0
							mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
							for i = 1, 30
								local tgtx = mo.x + (i*30)*cos(mo.angle)
								local tgty = mo.y + (i*30)*sin(mo.angle)
								local e = P_SpawnMobj(tgtx, tgty, mo.z+25*FRACUNIT, MT_DUMMY)
								e.state = S_THOK
								e.color = SKINCOLOR_GREY
								e.frame = FF_FULLBRIGHT
								e.scale = FRACUNIT/5
								e.tics = 1
							end
						end
					end
					if timer == 30
						mo.soullock = true
						target.soultarget = true
						ANIM_set(target, target.anim_hurt, false)
						playSound(mo.battlen, sfx_s3ka6)
						playSound(mo.battlen, sfx_s3k76)
						playSound(mo.battlen, sfx_s3k9c)
						if target.hp > 1 then damageObject(target, 1) else damageObject(target, 0) end
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						for i = 1, 30
							local tgtx = mo.x + (i*30)*cos(mo.angle)
							local tgty = mo.y + (i*30)*sin(mo.angle)
							local e = P_SpawnMobj(tgtx, tgty, mo.z, MT_THOK)
							e.state = S_THOK
							e.tics = -1
							e.color = SKINCOLOR_WHITE
							e.frame = FF_FULLBRIGHT
							e.destscale = FRACUNIT/10
							e.scalespeed = e.scale/8
							mo.lock[#mo.lock+1] = e
						end
					elseif timer == 60
						return true
					end
				end,
}

attackDefs["soul drain"] = {
		name = "Soul Drain",
		type = ATK_ALMIGHTY,
		power = 1,
		accuracy = 999,
		costtype = CST_SP,
		cost = 30,
		showsp = true,
		desc = "Drain 200 SP from 1 enemy\nand lowers magic stat.",
		target = TGT_ALLENEMIES,
		nocast = function(mo, n)
			if not mo.soullock
				BTL_logMessage(mo[1].battlen, "Soul lock not in effect.")
				return true
			end
		end,
		anim = function(mo, targets, hittargets, timer)
					for i = 1, #hittargets
						local target = hittargets[i]
						if target.soultarget
							ANIM_set(target, target.anim_hurt)
							if timer >= 1 and timer <= 40
								if timer == 1 then S_StartSound(mo, sfx_s3kcal) end
								for i = 1,2
									local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
									thok.color = SKINCOLOR_BLUE
									thok.momx = P_RandomRange(-10, 10)*FRACUNIT
									thok.momy = P_RandomRange(-10, 10)*FRACUNIT
									thok.momz = P_RandomRange(-10, 10)*FRACUNIT
									thok.scale = FRACUNIT/10
									thok.destscale = FRACUNIT/5
								end
								localquake(mo.battlen, FRACUNIT*2, 1)
							end
							if timer == 40
								S_StopSound(mo, sfx_s3kcal)
								localquake(mo.battlen, FRACUNIT*20, 5)
								target.psiodyne = {}
								playSound(mo.battlen, sfx_absorb)
								playSound(mo.battlen, sfx_s3ka8)
								buffStat(target, "mag", -25)
								damageSP(target, 200)
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
								playSound(mo.battlen, sfx_hamas2)
								playSound(mo.battlen, sfx_buff)
								damageSP(mo, -200)
								buffStat(mo, "mag", 25)
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
								local function spawnaura(t)
									local overlay = P_SpawnMobjFromMobj(t, 0, 0, 0, MT_DUMMY)
									overlay.sprite = t.sprite
									if t.sprite2 and t.skin
										overlay.skin = t.skin
										overlay.sprite2 = t.sprite2
									end
									overlay.frame = (t.frame & FF_FRAMEMASK)|FF_FULLBRIGHT|TR_TRANS50
									overlay.colorized = true
									overlay.color = SKINCOLOR_AQUA
									overlay.height = t.height
									overlay.angle = t.angle
									overlay.tics = 2
								end
								spawnaura(mo)
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
								mo.soullock = false
								target.soultarget = false
								return true 
							end
						end
					end
				end,
}

attackDefs["telekinetic disorder"] = {
		name = "Telekinetic Disorder",
		type = ATK_ALMIGHTY,
		desc = "Lifts one opponent in the air and launches\nthem at their teammate, hitting both.",
		accuracy = 999,
		power = 400,
		costtype = CST_SP,
        cost = 0,
        target = TGT_ALLENEMIES,
		nocast = function(targets, n)
			local target = targets[n]
			if #target.allies < 2
				BTL_logMessage(targets[1].battlen, "Need more than two people.")
				return true
			end
		end,
		anim = function(mo, targets, hittargets, timer)
				local btl = server.P_BattleStatus[mo.battlen]
				local cam = btl.cam
				if timer == 1
					mo.launchnum = P_RandomRange(1, #hittargets)
					mo.poornum = P_RandomRange(1, #hittargets)
					local target = mo.targets[1]
					local an = ANG1* P_RandomRange(10, 35)
					local gox = target.x + 800*cos(target.angle+an)
					local goy = target.y + 800*sin(target.angle+an)
					P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*80)	-- teleport the camera to a nice spot
					cam.angle = R_PointToAngle2(gox, goy, target.x, target.y)
					cam.aiming = ANG1*(-3)
					CAM_stop(cam)
				end
				
				if mo.poornum == mo.launchnum
					if mo.launchnum != 1
						mo.poornum = 1
					else
						mo.poornum = P_RandomRange(2, #hittargets)
					end
				end
				if timer >= 2
					mo.launchtarget = hittargets[mo.launchnum]
					mo.poortarget = hittargets[mo.poornum]
					local ltarget = mo.launchtarget
					local ptarget = mo.poortarget
					ltarget.shake = $ or 0

					ANIM_set(mo, mo.anim_stand_bored)
					ANIM_set(ltarget, ltarget.anim_hurt)

					local function spawnaura(t)
						local overlay = P_SpawnMobjFromMobj(t, 0, 0, 0, MT_DUMMY)
						overlay.sprite = t.sprite
						if t.sprite2 and t.skin
							overlay.skin = t.skin
							overlay.sprite2 = t.sprite2
						end
						overlay.frame = (t.frame & FF_FRAMEMASK)|FF_FULLBRIGHT|TR_TRANS50
						overlay.colorized = true
						overlay.color = SKINCOLOR_AQUA
						overlay.height = t.height
						overlay.angle = t.angle
						overlay.tics = 2
					end

					spawnaura(mo)

					if timer == 2
						playSound(mo.battlen, sfx_s3k74)
						ltarget.lifted = true
					end
					if timer == 35
						playSound(mo.battlen, sfx_s3k6f)
						ltarget.rumble = true
					end
					if ltarget.rumble
						if leveltime%2 == 0
							ltarget.shake = -4*FRACUNIT
						else
							ltarget.shake = 4*FRACUNIT
						end
						ltarget.flags2 = $|MF2_DONTDRAW
						local dummy = P_SpawnMobj(ltarget.x + ltarget.shake, ltarget.y + ltarget.shake, ltarget.z, MT_DUMMY)
						if ltarget.skin
							dummy.skin = ltarget.skin
						end
						dummy.state = ltarget.state
						dummy.sprite = ltarget.sprite
						dummy.sprite2 = ltarget.sprite2
						dummy.frame = (ltarget.frame & FF_FRAMEMASK)|FF_FULLBRIGHT
						dummy.angle = ltarget.angle
						dummy.scale = ltarget.scale
						dummy.color = SKINCOLOR_AQUA
						dummy.fuse = 1
					end

					if ltarget.lifted
						spawnaura(ltarget)
					end
					if timer < 50
						ltarget.momz = (ltarget.floorz + FRACUNIT*192 - ltarget.z)/8
					elseif timer == 50
						ltarget.rumble = false
						ltarget.flags2 = $ & ~MF2_DONTDRAW
						ltarget.momx = (ptarget.x - ltarget.x)/5
						ltarget.momy = (ptarget.y - ltarget.y)/5
						ltarget.momz = (ptarget.z - ltarget.z)/5
					end
					if R_PointToDist2(ptarget.x, ptarget.y, ltarget.x, ltarget.y) < FRACUNIT*20 and ltarget.lifted
						damageObject(ltarget)
						damageObject(ptarget)
						for i = 1,32
							local dust = P_SpawnMobj(ptarget.x, ptarget.y, ptarget.z, MT_DUMMY)
							dust.angle = ANGLE_90 + ANG1* (11*(i-1))
							dust.destscale = FRACUNIT*10
							dust.state = S_AOADUST1
							dust.frame = A|FF_FULLBRIGHT
							P_InstaThrust(dust, dust.angle, 20*FRACUNIT)
						end
						playSound(mo.battlen, sfx_s3k5f)
						localquake(mo.battlen, FRACUNIT*32, TICRATE/2)
						ltarget.lifted = false
						if ltarget.hp > 0
							ltarget.speen = true
							ltarget.momx = $/12
							ltarget.momy = $/12
							ltarget.momz = 12*FRACUNIT
						else
							ltarget.flags2 = $|MF2_DONTDRAW
						end
					end
					if ltarget.speen
						local s = P_SpawnMobj(ltarget.x + P_RandomRange(-64, 64)*FRACUNIT, ltarget.y + P_RandomRange(-32, 32)*FRACUNIT, ltarget.z + P_RandomRange(0, 64)*FRACUNIT, MT_THOK)
						s.state = S_AOADUST1
						s.scale = $/2
						ltarget.rollangle = $+ANG1*40
					end
					if timer == 95
						ltarget.speen = false
						ltarget.rollangle = 0
						return true
					end
				end
			end,
}

attackDefs["persona desync"] = {
		name = "Persona Desync",
		type = ATK_SUPPORT,
		desc = "Creates a separate persona enemy that fights alongside with you.",
		accuracy = 100,
		costtype = CST_SP,
        cost = 30,
        target = TGT_CASTER,
		anim = function(mo, targets, hittargets, timer)
				local btl = server.P_BattleStatus[mo.battlen]
				local cx = btl.arena_coords[1]
				local cy = btl.arena_coords[2]
				local dist = R_PointToDist2(cx, cy, mo.x, mo.y)/FRACUNIT
				local ang = R_PointToAngle2(cx, cy, mo.x, mo.y) + ANG1*(30)
				local pdestx = cx + dist*cos(ang)
				local pdesty = cy + dist*sin(ang)
				local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}
				if timer < 140 and timer >= 1
					summonAura(mo, SKINCOLOR_TEAL)
					if timer == 1
						mo.endurance = 75
						mo.energyspeed = 30
						playSound(mo.battlen, sfx_debuff)
						playSound(mo.battlen, sfx_s3ka1)
					end
					if timer >= 100
						localquake(mo.battlen, FRACUNIT*2, 1)
					end
					ANIM_set(mo, mo.anim_special1, true)
					local cam = server.P_BattleStatus[mo.battlen].cam
					local tgtx = mo.x + 256*cos(mo.angle)
					local tgty = mo.y + 256*sin(mo.angle)
					cam.angle = (R_PointToAngle(mo.x, mo.y))
					CAM_goto(cam, tgtx, tgty, mo.z + 50*FRACUNIT)
					if mo.energyspeed > 1 and leveltime%4 == 0 then mo.energyspeed = $-1 end
					if leveltime%2 == 0
						for i = 1,16
							mo.energy = P_SpawnMobj(mo.x-P_RandomRange(140,-140)*FRACUNIT, mo.y-P_RandomRange(140,-140)*FRACUNIT, mo.z-P_RandomRange(140,-140)*FRACUNIT, MT_DUMMY)
							mo.energy.fangle = (R_PointToAngle(mo.x, mo.y))
							mo.energy.sprite = SPR_PSID
							mo.energy.scale = FRACUNIT
							if P_RandomRange(1,4) == 1
								mo.energy.frame = A|FF_FULLBRIGHT|TR_TRANS20
							elseif P_RandomRange(1,4) == 2
								mo.energy.frame = B|FF_FULLBRIGHT|TR_TRANS20
							elseif P_RandomRange(1,4) == 3
								mo.energy.frame = C|FF_FULLBRIGHT|TR_TRANS20
							elseif P_RandomRange(1,4) == 4
								mo.energy.frame = D|FF_FULLBRIGHT|TR_TRANS20
							end
							mo.energy.color = psiocolors[P_RandomRange(1,5)]
							mo.energy.momx = (mo.x - mo.energy.x)/mo.energyspeed
							mo.energy.momy = (mo.y - mo.energy.y)/mo.energyspeed
							mo.energy.momz = (mo.z - mo.energy.z)/mo.energyspeed
						end
					end
					if mo.energy and mo.energy.valid
						if R_PointToDist2(mo.energy.x, mo.energy.y, mo.x, mo.y) < FRACUNIT*50
							P_RemoveMobj(mo.energy)
						end
					end
				elseif timer >= 140
					summonAura(mo, SKINCOLOR_TEAL)
					ANIM_set(mo, mo.anim_special2, true)
					if timer == 140
						buffStat(mo, "def", 150)
						mo.persona = nil
						local g = P_SpawnGhostMobj(mo)
						g.colorized = true
						g.destscale = mo.scale*4
						g.scalespeed = mo.scale/8
						for k,v in ipairs(mo.enemies)
							if v and v.control and v.control.valid
								P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
							end
						end
						playSound(mo.battlen, sfx_s3k9f)
					end
					if not mo.omoikane or not mo.omoikane.valid
						mo.omoikane = BTL_spawnEnemy(mo, "b_omoikane")
						mo.omoikane.scale = FRACUNIT*12/10
						mo.omoikane.timetobuff = true
						--buffStat(mo.omoikane, "def", 150)
						local g = P_SpawnGhostMobj(mo.omoikane)
						g.colorized = true
						g.destscale = mo.scale*4
						g.scalespeed = mo.scale/8
						for i = 1,16
							local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							dust.angle = ANGLE_90 + ANG1* (22*(i-1))
							dust.state = S_CDUST1
							P_InstaThrust(dust, dust.angle, 15*FRACUNIT)
							dust.color = SKINCOLOR_WHITE
							dust.scale = FRACUNIT
						end
						local cam = server.P_BattleStatus[mo.battlen].cam
						local an = ANG1* P_RandomRange(10, 35)
						local gox,goy

						gox = mo.omoikane.x + 300*cos(mo.omoikane.angle+an)
						goy = mo.omoikane.y + 300*sin(mo.omoikane.angle+an)

						--P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*40)	-- teleport the camera to a nice spot
						CAM_goto(cam, gox, goy, mo.z + FRACUNIT*40)
						CAM_angle(cam, R_PointToAngle2(gox, goy, mo.omoikane.x, mo.omoikane.y))
						CAM_aiming(cam, 0)
					else
						summonAura(mo.omoikane, SKINCOLOR_TEAL)
					end
				end
				if timer == 180
					mo.hp = 2500
					mo.omoikane.hp = 2000
					btl.phase = 2
					btl.linkhits = {}
					return true 
				end
			end,
}

//main thinker
addHook("MobjThinker", function(mo)
	if mo.cutscene return end --make sure cutscene MT_PFIGHTERs arent affected
	if not (mapheaderinfo[gamemap].bluemiststory) return end
	local btl = server.P_BattleStatus[mo.battlen]
	//if btl.battlestate == 0 return end
	if gamemap == 07
		mo.plsmercy = $ or false
		if btl.battlestate == 0
			btl.phase = $ or 1
			mo.plsmercy = false
			return
		end
		
		//TESTING HACKS
		/*if btl.battlestate == BS_START
			btl.emeraldpow = 300
		end*/
		/*if btl.battlestate == BS_START
			if not mo.enemy --and mo.skin != "amy"
				if mo.hp > 0
					damageObject(mo, mo.hp, DMG_NORMAL)
					BTL_deadEnemiescleanse(btl)
				end
				mo.hp = mo.maxhp*2/3
			end
		end*/
		
		/*if btl.phase == 2
			if mo.enemy
				mo.turns = 1
			end
		end*/
		
		//removes soul lock if soul locked guy is ded
		if mo.hp <= 0 and mo.soultarget
			mo.soultarget = false
			mo.enemies[1].soullock = false
		end
		if mo.enemy == nil return end
		if enemyList[mo.enemy].name != nil and mo.enemy == "b_silver"
			if not mo.soullock or mo.defeated
				if mo.lock and #mo.lock
					for i = 1, #mo.lock do
						if mo.lock[i] and mo.lock[i].valid
							P_RemoveMobj(mo.lock[i])
						end
					end
				end
			end
			if mo.hp <= 2500 and not mo.plsmercy
				mo.endurance = 400
				mo.plsmercy = true
			end
			//make silver throw a hissy fit if omoikane is dead
			if btl.phase == 2 and not mo.defeated
				if mo.allies[2]
					if mo.allies[2].hp <= 0
						damageObject(mo, mo.hp, DMG_NORMAL)
					end
				end
			end
		end
	end
	//i guess this one goes for all chars
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
end, MT_PFIGHTER)