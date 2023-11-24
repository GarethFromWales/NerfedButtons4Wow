
local NerfedButtonsVersion = "1.0.0-Vanilla";
local NerfedButtonsAuthor  = "NerfedWar; Vanilla adaptation of NerfedButtons.";



if NB == nil then NB = {} end
NB.cooldowns = {} -- global to hold fake cooldowns
NB.debugEnabled = true
NB.NerfedButtonsLoaded = false;


-----------------------------------------
-- React to events
--
function NerfedButtons_EventHandler()
	if (event=="VARIABLES_LOADED" ) then NerfedButtons_OnVariablesLoaded(); end
end


-----------------------------------------
-- Outputs loaded and usage message to chat
--
function NerfedButtons_OnVariablesLoaded()

	-- this gets called once per UI reload.

	-- Register the slash handles
	SlashCmdList["NERFEDBUTTONS"] = NB.slash_handler
	SLASH_NERFEDBUTTONS1 = "/nb";	

	NB.print("NerfedButtons Loaded. Usage information at:");
	NB.print("https://github.com/GarethFromWales/NerfedButtons4Wow")

end


--[[
	Parse the /nb command
--]]
function NB.slash_handler(msg)

	-- populate spell and item cache if not populated
	if not NB.getSpellFromCache("Attack") then
		NB.populateSpellCache()
		--NB.populateItemCache() 
	end

	-- extract the ACTION and CONDITIONS from the command-line string
	-- Example: "Flame Shock@target [buff@target!=Flame Shock, health@target>50%]"
	-- Example: "FS@t [b@t!FS,h@t>50%]"
	-- Example: "FS [b@t!FS,h@t>50%]"
	-- Example: "FS [b!FS,h>50%]"
	-- Example: "FS"
	local before_bracket = NB.trim(gsub(msg, "%[.-%]", ""))
	local inside_brackets = NB.trim(gsub(msg, "^.-%[(.-)%].-$", "%1"))

	-- extract the ACTION_NAME and ACTION_TARGET
	-- Example: "Flame Shock@target"
	-- Example: "FS@t"
	local action_name, action_target = "", ""
	action_name = gsub(before_bracket, "@.*$", "") -- "Flame Shock"
	local _, countAt = gsub(before_bracket, "@", "@")
	if countAt > 0 then
		action_target = gsub(before_bracket, "^.*@", "") -- "target"
	else
		action_target = ""
	end

	-- validate what we've got and obtain the type of action.
	-- we stop here if we don't get a propper validated spell/item/special.
	local action_type = "" -- do we have an item, spell or special?=
	action_name, action_type, action_target = NB.extract_and_validate_action(action_name, action_target)
	if action_name == "" or action_type == "" or action_target == "" then
		NB.error("Error parsing NB: "..msg)
		NB.error("Refer to documentation and try again.")
		return
	end

	--[[ 	Where are we at so far?
			action name and target have been parsed correctly and we've determined if the action
			is a spell, item or special. We've also set the target to the player if no target is
			passed as a parameter and the player has notbody targtted. The target is set to target
			if no target is passed and the payer does have something targetted.
			Next up, lets parse the checks... 	]]--

	local checkString = inside_brackets;
	--NB.debug("NB.slash_handler - Check string: "..inside_brackets)
	local checks = {}
	gsub(inside_brackets, '([^,]+)', function(c) c = NB.trim(c) table.insert(checks, c) end)

	-- validate checks from list
	-- returned as table of {name = check_name, target = check_target, operator = checkOperator, value = checkValue }
	checks = NB.extract_and_validate_checks(checks)
	if not checks then
		NB.error("Error parsing NerfedButton checks, execution terminated.")
		return
	end

	--do return end

	-- if we have a dynamic action target like group, raid, friendly, hostile
	-- then we need to perform the checks for each and break out of the loop
	-- as soon as we find someone who passes all the checks.
	local loops = 1
	-- TODO friendly and hostile will cause issues inside do_checks without refactoring
	--if action_target == "friendly" then loops = 10 end -- loop through closest 10 allies
	--if action_target == "hostile" then loops = 10 end -- loop through closest 10 enemies
	if action_target == "party" then loops = NB.getMemberCount() end
	if action_target == "raid" then loops = NB.getMemberCount() end

	-- loop through targets
	for i = 1, loops do

		-- if we're in a party we need to add the player as the last target of the loop
		-- TODO: does this need to be limited to party? and not raid as well?
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
					
				end
				NB.cooldowns[action_name] = time() -- store the time the spell/item was cast
			end

			-- deal with item actions
			if(action_type == "item") then 
				if UseItemByName(action_name, action_target == "player")  then
					
				end
				NB.cooldowns[action_name] = time() -- store the time the spell/item was cast
			end

			-- go back to original target
			if (action_target=="raid" or action_target == "party") and loops > 1 then TargetLastTarget() end
			
		else
			-- all checks failed, do nothing
		end
	end

end


--[[
	Validates and corrects the name and target of and action.
	Returns the name, type and target where to type is
	either: spell, item or special
--]]
function NB.extract_and_validate_action(orig_action_name, orig_action_target)

	if not orig_action_name or orig_action_name == "" then
		NB.error("Invalid empty action, refer to documentation.")
		return "", "", ""
	end

	local action_name = string.lower(orig_action_name)
	local action_target = string.lower(orig_action_target)

	--NB.debug("va 1:"..action_name)
	--NB.debug("va 1:"..action_target)

	-- just like action names, the target can be abbreviated, so we look it up to get the full version
	for k,v in pairs(NB.VALIDACTIONTARGETS) do if k == action_target then action_target = v break end end
	-- if we dont have an action target then use current if there is one
	-- otherwise use player
	if action_target == "" then -- if we have a blank target then set to target if we have one, or player if not
		if UnitExists("target") then action_target = "target" else action_target = "player" end
	end
	if not action_target or action_target == "" then
		NB.error("Invalid action target, refer to documentation.")
		return "", "", ""
	end

	--NB.debug("va 2:"..action_name)
	--NB.debug("va 2:"..action_target)	

	-- local action_rank = gsub(action_name, "%D+", "")

	for k,v in pairs(NB.SPECIALACTIONS) do 	-- deal with special actions
		if k == action_name then
			action_name = v
			local action_type = "special"
			--NB.debug("va 3.1:"..action_name)
			--NB.debug("va 3.1:"..action_type)
			--NB.debug("va 3.1:"..action_target)
			do return action_name, "special", action_target end
			break
		end
	end	

	if NB.SPELLCACHE[action_name] then  -- deal with spell actions
		action_name = NB.SPELLCACHE[action_name]
		local action_type = "spell"
		--NB.debug("va 3.2:"..action_name)
		--NB.debug("va 3.2:"..action_type)
		--NB.debug("va 3.2:"..action_target)		
		return action_name, "spell", action_target
	end

	if NB.ITEMCACHE[action_name] then -- deal with item actions
		action_name = NB.ITEMCACHE[action_name]
		local action_type = "item"
		--NB.debug("va 3.3:"..action_name)
		--NB.debug("va 3.3:"..action_type)
		--NB.debug("va 3.3:"..action_target)				
		return action_name, "item", action_target
	end	

	-- we have an invalid action_name (e.g. possibly the character doesnt know this spell)
	NB.error("Invalid action passed: "..orig_action_name)
	NB.error("Ensure a valid spell/item/special name is passed that this character knows/posseses.")

	return "", "", ""

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

	return string.lower(action), string.lower(action_target)

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
-- Returns the NP API correct form
--
function NB.validate_form_name(form)

	local api_form = ""
	for k,v in pairs(NB.VALIDDRUIDFORMS) do if k == form then api_form = v break end end
	return string.lower(api_form)

end


-----------------------------------------
-- Returns the NP API correct condition
--
function NB.validate_condition_name(condition)

	local api_condition = ""
	for k,v in pairs(NB.VALIDCONDITIONS) do if k == condition then api_condition = v break end end
	return string.lower(api_condition)

end


-----------------------------------------
-- Returns the WoW API correct class
--
function NB.validate_class_name(class)

	local api_class = ""
	for k,v in pairs(NB.VALIDCLASSES) do if k == class then api_class = v break end end
	return string.lower(api_class)

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
function NB.extract_and_validate_checks(checks)
	local validatedChecks = {}

	for i, v in ipairs(checks) do
		local checkString = v
		--NB.debug("NB.extract_and_validate_checks - Check item: "..checkString)

		-- checks are formatted as: [buff@player=Rejuvenation]
		-- ampersand is optional so split on the following modifiers !=><
		-- this will give us: 
		-- 1. buff@player
		-- 2. =
		-- 3. Rejuvenation

		gsub(checkString, '([^=!<>]+)([=!<>])([^=!<>]*)', function(checkAndTarget, checkOperator, checkValue) 

			-- bit of trimming
			NB.trim(checkAndTarget)
			NB.trim(checkOperator)
			NB.trim(checkValue)

			local check_name, check_target = "", ""
			check_name = gsub(checkAndTarget, "@.*$", "")
			local _, countAt = gsub(checkAndTarget, "@", "@")
			if countAt > 0 then
				check_target = gsub(checkAndTarget, "^.*@", "")
			else
				check_target = ""
			end
			NB.trim(check_name)
			NB.trim(check_target)

			-- validate the name
			if NB.validate_check_name(check_name ~= "") then 
				check_name = NB.validate_check_name(check_name) -- get NB API correct form of check name
			else
				NB.error("Error parsing check, execution terminated. \""..check_name.."\" is not a valid check name.")
				do return false end
			end	
			
			-- validate the target
			if NB.validate_check_target(check_target ~= "") then 
				check_target = NB.validate_check_target(check_target) -- get WoW API correct form of target name
			else
				NB.error("Error parsing check, execution terminated. \""..check_target.."\" is not a valid check target.")
				do return false end
			end		

			-- validate the operator
			local operatorOK = false
			gsub(checkOperator, '([=!<>])', function(c) operatorOK = true end)
			if not operatorOK then 
				NB.error("Error parsing check, invalid operator passed. Refer to documentation.")
				do return false end
			end

			-- validate the value. This we cannot do as it depends on the check. Value validation is done inside the check function.
			--NB.debug("NB.extract_and_validate_checks - Split Check item: "..check_name.."   "..check_target.."   "..checkOperator.."   "..checkValue)
			table.insert(validatedChecks, {name = check_name, target = check_target, operator = checkOperator, value = checkValue })

		end)
	end

	return validatedChecks
end


-----------------------------------------
-- Performs each check in the table
-- and if all pass returns true, 
-- else false
function NB.do_checks(checks, action_target, loop_iteration)

	-- checks is a table of: {name = check_name, target = check_target, operator = checkOperator, value = checkValue }

	for i, k in ipairs(checks) do

		local cname = k["name"]
		local ctarget = k["target"]
		local coperator = k["operator"]
		local cvalue = k["value"]

		-- if we have a smart action target then update the check target
		if ctarget == "smart" then
			ctarget = action_target..loop_iteration;
			if action_target == "player" then ctarget="player" end
		end
		
		-- we may end up we not target, if so, fail the check
		if not UnitExists(ctarget) then return false end

		-- check the check function actually exists
		if NB.isFunctionDefined("NB.check_"..cname) then
			NB.error("Internal error, function NB.check_"..cname.." is not defined")
			return false
		end

		-- call the check function and return false if it fails

		local checkPass =  NB["check_"..cname](ctarget, coperator, cvalue)

		if checkPass then 
			--NB.print("Check: ["..cname..":"..ctarget..":"..coperator..":"..cvalue.."] PASSED")
		else
			--NB.print("Check: ["..cname..":"..ctarget..":"..coperator..":"..cvalue.."] FAILED")
			return false -- a check has failed, no need to continur checking the other checks
		end
	end

	return true

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
-- word if we have 2 or more words, or the first 4
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
		abbrev = gsub(spellOrItemName, "(%a)(%a)(%a)(%a).*", "%1%2%3%4")
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

	if not spell then
		NB.error("Internal error, no spell passed to NB.getSpellFromCache(spell).")
        return false
	end

	spell = string.lower(spell)
	if NB.SPELLCACHE[spell] then
		return NB.SPELLCACHE[spell]
    else
        if spell ~= "Attack " then
			NB.error("Could not find spell: "..spell) -- we use attack as a check to init the cache
		end
        return false
    end

end


-----------------------------------------
-- Util: Returns the full name of a item form the cache
--
function NB.getItemFromCache(item)
	if not item then
		NB.error("Internal error, no item passed to NB.getItemFromCache(item).")
        return false
	end

	item = string.lower(item)	
	if NB.ITEMCACHE[item] then
		return NB.ITEMCACHE[item]
    else
        NB.error("Could not find item: "..item)
        return false
    end

end





