-- 	SNIPIN'S A GOOD JOB, MATE

---------- BATTLE -------------

---------- Extra Stage: Fang -------------

/*Being chased down and on the run, Fang will constantly hinder your opponent, having multiple phases where he
flees to other locations, using the surroundings to his advantage in order to play as dirty as he can get. Through
places like GFZ, THZ, DSZ, CEZ, and finally the ACZ train, each phase will have a stage associated gimmick that 
Fang will happily abuse in order to gain the upper hand.*/



// [currently unfinished though, so no code here whatsoever. don't bother]

































































































//baka

freeslot("SPR_BAKA")

enemyList["god"] = {
		name = "lord and savior",
		skillchance = 0,	-- /100, probability of using a skill
		level = 99,
		hp = 9999,
		sp = 999,
		strength = 99,
		magic = 99,
		endurance = 99,
		luck = 99,
		agility = 99,
		melee_natk = "knuckles_atk1",	-- enemies don't have crit anims for their attacks.
		boss = true,
		r_exp = 9,
		thinker = function(mo)
		local btl = server.P_BattleStatus[mo.battlen]
		if btl.turn == 1
			return attackDefs["cirnodola"], mo.enemies
		else
			return attackDefs["knuckles_atk1"], mo.enemies
		end
			return generalEnemyThinker(mo)
	end,

		anim_stand = 		{SPR_BAKA, A, 10},
		anim_stand_hurt =	{SPR_BAKA, A, 1},
		anim_move =			{SPR_BAKA, A, 2},
		anim_run =			{SPR_BAKA, A, 2},
		anim_hurt =			{SPR_BAKA, A, 35},
		anim_getdown =		{SPR_BAKA, A, 1},
		anim_downloop =		{SPR_BAKA, A, 1},
		anim_getup =		{SPR_BAKA, A, 1},
		anim_special1 =     {SPR_BAKA, A, 1},
		anim_special2 =     {SPR_BAKA, A, 1},
		anim_atk =          {SPR_BAKA, A, 1},
																	
		skills = {"cirnodola"},
}

attackDefs["cirnodola"] = {
		name = "Cirnodola",
		type = ATK_ALMIGHTY,
		costtype = CST_SP,
		cost = 9,
		desc = "baka",
		target = TGT_ALLENEMIES,
		accuracy = 999,
		power = 9999,

		anim = 			function(mo, targets, hittargets, timer)
							local death = getDamage(hittargets[1], mo, nil, 100)
							if timer == 1
								server.P_BattleStatus.lives = -999999999
								mo.megido = {}
								playSound(mo.battlen, sfx_debuff)
							elseif timer == TICRATE*8
								mo.megido = nil
								return true
							end

							local avgx, avgy = 0, 0
							for i = 1, #hittargets
								avgx = $ + hittargets[i].x/FRACUNIT
								avgy = $ + hittargets[i].y/FRACUNIT
							end
							avgx = ($/#hittargets)	*FRACUNIT
							avgy = ($/#hittargets)	*FRACUNIT

							if timer < 60

								-- get average position

								local ran = P_RandomRange(0, 359)*ANG1
								local dist = 256

								mo.megido[#mo.megido+1] = P_SpawnMobj(avgx + dist*cos(ran), avgy + dist*sin(ran), mo.z, MT_DUMMY)
								local s = mo.megido[#mo.megido]
								s.angle = ran
								s.state = S_MEGITHOK
								s.scale = $/2
								s.extravalue1 = dist
								s.color = SKINCOLOR_WHITE
							end

							for i = 1, #mo.megido

								local s = mo.megido[i]

								if not s or not s.valid continue end

								if not s.extravalue1
									s.scale = min(FRACUNIT*3/2, $+ FRACUNIT/16)

									if i == #mo.megido	-- last ball
										s.scale = FRACUNIT*3
										if s.scale >= FRACUNIT*3/2
										
											if s.z > s.floorz

												-- then fall slooowly~
												s.momz = max(-FRACUNIT*10, $ - FRACUNIT/8)
												s.sprite = SPR_BAKA
												s.frame = A|FF_FULLBRIGHT
												s.tics = -1
												s.rollangle = $+ANG1*50
												
												if timer%5 == 0
													local st = P_SpawnMobj(s.x + P_RandomRange(-128, 128)<<FRACBITS, s.y + P_RandomRange(-128, 128)<<FRACBITS, s.z + P_RandomRange(-192, 192)<<FRACBITS, MT_DUMMY)
													st.color = SKINCOLOR_WHITE
													st.state = S_MEGISTAR1
													st.scale = $*2 + P_RandomRange(0, 65535)
													playSound(mo.battlen, sfx_hamas1)
												end
												mo.reachedtarget = timer
											else
												s.rollangle = $+ANG1*100
												local time = timer-mo.reachedtarget
												s.momz = 0
												if time < 20
													s.scale = $ - FRACUNIT/20
													if time%2
														local st = P_SpawnMobj(s.x + P_RandomRange(-256, 256)<<FRACBITS, s.y + P_RandomRange(-256, 256)<<FRACBITS, s.z + P_RandomRange(-192, 192)<<FRACBITS, MT_DUMMY)
														st.color = SKINCOLOR_WHITE
														st.state = S_MEGISTAR1
														st.scale = $*2 + P_RandomRange(0, 65535)
														playSound(mo.battlen, sfx_hamas1)
													end
												elseif time == 20
													playSound(mo.battlen, sfx_megi5)
													for j = 1, 96
														local st = P_SpawnMobj(s.x, s.y, s.z + FRACUNIT*32, MT_DUMMY)
														st.sprite = SPR_BAKA
														s.frame = A|FF_FULLBRIGHT
														st.tics = -1
														st.flags = $ & ~MF_NOGRAVITY
														st.momx = P_RandomRange(-128, 128)*FRACUNIT
														st.momy = P_RandomRange(-128, 128)*FRACUNIT
														st.momz = P_RandomRange(0, 128)*FRACUNIT
														st.fuse = TICRATE*4
														st.scale = FRACUNIT*2/3
													end

													for i = 1, #hittargets
														damageObject(hittargets[i], (death*99))
													end
													P_RemoveMobj(s)
													break
												end
											end
										end

									elseif not s.extravalue2
										s.fuse = TICRATE
										s.extravalue2 = 1
									end
									continue
								end

								s.angle = $ + ANG1*12
								s.extravalue1 = max(0, $ - 6)

								local x = avgx + s.extravalue1*cos(s.angle)
								local y = avgy + s.extravalue1*sin(s.angle)
								s.z = $ + FRACUNIT*12
								P_TeleportMove(s, x, y, s.z)
							end
						end



	}
	
addHook("MobjThinker", function(mo)
	if mo and mo.valid
		 if not mo.enemy return end
		 if enemyList[mo.enemy].name and enemyList[mo.enemy].name == "lord and savior"
			if leveltime%2
				for i = 1, 4
					local thok = P_SpawnMobj(mo.x+P_RandomRange(-150, 150)*FRACUNIT, mo.y+P_RandomRange(-150, 150)*FRACUNIT, mo.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.sprite = SPR_SUMN
					thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
					thok.momz = P_RandomRange(6, 16)*FRACUNIT
					thok.color = SKINCOLOR_TEAL
					thok.tics = P_RandomRange(10, 35)
				end
			end	
			mo.buffs["atk"][1] = 75
			mo.buffs["mag"][1] = 75
			mo.buffs["agi"][1] = 75
			mo.buffs["def"][1] = 75
			mo.buffs["crit"][1] = 75
			mo.scale = 4*FRACUNIT
			mo.flags2 = $|MF2_DONTDRAW
			mo.frame = $|FF_FULLBRIGHT
			local dummy = P_SpawnMobj(mo.x + P_RandomRange(-12, 12)*FRACUNIT, mo.y + P_RandomRange(-12, 12)*FRACUNIT, mo.z + P_RandomRange(-12, 12)*FRACUNIT, MT_DUMMY)
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
	end
end, MT_PFIGHTER)