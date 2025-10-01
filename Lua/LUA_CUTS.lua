
---------- EVENTS/CUTSCENES! -------------

//heavily inefficient!!!

local cutsceneskip = 0
local skipx = -200
local fadetimer = 0
local fade = V_ALLOWLOWERCASE --this one's just here for a placeholder until turned into a V_10TRANS flag and so forth

/*addHook("boxFlip", function() //nah ill just do it manually LOL
	if boxflip == true
		boxflip = false
	else
		boxflip = true
	end
end)*/

eventList["ev_stage1"] = {
	[1] = {"function", --camera rolls down and sonic comes from the left
				function(evt, btl)
					if evt.ftimer == 1
						--cutsceneskip = 30 --kill
						S_ChangeMusic("stg1a")
						boxflip = false
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
					end
					if evt.ftimer < 70 and evt.ftimer > 1
						local cam = btl.cam
						P_TeleportMove(cam, cam.x, cam.y, cam.z-1*FRACUNIT)
					end
					--here's where we spawn a decoy sonic just outside the camera's range and have him jump in
					if evt.ftimer == 75
						evt.sonic = P_SpawnMobj(-750*FRACUNIT, -200*FRACUNIT, 50*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * -10
						s.scale = FRACUNIT*2
						s.momz = 12*FRACUNIT
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
					end
					if evt.ftimer >= 75 and evt.ftimer < 80
						local s = evt.sonic
						local landpointx = -400*FRACUNIT
						s.momx = (landpointx - s.x)/17
					end
					if evt.sonic and evt.sonic.valid and P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.momx = $/2
						s.momy = $/2
						if s.momx > 0 or s.momy > 0
							s.state = S_PLAY_SKID
							s.frame = F
						elseif s.momx == 0 and s.momy == 0
							s.state = S_PLAY_STND
							s.noidle = true
						end
					elseif evt.sonic and evt.sonic.valid and not P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.state = S_PLAY_FALL
					end
					
					if evt.ftimer == 120 return true end
				end
			},
	[2] = {"text", "Sonic", "...What's with this mist?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[3] = {"text", "Amy", "I-It's not toxic to breathe, is it?", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[4] = {"text", "Tails", "Do you think we should stay inside for today until it goes away?", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[5] = {"text", "Knuckles", "...No, something tells me this won't be going away if we leave it alone.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[6] = {"text", "Sonic", "If that's the case, we're gonna need some answers about this.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[7] = {"function", --silver falls down and slowly descends once he gets near floor
				function(evt, btl)
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
					
					if evt.silver and evt.silver.valid and not evt.silver.falling then spawnaura(evt.silver) end
					
					if evt.ftimer == 1
						evt.silver = P_SpawnMobj(600*FRACUNIT, -200*FRACUNIT, 700*FRACUNIT, MT_PFIGHTER)
						local s = evt.silver
						s.skin = "silver"
						s.color = SKINCOLOR_AETHER
						s.state = S_PLAY_FLOAT_RUN
						s.angle = ANG1 * 180
						s.scale = FRACUNIT*2
						s.momz = -30*FRACUNIT
						s.flags = $ | MF_NOGRAVITY
						local landpointx = 300*FRACUNIT
						s.momx = (landpointx - s.x)/17
						s.cutscene = true
					end

					if evt.silver and evt.silver.valid and evt.silver.z < evt.silver.floorz + 200*FRACUNIT and not evt.silver.flyup
						local s = evt.silver
						if s.state != S_PLAY_FLOAT
							s.state = S_PLAY_FLOAT
							S_StartSound(nil, sfx_float)
						end
						s.momz = $*80/100
						s.momx = $*80/100
						if leveltime%4 == 0
							for i = 1,16
								local dust = P_SpawnMobj(s.x, s.y, s.floorz, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (22*(i-1))
								dust.state = S_CDUST1
								P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
								dust.color = SKINCOLOR_WHITE
								dust.scale = FRACUNIT*2
							end
						end
						P_StartQuake(1*FRACUNIT, 2)
					end
					if evt.silver and evt.silver.valid and evt.silver.momz > -1*FRACUNIT and evt.ftimer > 20
						local s = evt.silver
						s.flyup = true
					end
					if evt.silver and evt.silver.valid and evt.silver.flyup and evt.ftimer > 20
						local s = evt.silver
						local landpointx = 300*FRACUNIT
						s.momx = (landpointx - s.x)/20
						if leveltime%10 == 0
							for i = 1,16
								local dust = P_SpawnMobj(s.x, s.y, s.floorz, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (22*(i-1))
								dust.state = S_CDUST1
								P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
								dust.color = SKINCOLOR_WHITE
								dust.scale = FRACUNIT*2
							end
						end
						if s.z < 100*FRACUNIT
							s.momz = 5*FRACUNIT
						else 
							s.momz = $/2
						end
					end
					if evt.ftimer == 80 
						S_StartSound(nil, sfx_pcan)
						local s = evt.silver
						s.flags = $ & ~MF_NOGRAVITY
						s.state = S_PLAY_FALL
						s.falling = true
						return true 
					end
				end
			},
	[8] = {"function",
				function(evt, btl) --we're gonna be seeing this a lot...
					boxflip = true
					return true
				end
			},
	[9] = {"text", "Silver", "There you are!", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[10] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[11] = {"text", "Sonic", "Oh, Silver! How's it goin? And, uh, what's with that look?", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[12] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[13] = {"text", "Silver", "Don't play dumb with me! I know for a fact that I saw you earlier ambushing Shadow and stealing his Chaos Emerald!", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[14] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[15] = {"text", "Sonic", "Huh? Shadow? I haven't seen him at all.", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[16] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[17] = {"text", "Silver", "Rgh! You expect me to believe that!? I know for a fact that the person running around was definitely you!", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[18] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[19] = {"text", "Sonic", "Really? Maybe I was sleeprunnin' or something.", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[20] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[21] = {"text", "Silver", "Don't tell me THEY all believe you too! Haven't any of you seen him doing anything suspicious?!", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[22] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[23] = {"text", "Tails", "No... nothing that I know of...", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[24] = {"text", "Amy", "It can't be true! I've known him long enough to know he would never do this!", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[25] = {"text", "Knuckles", "...", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[26] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[27] = {"text", "Silver", "Enough of this! I'll force the answer out of you if I need to! You're gonna give me the location of where you put that emerald!", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[28] = {"function", --start battle
			function(evt, btl)
				cutscene = false
				local wave = {"b_silver"}
				local team_1 = server.plentities[1]
				local team_2 = {}
				for i = 1,#wave
					local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
					enm.state = S_PLAY_STND
					enm.tics = -1
					enm.enemy = wave[i]
					team_2[#team_2+1] = enm
				end
				//advantage: 1 = player, 2 = enemy, 0 = neutral(?)
				BTL_StartBattle(1, team_1, team_2, 2, nil, "stg1b")
			end
			},
}

eventList["silver_defeat"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[2] = {"text", "Silver", "Urk!", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[3] = {"text", "Silver", "Y-you...won't...", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[4] = {"text", "Silver", "Ngh...", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[5] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[6] = {"text", "Sonic", "Huff, I don't think he can fight anymore. Though we're not clearin' up this misunderstanding either!", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[7] = {"text", "Tails", "We should go and find Shadow! He might give us answers to who really attacked him!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[8] = {"text", "Sonic", "That's more my speed! Hate to ditch ya, but give us a bit, we'll clear this whole thing up!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[9] = {"text", "Knuckles", "We really should clear up this suspicious mist while we're at it...", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[10] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[11] = {"text", "Silver", ".........", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[12] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						stagecleared = true
					end
				end
			},
}

eventList["ev_stage2"] = {
	[1] = {"function", --blah blah blah camera rolls down and sonic comes in from left the usual
				function(evt, btl)
					if evt.ftimer == 1
						S_ChangeMusic("stg2a")
						boxflip = false
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
					end
					if evt.ftimer == 2
						for s in sectors.iterate do
							if s.tag == 5
								s.lightlevel = 152
							end
						end
					end
					if evt.ftimer < 70 and evt.ftimer > 1
						local cam = btl.cam
						P_TeleportMove(cam, cam.x, cam.y, cam.z-1*FRACUNIT)
					end
					--here's where we spawn a decoy sonic just outside the camera's range and have him jump in
					if evt.ftimer == 75
						evt.sonic = P_SpawnMobj(-6600*FRACUNIT, -600*FRACUNIT, 50*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * -40
						s.scale = FRACUNIT*3
						s.momz = 18*FRACUNIT
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
					end
					if evt.ftimer >= 75 and evt.ftimer < 80
						local s = evt.sonic
						local landpointx = -6090*FRACUNIT
						local landpointy = -700*FRACUNIT
						s.momx = (landpointx - s.x)/25
						s.momy = (landpointy - s.y)/25
					end
					if evt.sonic and evt.sonic.valid and P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.momx = $/2
						s.momy = $/2
						if s.momx > 0 or s.momy > 0
							s.state = S_PLAY_SKID
							s.frame = F
						elseif s.momx == 0 and s.momy == 0
							s.state = S_PLAY_STND
							s.noidle = true
						end
					elseif evt.sonic and evt.sonic.valid and not P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.state = S_PLAY_FALL
					end
					
					if evt.ftimer == 120 return true end
				end
			},
	[2] = {"text", "Amy", "Phew... you know, Silver was really aggressive this early in the day.", nil, nil, nil, {"H_AMY3", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "...Still, did you actually fight Shadow and take his Chaos Emerald?", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[4] = {"text", "Sonic", "No! He ticks me off sometimes, but I wouldn't go full on Nack the Weasel on him!", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[5] = {"text", "Sonic", "(...Or was his name Fang?)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[6] = {"text", "Knuckles", "Either way, all we have to do is find him so that we can clear these annoying misunderstandings and get answers at the same time.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[7] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[8] = {"text", "???", "There you are, dirty sneak.", nil, nil, nil, nil},
	[9] = {"function", --shadow warps in front of gang
				function(evt, btl)
					if evt.ftimer == 1
						evt.shadow = P_SpawnMobj(-5200*FRACUNIT, -1100*FRACUNIT, 150*FRACUNIT, MT_PFIGHTER)
						local s = evt.shadow
						s.skin = "shadow"
						s.color = SKINCOLOR_BLACK
						s.angle = ANG1 * 180
						s.scale = FRACUNIT*3
						s.momz = 30*FRACUNIT
						s.cutscene = true
						s.sh_snaptime = 6
						s.state = S_PLAY_FALL
						local e = P_SpawnMobj(s.x, s.y, s.z, MT_DUMMY)
						e.skin = s.skin
						e.sprite = s.sprite
						e.angle = s.angle
						e.frame = s.frame & FF_FRAMEMASK | FF_TRANS60
						e.fuse = TICRATE/7
						e.scale = s.scale
						e.destscale = s.scale*6
						e.scalespeed = s.scale/2
						e.sprite2 = s.sprite2
						e.color = SKINCOLOR_CYAN
						e.colorized = true
						e.tics = -1
						S_StartSound(nil, sfx_csnap)
						s.state = S_SHADOW_WARP1
					end
					if evt.shadow and evt.shadow.valid and (evt.shadow.sh_snaptime)
						local s = evt.shadow 
						s.sh_snaptime = $-1
						s.flags2 = $|MF2_DONTDRAW
					else
						local s = evt.shadow 
						s.flags, s.flags2 = $ & ~MF_NOGRAVITY, $ & ~MF2_DONTDRAW
						s.state = S_PLAY_FALL
					end
					if P_IsObjectOnGround(evt.shadow)
						evt.shadow.state = S_PLAY_STND
					end
					if evt.ftimer == 60
						evt.shadow.noidle = true
						return true
					end
				end
			},
	[10] = {"text", "Shadow", "You're quite the imbecile, thinking you can just mosey along with your friends as they remain oblivious to what you've done.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[11] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[12] = {"text", "Tails", "Shadow, we need to know what happened! We heard that you were ambushed and had your Chaos Emerald stolen!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[13] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[14] = {"text", "Shadow", "If you must know, that pathetic blue worm over there had the nerve to jump at me and cowardly fleed as he took my Chaos Emerald!", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[15] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[16] = {"text", "Knuckles", "So what Silver said wasn't wrong. A Sonic lookalike really did attack Shadow.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[17] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[18] = {"text", "Shadow", "You weaklings may be convinced by his disgusting sweet talk, but I saw it with my very eyes! And now you'll give me that damn emerald!", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[19] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[20] = {"text", "Tails", "He really thinks that it's absolutely Sonic!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[21] = {"text", "Amy", "I know he's wrong! I'll stick with you all the way, Sonic!", nil, nil, nil, {"H_AMY2", SKINCOLOR_ROSY}},
	[22] = {"text", "Sonic", "Hear that, Shadow? We don't have the Chaos Emerald, but you're not beating the four of us anytime soon!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[23] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[24] = {"text", "Shadow", "Don't make me laugh! I may not have the Chaos Emerald to boost me, but I still have access to my powers.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[25] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						S_StopMusic(nil)
						S_StartSound(nil, sfx_s3k9f)
						for p in players.iterate
							P_FlashPal(p, 1, 2)
						end
						//create invisible shadow clone
						evt.shadow = P_SpawnMobj(-5200*FRACUNIT, -1100*FRACUNIT, -32*FRACUNIT, MT_PFIGHTER)
						local s = evt.shadow
						s.flags2 = $|MF2_DONTDRAW
						s.skin = "shadow"
						s.color = SKINCOLOR_BLACK
						s.angle = ANG1 * 180
						s.scale = FRACUNIT*3
						s.cutscene = true
						s.powercolor = SKINCOLOR_RED
						s.power = true
						for i = 1,16
							local dust = P_SpawnMobj(s.x, s.y, s.z, MT_DUMMY)
							dust.angle = ANGLE_90 + ANG1* (22*(i-1))
							dust.state = S_CDUST1
							P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
							dust.color = SKINCOLOR_WHITE
							dust.scale = FRACUNIT*2
						end
					end
					if evt.ftimer == 40
						S_ChangeMusic("stg2b")
						return true
					end
				end
			},
	[26] = {"text", "Shadow", "It will be more than enough to finish off the likes of you!", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[27] = {"function", --start battle
			function(evt, btl)
				cutscene = false
				local wave = {"b_shadow"}
				local team_1 = server.plentities[1]
				local team_2 = {}
				for i = 1,#wave
					local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
					enm.state = S_PLAY_STND
					enm.tics = -1
					enm.enemy = wave[i]
					team_2[#team_2+1] = enm
				end
				BTL_StartBattle(1, team_1, team_2, 2, nil, "stg2b")
			end
			},
}

eventList["shadow_defeat"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[2] = {"text", "Shadow", "You...!!!", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[3] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[4] = {"text", "Sonic", "Whew! Told 'ya Shadow, four is better than one!", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[5] = {"text", "Knuckles", "You might listen now. Is Eggman up to this? Where did that fake Sonic go?", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[6] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[7] = {"text", "Shadow", "........", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[8] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[9] = {"text", "Amy", "No answer, I think he doesn't know. That's really just like him...", nil, nil, nil, {"H_AMY3", SKINCOLOR_ROSY}},
	[10] = {"text", "Sonic", "Honestly, I personally can't think of any other guy other than Eggman.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[11] = {"text", "Tails", "Yeah, even if he might not the one behind it, he's the kind of person to be at least somewhat related to incidents like these.", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[12] = {"text", "Sonic", "It's a good thing Shadow confirmed what we're lookin' for! Let's find faker number two!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[13] = {"text", "Sonic", "Hear that, Shadow? You've got competition!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[14] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[15] = {"text", "Shadow", "...Quit your incessant jabbering and just get out of my sight.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[16] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						stagecleared = true
					end
				end
			},
}

eventList["ev_stage3"] = {
	[1] = {"function", //same stuff
				function(evt, btl)
					if evt.ftimer == 1
						S_ChangeMusic("stg3a")
						boxflip = false
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
					end
					if evt.ftimer == 2
						for s in sectors.iterate do
							if s.tag == 1
								s.lightlevel = 175
							end
						end
					end
					if evt.ftimer < 70 and evt.ftimer > 1
						local cam = btl.cam
						P_TeleportMove(cam, cam.x, cam.y, cam.z-1*FRACUNIT)
					end
					--here's where we spawn a decoy sonic just outside the camera's range and have him jump in
					if evt.ftimer == 75
						evt.sonic = P_SpawnMobj(100*FRACUNIT, 400*FRACUNIT, 25*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * -100
						s.scale = FRACUNIT*3/2
						s.momz = 12*FRACUNIT
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
					end
					if evt.ftimer >= 75 and evt.ftimer < 80
						local s = evt.sonic
						local landpointy = 275*FRACUNIT
						s.momy = (landpointy - s.y)/17
					end
					if evt.sonic and evt.sonic.valid and P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.momx = $/2
						s.momy = $/2
						if s.momy != 0
							s.state = S_PLAY_SKID
							s.frame = F
						else
							s.state = S_PLAY_WAIT
							s.noidlebored = true
						end
					elseif evt.sonic and evt.sonic.valid and not P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.state = S_PLAY_FALL
					end
					
					if evt.ftimer == 120 return true end
				end
			},
	[2] = {"text", "Amy", "Ow, ow... still stings... how was he still so strong...?", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[3] = {"text", "Tails", "It's definitely weird, for sure. Both Shadow and Silver were pretty powerful.", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[4] = {"text", "Sonic", "Good thing is, we're getting answers soon. Up ahead is the train leading to the base of our good ol McNosehair.", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[5] = {"function", --sonic walks in, but knuckles senses something and stops them
				function(evt, btl)
					if evt.sonic and evt.sonic.valid
						local s = evt.sonic
						if evt.ftimer == 1
							s.noidlebored = false
							s.state = S_PLAY_WALK
						end
						if evt.ftimer == 5
							evt.knuckles = P_SpawnMobj(175*FRACUNIT, 450*FRACUNIT, 18*FRACUNIT, MT_PFIGHTER)
							local k = evt.knuckles
							k.skin = "knuckles"
							k.color = SKINCOLOR_RED
							k.angle = ANG1 * -80
							k.scale = FRACUNIT*3/2
							k.landpointy = -300*FRACUNIT
							k.momy = (k.landpointy - k.y)/11
							k.state = S_PLAY_RUN
							k.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						end
						if evt.ftimer < 30
							if s.momy < 4*FRACUNIT
								s.momy = $ - 1*FRACUNIT
							end
						elseif evt.ftimer == 30
							s.momy = 0
							s.state = S_PLAY_STND
							s.noidle = true
						end
						if evt.knuckles and evt.knuckles.valid
							local k = evt.knuckles
							if evt.ftimer >= 19
								if evt.ftimer == 19 S_StartSound(nil, sfx_skid) end
								k.state = S_PLAY_SKID
								k.frame = A
								k.momy = $*70/100
								if evt.ftimer < 25
									P_SpawnMobj(k.x, k.y, k.floorz, MT_SPINDUST)
								end
							end
							if evt.ftimer == 35
								k.state = S_PLAY_STND
								k.noidle = true
								return true
							end
						end
					end
				end
			},
	[6] = {"text", "Knuckles", "...Wait, watch out!", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[7] = {"function", //blaze fire dives down near the gang as they evade
				function(evt, btl)
					if evt.ftimer == 1
						evt.firestuff = {}
						evt.firestuff2 = {} --bruh
					end
					if evt.knuckles and evt.knuckles.valid
						local k = evt.knuckles
						if evt.ftimer == 1
							k.noidle = false
							k.angle = ANG1 * -260
							k.state = S_PLAY_RUN
							k.landpointy = 700*FRACUNIT
							k.momy = (k.landpointy - k.y)/11
						end
					end
					if evt.sonic and evt.sonic.valid
						local s = evt.sonic
						if evt.ftimer == 5
							for i=1,16
								local b = P_SpawnMobj(s.x, s.y, s.z+20*FRACUNIT, MT_DUMMY)
								b.momx = P_RandomRange(-4, 4)*FRACUNIT
								b.momy = P_RandomRange(-4, 4)*FRACUNIT
								b.momz = P_RandomRange(-4, 4)*FRACUNIT
								b.state = S_AOADUST1
								b.frame = A|FF_FULLBRIGHT
								b.scale = FRACUNIT*2
								b.destscale = FRACUNIT/12
							end
							s.noidle = false
							S_StartSound(nil, sfx_s3k4a)
							s.state = S_PLAY_PAIN
							s.landpointy = 700*FRACUNIT
							s.momy = (s.landpointy - s.y)/11
						end
					end
					if evt.ftimer >= 2 and evt.ftimer < 14--or evt.ftimer == 8 or evt.ftimer == 14
						local x = 100*FRACUNIT + P_RandomRange(-96, 96)<<FRACBITS
						local y = -1050*FRACUNIT + P_RandomRange(-96, 96)<<FRACBITS
						
						evt.fire = P_SpawnMobj(x, y, 1100*FRACUNIT, MT_DUMMY)
						local f = evt.fire
						f.sprite = SPR_PUMA
						f.frame = A|FF_FULLBRIGHT
						f.tics = 35
						f.scale = FRACUNIT*3/2
						f.momx = ((0 - f.x)/10) + P_RandomRange(50, -50)*FRACUNIT
						f.momy = (-250*FRACUNIT - f.y)/10 + P_RandomRange(20, 50)*FRACUNIT
						f.momz = -P_RandomRange(120, 150)*FRACUNIT
						evt.firestuff[#evt.firestuff+1] = f
					end
					if evt.firestuff and #evt.firestuff
						for i = 1, #evt.firestuff
							local f = evt.firestuff[i] 
							if f and f.valid
								P_SpawnGhostMobj(f)
								if f.z <= f.floorz
									local boom = P_SpawnMobj(f.x, f.y, f.floorz+10*FRACUNIT, MT_BOSSEXPLODE)
									boom.scale = FRACUNIT*2
									boom.state = S_PFIRE1
									S_StartSound(nil, sfx_fire1)
									S_StartSound(nil, sfx_fire2)
									P_StartQuake(FRACUNIT*8, 3)
									
									//small flame
									for i = 1, 3
										local smol = P_SpawnMobj(f.x, f.y, f.floorz+10*FRACUNIT, MT_DUMMY)
										smol.state = S_CYBRAKDEMONNAPALMFLAME_FLY1
										smol.scale = FRACUNIT*3/2
										smol.momx = f.momx/30 + P_RandomRange(-20, 20)*FRACUNIT
										smol.momy = f.momy/30 + P_RandomRange(-20, 20)*FRACUNIT
										smol.momz = P_RandomRange(10, 15)*FRACUNIT
										evt.firestuff2[#evt.firestuff2+1] = smol
									end
									P_RemoveMobj(f)
								end
							end
						end
					end
					if evt.firestuff2 and #evt.firestuff2
						for i = 1, #evt.firestuff2
							local smol = evt.firestuff2[i] 
							if smol and smol.valid
								smol.momz = $-1*FRACUNIT
							end
						end
					end
					if evt.ftimer == 30
						evt.blaze = P_SpawnMobj(100*FRACUNIT, -1050*FRACUNIT, 900*FRACUNIT, MT_PFIGHTER)
						local b = evt.blaze
						b.skin = "blaze"
						b.landed = false
						b.color = SKINCOLOR_PASTEL
						b.angle = ANG1 * -260
						b.scale = FRACUNIT*3/2
						b.momz = -80*FRACUNIT
						b.state = S_PLAY_BLAZE_HOVER
						b.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						b.momy = (-400*FRACUNIT - b.y)/12
					end
					if evt.blaze and evt.blaze.valid
						local b = evt.blaze
						if evt.ftimer == 38
							S_StartSound(nil, sfx_blzhvr)
							b.momy = $/5
							b.momz = -1*FRACUNIT
							b.state = S_PLAY_FALL
							local g = P_SpawnGhostMobj(b)
							g.colorized = true
							g.destscale = FRACUNIT*4
						end
						//would get the old blaze's hover code but me no hav old version of srb2p :(
						if evt.ftimer >= 38 and not P_IsObjectOnGround(b)
							local x = b.x + P_RandomRange(-20, 20)*FRACUNIT
							local y = b.y + P_RandomRange(-20, 20)*FRACUNIT
							local z = b.z + P_RandomRange(-15, -20)*FRACUNIT
							local hover = P_SpawnMobj(x, y, z, MT_DUMMY)
							hover.sprite = SPR_FPRT
							hover.tics = 35
							hover.frame = A|FF_FULLBRIGHT
							hover.scale = FRACUNIT*2
							hover.destscale = FRACUNIT/6
							hover.momz = -8*FRACUNIT
						end
						if P_IsObjectOnGround(b)
							S_StopSoundByID(nil, sfx_blzhvr)
							if b.momy != 0
								b.state = S_PLAY_SKID
								b.frame = A
								b.momy = $*80/100
							else
								b.state = S_PLAY_STND
								b.noidle = true
							end
						end
					end
					if evt.ftimer == 80
						boxflip = true
						return true
					end
				end
			},
	[8] = {"text", "Blaze", "Ah! Knuckles, Tails, Amy, I apologize!", nil, nil, nil, {"H_BLAZE2", SKINCOLOR_PASTEL}},
	[9] = {"text", "Blaze", "...Or must I assume you are with him?", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[10] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						evt.sonic = P_SpawnMobj(100*FRACUNIT, 400*FRACUNIT, 25*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * -100
						s.scale = FRACUNIT*3/2
						s.state = S_PLAY_JUMP
						s.momz = 12*FRACUNIT
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						local landpointy = 275*FRACUNIT
						s.momy = (landpointy - s.y)/17
						s.noidle = true
					end
					if evt.ftimer == 2
						boxflip = false
						return true
					end
				end
			},
	[11] = {"text", "Sonic", "Geez, I'm pretty popular, aren't I?", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[12] = {"text", "Sonic", "So, same story? Saw me attacking Shadow? 'Cause if so, I hate to break it to ya, but your material's been stolen.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[13] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[14] = {"text", "Blaze", "I had not yet heard of this. I was simply attacked by you yesterday right after I had uncovered a strange ruby.", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[15] = {"text", "Blaze", "From inspection, I sensed the ruby was most dangerous, but before I knew it, it had been snatched by you without any explanation.", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[16] = {"text", "Blaze", "Your acquiantances must either be oblivious, or in on the act as well. In the case of the former, however...", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[17] = {"text", "Blaze", "...I ask of you three, will any of you join me?", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[18] = {"text", "Blaze", "The things that Sonic has been doing behind your back will certainly lead to grim destruction.", nil, nil, nil, {"H_BLAZE2", SKINCOLOR_PASTEL}},
	[19] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[20] = {"text", "Amy", "Sorry Blaze, but no way! I'll fight with Sonic no matter what! Sonic's the best in the world!", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[21] = {"text", "Tails", "Yeah! Sonic would never lie! You'll just have to defeat us instead of trying to convince us!", nil, nil, nil, {"H_TAILS2", SKINCOLOR_ORANGE}},
	[22] = {"text", "Knuckles", "...", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[23] = {"text", "Sonic", "Hey.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[24] = {"text", "Knuckles", "Yeah, yeah, I'll think about punching your lights out when we get solid proof from Eggman.", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[25] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[26] = {"text", "Blaze", "As pleasing as it would be to believe you, I have seen Sonic attack me with my own two eyes.", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[27] = {"text", "Blaze", "You may not believe me either, but no imposter could have mimicked that authentic form back then. It truly was Sonic!", nil, nil, nil, {"H_BLAZE2", SKINCOLOR_PASTEL}},
	[28] = {"text", "Blaze", "If I do not stop you, who will know how he will betray you all once he gets to Eggman with that ruby. It will be too late then!", nil, nil, nil, {"H_BLAZE2", SKINCOLOR_PASTEL}},
	[29] = {"function",
				function(evt, btl)
					S_FadeOutStopMusic(1*MUSICRATE)
					return true
				end
			},
	[30] = {"text", "Blaze", "...To think I am guarding Eggman's base to prevent Sonic from reaching it.", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[31] = {"function",
				function(evt, btl)
					S_StartSound(nil, sfx_buff2)
					P_StartQuake(5*FRACUNIT, 5)
					if evt.blaze and evt.blaze.valid
						local b = evt.blaze
						for i = 1,16
							local dust = P_SpawnMobj(b.x, b.y, b.floorz, MT_DUMMY)
							dust.angle = ANGLE_90 + ANG1* (22*(i-1))
							dust.state = S_CDUST1
							P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
							dust.color = SKINCOLOR_WHITE
							dust.scale = FRACUNIT*2
						end
						b.powercolor = SKINCOLOR_ORANGE
						b.power = true
					end
					S_ChangeMusic("stg3b")
					return true
				end
			},
	[32] = {"text", "Blaze", "But I am willing to take as extreme measures as I possibly can to prevent that ruby from causing harm to many others!", nil, nil, nil, {"H_BLAZE2", SKINCOLOR_PASTEL}},
	[33] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[34] = {"text", "Tails", "There's only one way to pass! We have to get through her!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[35] = {"text", "Sonic", "Hate to give you the bad news, but you won't stop us, Blaze! We're gonna get on that train one way or another!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[36] = {"function", --start battle
			function(evt, btl)
				cutscene = false
				local wave = {"b_blaze"}
				local team_1 = server.plentities[1]
				local team_2 = {}
				for i = 1,#wave
					local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
					enm.state = S_PLAY_STND
					enm.tics = -1
					enm.enemy = wave[i]
					team_2[#team_2+1] = enm
				end
				BTL_StartBattle(1, team_1, team_2, 2, nil, "stg3b")
				for s in sectors.iterate do
					if s.tag == 1
						s.lightlevel = 200
					end
				end
			end
			},
}

eventList["blaze_defeat"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[2] = {"text", "Blaze", "N-no...!", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[3] = {"text", "Blaze", "I...cannot! It is too dangerous...!", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[4] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[5] = {"text", "Tails", "...It really doesn't feel like we're the good guys here, huh?", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[6] = {"text", "Sonic", "That faker must've had one heck of a convincing act if everyone's so serious about this.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[7] = {"text", "Tails", "Then we should get to Eggman's base before it gets any worse!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[8] = {"function",
				function(evt, btl)
					if evt.ftimer == 25
						boxflip = true
						return true
					end
				end
			},
	[9] = {"text", "Blaze", "...I warn you now, all of you...", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[10] = {"text", "Blaze", "In the event that... you reach Eggman with Sonic by your side...", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[11] = {"text", "Blaze", "He... will strike you... at your weakest point...!", nil, nil, nil, {"H_BLAZE1", SKINCOLOR_PASTEL}},
	[12] = {"function",
				function(evt, btl)
					if evt.ftimer == 20
						boxflip = false
						return true
					end
				end
			},
	[13] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[14] = {"text", "Knuckles", "...Enough. Let's go.", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[15] = {"text", "Amy", "...Right...", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[16] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						stagecleared = true
					end
				end
			},
}

local sectorfloor = {}
local sectorceiling = {}
local sectorstuff = {}
eventList["ev_stage4"] = {
	[1] = {"function", --same stuff
				function(evt, btl)
					if evt.ftimer == 1
						S_ChangeMusic("stg4a")
						boxflip = false
						cutscene = true
						evt.usecam = true
						sectorfloor = {}
						sectorceiling = {}
						sectorstuff = {}
						for s in sectors.iterate
							sectorstuff[#sectorstuff+1] = s
							sectorfloor[#sectorfloor+1] = s.floorheight
							sectorceiling[#sectorceiling+1] = s.ceilingheight
						end
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
					end
					if evt.ftimer < 70 and evt.ftimer > 1
						local cam = btl.cam
						P_TeleportMove(cam, cam.x, cam.y, cam.z-1*FRACUNIT)
					end
					--here's where we spawn a decoy sonic just outside the camera's range and have him jump in
					if evt.ftimer == 75
						evt.sonic = P_SpawnMobj(-8750*FRACUNIT, 8300*FRACUNIT, btl.cam.floorz + 25*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * -60
						s.scale = FRACUNIT*3/2
						s.momz = 14*FRACUNIT
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
					end
					if evt.ftimer >= 75 and evt.ftimer < 80
						local s = evt.sonic
						local landpointx = -8500*FRACUNIT
						local landpointy = 7900*FRACUNIT
						s.momx = (landpointx - s.x)/40
						s.momy = (landpointy - s.y)/40
					end
					if evt.sonic and evt.sonic.valid and P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.momx = $/2
						s.momy = $/2
						if s.momy != 0
							s.state = S_PLAY_SKID
							s.frame = F
						else
							s.state = S_PLAY_WAIT
							s.noidlebored = true
						end
					elseif evt.sonic and evt.sonic.valid and not P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.state = S_PLAY_FALL
					end
					
					if evt.ftimer == 140 
						P_LinedefExecute(1001)
						S_StartSound(nil, sfx_buzz3)
						S_StartSound(nil, sfx_s3k41)
					end
					
					if evt.ftimer == 180
						S_StartSound(nil, sfx_s256)
						P_LinedefExecute(1002)
					end
					
					if evt.ftimer == 200 return true end
				end
			},
	[2] = {"text", "Amy", "Here we are...", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "The place where we'll get all our answers...", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[4] = {"text", "Sonic", "Guess this elevator'll bring us down in a hot minute. Hang tight.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[5] = {"function", --elevator starts and everyone waits (awkward silence ecks dee)
				function(evt, btl)
					if evt.ftimer == 50 return true end
				end
			},
	[6] = {"text", "Amy", "...", nil, nil, nil, {"H_AMY3", SKINCOLOR_ROSY}},
	[7] = {"text", "Tails", "...", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[8] = {"text", "Knuckles", "...", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[9] = {"text", "Sonic", "Yeesh, I wish we could just hurry up and find proof that I'm not doing this...", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[10] = {"text", "Amy", "...I guess we've all taken what Blaze said pretty seriously, huh?", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[11] = {"text", "Tails", "A dangerously unstable ruby, she said...", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[12] = {"text", "Knuckles", "Tch, she was pretty confident that the form she fought was completely like Sonic here.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[13] = {"text", "Knuckles", "I may be easy to trick, but Blaze isn't a fool. Neither were Shadow or Silver.", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[14] = {"text", "Amy", "H-Hey, it couldn't have been him...", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[15] = {"text", "Knuckles", "That uncertainty is enough to cost us our life if all the imposter needs to do is reach Eggman and give him the power he needs.", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[16] = {"text", "Amy", "...", nil, nil, nil, {"H_AMY3", SKINCOLOR_ROSY}},
	[17] = {"function", --the elevator stops at multiple 'entrances'
				function(evt, btl)
					if evt.ftimer == 1
						evt.stopped = 0
						P_LinedefExecute(1003)
						P_LinedefExecute(1009)
						S_FadeOutStopMusic(3*MUSICRATE)
						for s in sectors.iterate do
							if s.tag == 1 or s.tag == 7 or s.tag == 9
								s.floorheight = $ + 512*FRACUNIT
								s.ceilingheight = $ + 512*FRACUNIT
							end
						end
					end
					for s in sectors.iterate do
						if s.tag == 1 and s.ceilingheight >= -1563*FRACUNIT and evt.stopped == 0
							S_StartSound(nil, sfx_doorc2)
							P_LinedefExecute(1004)
							P_StartQuake(5*FRACUNIT, 2)
							evt.stopped = 1
						end
					end
					if evt.stopped > 0
						evt.stopped = $+1
						if evt.stopped == 50
							return true
						end
					end
				end
			},
	[18] = {"text", "Sonic", "...?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[19] = {"text", "Tails", "This layout... doesn't look right...", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[20] = {"text", "Knuckles", "I'm sure that only means one thing.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[21] = {"function", --badniks show up 
				function(evt, btl)
					local thecolors = {SKINCOLOR_EMERALD, SKINCOLOR_MAGENTA, SKINCOLOR_BLUE, SKINCOLOR_CYAN, SKINCOLOR_YELLOW, SKINCOLOR_RED, SKINCOLOR_SILVER}
					if evt.ftimer == 1
						S_StartSound(nil, sfx_doorb1)
						S_StartSound(nil, sfx_alarm)
						P_LinedefExecute(1005)
						for m in mobjs.iterate() do
							if m and m.valid and (m.type == MT_CRAWLACOMMANDER or m.type == MT_ROBOHOOD)
								m.emeraldcolor = thecolors[P_RandomRange(1, 7)]
								m.emeraldpowered = true
							end
						end
					end
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 2

							local cam = btl.cam
							cam.angle = m.angle
							cam.aiming = -ANG1*2
							CAM_goto(cam, m.x, m.y, m.z)
							CAM_angle(cam, m.angle)
							CAM_aiming(cam, cam.aiming)
							break
						end
					end
					if evt.ftimer == 40
						S_ChangeMusic("stg4b")
						return true
					end
				end
			},
	[22] = {"text", "Knuckles", "A trap! Eggman really loves tricking us, huh?!", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[23] = {"text", "Tails", "Hey... don't they look a little different? These colors aren't naturally what we've seen on badniks before.", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[24] = {"text", "Sonic", "Who cares! This is a relaxing change of pace after having to fight our friends! I'm ready anytime!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[25] = {"function", --start battle
			function(evt, btl)
				cutscene = false
				local wave = {"jetty gunner", "jetty bomber", "robo hood", "facestabber"}
				
				local team_1 = server.plentities[1]
				local team_2 = {}
				for i = 1,#wave
					local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
					enm.state = S_PLAY_STND
					enm.tics = -1
					enm.enemy = wave[i]
					enm.emeraldmode = P_RandomRange(1, 6)
					team_2[#team_2+1] = enm
				end
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
				btl.weaknesses = $ or {}
				btl.resistances = $ or {}
				for i = 1, #enemies
					btl.weaknesses[i] = atk_constants[P_RandomRange(1, #atk_constants)]
					btl.resistances[i] = atk_constants[P_RandomRange(1, #atk_constants)]
				end
				BTL_StartBattle(1, team_1, team_2, 2, nil, "stg4c")
			end
			},
}

eventList["ev_stage4_midway"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"text", "Amy", "Geez! There's no end to these guys!", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[2] = {"text", "Knuckles", "This darn elevator isn't budging either! I'm angry on how effective Eggman's trap was!", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[3] = {"text", "Tails", "There has to be a way to progress, but...", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[4] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[5] = {"text", "Sonic", "Yo, Tails, you look like you got an idea.", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[6] = {"text", "Tails", "W-Well, yeah... I've been thinking about it for a while, fly back up to the top to hack the panels, but...", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[7] = {"text", "Tails", "It's a long flight up, so I won't be able to carry anyone. And I can't just leave you here!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[8] = {"text", "Tails", "Alongside that, I don't even know if I'll be able to do it. What if I can't get it working in time?", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[9] = {"text", "Sonic", "Are you kiddin' me? You're the genius Miles 'Tails' Prower! You might not know if you can do it, but I do!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[10] = {"text", "Sonic", "We'll be totally fine here, so you go up there and do your thing! Trust me on this, because I trust you!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[11] = {"text", "Tails", "...", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[12] = {"text", "Tails", "Alright, you got it!", nil, nil, nil, {"H_TAILS2", SKINCOLOR_ORANGE}},
	[13] = {"function", //then he flies (unless he's dead in the battle)
				function(evt, btl)
					for m in mobjs.iterate() do
						if m and m.valid and m.type == MT_PFIGHTER
							if evt.ftimer == 1
								//stealthy stat increase, having perma 3 members is a pain after all
								if m.plyr
								and m.control
									local stats = {"strength", "magic", "endurance", "agility", "luck"}
									if not m.enemy
										for i = 1, #stats do
											m[stats[i]] = $+15
										end
									end
								end
								btl.turnorder[1].onemore = nil
								saveplentities = copyTable(server.plentities[1])
							end
							if m.skin == "tails"
								evt.tails = m
							end
						end
					end
					if evt.tails and evt.tails.valid
						if evt.tails.hp > 0
							local t = evt.tails
							local cam = btl.cam
							local x = t.x - 200*cos(t.angle)
							local y = t.y - 200*sin(t.angle)
							if evt.ftimer < 32
								CAM_goto(cam, x, y, t.z)
							else
								CAM_goto(cam, x, y, cam.z)
							end
							CAM_angle(cam, R_PointToAngle2(x, y, t.x, t.y))
							if evt.ftimer == 32
								S_StartSound(nil, sfx_jump)
								t.flags = $|MF_NOGRAVITY
								ANIM_set(t, t.anim_atk, true)
								t.momz = 8*FRACUNIT
							end
							if evt.ftimer == 42
								S_StartSound(nil, sfx_putput)
								ANIM_set(t, t.anim_special1, true)
							end
							if #t.allies > 1
								if evt.ftimer == 90
									D_startEvent(1, "ev_stage4_midway_nice")
									return true
								end
							else
								if evt.ftimer == 90
									D_startEvent(1, "ev_stage4_midway_revive")
									return true
								end
							end
						else
							if evt.ftimer == 50
								D_startEvent(1, "ev_stage4_midway_tailsdead")
								return true
							end
						end
					else
						if evt.ftimer == 50
							D_startEvent(1, "ev_stage4_midway_tailsdead")
							return true
						end
					end
				end
			},
}

local function killTails(t, f)		-- updateUDtable but cant have it going around cleaning dead people too 

	for i = 1, #t	-- we really need to cleanse

		for k,v in ipairs(t)
			if v.valid and v.skin == "tails" and v.byebye
				table.remove(t, k)
			end
		end
	end
end

eventList["ev_stage4_midway_nice"] = {
	[2] = {"text", "Amy", "...Guess we'd never get THAT kind of a pep talk from a faker!", nil, nil, nil, {"H_AMY2", SKINCOLOR_ROSY}},
	[3] = {"text", "Knuckles", "...Hmph.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[4] = {"function", //remove tails from team
				function(evt, btl)
					for m in mobjs.iterate() do
						if m and m.valid and m.type == MT_PFIGHTER
							if m.skin == "tails"
								evt.tails = m
							end
						end
					end
					if evt.tails and evt.tails.valid
						for k,v in ipairs(server.plentities[1])
							evt.tails.teampos = k
							--if evt.tails.teampos < 5 //dont kill extra tailses
								if v == evt.tails
									table.remove(server.plentities[1], k)
								end
							--end
						end
						for k,v in ipairs(btl.turnorder)
							if v and v.valid and v == evt.tails
								v.flags2 = $|MF2_DONTDRAW
								table.remove(btl.turnorder, k)
							end
						end
						for k,v in ipairs(evt.tails.enemies)
							for j,e in ipairs(v.enemies)
								if v and v.valid and v == evt.tails
									table.remove(v.enemies, k)
								end
							end
						end
						for k,v in ipairs(evt.tails.allies)
							for j,e in ipairs(v.allies)
								if v and v.valid and v == evt.tails
									table.remove(v.allies, k)
								end
							end
						end
						updateUDtable(btl.fighters)
						updateUDtable(btl.turnorder)
						evt.tails.byebye = true
						for k,v in ipairs(btl.fighters)
							if not v.valid continue end	-- wat
							killTails(v.enemies)
							killTails(v.allies)
							killTails(v.allies_noupdate)
							killTails(v.enemies_noupdate)	-- update for .valid still
						end
						return true
					end
				end
			},
}

eventList["ev_stage4_midway_tailsdead"] = {
	[2] = {"text", "Knuckles", "...Wait. Who are we talking to? Didn't Tails get knocked out?", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[3] = {"text", "Amy", "Hey, shh! Let him believe! He's probably somewhere up there!", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[4] = {"function", //remove tails from team
				function(evt, btl)
					for m in mobjs.iterate() do
						if m and m.valid and m.type == MT_PFIGHTER
							if m.skin == "tails"
								evt.tails = m
							end
						end
					end
					if evt.tails and evt.tails.valid
						for k,v in ipairs(server.plentities[1])
							evt.tails.teampos = k
							if v == evt.tails
								table.remove(server.plentities[1], k)
							end
						end
						for k,v in ipairs(btl.turnorder)
							if v and v.valid and v == evt.tails
								v.flags2 = $|MF2_DONTDRAW
								table.remove(btl.turnorder, k)
							end
						end
						for k,v in ipairs(evt.tails.enemies)
							for j,e in ipairs(v.enemies)
								if v and v.valid and v == evt.tails
									table.remove(v.enemies, k)
								end
							end
						end
						for k,v in ipairs(evt.tails.allies)
							for j,e in ipairs(v.allies)
								if v and v.valid and v == evt.tails
									table.remove(v.allies, k)
								end
							end
						end
						updateUDtable(btl.fighters)
						updateUDtable(btl.turnorder)
						for k,v in ipairs(btl.fighters)
							if not v.valid continue end	-- wat
							killTails(v.enemies)
							killTails(v.allies)
							killTails(v.allies_noupdate)
							killTails(v.enemies_noupdate)	-- update for .valid still
						end
						evt.tails.byebye = true
					end
					return true
				end
			},
}

eventList["ev_stage4_midway_revive"] = {
	[2] = {"text", "Sonic", "That said... we're not really in the best of shape right now.", nil, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},
	[3] = {"text", "Sonic", "But we can't afford to call it quits here!", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},
	[4] = {"text", "Amy", "Let's hold them off a little longer! We can do this!", nil, nil, nil, {"H_AMY2", SKINCOLOR_ROSY}},
	[5] = {"text", "Knuckles", "Fine!", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[6] = {"function", //remove tails from team and revive guys
				function(evt, btl)
					for m in mobjs.iterate() do
						if m and m.valid and m.type == MT_PFIGHTER
							if m.skin == "tails"
								evt.tails = m
							end
							if m == evt.tails
								for i = 1, #evt.tails.allies_noupdate
									local target = evt.tails.allies_noupdate[i]
									if target and target.valid and not target.cutscene
										if evt.ftimer == 1
											revivePlayer(target)
											target.hp = 1
											target.fieldstate = nil
											/*for k,v in ipairs(btl.turnorder)
												if v == target
													table.remove(btl.turnorder, k)
												end
											end*/
										end
										if evt.ftimer == 2
											
											-- explode the box and revive us!

											for i=1,16
												local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
												b.momx = P_RandomRange(-8, 8)*FRACUNIT
												b.momy = P_RandomRange(-8, 8)*FRACUNIT
												b.momz = P_RandomRange(-8, 8)*FRACUNIT
												b.state = S_AOADUST1
												b.frame = A|FF_FULLBRIGHT
												b.scale = FRACUNIT*3
												b.destscale = FRACUNIT/12
											end
											local heals = target.maxhp/2
											damageObject(target, -heals)
											

											ANIM_set(target, target.anim_revive, true)
											target.momz = 10*FRACUNIT
										elseif evt.ftimer > 1 and P_IsObjectOnGround(target)
											ANIM_set(target, target.anim_stand, true)
										end
									end
								end
							end
						end
					end
					if evt.ftimer == 2
						S_StartSound(nil, sfx_pop)
						S_StartSound(nil, sfx_heal2)
					end
					if evt.ftimer == 50
						--btl.turnorder = {}
						if evt.tails and evt.tails.valid
							evt.tails.fieldstate = nil
							for k,v in ipairs(server.plentities[1])
								evt.tails.teampos = k
								--if evt.tails.teampos < 5 //dont kill extra tailses
									if v == evt.tails
										table.remove(server.plentities[1], k)
									end
								--end
							end
							for k,v in ipairs(btl.turnorder)
								if v and v.valid and v == evt.tails
									v.flags2 = $|MF2_DONTDRAW
									table.remove(btl.turnorder, k)
								end
							end
							for k,v in ipairs(evt.tails.enemies)
								for j,e in ipairs(v.enemies)
									if v and v.valid and v == evt.tails
										table.remove(v.enemies, k)
									end
								end
							end
							for k,v in ipairs(evt.tails.allies)
								for j,e in ipairs(v.allies)
									if v and v.valid and v == evt.tails
										table.remove(v.allies, k)
									end
								end
							end
							updateUDtable(btl.fighters)
							updateUDtable(btl.turnorder)
							evt.tails.byebye = true
							for k,v in ipairs(btl.fighters)
								if not v.valid continue end	-- wat
								killTails(v.enemies)
								killTails(v.allies)
								killTails(v.allies_noupdate)
								killTails(v.enemies_noupdate)	-- update for .valid still
							end
							return true
						end
					end
				end
			},
}

eventList["ev_stage4_elevatorstart"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"function", //elevator starts back up
				function(evt, btl)
					if evt.ftimer == 1
						S_StartSound(nil, sfx_buzz3)
						S_StartSound(nil, sfx_s256)
						P_LinedefExecute(1007)
						P_LinedefExecute(1003)
						P_StartQuake(10*FRACUNIT, 5)
					end
					if evt.ftimer == 40
						return true
					end
				end
			},
	[2] = {"text", "Sonic", "Oh, sweet! He got it working!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[3] = {"text", "Amy", "Thank goodness! I thought we'd be stuck here forever!", nil, nil, nil, {"H_AMY2", SKINCOLOR_ROSY}},
	[4] = {"text", "Knuckles", "Hey, stay focused! We're still gonna have full badnik company for a while! Keep fighting!", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	
}

eventList["ev_stage4_final"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"function", //phone call
				function(evt, btl)
					if evt.ftimer == 1
						S_StartSound(nil, sfx_call)
					end
					if evt.ftimer == 40
						boxflip = true
						return true
					end
				end
			},
	[2] = {"text", "Tails", "Hello? Can you guys hear me?", nil, nil, nil, nil},
	[3] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[4] = {"text", "Sonic", "Woah, I had faith in him, but how'd he manage to do this in the span of a few battles?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[5] = {"text", "Knuckles", "The elevator was started a while ago, though. Hey, what's taking you so long to get down here and help?", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[6] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[7] = {"text", "Tails", "Sorry, I just finished hacking all of the badnik entrances, you shouldn't be facing any more after this one.", nil, nil, nil, nil},
	[8] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[9] = {"text", "Knuckles", "...Talk about timing. These guys look like they're tougher than usual.", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[10] = {"text", "Sonic", "Hoho, guess these guys really are rougher than the rest of 'em, eh?", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[11] = {"text", "Knuckles", "...", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[12] = {"text", "Amy", "...", nil, nil, nil, {"H_AMY3", SKINCOLOR_ROSY}},
	[13] = {"text", "Sonic", "Geez, everybody's a tough crowd today.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[14] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[15] = {"text", "Tails", "Regardless, don't tire out just yet! Keep at it for just one more round!", nil, nil, nil, nil},
	[16] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},

}

eventList["finalbadnik_defeat"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"text", "Sonic", "Phew... finally! Looks like that was all of them!", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[2] = {"text", "Amy", "Agh... so tired...", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[3] = {"text", "Knuckles", "Don't relax in this elevator just yet. Remember, we're heading towards the source of this problem. Eggman's base.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[4] = {"text", "Sonic", "Only thing we can do right now is just wait for Tails to fly back down here, though.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[5] = {"text", "Sonic", "Still, much as I hate waiting around in enclosed spaces, it sure beats getting accused and attacked by everyone!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[6] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						stagecleared = true
					end
				end
			},

}

eventList["ev_stage5"] = {
	[1] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						P_LinedefExecute(1007)
						P_LinedefExecute(1008)
						boxflip = false
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.sonic = P_SpawnMobj(-8330*FRACUNIT, 7750*FRACUNIT, btl.cam.floorz, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * -100
						s.scale = FRACUNIT*3/2
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						s.state = S_PLAY_WAIT
						evt.amy = P_SpawnMobj(-8230*FRACUNIT, 7800*FRACUNIT, btl.cam.floorz, MT_PFIGHTER)
						local a = evt.amy
						a.skin = "amy"
						a.color = SKINCOLOR_ROSY
						a.angle = ANG1 * -100
						a.scale = FRACUNIT*3/2
						a.cutscene = true
						a.state = S_PLAY_WAIT
						a.noidlebored = true
						evt.knuckles = P_SpawnMobj(-7950*FRACUNIT, 7750*FRACUNIT, btl.cam.floorz, MT_PFIGHTER)
						local k = evt.knuckles
						k.skin = "knuckles"
						k.color = SKINCOLOR_RED
						k.angle = ANG1 * -30
						k.scale = FRACUNIT*3/2
						k.cutscene = true
						k.state = S_PLAY_WAIT
						k.noidlebored = true
					end
					
					if evt.ftimer == 60
						evt.tails = P_SpawnMobj(-8450*FRACUNIT, 7700*FRACUNIT, btl.cam.floorz + 500*FRACUNIT, MT_PFIGHTER)
						local t = evt.tails
						t.skin = "tails"
						t.color = SKINCOLOR_ORANGE
						t.angle = ANG1 * 30
						t.scale = FRACUNIT*3/2
						t.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						t.state = S_PLAY_FLY
						//i dont know how to get followitem working here :(
						t.tails = P_SpawnMobjFromMobj(t, 0, 0, 0, MT_TAILSOVERLAY)
						t.tails.skin = "tails"
						t.tails.color = SKINCOLOR_ORANGE
						t.tails.scale = t.scale
						t.tails.state = S_TAILSOVERLAY_FLY
						t.flying = true
					end
					if evt.ftimer == 100
						evt.sonic.angle = ANG1 * -130
						evt.sonic.noidlebored = false
						evt.sonic.noidle = true
						return true
					end
				end
			},
	[2] = {"text", "Tails", "Phew, good thing I could still catch up to you guys. Thanks for holding out.", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[3] = {"text", "Sonic", "Yo, there you are! Awesome job up there, buddy! We woulda been done in hard without you!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[4] = {"text", "Knuckles", "No celebrating yet. This whole scenario proves Eggman knows we're on our way. Who knows what he'll do once we reach him.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[5] = {"text", "Sonic", "Kinda eerie, though. I haven't heard a peep from that chatterbox mouth of his this whole day.", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[6] = {"text", "Sonic", "I'm ready to just get this over with and kick his butt already! And this elevator's his countdown to scrambled city!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[7] = {"function",
			function(evt, btl)
				if evt.ftimer == 1
					evt.stopped = 0
					P_LinedefExecute(1003)
					P_LinedefExecute(1009)
					for s in sectors.iterate do
						if s.tag == 1 or s.tag == 7 or s.tag == 9
							s.floorheight = $ + 512*FRACUNIT
							s.ceilingheight = $ + 512*FRACUNIT
						end
					end
				end
				for s in sectors.iterate do
					if s.tag == 1 and s.ceilingheight >= -1664*FRACUNIT and evt.stopped == 0
						S_StartSound(nil, sfx_doorc2)
						P_LinedefExecute(1004)
						P_StartQuake(5*FRACUNIT, 2)
						evt.stopped = 1
						evt.sonic.angle = ANG1 * -100
					end
				end
				if evt.stopped > 0
					evt.stopped = $+1
					if evt.stopped == 30
						return true
					end
				end
			end
			},
	[8] = {"text", "Sonic", "Woah, nice timing. Eggman's got a taste for dramatic entrances!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[9] = {"text", "Amy", "Finally, we're here! Let's take Eggman down and get our answers!", nil, nil, nil, {"H_AMY2", SKINCOLOR_ROSY}},
	[10] = {"function", //fake sonic falls down
			function(evt, btl)
				if evt.sonic and evt.sonic.valid
					local s = evt.sonic
					if evt.ftimer == 1
						s.noidle = false
						s.state = S_PLAY_WALK
					end
					if evt.ftimer < 40
						if s.momy < 4*FRACUNIT
							s.momy = $ - 1*FRACUNIT
						end
					elseif evt.ftimer == 40
						s.momy = 0
						s.state = S_PLAY_STND
						s.noidle = true
					end
				end
				if evt.ftimer == 5
					evt.fakesonic = P_SpawnMobj(-8330*FRACUNIT, 7900*FRACUNIT, btl.cam.floorz + 500*FRACUNIT, MT_PFIGHTER)
					local f = evt.fakesonic
					f.skin = "sonic"
					f.color = SKINCOLOR_BLUE
					f.angle = ANG1 * -100
					f.scale = FRACUNIT*3/2
					f.momz = -10*FRACUNIT
					f.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
					f.state = S_PLAY_FALL
					f.landed = false
					f.renderflags = $|RF_FULLDARK
					f.frame = $|FF_TRANS50
					f.scary = true
				end
				if evt.fakesonic and evt.fakesonic.valid
					local f = evt.fakesonic
					if P_IsObjectOnGround(f)
						if not f.landed
							f.state = S_PLAY_STND
							S_StartSound(nil, sfx_s3k49)
							for i = 1,16
								local dust = P_SpawnMobj(f.x, f.y, f.z, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (22*(i-1))
								dust.state = S_CDUST1
								P_InstaThrust(dust, dust.angle, 8*FRACUNIT)
								dust.color = SKINCOLOR_WHITE
								dust.scale = FRACUNIT
							end
							f.landed = true
						end
					end
				end
				if evt.ftimer == 60
					return true
				end
			end
			},
	[11] = {"text", "Tails", "!!!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[12] = {"text", "Sonic", "...?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[13] = {"function", //sonic turns around and camera shifts
			function(evt, btl)
				if evt.sonic and evt.sonic.valid
					local s = evt.sonic
					if evt.ftimer < 10
						s.angle = $ + ANG1*20
					elseif evt.ftimer == 10
						evt.knuckles.angle = R_PointToAngle2(evt.knuckles.x, evt.knuckles.y, evt.fakesonic.x, evt.fakesonic.y)
						evt.knuckles.noidlebored = false
						evt.knuckles.noidle = true
						evt.knuckles.state = S_PLAY_STND
						evt.tails.angle = R_PointToAngle2(evt.tails.x, evt.tails.y, evt.fakesonic.x, evt.fakesonic.y)
						evt.tails.noidlebored = false
						evt.tails.noidle = true
						evt.tails.state = S_PLAY_STND
						evt.amy.angle = R_PointToAngle2(evt.amy.x, evt.amy.y, evt.fakesonic.x, evt.fakesonic.y)
						evt.amy.noidlebored = false
						evt.amy.noidle = true
						evt.amy.state = S_PLAY_STND
						P_RemoveMobj(evt.fakesonic)
					end
					if evt.ftimer >= 10
						local cam = btl.cam
						local tgtx = s.x - 250*cos(s.angle - ANG1*20)
						local tgty = s.y - 250*sin(s.angle - ANG1*20)
						P_TeleportMove(cam, tgtx, tgty, cam.z)
						cam.angle = s.angle
						CAM_stop(cam)
					end
				end
				if evt.ftimer == 40
					return true
				end
			end
			},
	[14] = {"text", "Sonic", "Weird, I swear I heard something behind me.", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[15] = {"function", //sonic turns around again to find no exit
			function(evt, btl)
				if evt.ftimer == 1
					for s in sectors.iterate do
						if s.tag == 1 or s.tag == 7 or s.tag == 9
							s.floorheight = $ - 512*FRACUNIT
							s.ceilingheight = $ - 512*FRACUNIT
						end
					end
				end
				if evt.sonic and evt.sonic.valid
					local s = evt.sonic
					if evt.ftimer < 16
						s.angle = $ - ANG1*12
					elseif evt.ftimer == 16
						P_StartQuake(5*FRACUNIT, 3)
						S_StartSound(nil, sfx_nani)
					end
					if evt.ftimer >= 16
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 2

								local cam = btl.cam
								local tgtx = m.x + 100*cos(m.angle)
								local tgty = m.y + 100*sin(m.angle)
								P_TeleportMove(evt.sonic, tgtx, tgty, evt.sonic.z)
								evt.sonic.angle = m.angle
								P_TeleportMove(cam, m.x, m.y, m.z)
								cam.angle = m.angle
								CAM_stop(cam)
								break
							end
						end
					end
				end
				if evt.ftimer == 40
					return true
				end
			end
			},
	[16] = {"text", "Sonic", "...!!!", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[17] = {"function", //fake sonic reappears and transforms into metal
			function(evt, btl) 
				if evt.ftimer == 1
					for mt in mapthings.iterate do	-- fetch awayviewmobj

						local m = mt.mobj
						if not m or not m.valid continue end

						if m and m.valid and m.type == MT_ALTVIEWMAN
						and mt.extrainfo == 3

							local cam = btl.cam
							cam.angle = m.angle
							CAM_goto(cam, m.x, m.y, m.z)
							CAM_angle(cam, cam.angle)
							break
						end
					end
				end
				if evt.ftimer == 50
					S_StartSound(nil, sfx_s3k8a)
					P_LinedefExecute(1010)
					local cam = btl.cam
					local tgtx = cam.x + 150*cos(cam.angle)
					local tgty = cam.y + 150*sin(cam.angle)
					evt.fakesonic = P_SpawnMobj(tgtx, tgty, btl.cam.floorz, MT_PFIGHTER)
					local f = evt.fakesonic
					f.skin = "sonic"
					f.color = SKINCOLOR_BLUE
					f.angle = R_PointToAngle2(f.x, f.y, cam.x, cam.y)
					f.scale = FRACUNIT*3/2
					f.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
					f.state = S_PLAY_STND
					f.scary = true
					f.renderflags = $|RF_FULLDARK
				end
				if evt.ftimer >= 90
				and evt.ftimer < 140
				and leveltime & 1
					local f = evt.fakesonic
					f.flags2 = $ & ~MF2_DONTDRAW
					local g = P_SpawnGhostMobj(f)
					f.flags2 = $|MF2_DONTDRAW
					g.fuse = 2
					g.renderflags = f.renderflags
					g.frame = f.frame
				end
				if evt.ftimer == 140
					P_LinedefExecute(1011)
					S_StartSound(nil, sfx_hamas2)
					local f = evt.fakesonic
					f.flags2 = $ & ~MF2_DONTDRAW
					f.scary = false
					f.skin = "metalsonic"
					f.frame = $ & ~FF_TRANS50
					f.renderflags = $ & ~RF_FULLDARK
					f.state = S_PLAY_SPRING
					f.ruby = true
				end
				if evt.ftimer == 200
					S_ChangeMusic("stg5a")
					return true
				end
			end
			},
	[18] = {"text", "Knuckles", "This guy...!", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[19] = {"text", "Sonic", "Guess that makes sense! It was Metal Sonic going around and somehow disguising himself as me!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[20] = {"text", "Sonic", "This is perfect! I've got a lotta payback to give ya for getting all my friends on my tail!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[21] = {"text", "Tails", "Be careful, Sonic! He came all this way to take us out! There's something odd about his aura as well!", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[22] = {"text", "Knuckles", "Let's just hurry up and beat the bolts out of this faker!", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[23] = {"function", --start battle
			function(evt, btl)
				cutscene = false
				local wave = {"b_metalsonic"}
				
				local team_1 = server.plentities[1]
				local team_2 = {}
				for i = 1,#wave
					local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
					enm.state = S_PLAY_STND
					enm.tics = -1
					enm.enemy = wave[i]
					team_2[#team_2+1] = enm
				end
				BTL_StartBattle(1, team_1, team_2, 2, nil, "stg5a")
			end
			},
				
					
}

eventList["metalsonic_defeat"] = {
	
	["hud_front"] = hud_front,
	
	[1] = {"text", "Amy", "That's...!", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[2] = {"text", "Tails", "I had a feeling, but I never would have imagined Eggman would have found the Phantom Ruby again...", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[3] = {"text", "Tails", "Using it as the core for Metal Sonic's power source... I can't believe how he managed to make it work...", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[4] = {"text", "Knuckles", "It's all starting to come together, but we just need one more person missing in all of this.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[5] = {"text", "Sonic", "And I bet you he's right behind this door! We'll find our answers and hit the climax real soon!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[6] = {"text", "Sonic", "No more of this imposter business! It's back to good ol' fashioned Eggman butt kicking! Let's go!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[7] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						stagecleared = true
					end
				end
			},
}

local rise = false
eventList["ev_stage6"] = {
	[1] = {"function", --sonic walks in as soon as soon as the black fades away
				function(evt, btl)
					if evt.ftimer == 1
						--cutsceneskip = 30 --kill
						rise = false
						S_ChangeMusic("stg6a")
						boxflip = false
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.sonic = P_SpawnMobj(-8127*FRACUNIT, 2110*FRACUNIT, btl.cam.floorz, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * 280
						s.scale = FRACUNIT*3/2
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						s.state = S_PLAY_WALK
					end
					if evt.ftimer > 93
						local s = evt.sonic
						if s.momy < 0
							if leveltime%2 == 0
								s.momy = $ + 1*FRACUNIT
							end
						else
							s.state = S_PLAY_STND
							s.noidle = true
						end
					else
						local s = evt.sonic
						s.momy = -8*FRACUNIT
					end
					if evt.ftimer == 120
						return true
					end
				end
			},
	[2] = {"text", "Sonic", "For a place that's THIS important looking, there sure is a whole lotta not Eggman.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[3] = {"text", "Tails", "Hold on a sec, because we might looking for Eggman, but this place might give us answers that he might not!", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[4] = {"text", "Tails", "Sonic, could you let me look at these blueprints on the monitors?", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[5] = {"function", -- beep boop
				function(evt, btl)
					if evt.ftimer == 1 or evt.ftimer == 6
						S_StartSound(nil, sfx_s3k89)
					end
					if evt.ftimer == 30
						return true
					end
				end
			},
	[6] = {"text", "Tails", "...", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[7] = {"text", "Amy", "Did you find anything, Tails?", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[8] = {"text", "Tails", "Quick question. None of you have the Chaos Emeralds, and Shadow didn't get his back, right?", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[9] = {"text", "Knuckles", "Nope. I didn't see a single one.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[10] = {"text", "Tails", "Then that settles it. The source of all this mist is the result of Eggman and the Chaos Emeralds he stole.", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[11] = {"text", "Tails", "By harnessing the negative energy within the Chaos Emeralds, he merged that energy with the mist that he'd later spread across the area.", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[12] = {"text", "Sonic", "Negative energy into the mist? What's that mist doing in the first place?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[13] = {"text", "Tails", "...It says here that by using the Chaos Emerald's negative aura as a base, the mist detects any form of distrust, hostility, or any negative emotion.", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[14] = {"text", "Tails", "If an opponent was filled with enough of that emotion, the negative energy within the blue mist would give the opponent more power without them realizing.", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[15] = {"text", "Tails", "It's a lot similar to how Chaos Emeralds grant unlimited power, but this time, this effect only comes to those with negative emotions.", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[16] = {"text", "Amy", "I think I can connect the dots... by using Metal Sonic to both disguise himself as Sonic and collect Chaos Emeralds...", nil, nil, nil, {"H_AMY3", SKINCOLOR_ROSY}},
	[17] = {"text", "Sonic", "They made everybody think it was me, and had the mist power up their anger... ugh...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[18] = {"text", "Knuckles", "That explains how they were so powerful, even with four against one.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[19] = {"text", "Knuckles", "...Hearing all this really makes me mad. All of this is a just a part of his plan.", nil, nil, nil, {"H_KNUX1", SKINCOLOR_RED}},
	[20] = {"text", "Sonic", "Well, not all of it. He hasn't seen us here yet, so that's the one up we've got on him!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[21] = {"text", "Knuckles", "...Wait, that's not right. If he planned a trap back there... doesn't he...", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[22] = {"function", -- earthquake!!!! eggman appears behind windows!!!!!!
				function(evt, btl)
					if evt.ftimer == 1
						S_StopMusic()
						P_StartQuake(10*FRACUNIT, 5)
						S_StartSound(nil, sfx_doorc2)
					end
					if evt.ftimer == 50
						--P_LinedefExecute(1002)
						S_StartSound(btl.cam, sfx_rumble)
						evt.sonic.noidle = false
						evt.sonic.state = S_PLAY_EDGE
						S_ChangeMusic("stg6b")
						rise = true
						evt.eggman = P_SpawnMobj(-8128*FRACUNIT, 800*FRACUNIT, -2100*FRACUNIT, MT_PFIGHTER)
						local s = evt.eggman
						s.skin = "eggman"
						s.color = SKINCOLOR_RED
						s.angle = ANG1*80
						s.scale = FRACUNIT*4/3
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						s.state = S_PLAY_WAIT
					end
					if evt.ftimer == 100
						S_StartSound(nil, sfx_buzz3)
						boxflip = true
						return true
					end
				end
			},
	[23] = {"text", "Eggman", "Oh, and how the prey falls right into the predator's lap!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[24] = {"text", "Eggman", "Ah, I do love it when I get the timing right! I've always been a man of dramatic entrances, if I do say so myself!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[25] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[26] = {"text", "Knuckles", "He finally shows himself! I'll ruin every single piece of that metal!", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[27] = {"text", "Tails", "...Wait, he was here all along? And he let us check his plans?", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[28] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[29] = {"text", "Eggman", "Well, I needed someone to understand how much of a brilliant plan I had conjured!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[30] = {"text", "Eggman", "After all, just look how all the pieces had fallen in place! I was so joyous, I couldn't stand keeping quiet any longer!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[31] = {"text", "Eggman", "And thus, here we are! Yes, it's all true, indeed! I was the one who spread this fantastic mist and put you on the wanted poster!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[32] = {"text", "Eggman", "Every single one of you was absolutely clueless as I sat and watched the strife unfold!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[33] = {"text", "Eggman", "Granted, it would have been convenient if you had just bit it during your playtime with your precious friends, but it's a good thing geniuses have back-up plans!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[34] = {"text", "Eggman", "You may have lucked out previously, but guess who still has the Chaos Emeralds at the end of the day!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},	
	[35] = {"function", -- eggman breaks windows and walls kinda!!!!!!!!!!!
				function(evt, btl)
					if evt.ftimer == 1
						P_StartQuake(20*FRACUNIT, 20)
						S_StartSound(nil, sfx_crumbl)
						S_StartSound(nil, sfx_s3k59)
						P_LinedefExecute(1001)
					end
					if evt.ftimer == 60
						return true
					end
				end
			},
	[36] = {"text", "Eggman", "Pesky rodents! Say hello to back-up plan!", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[37] = {"function", --start battle
			function(evt, btl)
				cutscene = false
				local wave = {"b_emerald", "b_emerald", "b_emerald", "b_emerald", "b_emerald", "b_emerald", "b_emerald", "b_eggman"}
				
				local team_1 = server.plentities[1]
				local team_2 = {}
				for i = 1,#wave
					local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
					enm.state = S_PLAY_STND
					enm.tics = -1
					enm.enemy = wave[i]
					team_2[#team_2+1] = enm
				end
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
				btl.weaknesses = $ or {}
				btl.resistances = $ or {}
				for i = 1, #enemies
					btl.weaknesses[i] = atk_constants[P_RandomRange(1, #atk_constants)]
					btl.resistances[i] = atk_constants[P_RandomRange(1, #atk_constants)]
				end
				BTL_StartBattle(1, team_1, team_2, 1, nil, "stg6c")
			end
			},
}

//egg mech rising up thinker
addHook("ThinkFrame", function()
	if not rise return end
	P_StartQuake(2*FRACUNIT, 1)
	if gamemap == 12
		for s in sectors.iterate
			if s.tag == 3
				s.ceilingheight = $+2*FRACUNIT
				s.floorheight = $+2*FRACUNIT
				if s.ceilingheight >= -1300*FRACUNIT
					local btl = server.P_BattleStatus[1]
					if btl
						S_StopSound(btl.cam)
					end
					rise = false
				end
			end
		end
	end
end)

eventList["ev_extrastage"] = {
	[1] = {"function", --blah blah blah camera rolls down and sonic comes in from left the usual
				function(evt, btl)
					if evt.ftimer == 1
						S_ChangeMusic("stg7a")
						boxflip = false
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

								local cam = btl.cam
								P_TeleportMove(cam, m.x, m.y, m.z)
								cam.angle = m.angle
								cam.aiming = -ANG1*2
								CAM_goto(cam, cam.x, cam.y, cam.z)
								CAM_angle(cam, cam.angle)
								CAM_aiming(cam, cam.aiming)
								break
							end
							
							if m and m.valid and m.type == MT_GFZTREE
								m.scale = FRACUNIT*2
							end
						end
						evt.fang = P_SpawnMobj(-690*FRACUNIT, 1120*FRACUNIT, 0, MT_DUMMY)
						local s = evt.fang
						--s.skin = "fang"
						s.color = SKINCOLOR_LAVENDER
						s.angle = ANG1 * 180
						s.scale = FRACUNIT
						s.sprite = SPR_FANG
						s.tics = -1
						s.frame = A
						--s.noidlebored = true
						--s.state = S_PLAY_WAIT
						--s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers*/
					end
					if evt.ftimer < 70 and evt.ftimer > 1
						local cam = btl.cam
						P_TeleportMove(cam, cam.x, cam.y, cam.z-1*FRACUNIT)
					end
					--here's where we spawn a decoy sonic just outside the camera's range and have him jump in
					if evt.ftimer == 75
						evt.sonic = P_SpawnMobj(-750*FRACUNIT, -200*FRACUNIT, 50*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * -10
						s.scale = FRACUNIT*2
						s.momz = 12*FRACUNIT
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
					end
					if evt.ftimer >= 75 and evt.ftimer < 80
						local s = evt.sonic
						local landpointx = -400*FRACUNIT
						s.momx = (landpointx - s.x)/17
					end
					if evt.sonic and evt.sonic.valid and P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.momx = $/2
						s.momy = $/2
						if s.momx > 0 or s.momy > 0
							s.state = S_PLAY_SKID
							s.frame = F
						elseif s.momx == 0 and s.momy == 0
							s.state = S_PLAY_STND
							s.noidle = true
						end
					elseif evt.sonic and evt.sonic.valid and not P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.state = S_PLAY_FALL
					end
					
					if evt.ftimer == 120 
						for p in players.iterate do
							S_FadeOutStopMusic(3*MUSICRATE, p)
						end
						return true
					end
				end
			},
	[2] = {"text", "Sonic", "...Huh? Where's the boss?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[3] = {"text", "Amy", "What do you mean?", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[4] = {"text", "Tails", "Wait... this can't be...", nil, nil, nil, {"H_TAILS1", SKINCOLOR_ORANGE}},
	[5] = {"text", "Tails", "Sonic, where did you take us?!", nil, nil, nil, {"H_TAILS5", SKINCOLOR_ORANGE}},
	[6] = {"text", "Sonic", "It's the Extra Stage. Y'know, the one on the main menu. Why're you askin?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[7] = {"text", "Tails", "T-This is bad! Extremely bad! Sonic, we have to get out of here!", nil, nil, nil, {"H_TAILS5", SKINCOLOR_ORANGE}},
	[8] = {"text", "Sonic", "Huh? Hold up a sec, what're you talking about?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[9] = {"text", "Tails", "Sonic, the Extra Stage is incomplete! The creator never worked on this boss fight!", nil, nil, nil, {"H_TAILS5", SKINCOLOR_ORANGE}},
	[10] = {"text", "Tails", "Actually, we're not even supposed to be here! H-How did you even manage to get to this place?!", nil, nil, nil, {"H_TAILS4", SKINCOLOR_ORANGE}},
	[11] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON6", SKINCOLOR_BLUE}},
	[12] = {"text", "Sonic", "(...It's not MY fault I saw MAP13 when the mod was loaded...)", nil, nil, nil, {"H_SON6", SKINCOLOR_BLUE}},
	[13] = {"text", "Amy", "Hey, calm down, Tails. What are you panicking for? There's no reason to rush, is there?", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[14] = {"text", "Tails", "No, you don't understand! L-Look, we need t-", nil, nil, nil, {"H_TAILS5", SKINCOLOR_ORANGE}},
	[15] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[16] = {"text", "???", "There you are!", nil, nil, nil, nil},
	[17] = {"function", --silver falls down and slowly descends once he gets near floor
				function(evt, btl)
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
					
					if evt.silver and evt.silver.valid and not evt.silver.falling then spawnaura(evt.silver) end
					
					if evt.ftimer == 1
						evt.silver = P_SpawnMobj(600*FRACUNIT, -200*FRACUNIT, 700*FRACUNIT, MT_PFIGHTER)
						local s = evt.silver
						s.skin = "silver"
						s.color = SKINCOLOR_AETHER
						s.state = S_PLAY_FLOAT_RUN
						s.angle = ANG1 * 210
						s.scale = FRACUNIT*2
						s.momz = -30*FRACUNIT
						s.flags = $ | MF_NOGRAVITY
						local landpointx = 300*FRACUNIT
						s.momx = (landpointx - s.x)/17
						s.cutscene = true
					end

					if evt.silver and evt.silver.valid and evt.silver.z < evt.silver.floorz + 200*FRACUNIT and not evt.silver.flyup
						local s = evt.silver
						if s.state != S_PLAY_FLOAT
							s.state = S_PLAY_FLOAT
							S_StartSound(nil, sfx_float)
						end
						s.momz = $*80/100
						s.momx = $*80/100
						if leveltime%4 == 0
							for i = 1,16
								local dust = P_SpawnMobj(s.x, s.y, s.floorz, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (22*(i-1))
								dust.state = S_CDUST1
								P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
								dust.color = SKINCOLOR_WHITE
								dust.scale = FRACUNIT*2
							end
						end
						P_StartQuake(1*FRACUNIT, 2)
					end
					if evt.silver and evt.silver.valid and evt.silver.momz > -1*FRACUNIT and evt.ftimer > 20
						local s = evt.silver
						s.flyup = true
					end
					if evt.silver and evt.silver.valid and evt.silver.flyup and evt.ftimer > 20
						local s = evt.silver
						local landpointx = 300*FRACUNIT
						s.momx = (landpointx - s.x)/20
						if leveltime%10 == 0
							for i = 1,16
								local dust = P_SpawnMobj(s.x, s.y, s.floorz, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (22*(i-1))
								dust.state = S_CDUST1
								P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
								dust.color = SKINCOLOR_WHITE
								dust.scale = FRACUNIT*2
							end
						end
						if s.z < 100*FRACUNIT
							s.momz = 5*FRACUNIT
						else 
							s.momz = $/2
						end
					end
					if evt.ftimer == 80 
						S_StartSound(nil, sfx_pcan)
						local s = evt.silver
						s.flags = $ & ~MF_NOGRAVITY
						s.state = S_PLAY_FALL
						s.falling = true
						return true 
					end
				end
			},
	[18] = {"text", "Silver", "I've finally found you, th-", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[19] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[20] = {"text", "Sonic", "Woahwoahwoah, hey, what? Silver, what're you doing here now? You aren't supposed to be here, are you?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[21] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[22] = {"text", "Silver", "Huh? Isn't this Stage 1?", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[23] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[24] = {"text", "Tails", "N-NO! What the- you- none of us are supposed to be here! This battle is unfinished! We have to get out of here now, before-", nil, nil, nil, {"H_TAILS5", SKINCOLOR_ORANGE}},
	[25] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						S_StopMusic()
						P_StartQuake(20*FRACUNIT, 10)
						S_StartSound(nil, sfx_litng4)
						for p in players.iterate
							P_FlashPal(p, 1, 4)
						end
						P_SetupLevelSky(34)
					end
					
					if evt.ftimer == 60
						S_StartSound(nil, sfx_rumble)
						evt.sonic.noidle = false
						evt.sonic.state = S_PLAY_EDGE
						evt.silver.falling = false
						evt.silver.noidle = false
						evt.silver.state = S_PLAY_PAIN
						evt.silver.tics = -1
						S_ChangeMusic("stg4b")
						rise = true
						return true
					end
				end
			},
	[26] = {"text", "Knuckles", "...???", nil, nil, nil, {"H_KNUX2", SKINCOLOR_RED}},
	[27] = {"text", "Tails", "We're in trouble... \x82it's\x80 starting!", nil, nil, nil, {"H_TAILS4", SKINCOLOR_ORANGE}},
	[28] = {"text", "Amy", "W-what's starting? What's going on?!", nil, nil, nil, {"H_AMY1", SKINCOLOR_ROSY}},
	[29] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[30] = {"text", "Silver", "I would also like to know!", nil, nil, nil, {"H_SIL1", SKINCOLOR_AETHER}},
	[31] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[32] = {"text", "Tails", "Don't you get it?! Legends say, in a stage without a proper boss battle, something dreadful takes its place!", nil, nil, nil, {"H_TAILS5", SKINCOLOR_ORANGE}},
	[33] = {"text", "Tails", "Now that we're here, it's coming! An enemy to fill in the missing gap! To substitute an incomplete battle!", nil, nil, nil, {"H_TAILS5", SKINCOLOR_ORANGE}},
	[34] = {"text", "Sonic", "...!!!!!", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[35] = {"text", "Tails", "That twisted thing is called...", nil, nil, nil, {"H_TAILS4", SKINCOLOR_ORANGE}},
	[36] = {"function",
				function(evt, btl)
					if evt.ftimer < 40
						for s in sectors.iterate
							s.lightlevel = s.lightlevel - 1
						end
					end
					
					if evt.ftimer == 60
						return true
					end
				end
			},
	[37] = {"text", "Tails", "\x82The placeholder boss.", nil, nil, nil, {"H_TAILS4", SKINCOLOR_ORANGE}},
	[38] = {"function", --start battle
			function(evt, btl)
				cutscene = false
				S_StopMusic()
				local wave = {"god"}
				local team_1 = server.plentities[1]
				local team_2 = {}
				for i = 1,#wave
					local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
					enm.state = S_PLAY_STND
					enm.tics = -1
					enm.enemy = wave[i]
					team_2[#team_2+1] = enm
				end
				//advantage: 1 = player, 2 = enemy, 0 = neutral(?)
				BTL_StartBattle(1, team_1, team_2, 1, nil, "stg7b")
			end
			},
}

//TIPS CORNER CUTSCENES (woah, half of this script is just tips corner)

//main points: magic powerhouse, hamaon v2, keep around links, watch out for hp
//also, masked eggman uses persona desync and summons his stand
eventList["ev_tipscorner_1"] = {
	[1] = {"function", --zamn
				function(evt, btl)
					if evt.ftimer == 1
						S_ChangeMusic("tips")
						S_StartSound(nil, sfx_s3k51)
						boxflip = true
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.eggman = P_SpawnMobj(448*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local e = evt.eggman
						e.skin = "eggman"
						e.color = SKINCOLOR_RED
						e.angle = ANG1 * 200
						e.scale = FRACUNIT
						--e.noidlebored = true
						e.state = S_MASKEDIDLE
						--e.tics = -1
						e.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						evt.sonic = P_SpawnMobj(-65*FRACUNIT, 320*FRACUNIT, 400*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * 340
						s.scale = FRACUNIT
						s.noidlebored = true
						s.sprite2 = SPR2_SHIT
						s.tics = -1
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						s.landed = false
					end
					if evt.ftimer > 1
						evt.eggman.sprite = SPR_MASK
						evt.sonic.sprite2 = SPR2_SHIT
					end
					
					if evt.sonic and evt.sonic.valid
						local s = evt.sonic
						if not P_IsObjectOnGround(s)
							s.spritexscale = $-FRACUNIT/100
							s.spriteyscale = $+FRACUNIT/100
						else
							if not s.landed
								S_StartSound(nil, sfx_s3k5d)
								P_StartQuake(2*FRACUNIT, 2)
								for i = 1,16
									local dust = P_SpawnMobj(s.x, s.y, s.z, MT_DUMMY)
									dust.angle = ANGLE_90 + ANG1* (22*(i-1))
									dust.state = S_CDUST1
									P_InstaThrust(dust, dust.angle, 10*FRACUNIT)
									dust.color = SKINCOLOR_WHITE
									dust.scale = FRACUNIT/2
								end
								s.spritexscale = FRACUNIT*3/2
								s.spriteyscale = FRACUNIT*2/3
								s.landed = true
							end
						end
						if s.landed
							s.spritexscale = s.spritexscale + (FRACUNIT - s.spritexscale)/5
							s.spriteyscale = s.spriteyscale + (FRACUNIT - s.spriteyscale)/5
						end
					end
					
					if evt.ftimer == 80 return true end
				end
			},
	[2] = {"text", "MASKED Eggman", "Ladies and gentlemen, welcome to the\x82 ".."Blue Mistery Tips Corner!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[3] = {"text", "MASKED Eggman", "Presented to you by your ravishingly handsome host for today, MASKED Eggman!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[4] = {"text", "MASKED Eggman", "Who has absolutely no relation to any similar figures in particular.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[5] = {"function",
				function(evt, btl)
					boxflip = false
					if evt.ftimer == 1
						S_StartSound(nil, sfx_nxbump)
					end
					if evt.ftimer == 50
						return true
					end
				end
			},
	[6] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[7] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[8] = {"text", "MASKED Eggman", "Aww... what's wrong, Sonic? In a bad mood?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[9] = {"text", "MASKED Eggman", "I mean, dying on Stage 1? Don't you have 5 more stages ahead of you?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[10] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[11] = {"text", "Sonic", "Oh, come on. We both know I'm weak to Psi. This matchup's hardly fair for a first battle.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[12] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[13] = {"text", "MASKED Eggman", "I bet you gave him many generous 1Mores!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[14] = {"text", "MASKED Eggman", "With his powerful magic stat, and the power of his persona, Stage 1 is not to be underestimated simply because it's Stage 1!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[15] = {"text", "MASKED Eggman", "However, he's quite a one trick pony. He relies solely on his magic attacks, so debuffing his magic hurts him more than you think.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[16] = {"text", "MASKED Eggman", "His endurance is most certainly low, so he's what they call a glass cannon. However, I suggest to avoid going the full assault path.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[17] = {"function",
				function(evt, btl)
					TIPS_pullImage(100, 60, "H_TIPS1", "up", true) --100, 60 is center
					return true
				end
			},
	[18] = {"text", "MASKED Eggman", "After all, believe it or not, this situation is dangerous! Without any defense buffs, Silver can knock out Amy in two unlucky moves!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[19] = {"function",
				function(evt, btl)
					TIPS_goAwayImage("down")
					boxflip = false
					return true
				end
			},
	[20] = {"text", "Sonic", "Yeah, I guess that's kinda been his thing. High attack, low defense.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[21] = {"text", "Sonic", "But then he just goes and summons his persona to fight alongside with him! Is that even fair!? How do you DO that!?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[22] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[23] = {"text", "MASKED Eggman", "Hm? That's pretty easy to do though?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[24] = {"function",
				function(evt, btl)
					S_FadeOutStopMusic(MUSICRATE*2)
					boxflip = false
					return true
				end
			},
	[25] = {"text", "Sonic", "Huh?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[26] = {"function",
				function(evt, btl)
					if evt.eggman and evt.eggman.valid
						local mo = evt.eggman
						local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}
						if evt.ftimer < 140 and evt.ftimer >= 1
							summonAura(mo, SKINCOLOR_TEAL)
							if evt.ftimer == 1
								mo.energyspeed = 30
								S_StartSound(nil, sfx_debuff)
								S_StartSound(nil, sfx_s3ka1)
							end
							if evt.ftimer >= 100
								P_StartQuake(FRACUNIT*2, 1)
							end
							if evt.ftimer <= 30
								for s in sectors.iterate
									s.lightlevel = s.lightlevel - 2
								end
							end
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
						elseif evt.ftimer >= 140
							summonAura(mo, SKINCOLOR_TEAL)
							if evt.ftimer == 140
								local g = P_SpawnGhostMobj(mo)
								g.colorized = true
								g.destscale = mo.scale*4
								g.scalespeed = mo.scale/8
								for p in players.iterate
									P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
								end
								S_StartSound(nil, sfx_s3k9f)
								
								mo.stando = P_SpawnGhostMobj(mo)
								mo.stando.fuse = -1
								mo.stando.state = S_PLAY_SUPER_TRANS6
								mo.stando.tics = -1
								mo.stando.frame = G|FF_TRANS40
								mo.stando.scale = FRACUNIT*3/2
								P_TeleportMove(mo.stando, mo.x+40*FRACUNIT, mo.y+30*FRACUNIT, mo.z+40*FRACUNIT)
								S_ChangeMusic("ubatl")
							end
							if mo.stando and mo.stando.valid
								summonAura(mo.stando, SKINCOLOR_TEAL)
							end
						end
						if evt.ftimer == 180
							return true
						end
					end
				end
			},
	[27] = {"text", "Sonic", "", nil, nil, nil, {"H_SON10", SKINCOLOR_BLUE}},
	[28] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[29] = {"text", "???", "I Art Thou, Thou Art I...", nil, nil, nil, nil},
	[30] = {"text", "???", "Thou Hast Separated Mind from Body, and Shalt Wage Warfare in the Form of Both Master and Spirit in Unison.", nil, nil, nil, nil},
	[31] = {"text", "???", "Also, Thou Shalt Recieve Maximized Defense Buffs and Restore Thy HP to 50%...", nil, nil, nil, nil},
	[32] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[33] = {"text", "Sonic", "Wait! Waitwaitwaitwaitwait! Back up! Restores HP to 50%!? I knew there was something up with that move! This is cheating! Where is he getting this from!?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[34] = {"text", "Sonic", "...Where are YOU getting this from!?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[35] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[36] = {"text", "MASKED Eggman", "Time's up, Sonic! You should have activated hyper!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[37] = {"function", //psio sonic
				function(evt, btl)
					if evt.sonic and evt.sonic.valid
						local mo = evt.sonic
						local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}

						if mo.psio and mo.psio[1]
							for k,v in ipairs(mo.psio)
								if leveltime%2
									v.color = psiocolors[P_RandomRange(1, #psiocolors)]
									if FixedHypot(v.momx, v.momy)
										local g = P_SpawnGhostMobj(v)
										g.fuse = 4
									end
								end
							end
						end

						if evt.ftimer >= 10 and evt.ftimer <= 26
							if evt.ftimer == 10
								mo.psio = {}
							end

							if not (evt.ftimer%2)
								local x, y, z = mo.x + P_RandomRange(-96, 96)*FRACUNIT, mo.y + P_RandomRange(-96, 96)*FRACUNIT, mo.z + P_RandomRange(0, 128)*FRACUNIT

								local ol = P_SpawnMobj(x, y, z, MT_DUMMY)
								ol.sprite = SPR_NTHK
								ol.scale = FRACUNIT/2
								ol.destscale = FRACUNIT*10
								ol.frame = B|FF_FULLBRIGHT
								ol.color = SKINCOLOR_BLACK
								ol.scalespeed = FRACUNIT/5
								ol.tics = 15

								ol = P_SpawnMobj(x, y, z, MT_DUMMY)
								ol.sprite = SPR_NTHK
								ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
								ol.scale = 1
								ol.destscale = FRACUNIT*32
								ol.scalespeed = FRACUNIT
								ol.frame = B|FF_FULLBRIGHT|TR_TRANS50
								ol.tics = 8

								if not (evt.ftimer%4) then ol.color = SKINCOLOR_WHITE; S_StartSound(nil, sfx_s3k74) end

								local psi = P_SpawnMobj(x, y, z, MT_DUMMY)
								psi.sprite = SPR_NTHK
								psi.scale = 1
								psi.destscale = FRACUNIT*2/3
								psi.color = psiocolors[P_RandomRange(1, #psiocolors)]
								psi.frame = A|FF_FULLBRIGHT
								psi.tics = -1
								mo.psio[#mo.psio+1] = psi
							end

						elseif evt.ftimer == 45
							S_StartSound(nil, sfx_s3k83)
							for k,v in ipairs(mo.psio)
								v.momx = -(v.x - mo.x) / 4
								v.momy = -(v.y - mo.y) / 4
								v.momz = -(v.z - mo.z) / 4
							end

						elseif evt.ftimer == 49
							P_StartQuake(12*FRACUNIT, 8)
							S_StartSound(nil, sfx_crit)

							mo.downanim = 10	-- oof
							if not mo.down
								mo.state = S_PLAY_PAIN
							end

							mo.down = true	-- down is a separate status condition
							for k,v in ipairs(mo.psio)
								P_RemoveMobj(v)
							end
							mo.psio = nil
							mo.momz = 8*FRACUNIT
						elseif evt.ftimer >= 50 and evt.ftimer <= 80
							if not (evt.ftimer%4)

								--playSound(target.battlen, sfx_s3k77)

								local ol = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
								ol.sprite = SPR_NTHK
								ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
								ol.scale = 1
								ol.destscale = FRACUNIT*32
								ol.scalespeed = FRACUNIT/5
								ol.frame = B|FF_FULLBRIGHT
								ol.tics = 20
							end
						end
						if evt.ftimer >= 49
							local an = leveltime * ANG1 * 8
							for i = 1, 2 do
								local dx = mo.x + 64*cos(an)
								local dy = mo.y + 64*sin(an)
								local dz = mo.z + mo.height + 12*sin(an + leveltime*ANG1*4)
								local s = P_SpawnMobj(dx, dy, dz, MT_DUMMY)
								s.state = S_SPRK1
								s.scale = FRACUNIT*2
								s.destscale = 0
								s.frame = A|FF_FULLBRIGHT
								s.tics = 1
								if (leveltime%2)
									s.fuse = 2
								end
								an = $+ ANG1*180
							end
						end
						if evt.ftimer == 95
							evt.sonic.state = S_PLAY_STND
							evt.sonic.sprite2 = SPR2_SHIT
							evt.sonic.tics = -1
							boxflip = false
							return true
						end
					end
				end
			},
	[38] = {"text", "Sonic", "Ow!? Way to welcome new players!? This is a brutal first stage! Nerf Silver already!!", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[39] = {"text", "Tails", "Sonic, stand back! I need to get rid of those buffs!", nil, nil, nil, {"H_TAILS5", SKINCOLOR_ORANGE}},
	[40] = {"function",
				function(evt, btl)
					if evt.eggman and evt.eggman.valid
						local target = evt.eggman
						if target.cards
							for kk, vv in ipairs(target.cards)

								if not target continue end
								if not vv continue end

								if evt.ftimer <= 70
									local target_x = target.x + 80*(cos(vv.angle - ANG1*80))
									local target_y = target.y + 80*(sin(vv.angle - ANG1*80))
									if kk%2
										vv.sprite = SPR_CARD
										vv.frame = A|FF_PAPERSPRITE
									else
										vv.sprite = SPR_SPRK
										vv.frame = A
									end
									vv.scale = FRACUNIT + FRACUNIT/3
									vv.angle = $-ANG1*35

									P_TeleportMove(vv, target_x, target_y, vv.z)
								else
									if vv and vv.valid
										vv.momz = 0
									end
								end

								if evt.ftimer == 80
								and vv.valid
									P_RemoveMobj(vv)
								end
							end
						end

						if evt.ftimer == 90
							target.cards = nil
						end
						
						if evt.ftimer == 80
							S_StartSound(nil, sfx_hamas1)
							S_StartSound(nil, sfx_status)
							local colors = {SKINCOLOR_ORANGE, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD, SKINCOLOR_YELLOW}
							local strs = {"atk", "mag", "def", "agi", "crit"}
							for j = 1, 16
								local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
								orb.momx = P_RandomRange(-16, 16)<<FRACBITS
								orb.momy = P_RandomRange(-16, 16)<<FRACBITS
								orb.momz = P_RandomRange(-16, 16)<<FRACBITS
								orb.destscale = 0
								orb.frame = A
								orb.color = colors[P_RandomRange(1, #colors)]
							end

							local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
							thok.state = S_INVISIBLE
							thok.tics = 1
							thok.scale = FRACUNIT*4
							A_OldRingExplode(thok, MT_SUPERSPARK)
						end

						if evt.ftimer == 100
							boxflip = true
							return true
						end

						if evt.ftimer >= 15
						and evt.ftimer <= 75
							if not (evt.ftimer%4)
								if not target.cards then target.cards = {} end
								for i = 1,8
									local angle = P_RandomRange(1, 359)*ANG1
									local x = target.x + 64*(cos(angle))
									local y = target.y + 64*(sin(angle))
									local item = P_SpawnMobj(x, y, target.z, MT_DUMMY)
									S_StartSound(nil, sfx_hamaca)
									item.tics = -1
									if i%2
										item.sprite = SPR_CARD
										item.frame = A|FF_PAPERSPRITE
									else
										item.sprite = SPR_SPRK
										item.frame = A
									end
									item.angle = angle - ANG1*80
									item.momz = 5*FRACUNIT
									table.insert(target.cards, item)
								end
							end
						end
					end
				end
			},
	[41] = {"text", "MASKED Eggman", "Ahh... Clever! While insta-kills are ineffective against bosses, \x82Hamaon v2\x80 has a chance on removing all buffs from a boss.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[42] = {"text", "MASKED Eggman", "However...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[43] = {"function",
				function(evt, btl)
					if evt.eggman and evt.eggman.valid
						local target = evt.eggman
						if evt.ftimer == 1
							target.dbs = {}
							S_StartSound(nil, sfx_debuff)
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
						if evt.ftimer == 100
							S_FadeOutStopMusic(MUSICRATE*2)
							if target.dbs and #target.dbs
								for i = 1, #target.dbs do
									local energy = target.dbs[i]
									if not energy or not energy.valid continue end	-- don't care
									energy.momz = FRACUNIT*20
								end
							end
							P_StartQuake(FRACUNIT*20, TICRATE/2)
							for p in players.iterate
								P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
							end
							S_StartSound(nil, sfx_buff2)
							S_StartSound(nil, sfx_hamas2)
							for i = 1,15
								local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (22*(i-1))
								dust.state = S_CDUST1
								P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
								dust.color = SKINCOLOR_WHITE
								dust.scale = FRACUNIT*3
							end

						elseif evt.ftimer > 100 and evt.ftimer <= 150
							
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
						elseif evt.ftimer == 175
							boxflip = false
							return true
						end
					end
				end
			},
	[44] = {"text", "Tails", "", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[45] = {"text", "Sonic", "", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[46] = {"function",
				function(evt, btl)
					S_ChangeMusic("tips")
					boxflip = true
					return true
				end
			},
	[47] = {"text", "MASKED Eggman", "Unfortunately, the newly desync'd Omoikane is programmed to use \x82Hyper Mamakakaja\x80 on its first turn, buffing Silver's magic up to max!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[48] = {"text", "MASKED Eggman", "I suggest you wait until AFTER Omoikane buffs Silver's magic to use Hamamon v2 to remove all of the buffs! Otherwise, you're rolling the dice twice!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[49] = {"text", "MASKED Eggman", "Plus, Omoikane can only use it once per battle! Isn't that convenient?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[50] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[51] = {"text", "Tails", "...Guess I'll wait, then.", nil, nil, nil, {"H_TAILS3", SKINCOLOR_ORANGE}},
	[52] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[53] = {"text", "MASKED Eggman", "But if toying with buffs isn't your style, you could go another route: \x82".."Switching targets and aiming for Omoikane!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[54] = {"text", "MASKED Eggman", "I'll let you in on a secret! Omoikane's endurance stat is actually \x82".."lower".."\x80 than Silver's! Plus, it has less HP than what Silver gains when he spawns it in!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[55] = {"text", "MASKED Eggman", "Hypothetically, if all goes well, targetting Omoikane would lead to a much faster victory!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[56] = {"text", "MASKED Eggman", "If you took the time to buff your teammates' defense, you'd have no problem nailing it on the head!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[57] = {"text", "MASKED Eggman", "But beware! Omoikane may not buff itself through any skills of its own, \x82".."but for every attack it receives, its magic gets buffed!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[58] = {"text", "MASKED Eggman", "A quick defeat is possible for both sides in this stage! You'll want to keep an eye on your HP at all times!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[59] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[60] = {"text", "Sonic", "Uh... so... in summary... \x82".."be careful about my teammates' HP and keep \x82Silver's buffs in check, right?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[61] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[62] = {"text", "MASKED Eggman", "Correct! I see you have a knack for understanding, just like me!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[63] = {"text", "MASKED Eggman", "This sort of advice may sound basic, but for a raw magic powerhouse like Silver, staying alive is imperative.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[64] = {"text", "MASKED Eggman", "One simple neglect to heal could result into a Telekinetic Disorderly serving of oblivion! Dear me!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[65] = {"text", "MASKED Eggman", "And dont' forget, Sonic! Make sure to activate \x82".."Hyper Mode".."\x80 as often as possible!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[66] = {"text", "MASKED Eggman", "After all, Silver won't be able to get a 1More off of you as long as you're in the Hyper Mode!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[67] = {"text", "MASKED Eggman", "In my opinion, the best way to execute this is through Tails' Emerald Skill, Faultless Reinforcement. Gets the defense rolling!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[68] = {"text", "MASKED Eggman", "If you like to dance with death, though, buffing your agility and banking on a dodge isn't a bad idea either!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[69] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[70] = {"text", "Sonic", "Yeah, yeah, you done now? This cutscene's a bit too long for my taste.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[71] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[72] = {"text", "MASKED Eggman", "Well, I won't keep you waiting any longer! That is all from me, so I shall bid you farewell!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[73] = {"text", "MASKED Eggman", "As always, I hope you taste defeat again so that you may experience my handsome visage once again! Ta-ta!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[74] = {"function",
				function(evt, btl)
					boxflip = false
					local ltarget = evt.eggman
					if evt.ftimer == 1
						S_StartSound(nil, sfx_s3k74)
						ltarget.lifted = true
					end

					if evt.ftimer >= 2
						ltarget.shake = $ or 0

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

						spawnaura(ltarget)
						
						if evt.ftimer == 35
							S_StartSound(nil, sfx_s3k6f)
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
						if evt.ftimer < 50
							ltarget.momz = (ltarget.floorz + FRACUNIT*130 - ltarget.z)/8
						elseif evt.ftimer == 50
							ltarget.rumble = false
							ltarget.flags2 = $ & ~MF2_DONTDRAW
							S_StartSound(nil, sfx_thok)
						end
						if evt.ftimer >= 50
							ltarget.momz = 80*FRACUNIT
							ltarget.rollangle = $+ANG1*40
						end
						if evt.ftimer == 65
							S_StartSound(nil, sfx_crumbl)
							S_StartSound(nil, sfx_s3k59)
							P_StartQuake(10*FRACUNIT, 10)
							ltarget.flags2 = $|MF2_DONTDRAW
						end
						if evt.ftimer == 120
							S_StartSound(nil, sfx_contin)
							tipsfinished = true
							return true
						end
					end
				end
			},
}

//main points: garuverse alter to bypass agility, buff defense and debuff his magic in preparation for big attacks, make sure hes properly debuffed when he starts to supercharge cuz he chaos controls the moment he gets it
//also, shadow meter keeps filling up as conversation goes and shadow chaos controls saying dont follow their tips
local meterx = -200
local metermax = 500 //125 on display
local meterdisplay = 0 //also known as the meter percentage
local meter = 0
local barcolor = 7
local metercolor = 132
local meterlevel = 0
local fullmeter = false
local itsmeteringtime = false

local firefield = false //blaze variable jumpscare

eventList["ev_tipscorner_2"] = {
	[1] = {"function", --zamn
				function(evt, btl)
					if evt.ftimer == 1
						S_ChangeMusic("tips")
						S_StartSound(nil, sfx_s3k51)
						boxflip = true
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.eggman = P_SpawnMobj(448*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local e = evt.eggman
						e.skin = "eggman"
						e.color = SKINCOLOR_RED
						e.angle = ANG1 * 200
						e.scale = FRACUNIT
						--e.noidlebored = true
						e.state = S_MASKEDIDLE
						--e.tics = -1
						e.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						evt.sonic = P_SpawnMobj(-65*FRACUNIT, 320*FRACUNIT, 400*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * 340
						s.scale = FRACUNIT
						s.noidlebored = true
						s.sprite2 = SPR2_SHIT
						s.tics = -1
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						s.landed = false
					end
					if evt.ftimer > 1
						evt.eggman.sprite = SPR_MASK
						evt.sonic.sprite2 = SPR2_SHIT
					end
					
					if evt.sonic and evt.sonic.valid
						local s = evt.sonic
						if not P_IsObjectOnGround(s)
							s.spritexscale = $-FRACUNIT/100
							s.spriteyscale = $+FRACUNIT/100
						else
							if not s.landed
								S_StartSound(nil, sfx_s3k5d)
								P_StartQuake(2*FRACUNIT, 2)
								for i = 1,16
									local dust = P_SpawnMobj(s.x, s.y, s.z, MT_DUMMY)
									dust.angle = ANGLE_90 + ANG1* (22*(i-1))
									dust.state = S_CDUST1
									P_InstaThrust(dust, dust.angle, 10*FRACUNIT)
									dust.color = SKINCOLOR_WHITE
									dust.scale = FRACUNIT/2
								end
								s.spritexscale = FRACUNIT*3/2
								s.spriteyscale = FRACUNIT*2/3
								s.landed = true
							end
						end
						if s.landed
							s.spritexscale = s.spritexscale + (FRACUNIT - s.spritexscale)/5
							s.spriteyscale = s.spriteyscale + (FRACUNIT - s.spriteyscale)/5
						end
					end
					
					if evt.ftimer == 80 return true end
				end
			},
	[2] = {"text", "MASKED Eggman", "Ladies and gentlemen, welcome to the\x82 ".."Blue Mistery Tips Corner!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[3] = {"text", "MASKED Eggman", "Presented to you by your astonishingly beautiful host for today, MASKED Eggman!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[4] = {"text", "MASKED Eggman", "Who is also in crippling debt after spending all of my savings on rolling for virtual women.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[5] = {"function",
				function(evt, btl)
					boxflip = false
					if evt.ftimer == 1
						S_StartSound(nil, sfx_nxbump)
					end
					if evt.ftimer == 50
						return true
					end
				end
			},
	[6] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[7] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[8] = {"text", "MASKED Eggman", "Don't feel so bad, Sonic! It's not that uncommon to die to Stage 2!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[9] = {"text", "MASKED Eggman", "Especially when it introduces a gimmick as crazy as a meter system for the boss! Such big boy attacks!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[10] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[11] = {"text", "Sonic", "Yeah, not too keen about Amy getting knocked out in one fell swoop. Not really the day I expected to have.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[12] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[13] = {"text", "MASKED Eggman", "Man, tell me about it! Unlike Silver, this guy may not be a base stat powerhouse right off the bat, but he can sure rack up a bad time for you!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[14] = {"text", "MASKED Eggman", "For starters, his base agility is off the charts, so you'd better buff your party's agility right away if you want attacks to land!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[15] = {"text", "MASKED Eggman", "However, you aren't the only ones getting stronger! Shadow's got plenty of tools to keep him from getting left in the dust as well!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[16] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						evt.sonic.spearset = $ or {} 
						itsmeteringtime = true
						meterx = -100
						//TIPS_pullImage(20, 10, "H_SMETER", "left", false) --100, 60 is center
					end
					if evt.sonic and evt.sonic.valid
						local target = evt.sonic
						if evt.ftimer >= 1 and evt.ftimer <= 8
							S_StartSound(nil, sfx_prloop)
							for i = 1, 2
								local ang = ANGLE_90 + ANG1* (47*((evt.ftimer-40)-2+i*20))
								local tgtx = target.x + P_RandomRange(30, 80)*cos(ang)
								local tgty = target.y + P_RandomRange(30, 80)*sin(ang)
								local spear = P_SpawnMobj(tgtx, tgty, target.z+((i*3)*P_RandomRange(1, 20)*FRACUNIT), MT_DUMMY)
								spear.sprite = SPR_CSPP
								spear.angle = ang
								spear.scale = FRACUNIT/2
								spear.frame = FF_FULLBRIGHT|A
								spear.tics = -1
								P_InstaThrust(spear, spear.angle, 10*FRACUNIT)
								target.spearset[#target.spearset+1] = spear
								local warp = P_SpawnMobj(spear.x, spear.y, spear.z, MT_DUMMY)
								warp.state = S_CHAOSCONTROL1
								warp.scale = FRACUNIT/2
								warp.destscale = FRACUNIT
							end
						end
						if target.spearset and #target.spearset
							for i = 1, #target.spearset do
								if target.spearset[i] and target.spearset[i].valid
									local spear = target.spearset[i]
									spear.momx = $*80/100
									spear.momy = $*80/100
									spear.momz = $*80/100
									spear.angle = R_PointToAngle2(spear.x, spear.y, target.x, target.y)
								end
							end
						end
					end
					if evt.ftimer == 50
						return true
					end
				end
			},
	[17] = {"text", "MASKED Eggman", "Between his Spear Set, his Supercharge move, and most of all, his meter, he certainly benefits from playing the long game!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[18] = {"function",
				function(evt, btl)
					meter = meter + 70
					//despawn spears if spear target dies
					/*local mo = evt.sonic
					if mo.spearset and #mo.spearset
						for i = 1, #mo.spearset do
							if mo.spearset[i] and mo.spearset[i].valid
								local spear = mo.spearset[i]
								P_RemoveMobj(spear)
							end
						end
					end*/
					boxflip = false
					return true
				end
			},
	[19] = {"text", "Sonic", "It's annoying, if I have anything to say about it! Even worse, he resists fire! Way to waste my time, jerk!", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[20] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[21] = {"text", "Sonic", "All I can do is just buff agility and use my one Strike move to do anything decent!", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[22] = {"function",
				function(evt, btl)
					meter = meter + 70
					boxflip = true
					return true
				end
			},
	[23] = {"text", "MASKED Eggman", "Well..... you could try your luck with Inferno Link.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[24] = {"function",
				function(evt, btl)
					meter = meter + 70
					boxflip = false
					return true
				end
			},
	[25] = {"text", "Sonic", "And why would I- oh. Because of the crit rate. What was it, again... 40%?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[26] = {"function",
				function(evt, btl)
					meter = meter + 70
					boxflip = true
					return true
				end
			},
	[27] = {"text", "MASKED Eggman", "Correctamundo! If you land a critical, you won't need to care about his resistance to fire!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[28] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[29] = {"text", "MASKED Eggman", "But if you're tired of getting hit in two shots, I suggest you use that EP for Tails' Faultless Reinforcement.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[30] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[31] = {"text", "MASKED Eggman", "While Shadow can't regularly knock you down in the first place, the physical barriers can screw up his Slash attacks!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[32] = {"function",
				function(evt, btl)
					meter = meter + 70
					boxflip = false
					return true
				end
			},
	[33] = {"text", "Sonic", "That sure won't stop him when he ruins our whole team with Chaos Spears! What was it called, Ultimate Chaos Spear? The one that needed 1 bar of meter?", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[34] = {"function",
				function(evt, btl)
					meter = meter + 70
					boxflip = true
					return true
				end
			},
	[35] = {"text", "MASKED Eggman", "You'll have to constantly keep his Magic buffs in check, then! Remember, his Supercharge buffs all of his stats, even Crit Rate!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[36] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[37] = {"text", "MASKED Eggman", "Plus, it gets him closer to that terrifying Chaos Control as well! Once he has 3 levels of meter, he'll use it immediately on his turn!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[38] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[39] = {"text", "MASKED Eggman", "If you can't remove those buffs in time, you're in a dangerous spot! End of the line!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[40] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[41] = {"text", "MASKED Eggman", "Don't neglect on debuffing his Magic and Physical attack, they could mean life or death in the face of his powerful meter skills!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[42] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[43] = {"text", "MASKED Eggman", "That said, his Luck's not the greatest, so Hamamon V2 will have a better chance of removing his buffs!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[44] = {"function",
				function(evt, btl)
					meter = meter + 70
					boxflip = false
					return true
				end
			},
	[45] = {"text", "Sonic", "Yeah, but that's not stopping him from dodging a bunch of our attacks. We got a boss with a weakness we can attack, and he just weaves through it!", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[46] = {"function",
				function(evt, btl)
					meter = meter + 70
					boxflip = true
					return true
				end
			},
	[47] = {"text", "MASKED Eggman", "That is indeed true! Thus, you'll have to hold off on Amy's Panta Rhei in favor of Garuverse Alter as an attacking move, due to its infinite accuracy!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[48] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[49] = {"text", "MASKED Eggman", "Number two, just keep on buffing your defense! Shadow doesn't have any means of taking those away, so prepare yourself to the fullest!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[50] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[51] = {"text", "MASKED Eggman", "Number three, debuffs, and more debuffs! Defense, Physical attack, Magic, debuff them all!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[52] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[53] = {"text", "MASKED Eggman", "You'll need to make sure you're prepped in order to survive his Chaos Control. And that means reducing his Magic and Physical attack as much as possible before it happens!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[54] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[55] = {"text", "MASKED Eggman", "And be quick about it! The moment Shadow obtains 3 levels of his meter, he immediately uses Chaos Control on his turn! Yikes! Cheater!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[56] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[57] = {"text", "MASKED Eggman", "Plus, if his HP gets low, he'll get desperate and use Supercharge a lot more often if he hasn't used Chaos Control yet!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[58] = {"function",
				function(evt, btl)
					meter = meter + 70
					boxflip = false
					return true
				end
			},
	[59] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[60] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[61] = {"text", "Sonic", "Okay, what the HECK is that meter still doing here?? And why in the world has it been charging?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[62] = {"function", function(evt, btl) meter = meter + 70 return true end},
	[63] = {"text", "Sonic", "Putting aside the fact that Shadow isn't even HERE, there's no way to charge that meter unle-", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[64] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						S_StartSound(nil, sfx_bchaos)
					end
					if evt.ftimer == 41
						S_StartSound(nil, sfx_bcntrl)
					end
					if evt.ftimer == 56
						if evt.eggman and evt.eggman.valid
							evt.eggman.flags = $|MF_NOTHINK
						end
						P_LinedefExecute(1002)
						S_StartSound(nil, sfx_tmstop)
						S_PauseMusic()
					end
					if evt.ftimer == 120
						boxflip = true
						return true
					end
				end
			},
	[65] = {"text", "Shadow", "You absolute fool. You dumb cretin. You bumbling idiot.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[66] = {"function", --zamn
				function(evt, btl)
					if evt.ftimer == 1
						evt.shadow = P_SpawnMobj(192*FRACUNIT, 320*FRACUNIT, evt.eggman.z+20*FRACUNIT, MT_PFIGHTER)
						local s = evt.shadow
						s.skin = "shadow"
						s.color = SKINCOLOR_BLACK
						s.angle = ANG1 * 225
						s.momz = 10*FRACUNIT
						s.cutscene = true
						s.sh_snaptime = 6
						s.state = S_PLAY_FALL
						s.renderflags = $|RF_NOCOLORMAPS|RF_FULLBRIGHT
						local e = P_SpawnMobj(s.x, s.y, s.z, MT_DUMMY)
						e.skin = s.skin
						e.sprite = s.sprite
						e.angle = s.angle
						e.frame = s.frame & FF_FRAMEMASK | FF_TRANS60
						e.fuse = TICRATE/7
						e.scale = s.scale
						e.destscale = s.scale*6
						e.scalespeed = s.scale/2
						e.sprite2 = s.sprite2
						e.color = SKINCOLOR_CYAN
						e.colorized = true
						e.tics = -1
						S_StartSound(nil, sfx_csnap)
						s.state = S_SHADOW_WARP1
					end
					if evt.shadow and evt.shadow.valid and (evt.shadow.sh_snaptime)
						local s = evt.shadow 
						s.sh_snaptime = $-1
						s.flags2 = $|MF2_DONTDRAW
					else
						local s = evt.shadow 
						s.flags, s.flags2 = $ & ~MF_NOGRAVITY, $ & ~MF2_DONTDRAW
						s.state = S_PLAY_FALL
					end
					if P_IsObjectOnGround(evt.shadow)
						evt.shadow.state = S_PLAY_STND
					end
					if evt.ftimer == 60
						evt.shadow.noidle = true
						return true
					end
				end
			},
	[67] = {"text", "Shadow", "As you've figured out, my meter fills up when I Supercharge, deal damage, or take damage.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[68] = {"text", "Shadow", "So naturally, I've been poking myself with this thumbtack. Free meter. You wish you were this smart.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[69] = {"text", "Shadow", "Now then... I'll make this quick.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[70] = {"text", "Shadow", "You. Player.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[71] = {"text", "Shadow", "Allow me to give you some REAL tips on how to fight me.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[72] = {"text", "Shadow", "First of all: DON'T buff your agility. There's no point, since you're not the ultimate life form. You won't be able to use it properly.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[73] = {"text", "Shadow", "Second of all: DON'T use Wind skills against me. Honestly, why bother? It's probably gonna miss at least once, so might as well not even try. Save yourself the shame.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[74] = {"text", "Shadow", "And lastly, this one's a big one:", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[75] = {"text", "Shadow", "\x82".."DON'T guard when I use Chaos Control. \x80It's really mean, and it hurts my feelings. Seriously. I warned you.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[76] = {"text", "Shadow", "...That's all. Remember to follow MY advice. These fools don't know the first thing about me.", nil, nil, nil, {"H_SHAD1", SKINCOLOR_BLACK}},
	[77] = {"function", --zamn
				function(evt, btl)
					if evt.ftimer == 1
						local s = evt.shadow
						s.skin = "shadow"
						s.color = SKINCOLOR_BLACK
						s.angle = ANG1 * 225
						s.momz = 30*FRACUNIT
						s.cutscene = true
						s.sh_snaptime = 6
						s.state = S_PLAY_FALL
						local e = P_SpawnMobj(s.x, s.y, s.z, MT_DUMMY)
						e.skin = s.skin
						e.sprite = s.sprite
						e.angle = s.angle
						e.frame = s.frame & FF_FRAMEMASK | FF_TRANS60
						e.fuse = TICRATE/7
						e.scale = s.scale
						e.destscale = s.scale*6
						e.scalespeed = s.scale/2
						e.sprite2 = s.sprite2
						e.color = SKINCOLOR_CYAN
						e.colorized = true
						e.tics = -1
						S_StartSound(nil, sfx_csnap)
						s.state = S_SHADOW_WARP1
					end
					if evt.shadow and evt.shadow.valid and (evt.shadow.sh_snaptime)
						local s = evt.shadow 
						s.sh_snaptime = $-1
						s.flags2 = $|MF2_DONTDRAW
					else
						local s = evt.shadow 
						s.flags2 = $|MF2_DONTDRAW
						s.state = S_PLAY_FALL
					end
					if evt.ftimer == 60
						S_ResumeMusic()
						P_LinedefExecute(1003)
						itsmeteringtime = false
						boxflip = false
						if evt.eggman and evt.eggman.valid
							evt.eggman.flags = $ & ~MF_NOTHINK
						end
						return true
					end
				end
			},
	[78] = {"text", "Sonic", "-ss I either hit him, or he hits me. Or uses Supercharge.", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[79] = {"text", "Sonic", "...Oh, it's gone.", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[80] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},	
	[81] = {"text", "MASKED Eggman", "Musta been a bug. I'll give the creator of this mod a good piece of my mind later!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[82] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[83] = {"text", "Sonic", "Right... well, I think that's all I need to know.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[84] = {"text", "Sonic", "In fact, maybe a bit too much information. Hard to remember all of this.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[85] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},	
	[86] = {"text", "MASKED Eggman", "Well, if you always need a reminder, just die! In fact, I encourage you! Let's get a streak going!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[87] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},		
	[88] = {"text", "Sonic", "Go away.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[89] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[90] = {"text", "MASKED Eggman", "Boo, you're no fun.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[91] = {"text", "MASKED Eggman", "Still, as always, I hope you taste defeat again so that you may experience my handsome visage once again! Ta-ta!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[92] = {"function",
				function(evt, btl)
					boxflip = false
					if evt.ftimer == 1
						for i = 1, 5
							local warp = P_SpawnMobj(evt.eggman.x, evt.eggman.y, evt.eggman.z+40*FRACUNIT, MT_DUMMY)
							warp.state = S_CHAOSCONTROL1
							warp.scale = FRACUNIT
							warp.destscale = FRACUNIT*2
						end
						S_StartSound(nil, sfx_prloop)
					end
					if evt.ftimer == 20
						evt.eggman.flags2 = $|MF2_DONTDRAW
					end
					if evt.ftimer == 60
						S_StartSound(nil, sfx_contin)
						tipsfinished = true
						return true
					end
				end
			},
}

//shadow meter gag for tips corner 2
hud.add(function(v)
	if gamemap != 14 return end
	if not itsmeteringtime return end
	v.drawScaled((meterx+15)*FRACUNIT, 47*FRACUNIT, FRACUNIT*3/4, v.cachePatch("H_SMETER"), V_SNAPTOLEFT|V_SNAPTOTOP)
	v.drawFill(meterx-2, 49, metermax/4, 10, 15|V_SNAPTOLEFT|V_SNAPTOTOP) //background layer
	v.drawFill(meterx, 47, metermax/4, 10, barcolor|V_SNAPTOLEFT|V_SNAPTOTOP)
	v.drawFill(meterx, 47, meterdisplay*5/4, 10, metercolor|V_SNAPTOLEFT|V_SNAPTOTOP)
	v.drawString(meterx+120, 36, "Meter level: " + meterlevel, V_REDMAP|V_SNAPTOLEFT|V_SNAPTOTOP, "thin-right")
end)
addHook("ThinkFrame", function()
	//shadow's super meter
	if gamemap != 14 return end
	if not itsmeteringtime return end
	if (meter*100)/metermax > meterdisplay and meterdisplay*5/4 < metermax/4
		meterdisplay = meterdisplay+2
	end
	if meterdisplay*5/4 >= metermax/4 and meterlevel < 2
		for i = 1,2
			S_StartSound(nil, sfx_s3kcas)
		end
		meter = meter - metermax
		meterdisplay = 0
		meterlevel = $+1
	elseif meterdisplay*5/4 >= metermax/4 and meterlevel >= 2 and not fullmeter
		for i = 1,2
			S_StartSound(nil, sfx_s3kcas)
		end
		meterlevel = 3
		metercolor = 47
		meter = metermax
		fullmeter = true
	end
	if meterlevel == 0
		barcolor = 7
		metercolor = 98
	elseif meterlevel == 1
		barcolor = 98
		metercolor = 73
	elseif meterlevel == 2
		barcolor = 73
		metercolor = 38
	elseif meterlevel == 3
		if metercolor > 38 and leveltime%2 == 0
			barcolor = 73
			metercolor = $-1
		end
	end
	meterx = meterx + (20 - meterx)/10
end)

addHook("MapLoad", function()
	if not server return end
	metermax = 500 //125 on display
	meterdisplay = 0 //also know as the meter percentage
	meter = 0
	barcolor = 7
	metercolor = 132
	meterlevel = 0
	fullmeter = false
	meterx = -200
	itsmeteringtime = false
	firefield = false
end)

//main points: reinforcement tempting but inferno link is nice for ep gain, thinker targets low hp, heal plenty during pyro boundary
//also, pyro boundary demonstration and they explain but cant hear over the music so they shout the explanation

eventList["ev_tipscorner_3"] = {
	[1] = {"function", --zamn
				function(evt, btl)
					if evt.ftimer == 1
						S_ChangeMusic("tips")
						S_StartSound(nil, sfx_s3k51)
						boxflip = true
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.eggman = P_SpawnMobj(448*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local e = evt.eggman
						e.skin = "eggman"
						e.color = SKINCOLOR_RED
						e.angle = ANG1 * 200
						e.scale = FRACUNIT
						--e.noidlebored = true
						e.state = S_MASKEDIDLE
						--e.tics = -1
						e.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						evt.sonic = P_SpawnMobj(-65*FRACUNIT, 320*FRACUNIT, 400*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * 340
						s.scale = FRACUNIT
						s.noidlebored = true
						s.sprite2 = SPR2_SHIT
						s.tics = -1
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						s.landed = false
						for mo in mobjs.iterate()
							if mo.type == MT_PFIGHTER and not mo.cutscene
								mo.hp = mo.maxhp
								mo.sp = mo.maxsp
							end
						end
					end
					if evt.ftimer > 1
						evt.eggman.sprite = SPR_MASK
						evt.sonic.sprite2 = SPR2_SHIT
					end
					
					if evt.sonic and evt.sonic.valid
						local s = evt.sonic
						if not P_IsObjectOnGround(s)
							s.spritexscale = $-FRACUNIT/100
							s.spriteyscale = $+FRACUNIT/100
						else
							if not s.landed
								S_StartSound(nil, sfx_s3k5d)
								P_StartQuake(2*FRACUNIT, 2)
								for i = 1,16
									local dust = P_SpawnMobj(s.x, s.y, s.z, MT_DUMMY)
									dust.angle = ANGLE_90 + ANG1* (22*(i-1))
									dust.state = S_CDUST1
									P_InstaThrust(dust, dust.angle, 10*FRACUNIT)
									dust.color = SKINCOLOR_WHITE
									dust.scale = FRACUNIT/2
								end
								s.spritexscale = FRACUNIT*3/2
								s.spriteyscale = FRACUNIT*2/3
								s.landed = true
							end
						end
						if s.landed
							s.spritexscale = s.spritexscale + (FRACUNIT - s.spritexscale)/5
							s.spriteyscale = s.spriteyscale + (FRACUNIT - s.spriteyscale)/5
						end
					end
					
					if evt.ftimer == 80 return true end
				end
			},
	[2] = {"text", "MASKED Eggman", "Ladies and gentlemen, welcome to the\x82 ".."Blue Mistery Tips Corner!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[3] = {"text", "MASKED Eggman", "Presented to you by your amazingly attractive host for today, MASKED Eggman!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[4] = {"text", "MASKED Eggman", "Who is also a certified Discord moderator on 70 alternate accounts.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[5] = {"function",
				function(evt, btl)
					boxflip = false
					if evt.ftimer == 1
						S_StartSound(nil, sfx_nxbump)
					end
					if evt.ftimer == 50
						return true
					end
				end
			},
	[6] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[7] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[8] = {"text", "MASKED Eggman", "Come on, Sonic, she's weak to Fire, for crying out loud! How'd you fumble this one?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[9] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},	
	[10] = {"text", "Sonic", "I dunno, maybe catching on fire or getting frozen every turn has something to do with it.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[11] = {"text", "Sonic", "Seriously, what was the creator thinking!? And to make it worse, he locked Me Patra off from Amy! What's with the moveset nerf!?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[12] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[13] = {"text", "MASKED Eggman", "There's our main point, it seems! \x82Status effects! And even more status effects!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[14] = {"text", "MASKED Eggman", "It's evident that Blaze doesn't have the damage firepower that Silver and Shadow hold, but she more than makes up for it with her status ailments!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[15] = {"text", "MASKED Eggman", "Firstly, there's the good ol' Tentarafoo we all know and love, with a SUPER high chance of inflicting dizzy!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[16] = {"text", "MASKED Eggman", "But we also have Blaze's new Combustion Strike and Orbs of Eruption, both having decent chances of putting the burn on you!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[17] = {"text", "MASKED Eggman", "Combine that with her persona's Bufudyne and Mabufula, you've got yourself a solid Fire & Ice special! Isn't that cool? Or hot?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[18] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[19] = {"text", "Sonic", "...Now that I think about it, does Blaze actually have any ways to buff her own stats?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[20] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[21] = {"text", "MASKED Eggman", "Keen memory, my good sir! Blaze, in fact,\x82 does not have any ways of buffing herself!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[22] = {"text", "MASKED Eggman", "However, she has ways of\x82 removing debuffs from herself, via Dekunda\x82 and Pyro Boundary!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[23] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[24] = {"text", "Sonic", "Wait, Dekunda!? She didn't have that! Not in the base game, at least! I'm filing a complaint!", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[25] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[26] = {"text", "MASKED Eggman", "Relax, buddy! She rarely uses it, so feel free to Stardrop and Mamakakanda all you like regardless!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[27] = {"text", "MASKED Eggman", "After all, her thinker's gonna be too busy to bat an eye on her debuffs when she's busy singling out your characters!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[28] = {"text", "MASKED Eggman", "Unlike the other bosses, Blaze has the power of breaking the 4th wall! On her turn,\x82 she'll detect any players low on HP, and exclusively \x82target them! Yikes!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[29] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[30] = {"text", "Sonic", "...I think my brain's getting tired of complaining about all these gimmicks. The only thing good about this is her lack of damage.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[31] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[32] = {"text", "MASKED Eggman", "Hey, you can't forget about Knuckles! Remember, Knuckles is weak to Ice, so no matter how strong his endurance is, it's a free 1More for Blaze if she lands it!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[33] = {"text", "MASKED Eggman", "And if you couldn't get enough of the 1Mores, if she lands a freeze on you, she'll get a technical hit when she uses either Fire OR Slash attacks!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[34] = {"text", "MASKED Eggman", "Your fire resistance won't be able to save you when that happens!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[35] = {"text", "MASKED Eggman", "If you're sick of all the 1Mores, then using Hyper Mode on vulnerable allies is a valid strategy!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[36] = {"text", "MASKED Eggman", "But... I wouldn't activate Faultless Reinforcement right off the bat...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[37] = {"text", "MASKED Eggman", "Remember how I said she was weak to fire, Sonic?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[38] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[39] = {"text", "Sonic", "Yeah, what are you trying to...", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[40] = {"text", "Sonic", "...Oh. \x82Inferno Link.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[41] = {"text", "Sonic", "Wait, but why use it before Faultless Reinforcement?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[42] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[43] = {"text", "MASKED Eggman", "To put it bluntly: \x82More EP gain! Yippee!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[44] = {"text", "MASKED Eggman", "You've most likely seen it for yourself, but using Faultless Reinforcement halts EP gain for a while due to all the Hyper Modes in effect.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[45] = {"text", "MASKED Eggman", "But with Inferno Link, you'll be able to not only deal crazy damage, but also refill your EP at astonishingly high rates, especially with a boss WEAK to Fire!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[46] = {"text", "MASKED Eggman", "Doing that will allow you to get your EP back in no time, and with plenty of Magic buffs too!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[47] = {"text", "MASKED Eggman", "And THEN you'll be able to use Faultless Reinforcement to your heart's content, and bring on the pain! There won't be anything to stop you at that point!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[48] = {"function", function(evt, btl) S_FadeOutStopMusic(2*MUSICRATE) return true end},	
	[49] = {"text", "MASKED Eggman", "...Well, except for...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[50] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[51] = {"text", "Sonic", "...Why do I have a bad feeling about this?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[52] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						S_StartSound(nil, sfx_fire1)
						P_StartQuake(5*FRACUNIT, 3)
						P_LinedefExecute(1007)
					end
					
					if evt.ftimer == 26
						S_StartSound(nil, sfx_fire1)
						P_StartQuake(10*FRACUNIT, 3)
						P_LinedefExecute(1007)
					end
					
					if evt.ftimer == 51
						S_ChangeMusic("stg3c")
						P_LinedefExecute(1008)
						S_StartSound(nil, sfx_megi5)
						S_StartSound(nil, sfx_fire2)
						S_StartSound(nil, sfx_fire1)
						P_StartQuake(15*FRACUNIT, 45)
						firefield = true
						
						for i = 1, 20
							local x = P_RandomRange(-100, 100)*FRACUNIT
							local y = P_RandomRange(-100, 100)*FRACUNIT
							local boom = P_SpawnMobj(x, y, 0, MT_BOSSEXPLODE)
							boom.scale = FRACUNIT*3
							boom.state = S_PFIRE1
							
							local flame = P_SpawnMobj(evt.sonic.x + x, evt.sonic.y + y, evt.sonic.floorz, MT_FLAME)
							flame.tics = -1
							flame.scale = FRACUNIT*P_RandomRange(1, 3)
							flame.frame = $|FF_FULLBRIGHT
							
							local flame2 = P_SpawnMobj(evt.eggman.x + x, evt.eggman.y + y, evt.eggman.floorz, MT_FLAME)
							flame2.tics = -1
							flame2.scale = FRACUNIT*P_RandomRange(1, 3)
							flame2.frame = $|FF_FULLBRIGHT
							
							for i = 1, 3
								local smol = P_SpawnMobj(evt.sonic.x + x, evt.sonic.y + y, 0, MT_DUMMY)
								smol.state = S_CYBRAKDEMONNAPALMFLAME_FLY1
								smol.scale = FRACUNIT
								smol.momx = P_RandomRange(-20, 20)*FRACUNIT
								smol.momy = P_RandomRange(-20, 20)*FRACUNIT
								smol.momz = P_RandomRange(10, 20)*FRACUNIT
								smol.fuse = P_RandomRange(20, 35)
							end
							
							for i = 1, 3
								local smol = P_SpawnMobj(evt.eggman.x + x, evt.eggman.y + y, 0, MT_DUMMY)
								smol.state = S_CYBRAKDEMONNAPALMFLAME_FLY1
								smol.scale = FRACUNIT
								smol.momx = P_RandomRange(-20, 20)*FRACUNIT
								smol.momy = P_RandomRange(-20, 20)*FRACUNIT
								smol.momz = P_RandomRange(10, 20)*FRACUNIT
								smol.fuse = P_RandomRange(20, 35)
							end
						end
						evt.sonic.state = S_PLAY_PAIN
					end
					
					if evt.ftimer == 131
						evt.sonic.state = S_PLAY_STND
						evt.sonic.sprite2 = SPR2_SHIT
						evt.sonic.tics = -1
						return true
					end
				end
			},
	[53] = {"text", "Sonic", "Is the music really necessary!?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[54] = {"function", function(evt, btl) boxflip = true return true end},
	[55] = {"text", "MASKED Eggman", "WHAAAAAT? SORRY, I CAN'T HEAR YOU OVER THE HEAVY METAL, WHAT DID YOU SAY??", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[56] = {"function", function(evt, btl) boxflip = false return true end},
	[57] = {"text", "Sonic", "I SAID IS THE MUSIC REALLY NECESSARY!?!?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[58] = {"function", function(evt, btl) boxflip = true return true end},
	[59] = {"text", "MASKED Eggman", "OH! DON'T BE LIKE THAT, SONIC! IT COMES WITH THE MOVE! YOU CAN'T HAVE ONE OR THE OTHER!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[60] = {"text", "MASKED Eggman", "THAT'S LIKE PEANUT BUTTER & JELLY SANDWICHES WITHOUT THE SANDWICH!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[61] = {"text", "MASKED Eggman", "NOW WHERE WAS I? OH, RIGHT! SAY HELLO TO \x82PYRO BOUNDARY\x80, LADIES AND GENTLEMEN!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[62] = {"text", "MASKED Eggman", "WHEN BLAZE REACHES A CERTAIN POINT IN HP, SHE'LL ACTIVATE THIS AND RESTORE HER HEALTH BACK TO 50%! UH OH!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[63] = {"function", function(evt, btl) boxflip = false return true end},
	[64] = {"text", "Sonic", "WHAT IS UP WITH THESE 2ND PHASES!? AND WHY CAN'T SHE DO THIS WHEN SHE'S ON OUR SIDE!?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[65] = {"text", "Sonic", "WAIT...", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[66] = {"function",
				function(evt, btl)
					if evt.ftimer == 40
						return true
					end
				end
			},
	[67] = {"text", "Sonic", "GAAAAHHHH OUR HP IS DECREASING!!!!!!! EGGMAN WHAT DID YOU DO?!?!?!", nil, nil, nil, {"H_SON8", SKINCOLOR_BLUE}},
	[68] = {"function", function(evt, btl) boxflip = true return true end},
	[69] = {"text", "MASKED Eggman", "HEY! THAT'S\x82 MASKED\x80 EGGMAN TO YOU! M-A-S-K-E-D EGGMAN! THAT WAS A VERY RUDE AND INSENSITIVE THING TO SAY, SONIC!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[70] = {"text", "MASKED Eggman", "HONESTLY, WE NEED TO HAVE A TALK ABOUT THE IMPORTANT DISTINCTIONS BETWEEN THE VARIED CHARACTERISTICS BETWEEN ME AND THAT OTHER PERSON WHO YOU KEEP SPEAKING OF, WHICH I OF COURSE HAVE NO RELATION TO IN ORDER TO AVOID SUCH STEREOTYPICAL AGGRESSIONS-", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[71] = {"function", function(evt, btl) boxflip = false return true end},
	[72] = {"text", "Sonic", "I DON'T CARE, JUST TURN THIS THING OFF!", nil, nil, nil, {"H_SON9", SKINCOLOR_BLUE}},
	[73] = {"function", function(evt, btl) boxflip = true return true end},
	[74] = {"text", "MASKED Eggman", "UNFORTUNATELY, I CAN'T QUITE DO THAT! PYRO BOUNDARY DOESN'T MERELY WEAR OFF, IT CAN ONLY DISSIPATE ONCE BLAZE IS DEFEATED!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[75] = {"text", "MASKED Eggman", "...OR UNTIL I'VE FINISHED MY EXPLANATION, WHICHEVER ONE COMES FIRST!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[76] = {"function", function(evt, btl) boxflip = false return true end},
	[77] = {"text", "Sonic", "WHATEVER, JUST FINISH IT! OUR HP'S RUNNING OUT!", nil, nil, nil, {"H_SON8", SKINCOLOR_BLUE}},
	[78] = {"function", function(evt, btl) boxflip = true return true end},
	[79] = {"text", "MASKED Eggman", "NOT JUST HP, BUT SP TOO!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[80] = {"text", "MASKED Eggman", "ALTHOUGH IT ISN'T AS FAST AS THE HP'S RATE, WITH THE SP DRAINING, YOU'LL HAVE TO THINK FAST IF YOU DON'T WANT TO RUN OUT OF OPTIONS!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[81] = {"text", "MASKED Eggman", "THAT WON'T BE AN EASY JOB THOUGH! AS I'VE MENTIONED BEFORE, BLAZE GETS RID OF ALL HER DEBUFFS WHEN PYRO BOUNDARY ACTIVATES!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[82] = {"text", "MASKED Eggman", "YOU'LL HAVE TO PUT 'EM BACK ON REALLY FAST IF YOU WANNA KEEP THE DAMAGE TRAIN ROLLING!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[83] = {"text", "MASKED Eggman", "ON THE FLIP SIDE, THIS IS A GREAT SITUATION FOR AMY'S\x82 PRAYER OF AFFECTION!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[84] = {"text", "MASKED Eggman", "I'M SURE YOU'RE WELL AWARE OF ITS ABILITY TO FULLY RESTORE HP AND SP, AS WELL AS REVIVE DEAD ALLIES!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[85] = {"text", "MASKED Eggman", "BUT IT ALSO GIVES REGENERATE 3 AS A PASSIVE, WHICH IS MORE IMPORTANT THAN YOU'D THINK IN THESE CONDITIONS!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[86] = {"text", "MASKED Eggman", "BE QUICK ABOUT IT, THOUGH! IF A PLAYER'S HP REACHES 1, THEY'LL BE MASSIVELY DEBUFFED IN ALL AREAS!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[87] = {"text", "MASKED Eggman", "THEY MIGHT AS WELL BE DEAD AT THAT POINT!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[88] = {"text", "MASKED Eggman", "HOWEVER, KEEP IN MIND!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[89] = {"text", "MASKED Eggman", "BLAZE STILL TARGETS PLAYERS WITH LOW HP, SO ALWAYS KEEP AN EYE ON THOSE IN NEED OF HEALING BEFORE IT'S TOO LATE TO SAVE THEM!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[90] = {"text", "MASKED Eggman", "NOT QUITE SURE HOW SHE DOES THAT, HONESTLY! MAYBE IT'S LIKE, SOME KIND OF EMPATHY THING WHERE SHE CAN ACCURATELY DEDUCE THE STATE OF OTHER PEOPLE BY SIMPLY LOOKING AT THEM, WOW, SHE'S SUCH A NICE PERS-", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[91] = {"function", function(evt, btl) boxflip = false return true end},
	[92] = {"text", "Sonic", "BLAHBLAHBLAH ARE YOU DONE YET!?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[93] = {"function", function(evt, btl) boxflip = true return true end},
	[94] = {"text", "MASKED Eggman", "OH, YEAH, HOLD ON.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[95] = {"function",
				function(evt, btl)
					if evt.ftimer == 20
						S_StartSound(nil, sfx_hamas2)
						firefield = false
						P_LinedefExecute(1010)
						S_FadeOutStopMusic(1*MUSICRATE)
					elseif evt.ftimer == 50
						boxflip = false
						return true
					end
				end
			},
	[96] = {"text", "Sonic", "Ugh...", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[97] = {"function", function(evt, btl) boxflip = true S_ChangeMusic("tips") return true end},
	[98] = {"text", "MASKED Eggman", "Phew! What a ride! As promised, though, that's the end of my explanation! That'll be all of me for this corner, folks!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[99] = {"text", "MASKED Eggman", "So as always, I hope you taste defeat again so that you may experience my handsome visage once again! Ta-ta!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[100] = {"function", --we scored 100! that's probably a bad thing
				function(evt, btl)
					boxflip = false
					local mo = evt.eggman
					if evt.ftimer < 50
						if evt.ftimer == 1 or evt.ftimer == 13 or evt.ftimer == 21 or evt.ftimer == 28 or evt.ftimer == 34 or evt.ftimer == 39 or evt.ftimer == 43 or evt.ftimer == 47
							S_StartSound(nil, sfx_spndsh)
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
							P_Thrust(fire1, 0, 5*fuckunit)
							fire1.angle = R_PointToAngle2(mo.x, mo.y, fire1.x, fire1.y)
							fire1.scale = firescale
							local fire2 = P_SpawnMobjFromMobj(mo, P_ReturnThrustX(mo.angle+FixedAngle(200*FRACUNIT), 20*FRACUNIT), P_ReturnThrustY(mo.angle+FixedAngle(200*FRACUNIT), 20*FRACUNIT), 0, MT_BLAZE_RUNFIRE)
							fire2.color = SKINCOLOR_BLAZING
							fire2.fuse = 20
							P_SetObjectMomZ(fire2, 2*fuckunit+fuckunit/2, false)
							fire2.momx = mo.momx*3/4
							fire2.momy = mo.momy*3/4
							P_Thrust(fire2, 0, 5*fuckunit)
							fire2.angle = R_PointToAngle2(mo.x, mo.y, fire2.x, fire2.y)
							fire2.scale = firescale
						end
						if evt.ftimer < 20
							firescale = FRACUNIT
						else
							P_StartQuake(2*FRACUNIT, 1)
							firescale = FRACUNIT*2
						end
						if evt.ftimer < 35
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
					if evt.ftimer >= 25 and evt.ftimer < 50
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
					if evt.ftimer == 50
						S_StartSound(nil, sfx_wind1)
						mo.momx = -40*FRACUNIT
						mo.momz = 30*FRACUNIT
						P_StartQuake(10*FRACUNIT, 2)
					end
					if evt.ftimer >= 50
						evt.eggman.rollangle = $ + 50*ANG1
					end
					if evt.ftimer == 120
						S_StartSound(nil, sfx_contin)
						tipsfinished = true
						return true
					end
				end
			},
}

addHook("MobjThinker", function(mo)
	if gamemap != 14 return end
	if mo.cutscene return end
	if firefield
		if leveltime%8 == 0
			if mo.hp > 1
				mo.hp = $-1
			end
		end
		if leveltime%16 == 0
			if mo.sp > 1
				mo.sp = $-1
			end
		end
	end
end, MT_PFIGHTER)

//main points: whittle down wave 1 and use to buff, check badnik weaknesses, use items
//also, talking badniks show up and pop quiz on random badniks weakness using options
--local badniks = {}

local badniknames = {
	"Markiplier", 
	"Bloopie",
	"Bob",
	"Darko",
	"Sky",
	"Xero",
	"CD Nazier",
	"Spectra",
	"zens159",
	"Goku",
	"Martha",
	"xxX_T0X1C_R1ZZ4RD_Xxx",
	"01000010 01100101 01101110",
	"Hinoko",
	"Elaine",
	"Raelie",
	"Dawn",
	"Veronica",
	"Haruka",
	"Billy",
	"Gojo",
	"Deez",
	"The One Piece",
	"Fthazzef",
	"Aigis Yore Gaei",
	"Light Yagami",
	"Rojo",
	"Titanium",
	"Edgephorica",
	"Jotaro Kujo",
	"DIO",
	"Neco-Arc",
	"Grounder",
	"E-102 Gamma",
	"The Piss Lord, Destroyer of Toilets",
	"The Night that Shines Bright"
}

--local badniknames2 = badniknames //badniknames table will have things removed for random sake, so badniknames2 preserves it

local badnikweaknesses = {
	"\x85".."Fire".."\x80",
	"\x87".."Strike".."\x80",
	"\x89".."Psi".."\x80",
	"\x82".."Electric".."\x80",
	"\x87".."Pierce".."\x80",
	"\x82".."Bless".."\x80",
	"\x8B".."Wind".."\x80"
}

--local badnikweaknesses2 = badnikweaknesses

/*local namenumbers = {1, 2, 3, 4, 5, 6} --placeholders
local weaknumbers = {1, 2, 3, 4, 5, 6} --placeholders*/

addHook("MapLoad", function()
	badniknames = {
		"Markiplier", 
		"Bloopie",
		"Bob",
		"Darko",
		"Sky",
		"Xero",
		"CD Nazier",
		"Spectra",
		"zens159",
		"Goku",
		"Martha",
		"xxX_T0X1C_R1ZZ4RD_Xxx",
		"01000010 01100101 01101110",
		"Hinoko",
		"Elaine",
		"Raelie",
		"Dawn",
		"Veronica",
		"Haruka",
		"Billy",
		"Gojo",
		"Deez",
		"The One Piece",
		"Fthazzef",
		"Aigis Yore Gaei",
		"Light Yagami",
		"Rojo",
		"Titanium",
		"Edgephorica",
		"Jotaro Kujo",
		"DIO",
		"Neco-Arc",
		"Grounder",
		"E-102 Gamma",
		"The Piss Lord, Destroyer of Toilets",
		"The Night that Shines Bright"
	}

	badnikweaknesses = {
		"\x85".."Fire".."\x80",
		"\x87".."Strike".."\x80",
		"\x89".."Psi".."\x80",
		"\x82".."Electric".."\x80",
		"\x87".."Pierce".."\x80",
		"\x82".."Bless".."\x80",
		"\x8B".."Wind".."\x80"
	}
end)

eventList["ev_tipscorner_4"] = {
	[1] = {"function", --zamn
				function(evt, btl)
					if evt.ftimer == 1
						evt.badniks = {}
						evt.badniktext = {}
						S_ChangeMusic("tips")
						S_StartSound(nil, sfx_s3k51)
						boxflip = true
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.eggman = P_SpawnMobj(448*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local e = evt.eggman
						e.skin = "eggman"
						e.color = SKINCOLOR_RED
						e.angle = ANG1 * 200
						e.scale = FRACUNIT
						--e.noidlebored = true
						e.state = S_MASKEDIDLE
						--e.tics = -1
						e.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						evt.sonic = P_SpawnMobj(-65*FRACUNIT, 320*FRACUNIT, 400*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * 340
						s.scale = FRACUNIT
						s.noidlebored = true
						s.sprite2 = SPR2_SHIT
						s.tics = -1
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						s.landed = false
					end
					if evt.ftimer > 1
						evt.eggman.sprite = SPR_MASK
						evt.sonic.sprite2 = SPR2_SHIT
					end
					
					if evt.sonic and evt.sonic.valid
						local s = evt.sonic
						if not P_IsObjectOnGround(s)
							s.spritexscale = $-FRACUNIT/100
							s.spriteyscale = $+FRACUNIT/100
						else
							if not s.landed
								S_StartSound(nil, sfx_s3k5d)
								P_StartQuake(2*FRACUNIT, 2)
								for i = 1,16
									local dust = P_SpawnMobj(s.x, s.y, s.z, MT_DUMMY)
									dust.angle = ANGLE_90 + ANG1* (22*(i-1))
									dust.state = S_CDUST1
									P_InstaThrust(dust, dust.angle, 10*FRACUNIT)
									dust.color = SKINCOLOR_WHITE
									dust.scale = FRACUNIT/2
								end
								s.spritexscale = FRACUNIT*3/2
								s.spriteyscale = FRACUNIT*2/3
								s.landed = true
							end
						end
						if s.landed
							s.spritexscale = s.spritexscale + (FRACUNIT - s.spritexscale)/5
							s.spriteyscale = s.spriteyscale + (FRACUNIT - s.spriteyscale)/5
						end
					end
					
					if evt.ftimer == 80 return true end
				end
			},
	[2] = {"text", "MASKED Eggman", "Ladies and gentlemen, welcome to the\x82 ".."Blue Mistery Tips Corner!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[3] = {"text", "MASKED Eggman", "Presented to you by your stupendously dazzingly host for today, MASKED Eggman!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[4] = {"text", "MASKED Eggman", "And lemme just tell you one thing.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[5] = {"text", "MASKED Eggman", "I HATE furries.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[6] = {"function",
				function(evt, btl)
					boxflip = false
					if evt.ftimer == 1
						S_StartSound(nil, sfx_nxbump)
					end
					if evt.ftimer == 50
						return true
					end
				end
			},
	[7] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[8] = {"function", function(evt, btl) boxflip = true return true end},
	[9] = {"text", "MASKED Eggman", "If there's anything to take out of this, at least you got past the halfway mark for Blue Mistery! Congrats!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[10] = {"function", function(evt, btl) boxflip = false return true end},
	[11] = {"text", "Sonic", "Touched.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[12] = {"text", "Sonic", "Seriously, though. What the heck? These badniks shouldn't be this tough. And what's with all the colors?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[13] = {"text", "Sonic", "I liked it better when my day was just 'jump on the badnik and poof!' Why does Eggman have to make this so complicated?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[14] = {"function", function(evt, btl) boxflip = true return true end},
	[15] = {"text", "MASKED Eggman", "...You sure it's this Eggman fellow who's behind this scheme?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[16] = {"function", function(evt, btl) boxflip = false return true end},
	[17] = {"text", "Sonic", "Don't give me that.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[18] = {"function", function(evt, btl) boxflip = true return true end},
	[19] = {"text", "MASKED Eggman", "Geez, buzzkill.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[20] = {"text", "MASKED Eggman", "Anyways! In order to effectively explain the nuances to this magnificant array of gimmicks...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[21] = {"text", "MASKED Eggman", "What better way than a practical course?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[22] = {"function", --badniks appear
				function(evt, btl)
					if evt.ftimer == 1
						evt.forbiddennum = {}
						/*evt.badniktext = {
							"Hey. My name's "..name..". I'm weak to "..weak..".",
							"Yo yo yo yo yo!!! Wazzaup, homie! The name's "..name..", and I'm weak to "..weak.."!!! Woo!",
							"Konnichiwa, dood. Watashi no name es "..name..", and mai weakunessu es "..weak.." desu.",
							"WHAT'S P0PP1N' MY ELITE Y0U CAN CA11 ME "..name..", AND I AM WEAK 2 "..weak.."!1!11!",
							"Hello! My name is "..name..", and I am weak to "..weak.."! I sincerely hope we can get along! ...Wait, I'm supposed to kill you?",
							"hey bro how u doing my names "..name.." and im weak to "..weak..". yea.",
							"Hahahahaha! Bow before me! You shall remember me as "..name..", for my weakness is none other than "..weak.."! Wahahaha!",
							"Yeehaw pardner! Y'all varmits better know me as "..name..", an' I reckon ya dun know that mah weakness is "..weak..", cuz it is!",
							"oh........hi........my name's "..name..".....i guess........ and my weakness is "..weak..".....im so sad..........",
							"Top o' da morning to you, lad! The name's "..name..", and I do appear to be weak to "..weak.."! Good heavens!",
							"OMG HI!!! I'm "..name..", and I'm, like, literally soooo weak to "..weak..", like, it's tooootally crazy.",
							"Ahoy, matey! Ya' landlubbers best know me as "..name.."! Me weakness be "..weak.."! Together, we will conquer the seas!",
							"Beep boop bop. I am robot. Designation is known as "..name..". Weakness is set to "..weak..". Beep."
						}
						evt.badniks = {}*/
					end
					/*if evt.badniktext and #evt.badniktext
						print(#evt.badniktext)
					end*/
					/*if evt.forbiddennum and #evt.forbiddennum
						for i = 1, #evt.forbiddennum
							print(evt.forbiddennum[i])
						end
					end*/
					for i = 1, 6
						if evt.ftimer == 1 + (i*5)
							local tgtx = -150 + 100*i
							local tgty = 400
							local enemystates = {S_JETGLOOK1, S_JETBLOOK1, 	S_ROBOHOOD_LOOK, S_FACESTABBER_STND1, S_CCOMMAND1, S_CACO_LOOK}
							local b = P_SpawnMobj(tgtx*FRACUNIT, tgty*FRACUNIT, 200*FRACUNIT, MT_PFIGHTER)
							b.angle = ANG1 * (260 - i*15)
							b.scale = FRACUNIT
							b.state = enemystates[i]
							if i == 4
								b.sprite = SPR_CBFS
								b.tics = -1
							elseif i == 5
								b.sprite = SPR_CCOM
								b.tics = -1
							end
							b.emeraldmode = i
							b.cutscene = true
							/*namenumbers[i] = P_RandomRange(1, #badniknames)
							table.remove(badniknames, namenumbers[i])
							weaknumbers[i] = P_RandomRange(1, #badnikweaknesses)
							table.remove(badnikweaknesses, weaknumbers[i])*/
							
							//assign names and weaknesses
							local namenumber = P_RandomRange(1, #badniknames)
							b.badnikname = badniknames[namenumber]
							table.remove(badniknames, namenumber)
							local weaknumber = P_RandomRange(1, #badnikweaknesses)
							b.badnikweakness = badnikweaknesses[weaknumber]
							table.remove(badnikweaknesses, weaknumber)
							evt.badniks[#evt.badniks+1] = b
							/*print(badniknames2[namenumbers[i]])
							print(badnikweaknesses2[weaknumbers[i]])*/
							/*print(b.badnikname)
							print(b.badnikweakness)*/
							for i = 1, 64
								local color = SKINCOLOR_RED
								if i%2 color = SKINCOLOR_BLACK end

								local x, y, z = b.x+P_RandomRange(-50, 50)*FRACUNIT, b.y+P_RandomRange(-50, 50)*FRACUNIT, b.z+P_RandomRange(-50, 50)*FRACUNIT
								local particle = P_SpawnMobj(x, y, z, MT_DUMMY)
								particle.color = color
								particle.frame = A
								particle.tics = 100
								particle.destscale = 0
								particle.momz = P_RandomRange(1, 10)*FRACUNIT
							end
							
							//assign text and textcolors
							local textcolors = {"\x8B", "\x89", "\x8C", "\x8A", "\x87", "\x85"}
							b.textcolor = textcolors[i]
							local name = tostring(b.textcolor) + tostring(b.badnikname) + "\x80"
							local weak = tostring(b.badnikweakness)
							--if i == 1
								evt.badniktext = {
									"Hey. My name's "..name..". I'm weak to "..weak..".",
									"Yo yo yo yo yo!!! Wazzaup, homie! The name's "..name..", and I'm weak to "..weak.."!!! Woo!",
									"Konnichiwa, dood. Watashi no name es "..name..", and mai weakunessu es "..weak.." desu.",
									"WHAT'S P0PP1N' MY ELITE Y0U CAN CA11 ME "..name..", AND I AM WEAK 2 "..weak.."!1!11!",
									"Hello! My name is "..name..", and I am weak to "..weak.."! I sincerely hope we can get along!",
									"hey bro how u doing my names "..name.." and im weak to "..weak..". yea.",
									"Hahahahaha! Bow before me! You shall remember me as "..name..", for my weakness is none other than "..weak.."! Wahahaha!",
									"Yeehaw pardner! Y'all varmits better know me as "..name..", an' I reckon ya dun know that mah weakness is "..weak.."!",
									"oh........hi........my name's "..name..".....i guess........ and my weakness is "..weak..".....im so sad..........",
									"Top o' da morning to you, lad! The name's "..name..", and I do appear to be weak to "..weak.."! Good heavens!",
									"OMG HI!!! I'm "..name..", and I'm, like, literally soooo weak to "..weak..", like, it's tooootally crazy.",
									"Ahoy, matey! Ya' landlubbers best know me as "..name.."! Me weakness be "..weak.."! Together, we conquer the seas!",
									"Beep boop bop. I am robot. Designation is known as "..name..". Weakness is set to "..weak..". Beep."
								}
							--end
							if i > 1 //remove already used texts
								for k,v in ipairs(evt.forbiddennum)
									--print("die")
									table.remove(evt.badniktext, v)
								end
							end
							b.textnumber = P_RandomRange(1, #evt.badniktext)
							evt.forbiddennum[#evt.forbiddennum+1] = b.textnumber
							b.text = evt.badniktext[b.textnumber]
							table.remove(evt.badniktext, b.textnumber)
						end
					end
					if evt.ftimer == 50
						return true
					end
				end
			},
	[23] = {"text", "MASKED Eggman", "Give a warm welcome to our guests for today!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[24] = {"text", "MASKED Eggman", "Each of them complete with their own traits, weaknesses, resistances, everything! Say hello, sweeties!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[25] = {"function",
				function(evt, btl)
					if evt.ftimer == 5
						//update the event text
						--local textnumber = P_RandomRange(1, #evt.badniktext)
						eventList["ev_tipscorner_4"][26] = {"text", "Jetty Gunner", evt.badniks[1].text, nil, nil, nil, nil}
						--table.remove(evt.badniktext, textnumber)
						evt.badniks[1].yapping = true
					end
					if evt.ftimer == 15
						return true
					end
				end
			},
	[26] = {"text", "Jetty Gunner", "Hello. My name is \x83".."Markiplier".."\x80. I'm weak to ".."Fire"..".", nil, nil, nil, nil},
	[27] = {"function", function(evt, btl) evt.badniks[1].yapping = false return true end},
	[28] = {"text", "MASKED Eggman", "Indeed! If you get hit by a\x8B green\x80 badnik, your EP gauge will decrease by quite the amount!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[29] = {"text", "MASKED Eggman", "Either take 'em out fast or be hasty with your EP if you don't want it stolen!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[30] = {"function",
				function(evt, btl)
					if evt.ftimer == 5
						--local textnumber = P_RandomRange(1, #evt.badniktext)
						eventList["ev_tipscorner_4"][31] = {"text", "Jetty Bomber", evt.badniks[2].text, nil, nil, nil, nil}
						--table.remove(evt.badniktext, textnumber)
						evt.badniks[2].yapping = true
					end
					if evt.ftimer == 15
						return true
					end
				end
			},
	[31] = {"text", "Jetty Bomber", "Hello. My name is \x83".."Markiplier".."\x80. I'm weak to ".."Fire"..".", nil, nil, nil, nil},
	[32] = {"function", function(evt, btl) evt.badniks[2].yapping = false return true end},
	[33] = {"text", "MASKED Eggman", "Indubitably! If you get hit by a\x89 purple\x80 badnik, you'll lose 50 SP!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[34] = {"text", "MASKED Eggman", "Not quite a direct annoyance, but you'll find yourself needing to refill at some point!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[35] = {"text", "MASKED Eggman", "By the way, this Jetty Bomber gets confused for the Jetty Gunner a lot because of the colors, so think carefully before assuming a weakness!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[36] = {"function",
				function(evt, btl)
					if evt.ftimer == 5
						--local textnumber = P_RandomRange(1, #evt.badniktext)
						eventList["ev_tipscorner_4"][37] = {"text", "Robo Hood", evt.badniks[3].text, nil, nil, nil, nil}
						--table.remove(evt.badniktext, textnumber)
						evt.badniks[3].yapping = true
					end
					if evt.ftimer == 15
						return true
					end
				end
			},
	[37] = {"text", "Robo Hood", "Hello. My name is \x83".."Markiplier".."\x80. I'm weak to ".."Fire"..".", nil, nil, nil, nil},
	[38] = {"function", function(evt, btl) evt.badniks[3].yapping = false return true end},
	[39] = {"text", "MASKED Eggman", "Most certainly! If you get hit by a\x8C blue\x80 badnik, you'll be randomly inflicted with one of four status effects!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[40] = {"text", "MASKED Eggman", "You'll either get a bad case of Burn, Freeze, Poison, or Dizzy. Even worse, I think it overwrites Hyper Mode too! Be careful!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[41] = {"function",
				function(evt, btl)
					if evt.ftimer == 5
						--local textnumber = P_RandomRange(1, #evt.badniktext)
						eventList["ev_tipscorner_4"][42] = {"text", "FaceStabber", evt.badniks[4].text, nil, nil, nil, nil}
						--table.remove(evt.badniktext, textnumber)
						evt.badniks[4].yapping = true
					end
					if evt.ftimer == 15
						return true
					end
				end
			},
	[42] = {"text", "FaceStabber", "Hello. My name is \x83".."Markiplier".."\x80. I'm weak to ".."Fire"..".", nil, nil, nil, nil},
	[43] = {"function", function(evt, btl) evt.badniks[4].yapping = false return true end},
	[44] = {"text", "MASKED Eggman", "Fo' shizzle! If you get hit by a\x8A light blue\x80 badnik, your status increases will be nullified, like a Dekaja!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[45] = {"text", "MASKED Eggman", "Gah!! That can ruin your day! Let's hope you either have enough agility buffs to be able to dodge it, or enough attack buffs to take it down first!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[46] = {"function",
				function(evt, btl)
					if evt.ftimer == 5
						--local textnumber = P_RandomRange(1, #evt.badniktext)
						eventList["ev_tipscorner_4"][47] = {"text", "Crawla Commander", evt.badniks[5].text, nil, nil, nil, nil}
						--table.remove(evt.badniktext, textnumber)
						evt.badniks[5].yapping = true
					end
					if evt.ftimer == 15
						return true
					end
				end
			},
	[47] = {"text", "Crawla Commander", "Hello. My name is \x83".."Markiplier".."\x80. I'm weak to ".."Fire"..".", nil, nil, nil, nil},
	[48] = {"function", function(evt, btl) evt.badniks[5].yapping = false return true end},
	[49] = {"text", "MASKED Eggman", "But of course! If you get hit by an\x87 orange\x80 badnik, you'll have either a Garuverse or Zioverse field cast on you!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[50] = {"text", "MASKED Eggman", "As a reminder, if you have a Zioverse field, that means you take partial damage when teammates are hit with single target attacks! Fun!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[51] = {"function",
				function(evt, btl)
					if evt.ftimer == 5
						--local textnumber = P_RandomRange(1, #evt.badniktext)
						eventList["ev_tipscorner_4"][52] = {"text", "Cacolantern", evt.badniks[6].text, nil, nil, nil, nil}
						--table.remove(evt.badniktext, textnumber)
						evt.badniks[6].yapping = true
					end
					if evt.ftimer == 15
						evt.numberlist = {}
						return true
					end
				end
			},
	[52] = {"text", "Cacolantern", "Hello. My name is \x83".."Markiplier".."\x80. I'm weak to ".."Fire"..".", nil, nil, nil, nil},
	[53] = {"function", function(evt, btl) evt.badniks[6].yapping = false return true end},
	[54] = {"text", "MASKED Eggman", "Absolutely! If you get hit by an\x85 red\x80 badnik, one of your stat buffs will get randomized!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[55] = {"text", "MASKED Eggman", "For example, your Defense buffs get reduced to -2 stages, or Agility buffs go up to 3 stages! It's a coin flip on whether this is good for you or not!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[56] = {"text", "MASKED Eggman", "And some of you might be wondering...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[57] = {"text", "MASKED Eggman", "'Isn't there another color that's missing?'", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[58] = {"text", "MASKED Eggman", "And to that, I say...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[59] = {"text", "MASKED Eggman", "I have no idea what you're talking about!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[60] = {"function", function(evt, btl) boxflip = false return true end},
	[61] = {"text", "Sonic", "(So sleepy... when's he gonna stop talking to himself...)", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[62] = {"function", function(evt, btl) boxflip = true S_FadeOutStopMusic(2*MUSICRATE) return true end},
	[63] = {"text", "MASKED Eggman", "Now then, without further ado, let's begin!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[64] = {"function", function(evt, btl) boxflip = false return true end},
	[65] = {"text", "Sonic", "Zz...huh?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[66] = {"function", function(evt, btl) boxflip = true return true end},
	[67] = {"text", "MASKED Eggman", "Sonic, I'm so flattered that you've taken the time to get to know all these wonderful individuals!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[68] = {"text", "MASKED Eggman", "Thus, I've decided to give you an amazing pop quiz for you to show off how well you remembered all of that!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[69] = {"function", function(evt, btl) boxflip = false return true end},
	[70] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[71] = {"text", "Sonic", "Well that's very kind of you but I'll have to respectfully declin-", nil, nil, nil, {"H_SON6", SKINCOLOR_BLUE}},
	[72] = {"function", function(evt, btl) boxflip = true return true end},
	[73] = {"text", "MASKED Eggman", "And if you get a question wrong there will be consequences.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[74] = {"function", 
				function(evt, btl) 
					//super unnecessary convoluted way to create choices, tldr; evt.badniknums indicate the relevant badniks for those 3 questions
					//evt.numberlist is so evt.badniknums dont roll the same number
					//evt.choicetable will be used in the updated event, and will have badnik info added to it by random
					//evt.choicepool will have 1 correct answer, and 2 random wrong answers, and will be added randomly into choicetable
					//also awkward timer spacing cuz im scared things implode if it happens on the same tic
					if evt.ftimer == 1
						evt.score = 0
						evt.numberlist = {1, 2, 3, 4, 5, 6}
						evt.choicetable = {}
						evt.choicepool = {}
						local num = P_RandomRange(1, #evt.numberlist)
						evt.badniknum1 = evt.numberlist[num]
						table.remove(evt.numberlist, num)
					end
					if evt.ftimer == 5
						local num = P_RandomRange(1, #evt.numberlist)
						evt.badniknum2 = evt.numberlist[num]
						table.remove(evt.numberlist, num)
					end
					if evt.ftimer == 10
						local num = P_RandomRange(1, #evt.numberlist)
						evt.badniknum3 = evt.numberlist[num]
						table.remove(evt.numberlist, num)
						
						//lets add the choices now!
						//make a table of the wrong answers to randomly add onto the options
						local wrongbadniks = copyTable(evt.badniks)
						for k,v in ipairs(wrongbadniks)
							if v == evt.badniks[evt.badniknum1]
								table.remove(wrongbadniks, k)
							end
						end
						//add 1 wrong answer
						local wrongnum = P_RandomRange(1, #wrongbadniks)
						evt.choicepool[#evt.choicepool+1] = wrongbadniks[wrongnum]
						table.remove(wrongbadniks, wrongnum)
						//lets add another wrong answer! yay!
						local wrongnum2 = P_RandomRange(1, #wrongbadniks)
						evt.choicepool[#evt.choicepool+1] = wrongbadniks[wrongnum2]
						table.remove(wrongbadniks, wrongnum2)
						//add the right answer
						evt.choicepool[#evt.choicepool+1] = evt.badniks[evt.badniknum1]
					end
					if evt.ftimer == 15
						//and now we take a random one from the pool and bring it to the choice table
						//and yes im doing this cuz i dont have another way of randomizing a table if anyones reading this please yell the solution at me im so idiot
						local poolnum = P_RandomRange(1, #evt.choicepool)
						evt.choicetable[#evt.choicetable+1] = evt.choicepool[poolnum]
						table.remove(evt.choicepool, poolnum)
					end
					if evt.ftimer == 16
						//more awkward timer spacing even though im pretty sure itd still work on the same tic
						local poolnum = P_RandomRange(1, #evt.choicepool)
						evt.choicetable[#evt.choicetable+1] = evt.choicepool[poolnum]
						table.remove(evt.choicepool, poolnum)
					end
					if evt.ftimer == 17
						//hi hows it going
						local poolnum = P_RandomRange(1, #evt.choicepool)
						evt.choicetable[#evt.choicetable+1] = evt.choicepool[poolnum]
						table.remove(evt.choicepool, poolnum)
					end
					//remember the choices in evt.choicetable are actual badniks
					if evt.ftimer == 40
						S_ChangeMusic("boss3") 
						//insert question stuff here
						local textcolors = {"\x8B", "\x89", "\x8C", "\x8A", "\x87", "\x85"}
						local colornames = {"green", "purple", "blue", "light blue", "orange", "red"}
						local color = tostring(textcolors[evt.badniknum1]) + tostring(colornames[evt.badniknum1])
						local weak = tostring(evt.badniks[evt.badniknum1].badnikweakness)
						eventList["ev_tipscorner_4"][76] = {"text", "MASKED Eggman", "Question #1: What was the name of the "..color.." badnik?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
						eventList["ev_tipscorner_4"][79] = {"text", "Sonic", "(Whatever. The "..color.." badnik.\x80 If I remember correctly, I think it was weak to "..weak..". So, its name should be...)", {{tostring(evt.choicetable[1].badnikname), 80}, {tostring(evt.choicetable[2].badnikname), 80}, {tostring(evt.choicetable[3].badnikname), 80}}, nil, nil, {"H_SON12", SKINCOLOR_BLUE}}
						return true 
					end
				end
			},
	[75] = {"text", "MASKED Eggman", "Let's begin! Here comes question one!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[76] = {"text", "MASKED Eggman", "Question #1: What was the name of the green badnik?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[77] = {"function", function(evt, btl) boxflip = false return true end},
	[78] = {"text", "Sonic", "(I didn't sign up for this...)", nil, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},
	[79] = {"text", "Sonic", "(Whatever. The green badnik. If I remember correctly, I think it was weak to Fire. So its name should be...)", {{"...I dunno.", 80}, {"I got nothin.", 80}}, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},
	[80] = {"function", 
				function(evt, btl)
					boxflip = true 
					if evt.choicetable[evt.choice] == evt.badniks[evt.badniknum1]
						evt.score = evt.score + 1
						/*print("CORRECT!!! :)")
					else
						print("WRONG")*/
					end
					return true 
				end
			},
	[81] = {"text", "MASKED Eggman", "Interesting! Oh yeah, I forgot to tell you! Your score will be revealed at the end of the quiz!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[82] = {"text", "MASKED Eggman", "Let's see if you can get everything correct in the end! Onto the next question!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[83] = {"function", 
				function(evt, btl) 
					if evt.ftimer == 1
						evt.choicetable = {}
						evt.choicepool = {}
						
						//lets add the choices now!
						//make a table of the wrong answers to randomly add onto the options
						local wrongbadniks = copyTable(evt.badniks)
						for k,v in ipairs(wrongbadniks)
							if v == evt.badniks[evt.badniknum2]
								table.remove(wrongbadniks, k)
							end
						end
						
						//add 1 wrong answer
						local wrongnum = P_RandomRange(1, #wrongbadniks)
						evt.choicepool[#evt.choicepool+1] = wrongbadniks[wrongnum]
						table.remove(wrongbadniks, wrongnum)
						
						//lets add another wrong answer! yay!
						local wrongnum2 = P_RandomRange(1, #wrongbadniks)
						evt.choicepool[#evt.choicepool+1] = wrongbadniks[wrongnum2]
						table.remove(wrongbadniks, wrongnum2)
						
						//add the right answer
						evt.choicepool[#evt.choicepool+1] = evt.badniks[evt.badniknum2]

						//okay i kinda have no choice but to do this in the same tic now so if it works it works but im too lazy to change the last function
						//anyways add these
						local poolnum = P_RandomRange(1, #evt.choicepool)
						evt.choicetable[#evt.choicetable+1] = evt.choicepool[poolnum]
						table.remove(evt.choicepool, poolnum)
						
						local poolnum2 = P_RandomRange(1, #evt.choicepool)
						evt.choicetable[#evt.choicetable+1] = evt.choicepool[poolnum2]
						table.remove(evt.choicepool, poolnum2)
						
						local poolnum3 = P_RandomRange(1, #evt.choicepool)
						evt.choicetable[#evt.choicetable+1] = evt.choicepool[poolnum3]
						table.remove(evt.choicepool, poolnum3)
					end
					//remember the choices in evt.choicetable are actual badniks
					if evt.ftimer == 40
						//insert question stuff here
						local textcolors = {"\x8B", "\x89", "\x8C", "\x8A", "\x87", "\x85"}
						local colornames = {"green", "purple", "blue", "light blue", "orange", "red"}
						local color = tostring(textcolors[evt.badniknum2]) + tostring(colornames[evt.badniknum2])
						local name = tostring(evt.badniks[evt.badniknum2].badnikname)
						eventList["ev_tipscorner_4"][84] = {"text", "MASKED Eggman", "Question #2: What element is "..name.." weak to?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
						eventList["ev_tipscorner_4"][86] = {"text", "Sonic", "("..name.."? The "..color.."\x80 one? Let's see... I think "..name.."'s weakness was...)", {{tostring(evt.choicetable[1].badnikweakness), 87}, {tostring(evt.choicetable[2].badnikweakness), 87}, {tostring(evt.choicetable[3].badnikweakness), 87}}, nil, nil, {"H_SON12", SKINCOLOR_BLUE}}
						return true 
					end
				end
			},
	[84] = {"text", "MASKED Eggman", "Question #2: What element is Markiplier weak to?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[85] = {"function", function(evt, btl) boxflip = false return true end},
	[86] = {"text", "Sonic", "(Markiplier? The green one? Let's see... I think its weakness was...)", {{"...I dunno.", 87}, {"I got nothin.", 87}}, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},
	[87] = {"function", 
				function(evt, btl)
					boxflip = true 
					if evt.choicetable[evt.choice] == evt.badniks[evt.badniknum2]
						evt.score = evt.score + 1
						/*print("CORRECT!!! :)")
					else
						print("WRONG")*/
					end
					return true 
				end
			},
	[88] = {"text", "MASKED Eggman", "Is that so! Only two more questions to go! Let's see if you can answer this one!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[89] = {"function", 
				function(evt, btl) 
					if evt.ftimer == 1
						evt.choicetable = {}
						evt.choicepool = {}
						
						//lets add the choices now!
						//make a table of the wrong answers to randomly add onto the options
						local wrongbadniks = copyTable(evt.badniks)
						for k,v in ipairs(wrongbadniks)
							if v == evt.badniks[evt.badniknum3]
								table.remove(wrongbadniks, k)
							end
						end
						
						//add 1 wrong answer
						local wrongnum = P_RandomRange(1, #wrongbadniks)
						evt.choicepool[#evt.choicepool+1] = wrongbadniks[wrongnum]
						table.remove(wrongbadniks, wrongnum)
						
						//lets add another wrong answer! yay!
						local wrongnum2 = P_RandomRange(1, #wrongbadniks)
						evt.choicepool[#evt.choicepool+1] = wrongbadniks[wrongnum2]
						table.remove(wrongbadniks, wrongnum2)
						
						//add the right answer
						evt.choicepool[#evt.choicepool+1] = evt.badniks[evt.badniknum3]

						//okay i kinda have no choice but to do this in the same tic now so if it works it works but im too lazy to change the last function
						//anyways add these
						local poolnum = P_RandomRange(1, #evt.choicepool)
						evt.choicetable[#evt.choicetable+1] = evt.choicepool[poolnum]
						table.remove(evt.choicepool, poolnum)
						
						local poolnum2 = P_RandomRange(1, #evt.choicepool)
						evt.choicetable[#evt.choicetable+1] = evt.choicepool[poolnum2]
						table.remove(evt.choicepool, poolnum2)
						
						local poolnum3 = P_RandomRange(1, #evt.choicepool)
						evt.choicetable[#evt.choicetable+1] = evt.choicepool[poolnum3]
						table.remove(evt.choicepool, poolnum3)
					end
					//remember the choices in evt.choicetable are actual badniks
					if evt.ftimer == 40
						//insert question stuff here
						local textcolors = {"\x8B", "\x89", "\x8C", "\x8A", "\x87", "\x85"}
						local colornames = {"Green", "Purple", "Blue", "Light blue", "Orange", "Red"}
						local weak = tostring(evt.badniks[evt.badniknum3].badnikweakness)
						local name = tostring(evt.badniks[evt.badniknum3].badnikname)
						eventList["ev_tipscorner_4"][90] = {"text", "MASKED Eggman", "Question #3: Which color is "..name.."?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
						eventList["ev_tipscorner_4"][92] = {"text", "Sonic", "(Which color is "..name.."...? I sorta remember that badnik being weak to "..weak..". Hmm...maybe its color was...)", {{tostring(colornames[evt.choicetable[1].emeraldmode]), 93}, {tostring(colornames[evt.choicetable[2].emeraldmode]), 93}, {tostring(colornames[evt.choicetable[3].emeraldmode]), 93}}, nil, nil, {"H_SON12", SKINCOLOR_BLUE}}
						return true 
					end
				end
			},
	[90] = {"text", "MASKED Eggman", "Question #3: Which color is Markiplier?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[91] = {"function", function(evt, btl) boxflip = false return true end},
	[92] = {"text", "Sonic", "(Which color is Markiplier...? I sorta remember that badnik being weak to Fire. Hmm...maybe its color was...)", {{"...I dunno.", 93}, {"I got nothin.", 93}}, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},
	[93] = {"function", 
				function(evt, btl)
					boxflip = true 
					if evt.choicetable[evt.choice] == evt.badniks[evt.badniknum3]
						evt.score = evt.score + 1
						/*print("CORRECT!!! :)")
					else
						print("WRONG")*/
					end
					return true 
				end
			},
	[94] = {"text", "MASKED Eggman", "Oho! We're already approaching the climactic finish! Here comes the final question!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[95] = {"function", function(evt, btl) if evt.ftimer == 40 return true end end},
	[96] = {"text", "MASKED Eggman", "Question #4: What's the square root of 4761?", {{"21", 97}, {"69", 97}, {"420", 97}, {"Why", 97}}, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[97] = {"text", "MASKED Eggman", "Okay, that last one doesn't count. Your score will be out of 3. Ready for the reveal, Sonic? I'm excited!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[98] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						S_FadeOutStopMusic(1*MUSICRATE)
					end
					if evt.ftimer < 40
						for s in sectors.iterate
							s.lightlevel = s.lightlevel - 1
						end
					end
					
					if evt.ftimer == 70
						return true
					end
				end
			},
	[99] = {"text", "MASKED Eggman", "Your score is...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[100] = {"function",
				function(evt, btl)
					if evt.ftimer == 60
						for p in players.iterate
							P_FlashPal(p, 1, 4)
						end
						
						if evt.score == 3
							for s in sectors.iterate
								s.lightlevel = 255
							end
							S_ChangeMusic("tips")
							S_StartSound(nil, sfx_nxbump)
							eventList["ev_tipscorner_4"][101] = {"text", "MASKED Eggman", "\x82".."3\x80 out of 3 questions answered correctly! Absolutely magnificent, Sonic! I knew you had it in you!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][102] = {"function", function(evt, btl) boxflip = false return true end}
							eventList["ev_tipscorner_4"][103] = {"text", "Sonic", "(I'm surprised. Still, glad that's over with. I'm ready to get the heck outta here before he does something stupid again.)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}}
							eventList["ev_tipscorner_4"][104] = {"function", function(evt, btl) boxflip = true return true end}
							eventList["ev_tipscorner_4"][105] = {"text", "MASKED Eggman", "For your reward, I'll let you in on a little secret!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][106] = {"text", "MASKED Eggman", "It's unrelated to Stage 4 in particular, but I assure you, it's quite a nifty trick!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][107] = {"text", "MASKED Eggman", "Did you know that you can bypass the restriction that prevents you from changing stages during a run?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][108] = {"text", "MASKED Eggman", "All you need to do is just activate debug cheats! How devious!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][109] = {"text", "MASKED Eggman", "With this power, you could skip ahead to Stage 6 by switching to MAP12 after starting a run, or retry a stage however many times you want!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][110] = {"function", function(evt, btl) boxflip = false return true end}
							eventList["ev_tipscorner_4"][111] = {"text", "Sonic", "Neat, I guess. Not sure if I'd use it all that much though.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}}
							eventList["ev_tipscorner_4"][112] = {"function", function(evt, btl) boxflip = true return true end}
							eventList["ev_tipscorner_4"][113] = {"text", "MASKED Eggman", "Not even if you wanted to use it to go to the locked extra stage?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][114] = {"function", function(evt, btl) boxflip = false return true end}
							eventList["ev_tipscorner_4"][115] = {"text", "Sonic", "-Huh?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}}
							eventList["ev_tipscorner_4"][116] = {"function", function(evt, btl) boxflip = true return true end}
							eventList["ev_tipscorner_4"][117] = {"text", "MASKED Eggman", "Kidding! You don't need debug cheats to get there!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][118] = {"function", function(evt, btl) boxflip = false return true end}
							eventList["ev_tipscorner_4"][119] = {"text", "Sonic", "Wait, you mean the-", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}}
							eventList["ev_tipscorner_4"][120] = {"function", function(evt, btl) boxflip = true return true end}
						else
							for s in sectors.iterate
								/*if s.tag == 6
									s.ceilingheight = 500*FRACUNIT
								end*/
								s.lightlevel = 140
							end
							S_StartSound(nil, sfx_litng4)
							if evt.score == 2
								eventList["ev_tipscorner_4"][101] = {"text", "MASKED Eggman", "\x82".."2\x80 out of 3 questions answered correctly. I'm utterly disappointed, Sonic.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
								eventList["ev_tipscorner_4"][102] = {"function", function(evt, btl) boxflip = false return true end}
								eventList["ev_tipscorner_4"][103] = {"text", "Sonic", "What!? Oh, come on, I only missed one! Can't I get some kind of credit?!?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}}
								eventList["ev_tipscorner_4"][104] = {"function", function(evt, btl) boxflip = true return true end}
								eventList["ev_tipscorner_4"][105] = {"text", "MASKED Eggman", "There will be no forgiveness. You've hurt the poor badnik's feelings.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							elseif evt.score == 1
								eventList["ev_tipscorner_4"][101] = {"text", "MASKED Eggman", "\x82".."1\x80 out of 3 questions answered correctly. Unacceptable on all fronts, Sonic.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
								eventList["ev_tipscorner_4"][102] = {"function", function(evt, btl) boxflip = false return true end}
								eventList["ev_tipscorner_4"][103] = {"text", "Sonic", "...I mean, I got one of them right. That's gotta count for something.", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}}
								eventList["ev_tipscorner_4"][104] = {"function", function(evt, btl) boxflip = true return true end}
								eventList["ev_tipscorner_4"][105] = {"text", "MASKED Eggman", "Your excuses disgust me. There is no saving you.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							elseif evt.score == 0
								eventList["ev_tipscorner_4"][101] = {"text", "MASKED Eggman", "\x82".."0\x80 out of 3 questions answered correctly. You useless garbage. Complete fodder. There are dust specks more worthy of my time, Sonic.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
								eventList["ev_tipscorner_4"][102] = {"function", function(evt, btl) boxflip = false return true end}
								eventList["ev_tipscorner_4"][103] = {"text", "Sonic", "Wait, what the heck!? Not even a single one!? That's gotta be rigged!", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}}
								eventList["ev_tipscorner_4"][104] = {"function", function(evt, btl) boxflip = true return true end}
								eventList["ev_tipscorner_4"][105] = {"text", "MASKED Eggman", "You are a fool to think that it was anything other than your narcissistic blindness and naivety.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							end
							eventList["ev_tipscorner_4"][106] = {"text", "MASKED Eggman", "Now, prepare to suffer the unyielding consequences.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][107] = {"function", function(evt, btl) boxflip = false return true end}
							eventList["ev_tipscorner_4"][108] = {"text", "Sonic", "A-And, uh...what kind of consequences are we talking about here?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}}
							eventList["ev_tipscorner_4"][109] = {"function", function(evt, btl) boxflip = true return true end}
							eventList["ev_tipscorner_4"][110] = {"text", "MASKED Eggman", "...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][111] = {"function",
																	function(evt, btl)
																		if evt.ftimer == 70
																			for s in sectors.iterate
																				s.lightlevel = 255
																				/*if s.tag == 6
																					s.ceilingheight = -100*FRACUNIT
																				end*/
																			end
																			S_ChangeMusic("tips")
																			return true
																		end
																	end}
							eventList["ev_tipscorner_4"][112] = {"text", "MASKED Eggman", "I dunno, I didn't think I'd get this far!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][113] = {"function", function(evt, btl) boxflip = false return true end}
							eventList["ev_tipscorner_4"][114] = {"text", "Sonic", "...Wow.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}}
							eventList["ev_tipscorner_4"][115] = {"function", function(evt, btl) boxflip = true return true end}
							eventList["ev_tipscorner_4"][116] = {"text", "MASKED Eggman", "Hey, if you want, I could think of something. Maybe a secret boss fight or two could-", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}}
							eventList["ev_tipscorner_4"][117] = {"function", function(evt, btl) boxflip = false return true end}
							eventList["ev_tipscorner_4"][118] = {"text", "Sonic", "Nope! I'm fine! I'm good! I'm great! Never been better! No worries! Carry on!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}}
							eventList["ev_tipscorner_4"][119] = {"function", function(evt, btl) D_requestIndex(1, 120) return true end}
						end
					end
					
					if evt.ftimer == 60
						return true
					end
				end
			},
	[101] = {"text", "MASKED Eggman", "\x82".."3\x80 out of 3 questions answered correctly! Absolutely magnificent, Sonic! I knew you had it in you!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[102] = {"function", function(evt, btl) boxflip = false return true end},
	[103] = {"text", "Sonic", "(I'm surprised. Still, glad that's over with. I'm ready to get the heck outta here before he does something stupid again.)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[104] = {"function", function(evt, btl) boxflip = true return true end},
	[105] = {"text", "MASKED Eggman", "For your reward, I'll let you in on a little secret!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[106] = {"text", "MASKED Eggman", "It's unrelated to Stage 4 in particular, but I assure you, it's quite a nifty trick!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[107] = {"text", "MASKED Eggman", "Did you know that you can bypass the restriction that prevents you from changing stages during a run?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[108] = {"text", "MASKED Eggman", "All you need to do is just activate debug cheats! How devious!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[109] = {"text", "MASKED Eggman", "With this power, you could skip ahead to Stage 6 by switching to MAP12 after starting a run, or retry a stage however many times you want!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[110] = {"function", function(evt, btl) boxflip = false return true end},
	[111] = {"text", "Sonic", "Neat, I guess. Not sure if I'd use it all that much though.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[112] = {"function", function(evt, btl) boxflip = true return true end},
	[113] = {"text", "MASKED Eggman", "Not even if you wanted to use it to go to the locked extra stage?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[114] = {"function", function(evt, btl) boxflip = false return true end},
	[115] = {"text", "Sonic", "-Huh?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[116] = {"function", function(evt, btl) boxflip = true return true end},
	[117] = {"text", "MASKED Eggman", "Kidding! You don't need debug cheats to get there!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[118] = {"function", function(evt, btl) boxflip = false return true end},
	[119] = {"text", "Sonic", "Wait, you mean the-", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[120] = {"function", function(evt, btl) boxflip = true return true end},
	[121] = {"text", "MASKED Eggman", "Anyways, back to the explanation! I wasn't finished with it yet!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[122] = {"text", "MASKED Eggman", "Being surrounded due to an ambush, it may be tough to stick to old habits of buffing at the start of the round!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[123] = {"text", "MASKED Eggman", "That's why I reccommend buffing only when you've reduced your load to only facing against\x82 one\x80 remaining badnik!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[124] = {"text", "MASKED Eggman", "What's that poor badnik gonna do against the four of you now? You'll be able to buff leisurely at that point!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[125] = {"text", "MASKED Eggman", "...Just make sure it's not a\x8A light blue\x80 badnik.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[126] = {"text", "MASKED Eggman", "Oh, and one more thing:\x82 Use gems!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[127] = {"text", "MASKED Eggman", "If you've got a lack of weakness coverage, or want to use a multi-target, utilize the newly acquired gems you accumulate by defeating badniks!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[128] = {"text", "MASKED Eggman", "They won't increase your item count in the resulting ranking tally, so spam them to your heart's content!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[129] = {"text", "MASKED Eggman", "Fun fact, all the badniks have weaknesses that your team is sure to have, so don't worry about any ice weaknesses or anything!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[130] = {"text", "MASKED Eggman", "Man, this stage is so easy! How'd you die in this one?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[131] = {"function", function(evt, btl) boxflip = false return true end},
	[132] = {"text", "Sonic", "Zzz...", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[133] = {"function", function(evt, btl) boxflip = true return true end},
	[134] = {"text", "MASKED Eggman", "Now then, let's begin the 2nd quiz!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[135] = {"function", function(evt, btl) boxflip = false return true end},
	[136] = {"text", "Sonic", "Gah!!! No more!", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[137] = {"function", function(evt, btl) boxflip = true return true end},
	[138] = {"text", "MASKED Eggman", "Good, you're awake.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[139] = {"text", "MASKED Eggman", "By the way, keep in mind. The badnik spawns? The weaknesses? The colors? They're ALL randomized! Everything!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[140] = {"text", "MASKED Eggman", "Even the names and questions in this tips corner are randomized, so no point in taking notes now!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[141] = {"text", "MASKED Eggman", "...Whew! Okay, that's all, for real! Quite an exposition dump, wouldn't you say?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[142] = {"function", function(evt, btl) boxflip = false return true end},
	[143] = {"text", "Sonic", "At least you admit it.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[144] = {"function", function(evt, btl) boxflip = true return true end},
	[145] = {"text", "MASKED Eggman", "That'll be all from me, then! As always, I hope you taste defeat again so that you may experience my handsome visage once again! Ta-ta!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[146] = {"function",
				function(evt, btl)
					local mo = evt.eggman
					boxflip = false
					if evt.ftimer == 1
						S_StartSound(nil, sfx_nskill)
					end
					if evt.badniks and #evt.badniks
						for i = 1, #evt.badniks
							if evt.badniks[i] and evt.badniks[i].valid
								local b = evt.badniks[i]
								b.flyawaynow = true
								b.flags = $|MF_NOCLIP|MF_NOCLIPHEIGHT
								local ang = ANG1*(60*(i-1))
								local tgtx = mo.x + 60*cos(mo.angle + ang)
								local tgty = mo.y + 60*sin(mo.angle + ang)
								b.momx = (tgtx - b.x)/10
								b.momy = (tgty - b.y)/10
								if evt.ftimer == 80
									b.momz = 12*FRACUNIT
								elseif evt.ftimer < 80
									b.momz = (mo.z - b.z)/10
								end
							end
						end
					end
					if evt.ftimer == 80
						S_StartSound(nil, sfx_jump)
						mo.momz = 12*FRACUNIT
						mo.flags = $|MF_NOGRAVITY
					end
					if evt.ftimer == 90
						S_StartSound(nil, sfx_putput)
					end
					if evt.ftimer == 150
						S_StartSound(nil, sfx_contin)
						tipsfinished = true
						return true
					end
				end
			},
}

addHook("MobjThinker", function(mo)
	if gamemap != 14 return end
	/*if not mo.cutscene 
		local evt = server.P_DialogueStatus[mo.control.P_party]
		if evt and evt.choice
			print(evt.choice)
		end
		return
	end*/
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
		if not mo.flyawaynow
			if mo.yapping
				mo.flags = $ & ~MF_NOGRAVITY
				if mo.z <= 200*FRACUNIT
					mo.momz = 5*FRACUNIT
				end
			else
				mo.flags = $|MF_NOGRAVITY
				mo.z = 200*FRACUNIT
			end
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
end, MT_PFIGHTER)

local eventtimer = 0
//main points: not much hp so focus on assault less on buffs/debuffs, counter fade, attack stat is important
//also, sonic is secretly phantom ruby'd eggman in disguise and constant bugs (eg dialogue looping & cut to player spawn)
eventList["ev_tipscorner_5"] = {
	[1] = {"function", --zamn
				function(evt, btl)
					if evt.ftimer == 1
						eventtimer = 0
						S_ChangeMusic("tips")
						S_StartSound(nil, sfx_s3k51)
						boxflip = true
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.eggman = P_SpawnMobj(448*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local e = evt.eggman
						e.skin = "eggman"
						e.color = SKINCOLOR_BLACK
						e.angle = ANG1 * 200
						e.scale = FRACUNIT
						--e.noidlebored = true
						e.state = S_MASKEDIDLE
						--e.tics = -1
						e.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						evt.sonic = P_SpawnMobj(-65*FRACUNIT, 320*FRACUNIT, 400*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * 340
						s.scale = FRACUNIT
						s.noidlebored = true
						s.sprite2 = SPR2_SHIT
						s.tics = -1
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						s.landed = false
					end
					if evt.ftimer > 1
						evt.eggman.sprite = SPR_MASK
						evt.sonic.sprite2 = SPR2_SHIT
					end
					if evt.sonic and evt.sonic.valid
						local s = evt.sonic
						
						if evt.ftimer == 20
							s.z = 90*FRACUNIT
							S_StartSound(nil, sfx_s3k5d)
							--P_StartQuake(2*FRACUNIT, 2)
							for i = 1,16
								local dust = P_SpawnMobj(s.x, s.y, s.z, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (22*(i-1))
								dust.state = S_CDUST1
								P_InstaThrust(dust, dust.angle, 10*FRACUNIT)
								dust.color = SKINCOLOR_WHITE
								dust.scale = FRACUNIT/2
							end
							s.spritexscale = FRACUNIT*3/2
							s.spriteyscale = FRACUNIT*2/3
							s.landed = true
						end
						if evt.ftimer == 40
							s.z = 150*FRACUNIT
							s.landed = false
						end
						if not P_IsObjectOnGround(s)
							s.spritexscale = $-FRACUNIT/100
							s.spriteyscale = $+FRACUNIT/100
						else
							if not s.landed
								S_StartSound(nil, sfx_s3k5d)
								P_StartQuake(2*FRACUNIT, 2)
								for i = 1,16
									local dust = P_SpawnMobj(s.x, s.y, s.z, MT_DUMMY)
									dust.angle = ANGLE_90 + ANG1* (22*(i-1))
									dust.state = S_CDUST1
									P_InstaThrust(dust, dust.angle, 10*FRACUNIT)
									dust.color = SKINCOLOR_WHITE
									dust.scale = FRACUNIT/2
								end
								s.spritexscale = FRACUNIT*3/2
								s.spriteyscale = FRACUNIT*2/3
								s.landed = true
							end
						end
						if s.landed
							s.spritexscale = s.spritexscale + (FRACUNIT - s.spritexscale)/5
							s.spriteyscale = s.spriteyscale + (FRACUNIT - s.spriteyscale)/5
						end
					end
					
					if evt.ftimer == 80 return true end
				end
			},
	[2] = {"text", "MASKED Eggman", "Ladies and gentlemen, welcome to the\x82 ".."Blue Mistery Tips Corner!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[3] = {"text", "MASKED Eggman", "Presented to you by your spectacularly spectacular host for today, MASKED Eggman!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[4] = {"text", "MASKED Eggman", "Tod y's Tips C rner is sponsored by HMS123311's taco stand! Man,  I could go for a ta o.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[5] = {"function",
				function(evt, btl)
					boxflip = false
					if evt.ftimer == 1
						S_StartSound(nil, sfx_nxbump)
					end
					if evt.ftimer == 50
						return true
					end
				end
			},
	[6] = {"text", "Sonic", "...?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[7] = {"function", function(evt, btl) boxflip = true return true end},
	[8] = {"text", "MASKED Eggman", "Hm? That was odd, I got cut off a bit there.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[9] = {"text", "MASKED Eggman", "Mic quality dropped? High ping? Muted by server? Eh, I'm sure it's nothing.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[10] = {"text", "MASKED Eggman", "Anyways, Sonic! Looks like you've gotten yourself into quite an unexpected pickle!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[11] = {"text", "MASKED Eggman", "A clash with Metal Sonic charged with the power of the Phantom Ruby, huh? That's a tough nut to crack!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[12] = {"function", function(evt, btl) boxflip = false return true end},
	[13] = {"text", "Sonic", "Tough, huh? Try impossible.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[14] = {"text", "Sonic", "It takes us ages to be able to even do half-decent damage to Metal Sonic with how he's throwing us around!", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},
	[15] = {"function", function(evt, btl) boxflip = true return true end},
	[16] = {"text", "MASKED Eggman", "Truly! Metal Sonic's got a lot of ways to disorient your gameplan!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[17] = {"text", "MASKED Eggman", "Let's go down the list of all these annoying things he can do!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[18] = {"text", "MASKED Eggman", "Number one:\x82 Mixing up your stat buffs!\x80 Rearrangement Type A randomizes both your party's and his buffs!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[19] = {"text", "MASKED Eggman", "This dumps all your efforts of buffing and debuffing down the drain! In some situations, it's a good idea to\x82 attacking over buffing!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[20] = {"function", function(evt, btl) boxflip = false return true end},
	[21] = {"text", "Sonic", "...And if he randomizes our stats into something terrible?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[22] = {"function", function(evt, btl) boxflip = true return true end},
	[23] = {"text", "MASKED Eggman", "Well that's a shame. Guess you'll have to buff it back up or use a Dekunda gem.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[24] = {"function", function(evt, btl) boxflip = false return true end},
	[25] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[26] = {"function", function(evt, btl) boxflip = true return true end},
	[27] = {"text", "<char_name>", "Number two:\x82 Stealing your EP!\x80 If you have at least 1 gauge of EP, he'll indulge himself by draining all of it and going into Hyper Mode!", nil, nil, nil, {"H_MASK1", SKINCOLOR_GREEN}},
	[28] = {"text", "<char_name>", "You don't want to hoard a bunch of EP here! The more EP gauges you have, the bigger his buffs!", nil, nil, nil, {"H_MASK1", SKINCOLOR_GREEN}},
	[29] = {"text", "<char_name>", "If you don't want to take any chances, try to make sure\x82 you always have less than one gauge\x80 when it's time for Metal Sonic's turn!", nil, nil, nil, {"H_MASK1", SKINCOLOR_GREEN}},
	[30] = {"text", "<char_name>", "But hey, if it ever does happen, know that\x82 he can't use it when he's in Hyper Mode himself!", nil, nil, nil, {"H_MASK1", SKINCOLOR_GREEN}},
	[31] = {"function", function(evt, btl) if evt.ftimer == 20 return true end end},
	[32] = {"text", "MASKED Eggman", "...What? Don't have a comment for that? No complaining this time?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[33] = {"function", function(evt, btl) boxflip = false return true end},
	[34] = {"text", "Sonic", "Oh, uh... nah, go on.", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[35] = {"function", function(evt, btl) boxflip = true return true end},
	[36] = {"text", "MASKED Eggman", "Number three:\x82 Swapping places with a teammate during an attack!\x80 Sometimes, when you try to hit him, he'll redirect that damage to a random ally! Rude!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[37] = {"text", "MASKED Eggman", "This triggers randomly, but there IS a way to tell if he's going use it!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[38] = {"function",
				function(evt, btl)
					evt.eggman.clone = P_SpawnMobj(evt.eggman.x, evt.eggman.y, evt.eggman.z, MT_PFIGHTER)
					local c = evt.eggman.clone
					c.skin = evt.eggman.skin
					c.cutscene = true
					c.timer = 0
					c.color = SKINCOLOR_BLUE
					c.colorized = true
					c.scale = evt.eggman.scale
					c.angle = evt.eggman.angle
					c.tics = -1
					c.blendmode = AST_ADD
					return true
				end
			},	
	[39] = {"text", "MASKED Eggman", "At the start of your turn, he'll suddenly be coated in\x8C blue\x80, only for it to fade away quickly.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[40] = {"text", "MASKED Eggman", "Kinda like how I did it just now!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[41] = {"text", "MASKED Eggman", "It's quite easy to miss, seeing as he's so far away when it's your turn, but that's exactly why you need to pay close attention during all times of the battle!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	/*[20] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},*/
	[42] = {"text", "Sonic", "Isn't it a bit camoflaugey having a blue character being coated blu-", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[43] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[44] = {"text", "Sonic", "Okay, what am I doing on this side?", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},
	[45] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[46] = {"text", "MASKED Eggman", "Hm? Now that you mention it, I'm feeling as if my offsets aren't displayed correctly either! So this is what it's like being offscreen!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[47] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},	
	[48] = {"text", "Sonic", "No, nonononono, hold up. This whole tips corner has been bugging out from the very beginning. What's the deal?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[49] = {"text", "Sonic", "It's like zens159 never even playtested this stupid cutscene and just called it a day!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[50] = {"text", "Sonic", "...Wait, who is zens159?", nil, nil, nil, {"H_SON2", SKINCOLOR_CYAN}},
	[51] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},	
	[52] = {"text", "MASKED Eggman", "Hm... it's possible that this may be due to the distorting nature of the Phantom Ruby! Perhaps it's mixing up our code!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[53] = {"text", "MASKED Eggman", "That Phantom Ruby has got to be somewhere around here! Sonic, did you perha-", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[54] = {"function",
				function(evt, btl)
					S_StopMusic(nil)
					eventtimer = 1
					return true
				end
			},	
}

addHook("ThinkFrame", function()
	if eventtimer > 0
		eventtimer = eventtimer + 1
		if eventtimer == 30
			D_startEvent(1, "ev_tipscorner_5_part2", true)
			eventtimer = 0
		end
	end
end)

eventList["ev_tipscorner_5_part2"] = {
	[1] = {"text", "Sonic", "Huh?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[2] = {"text", "Sonic", "What happened... Where am I...?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[3] = {"text", "Sonic", "Is this... the spawn point? For MAP14?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[4] = {"text", "Sonic", "Hey, Eggman? You there?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[5] = {"function", function(evt, btl) if evt.ftimer == 30 return true end end},
	[6] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[7] = {"text", "Sonic", "I guess it really is this Phantom Ruby then. Seems like it was a mistake using-", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[8] = {"function",
				function(evt, btl)
					for i = 1, 12
						if evt.ftimer == 2*i
							P_LinedefExecute(1015)
						end
					end
					if evt.ftimer == 24
						for p in players.iterate
							P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						S_StartSound(nil, sfx_shattr)
						S_StartSound(nil, sfx_shattr)
						S_ChangeMusic("tips")
						boxflip = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
					end
					if evt.ftimer == 40
						return true
					end
				end
			},
	[9] = {"text", "MASKED Eggman", "A clash with Metal Sonic charged with the power of the Phantom Ruby, huh? That's a tough nut to crack!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[10] = {"function", function(evt, btl) boxflip = false return true end},
	[11] = {"text", "Sonic", "Tough, huh? Try impossi-", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[12] = {"text", "Sonic", "(...No, wait, what? Hold on, I've been here before.)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[13] = {"text", "Sonic", "(Tch, I can't afford to beat around the bush. I'll get the information I came for, and get out of here quickly.)", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},
	[14] = {"function", function(evt, btl) boxflip = true return true end},
	[15] = {"text", "MASKED Eggman", "Something the matter, Sonic? I understand if you're nervous in the face of my aura, but do bear with me here.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[16] = {"function", function(evt, btl) boxflip = false return true end},
	[17] = {"text", "Sonic", "Give it to me straight, Eggman. What are Metal Sonic's weaknesses? How do you beat him?", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},
	[18] = {"function", function(evt, btl) boxflip = true return true end},
	[19] = {"text", "MASKED Eggman", "Wow, when did you become such a go-getter? Then I'll get right to his downsides, if you insist!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[20] = {"text", "MASKED Eggman", "Firstly, be careful of his\x82 Physical attack stat increases!\x80 Metal Sonic can prove to be a massive nuisance when he's got a lot of Strength under him!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[21] = {"text", "MASKED Eggman", "His hardest hitting moves are most certainly his Ruby upgraded\x82 Overdrive Dash and God's hand,\x80 both powerful Physical attacks!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[22] = {"text", "MASKED Eggman", "These are the easiest attacks to die from, so debuffing his Physical attack would definitely manage the damage.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[23] = {"text", "MASKED Eggman", "Secondly, keep in mind that Metal Sonic has\x82 extremely low HP and endurance, surprisingly!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[24] = {"text", "MASKED Eggman", "If you're feeling a lack of progress, try to forget about buffing and just dish out any sort of damage you can!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[25] = {"text", "MASKED Eggman", "Combine this with Metal Sonic's weakness to Lightning, Knuckles can achieve pretty good value despite Metal Sonic's Strike resistance!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[26] = {"text", "MASKED Eggman", "Weird, I thought Metal Sonic would be a lot more tanky, though. Must be because of the Ruby.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[27] = {"text", "MASKED Eggman", "Thirdly (Is that a word?),\x82 utilize Link hits!\x80 I'm obviously talking about Sonic's Flame Link, and perhaps even his Inferno link!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[28] = {"text", "MASKED Eggman", "Remember, Link hits will consistently deal the same amount of damage when it was initiated!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[29] = {"text", "MASKED Eggman", "That means no matter how high he raises his defense, Metal Sonic will still be dealt the same amount of Flame Link damage when hit!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[30] = {"text", "MASKED Eggman", "Just, uh, don't use it if someone like Amy gets it. If Metal Sonic ever swaps around your movesets.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[31] = {"function", function(evt, btl) boxflip = false return true end},
	[32] = {"text", "Sonic", "These are some pretty neat weaknesses, huh? I'll have to fix this once I get back, then.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[33] = {"function", function(evt, btl) S_FadeOutStopMusic(2*MUSICRATE) boxflip = true return true end},
	[34] = {"text", "MASKED Eggman", "Hm? Wuzzat mean?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[35] = {"function", function(evt, btl) boxflip = false return true end},
	[36] = {"text", "Sonic", "I might as well come clean, since I'm about to leave.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[37] = {"text", "Sonic", "Y'see, Eggman, I haven't entirely been honest with you up until now.", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[38] = {"text", "Sonic", "I'm sure you've felt the Phantom Ruby nearby ever since this started. I'd like you to see for yourself who its owner is!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[39] = {"function", //sonic turns into actual eggman
				function(evt, btl)
					for mo in mobjs.iterate()
						if mo.type == MT_PFIGHTER and mo.skin == "sonic"
							if evt.ftimer >= 1
							and evt.ftimer < 51
							and leveltime & 1
								local f = mo
								f.flags2 = $ & ~MF2_DONTDRAW
								local g = P_SpawnGhostMobj(f)
								f.flags2 = $|MF2_DONTDRAW
								g.fuse = 2
								g.renderflags = f.renderflags
								g.frame = f.frame
							end
							if evt.ftimer == 51
								P_LinedefExecute(1011)
								S_StartSound(nil, sfx_hamas2)
								local f = mo
								f.flags2 = $ & ~MF2_DONTDRAW
								f.state = S_PLAY_WAIT
								f.color = SKINCOLOR_RED
								f.skin = "eggman"
								--f.noidlebored = true
							end
						end
					end
					if evt.ftimer == 120
						boxflip = true
						return true
					end
				end
			},
	[40] = {"text", "MASKED Eggman", "No way.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[41] = {"function", function(evt, btl) S_ChangeMusic("batl1") boxflip = false return true end},
	[42] = {"text", "Eggman", "You better believe it, you naive fool! Dr. Ivo Robotnik is in the house!", nil, nil, nil, {"H_EGG3", SKINCOLOR_RED}},
	[43] = {"text", "Eggman", "You're quite the cheeky one, giving tips and tricks behind my back!", nil, nil, nil, {"H_EGG3", SKINCOLOR_RED}},
	[44] = {"text", "Eggman", "But I thought it was too pathetic to simply just shut it down, and that's where a brilliant idea sparked!", nil, nil, nil, {"H_EGG3", SKINCOLOR_RED}},
	[45] = {"text", "Eggman", "As you can see, I used the Phantom Ruby to infiltrate this funky little playdate disguised as that pesky rodent!", nil, nil, nil, {"H_EGG3", SKINCOLOR_RED}},
	[46] = {"text", "Eggman", "It's a good thing I took drama class in high school! My acting was truly divine, I must say!", nil, nil, nil, {"H_EGG3", SKINCOLOR_RED}},
	[47] = {"text", "Eggman", "And now that you've informed me of Metal Sonic's weak points, I'm gonna go back and give him the greatest makeover yet!", nil, nil, nil, {"H_EGG3", SKINCOLOR_RED}},
	[48] = {"text", "Eggman", "Get ready for Blue Mistery v2.0! The newest patch notes will blow your mind! Lightning resistance! Maxed out Strength! Everything!", nil, nil, nil, {"H_EGG3", SKINCOLOR_RED}},
	[49] = {"function", function(evt, btl) boxflip = true return true end},
	[50] = {"text", "MASKED Eggman", "Curses! What meaning will my advice hold now?! I should have known you'd be up to no good, mysterious stranger!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[51] = {"text", "MASKED Eggman", "I won't forgive you for this, person whom I have no association with whatsoever!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[52] = {"function", function(evt, btl) boxflip = false return true end},
	[53] = {"text", "Eggman", "Ohohohohohoho! It's been fun, but it's time I take my leave! I do hope you'll be there to experience the new and improved Metal Sonic!", nil, nil, nil, {"H_EGG3", SKINCOLOR_RED}},
	[54] = {"text", "Eggman", "Phantom Ruby! Exit this level at once!", nil, nil, nil, {"H_EGG3", SKINCOLOR_RED}},
	[55] = {"function",
				function(evt, btl)
					for i = 1, 19
						if evt.ftimer == 2*i
							P_LinedefExecute(1015)
						end
					end
					if evt.ftimer == 40
						S_StartSound(nil, sfx_s3k7b)
						S_StopMusic(nil)
						print("\x82WARNING:\x80 .\DOWNLOAD\PL_BlueMisteryBETA-v1.pk3|Lua/LUA_CUTS:5454: attempt to call global 'G_Exitlevel' (a nil value) stack traceback:.\DOWNLOAD\PL_BlueMisteryBETA-v1.pk3|Lua/LUA_CUTS:5454: in function '?'")
						//lol
					end
					if evt.ftimer == 70
						return true
					end
				end
			},
	[56] = {"text", "Eggman", "...", nil, nil, nil, {"H_EGG3", SKINCOLOR_RED}},
	[57] = {"function", function(evt, btl) boxflip = true return true end},
	[58] = {"text", "MASKED Eggman", "Oh, I think the Phantom Ruby inputted G_Exitlevel() instead of G_ExitLevel(). You gotta capitalize that L.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[59] = {"function", function(evt, btl) boxflip = false return true end},
	[60] = {"text", "Eggman", "Ugh, this blasted Ruby. Nothing but glitches and troubles.", nil, nil, nil, {"H_EGG4", SKINCOLOR_RED}},
	[61] = {"text", "Eggman", "I knew I should have recycled the old Metal Sonic I made way back. That one was cooler. Oh well, too late now.", nil, nil, nil, {"H_EGG4", SKINCOLOR_RED}},
	[62] = {"function", function(evt, btl) boxflip = true return true end},
	[63] = {"text", "MASKED Eggman", "Aw, don't leave! At least let me do my outro!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[64] = {"function", function(evt, btl) boxflip = false return true end},
	[65] = {"text", "Eggman", "You're going to make me puke. And quit giving advice to that darned rodent and his friends. I'm leaving.", nil, nil, nil, {"H_EGG4", SKINCOLOR_RED}},
	[66] = {"function",
				function(evt, btl)
					for i = 1, 19
						if evt.ftimer == 2*i
							P_LinedefExecute(1015)
						end
					end
					if evt.ftimer == 40
						for p in players.iterate
							P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						S_StartSound(nil, sfx_shattr)
						S_StartSound(nil, sfx_shattr)
						for mo in mobjs.iterate()
							if mo.type == MT_PFIGHTER and mo.skin == "eggman" and mo.color == SKINCOLOR_RED
								mo.flags2 = $|MF2_DONTDRAW
							end
						end
					end
					if evt.ftimer == 80
						S_StartSound(nil, sfx_contin)
						tipsfinished = true
						return true
					end
				end
			},
}
	
//main points: immune to debuffs but can get buffs removed, remember weaknesses for platforms, use phantom ruby and ruby analysis
//also, old school cutscene dream where he summons egg gundam and platform lock hyper cannons poor sonic
eventList["ev_tipscorner_6"] = {
	[1] = {"function", --zamn
				function(evt, btl)
					if evt.ftimer == 1
						--S_ChangeMusic("tips")
						P_StartQuake(10*FRACUNIT, 10)
						S_StartSound(nil, sfx_wake)
						boxflip = false
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.eggman = P_SpawnMobj(448*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local e = evt.eggman
						e.skin = "eggman"
						e.color = SKINCOLOR_RED
						e.angle = ANG1 * 200
						e.scale = FRACUNIT
						--e.noidlebored = true
						e.sprite = SPR_MASK
						e.state = S_MASKEDIDLE
						--e.tics = -1
						e.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						evt.sonic = P_SpawnMobj(-65*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * 340
						s.scale = FRACUNIT
						s.noidlebored = true
						s.sprite2 = SPR2_SHIT
						s.tics = -1
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						return true
					end
				end
			},
	[2] = {"text", "Sonic", "Gah!!!!", nil, nil, nil, {"H_SON8", SKINCOLOR_BLUE}},
	[3] = {"text", "Sonic", "......???????", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[4] = {"function", function(evt, btl) boxflip = true return true end},
	[5] = {"text", "MASKED Eggman", "Oh, you're finally awake. I guess that boss really knocked you out cold, huh?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[6] = {"function", function(evt, btl) S_ChangeMusic("tips") return true end},
	[7] = {"text", "MASKED Eggman", "Anyways, ladies and gentlemen, welcome to the\x82 ".."Blue Mistery Tips Corner!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[8] = {"text", "MASKED Eggman", "Presented to you by your supremely sparkling host for today, MASKED Eggman!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[9] = {"text", "MASKED Eggman", "Who, again, has absolutely NO affiliation with any specific boss in particular.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[10] = {"function",
				function(evt, btl)
					boxflip = false
					if evt.ftimer == 1
						S_StartSound(nil, sfx_nxbump)
					end
					if evt.ftimer == 50
						return true
					end
				end
			},
	[11] = {"text", "Sonic", "(...Was that all a dream? Why did it feel so familiar?)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[12] = {"function", function(evt, btl) boxflip = true return true end},
	[13] = {"text", "MASKED Eggman", "So... Stage 6! Good job making it this far!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[14] = {"text", "MASKED Eggman", "Your final hurdle before the finish line! And you just had to die!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[15] = {"function", function(evt, btl) boxflip = false return true end},
	[16] = {"text", "Sonic", "Well gee, sorry. Guess I should have used MY seven Chaos Emeralds. Maybe that'll make it even.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[17] = {"function", function(evt, btl) boxflip = true return true end},
	[18] = {"text", "MASKED Eggman", "Well, let's get the obvious out of the way, first.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[19] = {"text", "MASKED Eggman", "Eggman. Is. Invulnerable. To. Damage.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[20] = {"text", "MASKED Eggman", "Debuffs? Nullified. Megidolaons? Nullified. EP Skills? Can't even try it.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[21] = {"text", "MASKED Eggman", "As long as a single Chaos Emerald is powering that barrier, you can't hit him!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[22] = {"text", "MASKED Eggman", "But I'm sure you already knew that. The only thing you CAN deal damage to are the badniks in your platform!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[23] = {"text", "MASKED Eggman", "Once you've eradicated all badniks on the platform you reside in, you'll retrieve the Chaos Emerald that powers it!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[24] = {"text", "MASKED Eggman", "Not only does it get you closer to deactivating the barrier, but you'll gain a nifty little move, too!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[25] = {"text", "MASKED Eggman", "You'd do well to utilize the Chaos Emeralds for yourself! They can provide solutions to all sorts of problems!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[26] = {"function", function(evt, btl) boxflip = false return true end},
	[27] = {"text", "Sonic", "Right, but which Chaos Emerald does which?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[28] = {"function", function(evt, btl) boxflip = true return true end},
	[29] = {"text", "MASKED Eggman", "Well, why don't you try paying attention, dummy! You'll figure it out! No need for me to spell out everything!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[30] = {"function", function(evt, btl) boxflip = false return true end},
	[31] = {"text", "Sonic", "Ugh, I remember you being less snarky in the past. A part of me misses that dream now. For some reason.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[32] = {"function", function(evt, btl) boxflip = true return true end},
	[33] = {"text", "MASKED Eggman", "In the past, huh? Ahhh, good times! Remember when we met in Kimo Sanctuary?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[34] = {"function", function(evt, btl) boxflip = false return true end},
	[35] = {"text", "Sonic", "I...think so? My memory's kind of a blur... I think there was some kind of... robot? Like a giant mech?", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[36] = {"function", function(evt, btl) boxflip = true return true end},
	[37] = {"text", "MASKED Eggman", "Giant mech?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[38] = {"text", "MASKED Eggman", "Oh, you mean this one?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[39] = {"function", //camera pans out and it RISES
				function(evt, btl)
					if evt.ftimer == 1
						local cam = btl.cam
						CAM_goto(cam, cam.x, -255*FRACUNIT, cam.z)
						S_FadeOutStopMusic(1*MUSICRATE)
					end
					
					if evt.ftimer == 30
						P_StartQuake(1*FRACUNIT, 10)
					end
					if evt.ftimer == 40
						S_ChangeMusic("stg6b")
						evt.sonic.noidlebored = false
						evt.sonic.state = S_PLAY_EDGE
						
						//gundam guy
						evt.gundam = P_SpawnMobj(192*FRACUNIT, 50*FRACUNIT, -555*FRACUNIT, MT_DUMMY)
						evt.gundam.flags = $|MF_NOCLIPHEIGHT|MF_NOGRAVITY
						evt.gundam.sprite = SPR_GUND
						evt.gundam.tics = -1
						evt.gundam.frame = A
						evt.gundam.scale = FRACUNIT*3
					end
					if evt.ftimer > 40 and evt.ftimer < 205
						P_StartQuake(3*FRACUNIT, 1)
						if evt.gundam and evt.gundam.valid
							evt.gundam.z = evt.gundam.z + 2*FRACUNIT
						end
					end
					if evt.ftimer == 205
						evt.sonic.state = S_PLAY_STND
						evt.sonic.noidle = true
						--boxflip = false
						return true
					end
				end
			},
	[40] = {"text", "Egg Gundam", "HA HA HA. I AM A GIANT DEATH ROBOT. EAT YOUR GREENS. DON'T DO DRUGS.", nil, nil, nil, nil},
	[41] = {"function", function(evt, btl) boxflip = false return true end},
	[42] = {"text", "Sonic", "Wha- he's covering me! I can't see! Hey!", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[43] = {"function", function(evt, btl) boxflip = true return true end},
	[44] = {"text", "MASKED Eggman", "Anyways! Sonic, where were we? I forgot which move I was gonna talk about next.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[45] = {"function", function(evt, btl) boxflip = false return true end},
	[46] = {"text", "Sonic", "I dunno. What other moves were there?", nil, nil, nil, {"H_SON10", SKINCOLOR_BLUE}},
	[47] = {"function", function(evt, btl) boxflip = true return true end},
	[48] = {"text", "MASKED Eggman", "Hm... let's see...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[49] = {"text", "MASKED Eggman", "The Chaos Harness, Egg Missiles, Direct Combustion, what else was there?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[50] = {"function", //hyper cannon
				function(evt, btl)
					local mo = evt.gundam
					local target = evt.sonic
					local cam = btl.cam
					if evt.ftimer == 1
						mo.warning = {}
						mo.energypoint = P_SpawnMobj(mo.x, mo.y - 5*FRACUNIT, 50*FRACUNIT, MT_DUMMY)
						mo.energypoint.state = S_THOK
						mo.energypoint.scale = FRACUNIT/16
						mo.energypoint.color = SKINCOLOR_WHITE
						mo.energypoint.frame = FF_FULLBRIGHT
						mo.energypoint.tics = -1
						mo.energypoint.destscale = FRACUNIT*3
						S_StartSound(nil, sfx_s3kcas)
						S_StartSound(nil, sfx_s3kd9l)
					end
					if evt.ftimer >= 90
						local en = mo.energypoint
						if evt.ftimer == 90
							P_TeleportMove(en, mo.x, mo.y + 5*FRACUNIT, 50*FRACUNIT)
							for i = 1, 40
								local tgtx = en.x + (i*80)*cos(R_PointToAngle2(en.x, en.y, target.x, target.y))
								local tgty = en.y + (i*80)*sin(R_PointToAngle2(en.x, en.y, target.x, target.y))
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
						local cx = target.x + 200*cos(ANG1*180)--(R_PointToAngle2(mo.x, mo.y, target.x, target.y))
						local cy = target.y + 200*sin(ANG1*180)--(R_PointToAngle2(mo.x, mo.y, target.x, target.y))
						CAM_goto(cam, cx, cy, target.z + 50*FRACUNIT)
					end
					if evt.ftimer == 140
						return true
					end
				end
			},
	[51] = {"text", "MASKED Eggman", "Riiiiight, Hyper Cannon! It was Hyper Cannon! Silly me! I knew I could count on you, Egg Gundam!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[52] = {"function", function(evt, btl) boxflip = false return true end},
	[53] = {"text", "Sonic", "Wow, I'm glad you could help him remember! I'm so happy for you! You're a great pal!", nil, nil, nil, {"H_SON3", SKINCOLOR_BLUE}},
	[54] = {"text", "Sonic", "Now how about you aim that away from me! I'll give you a treat, too! Sound good, buddy?", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},
	[55] = {"function", function(evt, btl) boxflip = true return true end},
	[56] = {"text", "MASKED Eggman", "Here, lemme turn that off. As soon as I find out which button that is. Ugh, I should have labeled this remote.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[57] = {"text", "MASKED Eggman", "Ah, there we go.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[58] = {"function",
				function(evt, btl)
					//MY EYEEEEES
					if evt.ftimer == 20
						for p in players.iterate
							P_FlashPal(p, 1, 5) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						for s in sectors.iterate
							//for walls
							if s.tag == 53 or s.tag == 54
								s.ceilingheight = 216*FRACUNIT
								s.floorheight = 88*FRACUNIT
							end
							//for ceiling
							if s.tag == 41 or s.tag == 42
								s.ceilingheight = 216*FRACUNIT
								s.floorheight = 184*FRACUNIT
							end
							if s.tag == 8
								for i = 0, 3
									s.lines[i].frontside.midtexture = 3737
									s.lines[i].backside.midtexture = 3737
								end
							end
						end
						P_LinedefExecute(1004)
						S_StartSound(nil, sfx_s3k9f)
						S_StartSound(nil, sfx_hamas2)
					end
					if evt.ftimer == 80
						boxflip = false
						return true
					end
				end
			},
	[59] = {"text", "Sonic", "", nil, nil, nil, {"H_SON10", SKINCOLOR_BLUE}},
	[60] = {"function", function(evt, btl) boxflip = true return true end},
	[61] = {"text", "MASKED Eggman", "Oops, wrong button. Oh well! I'm sure you'll be fine!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[62] = {"function", function(evt, btl) boxflip = false return true end},
	[63] = {"text", "Sonic", "What part of this spells out 'fine'!?", nil, nil, nil, {"H_SON9", SKINCOLOR_BLUE}},
	[64] = {"function", function(evt, btl) boxflip = true return true end},
	[65] = {"text", "MASKED Eggman", "I mean, you could always guard and pray.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[66] = {"function", function(evt, btl) boxflip = false return true end},
	[67] = {"text", "Sonic", "I can't even guard! This is a cutscene!", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[68] = {"function", function(evt, btl) boxflip = true return true end},
	[69] = {"text", "MASKED Eggman", "Well, if we're going by that logic, surely you won't be damaged! You're already dead! HP is zero! Nothing to fear!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[70] = {"function", function(evt, btl) boxflip = false return true end},
	[71] = {"text", "Sonic", "Your logic sucks! Am I getting a Game Over in a Game Over because of you!?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[72] = {"function",
				function(evt, btl)
					local mo = evt.gundam
					if evt.ftimer == 1
						evt.usecam = true
						S_StartSound(nil, sfx_s3k5a)
					end
					if evt.ftimer == 40
						S_StartSound(mo, sfx_s3k54)
						S_StartSound(mo, sfx_beam)
					end
					if evt.ftimer > 40 and evt.ftimer < 45
						//FIRE
						P_StartQuake(FRACUNIT*12, 1)
						local en = mo.energypoint
						for i = 1,4
							local beam = P_SpawnMobj(en.x-P_RandomRange(200,-200)*FRACUNIT, en.y-P_RandomRange(60,-60)*FRACUNIT, en.z-P_RandomRange(100,-100)*FRACUNIT, MT_DUMMY)
							beam.scale = FRACUNIT*3/2
							beam.fuse = 30
							beam.state = S_MEGITHOK
							beam.angle = R_PointToAngle2(en.x, en.y, evt.sonic.x, evt.sonic.y)
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
					if evt.ftimer == 45
						S_StopSound(mo)
						P_StartQuake(10*FRACUNIT, 10)
						S_StartSound(nil, sfx_wake)
						S_StopMusic()
						for p in players.iterate
							P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.sonic.noidle = false
						evt.sonic.noidlebored = true
						evt.sonic.sprite2 = SPR2_SHIT
						evt.sonic.tics = -1
						P_RemoveMobj(mo.energypoint)
						P_RemoveMobj(mo)
						for m in mobjs.iterate()
							if m.state == S_THOK or m.state == S_MEGITHOK
								P_RemoveMobj(m)
							end
						end
						for s in sectors.iterate
							//for walls
							if s.tag == 53 or s.tag == 54
								s.ceilingheight = -100*FRACUNIT
								s.floorheight = -100*FRACUNIT
							end
							//for ceiling
							if s.tag == 41 or s.tag == 42
								s.ceilingheight = -100*FRACUNIT
								s.floorheight = -100*FRACUNIT
							end
							if s.tag == 8
								for i = 0, 3
									s.lines[i].frontside.midtexture = 0
									s.lines[i].backside.midtexture = 0
								end
							end
						end
						return true
					end
				end
			},
	[73] = {"text", "Sonic", "Gah!!!!!!!!!!!!!", nil, nil, nil, {"H_SON8", SKINCOLOR_BLUE}},
	[74] = {"text", "Sonic", "-", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},	
	[75] = {"function", function(evt, btl) boxflip = true return true end},
	[76] = {"text", "MASKED Eggman", "Oh, you're finally awake. I guess that I really knocked you out cold, huh?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[77] = {"function", function(evt, btl) boxflip = false return true end},
	[78] = {"text", "Sonic", "No, what? Wait. Huh?", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},	
	[79] = {"function", function(evt, btl) boxflip = true return true end},
	[80] = {"text", "MASKED Eggman", "Ready for round two? It's gonna take at least 530,000 tries to clear my boss fight!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[81] = {"function",
				function(evt, btl)
					local mo = evt.eggman
					if evt.ftimer == 1
						for p in players.iterate
							P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						S_StartSound(nil, sfx_s3k9f)
						mo.skin = "eggman"
						mo.color = SKINCOLOR_BLACK
						mo.state = S_PLAY_SUPER_TRANS6
						mo.tics = -1
						mo.frame = G
						mo.scale = FRACUNIT*3
					end
					if evt.ftimer >= 1 and evt.ftimer < 50
						summonAura(mo, SKINCOLOR_BLACK)
					end
					if evt.ftimer == 50
						P_StartQuake(10*FRACUNIT, 10)
						S_StartSound(nil, sfx_wake)
						for p in players.iterate
							P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						mo.sprite = SPR_MASK
						mo.state = S_MASKEDIDLE
						mo.scale = FRACUNIT
						boxflip = false
						return true
					end
				end
			},
	[82] = {"text", "Sonic", "Don'tkillmeeee!!!!!!!", nil, nil, nil, {"H_SON8", SKINCOLOR_BLUE}},
	[83] = {"text", "Sonic", "Wha-", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},		
	[84] = {"function", function(evt, btl) boxflip = true return true end},
	[85] = {"text", "MASKED Eggman", "I've come to make an announcement", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[86] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						P_StartQuake(10*FRACUNIT, 10)
						S_StartSound(nil, sfx_wake)
						for p in players.iterate
							P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						boxflip = false
						return true
					end
				end
			},
	[87] = {"text", "Updog", "Noooooo!!!!", nil, nil, nil, {"H_SON8", SKINCOLOR_BLUE}},
	[88] = {"function", //ugly knux wall
				function(evt, btl)
					if evt.ftimer == 1
						P_LinedefExecute(1005)
						for s in sectors.iterate
							if s.tag == 5
								for i = 0, 2 --why is it like this im crying
									if s.lines[i].tag == 1 or s.lines[i].tag == 2 or s.lines[i].tag == 11
										s.ceilingheight = -100*FRACUNIT
										s.floorheight = -100*FRACUNIT
									end
								end
							end
						end
						
						P_StartQuake(10*FRACUNIT, 10)
						S_StartSound(nil, sfx_wake)
						for p in players.iterate
							P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						boxflip = false
						return true
					end
				end
			},
	[89] = {"text", "Sonic", "Fbhdnjfhfsjdfjkafndfkfkjw", nil, nil, nil, {"H_SON8", SKINCOLOR_BLUE}},
	[90] = {"function", //masked eggman being the goat
				function(evt, btl)
					if evt.ftimer == 1
						P_LinedefExecute(1006)
						for s in sectors.iterate
							if s.tag == 5
								for i = 0, 2 --why is it like this im crying
									if s.lines[i].tag == 1 or s.lines[i].tag == 2
										s.ceilingheight = 104*FRACUNIT
										s.floorheight = 96*FRACUNIT
									end
									if s.lines[i].tag == 11
										s.ceilingheight = 344*FRACUNIT
										s.floorheight = 104*FRACUNIT
									end
								end
							end
						end
						
						P_StartQuake(10*FRACUNIT, 10)
						S_StartSound(nil, sfx_wake)
						for p in players.iterate
							P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						boxflip = true
						return true
					end
				end
			},
	[91] = {"text", "The Ohio Rizzler", "skibidi toilet", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[92] = {"function", //super saiyan sonic
				function(evt, btl)
					if evt.ftimer == 1
						P_StartQuake(10*FRACUNIT, 10)
						S_StartSound(nil, sfx_wake)
						for p in players.iterate
							P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						boxflip = false
						return true
					end
				end
			},
	[93] = {"text", "Sonic", "sample text", nil, nil, nil, {"H_SSLOL", SKINCOLOR_BLUE}},
	[94] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
					or evt.ftimer == 20
					or evt.ftimer == 40
					or evt.ftimer == 50
					or evt.ftimer == 60
					or evt.ftimer == 70
					or evt.ftimer == 80
					or evt.ftimer == 85
					or evt.ftimer == 90
					or evt.ftimer == 95
					or evt.ftimer == 100
					or evt.ftimer == 105
					or evt.ftimer == 110
					or evt.ftimer == 115
					or evt.ftimer == 120
						P_StartQuake(10*FRACUNIT, 10)
						S_StartSound(nil, sfx_wake)
						for p in players.iterate
							P_FlashPal(p, 1, 2) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
						end
						boxflip = false
					end
					if evt.ftimer == 120
						for mt in mapthings.iterate do
							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_TELEPORTMAN
							and mt.extrainfo == 1
								P_TeleportMove(evt.sonic, m.x, m.y, m.z)
								evt.sonic.state = S_PLAY_PAIN
								evt.sonic.tics = -1
								evt.sonic.angle = m.angle
								for mt in mapthings.iterate do	-- fetch awayviewmobj

									local m = mt.mobj
									if not m or not m.valid continue end

									if m and m.valid and m.type == MT_ALTVIEWMAN
									and mt.extrainfo == 2

										local cam = btl.cam
										P_TeleportMove(cam, m.x-20*FRACUNIT, m.y-20*FRACUNIT, m.z-10*FRACUNIT)
										cam.angle = R_PointToAngle2(cam.x, cam.y, evt.sonic.x, evt.sonic.y)
										cam.aiming = 0
										--CAM_goto(cam, cam.x, cam.y, cam.z)
										--CAM_angle(cam, cam.angle)
										--CAM_aiming(cam, cam.aiming)
										break
									end
								end
							end
						end
						return true
					end
				end
			},
	[95] = {"text", "Sonic", "ENOUGH!!!!!!", nil, nil, nil, {"H_SON8", SKINCOLOR_BLUE}},
	[96] = {"text", "Sonic", ".......", nil, nil, nil, {"H_SON7", SKINCOLOR_BLUE}},
	[97] = {"text", "Sonic", ".....................", nil, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},
	[98] = {"text", "Sonic", "...Is it over?", nil, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},
	[99] = {"text", "Sonic", "Where am I?", nil, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},
	[100] = {"text", "Sonic", "If I fell asleep here, I'm pretty sure I'd remember. There's absolutely nothing here.", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},
	[101] = {"text", "Sonic", "...Nothing here, except for-", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[102] = {"function", --camera pans to FHMS
				function(evt, btl)
					if evt.ftimer == 1
						evt.usecam = true
						evt.sonic.state = S_PLAY_STND
						evt.sonic.noidle = true
						evt.hms = P_SpawnMobj(2265*FRACUNIT, 2270*FRACUNIT, 0, MT_PFIGHTER)
						local s = evt.hms
						s.skin = "sonic"
						s.color = SKINCOLOR_YELLOW
						s.angle = ANG1 * 90
						s.scale = FRACUNIT
						s.noidle = true
						s.state = S_PLAY_STND
						s.tics = -1
						s.hms = true
						s.oghms = true
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						
						evt.hms2 = P_SpawnMobj(4800*FRACUNIT, 2270*FRACUNIT, 0, MT_PFIGHTER)
						local s2 = evt.hms2
						s2.skin = "sonic"
						s2.color = SKINCOLOR_YELLOW
						s2.angle = ANG1 * 90
						s2.scale = FRACUNIT
						s2.noidle = true
						s2.state = S_PLAY_STND
						s2.tics = -1
						s2.hms = true
						s2.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						
						local cam = btl.cam
						CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, s.x, s.y))
						local cx = evt.sonic.x + 130*cos(ANG1*260)--(R_PointToAngle2(mo.x, mo.y, target.x, target.y))
						local cy = evt.sonic.y + 130*sin(ANG1*260)--(R_PointToAngle2(mo.x, mo.y, target.x, target.y))
						CAM_goto(cam, cx, cy, evt.sonic.z + 15*FRACUNIT)
					end
					if evt.ftimer == 100
						for mt in mapthings.iterate do
							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_TELEPORTMAN
							and mt.extrainfo == 2
								for p in players.iterate()
									P_TeleportMove(p.mo, m.x, m.y, m.z)
									p.mo.angle = ANG1*90
								end
							end
						end
						return true
					end
				end
			},
	[103] = {"text", "Sonic", "Who... is that?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
}

local hmswarp = false
eventList["ev_tips6"] = { //actually part 2 of tips corner 6 but its short enough for a linedef executor
	[1] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						for m in mobjs.iterate()
							if m.hms and m.cutscene and m.oghms
								evt.hms = m
								m.angle = ANG1*100
							end
						end
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 3

								local cam = btl.cam
								P_TeleportMove(cam, m.x - 100*FRACUNIT, m.y, m.z)
								cam.angle = ANG1*55
							end
						end
						
						evt.sonic = P_SpawnMobj(2265*FRACUNIT, 1475*FRACUNIT, 0, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * 80
						s.scale = FRACUNIT
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						s.state = S_PLAY_WALK
					end
					if evt.sonic and evt.sonic.valid
						local s = evt.sonic
						if evt.ftimer < 80
							s.momy = 4*FRACUNIT
						else
							s.momy = $/6*5
							if s.momy < (1*FRACUNIT)/4
								s.state = S_PLAY_STND
								s.noidle = true
							end
						end
					end
					if evt.ftimer == 110
						boxflip = true
						return true
					end
				end
			},
	[2] = {"text", "HMS123311", "Hm?", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[3] = {"function",
				function(evt, btl)
					if evt.ftimer <= 20
						evt.hms.angle = evt.hms.angle + ANG1*10
					elseif evt.ftimer == 50
						return true
					end
				end
			},
	[4] = {"text", "HMS123311", "Oh hey, you're finally here. Awesome sauce.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[5] = {"function", function(evt, btl) S_ChangeMusic("tips2") boxflip = false return true end},
	[6] = {"text", "Sonic", "Uh??", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},	
	[7] = {"text", "Sonic", "(Is that... me? Me but yellow? I have way too many questions...)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[8] = {"function", function(evt, btl) boxflip = true return true end},
	[9] = {"text", "HMS123311", "Oh, don't worry about that, I'll answer them in a minute.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[10] = {"function", function(evt, btl) boxflip = false return true end},
	[11] = {"text", "Sonic", "(...)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[12] = {"text", "Sonic", "(Okay... that's one more question on the list.)", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},	
	[13] = {"text", "Sonic", "Let me just start with this. Who are you? And have we... met before?", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},	
	[14] = {"function", function(evt, btl) boxflip = true return true end},
	[15] = {"text", "HMS123311", "Guess you forgot after all, huh. Makes sense, with the whole Persona thing merging with our canon.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[16] = {"text", "HMS123311", "Oh well. Name's HMS123311. I was kind of a big deal back then. Pretty powerful.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[17] = {"text", "HMS123311", "I guess I got unlucky and was left out in this universe. Oh well. Maybe I should buy a retirement home.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[18] = {"text", "HMS123311", "But we HAVE met before. I'm glad you took the time to learn some 3rd grade level spelling this time around.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[19] = {"function", function(evt, btl) boxflip = false return true end},
	[20] = {"text", "Sonic", "I'm... having a hard time remembering that, but...", nil, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},	
	[21] = {"text", "Sonic", "I can't shake off this deja vu... talk about a headache.", nil, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},	
	[22] = {"function", function(evt, btl) boxflip = true return true end},
	[23] = {"text", "HMS123311", "Well, all you need to know is that I've been watching you for a while. I saw how you got thrashed by Eggman back there, too.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[24] = {"text", "HMS123311", "Ask me anything. I'm pretty sure I have the answers to them.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[25] = {"function", function(evt, btl) boxflip = false return true end},
	[26] = {"text", "Sonic", "(He's been watching me? What are you, god?)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[27] = {"function", function(evt, btl) boxflip = true return true end},
	[28] = {"text", "HMS123311", "(lol)", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[29] = {"function", function(evt, btl) boxflip = false return true end},
	[30] = {"text", "Sonic", "(So... I can ask him any question, right?)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[31] = {"text", "Sonic", "(But what kind of question should I ask him?)", {{"About Eggman", 32}, {"About HMS", 103}, {"...I'm good.", 198}}, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	
	//ABOUT EGGMAN
	[32] = {"text", "Sonic", "(I still don't have enough information on how to beat that cheater of a boss. Where to start...)", {{"Buffs/debuffs", 33}, {"Badniks", 49}, {"Phantom Ruby", 72}, {"Back", 196}}, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
		//"buffs/debuffs" (complete)
	[33] = {"function", function(evt, btl) boxflip = true return true end},
	[34] = {"text", "HMS123311", "Hm... Just like Masked Eggman said, his barrier makes him immune to debuffs.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[35] = {"text", "HMS123311", "But he's capable of buffing himself through Emerald Leech and Hyper Soul Leech, both moves coming from Chaos Harness.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[36] = {"text", "HMS123311", "Fortunately, while he's immune to getting debuffed,\x82 he's not immune to getting his buffs removed.\x80", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[37] = {"text", "HMS123311", "Taking your chances with Hamaon v2 is probably worth the risk. Or you could just use the Light Blue emerald, I dunno.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[38] = {"text", "HMS123311", "Either way, make sure to take notice of his buffs whenever he gets you with the Emerald and Soul leechie schmeechies.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[39] = {"function", function(evt, btl) boxflip = false return true end},
	[40] = {"text", "Sonic", "Well, what about our side? I mean, in terms of buffs and debuffs. How should we manage that?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[41] = {"function", function(evt, btl) boxflip = true return true end},
	[42] = {"text", "HMS123311", "Elementary, my dear. It'd be best if you started buffing\x82 after you've dealt with the middle platform.\x80 Y'know the Dekaja one.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[43] = {"text", "HMS123311", "With no badniks on your platform, you'll have less enemies to harass you while you go about your buffing beeswax.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[44] = {"text", "HMS123311", "It'd also be nice if your whole team was still on your platform while you buff. But sometimes you ain't so lucky.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[45] = {"function", function(evt, btl) boxflip = false return true end},
	[46] = {"text", "Sonic", "(I guess it does kinda sound like common sense.)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[47] = {"text", "Sonic", "(\x82".."Still, I should make an effort to keep the team in one place before\x82 we start buffing. And after we\x82 deal with the middle badniks.\x80)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},		
	[48] = {"function", function(evt, btl) D_requestIndex(1, 196) return true end},
		//"badnik"
	[49] = {"function", function(evt, btl) boxflip = true return true end},
	[50] = {"text", "HMS123311", "Riiiight, the badniks. Powered with the Emeralds. Big yikes.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[51] = {"text", "HMS123311", "This'll sound obvious, but the badniks' Emerald modes correspond to the platform they're on.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[52] = {"text", "HMS123311", "In other words, light blue badniks appear on the light blue platform.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[53] = {"text", "HMS123311", "But in this stage, after they attack, they'll switch over to another color, depending on the remaining emeralds.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[54] = {"text", "HMS123311", "Let's say you're getting pissed at your EP getting stolen, or your buffs being removed.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[55] = {"text", "HMS123311", "It might be good to go after those annoying Emerald platforms first and take them so they can't use it anymore.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[56] = {"text", "HMS123311", "Buuuuut frankly, if we're talking badniks, I'd say to\x82 prioritize targetting weaknesses\x80 if you can.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[57] = {"text", "HMS123311", "For example, the Cacolantern on the right platform is weak to\x85 Fire,\x80 and the FaceStabber on the left is weak to\x87 Pierce.\x80", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[58] = {"text", "HMS123311", "Which platform do you think\x82 you\x80 should go to?", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[59] = {"function", function(evt, btl) boxflip = false return true end},
	[60] = {"text", "Sonic", "...The one on the right. Because the Cacolantern's there.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[61] = {"function", function(evt, btl) boxflip = true return true end},
	[62] = {"text", "HMS123311", "Yup. Free 1More. That's why it's important to\x82 memorize the badniks' weaknesses.\x80", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[63] = {"text", "HMS123311", "Y'know, since the game won't be able to shove a weakness indicator at you towards badniks on other platforms. It's up to you to remember.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[64] = {"text", "HMS123311", "Weaknesses are a big key in winning Stage 6. After all, you're fighting, like, 20 enemies. You need those turns.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[65] = {"text", "HMS123311", "And if the character doesn't have that element, don't give up. You still have those\x82 gems,\x80 after all.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[66] = {"text", "HMS123311", "But hey, that doesn't mean you should ignore the Emeralds. Don't forget that you\x82 gain the Emerald for defeating all badniks in a\x82 platform.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[67] = {"text", "HMS123311", "Weaknesses are cool n' all, but if you manage to snatch something like the Green Emerald early on, you can use its skill for like, free EP. For free.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[68] = {"function", function(evt, btl) boxflip = false return true end},
	[69] = {"text", "Sonic", "Oh yeah, I keep forgetting you get those moves for your character. Huh. Too bad it doesn't give it to the whole party.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[70] = {"text", "Sonic", "(\x82".."Nevertheless, I should start paying attention to the badniks on other\x82 platforms so I know which\x82 weaknesses to exploit.\x80)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[71] = {"function", function(evt, btl) D_requestIndex(1, 196) return true end},
		//"phantom ruby"
	[72] = {"function", function(evt, btl) boxflip = true return true end},
	[73] = {"text", "HMS123311", "The Phantom Ruby, huh? Good thing Metal Sonic spat it out in the fight before.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[74] = {"text", "HMS123311", "Though, essentially, it's pretty much only got two uses.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[75] = {"text", "HMS123311", "\x82".."Warping to any platform, and using it to analyze badniks.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[76] = {"text", "HMS123311", "Both of which put it on a 3-turn cooldown. Yikes. Power scaling sucks, huh, buddy?", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[77] = {"text", "HMS123311", "If only you could make clones of yourself, or turn into other people. That'd be lit.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[78] = {"function", function(evt, btl) boxflip = false return true end},
	[79] = {"text", "Sonic", "Speaking of Analysis, it's weird how we're only getting it on this stage.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[80] = {"text", "Sonic", "Would've been reeeeeeal helpful in Stage 4.", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},
	[81] = {"function", function(evt, btl) boxflip = true return true end},
	[82] = {"text", "HMS123311", "Hey, take it up with zens159. Not me. I'm god, but I don't make the rules.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[83] = {"function", function(evt, btl) boxflip = false return true end},
	[84] = {"text", "Sonic", "(Who the heck is zens159?????)", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},
	[85] = {"function", function(evt, btl) boxflip = true return true end},
	[86] = {"text", "HMS123311", "Anyways, you can toggle the Phantom Ruby by pressing Custom 1 whenever the icon shows up.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[87] = {"text", "HMS123311", "Which is either when the map is opened, or when you're on the Analysis skill. But, like, you already knew that. You have eyes.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[88] = {"text", "HMS123311", "The better question is...", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[89] = {"text", "HMS123311", "Did you have Custom 1, 2, and 3 properly binded when you started this stage?", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[90] = {"function", function(evt, btl) boxflip = false return true end},
	[91] = {"text", "Sonic", "(...)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[92] = {"function", function(evt, btl) boxflip = true return true end},
	[93] = {"text", "HMS123311", "Don't worry about answering.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[94] = {"text", "HMS123311", "Takeaway here is pretty much just to remember to use it often. Hell, maybe use it right away to find a badnik's weakness.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[95] = {"text", "HMS123311", "Better to have the Ruby cooldown for 3-turns than forgetting to use it for just as long.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[96] = {"text", "HMS123311", "Maybe you could use the warp to wipe out badniks with suitable weaknesses, or take an Emerald that's screwin' with you.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[97] = {"text", "HMS123311", "Or maybe there's a teammate who reeeeeallly needs a healer. Your team can get split up pretty often in this stage.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[98] = {"text", "HMS123311", "Plenty of uses for this thing, despite there being very little uses for this thing. Makes sense, right?", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[99] = {"function", function(evt, btl) boxflip = false return true end},
	[100] = {"text", "Sonic", "(Well, first of all, no it doesn't. Second of all, he made a good point.)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[101] = {"text", "Sonic", "(\x82".."I should use the Phantom Ruby as much as possible, whether analyzing\x82 weaknesses or warping to other\x82 platforms.\x80)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[102] = {"function", function(evt, btl) D_requestIndex(1, 196) return true end},
	//ABOUT HMS
	[103] = {"text", "Sonic", "(HMS123311... he's still a big giant mystery. It doesn't sound like he's keeping secrets from me though. In that case...)", {{"How did we meet?", 104}, {"Other universes?", 133}, {"Origin story?", 165}, {"Back", 196}}, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
		//"how did we meet?" (complete)
	[104] = {"function", function(evt, btl) boxflip = true return true end},
	[105] = {"text", "HMS123311", "Oh, boy. Alright, Sonic. How much do you know about anime?", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[106] = {"function", function(evt, btl) boxflip = false return true end},
	[107] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[108] = {"text", "Sonic", "Enough???", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},	
	[109] = {"function", function(evt, btl) boxflip = true return true end},
	[110] = {"text", "HMS123311", "I'll start from the beginning, but to keep things short, let's just say it's a typical Eggman foiling plotline.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[111] = {"text", "HMS123311", "Yada yada go on a trip collect the Emeralds and confront big bad Eggman guy.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[112] = {"text", "HMS123311", "But suddenly, BOOM. Eggman unleashes a weapon on you, corrupting your mind and merging you with the dangerous Anime Eyes Sonic.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[113] = {"text", "HMS123311", "After that, you join Eggman's side. In other words, pretty much brainwashing. Frankly? Not the worst doujin tag.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[114] = {"text", "HMS123311", "But fast forward a few years, and a heated debate over some Evangelion BS breaks the two of you up, returning you to 'normal'.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[115] = {"text", "HMS123311", "That's when you start looking for me, hoping that I'd take out Eggman for you.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[116] = {"text", "HMS123311", "Honestly, appreciate the flattery, but being an assassin isn't the best trait for my tinder profile.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[117] = {"text", "HMS123311", "But rinse and repeat, another adventure, grab the Emeralds, same as usual. Joseph Joestar. Wonderful.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[118] = {"text", "HMS123311", "I think you beat up this one other guy, forgot his name, though.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[119] = {"text", "HMS123311", "Anyway, that's when you made it to Kawaii Sanctuary. It's also where you meet that Masked Eggman guy for the first time, too. Cool guy.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[120] = {"text", "HMS123311", "Turns out, though, when Eggman knocked the Anime Eyes Sonic out of you, it didn't completely vanish.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[121] = {"text", "HMS123311", "So when you made it through the Kimoi dimension, you confronted Anime Eyes Sonic again and took him out for now. Pretty neat fight.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[122] = {"text", "HMS123311", "Aaaaaand then you finally reach little ol' me.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[123] = {"text", "HMS123311", "We have a nice chat for a bit, sip some tea, and I throw you into a time portal back to Kawaii Sanctuary.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[124] = {"text", "HMS123311", "And then you did it all over again because apparently you were too stupid to remember anything. The end. Roll credits.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[125] = {"function", function(evt, btl) boxflip = false return true end},
	[126] = {"text", "Sonic", ".............................", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[127] = {"text", "Sonic", "You weren't making that up, were you?", nil, nil, nil, {"H_SON12", SKINCOLOR_BLUE}},	
	[128] = {"function", function(evt, btl) boxflip = true return true end},
	[129] = {"text", "HMS123311", "Hey, just be glad your pupils aren't the size of watermelons anymore.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[130] = {"function", function(evt, btl) boxflip = false return true end},
	[131] = {"text", "Sonic", "(I shouldn't have asked this question. Whatever, I'll pretend it didn't happen.)", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},	
	[132] = {"function", function(evt, btl) D_requestIndex(1, 196) return true end},
		//"other universes?" (srb2, top down, destructive illusion, bomberman, riders, kart) (complete)
	[133] = {"function", function(evt, btl) boxflip = true return true end},
	[134] = {"text", "HMS123311", "You want me to explain more on that, huh? Well, it is pretty interesting.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[135] = {"text", "HMS123311", "Where to begin, though? It's hard remembering all of them. I'll just give you some random examples.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[136] = {"text", "HMS123311", "For starters, there's a universe where you ride on karts and throw items at each other. Hell, there's two.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[137] = {"text", "HMS123311", "Similarly, there was another universe where you raced on those cool hoverboards. That one was pretty old.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[138] = {"text", "HMS123311", "Oh yeah, there was a pretty nifty top down kinda universe, too. I liked that one.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[139] = {"function", function(evt, btl) boxflip = false return true end},
	[140] = {"text", "Sonic", ".........", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[141] = {"text", "Sonic", "So...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[142] = {"function", function(evt, btl) boxflip = true return true end},
	[143] = {"text", "HMS123311", "Before you ask, yep. Your Persona universe is also a deviation off of the main universe, just like those others.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[144] = {"text", "HMS123311", "This may be a shock to you, but the main universe was a lot less... turn basey.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[145] = {"function", function(evt, btl) boxflip = false return true end},
	[146] = {"text", "Sonic", "Can't say I don't have complicated feelings about that.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[147] = {"function", function(evt, btl) boxflip = true return true end},
	[148] = {"text", "HMS123311", "Important to note, though. These universes aren't born at the same time.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[149] = {"text", "HMS123311", "Some universes are way older than others, and some are more populated than others.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[150] = {"text", "HMS123311", "Let's take, for instance, one universe where Metal Sonic used the Phantom Ruby and fought against a resistance without Sonic.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[151] = {"text", "HMS123311", "I'd say that universe doesn't even have half the age as that one Bomberman universe. That one lasted like, more than a decade.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[152] = {"text", "HMS123311", "Lots of pretty cool universes are created at different times, and by different people. And they're all super swag.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[153] = {"text", "HMS123311", "Except for that SMS blast universe. Hated that one.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[154] = {"text", "HMS123311", "Still, if only you had reality-bending-time-warping-omniversal-godly powers like I did.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[155] = {"text", "HMS123311", "You have no idea how vast these universes are. It's pretty rad.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[156] = {"function", function(evt, btl) boxflip = false return true end},
	[157] = {"text", "Sonic", "So I'm not even the original Sonic, huh? That's pretty weird to think about.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[158] = {"function", function(evt, btl) boxflip = true return true end},
	[159] = {"text", "HMS123311", "Well, you don't have to think about it like that. It does kinda suck though.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[160] = {"text", "HMS123311", "Frankly? I miss my lack of shading. You shoulda seen me at my prime.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[161] = {"function", function(evt, btl) boxflip = false return true end},
	[162] = {"text", "Sonic", "(Sheesh, talk about eye opening. No, actually this whole thing feels more like some kind of twisted wake up call.)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[163] = {"text", "Sonic", "(Well, I'll hold off on the existential crisis for now, at least.)", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},	
	[164] = {"function", function(evt, btl) D_requestIndex(1, 196) return true end},
		//"origin story?" (complete?)
	[165] = {"function", function(evt, btl) boxflip = true return true end},
	[166] = {"text", "HMS123311", "Aw, shucks. Well, if you insist, I'll talk about myself a bit more.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[167] = {"text", "HMS123311", "You can still call me HMS, but my full name's Hyper mysterious shadonic 123311.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[168] = {"text", "HMS123311", "I'm\x84 505505404740\x80 times stronger than Super Sonic, and I'm part of an\x85 ancient warrior tribe.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[169] = {"text", "HMS123311", "BTW, I also happen to be one of your ancestors. Pretty cool, right?", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[170] = {"function", function(evt, btl) boxflip = false return true end},
	[171] = {"text", "Sonic", "So is that why you just look like a recolored version of me?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[172] = {"function", function(evt, btl) boxflip = true return true end},
	[173] = {"text", "HMS123311", "Rude. Let's see you try to Chaos Control Armageddon Multi-Thok. I'm obviously cooler.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[174] = {"text", "HMS123311", "It's unfortunate, though. My power seems to have been nerfed in this universe. After all, my sprites are shaded.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[175] = {"text", "HMS123311", "I used to have an 'F' in my name, too. Man... Times were much better back then.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[176] = {"function", function(evt, btl) boxflip = false return true end},
	[177] = {"text", "Sonic", "Right, so, what else?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[178] = {"function", function(evt, btl) boxflip = true return true end},
	[179] = {"text", "HMS123311", "Hm? What do ya mean, what else?", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[180] = {"function", function(evt, btl) boxflip = false return true end},
	[181] = {"text", "Sonic", "Your backstory, you didn't finish.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[182] = {"function", function(evt, btl) boxflip = true return true end},
	[183] = {"text", "HMS123311", "Huh? Oh, nah, that's it.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[184] = {"function", function(evt, btl) boxflip = false return true end},
	[185] = {"text", "Sonic", "Huh?", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},	
	[186] = {"function", function(evt, btl) boxflip = true return true end},
	[187] = {"text", "HMS123311", "That's my whole backstory.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[188] = {"function", function(evt, btl) boxflip = false return true end},
	[189] = {"text", "Sonic", "Seriously?", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},	
	[190] = {"function", function(evt, btl) boxflip = true return true end},
	[191] = {"text", "HMS123311", "What? I think it's pretty original.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[192] = {"function", function(evt, btl) boxflip = false return true end},
	[193] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},	
	[194] = {"text", "Sonic", "Fine.", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},	
	[195] = {"function", function(evt, btl) D_requestIndex(1, 196) return true end},
	
	//"what else?" (after every option)
	[196] = {"function", function(evt, btl) evt.choice = 1 return true end},
	[197] = {"text", "Sonic", "(Okay, what else?)", {{"About Eggman", 32}, {"About HMS", 103}, {"...I'm good.", 199}}, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	
	//SKIP WITHOUT ASKING
	[198] = {"text", "Sonic", "(...On second thought, I think I'll just go. I've already reached my limit for one day. I can't understand a thing happening anymore.)", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},	

	//time to leave
	[199] = {"function", function(evt, btl) boxflip = true return true end},
	[200] = {"text", "HMS123311", "You're leaving? Sweet, I can get back to playing the newest version of Animal Crossing: New Leaf on my Nintendo 3DS.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[201] = {"text", "HMS123311", "It's surprisingly easy to hack, too. You should try it.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[202] = {"function", function(evt, btl) boxflip = false return true end},
	[203] = {"text", "Sonic", "Right...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[204] = {"text", "Sonic", "(I should leave before I start forgetting the difference between reality and a fever dream.)", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},	
	[205] = {"text", "Sonic", "Wait, so how do I get outta here?", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},	
	[206] = {"function", function(evt, btl) boxflip = true return true end},
	[207] = {"text", "HMS123311", "Oh, just noclip thok three times to the right, and keep going north from there.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[208] = {"function", function(evt, btl) boxflip = false return true end},
	[209] = {"text", "Sonic", ".........", nil, nil, nil, {"H_SON11", SKINCOLOR_BLUE}},	
	[210] = {"function", function(evt, btl) boxflip = true return true end},
	[211] = {"text", "HMS123311", "Okay FINE, I'll warp you out. No need to THANK ME or anything.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[212] = {"function", function(evt, btl) evt.hms.powercolor = SKINCOLOR_RED evt.hms.power = true return true end},
	[213] = {"text", "HMS123311", "Make sure you remember what I told you. I don't care which part, just try not to get amnesia again. Ruined my weekend back then.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[214] = {"text", "HMS123311", "BTW, when you get back, tell Masked Eggman he still needs to give back my copy of Barbie. Final warning.", nil, nil, nil, {"H_FHMS", SKINCOLOR_YELLOW}},
	[215] = {"function", //dear zens159 on line 4027: you have no god damn idea
				function(evt, btl)
					if evt.ftimer == 1
						S_StopMusic()
						S_StartSound(nil, sfx_epower)
						hmswarp = true
					end
					
					if evt.ftimer == 80
						--hmswarp = false
						S_StartSound(nil, sfx_contin)
						tipsfinished = true
					end
				end
			},
}

local timer = 0
rawset(_G, "hmsWarp", function(v, p)
	if not hmswarp
		timer = 0
		return
	end
	timer = timer + 1
	
	//faded background, can't get drawfill to be transparent so i have to put a black graphic in here :(
	local bruh = v.cachePatch("H_BRUH3")
	local hi = V_90TRANS
	if timer >= 3 and timer <= 5
		hi = V_80TRANS
	elseif timer > 5 and timer <= 7
		hi = V_70TRANS
	elseif timer > 7 and timer <= 9
		hi = V_60TRANS
	elseif timer > 9 and timer <= 11
		hi = V_50TRANS
	elseif timer > 11 and timer <= 13
		hi = V_40TRANS
	elseif timer > 13 and timer <= 15
		hi = V_30TRANS
	elseif timer > 15 and timer <= 17
		hi = V_20TRANS
	elseif timer > 17 and timer <= 19
		hi = V_10TRANS
	elseif timer > 19
		hi = V_SNAPTOTOP
	end
	v.drawScaled(0, 0, FRACUNIT*5, bruh, V_SNAPTOTOP|V_SNAPTOLEFT|hi)
end)
hud.add(hmsWarp)

addHook("MapLoad", function()
	hmswarp = false
end)

//hms particles
addHook("MobjThinker", function(mo)
	if mo.hms and mo.cutscene
		if not (leveltime%4)
			local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height/2, MT_DUMMY)
			elec.sprite = SPR_DELK
			elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
			elec.destscale = FRACUNIT
			elec.scalespeed = FRACUNIT/2
			elec.tics = TICRATE/8
			elec.color = SKINCOLOR_CYAN
		end
		if leveltime%8 == 0
			local spark = P_SpawnMobj(mo.x + P_RandomRange(-20, 20)*FRACUNIT, mo.y + P_RandomRange(-20, 20)*FRACUNIT, mo.z + P_RandomRange(-15, 25)*FRACUNIT, MT_SUPERSPARK)
		end
	end
end, MT_PFIGHTER)

//energypoint for gundam
addHook("MobjThinker", function(mo)
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
end, MT_DUMMY)

eventList["ev_tipscorner_placeholder"] = {
	[1] = {"function", --zamn
				function(evt, btl)
					if evt.ftimer == 1
						S_ChangeMusic("tips")
						boxflip = true
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.eggman = P_SpawnMobj(448*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local e = evt.eggman
						e.skin = "eggman"
						e.color = SKINCOLOR_RED
						e.angle = ANG1 * 200
						e.scale = FRACUNIT
						--e.noidlebored = true
						e.sprite = SPR_MASK
						e.state = S_MASKEDIDLE
						--e.tics = -1
						e.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						evt.sonic = P_SpawnMobj(-65*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * 340
						s.scale = FRACUNIT
						s.noidlebored = true
						s.sprite2 = SPR2_SHIT
						s.tics = -1
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
					end
					if evt.ftimer > 1
						evt.eggman.sprite = SPR_MASK
						evt.sonic.sprite2 = SPR2_SHIT
					end
					
					if evt.ftimer == 30 return true end
				end
			},
	[2] = {"text", "MASKED Eggman", "And I kid you not, he turns himself into a pickle! It's the epitome of comedic genius!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[3] = {"function",
				function(evt, btl)
					boxflip = false
					if evt.ftimer == 1
						S_StartSound(nil, sfx_nxbump)
					end
					if evt.ftimer == 50
						return true
					end
				end
			},
	[4] = {"text", "Sonic", "Hate to... uh... interrupt whatever you're doing, but what the heck's going on here?", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[5] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[6] = {"text", "MASKED Eggman", "No need to worry, for this is all just an unfinished version of a soon to implemented feature in the full release!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[7] = {"text", "MASKED Eggman", "After a tragic game over, you'll have the option to view an exquisite tips corner, directed by yours truly! MASKED Eggman!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[8] = {"text", "MASKED Eggman", "I'll handsomely present superbly insightful advice on how to master all the boss stages!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[9] = {"text", "MASKED Eggman", "And if I'm in a delightfully good mood, maybe I'll let you in on a couple moveset behavior patterns as well!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[10] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[11] = {"text", "Sonic", "Well, that's awfully kind of you, but, uh... you can't do it now, right?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[12] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[13] = {"text", "MASKED Eggman", "Truly amazing deduction! I expected no less! Why yes, indeed, as I've said before, this is in fact, unfinished.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[14] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[15] = {"text", "Sonic", "That's a bit of a shame, then. No point in offering advice when the public has all the time to fight the bosses in the beta.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[16] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[17] = {"text", "MASKED Eggman", "I do believe you fail to see the selling point of this feature though! A disappointing blunder from you, if I do say so myself!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[18] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[19] = {"text", "Sonic", "I probably know the answer to this, but what'd that b-", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[20] = {"function",
				function(evt, btl)
					P_StartQuake(20*FRACUNIT, 10)
					S_StartSound(nil, sfx_litng4)
					boxflip = true
					return true
				end
			},
	[21] = {"text", "MASKED Eggman", "MEEEEEEEEEEEE!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[22] = {"function",
				function(evt, btl)
					P_StartQuake(20*FRACUNIT, 10)
					S_StartSound(nil, sfx_litng4)
					return true
				end
			},
	[23] = {"text", "MASKED Eggman", "AND MY GLORIOUS FACE!!!!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[24] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[25] = {"text", "Sonic", "...Whatever you say, pal. I think I'm gonna go now.", nil, nil, nil, {"H_SON4", SKINCOLOR_BLUE}},
	[26] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[27] = {"text", "MASKED Eggman", "I do hope you'll stick around to see more of my beautiful and dazzling figure in the full version!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[28] = {"text", "MASKED Eggman", "Oh, before I go, here's a nifty tip! Did you know that you can bypass the restriction that prevents you from changing stages during a run?", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[29] = {"text", "MASKED Eggman", "All you need to do is just activate debug cheats! How devious!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[30] = {"text", "MASKED Eggman", "And so, that will be all from me! I'll meet you all again soon! Cheers for now!", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[31] = {"function",
				function(evt, btl)
					boxflip = false
					if evt.ftimer == 1
						S_StartSound(nil, sfx_jump)
					end
					evt.eggman.momz = 12*FRACUNIT
					evt.eggman.rollangle = $ + 25*ANG1
					if evt.ftimer == 60
						S_StartSound(nil, sfx_contin)
						tipsfinished = true
						return true
					end
				end
			},
}

eventList["ev_tipscorner_7"] = {
	[1] = {"function", --zamn
				function(evt, btl)
					if evt.ftimer == 1
						--S_ChangeMusic("tips")
						boxflip = true
						cutscene = true
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
						evt.eggman = P_SpawnMobj(448*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local e = evt.eggman
						e.skin = "eggman"
						e.color = SKINCOLOR_RED
						e.angle = ANG1 * 200
						e.scale = FRACUNIT
						e.noidlebored = true
						e.sprite = SPR_MASK
						e.tics = -1
						e.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
						evt.sonic = P_SpawnMobj(-65*FRACUNIT, 320*FRACUNIT, 90*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * 340
						s.scale = FRACUNIT
						s.noidlebored = true
						s.sprite2 = SPR2_SHIT
						s.tics = -1
						s.cutscene = true --make sure it's not affected by battle MT_PFIGHTER thinkers
					end
					if evt.ftimer > 1
						evt.eggman.sprite = SPR_MASK
						evt.sonic.sprite2 = SPR2_SHIT
					end
					
					if evt.ftimer == 30 return true end
				end
			},
	[2] = {"text", "MASKED Eggman", "...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[3] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[4] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[5] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[6] = {"text", "MASKED Eggman", "I have no words.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[7] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},	
	[8] = {"text", "Sonic", "...Not even any explanation?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[9] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[10] = {"text", "MASKED Eggman", "None.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[11] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[12] = {"text", "Sonic", "...", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[13] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[14] = {"text", "MASKED Eggman", "...", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[15] = {"function",
				function(evt, btl)
					if evt.ftimer == 70
						boxflip = false
						return true
					end
				end
			},
	[16] = {"text", "Sonic", "I wonder when the Extra Stage is gonna be finished?", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[17] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[18] = {"text", "MASKED Eggman", "I give it two years, minimum.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[19] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[20] = {"text", "Sonic", "Guess I'm not coming back to this map anytime soon, then.", nil, nil, nil, {"H_SON2", SKINCOLOR_BLUE}},
	[21] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[22] = {"text", "MASKED Eggman", "Yep.", nil, nil, nil, {"H_MASK1", SKINCOLOR_BLACK}},
	[23] = {"function",
				function(evt, btl)
					boxflip = false
					if evt.ftimer == 70
						G_ExitLevel(1, 1)
						return true
					end
				end
			},
}

//lol
eventList["ev_test"] = {
	[1] = {"function",
				function(evt, btl)
					if evt.ftimer == 1
						evt.usecam = true
						for mt in mapthings.iterate do	-- fetch awayviewmobj

							local m = mt.mobj
							if not m or not m.valid continue end

							if m and m.valid and m.type == MT_ALTVIEWMAN
							and mt.extrainfo == 1

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
					end
					if evt.ftimer < 70 and evt.ftimer > 1
						local cam = btl.cam
						P_TeleportMove(cam, cam.x, cam.y, cam.z-1*FRACUNIT)
					end
					--here's where we spawn a decoy sonic just outside the camera's range and have him jump in
					if evt.ftimer == 75
						evt.sonic = P_SpawnMobj(-750*FRACUNIT, -200*FRACUNIT, 50*FRACUNIT, MT_PFIGHTER)
						local s = evt.sonic
						s.skin = "sonic"
						s.color = SKINCOLOR_BLUE
						s.angle = ANG1 * -10
						s.scale = FRACUNIT*2
						s.momz = 12*FRACUNIT
					end
					if evt.ftimer >= 75 and evt.ftimer < 80
						local s = evt.sonic
						local landpointx = -400*FRACUNIT
						s.momx = (landpointx - s.x)/17
					end
					if evt.sonic and evt.sonic.valid and P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.momx = $/2
						s.momy = $/2
						if s.momx > 0 or s.momy > 0
							s.state = S_PLAY_SKID
							s.frame = F
						elseif s.momx == 0 and s.momy == 0
							s.state = S_PLAY_STND
							s.noidle = true
						end
					elseif evt.sonic and evt.sonic.valid and not P_IsObjectOnGround(evt.sonic)
						local s = evt.sonic
						s.state = S_PLAY_FALL
					end
					
					if evt.ftimer == 120 return true end
				end
			},
	[2] = {"text", "Sonic", "...awfully darker than usual here...", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[3] = {"function", --we're gonna be seeing this a lot...
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[4] = {"text", "???", "I KID YOU NOT, HE TURNS HIMSELF INTO A PICKLE!", nil, nil, nil, nil},
	[5] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[6] = {"text", "Sonic", "wha", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[7] = {"function", --eggman floats down on his eggmobile
				function(evt, btl)
					if evt.ftimer == 1
						evt.eggman = P_SpawnMobj(300*FRACUNIT, -200*FRACUNIT, 700*FRACUNIT, MT_EGGMOBILE)
						local s = evt.eggman
						s.state = S_EGGMOBILE_STND
						s.angle = ANG1 * 180
						s.scale = FRACUNIT*2
						s.momz = -30*FRACUNIT
					end
					if evt.eggman and evt.eggman.valid and evt.eggman.z < evt.eggman.floorz + 175*FRACUNIT and not evt.eggman.flyup
						local s = evt.eggman
						if leveltime%3 == 0
							s.momz = $/2
						end
						if leveltime%4 == 0
							for i = 1,16
								local dust = P_SpawnMobj(s.x, s.y, s.floorz, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (22*(i-1))
								dust.state = S_CDUST1
								P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
								dust.color = SKINCOLOR_WHITE
								dust.scale = FRACUNIT*2
							end
						end
						P_StartQuake(1*FRACUNIT, 2)
					end
					if evt.eggman and evt.eggman.valid and evt.eggman.momz > -1*FRACUNIT
						local s = evt.eggman
						s.flyup = true
					end
					if evt.eggman and evt.eggman.valid and evt.eggman.flyup
						local s = evt.eggman
						if leveltime%10 == 0
							for i = 1,16
								local dust = P_SpawnMobj(s.x, s.y, s.floorz, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (22*(i-1))
								dust.state = S_CDUST1
								P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
								dust.color = SKINCOLOR_WHITE
								dust.scale = FRACUNIT*2
							end
						end
						if s.z < 140*FRACUNIT
							s.momz = 5*FRACUNIT
						else 
							s.momz = $/2
						end
					end
					if evt.ftimer == 80 return true end
				end
			},
	[8] = {"function",
				function(evt, btl)
					boxflip = true
					return true
				end
			},
	[9] = {"text", "Eggman", "SO WHEN THE GUY TELLS HIM 'ONLY A SPOONFUL', HE PULLS OUT THIS COMICALLY LARGE SPOON", nil, nil, nil, {"H_EGG1", SKINCOLOR_RED}},
	[10] = {"function",
				function(evt, btl)
					boxflip = false
					return true
				end
			},
	[11] = {"text", "susnic", "EGGMAN NOO", nil, nil, nil, {"H_SON1", SKINCOLOR_BLUE}},
	[12] = {"function",
				function(evt, btl)
					local wave = {"amy_tutorial"}
					local team_1 = server.plentities[1]
					local team_2 = {}
					for i = 1,#wave
						local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
						enm.state = S_PLAY_STND
						enm.tics = -1
						enm.enemy = wave[i]
						team_2[#team_2+1] = enm
					end
					//advantage: 1 = player, 2 = enemy, 0 = neutral(?)
					BTL_StartBattle(1, team_1, team_2, 2, nil, "BATL1") //placeholder music lol
				end
			},
}

addHook("MobjThinker", function(mo)
	if not (mapheaderinfo[gamemap].bluemiststory) return end
	//resetting skip meter when a battle occurs normally while it's loading
	if not mo.cutscene 
		if server.P_BattleStatus[mo.battlen].battlestate == BS_START
			cutsceneskip = 0
			skipx = -200
			fadetimer = 0
			fade = V_ALLOWLOWERCASE
			return 
		end
	end
end, MT_PFIGHTER)

addHook("ThinkFrame", function()
	if (mapheaderinfo[gamemap].bluemiststory) and leveltime == 1
		if gamemap == 07 then D_startEvent(1, "ev_stage1", true) end
		if gamemap == 08 then D_startEvent(1, "ev_stage2", true) end
		if gamemap == 09 then D_startEvent(1, "ev_stage3", true) end
		if gamemap == 10 then D_startEvent(1, "ev_stage4", true) end
		if gamemap == 11 then D_startEvent(1, "ev_stage5", true) end
		if gamemap == 12 then D_startEvent(1, "ev_stage6", true) end
		if gamemap == 13 then D_startEvent(1, "ev_extrastage", true) end
		if gamemap == 14 
			local scenes = {"ev_tipscorner_1", "ev_tipscorner_2", "ev_tipscorner_3", "ev_tipscorner_4", "ev_tipscorner_5", "ev_tipscorner_6", "ev_tipscorner_7"}
			if diedstage == 1 and not cv_debugcheats.value
				G_ExitLevel(1, 1)
			end
			if scenes[diedstage]
				D_startEvent(1, scenes[diedstage], true)
			else
				D_startEvent(1, "ev_tipscorner_placeholder", true)
			end
			--D_startEvent(1, "ev_tipscorner_placeholder", true) --kill
		end
		if gamemap == 15
			if diedstage == 1 and not cv_debugcheats.value
				G_ExitLevel(1, 1)
			end
			D_startEvent(1, "ev_tipscorner_6", true) 
		end
	end
	if (mapheaderinfo[gamemap].bluemiststory)
		if timestop return end --no spawning clouds during chaos control!
		if leveltime == 1 or leveltime%P_RandomRange(25, 40) == 0
			for i = 1, 50
				if P_RandomRange(1, 5) == 1
					local btl = server.P_BattleStatus[1]
					if btl.battlestate == 0
						local x
						local y
						local z
						if gamemap == 07 
							x = P_RandomRange(-1450, 1450)*FRACUNIT
							y = P_RandomRange(-1000, 1300)*FRACUNIT
							z = P_RandomRange(10, 400)*FRACUNIT
						elseif gamemap == 08
							x = P_RandomRange(-8350, 2850)*FRACUNIT
							y = P_RandomRange(2100, -5100)*FRACUNIT
							z = P_RandomRange(10, 400)*FRACUNIT
						elseif gamemap == 09
							x = P_RandomRange(-1300, 1300)*FRACUNIT
							y = P_RandomRange(1000, -1300)*FRACUNIT
							z = P_RandomRange(10, 400)*FRACUNIT
						end
						if x and y and z
							local mist = P_SpawnMobj(x, y, z, MT_DUMMY)
							mist.state = S_TNTDUST_7
							mist.spriteyscale = FRACUNIT*2
							mist.spritexscale = FRACUNIT*4
							mist.tics = 300
							mist.momx = P_RandomRange(2, -2)*FRACUNIT
						end
					else
						local x
						local y
						local z
						if gamemap == 07
							x = P_RandomRange(1200, 4800)*FRACUNIT
							y = P_RandomRange(-1900, -5300)*FRACUNIT
							z = P_RandomRange(10, 400)*FRACUNIT
						elseif gamemap == 08
							x = P_RandomRange(-1400, 4100)*FRACUNIT
							y = P_RandomRange(2100, -5100)*FRACUNIT
							z = P_RandomRange(10, 400)*FRACUNIT
						elseif gamemap == 09
							x = P_RandomRange(3400, 6000)*FRACUNIT
							y = P_RandomRange(1000, -1300)*FRACUNIT
							z = P_RandomRange(10, 400)*FRACUNIT
						end
						if x and y and z
							local mist = P_SpawnMobj(x, y, z, MT_DUMMY)
							mist.state = S_TNTDUST_7
							mist.spriteyscale = FRACUNIT*2
							mist.spritexscale = FRACUNIT*4
							mist.tics = 300
							mist.momx = P_RandomRange(2, -2)*FRACUNIT
							mist.momy = P_RandomRange(2, -2)*FRACUNIT
						end
					end
				end
			end
		end
	end
	//title exclusive
	if gamemap == 40
		if leveltime == 1 or leveltime%P_RandomRange(15, 30) == 0
			for i = 1, 50
				if P_RandomRange(1, 5) == 1
					local x
					local y
					local z
					x = P_RandomRange(-1450, 1450)*FRACUNIT
					y = P_RandomRange(-1000, 1300)*FRACUNIT
					z = P_RandomRange(10, 400)*FRACUNIT
					if x and y and z
						local mist = P_SpawnMobj(x, y, z, MT_DUMMY)
						mist.state = S_TNTDUST_7
						mist.spriteyscale = FRACUNIT*2
						mist.spritexscale = FRACUNIT*4
						mist.tics = 300
						mist.momx = P_RandomRange(2, -2)*FRACUNIT
					end
				end
			end
		end
		for mt in mapthings.iterate do	-- fetch awayviewmobj

			local m = mt.mobj
			if not m or not m.valid continue end

			if m and m.valid and m.type == MT_ALTVIEWMAN
			and mt.extrainfo == 1

				m.cusval = -ANG1*2
				P_TeleportMove(m, m.x, m.y, 200*FRACUNIT)
				break
			end
		end
	end
	//oh yeah this is unrelated to mist but real quick for emerald powered badnik colors in cutscenes
	for m in mobjs.iterate() do
		if m and m.valid and m.emeraldpowered and (m.type == MT_CRAWLACOMMANDER or m.type == MT_ROBOHOOD)
			if leveltime & 2
				local g = P_SpawnGhostMobj(m)
				g.color = m.emeraldcolor
				g.colorized = true
				g.scale = m.scale
				g.frame = $|FF_TRANS40
				g.tics = -1
			end
		end
	end
end)

addHook("MapLoad", function()
	if not server return end
	cutsceneskip = 0
	skipx = -200
	fadetimer = 0
	fade = V_ALLOWLOWERCASE
	rise = false
end)

hud.add(function(v)
	if not (mapheaderinfo[gamemap].bluemiststory) return end
	if server
		if server.P_BattleStatus[1].battlestate != 0 return end
		if not cutscene
			skipx = -200
			fadetimer = 0
			fade = V_ALLOWLOWERCASE
		else
			if skipx <= -175
				skipx = skipx + 9
			elseif skipx <= -150
				skipx = skipx + 8
			elseif skipx <= -125
				skipx = skipx + 7
			elseif skipx <= -100
				skipx = skipx + 6
			elseif skipx <= -75
				skipx = skipx + 5
			elseif skipx <= -50
				skipx = skipx + 4
			elseif skipx <= -25
				skipx = skipx + 3
			elseif skipx <= -7
				skipx = skipx + 2
			elseif skipx <= 9
				skipx = skipx + 1
			end
			if fadetimer == 10
				fade = V_10TRANS
			elseif fadetimer == 11
				fade = V_20TRANS
			elseif fadetimer == 12
				fade = V_30TRANS
			elseif fadetimer == 13
				fade = V_40TRANS
			elseif fadetimer == 14
				fade = V_50TRANS
			elseif fadetimer == 15
				fade = V_60TRANS
			elseif fadetimer == 16
				fade = V_70TRANS
			elseif fadetimer == 17
				fade = V_80TRANS
			elseif fadetimer == 18
				fade = V_90TRANS
			elseif fadetimer == 19
				skipx = 1000
				fade = V_ALLOWLOWERCASE
				--skiptimer = 1
			end
		end
	end
	if cutsceneskip > 0 then v.drawFill(5, 7, (cutsceneskip*100)/16, 15, 100|V_SNAPTOLEFT|V_SNAPTOTOP) end
	v.drawString(skipx, 10, "Hold Custom 3 to skip...", V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOTOP|fade, "left")
end)

addHook("MobjThinker", function(mo)
	if not cutscene return end
	if tipsfinished return end
	if server.P_BattleStatus[1].battlestate != 0 return end
	local btl = server.P_BattleStatus[1]
	--local music = nil
	if mo.player == server.playerlist[1][1]
		if mo.player.cmd.buttons & BT_CUSTOM3
			cutsceneskip = $+1
			if cutsceneskip == 1
				fadetimer = 9
				skipx = 10
				fade = V_90TRANS
			elseif cutsceneskip == 2
				fade = V_80TRANS
			elseif cutsceneskip == 3
				fade = V_70TRANS
			elseif cutsceneskip == 4
				fade = V_60TRANS
			elseif cutsceneskip == 5
				fade = V_50TRANS
			elseif cutsceneskip == 6
				fade = V_40TRANS
			elseif cutsceneskip == 7
				fade = V_30TRANS
			elseif cutsceneskip == 8
				fade = V_20TRANS
			elseif cutsceneskip == 9
				fade = V_10TRANS
			elseif cutsceneskip == 10
				fade = V_ALLOWLOWERCASE
			end
		else
			if skipx == 10 or skipx == 1000
				if cutsceneskip > 0
					cutsceneskip = $-1
				else
					fadetimer = $+1
				end
			end
		end
	end
	if cutsceneskip == 30
		if gamemap == 07
			local wave = {"b_silver"}
			local team_1 = server.plentities[1]
			local team_2 = {}
			for i = 1,#wave
				local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
				enm.state = S_PLAY_STND
				enm.tics = -1
				enm.enemy = wave[i]
				team_2[#team_2+1] = enm
			end
			S_StopMusic()
			//advantage: 1 = player, 2 = enemy, 0 = neutral(?)
			BTL_StartBattle(1, team_1, team_2, 2, nil, "stg1b")
		elseif gamemap == 08
			local wave = {"b_shadow"}
			local team_1 = server.plentities[1]
			local team_2 = {}
			for i = 1,#wave
				local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
				enm.state = S_PLAY_STND
				enm.tics = -1
				enm.enemy = wave[i]
				team_2[#team_2+1] = enm
			end
			S_StopMusic()
			//advantage: 1 = player, 2 = enemy, 0 = neutral(?)
			BTL_StartBattle(1, team_1, team_2, 2, nil, "stg2b")
		elseif gamemap == 09
			for s in sectors.iterate do
				if s.tag == 1
					s.lightlevel = 200
				end
			end
			local wave = {"b_blaze"}
			local team_1 = server.plentities[1]
			local team_2 = {}
			for i = 1,#wave
				local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
				enm.state = S_PLAY_STND
				enm.tics = -1
				enm.enemy = wave[i]
				team_2[#team_2+1] = enm
			end
			S_StopMusic()
			//advantage: 1 = player, 2 = enemy, 0 = neutral(?)
			BTL_StartBattle(1, team_1, team_2, 2, nil, "stg3b")
		elseif gamemap == 10
			P_LinedefExecute(1003)
			P_LinedefExecute(1004)
			P_LinedefExecute(1005)
			P_LinedefExecute(1009)
			P_LinedefExecute(1012)
			for s in sectors.iterate do
				if s.tag == 3
					s.lightlevel = 255
				end
			end
			if sectorstuff and #sectorstuff
				for i = 1, #sectorstuff
					if sectorstuff[i]
						local sector = sectorstuff[i]
						if sector.tag == 1 or sector.tag == 7 or sector.tag == 9
							sector.floorheight = sectorfloor[i] + 1125*FRACUNIT
							sector.ceilingheight = sectorceiling[i] + 1125*FRACUNIT
						end
					end
				end
			end
			local wave = {"jetty gunner", "jetty bomber", "robo hood", "facestabber"}
			local team_1 = server.plentities[1]
			local team_2 = {}
			for i = 1,#wave
				local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
				enm.state = S_PLAY_STND
				enm.tics = -1
				enm.enemy = wave[i]
				enm.emeraldmode = P_RandomRange(1, 6)
				team_2[#team_2+1] = enm
			end
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
			btl.weaknesses = $ or {}
			btl.resistances = $ or {}
			for i = 1, #enemies
				btl.weaknesses[i] = atk_constants[P_RandomRange(1, #atk_constants)]
				btl.resistances[i] = atk_constants[P_RandomRange(1, #atk_constants)]
			end
			S_StopMusic()
			//advantage: 1 = player, 2 = enemy, 0 = neutral(?)
			BTL_StartBattle(1, team_1, team_2, 2, nil, "stg4c")
		elseif gamemap == 11
			local wave = {"b_metalsonic"}
			local team_1 = server.plentities[1]
			local team_2 = {}
			for i = 1,#wave
				local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
				enm.state = S_PLAY_STND
				enm.tics = -1
				enm.enemy = wave[i]
				team_2[#team_2+1] = enm
			end
			S_StopMusic()
			//advantage: 1 = player, 2 = enemy, 0 = neutral(?)
			BTL_StartBattle(1, team_1, team_2, 2, nil, "stg5a")
		elseif gamemap == 12
			rise = false
			local wave = {"b_emerald", "b_emerald", "b_emerald", "b_emerald", "b_emerald", "b_emerald", "b_emerald", "b_eggman"}
			local team_1 = server.plentities[1]
			local team_2 = {}
			for i = 1,#wave
				local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
				enm.state = S_PLAY_STND
				enm.tics = -1
				enm.enemy = wave[i]
				team_2[#team_2+1] = enm
			end
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
			btl.weaknesses = $ or {}
			btl.resistances = $ or {}
			for i = 1, #enemies
				btl.weaknesses[i] = atk_constants[P_RandomRange(1, #atk_constants)]
				btl.resistances[i] = atk_constants[P_RandomRange(1, #atk_constants)]
			end
			S_StopMusic()
			//advantage: 1 = player, 2 = enemy, 0 = neutral(?)
			BTL_StartBattle(1, team_1, team_2, 1, nil, "stg6c") --1
		elseif gamemap == 13
			local wave = {"god"}
			local team_1 = server.plentities[1]
			local team_2 = {}
			for i = 1,#wave
				local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
				enm.state = S_PLAY_STND
				enm.tics = -1
				enm.enemy = wave[i]
				team_2[#team_2+1] = enm
			end
			S_StopMusic()
			//advantage: 1 = player, 2 = enemy, 0 = neutral(?)
			BTL_StartBattle(1, team_1, team_2, 1, nil, "stg7b")
			for s in sectors.iterate
				s.lightlevel = s.lightlevel - 40
			end
			P_SetupLevelSky(34)
			rise = true
		end
		if gamemap == 14 or gamemap == 15
			S_StartSound(nil, sfx_contin)
			tipsfinished = true
		end
		cutsceneskip = 0
		cutscene = false
	end
end, MT_PLAYER)

local tipsimage = ""
local tipsimagex = 0
local tipsimagey = 0
local t_xdest = 0
local t_ydest = 0
local imagetimer = 0
local imagedirection = ""
local lightsdown = false
local goodbye = false

addHook("MapLoad", function()
	tipsimage = ""
	tipsimagex = 0
	tipsimagey = 0
	t_xdest = 0
	t_ydest = 0
	imagetimer = 0
	imagedirection = ""
	lightsdown = false
	goodbye = false
end)

rawset(_G, "TIPS_pullImage", function(x, y, image, direction, dark)
	imagetimer = 1
	tipsimage = image
	t_xdest = x
	t_ydest = y
	imagedirection = direction
	if dark == true
		lightsdown = true
	end
end)

rawset(_G, "TIPS_goAwayImage", function(direction)
	imagedirection = direction
	goodbye = true
	if lightsdown
		lightsdown = false
	end
end)

rawset(_G, "drawTipsImage", function(v, p)
	if gamemap != 14 return end
	if imagetimer >= 1
		local image = v.cachePatch(tipsimage)
		local staticwidth = image.width
		local staticheight = image.height
		imagetimer = imagetimer + 1
		if not goodbye
			if imagedirection == "up" or not imagedirection
				if imagetimer == 2
					tipsimagey = -200
					tipsimagex = t_xdest
				else
					tipsimagey = tipsimagey + (t_ydest - tipsimagey)/10
					tipsimagex = t_xdest
				end
			end
			if imagedirection == "down"
				if imagetimer == 2
					tipsimagey = 400
					tipsimagex = t_xdest
				else
					tipsimagey = tipsimagey + (t_ydest - tipsimagey)/10
					tipsimagex = t_xdest
				end
			end
			if imagedirection == "left"
				if imagetimer == 2
					tipsimagey = t_ydest
					tipsimagex = -200
				else
					tipsimagey = t_ydest
					tipsimagex = tipsimagey + (t_xdest - tipsimagey)/10
				end
			end
			if imagedirection == "right"
				if imagetimer == 2
					tipsimagey = t_ydest
					tipsimagex = 500
				else
					tipsimagey = t_ydest
					tipsimagex = tipsimagey + (t_xdest - tipsimagey)/10
				end
			end
		else
			if imagedirection == "up"
				tipsimagey = tipsimagey - 20
				if tipsimagey <= -200
					imagetimer = 0
					tipsimage = ""
					goodbye = false
				end
			end
			if imagedirection == "down"
				tipsimagey = tipsimagey + 20
				if tipsimagey >= 200
					imagetimer = 0
					tipsimage = ""
					goodbye = false
				end
			end
			if imagedirection == "right"
				tipsimagex = tipsimagex + 20
				if tipsimagex >= 500
					imagetimer = 0
					tipsimage = ""
					goodbye = false
				end
			end
			if imagedirection == "left"
				tipsimagex = tipsimagex - 20
				if tipsimagex <= -200
					imagetimer = 0
					tipsimage = ""
					goodbye = false
				end
			end
		end
		if imagetimer >= 1 and tipsimage != ""
			v.drawScaled(tipsimagex*FRACUNIT, tipsimagey*FRACUNIT, FRACUNIT/3, image, nil, nil)
			/*v.drawCropped(tipsimagex*FRACUNIT, tipsimagey*FRACUNIT, FRACUNIT/3, FRACUNIT/3, v.cachePatch("H_STATIC"), V_80TRANS, nil, 0, 0, staticwidth*FRACUNIT, staticheight*FRACUNIT)
			if leveltime%3 == 0 //static
				v.drawCropped(tipsimagex*FRACUNIT, tipsimagey*FRACUNIT, FRACUNIT/3, FRACUNIT/3, v.cachePatch("H_STATIC"), V_70TRANS, nil, 0, 0, staticwidth*FRACUNIT, staticheight*FRACUNIT)
			end*/
		end
	end
end)

hud.add(drawTipsImage)

/*addHook("ThinkFrame", function()
	if gamemap != 14 return end
	//lights
	if lightsdown
		if imagetimer <= 30
			for s in sectors.iterate
				s.lightlevel = s.lightlevel - 2
			end
		end
	else
		for s in sectors.iterate
			if s.lightlevel < 255
				s.lightlevel = s.lightlevel + 2
			end
		end
	end
end)*/
