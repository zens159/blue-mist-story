-- 01001011010010010100110001001100001000000101100101001111010101010101001001010011010001010100110001000110

---------- BATTLE -------------

---------- Stage 4: Badnik Army -------------

/*These are constant waves of several mysteriously emerald powered badniks, where the team is forced to fend 
them off for long enough to ride the elevator down and survive the ambushes and onslaughts. That's about it.
There's less effort that I put into this than I probably should have...*/

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

itemDefs["maragidyne gem"] = {
		name = "Maragidyne Gem",
		desc = "Cast Maragidyne",
		attack = "maragidyne",
		nouse = true,
		cost = 350,
		rarity = 5,
	}

itemDefs["maziodyne gem"] = {
		name = "Maziodyne Gem",
		desc = "Cast Maziodyne",
		attack = "maziodyne",
		nouse = true,
		cost = 350,
		rarity = 5,
	}

itemDefs["magarudyne gem"] = {
		name = "Magarudyne Gem",
		desc = "Cast Magarudyne",
		attack = "magarudyne",
		nouse = true,
		cost = 350,
		rarity = 5,
	}

itemDefs["mapsiodyne gem"] = {
		name = "Mapsiodyne Gem",
		desc = "Cast Mapsiodyne",
		attack = "mapsiodyne",
		nouse = true,
		cost = 350,
		rarity = 5,
	}

itemDefs["pralaya gem"] = {
		name = "Pralaya Gem",
		desc = "Cast Pralaya",
		attack = "pralaya",
		nouse = true,
		cost = 350,
		rarity = 4,
	}

enemyList["jetty bomber"] = {
		name = "Jetty-Syn Bomber",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 400,
		sp = 200,
		strength = 10,
		magic = 50,
		endurance = 40,
		luck = 40,
		agility = 60,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_NUKE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_JETB, A, B, 4},
		anim_stand_hurt =	{SPR_JETB, A, B, 4},
		anim_move =			{SPR_JETB, A, B, 4},
		anim_run =			{SPR_JETB, A, B, 4},
		anim_hurt =			{SPR_JETB, A, B, 4},
		anim_getdown =		{SPR_JETB, A, B, 4},
		anim_downloop =		{SPR_JETB, A, B, 4},
		anim_getup =		{SPR_JETB, A, B, 4},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"freidyne", "moondrop", "flame link"},
		
		r_drops = {
			{"agidyne gem", 10},
			{"garudyne gem", 10},
			{"ziodyne gem", 10},
			{"psiodyne gem", 10},
			{"pralaya gem", 10},
			{"holy scroll", 10},
			{"maragidyne gem", 5},
			{"magarudyne gem", 5},
			{"maziodyne gem", 5},
			{"mapsiodyne gem", 5},
			{"assault signal", 10},
			{"casting signal", 10},
			{"guarding signal", 10},
			{"speedup signal", 10},
		},
		
		deathanim = function(mo)
						badnikDeath(mo)
					end,
	}

enemyList["jetty gunner"] = {
		name = "Jetty-Syn Gunner",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 400,
		sp = 200,
		strength = 40,
		magic = 10,
		endurance = 40,
		luck = 40,
		agility = 60,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_PIERCE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_JETG, A, B, 4},
		anim_stand_hurt =	{SPR_JETG, A, B, 4},
		anim_move =			{SPR_JETG, A, B, 4},
		anim_run =			{SPR_JETG, A, B, 4},
		anim_hurt =			{SPR_JETG, A, B, 4},
		anim_getdown =		{SPR_JETG, A, B, 4},
		anim_downloop =		{SPR_JETG, A, B, 4},
		anim_getup =		{SPR_JETG, A, B, 4},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"heavy shot", "poison arrow", "flame link"},
		
		r_drops = {
			{"agidyne gem", 10},
			{"garudyne gem", 10},
			{"ziodyne gem", 10},
			{"psiodyne gem", 10},
			{"pralaya gem", 10},
			{"holy scroll", 10},
			{"maragidyne gem", 5},
			{"magarudyne gem", 5},
			{"maziodyne gem", 5},
			{"mapsiodyne gem", 5},
			{"assault signal", 10},
			{"casting signal", 10},
			{"guarding signal", 10},
			{"speedup signal", 10},
		},
		
		deathanim = function(mo)
						badnikDeath(mo)
					end,	
	}
	
enemyList["robo hood"] = {
		name = "Robo Hood",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 600,
		sp = 200,
		strength = 60,
		magic = 10,
		endurance = 40,
		luck = 60,
		agility = 60,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_PIERCE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ARCH, A, 4},
		anim_stand_hurt =	{SPR_ARCH, A, 4},
		anim_move =			{SPR_ARCH, A, 4},
		anim_run =			{SPR_ARCH, A, 4},
		anim_hurt =			{SPR_ARCH, A, 4},
		anim_getdown =		{SPR_ARCH, A, 4},
		anim_downloop =		{SPR_ARCH, A, 4},
		anim_getup =		{SPR_ARCH, A, 4},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"torrent shot", "gale slash", "vile assault", "gale link"},
		
		r_drops = {
			{"agidyne gem", 10},
			{"garudyne gem", 10},
			{"ziodyne gem", 10},
			{"psiodyne gem", 10},
			{"pralaya gem", 10},
			{"holy scroll", 10},
			{"maragidyne gem", 5},
			{"magarudyne gem", 5},
			{"maziodyne gem", 5},
			{"mapsiodyne gem", 5},
			{"assault signal", 10},
			{"casting signal", 10},
			{"guarding signal", 10},
			{"speedup signal", 10},
		},
		
		deathanim = function(mo)
						badnikDeath(mo)
					end,	
	}

//make 2nd defensive phase like in the game?
enemyList["crawla commander"] = {
		name = "Crawla Commander",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 800,
		sp = 300,
		strength = 60,
		magic = 65,
		endurance = 40,
		luck = 40,
		agility = 70,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_PIERCE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_CCOM, A, B, C, D, 1},
		anim_stand_hurt =	{SPR_CCOM, A, B, C, D, 1},
		anim_move =			{SPR_CCOM, A, B, C, D, 1},
		anim_run =			{SPR_CCOM, A, B, C, D, 1},
		anim_hurt =			{SPR_CCOM, A, B, C, D, 1},
		anim_getdown =		{SPR_CCOM, A, B, C, D, 1},
		anim_downloop =		{SPR_CCOM, A, B, C, D, 1},
		anim_getup =		{SPR_CCOM, A, B, C, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"heavy shot", "grydyne", "life siphon", "stardrop", "bolt link"},
		
		r_drops = {
			{"agidyne gem", 10},
			{"garudyne gem", 10},
			{"ziodyne gem", 10},
			{"psiodyne gem", 10},
			{"pralaya gem", 10},
			{"holy scroll", 10},
			{"maragidyne gem", 5},
			{"magarudyne gem", 5},
			{"maziodyne gem", 5},
			{"mapsiodyne gem", 5},
			{"assault signal", 10},
			{"casting signal", 10},
			{"guarding signal", 10},
			{"speedup signal", 10},
		},
		
		deathanim = function(mo)
						badnikDeath(mo)
					end,	
	}
	
enemyList["facestabber"] = {
		name = "FaceStabber",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 500,
		sp = 200,
		strength = 60,
		magic = 10,
		endurance = 90,
		luck = 20,
		agility = 70,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_SLASH,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_stand_hurt =	{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_move =			{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_run =			{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_hurt =			{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_getdown =		{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_downloop =		{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_getup =		{SPR_CBFS, A, B, C, D, E, F, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"brave blade", "vile assault", "blade of fury"},
		
		r_drops = {
			{"agidyne gem", 10},
			{"garudyne gem", 10},
			{"ziodyne gem", 10},
			{"psiodyne gem", 10},
			{"pralaya gem", 10},
			{"holy scroll", 10},
			{"maragidyne gem", 5},
			{"magarudyne gem", 5},
			{"maziodyne gem", 5},
			{"mapsiodyne gem", 5},
			{"assault signal", 10},
			{"casting signal", 10},
			{"guarding signal", 10},
			{"speedup signal", 10},
		},
		
		deathanim = function(mo)
						badnikDeath(mo)
					end,	
	}
	
enemyList["cacolantern"] = {
		name = "Cacolantern",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 250,
		sp = 200,
		strength = 40,
		magic = 90,
		endurance = 50,
		luck = 60,
		agility = 60,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_CURSE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_CACO, A, 4},
		anim_stand_hurt =	{SPR_CACO, A, 4},
		anim_move =			{SPR_CACO, A, 4},
		anim_run =			{SPR_CACO, A, 4},
		anim_hurt =			{SPR_CACO, A, 4},
		anim_getdown =		{SPR_CACO, A, 4},
		anim_downloop =		{SPR_CACO, A, 4},
		anim_getup =		{SPR_CACO, A, 4},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"eigaon", "mudoon", "dekaja", "life siphon"},
		
		r_drops = {
			{"agidyne gem", 10},
			{"garudyne gem", 10},
			{"ziodyne gem", 10},
			{"psiodyne gem", 10},
			{"pralaya gem", 10},
			{"holy scroll", 10},
			{"maragidyne gem", 5},
			{"magarudyne gem", 5},
			{"maziodyne gem", 5},
			{"mapsiodyne gem", 5},
			{"assault signal", 10},
			{"casting signal", 10},
			{"guarding signal", 10},
			{"speedup signal", 10},
		},
		
		deathanim = function(mo)
						badnikDeath(mo)
					end,	
	}
	
enemyList["crawla commander final"] = {
		name = "Alpha Crawla Commander",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 1000,
		sp = 300,
		strength = 70,
		magic = 75,
		endurance = 50,
		luck = 40,
		agility = 80,
		boss = true,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_PIERCE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_CCOM, A, B, C, D, 1},
		anim_stand_hurt =	{SPR_CCOM, A, B, C, D, 1},
		anim_move =			{SPR_CCOM, A, B, C, D, 1},
		anim_run =			{SPR_CCOM, A, B, C, D, 1},
		anim_hurt =			{SPR_CCOM, A, B, C, D, 1},
		anim_getdown =		{SPR_CCOM, A, B, C, D, 1},
		anim_downloop =		{SPR_CCOM, A, B, C, D, 1},
		anim_getup =		{SPR_CCOM, A, B, C, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"heavy shot", "grydyne", "life siphon", "stardrop", "bolt link"},
		
		r_drops = {
			{"agidyne gem", 10},
			{"garudyne gem", 10},
			{"ziodyne gem", 10},
			{"psiodyne gem", 10},
			{"pralaya gem", 10},
			{"holy scroll", 10},
			{"maragidyne gem", 5},
			{"magarudyne gem", 5},
			{"maziodyne gem", 5},
			{"mapsiodyne gem", 5},
			{"assault signal", 10},
			{"casting signal", 10},
			{"guarding signal", 10},
			{"speedup signal", 10},
		},
		
		deathanim = function(mo)

						mo.deathtimer = $ and $+1 or 1
						local btl = server.P_BattleStatus[mo.battlen]
						local cam = btl.cam
						--btl.battletime3 = btl.battletime3 + btl.battletime2
						CAM_stop(cam)
						local tgtx = mo.x + 128*cos(mo.angle)
						local tgty = mo.y + 128*sin(mo.angle)
						if mo.deathtimer == 2
							for m in mobjs.iterate()
								if m and m.valid and m.type == MT_PFIGHTER
									if m.byebye
										BTL_setupstats(m)
										server.plentities[1] = copyTable(saveplentities)
										--table.insert(server.plentities[1], m.teampos-1, m)
									end
								end
							end
							for k,v in ipairs(server.plentities[1])
								cureStatus(v)
								BTL_setupstats(v)	-- reset the stats from hyper mode
							end
							for p in players.iterate do
								if p and p.control and p.control.valid and p.control.battlen == mo.battlen
									S_FadeOutStopMusic(100, p)
								end
							end
							P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
							for k,v in ipairs(mo.enemies)
								if v and v.control and v.control.valid
									P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
								end
							end
							P_InstaThrust(mo, mo.angle, -30*FRACUNIT)
							playSound(mo.battlen, sfx_bbreak)
							cutscene = true
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
								elec.color = SKINCOLOR_YELLOW
							end
						end
						
						if mo.deathtimer == 60
							mo.hp = 1
							playSound(mo.battlen, sfx_pop)
							local pop = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							pop.state = S_XPLD1
							pop.scale = mo.scale
							mo.sprite = SPR_NULL
							mo.flags2 = $|MF2_DONTDRAW
							mo.deathanim = nil
							D_startEvent(1, "finalbadnik_defeat")
							return
						end
						if mo.deathtimer == 71
							mo.deathanim = nil
							return
						end
					end,	
	}
	
enemyList["facestabber final"] = {
		name = "Super FaceStabber",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 700,
		sp = 200,
		strength = 70,
		magic = 20,
		endurance = 100,
		luck = 20,
		agility = 80,
		boss = true,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_SLASH,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_stand_hurt =	{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_move =			{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_run =			{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_hurt =			{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_getdown =		{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_downloop =		{SPR_CBFS, A, B, C, D, E, F, 1},
		anim_getup =		{SPR_CBFS, A, B, C, D, E, F, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"brave blade", "vile assault", "blade of fury"},
		
		r_drops = {
			{"agidyne gem", 10},
			{"garudyne gem", 10},
			{"ziodyne gem", 10},
			{"psiodyne gem", 10},
			{"pralaya gem", 10},
			{"holy scroll", 10},
			{"maragidyne gem", 5},
			{"magarudyne gem", 5},
			{"maziodyne gem", 5},
			{"mapsiodyne gem", 5},
			{"assault signal", 10},
			{"casting signal", 10},
			{"guarding signal", 10},
			{"speedup signal", 10},
		},
		
		deathanim = function(mo)

						mo.deathtimer = $ and $+1 or 1
						local btl = server.P_BattleStatus[mo.battlen]
						local cam = btl.cam
						--btl.battletime3 = btl.battletime3 + btl.battletime2
						CAM_stop(cam)
						local tgtx = mo.x + 128*cos(mo.angle)
						local tgty = mo.y + 128*sin(mo.angle)
						if mo.deathtimer == 2
							for m in mobjs.iterate()
								if m and m.valid and m.type == MT_PFIGHTER
									if m.byebye
										BTL_setupstats(m)
										server.plentities[1] = copyTable(saveplentities)
										--table.insert(server.plentities[1], m.teampos-1, m)
									end
								end
							end
							for k,v in ipairs(server.plentities[1])
								cureStatus(v)
								BTL_setupstats(v)	-- reset the stats from hyper mode
							end
							for p in players.iterate do
								if p and p.control and p.control.valid and p.control.battlen == mo.battlen
									S_FadeOutStopMusic(100, p)
								end
							end
							P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
							for k,v in ipairs(mo.enemies)
								if v and v.control and v.control.valid
									P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
								end
							end
							P_InstaThrust(mo, mo.angle, -30*FRACUNIT)
							playSound(mo.battlen, sfx_bbreak)
							cutscene = true
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
								elec.color = SKINCOLOR_YELLOW
							end
						end
						
						if mo.deathtimer == 60
							mo.hp = 1
							playSound(mo.battlen, sfx_pop)
							local pop = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							pop.state = S_XPLD1
							pop.scale = mo.scale
							mo.sprite = SPR_NULL
							mo.flags2 = $|MF2_DONTDRAW
							mo.deathanim = nil
							D_startEvent(1, "finalbadnik_defeat")
							return
						end
						if mo.deathtimer == 71
							mo.deathanim = nil
							return
						end
					end,
	}
	
enemyList["robo hood final"] = {
		name = "Omega Robo Hood",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 700,
		sp = 200,
		strength = 60,
		magic = 10,
		endurance = 40,
		luck = 40,
		agility = 50,
		boss = true,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_PIERCE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ARCH, A, 4},
		anim_stand_hurt =	{SPR_ARCH, A, 4},
		anim_move =			{SPR_ARCH, A, 4},
		anim_run =			{SPR_ARCH, A, 4},
		anim_hurt =			{SPR_ARCH, A, 4},
		anim_getdown =		{SPR_ARCH, A, 4},
		anim_downloop =		{SPR_ARCH, A, 4},
		anim_getup =		{SPR_ARCH, A, 4},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"torrent shot", "gale slash", "vile assault", "gale link"},
		
		r_drops = {
			{"agidyne gem", 10},
			{"garudyne gem", 10},
			{"ziodyne gem", 10},
			{"psiodyne gem", 10},
			{"pralaya gem", 10},
			{"holy scroll", 10},
			{"maragidyne gem", 5},
			{"magarudyne gem", 5},
			{"maziodyne gem", 5},
			{"mapsiodyne gem", 5},
			{"assault signal", 10},
			{"casting signal", 10},
			{"guarding signal", 10},
			{"speedup signal", 10},
		},
		
		deathanim = function(mo)
						
						mo.deathtimer = $ and $+1 or 1
						local btl = server.P_BattleStatus[mo.battlen]
						local cam = btl.cam
						--btl.battletime3 = btl.battletime3 + btl.battletime2
						CAM_stop(cam)
						local tgtx = mo.x + 128*cos(mo.angle)
						local tgty = mo.y + 128*sin(mo.angle)
						if mo.deathtimer == 2
							for m in mobjs.iterate()
								if m and m.valid and m.type == MT_PFIGHTER
									if m.byebye
										BTL_setupstats(m)
										server.plentities[1] = copyTable(saveplentities)
										--table.insert(server.plentities[1], m.teampos-1, m)
									end
								end
							end
							for k,v in ipairs(server.plentities[1])
								cureStatus(v)
								BTL_setupstats(v)	-- reset the stats from hyper mode
							end
							for p in players.iterate do
								if p and p.control and p.control.valid and p.control.battlen == mo.battlen
									S_FadeOutStopMusic(100, p)
								end
							end
							P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
							for k,v in ipairs(mo.enemies)
								if v and v.control and v.control.valid
									P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
								end
							end
							P_InstaThrust(mo, mo.angle, -30*FRACUNIT)
							playSound(mo.battlen, sfx_bbreak)
							cutscene = true
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
								elec.color = SKINCOLOR_YELLOW
							end
						end
						
						if mo.deathtimer == 60
							mo.hp = 1
							playSound(mo.battlen, sfx_pop)
							local pop = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							pop.state = S_XPLD1
							pop.scale = mo.scale
							mo.sprite = SPR_NULL
							mo.flags2 = $|MF2_DONTDRAW
							mo.deathanim = nil
							D_startEvent(1, "finalbadnik_defeat")
							return
						end
						if mo.deathtimer == 71
							mo.deathanim = nil
							return
						end
					end,
	}
	
//ehhhhhh
/*enemyList["turret"] = {
		name = "Turret",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 1,
		sp = 200,
		strength = 1,
		magic = 60,
		endurance = 1,
		luck = 90,
		agility = 80,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_TRET, A, 4},
		anim_stand_hurt =	{SPR_TRET, A, 4},
		anim_move =			{SPR_TRET, A, 4},
		anim_run =			{SPR_TRET, A, 4},
		anim_hurt =			{SPR_TRET, A, 4},
		anim_getdown =		{SPR_TRET, A, 4},
		anim_downloop =		{SPR_TRET, A, 4},
		anim_getup =		{SPR_TRET, A, 4},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"rapid fire"}, --link skill
	}*/

//give wave requirement hud indicator?
addHook("MobjThinker", function(mo)
	if gamemap != 10 return end
	if mo and mo.valid
		if mo.cutscene return end
		local btl = server.P_BattleStatus[1]
		if btl.battlestate != 0
			if btl.battlestate == BS_START
				P_LinedefExecute(1004)
				P_LinedefExecute(1006)
				if mo.enemy and mo.valid
					if not mo.sup
						//increase power if there are less enemies
						local stats = {"strength", "magic", "endurance"}
						for i = 1, #stats do
							mo.hp = $+50*(4-#mo.allies)
							mo.maxhp = $+50*(4-#mo.allies)
							mo[stats[i]] = $+10*(4-#mo.allies)
						end
						if #mo.allies < 2
							mo.enemyturns = 2
							if #mo.allies == 1
								mo.strongbadnik = true
							end
						end
						if P_RandomRange(1, 8) == 8
							mo.extra = true
							mo.status_condition = COND_HYPER
							local stats = {"strength", "magic", "endurance", "agility", "luck"}
							for i = 1, #stats do
								mo[stats[i]] = $+10
							end
						end
						mo.enemyscale = FRACUNIT*((5-#mo.allies)/2)
						mo.emeraldmode = P_RandomRange(1, 6)
						for i = 1, #enemies
							if mo.enemy == enemies[i]
								mo.weak = btl.weaknesses[i]
								mo.resist = btl.resistances[i]
								if mo.weak == mo.resist
									mo.resist = 0
								end
							end
						end
						mo.sup = true
					end
				/*elseif not mo.enemy and mo.valid 	-- for quick testing
					if mo.skin == "tails"
						local stats = {"strength", "magic", "endurance", "agility", "luck"}
						for i = 1, #stats do
							mo[stats[i]] = 3000
						end
						table.insert(mo.skills, "maziodyne")
						--table.insert(mo.skills, "analysis")
						btl.emeraldpow = 700
					end*/
				end
			end
			for s in sectors.iterate do
				if s.tag == 1 and s.ceilingheight >= -439*FRACUNIT
					P_LinedefExecute(1008)
				end
			end
			//get the hell out of here fox boy
			if btl.battlestate == BS_DOTURN
				for k,v in ipairs(btl.fighters)
					if v and v.valid and v.byebye
						v.flags2 = $|MF2_DONTDRAW
						table.remove(btl.fighters, k)
					end
				end
				/*if not mo.enemy and btl.turnorder[1] == mo
					print(mo.enemies[mo.t_target].name)
				end*/
				/*if btl.waven == 1
					if mo.plyr and mo.skin != "tails" --kill
						mo.hp = 1
					end
				end*/
			end
			if mo.enemy
				if mo.enemyscale
					mo.scale = mo.enemyscale
				end
				if mo.enemyturns
					mo.turns = mo.enemyturns
				end
				if mo.enemy == "jetty bomber" or mo.enemy == "jetty gunner" or mo.enemy == "cacolantern" or mo.enemy == "crawla commander" or mo.enemy == "crawla commander final"
					mo.z = mo.floorz + 50*FRACUNIT
					mo.flags = $|MF_NOGRAVITY
				end
				if btl.waven == 6
					mo.scale = 2*FRACUNIT
					if btl.battlestate == BS_DOTURN or btl.battlestate == BS_ACTION
						if mo.allies and #mo.allies 
							if #mo.allies == 1
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
								mo.deathtimer = 70
							end
						end
					end
				else
					mo.deathtimer = 70
				end
				//emerald modes! giving emerald effects to enemies! this'll switch every time a badnik ends its turn (taken from stage 6 lol)
				if mo.emeraldmode
					local mode = mo.emeraldmode
					//coat the badnik in the mode color
					local thecolors = {SKINCOLOR_EMERALD, SKINCOLOR_MAGENTA, SKINCOLOR_BLUE, SKINCOLOR_CYAN, SKINCOLOR_YELLOW, SKINCOLOR_RED, SKINCOLOR_GREY}
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
			end
			if btl.waven != 6
				if btl.battlestate == BS_ENDTURN
					local t1, t2 = BTL_deadEnemiescleanse(btl)
					if not #t2	--if all enemies are dead, remember this
						/*if server
							btl.battletime3 = btl.battletime3 + btl.battletime2
						end*/
						if btl.waven != 6
							if btl.waven < 5
								local enemyamount = P_RandomRange(1, 4)
								local enemywave = {}
								for i = 1, enemyamount
									enemywave[#enemywave+1] = enemies[P_RandomRange(1, #enemies)]
								end
								btl.waven = $+1
								btl.nextwave = enemywave
								btl.hudtimer.moreenemies = TICRATE*5/2
								btl.battlestate = BS_MOREENEMIES
								BTL_fullCleanse(btl)
							else
								local enemywave = {"robo hood final", "facestabber final", "crawla commander final"}
								btl.waven = $+1
								btl.nextwave = enemywave
								btl.hudtimer.moreenemies = TICRATE*5/2
								btl.battlestate = BS_MOREENEMIES
								BTL_fullCleanse(btl)
								D_startEvent(1, "ev_stage4_final")
							end
						end
					end
				end
			end
			if btl.battlestate == BS_MOREENEMIES
				if btl.waven == 3
					D_startEvent(1, "ev_stage4_midway")
				end
				if btl.waven == 4
					D_startEvent(1, "ev_stage4_elevatorstart")
				end
				/*if btl.waven == 3
					D_startEvent(1, "ev_stage4_turret")
				end*/
				if mo.enemy and mo.valid
					if not mo.sup
						//increase power if there are less enemies
						local stats = {"strength", "magic", "endurance"}
						for i = 1, #stats do
							mo.hp = $+75*(4-#mo.allies)
							mo.maxhp = $+75*(4-#mo.allies)
							mo[stats[i]] = $+15*(4-#mo.allies)
						end
						if #mo.allies <= 2
							mo.strongbadnik = true
							if #mo.allies == 1
								mo.enemyturns = 2
							end
						end
						if P_RandomRange(1, 8) == 8
							mo.extra = true
							mo.status_condition = COND_HYPER
							local stats = {"strength", "magic", "endurance", "agility", "luck"}
							for i = 1, #stats do
								mo[stats[i]] = $+10
							end
						end
						mo.enemyscale = FRACUNIT*((5-#mo.allies)/2)
						mo.emeraldmode = P_RandomRange(1, 6)
						for i = 1, #enemies
							if mo.enemy == enemies[i]
								mo.weak = btl.weaknesses[i]
								mo.resist = btl.resistances[i]
								if mo.weak == mo.resist
									mo.resist = 0
								end
							end
						end
						if mo.boss
							if mo.enemy == "crawla commander final"
								mo.weak = btl.weaknesses[5]
								mo.resist = btl.resistances[5]
								if mo.weak == mo.resist
									mo.resist = 0
								end
							elseif mo.enemy == "facestabber final"
								mo.weak = btl.weaknesses[4]
								mo.resist = btl.resistances[4]
								if mo.weak == mo.resist
									mo.resist = 0
								end
							elseif mo.enemy == "robo hood final"
								mo.weak = btl.weaknesses[3]
								mo.resist = btl.resistances[3]
								if mo.weak == mo.resist
									mo.resist = 0
								end
							end
						end
						mo.sup = true
					end
				end
			end
		end
	end
end, MT_PFIGHTER)