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
-- Util: Finds a spell by id and rank
--
function NB.FindSpell(spell, rank)
	local i = 1;
	local booktype = { "spell", "pet", };
	local s,r;
	local ys, yr;
	for k, book in booktype do
		while spell do
		s, r = GetSpellName(i,book);
		if ( not s ) then
			i = 1;
			break;
		end
		if ( string.lower(s) == string.lower(spell)) then ys=true; end
		if ( (r == rank) or (r and rank and string.lower(r) == string.lower(rank))) then yr=true; end
		if ( rank=='' and ys and (not GetSpellName(i+1, book) or string.lower(GetSpellName(i+1, book)) ~= string.lower(spell) )) then
			yr = true; -- use highest spell rank if omitted
		end
		if ( ys and yr ) then
			return i,book;
		end
		i=i+1;
		ys = nil;
		yr = nil;
		end
	end
	return;
end


-----------------------------------------
-- Util: Finds a spell by name
--
function NB.FindSpellByName(spell)
	local s = gsub(spell, "%s*(.*)%s*%(.*","%1");
	local r="";
	local num = tonumber(gsub( spell, "%D*(%d+)%D*", "%1"),10);
	if ( string.find(spell, "%(%s*[Rr]acial")) then
		r = "racial"
	elseif ( string.find(spell, "%(%s*[Ss]ummon")) then
		r = "summon"
	elseif ( string.find(spell, "%(%s*[Aa]pprentice")) then
		r = "apprentice"
	elseif ( string.find(spell, "%(%s*[Jj]ourneyman")) then
		r = "journeyman"
	elseif ( string.find(spell, "%(%s*[Ee]xpert")) then
		r = "expert"
	elseif ( string.find(spell, "%(%s*[Aa]rtisan")) then
		r = "artisan"
	elseif ( string.find(spell, "%(%s*[Mm]aster")) then
		r = "master"
	elseif ( string.find(spell, "%(%s*[Mm]inor")) then
		s=s.."(Minor)";
	elseif ( string.find(spell, "%(%s*[Ll]esser")) then
		s=s.."(Lesser)";
	elseif ( string.find(spell, "%(%s*[Gg]reaterr")) then
		s=s.."(Greater)";
	elseif ( string.find(spell, "%(%s*[Ff]eral")) then
		s=s.."(Feral)";
	end
	if ( string.find(spell, "[Rr]ank%s*%d+") and num and num > 0) then
		r = gsub(spell, ".*%(.*[Rr]ank%s*(%d+).*", "Rank "..num);
	end
	return NB.FindSpell(s,r);
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
-- Util: Checks if a spell is on cooldown
--
function NB.SpellReady(spell)
    local i,a = 0, nil
    while a~=spell do
        i=i+1
        a=GetSpellName(i,"spell")
    end 
    if GetSpellCooldown(i,"spell") == 0 then
        return true
    end
end



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


-----------------------------------------
-- Util: Populates all the spells on
-- the player into a cache
function NB.populateSpellCache() 
	-- populate spells
	local i = 1
	while true do
	   local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
	   
	   if not spellName then do break end end

	   NB.putSpellIntoCache(spellName, "spell") 
	   
	   --DEFAULT_CHAT_FRAME:AddMessage( spellName .. '(' .. spellRank .. ')' )
	   
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
	   local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
	   
	   if not spellName then do break end end

	   NB.putItemIntoCache(spellName, "item") 
	   
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

	if wcount > 1 then
		abbrev = gsub(spellOrItemName, "(%a)%S*%s*", "%1")
	else
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













