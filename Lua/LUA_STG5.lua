-- 011010110110010101100101011100000010000001111001011011110111010101110010011100110110010101101100011001100010000001110011011000010110011001100101

---------- BATTLE -------------

---------- Stage 5: Metal Sonic -------------

/*Equipped with the phantom ruby, Metal Sonic's attacks are unorthadox, random, and unordinarily complex.
With link skills that randomly attack you during moves, mixing up movesets and buffs, creating illusionary 
decoy traps, swapping moves, stealing EP, randomizing buffs, and even redirecting attacks to a teammate, 
Metal Sonic's unusual attacks will need players to be careful of his high stats paired alongside them.*/

local dyneskills = {"agidyne", "bufudyne", "garudyne", "ziodyne", "psiodyne", "eigaon", "kougaon"}
/*local counterscene = true
local metaloop = nil
local portaldamage = 0
local portalready = false
local rearrangecooldown = 6
local decoycooldown = 6*/

//for ereasing illusion decoys from battle
local function updateUDtable_nohp_decoy(t, f)		-- remove dead entities from an userdata table

	for i = 1, #t	-- we really need to cleanse

		for k,v in ipairs(t)
			if v and v.valid and v.enemy == "b_metalsonic" and not v.hp
				--print("please die")
				table.remove(t, k)
			end
		end
	end
end

local function BTL_deadDecoycleanse(btl)
	-- check for dead entities, but it's racist towards illusions
	updateUDtable_nohp_decoy(btl.turnorder)

	local playerref

	local t1
	local t2
	for k,v in ipairs(btl.fighters)
		if not v.valid continue end	-- wat
		updateUDtable(v.enemies)
		updateUDtable(v.allies)
		updateUDtable_nohp_decoy(v.enemies)
		updateUDtable_nohp_decoy(v.allies)

		updateUDtable(v.allies_noupdate)
		updateUDtable(v.enemies_noupdate)	-- update for .valid still
		if v.plyr and not playerref
			t1 = v.allies
			t2 = v.enemies
			playerref = true
		end
	end

	return t1 or {}, t2 or {}
end

/*addHook("MapLoad", function()
	if not server return end
	counterscene = true
	metaloop = nil
	portaldamage = 0
	portalready = false
	rearrangecooldown = 6
	decoycooldown = 6
end)*/

enemyList["b_metalsonic"] = {
		name = "Metal Sonic",
		skillchance = 100,	-- /100, probability of using a skill
		level = 100,
		hp = 5500,
		sp = 2000,
		strength = 100,
		magic = 100,
		endurance = 90,
		luck = 50,
		agility = 70,
		boss = true,
		turns = 2,
		weak = ATK_ELEC,
		resist = ATK_STRIKE|ATK_NUCLEAR,
		r_exp = 0,
		
		skin = "metalsonic",			-- for "player" fights.
		color = SKINCOLOR_BLUE,	-- for colormapping
		hudcutin = "MSON_A",	-- cut in
		hudspr = "MSON",	-- sprite prefix since hud can't retrieve it. yikes

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
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

		anim_special1 =		{SPR_PLAY, A, 2, "SPR2_SPNG"},	-- charge
		anim_special2 =		{SPR_PLAY, A, 2, "SPR2_DASH"},	-- dash
		anim_special3 = 	{SPR_PLAY, A, 1, "SPR2_TRNS"}, -- morbing start
		anim_special4 = 	{SPR_SSPK, A, B, C, B, 3}, -- illusion sparkle
		anim_special5 = 	{SPR_FBOM, A, 1}, -- illusion bomb sprite 
		anim_special6 = 	{SPR_TVEG, A, 1}, -- illusion eggbox sprite 
		anim_special7 = 	{SPR_FAKE, A, 1}, -- illusion sea egg zapper sprite 
		anim_special8 =		{SPR_PLAY, A, 1, "SPR2_FALL"},	-- falling
		

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
					
		skills = {"ruby overdrive dash", "multi god hand"},
		
		deathanim = function(mo)

						mo.deathtimer = $ and $+1 or 1
						local btl = server.P_BattleStatus[mo.battlen]
						local cam = btl.cam
						
						//fakeout anims for illusionary decoy
						if mo.fakeillusion
						
							if mo.deathtimer == 1
								CAM_stop(cam)
								local tgtx = mo.x + 128*cos(mo.angle)
								local tgty = mo.y + 128*sin(mo.angle)
								P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
								ANIM_set(mo, mo.anim_hurt, true)
								for k,v in ipairs(mo.enemies)
									if v and v.control and v.control.valid
										P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
									end
								end
								P_InstaThrust(mo, mo.angle, -30*FRACUNIT)
								playSound(mo.battlen, sfx_slash)
								localquake(mo.battlen, 10*FRACUNIT, 5)
							end
							
							if mo.deathtimer < 49
								cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
								mo.momx = $*90/100
								mo.momy = $*90/100
							end
							
							if mo.deathtimer >= 50 and mo.deathtimer < 100
								localquake(mo.battlen, 2*FRACUNIT, 1)
							end
							
							if mo.deathtimer == 65
								local tgtx = mo.x + 500*cos(mo.angle)
								local tgty = mo.y + 500*sin(mo.angle)
								CAM_goto(cam, tgtx, tgty, mo.z + 50*FRACUNIT)
							end
							
							if mo.deathtimer == 100
								playSound(mo.battlen, sfx_hamas1)
								playSound(mo.battlen, sfx_hamas2)
							end
							
							for i = 1, #mo.allies
								local a = mo.allies[i]
								if a and a.valid
									if not a.fakeillusion
										if mo.deathtimer >= 65
										and mo.deathtimer < 100
										and leveltime & 1
											if a.bombillusion
												a.flags = $|MF_NOGRAVITY
												P_TeleportMove(a, a.x, a.y, a.floorz + 20*FRACUNIT)
												ANIM_set(a, a.anim_special5, true)
											elseif a.boxillusion
												ANIM_set(a, a.anim_special6, true)
											elseif a.spiritillusion
												ANIM_set(a, a.anim_special7, true)
											end
											a.flags2 = $ & ~MF2_DONTDRAW
											local g = P_SpawnGhostMobj(a)
											a.flags2 = $|MF2_DONTDRAW
											g.fuse = 2
										end
										if mo.deathtimer == 100
											local thok = P_SpawnMobj(a.x, a.y, a.z+5*FRACUNIT, MT_DUMMY)
											thok.state = S_INVISIBLE
											thok.tics = 1
											thok.scale = FRACUNIT
											A_OldRingExplode(thok, MT_SUPERSPARK)
											clearField(a)
											P_RemoveMobj(a)
										end
									end
								end
							end
							
							if mo.deathtimer == 130
								mo.maxhp = 5500
								mo.hp = mo.actualhp
								mo.turns = 2
								mo.illusion = false
								mo.fakeillusion = false
								BTL_deadDecoycleanse(btl)
								BTL_normalizePositions(mo.allies, true)
								if mo.prevstatus and mo.prevstatus > 0 and mo.prevstatus != 4096
									inflictStatus(mo, mo.prevstatus)
								end
								if mo.prevfield and mo.prevfield > 0
									startField(mo, mo.prevfield, 5)
								end
								mo.deathanim = nil
								return
							end
						end
						
						if mo.bombillusion or mo.boxillusion or mo.spiritillusion
						
							if mo.deathtimer == 1
								CAM_stop(cam)
								local tgtx = mo.x + 128*cos(mo.angle)
								local tgty = mo.y + 128*sin(mo.angle)
								P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
								ANIM_set(mo, mo.anim_hurt, true)
								for k,v in ipairs(mo.enemies)
									if v and v.control and v.control.valid
										P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
									end
								end
								P_InstaThrust(mo, mo.angle, -30*FRACUNIT)
								playSound(mo.battlen, sfx_slash)
								localquake(mo.battlen, 10*FRACUNIT, 5)
							end
							
							if mo.deathtimer < 49
								cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
								mo.momx = $*90/100
								mo.momy = $*90/100
							end
							
							if mo.deathtimer == 65
								local tgtx = mo.x + 500*cos(mo.angle)
								local tgty = mo.y + 500*sin(mo.angle)
								CAM_goto(cam, tgtx, tgty, mo.z + 50*FRACUNIT)
							end
							
							if mo.deathtimer >= 50
							and mo.deathtimer < 100
							and mo.deathtimer & 1
								if mo.bombillusion
									mo.flags = $|MF_NOGRAVITY
									P_TeleportMove(mo, mo.x, mo.y, mo.floorz + 20*FRACUNIT)
									ANIM_set(mo, mo.anim_special5, true)
									mo.flags2 = $ & ~MF2_DONTDRAW
									local g = P_SpawnGhostMobj(mo)
									mo.flags2 = $|MF2_DONTDRAW
									g.fuse = 2
								elseif mo.boxillusion
									mo.sparkle = {}
									ANIM_set(mo, mo.anim_special6, true)
									mo.flags2 = $ & ~MF2_DONTDRAW
									local g = P_SpawnGhostMobj(mo)
									mo.flags2 = $|MF2_DONTDRAW
									g.fuse = 2
								elseif mo.spiritillusion
									ANIM_set(mo, mo.anim_special7, true)
									mo.flags2 = $ & ~MF2_DONTDRAW
									local g = P_SpawnGhostMobj(mo)
									mo.flags2 = $|MF2_DONTDRAW
									g.fuse = 2
								end
							end
							if mo.deathtimer == 100
								mo.flags2 = $ & ~MF2_DONTDRAW
								local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
								thok.state = S_INVISIBLE
								thok.tics = 1
								thok.scale = FRACUNIT
								A_OldRingExplode(thok, MT_SUPERSPARK)
								if mo.bombillusion
									mo.flags = $ & ~MF_NOGRAVITY
									playSound(mo.battlen, sfx_s3k51)
									mo.momz = 8*FRACUNIT
								elseif mo.boxillusion
									local pop = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
									pop.state = S_BOX_POP1
									pop.scale = mo.scale
									pop.fuse = 120
									mo.sprite = SPR_NULL
									mo.flags2 = $|MF2_DONTDRAW
									playSound(mo.battlen, sfx_pop)
									for i = 1, #mo.allies
										if mo.allies[i] != mo
											local orb = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
											orb.state = S_MEGITHOK
											orb.color = SKINCOLOR_WHITE
											orb.tics = -1
											orb.fuse = -1
											orb.destx = mo.x + P_RandomRange(-250, 250)*FRACUNIT
											orb.desty = mo.y + P_RandomRange(-250, 250)*FRACUNIT
											orb.destz = mo.z + P_RandomRange(100, 250)*FRACUNIT
											orb.target = mo.allies[i]
											mo.sparkle[#mo.sparkle+1] = orb
										end
									end
								elseif mo.spiritillusion
									playSound(mo.battlen, sfx_s3k5a)
								end
							end
							if mo.sparkle and #mo.sparkle
								for i = 1, #mo.sparkle
									local ball = mo.sparkle[i]
									if ball and ball.valid
										if mo.deathtimer < 130
											ball.momx = (ball.destx - ball.x)/6
											ball.momy = (ball.desty - ball.y)/6
											ball.momz = (ball.destz - ball.z)/6
										elseif mo.deathtimer >= 130
											ball.destscale = FRACUNIT/10
											ball.momx = (ball.target.x - ball.x)/6
											ball.momy = (ball.target.y - ball.y)/6
											ball.momz = (ball.target.z - ball.z)/6
										end
										if mo.deathtimer == 150
											P_RemoveMobj(ball)
										end
									end
								end
							end
							if mo.deathtimer >= 100
								if mo.bombillusion
									local target = btl.turnorder[1]
									mo.momx = (target.x - mo.x)/12
									mo.momy = (target.y - mo.y)/12
									if not mo.ded
										local tgtx = mo.x + 500*cos(mo.angle)
										local tgty = mo.y + 500*sin(mo.angle)
										P_TeleportMove(cam, tgtx, tgty, mo.z + 50*FRACUNIT)
									end
									if mo.z <= mo.floorz + 5*FRACUNIT and not mo.ded
										local boom = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_BOSSEXPLODE)
										boom.scale = FRACUNIT*4
										boom.state = S_PFIRE1
										playSound(mo.battlen, sfx_fire2)
										playSound(mo.battlen, sfx_s3k4e)
										damageObject(target, 200)
										mo.sprite = SPR_NULL
										mo.flags2 = $|MF2_DONTDRAW
										mo.ded = true
									end
									if mo.deathtimer == 160
										mo.deathanim = nil
										mo.bombillusion = false
										/*for k,v in ipairs(server.plentities[1])
											if v == mo
												table.remove(server.plentities[1], k)
											end
										end*/
										return
									end
								elseif mo.boxillusion
									if mo.deathtimer == 150
										--print("hi")
										playSound(mo.battlen, sfx_buff1)
										playSound(mo.battlen, sfx_buff2)
										localquake(mo.battlen, 5*FRACUNIT, 3)
										for i = 1, #mo.allies
											local target = mo.allies[i]
											if target != mo
												if i == #mo.allies
													buffStat(target, "atk", 25)
													buffStat(target, "mag", 25)
													buffStat(target, "def", 25)
													buffStat(target, "agi", 25)
													buffStat(target, "crit", 25)
												end
												for i = 1,16
													local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
													dust.angle = ANGLE_90 + ANG1* (22*(i-1))
													dust.state = S_CDUST1
													P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
													dust.color = SKINCOLOR_WHITE
													dust.scale = FRACUNIT*2
												end
												BTL_logMessage(mo.battlen, "All stats increased!")
											end
										end
									end
									/*if mo.deathtimer == 130
										local avgx, avgy, avgz = 0, 0, 0
										for i = 1, #mo.allies
											avgx = $ + mo.allies[i].x/FRACUNIT
											avgy = $ + mo.allies[i].y/FRACUNIT
											avgz = $ + mo.allies[i].z/FRACUNIT
										end

										avgx = ($/#mo.allies)*FRACUNIT
										avgy = ($/#mo.allies)*FRACUNIT
										avgz = ($/#mo.allies)*FRACUNIT
										local tgtx = avgx + 500*cos(mo.angle)
										local tgty = avgy + 500*sin(mo.angle)
										CAM_goto(cam, tgtx, tgty, mo.z + 50*FRACUNIT)
									end*/
									if mo.deathtimer >= 150 and mo.deathtimer < 200
										for i = 1, #mo.allies
											local target = mo.allies[i]
											if target != mo
												local colors = {SKINCOLOR_ORANGE, SKINCOLOR_TEAL, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD}
												if leveltime%2 == 0
													for i = 1,16

														local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
														thok.state = S_CDUST1
														thok.momz = P_RandomRange(3, 10)*FRACUNIT
														thok.color = SKINCOLOR_WHITE
														thok.tics = P_RandomRange(10, 35)
														thok.scale = FRACUNIT*3/2
													end
												end

												for i = 1, 8
													local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
													thok.sprite = SPR_SUMN
													thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
													thok.momz = P_RandomRange(6, 16)*FRACUNIT
													thok.color = colors[P_RandomRange(1, #colors)]
													thok.tics = P_RandomRange(10, 35)
												end
											end
										end
									end
									if mo.deathtimer == 220
										mo.deathanim = nil
										mo.boxillusion = false
										BTL_deadDecoycleanse(btl)
										return
									end
								elseif mo.spiritillusion
									if mo.deathtimer < 120
										local energy = P_SpawnMobj(mo.x-P_RandomRange(200,-200)*FRACUNIT, mo.y-P_RandomRange(200,-200)*FRACUNIT, mo.z-P_RandomRange(150,-50)*FRACUNIT, MT_DUMMY)
										energy.sprite = SPR_THOK
										energy.frame = FF_FULLBRIGHT
										energy.color = SKINCOLOR_PURPLE
										energy.scale = FRACUNIT/2
										energy.tics = 10
										energy.momx = (mo.x - energy.x)/10
										energy.momy = (mo.y - energy.y)/10
										energy.momz = (mo.z - energy.z)/10
									end
									if mo.deathtimer == 130
										for i = 1, #mo.enemies
											ANIM_set(mo.enemies[i], mo.enemies[i].anim_hurt, true)
											damageSP(mo.enemies[i], 100)
											buffStat(mo.enemies[i], "mag", -25)
										end
										playSound(mo.battlen, sfx_absorb)
										local tgtx = mo.x + 1200*cos(mo.angle)
										local tgty = mo.y + 1200*sin(mo.angle)
										CAM_goto(cam, tgtx, tgty, mo.z + 100*FRACUNIT)
										local an = 0
										for i = 1, 32
											local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
											s.color = SKINCOLOR_PURPLE
											s.state = S_MEGITHOK
											s.scale = $/2
											s.fuse = TICRATE*2
											P_InstaThrust(s, an*ANG1, 50<<FRACBITS)
											s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
											s.color = SKINCOLOR_PURPLE
											s.state = S_MEGITHOK
											s.scale = $/4
											s.fuse = TICRATE*2
											P_InstaThrust(s, an*ANG1, 30<<FRACBITS)
											an = $ + (360/32)
										end
									end
									if mo.deathtimer == 170
										mo.sprite = SPR_NULL
										mo.flags2 = $|MF2_DONTDRAW
										mo.spiritillusion = false
										mo.deathanim = nil
										BTL_deadDecoycleanse(btl)
										return
									end
								end
							end
						end
						
						//the real deathanim
						if not mo.illusion and not mo.fakeillusion and not mo.boxillusion and not mo.spiritillusion
							if mo.deathtimer == 1
								cutscene = true
								for k,v in ipairs(server.plentities[1])
									--resetHyperStats(v)
									cureStatus(v)
									BTL_setupstats(v)	-- reset the stats from hyper mode
									v.skills = v.startskills
								end
								for p in players.iterate do
									if p and p.control and p.control.valid and p.control.battlen == mo.battlen
										S_FadeOutStopMusic(100, p)
									end
								end
								CAM_stop(cam)
								local tgtx = mo.x + 128*cos(mo.angle)
								local tgty = mo.y + 128*sin(mo.angle)
								P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
								ANIM_set(mo, mo.anim_hurt, true)
								for k,v in ipairs(mo.enemies)
									if v and v.control and v.control.valid
										P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
									end
								end
								P_InstaThrust(mo, mo.angle, -30*FRACUNIT)
								playSound(mo.battlen, sfx_bbreak)
								mo.shake = $ or 2*FRACUNIT
								
								//remove ruby effects
								for m in mobjs.iterate() do
									if m and m.valid and m.state == S_FLAME
										P_RemoveMobj(m)
									end
								end
								P_LinedefExecute(1017)
								btl.icefield = false
								btl.cursefield = false

								for s in sectors.iterate
									if s.tag == 3
										s.lightlevel = 255
									end
								end
							end
							
							if mo.deathtimer < 40
								cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
								mo.momx = $*90/100
								mo.momy = $*90/100
								if leveltime%P_RandomRange(2, 4) == 0
									local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height/2, MT_DUMMY)
									elec.sprite = SPR_DELK
									elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
									elec.destscale = FRACUNIT*2
									elec.scalespeed = FRACUNIT/2
									elec.tics = TICRATE/12
									elec.color = SKINCOLOR_YELLOW
								end
							end
							
							if mo.deathtimer == 40
								playSound(mo.battlen, sfx_s3k51)
								mo.ruby = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
								mo.ruby.sprite = SPR_RUBY
								mo.ruby.scale = FRACUNIT*2
								mo.ruby.frame = FF_FULLBRIGHT
								mo.ruby.tics = -1
								mo.ruby.fuse = -1
								mo.ruby.flags = $ & ~MF_NOCLIPHEIGHT & ~MF_NOGRAVITY
								mo.ruby.momz = 15*FRACUNIT
								mo.ruby.bounce = 2
								P_InstaThrust(mo.ruby, mo.angle + ANG1*180, 8*FRACUNIT)
							end
							
							if mo.deathtimer > 40
								local tgtx = mo.ruby.x + 200*cos(mo.angle + ANG1*90)
								local tgty = mo.ruby.y + 200*sin(mo.angle + ANG1*90)
								cam.angle = R_PointToAngle2(cam.x, cam.y, mo.ruby.x, mo.ruby.y)
								CAM_goto(cam, tgtx, tgty, mo.ruby.z)
								if mo.ruby.bounce == 2
									mo.ruby.rollangle = $+ANG1*30
								elseif mo.ruby.bounce == 1
									mo.ruby.rollangle = $+ANG1*20
								elseif mo.ruby.bounce == 0
									if not P_IsObjectOnGround(mo.ruby)
										mo.ruby.rollangle = $+ANG1*10
									end
								end
								if P_IsObjectOnGround(mo.ruby) and mo.ruby.bounce > 0
									playSound(mo.battlen, sfx_tink)
									mo.ruby.momx = $*80/100
									mo.ruby.momy = $*80/100
									mo.ruby.momz = 6*mo.ruby.bounce*FRACUNIT
									mo.ruby.bounce = $-1
									--P_LinedefExecute()?
								end
								if mo.ruby.z <= mo.ruby.floorz and mo.ruby.bounce == 0
									mo.ruby.momx = $*80/100
									mo.ruby.momy = $*80/100
								end
							end
							
							if mo.deathtimer == 150
								mo.hp = 1
								mo.deathanim = nil
								D_startEvent(1, "metalsonic_defeat")
								return
							end
						end
					end,
					
		thinker = function(mo)
			local btl = server.P_BattleStatus[mo.battlen]
			local attack = P_RandomRange(1, 6)
			if mo.illusion
				attack = P_RandomRange(3, 6)
			end
			if btl.rearrangecooldown > 0
				btl.rearrangecooldown = btl.rearrangecooldown - 1
			end
			if btl.decoycooldown > 0
				btl.decoycooldown = btl.decoycooldown - 1
			end
			
			//hp threshold skill triggers
			if not mo.illusion
				/*if mo.hp <= 5000 and not mo.rearrangebtrigger
					mo.rearrangebtrigger = true
					return attackDefs["rearrangement type b"], mo.enemies
				end
				if mo.hp <= 4000 and not mo.rearrangeatrigger
					mo.rearrangeatrigger = true
					return attackDefs["rearrangement type a"], btl.fighters
				end*/
				if mo.hp <= 3000 and not mo.decoytrigger
					mo.dontruby = true
					btl.randomtimer = 0
					return attackDefs["illusionary decoy"], {mo}
				end
				if mo.hp <= 2000 and not mo.rearrangebtrigger2
					mo.rearrangebtrigger2 = true
					return attackDefs["rearrangement type b"], mo.enemies
				end
				if mo.hp <= 1000 and not mo.rearrangeatrigger2
					mo.rearrangeatrigger2 = true
					return attackDefs["rearrangement type a"], btl.fighters
				end
			end
			
			if btl.emeraldpow >= 100 and P_RandomRange(1, 4) == 1 and mo.status_condition ~= COND_HYPER
				return attackDefs["emerald leech"], mo.enemies
			end
			if btl.portaldamage <= 0 and attack == 1
				return attackDefs["indirect energy blast"], mo.enemies
			end
			if (attack == 2 or attack == 6) and btl.decoycooldown == 0 and not mo.illusion and mo.hp <= 3000
				mo.dontruby = true
				btl.randomtimer = 0
				return attackDefs["illusionary decoy"], {mo}
			end
			if attack == 3
				return attackDefs[dyneskills[P_RandomRange(1, #dyneskills)]], {mo.enemies[P_RandomRange(1, #mo.enemies)]}
			end
			if attack == 4 or attack == 5
				if btl.rearrangecooldown == 0
					if P_RandomRange(1, 2) == 1
						return attackDefs["rearrangement type a"], btl.fighters
					else
						return attackDefs["rearrangement type b"], mo.enemies
					end
				else
					return attackDefs[dyneskills[P_RandomRange(1, #dyneskills)]], {mo.enemies[P_RandomRange(1, #mo.enemies)]}
				end
			end
			return generalEnemyThinker(mo)
		end,
}

attackDefs["ruby overdrive dash"] = {
		name = "Overdrive Dash",
		type = ATK_ALMIGHTY,
		power = 1200,
		accuracy = 100,
		hits = 9,
		critical = 1, 
		target = TGT_ENEMY,
		costtype = CST_HPPERCENT,
		cost = 10,
		anim_norepel = true,
		desc = "A rapid overdrive attack. \nMore powerful than the average \nMelee hit, but low critical rate.",
		anim = 	function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					if timer == 1
						mo.startx = mo.x
						mo.starty = mo.y
						mo.camdist = 200
						mo.another = 0
						mo.deadtimer = 0
						mo.clones = {}
						mo.flags = $|MF_NOCLIP
						ANIM_set(mo, mo.anim_special2, true)
						mo.reachedtarget = 0	-- yeah we can use variables here that you like it or not :^)
						S_StartSound(mo, sfx_msovd1)
						local cx = target.x + mo.camdist*cos(target.angle + ANG1*20)
						local cy = target.y + mo.camdist*sin(target.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*50, 80*FRACUNIT)
					end
					local cx = target.x + mo.camdist*cos(target.angle + ANG1*20)
					local cy = target.y + mo.camdist*sin(target.angle + ANG1*20)
					CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y), ANG1*6)
					
					local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					s.state = S_MSOVERDRIVE1
					if target.hp
						P_InstaThrust(mo, mo.angle, FRACUNIT*60)
					end
					
					if mo.clones and #mo.clones
						for i = 1, #mo.clones
							if mo.clones[i] and mo.clones[i].valid
								local c = mo.clones[i]
								local s = P_SpawnMobj(c.x, c.y, c.z, MT_DUMMY)
								s.state = S_MSOVERDRIVE1
								P_InstaThrust(c, c.angle, FRACUNIT*60)
								if not c.reachedtarget

									if c.anim ~= mo.anim_special2
										ANIM_set(c, mo.anim_special2, true)
									end

									c.angle = R_PointToAngle2(c.x, c.y, target.x, target.y)

									if R_PointToDist2(c.x, c.y, target.x, target.y) <= FRACUNIT*60

										damageObject(target)
										playSound(mo.battlen, sfx_bkpoof)
										c.reachedtarget = timer
										mo.reachedtarget = timer

										for i=1,24
											local b = P_SpawnMobj(target.x, target.y, target.z+2*FRACUNIT, MT_DUMMY)
											b.momx = P_RandomRange(-32, 32)*FRACUNIT
											b.momy = P_RandomRange(-32, 32)*FRACUNIT
											b.momz = P_RandomRange(4, 16)*FRACUNIT
											b.state = S_AOADUST1
											b.frame = A|FF_FULLBRIGHT
											b.scale = FRACUNIT*3
											b.destscale = FRACUNIT/12
										end
									end
								end
							end
						end
					end

					if not mo.reachedtarget and target.hp

						if mo.anim ~= mo.anim_special2
							ANIM_set(mo, mo.anim_special2, true)
						end

						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)

						if R_PointToDist2(mo.x, mo.y, target.x, target.y) <= FRACUNIT*60

							damageObject(target)
							playSound(mo.battlen, sfx_bkpoof)
							mo.reachedtarget = timer

							for i=1,24
								local b = P_SpawnMobj(target.x, target.y, target.z+2*FRACUNIT, MT_DUMMY)
								b.momx = P_RandomRange(-32, 32)*FRACUNIT
								b.momy = P_RandomRange(-32, 32)*FRACUNIT
								b.momz = P_RandomRange(4, 16)*FRACUNIT
								b.state = S_AOADUST1
								b.frame = A|FF_FULLBRIGHT
								b.scale = FRACUNIT*3
								b.destscale = FRACUNIT/12
							end
						end
					elseif mo.reachedtarget and target.hp
						if target.hp and timer - mo.reachedtarget == 40 and mo.another == 0 or (mo.another > 0 and mo.another < 9 and timer - mo.reachedtarget == 1)
							mo.camdist = 375
							if mo.another == 0
								CAM_stop(server.P_BattleStatus[mo.battlen].cam)
								local cx = target.x + mo.camdist*cos(target.angle + ANG1*20)
								local cy = target.y + mo.camdist*sin(target.angle + ANG1*20)
								CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*50)
							end
							local randomangle = ANG1*P_RandomRange(1, 359)
							local tgtx = target.x + 150*cos(randomangle)
							local tgty = target.y + 150*sin(randomangle)
							local warp = P_SpawnMobj(tgtx, tgty, target.z + 35*FRACUNIT, MT_DUMMY)
							warp.state = S_CHAOSCONTROL1
							warp.scale = FRACUNIT
							warp.scalespeed = FRACUNIT/8
							warp.destscale = FRACUNIT*2
							playSound(mo.battlen, sfx_prloop)
							mo.another = $+1
							local c = P_SpawnMobj(tgtx, tgty, target.z, MT_PFIGHTER)
							c.skin = mo.skin
							c.cutscene = true --even if its not actually in a cutscene, dont affect it with pfighter thinkers!
							c.color = mo.color
							c.scale = mo.scale
							c.angle = mo.angle
							c.flags = mo.flags
							c.fuse = -1
							c.reachedtarget = 0
							mo.clones[#mo.clones+1] = c
						end
						
						if mo.another == 9
							if timer - mo.reachedtarget > 40 
								P_TeleportMove(mo, mo.startx, mo.starty, target.floorz)
								return true
							end
						end
					end
					//ded
					if not target.hp or target.hp <= 0 or not target.valid
						mo.deadtimer = $+1
						if mo.deadtimer >= 40
							P_TeleportMove(mo, mo.startx, mo.starty, target.floorz)
							return true
						end
					end
				end,
	}

//this move also goes to an emerald enemy in stage 6
attackDefs["emerald leech"] = {
		name = "Emerald Leech",
		type = ATK_ALMIGHTY,
		costtype = CST_SP,
		cost = 25,
		power = 300,
		desc = "suck",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
					local btl = server.P_BattleStatus[mo.battlen]
					local emeraldcolors = {SKINCOLOR_MINT, SKINCOLOR_EMERALD, SKINCOLOR_FOREST}
					if timer == 1
						mo.thokstuff = {}
						if btl.emeraldpow >= 100 and btl.emeraldpow < 200
							mo.eplevel = 1
						elseif btl.emeraldpow >= 200 and btl.emeraldpow < 300
							mo.eplevel = 2
						elseif btl.emeraldpow >= 300
							mo.eplevel = 3
						end
						S_StartSound(mo, sfx_s3kcal)
					end
					local cam = server.P_BattleStatus[mo.battlen].cam
					local tgtx = mo.x - 200*cos(mo.angle)
					local tgty = mo.y - 200*sin(mo.angle)
					cam.angle = (R_PointToAngle(mo.x, mo.y))
					CAM_goto(cam, tgtx, tgty, mo.z + 50*FRACUNIT)
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
						S_StopSound(mo, sfx_s3kcal)
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
							local s_z = (mo.z+mo.height/2)+ dist* sin(v_angle)

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
							s.tics = 10
							s.momx = (mo.x - s.x)/10
							s.momy = (mo.y - s.y)/10
							s.momz = (mo.z - s.z)/10
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
					
					if timer == 90
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
					
					if timer == 120
						return true
					end
				end,
}

attackDefs["illusionary decoy"] = {
		name = "Illusionary Decoy",
		type = ATK_SUPPORT,
		accuracy = 999,
		costtype = CST_HPPERCENT,
		cost = 0,
		desc = "Creates 3 different decoys.",
		target = TGT_CASTER,
		anim = function(mo, targets, hittargets, timer)
			local btl = server.P_BattleStatus[mo.battlen]
			local cam = btl.cam
			if timer == 1
				btl.decoycooldown = 8
				if mo.status_condition
					mo.prevstatus = mo.status_condition
				else
					mo.prevstatus = nil
				end
				if mo.fieldstate
					mo.prevfield = mo.fieldstate.type
				else
					mo.prevfield = nil
				end
				mo.replica = {}
				mo.placex = 0
				mo.placey = 0
				mo.fakeillusion = true
				mo.fakeillusionx = 0
				mo.fakeillusiony = 0
				mo.bombillusionx = 0
				mo.bombillusiony = 0
				mo.boxillusionx = 0
				mo.boxillusiony = 0
				mo.spiritillusionx = 0
				mo.spiritillusiony = 0
				mo.fakeposx = 0
				mo.fakeposy = 0
				mo.bombposx = 0
				mo.bombposy = 0
				mo.boxposx = 0
				mo.boxposy = 0
				mo.zapposx = 0
				mo.zapposy = 0
				mo.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
				mo.decoytrigger = true
				for i = 1, 3
					local e = BTL_spawnEnemy(mo, "b_metalsonic")
					e.decoytrigger = true
					e.flags = $|MF_NOGRAVITY
					e.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
					e.placex = 0
					e.placey = 0
					P_TeleportMove(e, e.x, e.y, e.floorz + 40*FRACUNIT)
					if i == 1
						e.bombillusion = true
						ANIM_set(e, e.anim_special5, true)
					elseif i == 2
						e.boxillusion = true
						ANIM_set(e, e.anim_special6, true)
					elseif i == 3
						e.spiritillusion = true
						ANIM_set(e, e.anim_special7, true)
					end
					if mo.status_condition
						e.prevstatus = mo.status_condition
					else
						e.prevstatus = nil
					end
					if mo.fieldstate
						e.prevfield = mo.fieldstate.type
					else
						e.prevfield = nil
					end
					mo.replica[#mo.replica+1] = e
				end
				
				if mo.replica and #mo.replica
					for i = 1, #mo.replica
						if mo.replica[i] and mo.replica[i].valid
							local target = mo.replica[i]
							target.flags2 = $|MF2_DONTDRAW
							if i == 2
								local an = ANG1* P_RandomRange(10, 35)
								local gox,goy

								gox = target.x + 400*cos(target.angle+an)
								goy = target.y + 400*sin(target.angle+an)

								--P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*40)	-- teleport the camera to a nice spot
								CAM_goto(cam, gox, goy, target.z + FRACUNIT*40)
								CAM_angle(cam, R_PointToAngle2(gox, goy, target.x, target.y))
								CAM_aiming(cam, 0)
							end
						end
					end
				end
			end
			
			if timer == 40
				P_LinedefExecute(1012)
				playSound(mo.battlen, sfx_s3k8a)
				playSound(mo.battlen, sfx_hamas1)
				btl.cursefield = false
				btl.icefield = false
			end
			
			if timer >= 60
			and timer < 90
			and leveltime & 1
				mo.flags2 = $ & ~MF2_DONTDRAW
				local g = P_SpawnGhostMobj(mo)
				mo.flags2 = $|MF2_DONTDRAW
				g.fuse = 2
			end
			
			if timer == 90
				ANIM_set(mo, mo.anim_special4, true)
				mo.flags2 = $ & ~MF2_DONTDRAW
				playSound(mo.battlen, sfx_psi)
				playSound(mo.battlen, sfx_hamas1)
				mo.flags = $|MF_NOGRAVITY
				P_TeleportMove(mo, mo.x, mo.y, mo.floorz + 40*FRACUNIT)
				local thok = P_SpawnMobj(mo.x, mo.y, mo.z+10*FRACUNIT, MT_DUMMY)
				thok.state = S_INVISIBLE
				thok.tics = 1
				thok.scale = FRACUNIT
				A_OldRingExplode(thok, MT_SUPERSPARK)
				mo.status_condition = COND_NORMAL
				clearField(mo)
			end
			
			if timer == 120 or timer == 140 or timer == 158 or timer == 174 or timer == 188 or timer == 200 or timer == 212 or timer == 224 or timer == 236 or timer == 248 or timer == 260 or timer == 272 or timer == 284
				playSound(mo.battlen, sfx_bufu1)
				mo.num1 = P_RandomRange(1, #mo.allies)
				mo.num2 = P_RandomRange(1, #mo.allies)
				if mo.num1 == mo.num2
					if mo.num1 != 1
						mo.num2 = 1
					else
						mo.num2 = P_RandomRange(2, #mo.allies)
					end
				end
				mo.target1 = mo.allies[mo.num1]
				mo.target2 = mo.allies[mo.num2]
			end
			
			for i = 1, #mo.allies
				local a = mo.allies[i]
				a.buffs = mo.buffs
				if timer == 100
					//unfortunately we gotta cheat a little and have to save the positions before they reset
					if a.fakeillusion
						mo.fakeposx = a.x
						mo.fakeposy = a.y
					end
					if a.bombillusion
						mo.bombposx = a.x
						mo.bombposy = a.y
					end
					if a.boxillusion
						mo.boxposx = a.x
						mo.boxposy = a.y
					end
					if a.spiritillusion
						mo.zapposx = a.x
						mo.zapposy = a.y
					end
				end
				if timer == 120 or timer == 140 or timer == 158 or timer == 174 or timer == 188 or timer == 200 or timer == 212 or timer == 224 or timer == 236 or timer == 248 or timer == 260 or timer == 272 or timer == 284
					if a == mo.target1
						a.placex = mo.target2.x
						a.placey = mo.target2.y
					end
					if a == mo.target2
						a.placex = mo.target1.x
						a.placey = mo.target1.y
					end
				end
				if timer >= 120 and timer < 300
					if a.placex != 0 and a.placey != 0
						local e = P_SpawnGhostMobj(a)
						e.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
						a.momx = (a.placex - a.x)/2
						a.momy = (a.placey - a.y)/2
					end
				end
				if timer == 300
					a.illusion = true
					ANIM_set(a, a.anim_special8, true)
					a.flags = $ & ~MF_NOGRAVITY
					a.momz = 5*FRACUNIT
					local thok = P_SpawnMobj(a.x, a.y, a.z+10*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT
					A_OldRingExplode(thok, MT_SUPERSPARK)
					local g = P_SpawnGhostMobj(a)
					g.colorized = true
					g.destscale = FRACUNIT*8
					a.angle = R_PointToAngle2(a.x, a.y, cam.x, cam.y)
					//unfortunately we gotta cheat a little and have to save the positions before they reset
					if a.fakeillusion
						mo.fakeillusionx = a.x
						mo.fakeillusiony = a.y
						a.fakeillusion = false
					end
					if a.bombillusion
						mo.bombillusionx = a.x
						mo.bombillusiony = a.y
						a.bombillusion = false
					end
					if a.boxillusion
						mo.boxillusionx = a.x
						mo.boxillusiony = a.y
						a.boxillusion = false
					end
					if a.spiritillusion
						mo.spiritillusionx = a.x
						mo.spiritillusiony = a.y
						a.spiritillusion = false
					end
					a.renderflags = $ & ~RF_FULLBRIGHT & ~RF_NOCOLORMAPS
					mo.renderflags = $ & ~RF_FULLBRIGHT & ~RF_NOCOLORMAPS
				end
				if timer >= 100 and P_IsObjectOnGround(a) and timer < 339
					ANIM_set(a, a.anim_stand, false)
					//we're actually switching them back to the starting position last second
					//but we're keeping the ending positions and applying them to the enemies
					if i == 1
						P_TeleportMove(a, mo.fakeposx, mo.fakeposy, a.z)
					elseif i == 2
						P_TeleportMove(a, mo.bombposx, mo.bombposy, a.z)
					elseif i == 3
						P_TeleportMove(a, mo.boxposx, mo.boxposy, a.z)
					elseif i == 4
						P_TeleportMove(a, mo.zapposx, mo.zapposy, a.z)
					end
					if R_PointToDist2(a.x, a.y, mo.fakeillusionx, mo.fakeillusiony) < 2*FRACUNIT
						a.fakeillusion = true
						a.actualhp = mo.hp
					end
					if R_PointToDist2(a.x, a.y, mo.bombillusionx, mo.bombillusiony) < 2*FRACUNIT
						a.bombillusion = true
					end
					if R_PointToDist2(a.x, a.y, mo.boxillusionx, mo.boxillusiony) < 2*FRACUNIT
						a.boxillusion = true
					end
					if R_PointToDist2(a.x, a.y, mo.spiritillusionx, mo.spiritillusiony) < 2*FRACUNIT
						a.spiritillusion = true
					end
					--a.defaultcoords = {a.x, a.y, a.z}
				end
				if timer == 339
					a.hp = 5
					a.maxhp = 5
					a.turns = 1
				end
			end
			
			if timer == 300
				P_LinedefExecute(1013)
				playSound(mo.battlen, sfx_reflc)
				playSound(mo.battlen, sfx_bufu6)
			end
		
			if mo.replica and #mo.replica
				for i = 1, #mo.replica
					if mo.replica[i] and mo.replica[i].valid
						local t = mo.replica[i]
						if timer >= 1
						and timer < 40
						and leveltime & 1

							t.flags2 = $ & ~MF2_DONTDRAW
							local g = P_SpawnGhostMobj(t)
							t.flags2 = $|MF2_DONTDRAW
							--g.colorized = true
							g.fuse = 2
						end
						if timer == 40
							ANIM_set(t, t.anim_special4, true)
							t.flags2 = $ & ~MF2_DONTDRAW
							local thok = P_SpawnMobj(t.x, t.y, t.z+10*FRACUNIT, MT_DUMMY)
							thok.state = S_INVISIBLE
							thok.tics = 1
							thok.scale = FRACUNIT
							A_OldRingExplode(thok, MT_SUPERSPARK)
							t = nil
						end
					end
				end
			end
			
			if timer == 340
				BTL_normalizePositions(mo.allies, true)
				mo.dontruby = false
				return true
			end
		end,
	}
	
attackDefs["rearrangement type a"] = {
		name = "Rearrangement Type A",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 20,
		desc = "Randomizes all stats",
		target = TGT_EVERYONE,
		norepel = true,
		anim = function(mo, targets, hittargets, timer)
			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_GREEN, SKINCOLOR_LAVENDER, SKINCOLOR_TEAL, SKINCOLOR_RED}
			local btl = server.P_BattleStatus[mo.battlen]
			if timer == 1
				btl.rearrangecooldown = 6
				playSound(mo.battlen, sfx_psi)
			end
			
			if timer == 100
				playSound(mo.battlen, sfx_cdfm44)
				playSound(mo.battlen, sfx_s3k73)
			end

			for i = 1, #targets do
				local target = targets[i]
				if leveltime%4 == 0 and timer <= 100
					local g = P_SpawnGhostMobj(target)
					g.color = colors[P_RandomRange(1, #colors)]
					g.colorized = true
					g.destscale = FRACUNIT*4
					g.frame = $|FF_FULLBRIGHT
				end
				if timer >= 20 and timer < 100
					if target != mo
						target.state = S_PLAY_EDGE
					end
				end	
				if timer <= 40 and timer >= 20
					target.angle = $ + 25 * ANG1
				elseif timer > 40 and timer <= 60
					target.angle = $ + 45 * ANG1
				elseif timer > 60 and timer <= 70
					target.angle = $ + 65 * ANG1
				elseif timer > 70 and timer <= 100
					target.angle = $ + 85 * ANG1
				end
				if timer >= 100
					if timer == 100
						if target != mo
							ANIM_set(target, target.anim_hurt, true)
						end
						for i = 1,16
							local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							dust.angle = ANGLE_90 + ANG1* (22*(i-1))
							dust.state = S_CDUST1
							P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
							dust.color = colors[P_RandomRange(1, #colors)]
							dust.scale = FRACUNIT*2
						end
						buffStat(target, "atk", 25*P_RandomRange(-3, 3))
						buffStat(target, "mag", 25*P_RandomRange(-3, 3))
						buffStat(target, "def", 25*P_RandomRange(-3, 3))
						buffStat(target, "agi", 25*P_RandomRange(-3, 3))
						BTL_logMessage(targets[1].battlen, "All stats randomized!")
					end
					if timer <= 120
						target.angle = $ + 60 * ANG1
					end
					if timer <= 130 and timer > 120
						target.angle = $ + 30 * ANG1
					end
					if timer <= 140 and timer > 130
						target.angle = $ + 15 * ANG1
					end
					if timer <= 150 and timer > 140
						target.angle = $ + 7 * ANG1
					end
					if timer <= 160 and timer > 150
						target.angle = $ + 3 * ANG1
					end
				end
			end
			if timer == 170
				return true
			end
		end,
	}
	
attackDefs["rearrangement type b"] = {
		name = "Rearrangement Type B",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 20,
		desc = "Shuffles enemy team's movesets",
		target = TGT_ALLENEMIES,
		norepel = true,
		anim = function(mo, targets, hittargets, timer)
			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_ROSY, SKINCOLOR_RED, SKINCOLOR_BLUE}
			local btl = server.P_BattleStatus[mo.battlen]
			if timer == 1
				btl.rearrangecooldown = 6
				playSound(mo.battlen, sfx_psi)
				mo.movesets = {}
				mo.targetstartx = {}
				mo.targetstarty = {}
			end
			
			if timer == 100 or timer == 120
				playSound(mo.battlen, sfx_s3kcas)
			end 
			
			if timer == 140
				playSound(mo.battlen, sfx_cdfm44)
				playSound(mo.battlen, sfx_s3k73)
			end

			for i = 1, #hittargets do
				local target = hittargets[i]
				if timer == 2
					mo.movesets[#mo.movesets+1] = target.skills
					mo.targetstartx[#mo.targetstartx+1] = target.x
					mo.targetstarty[#mo.targetstarty+1] = target.y
				end
				if leveltime%4 == 0 and timer <= 140
					local g = P_SpawnGhostMobj(target)
					g.color = colors[P_RandomRange(1, #colors)]
					g.colorized = true
					g.destscale = FRACUNIT*4
					g.frame = $|FF_FULLBRIGHT
				end
				
				if timer == 100
					local pos = (#mo.targetstartx+1) - i
					P_TeleportMove(target, mo.targetstartx[pos], mo.targetstarty[pos], target.z)
				elseif timer == 120
					local pos = (#mo.targetstartx) - i
					if pos <= 0
						pos = #mo.targetstartx
					end
					P_TeleportMove(target, mo.targetstartx[pos], mo.targetstarty[pos], target.z)
				end
				
				
				if timer >= 20 and timer < 140
					target.state = S_PLAY_EDGE
				end	
				if timer <= 40 and timer >= 20
					target.angle = $ + 25 * ANG1
				elseif timer > 40 and timer <= 60
					target.angle = $ + 45 * ANG1
				elseif timer > 60 and timer <= 70
					target.angle = $ + 65 * ANG1
				elseif timer > 70 and timer <= 140
					target.angle = $ + 85 * ANG1
				end
				if timer >= 140
					if timer == 140
						local e = P_RandomRange(1, #mo.movesets)
						target.skills = mo.movesets[e]
						table.remove(mo.movesets, e)
						ANIM_set(target, target.anim_hurt, true)
						P_TeleportMove(target, mo.targetstartx[i], mo.targetstarty[i], target.z)
						BTL_logMessage(targets[1].battlen, "Movesets shuffled!")
						for i = 1,16
							local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							dust.angle = ANGLE_90 + ANG1* (22*(i-1))
							dust.state = S_CDUST1
							P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
							dust.color = colors[P_RandomRange(1, #colors)]
							dust.scale = FRACUNIT*2
						end
					end
					if timer <= 160
						target.angle = $ + 60 * ANG1
					end
					if timer <= 170 and timer > 160
						target.angle = $ + 30 * ANG1
					end
					if timer <= 180 and timer > 170
						target.angle = $ + 15 * ANG1
					end
					if timer <= 190 and timer > 180
						target.angle = $ + 7 * ANG1
					end
					if timer <= 200 and timer > 190
						target.angle = $ + 3 * ANG1
					end
				end
			end
			if timer == 220
				return true
			end
		end,
	}
	
attackDefs["multi god hand"] = {
		name = "God's hand",
		type = ATK_STRIKE,
		power = 450,
		accuracy = 100,
		costtype = CST_HPPERCENT,
		cost = 25,
		desc = "Severe Strike damage to \none enemy. Very high critical rate.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			if timer == 16
				mo.zahando = {}
				mo.kill = false
				mo.handtarget = hittargets[P_RandomRange(1, #hittargets)]
				local target = mo.handtarget

				S_StartSound(mo, sfx_becrsh)
				for i = 1, 16 do 
					local atk = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					atk.momz = -1*FRACUNIT
					atk.state = S_AOADUST1
					atk.scale = FRACUNIT*1
					atk.destscale = FRACUNIT*2
					atk.angle = ANG1*360 / 16	* (i-1)
					P_InstaThrust(atk, atk.angle, 10*FRACUNIT)
				end

				mo.hand = P_SpawnMobj(target.x, target.y, target.z + 500*FRACUNIT, MT_DUMMY)
				mo.hand.momz = -25*FRACUNIT
				mo.hand.tics = -1
				mo.hand.fuse = -1
				mo.hand.sprite = SPR_HAND
				mo.hand.frame = A
				mo.hand.scale = FRACUNIT*4
				mo.hand.target = target
				mo.pause = 0
				mo.zahando[#mo.zahando+1] = mo.hand
			end

			local j = mo.columns and #mo.columns or 0
			while j
				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)
				j = $-1
			end
			
			if mo.zahando and #mo.zahando
				for i = 1, #mo.zahando
					if mo.zahando[i] and mo.zahando[i].valid
						local h = mo.zahando[i]

						if leveltime%4 == 0 and mo.pause == 0
							for i = 1, 16 do
								local atk = P_SpawnMobj(h.x, h.y, h.z, MT_DUMMY)
								atk.momz = -1*FRACUNIT
								atk.state = S_AOADUST1
								atk.scale = FRACUNIT*2
								atk.destscale = FRACUNIT*4
								atk.angle = ANG1*360 / 16	* (i-1)
								P_InstaThrust(atk, atk.angle, 30*FRACUNIT)
							end
						end
						
						if mo.pause == 0
							h.flags2 = $ & ~MF2_DONTDRAW
							for i = 1, 2
								local f = P_SpawnMobj(h.x + P_RandomRange(-32, 32)*FRACUNIT, h.y + P_RandomRange(-32, 32)*FRACUNIT, h.z + FRACUNIT*60, MT_DUMMY)
								f.state = S_QUICKBOOM1
								f.color = SKINCOLOR_RED
								f.scale = FRACUNIT*3
							end
						end
						
						if h.z <= mo.floorz + 100*FRACUNIT and not mo.kill
							mo.pause = $+1
						end
						
						if mo.pause > 0
							if mo.pause == 1
								S_StopSound(mo)
							end
							if leveltime & 1
								h.momz = 0
								h.flags2 = $ & ~MF2_DONTDRAW
								local g = P_SpawnGhostMobj(h)
								h.flags2 = $|MF2_DONTDRAW
								g.fuse = 2
							end
							if mo.pause == 20
								playSound(mo.battlen, sfx_portal)
								local luckytarget = P_RandomRange(1, #hittargets)
								for i = 1, #hittargets
									if hittargets[i] != mo.handtarget
										if hittargets[luckytarget] != mo.handtarget
											if hittargets[i] == hittargets[luckytarget]
												local c = P_SpawnMobj(h.x, h.y, h.z, MT_DUMMY)
												c.momz = -25*FRACUNIT
												c.tics = -1
												c.fuse = -1
												c.sprite = SPR_HAND
												c.frame = A
												c.scale = FRACUNIT*4
												c.target = hittargets[luckytarget]
												mo.zahando[#mo.zahando+1] = c
											end
										else
											local c = P_SpawnMobj(h.x, h.y, h.z, MT_DUMMY)
											c.momz = -25*FRACUNIT
											c.tics = -1
											c.fuse = -1
											c.sprite = SPR_HAND
											c.frame = A
											c.scale = FRACUNIT*4
											c.target = hittargets[i]
											mo.zahando[#mo.zahando+1] = c
										end
									end
								end
							end
							h.momx = (h.target.x - h.x)/5
							h.momy = (h.target.y - h.y)/5
							if mo.pause == 75
								mo.kill = true
								playSound(mo.battlen, sfx_becrsh)
								mo.pause = 0
							end
						end
						
						if mo.kill
							h.momz = -25*FRACUNIT
						end

						if h.z <= mo.floorz				
							local target = h.target
							-- delet old shit:
							mo.fangle = (R_PointToAngle(target.x, target.y)) + ANG1*180
							mo.columns = {}

							local a = mo.fangle - ANG1*80

							for i = 1, 16
								local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
								P_InstaThrust(m, a, FRACUNIT*48)
								mo.columns[#mo.columns+1] = m
								m.state = S_INVISIBLE
								m.tics = TICRATE
								a = $+ ANG1*10
							end

							damageObject(target)

							localquake(mo.battlen, FRACUNIT*50, 10)
							P_RemoveMobj(h)
						end
					end
				end
			end
			
			if timer == 115
				mo.columns = nil
				mo.fangle = nil
				return true
			end
		end,
	}
	
attackDefs["indirect energy blast"] = {
		name = "Indirect energy blast",
		type = ATK_ALMIGHTY,
		power = 450,
		accuracy = 999,
		costtype = CST_SPPERCENT,
		cost = 10,
		link = true,
		desc = "Light Almighty damage to\none enemy. Any following attacks\ngain Link follow-ups.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			local btl = server.P_BattleStatus[mo.battlen]
			local cam = btl.cam
			
			//anim set 1: initiating the link
			if btl.portaldamage <= 0
				
				if timer == 1
					mo.balls = {} //yeah it's on purpose again
					mo.startx = mo.x
					mo.starty = mo.y
					mo.camangle = mo.angle
					playSound(mo.battlen, sfx_s3k5a)
					ANIM_set(mo, mo.anim_special3, true)
					local e = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					e.state = S_MSSHIELD_F1
					e.fuse = 30
					e.scale = FRACUNIT
				end
				
				if timer < 50
					CAM_stop(cam)
					local tgtx = mo.x + 400*cos(mo.camangle)
					local tgty = mo.y + 400*sin(mo.camangle)
					cam.angle = (R_PointToAngle(mo.x, mo.y))
					P_TeleportMove(cam, tgtx, tgty, mo.z + 40*FRACUNIT)
				end
				
				if timer == 30
					playSound(mo.battlen, sfx_jump)
					mo.angle = ANG1*P_RandomRange(1, 359)
					ANIM_set(mo, mo.anim_getup, true)
					mo.momz = 15*FRACUNIT
					mo.tgtx = mo.x + 500*cos(mo.angle)
					mo.tgty = mo.y + 500*sin(mo.angle)
				end
				
				if timer == 50
					ANIM_set(mo, mo.anim_special1, true)
					playSound(mo.battlen, sfx_s3k54)
					P_InstaThrust(mo, mo.angle + ANG1*180, 50*FRACUNIT)
					local b = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					b.state = S_ENERGYBALL1
					b.fuse = -1
					b.builtdiff = true
					b.warp = 1
					b.scale = FRACUNIT
					b.momx = (mo.tgtx - b.x)/15
					b.momy = (mo.tgty - b.y)/15
					mo.balls[#mo.balls+1] = b
				end
				
				--MULTI HIT LINK SKILLS DON'T WORK NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
				/*if timer == 54 or timer == 58
					playSound(mo.battlen, sfx_s3k54)
					local b = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					b.state = S_ENERGYBALL1
					b.fuse = -1
					b.warp = 1
					b.scale = FRACUNIT
					b.momx = (mo.tgtx - b.x)/15
					b.momy = (mo.tgty - b.y)/15
					mo.balls[#mo.balls+1] = b
				end*/
				
				if mo.balls and #mo.balls
					for i = 1, #mo.balls
						if mo.balls[i] and mo.balls[i].valid
							local b = mo.balls[i]
							b.warp = $+1
							if b.warp == 15
								if b.builtdiff
									local warp = P_SpawnMobj(b.x, b.y, b.z + 75*FRACUNIT, MT_DUMMY)
									warp.state = S_CHAOSCONTROL1
									warp.scale = FRACUNIT*2
									warp.scalespeed = FRACUNIT/8
									warp.destscale = FRACUNIT*4
									playSound(mo.battlen, sfx_prloop)
									P_RemoveMobj(b)
								else
									P_RemoveMobj(b)
								end
							end
						end
					end
				end
							
				
				if timer >= 50
					mo.momx = $*80/100
					mo.momy = $*80/100
					mo.momz = 0
					local tgtx = mo.startx + 900*cos(mo.camangle)
					local tgty = mo.starty + 900*sin(mo.camangle)
					cam.angle = (R_PointToAngle(mo.x, mo.y))
					CAM_goto(cam, tgtx, tgty, mo.z + 40*FRACUNIT)
				end
				
				if timer == 100
					P_TeleportMove(mo, mo.startx, mo.starty, mo.floorz) 
					btl.portaldamage = getDamage(target, mo, nil, 100)
					return true
				end
				
			else 	//anim set 2: the link's attack
			
				if timer == 1
					btl.portalready = false
					target.doomed = false
					mo.balls = {}
				end
				
				if timer == 2
					mo.randomangle = ANG1*P_RandomRange(1, 359)
					mo.tgtx = target.x + 200*cos(mo.randomangle)
					mo.tgty = target.y + 200*sin(mo.randomangle)
					mo.tgtz = target.z  + P_RandomRange(50, 200)*FRACUNIT
					local warp = P_SpawnMobj(mo.tgtx, mo.tgty, mo.tgtz + 75*FRACUNIT, MT_DUMMY)
					warp.state = S_CHAOSCONTROL1
					warp.scale = FRACUNIT*2
					warp.scalespeed = FRACUNIT/8
					warp.destscale = FRACUNIT*4
					playSound(mo.battlen, sfx_prloop)
					playSound(mo.battlen, sfx_s3k54)
					local b = P_SpawnMobj(mo.tgtx, mo.tgty, mo.tgtz, MT_DUMMY)
					b.state = S_ENERGYBALL1
					b.fuse = -1
					b.scale = FRACUNIT*3/4
					b.momx = (target.x - b.x)/10
					b.momy = (target.y - b.y)/10
					b.momz = (target.z - b.z)/10
					mo.balls[#mo.balls+1] = b
				end
				
				--IM GONNA CRY
				/*if timer == 2 or timer == 6 or timer == 10
					playSound(mo.battlen, sfx_s3k54)
					local b = P_SpawnMobj(mo.tgtx, mo.tgty, mo.tgtz, MT_DUMMY)
					b.state = S_ENERGYBALL1
					b.fuse = -1
					b.scale = FRACUNIT*3/4
					b.momx = (target.x - b.x)/10
					b.momy = (target.y - b.y)/10
					b.momz = (target.z - b.z)/10
					mo.balls[#mo.balls+1] = b
				end*/
				
				if mo.balls and #mo.balls
					for i = 1, #mo.balls
						if mo.balls[i] and mo.balls[i].valid
							local b = mo.balls[i]
							if R_PointToDist2(b.x, b.y, target.x, target.y) < FRACUNIT*5
								damageObject(target)
								P_RemoveMobj(b)
							end
						end
					end
				end
				
				if timer == 50
					btl.portaldamage = 0
					return true
				end
			end
		end,
	}

addHook("MobjThinker", function(mo)
	if gamemap != 11 return end
	if mo.cutscene return end
	local btl = server.P_BattleStatus[mo.battlen]
	//thinker for metal
	if mo.enemy and enemyList[mo.enemy].name != nil and mo.enemy == "b_metalsonic"
	
		if btl.battlestate == BS_START
			btl.metaloop = mo
			mo.counter = $ or false
			mo.countercooldown = $ or 0
			mo.morb = $ or false
			mo.illusion = $ or false
			mo.fakeillusion = $ or false
			mo.bombillusion = $ or false
			mo.boxillusion = $ or false
			mo.spiritillusion = $ or false
			mo.hello = $ or false
			mo.rearrangebtrigger = $ or false
			mo.rearrangeatrigger = $ or false
			mo.decoytrigger = $ or false
			mo.rearrangebtrigger2 = $ or false
			mo.rearrangeatrigger2 = $ or false
			mo.dontruby = $ or false
			mo.prevstatus = $ or nil
			mo.prevfield = $ or nil
			
			btl.counterscene = $ or true
			btl.metaloop = $ or nil
			btl.portaldamage = $ or 0
			btl.portalready = $ or false
			btl.rearrangecooldown = $ or 0
			btl.decoycooldown = $ or 6
			btl.randomtimer = $ or 0
			btl.icefield = $ or false
			btl.cursefield = $ or false
			/*btl.startx = {}
			btl.starty = {}*/
		end
		
		
		--print(btl.decoycooldown)
		--print(mo.decoytrigger)
		--print(mo.countered)
		
		//particles
		if not server.P_DialogueStatus[btl.n].running and mo.hp > 0
			if not (leveltime%P_RandomRange(10, 80))
				local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height, MT_DUMMY)
				elec.sprite = SPR_DELK
				elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
				elec.destscale = FRACUNIT*4
				elec.scalespeed = FRACUNIT/4
				elec.tics = TICRATE/8
				elec.color = SKINCOLOR_MAGENTA
			end

			if leveltime%P_RandomRange(10, 80) == 0
				local a = R_PointToAngle(mo.x, mo.y)
				local x = mo.x - cos(a)
				local y = mo.y - sin(a)

				local dummy = P_SpawnMobj(x, y, mo.z, MT_DUMMY)
				if mo.skin
					dummy.skin = mo.skin
				end
				dummy.state = mo.state
				dummy.sprite = mo.sprite
				dummy.sprite2 = mo.sprite2
				dummy.frame = mo.frame
				dummy.angle = mo.angle
				dummy.scale = mo.scale
				dummy.colorized = true
				dummy.color = SKINCOLOR_MAGENTA
				dummy.fuse = 2
			end
		end
		
		//change skins when using dyne skill
		//quick note if you're ever gonna do something like this in the future make sure to actually look in things like dyneskills 
		if mo.attack and (mo.attack.power == 350 or mo.attack.power == 400)
			local type = mo.attack.type
			if type == ATK_FIRE
				mo.skin = "sonic"
			elseif type == ATK_BLESS
				mo.skin = "tails"
			elseif type == ATK_ELEC
				mo.skin = "knuckles" --no evoker anim for knuckles it doesnt even set it to stnd :(
				ANIM_set(mo, mo.anim_stand, true)
			elseif type == ATK_WIND
				mo.skin = "amy"
			elseif type == ATK_CURSE
				mo.skin = "eggman"
				ANIM_set(mo, mo.anim_stand, true) --not for eggman either
			elseif type == ATK_ICE
				mo.skin = "blaze" 
				ANIM_set(mo, mo.anim_stand, true) --blaze too
			elseif type == ATK_PSY
				mo.skin = "silver"
			end
			ANIM_set(mo, charStats[mo.skin].anim_evoker, true)
			mo.color = skins[mo.skin].prefcolor
			if not mo.morb
				playSound(mo.battlen, sfx_s3k74)
				playSound(mo.battlen, sfx_psi)
				for i = 1,15
					local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_WHITE
					dust.scale = FRACUNIT*2
				end
				mo.clone = P_SpawnMobj(mo.x, mo.y, mo.z, MT_PFIGHTER)
				local c = mo.clone
				c.skin = mo.skin
				c.cutscene = true --even if its not actually in a cutscene, dont affect it with pfighter thinkers!
				c.timer = 0
				c.color = SKINCOLOR_MAGENTA
				c.colorized = true
				c.scale = mo.scale
				c.angle = mo.angle
				c.tics = -1
				mo.morb = true
			end
		else
			mo.morb = false
			mo.skin = "metalsonic"
			mo.color = skins[mo.skin].prefcolor
		end
		
		if btl.battlestate == BS_PRETURN
			mo.deathtimer = 0
			mo.deathanim = true
		end
		
		//counter script (originally for shadow)
		if not mo.illusion
			if btl.battlestate == BS_PRETURN and not server.P_DialogueStatus[btl.n].running
				if not btl.counterscene
					mo.flags2 = $ & ~MF2_DONTDRAW
				end
				//for indirect energy blast
				mo.luckyman = P_RandomRange(1, #mo.enemies)
				if mo.countercooldown > 0
					mo.countercooldown = $-1
				end
				//lose the counter after a turn passes with the counter active
				if mo.counter
					mo.countercooldown = P_RandomRange(2, 5)
					mo.counter = false
				end
				if mo.countercooldown <= 0 and btl.turnorder[1] != mo and P_RandomRange(1,4) == 1
					mo.counter = true
					mo.clone = P_SpawnMobj(mo.x, mo.y, mo.z, MT_PFIGHTER)
					local c = mo.clone
					c.skin = mo.skin
					c.cutscene = true --even if its not actually in a cutscene, dont affect it with pfighter thinkers!
					c.timer = 0
					c.color = SKINCOLOR_BLUE
					c.colorized = true
					c.scale = mo.scale
					c.angle = mo.angle
					c.tics = -1
					c.blendmode = AST_ADD
				end
			end
		else
			mo.counter = false
			mo.countercooldown = P_RandomRange(2, 5)
		end
		
		//reappear after counter
		if not server.P_DialogueStatus[btl.n].running
			if mo.hello
				mo.flags2 = $ & ~MF2_DONTDRAW
				mo.hello = false
			end
		end
		
		//clone script
		if mo.clone and mo.clone.valid
			local c = mo.clone
			P_TeleportMove(c, mo.x, mo.y, mo.z)
			c.timer = $+1
			if c.timer == 2
				c.frame = TR_TRANS10
			elseif c.timer == 8
				c.frame = TR_TRANS20
			elseif c.timer == 14
				c.frame = TR_TRANS30
			elseif c.timer == 20
				c.frame = TR_TRANS40
			elseif c.timer == 26
				c.frame = TR_TRANS50
			elseif c.timer == 32
				c.frame = TR_TRANS60
			elseif c.timer == 38
				c.frame = TR_TRANS70
			elseif c.timer == 44
				c.frame = TR_TRANS80
			elseif c.timer == 50
				c.frame = TR_TRANS90
			elseif c.timer == 56
				P_RemoveMobj(c)
			end
		end
		
		if not mo.illusion and not mo.bombillusion and not mo.spiritillusion and not mo.boxillusion
			if mo.countered
				local target = mo.enemies[P_RandomRange(1, #mo.enemies)]
				mo.counter = false
				mo.countercooldown = P_RandomRange(5, 10)
				P_TeleportMove(target, mo.x, mo.y, mo.z)
				mo.flags2 = $|MF2_DONTDRAW
				local damage = getDamage(target, btl.turnorder[1]) --just in case
				damageObject(target, damage, nil, 100)
				if target == btl.turnorder[1]
					target.lmao = true
				end
				if btl.counterscene 
					btl.turnorder[1].whoops = true
					if charStats[target.stats].name == "Sonic"
						D_startEvent(mo.battlen, "ev_shadow_timecounter_s")
					elseif charStats[target.stats].name == "Tails"
						D_startEvent(mo.battlen, "ev_shadow_timecounter_t")
					elseif charStats[target.stats].name == "Knuckles"
						D_startEvent(mo.battlen, "ev_shadow_timecounter_k")
					elseif charStats[target.stats].name == "Amy"
						D_startEvent(mo.battlen, "ev_shadow_timecounter_a")
					end
					//unintended skin failsafe
					if charStats[target.stats].name != "Sonic" and charStats[target.stats].name != "Tails" and charStats[target.stats].name != "Knuckles" and charStats[target.stats].name != "Amy"
						btl.counterscene = false
						mo.hello = true
					end
				end
				target.angle = mo.angle
				mo.countered = false
			end
			
			//ruby illusion effects to mess with your brain and make cool decorations
			if btl.battletime%300 == 0 and btl.battlestate != BS_START and P_RandomRange(1,2) == 1 and not cutscene and not mo.dontruby
				btl.randomtimer = 1
			end
			
			if btl.randomtimer > 0
				btl.randomtimer = $+1
				local randnum = 1
				for i = 1, 12
					if btl.randomtimer == 2*i
						P_LinedefExecute(1015)
						randnum = P_RandomRange(1, 6)
					end
				end
				if btl.randomtimer == 24
					for k,v in ipairs(mo.enemies)
						if v and v.control and v.control.valid
							P_FlashPal(v.control, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
					end
					playSound(mo.battlen, sfx_shattr)
					playSound(mo.battlen, sfx_shattr)
					for m in mobjs.iterate() do
						if m and m.valid and m.state == S_FLAME
							P_RemoveMobj(m)
						end
					end
					if randnum == 1 //ELEVATOR GOES REALLY DOWN
						P_LinedefExecute(1014)
						btl.icefield = false
						btl.cursefield = false
					end
					if randnum == 2 //ELEVATOR GOES REALLY UP
						P_LinedefExecute(1016)
						btl.icefield = false
						btl.cursefield = false
					end
					if randnum == 3 //SPAWN FIRE
						for i = 1, 30
							local x = P_RandomRange(-12300, -10370)*FRACUNIT
							local y = P_RandomRange(6590, 8580)*FRACUNIT
							local flame = P_SpawnMobj(x, y, mo.floorz, MT_DUMMY)
							flame.state = S_FLAME
							flame.scale = FRACUNIT*P_RandomRange(1, 3)
							flame.frame = $|FF_FULLBRIGHT
						end
						btl.icefield = false
						btl.cursefield = false
					end
					if randnum == 4 //ICE FIELD
						btl.icefield = true
						btl.cursefield = false
					end
					if randnum == 5 //STOP ELEVATOR (and darken the place)
						P_LinedefExecute(1017)
						for s in sectors.iterate
							if s.tag == 3
								s.lightlevel = 175
							end
						end
						btl.icefield = false
						btl.cursefield = false
					end
					if randnum == 6 //CURSE FIELD
						btl.cursefield = true
						btl.icefield = false
					end
					/*if randnum == 6 //SWAP PLAYER POSITIONS [doesnt work :(]
						for i = 1, #mo.enemies
							if #mo.enemies > 1 //pls i dont want to swap places with myself
								if i < #mo.enemies
									P_TeleportMove(mo.enemies[i], btl.startx[i+1], btl.startx[i+1], mo.enemies[i].z)
								else
									P_TeleportMove(mo.enemies[i], btl.startx[1], btl.startx[1], mo.enemies[i].z)
								end
							end
						end
						btl.icefield = false
					end*/
					//reset lightlevel
					if randnum != 5
						for s in sectors.iterate
							if s.tag == 3
								s.lightlevel = 255
							end
						end
					end
					btl.randomtimer = 0
				end
			end
			
			if btl.icefield
				for i = 1, 7
					local x = P_RandomRange(-12300, -10370)*FRACUNIT
					local y = P_RandomRange(6590, 8580)*FRACUNIT
					local dust = P_SpawnMobj(x, y, mo.floorz+P_RandomRange(-100, 600)*FRACUNIT, MT_DUMMY)
					dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
					dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT*P_RandomRange(1,2), 0
					dust.destscale = FRACUNIT*9/4
					dust.scalespeed = FRACUNIT/18
				end
			end
			
			if btl.cursefield
				for i = 1,20
					local x = P_RandomRange(-12300, -10370)*FRACUNIT
					local y = P_RandomRange(6590, 8580)*FRACUNIT
					local thok = P_SpawnMobj(x, y, mo.floorz, MT_DUMMY)
					thok.flags = MF_NOBLOCKMAP
					thok.color = SKINCOLOR_RED
					if leveltime%2 then thok.color = SKINCOLOR_BLACK end
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
		end
		
		//store startx and y
		/*if btl.battlestate == BS_START
			for i = 1, #mo.enemies
				btl.startx[i] = mo.enemies[i].x
				btl.starty[i] = mo.enemies[i].y
			end
		end*/
				
	else //thinker for truly organic substances
		
		//testing hack: multi target
		/*if mo.plyr
			mo.skills = {"maziodyne"}
		end*/
		
		if btl.battlestate == BS_START
			mo.startskills = mo.skills
		end
		
		//energy blast link
		if btl.battlestate == BS_PRETURN and not server.P_DialogueStatus[btl.n].running
			if btl.portaldamage > 0 and not btl.portalready
				if P_RandomRange(1, 6) == 1
					btl.portalready = true
				end
			end
			if btl.portalready and btl.portaldamage > 0
				if btl.metaloop and btl.metaloop.valid
					for i = 1, #btl.metaloop.enemies
						if btl.metaloop.enemies[btl.metaloop.luckyman] == mo
							mo.linkstate = {
								link = 0,
								maxlink = 1,
								linkboost = 0,
								atkref = "indirect energy blast",
								entref = btl.metaloop,
								dmg = btl.portaldamage,
							}
							mo.doomed = true
							mo.portalnum = #btl.linkhits+1
						end
					end
				end
			end
		end
		
		if btl.portalready and btl.portaldamage > 0
			if mo.doomed
				btl.linkhits[mo.portalnum] = mo
			end
		end
		
		//apology essay when you hit your ally due to a counter
		if mo.whoops and not btl.counterscene 
			if not mo.lmao
				if charStats[mo.stats].name == "Sonic"
					D_startEvent(mo.battlen, "ev_shadow_timecounter_s2")
				elseif charStats[mo.stats].name == "Tails"
					D_startEvent(mo.battlen, "ev_shadow_timecounter_t2")
				elseif charStats[mo.stats].name == "Knuckles"
					D_startEvent(mo.battlen, "ev_shadow_timecounter_k2")
				elseif charStats[mo.stats].name == "Amy"
					D_startEvent(mo.battlen, "ev_shadow_timecounter_a2")
				end
			else //unless you hit yourself (idiot)
				if charStats[mo.stats].name == "Sonic"
					D_startEvent(mo.battlen, "ev_shadow_timecounter_s2")
				elseif charStats[mo.stats].name == "Tails"
					D_startEvent(mo.battlen, "ev_shadow_timecounter_t3")
				elseif charStats[mo.stats].name == "Knuckles"
					D_startEvent(mo.battlen, "ev_shadow_timecounter_k3")
				elseif charStats[mo.stats].name == "Amy"
					D_startEvent(mo.battlen, "ev_shadow_timecounter_a3")
				end
			end
			mo.lmao = false
			mo.whoops = false
		end
		
		/*if btl.turnorder[1] == mo
			if mo.enemies and #mo.enemies
				for i = 1, #mo.enemies
					local e = mo.enemies[i]
					if i == mo.t_target
						if e.fakeillusion
							print("fakeillusion")
						elseif e.bombillusion
							print("bombillusion")
						elseif e.boxillusion
							print("boxillusion")
						elseif e.spiritillusion
							print("spiritillusion")
						end
						if e.illusion
							print("illusion")
						end
					end
				end
			end
		end*/
	end
end, MT_PFIGHTER)

//event for when shadow time counters someone
eventList["ev_shadow_timecounter_s"] = {
	[1] = {"text", "Sonic", "Ow, ow, ow!", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[2] = {"function",
				function(evt, btl)
					btl.counterscene = false
					return true
				end
			},
}

eventList["ev_shadow_timecounter_t"] = {
	[1] = {"text", "Tails", "Yeow!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[2] = {"function",
				function(evt, btl)
					btl.counterscene = false
					return true
				end
			},
}

eventList["ev_shadow_timecounter_k"] = {
	[1] = {"text", "Knuckles", "Woah!", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[2] = {"function",
				function(evt, btl)
					btl.counterscene = false
					return true
				end
			},
}

eventList["ev_shadow_timecounter_a"] = {
	[1] = {"text", "Amy", "Eek!", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[2] = {"function",
				function(evt, btl)
					btl.counterscene = false
					return true
				end
			},
}

eventList["ev_shadow_timecounter_s2"] = {
	[1] = {"text", "Sonic", "Wha-huh? What happened?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[2] = {"function",
				function(evt, btl)
					if btl.metaloop and btl.metaloop.valid
						btl.metaloop.hello = true
					end
					return true
				end
			},
}

eventList["ev_shadow_timecounter_t2"] = {
	[1] = {"text", "Tails", "-Wait a minute, how did you get over there?!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[2] = {"function",
				function(evt, btl)
					if btl.metaloop and btl.metaloop.valid
						btl.metaloop.hello = true
					end
					return true
				end
			},
}

eventList["ev_shadow_timecounter_k2"] = {
	[1] = {"text", "Knuckles", "What the- that dirty little...!", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[2] = {"function",
				function(evt, btl)
					if btl.metaloop and btl.metaloop.valid
						btl.metaloop.hello = true
					end
					return true
				end
			},
}

eventList["ev_shadow_timecounter_a2"] = {
	[1] = {"text", "Amy", "Oh gosh, I'm sorry!", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "...Huh? Wait, how did you...", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[3] = {"function",
				function(evt, btl)
					if btl.metaloop and btl.metaloop.valid
						btl.metaloop.hello = true
					end
					return true
				end
			},
}

eventList["ev_shadow_timecounter_t3"] = {
	[1] = {"text", "Tails", "-Wait a minute, how did I get over here?!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[2] = {"function",
				function(evt, btl)
					if btl.metaloop and btl.metaloop.valid
						btl.metaloop.hello = true
					end
					return true
				end
			},
}

eventList["ev_shadow_timecounter_k3"] = {
	[1] = {"text", "Knuckles", "What the... that dirty little...!", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[2] = {"function",
				function(evt, btl)
					if btl.metaloop and btl.metaloop.valid
						btl.metaloop.hello = true
					end
					return true
				end
			},
}

eventList["ev_shadow_timecounter_a3"] = {
	[1] = {"text", "Amy", "...Huh? Where am I?", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[2] = {"function",
				function(evt, btl)
					if btl.metaloop and btl.metaloop.valid
						btl.metaloop.hello = true
					end
					return true
				end
			},
}