
---------- OTHER (Menu stuff, freeslots, new player moves, all that jim jam) -------------

rawset(_G, "boxflip", false)
/*quick note if you're wondering why this 'cutscene' thing exists its because i 
didnt know server.P_DialogueStatus[btl.n].running was a thing when i started this LMAO*/
rawset(_G, "cutscene", false)
rawset(_G, "timestop", false) -- for shadow's chaos control
rawset(_G, "stagecleared", false) -- to run the stageClear function
rawset(_G, "playersdead", 0) -- for stage 6
rawset(_G, "characterhack", false) -- bypass skinrestrict through a debug command
rawset(_G, "skinrestrict", false)
rawset(_G, "bluemistbegin", false) -- i sorta forgot what this one was for lol
rawset(_G, "diedstage", 1) -- used to track which stage you died on before coming to tips corner
rawset(_G, "saveplentities", {}) -- restoring the team after tails leaves in stage 4
rawset(_G, "tipsfinished", false) -- for going back to the game after tips corner

rawset(_G, "sonicisdead", false)
rawset(_G, "tailsisdead", false)
rawset(_G, "knucklesisdead", false)
rawset(_G, "amyisdead", false)

//im bad at naming stuff
freeslot("sfx_bbreak", "sfx_bchaos", "sfx_bspear", "sfx_cspear", "sfx_tmstop", "sfx_bcntrl", "sfx_portal", "sfx_perish", "sfx_call", "sfx_nani", "sfx_yikes", "sfx_beam", "sfx_epower", "sfx_steal", "sfx_result", "sfx_rankf", "sfx_prowlr", "sfx_boost1", "sfx_boost2", "sfx_poof", "sfx_light", "sfx_wake", "sfx_contin")
freeslot("SPR_WHY1", "SPR_WHY2", "SPR_WHY3", "SPR_WHY4", "SPR_WHY5", "SPR_WHY6", "SPR_WHY7", "SPR_MASK", "SPR_CSPP", "SPR_RUBY", "SPR_FILD", "SPR_KILL", "SPR_TAIL", "SPR_HAMR", "SPR_ASTR", "SPR_GUND", "SPR_FANG")
freeslot("S_HURTC1", "S_HURTC2", "S_HURTC3", "S_HURTC4", "S_EGGMANRETICULE", "S_SUPERSONICDRILL1", "S_SUPERSONICDRILL2", "S_SUPERSONICDRILL3", "S_SUPERSONICDRILL4", "S_TAILSFLY", "S_ETERNALTWINSPIN", "S_AMYSTARS1", "S_AMYSTARS2", "S_AMYSTARS3", "S_AMYSTARS4", "S_MASKEDIDLE")
states[S_HURTC1] = {SPR_HURT, A, 2,nil,0,0,S_HURTC2}
states[S_HURTC2] = {SPR_HURT, B, 2,nil,0,0,S_HURTC3}
states[S_HURTC3] = {SPR_HURT, C, 2,nil,0,0,S_HURTC4}
states[S_HURTC4] = {SPR_HURT, D, 2,nil,0,0,S_NULL}
states[S_EGGMANRETICULE] = {SPR_NULL, A, 24, A_VileTarget, MT_CYBRAKDEMON_TARGET_RETICULE, 0, nil}
//theres no super sonic sprites in srb2p chars files :(
states[S_SUPERSONICDRILL1] = {SPR_WHY7, A, 2,nil,0,0,S_SUPERSONICDRILL2}
states[S_SUPERSONICDRILL2] = {SPR_WHY7, B, 2,nil,0,0,S_SUPERSONICDRILL3}
states[S_SUPERSONICDRILL3] = {SPR_WHY7, C, 2,nil,0,0,S_SUPERSONICDRILL4}
states[S_SUPERSONICDRILL4] = {SPR_WHY7, D, 2,nil,0,0,S_SUPERSONICDRILL1}

//make the tails go faster because i dont know how else to do it
states[S_TAILSFLY] = {SPR_TAIL, FF_ANIMATE|A, -1,nil,3,1,S_TAILSFLY}

//amy twinspin but really fast and looping
states[S_ETERNALTWINSPIN] = {SPR_PLAY, FF_ANIMATE|SPR2_TWIN, -1,nil,4,1,S_ETERNALTWINSPIN}

//amy constellations or whatever pops up in the ending to srb2
states[S_AMYSTARS1] = {SPR_ASTR, FF_ANIMATE|A, -1,nil,1,2,S_AMYSTARS1}
states[S_AMYSTARS2] = {SPR_ASTR, FF_ANIMATE|B, -1,nil,1,2,S_AMYSTARS2}
states[S_AMYSTARS3] = {SPR_ASTR, C, 2,nil,0,0,S_AMYSTARS4}
states[S_AMYSTARS4] = {SPR_NULL, A, 2,nil,0,0,S_AMYSTARS3}

//MASKED eggman's idle
states[S_MASKEDIDLE] = {SPR_MASK, FF_ANIMATE|A, -1,nil,1,30,S_MASKEDIDLE}

//knuckles sparks but it loops lol
local radius = FRACUNIT*320	-- you guys change that to anything idgaf!


for i = 1, 14
	freeslot("S_KNUXSPARK"..i)
end

local ltrans = {}
ltrans[5] = TR_TRANS30
ltrans[6] = TR_TRANS60
ltrans[7] = TR_TRANS80

for i = 0, 13
	states[S_KNUXSPARK1+i] = {i%2==0 and SPR_KSPK or SPR_NULL,
			i%2 == 0 and i/2|FF_FULLBRIGHT|(ltrans[i/2] or 0) or A,
			i%2 and 1 or 2,
			nil,
			0,
			0,
			i<13 and S_KNUXSPARK2+i or S_KNUXSPARK1
		}
end

//prevent stage skipping by changing maps (unless you have debug cheats enabled)
rawset(_G, "completedstages", 0)

addHook("MapLoad", function()
	if not server return end
	if gamemap == 01 or not (mapheaderinfo[gamemap].bluemiststory)
		diedstage = 1
		completedstages = 0
	end
end)

addHook("ThinkFrame", function()
	if cv_debugcheats.value
		if (mapheaderinfo[gamemap].bluemiststory)
			completedstages = gamemap-7
		end
		return
	end
	if stagecleared return end
	for i = 0, 5
		if gamemap == 07 + i
			if completedstages != i
				G_ExitLevel(1, 1)
			end
		end
	end
end)

//turn off skin restrict
COM_AddCommand("b_skinrestrict", function(p)

	if not cv_debugcheats.value
		CONS_Printf(p, "Debug cheats required")
		return
	end

	if not characterhack
		characterhack = true
		CONS_Printf(p, "DEBUG: Blue Mist character restriction turned off. Be warned, not accounted for balance! Not recommended on a first playthrough!")
	else
		characterhack = false
		CONS_Printf(p, "DEBUG: Blue Mist character restriction turned on.")
	end
end, 1)

//add the blue mist option to our main menu for gamemodes
M_menus["mpselect_main"].mpselect_mainmenu.choices = {
	{"TARTARUS", "Explore Tartarus with your team!",	"mpselect_tartarus"},
	{"VOID RUN", "Take on tough challenges, starting from nothing!",	"mpselect_void"},
	{"VISION QUEST", "Face off against strong bosses in a timed battle!", "mpselect_challenge"},
	{"COLISEUM", "Fight it out with your friends and see who's the best!", "mpselect_coloseo"},
	{"CUSTOM", "Explore custom-made dungeons by loading files!", "mpselect_cdungeon"},
	{"BLUE MIST", "Experience a unique scenario with Sonic, Tails, Knuckles, and Amy!", "mpselect_bluemist"},
}

local function drawMenu_blueMist(v, mo, choice, forcetimer)
	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0

	local fade = V_50TRANS
	if timer
		fade = V_90TRANS - ((8 - timer)/2)*V_10TRANS
	end
	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	v.fadeScreen(31, 7)

	-- OLD MENU DRAWER
	if 1	-- < i know this is stupid but at least it's more organized :)
		local oldtimer = TICRATE/3 - (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

		local mx = 320
		if oldtimer
			mx = 320 + oldtimer*64
		end

		-- draw menu string or smth:
		v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
		V_drawString(v, mx - 102, 0, "SELECT", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

		local m = M_menus["mpselect_main"].mpselect_mainmenu

		-- draw the command help first:
		v.drawFill(oldtimer*96, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

		-- draw the commands for it:
		for i = 1, #m.choices do
			V_drawString(v, mx - (124 + i*6), 40 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
		end
	end

	-- main
	local mx = 320
	if timer
		mx = 320 + timer*64
	end
	PDraw(v, mx, 200, v.cachePatch("M_BG1"), V_SNAPTORIGHT|V_SNAPTOBOTTOM)

	-- draw menu string or smth:
	v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, mx - 102, 0, "MAIN CAMPAIGN", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

	local m = M_menus["mpselect_main"].mpselect_bluemist

	-- draw the command help first:
	v.drawFill(0, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	V_drawString(v, 12, 182, m.choices[choice][2], "NFNT", V_SNAPTORIGHT|V_SNAPTOBOTTOM, nil, 0, nil)

	-- draw the commands for it:
	for i = 1, #m.choices do
		-- draw cursor:
		if i == choice
			PDraw(v, mx - (130 + i*6), 56 + (i*20), v.cachePatch("M_CURS1"), V_SNAPTORIGHT)
		end
		V_drawString(v, mx - (124 + i*6), 60 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
	end
end

M_menus["mpselect_main"].mpselect_bluemist = {
	opentimer = TICRATE/3,
	closetimer = TICRATE/3,
	hoversound = sfx_hover,
	confirmsound = sfx_confir,
	prev = "mpselect_mainmenu",
	drawer = drawMenu_blueMist,
	
	-- choices: mostly used for the input handler. The drawer might not need it.
	choices = {
		-- syntax: {name, description, nextmenu}
		{"MAIN STORY", "Uncover a new mystery throughout 6 consecutive battles!", ""},
		{"EXTRA STAGE", "Confront a difficult extra battle after the main story! (Unfinished)", ""},
	},
	
	confirmfunc = 	function(mo)
		local count = 0
		for p in players.iterate do
			count = $+1
		end
		if mo.m_menuchoices[mo.m_submenu] == 2 --or count > 4
			S_StartSound(nil, sfx_not, mo.player)
			return true
		end
		skinrestrict = true
		server.bluemist = true
		bluemistbegin = true
		
		for p in players.iterate
			p.rewardqueue = {}
			p.queueposition = 0
			p.rewardposition = {}
		end
		
		mo.P_inputs[BT_JUMP] = 2	-- skip inpt
		NET_begin()
		for i = 1, count
			server.P_netstat.skinlist[1][i] = nil
		end
		server.P_netstat.buffer = {
			map = 7, --7
			gamemode = GM_COOP,
			extradata = 5, //difficulty rating; sets the number of continues (3 right now)
			maxparties = 1,
		}
		M_closeMenu(mo)
	end,
}

//character things, incredibly messy and unnecessarily convoluted because i made this script like a year ago
addHook("ThinkFrame", function()
	//force skin color
	if (mapheaderinfo[gamemap].bluemiststory)
		for p in players.iterate
			local mo = p.mo
			if mo.skin == "sonic"
				mo.color = SKINCOLOR_BLUE
			elseif mo.skin == "tails"
				mo.color = SKINCOLOR_ORANGE
			elseif mo.skin == "knuckles"
				mo.color = SKINCOLOR_RED
			elseif mo.skin == "amy"
				mo.color = SKINCOLOR_ROSY
			end
		end
	end
	
	//forces the skins to sonic, tails, knuckles, and amy for blue mist story
	if not skinrestrict return end
	if characterhack return end
	local minskin = 0
	local maxskin = 0
	for i = 0, 32
		if skins[i] and skins[i].valid
			maxskin = i
		else
			break	-- skins are a normal list, so as soon as one is invalid, all the others are too
		end
	end
	//we need to make sure you can't have two of the same character! ...unless you have teamsize 5 or more.
	for p in players.iterate
		local mo = p.mo
		local net = server.P_netstat
		if not net.skinlist
			skinrestrict = false
			server.bluemist = false
			return
		end
		if not p.P_party return end
		local da = net.skinlist[p.P_party]
		if da[1] != "sonic" and da[2] != "sonic" and da[3] != "sonic" and da[4] != "sonic"
			sonicisdead = false
		end
		if da[1] != "tails" and da[2] != "tails" and da[3] != "tails" and da[4] != "tails"
			tailsisdead = false
		end
		if da[1] != "knuckles" and da[2] != "knuckles" and da[3] != "knuckles" and da[4] != "knuckles"
			knucklesisdead = false
		end
		if da[1] != "amy" and da[2] != "amy" and da[3] != "amy" and da[4] != "amy"
			amyisdead = false
		end
		if server.P_netstat.teamlen <= 4
			for i = 1, 4
				if da[i] == "sonic"
					sonicisdead = true
				end
				if da[i] == "tails"
					tailsisdead = true
				end
				if da[i] == "knuckles"
					knucklesisdead = true
				end
				if da[i] == "amy"
					amyisdead = true
				end
			end
		end

		if mo.P_net_skinselect == nil return end
		
		/*if sonicisdead and tailsisdead and knucklesisdead and amyisdead
			mo.P_net_skinselect = 1
		end*/
		
		//if <SKIN> selected, go to <NAME1>. if <NAME1> isnt there, go to <NAME2>, then <NAME3> 
		//<skin>: <name1>, <name2>, <name3>
		--if #da < 4
		if not (sonicisdead and tailsisdead and knucklesisdead and amyisdead)
			//sonic: tails, knuckles, amy
			if sonicisdead == true and mo.P_net_skinselect == 0 and not mo.P_net_launchprompt
				if not tailsisdead
					//what if you went left tho
					if mo.prevselect == 1
						if not amyisdead
							mo.P_net_skinselect = 3
						elseif amyisdead and not knucklesisdead
							mo.P_net_skinselect = 2
						elseif knucklesisdead
							mo.P_net_skinselect = 1
						end
					else
						mo.P_net_skinselect = 1
					end
				elseif tailsisdead and not knucklesisdead
					mo.P_net_skinselect = 2
				elseif tailsisdead and knucklesisdead
					mo.P_net_skinselect = 3
				end
			end
			//tails: knuckles, amy, sonic
			if tailsisdead == true and mo.P_net_skinselect == 1
				if not knucklesisdead
					//what if you went left tho
					if mo.prevselect == 2
						if not sonicisdead
							mo.P_net_skinselect = 0
						elseif sonicisdead and not amyisdead
							mo.P_net_skinselect = 3
						elseif amyisdead
							mo.P_net_skinselect = 2
						end
					else
						mo.P_net_skinselect = 2
					end
				elseif knucklesisdead and not amyisdead
					mo.P_net_skinselect = 3
				elseif knucklesisdead and amyisdead
					mo.P_net_skinselect = 0
				end
			end
			//knuckles: amy, sonic, tails
			if knucklesisdead == true and mo.P_net_skinselect == 2
				if not amyisdead
					//what if you went left tho
					if mo.prevselect == 3
						if not tailsisdead
							mo.P_net_skinselect = 1
						elseif tailsisdead and not sonicisdead
							mo.P_net_skinselect = 0
						elseif sonicisdead
							mo.P_net_skinselect = 3
						end
					else
						mo.P_net_skinselect = 3
					end
				elseif amyisdead and not sonicisdead
					mo.P_net_skinselect = 0
				elseif amyisdead and sonicisdead
					mo.P_net_skinselect = 1
				end
			end
			//amy: sonic, tails, knuckles
			if amyisdead == true and mo.P_net_skinselect == 3
				if not sonicisdead
					//what if you went left tho
					if mo.prevselect == 0
						if not knucklesisdead
							mo.P_net_skinselect = 2
						elseif knucklesisdead and not tailsisdead
							mo.P_net_skinselect = 1
						elseif tailsisdead
							mo.P_net_skinselect = 0
						end
					else
						mo.P_net_skinselect = 0
					end
				elseif sonicisdead and not tailsisdead
					mo.P_net_skinselect = 1
				elseif sonicisdead and tailsisdead
					mo.P_net_skinselect = 2
				end
			end
		end
		
		//going too far left
		if mo.P_net_skinselect >= maxskin
			//goes to amy, sonic, then tails
			if not amyisdead
				mo.P_net_skinselect = 3
			elseif amyisdead and not knucklesisdead
				mo.P_net_skinselect = 2
			elseif knucklesisdead and not tailsisdead
				mo.P_net_skinselect = 1
			elseif tailsisdead
				if (sonicisdead and tailsisdead and knucklesisdead and amyisdead)
					mo.P_net_skinselect = 3
				else
					mo.P_net_skinselect = 0
				end
			end
		end
		
		//going too far right
		if mo.P_net_skinselect > 3
			//goes to sonic, tails, then knuckles
			if not sonicisdead
				mo.P_net_skinselect = 0
			elseif sonicisdead and not tailsisdead
				mo.P_net_skinselect = 1
			elseif sonicisdead and not knucklesisdead
				mo.P_net_skinselect = 2
			elseif knucklesisdead
				if (sonicisdead and tailsisdead and knucklesisdead and amyisdead)
					mo.P_net_skinselect = 0
				else
					mo.P_net_skinselect = 3
				end
			end
		end
		
		//unintended skin failsafe
		if mo.skin != "sonic" and mo.skin != "tails" and mo.skin != "knuckles" and mo.skin != "amy"
			if not mo.nomorebruh
				mo.bruh = true
			end
		end
		if mo.bruh
			mo.P_net_skinselect = 0
			mo.nomorebruh = true
			mo.bruh = false
		end
		
		mo.prevselect = mo.P_net_skinselect
	end
end)

//there's a bug in the thinkframe version where the iterator refuses to work if a hypothetical player #3 joins the team before hypothetical player #2 joins so this playerthink is to make sure all players get the skin restrict treatment but the thinkframe up there still has to be there because in the playerthink function for SOME REASON looks wonky whenever your skin selection gets sent back which DIDNT HAPPEN IN THE THINKFRAME FUNCTION AND I DONT KNOW HOW TO FIX THIS BUG SO IM LEAVING THIS RANT HERE AND CRYING ABOUT IT
addHook("PlayerThink", function(p)
	//force skin color
	if (mapheaderinfo[gamemap].bluemiststory)
		local mo = p.mo
		if mo.skin == "sonic"
			mo.color = SKINCOLOR_BLUE
		elseif mo.skin == "tails"
			mo.color = SKINCOLOR_ORANGE
		elseif mo.skin == "knuckles"
			mo.color = SKINCOLOR_RED
		elseif mo.skin == "amy"
			mo.color = SKINCOLOR_ROSY
		end
	end
	
	//forces the skins to sonic, tails, knuckles, and amy for blue mist story
	if not skinrestrict return end
	if characterhack return end
	local minskin = 0
	local maxskin = 0
	for i = 0, 32
		if skins[i] and skins[i].valid
			maxskin = i
		else
			break	-- skins are a normal list, so as soon as one is invalid, all the others are too
		end
	end
	
	//we need to make sure you can't have two of the same character!
	local mo = p.mo
	local net = server.P_netstat
	local inputs = mo.P_inputs
	if not net.skinlist
		skinrestrict = false
		server.bluemist = false
		return
	end
	if not p.P_party return end
	local da = net.skinlist[p.P_party]
	if da[1] != "sonic" and da[2] != "sonic" and da[3] != "sonic" and da[4] != "sonic"
		sonicisdead = false
	end
	if da[1] != "tails" and da[2] != "tails" and da[3] != "tails" and da[4] != "tails"
		tailsisdead = false
	end
	if da[1] != "knuckles" and da[2] != "knuckles" and da[3] != "knuckles" and da[4] != "knuckles"
		knucklesisdead = false
	end
	if da[1] != "amy" and da[2] != "amy" and da[3] != "amy" and da[4] != "amy"
		amyisdead = false
	end
	if server.P_netstat.teamlen <= 4
		for i = 1, 4
			if da[i] == "sonic"
				sonicisdead = true
			end
			if da[i] == "tails"
				tailsisdead = true
			end
			if da[i] == "knuckles"
				knucklesisdead = true
			end
			if da[i] == "amy"
				amyisdead = true
			end
		end
	end

	if mo.P_net_skinselect == nil return end
	
	/*if sonicisdead and tailsisdead and knucklesisdead and amyisdead
		mo.P_net_skinselect = 1
	end*/
	
	//if <SKIN> selected, go to <NAME1>. if <NAME1> isnt there, go to <NAME2>, then <NAME3> 
	//<skin>: <name1>, <name2>, <name3>
	//sonic: tails, knuckles, amy
	if not (sonicisdead and tailsisdead and knucklesisdead and amyisdead)
		--mo.extrajoin = 1
		if sonicisdead == true and mo.P_net_skinselect == 0 and not mo.P_net_launchprompt
			if not tailsisdead
				//what if you went left tho
				if mo.prevselect == 1
					if not amyisdead
						mo.P_net_skinselect = 3
					elseif amyisdead and not knucklesisdead
						mo.P_net_skinselect = 2
					elseif knucklesisdead
						mo.P_net_skinselect = 1
					end
				else
					mo.P_net_skinselect = 1
				end
			elseif tailsisdead and not knucklesisdead
				mo.P_net_skinselect = 2
			elseif tailsisdead and knucklesisdead
				mo.P_net_skinselect = 3
			end
		end
		//tails: knuckles, amy, sonic
		if tailsisdead == true and mo.P_net_skinselect == 1
			if not knucklesisdead
				//what if you went left tho
				if mo.prevselect == 2
					if not sonicisdead
						mo.P_net_skinselect = 0
					elseif sonicisdead and not amyisdead
						mo.P_net_skinselect = 3
					elseif amyisdead
						mo.P_net_skinselect = 2
					end
				else
					mo.P_net_skinselect = 2
				end
			elseif knucklesisdead and not amyisdead
				mo.P_net_skinselect = 3
			elseif knucklesisdead and amyisdead
				mo.P_net_skinselect = 0
			end
		end
		//knuckles: amy, sonic, tails
		if knucklesisdead == true and mo.P_net_skinselect == 2
			if not amyisdead
				//what if you went left tho
				if mo.prevselect == 3
					if not tailsisdead
						mo.P_net_skinselect = 1
					elseif tailsisdead and not sonicisdead
						mo.P_net_skinselect = 0
					elseif sonicisdead
						mo.P_net_skinselect = 3
					end
				else
					mo.P_net_skinselect = 3
				end
			elseif amyisdead and not sonicisdead
				mo.P_net_skinselect = 0
			elseif amyisdead and sonicisdead
				mo.P_net_skinselect = 1
			end
		end
		//amy: sonic, tails, knuckles
		if amyisdead == true and mo.P_net_skinselect == 3
			if not sonicisdead
				//what if you went left tho
				if mo.prevselect == 0
					if not knucklesisdead
						mo.P_net_skinselect = 2
					elseif knucklesisdead and not tailsisdead
						mo.P_net_skinselect = 1
					elseif tailsisdead
						mo.P_net_skinselect = 0
					end
				else
					mo.P_net_skinselect = 0
				end
			elseif sonicisdead and not tailsisdead
				mo.P_net_skinselect = 1
			elseif sonicisdead and tailsisdead
				mo.P_net_skinselect = 2
			end
		end
	end
	
	//going too far left
	if mo.P_net_skinselect >= maxskin
		//goes to amy, sonic, then tails
		if not amyisdead
			mo.P_net_skinselect = 3
		elseif amyisdead and not knucklesisdead
			mo.P_net_skinselect = 2
		elseif knucklesisdead and not tailsisdead
			mo.P_net_skinselect = 1
		end
	end
	
	//going too far right
	if mo.P_net_skinselect > 3
		//goes to sonic, tails, then knuckles
		if not sonicisdead
			mo.P_net_skinselect = 0
		elseif sonicisdead and not tailsisdead
			mo.P_net_skinselect = 1
		elseif sonicisdead and not knucklesisdead
			mo.P_net_skinselect = 2
		elseif knucklesisdead
			mo.P_net_skinselect = 3
		end
	end
	
	mo.prevselect = mo.P_net_skinselect
end)

//will be activated for certain objects in cutscene functions
addHook("MobjThinker", function(mo)
	if mo and mo.valid
		if not (mapheaderinfo[gamemap].bluemiststory) return end
		if not mo.cutscene return end
		if P_IsObjectOnGround(mo)
			//preventing idle stances for player objects appearing in cutscenes
			if mo.noidle 
				if mo.momx != 0 or mo.momy != 0
					mo.momx = $*80/100
					mo.momy = $*80/100
					mo.state = S_PLAY_SKID
					mo.frame = A
				else
					mo.state = S_PLAY_STND 
				end
			end
			//preventing cycling when in said idle stance
			if mo.noidlebored
				mo.frame = A
			end
		end
		//for silver
		if mo.falling 
			if P_IsObjectOnGround(mo)
				mo.state = S_PLAY_STND
			end
		end
		//keeping power aura mid conversation for shadow and blaze
		if mo.power
			summonAura(mo, mo.powercolor)
		end
		//tails flying down during elevator ride
		if mo.flying
			if P_IsObjectOnGround(mo)
				mo.state = S_PLAY_STND
				mo.tails.skin = "tails"
				if not mo.landed
					mo.tails.state = S_TAILSOVERLAY_STAND
					mo.landed = true
				end
				mo.tails.color = SKINCOLOR_ORANGE
				local x = mo.x - 6*cos(mo.angle)
				local y = mo.y - 6*sin(mo.angle)
				P_TeleportMove(mo.tails, x, y, mo.z)
				mo.noidle = true
				S_StopSound(mo)
			else
				mo.landed = false
				if leveltime%10 == 0
					S_StartSound(mo, sfx_putput)
				end
				mo.momz = -8*FRACUNIT
				P_TeleportMove(mo.tails, mo.x, mo.y, mo.z+4*FRACUNIT)
			end
		end
		//fake sonic's translucency
		if mo.scary
			mo.frame = A|FF_TRANS50
		end
		//cutscene metal sonic's phantom ruby aura
		if mo.ruby
			if not (leveltime%P_RandomRange(10, 40))
				local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height, MT_DUMMY)
				elec.sprite = SPR_DELK
				elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
				elec.destscale = FRACUNIT*4
				elec.scalespeed = FRACUNIT/4
				elec.tics = TICRATE/8
				elec.color = SKINCOLOR_MAGENTA
			end
			if leveltime%P_RandomRange(10, 40) == 0
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
	end
end, MT_PFIGHTER)

addHook("MapLoad", function()
	if not server return end
	skinrestrict = false
	boxflip = false
	sonicisdead = false
	tailsisdead = false
	knucklesisdead = false
	amyisdead = false
	cutscene = false
	stagecleared = false
	playersdead = 0
	server.bluemist = false
	for p in players.iterate
		COM_BufInsertText(p, "hu_partybars on")
		COM_BufInsertText(p, "hu_command on")
		COM_BufInsertText(p, "hu_battlebars on")
		COM_BufInsertText(p, "hu_partystatus on")
		p.canileave = false
	end
	if (mapheaderinfo[gamemap].bluemiststory)
		--change the day of week
		SAVE_localtable.date[1] = 6
		--change the time
		SAVE_localtable.date[5] = 5
		--change the monthday
		SAVE_localtable.date[3] = 30
		--change the month
		SAVE_localtable.date[2] = 1
	else
		--change the day of week
		SAVE_localtable.date[1] = 3
		--change the time
		SAVE_localtable.date[5] = -1
		--change the monthday
		SAVE_localtable.date[3] = 20
		--change the month
		SAVE_localtable.date[2] = 4
	end
	
	//reset stats for stageClear
	if server and server.P_BattleStatus[1]
		local btl = server.P_BattleStatus[1]
		btl.netstats.timesdied = 0
		btl.netstats.itemsused = 0
	end
end)

//battle start stuff
addHook("MobjThinker", function(mo)
	if mo and mo.valid
		if mo.cutscene return end --make sure cutscene MT_PFIGHTERs arent affected
		if not (mapheaderinfo[gamemap].bluemiststory) return end
		local btl = server.P_BattleStatus[1]
		if btl.battlestate == BS_START
			btl.emeraldpow_max = 3
			if mo.plyr
				mo.hp = mo.maxhp
				mo.sp = mo.maxsp
			end
			//bring the hud back!
			for p in players.iterate
				COM_BufInsertText(p, "hu_command on")
			end
			//altering movesets
			for k,v in ipairs(mo.skills)
				if v == "dekaja" then table.remove(mo.skills, k) end
				if v == "analysis" then table.remove(mo.skills, k) end
				if v == "samarecarm" 
					table.remove(mo.skills, k)
					--table.insert(mo.skills, "recarm")
				end
				if v == "me patra" 
					table.remove(mo.skills, k)
					table.insert(mo.skills, "patra")
				end
				if v == "maragidyne" 
					table.remove(mo.skills, k)
					table.insert(mo.skills, "inferno link")
				end
				if v == "makougaon" 
					table.remove(mo.skills, k)
				end
				if v == "magarudyne"
					table.remove(mo.skills, k)
				end
				if v == "garuverse"
					table.remove(mo.skills, k)
					table.insert(mo.skills, "garuverse alter")
				end
				if v == "mediarahan" 
					table.remove(mo.skills, k)
					if charStats[mo.stats].name == "Amy"
						table.insert(mo.skills, "mediarama")
						table.insert(mo.skills, "prayer of affection")
					elseif charStats[mo.stats].name == "Tails" 
						table.insert(mo.skills, "mamakakaja")
						table.insert(mo.skills, "faultless reinforcement")
					end
				end
				if v == "diarahan" 
					if charStats[mo.stats].name == "Tails"
						table.remove(mo.skills, k)
						table.insert(mo.skills, "diarama")
					elseif charStats[mo.stats].name == "Knuckles"
						table.remove(mo.skills, k)
						table.insert(mo.skills, "rakukaja v2")
						table.insert(mo.skills, "hostile judgement")
					end
				end
				if v == "hamaon" 
					table.remove(mo.skills, k)
					table.insert(mo.skills, "hamaon v2")
				end
				for j,e in ipairs(mo.skills)
					if attackDefs[v].replace
						if e == attackDefs[v].replace or (attackDefs[attackDefs[v].replace].replace and e == attackDefs[attackDefs[v].replace].replace)
							table.remove(mo.skills, k)
						end
					end
				end
			end
			
			for k,v in ipairs(mo.passiveskills)
				if v == "wild vertigo"
					for i = 1, #mo.allies
						local ally = mo.allies[i]
						if ally.passiveskills[#ally.passiveskills] != "wild vertigo pt.2" //weird way of doing this
							table.insert(ally.passiveskills, "wild vertigo pt.2")
						end
					end
				end
				if v == "regenerate 3"
					table.remove(mo.passiveskills, k)
				end
				if v == "endure"
					table.remove(mo.passiveskills, k)
				end
				for j,e in ipairs(mo.skills)
					if attackDefs[v].replace
						if e == attackDefs[v].replace or (attackDefs[attackDefs[v].replace].replace and e == attackDefs[attackDefs[v].replace].replace) --wtf
							table.remove(mo.skills, k)
						end
					end
				end
			end
			//increased stats from stat tuner
			for p in players.iterate
				for k,v in ipairs(server.plentities[1])
					if p.rewardposition and #p.rewardposition
						for i = 1, #p.rewardposition
							if k == p.rewardposition[i]
								if p.booststats
									if p.booststats[k] and #p.booststats[k]
										local stats = {"strength", "magic", "endurance", "agility", "luck"}
										for j = 1, #stats
											v[stats[j]] = p.booststats[k][j]
											v.savestats[j] = p.booststats[k][j]
										end
									end
								end
								/*if p.boostskills and p.boostskills[k] and #p.boostskills[k]
									v.skills = p.boostskills[k]
								end*/
								if p.boostpassives and p.boostpassives[k] and #p.boostpassives[k]
									v.passiveskills = p.boostpassives[k]
								end
							end
						end
					end
				end
				/*for i = 1, #p.rewardposition
					print(p.rewardposition[i])
				end*/
			end
			
			//remove multi targets items when going into stage 5
			if gamemap == 11
				for k,v in ipairs(btl.items)
					local attack = itemDefs[v[1]].attack
					local skill = attackDefs[attack]
					if skill.target == TGT_ALLENEMIES and skill.type != ATK_SUPPORT
						table.remove(btl.items, k)
					end
				end
			end
		end
		btl.boss = true //no running!
	end
end, MT_PFIGHTER)

attackDefs["rakukaja v2"] = {
		name = "Rakukaja v2",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Raise one ally's defence \nby 2 stages.",
		target = TGT_ALLY,
		buff = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["def"][1] >= 75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_buff)
				buffStat(target, "def", 50)
				for i = 1,16
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_LAVENDER
					dust.scale = FRACUNIT*2
				end

			elseif timer > 20 and timer <= 50

				if leveltime%2 == 0
					for i = 1,16

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_LAVENDER
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end
				end

				for i = 1, 8
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.sprite = SPR_SUMN
					thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
					thok.momz = P_RandomRange(6, 16)*FRACUNIT
					thok.color = SKINCOLOR_LAVENDER
					thok.tics = P_RandomRange(10, 35)
				end
			elseif timer == 60
				return true
			end
		end,
}

//garuverse v2 sounded more of an improvement than an alternative and this one targets only one enemy
attackDefs["garuverse alter"] = {
		name = "Garuverse Alter",
		type = ATK_WIND,
		power = 180,
		accuracy = 999,
		costtype = CST_SP,
		cost = 20,
		desc = "Medium Wind dmg to one enemy.\nDeploys a field that heals 50%\nof damage dealt for 4 turns.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			
			if timer == 20
				playSound(mo.battlen, sfx_wind2)
				for i = 1, 12
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
				end

			elseif timer == 30
			or timer == 33
			or timer == 36
			or timer == 39
				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.scale = FRACUNIT/4
				s.sprite = SPR_SLAS
				s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
				s.destscale = FRACUNIT*9
				s.scalespeed = FRACUNIT
				s.tics = TICRATE/3

			elseif timer == 40
				damageObject(target)
				for i = 1, 32
					local g = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					g.scale = FRACUNIT/2
					g.destscale = 1
					g.color = SKINCOLOR_EMERALD
					g.frame = A
					if i%2 then g.color = SKINCOLOR_WHITE end
					g.momx = P_RandomRange(-15, 15)*FRACUNIT
					g.momy = P_RandomRange(-15, 15)*FRACUNIT
					g.momz = P_RandomRange(-15, 15)*FRACUNIT
				end
				if target.damagestate ~= DMG_MISS
				and target.damagestate ~= DMG_BLOCK
				and target.damagestate ~= DMG_DRAIN
					startField(target, FLD_GARUVERSE, 5)
				end
			elseif timer == 75
				return true
			end
		end,
}

attackDefs["hamaon v2"] = {
		name = "Hamaon v2",
		type = ATK_BLESS,
		power = 100,
		accuracy = 40,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 16,
		desc = "Expel based attack. \nModerate chance of instant kill to \none enemy. Also has moderate chance of\nremoving buffs from one boss.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if target.cards
				local cam = server.P_BattleStatus[mo.battlen].cam
				for kk, vv in ipairs(target.cards)

					if not target continue end
					if not vv continue end

					if timer <= 70
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

					if timer == 80
					and vv.valid
						P_RemoveMobj(vv)
					end
				end
			end

			if timer == 90
				target.cards = nil
			end
			
			if timer == 80
				playSound(mo.battlen, sfx_hamas1)
				if not target.boss
					damageObject(target)
				else
					local hitrate = 40 + (mo.luck - target.luck)/2
					if P_RandomRange(1, 100) <= hitrate
						playSound(mo.battlen, sfx_status)
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
						for j = 1, #strs
							local t = target
							local s = strs[j]
							if t.buffs[s][1] > 0
								t.buffs[s][1] = 0
								t.buffs[s][2] = 0
							end
						end
						BTL_logMessage(targets[1].battlen, "Stat increases nullified")
					else
						damageObject(target)
					end
				end

				local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
				thok.state = S_INVISIBLE
				thok.tics = 1
				thok.scale = FRACUNIT*4
				A_OldRingExplode(thok, MT_SUPERSPARK)
			end

			if timer == 100
				return true
			end

			if timer >= 15
			and timer <= 75
				if not (timer%4)
					if not target.cards then target.cards = {} end
					for i = 1,8
						local angle = P_RandomRange(1, 359)*ANG1
						local x = target.x + 64*(cos(angle))
						local y = target.y + 64*(sin(angle))
						local item = P_SpawnMobj(x, y, target.z, MT_DUMMY)
						playSound(mo.battlen, sfx_hamaca)
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
		end,
}

//emerald skills
attackDefs["inferno link"] = {
		name = "Inferno Link",
		type = ATK_FIRE,
		power = 100,
		accuracy = 999,
		costtype = CST_EP,
		cost = 2,
		critical = 40,
		link = true,
		desc = "Medium Fire damage to\none enemy. Following allied attacks\ngain Link follow-ups and boosted magic.\nVery high critical rate.",
		target = TGT_ENEMY,
		nocast = 	function(targets, n)	//dont activate if only remaining enemy is eggman
						if targets[n].enemy == "b_eggman"
							BTL_logMessage(targets[1].battlen, "No effect.")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			//two anims for this, the initiator (sonic selects the move), and the link (links off other move)
			local target = hittargets[1]
			local emeraldcolors = {SKINCOLOR_MINT, SKINCOLOR_EMERALD, SKINCOLOR_FOREST}
			local btl = server.P_BattleStatus[mo.battlen]
			//initiator 
			if mo.infernoselect
				local boostdamage = getDamage(target, mo, nil, 100)
				if timer == 1
					mo.startx = mo.x
					mo.starty = mo.y
					mo.startz = mo.z
					mo.speen = false
					mo.spinangle = 270
					mo.anglespeed = 20
					playSound(mo.battlen, sfx_bufu1)
					for i = 1, 30
						local energy = P_SpawnMobj(mo.x-P_RandomRange(200,-200)*FRACUNIT, mo.y-P_RandomRange(200,-200)*FRACUNIT, mo.z+P_RandomRange(150,0)*FRACUNIT, MT_DUMMY)
						energy.sprite = SPR_THOK
						energy.frame = FF_FULLBRIGHT
						energy.color = emeraldcolors[P_RandomRange(1, #emeraldcolors)]
						energy.scale = FRACUNIT/P_RandomRange(3, 6)
						energy.tics = 20
						energy.momx = (mo.x - energy.x)/20
						energy.momy = (mo.y - energy.y)/20
						energy.momz = (mo.z - energy.z)/20
					end
					mo.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPTHING
				end
				if timer == 20
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
					playSound(mo.battlen, sfx_bufu6)
					if mo.status_condition == COND_HYPER
						mo.hyperpower = true
						playSound(mo.battlen, sfx_buff2)
						localquake(mo.battlen, FRACUNIT*10, 10)
					else
						mo.status_condition = COND_HYPER
					end
				end
				if mo.hyperpower
					summonAura(mo, SKINCOLOR_EMERALD)
				end
				if timer == 40 or timer == 50
					playSound(mo.battlen, sfx_spndsh)
					ANIM_set(mo, mo.anim_run, true)
					local tgtx = target.x + 100*cos(target.angle + ANG1*mo.spinangle)
					local tgty = target.y + 100*sin(target.angle + ANG1*mo.spinangle)
					mo.angle = R_PointToAngle2(mo.x, mo.y, tgtx, tgty)
				end
				if timer == 60
					playSound(mo.battlen, sfx_cdfm01)
					local tgtx = target.x + 100*cos(target.angle + ANG1*mo.spinangle)
					local tgty = target.y + 100*sin(target.angle + ANG1*mo.spinangle)
					mo.savemomx = (tgtx - mo.x)/3
					mo.savemomy = (tgty - mo.y)/3
					mo.angle = R_PointToAngle2(mo.x, mo.y, tgtx, tgty)
				end
				if timer >= 60
					local g = P_SpawnGhostMobj(mo)
					g.frame = $|FF_FULLBRIGHT
					P_TeleportMove(g, g.x, g.y, mo.z)
					P_TeleportMove(mo, mo.x, mo.y, mo.z)
					if not mo.speen
						mo.momx = mo.savemomx
						mo.momy = mo.savemomy
					end
					if R_PointToDist2(mo.x, mo.y, target.x, target.y) <= 102*FRACUNIT
						mo.momx = 0
						mo.momy = 0
						mo.speen = true
					end
					if mo.speen and timer < 128
						mo.anglespeed = $+1
						mo.spinangle = $-mo.anglespeed
						local tgtx = target.x + 100*cos(target.angle + ANG1*mo.spinangle)
						local tgty = target.y + 100*sin(target.angle + ANG1*mo.spinangle)
						P_TeleportMove(mo, tgtx, tgty, mo.z)
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y) + ANG1*90
					end
					if timer == 70
					or timer == 78
					or timer == 84
					or timer == 90
					or timer == 96
					or timer == 101
					or timer == 106
					or timer == 111
					or timer == 116
					or timer == 121
					or timer == 126
						playSound(mo.battlen, sfx_mswing)
					end
					if timer == 126
						playSound(mo.battlen, sfx_zoom)
						P_InstaThrust(mo, mo.angle, 1500*FRACUNIT)
						mo.flags = $|MF_NOCLIP
					end
					
					if timer == 140
						ANIM_set(mo, mo.anim_atk, true)
						for i = 1, 30
							mo.angle = target.angle + ANG1*270
							local dist = 1000 - (i*50)
							local tgtx = target.x + dist*cos(target.angle + ANG1*90)
							local tgty = target.y + dist*sin(target.angle + ANG1*90)
							local e = P_SpawnGhostMobj(mo)
							P_TeleportMove(e, tgtx, tgty, target.floorz)
							e.tics = 30
							e.color = SKINCOLOR_BLUE
							e.frame = FF_TRANS50|FF_FULLBRIGHT
							e.scale = FRACUNIT
							e.destscale = 0
							e.scalespeed = e.scale/12
						end
						local s = P_SpawnMobj(target.x, target.y, target.z+1*FRACUNIT, MT_DUMMY)
						s.state = S_SLASHING_1_1
						s.color = SKINCOLOR_RED
						s.frame = $|FF_FULLBRIGHT
						s.scale = FRACUNIT*3
						playSound(mo.battlen, sfx_slash)
						localquake(mo.battlen, FRACUNIT*5, 2)
						
					elseif timer == 143
						local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						s.state = S_SLASHING_2_1
						s.color = SKINCOLOR_RED
						s.frame = $|FF_FULLBRIGHT
						s.scale = FRACUNIT*3
						playSound(mo.battlen, sfx_slash)
						localquake(mo.battlen, FRACUNIT*5, 2)

					elseif timer == 160
						localquake(mo.battlen, FRACUNIT*40, 8)
						if not mo.hyperpower
							damageObject(target)
						else
							damageObject(target, boostdamage*6/5) //1.2x boost if already hyper
							playSound(mo.battlen, sfx_boost1)
							local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
							thok.state = S_INVISIBLE
							thok.tics = 1
							thok.scale = FRACUNIT*3
							A_OldRingExplode(thok, MT_SUPERSPARK)
						end
						buffStat(mo, "mag", 50)
						playSound(mo.battlen, sfx_bexpld)
						playSound(mo.battlen, sfx_buff1)
						playSound(mo.battlen, sfx_fire1)
						playSound(mo.battlen, sfx_fire2)
						
						local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
						s.sprite = SPR_SLSH
						s.frame = I|FF_FULLBRIGHT
						s.scale = FRACUNIT/2
						s.destscale = FRACUNIT*4
						s.scalespeed = FRACUNIT/3
						s.color = SKINCOLOR_RED
						
						local boom = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_BOSSEXPLODE)
						boom.scale = FRACUNIT*4
						boom.state = S_PFIRE1
						boom.frame = $|FF_FULLBRIGHT
						for i = 1, 8
							local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
							smoke.scale = FRACUNIT*6
							smoke.momx = P_RandomRange(-5, 5)*FRACUNIT
							smoke.momy = P_RandomRange(-5, 5)*FRACUNIT
							smoke.momz = P_RandomRange(3, 6)*FRACUNIT
						end
						local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
						sm.fuse = TICRATE/2
						sm.scale = target.scale*3/2
					end
					if timer == 200
						mo.renderflags = $ & ~RF_FULLBRIGHT
						mo.flags = $ & ~MF_NOCLIP & ~MF_NOGRAVITY & ~MF_NOCLIPTHING
						mo.hyperpower = false
						cureStatus(mo)
						P_TeleportMove(mo, mo.startx, mo.starty, mo.startz)
						mo.infernoselect = false
						return true
					end
				end
			//link anim
			else
				if timer == 1
					local s = P_SpawnMobj(target.x, target.y, target.z+1*FRACUNIT, MT_DUMMY)
					s.state = S_SLASHING_1_1
					s.color = SKINCOLOR_RED
					s.frame = $|FF_FULLBRIGHT
					s.scale = FRACUNIT*3
					playSound(mo.battlen, sfx_slash)
					localquake(mo.battlen, FRACUNIT*5, 2)
					
				elseif timer == 4
					local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					s.state = S_SLASHING_2_1
					s.color = SKINCOLOR_RED
					s.frame = $|FF_FULLBRIGHT
					s.scale = FRACUNIT*3
					playSound(mo.battlen, sfx_slash)
					localquake(mo.battlen, FRACUNIT*5, 2)

				elseif timer == 20
					if not btl.turnorder[1].enemy
						buffStat(btl.turnorder[1], "mag", 50)
					end
					localquake(mo.battlen, FRACUNIT*40, 8)
					damageObject(target)
					playSound(mo.battlen, sfx_bexpld)
					playSound(mo.battlen, sfx_buff1)
					playSound(mo.battlen, sfx_fire1)
					playSound(mo.battlen, sfx_fire2)
					
					local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
					s.sprite = SPR_SLSH
					s.frame = I|FF_FULLBRIGHT
					s.scale = FRACUNIT/2
					s.destscale = FRACUNIT*4
					s.scalespeed = FRACUNIT/3
					s.color = SKINCOLOR_RED
					
					local boom = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_BOSSEXPLODE)
					boom.scale = FRACUNIT*4
					boom.state = S_PFIRE1
					boom.frame = $|FF_FULLBRIGHT
					for i = 1, 8
						local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
						smoke.scale = FRACUNIT*6
						smoke.momx = P_RandomRange(-5, 5)*FRACUNIT
						smoke.momy = P_RandomRange(-5, 5)*FRACUNIT
						smoke.momz = P_RandomRange(3, 6)*FRACUNIT
					end
					local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
					sm.fuse = TICRATE/2
					sm.scale = target.scale*3/2
				end
				if timer >= 20
					if not btl.turnorder[1].enemy
						if leveltime%2 == 0
							for i = 1, 3
								local thok = P_SpawnMobj(btl.turnorder[1].x+P_RandomRange(-70, 70)*FRACUNIT, btl.turnorder[1].y+P_RandomRange(-70, 70)*FRACUNIT, btl.turnorder[1].z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
								thok.sprite = SPR_SUMN
								thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
								thok.momz = P_RandomRange(6, 16)*FRACUNIT
								thok.color = SKINCOLOR_TEAL
								thok.tics = P_RandomRange(10, 35)
							end
						end
					end
				end
				if timer == 60
					return true
				end
			end
		end,
}

attackDefs["faultless reinforcement"] = {
		name = "Faultless Reinforcement",
		type = ATK_SUPPORT,
		costtype = CST_EP,
		cost = 2,
		desc = "Give a strong barrier that blocks\nphysical attacks to all allies, raise\ndefense and inflict hyper status to party.",
		target = TGT_ALLALLIES,
		makarakarn = true,
		tetrakarn = true,
		anim = function(mo, targets, hittargets, timer)
			local emeraldcolors = {SKINCOLOR_MINT, SKINCOLOR_EMERALD, SKINCOLOR_FOREST}
			if timer == 1
				mo.fields = {}
				mo.sparkles = {}
				mo.angspeed = 2
				playSound(mo.battlen, sfx_bufu1)
				for i = 1, 30
					local energy = P_SpawnMobj(mo.x-P_RandomRange(200,-200)*FRACUNIT, mo.y-P_RandomRange(200,-200)*FRACUNIT, mo.z+P_RandomRange(150,0)*FRACUNIT, MT_DUMMY)
					energy.sprite = SPR_THOK
					energy.frame = FF_FULLBRIGHT
					energy.color = emeraldcolors[P_RandomRange(1, #emeraldcolors)]
					energy.scale = FRACUNIT/P_RandomRange(3, 6)
					energy.tics = 20
					energy.momx = (mo.x - energy.x)/20
					energy.momy = (mo.y - energy.y)/20
					energy.momz = (mo.z - energy.z)/20
				end
			end
			if timer == 20
				local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
				thok.state = S_INVISIBLE
				thok.tics = 1
				thok.scale = FRACUNIT*4
				A_OldRingExplode(thok, MT_SUPERSPARK)
				playSound(mo.battlen, sfx_hamas2)
				playSound(mo.battlen, sfx_bufu6)
				if mo.status_condition == COND_HYPER
					mo.hyperpower = true
					playSound(mo.battlen, sfx_buff2)
					localquake(mo.battlen, FRACUNIT*10, 10)
				else
					mo.status_condition = COND_HYPER
				end
				//sparkles rotate around invisible field, field multiplies into separate copies for team
				for i = 1, #hittargets
					local field = P_SpawnMobj(mo.x, mo.y, mo.floorz - 5*FRACUNIT, MT_DUMMY)
					field.state = S_INVISIBLE
					field.tics = -1
					field.target = hittargets[i]
					mo.fields[#mo.fields+1] = field
					for i = 1, 20
						local ang = ANG1*(18*(i-1))
						local tgtx = mo.x + 60*cos(mo.angle + ang)
						local tgty = mo.y + 60*sin(mo.angle + ang)
						local sparkle = P_SpawnMobj(tgtx, tgty, mo.floorz - 5*FRACUNIT, MT_DUMMY)
						sparkle.rotate = ang
						sparkle.scale = FRACUNIT/2
						sparkle.tics = -1
						sparkle.sprite = SPR_FILD
						sparkle.frame = FF_FULLBRIGHT
						sparkle.colorized = true
						sparkle.direction = 0
						sparkle.target = field
						mo.sparkles[#mo.sparkles+1] = sparkle
					end
				end
			end
			if mo.hyperpower
				summonAura(mo, SKINCOLOR_EMERALD)
			end
			if timer == 60
				playSound(mo.battlen, sfx_aoaask)
			end
			if timer == 100
				playSound(mo.battlen, sfx_nskill)
			end
			if timer == 190
				playSound(mo.battlen, sfx_mirror)
			end
			if timer >= 120 and timer <= 130
				if leveltime%3 == 0
					mo.angspeed = $+1
				end
			end
			if timer >= 220
				if mo.angspeed > 0
					if leveltime%5 == 0
						mo.angspeed = $-1
					end
				end
			end
			
			for i = 1, #hittargets
				local target = hittargets[i]
				if timer >= 130 and timer < 190
					if leveltime%2 == 0
						local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						s.sprite = SPR_FORC
						s.frame = $|FF_FULLBRIGHT
						s.tics = 1
					end
				end
				if timer == 170
					cureStatus(mo)	-- clear previous status. Especially useful for hunger and its half-stats
					target.status_condition = COND_HYPER
					mo.status_condition = COND_HYPER
					playSound(mo.battlen, sfx_supert)
					playSound(mo.battlen, sfx_supert)
					BTL_logMessage(mo.battlen, "Hyper Mode activated!")
					-- increase all stats
					local stats = {"strength", "magic", "endurance", "agility", "luck"}
					for i = 1, #stats do
						target[stats[i]] = $+10
						mo[stats[i]] = $+10
					end
					local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					A_OldRingExplode(thok, MT_SUPERSPARK)
				end
				if timer == 190
					local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					A_OldRingExplode(thok, MT_SUPERSPARK)

					target.tetrakarn = true
					BTL_logMessage(targets[1].battlen, "Physical barrier invoked!")
				end
				if timer == 210
					buffStat(target, "def", 75)
					if not mo.hyperpower
						playSound(mo.battlen, sfx_buff)
					else
						playSound(mo.battlen, sfx_buff2)
						buffStat(target, "crit", 75)
						BTL_logMessage(targets[1].battlen, "Critical rate and defense dramatically increased!")
					end
					for i = 1,16
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_WHITE
						dust.scale = FRACUNIT*2
					end

				elseif timer > 210 and timer <= 240

					local colors = {SKINCOLOR_YELLOW, SKINCOLOR_LAVENDER}
					if leveltime%2 == 0
						for i = 1,16

							local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
							thok.state = S_CDUST1
							thok.momz = P_RandomRange(5, 12)*FRACUNIT
							if mo.hyperpower
								thok.color = colors[P_RandomRange(1,2)]
							else
								thok.color = colors[2]
							end
							thok.tics = P_RandomRange(10, 35)
							thok.scale = FRACUNIT*3/2
						end
					end

					for i = 1, 8
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_SUMN
						thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
						thok.momz = P_RandomRange(8, 18)*FRACUNIT
						if mo.hyperpower
							thok.color = colors[P_RandomRange(1,2)]
						else
							thok.color = colors[2]
						end
						thok.tics = P_RandomRange(10, 35)
					end
				end
			end
			
			if mo.fields and #mo.fields
				for i = 1, #mo.fields
					if mo.fields[i] and mo.fields[i].valid
						local f = mo.fields[i]
						if timer >= 60
							f.momx = (f.target.x - f.x)/10
							f.momy = (f.target.y - f.y)/10
						end
						for i = 1, 4
							local num = i
							if timer == 100
								for i = 1, 20
									local ang = ANG1*(18*(i-1))
									local tgtx = mo.x + 60*cos(mo.angle + ang)
									local tgty = mo.y + 60*sin(mo.angle + ang)
									local sparkle = P_SpawnMobj(tgtx, tgty, mo.floorz - 5*FRACUNIT, MT_DUMMY)
									sparkle.rotate = ang
									sparkle.scale = FRACUNIT/2
									sparkle.tics = -1
									sparkle.sprite = SPR_FILD
									sparkle.frame = FF_FULLBRIGHT
									sparkle.colorized = true
									sparkle.direction = num
									sparkle.target = f
									sparkle.fieldz = mo.z + (num*25*FRACUNIT)
									mo.sparkles[#mo.sparkles+1] = sparkle
								end
							end
						end
						if timer == 270
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
							P_TeleportMove(s, tgtx, tgty, s.z)
						end
						if s.direction%2 == 0
							s.rotate = $ - ANG1*mo.angspeed
						else
							s.rotate = $ + ANG1*mo.angspeed
						end
						if s.fieldz and timer < 240
							s.momz = (s.fieldz - s.z)/10
						end
						if timer >= 240
							s.momz = ((mo.floorz - 5*FRACUNIT) - s.z)/8
						end
						if timer == 270
							P_RemoveMobj(s)
						end
					end
				end
			end
			if timer == 270
				mo.renderflags = $ & ~RF_FULLBRIGHT
				return true
			end
		end,
}

attackDefs["prayer of affection"] = {
		name = "Prayer of Affection",
		type = ATK_HEAL,
		costtype = CST_EP,
		cost = 2,
		desc = "Revive fallen members, restore full\nHP and SP, and give\nRegen 3 to party.",
		target = TGT_ALLALLIES,
		power = 999999,
		anim = function(mo, targets, hittargets, timer)
			local emeraldcolors = {SKINCOLOR_MINT, SKINCOLOR_EMERALD, SKINCOLOR_FOREST}
			local btl = server.P_BattleStatus[mo.battlen]
			local cam = btl.cam
			if timer < 10
				local tgtx = mo.x + 125*cos(mo.angle)
				local tgty = mo.y + 125*sin(mo.angle)
				CAM_stop(cam)
				cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
				P_TeleportMove(cam, tgtx, tgty, mo.z+30*FRACUNIT)
			end
			if timer == 1
				mo.heal = {}
				for i = 1, #mo.allies_noupdate
					mo.allies_noupdate[i].healing = 0
				end
				playSound(mo.battlen, sfx_bufu1)
				for i = 1, 30
					local energy = P_SpawnMobj(mo.x-P_RandomRange(200,-200)*FRACUNIT, mo.y-P_RandomRange(200,-200)*FRACUNIT, mo.z+P_RandomRange(150,0)*FRACUNIT, MT_DUMMY)
					energy.sprite = SPR_THOK
					energy.frame = FF_FULLBRIGHT
					energy.color = emeraldcolors[P_RandomRange(1, #emeraldcolors)]
					energy.scale = FRACUNIT/P_RandomRange(3, 6)
					energy.tics = 20
					energy.momx = (mo.x - energy.x)/20
					energy.momy = (mo.y - energy.y)/20
					energy.momz = (mo.z - energy.z)/20
				end
			end
			if timer == 20
				local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
				thok.state = S_INVISIBLE
				thok.tics = 1
				thok.scale = FRACUNIT*4
				A_OldRingExplode(thok, MT_SUPERSPARK)
				playSound(mo.battlen, sfx_hamas2)
				playSound(mo.battlen, sfx_bufu6)
				if mo.status_condition == COND_HYPER
					mo.hyperpower = true
					playSound(mo.battlen, sfx_buff2)
					localquake(mo.battlen, FRACUNIT*10, 10)
				else
					mo.status_condition = COND_HYPER
				end
			end
			if mo.hyperpower
				summonAura(mo, SKINCOLOR_EMERALD)
			end
			if timer >= 20
				if leveltime%6 == 0
					local g = P_SpawnGhostMobj(mo)
					g.color = SKINCOLOR_EMERALD
					g.colorized = true
					g.destscale = FRACUNIT*4
					g.frame = $|FF_FULLBRIGHT
				end
			end
			if timer == 60
				playSound(mo.battlen, sfx_buff)
				mo.ball = P_SpawnMobj(mo.x, mo.y, mo.z+40*FRACUNIT, MT_DUMMY)
				mo.ball.state = S_MEGITHOK
				mo.ball.frame = FF_FULLBRIGHT
				mo.ball.tics = -1
				mo.ball.scale = FRACUNIT/4
				mo.ball.destscale = FRACUNIT
				mo.ball.color = SKINCOLOR_WHITE
			end
			if mo.ball and mo.ball.valid
				local b = mo.ball
				local z = mo.z + 150*FRACUNIT
				b.momz = (z - b.z)/5
				CAM_stop(cam)
				P_TeleportMove(cam, cam.x, cam.y, b.z-10*FRACUNIT)
				if leveltime%6 == 0
					local g = P_SpawnGhostMobj(b)
					g.color = SKINCOLOR_EMERALD
					g.colorized = true
					g.destscale = FRACUNIT*4
					g.frame = $|FF_FULLBRIGHT
				end
				if timer >= 80 and leveltime%2 == 0 and timer < 120
					local energy = P_SpawnMobj(b.x-P_RandomRange(200,-200)*FRACUNIT, b.y-P_RandomRange(200,-200)*FRACUNIT, b.z+P_RandomRange(150,-150)*FRACUNIT, MT_DUMMY)
					energy.sprite = SPR_THOK
					energy.frame = FF_FULLBRIGHT
					energy.color = SKINCOLOR_WHITE
					energy.scale = FRACUNIT/P_RandomRange(3, 6)
					energy.tics = 15
					energy.momx = (b.x - energy.x)/15
					energy.momy = (b.y - energy.y)/15
					energy.momz = (b.z - energy.z)/15
				end
				if timer == 135
					local thok = P_SpawnMobj(b.x, b.y, b.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT*2
					A_OldRingExplode(thok, MT_SUPERSPARK)
					playSound(mo.battlen, sfx_hamas1)
					playSound(mo.battlen, sfx_megi6)
					for i = 1, #mo.allies_noupdate
						local energy = P_SpawnMobj(b.x, b.y, b.z, MT_DUMMY)
						energy.state = S_MEGITHOK
						energy.frame = FF_FULLBRIGHT
						energy.flags = $ & ~MF_NOGRAVITY
						energy.fuse = -1
						energy.scale = FRACUNIT/4
						energy.destscale = FRACUNIT
						energy.color = SKINCOLOR_WHITE
						energy.momz = 10*FRACUNIT
						energy.target = mo.allies_noupdate[i]
						mo.heal[#mo.heal+1] = energy
					end
					local tgtx = mo.x + 600*cos(mo.angle)
					local tgty = mo.y + 600*sin(mo.angle)
					cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
					CAM_goto(cam, tgtx, tgty, mo.z+100*FRACUNIT)
					P_RemoveMobj(b)
				end
			end
			if mo.heal and #mo.heal
				for i = 1, #mo.heal
					if mo.heal[i] and mo.heal[i].valid
						local heal = mo.heal[i]
						heal.momx = (heal.target.x - heal.x)/10
						heal.momy = (heal.target.y - heal.y)/10
						if heal.z <= mo.floorz
							if i == 1
								playSound(mo.battlen, sfx_drop)
								playSound(mo.battlen, sfx_status)
							end
							heal.target.healing = 1
							P_RemoveMobj(heal)
						end
					end
				end
			end
			for i = 1, #mo.allies_noupdate
				local target = mo.allies_noupdate[i]
				if target == mo and timer >= 20 and target.healing == 0
					if leveltime%4 == 0
						local st = P_SpawnMobj(mo.x + P_RandomRange(-60, 60)*FRACUNIT, mo.y + P_RandomRange(-60, 60)*FRACUNIT, mo.z + P_RandomRange(-25, 20)*FRACUNIT, MT_DUMMY)
						st.color = SKINCOLOR_WHITE
						st.frame = $|FF_FULLBRIGHT
						st.state = S_MEGISTAR1
					end
				end
				if target.healing
					if leveltime%6 == 0
						local g = P_SpawnGhostMobj(target)
						g.color = SKINCOLOR_EMERALD
						g.colorized = true
						g.destscale = FRACUNIT*4
						g.frame = $|FF_FULLBRIGHT
						local an = 0
						for i = 1, 32
							local s = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
							if leveltime%12 == 0
								s.color = SKINCOLOR_MINT
							else
								s.color = SKINCOLOR_WHITE
							end
							s.state = S_THOK
							s.frame = FF_FULLBRIGHT
							s.scale = $/8
							s.tics = 20
							P_InstaThrust(s, an*ANG1, 8*FRACUNIT)

							an = $ + (360/32)
						end
					end
					target.healing = $+1
					if target.healing == 50 + (i*5)
						P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
						playSound(mo.battlen, sfx_heal4)
						playSound(mo.battlen, sfx_buff)
						if target.hp <= 0
							revivePlayer(target)
							damageObject(target, -99999)
							damageSP(target, -target.maxsp)
							ANIM_set(target, target.anim_revive, true)
							target.momz = 10*FRACUNIT
						end
						damageObject(target, -99999)
						damageSP(target, -target.maxsp)
						for k,v in ipairs(target.passiveskills)
							if v == "regenerate 3" return end
						end
						if mo.hyperpower
							table.insert(target.passiveskills, "regenerate 3") //TWO OF THEM IF YOURE ALREADY HYPER WOOOO
						end
						table.insert(target.passiveskills, "regenerate 3")
					end
					if target.healing >= 50 + (i*5)
						if leveltime%2 == 0
							for i = 1,10

								local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
								thok.state = S_CDUST1
								thok.momz = P_RandomRange(6, 12)*FRACUNIT
								if P_RandomRange(1, 2) == 1
									thok.color = SKINCOLOR_EMERALD
								else
									thok.color = SKINCOLOR_MINT
								end
								thok.tics = P_RandomRange(10, 35)
								thok.scale = FRACUNIT*3/2
							end
						end

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_SUMN
						thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
						thok.momz = P_RandomRange(8, 18)*FRACUNIT
						if P_RandomRange(1, 2) == 1
							thok.color = SKINCOLOR_EMERALD
						else
							thok.color = SKINCOLOR_MINT
						end
						thok.tics = P_RandomRange(10, 35)
					end
					if target.healing > 60 + (i*5) and P_IsObjectOnGround(target)
						ANIM_set(target, target.anim_stand, true)
					end
					if target.healing == 110 + (#mo.allies_noupdate*5)
						mo.renderflags = $ & ~RF_FULLBRIGHT
						mo.status_condition = COND_NORMAL
						mo.hyperpower = false
						target.healing = 0

						local newparty = {}
						for k,v in ipairs(mo.allies_noupdate)
							if v.hp or v == mo	-- we're getting revived too.
								newparty[#newparty+1] = v
							end
						end

						-- apply newparty as our allies and as our enemies' enemies.
						for k,v in ipairs(mo.allies_noupdate)
							if not v or not v.valid continue end
							v.allies = copyTable(newparty)
						end
						for k,v in ipairs(mo.enemies_noupdate)
							if not v or not v.valid continue end
							v.enemies = copyTable(newparty)
						end

						return true
					end
				end
			end
						
		end,
}

attackDefs["hostile judgement"] = {
		name = "Hostile Judgement",
		type = ATK_STRIKE,
		power = 5000,
		accuracy = 999,
		costtype = CST_EP,
		cost = 2,
		desc = "Max out own physical attack and deal\ncolossal Strike damage to one enemy.",
		target = TGT_ENEMY,
		technical = COND_FREEZE,
		nocast = 	function(targets, n)	//dont activate if only remaining enemy is eggman
						if targets[n].enemy == "b_eggman"
							BTL_logMessage(targets[1].battlen, "No effect.")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			local emeraldcolors = {SKINCOLOR_MINT, SKINCOLOR_EMERALD, SKINCOLOR_FOREST}
			--local boostdamage = getDamage(target, mo, nil, 100)
			if timer == 1
				mo.sectorstuff = {}
				mo.lights = {}
				mo.prevx = mo.x
				mo.prevy = mo.y
				mo.prevz = mo.z
				--mo.afterimage = {}
				mo.state = S_PLAY_SUPER_TRANS3
				mo.tics = -1
				mo.frame = C
				playSound(mo.battlen, sfx_bufu1)
				for i = 1, 30
					local energy = P_SpawnMobj(mo.x-P_RandomRange(200,-200)*FRACUNIT, mo.y-P_RandomRange(200,-200)*FRACUNIT, mo.z+P_RandomRange(150,0)*FRACUNIT, MT_DUMMY)
					energy.sprite = SPR_THOK
					energy.frame = FF_FULLBRIGHT
					energy.color = emeraldcolors[P_RandomRange(1, #emeraldcolors)]
					energy.scale = FRACUNIT/P_RandomRange(3, 6)
					energy.tics = 20
					energy.momx = (mo.x - energy.x)/20
					energy.momy = (mo.y - energy.y)/20
					energy.momz = (mo.z - energy.z)/20
				end
				mo.flags = $|MF_NOGRAVITY|MF_NOCLIP
			end
			if timer == 20
				for s in sectors.iterate
					mo.sectorstuff[#mo.sectorstuff+1] = s
				end
				local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
				thok.state = S_INVISIBLE
				thok.tics = 1
				thok.scale = FRACUNIT*4
				A_OldRingExplode(thok, MT_SUPERSPARK)
				playSound(mo.battlen, sfx_hamas2)
				playSound(mo.battlen, sfx_bufu6)
				if mo.status_condition == COND_HYPER
					mo.hyperpower = true
					playSound(mo.battlen, sfx_buff2)
					localquake(mo.battlen, FRACUNIT*10, 10)
				else
					mo.status_condition = COND_HYPER
				end
			end
			if mo.hyperpower and (timer < 120 or timer >= 172)
				summonAura(mo, SKINCOLOR_EMERALD)
			end
			if timer >= 20 and timer < 60
				if leveltime%2 == 0
					local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height, MT_DUMMY)
					elec.sprite = SPR_DELK
					elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
					elec.destscale = FRACUNIT*4
					elec.scalespeed = FRACUNIT/4
					elec.tics = TICRATE/16
					elec.color = SKINCOLOR_CRIMSON
				end
			end
			if timer >= 40 and timer < 60
				if timer == 40
					localquake(mo.battlen, 20*FRACUNIT, 3)
					buffStat(mo, "atk", 150)
					playSound(mo.battlen, sfx_buff)
					playSound(mo.battlen, sfx_buff2)
					BTL_logMessage(targets[1].battlen, "Physical Attack maxed out!")
					mo.tics = -1
					mo.frame = G
					mo.status_condition = COND_NORMAL
				end
				if leveltime%4 == 0
					local g = P_SpawnGhostMobj(mo)
					g.color = SKINCOLOR_RED
					g.colorized = true
					g.destscale = FRACUNIT*4
					g.frame = $|FF_FULLBRIGHT
					for i = 1,16
						local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_RED
						dust.scale = FRACUNIT*2
						dust.frame = $|FF_FULLBRIGHT
						dust.renderflags = $|RF_NOCOLORMAPS
					end
				end
			end
			if timer == 70
				mo.state = S_PLAY_WALK
				mo.tics = -1
				mo.frame = A
				mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
				mo.savemomx = (target.x - mo.x)/40
				mo.savemomy = (target.y - mo.y)/40
				playSound(mo.battlen, sfx_belnch)
			end
			if timer == 75
				local an = target.angle + 45*ANG1
				local cx = target.x + 384*cos(an)
				local cy = target.y + 384*sin(an)
				CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, server.P_BattleStatus[mo.battlen].cam.z, 70*FRACUNIT)
				CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y), ANG1*4)
			end
			if timer >= 70 and timer < 108
				local g = P_SpawnGhostMobj(mo)
				g.color = SKINCOLOR_COBALT
				g.colorized = true
				g.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
				--mo.afterimage[#mo.afterimage+1] = g
				mo.momx = mo.savemomx
				mo.momy = mo.savemomy
			end
			//only make ghostmobjs blue not knuckles it's picky i know
			/*if mo.afterimage and #mo.afterimage
				for i = 1, #mo.afterimage
					if mo.afterimage[i] and mo.afterimage.valid
						local e = mo.afterimage[i]
						if e.tics == 892
							e.sprite = SPR_NULL
						end
						e.color = SKINCOLOR_COBALT
					end
				end
			end*/
			if timer == 108
				playSound(mo.battlen, sfx_s3k4a)
				ANIM_set(target, target.anim_hurt, true)
				mo.momx = 0
				mo.momy = 0
			end
			if timer == 120
				mo.renderflags = $ & ~RF_FULLBRIGHT
			end
			if timer >= 120 and leveltime%2 == 0 and timer < 170
				playSound(mo.battlen, sfx_hit1)
				playSound(mo.battlen, sfx_pstop)
				localquake(mo.battlen, 20*FRACUNIT, 2)
				local b = P_SpawnMobj(target.x+P_RandomRange(100, -100)*FRACUNIT, target.y+P_RandomRange(100, -100)*FRACUNIT, target.z+P_RandomRange(75, 0)*FRACUNIT, MT_DUMMY)
				b.state = S_HURTC1
				b.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
				b.destscale = FRACUNIT*3
			end
			if timer == 172
				local b = P_SpawnMobj(mo.x, mo.y, mo.z+50*FRACUNIT, MT_DUMMY)
				b.sprite = SPR_KILL
				b.tics = 50
				b.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
				b.scale = FRACUNIT*2
				local g = P_SpawnGhostMobj(b)
				g.destscale = FRACUNIT*8
				g.frame = $|FF_FULLBRIGHT
				g.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
				for i = 1,2
					playSound(mo.battlen, sfx_perish)
				end
				mo.state = S_PLAY_WAIT
				mo.tics = -1
				mo.frame = A
				mo.angle = R_PointToAngle2(mo.x, mo.y, server.P_BattleStatus[mo.battlen].cam.x, server.P_BattleStatus[mo.battlen].cam.y) + ANG1*180
				mo.renderflags = $|RF_FULLBRIGHT|RF_NOCOLORMAPS
			end
			if timer == 220
				playSound(mo.battlen, sfx_megi5)
				for j = 1, 60
					local st = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					st.state = S_MEGITHOK
					st.flags = $ & ~MF_NOGRAVITY
					st.momx = P_RandomRange(-128, 128)*FRACUNIT
					st.momy = P_RandomRange(-128, 128)*FRACUNIT
					st.momz = P_RandomRange(-32, 128)*FRACUNIT
					st.fuse = 20
					st.scale = FRACUNIT*2/3
				end
				if not mo.hyperpower
					damageObject(target)
				else
					--damageObject(target, boostdamage*6/5) //1.2x boost if already hyper
					damageObject(target)
					inflictStatus(target, COND_SHOCK)
					playSound(mo.battlen, sfx_boost1)
					local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT*3
					A_OldRingExplode(thok, MT_SUPERSPARK)
				end
				P_TeleportMove(mo, mo.prevx, mo.prevy, mo.prevz)
				mo.renderflags = $ & ~RF_FULLBRIGHT & ~RF_NOCOLORMAPS
				mo.flags = $ & ~MF_NOGRAVITY & ~MF_NOCLIP
				mo.hyperpower = false
			end
			if mo.sectorstuff and #mo.sectorstuff
				for i = 1, #mo.sectorstuff
					if mo.sectorstuff[i]
						local sector = mo.sectorstuff[i]
						if timer == 40
							mo.lights[#mo.lights+1] = sector.lightlevel
						end
						if timer == 120
							sector.lightlevel = 0
						end
						if timer == 220
							sector.lightlevel = mo.lights[i]
						end
					end
				end
			end
			if timer == 260
				return true
			end
		end,
}

//thinker for sonic's inferno link (and ep skills) (and a bit of rankpoints)
addHook("MobjThinker", function(mo)
	if mo and mo.valid
		if not (mapheaderinfo[gamemap].bluemiststory) 
			mo.rankpoints = 0 --reset rank points rq when blue mist run over
			if mo.control and mo.control.valid
				mo.control.rankpoints = {}
				mo.control.rewardqueue = {}
				mo.control.queueposition = 0
				mo.control.rewardposition = {}
			end
			for p in players.iterate
				p.rankpoints = {}
				p.rewardqueue = {}
				p.queueposition = 0
				p.rewardposition = {}
			end
			return
		end
		if mo.cutscene return end
		local btl = server.P_BattleStatus[mo.battlen]
		mo.rankpoints = $ or 0
		mo.infernoselect = $ or false
		mo.emeraldskill = $ or false
		local skill = mo.attack
		if not skill return end
		//dont do initiator anim twice in one turn
		if skill.name == "Inferno Link"
			if btl.battlestate == BS_DOTURN
				mo.infernoselect = true
			end
		else
			mo.infernoselect = false
		end
		if skill.costtype == CST_EP and skill.cost == 2 and btl.emeraldpow >= 200
			if not mo.emeraldskill
				mo.renderflags = $|RF_FULLBRIGHT
				for s in sectors.iterate
					local darklight = min(s.lightlevel, 25)
					s.lightlevel = s.lightlevel - darklight
				end
				mo.emeraldskill = true
			end
		else
			if mo.emeraldskill
				mo.renderflags = $ & ~RF_FULLBRIGHT
				for s in sectors.iterate
					if s.lightlevel != 0
						s.lightlevel = s.lightlevel + 25
					end
				end
				mo.emeraldskill = false
			end
		end
		if skill.name == "Dive Press" or skill.name == "Spin Strike" or skill.name == "Hammer Hit"  
			if btl.battlestate == BS_DOTURN
				local enemy = mo.enemies[mo.t_target].enemy
				if enemy == "jetty bomber" or enemy == "jetty gunner" or enemy == "cacolantern" or enemy == "crawla commander" or enemy == "crawla commander final"
					mo.melee = "lunge"
					--mo.commandflags = $|CDENY_ATTACK
				else
					mo.melee = charStats[mo.skin].melee_natk
					--mo.commandflags = $ & ~CDENY_ATTACK
				end
			end
		end
	end
end, MT_PFIGHTER)

//STAGE CLEAR! show your ranking according to deaths, items, and overall time spent on the boss
local timer = 0
local texttimer = {0, 0, 0, 0, 0}
local csize = 1
local xdist = -250
local xvalues = {60, 190, 130, 40}
local yvalues = {-200, -200, -200, -200, 40, 0, 65}
local ydest = {80, 80, 115, 160, 40, 0, 65}
local getmeout = false //for exitlevel
local shake = {10, 10, 10}
local wtf = false //f rank
local newtimer = 0
local rankpoints = {0, 4, 6, 8, 10, 15, 20} --{0, 2, 3, 4, 5, 7, 10}
local newyvalues = {300, 300, 300, 300, 300, 300, 300}
local newydest = {60, 60, 60, 180, 30, 50, 130, 90}
local newxvalues = {70, 120, 20, 5, 320, 55, 51}
local order1 = {70, 120, 20}
local order2 = {20, 70, 120}
local order3 = {120, 20, 70}
local newxdest = {order1, order2, order3}
local selectcolor = 0
local selectcolor2 = 0
local selectcolor3 = 0
local score = 0

rawset(_G, "stageClear", function(v, p)
	if not stagecleared
		timer = 0
		texttimer = {0, 0, 0, 0, 0}
		csize = 1
		xdist = -250
		yvalues = {-200, -200, -200, -200, 40, 0, 65}
		ydest = {80, 80, 115, 160, 40, 0, 65}
		shake = {10, 10, 10}
		wtf = false
		newtimer = 0
		newyvalues = {300, 300, 300, 300, 300, 300, 300}
		newxvalues = {70, 120, 20, 5, 320, 55, 51}
		selectcolor = 0
		selectcolor2 = 0
		selectcolor3 = 0
		score = 0
		/*if gamemap == 07 or gamemap == 08
			stagecleared = true
		end*/
		return
	end
	if p.P_spectator
		drawWaitScreen(v, 1, "Waiting for remaining \nplayers to finish \nupgrade selection.")
		return
	end
	local btl = server.P_BattleStatus[1]
	local deathscore = 2
	local itemscore = 2
	local timescore = 2
	local besttime = 6
	local rankcolors = {73, 73, 73}
	if gamemap == 07
		besttime = 360*TICRATE // 6 minutes
	elseif gamemap == 08
		besttime = 540*TICRATE // 9 minutes
	elseif gamemap == 09
		besttime = 540*TICRATE // 9 minutes
	elseif gamemap == 10
		besttime = 720*TICRATE // 12 minutes
	elseif gamemap == 11
		besttime = 900*TICRATE // 15 minutes
	elseif gamemap == 12
		besttime = 1500*TICRATE // 25 minutes
	end
	timer = timer + 1
	
	//faded background, can't get drawfill to be transparent so i have to put a black graphic in here :(
	local bruh = v.cachePatch("H_BRUH")
	local hi = V_90TRANS
	if timer >= 3 and timer <= 5
		hi = V_80TRANS
	elseif timer > 5 and timer <= 7
		hi = V_70TRANS
	elseif timer > 7 and timer <= 9
		hi = V_60TRANS
	elseif timer > 9 and timer <= 11
		hi = V_50TRANS
	elseif timer > 11
		hi = V_40TRANS
	end
	v.drawScaled(0, 0, FRACUNIT*5, bruh, V_SNAPTOTOP|V_SNAPTOLEFT|hi)
	
	if timer >= 92
		//the result hud thing too
		PDraw(v, 0, yvalues[6], v.cachePatch("H_RSLT"), V_SNAPTOTOP|V_SNAPTOLEFT)
		
		//stage clear text
		V_drawString(v, 60, yvalues[5], "STAGE " + tostring(gamemap-6) + " CLEARED!", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 103, FRACUNIT)
	end
	
	if timer >= 30
		if timer == 32 and gamemap != 12
			S_ChangeMusic("clear")
		end
		//draw the circle and circle border
		local c1 = v.cachePatch("H_BALL1")
		local c2 = v.cachePatch("H_BALL2")
		csize = csize + (120 - csize)/20
		v.drawScaled(275*FRACUNIT, 175*FRACUNIT, FRACUNIT*csize/100, c2, V_SNAPTOBOTTOM|V_SNAPTORIGHT, nil)	
		v.drawScaled(275*FRACUNIT, 175*FRACUNIT, FRACUNIT*csize/100, c1, V_SNAPTOBOTTOM|V_SNAPTORIGHT, nil)
		
		//slide the portrait in
		local portrait = v.cachePatch("H_SONAOA")
		local portraitcolor = p.mo.color
		if not (p.rewardqueue and #p.rewardqueue) or not p.queueposition
			for k,e in ipairs(server.plentities[1])
				if e and e.valid and not e.enemy and e.plyr and e.skin == p.mo.skin
					portrait = v.cachePatch(charStats[e.stats].hudaoa)
				end
			end
			//damn offsets
			if p.mo.skin == "sonic"
				xdist = xdist + (230 - xdist)/10
			else
				xdist = xdist + (210 - xdist)/10
			end
		else
			if p.rewardqueue[p.queueposition] and p.rewardqueue[p.queueposition].valid
				for k,e in ipairs(server.plentities[1])
					if e and e.valid and not e.enemy and e.plyr and e.skin == p.rewardqueue[p.queueposition].skin
						portrait = v.cachePatch(charStats[e.stats].hudaoa)
						portraitcolor = e.color
					end
				end
				//damn offsets
				if p.rewardqueue[p.queueposition].skin == "sonic"
					xdist = xdist + (230 - xdist)/10
				else
					xdist = xdist + (210 - xdist)/10
				end
			end
		end
		v.drawScaled(xdist*FRACUNIT, 50*FRACUNIT, FRACUNIT/2, portrait, V_SNAPTOBOTTOM|V_SNAPTORIGHT, v.getColormap(TC_DEFAULT, portraitcolor))
		
		//bring down the 4 things
		if timer >= 50
			for i = 1, 7
				yvalues[i] = yvalues[i] + (ydest[i] - yvalues[i])/10
			end
			for i = 1, 4
				local colors = {SKINCOLOR_RUST, SKINCOLOR_EMERALD, SKINCOLOR_BLUE, SKINCOLOR_NEON}
				local size = FRACUNIT*3/5
				if i == 4 then size = FRACUNIT end
				v.drawScaled((xvalues[i]+10)*FRACUNIT, (yvalues[i]+5)*FRACUNIT, size, v.cachePatch("H_RESULT"), V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, SKINCOLOR_BLACK))
				v.drawScaled(xvalues[i]*FRACUNIT, yvalues[i]*FRACUNIT, size, v.cachePatch("H_RESULT"), V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, colors[i]))
				
				//draw the stats
				if timer >= 90+(15*i)
					texttimer[i] = texttimer[i] + 1
					local x = xvalues[i]
					local y = yvalues[i]
					local size = FRACUNIT*4/5
					if i < 4
						y = yvalues[i] + 5
						if i == 1
							x = xvalues[i] + 20
						elseif i == 2
							x = xvalues[i] + 5
						elseif i == 3
							x = xvalues[i] + 20
							y = yvalues[i] + 2
							size = FRACUNIT*7/6
						end
					end
					if i == 4
						y = yvalues[i] + 10
						x = xvalues[i] + 30
						size = FRACUNIT*5/4
					end
					local text = {"Deaths:", "Items used:", "Time:", "Ranking:"}
					local s = text[i]:sub(1, texttimer[i])
					V_drawString(v, x, y, s, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31, size)
					
					if i == 3
						local b = ""
						if G_TicsToSeconds(besttime) > 9
							b = "Best time: " + G_TicsToMinutes(besttime, true) + ":" + G_TicsToSeconds(besttime)
						else
							b = "Best time: " + G_TicsToMinutes(besttime, true) + ":0" + G_TicsToSeconds(besttime)
						end
						local s = b:sub(1, texttimer[i])
						V_drawString(v, x - 5, y + 25, s, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 8, 31, FRACUNIT/2)
					end
				end
				
				//draw the stats #2, the actual numbers this time
				if i < 4
					if timer >= 150+(15*i)
						//wtf is this
						local x = xvalues[i]
						local y = yvalues[i]
						local deaths = btl.netstats.timesdied
						local items = btl.netstats.itemsused
						local time = "?"
						if timer == 150+(15*i) then	S_StartSound(nil, sfx_result) end
						if shake[i] > 0
							shake[i] = shake[i] - 1
						end
						--if gamemap != 10
							if btl.battletime2
								if G_TicsToSeconds(btl.battletime2) > 9
									time = G_TicsToMinutes(btl.battletime2, true) + ":" + G_TicsToSeconds(btl.battletime2)
								else
									time = G_TicsToMinutes(btl.battletime2, true) + ":0" + G_TicsToSeconds(btl.battletime2)
								end
							end
						--else
							/*if btl.battletime3
								if G_TicsToSeconds(btl.battletime3) > 9
									time = G_TicsToMinutes(btl.battletime3, true) + ":" + G_TicsToSeconds(btl.battletime3)
								else
									time = G_TicsToMinutes(btl.battletime3, true) + ":0" + G_TicsToSeconds(btl.battletime3)
								end
							end
						end*/
						local stats = {deaths, items, time}
						if stats[1] > 0 and stats[1] <= 1
							rankcolors[1] = 0
							deathscore = 1
						elseif stats[1] > 1 and stats[1] <= 3
							rankcolors[1] = 34
							deathscore = 0
						elseif stats[1] > 3
							rankcolors[1] = 34
							deathscore = -1
						end
						if stats[2] > 0 and stats[2] <= 2
							rankcolors[2] = 0
							itemscore = 1
						elseif stats[2] > 2 and stats[2] <= 5
							rankcolors[2] = 34
							itemscore = 0
						elseif stats[2] > 5
							rankcolors[2] = 34
							itemscore = -1
						end
						if btl.battletime2
							if btl.battletime2 > besttime and btl.battletime2 <= besttime + 120*TICRATE // 2 or less minutes over
								rankcolors[3] = 0
								timescore = 1
							elseif btl.battletime2 > besttime + 120*TICRATE and btl.battletime2 <= besttime + 360*TICRATE // over 2 minutes of best time
								rankcolors[3] = 34
								timescore = 0
							elseif btl.battletime2 > besttime + 360*TICRATE // over 6 minutes of best time
								rankcolors[3] = 34
								timescore = -1
							end
						end
						if timer%2 == 0
							if i == 3
								V_drawString(v, x+85, y + shake[i], stats[i], "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, rankcolors[i], 31, FRACUNIT*3/2)
							else
								V_drawString(v, x+90, y + shake[i], stats[i], "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, rankcolors[i], 31, FRACUNIT*3/2)
							end
						else
							if i == 3
								V_drawString(v, x+85, y - shake[i], stats[i], "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, rankcolors[i], 31, FRACUNIT*3/2)
							else
								V_drawString(v, x+90, y - shake[i], stats[i], "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, rankcolors[i], 31, FRACUNIT*3/2)
							end
						end
					end
				else
					if timer >= 240
						local x = xvalues[i]
						local y = yvalues[i]
						local color = 0
						score = deathscore + itemscore + timescore
						if score < 0
							score = 0
						end
						if gamemap == 12 and score == 0 //stage 6 pity
							score = 1
						end
						local ranks = {"F", "E", "D", "C", "B", "A", "S"}
						local ranksounds = {sfx_rankf, sfx_s3k35, sfx_kc40, sfx_cdpcm9, sfx_s3k63, sfx_chchng, sfx_nxdone}
						if timer == 240
							S_StartSound(nil, ranksounds[score+1])
							S_StartSound(nil, ranksounds[score+1])
							if score == 0
								wtf = true
								S_StopMusic(nil)
							end
						end
						if score == 6
							if leveltime%2 == 0
								color = 0
							else
								color = 82
							end
						end
						V_drawString(v, x+130, y+1, ranks[score+1], "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, color, 31, FRACUNIT*2)
						if score != 0 and gamemap != 12
							V_drawString(v, x+170, y+10, "+" + tostring(rankpoints[score+1]), "FPNUM", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 97, 31, FRACUNIT)
						end
					end
				end
			end
		end
		
		if timer >= 260
			if not wtf
				texttimer[5] = texttimer[5] + 1
				local text = "Press A to proceed to the next menu" --"Press A to move onto next stage"
				if gamemap == 12
					text = "Press A to finish the stage"
				end
				local s = text:sub(1, texttimer[5])
				V_drawString(v, 92, yvalues[7], s, "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 73, 31)
				if server.plentities[1][1].control.mo.P_inputs[BT_JUMP] == 1
					if gamemap == 12
						getmeout = true
					else
						--getmeout = true --kill
						newtimer = 1
					end
				end
			end
		end
		
		//GOKU PROWLER IF YOU GET A RANK F THIS IS BY NO MEANS NECESSARY
		if timer >= 280
			if wtf
				if timer == 280 then S_StartSound(nil, sfx_prowlr) end
				
				local goku = v.cachePatch("H_GOKU")
				v.drawScaled(0, 0, FRACUNIT*2/3, goku, V_SNAPTOTOP|V_SNAPTOLEFT, nil)
				
				//background fade again but it starts opaque and fades out instead
				local bruh = v.cachePatch("H_BRUH")
				local hi = V_SNAPTOTOP
				if timer >= 283 and timer <= 285
					hi = V_10TRANS
				elseif timer > 285 and timer <= 287
					hi = V_20TRANS
				elseif timer > 287 and timer <= 289
					hi = V_30TRANS
				elseif timer > 289 and timer <= 291
					hi = V_40TRANS
				elseif timer > 291 and timer <= 293
					hi = V_50TRANS
				elseif timer > 291 and timer <= 293
					hi = V_60TRANS
				elseif timer > 293 and timer <= 295
					hi = V_70TRANS
				elseif timer > 295 and timer <= 297
					hi = V_80TRANS
				elseif timer > 297
					hi = V_90TRANS
				end
				if timer < 300
					v.drawScaled(0, 0, FRACUNIT*5, bruh, V_SNAPTOTOP|V_SNAPTOLEFT|hi)
				end
			end
		end
		
		if timer >= 400
			if wtf
				texttimer[5] = texttimer[5] + 1
				local text = "Press A to move onto next stage"
				if gamemap == 12
					text = "Press A to finish the stage"
				end
				local s = text:sub(1, texttimer[5])
				V_drawString(v, 20, yvalues[7], s, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 73, 31)
				if server.plentities[1][1].control.mo.P_inputs[BT_JUMP] == 1
					getmeout = true
				end
			end
		end
		
		//white background flash because flashpal wont work here
		if timer == 92 or timer == 93 or timer == 94
			local bruh3 = v.cachePatch("H_BRUH3")
			v.drawScaled(0, 0, FRACUNIT*5, bruh3, V_SNAPTOTOP|V_SNAPTOLEFT)
		end
		
		//reward timer
		if newtimer > 0
			newtimer = newtimer + 1
			if p.rewardqueue
				local rewardchar = p.rewardqueue[p.queueposition]
				if rewardchar
					if leveltime%5 == 0 and leveltime%10 != 0
						selectcolor = 0
						selectcolor2 = 0
						selectcolor3 = 0
					end
					if leveltime%10 == 0
						selectcolor = 31
						selectcolor2 = 6
						selectcolor3 = 73
					end
					//remove old stuff
					for i = 1, 7
						ydest[i] = -300
					end
					//put in new stuff
					for i = 1, 5
						if i < 4 //move selected boxes
							if p.saveselect != i
								newyvalues[i] = newyvalues[i] + (newydest[i] - newyvalues[i])/4
							else
								newyvalues[i] = newyvalues[i] + (newydest[8] - newyvalues[i])/min(4, abs((newydest[8] - newyvalues[i]) + 1))
							end
							newxvalues[i] = newxvalues[i] + (newxdest[p.saveselect][i] - newxvalues[i])/3
							--print((newydest[7] - newyvalues[i]))
						else
							newyvalues[i] = newyvalues[i] + (newydest[i] - newyvalues[i])/10
						end
						local playercolor = 145
						if p.rewardoptions[i] != "empty"
							if rewardchar.skin == "sonic"
								playercolor = 148
							elseif rewardchar.skin == "tails"
								playercolor = 52
							elseif rewardchar.skin == "knuckles"
								playercolor = 34
							elseif rewardchar.skin == "amy"
								playercolor = 200
							end
						else
							playercolor = 8
						end
						if i != 5
							if i != 4 //boxes
								--v.drawFill(newxvalues[i], newyvalues[i], 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|playercolor)
								if p.rewardselect != i //it gets messy here cuz i try to put selected boxes in the front
									v.drawFill((newxvalues[i]+10), (newyvalues[i]+5), 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|31)
									if i == 3		
										v.drawFill(newxvalues[i], newyvalues[i], 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|6)
									else
										v.drawFill(newxvalues[i], newyvalues[i], 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|playercolor)
									end
								end
								if p.rewardselect != i
									if i != 3
										if p.rewardoptions and #p.rewardoptions
											if p.rewardoptions[i] != "empty"
												local skill = p.rewardoptions[i]
												local atk = attackDefs[skill]
												local skilldesc = string.gsub(atk.desc, "\n", " ")
												local desctext = STR_WordWrap(v, skilldesc, 95, "NFNT", FRACUNIT/2)
												local desctext2 = STR_WWToString(desctext)
												local titletext = STR_WordWrap(v, atk.name, 80, "NFNT", FRACUNIT/2)
												local titletext2 = STR_WWToString(titletext)
												V_drawString(v, newxvalues[i]+20, newyvalues[i]+5, titletext2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 73, 31)
												V_drawString(v, newxvalues[i]+5, newyvalues[i]+20, desctext2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
												//draw player icon
												v.draw(newxvalues[i]+10, newyvalues[i]+13, v.getSprite2Patch(rewardchar.skin, SPR2_LIFE), V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(nil, rewardchar.color))
												//draw cost
												if atk.price
													V_drawString(v, newxvalues[i]+5, newyvalues[i]+90, "COST: \x82" + atk.price, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
												end
												if atk.next
													V_drawString(v, newxvalues[i]+5, newyvalues[i]+80, "NEXT: \x8C" + attackDefs[atk.next].name, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
													//draw element icon
													v.drawScaled((newxvalues[i]+80)*FRACUNIT, (newyvalues[i]+60)*FRACUNIT, FRACUNIT/2, v.cachePatch("AT2_"..atk_constant_2_num[atk.type]), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
												else
													//draw element icon
													v.drawScaled((newxvalues[i]+80)*FRACUNIT, (newyvalues[i]+80)*FRACUNIT, FRACUNIT/2, v.cachePatch("AT2_"..atk_constant_2_num[atk.type]), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
												end
											else
												V_drawString(v, newxvalues[i]+10, newyvalues[i]+45, "CLEARED OUT", "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 10, 31)
											end
										else
											V_drawString(v, newxvalues[i]+10, newyvalues[i]+45, "CLEARED OUT", "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 10, 31)
										end
									else
										local stats = {"strength", "magic", "endurance", "agility", "luck"}
										local statcolor = "\x80"
										if not p.tunermenu
											local desctext = STR_WordWrap(v, "Increase any stats of your choosing for the cost of 1 Rank Point per stat increase. Changes may be reverted at any time.", 95, "NFNT", FRACUNIT/2)
											local desctext2 = STR_WWToString(desctext)
											V_drawString(v, newxvalues[i]+23, newyvalues[i]+5, "Stat Tuner", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 73, 31)
											V_drawString(v, newxvalues[i]+5, newyvalues[i]+20, desctext2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
										else
											v.drawFill((newxvalues[i]+10), (newyvalues[i]+5), 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|31)
											V_drawString(v, newxvalues[i]+33, newyvalues[i]+10, "Stat Tuner", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 73, 31)
											local space = leveltime%10 < 5 and ": " or ":  "
											local str1 = leveltime%10 < 5 and "<  " or "< "
											local str2 = leveltime%10 < 5 and "  >" or " >"
											for j = 1, #stats
												if p.tunerselect == j
													str1 = leveltime%10 < 5 and "\x82<  " or "\x82< "
													str2 = leveltime%10 < 5 and "\x82  >" or "\x82 >"
												else
													str1 = leveltime%10 < 5 and "\x80<  " or "\x80< "
													str2 = leveltime%10 < 5 and "\x80  >" or "\x80 >"
												end
												if rewardchar[stats[j]] > rewardchar.savestats[j]
													statcolor = "\x82"
													V_drawString(v, newxvalues[i]+115, j*10+(newyvalues[i]+40), "+"..(rewardchar[stats[j]]-rewardchar.savestats[j]), "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 97, 31)
												else
													statcolor = "\x80"
												end
												V_drawString(v, newxvalues[i]+15, j*10+(newyvalues[i]+40), stats[j]..space..str1..statcolor..rewardchar[stats[j]]..str2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
											end
										end
										for j = 1, #stats
											if rewardchar.savestats and #rewardchar.savestats
												if rewardchar[stats[j]] > rewardchar.savestats[j]
													statcolor = "\x82"
													V_drawString(v, newxvalues[i]+115, j*10+(newyvalues[i]+40), "+"..(rewardchar[stats[j]]-rewardchar.savestats[j]), "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 97, 31)
												else
													statcolor = "\x80"
												end
											end
										end
									end
									v.drawScaled(newxvalues[i]*FRACUNIT, newyvalues[i]*FRACUNIT, FRACUNIT, bruh, V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_50TRANS) --fade
								end
								
								//repeated but for selected box
								/*if p.rewardselect == i
									v.drawFill((newxvalues[i]+10), (newyvalues[i]+5), 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|selectcolor)
									if i == 3
										if p.tunermenu
											v.drawFill(newxvalues[i], newyvalues[i], 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|selectcolor2)
										else
											v.drawFill(newxvalues[i], newyvalues[i], 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|6)
										end
									end
									if i != 3
										if p.rewardoptions and #p.rewardoptions
											if p.rewardoptions[i] != "empty"
												local skill = p.rewardoptions[i]
												local atk = attackDefs[skill]
												local skilldesc = string.gsub(atk.desc, "\n", " ")
												local desctext = STR_WordWrap(v, skilldesc, 95, "NFNT", FRACUNIT/2)
												local desctext2 = STR_WWToString(desctext)
												local titletext = STR_WordWrap(v, atk.name, 80, "NFNT", FRACUNIT/2)
												local titletext2 = STR_WWToString(titletext)
												V_drawString(v, newxvalues[i]+20, newyvalues[i]+5, titletext2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 73, 31)
												V_drawString(v, newxvalues[i]+5, newyvalues[i]+20, desctext2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
												//draw player icon
												v.draw(newxvalues[i]+10, newyvalues[i]+13, v.getSprite2Patch(rewardchar.skin, SPR2_LIFE), V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(nil, rewardchar.color))
												//draw cost
												if atk.price
													V_drawString(v, newxvalues[i]+5, newyvalues[i]+90, "COST: \x82" + atk.price, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
												end
												if atk.next
													V_drawString(v, newxvalues[i]+5, newyvalues[i]+80, "NEXT: \x8C" + attackDefs[atk.next].name, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
													//draw element icon
													v.drawScaled((newxvalues[i]+80)*FRACUNIT, (newyvalues[i]+60)*FRACUNIT, FRACUNIT/2, v.cachePatch("AT2_"..atk_constant_2_num[atk.type]), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
												else
													//draw element icon
													v.drawScaled((newxvalues[i]+80)*FRACUNIT, (newyvalues[i]+80)*FRACUNIT, FRACUNIT/2, v.cachePatch("AT2_"..atk_constant_2_num[atk.type]), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
												end
											else
												V_drawString(v, newxvalues[i]+10, newyvalues[i]+45, "CLEARED OUT", "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 10, 31)
											end
										else
											V_drawString(v, newxvalues[i]+10, newyvalues[i]+45, "CLEARED OUT", "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 10, 31)
										end
									else
										local stats = {"strength", "magic", "endurance", "agility", "luck"}
										local statcolor = "\x80"
										if not p.tunermenu
											local desctext = STR_WordWrap(v, "Increase any stats of your choosing for the cost of 1 Rank Point per stat increase. Changes may be reverted at any time.", 95, "NFNT", FRACUNIT/2)
											local desctext2 = STR_WWToString(desctext)
											V_drawString(v, newxvalues[i]+23, newyvalues[i]+5, "Stat Tuner", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 73, 31)
											V_drawString(v, newxvalues[i]+5, newyvalues[i]+20, desctext2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
										else
											v.drawFill((newxvalues[i]+10), (newyvalues[i]+5), 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|31)
											V_drawString(v, newxvalues[i]+33, newyvalues[i]+10, "Stat Tuner", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 73, 31)
											local space = leveltime%10 < 5 and ": " or ":  "
											local str1 = leveltime%10 < 5 and "<  " or "< "
											local str2 = leveltime%10 < 5 and "  >" or " >"
											for j = 1, #stats
												if p.tunerselect == j
													str1 = leveltime%10 < 5 and "\x82<  " or "\x82< "
													str2 = leveltime%10 < 5 and "\x82  >" or "\x82 >"
												else
													str1 = leveltime%10 < 5 and "\x80<  " or "\x80< "
													str2 = leveltime%10 < 5 and "\x80  >" or "\x80 >"
												end
												if rewardchar[stats[j]] > rewardchar.savestats[j]
													statcolor = "\x82"
													V_drawString(v, newxvalues[i]+115, j*10+(newyvalues[i]+40), "+"..(rewardchar[stats[j]]-rewardchar.savestats[j]), "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 97, 31)
												else
													statcolor = "\x80"
												end
												V_drawString(v, newxvalues[i]+15, j*10+(newyvalues[i]+40), stats[j]..space..str1..statcolor..rewardchar[stats[j]]..str2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
											end
										end
										for j = 1, #stats
											if rewardchar.savestats and #rewardchar.savestats
												if rewardchar[stats[j]] > rewardchar.savestats[j]
													statcolor = "\x82"
													V_drawString(v, newxvalues[i]+115, j*10+(newyvalues[i]+40), "+"..(rewardchar[stats[j]]-rewardchar.savestats[j]), "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 97, 31)
												else
													statcolor = "\x80"
												end
											end
										end
									end
								end*/
							else //text
								V_drawString(v, newxvalues[i], newyvalues[i], "Rank Points: \x82" + rewardchar.rankpoints, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
							end
						else //NEXT option
							v.drawScaled((newxvalues[i]-85)*FRACUNIT, (newyvalues[i]+10)*FRACUNIT, FRACUNIT*2/3, v.cachePatch("H_CHCL"), V_SNAPTOTOP|V_SNAPTORIGHT)
							--v.drawScaled((newxvalues[i]+20)*FRACUNIT, (newyvalues[i]+15)*FRACUNIT, FRACUNIT, v.cachePatch("H_TCONT"), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
							if p.rewardselect == 4
								V_drawString(v, newxvalues[i]-100, newyvalues[i], "NEXT", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, selectcolor3, 31)
							else
								V_drawString(v, newxvalues[i]-100, newyvalues[i], "NEXT", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
							end
							V_drawLetter(v, (newxvalues[i]-130)*FRACUNIT, (newyvalues[i]-5)*FRACUNIT, "\x92", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, 0, FRACUNIT*4/3)
						end
					end
					
					//last minute thing
					newyvalues[6] = newyvalues[6] + (newydest[6] - newyvalues[6])/5
					newyvalues[7] = newyvalues[7] + (newydest[7] - newyvalues[7])/5
					V_drawString(v, newxvalues[6], newyvalues[6], "UPGRADE!", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 135, FRACUNIT)
					
					if p.saveselect
						local i = p.saveselect
						local playercolor = 145
						if p.rewardoptions[i] != "empty"
							if rewardchar.skin == "sonic"
								playercolor = 148
							elseif rewardchar.skin == "tails"
								playercolor = 52
							elseif rewardchar.skin == "knuckles"
								playercolor = 34
							elseif rewardchar.skin == "amy"
								playercolor = 200
							end
						else
							playercolor = 8
						end
						if i == p.rewardselect
							v.drawFill((newxvalues[i]+10), (newyvalues[i]+5), 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|selectcolor)
						else
							v.drawFill((newxvalues[i]+10), (newyvalues[i]+5), 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|31)
						end
						if i == 3
							if p.tunermenu
								v.drawFill(newxvalues[i], newyvalues[i], 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|selectcolor2)
							else
								v.drawFill(newxvalues[i], newyvalues[i], 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|6)
							end
							v.drawFill(newxvalues[i], newyvalues[i], 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|6)
						else
							v.drawFill(newxvalues[i], newyvalues[i], 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|playercolor)
						end
						if i != 3
							if p.rewardoptions and #p.rewardoptions
								if p.rewardoptions[i] != "empty"
									local skill = p.rewardoptions[i]
									local atk = attackDefs[skill]
									local skilldesc = string.gsub(atk.desc, "\n", " ")
									local desctext = STR_WordWrap(v, skilldesc, 95, "NFNT", FRACUNIT/2)
									local desctext2 = STR_WWToString(desctext)
									local titletext = STR_WordWrap(v, atk.name, 80, "NFNT", FRACUNIT/2)
									local titletext2 = STR_WWToString(titletext)
									V_drawString(v, newxvalues[i]+20, newyvalues[i]+5, titletext2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 73, 31)
									V_drawString(v, newxvalues[i]+5, newyvalues[i]+20, desctext2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
									//draw player icon
									v.draw(newxvalues[i]+10, newyvalues[i]+13, v.getSprite2Patch(rewardchar.skin, SPR2_LIFE), V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(nil, rewardchar.color))
									//draw cost
									if atk.price
										V_drawString(v, newxvalues[i]+5, newyvalues[i]+90, "COST: \x82" + atk.price, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
									end
									if atk.next
										V_drawString(v, newxvalues[i]+5, newyvalues[i]+80, "NEXT: \x8C" + attackDefs[atk.next].name, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
										//draw element icon
										v.drawScaled((newxvalues[i]+80)*FRACUNIT, (newyvalues[i]+60)*FRACUNIT, FRACUNIT/2, v.cachePatch("AT2_"..atk_constant_2_num[atk.type]), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
									else
										//draw element icon
										v.drawScaled((newxvalues[i]+80)*FRACUNIT, (newyvalues[i]+80)*FRACUNIT, FRACUNIT/2, v.cachePatch("AT2_"..atk_constant_2_num[atk.type]), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
									end
								else
									V_drawString(v, newxvalues[i]+10, newyvalues[i]+45, "CLEARED OUT", "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 10, 31)
								end
							else
								V_drawString(v, newxvalues[i]+10, newyvalues[i]+45, "CLEARED OUT", "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 10, 31)
							end
						else
							local stats = {"strength", "magic", "endurance", "agility", "luck"}
							local statcolor = "\x80"
							if not p.tunermenu
								local desctext = STR_WordWrap(v, "Increase any stats of your choosing for the cost of 1 Rank Point per stat increase. Changes may be reverted at any time.", 95, "NFNT", FRACUNIT/2)
								local desctext2 = STR_WWToString(desctext)
								V_drawString(v, newxvalues[i]+23, newyvalues[i]+5, "Stat Tuner", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 73, 31)
								V_drawString(v, newxvalues[i]+5, newyvalues[i]+20, desctext2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
							else
								v.drawFill((newxvalues[i]+10), (newyvalues[i]+5), 100, 100, V_SNAPTOBOTTOM|V_SNAPTOLEFT|31)
								V_drawString(v, newxvalues[i]+33, newyvalues[i]+10, "Stat Tuner", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 73, 31)
								local space = leveltime%10 < 5 and ": " or ":  "
								local str1 = leveltime%10 < 5 and "<  " or "< "
								local str2 = leveltime%10 < 5 and "  >" or " >"
								for j = 1, #stats
									if p.tunerselect == j
										str1 = leveltime%10 < 5 and "\x82<  " or "\x82< "
										str2 = leveltime%10 < 5 and "\x82  >" or "\x82 >"
									else
										str1 = leveltime%10 < 5 and "\x80<  " or "\x80< "
										str2 = leveltime%10 < 5 and "\x80  >" or "\x80 >"
									end
									if rewardchar[stats[j]] > rewardchar.savestats[j]
										statcolor = "\x82"
										V_drawString(v, newxvalues[i]+115, j*10+(newyvalues[i]+40), "+"..(rewardchar[stats[j]]-rewardchar.savestats[j]), "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 97, 31)
									else
										statcolor = "\x80"
									end
									V_drawString(v, newxvalues[i]+15, j*10+(newyvalues[i]+40), stats[j]..space..str1..statcolor..rewardchar[stats[j]]..str2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
								end
							end
							for j = 1, #stats
								if rewardchar.savestats and #rewardchar.savestats
									if rewardchar[stats[j]] > rewardchar.savestats[j]
										statcolor = "\x82"
										V_drawString(v, newxvalues[i]+115, j*10+(newyvalues[i]+40), "+"..(rewardchar[stats[j]]-rewardchar.savestats[j]), "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 97, 31)
									else
										statcolor = "\x80"
									end
								end
							end
						end
					end
					
					local str1 = leveltime%10 < 5 and "<   " or "  <  "
					local str2 = leveltime%10 < 5 and "   >" or ">"
					if p.rewardselect != 4 and not p.tunermenu
						V_drawString(v, newxvalues[7], newyvalues[7], "\x82"..str1.."                      "..str2, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
					end
				end
			end
			
			
			
			//all done, waiting for others to finish upgrading
			if p.canileave
				drawWaitScreen(v, 1, "Waiting for remaining \nplayers to finish \nupgrade selection.")
			end
		end
	end
end)
hud.add(stageClear)

addHook("ThinkFrame", function()
	//do this real quick because you cant exitlevel in hud thinker
	if getmeout
		getmeout = false
		if gamemap != 12
			completedstages = completedstages + 1
			--G_ExitLevel(nil, 1)
			for mo in mobjs.iterate()
				if mo.type == MT_PFIGHTER
					mo.hp = mo.maxhp
					mo.sp = mo.maxsp
				end
			end
			DNG_loadNewMap(gamemap+1)
		else
			G_ExitLevel(1, 1)
		end
	end
	//also battletime thinker
	if (mapheaderinfo[gamemap].bluemiststory)
		if server and server.P_BattleStatus[1]
			local btl = server.P_BattleStatus[1]
			if btl.battlestate != 0 and not cutscene
				btl.battletime2 = btl.battletime
				--print(btl.battletime2)
				--print(btl.battletime3)
			end
		end
	end
	//results screen function
	if stagecleared
		for p in players.iterate
			local btl = server.P_BattleStatus[1]
			if score
				if timer == 240
					if p.control and not p.control.enemy and p.control.plyr
						if not p.booststats
							p.booststats = {}
							p.boostskills = {}
							p.boostpassives = {}
							p.rankpoints = {}
							p.rewardposition = {}
						end
						p.rewardselect = 1
						p.saveselect = 1
						p.tunerselect = 1
						p.rewardqueue = {p.maincontrol}
						p.swaggy = true -- for readying up
						btl.leavecount = 0
						for k,v in ipairs(server.plentities[1])
							//for our main player
							if v.control.maincontrol == v and p == v.control
								p.rewardposition = {k}
								if not p.booststats[k]
									p.booststats[k] = {}
								end
							end
							//for the bots we control
							if v.control and v.control.maincontrol != v and p == v.control
								p.rewardqueue[#p.rewardqueue+1] = v
								p.rewardposition[#p.rewardposition+1] = k 
								if not p.booststats[k]
									p.booststats[k] = {}
								end
							end
						end
						for i = 1, #p.rewardqueue
							if not p.rankpoints[i]
								p.rankpoints[i] = rankpoints[score+1]
							else
								p.rankpoints[i] = $ + rankpoints[score+1]
							end
							p.rewardqueue[i].rankpoints = p.rankpoints[i]
						end
						if p.mo.skin == "sonic"
							p.rewardoptions = {"trisagion ex", "masukunda"}
						elseif p.mo.skin == "tails"
							p.rewardoptions = {"mamakanda v2", "faultless reinforcement v2"}
						elseif p.mo.skin == "knuckles"
							p.rewardoptions = {"thunder reign", "chaos surge"}
						elseif p.mo.skin == "amy"
							p.rewardoptions = {"patra alter", "swift vertigo"}
						end
						p.queueposition = 1
					end
				end
			end
			if newtimer >= 1 and not p.canileave
				if not p.rewardqueue return end
				local rewardchar = p.rewardqueue[p.queueposition]
				
				//remove options if they are already in your skillset
				if rewardchar and rewardchar.valid
					for k,v in ipairs(rewardchar.skills)
						for i = 1, #p.rewardoptions
							local skill = p.rewardoptions[i]
							local atk = attackDefs[skill]
							if v == skill and atk
								if atk.next
									p.rewardoptions[i] = atk.next
								else
									p.rewardoptions[i] = "empty"
								end
							end
							if atk and atk.next and v == atk.next
								if attackDefs[atk.next].next
									p.rewardoptions[i] = attackDefs[atk.next].next
								else
									p.rewardoptions[i] = "empty"
								end
							end
							if atk and atk.next and attackDefs[atk.next].next and v == attackDefs[atk.next].next //lmao
								p.rewardoptions[i] = "empty"
							end
						end
					end
					if rewardchar.passiveskills
						for k,v in ipairs(rewardchar.passiveskills)
							for i = 1, #p.rewardoptions
								local skill = p.rewardoptions[i]
								local atk = attackDefs[skill]
								if v == skill and atk
									if atk.next
										p.rewardoptions[i] = atk.next
									else
										p.rewardoptions[i] = "empty"
									end
								elseif atk and atk.next and v == atk.next
									if atk.next.next
										p.rewardoptions[i] = atk.next.next
									else
										p.rewardoptions[i] = "empty"
									end
								elseif atk and atk.next and atk.next.next and v == atk.next.next //lmao
									p.rewardoptions[i] = "empty"
								end
							end
						end
					end
				end
						
				//navigation
				if not p.tunermenu
					/*if p.mo.P_inputs["left"] == 1 and p.rewardselect != 1
						if p.rewardselect == 2 or p.rewardselect == 3
							p.rewardselect = 1
						else
							p.rewardselect = 2
						end
						S_StartSound(nil, sfx_hover, p)
					end
					if p.mo.P_inputs["right"] == 1 and p.rewardselect != 4
						if p.rewardselect == 1 or p.rewardselect == 3
							p.rewardselect = 2
						elseif p.rewardselect == 2
							p.rewardselect = 4
						end
						S_StartSound(nil, sfx_hover, p)
					end
					if p.mo.P_inputs["up"] == 1 and p.rewardselect == 3
						p.rewardselect = 1
						S_StartSound(nil, sfx_hover, p)
					end
					if p.mo.P_inputs["down"] == 1 and p.rewardselect != 3
						p.rewardselect = 3
						S_StartSound(nil, sfx_hover, p)
					end*/
					
					if p.mo.P_inputs["left"] == 1 and p.rewardselect != 4
						if p.rewardselect == 2 or p.rewardselect == 3
							p.rewardselect = $ - 1
							p.saveselect = p.rewardselect
						else
							p.rewardselect = 3
							p.saveselect = p.rewardselect
						end
						S_StartSound(nil, sfx_hover, p)
					end
					if p.mo.P_inputs["right"] == 1 and p.rewardselect != 4
						if p.rewardselect == 1 or p.rewardselect == 2
							p.rewardselect = $ + 1
							p.saveselect = p.rewardselect
						else
							p.rewardselect = 1
							p.saveselect = p.rewardselect
						end
						S_StartSound(nil, sfx_hover, p)
					end
					if (p.mo.P_inputs[BT_BTNC] == 1 or p.mo.P_inputs["up"] == 1) and p.rewardselect != 4
						p.rewardselect = 4
						S_StartSound(nil, sfx_hover, p)
					end
					if (p.mo.P_inputs["down"] == 1 or p.mo.P_inputs[BT_USE] == 1) and p.rewardselect == 4
						p.rewardselect = p.saveselect
						S_StartSound(nil, sfx_hover, p)
					end
				else
					if p.mo.P_inputs["up"] == 1
						if p.tunerselect != 1
							p.tunerselect = $-1
							S_StartSound(nil, sfx_hover, p)
						else
							p.tunerselect = 5
							S_StartSound(nil, sfx_hover, p)
						end
					end
					if p.mo.P_inputs["down"] == 1
						if p.tunerselect != 5
							p.tunerselect = $+1
							S_StartSound(nil, sfx_hover, p)
						else
							p.tunerselect = 1
							S_StartSound(nil, sfx_hover, p)
						end
					end
					if p.mo.P_inputs["right"] == 1
						local stats = {"strength", "magic", "endurance", "agility", "luck"}
						for j = 1, #stats
							if p.tunerselect == j and rewardchar.rankpoints > 0
								rewardchar.rankpoints = $-1
								rewardchar[stats[j]] = $+1
								S_StartSound(nil, sfx_hover, p)
							end
						end
					end
					if p.mo.P_inputs["left"] == 1
						local stats = {"strength", "magic", "endurance", "agility", "luck"}
						for j = 1, #stats
							if p.tunerselect == j and rewardchar[stats[j]] > rewardchar.savestats[j]
								rewardchar.rankpoints = $+1
								rewardchar[stats[j]] = $-1
								S_StartSound(nil, sfx_hover, p)
							end
						end
					end
				end
				
				//selecting
				if p.mo.P_inputs[BT_JUMP] == 1
					if p.rewardselect == 1 or p.rewardselect == 2 //selected move upgrade
						if attackDefs[p.rewardoptions[p.rewardselect]]
							local atk = p.rewardoptions[p.rewardselect]
							local skill = attackDefs[atk]
							if skill != "empty" //no price failsafe
								if not skill.price
									S_StartSound(nil, sfx_chchng, p)
									if skill.next
										p.rewardoptions[p.rewardselect] = skill.next
									else
										p.rewardoptions[p.rewardselect] = "empty"
									end
									if skill.replace
										if skill.passive
											for k,v in ipairs(rewardchar.passiveskills)
												if v == skill.replace
													table.remove(rewardchar.passiveskills, k)
													table.insert(rewardchar.passiveskills, k, atk)
												end
											end
										else
											for k,v in ipairs(rewardchar.skills)
												if v == skill.replace
													table.remove(rewardchar.skills, k)
													table.insert(rewardchar.skills, k, atk)
												end
											end
										end
									else
										if skill.passive
											rewardchar.passiveskills[#rewardchar.passiveskills+1] = atk
										else
											table.insert(rewardchar.skills, atk)
										end
									end
									return
								end
							end
							if (skill.price > rewardchar.rankpoints or skill == "empty") //ye' too broke, lad
								S_StartSound(nil, sfx_not, p)
							else
								S_StartSound(nil, sfx_chchng, p)
								rewardchar.rankpoints = $ - skill.price
								if skill.next
									p.rewardoptions[p.rewardselect] = skill.next
								else
									p.rewardoptions[p.rewardselect] = "empty"
								end
								if skill.replace
									if skill.passive
										for k,v in ipairs(rewardchar.passiveskills)
											if v == skill.replace
												table.remove(rewardchar.passiveskills, k)
												table.insert(rewardchar.passiveskills, k, atk)
											end
										end
									else
										for k,v in ipairs(rewardchar.skills)
											if v == skill.replace
												table.remove(rewardchar.skills, k)
												table.insert(rewardchar.skills, k, atk)
											end
										end
									end
								else
									if skill.passive
										rewardchar.passiveskills[#rewardchar.passiveskills+1] = atk
									else
										table.insert(rewardchar.skills, atk)
									end
								end
							end
						else
							S_StartSound(nil, sfx_not, p)
						end
					elseif p.rewardselect == 3 //selected stat tuner
						if not p.tunermenu
							p.tunermenu = true
							S_StartSound(nil, sfx_select, p)
						end
					elseif p.rewardselect == 4 //selected NEXT
						local stats = {"strength", "magic", "endurance", "agility", "luck"}
						if rewardchar and rewardchar.valid
							--print(p.rewardposition[p.queueposition])
							for i = 1, #stats
								p.booststats[p.rewardposition[p.queueposition]][i] = rewardchar[stats[i]]
							end
							--p.boostskills[p.rewardposition[p.queueposition]] = rewardchar.skills
							p.boostpassives[p.rewardposition[p.queueposition]] = rewardchar.passiveskills
						end
						if p.queueposition < #p.rewardqueue
							p.queueposition = $+1
							if p.rewardqueue[p.queueposition].skin == "sonic"
								p.rewardoptions = {"trisagion ex", "masukunda"}
							elseif p.rewardqueue[p.queueposition].skin == "tails"
								p.rewardoptions = {"mamakanda v2", "faultless reinforcement v2"}
							elseif p.rewardqueue[p.queueposition].skin == "knuckles"
								p.rewardoptions = {"thunder reign", "chaos surge"}
							elseif p.rewardqueue[p.queueposition].skin == "amy"
								p.rewardoptions = {"patra alter", "swift vertigo"}
							end
							S_StartSound(nil, sfx_qsumon, p)
							xdist = -250
							p.rewardselect = 1
							p.saveselect = 1
						else
							for i = 1, #p.rewardqueue
								p.rankpoints[i] = p.rewardqueue[i].rankpoints
							end
							p.rewardqueue = nil
							p.queueposition = nil
							p.canileave = true
							p.rewardselect = 1
							btl.leavecount = btl.leavecount + 1
							S_StartSound(nil, sfx_confir, p)
							--getmeout = true
						end
					end
				end
				//exiting out of stat tuner
				if p.mo.P_inputs[BT_USE] == 1
					if p.tunermenu
						p.tunermenu = false
						S_StartSound(nil, sfx_cancel, p)
					end
				end
				//exiting out of the level once everyone is ready
				if btl and btl.leavecount >= #server.playerlist[1]
					getmeout = true
					btl.leavecount = 0
				end
			end
		end
	else
		//reset player stuff
		/*for p in players.iterate
			p.rewardqueue = {}
			p.queueposition = 0
			p.rewardposition = {}
		end*/
	end
end)

//skill upgrades (theres a lot)
attackDefs["trisagion ex"] = {
		name = "Trisagion EX",
		type = ATK_FIRE,
		power = 800,
		accuracy = 100, --original: 95
		costtype = CST_SP,
		status = COND_BURN,
		statuschance = 10,
		cost = 32,
		desc = "Severe Fire dmg to one enemy.\nHigh chance of burn.\nIncreased power and\nguaranteed burn on first hit.",
		target = TGT_ENEMY,
		price = 30, --custom stuff for upgrade shop --15
		replace = "trisagion",
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 1
				mo.fangle = 0
				mo.fdist = 400
				mo.columns = {}

			elseif timer >= 15
			and timer <= 30
				for i = 1, 12
					local colors = {SKINCOLOR_COBALT, SKINCOLOR_BLUE, SKINCOLOR_PURPLE, SKINCOLOR_DUSK, SKINCOLOR_NEON, SKINCOLOR_VIOLET, SKINCOLOR_SAPPHIRE}
					local boom = P_SpawnMobj(target.x + P_RandomRange(-48, 48)*FRACUNIT, target.y + P_RandomRange(-48, 48)*FRACUNIT, target.z, MT_DUMMY)
					boom.colorized = true
					boom.state = S_QUICKBOOM1
					boom.color = colors[P_RandomRange(1, #colors)]
					boom.flags = $ & ~MF_NOGRAVITY
					boom.momz = 8*FRACUNIT
					boom.scale = FRACUNIT*3/2

				end

			elseif timer == 31

				DoExplosion(target)
				for i = 1, 3 do
					local an = (mo.fangle + (i-1)*120)*ANG1
					local h = P_SpawnMobj(target.x + mo.fdist*cos(an), target.y + mo.fdist*sin(an), target.z, MT_DUMMY)
					h.state = S_INVISIBLE
					h.tics = -1
					mo.columns[#mo.columns+1] = h
				end
			end

			--if timer%2 == 0
			--	playSound(mo.battlen, sfx_fire1)
			--end

			local j = #mo.columns
			while j

				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local colors = {SKINCOLOR_COBALT, SKINCOLOR_BLUE, SKINCOLOR_PURPLE, SKINCOLOR_DUSK, SKINCOLOR_NEON, SKINCOLOR_VIOLET, SKINCOLOR_SAPPHIRE}
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.colorized = true
					boom.state = S_QUICKBOOM1
					boom.color = colors[P_RandomRange(1, #colors)]
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*5/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)

				if timer <= 140
					local an = (mo.fangle + (j-1)*120)*ANG1
					P_TeleportMove(m, target.x + mo.fdist*cos(an), target.y + mo.fdist*sin(an), target.z)
				end

				j = $-1

			end

			if timer >= 31
				mo.fangle = $ + min(14, ((timer-31)/4))
				mo.fdist = max(96, $- 4)
			end

			if timer == 120
				DoExplosion(target)
			elseif timer >= 120 and timer < 140
				for i = 1, 12
					local colors = {SKINCOLOR_COBALT, SKINCOLOR_BLUE, SKINCOLOR_PURPLE, SKINCOLOR_DUSK, SKINCOLOR_NEON, SKINCOLOR_VIOLET, SKINCOLOR_SAPPHIRE}
					local boom = P_SpawnMobj(target.x + P_RandomRange(-64, 64)*FRACUNIT, target.y + P_RandomRange(-64, 64)*FRACUNIT, target.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.color = colors[P_RandomRange(1, #colors)]
					boom.momz = P_RandomRange(0, 80)*FRACUNIT
					boom.scale = FRACUNIT*5
				end
			elseif timer == 140
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
				
				if not mo.firstburn
					inflictStatus(target, COND_BURN)
					mo.firstburn = true
				end

				damageObject(target)
			elseif timer == 180
				mo.fangle = nil
				mo.columns = nil
				return true
			end
		end,
	}
	
attackDefs["masukunda"] = {
		name = "Masukunda",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Lower enemies' agility\nby 1 stage.",
		target = TGT_ALLENEMIES,
		debuff = true,
		norepel = true,
		next = "masukunda II",
		price = 15,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + 8*(i-1)
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_EMERALD

				elseif timer == 5+2*TICRATE + 8*(i-1)
					buffStat(target, "agi", -BUFFSTEP)	-- negative values lower a stat
					playSound(mo.battlen, sfx_s3k8c)
					local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
					dbuff.state = S_DBUFF1
					dbuff.color = SKINCOLOR_EMERALD
					dbuff.scale = FRACUNIT*5/2
				end
			end

			if timer == TICRATE*3 + 8*(#targets-1)
				return true
			end
		end,
	}
	
attackDefs["masukunda II"] = {
		name = "Masukunda II",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 24,
		desc = "Lower enemies' agility\nby 2 stages",
		target = TGT_ALLENEMIES,
		debuff = true,
		norepel = true,
		next = "masukunda III",
		price = 17,
		replace = "masukunda",
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + 8*(i-1)
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_EMERALD

				elseif timer == 5+2*TICRATE + 8*(i-1)
					buffStat(target, "agi", -BUFFSTEP*2)	-- negative values lower a stat
					playSound(mo.battlen, sfx_s3k8c)
					local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
					dbuff.state = S_DBUFF1
					dbuff.color = SKINCOLOR_EMERALD
					dbuff.scale = FRACUNIT*5/2
				end
			end

			if timer == TICRATE*3 + 8*(#targets-1)
				return true
			end
		end,
	}

attackDefs["masukunda III"] = {
		name = "Masukunda III",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 36,
		desc = "Lower enemies' agility\nby 3 stages",
		target = TGT_ALLENEMIES,
		debuff = true,
		norepel = true,
		price = 20,
		replace = "masukunda II",
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + 8*(i-1)
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_EMERALD

				elseif timer == 5+2*TICRATE + 8*(i-1)
					buffStat(target, "agi", -BUFFSTEP*3)	-- negative values lower a stat
					playSound(mo.battlen, sfx_s3k8c)
					local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
					dbuff.state = S_DBUFF1
					dbuff.color = SKINCOLOR_EMERALD
					dbuff.scale = FRACUNIT*5/2
				end
			end

			if timer == TICRATE*3 + 8*(#targets-1)
				return true
			end
		end,
	}
	
attackDefs["mamakanda v2"] = {
		name = "Mamakanda v2",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Lower enemies' magic\nattack by 2 stages.",
		target = TGT_ALLENEMIES,
		debuff = true,
		norepel = true,
		price = 20,
		replace = "mamakanda",
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + 8*(i-1)
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_TEAL

				elseif timer == 5+2*TICRATE + 8*(i-1)
					buffStat(target, "mag", -BUFFSTEP*2)	-- negative values lower a stat
					playSound(mo.battlen, sfx_s3k8c)
					local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
					dbuff.state = S_DBUFF1
					dbuff.color = SKINCOLOR_TEAL
					dbuff.scale = FRACUNIT*5/2
				end
			end

			if timer == TICRATE*3 + 8*(#targets-1)
				return true
			end
		end,
	}
	
attackDefs["faultless reinforcement v2"] = {
		name = "Faultless Reinforcement v2",
		type = ATK_SUPPORT,
		costtype = CST_EP,
		cost = 2,
		desc = "Removes debuffs, raises defense,\ngrants Endure for one time, and\ninvokes a physical barrier to all allies.",
		target = TGT_ALLALLIES,
		makarakarn = true,
		tetrakarn = true,
		price = 30,
		replace = "faultless reinforcement",
		anim = function(mo, targets, hittargets, timer)
			local emeraldcolors = {SKINCOLOR_MINT, SKINCOLOR_EMERALD, SKINCOLOR_FOREST}
			if timer == 1
				mo.fields = {}
				mo.sparkles = {}
				mo.angspeed = 2
				playSound(mo.battlen, sfx_bufu1)
				for i = 1, 30
					local energy = P_SpawnMobj(mo.x-P_RandomRange(200,-200)*FRACUNIT, mo.y-P_RandomRange(200,-200)*FRACUNIT, mo.z+P_RandomRange(150,0)*FRACUNIT, MT_DUMMY)
					energy.sprite = SPR_THOK
					energy.frame = FF_FULLBRIGHT
					energy.color = emeraldcolors[P_RandomRange(1, #emeraldcolors)]
					energy.scale = FRACUNIT/P_RandomRange(3, 6)
					energy.tics = 20
					energy.momx = (mo.x - energy.x)/20
					energy.momy = (mo.y - energy.y)/20
					energy.momz = (mo.z - energy.z)/20
				end
			end
			if timer == 20
				local thok = P_SpawnMobj(mo.x, mo.y, mo.z+5*FRACUNIT, MT_DUMMY)
				thok.state = S_INVISIBLE
				thok.tics = 1
				thok.scale = FRACUNIT*4
				A_OldRingExplode(thok, MT_SUPERSPARK)
				playSound(mo.battlen, sfx_hamas2)
				playSound(mo.battlen, sfx_bufu6)
				if mo.status_condition == COND_HYPER
					mo.hyperpower = true
					playSound(mo.battlen, sfx_buff2)
					localquake(mo.battlen, FRACUNIT*10, 10)
				else
					mo.status_condition = COND_HYPER
				end
				//sparkles rotate around invisible field, field multiplies into separate copies for team
				for i = 1, #hittargets
					local field = P_SpawnMobj(mo.x, mo.y, mo.floorz - 5*FRACUNIT, MT_DUMMY)
					field.state = S_INVISIBLE
					field.tics = -1
					field.target = hittargets[i]
					mo.fields[#mo.fields+1] = field
					for i = 1, 20
						local ang = ANG1*(18*(i-1))
						local tgtx = mo.x + 60*cos(mo.angle + ang)
						local tgty = mo.y + 60*sin(mo.angle + ang)
						local sparkle = P_SpawnMobj(tgtx, tgty, mo.floorz - 5*FRACUNIT, MT_DUMMY)
						sparkle.rotate = ang
						sparkle.scale = FRACUNIT/2
						sparkle.tics = -1
						sparkle.sprite = SPR_FILD
						sparkle.frame = FF_FULLBRIGHT
						sparkle.colorized = true
						sparkle.direction = 0
						sparkle.target = field
						mo.sparkles[#mo.sparkles+1] = sparkle
					end
				end
			end
			if mo.hyperpower
				summonAura(mo, SKINCOLOR_EMERALD)
			end
			if timer == 60
				playSound(mo.battlen, sfx_aoaask)
			end
			if timer == 100
				playSound(mo.battlen, sfx_nskill)
			end
			if timer == 190
				playSound(mo.battlen, sfx_mirror)
			end
			if timer >= 120 and timer <= 130
				if leveltime%3 == 0
					mo.angspeed = $+1
				end
			end
			if timer >= 220
				if mo.angspeed > 0
					if leveltime%5 == 0
						mo.angspeed = $-1
					end
				end
			end
			
			for i = 1, #hittargets
				local target = hittargets[i]
				if timer >= 130 and timer < 190
					if leveltime%2 == 0
						local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						s.sprite = SPR_FORC
						s.frame = $|FF_FULLBRIGHT
						s.tics = 1
					end
				end
				if timer == 170
					cureStatus(mo)	-- clear previous status. Especially useful for hunger and its half-stats
					target.status_condition = COND_HYPER
					mo.status_condition = COND_HYPER
					playSound(mo.battlen, sfx_supert)
					playSound(mo.battlen, sfx_supert)
					BTL_logMessage(mo.battlen, "Hyper Mode activated!")
					-- increase all stats
					local stats = {"strength", "magic", "endurance", "agility", "luck"}
					for i = 1, #stats do
						target[stats[i]] = $+10
						mo[stats[i]] = $+10
					end
					local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					A_OldRingExplode(thok, MT_SUPERSPARK)
				end
				if timer == 190
					local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					A_OldRingExplode(thok, MT_SUPERSPARK)

					target.tetrakarn = true
					BTL_logMessage(targets[1].battlen, "Physical barrier invoked!")
				end
				if timer == 210
					local colors = {SKINCOLOR_ORANGE, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD, SKINCOLOR_YELLOW}
					local strs = {"atk", "mag", "def", "agi", "crit"}
					playSound(mo.battlen, sfx_status)
					for j = 1, 16
						local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						orb.momx = P_RandomRange(-16, 16)<<FRACBITS
						orb.momy = P_RandomRange(-16, 16)<<FRACBITS
						orb.momz = P_RandomRange(-16, 16)<<FRACBITS
						orb.destscale = 0
						orb.frame = A
						orb.color = colors[P_RandomRange(1, #colors)]
					end
					for j = 1, #strs
						local s = strs[j]
						if target.buffs[s][1] < 0
							target.buffs[s][1] = 0
							target.buffs[s][2] = 0
						end
					end
					BTL_logMessage(targets[1].battlen, "Stat decreases nullified")
				end
				
				if timer == 230
					local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					A_OldRingExplode(thok, MT_SUPERSPARK)
					playSound(mo.battlen, sfx_karin)
					BTL_logMessage(targets[1].battlen, "Endure passive gained!")
					if not target.alreadygotit
						table.insert(target.passiveskills, "endure")
						target.alreadygotit = true
					end
				end
					
				if timer == 250
					buffStat(target, "def", 75)
					if not mo.hyperpower
						playSound(mo.battlen, sfx_buff)
					else
						playSound(mo.battlen, sfx_buff2)
						buffStat(target, "crit", 75)
						BTL_logMessage(targets[1].battlen, "Critical rate and defense maximized!")
					end
					for i = 1,16
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_WHITE
						dust.scale = FRACUNIT*2
					end

				elseif timer > 250 and timer <= 280

					local colors = {SKINCOLOR_YELLOW, SKINCOLOR_LAVENDER}
					if leveltime%2 == 0
						for i = 1,16

							local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
							thok.state = S_CDUST1
							thok.momz = P_RandomRange(5, 12)*FRACUNIT
							if mo.hyperpower
								thok.color = colors[P_RandomRange(1,2)]
							else
								thok.color = colors[2]
							end
							thok.tics = P_RandomRange(10, 35)
							thok.scale = FRACUNIT*3/2
						end
					end

					for i = 1, 8
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_SUMN
						thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
						thok.momz = P_RandomRange(8, 18)*FRACUNIT
						if mo.hyperpower
							thok.color = colors[P_RandomRange(1,2)]
						else
							thok.color = colors[2]
						end
						thok.tics = P_RandomRange(10, 35)
					end
				end
			end
			
			if mo.fields and #mo.fields
				for i = 1, #mo.fields
					if mo.fields[i] and mo.fields[i].valid
						local f = mo.fields[i]
						if timer >= 60
							f.momx = (f.target.x - f.x)/10
							f.momy = (f.target.y - f.y)/10
						end
						for i = 1, 4
							local num = i
							if timer == 100
								for i = 1, 20
									local ang = ANG1*(18*(i-1))
									local tgtx = mo.x + 60*cos(mo.angle + ang)
									local tgty = mo.y + 60*sin(mo.angle + ang)
									local sparkle = P_SpawnMobj(tgtx, tgty, mo.floorz - 5*FRACUNIT, MT_DUMMY)
									sparkle.rotate = ang
									sparkle.scale = FRACUNIT/2
									sparkle.tics = -1
									sparkle.sprite = SPR_FILD
									sparkle.frame = FF_FULLBRIGHT
									sparkle.colorized = true
									sparkle.direction = num
									sparkle.target = f
									sparkle.fieldz = mo.z + (num*25*FRACUNIT)
									mo.sparkles[#mo.sparkles+1] = sparkle
								end
							end
						end
						if timer == 310
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
							P_TeleportMove(s, tgtx, tgty, s.z)
						end
						if s.direction%2 == 0
							s.rotate = $ - ANG1*mo.angspeed
						else
							s.rotate = $ + ANG1*mo.angspeed
						end
						if s.fieldz and timer < 280
							s.momz = (s.fieldz - s.z)/10
						end
						if timer >= 280
							s.momz = ((mo.floorz - 5*FRACUNIT) - s.z)/8
						end
						if timer == 310
							P_RemoveMobj(s)
						end
					end
				end
			end
			if timer == 310
				mo.renderflags = $ & ~RF_FULLBRIGHT
				return true
			end
		end,
}

attackDefs["thunder reign"] = {
		name = "Thunder Reign",
		type = ATK_ELEC,
		power = 650,
		accuracy = 100,
		costtype = CST_SP,
		status = COND_SHOCK,
		statuschance = 10,
		cost = 32,
		price = 15,
		next = "thunder reign v2",
		replace = "ziodyne",
		desc = "Severe Elec dmg to one enemy.\nHigh chance of shock.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				playSound(mo.battlen, sfx_zio5)
			end

			if timer >= 16
			and timer <= 20
				local s = P_SpawnMobj(target.x, target.y, target.z + target.height/2, MT_THOK)
				s.tics = -1
				s.sprite = SPR_LZI1
				s.frame = F|FF_FULLBRIGHT|FF_TRANS70
				s.scale = mo.scale/2
				s.destscale = mo.scale*16
				s.scalespeed = mo.scale/(12-((timer-16)*2))
				s.blendmode = AST_ADD
				s.fuse = 70 - timer
			end

			if timer >= 16
			and timer <= 70
			and leveltime%3 == 0


				local range = 60
				if timer >= 50
					range = 100
				end

				local s = P_SpawnMobj(target.x + P_RandomRange(-range, range)*mo.scale, target.y + P_RandomRange(-range, range)*mo.scale, target.z + P_RandomRange(0, 100)*mo.scale, MT_SUPERSPARK)
			end

			if timer == 50
			or timer == 70
				for i = 1, #server.playerlist[mo.battlen]
					if server.playerlist[mo.battlen][i]
						P_FlashPal(server.playerlist[mo.battlen][i], 1, 2)
					end
				end
				localquake(mo.battlen, FRACUNIT*(timer == 50 and 16 or 32), 10)
			end

			if timer == 70
				lightningblast(target, SKINCOLOR_GOLD, FRACUNIT*3)
				damageObject(target)

				for i = 1, 10
					local range = 1024
					local z1 = P_SpawnMobj(target.x + P_RandomRange(-range, range)*mo.scale, target.y + P_RandomRange(-range, range)*mo.scale, target.z, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_GOLD
					z1.destscale = target.scale
					z1.tics = $ + P_RandomRange(-1, 12)
				end

			elseif timer == 120
				return true
			end

		end,
}

attackDefs["thunder reign v2"] = {
		name = "Thunder Reign v2",
		type = ATK_ELEC,
		power = 650,
		accuracy = 100,
		costtype = CST_SP,
		status = COND_SHOCK,
		statuschance = 20,
		cost = 32,
		price = 12,
		desc = "Severe Elec dmg to one enemy.\nVery high chance of shock.\nLowers physical attack on hit.",
		target = TGT_ENEMY,
		replace = "thunder reign",
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				playSound(mo.battlen, sfx_zio5)
			end

			if timer >= 16
			and timer <= 20
				local s = P_SpawnMobj(target.x, target.y, target.z + target.height/2, MT_THOK)
				s.tics = -1
				s.sprite = SPR_LZI1
				s.frame = F|FF_FULLBRIGHT|FF_TRANS70
				s.scale = mo.scale/2
				s.destscale = mo.scale*16
				s.scalespeed = mo.scale/(12-((timer-16)*2))
				s.blendmode = AST_ADD
				s.fuse = 70 - timer
			end

			if timer >= 16
			and timer <= 70
			and leveltime%3 == 0


				local range = 60
				if timer >= 50
					range = 100
				end

				local s = P_SpawnMobj(target.x + P_RandomRange(-range, range)*mo.scale, target.y + P_RandomRange(-range, range)*mo.scale, target.z + P_RandomRange(0, 100)*mo.scale, MT_SUPERSPARK)
			end

			if timer == 50
			or timer == 70
				for i = 1, #server.playerlist[mo.battlen]
					if server.playerlist[mo.battlen][i]
						P_FlashPal(server.playerlist[mo.battlen][i], 1, 2)
					end
				end
				localquake(mo.battlen, FRACUNIT*(timer == 50 and 16 or 32), 10)
			end

			if timer == 70
				lightningblast(target, SKINCOLOR_GOLD, FRACUNIT*3)
				damageObject(target)
				buffStat(target, "atk", -BUFFSTEP)	-- negative values lower a stat

				for i = 1, 10
					local range = 1024
					local z1 = P_SpawnMobj(target.x + P_RandomRange(-range, range)*mo.scale, target.y + P_RandomRange(-range, range)*mo.scale, target.z, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_GOLD
					z1.destscale = target.scale
					z1.tics = $ + P_RandomRange(-1, 12)
				end

			elseif timer == 120
				return true
			end

		end,
}

attackDefs["chaos surge"] = {
		name = "Chaos Surge",
		type = ATK_PASSIVE,
		passive = PSV_STARTTURN,
		desc = "Emerald Gauge is increased\npassively by 50% per turn.",
		price = 40,
		anim = function(mo, targets, hittargets, timer)
			if timer == 1
				playSound(mo.battlen, sfx_s3kcas)
				local g = P_SpawnGhostMobj(mo)
				g.color = SKINCOLOR_EMERALD
				g.colorized = true
				g.destscale = FRACUNIT*4
				fillEmeraldGauge(mo, 50, true)
			elseif timer == 2
				return true
			end
		end,
}

attackDefs["patra alter"] = {
		name = "Patra Alter",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 15,
		desc = "Remove status conditions \nfrom 1 ally and gain EP. Curing\nailments increase EP gain.",
		target = TGT_ALLY,
		patra = true,
		price = 10,
		next = "me patra alter",
		replace = "patra",
		anim = function(mo, targets, hittargets, timer)
			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD}

			local target = hittargets[1]
			if timer == 20
				playSound(mo.battlen, sfx_status)
				for j = 1, 16
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.momx = P_RandomRange(-16, 16)<<FRACBITS
					orb.momy = P_RandomRange(-16, 16)<<FRACBITS
					orb.momz = P_RandomRange(-16, 16)<<FRACBITS
					orb.destscale = 0
					orb.frame = A
					orb.color = colors[P_RandomRange(1, #colors)]
				end
				if target.status_condition and target.status_condition < COND_HYPER
					cureStatus(target)
					playSound(mo.battlen, sfx_buff)
					fillEmeraldGauge(mo, 30, true)
					local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					A_OldRingExplode(thok, MT_SUPERSPARK)
				else
					fillEmeraldGauge(mo, 10, true)
				end
				BTL_logMessage(targets[1].battlen, "Status nullified")
			end
			if timer == TICRATE*3/2
				return true
			end
		end,
	}

attackDefs["me patra alter"] = {
		name = "Me Patra Alter",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 24,
		desc = "Remove status conditions\nfrom the party and gain\nEP from allies. Curing ailments\nincrease EP gain.",
		target = TGT_ALLALLIES,
		patra = true,
		price = 20,
		replace = "patra alter",
		anim = function(mo, targets, hittargets, timer)
			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD}

			for i = 1, #targets
				local target = targets[i]
				if timer == 20 + (i-1)*10
					playSound(mo.battlen, sfx_status)
					for j = 1, 16
						local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						orb.momx = P_RandomRange(-16, 16)<<FRACBITS
						orb.momy = P_RandomRange(-16, 16)<<FRACBITS
						orb.momz = P_RandomRange(-16, 16)<<FRACBITS
						orb.destscale = 0
						orb.frame = A
						orb.color = colors[P_RandomRange(1, #colors)]
					end
					if target.status_condition and target.status_condition < COND_HYPER
						cureStatus(target)
						playSound(mo.battlen, sfx_buff)
						fillEmeraldGauge(mo, 30, true)
						local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
						thok.state = S_INVISIBLE
						thok.tics = 1
						A_OldRingExplode(thok, MT_SUPERSPARK)
					else
						fillEmeraldGauge(mo, 10, true)
					end
					BTL_logMessage(targets[1].battlen, "Status nullified")
				end
			end
			if timer == TICRATE*3/2 + (#targets-1)*10
				return true
			end
		end,
	}
	
attackDefs["swift vertigo"] = {
		name = "Swift Vertigo",
		type = ATK_PASSIVE,
		passive = PSV_ONDAMAGE,
		desc = "All Wind type moves have a\x82 20%\x80 chance\nto inflict dizzy.",
		price = 20,
		next = "wild vertigo",
		anim = 	function(mo, target)
					if mo.attack and P_RandomRange(0,100) <= 20 and mo.attack.type & ATK_WIND
						playSound(mo.battlen, sfx_ngskid)
						if target.enemy
							inflictStatus(target, COND_DIZZY)
						end
					end
				end,
}

attackDefs["wild vertigo"] = {
		name = "Wild Vertigo",
		type = ATK_PASSIVE,
		passive = PSV_ONDAMAGE,
		desc = "All Wind type moves have a\x82 40%\x80 chance\nto inflict dizzy.\nTeam gains \x82+20%\x80 technical damage.",
		price = 25,
		replace = "swift vertigo",
		anim = 	function(mo, target)
					if mo.attack and P_RandomRange(0,100) <= 40 and mo.attack.type & ATK_WIND
						playSound(mo.battlen, sfx_ngskid)
						if target.enemy
							inflictStatus(target, COND_DIZZY)
						end
					end
				end,
}

attackDefs["wild vertigo pt.2"] = {
		name = "Wild Vertigo pt.2",
		type = ATK_PASSIVE,
		passive = PSV_TRIGGERDAMAGE,
		desc = "All Wind type moves have a\x82 25%\x80 chance\nto inflict dizzy.\nTeam gains \x82+20%\x80 technical damage.",
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_TECHNICAL
						dmg = $*120/100
					end
					return dmg
				end,
}

addHook("MobjThinker", function(mo)
	//TESTING TESTING NEW SKILL TESTING
	local btl = server.P_BattleStatus[1]
	--mo.skills = {"trisagion ex", "faultless reinforcement v2"}
	--mo.passiveskills = {"chaos surge"}
	/*if mo.skin == "amy"
		mo.skills = {"me patra alter"}
	end
	if mo.skin == "sonic" and btl.battlestate == BS_START
		inflictStatus(mo, COND_BURN)
	end*/
	--btl.emeraldpow = 300
end, MT_PFIGHTER)

//item drop display in stage 4
local itemtable = {}
local itemx = {}
local itemfade = {}
local itemtimer = {}
local itemamount = {}
local fades = {V_60TRANS, V_30TRANS, V_SNAPTOLEFT}

rawset(_G, "displayItemStart", function(item, amount)

	itemtable[#itemtable+1] = item
	itemx[#itemx+1] = -5
	itemfade[#itemfade+1] = V_80TRANS
	itemtimer[#itemtimer+1] = 1
	itemamount[#itemamount+1] = amount

	S_StartSound(nil, sfx_drop)
end)

rawset(_G, "displayItemHandler", function(v)

	for i = 1, #itemtable
		if itemtable[i]
			local item = itemtable[i]
			local fade = itemfade[i]
			local amount = itemamount[i]
			
			if itemtimer[i] == 1
				itemx[i] = itemx[i] + 10
			elseif itemtimer[i] == 2
				itemx[i] = itemx[i] + 8
			elseif itemtimer[i] == 3
				itemx[i] = itemx[i] + 6
			elseif itemtimer[i] == 4
				itemx[i] = itemx[i] + 4
			elseif itemtimer[i] == 5
				itemx[i] = itemx[i] + 2
			end
			
			//fade
			if itemtimer[i] < 50
				fade = fades[min(itemtimer[i], #fades)]
			end
			
			if itemtimer[i] == 50
				fade = V_20TRANS
			elseif itemtimer[i] == 51
				fade = V_40TRANS
			elseif itemtimer[i] == 52
				fade = V_60TRANS
			elseif itemtimer[i] == 53
				fade = V_80TRANS
			end
			
			//text
			if itemDefs[item].rarity >= 5
				V_drawString(v, itemx[i], i*10, itemDefs[item].name + " x" + amount, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT|fade, nil, 73, 31)
			else
				V_drawString(v, itemx[i], i*10, itemDefs[item].name + " x" + amount, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT|fade, nil, 0, 31)
			end
			
			//draw element icon
			local atk = itemDefs[item].attack
			local skill = attackDefs[atk]
			v.drawScaled((itemx[i]-15)*FRACUNIT, (i*10)*FRACUNIT, FRACUNIT/4, v.cachePatch("AT2_"..atk_constant_2_num[skill.type]), V_SNAPTOTOP|V_SNAPTOLEFT|fade)
			
			itemtimer[i] = itemtimer[i] + 1
			
			
			if itemtimer[i] == 55 //begone
				table.remove(itemtable, i)
				table.remove(itemx, i)
				table.remove(itemfade, i)
				table.remove(itemtimer, i)
				table.remove(itemamount, i)
			end
		end
	end
end)

hud.add(displayItemHandler)

local agauge = 0
local bgauge = 0
rawset(_G, "tipsCornerContinue", function(v)
	if tipsfinished
		//faded background, can't get drawfill to be transparent so i have to put a black graphic in here :(
		local bruh = v.cachePatch("H_BRUH")
		v.drawScaled(0, 0, FRACUNIT*5, bruh, V_SNAPTOTOP|V_SNAPTOLEFT|V_50TRANS)
		V_drawString(v, 160, 70, "CONTINUE?", "FPIMP", V_SNAPTOBOTTOM, "center", 0, nil)
		local acolor = "\x82"
		local bcolor = "\x82"
		if agauge > 0
			bcolor = "\x8F"
			v.drawFill(61, 120, agauge*2, 2, 73|V_SNAPTOBOTTOM)
		end
		if bgauge > 0
			acolor = "\x8F"
			v.drawFill(177, 120, bgauge*2, 2, 73|V_SNAPTOBOTTOM)
		end
		if server.P_BattleStatus.lives < 1
			acolor = "\x8F"
		end
		--V_drawString(v, 160, 160, "\x82".."Continues: 3", "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
		V_drawString(v, 160, 170, "\x82".."Continues: "..server.P_BattleStatus.lives, "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
		V_drawString(v, 100, 110, acolor.."Press A to retry", "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
		V_drawString(v, 220, 110, bcolor.."Press B to give up", "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
		
	end
end)

/*addHook("ThinkFrame", function(mo)
	if not tipsfinished return end
	if server.plentities[pn][1] and server.plentities[pn][1].valid
		local inputs = server.plentities[pn][1].control.mo.P_inputs
			
		if inputs[BT_JUMP] == 1
		and server.P_BattleStatus.lives
		and server.gamemode ~= GM_VOIDRUN
			DNG_loadNewMap(diedstage+6)

			-- take my life away
			server.P_BattleStatus.lives = $-1

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
		end
	end
end)*/

addHook("MobjThinker", function(mo)
	if not tipsfinished
		agauge = 0
		bgauge = 0
		return
	end
	S_StopMusic()
	if mo.player == server.playerlist[1][1]
		if bgauge < 1 and server.P_BattleStatus.lives > 0
			if mo.player.cmd.buttons & BT_JUMP
				agauge = $+1
			else
				if agauge > 0
					agauge = $-1
				end
			end
		end
		if agauge < 1
			if mo.player.cmd.buttons & BT_USE
				bgauge = $+1
			else
				if bgauge > 0
					bgauge = $-1
				end
			end
		end
	end
	if agauge == 43
		agauge = 0
		-- take my life away
		server.P_BattleStatus.lives = $-1
		
		for j = 1, server.P_netstat.teamlen do
			if not server.plentities[1][j] continue end
			local mo = server.plentities[1][j]
			mo.hp = mo.maxhp
			mo.sp = mo.maxsp
		end
		DNG_loadNewMap(diedstage+6)
		tipsfinished = false
	end
	if bgauge == 43
		bgauge = 0
		-- terminate the game
		for i = 1, 4
			server.P_BattleStatus[i].running = false
			server.P_BattleStatus[i].battlestate = 0
		end
		server.P_BattleStatus.kill = true
		G_SetCustomExitVars(1, 1)
		G_ExitLevel()
		dprint("Terminated session")
		tipsfinished = false
	end
end, MT_PLAYER)

addHook("MapLoad", function()
	itemtable = {}
	itemx = {}
	itemfade = {}
	itemtimer = {}
	tipsfinished = false
end)


hud.add(tipsCornerContinue)

/*rawset(_G, "resetHyperStats", function(mo)
	if mo.status_condition == COND_HYPER
		local stats = {"strength", "magic", "endurance", "agility", "luck"}
		for i = 1, #stats do
			mo[stats[i]] = $-10
		end
	end
	if gamemap == 10
		local stats = {"strength", "magic", "endurance", "agility", "luck"}
		for i = 1, #stats do
			mo[stats[i]] = $-15
		end
	end
end)*/