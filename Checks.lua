local DruidManaLib = AceLibrary("DruidManaLib-1.0")
if NB == nil then NB = {} end


-----------------------------------------
-- Check: Buff
--
function NB.check_buff(unit, operator, buffName)
    if not buffName or not unit then
        return false;
    end

    buffName = string.lower(buffName)
    
    -- look for buff
    local gotbuff = false
    local text = getglobal(NBTooltip:GetName().."TextLeft1");
	for i=1, 32 do
		NBTooltip:SetOwner(UIParent, "ANCHOR_NONE");
		NBTooltip:SetUnitBuff(unit, i);
		local name = text:GetText();
        if name then name = string.lower(name) end
		NBTooltip:Hide();
        --buffName = string.gsub(buffName, "_", " ");
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
        if name then name = string.lower(name) end
		NBTooltip:Hide();
        --buffName = string.gsub(buffName, "_", " ");
		if ( name and string.find(name, buffName) ) then
			gotbuff =  true;
		end
    end    

    -- finally use the modifier to decide on true/false
    if operator == "" and gotbuff == true then
        return true
    end
    if operator == "!" and gotbuff == false then
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
    local apiClass = NB.validate_class_name(className)
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
-- Check: Cooldown
-- e.g. HT30 (only pass if there has been 30 secodns since HT was last cast)
function NB.check_cooldown(unit, spellAndCooldown)

    local letters, numbers
    gsub (spellAndCooldown, "^(%d+)(%a+)$", function (a, b)  numbers = a; letters = b end)

    -- look up spell
    local realSpellName = NB.getSpellFromCache(letters)

    if not NB.cooldowns[realSpellName] then

        return true
    else
        if time() > tonumber(NB.cooldowns[realSpellName]) + tonumber(numbers) then
            return true
        end
    end

    return false

end

-----------------------------------------
-- Check: Combo
--
function NB.check_combo_points(unit, test)

    -- get combo points
    local actualCombo = GetComboPoints("player")

    -- get test modifier > < =
    local modifier = string.sub(test, 1, 1)
    local charList = {'<', '>', '='}
    if not NB.isCharInList(modifier, charList) then
        modifier = "="
    end
    test = string.sub(test, 2) 

    if modifier == "=" then
        if tonumber(actualCombo) == tonumber(test) then
            return true
        end
    elseif modifier == "<" then
        if tonumber(actualCombo) < tonumber(test) then
            return true
        end
    elseif modifier == ">" then
        if tonumber(actualCombo) > tonumber(test) then
            return true
        end
    end
     
    return false

end




-----------------------------------------
-- Check: Con(ditions)
--
function NB.check_condition(unit, typeCheck)

    -- get test modifier !
    local modifier = string.sub(typeCheck, 1, 1)
    local charList = {'!'}
    if not NB.isCharInList(modifier, charList) then
        modifier = ""
    else
        typeCheck = string.sub(typeCheck, 2)
    end     
    typeCheck = NB.CONDITIONS[typeCheck]
    if not typeCheck then
        NB.error("Invalid condition type passed: \""..typeCheck.."\".")
    end

    for i=1,40 do 
        local name, rank, typeHas, rest = UnitDebuff(unit, i); 
        if typeHas then
            typeHas = string.lower(typeHas)
            if typeHas == typeCheck then
                if modifier == "" then
                    return true
                end
            end
        end
    end
    
    return false

end


-----------------------------------------
-- Check: Form
--
function NB.check_form(unit, testForm)

    -- get if of current form
    local formId = 6
    local actualForm = 0
    for i=1, GetNumShapeshiftForms() do
        _, _, actualForm = GetShapeshiftFormInfo(i);
        if actualForm then
            formId =  i;
        end
    end

    -- get test modifier !
    local modifier = string.sub(testForm, 1, 1)
    local charList = {'!'}
    if not NB.isCharInList(modifier, charList) then
        modifier = ""
    else
        testForm = string.sub(testForm, 2)
    end

    -- get testForm API version
    testForm = NB.VALIDDRUIDFORMS[testForm]

    local FORMS = {
        [6] = "humanoid",
        [1] = "bear" ,
        [2] = "aquatic",
        [3] = "cat",
        [4] = "travel",
        [5] = "moonkin"
    }

    if testForm == FORMS[formId] and modifier=="" then 
        return true 
    end

    if testForm ~= FORMS[formId] and modifier=="!" then 
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






