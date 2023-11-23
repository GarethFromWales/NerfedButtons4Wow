local DruidManaLib = AceLibrary("DruidManaLib-1.0")
if NB == nil then NB = {} end


----------------------------------------
-- Check: Combo
--
function NB.check_combo_points(unit, operator, test)

    if  operator ~= ">" and operator ~= "<" and operator ~= "=" and operator ~= "!" then
        NB.error("Invalid operator passed to power check, only > < ! = are allowed.")
        return false
    end        

    -- get combo points
    local actualCombo = GetComboPoints("player")

    if operator == "=" then
        if tonumber(actualCombo) == tonumber(test) then
            return true
        end
    elseif operator == "<" then
        if tonumber(actualCombo) < tonumber(test) then
            return true
        end
    elseif operator == ">" then
        if tonumber(actualCombo) > tonumber(test) then
            return true
        end
    elseif operator == "!" then
        if tonumber(actualCombo) ~= tonumber(test) then
            return true
        end
    end
     
    return false

end


-----------------------------------------
-- Check: Form
--
function NB.check_form(unit, operator, testForm)

    if not testForm or not unit then return false; end
    testForm = string.lower(testForm)
    if  operator ~= "!" and operator ~= "=" then
        NB.error("Invalid operator passed to form check, only = and ! are allowed.")
        return false
    end 

    -- get if of current form
    local formId = 6
    local actualForm = 0
    for i=1, GetNumShapeshiftForms() do
        _, _, actualForm = GetShapeshiftFormInfo(i);
        if actualForm then
            formId =  i;
        end
    end

    -- get testForm API version
    testForm = NB.validate_form_name(testForm)

    local FORMS = {
        [6] = "humanoid",
        [1] = "bear" ,
        [2] = "aquatic",
        [3] = "cat",
        [4] = "travel",
        [5] = "moonkin"
    }

    if string.lower(testForm) == string.lower(FORMS[formId]) and operator == "=" then 
        return true 
    end

    if string.lower(testForm) ~= string.lower(FORMS[formId]) and operator == "!" then 
        return true 
    end   

    return false

end


-----------------------------------------
-- Check: Power
--
function NB.check_power(unit, operator, powerTest)

    if  operator ~= ">" and operator ~= "<" and operator ~= "=" and operator ~= "!" then
        NB.error("Invalid operator passed to power check, only > < ! = are allowed.")
        return false
    end            

    -- do we have a percentage at the end of the powerTest?
    local num = gsub(powerTest,"(.-)%%.*", "%1")
    local percent  = false
    local actualPower = 0
    if string.find(powerTest, "%%") then
        actualPower=100*UnitMana(unit)/UnitManaMax(unit)
    else
        actualPower=UnitMana(unit)
    end
    
    if operator == "=" then
        if tonumber(actualPower) == tonumber(num) then
            return true
        end
    elseif operator == "<" then
        if tonumber(actualPower) < tonumber(num) then
            return true
        end
    elseif operator == ">" then
        if tonumber(actualPower) > tonumber(num) then
            return true
        end
    elseif operator == "!" then
        if tonumber(actualPower) ~= tonumber(num) then
            return true
        end        
    end
    
    return false

end



-----------------------------------------
-- Check: Health
--
function NB.check_health(unit, operator, healthTest)

    if  operator ~= ">" and operator ~= "<" and operator ~= "=" and operator ~= "!" then
        NB.error("Invalid operator passed to health check, only > < ! = are allowed.")
        return false
    end            

    -- do we have a percentage at the end of the healthTest?
    local num = gsub(healthTest,"(.-)%%.*", "%1")
    local percent  = false
    local actualHealth = 0
    if string.find(healthTest, "%%") then
        actualHealth=100*UnitHealth(unit)/UnitHealthMax(unit)
    else
        actualHealth=UnitHealth(unit)
    end
    
    if operator == "=" then
        if tonumber(actualHealth) == tonumber(num) then
            return true
        end
    elseif operator == "<" then
        if tonumber(actualHealth) < tonumber(num) then
            return true
        end
    elseif operator == ">" then
        if tonumber(actualHealth) > tonumber(num) then
            return true
        end
    elseif operator == "!" then
        if tonumber(actualHealth) ~= tonumber(num) then
            return true
        end        
    end
    
    return false

end


-----------------------------------------
-- Check: Buff
--
function NB.check_buff(unit, operator, buffName)

    -- validate the parameters
    if not buffName or not unit then return false; end
    buffName = string.lower(buffName)
    if  operator ~= "!" and operator ~= "=" then
        NB.error("Invalid operator passed to buff check, only = and ! are allowed.")
        return false
    end

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
    if operator == "=" and gotbuff == true then
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
function NB.check_class(unit, operator, className)
    if not className or not unit then
        return false;
    end
    className = NB.validate_class_name(className)

    if  operator ~= "!" and operator ~= "=" then
        NB.error("Invalid operator passed to class check, only = and ! are allowed.")
        return false
    end    

    -- do we have a valid class?
    local apiClass = NB.validate_class_name(className)
    if not apiClass then
        NB.error("Invalid class passed to check *"..className.."*")
        return false
    end

    local gotClass = false
    local _, actual_class, _ = UnitClass(unit) 
    if string.lower(className) == string.lower(actual_class) then
        gotClass = true
    else
        gotClass = false
    end

    -- finally use the operator to decide on true/false  
    if operator == "=" and gotClass == true then
        return true
    end
    if operator == "!" and gotClass == false then
        return true
    end    
    
    return false;
end


-----------------------------------------
-- Check: Combat
-- com@player=1
-- com@target!1
function NB.check_combat(unit, operator, value)

    if  operator ~= "!" and operator ~= "=" then
        NB.error("Invalid operator passed to combat check, only = and ! are allowed.")
        return false
    end    

    local test = false
    if UnitAffectingCombat(unit) then test = true end

    -- finally use the operator to decide on true/false
    if operator == "=" and test == true then
        return true
    end
    if operator == "!" and test == false then
        return true
    end   

    return false

end


-----------------------------------------
-- Check: Cooldown
-- cd@player>3Healing Touch
function NB.check_cooldown(unit, operator, spellAndCooldown)

    if  operator ~= ">" and operator ~= "<" then
        NB.error("Invalid operator passed to cooldown check, only > and < are allowed.")
        return false
    end        

    local letters, numbers
    gsub (spellAndCooldown, "^(%d+)(%a+)$", function (a, b)  numbers = a; letters = b end)

    -- look up spell
    local realSpellName = NB.getSpellFromCache(string.lower(letters))

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
-- Check: Con(ditions)
--
function NB.check_condition(unit, operator, typeCheck)
    if  operator ~= "!" and operator ~= "=" then
        NB.error("Invalid operator passed to condition check, only = and ! are allowed.")
        return false
    end    

    typeCheck = NB.validate_condition_name(typeCheck)
    if not typeCheck then
        NB.error("Invalid condition type passed: \""..typeCheck.."\".")
    end

    for i=1,40 do 
        local name, rank, typeHas, rest = UnitDebuff(unit, i); 
        if typeHas then
            typeHas = string.lower(typeHas)
            if typeHas == typeCheck then
                if operator == "=" then
                    return true
                end
            end
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





