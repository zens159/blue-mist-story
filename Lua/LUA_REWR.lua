
---------- Rewrites...how wonderful... -------------

//we need to prevent the overworld menu from being able to open during cutscenes (or at all during this story)
rawset(_G, "D_HandleMenu", function(mo)
	if (mapheaderinfo[gamemap].bluemiststory) and not mo.player.P_spectator return end
	-- open menu:
	local inputs = mo.P_inputs
	local openmenu = "main"

	-- exception: tartarus lobby
	if gamemap == srb2p.tartarus_map
	and not mo.m_menu
		-- always consider p1's as server
		local thisp = mo.player
		for p in players.iterate do	-- < take first p that exists (aka not server in dedi)
			if p.mo and p.mo.valid
				thisp = p
				break
			end
		end

		if mo.player == thisp
			openmenu = "mpselect_main"
			--openmenu = "m_selectfacility"
			if inputs[BT_USE]==1
				M_openMenu(mo, openmenu)
				inputs[BT_USE] = 2	-- fixes a little bug
			end
		end
		M_handleMenu(mo)

		if not mo.m_menu
			PLAY_move(mo.player)
		end

		return
	end

	if mo.player.P_spectator
		openmenu = "spectate_jointeam"
	end

	if not mo.m_menu
	and (mo.player.P_spectator or not (server.P_DialogueStatus and server.P_DialogueStatus[mo.player.P_party] and server.P_DialogueStatus[mo.player.P_party].running))
		if inputs[BT_USE]==1
		and P_IsObjectOnGround(mo)
			M_openMenu(mo, openmenu)
			inputs[BT_USE] = 2	-- fixes a little bug
		end
	end
	M_handleMenu(mo)
end)

//this one is needed for the previous one to work
rawset(_G, "DNG_Thinker", function()

	if not server return end

	if server.entrycard
		server.entrytime = $-1
		if server.P_DungeonStatus.gameoverfade
			server.P_DungeonStatus.gameoverfade = $-1
		end
		if server.P_DungeonStatus.lifeexplode
			if server.P_DungeonStatus.lifeexplode == 20
			and server.P_BattleStatus and server.P_BattleStatus.lives and server.P_BattleStatus.lives >= 0
				S_StartSound(nil, sfx_mchurt)
			end
			server.P_DungeonStatus.lifeexplode = $-1
		end

		if not server.entrytime
			server.entrycard = nil
			server.entrytime = nil
		end
	end

	if NET_running() return end	-- don't run anything during character selection

	if not server.P_BattleStatus return end

	if gamemap == srb2p.tartarus_play
	or server.gamemode == GM_VOIDRUN
		for i = 1, 4
			if server.P_BattleStatus[i].battlestate ~= BS_MPFINISH
				server.P_BattleStatus[i].netstats.time = $+1
			end
		end
	end

	-- menus & shops:
	for p in players.iterate do
		if p.maincontrol and p.maincontrol.valid
			if server.P_BattleStatus[p.maincontrol.battlen] and server.P_BattleStatus[p.maincontrol.battlen].running continue end	-- nope
		end
		local mo = p.mo
		if not mo continue end

		if DNG_handleShop(mo) continue end		-- in shop, don't open the menus in that case
		if DNG_handleEquipLab(mo) continue end	-- in equip lab, don't open menu either
		D_HandleMenu(mo)	-- let menus open even without net
	end

	for p in players.iterate do
		local btl = server.P_BattleStatus
		if btl and p.P_party
			btl = btl[p.P_party]
			if btl.running continue end
		end

		-- spectators can't move in these gamemodes.
		if p.P_spectator
		and server.gamemode ~= GM_COOP
		and server.gamemode ~= GM_VOIDRUN
			PLAY_nomove(p)
			continue
		end

		DNG_HandleAbilities(p, true)
	end

	if not NET_isset() return end	-- wait until we're finished setting up our team in MP

	SRB2P_runHook("DungeonThinker", battle)

	if server.entrytime

		-- voidrun hack
		if server.gamemode == GM_VOIDRUN
		and server.P_DungeonStatus.VR_type == VC_REPEL
		and server.entrytime == TICRATE/2
		and server.P_DungeonStatus.VR_timer ~= nil

			local bwaves = {}
			server.P_DungeonStatus.VR_target = 0

			for i = 1, 3 do
				bwaves[i] = server.waves[P_RandomRange(1, #server.waves)]
				server.P_DungeonStatus.VR_target = $ + #bwaves[i]
			end

			BTL_start(1, bwaves[1])
			server.P_BattleStatus[1].storedwaves = bwaves
		end
		D_voidRun()

		return
	else

		for p in players.iterate
			if p.mo and p.mo.valid
				if p.P_spectator
					p.mo.frame = $ & ~FF_TRANSMASK
					p.mo.frame = $|FF_TRANS50
					p.mo.colorized = true
				end
			end
		end

		D_tartarusCrawler()
		if server.gamemode == GM_VOIDRUN
			D_voidRun()
			return
		end

		if not mapheaderinfo[gamemap].tartarus
		and not server.cdungeon
			for p in players.iterate do

				if not p.mo or not p.mo.valid continue end

				if D_ReadyBattle(p) continue end

			end
		end
	end
end)

//dialouge box flipping!
local textbuf	-- last text
local wwtext	-- word wrapped text

rawset(_G, "R_drawTextBox", function(v, name, text, portrait, colour, timer, texttimer)
	-- draw the portrait:
	
	local y = 130 + timer*16

	-- Text buffering:
	if text ~= textbuf
		textbuf = text
		wwtext = STR_WordWrap(v, textbuf, 160, "NFNT", FRACUNIT/2)
		-- ready a table of strings.
	end

	if portrait
		if boxflip
			PDraw(v, 225, y-32, v.cachePatch(portrait), V_SNAPTOBOTTOM, v.getColormap(TC_DEFAULT, colour))
		else
			PDraw(v, 8, y-32, v.cachePatch(portrait), V_SNAPTOBOTTOM, v.getColormap(TC_DEFAULT, colour))
		end
	end

	-- draw the text box:
	if boxflip
		PDraw(v, 54, y, v.cachePatch("H_TBG2"), V_SNAPTOBOTTOM|V_30TRANS)
		PDraw(v, 54, y, v.cachePatch("H_TBX2"), V_SNAPTOBOTTOM)
	else
		PDraw(v, 54, y, v.cachePatch("H_TBG"), V_SNAPTOBOTTOM|V_30TRANS)
		PDraw(v, 54, y, v.cachePatch("H_TBOX"), V_SNAPTOBOTTOM)
	end

	-- name
	if name
		if boxflip
			V_drawString(v, 175, y+10, name, "NFNT", V_SNAPTOBOTTOM, nil, 31, nil)
		else
			V_drawString(v, 100, y+10, name, "NFNT", V_SNAPTOBOTTOM, nil, 31, nil)
		end
	end

	-- text:
	local time = texttimer
	local cury = y+25

	for i = 1, #wwtext do
		local s = wwtext[i]:sub(1, time)
		V_drawString(v, 90, cury, s, "NFNT", V_SNAPTOBOTTOM, nil, 0, 31)
		cury = $+8
		time = $ - s:len()
		if time < 1
			break
		end	-- no use continuing if we have nothing else to draw
	end
end)

rawset(_G, "drawEvent", function(v, p)

	if not server.plentities or not #server.plentities or not server.skinlist return end	-- wait until we're finished setting up our team in MP

	local evt = server.P_DialogueStatus[p.P_party]
	if not evt.running return end
	if not evt.event return end

	local cur = eventList[evt.event][evt.eventindex]

	-- even hud, back, behind text boxes portrait etc
	if eventList[evt.event]["hud_back"]
		eventList[evt.event]["hud_back"](v, evt)
	end

	if not cur	return end

	if cur[1] == "text"	-- regular shit handling
	and evt.curtype == "text"

		local y = 130
		local tboxtimer = 0

		if evt.timers.textboxanim_in
			y = $ + (evt.timers.textboxanim_in*16)
			tboxtimer = evt.timers.textboxanim_in
		elseif evt.timers.textboxanim_out
			y = $ + (TICRATE/3 - evt.timers.textboxanim_out)*16
			tboxtimer = TICRATE/3 - evt.timers.textboxanim_out
		end

		-- draw the choices sliding in whenever possible.
		-- Choices are specific to events so it's fine to only ever handle them here.
		if textbuf ~= nil and evt.texttime >= textbuf:len()
				if cur[4]
				local top = y - 18 - (16*(#cur[4]-1))
				local dx = 210
				for i = 1, #cur[4]
					local c = cur[4][i]
					local dy = top + (i-1)*16 + (evt.timers.choices*20 or 0)

					if evt.choice == i
						PDraw(v, dx, dy, v.cachePatch("H_TBOXS2"), V_SNAPTOBOTTOM)
						V_drawString(v, 210 + 40, dy + 5, c[1], "NFNT", V_SNAPTOBOTTOM, "center", 31, 138)
					else
						PDraw(v, dx, dy, v.cachePatch("H_TBOXS1"), V_SNAPTOBOTTOM|V_30TRANS)
						V_drawString(v, dx + 40, dy + 5, c[1], "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
					end
				end
			else
				-- otherwise, draw the continue arrow
				local xpos = leveltime%10 < 5 and 100 or 102
				PDraw(v, xpos, 190, v.cachePatch("H_TCONT"), V_SNAPTOBOTTOM)
			end
		end

		local portrait = cur[7] and cur[7][1] or nil
		local colour = cur[7] and cur[7][2] or nil

		R_drawTextBox(v, cur[2], cur[3], portrait, colour, tboxtimer, evt.texttime)
	end

	-- event hud: front
	if eventList[evt.event]["hud_front"]
		eventList[evt.event]["hud_front"](v, evt)
	end

end)

//change the days until full moon
rawset(_G, "drawDate", function(v, y)
	y = $ or 0

	local save = SAVE_localtable
	if server.gamemode == GM_VOIDRUN return end	-- nobody cares!

	--save.date = {5, 6, 26, 2010, -1}

	-- render background:
	PDraw(v, 320, y, v.cachePatch("H_DATEOL"), V_SNAPTOTOP|V_SNAPTORIGHT|V_30TRANS)

	local color = 0
	if save.date[5] < 0	-- this is the dark hour
		color = 103
	end

	-- draw lunar phase
	local str = "NEXT 2"
	local pp = "H_MOON6"
	if not (mapheaderinfo[gamemap].bluemiststory) then save.date = {5, 4, 24, 2010, -1} end
	
	if server.marathon
	or not netgame
	and not (mapheaderinfo[gamemap].bluemiststory)
		str = "FULL"
		pp = "H_MOON7"
		save.date = {5, 4, 24, 2010, -1}
	end
	
	PDraw(v, 310 - V_stringWidth(v, str, "NFNT")>>FRACBITS +1, y + 25, v.cachePatch("H_MOONBG"), V_SNAPTOTOP|V_SNAPTORIGHT)
	PDraw(v, 310 - V_stringWidth(v, str, "NFNT")>>FRACBITS, y + 25, v.cachePatch(pp), V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, 310, y + 22, str, "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", color, 31)

	V_drawString(v, 310, y + 4, save.date[2].."/"..save.date[3].." "..days[save.date[1]]:sub(1, 2), "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", color, 31)

	-- draw time of day
	V_drawString(v, 310, y + 12, timeofday[save.date[5]], "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", color, 31)
end)

//same stuff, but music doesn't change. that's it.
rawset(_G, "BTL_StartBattle", function(pn, team1, team2, advantage, func, music, p1)	-- teams can be anything lol.
	local battleStatus = server.P_BattleStatus[pn]
	local bossbuf = battleStatus.boss

	BTL_softReset(pn)	-- ust i case

	battleStatus.boss = bossbuf

	-- if normalbattle is true, team2 will spawn like enemies and the camera will do preset stuff while BST_START is here.
	-- else you're free to tp the camera anywhere after calling this function
	battleStatus.running = true			-- battle is now running
	battleStatus.battletime = 0
	battleStatus.battlestate = 0
	battleStatus.emeraldpow_max = (server.cdungeon and server.cdungeon.maxep or server.difficulty)
	battleStatus.turn = 0
	battleStatus.turnorder = {}
	battleStatus.crit_seeds = {}
	battleStatus.deadplayers = {}
	battleStatus.battlestate = BS_START
	battleStatus.hudtimer.start = TICRATE*((advantage or battleStatus.boss) and 3 or 1) -- start transition
	battleStatus.advantage = advantage		-- advantage, stored here for animations and whatnot

	if battleStatus.func_buf	-- function buffer, used for some very specific instances (tutorial)
		battleStatus.func = battleStatus.func_buf
		battleStatus.func_buf = nil
	else
		battleStatus.func = func				-- used for starting events and other stuff, called at the start of each turn
	end

	battleStatus.music = music	-- save this

	battleStatus.refplayer = team1[1]	-- useful for dead players revival

	battleStatus.netstats.encounters = $ +1
	battleStatus.arena_coords[4] = $ or 0	-- angle, mostly unused

	D_endEvent(pn)

	if battleStatus.arenacenter and battleStatus.arenacenter.valid
		battleStatus.arena_coords[1] = battleStatus.arenacenter.x
		battleStatus.arena_coords[2] = battleStatus.arenacenter.y
		battleStatus.arena_coords[3] = battleStatus.arenacenter.z
		battleStatus.arena_coords[4] = battleStatus.arenacenter.angle
	end

	if server.gamemode == GM_CHALLENGE
		battleStatus.challengen = server.P_netstat.buffer.extradata
		battleStatus.timer = BTL_challengebtllist[battleStatus.challengen].time
		--battleStatus.scoretarget = BTL_challengebtllist[battleStatus.challengen].points
		--battleStatus.score = 0
		battleStatus.waven = $ or 1
	end

	local x, y, z = battleStatus.arena_coords[1], battleStatus.arena_coords[2], battleStatus.arena_coords[3]
	local dist = 256
	local currangle = battleStatus.arena_coords[4]

	local cam = battleStatus.cam
	if cam
		P_RemoveMobj(cam)
	end
	battleStatus.cam = spawnbattlecam()
	cam = battleStatus.cam

	P_TeleportMove(cam, x, y, z)
	CAM_stop(cam)
	cam.angle = currangle + ANG1*180

	local temp_an = currangle

	for k,v in ipairs(team1)	-- spawn team1 (generally players row)
		x, y = battleStatus.arena_coords[1]+dist*cos(currangle), battleStatus.arena_coords[2]+dist*sin(currangle)
		P_TeleportMove(v, x, y, z)	-- Teleport the object to the right spot.
		v.angle = currangle+ANGLE_180
		--if k <= 3
		currangle = $- (ANG1*30)
		v.shadowscale = v.scale
		--end

		v.battlen = pn	-- save which arena we're on

		-- special case for some cool stuff :)
		if battleStatus.superform
			v.status_condition = COND_SUPER
			local stats = {"strength", "magic", "endurance", "agility", "luck"}
			for i = 1, #stats do
				v[stats[i]] = $+25
			end
		end

		if v.enemy
			if not BTL_initEnemy(v)	-- this would be very unexpected.
				dprint("Failed to generate enemy "..v.enemy)
				P_RemoveMobj(v.enemy)
				updateUDtable(team1)
				continue
			end

			if v.gold
				v.expval = enemyList[v.enemy].r_exp *2
				v.enemy = "maya_gold"

				-- restart the enemy generation...
				if not BTL_initEnemy(v)	-- this would be very unexpected.
					dprint("Failed to generate enemy "..v.enemy)
					P_RemoveMobj(v.enemy)
					updateUDtable(team1)
					continue
				end

				if server.gamemode == GM_COOP and server.difficulty

					local stats_diff = {
						11,
						22,
						33,
						55,
						88,
						99,
						99,
					}

					local st = stats_diff[server.difficulty] or 99
					print(st)
					v.agility = st
					v.luck = st
				end
			end


			if v.extra
				v.status_condition = COND_HYPER
				local stats = {"strength", "magic", "endurance", "agility", "luck"}
				for i = 1, #stats do
					v[stats[i]] = $+10
				end
			end

		end

		v.enemies = copyTable(team2)
		v.allies = copyTable(team1)
		v.allies_noupdate = copyTable(team1)	-- this table doesn't update, we use it for HUD displaying (players hp bars)
		v.enemies_noupdate = copyTable(team2)	-- this table doesn't update, we use it for reviving
		v.saveskills = copyTable(v.skills)		-- for skill cards and sub persona reverting
		if v.plyr
			PLYR_getStats(v, v.level, true)
		end
		v.savestats = {v.strength, v.magic, v.endurance, v.agility, v.luck}	-- back up stats
		v.flags2 = $ & ~MF2_DONTDRAW
		ANIM_set(v, v.anim_stand, true)
		BTL_initAdditionalSkills(v)
		BTL_setupstats(v)

		-- finally equip the subpersona
		if v.subpersona
			BTL_equipSubPersona(v, v.subpersona)
		else
			BTL_splitSkills(v)
		end

		BTL_initSkillChange(v)

		local new_skills = {} --preform a duplicate skill check now, because
		for i = 1, #v.skills --splitskills gets triggered twice
			local dupecheck = false
			for z = 1, #v.skills
				if v.skills[i] == v.skills[z]
				and i > z
					dupecheck = true
				end
			end
			if not dupecheck
				table.insert(new_skills, v.skills[i])
			end
		end
		v.skills = new_skills
		new_skills = {}
		for i = 1, #v.passiveskills
			local dupecheck = false
			for z = 1, #v.passiveskills
				if v.passiveskills[i] == v.passiveskills[z]
				and i > z
					dupecheck = true
				end
			end
			if not dupecheck
				table.insert(new_skills, v.passiveskills[i])
			end
		end
		v.passiveskills = new_skills
		new_skills = nil

		battleStatus.fighters[#battleStatus.fighters+1] = v
		BTL_addtoplist(battleStatus, v)

		-- check for PSV_STARTBATTLE skills and execute them!

		for i = 1, #v.passiveskills
			local psv = v.passiveskills[i]
			if attackDefs[psv]
				psv = attackDefs[$]
				if psv.passive == PSV_STARTBATTLE
				and psv.anim
					psv.anim(v, {v}, {v}, 1)	-- Execute this skill's anim function on myself ONCE.
				end
			end
		end

		if advantage == 1	-- team 1 has the advantage!
			v.priority = 16
		else
			v.priority = 0
		end
	end

	currangle = temp_an + ANG1*180 --ANGLE_180+ANGLE_90+ANG1*20

	for k,v in ipairs(team2)	-- spawn team2 (generally enemies row)
		x, y = battleStatus.arena_coords[1]+dist*cos(currangle), battleStatus.arena_coords[2]+dist*sin(currangle)
		P_TeleportMove(v, x, y, z)	-- Teleport the object to the right spot.
		v.angle = currangle+ANGLE_180
		--if k <= 3
		currangle = $- (ANG1*30)
		v.shadowscale = v.scale
		--else
			--currangle = ANG1*154
		--end

		v.battlen = pn	-- save which arena we're on

		if v.enemy	-- enemy stat initialization
			if not BTL_initEnemy(v)
				dprint("Failed to generate enemy "..v.enemy)
				P_RemoveMobj(v)
				updateUDtable(team1)
				continue
			end

			if v.extra
				v.status_condition = COND_HYPER
				local stats = {"strength", "magic", "endurance", "agility", "luck"}
				for i = 1, #stats do
					v[stats[i]] = $+10
				end
			end

			if v.gold
				v.expval = enemyList[v.enemy].r_exp *4
				v.enemy = "maya_gold"

				-- restart the enemy generation to make a gold shadow.
				if not BTL_initEnemy(v)
					dprint("Failed to generate enemy "..v.enemy)
					P_RemoveMobj(v.enemy)
					updateUDtable(team1)
					continue
				end


				if server.gamemode == GM_COOP and server.difficulty

					local stats_diff = {
						11,
						22,
						33,
						55,
						88,
						99,
						99,
					}

					local st = stats_diff[server.difficulty] or 99
					v.agility = st
					v.luck = st
				end

			end
		end

		v.enemies = copyTable(team1)
		v.allies = copyTable(team2)
		v.allies_noupdate = copyTable(team2)
		v.enemies_noupdate = copyTable(team1)	-- this table doesn't update, we use it for reviving
		v.saveskills = copyTable(v.skills)	-- you never know
		v.savestats = {v.strength, v.magic, v.endurance, v.agility, v.luck}	-- back up stats
		BTL_initAdditionalSkills(v)
		BTL_setupstats(v)

		-- in battle, we cannot use passive skills
		BTL_splitSkills(v)
		v.flags2 = $ & ~MF2_DONTDRAW

		-- rather unlikely
		if v.subpersona
			BTL_equipSubPersona(v, v.subpersona)
		end

		for i = 1, #v.passiveskills
			local psv = v.passiveskills[i]
			if attackDefs[psv]
				psv = attackDefs[$]
				if psv.passive == PSV_STARTBATTLE
				and psv.anim
					psv.anim(v, {v}, {v}, 1)	-- Execute this skill's anim function on myself ONCE.
				end
			end
		end

		if server.gamemode ~= GM_PVP
			v.sprite = SPR_ENMA
			v.frame = A
		end

		if advantage == 2	-- team 2 has the advantage!
		and not bossbuf
			v.priority = 16
		else
			v.priority = 0
		end

		if advantage~= nil
		and advantage < 3	-- specific to team2. This makes them invisible and then pop up like bad guys!
							-- this is handled later on in the BS_START handler.
			battleStatus.starttype = 0
			v.enemy_spawndelay = TICRATE*2 + (TICRATE/6)*k
			if k == 1
				P_TeleportMove(cam, v.x + 10*cos(v.angle), v.y + 10*sin(v.angle), v.z)
				cam.aiming = -ANG1*60
			end
		end
		battleStatus.fighters[#battleStatus.fighters+1] = v
		BTL_addtoplist(battleStatus, v)
	end

	if battleStatus.boss
		battleStatus.advantage = 2	-- weird hack, alright
	end

	-- I was about to forget...
	for i = 1, #battleStatus.plist do
		local p = battleStatus.plist[i]
		if not p or not p.valid continue end
		S_StartSound(nil, sfx_battle, p)	-- IT'S TIME!
		if server.gamemode ~= GM_VOIDRUN and not (mapheaderinfo[gamemap].nomusicstop) 
			S_StopMusic(p)
		end
	end

	-- pvp: make the camera start differently from how it does in regular pve battles
	if server.gamemode == GM_PVP
		local dist = 1024
		local currangle = P_RandomRange(0, 359)*ANG1
		local x, y = battleStatus.arena_coords[1]+dist*cos(currangle), battleStatus.arena_coords[2]+dist*sin(currangle)
		P_TeleportMove(cam, x, y, 224*FRACUNIT)
		cam.aiming = ANG1*5
		cam.angle = R_PointToAngle2(cam.x, cam.y, battleStatus.arena_coords[1], battleStatus.arena_coords[2])

		x, y = battleStatus.arena_coords[1]+dist*2*cos(currangle), battleStatus.arena_coords[2]+dist*2*sin(currangle)
		CAM_goto(cam, x, y, 512*FRACUNIT, FRACUNIT/2)
	end

	SRB2P_runHook("BattleStart", battleStatus)
end)

//set players level to 85
local difficulty_levels = {
	[1] = 10,	-- beginner
	[2] = 15,	-- easy
	[3] = 20,	-- normal
	[4] = 35,	-- hard
	[5] = 50,	-- spicy
	[6] = 65,	-- risky
	[7]	= 80,	-- nightmare
}

PLYR_spawn = function(team)

	server.plentities = {}
	local maxteam = server.P_netstat.teamlen
	for i = 1, 4
		server.plentities[i] = {}
	end

	server.skinlist = team

	for pa = 1, #team
		for i = 1, #team[pa]

			local mo = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
			mo.commandflags = 0
			mo.skin = team[pa][i] or "sonic"
			mo.state = S_PLAY_STND
			mo.color = skins[mo.skin].prefcolor

			local useskin = mo.skin
			local data

			if not charStats[mo.skin]
				print("\x82".."ERROR: ".."\x80".."Skin \'"..mo.skin.."\' has no charStats. Reverting back to Sonic's stats")
				useskin = "sonic"
			end
			data = charStats[useskin]

			mo.name = data.name or "ERRORNAME"
			mo.level = server.difficulty and difficulty_levels[server.difficulty] or 10	-- for now this is it.
			mo.levelcap = server.difficulty and difficulty_cap[server.difficulty] or 99	-- levelcap 99 by default

			if server.gamemode == GM_PVP
				mo.level = 80
				if server.bossmode
					mo.level = min(99, server.bosslevel-3)
				end
				mo.levelcap = mo.level
				-- eventually, allow this to be set dynamically or smth
			elseif server.gamemode == GM_VOIDRUN
				mo.level = 1
				mo.levelcap = 1
			elseif server.cdungeon	-- custom dungeons
				mo.level = server.cdungeon.level
				mo.levelcap = server.cdungeon.levelcap or mo.level	-- whatever exists
			elseif (mapheaderinfo[gamemap].bluemiststory)
				mo.level = 85
				mo.levelcap = 85
			end

			if server.gamemode == GM_CHALLENGE
				if BTL_challengebtllist[server.P_netstat.buffer.extradata].level
					mo.level = BTL_challengebtllist[server.P_netstat.buffer.extradata].level
				end

				if BTL_challengebtllist[server.P_netstat.buffer.extradata].levelcap
					mo.levelcap = BTL_challengebtllist[server.P_netstat.buffer.extradata].levelcap
				elseif not mo.levelcap
					mo.levelcap = 99
				end	-- default level cap @ 99
			end


			mo.exp = 0-- set EXP
			mo.melee = data.melee_natk

			/*mo.atk = data.atk or 30
			-- increase atk by difficulty factor in multiplayer:
			mo.atk = $+ (difficulty_atk[server.difficulty] or 0)
			mo.acc = data.acc or 85
			mo.crit = data.crit or 3*/

			mo.party = pa	-- keep track of our party #
			mo.battlen = pa	-- this can be initiated at the same time.

			local setpersona = data.persona or "orpheus"
			if server.gamemode == GM_VOIDRUN
				setpersona = "unequipped"
			end

			PLYR_initPersona(mo, setpersona, useskin)
			PLYR_initAnims(mo, useskin)
			BTL_readybuffs(mo)

			if data.overlay
				local o = P_SpawnMobjFromMobj(mo, 0, 0, 0, data.overlay)
				o.target = mo
				mo.overlay = o
				--dprint("Spawned overlay for skin "..mo.skin)
			end

			local firstvalidp	-- fallback for bots
			local plist = server.playerlist[pa]

			--for k, p in ipairs(plist)
			for j = 1, server.P_netstat.teamlen
				local p = plist[j]
				if p and p.valid and p.mo and p.mo.valid
					firstvalidp = p
					break
				end
			end

			-- control player
			local controlp = (plist[i] and plist[i].valid) and plist[i] or firstvalidp

			dprint("PA #"..pa..": Assigning control of bot "..i.." to "..(controlp and controlp.name or "ERRORNAME"))
			/*if players[i-1]
				PLYR_setcontrol(mo, players[i-1])
			end*/
			PLYR_setcontrol(mo, controlp, plist[i] == controlp)	-- assign control to a player
			mo.plyr = true	-- we are players, not normal enemies.
							-- this is used for summon animation, and enables control by player.
							-- EVEN if the player is in an opposing team!
			mo.coreentity = true
							-- do not remove on battle end, if we happen to be enemies!

			-- uncomment this line and change the test entity to any enemy if you want some fun :P
			/*if i == 2
				mo.enemy = "test_entity"
			end*/
			table.insert(server.plentities[pa], mo)
			mo.flags2 = $|MF2_DONTDRAW
			mo.stats = useskin

			-- EQUIPMENT. Set it last because we need a bunch of stuff first
			-- get weapon name
			local wpn = data.wep
			if not weaponsList[wpn]
				wpn = "shoes_01"
			end	-- you never know...

			equipWeapon(mo, makeWeapon(wpn))

			-- for wardring, use basic ring and don't ever enhance it.
			equipRing(mo, makeRing("ring_01"))

			-- buff weapon w/ difficulty
			if server.cdungeon
				-- custom dungeons can have their own buff values:
				mo.weapon.atk = $ + server.cdungeon.weapon_addpow
				mo.wardring.def = $ + server.cdungeon.armour_adddef

			elseif server.difficulty	-- exploration
			and server.gamemode == GM_COOP
				mo.weapon.atk = $ + (difficulty_atk[server.difficulty] or 0)*10
				mo.wardring.def = $ + (difficulty_def[server.difficulty] or 0)*10
			end

			mo.weapon.acc = $ or 95
			mo.weapon.crit = $ or 5


			if server.gamemode == GM_PVP
			and not server.bossmode	-- keep everything the same for boss mode
				mo.sp = $/3
				mo.maxsp = mo.sp
				-- more HP but less SP, for balance.
			end
		end
	end
end

rawset(_G, "damageObject", function(mo, damage, damagestate, reset)		-- damage an object
	-- set damage to nil to use the sevrer pre-calculated damage!
	local btl = server.P_BattleStatus[mo.battlen]

	if (mo.enemy and not mo.deathanim and enemyList[mo.enemy].deathanim)
		return
	end	-- Shouldn't be damaged, has technically died but is still here, perhaps due to a cutscene?

	-- fallbacks to prevent errors
	if mo.atk_hitby == nil
		mo.atk_hitby = BTL_copyAttackDefs(attackDefs["dummy"])	-- make do
	end
	if mo.atk_attacker == nil or not mo.atk_attacker.valid
		mo.atk_attacker = mo	-- we need SOMETHING
	end

	if reset
		resetDamage(mo)
	end

	if damagestate
		mo.damagestate = damagestate
	end

	-- status only attack, don't bother!
	if mo.damagestate == DMG_STATUS
	and mo.cachestatus
	--and not mo.boss
	and not SAVE_localtable.tutorial	-- no status condition on tutorials, they might break stuff
		inflictStatus(mo, mo.cachestatus)
		mo.cachestatus = nil
		mo.damaged = 1
		mo.damage_wait = 1
		return
	end

	if not mo.damageflags
		mo.damageflags = 0
	end

	mo.damageflags = $|DF_HP

	-- heals and baton pass:
	if damage and damage < 0	-- negative damage means heals!
		mo.damagestate = DMG_NORMAL
		local batonbuff = mo.atk_attacker.batonpassbuff or 0
		damage = $ + damage * batonbuff/100
		damage = $ + damage * mo.atk_attacker.buffs["mag"][1] /100

		-- while we're here, handle serene grace (and other heal boosts)
		-- heal boost must be checked from the attacker!
		for i = 1, #mo.atk_attacker.passiveskills

			local a = attackDefs[mo.atk_attacker.passiveskills[i]]
			if a and a.passive == PSV_BOOST and (a.type & ~ATK_PASSIVE) & ATK_HEAL	-- healing boost!
				damage = $ + damage*a.power/100	-- boost by power%.
												-- also stacks!
			end
		end

		-- in PVP; healing is reduced by half
		-- unless it's a revive (hp <= 0)
		if server.gamemode == GM_PVP
		and mo.hp > 0
		and mo.atk_hitby.power and mo.atk_hitby.power >= 999	-- only apply this to diarahan
			damage = $/2
		end

		damage = max($, -mo.maxhp)

		if mo.atk_attacker ~= mo
			VFX_Play(mo, VFX_HEAL)	-- say thanks to your healer, asshole!
		else
			VFX_Play(mo, VFX_HEALSELF)	-- don't thank yourself fucking idiot
		end
	end

	local atktype = mo.atk_hitby.type
	local nihilwep

	if mo.atk_hitby.physical and mo.atk_attacker and mo.atk_attacker.weapon and mo.atk_attacker.weapon.element
		atktype = mo.atk_attacker.weapon.element
		nihilwep = true	-- draw nihil weapon effects on-hit
	end

	-- Almighty *destroys* barriers.
	if mo.atk_hitby and atktype == ATK_ALMIGHTY
	and (mo.makarakarn or mo.tetrakarn or mo.tetraja)
		BTL_logMessage(mo.battlen, mo.name.."'s barrier couldn't\nwithstand the Almighty attack!")
		mo.makarakarn = nil
		mo.tetrakarn = nil
		mo.tetraja = nil

		playSound(mo.battlen, sfx_bufu6)
	end

	-- attack is to be repelled; show this:
	if mo.repelto
	and mo.atk_hitby.anim_norepel
		local t = mo.repelto
		local x, y = t.x + 32*cos(t.angle), t.y + 32*sin(t.angle)
		local s = P_SpawnMobj(x, y, t.z+mo.height/2, MT_DUMMY)
		s.scale = FRACUNIT/2
		s.destscale = FRACUNIT*3
		s.scalespeed = FRACUNIT/3
		s.fuse = TICRATE/2
		s.sprite = t.repelspr
		s.frame = $|FF_PAPERSPRITE
		s.angle = t.angle + ANG1*90
		playSound(mo.battlen, sfx_reflc)
		t.repelspr = nil
	end
	mo.repelto = nil

	-- mo already blocked the damage.
	if mo.damagestate == DMG_BLOCK
		playSound(mo.battlen, sfx_hamas2)
		mo.damaged = 1

		if mo.atk_attacker and mo.atk_attacker.valid
			VFX_Play(mo.atk_attacker, VFX_MISS)
		end

		if mo.tetraja
			BTL_logMessage(mo.battlen, "Tetraja blocked the attack!")
			mo.tetraja = nil
		end

		if mo.homunculus	-- homunculus sacrifice takes the form of a block with mo.homunculus being != nil
			BTL_logMessage(mo.battlen, "The Homunculus sacrificed itself!")
			mo.homunculus = nil
		end
		run_ondamagepassives(mo)
		return
	end
	local downsyndrome, dmgtable

	if damage == nil
		dmgtable = btl.dmg_hits
		if not dmgtable[mo.dmg_index]	-- something went wrong.
			mo.damaged = 1	-- ????
			mo.damagestate = DMG_MISS	-- just miss.
			-- Only case where we will directly set DMG_MISS here

			--dprint("ERROR: No damage value was here. Did something go wrong?")
		else
			damage = dmgtable[mo.dmg_index][1]
			table.remove(dmgtable[mo.dmg_index], 1)
		end
		local downtable = btl.dmg_downs	-- do we get adhd this turn
		if not downtable[mo.dmg_index]
			downsyndrome = nil
		else
			downsyndrome = downtable[mo.dmg_index][1]
			table.remove(downtable[mo.dmg_index], 1)
		end
		if mo.barrier
			playSound(mo.battlen, sfx_s1b4)
			damage = 0
			return
		end
		if mo.counter
			mo.countered = true
			return
		end
		if timestop
			playSound(mo.battlen, sfx_hit)
			mo.timestopdamage = $ + damage
			return
		end
		//give ultra instinct warp passive if you have red emerald
		for k,v in ipairs(mo.skills)
			if v == "platform warp" and P_RandomRange(1, 3) == 1
				playSound(mo.battlen, sfx_portal)
				playSound(mo.battlen, sfx_psi)
				VFX_Play(mo, VFX_DODGE)
				BTL_logMessage(mo.battlen, "The red Chaos Emerald warped " + mo.name + " out of harm!")
				mo.warpdodge = true
				return
			end
		end
		if type(damage) != "string" //dont do the emerald effect it if it misses
			if mo.atk_attacker.emeraldmode
				local mode = mo.atk_attacker.emeraldmode
				if mode == 1
					if btl.emeraldpow > 0 or mo.status_condition == COND_HYPER
						playSound(mo.battlen, sfx_antiri)
						playSound(mo.battlen, sfx_kc59)
						local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
						thok.state = S_INVISIBLE
						thok.tics = 1
						thok.scale = FRACUNIT*4
						A_OldRingExplode(thok, MT_SUPERSPARK)
						btl.emeraldpow = $-35
						if mo.status_condition == COND_HYPER
							cureStatus(mo)
						end
					end
				end
				if mode == 2
					playSound(mo.battlen, sfx_absorb)
					if mo.atk_hitby.hits
						damageSP(mo, 50/mo.atk_hitby.hits)
					else
						damageSP(mo, 50)
					end
					local dbuff = P_SpawnMobj(mo.x, mo.y, mo.z+mo.height, MT_DUMMY)
					dbuff.state = S_DBUFF1
					dbuff.color = SKINCOLOR_TEAL
					dbuff.scale = FRACUNIT*5/2
				end
				if mode == 3
					if mo.status_condition ~= COND_HYPER
						playSound(mo.battlen, sfx_psi)
						cureStatus(mo)
						//burn, freeze, poison, or dizzy
						local statuses = {COND_BURN, COND_FREEZE, COND_POISON, COND_DIZZY}
						inflictStatus(mo, statuses[P_RandomRange(1, #statuses)])
					end
				end
				if mode == 4
					local colors = {SKINCOLOR_ORANGE, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD, SKINCOLOR_YELLOW}
					local strs = {"atk", "mag", "def", "agi", "crit"}
					playSound(mo.battlen, sfx_status)
					for j = 1, 16
						local orb = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						orb.momx = P_RandomRange(-16, 16)<<FRACBITS
						orb.momy = P_RandomRange(-16, 16)<<FRACBITS
						orb.momz = P_RandomRange(-16, 16)<<FRACBITS
						orb.destscale = 0
						orb.frame = A
						orb.color = colors[P_RandomRange(1, #colors)]
					end
					for j = 1, #strs
						local s = strs[j]
						if mo.buffs[s][1] > 0
							mo.buffs[s][1] = 0
							mo.buffs[s][2] = 0
						end
					end
					BTL_logMessage(mo.battlen, "Stat increases nullified")
				end
				if mode == 5
					if P_RandomRange(1, 2) == 1
						playSound(mo.battlen, sfx_zio1)
						for i=1,20
							local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
							b.momx = P_RandomRange(-8, 8)*FRACUNIT
							b.momy = P_RandomRange(-8, 8)*FRACUNIT
							b.momz = P_RandomRange(-8, 8)*FRACUNIT
							b.scale = FRACUNIT*3
							b.state = S_SSPK1
						end
						startField(mo, FLD_ZIOVERSE, 4)
					else
						playSound(mo.battlen, sfx_wind1)
						for i = 1, 2
							local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							s.scale = FRACUNIT/4
							s.sprite = SPR_SLAS
							s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
							s.destscale = FRACUNIT*9
							s.scalespeed = FRACUNIT
							s.tics = TICRATE/3
						end
						startField(mo, FLD_GARUVERSE, 4)
					end
				end
				if mode == 6
					local buffs = {"atk", "mag", "def", "agi"}
					local randstat = buffs[P_RandomRange(1, #buffs)]
					for i = 1,16
						local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.scale = FRACUNIT*2
						if randstat == "atk"
							dust.color = SKINCOLOR_ORANGE
						elseif randstat == "mag"
							dust.color = SKINCOLOR_TEAL
						elseif randstat == "def"
							dust.color = SKINCOLOR_LAVENDER
						elseif randstat == "agi"
							dust.color = SKINCOLOR_GREEN
						end
					end
					buffStat(mo, randstat, 25*P_RandomRange(-3, 3))
					if randstat == "atk"
						BTL_logMessage(mo.battlen, "Physical Attack randomized!")
					elseif randstat == "mag"
						BTL_logMessage(mo.battlen, "Magic Attack randomized!")
					elseif randstat == "def"
						BTL_logMessage(mo.battlen, "Defense randomized!")
					elseif randstat == "agi"
						BTL_logMessage(mo.battlen, "Agility randomized!")
					end
					playSound(mo.battlen, sfx_cdfm44)
					playSound(mo.battlen, sfx_s3k73)
				end
				if mode == 7 and gamemap == 12 //just in case
					mo.locked = true
					local g = P_SpawnGhostMobj(mo)
					g.color = SKINCOLOR_WHITE
					g.colorized = true
					g.destscale = FRACUNIT*6
					g.frame = $|FF_FULLBRIGHT
					playSound(mo.battlen, sfx_cdfm28)
					playSound(mo.battlen, sfx_cdfm34)
					BTL_logMessage(mo.battlen, mo.name.." is locked to the platform!")
				end
			end
		end
	else
		if mo.counter
			mo.countered = true
			return
		end
		if timestop
			playSound(mo.battlen, sfx_hit)
			mo.timestopdamage = $ + damage
			return
		end
		mo.atk_hitby = $ or mo.attack	-- oh well!
	end

	if not mo.hitstaken
		mo.hitstaken = 1
	else
		mo.hitstaken = $+1
	end

	-- damage is a miss:
	if type(damage) == "string"
		-- before applying this damagestate, check if there are hits remaining
		if dmgtable and #dmgtable[mo.dmg_index]	-- < more damage left
		or mo.damaged	-- was already damaged
		or mo.damagetaken -- ditto
			return	-- don't do anything, only miss on the last hit if we weren't damaged already!
		end

		mo.damaged = 1
		mo.damagestate = DMG_MISS

		VFX_Play(mo, VFX_DODGE)
		if mo.atk_attacker and mo.atk_attacker.valid	-- might not exist?
			VFX_Play(mo.atk_attacker, VFX_MISS)
		end

		if mo.passivedodge
			BTL_logMessage(mo.battlen, mo.passivedodge)
		end

		if mo.guaranteedevasion
			BTL_logMessage(mo.battlen, "The attack won't connect!")
		end

		mo.dodgeanim = TICRATE/2
		run_ondamagepassives(mo)
		return
	end

	local canknockdown = mo.status_condition ~= COND_HYPER and ((not mo.boss) or (mo.endboss and damage >= (mo.hp-1)))

	if type(damage) == "number"
		if damage > 0	-- we got hurt
			mo.redhp = mo.hp
			mo.hp = max(0, $-damage)

			if btl.scoremode	-- implicit: GM_CHALLENGE
			and not mo.plyr	-- damaging an enemy in challenge score mode

				BTL_addScore(mo.battlen, damage*2*(downsyndrome and 2 or 1))
				-- pts + damage*2 or damage*4 if knockdown

				if mo.hp == 0	-- enemy defeated
					BTL_addScore(mo.battlen, 1000, "Enemy defeated!")
				end
			end

			if mo.state ~= S_INVISIBLE
				ANIM_set(mo, mo.anim_hurt)
			end

			if mo.plyr	-- we are a player, technically!
				S_StartSound(mo, sfx_s1c6)
				for i = 1, min(damage, 8)
					local ring = P_SpawnMobj(mo.x, mo.y, mo.z, MT_FLINGRING)
					ring.momx = P_RandomRange(-16, 16)*FRACUNIT
					ring.momy = P_RandomRange(-16, 16)*FRACUNIT
					ring.momz = P_RandomRange(0, 16)*FRACUNIT
					ring.flags = $ & ~MF_SPECIAL
					ring.fuse = TICRATE
				end
			end

			if nihilwep
				if atktype == ATK_FIRE
					playSound(mo.battlen, sfx_fire1)
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.state = S_QUICKBOOM1
						b.scale = FRACUNIT*3
					end

				elseif atktype == ATK_ICE

					playSound(mo.battlen, sfx_bufu4)
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_BUFU_PARTICLE)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.scale = FRACUNIT*3
					end

				elseif atktype == ATK_ELEC

					playSound(mo.battlen, sfx_zio1)
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.scale = FRACUNIT*3
						b.state = S_SSPK1
					end

				elseif atktype == ATK_WIND
					playSound(mo.battlen, sfx_wind1)
					for i = 1, 2
						local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						s.scale = FRACUNIT/4
						s.sprite = SPR_SLAS
						s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
						s.destscale = FRACUNIT*9
						s.scalespeed = FRACUNIT
						s.tics = TICRATE/3
					end

				elseif atktype == ATK_PSY
					playSound(mo.battlen, sfx_s3k83)
					local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.color = psiocolors[P_RandomRange(1, #psiocolors)]
					end

				elseif atktype == ATK_NUCLEAR
					playSound(mo.battlen, sfx_megi6)
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.state = S_QUICKBOOM1
						b.colorized = true
						b.color = SKINCOLOR_TEAL
						b.scale = FRACUNIT*3
					end

				elseif atktype == ATK_BLESS
					playSound(mo.battlen, sfx_hamas1)
					local speeds = {FRACUNIT/16, FRACUNIT/10, FRACUNIT/3, FRACUNIT/8}
					local fuses = {20, 16, 8, 16}

					for i = 1, 4
						local l = P_SpawnMobj(mo.x, mo.y, mo.z + FRACUNIT*32, MT_THOK)	-- mt_thok for auto fadeout
						l.tics = -1
						l.sprite = SPR_CARD
						l.color = SKINCOLOR_YELLOW
						l.frame = L|(i== 2 and TR_TRANS40 or TR_TRANS70)|FF_FULLBRIGHT
						l.scale = FRACUNIT/2
						l.destscale = FRACUNIT*6
						l.scalespeed = speeds[i]
						l.fuse = fuses[i]
					end

				elseif atktype == ATK_CURSE
					playSound(mo.battlen, sfx_eih4)
					local psiocolors = {SKINCOLOR_BLACK, SKINCOLOR_WHITE, SKINCOLOR_RED}
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.color = psiocolors[P_RandomRange(1, #psiocolors)]
					end
				end
			end

			-- ready Link properties.
			if mo.atk_hitby
			and mo.atk_hitby.link
			and mo.atk_attacker.attackref
			and btl.battlestate ~= BS_LINK	-- don't reset links during links (lol)

				local numlinks = 1
				local linkdamage = 0
				-- check attacker passives (psv_linkhits, psv_linkboost)
				for i = 1, #mo.atk_attacker.passiveskills
					local s = attackDefs[mo.atk_attacker.passiveskills[i]]

					if not s continue end
					if s and s.passive and s.passive == PSV_LINKHITS
						numlinks = max($, s.accuracy)
					elseif s and s.passive and s.passive == PSV_LINKBOOST
						linkdamage = max($, s.power)
					end
				end

				if mo.atk_attacker.attackref
				and attackDefs[mo.atk_attacker.attackref]
				and not attackDefs[mo.atk_attacker.attackref].link
					return	-- !?
				end

				-- Link set
				mo.linkstate = {
					link = 0,
					maxlink = numlinks,
					linkboost = linkdamage,
					atkref = mo.atk_attacker.attackref,
					entref = mo.atk_attacker,
					dmg = damage,
				}
			end

			-- Hooks
			SRB2P_runHook("FighterDamage", mo, mo.atk_attacker)
		else			-- we got healed
			mo.redhp = min(mo.maxhp, mo.hp-damage)
		end
		if not mo.damagetaken then mo.damagetaken = 0 end

		if not mo.damagetype
			mo.damagetaken = $+damage
		else
			mo.damagetaken = damage
		end
		mo.damagetype = 0

		if mo.plyr and damage > 0	-- don't shake if we got healed lmao
			P_StartQuake(FRACUNIT*7, 4)
		end

		-- inflict status conition?
		-- / freeze gets broken out of if you get hit (not anymore as of 1.3)
		/*if mo.status_condition == COND_FREEZE
		and damage > 0
			mo.status_condition = 0
			BTL_logMessage(mo.battlen, mo.name.." was broken out of the ice!")*/

		-- / or wake up
		if mo.status_condition == COND_SLEEP
		and damage > 0
			mo.status_condition = 0
			BTL_logMessage(mo.battlen, mo.name.." was woken up!")

		elseif mo.atk_attacker ~= mo
		and mo.atk_attacker and mo.atk_attacker.valid
		and mo.atk_attacker and mo.atk_attacker.status_condition == COND_HEX
		and damage > 0
			-- ...they take damage!
			mo.atk_attacker.atk_attacker = mo
			mo.atk_hitby = attackDefs["dummy"]
			damageObject(mo.atk_attacker, min(mo.atk_attacker.hp-1, damage/2))

		elseif mo.cachestatus
		and not SAVE_localtable.tutorial
		and mo.damagestate ~= DMG_DRAIN
			inflictStatus(mo, mo.cachestatus)
			mo.cachestatus = nil
		end

		-- handle knock down?
		local gotdown
		if mo.atk_hitby and (downsyndrome or mo.damagestate == DMG_WEAK)
		and not mo.guard
		and canknockdown
			playSound(mo.battlen, sfx_crit)

			mo.downanim = 10	-- oof
			if not mo.down
				ANIM_set(mo, mo.anim_getdown)
			end

			if not mo.down
				btl.netstats.knockdowns = $ +1
			end

			mo.down = true	-- down is a separate status condition
			gotdown = true
			if mo.crituptheass2
				mo.crituptheass = true
				mo.hudpop = 1
			end
		end

		if mo.hp	-- play voices!
		and damage > 0
			VFX_Play(mo, (gotdown or damage > mo.maxhp/2) and VFX_HURTX or VFX_HURT)
		end

	else	-- if it's not a number, then that's a miss
		/*if not mo.damagetaken
			mo.damagetaken = "MISS"
		end*/
	end
	if mo.damaged
		mo.damaged = 5	-- don't pop the earth again
	else
		mo.damaged = 1
	end
	mo.damage_wait = 0

	if damage and damage > 0
		mo.guard = nil		-- we aren't guarding anymore. But only if we took damage that was POSITIVE. (negative damage = healing)
	end

	if not mo.coreentity	-- thing getting damaged is an unimportant enemy
	and damage and type(damage) == "number"	-- reminder that string damage is a miss.
	and btl.dmg_actor and btl.dmg_actor.plyr
		local fill = min(mo.hp, damage)/3
		fill = min($, 34)
		fill = max($, 5)
		if downsyndrome	-- enemy was knocked down this turn
		or mo.damagestate == DMG_TECHNICAL
		or mo.damagestate == DMG_WEAK
		or mo.damagestate == DMG_CRITICAL
			fill = $*3/2
		end

		-- lower this amount for multi target attacks:
		if btl.dmg_actor and btl.dmg_actor.plyr and btl.dmg_actor.targets and #btl.dmg_actor.targets
			fill = $ / #btl.dmg_actor.targets
		end

		-- lower this by the amount of hits the attack does
		if mo.atk_hitby and mo.atk_hitby.hits
			fill = $ / mo.atk_hitby.hits
		end

		if mo.fieldstate and mo.fieldstate.type == FLD_AGIVERSE
			fill = $*2
		end

		-- fill emerald gauge with the damage we've done!
		fillEmeraldGauge(btl.dmg_actor, fill)
	end

	-- drain sfx
	if mo.damagestate == DMG_DRAIN
		playSound(mo.battlen, sfx_absorb)
		if mo.atk_attacker and mo.atk_attacker.valid
			VFX_Play(mo.atk_attacker, VFX_MISS)
		end
	end

	-- endure!
	if mo.endured	-- print a message if we endured the skill
		BTL_logMessage(mo.battlen, mo.name.." endured the attack!")
		mo.endured = nil
	end

	-- endboss shit
	if mo.endboss and not btl.holdupfinish
		mo.hp = max($, 1)
	elseif btl.holdupfinish
		mo.hp = 0
	end

    if downsyndrome
        local popup = max(0, ((damage*100)/mo.maxhp)/5)
        P_SetObjectMomZ(mo, FRACUNIT*(min(11, 3+popup)))
    end

	if mo.swordbreaker	-- homunculus sacrifice takes the form of a block with mo.homunculus being != nil
		BTL_logMessage(mo.battlen, mo.swordbreaker.." activated!")
		mo.swordbreaker = nil
	end

	local dmgnum = type(damage) == "number"

	if mo.plyr and dmgnum
		if damage >= 0
			btl.netstats.damagetaken = $+ damage
		else
			btl.netstats.damagehealed = $- damage
		end
	elseif type(damage) == "number" and damage >= 0
		btl.netstats.damagedealt = $ +damage
	end

	-- handle some field shit:
	if (dmgnum and damage > 0) and mo.fieldstate
	and mo.atk_attacker
	and mo.atk_attacker ~= mo	-- not if you attacked yourself somehow
	and mo and mo.valid	--??
	and btl.turnorder[1] ~= mo	-- repels, counters...???
	and mo.hp
	and mo.damagestate ~= DMG_DRAIN


		if mo.fieldstate.type == FLD_GARUVERSE

			playSound(mo.battlen, sfx_heal)
			mo.atk_attacker.atk_attacker = mo.atk_attacker	--... yes, we need to set this manually and this looks horrible LOL
			mo.atk_attacker.atk_hitby = BTL_copyAttackDefs(attackDefs["dia"])	-- yeah this is horrible alright.

			local div = 4
			if mo.atk_hitby.target == TGT_ALLENEMIES
				div = #mo.allies +5
			end

			if btl.battlestate == BS_LINK
				div = $*6
			end	-- only restore 12.5% of damage dealt with link skills
			
			//DONT HEAL IF YOU A DEAD MF
			if mo.atk_attacker.hp
				damageObject(mo.atk_attacker, -(abs(damage)*3/div))
			end

		elseif mo.fieldstate.type == FLD_ZIOVERSE
		and not mo.zionverse_spread	-- flag to make sure we don't endlessly damage everything lol
		and mo.atk_hitby.target == TGT_ENEMY	-- only single target skills

			-- spread damage to everyone else inflicted with zionverse in my party!
			for i = 1, #mo.allies do
				local a = mo.allies[i]
				if a ~= mo
				and a.fieldstate
				and a.fieldstate.type == FLD_ZIOVERSE

					a.atk_attacker = mo.atk_attacker
					a.atk_hitby = mo.atk_hitby

					a.zionverse_spread = true	-- flag to not spread damage endlessly
					damageObject(a, damage/5)
					a.zionverse_spread = nil

					for j = 1, 16
						local b = P_SpawnMobj(a.x, a.y, a.z, MT_SUPERSPARK)
						b.momx = P_RandomRange(-32, 32)*b.scale
						b.momy = P_RandomRange(-32, 32)*b.scale
						b.momz = P_RandomRange(-32, 32)*b.scale
					end
				end
			end
		end
	end

	if not mo.hp and (dmgnum or damage > 0)	-- I can't believe we're fucking dead
	--and not (mo.flags2 & MF2_DONTDRAW)
	and mo.state ~= S_INVISIBLE

		if not mo.extra
			cureStatus(mo)
			mo.status_condition = nil
			mo.status_turns = 0	-- hyper mode
		end

		VFX_Play(mo.atk_attacker, VFX_KILL)
		VFX_Play(mo, VFX_DIE)
		mo.down = nil	-- Not down anymore

		if mo.enemy
		and not mo.plyr				-- no, enemy players don't explode as far as I recall

			local exp = mo.expval or enemyList[mo.enemy].r_exp or 1
			local money = mo.moneyval or enemyList[mo.enemy].r_macca or exp/4

			-- get item drops:
			/*if enemyList[mo.enemy].r_drops
				local t = enemyList[mo.enemy].r_drops
				for i = 1, #t do
					if P_RandomRange(0, 100) <= t[i][2]
						BTL_addResultItem(btl, t[i][1], 1)
					end
				end
			end*/
			getRandomDrops(mo)

			if mo.extra
				btl.r_exp = $+ exp*3/2
				btl.r_money = $+money*3/2
				return
			end	-- sequence handled in a separate battlestate

			playSound(mo.battlen, sfx_srip)		-- die monster
			clearField(mo)			-- clear Fields
			mo.state = S_INVISIBLE	-- turn invisible

			if not mo.deathanim

				mo.anim = nil			-- stop pain animation
				mo.flags2 = $|MF2_DONTDRAW
				explodeShadow(mo)		-- directed by micheal bay

				if btl.holdupfinish
					explodeShadowBig(mo)
				end
			else
				if mo.enemy
					local btl = server.P_BattleStatus[mo.battlen]
					btl.saved_affs[mo.enemy][3] = true	-- enemy was beaten, that means every subsequent type of this enemy can have its stats be displayed in analysis
				end
			end

			-- give us some exp?
			btl.r_exp = $+ (exp or 0)
			btl.r_money = $+ money

			btl.netstats.enemiesdefeated = $ +1
			if server.P_DungeonStatus.VR_type == VC_ERADICATION
			or server.P_DungeonStatus.VR_type == VC_REPEL
				server.P_DungeonStatus.VR_score = $+1
			end

		elseif mo.plyr
		and mo.state ~= S_INVISIBLE	-- not already dead
			-- player dies
			playSound(mo.battlen, sfx_s3k35)
			cureStatus(mo)
			mo.status_condition = nil
			mo.status_turns = 0
			BTL_readybuffs(mo)	-- reset buffs / debuffs
			mo.anim = nil
			mo.state = S_INVISIBLE
			mo.tics = -1
			-- spawn deathstate:
			local d = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
			d.skin = mo.skin
			d.color = mo.color
			d.state = S_PLAY_DEAD
			d.tics = -1
			d.flags = MF_NOCLIPHEIGHT
			d.fuse = TICRATE*6
			P_SetObjectMomZ(d, 10<<FRACBITS)
			btl.netstats.timesdied = $ +1

			if server.gamemode == GM_VOIDRUN
				server.P_DungeonStatus.VR_lives = max(0, $-1)
				BTL_logMessage(mo.battlen, "\x82".."You lost a life!")
			end

			-- put me back where I was!
			mo.momx = 0
			mo.momy = 0
			mo.momz = 0
			if mo.defaultcoords
				P_TeleportMove(mo, mo.defaultcoords[1], mo.defaultcoords[2], mo.z)
			end

		end
	end
	run_ondamagepassives(mo)
end)

local netstates = {
	"NET_TEAMSELECT",
	"NET_SKINSELECT",
	"NET_PVP_SKINSELECT",
	"NET_PVP_TEAMSELECT",
	"NET_LOAD",
}

for i = 1, #netstates
	rawset(_G, netstates[i], i-1)
end

rawset(_G, "NET_begin", function(state)

	if not server return end
	COM_BufInsertText(server, "rejointimeout 0")

	server.P_netset = true	-- prevents other scripts from running
	server.plentities = {}
	server.playerlist = {}

	for p in players.iterate
		p.tempboss = nil
	end

	-- setup teams:
	for i = 1, 4
		server.plentities[i] = {}
		server.playerlist[i] = {}
	end

	--print("Beginning network status at state "..(state or 1))

	-- change to tartarus f1 music regardless
	--S_ChangeMusic(1)

	server.P_netstat = {
		running = true,
		netstate = state or NET_TEAMSELECT,
		spectators = {},	-- spectator players
		leaders = {},	-- players leading the teams, p1 will always lead one, everyone else will be chosen arbitrarily
		playerlist = {},
		teamlen = 4,
		skinlist = {},	-- keep track of what skins to use.
		ready = false,
		buffer = 	{
						-- buffer information relative to what we must do once characters have been set
						-- if this buffer is nil / not set, nothing will happen and netstat won't end
						gamemode = 1,
						extradata = 1,
						map = 1,
					}

	}
	
	if cv_teamsize and cv_teamsize.value
		server.P_netstat.teamlen = cv_teamsize.value
	end

	for i = 1, 4
		server.P_netstat.skinlist[i] = {}
		server.P_netstat.playerlist[i] = {}
	end

	-- reset PLAYER stuff
	for p in players.iterate do
		local mo = p.mo
		if not mo or not mo.valid continue end

		p.P_party = 0				-- which team are we on?
		p.P_teamleader = nil		-- is team leader
		p.tempboss = nil			-- you never know
		p.bossselect = nil
		p.confirmboss = nil
		server.bosslevel = nil

		-- team related options
		mo.P_net_teamstate = 0
		mo.P_net_spectate = nil
		mo.P_net_teamchoice = 1
		mo.P_net_createparty = nil

		mo.P_net_skinselect = nil	-- skin selected. Set it to nil so that it's initialized to our current skin
		mo.P_net_menu = 0			-- menus are only either yes/no
		mo.P_net_menuanim = 0		-- used for short animations
		mo.P_net_selectindex = 1	-- ...who are we selecting?
		-- P_inputs already works by default so we're good
	end

	-- bossmode
	-- THERES PROBABLY A MUCH EASIER WAY OF DOING THIS
	-- IF ANYONE SEES THIS, PLEASE TRY TO CORRECT MY HALVED BRAINCELL
	--                                     - Spectra

	if (server.bossmode)
		local count = 0
		for p in players.iterate
			count = $+1
		end

		server.bosscount = 1
		-- prepare a list of bosses:
		server.bosslist = {}
		for k,v in pairs(enemyList)
			if (v.boss or v.endboss or v.finalboss)
			and k ~= "batkan" and k ~= "alt"	-- there are pvp exlcusive versions of these which work betetr
			and not v.nopvp
				server.bosslist[#server.bosslist+1] = k
			end
		end

		table.sort(server.bosslist, function(a, b)
			local enm1 = enemyList[a]
			local enm2 = enemyList[b]

			return enm1.level < enm2.level

		end)
		server.bosslist[#server.bosslist+1] = nil

		for i = 1, server.bosscount
			local boss = players[P_RandomRange(1, count)-1]
			boss.tempboss = true
		end

		local lead = false
		for p in players.iterate
			local mo = p.mo
			if not mo or not mo.valid continue end

			if p.tempboss
				table.insert(server.plentities[2], p)
				table.insert(server.playerlist[2], p)
				table.insert(server.P_netstat.skinlist[2], p.mo.skin)
				table.insert(server.P_netstat.playerlist[2], p)
				mo.P_net_selectindex = 1
				-- boss stuff is set in stone
			else
				--table.insert(server.plentities[1], p)
				--table.insert(server.playerlist[1], p)
				table.insert(server.P_netstat.skinlist[1], p.mo.skin)
				table.insert(server.P_netstat.playerlist[1], p)
				mo.P_net_selectindex = #server.P_netstat.skinlist[1]	-- skin selection index
			end
			mo.P_net_teamstate = 2	-- consider the party joined

			if p.tempboss
				p.P_party = 2
				p.P_teamleader = true
			else
				p.P_party = 1
				if lead == false
					p.P_teamleader = true
					lead = true
				end
			end
		end

		server.P_netstat.buffer.map = srb2p.colosseo_map
		server.P_netstat.buffer.gamemode = GM_PVP
		server.P_netstat.buffer.extradata = PVP_BOSSMODE
		server.P_netstat.buffer.maxparties = 2
		--NET_startgame()
	end
	
	if (server.bluemist)
		local count = 0
		for p in players.iterate
			count = $+1
		end

		local lead = false
		for p in players.iterate
			local mo = p.mo
			local netstat = server.P_netstat
			if not mo or not mo.valid continue end
			
			if p == server
				mo.P_net_createparty = true
				local firstinvalid
				local maxparties = netstat.buffer.maxparties or 1

				for i = 1, maxparties
					if not netstat.leaders[i]
						firstinvalid = i
						break
					end
				end

				if not firstinvalid	-- soz
					S_StartSound(nil, sfx_not, p)
					chatprintf(p, "\x82*No more parties can be made, maximum reached ("..maxparties..")")
					mo.P_net_teamstate = 0
					continue
				end

				-- otherwise, make my OWN team!
				netstat.leaders[firstinvalid] = p
				p.P_teamleader = true	-- set as team leader (mostly used as reference for the game)
				p.P_party = firstinvalid	-- assign to party
				netstat.playerlist[firstinvalid][1] = p
				chatprint("\x82*"..p.name.." created a party.")
				mo.P_net_createparty = nil
				continue
			end
			
			/*table.insert(server.P_netstat.skinlist[1], p.mo.skin)
			table.insert(server.P_netstat.playerlist[1], p)
			mo.P_net_selectindex = #server.P_netstat.skinlist[1]	-- skin selection index
			mo.P_net_teamstate = 2	-- consider the party joined
			
			p.P_party = 1
			if lead == false
				p.P_teamleader = true
				lead = true
			end*/
		end
		
		server.P_netstat.buffer.map = 7
		server.P_netstat.buffer.gamemode = GM_COOP
		server.P_netstat.buffer.extradata = 1
		server.P_netstat.buffer.maxparties = 1
		--NET_startgame()
	end
end)

local function NET_team_skinselect(p)
	local net = server.P_netstat
	local minskin = 0
	local maxskin = 0
	for i = 0, 31
		if skins[i] and skins[i].valid
			maxskin = i
		else
			break	-- skins are a normal list, so as soon as one is invalid, all the others are too
		end
	end

	if not net.buffer then return end	-- net.buffer can be nil
	local nostack = net.buffer.nostack	-- No stacking skins!
	--print(nostack)


	local mo = p.mo
	if not mo return end

	local inpt = mo.P_inputs
	if not net.playerlist then return end
	local party = net.playerlist[p.P_party]

	-- figure out where in the party i am
	local myindex
	for i = 1, #party
		if party[i] == p
			myindex = i
			break
		end
	end

	mo.P_net_selectindex = $ or myindex

	if mo.P_net_skinselect == nil
		for i = 0, 31 do
			if skins[i].name == mo.skin
				mo.P_net_skinselect = i
				break
			end
		end
	end
	mo.P_net_skinselect = $ or 0

	-- check if we're trying to select a skin a player is going to take:
	local ind = mo.P_net_selectindex
	if party[ind] and party[ind].valid and party[ind] ~= p	-- no we don't count lol
		-- try to find a skin to set, otherwise ready up
		for i = mo.P_net_selectindex+1, net.teamlen
			if i > net.teamlen
				break
			end

			if not party[i]
				mo.P_net_selectindex = i
				dprint("Now setting skin "..i)
				break
			end
		end

		if mo.P_net_selectindex == ind	-- yikes!
			mo.P_net_ready = true
		end
	end

	-- the launch prompt:
	if mo.P_net_launchprompt
		if inpt[BT_JUMP] == 1	-- yeah let's go
			-- this is where we begin the game
			NET_startgame()
			return
		end
		-- pressing BT_USE will undo our last skin selection as expected, handled in the code below :P
	end

	-- handle skin selection

	if inpt["left"] == 1
		mo.P_net_skinselect = $-1
		S_StartSound(nil, sfx_hover, p)

		if mo.P_net_skinselect < 0
			mo.P_net_skinselect = maxskin
		end

		while (not P_netUnlockedCharacter(mo.player, skins[mo.P_net_skinselect].name))
			mo.P_net_skinselect = $-1

			if mo.P_net_skinselect < 0
				mo.P_net_skinselect = maxskin
			end
		end

	elseif inpt["right"] == 1
		mo.P_net_skinselect = $+1
		S_StartSound(nil, sfx_hover, p)

		if mo.P_net_skinselect > maxskin
			mo.P_net_skinselect = 0
		end

		while (not P_netUnlockedCharacter(mo.player, skins[mo.P_net_skinselect].name))
			mo.P_net_skinselect = $+1

			if mo.P_net_skinselect > maxskin
				mo.P_net_skinselect = 0
			end
		end

	elseif inpt[BT_JUMP] == 1
	and not mo.P_net_ready

		-- check if this skin CAN be selected:
		local s = skins[mo.P_net_skinselect].name

		if nostack
			for i = 1, 4
				if net.skinlist[p.P_party][i] == s
					S_StartSound(nil, sfx_not, p)
					return
					-- No skin stacking if this is on!
				end
			end
		end

		-- lock on to this skin:

		if not p.P_teamleader or mo.P_net_selectindex >= net.teamlen
			mo.P_net_ready = true
		end

		net.skinlist[p.P_party][mo.P_net_selectindex] = s
		S_StartSound(nil, sfx_confir, p)

		if p.P_teamleader
			-- do we need to check another skin......??
			for i = mo.P_net_selectindex+1, net.teamlen+1
				if i > net.teamlen
					mo.P_net_ready = true	-- then there's nothing to set, huh!
					dprint("Partyleader ready")
					break
				end


				if not party[i]
					mo.P_net_selectindex = i
					dprint("Now setting skin "..i)
					break
				end
			end
		end

	elseif inpt[BT_USE] == 1
	and (p.P_teamleader or mo.P_net_ready)

		if mo.P_net_ready
			mo.P_net_ready = nil
			mo.P_net_launchprompt = nil
			S_StartSound(nil, sfx_cancel, p)
			net.skinlist[p.P_party][mo.P_net_selectindex] = nil
			return
		end

		-- can we go back?
		local goback = mo.P_net_selectindex
		if goback <= 1
			if p.P_teamleader and p.P_party == 1
				NET_end(true)
			end
			return
		end

		if p.P_teamleader
			goback = $-1
		end

		while goback

			if not party[goback]
			or party[goback] == p	-- yeah it's fine if it's moi~
				net.skinlist[p.P_party][mo.P_net_selectindex] = nil
				net.skinlist[p.P_party][goback] = nil
 				mo.P_net_selectindex = goback
				S_StartSound(nil, sfx_cancel, p)
				return
			end
			goback = $-1
		end
		S_StartSound(nil, sfx_not, p)
	end
end

local function NET_teamselect()
	local nump = 0
	local ready = 0
	local inparty_orready = 0
	local validpnums = {}
	local netstat = server.P_netstat
	local firstp
	local minparties = netstat.buffer.minparties or 1

	local count = 0

	for p in players.iterate do
		if p.mo and p.mo.valid

			count = $+1

			firstp = $ or p

			PLAY_nomove(p)	-- disable cmd
			nump = $+1

			if not p.P_party
				validpnums[#validpnums+1] = #p
			end

			if p.mo.P_net_ready
				ready = $+1
				inparty_orready = $+1
			elseif p.P_party
				inparty_orready = $+1
			end
		end
	end

	-- Cancel the gamemode / party selection if we have too many players!!
	if netstat.buffer and netstat.buffer.maxparties
		--dprint(count.."/"..(netstat.buffer.maxparties*4))
		if count > netstat.buffer.maxparties*server.P_netstat.teamlen
			chatprint("\x82".."*Max # of players for the gamemode reached! ("..(netstat.buffer.maxparties*4)..")")
			NET_end(true)
			return
		end
	end

	-- Cancel as well if we don't have enough players left to satisfy the party requirements somehow
	local unreadyplayers = nump - inparty_orready
	local neededparties = minparties - #netstat.leaders	-- <= 0 if all the needed parties are already made.

	-- in short, if unreadyplayers <= neededparties, we can't become a party member
	if unreadyplayers < neededparties
	and not server.bossmode
	--and not server.bluemist --lol
		chatprint("\x82".."*Not enough unready players to satisfy party count requirements!")
		NET_end(true)
		return
	end

	if ready >= nump	-- everyone is ready
		firstp.mo.P_net_launchprompt = true
	else	-- dynamically check for new joiners
		firstp.mo.P_net_launchprompt = nil
	end

	-- determine how many leaders we NEED (we COULD have more than that.)
	local numteams
	local gamemode = netstat.buffer.gamemode

	if gamemode == GM_PVP
		-- how many players per team do we allow...?
		server.P_netstat.teamlen = 4 -- nump/2 + (nump%2 and 1 or 0)	-- split players in half (add 1 for .5 player ofc)
		numteams = 2	-- always.

		if nump > 8	-- there is an issue (for now.)
			return
		end
	else
		numteams = nump/4 +((nump%4) and 1 or 0)
	end

	if server.bossmode or server.bluemist
		numteams = 0	-- leaders are automatically assigned
	end
	-- technically speaking, if there's only one team we don't need this screen at all!

	-- party cleansing etc:
	for i = 1, #server.P_netstat.playerlist
		local j = #server.P_netstat.playerlist[i]

		while j
			if not (server.P_netstat.playerlist[i][j] and server.P_netstat.playerlist[i][j].valid)
				table.remove(server.P_netstat.playerlist[i], j)
				-- if the leader is invalid for this team, cleanse the skin data from it as well.
				server.skinlist[i] = {}
				-- all players from this team should be made un-ready as well.
				for k = 1, #server.P_netstat.playerlist[i]
					server.P_netstat.playerlist[i][k].mo.P_net_ready = nil
					-- we must also reattribute a selectindex to EACH OF THEM
					server.P_netstat.playerlist[i][k].mo.P_net_selectindex = k -- luckily, it's 'k'
					dprint("Player left, reseting team status to ensure net-safety.")

					-- another issue...;
					if k > server.P_netstat.teamlen
						table.remove(server.P_netstat.playerlist[i], k)
						dprint("Removed player "..k.." from team "..i.." to ensure team balance.")
					end
				end
			end

			if j == 1
			and server.P_netstat.playerlist[i][j]
			and server.P_netstat.playerlist[i][j].valid

				if not server.P_netstat.playerlist[i][j].P_teamleader
					server.P_netstat.playerlist[i][j].P_teamleader = true
					server.P_netstat.leaders[i] = server.P_netstat.playerlist[i][j]
				end
			end
			j = $-1
		end
	end

	-- same shit for spectators
	local i = #netstat.spectators
	while i
		local sp = netstat.spectators[i]
		if not sp or not sp.valid
			table.remove(netstat.spectators, i)
		end
		i = $-1
	end

	-- leader cleansing:
	local i = 4
	while i
		-- if the leader doen't exist, make it nil
		if not (server.P_netstat.leaders[i] and server.P_netstat.leaders[i].valid)
			server.P_netstat.leaders[i] = nil
			--dprint("Removed leader data from team "..i)
		end
		i = $-1
	end

	-- now it's a per player case...
	for p in players.iterate do

		local mo = p.mo
		if not mo continue end

		if mo.P_net_teamstate == 2
			if p.tempboss
				NET_team_bossselect(p)
			else
				NET_team_skinselect(p)
			end
			continue
		end

		if mo.P_net_ready
			continue
		end

		local inpt = mo.P_inputs

		if p.P_teamleader
			mo.P_net_teamstate = 2	-- consider things as if we had selected.
			continue
		end

		mo.P_net_teamstate = $ or 0
		mo.P_net_teamchoice = $ or 1

		-- else, we aren't a team leader

		-- teamstate 0, select our team
		if not mo.P_net_teamstate
			local maxc = min(4, #netstat.leaders)

			if server.P_netstat.buffer
				maxc = $+2
			end		-- +2 choices for party creation and spectating

			-- in case players leave and teams need to be undone...
			mo.P_net_teamchoice = min($, maxc)

			if inpt["down"] == 1
				S_StartSound(nil, sfx_hover, p)
				-- make sure this team exists...
				mo.P_net_teamchoice = $+1
				if mo.P_net_teamchoice > maxc
					mo.P_net_teamchoice = 1
				end
				while not netstat.playerlist[mo.P_net_teamchoice]
					mo.P_net_teamchoice = $+1
					if mo.P_net_teamchoice > maxc
						mo.P_net_teamchoice = 1
						break
					end
				end
			elseif inpt["up"] == 1
				S_StartSound(nil, sfx_hover, p)
				mo.P_net_teamchoice = $-1
				if mo.P_net_teamchoice < 1
					mo.P_net_teamchoice = maxc
				end
				while not netstat.playerlist[mo.P_net_teamchoice]
					mo.P_net_teamchoice = $-1
					if mo.P_net_teamchoice < 0
						mo.P_net_teamchoice = maxc
						break
					end
				end

			elseif inpt[BT_JUMP] == 1

				local team = netstat.playerlist[mo.P_net_teamchoice]

				if team and #team >= netstat.teamlen	-- team valid, check how many people are in...
					S_StartSound(nil, sfx_not, p)
					continue
				end

				-- team invalid
				if not #team

					if mo.P_net_teamchoice == maxc-1	-- new party
						mo.P_net_createparty = true
						mo.P_net_spectate = nil
					else
						mo.P_net_spectate = true
						mo.P_net_createparty = nil
					end
				end

				S_StartSound(nil, sfx_confir, p)
				mo.P_net_teamstate = 1	-- confirm?
			end


		-- ask for confirmation
		elseif mo.P_net_teamstate == 1

			-- check if team exists each frame, if it doesn't anymore, yeet tf outta here

			if not mo.P_net_createparty
			and not mo.P_net_spectate
				if not netstat.leaders[mo.P_net_teamchoice]
					mo.P_net_teamchoice = 1
					mo.P_net_teamstate = 0
					mo.P_net_createparty = nil
					continue
				end

				local team = netstat.playerlist[mo.P_net_teamchoice]
				if #team >= netstat.teamlen
					S_StartSound(nil, sfx_not, p)
					mo.P_net_teamstate = 0
					continue
				end
			else
				-- check if we CAN create a party in that case...
				if #netstat.leaders >= 4
					S_StartSound(nil, sfx_not, p)
					mo.P_net_teamstate = 0
					continue
				end
			end

			if inpt[BT_JUMP] == 1
				-- yes mom i wanna be there
				S_StartSound(nil, sfx_confir, p)

				if mo.P_net_spectate

					-- we must check that assuming the current amount of people who are ready
					-- and the amount of parties, there are still enough left AFTER we've become a spec
					-- to make the REQUIRED amount of parties...

					-- in short, if unreadyplayers <= neededparties, we can't become a spectator.
					if unreadyplayers <= neededparties
						S_StartSound(nil, sfx_not, p)
						chatprintf(p, "\x82".."*Create a party. The gamemode requires "..minparties.." party/ies and there are not enough players left to allow joining an existing party or spectating.")
						mo.P_net_spectate = nil
						continue	-- don't ready us up duh
					end

					netstat.spectators[#netstat.spectators+1] = p
					mo.P_net_ready = true

					continue
				elseif mo.P_net_createparty
					-- tell you what i wanna make my OWN TEAM!!!
					local firstinvalid
					local maxparties = netstat.buffer.maxparties or 1

					for i = 1, maxparties
						if not netstat.leaders[i]
							firstinvalid = i
							break
						end
					end

					if not firstinvalid	-- soz
						S_StartSound(nil, sfx_not, p)
						chatprintf(p, "\x82*No more parties can be made, maximum reached ("..maxparties..")")
						mo.P_net_teamstate = 0
						continue
					end

					-- otherwise, make my OWN team!
					netstat.leaders[firstinvalid] = p
					p.P_teamleader = true	-- set as team leader (mostly used as reference for the game)
					p.P_party = firstinvalid	-- assign to party
					netstat.playerlist[firstinvalid][1] = p
					chatprint("\x82*"..p.name.." created a party.")
					mo.P_net_createparty = nil
					continue
				end

				-- we must check that assuming the current amount of people who are ready
				-- and the amount of parties, there are still enough left AFTER we've become a member
				-- to make the REQUIRED amount of parties...

				-- in short, if unreadyplayers <= neededparties, we can't become a party member
				if unreadyplayers <= neededparties
					S_StartSound(nil, sfx_not, p)
					chatprintf(p, "\x82".."*Create a party. The gamemode requires "..minparties.." party/ies and there are not enough players left to allow joining an existing party or spectating.")
					mo.P_net_teamstate = 0
					continue	-- don't ready us up duh
				end

				chatprint("\x82*"..p.name.." joined team "..mo.P_net_teamchoice)
				p.P_party = mo.P_net_teamchoice
				table.insert(netstat.playerlist[mo.P_net_teamchoice], p)
				mo.P_net_teamstate = 2
				local myindex = 0
				for i = 1, netstat.teamlen
					if netstat.playerlist[mo.P_net_teamchoice][i] == p
						myindex = i
						break
					end
				end
				mo.P_net_selectindex = myindex
				
				if server.bluemist
					//just in case someone missed it the first time
					skinrestrict = true
					
					local da = netstat.skinlist[p.P_party]
					if da[myindex] == "sonic"
						sonicisdead = false
						da[myindex] = nil
					end
					if da[myindex] == "tails"
						tailsisdead = false
						da[myindex] = nil
					end
					if da[myindex] == "knuckles"
						knucklesisdead = false
						da[myindex] = nil
					end
					if da[myindex] == "amy"
						amyisdead = false
						da[myindex] = nil
					end
				end

			elseif inpt[BT_USE] == 1
				S_StartSound(nil, sfx_confir, p)
				mo.P_net_teamstate = 0
				mo.P_net_spectate = nil
			end
		end
	end

	local pready = 0
	for p in players.iterate
		if p.P_net_team
			pready = $+1
		end
	end
	
	-- the launch prompt(if our host is deciding to spectate):
	for p in players.iterate
		local inpt = p.mo.P_inputs
		if p.mo.P_net_launchprompt
			if inpt[BT_JUMP] == 1	-- yeah let's go
				-- this is where we begin the game
				NET_startgame()
				return
			end
			-- pressing BT_USE will undo our last skin selection as expected, handled in the code below :P
		end
	end

	--if pready >= nump
	--	dprint("thighs")
	--	NET_setstate(NET_SKINSELECT)
	--end
end

local state_2_func = {
	[NET_TEAMSELECT] = NET_teamselect,
	[NET_SKINSELECT] = NET_teamselect,
	[NET_PVP_SKINSELECT] = NET_skinselect,
	[NET_PVP_TEAMSELECT] = NET_pvpteam,
	[NET_LOAD] = NET_load
}

rawset(_G, "NET_Lobby", function()
	if not netgame
	and server
	and not server.skinlist
		-- quick intialization
		--server.skinlist = {{"sonic"}}
	end

	if not NET_isset()
	and gamemap ~= srb2p.tartarus_map
	and leveltime == 3	-- oddly specific, I know, but this guarantees the mapchange only happens once.
	and netgame			-- Only pull this weird stunt in netgames!
		NET_exitready(srb2p.tartarus_map, true)
		G_ExitLevel()
		return
	end

	if not NET_running() return end

	if state_2_func[server.P_netstat.netstate]
		state_2_func[server.P_netstat.netstate]()
	end
end)

//to avoid gameover when players on other platforms die in stage 6
rawset(_G, "BTL_endturnHandler", function(pn)
	local btl = server.P_BattleStatus[pn]
	local mo = btl.turnorder[1]
	if not mo or not mo.valid
		--print("\x82".."WARNING".."\x80"..": No valid entity at the end of the turn? Be careful how you use those debug commands!")
		for k,v in ipairs(btl.fighters)
			if v and v.valid
				mo = v
				btl.turnorder[1] = v
				--print("Using entity "..k.." ("..v.name..") as a backup for reference. Battle flow may be altered.")
				break
			end
		end
	end

	if not mo.t_passivebuffer
		for i = 1, #mo.passiveskills
			local psv = mo.passiveskills[i]
			if attackDefs[psv]
				psv = attackDefs[$]
				if psv.passive == PSV_ENDTURN and mo.t_passivestuff < i
					mo.t_passivestuff = i
					mo.t_passivebuffer = i
					mo.t_passivetimer = 0	-- reset this timer
					break	-- ^ this is the skill we're going to use
				end
			end
		end
	end

	if mo.t_passivebuffer
		-- tp cam to us:
		local cam = btl.cam
		--CAM_stop(cam)
		local x, y = mo.x + 320*cos(mo.angle + ANG1*50), mo.y + 320*sin(mo.angle + ANG1*50)
		P_TeleportMove(cam, x, y, mo.z + FRACUNIT*80)
		cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
		cam.aiming = -ANG1*2
		CAM_stop(cam)

		mo.atk_attacker = mo	-- makes these function correctly, we don't get getDamage for this, so we have to set it manually.
		local atk = attackDefs[mo.passiveskills[mo.t_passivebuffer]]
		mo.atk_hitby = BTL_copyAttackDefs(atk)	-- ditto
		if mo.t_passivetimer == 1
			BTL_logMessage(mo.battlen, atk.name)
		end
		if atk.anim(mo, {mo}, {mo}, mo.t_passivetimer)
			mo.t_passivebuffer = 0
			mo.t_passivetimer = 0
		end
		mo.t_passivetimer = $ +1
		return
	end

	-- before we cleanse, iterate t2 for dead enemies with extra flag for blowup seq
	for k,v in ipairs(btl.fighters)

		if v and v.valid and v.deathanim and v.hp <= 0
			return
		end

		if v and v.valid and v.hu_deadanim and not v.extra and v.hu_deadanim < 13
			-- deadanim at 13 is considered finished
			return	-- wait for deadanim to finish playing before cleansing
		end

		if v and v.valid and v.hp <= 0 and v.extra
			btl.extra_blowuptarget = v
			btl.extra_blowuptime = 0
			btl.battlestate = BS_HYPERDIE
			return
		end
	end

	local t1, t2 = BTL_deadEnemiescleanse(btl)
	-- don't forget to use BTL_fullCleanse(btl) to remove dead enemy objects once they aren't needed anymore


	-- voidrun: if timer hits 0 at the end of a turn, kill all enemies and end the battle!
	if server.gamemode == GM_VOIDRUN
	and server.P_DungeonStatus.VR_timer <= 0
		for i = 1, #t2 do
			local e = t2[i]
			e.hp = 0
			e.flags2 = $ | MF2_DONTDRAW

			local fake = P_SpawnMobj(e.x, e.y, e.z, MT_THOK)
			fake.sprite = e.sprite
			fake.angle = e.angle
			fake.frame = e.frame
			fake.scale = e.scale
			fake.tics = -1
			fake.fuse = 10
		end
		t1, t2 = BTL_deadEnemiescleanse(btl)	-- do this again since we just fake-killed enemies lol
	end

	-- are there any teams left?
	if server.gamemode == GM_PVP
		if not #t1 or not #t2
			BTL_fullCleanse(btl)
			for i = 1, 4
				btl.battlestate = BS_PVPOVER
				btl.hudtimer.pvpend = TICRATE*3
				return
			end
		end
	end

	if (gamemap != 12 and not #t1) or (gamemap == 12 and playersdead == #server.plentities[1])			-- all players are dead
	or (server.gamemode == GM_VOIDRUN and server.P_DungeonStatus.VR_lives <= 0)
	-- do game over sequence

		if server.gamemode == GM_VOIDRUN
		and server.P_DungeonStatus.VR_lives	-- we still have lives!!
			btl.turnorder = {}	-- let's cheat, this will force party members to be revived, otherwise things break lol
			btl.battlestate = BS_PRETURN
			print("Don't gameover")
			return
		end

		if server.gamemode ~= GM_VOIDRUN
		or server.P_DungeonStatus.VR_lives
			for p in players.iterate do
				if p and p.P_party == pn
					S_FadeOutStopMusic(MUSICRATE*2, p)
				end
			end
		end

		if server.gamemode == GM_CHALLENGE
			btl.battlestate = BS_CHALLENGEEND
			btl.hudtimer.challengeend = TICRATE*5
			btl.challengewon = nil
			BTL_fullCleanse(btl)
			return
			-- yep, that's a loss
		end
		
		//blue mist: reset plentities that left during stage 4 (aka bring tails back on the team)
		if gamemap == 10
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
		end

		if not btl.gameover
			btl.gameover = 1
		end
		btl.gameover = $+1
		
		//reset completed stages (wait no dont)
		--completedstages = 0

		if btl.gameover == TICRATE
			--D_startEvent("ev_gameover")
			-- ^ that's for singleplayer
			BTL_fullCleanse(btl)
			btl.battlestate = BS_GAMEOVER
			btl.hudtimer.gameover = TICRATE
			btl.hudtimer.gameovertimeout = TICRATE*5
			btl.gameoverchoice = 0
		end

		-- start the event
		if D_eventHandler(pn) return end	-- cutscene running, don't proceed

		return
	elseif not #t2		-- all enemies are dead

		-- revive our dead players and remove status conditions
		-- also remove the added skills from skill cards and subpersonas, we don't want to carry those over :yikes:

		local mo = server.plentities[pn][1]
		if server.gamemode ~= GM_CHALLENGE	-- bruh.
		and not (btl.storedwaves and #btl.storedwaves and btl.waven < #btl.storedwaves)
			for i = 1, #mo.allies_noupdate
				local m = mo.allies_noupdate[i]

				m.skills = copyTable(m.saveskills)
				table.sort(m.skills, attackSortFunc)	-- re-sort in case we learned something new.
				-- we don't NEED to remove passiveskills since it'll get reset by the next battle anyway.

				if not m.hp
					--dprint("Reviving player "..m.name)
					revivePlayer(m)
					m.hp = 1
				end
			end
		end

		if server.gamemode == GM_CHALLENGE
		or (btl.storedwaves and #btl.storedwaves)	-- multi-wave battles

			btl.waven = $+1	-- increase wave and check if we got more!

			if server.gamemode == GM_CHALLENGE
			and btl.scoremode
				if btl.waven > #BTL_challengebtllist[btl.challengen].waves
					btl.waven = 1	-- restart
				end

				BTL_addScore(pn, 5000, "Wave completed!")
			end

			-- If we killed an enemy with a 1more, it will technically linger and give us a nonsensical 1more next time we act.
			-- So we must get rid of it here
			if mo and mo.valid
				mo.setonemore = nil
			end

			local wave = btl.storedwaves
			if server.gamemode == GM_CHALLENGE
				wave = BTL_challengebtllist[btl.challengen].waves
			end

			if wave[btl.waven]
				-- There are still waves to be had!

				resetEntitiesPositions(pn)
				CAM_stop(btl.cam)
				btl.turnorder = BTL_BuildTurnOrder(pn)
				btl.cam.goto = {}
				btl.cam.momx = 0
				btl.cam.momy = 0
				btl.cam.momz = 0
				local fd = btl.cam.firstdefault
				P_TeleportMove(btl.cam, fd[1], fd[2], fd[3])
				btl.cam.angle = fd[4]
				btl.cam.aiming = 0
				btl.nextwave = wave[btl.waven]
				btl.hudtimer.moreenemies = TICRATE*5/2
				btl.battlestate = BS_MOREENEMIES
				BTL_fullCleanse(btl)
				return
			end

			if server.gamemode == GM_CHALLENGE

				for p in players.iterate do
					if p and p.P_party == pn
						S_StopMusic(p)
					end
				end

				-- wow, you have winned
				-- all enemies cleared, go to challenge mode result screen

				btl.battlestate = BS_CHALLENGEEND
				btl.challengewon = true	-- yes, you won, used to know what graphic to display
				btl.hudtimer.challengeend = TICRATE*5
				BTL_fullCleanse(btl)
				return
			end
		end

		-- do end of battle screen
		--S_ChangeMusic("AFTRBL")
		if not btl.shuffletimer
			for p in players.iterate do
				if p and p.P_party == pn

					local winquote = P_RandomRange(1, #server.plentities[p.P_party])
					for i = 1, #server.plentities[p.P_party]
						if i == winquote
						and btl.r_exp	-- no exp = run away
							VFX_Play(server.plentities[p.P_party][i], VFX_WIN, nil, p)
						end
					end

					if server.gamemode ~= GM_VOIDRUN
						S_FadeOutStopMusic(MUSICRATE, p)
					end
				end
			end
		end

		-- endboss finisher:
		if btl.holdupfinish
		-- check for tartarus netgame here
			btl.battlestate = BS_MPFINISH
			btl.hudtimer.mpfinish = TICRATE*6
			BTL_fullCleanse(btl)
			btl.netstats.wins = $+1	-- count that as a win!

			-- Do Tartarus specific unlocks etc:
			if server.gamemode == GM_COOP
				if mapheaderinfo[gamemap].tartarus

					-- Finished Block 6 / Marathon mode (both work to unlock Monad)

					if server.difficulty >= 6
					and not srb2p.local_conds[UNLOCK_B7]
						for p in players.iterate do
							P_unlock(UNLOCK_B7, p, "The Monad Block is now available from Rogue Mode!")
						end
					end

					-- Finished block 7:
					if server.difficulty == 7
					and not server.marathon	-- ?
					and not srb2p.local_conds[UNLOCK_B7_FINISHED]
						P_unlock(UNLOCK_B7_FINISHED)		-- Silent unlock
					end
				end

				-- Finished Marathon
				if server.marathon
					if not srb2p.local_conds[UNLOCK_B7]
						for p in players.iterate do
							P_unlock(UNLOCK_B7, p, "The Monad Block is now available from Rogue Mode!")
						end
					end
					if not srb2p.local_conds[UNLOCK_MR_FINISHED]
						P_unlock(UNLOCK_MR_FINISHED)		-- Silent unlock
					end

				end
			end
			-- Finished Void Run
			if server.gamemode == GM_VOIDRUN
			and not srb2p.local_conds[UNLOCK_VR_FINISHED]
				P_unlock(UNLOCK_VR_FINISHED)
			end

			return
		end

		-- we must know whether we should have a shuffle time first
		-- AKA: quick finish, did AOA in battle or 1/6 random

		if (btl.turn <= 1 or btl.aoa or not P_RandomRange(0, 6))	-- lol debug
		and not btl.shuffletimer	-- < we already did shuffletime
		and not btl.runaway
		and not btl.holdupfinish	-- for 1p
		and not SAVE_localtable.tutorial		-- not during tutorials
		and not (server.gamemode == GM_VOIDRUN)	-- not in void run.
			btl.battlestate = BS_SHUFFLE
			btl.hudtimer.shufflestart = TICRATE*3/2

			-- for wand cards:
			btl.r_baseexp = btl.r_exp
			btl.r_basemoney = btl.r_money
			btl.r_expmultiplier = 0
			btl.r_moneymultiplier = 0
			btl.r_healhp = 0
			btl.r_healsp = 0
			btl.r_expmultipliers = {}
			btl.r_moneymultipliers = {}
			btl.r_healhps = {}
			btl.r_healsps = {}
			return
		end

		-- Iterate through mo's party and check for passive skills with PSV_ENDBATTLE
		for i = 1, #mo.allies
			local v = mo.allies[i]
			dprint("Executing PSV_ENDBATTLE passives for "..v.name)
			for j = 1, #v.passiveskills
				local psv = v.passiveskills[j]
				if attackDefs[psv]
					psv = attackDefs[$]
					if psv.passive == PSV_ENDBATTLE
					and psv.anim
						psv.anim(v, {v}, {v}, 1)	-- Execute this skill's anim function on myself ONCE.
					end
				end
			end

			PLYR_getStats(v, v.level, true)
		end

		btl.battlestate = BS_END
		btl.hudtimer.endb = TICRATE*3/2
		btl.r_precalculates = {}

		-- obtain random roll items
		if not btl.runaway
		--and mo.attack ~= attackDefs["run"]
			local tbl = server.items
			local newtable = {}
			if tbl
				for k,v in ipairs(tbl)
					for j = 1, v[2]
						newtable[#newtable+1] = v[1]
					end
				end
			end
		end

		BTL_fullCleanse(btl)
		return
	end

	-- challenge mode: time's up!
	if server.gamemode == GM_CHALLENGE
	and not btl.timer
		btl.battlestate = BS_CHALLENGEEND
		btl.hudtimer.challengeend = TICRATE*5
		btl.challengewon = btl.scoremode	-- false if outside of score mode, otherwise, it's a victory regardless!
		BTL_fullCleanse(btl)
		return
		-- yep, that's a loss
	end

	if mo and mo.valid and mo.setonemore

		-- we have gotten a one more; this means we knocked an enemy down on our turn.
		-- so let's check if *all* our enemies are down to see if we can initiate an All Out Attack:

		if mo.plyr and #mo.allies > 1	-- of course this would only apply for players, and if we have more than 1 ally to attack with

			local dcount = 0
			for k,v in ipairs(mo.enemies) do
				if v.down
					dcount = $+1
				end
			end

			-- check if we have at least 1 ally free of status condition:
			local cond_count = 0
			for k,v in ipairs(mo.allies)
				if not BTL_noAOAStatus(v)
					cond_count = $+1
				end
			end

			if dcount >= #mo.enemies
			and server.gamemode ~= GM_CHALLENGE	-- no all out attacks in challenge mode
			and cond_count > 1	-- At least 2 allies necessary!
			and mo.hp
				VFX_Play(mo, VFX_AOAASK)
				BTL_fullCleanse(btl)
				BTL_initHoldup(btl, mo.allies)
				return	-- don't process anymore. We will get back to the entity's turn if we cancel or to the next turn if we don't
			end
		end

		mo.turnset = nil
		mo.onemore = TICRATE
		mo.setonemore = nil

		VFX_Play(mo, VFX_1MORE)
	end

	-- even if we aren't doing the above, check for endboss being knocked down to initiate the final AOA
	for k,v in ipairs(mo.enemies) do
		if v.down and v.endboss and v.hp == 1
			BTL_fullCleanse(btl)
			BTL_initHoldup(btl, mo.allies)
			return
		end
	end

	if not mo.statustimer then mo.statustimer = 0 end

	if btl.turnorder[2] ~= mo	-- ditto, only do that at the end of an enemy's last turn for multi-turn enemies
	and not btl.skipstatus		-- set after link skills etc
		if not BTL_handleStatusConditions(pn, mo.statustimer)
			mo.statustimer = $+1
			return
		end

		if mo.status_res
			mo.status_res = max(0, $-2)
		end
	end

	mo.skipdowncheck = nil	-- don't forget to remove this
	mo.batontouch = nil	-- can't baton touch anymore
	if btl.turnorder[1] and btl.turnorder[1].valid
		btl.turnorder[1].status_condition_pass = nil	-- it's a full loop!
		btl.turnorder[1].statustimer = nil
	end

	local pdump
	if mo.batonpassto
		pdump = mo.batonpassto
		mo.batonpassto = nil
	end

	-- remove dead entities from turn order and fighters (like, dead but still in-game, players)
	updateUDtable_nohp(btl.turnorder)
	updateUDtable_nohp(btl.fighters)

	if pdump

		-- delete any entry regarding pdump in the turn list, we're moving it!
		for i = 1, #btl.turnorder
			if btl.turnorder[i] == pdump
				table.remove(btl.turnorder, i)
				break
			end
		end

		btl.turnorder[1] = pdump
	else
		if mo and not mo.onemore and not (btl.linkhits and #btl.linkhits)
			-- don't remove turns if we're about to enter link hit state
			mo.batonpassbuff = 0	-- reset baton pass buff
			table.remove(btl.turnorder, 1)
			-- advance through turnorder
		end
	end

	BTL_fullCleanse(btl)	-- *remove* dead enemies, they aren't needed anymore

	-- perform link states:
	if btl.linkhits
	and #btl.linkhits
		--print("Do links")
		btl.skipstatus = true
		btl.battlestate = BS_LINK
		return
	end

	btl.skipstatus = nil

	if btl.battlestate ~= BS_HOLDUP
		btl.battlestate = BS_PRETURN	-- bullshit preturn
	end
	btl.actionstate = ACT_NONE		-- get back on the main menu
end)

//restart map when continuing in blue mist, and also the option of going to the tips corner
rawset(_G, "BTL_gameOver", function(pn)
	local battle = server.P_BattleStatus[pn]
	local t = battle.hudtimer.gameovertimeout

	local nbkill = 0
	for i = 1, 4
		local tb = server.P_BattleStatus[i]

		if tb.gameover or not (server.plentities[i][1])
			nbkill = $+1
		end
	end

	if battle.hudtimer.gameoverremove

		if battle.hudtimer.gameoverremove == 1	--
			-- start by ending the battles:
			for i = 1,4
				if not server.P_BattleStatus[i].running continue end
				for j = 1, server.P_netstat.teamlen do
					if not server.plentities[i][j] continue end
					local mo = server.plentities[i][j]
					mo.hp = mo.maxhp
					mo.sp = mo.maxsp
					mo.skills = copyTable(mo.saveskills)
				end
				server.P_BattleStatus[i].r_wipe = 1	-- instantly clear
				BTL_finish(i)
			end

			server.P_DungeonStatus.gameoverfade = 9		-- quick hack
			server.P_DungeonStatus.lifeexplode = 9+20
			if gamemap == 5
				-- If we're at the peak, reset the map
				DNG_loadNewMap(5)
			elseif (mapheaderinfo[gamemap].bluemiststory)
				-- same for blue mist
				for j = 1, server.P_netstat.teamlen do
					if not server.plentities[1][j] continue end
					local mo = server.plentities[1][j]
					mo.hp = mo.maxhp
					mo.sp = mo.maxsp
				end
				DNG_loadNewMap(gamemap)
			else
				-- go back to the last floor where we saved
				DNG_setFloor(server.P_DungeonStatus.savefloor)
			end
			DNG_logMessage(retrymsg[P_RandomRange(1, #retrymsg)])
		end

		return	-- don't continue
	end

	if nbkill >= 4
	and pn == 1	-- first battle status gets to choose what we do
		if server.plentities[pn][1] and server.plentities[pn][1].valid
			local inputs = server.plentities[pn][1].control.mo.P_inputs	-- player 1

			if inputs[BT_JUMP] == 1
			and server.P_BattleStatus.lives
			and server.gamemode ~= GM_VOIDRUN
				if gamemap != 13
					dprint("Retrying from the last starpost...!")
					-- restart from the last checkpoint
					
					-- start by ending the battles:
					for i = 1,4
						if not server.P_BattleStatus[i].running continue end
						server.P_BattleStatus[i].hudtimer.gameoverremove = 9
					end

					-- take my life away
					server.P_BattleStatus.lives = $-1
				end

			elseif inputs[BT_USE] == 1
				-- terminate the game
				for i = 1, 4
					server.P_BattleStatus[i].running = false
					server.P_BattleStatus[i].battlestate = 0
				end
				server.P_BattleStatus.kill = true
				G_SetCustomExitVars(1, 1)
				G_ExitLevel()
				dprint("Terminated session")
			elseif inputs[BT_TOSSFLAG] == 1 and (mapheaderinfo[gamemap].bluemiststory)
				diedstage = gamemap-6
				if gamemap == 12
					DNG_loadNewMap(15)
				else
					DNG_loadNewMap(14)
				end
			end
		end
	end
end)

rawset(_G, "drawGameOver", function(v, btl)
	local t = btl.hudtimer.gameover

	if not t
		v.drawFill()
	end

	if t < TICRATE/3
		local scale = FRACUNIT /2 + FRACUNIT*t/2
		v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_GMOVR"))
	end

	if not t

		local nbkill = 0
		for i = 1, 4
			local tb = server.P_BattleStatus[i]

			if tb.gameover or not (server.plentities[i][1])
				nbkill = $+1
			end
		end

		if nbkill >= 4
		and btl.n == 1	-- first battle status gets to choose what we do
			if server.gamemode ~= GM_VOIDRUN
				V_drawString(v, 160, 10, "\x82".."Press A to retry from last checkpoint", "NFNT", V_SNAPTOTOP, "center", 0, nil)
				if (mapheaderinfo[gamemap].bluemiststory)
					//if gamemap == 13
					//	V_drawString(v, 160, 170, "\x82".."Continues: -99999999999999", "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
					//else
						V_drawString(v, 160, 170, "\x82".."Continues: "..server.P_BattleStatus.lives, "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
					//end
				end
			end
			V_drawString(v, 160, 20, "\x82".."Press B to give up", "NFNT", V_SNAPTOTOP, "center", 0, nil)
			if (mapheaderinfo[gamemap].bluemiststory)
				V_drawString(v, 160, 30, "\x82".."Press C to enter Stage "..tostring(gamemap-6).."'s Tips Corner", "NFNT", V_SNAPTOTOP, "center", 0, nil)
			end
		end

		V_drawString(v, 160, 160, "Your party was wiped out.", "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
		if server.P_netstat and server.P_netstat.leaders and #server.P_netstat.leaders > 1
			V_drawString(v, 160, 170, "You will respawn next floor", "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
			V_drawString(v, 160, 180, "(PRESS F12 TO WATCH OTHER PLAYERS)", "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
		end
	end

	local newt = btl.hudtimer.gameoverremove

	if newt and newt > 1
		local ript = 8- newt
		drawScreenwidePatch(v, v.cachePatch("H_RIP"..min(4, (ript/2)+1)))
	end
end)

rawset(_G, "battlefunchandler", {
	[BS_START] 		=	{BTL_startHandler, 		BS_PRETURN},
	[BS_PRETURN] 	=	{BTL_preturnHandler, 	BS_DOTURN},
	[BS_DOTURN]		=	{BTL_turnHandler,		BS_ACTION},
	[BS_ACTION]		=	{BTL_actionHandler,		BS_ENDTURN},
	[BS_ENDTURN]	=	{BTL_endturnHandler,	nil},
	[BS_HOLDUP]		=	{BTL_holdupHandler,		nil},
	[BS_SHUFFLE]	=	{BTL_shuffleHandler,	nil},
	[BS_END]		=	{BTL_endHandler,		nil},
	[BS_LEVELUP]	=	{BTL_levelUpHandler,	nil},
	[BS_FINISH] 	=	{BTL_finish,			nil},
	[BS_MPFINISH]	=	{BTL_MPfinish,			nil},
	[BS_HYPERDIE]	=	{BTL_HyperDie,			nil},
	[BS_GAMEOVER]	=	{BTL_gameOver,			nil},
	[BS_PVPOVER]	=	{BTL_pvpOver,			nil},
	[BS_MOREENEMIES]=	{BTL_moreEnemiesHandler,nil},
	[BS_CHALLENGEEND]=	{BTL_challengeEndHandler,	nil},
	[BS_LINK] = 		{BTL_linkHandler, 		BS_ENDTURN},
})


//p much just for knuckles' super thing
rawset(_G, "BTL_skillCostDepletion", function(mo)
	local skill = mo.attack
	if not skill return end
	local btl = server.P_BattleStatus[mo.battlen]
	local cost = ATK_getSkillCost(mo, skill)
	
	if not mo.demon
		if mo.status_condition == COND_SUPER
			return true	-- free!
		end
	else
		if mo.status_condition == COND_SUPER and skill.costtype != CST_EP
			return true	-- free!
		end
	end

	if skill.costtype == CST_HP
	or skill.costtype == CST_HPPERCENT
		if mo.boss then return true end

		if mo.hp <= cost
			playSound(mo.battlen, sfx_not)
			BTL_logMessage(mo.battlen, "Insufficient HP")
			return
		else
			mo.losehp = cost
		end
	elseif skill.costtype == CST_SP
	or skill.costtype == CST_SPPERCENT
		if mo.sp < cost
			playSound(mo.battlen, sfx_not)
			BTL_logMessage(mo.battlen, "Insufficient SP")
			return
		else
			mo.losesp = cost
		end
	elseif skill.costtype == CST_EP

		if not btl.emeraldpow_max
			playSound(mo.battlen, sfx_not)
			BTL_logMessage(mo.battlen, "What's \'EP\' ???")
			return
		end

		if btl.emeraldpow < cost
			playSound(mo.battlen, sfx_not)
			BTL_logMessage(mo.battlen, "Insufficient Emerald Power")
			return
		else
			btl.emeraldpow = $- cost
		end
	end

	return true
end)

rawset(_G, "drawSkillCommand", function(v, x, y, mo, skill, active, have_item, skillcard, equip, owner)	-- draw skill command (also applies for items)
	if not skill
		-- Generate our own skill in that case...
		skill = {
			name = "INVALID SKILL",
			type = ATK_SLASH,
			power = 0,
			accuracy = 0,
		}
	end
	-- type icon

	-- note: passives stack with other types.
	local atk_type
	local atk_color
	if skill.type & ATK_PASSIVE	-- rather special case, heh!
		atk_type = 15
		atk_color = SKINCOLOR_ORANGE
	else
		atk_type = atk_constant_2_num[skill.type]
	end

	local unknown
	if server.gamemode == GM_VOIDRUN
		if server.P_DungeonStatus.VR_clause == VE_SKILLJAMMER
		and not have_item

		or have_item
		and server.P_DungeonStatus.VR_clause == VE_ITEMJAMMER
			unknown = true
		end
	end

	if unknown
		atk_color = SKINCOLOR_GREY
		atk_type = 0

		skill = {
			name = "JAMMED",
			type = 0,
			power = 0,
			accuracy = 0,
		}

	end

	PDraw(v, x+3, y+3, v.cachePatch("ATK_"..atk_type), V_SNAPTOLEFT)
	-- background
	PDraw(v, x, y, v.cachePatch("H_ATKBG"), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, atk_color or skill_color[skill.type]))

	if have_item	-- Skill is from item list, proceed differently.
		-- name
		V_drawString(v, x+20, y+2, unknown and "JAMMED" or itemDefs[have_item[1]].name:upper(), "FPIMP", V_SNAPTOLEFT, nil, (not active and 16 or 0), 31)
		v.drawIndex((x+22)<<FRACBITS, (y+15)<<FRACBITS, FRACUNIT/2, v.cachePatch("H_HAVE"), V_SNAPTOLEFT, 31)
		v.drawIndex((x+21)<<FRACBITS, (y+14)<<FRACBITS, FRACUNIT/2, v.cachePatch("H_HAVE"), V_SNAPTOLEFT, not active and 16 or 0)
		V_drawString(v, x+42, y+12, unknown and "" or have_item[2], "FPNUM", V_SNAPTOLEFT, nil, not active and 16 or 0, 31)
		return
	end

	-- name
	V_drawString(v, x+20, y+2, skill.name:upper(), "FPIMP", V_SNAPTOLEFT, nil, (not active and 16 or 0), 31)
	--drawCusString(v, x+20, y+4, "PersonaImpact", skill.name:upper(), 0|V_SNAPTOLEFT, 31|V_SNAPTOLEFT)

	if equip
		V_drawString(v, x+21, y+14, "\x82".."EQUIPPED", "FPIMP", V_SNAPTOLEFT, nil, (not active and 16 or 0), 31, FRACUNIT/4)
		return
	end
	if skillcard
		V_drawString(v, x+21, y+14, "SKILL CARD", "FPIMP", V_SNAPTOLEFT, nil, (not active and 16 or 0), 31, FRACUNIT/4)
		return
	end

	-- is this skill a weakness?
	-- check if we got a battle going before checking this however
	if mo.battlen and server.P_BattleStatus[mo.battlen] and server.P_BattleStatus[mo.battlen].running
	and not (skill.type & ATK_PASSIVE)	-- yeah no lol

		local drawn

		for i = 1, #mo.enemies
			local t = mo.enemies[i]
			if t.enemy and server.P_BattleStatus[mo.battlen].saved_affs[t.enemy][1] & getAttackType(mo, skill)	-- make sure we unlocked the affinity ...
			--and t.weak & skill.type	-- TODO: finish the thingy to check affinities reliably
			and getAttackAff(t, skill, mo) == DMG_WEAK	-- lol did it

				local scale = leveltime%10 < 5 and FRACUNIT/2 or FRACUNIT/2 + FRACUNIT/10
				v.drawScaled((x+60)<<FRACBITS, (y+20)<<FRACBITS, scale, v.cachePatch("H_AWEAK"), V_SNAPTOLEFT)
				drawn = true

			-- technical damage doesn't require knowledge of the affinity
			elseif getAttackAff(t, skill, mo) == DMG_TECHNICAL
			and not drawn
				local scale = leveltime%10 < 5 and FRACUNIT/2 or FRACUNIT/2 + FRACUNIT/10
				v.drawScaled((x+60)<<FRACBITS, (y+20)<<FRACBITS, scale, v.cachePatch("H_ATECH"), V_SNAPTOLEFT)
				drawn = true
			end
		end
	end

	-- draw the cost:
	-- get cost amount
	local cost
	local pp = {"H_HP", 131}

	if not skill.cost or unknown return end	-- nothing to draw here

	if skill.costtype == CST_HPPERCENT
	or skill.costtype == CST_HP
		cost = ATK_getSkillCost(owner or mo, skill)
	elseif skill.costtype == CST_EP	-- emerald power
		cost = ATK_getSkillCost(owner or mo, skill)/100
		pp = {"C_EP"}
	elseif skill.costtype == CST_SP
	or skill.costtype == CST_SPPERCENT
		cost = ATK_getSkillCost(owner or mo, skill)
		pp = {"H_SP", 181}
	end
	
	if not mo.demon
		if mo.status_condition == COND_SUPER
			cost = 0	-- hack
		end
	else
		if mo.status_condition == COND_SUPER and skill.costtype != CST_EP
			cost = 0	-- hack
		end
	end

	V_drawString(v, x+32, y+12, cost, "FPNUM", V_SNAPTOLEFT, "right", ((skill.costtype == CST_EP and 112 or (skill.costtype == CST_SP or skill.costtype == CST_SPPERCENT) and 181 or 131) + (not active and 3 or 0)), 31)
	if skill.costtype == CST_EP --let's render percentages for EP
		local percentage = ATK_getSkillCost(owner or mo, skill) - cost*100
		if percentage < 10 then percentage = "0"..$ end
		V_drawString(v, x+35, y+10, ".", "NFNT", V_SNAPTOLEFT, "right", 112 + (not active and 3 or 0), 31)
		V_drawString(v, x+44, y+12, percentage, "FSNUM", V_SNAPTOLEFT, "right", 112 + (not active and 3 or 0), 31)
		v.drawIndex((x+47)<<FRACBITS, (y+15)<<FRACBITS, FRACUNIT/2, v.cachePatch(pp[1]), V_SNAPTOLEFT, 31)
	else
		v.drawIndex((x+35)<<FRACBITS, (y+15)<<FRACBITS, FRACUNIT/2, v.cachePatch(pp[1]), V_SNAPTOLEFT, 31)
	end

	if pp[2]	-- palette index: SP, or HP
		v.drawIndex((x+34)<<FRACBITS, (y+14)<<FRACBITS, FRACUNIT/2, v.cachePatch(pp[1]), V_SNAPTOLEFT, pp[2] + (not active and 3 or 0))
	else	-- for emerald power, use normal colours and draw
		v.drawScaled((x+45)<<FRACBITS, (y+14)<<FRACBITS, FRACUNIT/2, v.cachePatch(pp[1]), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, ep_colors[cost]))
	end


	if owner
		local patch = charStats[owner.stats].icon
		PDraw(v, x + 48, y+12, v.cachePatch(patch), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, owner.color))
	end
end)

//enemy drops, now tweaked so that badniks give it immediately in stage 4
rawset(_G, "getRandomDrops", function(mo)
	--print("get random drops...")
	local btl = server.P_BattleStatus[mo.battlen]
	if server.gamemode == GM_CHALLENGE return end	-- nope

	local tbl = server.items
	local newtable = {}

	local maxrarity = 0

	if tbl
		for k,v in ipairs(tbl)
			for j = 1, v[2]
				newtable[#newtable+1] = v[1]
			end
		end

		-- 25% chance to obtain random drop item 3 times

		for i = 1, 3
			if P_RandomRange(0, 100) <= 40
				--print("Get drop")
				local rng = P_RandomRange(1, #newtable)	-- rng seed
				local it = newtable[rng]
				local rare

				-- check if item is a weapon / ring / weapon series
				if type(it) == "table"
					if it[1] == "series"
						local wpn = dropWeaponFromSeries(it[2], server.plentities[mo.battlen])
						wpn = makeWeapon(wpn, P_RandomRange(0, 3))

						maxrarity = max($, wpn.rarity)
						btl.r_weapons = $ or {}

						btl.r_weapons[#btl.r_weapons+1] = wpn
						spawnWeaponDrop(wpn, mo.x, mo.y, mo.z)

					elseif it[1] == "ring"
						local ring = it[2]

						if ring
							btl.r_rings = $ or {}
							btl.r_rings[#btl.r_rings+1] = makeRing(ring, P_RandomRange(0, 3))
							maxrarity = max($, btl.r_rings[#btl.r_rings].rarity)
							spawnRingDrop(btl.r_rings[#btl.r_rings], mo.x, mo.y, mo.z)
						end

					elseif it[1] == "weapon"
						local wpn = it[2]

						if wpn
							btl.r_weapons = $ or {}
							btl.r_weapons[#btl.r_weapons+1] = makeWeapon(wpn, P_RandomRange(0, 3))
							maxrarity = max($, btl.r_weapons[#btl.r_weapons].rarity)
							spawnWeaponDrop(btl.r_weapons[#btl.r_weapons], mo.x, mo.y, mo.z)
						end
					end

					--[[if rare
						for p in players.iterate
							if p and p.control and p.control.valid and p.control.battlen == mo.battlen
								IT_startRareDropAnim(p)
							end
						end
					end--]]

					continue
				end

				if itemDefs[it] and itemDefs[it].rarity
					maxrarity = max($, itemDefs[it].rarity)
					--[[for p in players.iterate
						if p and p.control and p.control.valid and p.control.battlen == mo.battlen
							IT_startRareDropAnim(p)
						end
					end--]]
				end

				spawnItemDrop(itemDefs[it], mo.x, mo.y, mo.z)
				if gamemap == 10 or gamemap == 12
					local randomamount = P_RandomRange(1, 2)
					BTL_addItem(btl, it, randomamount)
					displayItemStart(it, randomamount)
				else
					BTL_addResultItem(btl, it, 1)
				end
			end
		end
	end

	-- enemy specific drops all have their own odds rolled.
	local enemy = enemyList[mo.enemy]
	if enemy.r_drops and #enemy.r_drops

		for i = 1, #enemy.r_drops

			if P_RandomRange(0, 100) < enemy.r_drops[i][2]
				local it = enemy.r_drops[i][1]
				local rare
				-- check if item is a weapon / ring / weapon series
				if type(it) == "table"
					if it[1] == "series"
						local wpn = dropWeaponFromSeries(it[2], server.plentities[mo.battlen])
						wpn = makeWeapon(wpn, P_RandomRange(0, 3))

						maxrarity = max($, wpn.rarity)
						btl.r_weapons = $ or {}

						btl.r_weapons[#btl.r_weapons+1] = wpn
						spawnWeaponDrop(wpn, mo.x, mo.y, mo.z)

					elseif it[1] == "ring"
						local ring = it[2]

						if ring
							btl.r_rings = $ or {}
							btl.r_rings[#btl.r_rings+1] = makeRing(ring, P_RandomRange(0, 3))
							maxrarity = max($, btl.r_rings[#btl.r_rings].rarity)
							spawnRingDrop(btl.r_rings[#btl.r_rings], mo.x, mo.y, mo.z)
						end

					elseif it[1] == "weapon"
						local wpn = it[2]

						if wpn
							btl.r_weapons = $ or {}
							btl.r_weapons[#btl.r_weapons+1] = makeWeapon(wpn, P_RandomRange(0, 3))
							maxrarity = max($, btl.r_weapons[#btl.r_weapons].rarity)
							spawnWeaponDrop(btl.r_weapons[#btl.r_weapons], mo.x, mo.y, mo.z)
						end
					end

					--[[if rare
						for p in players.iterate
							if p and p.control and p.control.valid and p.control.battlen == mo.battlen
								IT_startRareDropAnim(p)
							end
						end
					end--]]

					continue
				end

				if itemDefs[it] and itemDefs[it].rarity
					maxrarity = max($, itemDefs[it].rarity)
					--[[for p in players.iterate
						if p and p.control and p.control.valid and p.control.battlen == mo.battlen
							IT_startRareDropAnim(p)
						end
					end--]]
				end

				spawnItemDrop(itemDefs[it], mo.x, mo.y, mo.z)
				if gamemap == 10 or gamemap == 12
					local randomamount = P_RandomRange(1, 2)
					BTL_addItem(btl, it, randomamount)
					displayItemStart(it, randomamount)
				else
					BTL_addResultItem(btl, it, 1)
				end
			end
		end
	end

	if maxrarity >= 5
		for p in players.iterate
			if p and p.control and p.control.valid and p.control.battlen == mo.battlen
				IT_startRareDropAnim(p, maxrarity)
			end
		end
	end
end)

//dont increment itemsused if gem is given by badnik
rawset(_G, "BTL_useItem", function(btl, itemn, use)

	if use
		if (mapheaderinfo[gamemap].bluemiststory)
			if itemDefs[btl.items[itemn][1]].cost != 350 and itemDefs[btl.items[itemn][1]].cost != 500
				btl.netstats.itemsused = $+1
			end
		else
			btl.netstats.itemsused = $+1
		end
	end

	btl.items[itemn][2] = $-1
	if not btl.items[itemn][2]
		table.remove(btl.items, itemn)
		BTL_sortItems(btl)
		return true
	end
end)

local function m_teamselect_drawer(v, mo, choice)
	if stagecleared return end
	local timer = mo.m_hudtimers.sclosemenu and mo.m_hudtimers.sclosemenu or (7 - (mo.m_hudtimers.smenuopen or 0))

	if timer
		v.fadeScreen(31, timer)
	end

	local nteams = 0
	
	for i = 1, 4
		if #server.plentities[i]
			nteams = $+1	-- empty teams can exist if people leave (how)
		end
	end

	local w = 75
	local x = 160 - (w/2)*nteams
	local y = 50- (7-timer)*32

	local hpos = mo.m_teamselect
	local vpos = mo.m_slotselect

	V_drawString(v, 160, 20, "Select a party to join", "NFNT", 0, "center", 0, 31)

	for i = 1, 4
		local team = server.plentities[i]
		if #team

			-- find the first valid player in that party (server.playerlist[i])
			local firstplayer = server.playerlist[i][1]
			local k = 2
			-- only enter this loop if firstplayer somehow doesn't exist
			while not firstplayer and k < #team
				firstplayer = server.playerlist[i][k]
				k = $+1
			end

			V_drawString(v, x, y-10, "\x82"..firstplayer.name.."'s party", "TFNT", 0, nil, 0, 31)

			for j = 1, #team
				local dta = team[j]
				local sk = team[j].stats
				local ico = charStats[sk].icon or "ICO_SONI"

				-- only assign this player if it is our MAIN.
				-- and grey out the name display later so it shows we can't take over it.
				local p
				if dta.control.maincontrol == dta
					p = dta.control
				end

				if i == hpos and j == vpos
					v.drawFill(x-2, y-2, 80, 32, 135)
				end

				PDraw(v, x, y, v.cachePatch(ico), 0, v.getColormap(TC_DEFAULT, skins[sk].prefcolor))
				local name = p and "\x86"..p.name.."\x80" or skins[sk].realname
				local nstr = "Lv"..dta.level.." "..name
				V_drawString(v, x+9, y, nstr, nstr:len() >= 15 and "TFNT" or "NFNT", 0, nil, 0, 31)
				-- draw HP/SP
				v.drawFill(x+9, y+14, 48, 2, 31)
				v.drawFill(x+9, y+14, dta.hp*47/dta.maxhp, 1, 131)
				V_drawString(v, x+9, y+10, "HP "..dta.hp.."/"..dta.maxhp, "NFNT", 0, nil, 135, 31, FRACUNIT/3)

				v.drawFill(x+9, y+21, 48, 2, 31)
				v.drawFill(x+9, y+21, dta.sp*47/dta.maxsp, 1, 181)
				V_drawString(v, x+9, y+17, "SP "..dta.sp.."/"..dta.maxsp, "NFNT", 0, nil, 183, 31, FRACUNIT/3)

				y = $+32
			end

			x = $+w
			y = 50- (7-timer)*32
		end
	end
end


local function m_teamselect_inputs(mo)
	if stagecleared return end
	local inputs = mo.P_inputs


	local nteams = 0
	local minteam = 0
	local maxteam = 0
	
	for i = 1, 4
		if #server.plentities[i]
			nteams = i	-- empty teams can exist if people leave (how)
			
			if not minteam
				minteam = i
			end
			maxteam = i			
		end
	end
	
	mo.m_teamselect = max($, minteam)

	local currteam = server.plentities[mo.m_teamselect]
	local cteamlen = #currteam
	if cteamlen > 1
		if inputs["down"] == 1
			mo.m_slotselect = $+1
			if mo.m_slotselect > cteamlen
				mo.m_slotselect = 1
			end
			S_StartSound(nil, sfx_hover, mo.player)

		elseif inputs["up"] == 1
			mo.m_slotselect = $-1
			if mo.m_slotselect < 1
				mo.m_slotselect = cteamlen
			end
			S_StartSound(nil, sfx_hover, mo.player)
		end
	end

	if nteams > 1
		if inputs["right"] == 1

			mo.m_teamselect = $+1
			while (mo.m_teamselect > 4 or not #server.plentities[mo.m_teamselect])
				mo.m_teamselect = $+1	-- this can make us go out of bounds but it doesn't matter
				if mo.m_teamselect > nteams
					mo.m_teamselect = 1
				end
			end	

			-- just in case...
			local newteam = server.plentities[mo.m_teamselect]
			mo.m_slotselect = min($, #newteam)

			S_StartSound(nil, sfx_hover, mo.player)
		elseif inputs["left"] == 1
			mo.m_teamselect = $-1
			while (mo.m_teamselect < 1 or not #server.plentities[mo.m_teamselect])
				mo.m_teamselect = $-1	-- this can make us go out of bounds but it doesn't matter
				if mo.m_teamselect < 1
					mo.m_teamselect = nteams
				end
			end	

			-- just in case...
			local newteam = server.plentities[mo.m_teamselect]
			mo.m_slotselect = min($, #newteam)

			S_StartSound(nil, sfx_hover, mo.player)
		end
	end


	if inputs[BT_JUMP] == 1
		local pm = server.plentities[mo.m_teamselect][mo.m_slotselect]
		if not pm or not pm.valid	-- how
		or pm.control and pm.control.valid and pm.control.maincontrol == pm	-- this belongs to someone else

			S_StartSound(nil, sfx_not, mo.player)
			return
		end

		-- this guy is okay for the taking!
		PLYR_spectatorJoinGame(mo.player, mo.m_teamselect, mo.m_slotselect)
		M_closeMenu(mo)
	elseif inputs[BT_USE] == 1
		M_closeMenu(mo)
		S_StartSound(nil, sfx_cancel, mo.player)
	end
end

-- initiate main pause menu:
M_menus["spectate_jointeam"] = {
	m_start_at = "m_teamselect",	-- where the menu starts
	openfunc = function(mo)	-- play a sound when we open the menu:
		if stagecleared
			return true
		else
			S_StartSound(nil, sfx_select, mo.player)
		end
	end,

	m_teamselect = {
		opentimer = 7,
		closetimer = 7,

		openfunc =	function(mo)
						mo.m_teamselect = 1
						mo.m_slotselect = 1
					end,

		prev = nil,
		drawer = m_teamselect_drawer,
		runfunc = m_teamselect_inputs,
	}
}

//retain lives when switching maps in blue mist
rawset(_G, "BTL_MapLoad", function()
	if not server return end

	local difficulty_macca = {
		250,
		750,
		1500,
		2500,
		4000,
		8000,
		15000,
	}

	if not server.P_BattleStatus or server.P_BattleStatus.kill
		server.P_BattleStatus = {}

		for i = 1, 4
			server.P_BattleStatus[i] = {
				n = i,	-- # of battle status, can be used for misc purposes i guess?
				firstact = i,	-- used for PVP
				running = false,		-- is a battle going on?
				boss = false,			-- battle is a boss
				saved_affs = {},		-- enemy affinities and attacks
				--subpersonas = {P_generateSubPersona("none"), P_generateSubPersona("black frost"), P_generateSubPersona("pale rider"), P_generateSubPersona("titania")},		-- sub personas
				subpersonas = {P_generateSubPersona("none")},
				subpersonastock = 17,	-- # of subpersonas possible (+1 because none counts as its own subp)
				spu = 1,				-- number of sp units for players to work with
				emeraldpow_max = server.difficulty or 1,		-- max emerald power gauge
				emeraldpow = 0,			-- emerald power
				emeraldpow_lvbuf = 0,	-- for sounds
				emeraldpow_buffer = false,	-- someone is using hyper mode
				battletime = 0,			-- a timer that runs constantly while the battle is going.
				battlestate = 	0,		-- BS_ constants. battle state.
				actionstate = 0,		-- ACT_ constants. Used for player menus
				turn = 0,				-- # of turn
				turnorder = {},			-- list of entities that will act this turn. turnorder[1] is the current acting entity.
				fighters = {},			-- list of entities who are fighting
				plist = {},				-- what players are in the battle? Used for pvp, mostly
				deadplayers = {},		-- these players were KO'd and can be targetted by revive spells
				arena_coords = {-5024*FRACUNIT,7328*FRACUNIT,256*FRACUNIT},	-- this is where we do battle stuff
				crit_seeds = {},		-- we determine crit for each individual entity :P
				evasion_seeds = {},		-- we determine evasion rate for each entity
				items = {{"snuffsoul", 5}, {"superring", 5}, {"patra gem", 3}, {"1up", 2}, {"dekaja gem", 2}, {"dekunda gem", 2}, {"homunculus", 1}, {"chaos drive x", 1}, {"soma", 1}},		-- everyone shares items.
				weapons = {},			-- list of weapons
				armours = {},			-- list of wardrings
				skillcards = {},		-- everyone shares skillcards as well.
				cam = spawnbattlecam(),	-- nice altviewpoint slave.
				starttype = 0,			-- how do we start the battle? these are for presets.
				atktimer = 0,			-- for attack animations
				transition = 0,			-- used mainly for players
				hudtimer = {},			-- used for player UI animations
				refplayer = 0,			-- we use this player for reference when reviving!
				console = nil,
				console_time = 0,		-- console handler
				macca = difficulty_macca[server.difficulty] or 1000,			-- money
				r_exp = 0,				-- amount of total exp earned for the end of the battle:
				r_item,					-- item earned for the end of the battle;
				r_weapons,				-- weapons earned
				r_rings,				-- rings (armour) earned
				r_money = 0,			-- amount of money earned for the end of the battle:s
				r_precalculates = {},	-- precalculates level and exp after battle for animation
				r_levelupqueue = {},	-- level up queue, this is a queue of what entities are to level up for each player
				r_queueprogress = {},	-- level up queue progress for each player
				r_newskillsqueue = {},	-- new skills learnt queue progress. Per entity rather than per player.
				r_skillqueueprogress = {},	-- new skills queue progress.
				r_wipe = 20,
				waven = 1,
				gameover = nil,

				netstats = {
					floors = 0,
					time = 0,

					encounters = 0,
					wins = 0,
					runaways = 0,
					damagedealt = 0,
					damagetaken = 0,
					damagehealed = 0,
					enemiesdefeated = 0,
					knockdowns = 0,
					timesdied = 0,
					timesrevived = 0,

					holdups = 0,
					alloutattacks = 0,

					subpersonasfound = 0,

					maccaearned = 0,
					maccaspent = 0,

					itemsfound = 0,
					itemsused = 0,
					itemsbought = 0,
					itemssold = 0,

					weaponsenhanced = 0,
					ringsenhanced = 0,

					reaperspotted = 0,
				}

			}

			-- uuuh test
			/*local wep = {"shoes_01", "device_01", "hammer_01", "knuckles_01"}
			for k = 1, 24
				local wepn = wep[P_RandomRange(1, #wep)]
				--print(wepn)
				local w = makeWeapon(wepn, P_RandomRange(0, 10))
				table.insert(server.P_BattleStatus[i].weapons, w)
			end*/
		end

		SRB2P_runHook("DungeonStart", server.P_BattleStatus[i])
	else
		for i = 1, 4
			BTL_softReset(i)
			local btl = server.P_BattleStatus[i]
			btl.emeraldpow_max = server.difficulty or 1		-- max emerald power gauge
		end

		SRB2P_runHook("DungeonStart", server.P_BattleStatus[i])
	end

	if server.difficulty
		if (mapheaderinfo[gamemap].bluemiststory) 
			if bluemistbegin
				server.P_BattleStatus.lives = lives_difficulty[server.difficulty]
				//giving items
				for i = 1, 4
					local btl = server.P_BattleStatus[i]
					btl.items = {{"dekaja gem", 2}, {"dekunda gem", 1}, {"chewing soul", 3}, {"silverring", 5}, {"silvercombiring", 3}, {"patra gem", 3}, {"1up", 5}, {"chaos drive 2", 2}, {"chaos drive 3", 1}}
				end
				bluemistbegin = false
			end
		else
			server.P_BattleStatus.lives = lives_difficulty[server.difficulty]
		end
	end

	local parsed_from_header = 0
	for i = 1, 4

		-- parse arena coordinates if available:
		local btl = server.P_BattleStatus[i]
		local process = {"x","y","z"}
		for j = 1, #process do
			--dprint("Updating arena coordinate "..process[j].." for battle status "..i)

			if mapheaderinfo[gamemap]["arena"..process[j]] ~= nil
				btl.arena_coords[j] = tonumber(mapheaderinfo[gamemap]["arena"..process[j]]) * FRACUNIT
				dprint("Parsed arena coord "..process[j].." as "..(btl.arena_coords[j]/FRACUNIT))
				parsed_from_header = true
			end
		end
	end

	if not parsed_from_header
		-- parse boss waypoint if possible
		for m in mobjs.iterate() do
			if m and m.valid and m.type == MT_BOSS3WAYPOINT

				for i = 1, 4
					local btl = server.P_BattleStatus[i]
					local shiftx = (mapheaderinfo[gamemap].arenashiftx or 0)*FRACUNIT *(i-1)
					local shifty = (mapheaderinfo[gamemap].arenashifty or 0)*FRACUNIT *(i-1)
					local t = P_SpawnMobj(m.x+shiftx, m.y+shifty, m.z, MT_THOK)
					t.state = S_INVISIBLE

					btl.arenacenter = t
				end
				break
			end
		end
	end
end)

//random badnik names during tips corner 4
rawset(_G, "drawEvent", function(v, p)

	if not server.plentities or not #server.plentities or not server.skinlist return end	-- wait until we're finished setting up our team in MP

	local evt = server.P_DialogueStatus[p.P_party]
	if not evt.running return end
	if not evt.event return end

	local cur = eventList[evt.event][evt.eventindex]

	-- even hud, back, behind text boxes portrait etc
	if eventList[evt.event]["hud_back"]
		eventList[evt.event]["hud_back"](v, evt)
	end

	if not cur	return end

	if cur[1] == "text"	-- regular shit handling
	and evt.curtype == "text"

		local y = 130
		local tboxtimer = 0

		if evt.timers.textboxanim_in
			y = $ + (evt.timers.textboxanim_in*16)
			tboxtimer = evt.timers.textboxanim_in
		elseif evt.timers.textboxanim_out
			y = $ + (TICRATE/3 - evt.timers.textboxanim_out)*16
			tboxtimer = TICRATE/3 - evt.timers.textboxanim_out
		end

		-- draw the choices sliding in whenever possible.
		-- Choices are specific to events so it's fine to only ever handle them here.
		if textbuf ~= nil and evt.texttime >= textbuf:len()
				if cur[4]
				local top = y - 18 - (16*(#cur[4]-1))
				local dx = 210
				for i = 1, #cur[4]
					local c = cur[4][i]
					local dy = top + (i-1)*16 + (evt.timers.choices*20 or 0)

					if evt.choice == i
						PDraw(v, dx, dy, v.cachePatch("H_TBOXS2"), V_SNAPTOBOTTOM)
						V_drawString(v, 210 + 40, dy + 5, c[1], "NFNT", V_SNAPTOBOTTOM, "center", 31, 138)
					else
						PDraw(v, dx, dy, v.cachePatch("H_TBOXS1"), V_SNAPTOBOTTOM|V_30TRANS)
						V_drawString(v, dx + 40, dy + 5, c[1], "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
					end
				end
			else
				-- otherwise, draw the continue arrow
				local xpos = leveltime%10 < 5 and 100 or 102
				PDraw(v, xpos, 190, v.cachePatch("H_TCONT"), V_SNAPTOBOTTOM)
			end
		end

		local portrait = cur[7] and cur[7][1] or nil
		local colour = cur[7] and cur[7][2] or nil

		R_drawTextBox(v, cur[2], cur[3], portrait, colour, tboxtimer, evt.texttime)
	end

	-- event hud: front
	if eventList[evt.event]["hud_front"]
		eventList[evt.event]["hud_front"](v, evt)
	end

end)

//dont reset camera when event gets skipped during tips corner and prevent progression
rawset(_G, "D_eventHandler", function(pn)
	if not server.P_BattleStatus return end
	if not server.P_BattleStatus[pn] return end
	local battle = server.P_BattleStatus[pn]
	if not server.plentities or not #server.plentities or not server.skinlist return end
	if not server.plentities[pn] or not #server.plentities[pn] return end
	if tipsfinished 
		local evt = server.P_DialogueStatus and server.P_DialogueStatus[pn]
		for p in players.iterate do
			if p.P_party == pn
				p.awayviewmobj = battle.cam
				if evt.usecam
					p.awayviewtics = 2
					p.awayviewaiming = battle.cam.aiming or 0
				end
				--p.mo.flags2 = $|MF2_DONTDRAW
				PLAY_nomove(p)
			end	
		end
		return 
	end
	
	local firstp
	for i = 1, server.P_netstat.teamlen or 4 
		if server.plentities[pn][i]
		and server.plentities[pn][i].valid
		and server.plentities[pn][i].control
			firstp = server.plentities[pn][i]
			break
		end
	end
	
	if not (firstp and firstp.valid) return end	--??
	if not (firstp.control and firstp.control.valid and firstp.control.mo and firstp.control.mo.valid) return end
	local inputs = firstp.control.mo.P_inputs
	if not inputs return end	-- errors

	local evt = server.P_DialogueStatus and server.P_DialogueStatus[pn]

	if evt and evt.event

		evt.running = true
		evt.time = $+1

		for p in players.iterate do
			if p.P_party == pn
				p.awayviewmobj = battle.cam
				if evt.usecam
					p.awayviewtics = 2
					p.awayviewaiming = battle.cam.aiming or 0
				end
				--p.mo.flags2 = $|MF2_DONTDRAW
				PLAY_nomove(p)
			end	
		end

		-- handle timers and special cases
		for k, v in pairs(evt.timers)
			if evt.timers[k]
				evt.timers[k] = $-1
				if k == "to" and evt.timers[k] == 0 and evt.save_event
					--dprint("Switching to next index after animation.")
					evt.eventindex = evt.save_event
					evt.save_event = nil
					evt.texttime = 0
				elseif k == "quit" and evt.timers[k] == 0	-- quit timer elapsed, cleanse event
					D_endEvent(pn)
					return
				end
			end
		end

		-- these timers are special and cut our handlers from doing anything:
		if evt.timers.start or evt.timers.to or evt.timers.quit
			return true	-- still technically running, but on time out
		end

		local cur = eventList[evt.event][evt.eventindex]

		if not cur	-- index doesn't exist. We'll assume it ended!
		and not evt.timers.quit
			evt.timers.quit = TICRATE/3
			--dprint("Requesting for end of event")
			return true
		end

		local evflags = cur[6] or 0
		if cur[1] == "text"	-- regular shit handling

			if evt.curtype ~= "text"	-- we started with a text box, ready the animation, quick, quick!
				evt.timers.textboxanim_in = TICRATE/3
				evt.curtype = cur[1]
			end

			local txt = cur[3]

			if evt.timers.textboxanim_in or evt.timers.textboxanim_out then return true end	-- cannot proceed yet
			if evt.timers.choices then return true end	-- yoinks...


			-- quick hack to skip control characters:
			local curchar = txt:sub(evt.texttime, evt.texttime)
			local nextchar = txt:sub(evt.texttime+1, evt.texttime+1)

			-- set delay if the current character is one of these and if the last character is a space
			/*if (curchar == "," or curchar == "." or curchar == "?" or curchar == "!")
			and (nextchar == " " or nextchar == "\n")
			and not evt.textdelay
				evt.textdelay = 8
			end*/

			if evt.textdelay
				evt.textdelay = $-1
			end
			if not evt.textdelay
				evt.texttime = $+1
			end

			-- skip control characters.
			while txt:sub(evt.texttime, evt.texttime) and V_isControlChar(txt:sub(evt.texttime, evt.texttime))
				evt.texttime = $+1
			end

			if evt.texttime == txt:len()
			and cur[4]	-- there are choices
				evt.timers.choices = 8
				return true
			end

			if cur[4]	-- handle choice selection:
				if inputs["down"] == 1
					evt.choice = $+1
					S_StartSound(nil, sfx_hover)
					if evt.choice > #cur[4]
						evt.choice = 1
					end
				elseif inputs["up"] == 1
					evt.choice = $-1
					S_StartSound(nil, sfx_hover)
					if evt.choice < 1
						evt.choice = #cur[4]
					end
				end
			end

			if evflags & EV_AUTO	-- wait for text box
				if evt.texttime < txt:len() + 20
					inputs[BT_JUMP] = 0
				else
					inputs[BT_JUMP] = 1
				end
			end

			if inputs[BT_JUMP] == 1
				if evt.texttime < txt:len()
					evt.texttime = txt:len()
					if cur[4]
						evt.timers.choices = 8	-- bring up the choices.
					end
				else

					if cur[4]	-- in case of dialogue choices:
						S_StartSound(nil, sfx_confir)
						local newe = cur[4][evt.choice][2] or 0
						if cur[5]
							D_requestIndex(pn, newe)
						else
							evt.eventindex = newe
							evt.texttime = 0
						end
					else
						S_StartSound(nil, sfx_hover)
						-- in the case of text, 4 is for potential choices;
						-- 5 is whether or not we want a transition for the next box
						if cur[5]
							D_requestIndex(pn, evt.eventindex+1)
						else
							evt.eventindex = $+1	-- next
							evt.texttime = 0
						end
					end
				end
			end
		elseif cur[1] == "function"	-- execute a function.
			evt.ftimer = $ and $+1 or 1	-- function timer
			if cur[2](evt, battle)	-- makes acting on the tables easier.
				evt.eventindex = $+1
				evt.ftimer = 0
			end
		end

		-- event has been running
		return true
	end
end)

//dont reduce ep gauge during knuckles super anim lmaos
rawset(_G, "BTL_handleStatusConditions", function(pn, timer)
	local btl = server.P_BattleStatus[pn]
	local mo = btl.turnorder[1]
	local cam = btl.cam

	if not mo return true end	-- well uh shit?
	if not mo.status_condition return true end	-- go on, go on
	if mo.status_condition_pass return true end	-- that means we already did this

	if timer == 1		-- not that the camera should do anything else
		resetEntitiesPositions(pn)
	end

	if mo.status_condition == COND_BURN	-- Ca bruuuule

		if timer == 1
			status_cam(mo)
			mo.status_turns = $+1
		elseif timer == 5
			BTL_logMessage(pn, mo.name.. " is damaged by their burn.")
		elseif timer == 30
			playSound(mo.battlen, sfx_fire1)
			local fire = P_SpawnMobj(mo.x, mo.y, mo.z, MT_BOSSEXPLODE)
			fire.state = S_QUICKBOOM1
			fire.scale = FRACUNIT*3/2
			local damage = mo.maxhp/20
			if mo.hp - damage < 1
				damage = mo.hp-1
			end
			damageObject(mo, damage, DMG_NORMAL)
			if mo.hp == 1
			or (mo.boss and mo.status_turns > 2)
				BTL_logMessage(pn, "The burn wore off.")
			end
		elseif timer >= 75
			if mo.hp == 1
			or (mo.boss and mo.status_turns > 2)
				mo.status_condition = nil
				mo.status_turns = nil
			end
			return true
		end

	elseif mo.status_condition == COND_POISON	-- poison

		if timer == 1
			status_cam(mo)
			mo.status_turns = $+1
		elseif timer == 5
			BTL_logMessage(pn, mo.name.. " is damaged by poison")
		elseif timer == 30
			playSound(mo.battlen, sfx_absorb)
			local damage = mo.maxhp/20
			if mo.hp - damage < 1
				damage = mo.hp-1
			end
			damageObject(mo, damage, DMG_NORMAL)
			if mo.hp == 1
			or (mo.boss and mo.status_turns > 2)
				BTL_logMessage(pn, "The poison wore off.")
			end
		elseif timer >= 75
			if mo.hp == 1
			or (mo.boss and mo.status_turns > 2)
				mo.status_condition = nil
				mo.status_turns = nil
			end
			return true
		end

	elseif mo.status_condition == COND_DESPAIR	-- depresso

		if timer == 1
			status_cam(mo)
			mo.status_turns = $+1
		elseif timer == 5
			BTL_logMessage(pn, mo.name.. " is hit by desperation...")
		elseif timer == 30
			playSound(mo.battlen, sfx_absorb)
			local damage = mo.maxsp/20
			if mo.boss
				damage = min(10, mo.maxsp/50)
			end

			if mo.sp - damage < 1
				damage = mo.sp-1
			end
			mo.damagestate = DMG_NORMAL
			mo.damageflags = DF_SP
			damageSP(mo, damage)
			if mo.sp == 1
			or (mo.boss and mo.status_turns > 2)
				BTL_logMessage(pn, "The despair went away")
			end
		elseif timer >= 75
			if mo.sp == 1
			or (mo.boss and mo.status_turns > 2)
				mo.status_condition = nil
				mo.status_turns = nil
			end
			return true
		end

	elseif mo.status_condition == COND_HYPER
		mo.status_turns = $ or 0

		if timer == 1
			if not mo.extra
				mo.status_turns = $+1
			end
			if mo.status_turns >= 3
				BTL_logMessage(pn, "Hyper Mode wore off...")
				status_cam(mo)
			else
				return true
			end
		elseif timer == TICRATE
			-- this here only happens if hyper mode wears off
			mo.status_condition = 0
			mo.status_turns = 0
			BTL_setupstats(mo)	-- reset the stats from hyper mode
			--btl.emeraldpow_buffer = false	-- can use hyper mode again
		end

	elseif mo.status_condition == COND_SUPER
	and not btl.superform	-- free super formes
		mo.status_turns = $ or 0
		if timer == 1

			if mo.status_turns > 1	-- skip the first turn, it's free.
			and btl.emeraldpow >= 100
				if gamemap == 12
					if btl.superman and btl.superman.valid
					and mo != btl.superman
						btl.emeraldpow = max(0, $-100)
					end
				else
					btl.emeraldpow = max(0, $-100)
				end
			end

			mo.status_turns = $+1

			if btl.emeraldpow < 100
			or (btl.emeraldpow_max < 7 and not btl.superform)
				BTL_logMessage(pn, mo.name.."'s Super Form wore off...")
				status_cam(mo)
			else
				return true
			end

		elseif timer == TICRATE
			mo.status_condition = 0
			mo.status_turns = 0
			if mo.control and mo.control.maincontrol == mo
				mo.color = mo.control.mo.color
			else
				mo.color = skins[mo.skin].prefcolor
			end
			BTL_setupstats(mo)	-- akin to hypermode
			ANIM_set(mo, mo.anim_stand)
		end
	else
		return true	-- status condition not handled here
	end
end)

//do something about the garuverse softlock!!! please!!!!!
rawset(_G, "clearField", function(mo)
	if not mo or not mo.valid return end
	if not mo.fieldstate return end

	if mo.fieldstate.entities and #mo.fieldstate.entities
		for i = 1, #mo.fieldstate.entities do
			if mo.fieldstate.entities[i] and mo.fieldstate.entities[i].valid
				mo.fieldstate.entities[i].fuse = 2
			end
		end
	end

	--print("Removed field state...")
	mo.fieldstate = nil
end)