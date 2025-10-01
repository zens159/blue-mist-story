-- THAT IS BULLSH*T BLAZING NOW MY HEART IS BLAZING

---------- BATTLE -------------

---------- Stage 3: Blaze -------------

/*Just like her playable counter part, Blaze is focused on statuses and crippling the opponent, and while not
as power heavy as the first two, she can stall out a fight as her Pyro Boundary chips the team's hp away.
Armed with a Dekunda to cancel out any debuffs, the team will be forced to make a quick plan on going on the 
offensive while keeping their incinerating hp in check at the same time.*/

/*local firefield = false

addHook("MapLoad", function()
	if not server return end
	firefield = false
end)*/

enemyList["b_blaze"] = {
		name = "Blaze",
		skillchance = 100,	-- /100, probability of using a skill
		level = 100,
		hp = 8000,
		sp = 2000,
		strength = 45,
		magic = 70,
		endurance = 80,
		luck = 75,
		agility = 75,
		boss = true,
		turns = 2,
		weak = ATK_FIRE,
		resist = ATK_ICE|ATK_SLASH,
		r_exp = 0,
		
		persona = "penthesilea",
		skin = "blaze",			-- for "player" fights.
		color = SKINCOLOR_PASTEL,	-- for colormapping
		hudcutin = "BLAZ_A",	-- cut in
		hudspr = "BLAZ",	-- sprite prefix since hud can't retrieve it. yikes

		overlay = MT_SRB2P_BLAZETAIL,
		overlaythink = spr2_doblazetail,

		supercolor_start = SKINCOLOR_SUPERRED1,

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, B, A, B, A, B, A, B, 10, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, 1, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, E, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, A, B, C, D, E, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_CNT1"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, E, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets revived
		--anim_evoker =		{SPR_CSMN, A, B, 2},	-- holding evoker to head
		--anim_evoker_shoot =	{SPR_CSMN, C, 2},		-- shooting evoker

		anim_evoker = 		{SPR_PLAY, A, 8},
		anim_evoker_shoot = 		{SPR_PLAY, A, 8},

		anim_special1 = 	{SPR_PLAY, A, 1, "SPR2_TRNS"}, -- morbing start
		anim_special2 = 	{SPR_PLAY, G, 1, "SPR2_TRNS"}, -- morbing end
		anim_special3 = 	{SPR_PLAY, A, 1, "SPR2_GLID"}, -- fly/hover sorta
		anim_special4 = 	{SPR_PLAY, A, B, C, D, 3, "SPR2_RUN_"}, -- because anim_run doesn't work????
		anim_special5 = 	{SPR_PLAY, A, B, C, D, E, F, G, H, 5, "SPR2_WALK"}, -- awesome walking

		
		vfx_summon = {"sfx_blsum1", "sfx_blsum2"},
        vfx_skill = {"sfx_blskl1", "sfx_blskl2", "sfx_blskl3", "sfx_blskl4"},
        vfx_item = {"sfx_blskl1", "sfx_blskl2"},
        vfx_hurt = {"sfx_blhrt1", "sfx_blhrt2"},
        vfx_hurtx = {"sfx_blhrx1"},
        vfx_die = {"sfx_bldie1", "sfx_bldie2"},
        vfx_heal = {"sfx_blhel1", "sfx_blhel2", "sfx_blhel3"},
        vfx_healself = {"sfx_blkll1"},
        vfx_kill = {"sfx_blkll1", "sfx_blkll2", "sfx_blkll3"},
        vfx_1more = {"sfx_blkll1", "sfx_blkll2"},
        vfx_crit = {"sfx_blcrt1", "sfx_blcrt2", "sfx_blcrt3"},
        vfx_aoaask = {"sfx_blaoi1"},
        vfx_aoado = {"sfx_blcrt2", "sfx_blcrt3", "sfx_blsum2"},
        vfx_aoarelent = {"sfx_blaor1"},
        vfx_miss = {"sfx_blmis1", "sfx_blmis2"},
        vfx_dodge = {"sfx_bldge1", "sfx_bldge2"},
        vfx_win = {"sfx_blwin1", "sfx_blwin2", "sfx_blwin3"},
        vfx_levelup = {"sfx_bllvl1", "sfx_bllvl2"},

		icon = "ICO_BLAZ",	-- icon for net select and other menus
		hudbust = "BLA_H",			-- patch to draw on the stat hud
		hudbustlayer = "",		-- transparent patch to draw for status conditions
		hudaoa = "H_BLAAOA",	-- patch for all out attack hud
		hudcutin = "BLAZ_A",	-- cut in
		hudspr = "BLAZ",	-- sprite prefix since hud can't retrieve it. yikes
					
		skills = {"combustion strike", "orbs of eruption", "bufudyne", "mabufula", "fatal end", "tentarafoo", "impure reach", "dekunda"},
		
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
								mo.color = SKINCOLOR_PASTEL
							end
						end
						
						if mo.deathtimer == 60
							mo.color = SKINCOLOR_PASTEL
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
						end
						
						if mo.deathtimer == 100
							for i = 1, #mo.enemies
								local enemy = mo.enemies[i]
								enemy.status_condition = nil
							end
							playSound(mo.battlen, sfx_hamas2)
							btl.firefield = false
							P_LinedefExecute(1010)
						end
						
						if mo.deathtimer == 140
							mo.hp = 1
							mo.deathanim = nil
							D_startEvent(1, "blaze_defeat")
							return
						end
					end,
					
		//'s lot less complex than shadow... huh...
		thinker = function(mo)
			local btl = server.P_BattleStatus[mo.battlen]
			local singleattack = {"combustion strike", "bufudyne", "fatal end"}
			local nostatusattack = {"orbs of eruption", "mabufula", "bufudyne", "combustion strike", "fatal end"}
			local s = singleattack[P_RandomRange(1, #singleattack)]
			local n = nostatusattack[P_RandomRange(1, #nostatusattack)]
			if mo.hp <= 4500 and not btl.firefield 
				S_FadeOutStopMusic(1*MUSICRATE)
				return attackDefs["pyro boundary"], mo.enemies
			end
			mo.enemystatuses = 0
			if #mo.enemies == 1
				return attackDefs[s], {mo.enemies[P_RandomRange(1, #mo.enemies)]}
			end
			for i = 1, #mo.enemies
				local enemy = mo.enemies[i]
				if enemy.hp < 100
					return attackDefs[s], {enemy}
				end
				if enemy.status_condition != 0 and enemy.status_condition != nil
					mo.enemystatuses = $+1
					if mo.enemystatuses >= #mo.enemies-1
						//multi target bufudyne?!?!? multi target fatal end?!?!?!? not on my watch
						if n != nostatusattack[5] and n != nostatusattack[4] and n != nostatusattack[3]
							return attackDefs[n], mo.enemies
						else
							return attackDefs[n], {mo.enemies[P_RandomRange(1, #mo.enemies)]}
						end
					end
				end
			end
			return generalEnemyThinker(mo)
		end,
}

attackDefs["combustion strike"] = {
		name = "Combustion Strike",
		type = ATK_FIRE,
		power = 750,
		accuracy = 999,
		status = COND_BURN,
		statuschance = 12,
		costtype = CST_HP,
		cost = 20,
		anim_norepel = true,
		desc = "Charge yourself with heat and deal\nsevere fire damage to an enemy.\nModerate burn chance.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
				local btl = server.P_BattleStatus[mo.battlen]
				local target = hittargets[1]
				if timer == 1 and target == mo //failsafe anim if reflected
					for i = 1, #mo.enemies
						if mo.enemies[i].repelspr
							mo.harhar = mo.enemies[i]
						end
					end
				end
				if target == mo
					target = mo.harhar
				end
				P_SpawnGhostMobj(mo) --lol
				if timer < 50
					mo.slowdown = false
					target.oof = false
					mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
					local cam = btl.cam
					local tgtx = mo.x + 250*cos(mo.angle - ANG1*40)
					local tgty = mo.y + 250*sin(mo.angle - ANG1*40)
					cam.angle = (R_PointToAngle(mo.x, mo.y))
					CAM_goto(cam, tgtx, tgty, mo.z + 70*FRACUNIT)
					if timer == 1 then ANIM_set(mo, mo.anim_special4, true) end
				end
				if timer < 50
					if timer == 1 or timer == 13 or timer == 21 or timer == 28 or timer == 34 or timer == 39 or timer == 43 or timer == 47
						playSound(mo.battlen, sfx_spndsh)
					end
					local fuckunit = mo.scale
					local firescale = FRACUNIT
					if leveltime%2 == 0
						local fire1 = P_SpawnMobjFromMobj(mo, P_ReturnThrustX(mo.angle+FixedAngle(160*FRACUNIT), 20*FRACUNIT), P_ReturnThrustY(mo.angle+FixedAngle(160*FRACUNIT), 20*FRACUNIT), 0, MT_BLAZE_RUNFIRE)
						fire1.color = SKINCOLOR_BLAZING
						fire1.fuse = 20
						P_SetObjectMomZ(fire1, 2*fuckunit+fuckunit/2, false)
						fire1.momx = mo.momx*3/4
						fire1.momy = mo.momy*3/4
						P_Thrust(fire1, R_PointToAngle2(mo.x, mo.y, fire1.x, fire1.y), 5*fuckunit)
						fire1.angle = R_PointToAngle2(mo.x, mo.y, fire1.x, fire1.y)
						fire1.scale = firescale
						local fire2 = P_SpawnMobjFromMobj(mo, P_ReturnThrustX(mo.angle+FixedAngle(200*FRACUNIT), 20*FRACUNIT), P_ReturnThrustY(mo.angle+FixedAngle(200*FRACUNIT), 20*FRACUNIT), 0, MT_BLAZE_RUNFIRE)
						fire2.color = SKINCOLOR_BLAZING
						fire2.fuse = 20
						P_SetObjectMomZ(fire2, 2*fuckunit+fuckunit/2, false)
						fire2.momx = mo.momx*3/4
						fire2.momy = mo.momy*3/4
						P_Thrust(fire2, R_PointToAngle2(mo.x, mo.y, fire2.x, fire2.y), 5*fuckunit)
						fire2.angle = R_PointToAngle2(mo.x, mo.y, fire2.x, fire2.y)
						fire2.scale = firescale
					end
					if timer < 20
						firescale = FRACUNIT
					else
						localquake(mo.battlen, 2*FRACUNIT, 1)
						firescale = FRACUNIT*2
					end
					if timer < 35
						if leveltime%8 == 0
							local g = P_SpawnGhostMobj(mo)
							g.color = SKINCOLOR_BLAZING
							g.colorized = true
							g.destscale = FRACUNIT*4
						end
					else
						if leveltime%4 == 0
							local g = P_SpawnGhostMobj(mo)
							g.color = SKINCOLOR_BLAZING
							g.colorized = true
							g.scalespeed = FRACUNIT/6
							g.destscale = FRACUNIT*4
						end
					end
				end
				if timer >= 25 and timer < 50
					for i = 1, 2
						local fire = P_SpawnMobj(mo.x+P_RandomRange(-45, 45)*FRACUNIT, mo.y+P_RandomRange(-45, 45)*FRACUNIT, mo.z+P_RandomRange(0, 40)*FRACUNIT, MT_DUMMY)
						fire.sprite = SPR_FPRT
						fire.frame = $ & ~FF_TRANSMASK
						fire.frame = $|FF_FULLBRIGHT|TR_TRANS20
						fire.scale = FRACUNIT*2
						fire.scalespeed = FRACUNIT/2
						fire.destscale = 0
						fire.tics = TICRATE
					end
				end
				if timer >= 50
					if not mo.slowdown
						local effect = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						effect.tics = 1
						effect.sprite = SPR_FIRS
						effect.frame = S|FF_TRANS50
						effect.angle = mo.angle
					elseif mo.slowdown and not target.oof
						if leveltime%2 == 0
							local effect = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							effect.tics = 1
							effect.sprite = SPR_FIRS
							effect.frame = S|FF_TRANS50
							effect.angle = mo.angle
						end
					end
				end
				if timer == 50
					playSound(mo.battlen, sfx_wind1)
					mo.momx = (target.x - mo.x)/5
					mo.momy = (target.y - mo.y)/5
					localquake(mo.battlen, 10*FRACUNIT, 2)
					ANIM_set(mo, mo.anim_special3, true)
				end
				if timer >= 55
					//camera
					local cam = btl.cam
					local tgtx = target.x + 250*cos(target.angle - ANG1*60)
					local tgty = target.y + 250*sin(target.angle - ANG1*60)
					cam.angle = (R_PointToAngle(target.x, target.y))
					CAM_stop(cam)
					P_TeleportMove(cam, tgtx, tgty, target.z + 40*FRACUNIT)
					
					//teleport blaze in front
					if timer == 55
						local x = target.x + 600*cos(target.angle)
						local y = target.y + 600*sin(target.angle)
						P_TeleportMove(mo, x, y, target.z + 1*FRACUNIT)
						mo.flags = $|MF_NOGRAVITY
						mo.momx = (target.x - mo.x)/10
						mo.momy = (target.y - mo.y)/10
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
					end
					if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*80 and not mo.slowdown
						P_LinedefExecute(1001)
						mo.momx = $/18
						mo.momy = $/18
						for i = 1, #mo.enemies
							mo.enemies[i].flags = $|MF_NOTHINK
						end
						mo.slowdown = true
						playSound(mo.battlen, sfx_bufu3)
					end
					if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*20 and mo.slowdown
						if not btl.firefield
							P_LinedefExecute(1002) 
						else
							P_LinedefExecute(1009)
						end
						playSound(mo.battlen, sfx_megi5)
						ANIM_set(mo, mo.anim_atk, true)
						for i = 1, #mo.enemies
							mo.enemies[i].flags = $ & ~MF_NOTHINK
						end
						if target != mo.harhar
							damageObject(target)
						else
							damageObject(mo)
						end
						for k,v in ipairs(mo.enemies)
							if v and v.control and v.control.valid
								P_FlashPal(v.control, 1, 5) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
							end
						end
						mo.flags = $ & ~MF_NOGRAVITY
						P_InstaThrust(mo, target.angle, 10*FRACUNIT)
						mo.momz = 10*FRACUNIT
						target.oof = true
						if target.hp <= 0
							target.flags2 = $|MF2_DONTDRAW
						end
					end
					if target.oof and timer < 100
						if timer%8 == 0
							playSound(mo.battlen, sfx_fire1)
						end
						if mo.hp > 0
							ANIM_set(target, target.anim_hurt, false)
						end
						localquake(target.battlen, 4*FRACUNIT, 1)
						local tgtx = target.x - 250*cos(target.angle)
						local tgty = target.y - 250*sin(target.angle)
						for i = 1, 8
							local st = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							st.state = S_QUICKBOOM1
							st.scale = FRACUNIT/2
							--st.flags = $ & ~MF_NOGRAVITY
							st.momx = (tgtx - target.x)/5 + P_RandomRange(0, 50)*FRACUNIT
							st.momy = (tgty - target.y)/5 + P_RandomRange(0, 50)*FRACUNIT
							st.momz = P_RandomRange(0, 16)*FRACUNIT
							st.fuse = 20
						end
					end
				end
				if timer == 120
					mo.slowdown = false
					return true 
				end
			end,
}

attackDefs["orbs of eruption"] = {
		name = "Orbs of Eruption",
		type = ATK_FIRE,
		power = 400,
		accuracy = 100,
		status = COND_BURN,
		statuschance = 8,
		costtype = CST_SP,
		cost = 20,
		desc = "Heavy fire damage to all\nenemies. Slight burn chance.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
				if timer == 1
					ANIM_set(mo, mo.anim_special1, true)
					mo.flags = $|MF_NOGRAVITY
					mo.airpoint = mo.z + 100*FRACUNIT
					mo.balls = {} -- yes i am deliberately naming it balls you cannot stop me
				end
				if timer > 1 and timer < 70
					mo.momz = (mo.airpoint - mo.z)/8
				elseif timer == 70
					mo.flags = $ & ~MF_NOGRAVITY
				end
				if P_IsObjectOnGround(mo) and timer >= 70
					ANIM_set(mo, mo.anim_stand, true)
				end
				if timer == 20
					playSound(mo.battlen, sfx_hamas1)
					ANIM_set(mo, mo.anim_special2, true)
					for i = 1, #hittargets
						local orb = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						orb.sprite = SPR_PUMA
						orb.frame = A|FF_FULLBRIGHT
						orb.tics = -1
						orb.scale = FRACUNIT*2
						orb.destx = mo.x + P_RandomRange(-250, 250)*FRACUNIT
						orb.desty = mo.y + P_RandomRange(-250, 250)*FRACUNIT
						orb.destz = mo.z + P_RandomRange(100, 250)*FRACUNIT
						orb.target = hittargets[i]
						mo.balls[#mo.balls+1] = orb
					end
				end
				if mo.balls and #mo.balls
					for i = 1, #mo.balls
						local ball = mo.balls[i]
						if ball and ball.valid
							ball.rollangle = $+ANG1*20
							local e = P_SpawnGhostMobj(ball)
							e.spritexscale = ball.spritexscale
							
							if not (leveltime%2)
								local fire = P_SpawnMobj(ball.x+P_RandomRange(-45, 45)*ball.scale, ball.y+P_RandomRange(-45, 45)*FRACUNIT, ball.z+P_RandomRange(-30, 30)*ball.scale, MT_DUMMY)
								fire.sprite = SPR_FPRT
								fire.frame = $ & ~FF_TRANSMASK
								fire.frame = $|FF_FULLBRIGHT|TR_TRANS20
								fire.scale = mo.scale*5/2
								fire.momz = P_RandomRange(1, 3)*mo.scale
								fire.scalespeed = mo.scale/12
								fire.destscale = 1
								fire.tics = TICRATE
							end
							
							if timer < 50
								ball.momx = (ball.destx - ball.x)/6
								ball.momy = (ball.desty - ball.y)/6
								ball.momz = (ball.destz - ball.z)/6
							elseif timer >= 50
								ball.momx = (ball.target.x - ball.x)/6
								ball.momy = (ball.target.y - ball.y)/6
								if timer < 70
									ball.momz = ((ball.target.z + 150*FRACUNIT) - ball.z)/6
								end
							end
							
							local time = timer - 3*(i-1)
							if time == 70
								ball.momz = 20*FRACUNIT
							elseif time > 70
								ball.momz = $-3*FRACUNIT
								if ball.momz <= -8*FRACUNIT
									ball.spritexscale = $*95/100
								end
							end
							
							if ball.z <= ball.floorz
								damageObject(ball.target)
								ball.target.fired = true
								playSound(mo.battlen, sfx_megi5)
								P_RemoveMobj(ball)
							end
							
							for i = 1, #hittargets
								local target = hittargets[i]
								if target.fired and time < 120
									for i = 1, 12
										local boom = P_SpawnMobj(target.x + P_RandomRange(-48, 48)*FRACUNIT, target.y + P_RandomRange(-48, 48)*FRACUNIT, target.z, MT_DUMMY)
										boom.state = S_QUICKBOOM1
										boom.momz = P_RandomRange(0, 48)*FRACUNIT
										boom.scale = FRACUNIT*3/2
									end
								end
							end
						end
					end
				end
				if timer == 120 + 6*(#hittargets-1)
					for i = 1, #hittargets
						hittargets[i].fired = false
					end
					return true
				end
			end,
}

//this anim's especially messy!
attackDefs["pyro boundary"] = {
		name = "Pyro Boundary",
		type = ATK_SUPPORT,
		accuracy = 999,
		costtype = CST_SP,
		cost = 30,
		desc = "Create a field of surrounding flames\nthat slowly reduces opponents' hp",
		norepel = true,
		target = TGT_CASTER,
		buff = true,
		anim = function(mo, targets, hittargets, timer)
				local btl = server.P_BattleStatus[mo.battlen]
				local cam = btl.cam
				if timer == 1
					P_LinedefExecute(1004)
					mo.fireorbit = {}
					mo.flamecircle = {}
					mo.smallflame = {}
					mo.targetx = {}
					mo.targety = {}
					mo.startx = mo.x
					mo.starty = mo.y
					mo.airpoint = mo.z + 150*FRACUNIT
					playSound(mo.battlen, sfx_cutin)
					P_LinedefExecute(1003)
					mo.endurance = 80
				end
				
				if timer == 670
					for s in sectors.iterate do
						if s.tag == 6
							s.ceilingheight = 808*FRACUNIT
							s.ceilingpic = "F_SKY1"
						elseif s.tag == 4
							s.ceilingheight	= 360*FRACUNIT
							s.ceilingpic = "CEMENTW"
						end
					end
				end
				
				if timer < 670
					mo.renderflags = $|RF_NOCOLORMAPS
					mo.frame = $|FF_FULLBRIGHT
					for i = 1, #mo.enemies
						local target = mo.enemies[i]
						target.renderflags = $|RF_NOCOLORMAPS
						target.frame = $|FF_FULLBRIGHT
						if timer == 2
							mo.targetx[#mo.targetx+1] = target.x
							mo.targety[#mo.targety+1] = target.y
						end
					end
				end
				
				if timer < 40
					local tgtx = mo.x + 175*cos(mo.angle)
					local tgty = mo.y + 175*sin(mo.angle)
					cam.angle = (R_PointToAngle(mo.x, mo.y))
					CAM_goto(cam, tgtx, tgty, mo.z + 25*FRACUNIT)
				end
				
				if timer >= 40 and timer < 100
					local tgtx = mo.x + 20*cos(mo.angle - ANG1*90)
					local tgty = mo.y + 20*sin(mo.angle - ANG1*90)
					cam.angle = (R_PointToAngle(mo.x, mo.y))
					CAM_stop(cam)
					P_TeleportMove(cam, tgtx, tgty, mo.z - 20*FRACUNIT)
				end
				
				if timer == 50
					playSound(mo.battlen, sfx_blwin1)
					ANIM_set(mo, mo.anim_special5, true)
				end
				
				if timer == 80
					playSound(mo.battlen, sfx_s3k43)
					for i = 1, 2
						local ang = ANG1*(180*i-1)
						local tgtx = mo.x + 12*cos(mo.angle + ang)
						local tgty = mo.y + 12*sin(mo.angle + ang)
						local fire = P_SpawnMobj(tgtx, tgty, mo.z, MT_DUMMY)
						fire.scale = FRACUNIT/16
						fire.scalespeed = FRACUNIT/20
						fire.destscale = FRACUNIT/3
						fire.tics = -1
						fire.sprite = SPR_FPRT
						fire.flags = $|MF_NOGRAVITY
						fire.frame = A|FF_FULLBRIGHT
						fire.renderflags = $|RF_NOCOLORMAPS
						fire.dist = 1
						fire.angspeed = 1
						fire.tgtx = tgtx
						fire.tgty = tgty
						mo.fireorbit[#mo.fireorbit+1] = fire
					end
				end
				
				if timer >= 80 and timer%30 == 0 and timer < 580
					playSound(mo.battlen, sfx_s3k43)
				end
				
				if mo.fireorbit and #mo.fireorbit
					for i = 1, #mo.fireorbit
						local f = mo.fireorbit[i]
						local ang = ANG1*((180*i-1) + (timer-70)*5)
						
						if timer < 100
							f.tgtx = mo.x + 12*cos(mo.angle + ang)
							f.tgty = mo.y + 12*sin(mo.angle + ang)
						elseif timer >= 100
							f.tgtx = mo.x + (f.dist+65)*cos(mo.angle + ang + ANG1*f.angspeed)
							f.tgty = mo.y + (f.dist+65)*sin(mo.angle + ang + ANG1*f.angspeed)
							if timer == 100
								f.scale = FRACUNIT*2
							end
						end
						
						if timer >= 180
							if timer >= 250
								local e = P_SpawnGhostMobj(f)
								e.scale = f.scale/2
								e.frame = A|FF_FULLBRIGHT
								e.renderflags = $|RF_NOCOLORMAPS
							end
							if timer < 350
								f.dist = $+2
							end
							f.angspeed = $+2
							if timer == 180
								f.scalespeed = FRACUNIT/30
								f.destscale = FRACUNIT*10
							end
						end
						
						if timer >= 350 and timer%4 == 0 and timer < 530
							playSound(mo.battlen, sfx_s233)
							local flame = P_SpawnMobj(f.x, f.y, f.z, MT_FLAME)
							flame.tics = -1
							flame.scale = FRACUNIT
							flame.frame = $|FF_FULLBRIGHT
							flame.renderflags = $|RF_NOCOLORMAPS
							mo.flamecircle[#mo.flamecircle+1] = flame
						end
						
						if timer >= 530
							if f.dist > -65
								f.dist = $-5
							end
							
							f.momz = 8*FRACUNIT
							
							if timer == 530
								f.scalespeed = FRACUNIT/20
								f.destscale = FRACUNIT/50
							end
						end
						
						if timer < 400
							P_TeleportMove(f, f.tgtx, f.tgty, mo.z)
						else 
							P_TeleportMove(f, f.tgtx, f.tgty, f.z)
						end
					end
				end
				
				if timer >= 100
					local x = btl.arenacenter.x/FRACUNIT
					local y = btl.arenacenter.y/FRACUNIT
					mo.angle = R_PointToAngle2(mo.x, mo.y, x, y) + ANG1*180
					if timer == 150
						ANIM_set(mo, mo.anim_stand, true)
						mo.momx = 0
						mo.momy = 0
					elseif timer < 150
						P_InstaThrust(mo, mo.angle, 6*FRACUNIT)
					end
					local gox = btl.arena_coords[1] + 600*cos(ANG1*30)
					local goy = btl.arena_coords[2] + 600*sin(ANG1*30)
					P_TeleportMove(cam, gox, goy, mo.z + FRACUNIT*120)
					cam.angle = R_PointToAngle2(gox, goy, btl.arena_coords[1], btl.arena_coords[2])
					cam.aiming = ANG1*(-4)
					CAM_stop(cam)
				end
				
				if timer == 180
					playSound(mo.battlen, sfx_s3k42)
					localquake(mo.battlen, 5*FRACUNIT, 5)
					for i = 1,16
						local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 10*FRACUNIT)
						dust.color = SKINCOLOR_WHITE
						dust.scale = FRACUNIT/2
						dust.frame = A|FF_FULLBRIGHT
						dust.renderflags = $|RF_NOCOLORMAPS
					end
					ANIM_set(mo, mo.anim_special1, true)
				end
				
				if timer >= 190 and timer < 670
					if leveltime%6 == 0
						local g = P_SpawnGhostMobj(mo)
						g.color = SKINCOLOR_BLAZING
						g.colorized = true
						g.destscale = FRACUNIT*4
						g.frame = $|FF_FULLBRIGHT
						g.renderflags = $|RF_NOCOLORMAPS
					end
				end
				
				if timer == 400
					mo.flags = $|MF_NOGRAVITY
					mo.momz = 1*FRACUNIT
				end
				
				if timer >= 400
					if mo.z >= mo.airpoint
						mo.momz = 0
					end
				end
				
				if timer == 620
					playSound(mo.battlen, sfx_fire1)
					localquake(mo.battlen, 5*FRACUNIT, 3)
					P_LinedefExecute(1007)
				end
				
				if timer == 645
					playSound(mo.battlen, sfx_fire1)
					localquake(mo.battlen, 10*FRACUNIT, 3)
					P_LinedefExecute(1007)
				end
				
				if timer == 670
					S_ChangeMusic("stg3c")
					local strs = {"atk", "mag", "def", "agi", "crit"}
					for j = 1, #strs
						local s = strs[j]
						if mo.buffs[s][1] < 0
							mo.buffs[s][1] = 0
							mo.buffs[s][2] = 0
						end
					end
					BTL_logMessage(targets[1].battlen, "Firefield activated!")
					btl.firefield = true
					P_LinedefExecute(1008)
					playSound(mo.battlen, sfx_megi5)
					playSound(mo.battlen, sfx_fire2)
					playSound(mo.battlen, sfx_fire1)
					playSound(mo.battlen, sfx_blskl4)
					localquake(mo.battlen, 15*FRACUNIT, 45)
					ANIM_set(mo, mo.anim_special2, true)
					
					for i = 1, 50
						local x = P_RandomRange(3400, 6000)*FRACUNIT
						local y = P_RandomRange(1000, -1300)*FRACUNIT
						local boom = P_SpawnMobj(x, y, mo.floorz, MT_BOSSEXPLODE)
						boom.scale = FRACUNIT*3
						boom.state = S_PFIRE1
						
						for i = 1, #mo.targetx
							if R_PointToDist2(x, y, mo.targetx[i], mo.targety[i]) > 200*FRACUNIT and R_PointToDist2(x, y, mo.startx, mo.starty) > 200*FRACUNIT 
								local flame = P_SpawnMobj(x, y, mo.floorz, MT_FLAME)
								flame.tics = -1
								flame.scale = FRACUNIT*P_RandomRange(1, 3)
								flame.frame = $|FF_FULLBRIGHT
								break
							end
						end
						
						for i = 1, 3
							local smol = P_SpawnMobj(x, y, mo.floorz, MT_DUMMY)
							smol.state = S_CYBRAKDEMONNAPALMFLAME_FLY1
							smol.scale = FRACUNIT
							smol.momx = P_RandomRange(-20, 20)*FRACUNIT
							smol.momy = P_RandomRange(-20, 20)*FRACUNIT
							smol.momz = P_RandomRange(10, 20)*FRACUNIT
							smol.fuse = P_RandomRange(20, 35)
							mo.smallflame[#mo.smallflame+1] = smol
						end
					end	
					mo.frame = $ & ~FF_FULLBRIGHT
					mo.renderflags = $ & ~RF_NOCOLORMAPS
					for i = 1, #mo.enemies
						local target = mo.enemies[i]
						target.frame = $ & ~FF_FULLBRIGHT
						target.renderflags = $ & ~RF_NOCOLORMAPS
						ANIM_set(target, target.anim_hurt, false)
					end
				end
				
				if mo.smallflame and #mo.smallflame
					for i = 1, #mo.smallflame
						local smol = mo.smallflame[i]
						if smol and smol.valid
							smol.momz = $-1*FRACUNIT
						end
					end
				end
				
				if mo.flamecircle and #mo.flamecircle
					for i = 1, #mo.flamecircle
						local flame = mo.flamecircle[i]
						if flame and flame.valid
							if timer == 670
								P_RemoveMobj(flame)
							end
						end
					end
				end
				
				if timer == 750
					P_TeleportMove(mo, mo.x, mo.y, mo.floorz)
					mo.flags = $ & ~MF_NOGRAVITY
					mo.hp = 4500
					btl.linkhits = {}
					return true
				end
						
			end,
}

addHook("MobjThinker", function(mo)
	if mo.cutscene return end
	if gamemap != 09 return end
	mo.plsmercy = $ or false
	if mo.enemy and enemyList[mo.enemy].name != nil and mo.enemy == "b_blaze"
		if mo.hp <= 4500 and not mo.plsmercy
			mo.endurance = 400
			mo.plsmercy = true
		end
		return
	end
	local btl = server.P_BattleStatus[mo.battlen]
	
	btl.firefield = $ or false
	
	if btl.battlestate == 0
		btl.firefield = false
		mo.plsmercy = $ or false
	end
	
	//testing hack
	/*if btl.battlestate == BS_START
		if mo.plyr
			--mo.hp = 1
			--mo.tetrakarn = true
			btl.firefield = true
			mo.hp = 100
		end
	end
	if mo.plyr
		mo.passiveskills = {"endure"}
	end*/
	
	if btl.firefield
		local x = P_RandomRange(3400, 6000)*FRACUNIT
		local y = P_RandomRange(1000, -1300)*FRACUNIT
		local z = P_RandomRange(10, 800)*FRACUNIT
		local fire = P_SpawnMobj(x, y, z, MT_DUMMY)
		fire.sprite = SPR_FPRT
		fire.frame = $ & ~FF_TRANSMASK
		fire.frame = $|FF_FULLBRIGHT|TR_TRANS20
		fire.scale = mo.scale*5/2
		fire.momz = P_RandomRange(3, 6)*mo.scale
		fire.scalespeed = mo.scale/12
		fire.destscale = 1
		fire.tics = TICRATE
		
		mo.firedebuff = $ or false
		if leveltime%8 == 0
			if btl.turnorder[1] and btl.turnorder[1].valid
				/*print(btl.turnorder[1].name)
				print(btl.turnorder[1].attack)*/
				if btl.turnorder[1].enemy != "b_blaze" --and btl.battlestate != BS_ACTION //to prevent endure from being bypassed
					if mo.hp > 1
						mo.hp = $-1
					end
					if leveltime%16 == 0
						if mo.sp > 1
							mo.sp = $-1
						end
					end
				else
					if leveltime%16 == 0
						if mo.sp > 1
							mo.sp = $-1
						end
					end
				end
			end
		end
		if btl.turnorder[1] == mo and btl.battlestate == BS_DOTURN
			if leveltime%2 == 0 
				if mo.hp > 1
					mo.hp = $-1
				end
				if leveltime%4 == 0
					if mo.sp > 1
						mo.sp = $-1
					end
				end
			end
		end
		if mo.hp == 1 and not mo.firedebuff
			mo.buffs["mag"][1] = -75
			mo.buffs["agi"][1] = -75
			mo.buffs["def"][1] = -75
			mo.buffs["atk"][1] = -75
			BTL_logMessage(mo.battlen, mo.name.." is fatigued\nfrom the heat.")
			playSound(mo.battlen, sfx_absorb)
			mo.firedebuff = true
		elseif mo.hp > 1
			mo.firedebuff = false
		end
	end
end, MT_PFIGHTER)	

//despawn flame if its covering camera (doesnt work that well)
addHook("MobjThinker", function(mo)
	local btl = server.P_BattleStatus[1]
	if btl and btl.valid
		local cam = btl.cam
		if R_PointToDist2(mo.x, mo.y, cam.x, cam.y) < 180*FRACUNIT
			P_RemoveMobj(mo)
		end
	end
	if mo and mo.valid
		if not btl.firefield and btl.battlestate != BS_ACTION
			P_RemoveMobj(mo)
		end
	end
end, MT_FLAME)
