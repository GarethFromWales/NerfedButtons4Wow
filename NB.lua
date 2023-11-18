local NerfedButtonsVersion = "1.0.0-Vanilla";
local NerfedButtonsAuthor  = "NerfedWar; Vanilla adaptation of NerfedButtons.";

local NerfedButtonsLoaded = false;

local debug = true

if NB == nil then NB = {} end



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
	-- specials are custom actions that can be found
	-- in Actions.lua
	local action_type = NB.get_action_type(action_name)

	-- validate the action exists
	-- check spell or item exists or if a special then the 
	-- fucntion exists
	if(action_type == "special") then
		action_name = NB.get_APISpecial(action_name)
		if NB.isFunctionDefined("NB.action_"..action_name) then
			NB.error("Internal error, function NB.action_"..action_name.." is not defined")
			return
		end
	end
	if(action_type == "spell") then
		-- TODO: does it exist? Here we look up spell names from their short form
	end
	if(action_type == "item") then
		-- TODO: does it exist? Here we look up item names from their short form
	end	

	-- Validate action target from list
	if NB.get_APIActionTarget(action_target ~= "") then 
		action_target = NB.get_APIActionTarget(action_target)
	else
		NB.error("Error parsing NefedButton action target, execution terminated.")
		return
	end

	-- if we dont have an action target then use current if there is one
	-- otherwise use player
	local onSelf = true
	if action_target and action_target ~= "player" then
		if UnitExists("target") then
			onSelf = false
		end
	end

	-- Validate checks from list
	local checks = NB.get_checks(parts)
	if not checks then
		NB.error("Error parsing NefedButton checks, execution terminated.")
		return
	end
	


	-- if we have a dynamic action target like group, raid, friendly, hostile
	-- then we need to perform the checks for each and break out of the loop
	-- as soon as we find someone who passes all the checks.
	local loops = 1
	local count = 0
	-- if action_target == "friendly" then loops = 10 end
	-- if action_target == "hostile" then loops = 10 end
	if action_target == "party" then loops = NB.getMemberCount() end
	if action_target == "raid" then loops = NB.getMemberCount() end

	-- loop through targets
	for i = 1, loops do

		-- if we're in a party we need to add the player
		if i == loops then action_target = "player" end

		-- Run all the checks. If they all pass then
		-- do the action!
		if NB.do_checks(checks, action_target, i) then
			-- all the check have passed!!! Do something!!!

			-- target the right target if we had a dynamic
			if loops > 1 then TargetUnit(action_target..i) end

			-- deal with special actions like targetting and talking
			if(action_type == "special") then
				if action_target then
					if not NB["action_"..action_name](action_target) then return false end
				else 
					if not NB["action_"..action_name]() then return false end
				end
			end

			-- deal with spells
			if(action_type == "spell") then CastSpellByName(action_name, onSelf) end

			-- deal with items
			if(action_type == "item") then UseItemByName(action_name, onSelf) end

			-- go back to original target
			TargetLastTarget();
		else
			-- all checks failed, do nothing
		end
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
		-- no target so extract the action differently and default to target as the
		-- target
		_, _, action, _ = string.find(actionString, "(%b[])")
		action = string.sub(action, 2, -2)
		action_target = "target"
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
	for k,v in pairs(NB.SPECIALACTIONS) do

		if k == action_name then
			do return "special" end
			break
		end
	end

	-- TODO: add item and special support
	return "spell"

end

-----------------------------------------
-- Returns the API correct action target
--
function NB.get_APIActionTarget(target)

	local api_target = ""
	for k,v in pairs(NB.VALIDACTIONTARGETS) do if k == target then api_target = v break end end
	return api_target

end


-----------------------------------------
-- Returns the WoW API correct check target
--
function NB.get_APICheckTarget(target)

	local api_target = ""
	for k,v in pairs(NB.VALIDCHECKTARGETS) do if k == target then api_target = v break end end
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
function NB.get_APIClass(class)

	local api_class = ""
	for k,v in pairs(NB.VALIDCLASSES) do if k == class then api_class = v break end end
	return api_class

end


-----------------------------------------
-- Returns the NB API correct special
--
function NB.get_APISpecial(special)

	local api_special = ""
	for k,v in pairs(NB.SPECIALACTIONS) do if k == special then api_special = v break end end
	return api_special

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
		if NB.get_APICheckTarget(check_target ~= "") then 
			check_target = NB.get_APICheckTarget(check_target) -- get WoW API correct form of target name
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
function NB.do_checks(checks, action_target, loop_iteration)

	for i, k in checks do
		local ctype = k[1]
		local ctarget = k[2]
		local cvalue = k[3]

		if ctarget == "dynamic" then
			ctarget = action_target..loop_iteration;
			if action_target == "player" then ctarget="player" end
		end
		
		if not UnitExists(ctarget) then return false end


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


