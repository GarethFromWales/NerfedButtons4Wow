local NerfedButtonsVersion = "1.0.0-Vanilla";
local NerfedButtonsAuthor  = "NerfedWar; Vanilla adaptation of NerfedButtons.";

local NerfedButtonsLoaded = false;

local debug = true

if NB == nil then NB = {} end

-- list of valid checks
NB.VALIDCHECKS = {
	"health",
	"power",
	"con",
	"buff"
}

-- list of valid targets
NB.VALIDTARGETS = {
	"player",
	"target",
	"party",
	"raid"
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
	SlashCmdList["NERFEDBUTTONS"] = slash_handler
	SLASH_NERFEDBUTTONS1 = "/nb";	

	NB.print("NerfedButtons Loaded.");
	NerfedButtonsLoaded = true;
end

-----------------------------------------
-- Parse the /nb command
--
function slash_handler(msg)

	-- split the arguments by [] brackets
	local parts = {}
	string.gsub(msg, "(%b[])", function (part)
		  table.insert(parts, part)
	end)

	-- get the action and action_target
	local action, action_target = NB.get_action(parts)

	-- do we have an item, spell or special?
	-- TODO: we assume a spell right now
	local action_type = "spell" -- NB.get_action_type(action)

	-- get the checks
	local checks = NB.get_checks(parts)
	if not checks then
		NB.error("Error parsing NefedButton, execution terminated.")
		return
	end

	-- loop through the checks and return true if they all pass
	if NB.do_checks(checks) then
		-- checks have passed! Perform the action
		CastSpellByName(action, action_target);
	else
		-- all checks failed
	end
end

-----------------------------------------
-- Splits the parts of the action into
-- action name and target.
--
function NB.get_action(parts)

	local actionString = parts[1] -- first element
	local _, _, action, _ = string.find(actionString, "(%b[:)")
	action = string.sub(action, 2, -2)

	local _, _, action_target, _ = string.find(actionString, "(%b:])")
	action_target = string.sub(action_target, 2, -2)

	return action, action_target

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
		check_type = string.sub(check_type, 2, -2)
		local _, _, check_target, _ = string.find(k, "(%b::)")
		check_target = string.sub(check_target, 2, -2)	
		local _, _, check_value, _ = string.find(k, "(%b:])")
		check_value = string.sub(check_value, 2, -2)

		local validated_type_check = false
		for _, value in ipairs(NB.VALIDCHECKS) do
			if value == check_type then
				validated_type_check = true
			end
		end
		local validated_target_check = false
		for _, value in ipairs(NB.VALIDTARGETS) do
			if value == check_target then
				validated_target_check = true
			end
		end
		local validated_value_check = false
		if string.find(check_value, "^[<>=!]?[%w]+") then
			validated_value_check = true
		end

		-- validate the type, target and value
		if not validated_type_check then NB.error("Invalid type in check: [*"..check_type.."*:"..check_target..":"..check_value.."]") return false end
		if not validated_target_check then NB.error("Invalid target in check: ["..check_type..":*"..check_target.."*:"..check_value.."]") return false end
		if not validated_value_check then NB.error("Invalid value in check: ["..check_type..":"..check_target..":*"..check_value.."*]") return false end

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
		local type = k[1]
		local target = k[2]
		local value = k[3]

		--NB.print(type..":"..target..":"..value)

		-- check the check function actually exists
		if NB.isFunctionDefined("NB.check_"..type) then
			NB.error("Internal error, function NB.check_"..type.." is not defined")
			return false
		end

		-- call the check function and return false if it fails
		local test = NB["check_"..type](target, value)
		if not test then return false end
	end
	return true
end


-----------------------------------------
-- Use an item
--
function NB.do_item(itemName, target)
	UseItemByName(itemName, target);
end

-----------------------------------------
-- Cast a spell
--
function NB.do_spell(spellName, target)
	CastSpellByName(spellName, target);
end


-----------------------------------------


