local DruidManaLib = AceLibrary("DruidManaLib-1.0")
if NB == nil then NB = {} end


-----------------------------------------
-- Check: Buff
--
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
		local name = text:GetText();
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
		local name = text:GetText();
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


-----------------------------------------
-- Check: Class
--
function NB.check_class(unit, className)
    if not className or not unit then
        return false;
    end

    -- get test modifier !
    local modifier = string.sub(className, 1, 1)
    local charList = {'!'}
    if not NB.isCharInList(modifier, charList) then
        modifier = ""
    else
        className = string.sub(className, 2)
    end

    -- do we have a valid class?
    local apiClass = NB.get_APIClass(className)
    if not apiClass then
        NB.error("Invalid class passed to check *"..className.."*")
        return false
    end

    local _, actual_class, _ = UnitClass(unit) 
    if string.upper(className) == string.upper(actual_class) then
        return true
    else
        return false
    end

    -- finally use the modifier to decide on true/false
    local test = false    
    if modifier == "" and test == true then
        return true
    end
    if modifier == "!" and test == false then
        return true
    end    
    
    return false;
end


-----------------------------------------
-- Check: Combat
--
function NB.check_combat(unit, modifier)

    local charList = {'!'}
    if not NB.isCharInList(modifier, charList) then
        modifier = ""
    end

    local test = nil
    if UnitAffectingCombat(unit) then test = true end

    -- finally use the modifier to decide on true/false
    local test = false    
    if modifier == "" and test == true then
        return true
    end
    if modifier == "!" and test == false then
        return true
    end   

    return false

end


-----------------------------------------
-- Check: Con(ditions)
--
function NB.check_condition(unit, type)

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
        local name, rank, type, rest = UnitDebuff(unit, i); 
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


-----------------------------------------
-- Check: Health
--
function NB.check_health(unit, healthTest)

    -- get health % of unit
    local actualHealth=100*UnitHealth(unit)/UnitHealthMax(unit)

    -- get test modifier > < =
    local modifier = string.sub(healthTest, 1, 1)
    local charList = {'<', '>', '='}
    if not NB.isCharInList(modifier, charList) then
        modifier = "="
    end
    healthTest = string.sub(healthTest, 2)
    
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


-----------------------------------------
-- Check: Mana
--
function NB.check_mana(unit, powerTest)

    -- if target is not a shapeshifted druid then return current power
    local DRUID_SHIFT_FORMS = { bear=1, aquatic=2, cat=3, travel=4, moonkin=5 };
    local in_form = false
    local _, class, _ = UnitClass(unit) 
    if class == "DRUID" then
        for i=1,5  do
            local _, _, active = GetShapeshiftFormInfo(i)
            if active then in_form = true end
            break
        end
    end 
    if not in_form then
        return NB.check_power(unit, powerTest)
    end
    
    -- CUSTOM DRUID MANA CODE HERE

    return false

end


-----------------------------------------
-- Check: Power
--
function NB.check_power(unit, powerTest)

    -- get health % of unit
    local actualPower=100*UnitMana(unit)/UnitManaMax(unit)

    -- get test modifier > < =
    local modifier = string.sub(powerTest, 1, 1)
    local charList = {'<', '>', '='}
    if not NB.isCharInList(modifier, charList) then
        modifier = "="
    end
    powerTest = string.sub(powerTest, 2)
    
    if modifier == "=" then
        if tonumber(actualPower) == tonumber(powerTest) then
            return true
        end
    elseif modifier == "<" then
        if tonumber(actualPower) < tonumber(powerTest) then
            return true
        end
    elseif modifier == ">" then
        if tonumber(actualPower) > tonumber(powerTest) then
            return true
        end
    end
    
    return false

end






