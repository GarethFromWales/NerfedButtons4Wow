if NB == nil then NB = {} end

NB.SPELLCACHE = { }
NB.ITEMCACHE = { }

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
	["cd"] = "cooldown", 	
	["b"] = "buff",
	["buff"] = "buff",
	["d"] = "buff",
	["debuff"] = "buff",
	["com"] = "combat",
	["combat"] = "combat",
	["f"] = "form",
	["form"] = "form",	
	["combo"] = "combo_points",
	["cp"] = "combo_points"		
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

NB.VALIDDRUIDFORMS = {
	["b"] = "bear",
	["bear"] = "bear",
	["Bear Form"] = "bear",
	["Dire Bear Form"] = "bear",
	["a"] = "aquatic",
	["aquatic"] = "aquatic",
	["Aquatic Form"] = "aquatic",	
	["c"] = "cat",	
	["cat"] = "cat",
	["Cat Form"] = "cat",	
	["t"] = "travel",	
	["travel"] = "travel",
	["Travel Form"] = "travel",	
	["m"] = "moonkin",
	["moonkin"] = "moonkin",
	["Moonkin Form"] = "moonkin",	
	["n"] = "humanoid",
	["no"] = "humanoid",
	["none"] = "humanoid",			
	["h"] = "humanoid",
	["humanoid"] = "humanoid"
};


NB.CONDITIONS = {
	["c"] = "curse",
	["curse"] = "curse",
	["p"] = "poison",
	["poison"] = "poison",
	["m"] = "magic",
	["magic"] = "magic",
	["d"] = "disease",
	["disease"] = "disease"
}



