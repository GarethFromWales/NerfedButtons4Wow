function NB.check_health(unit, healthTest)

    -- get health % of unit
    local actualHealth=100*UnitHealth(unit)/UnitHealthMax(unit)

    -- get test modifier > < =
    local modifier = string.sub(healthTest, 1, 1)
    local charList = {'<', '>', '='}
    if not NB.isCharInList(modifier, charList) then
        modifier = "="
    end
    local healthTest = string.sub(healthTest, 2)
    
    if modifier == "=" then
        if tonumber(actualHealth) == tonumber(healthTest) then
            return true
        end
    elseif modifier == "<" then
        if tonumber(actualHealth) < tonumber(healthTest) then
            return true
        end
    elseif modifier == ">" then
        if tonumber(actualHealth) > tonumber(healthTest) then
            return true
        end
    end
    
    return false

end


function NB.check_buff(unit, buffName)
    if not buffName or not unit then
        return false;
    end

    -- get test modifier !
    local modifier = string.sub(buffName, 1, 1)
    local charList = {'!'}
    if not NB.isCharInList(modifier, charList) then
        modifier = ""
    else
        buffName = string.sub(buffName, 2)
    end    
    
    -- look for buff
    local gotbuff = false
    local text = getglobal(NBTooltip:GetName().."TextLeft1");
	for i=1, 32 do
		NBTooltip:SetOwner(UIParent, "ANCHOR_NONE");
		NBTooltip:SetUnitBuff(unit, i);
		name = text:GetText();
		NBTooltip:Hide();
        buffName = string.gsub(buffName, "_", " ");
		if ( name and string.find(name, buffName) ) then
			gotbuff =  true;
		end
    end

    -- look for debuff
    local text = getglobal(NBTooltip:GetName().."TextLeft1");
	for i=1, 16 do
		NBTooltip:SetOwner(UIParent, "ANCHOR_NONE");
		NBTooltip:SetUnitDebuff(unit, i);
		name = text:GetText();
		NBTooltip:Hide();
        buffName = string.gsub(buffName, "_", " ");
		if ( name and string.find(name, buffName) ) then
			gotbuff =  true;
		end
    end    

    -- finally use the modifier to decide on true/false
    if modifier == "" and gotbuff == true then
        return true
    end
    if modifier == "!" and gotbuff == false then
        return true
    end    

    
    return false;
end


function check_con(unit, type)

    -- get test modifier !
    local modifier = string.sub(type, 1, 1)
    local charList = {'!'}
    if not NB.isCharInList(modifier, charList) then
        modifier = ""
    else
        type = string.sub(type, 2)
    end   

    local gotcurse = false
    local gotpoison = false
    local gotmagic = false
    local gotdisease = false
    for i=1,40 do 
        local name, rank, type, rest = UnitDebuff("player",i); 
        if type=="Curse" then gotcurse = true end
        if type=="Poison" then gotpoison = true end
        if type=="Magic" then gotmagic = true end
        if type=="Disease" then gotdisease = true end
    end

    -- finally use the modifier to decide on true/false
    if type == "curse" and modifier == "" and gotcurse == true then
        return true
    elseif type == "curse" and modifier == "!" and gotcurse == false then
        return true
    end   
    if type == "poison" and modifier == "" and gotpoison == true then
        return true
    elseif type == "poison" and modifier == "!" and gotpoison == false then
        return true
    end  
    if type == "magic" and modifier == "" and gotmagic == true then
        return true
    elseif type == "magic" and modifier == "!" and gotmagic == false then
        return true
    end  
    if type == "disease" and modifier == "" and gotdisease == true then
        return true
    elseif type == "disease" and modifier == "!" and gotdisease == false then
        return true
    end   
    
    return false

end
