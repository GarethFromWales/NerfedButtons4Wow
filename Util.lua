--[[ This file contains any Lua utility functions. ]]


if NB == nil then NB = {} end


-----------------------------------------
-- Util: Output to chat
--
function NB.error(msg)
    if (DEFAULT_CHAT_FRAME) then
        DEFAULT_CHAT_FRAME:AddMessage("NB: "..msg, 1, 0, 0);
    end
end



-----------------------------------------
-- Util: Checks if a character is in a string
--
function NB.isCharInList(char, list)
    for _, value in ipairs(list) do
        if value == char then
            return true
        end
    end
    return false
end


-----------------------------------------
-- Util: Check if a function is defined
--
function NB.isFunctionDefined(func)
    return type(func) == "function"
end


-----------------------------------------
-- Util: Output to chat
--
function NB.print(msg)
    if (DEFAULT_CHAT_FRAME) then
        DEFAULT_CHAT_FRAME:AddMessage("NB: "..msg);
    end
end


-----------------------------------------
-- Util: Returns the number of people in a riad or party
-- adds an extra one to party count as it doesn't 
-- include the player.
--
function NB.getMemberCount()
	local count = 0
	if UnitInRaid("player") then
		for i=1, 40 do
			if UnitExists("raid"..i) then count=count+1 end
		end	
	elseif UnitInParty("player") then
		count=count+1 -- include the player in the party
		for i=1, 5 do
			if UnitExists("party"..i) then count=count+1 end
		end
	end
	return count
end



















