local NerfedButtonsVersion = "1.0.0-Vanilla";
local NerfedButtonsAuthor  = "NerfedWar; Vanilla adaptation of NerfedButtons.";

local NerfedButtonsLoaded = false;

local debug = true

if NB == nil then NB = {} end


-- list of valid custom actions, long and short forms
-- does not include items and spells
NB.VALIDACTIONS = {
	["c"] = "cancel",
	["cancel"] = "cancel",
	["t"] = "target",
	["target"] = "target",
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
NB.VALIDTARGETS = {
	["p"] = "player",
	["player"] = "player",
	["t"] = "target",
	["target"] = "target",
	["g"] = "group",
	["group"] = "group",
	["r"] = "raid",
	["raid"] = "raid"
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

-----------------------------------------
-- React to events
--
function NerfedButtons_EventHandler()

	if (event=="VARIABLES_LOADED" ) then NerfedButtons_OnLoad(); end

end
	
-----------------------------------------
-- Initialises NerfedButtons
--
function NerfedButtons_OnLoad()
	

	-- Register the slash handles
	SlashCmdList["NERFEDBUTTONS"] = NB.slash_handler
	SLASH_NERFEDBUTTONS1 = "/nb";	

	NB.print("NerfedButtons Loaded. Usage information at:");
	NB.print("https://github.com/GarethFromWales/NerfedButtons4Wow")
	NerfedButtonsLoaded = true;
end

-----------------------------------------
-- Parse the /nb command
--
function NB.slash_handler(msg)

	-- split the arguments by [] brackets
	local parts = {}
	local split = string.gsub(msg, "(%b[])", function (part) table.insert(parts, part) end)

	-- get the action name and action_target
	local action_name, action_target = NB.get_action(parts)

	-- do we have an item, spell or special?
	local action_type = NB.get_action_type(action_name)

	-- get the WoW API valid target strings
	if NB.get_APITarget(action_target ~= "") then 
		action_target = NB.get_APITarget(action_target)
	else
		NB.error("Error parsing NefedButton target, execution terminated.")
		return
	end

	-- get the checks
	local checks = NB.get_checks(parts)
	if not checks then
		NB.error("Error parsing NefedButton check, execution terminated.")
		return
	end

	-- loop through the checks and return true if they all pass
	if NB.do_checks(checks) then
		-- checks have passed! Perform the action

		if(action_type == "special") then 
			if NB.isFunctionDefined("NB.action_"..action_name) then
				NB.error("Internal error, function NB.action_"..action_name.." is not defined")
				return
			end
			if not NB["action_"..action_name](action_target) then return false end
		end
		if(action_type == "spell") then CastSpellByName(action_name, action_target) end
		if(action_type == "item") then UseItemByName(action_name, action_target) end
	else
		-- all checks failed, do nothing
	end
end

-----------------------------------------
-- Splits the parts of the action into
-- action name and target.
--
function NB.get_action(parts)

	local actionString = parts[1] -- first element
	local action, action_target = nil, nil

	-- check if we have a target as well as an action
	if  string.find(actionString, "(%b[:)") ~= nil then
		_, _, action, _ = string.find(actionString, "(%b[:)")
		action = string.sub(action, 2, -2)
		_, _, action_target, _ = string.find(actionString, "(%b:])")
		action_target = string.sub(action_target, 2, -2)
	else
		-- no target so extract the action differently and default to player as the
		-- target
		_, _, action, _ = string.find(actionString, "(%b[])")
		action = string.sub(action, 2, -2)
		action_target = "player"
	end

	return action, action_target

end


-----------------------------------------
-- Returns the type of action:
-- spell, item, special
--
function NB.get_action_type(action_name)

	local api_action = ""

	-- deal with special actions
	for k,v in pairs(NB.VALIDACTIONS) do 

		if k == action_name then 
			do return "special" end 
			break 
		end
	end

	-- TODO: add item and special support
	return "spell"

end

-----------------------------------------
-- Returns the WoW API correct target
--
function NB.get_APITarget(target)

	local api_target = ""
	for k,v in pairs(NB.VALIDTARGETS) do if k == target then api_target = v break end end
	return api_target

end


-----------------------------------------
-- Returns the NB API correct check
--
function NB.get_APICheck(check)

	local api_check = ""
	for k,v in pairs(NB.VALIDCHECKS) do if k == check then api_check = v break end end
	return api_check

end


-----------------------------------------
-- Returns the WoW API correct class
--
function NB.get_APIClass(check)

	local api_class = ""
	for k,v in pairs(NB.VALIDCLASSES) do if k == class then api_class = v break end end
	return api_class

end


-----------------------------------------
-- Splits the checks into a table of
-- tables.
--
function NB.get_checks(parts)
	local checkTable = {}
	table.remove(parts, 1) -- remove the action/action_target
	for i, k in parts do
		local _, _, check_type, _ = string.find(k, "(%b[:)")

		-- extract the type of check to be performed and
		-- expand it to the full string version we can use to call
		-- the check function in Checks.lua
		check_type = string.sub(check_type, 2, -2)
		if NB.get_APICheck(check_type ~= "") then 
			check_type = NB.get_APICheck(check_type) -- get NB API correct form of check name
		else
			NB.error("Error parsing check, execution terminated. \""..check_type.."\" is not a valid check type.")
			return false
		end				

		-- extract the target of the check to be performed and
		-- expand it to the full string version the WoW API
		-- understands.
		local _, _, check_target, _ = string.find(k, "(%b::)")
		check_target = string.sub(check_target, 2, -2)	
		if NB.get_APITarget(check_target ~= "") then 
			check_target = NB.get_APITarget(check_target) -- get WoW API correct form of target name
		else
			NB.error("Error parsing check, execution terminated. \""..check_target.."\" is not a valid check target.")
			return false
		end		

		-- Get the value to test in the check
		local _, _, check_value, _ = string.find(k, "(%b:])")
		check_value = string.sub(check_value, 2, -2)
		if not string.find(check_value, "^[<>=!]?[%w]+") then
			NB.error("Error parsing check, execution terminated. \""..check_value.."\" is not a valid check value.")
			return false
		end
		
		table.insert(checkTable, {check_type, check_target, check_value})
	end
	return checkTable
end

-----------------------------------------
-- Performs each check in the table
-- and if all pass returns true, 
-- else false
function NB.do_checks(checks)
	for i, k in checks do
		local ctype = k[1]
		local ctarget = k[2]
		local cvalue = k[3]

		-- check the check function actually exists
		if NB.isFunctionDefined("NB.check_"..ctype) then
			NB.error("Internal error, function NB.check_"..ctype.." is not defined")
			return false
		end

		-- call the check function and return false if it fails
		if not NB["check_"..ctype](ctarget, cvalue) then return false end
	end
	return true
end


