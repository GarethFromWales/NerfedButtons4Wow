if NB == nil then NB = {} end

-- list of valid custom actions, long and short forms
-- does not include items and spells
NB.SPECIALACTIONS = {
	["c"] = "cancel",
	["cancel"] = "cancel",
	["t"] = "target",
	["target"] = "target",
	["te"] = "targetenemy",
	["tep"] = "targetenemyplayer",
	["tf"] = "targetfriend",
	["tl"] = "targetlasttarget",
	["tlt"] = "targetlasttarget",
	["s"] = "stop",
	["stop"] = "stop",
	["sc"] = "stopcast",
	["stopcast"] = "stopcast",
	["sa"] = "stopattack",
	["stopattack"] = "stopattack"
}

-- list of valid checks, long and short forms
NB.VALIDCHECKS = {
	["h"] = "health",
	["health"] = "health",
	["p"] = "power",
	["pow"] = "power",	
	["power"] = "power", 
	["m"] = "mana",	
	["mana"] = "mana", 	
	["c"] = "condition", 
	["con"] = "condition", 
	["condition"] = "condition",
	["b"] = "buff",
	["buff"] = "buff",
	["d"] = "buff",
	["debuff"] = "buff",
	["com"] = "combat",
	["combat"] = "combat"		
}

-- list of valid targets, long and short forms
NB.VALIDACTIONTARGETS = {
	["p"] = "player",
	["player"] = "player",
	["t"] = "target",
	["target"] = "target",
	["g"] = "party",
	["group"] = "party",
	["r"] = "raid",
	["raid"] = "raid"
	--["f"] = "friendly",
	--["friendly"] = "friendly",
	--["h"] = "hostile",
	--["hostile"] = "hostile" 
}


-- list of valid targets, long and short forms
NB.VALIDCHECKTARGETS = {
	["p"] = "player",
	["player"] = "player",
	["t"] = "target",
	["target"] = "target",
	["d"] = "dynamic",
	["dynamic"] = "dynamic"
}

-- list of valid classes, long and short forms
NB.VALIDCLASSES = {
	["war"] = "warrior",
	["warior"] = "warrior",
	["dru"] = "druid",	
	["druid"] = "druid",
	["pal"] = "paladin",
	["paladin"] = "paladin",
	["pri"] = "priest",
	["priest"] = "priest",	
	["hun"] = "hunter",
	["hunter"] = "hunter",	
	["sha"] = "shaman",
	["shaman"] = "shaman",		
	["loc"] = "warlock",
	["warlock"] = "warlock",
	["mag"] = "mage",
	["mage"] = "mage",		
	["rog"] = "rogue",
	["rogue"] = "rogue"			
}