
local NerfedButtonsVersion = "1.0.0-Vanilla";
local NerfedButtonsAuthor  = "NerfedWar; Vanilla adaptation of NerfedButtons.";

local debug = true

if NB == nil then NB = {} end
NB.cooldowns = {} -- global to hold fake cooldowns


NB.NerfedButtonsLoaded = false;


-----------------------------------------
-- React to events
--
function NerfedButtons_EventHandler()

	if (event=="VARIABLES_LOADED" ) then NerfedButtons_OnAddonLoaded(); end

end

	
-----------------------------------------
-- Initialises NerfedButtons
--
function NerfedButtons_OnAddonLoaded()

	-- Register the slash handles
	SlashCmdList["NERFEDBUTTONS"] = NB.slash_handler
	SLASH_NERFEDBUTTONS1 = "/nb";	

	NB.print("NerfedButtons Loaded. Usage information at:");
	NB.print("https://github.com/GarethFromWales/NerfedButtons4Wow")

	-- populate the spell and item cache
	NB.populateSpellCache() 
	--NB.populateItemCache() 

end


-----------------------------------------
-- Parse the /nb command
--
function NB.slash_handler(msg)

	-- parse the paramters to /nb
	local parts = {}
	local split = string.gsub(msg, "(%b[])", function (part) table.insert(parts, part) end) -- split the arguments by [] brackets

	local action_name, action_target = NB.split_action(parts) -- get the action name and action_target

	local action_type -- do we have an item, spell or special?
	action_name, action_type, action_target = NB.validate_action(action_name, action_target) -- expand the action to its full name
	if action_name == "" then -- deal with not finding a matching action
		NB.error("Error parsing NefedButton, \""..action_name.."\" is not a valid action.")
		return
	end

	-- Validate checks from list
	local checks = NB.validate_checks(parts)
	if not checks then
		NB.error("Error parsing NefedButton checks, execution terminated.")
		return
	end

	-- if we have a dynamic action target like group, raid, friendly, hostile
	-- then we need to perform the checks for each and break out of the loop
	-- as soon as we find someone who passes all the checks.
	local loops = 1
	-- if action_target == "friendly" then loops = 10 end
	-- if action_target == "hostile" then loops = 10 end
	if action_target == "party" then loops = NB.getMemberCount() end
	if action_target == "raid" then loops = NB.getMemberCount() end

	-- loop through targets
	for i = 1, loops do

		-- if we're in a party we need to add the player as the last target of the loop
		if loops > 1 and i == loops then action_target = "player" end

		-- Run all the checks. If they all pass then
		-- do the action!
		if NB.do_checks(checks, action_target, i) then
			-- all the check have passed!!! Do something!!!

			-- target the right target if we had a dynamic
			if (action_target=="raid" or action_target == "party") and loops > 1 then TargetUnit(action_target..i) end

			-- deal with special actions like targetting and talking
			if(action_type == "special") then
				if action_target then
					if not NB["action_"..action_name](action_target) then return false end
				else 
					if not NB["action_"..action_name]() then return false end
				end
			end

			-- deal with spell actions
			if(action_type == "spell") then 
				if CastSpellByName(action_name, action_target == "player") then
					-- store the time the spell/item was cast
							
				end
				NB.cooldowns[action_name] = time()
			end

			-- deal with item actions
			if(action_type == "item") then 
				if UseItemByName(action_name, action_target == "player")  then
					-- store the time the spell/item was cast
					NB.cooldowns[action_name] = time()
				end
			end

			-- go back to original target
			if (action_target=="raid" or action_target == "party") and loops > 1 then TargetLastTarget() end
			
		else
			-- all checks failed, do nothing
		end
	end

end


-----------------------------------------
-- Splits the parts of the action into
-- action name and target.
--
function NB.split_action(parts)

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
-- Returns the WoW API correct check target
--
function NB.validate_check_target(target)

	local api_target = ""
	for k,v in pairs(NB.VALIDCHECKTARGETS) do if k == target then api_target = v break end end
	return api_target

end


-----------------------------------------
-- Returns the NB API correct check
--
function NB.validate_check_name(check)

	local api_check = ""
	for k,v in pairs(NB.VALIDCHECKS) do if k == check then api_check = v break end end
	return api_check

end


-----------------------------------------
-- Returns the WoW API correct class
--
function NB.validate_class_name(class)

	local api_class = ""
	for k,v in pairs(NB.VALIDCLASSES) do if k == class then api_class = v break end end
	return api_class

end


-----------------------------------------
-- Returns the NB API correct special
--
function NB.validate_special_name(special)

	local api_special = ""
	for k,v in pairs(NB.SPECIALACTIONS) do if k == special then api_special = v break end end
	return api_special

end


-----------------------------------------
-- Splits the checks into a table of
-- tables.
--
function NB.validate_checks(parts)
	local checkTable = {}
	table.remove(parts, 1) -- remove the action/action_target
	for i, k in parts do
		local _, _, check_type, _ = string.find(k, "(%b[:)")

		-- extract the type of check to be performed and
		-- expand it to the full string version we can use to call
		-- the check function in Checks.lua
		check_type = string.sub(check_type, 2, -2)
		if NB.validate_check_name(check_type ~= "") then 
			check_type = NB.validate_check_name(check_type) -- get NB API correct form of check name
		else
			NB.error("Error parsing check, execution terminated. \""..check_type.."\" is not a valid check type.")
			return false
		end				

		-- extract the target of the check to be performed and
		-- expand it to the full string version the WoW API
		-- understands.
		local _, _, check_target, _ = string.find(k, "(%b::)")
		check_target = string.sub(check_target, 2, -2)	
		if NB.validate_check_target(check_target ~= "") then 
			check_target = NB.validate_check_target(check_target) -- get WoW API correct form of target name
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
		return NB["check_"..ctype](ctarget, cvalue)

	end

	return true

end


-----------------------------------------
-- Returns the type of action:
-- spell, item, special
--
function NB.validate_action(action_name, action_target)

	action_name = string.lower(action_name)
	action_target = string.lower(action_target)

	-- just like action names, the target can be abbreviated, so we look it up to get the full version
	for k,v in pairs(NB.VALIDACTIONTARGETS) do if k == action_target then action_target = v break end end
	-- if we dont have an action target then use current if there is one
	-- otherwise use player
	if action_target == "" then -- if we have a blank target then set to target if we have one, or player if not
		if UnitExists("target") then action_target = "target" else action_target = "player" end
	end

	for k,v in pairs(NB.SPECIALACTIONS) do 	-- deal with special actions

		if k == action_name then
			do return v, "special", action_target end
			break
		end
	end

	if NB.SPELLCACHE[action_name] then  -- deal with spell actions
		return NB.SPELLCACHE[action_name], "spell", action_target
	end

	if NB.ITEMCACHE[action_name] then -- deal with item actions
		return NB.ITEMCACHE[action_name], "item", action_target
	end	

	return "", "", ""

end


-----------------------------------------
-- Util: Populates all the spells on
-- the player into a cache
function NB.populateSpellCache()

	-- populate spells
	local i = 1
	while true do
	   local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
	   
	   if not spellName then do break end end

		-- hack to deal with (Feral) spells that require a rank or () to cast
		local s = gsub(spellName, "%s*(.*)%s*%(.*","%1")
		if ( string.find(spellName, "%(%s*[Ff]eral")) then
		s=s.."(Feral)()";
		end

	   NB.putSpellIntoCache(s) 
	   
	   i = i + 1
	end
end


-----------------------------------------
-- Util: Populates all the items on
-- the player into a cache
function NB.populateItemCache() 
	-- populate spells
	local i = 1
	while true do
	   local itemName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
	   
	   if not itemName then do break end end

	   NB.putItemIntoCache(itemName) 
	   
	   i = i + 1
	end
end


-----------------------------------------
-- Util: Populates a spell database
-- with all the spells and items on the player
--
-- we put 2 entries in for each spell/item
-- The full name, and the abbreviated version
-- The abbrev version is the first letter of each
-- word if we have 2 or more words, or the first 3
-- letters of the spell if only 1 word.
function NB.putSpellIntoCache(spellOrItemName) 

	-- we treat everything in lowercase
	spellOrItemName = string.lower(spellOrItemName)

	local _, wcount = gsub(spellOrItemName, "%S+", "")
	local abbrev = ""

	if wcount > 1 then -- more than one word, remove backets and take first letter of each
		
		abbrev = gsub(spellOrItemName,"%(", "") -- replace ( with empty string
		abbrev = gsub(abbrev,"%)", "") -- replace ) with empty string		
		abbrev = gsub(abbrev, "(%a)%S*%s*", "%1")

	else -- just one word, take first 4 characters
		abbrev = gsub(spellOrItemName, "(%a)(%a)(%a).*", "%1%2%3")
	end

	NB.SPELLCACHE[spellOrItemName] =  spellOrItemName 
	NB.SPELLCACHE[abbrev] = spellOrItemName
end


-----------------------------------------
-- Util: Populates a item database
--
function NB.putItemIntoCache(spellOrItemName) 

	-- we treat everything in lowercase
	spellOrItemName = string.lower(spellOrItemName)

	local _, wcount = gsub(spellOrItemName, "%S+", "")
	local abbrev = ""

	if wcount > 1 then
		abbrev = gsub(spellOrItemName, "(%a)%S*%s*", "%1")
	else
		abbrev = gsub(spellOrItemName, "(%a)(%a)(%a).*", "%1%2%3")
	end

	NB.SPELLCACHE[spellOrItemName] =  spellOrItemName 
	NB.SPELLCACHE[abbrev] = spellOrItemName
end


-----------------------------------------
-- Util: Returns the full name of a spell form the cache
--
function NB.getSpellFromCache(spell) 

	spell = string.lower(spell)
	if NB.SPELLCACHE[spell] then
		return NB.SPELLCACHE[spell]
    else
        NB.error("Could not find spell: "..spell)
        return false
    end

end


-----------------------------------------
-- Util: Returns the full name of a item form the cache
--
function NB.getItemFromCache(item) 

	if NB.ITEMCACHE[item] then
		return NB.ITEMCACHE[item]
    else
        NB.error("Could not find item: "..item)
        return false
    end

end





