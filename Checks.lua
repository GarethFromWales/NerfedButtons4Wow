if NB == nil then NB = {} end
NB.DruidManaLib = nil -- global that we use to points to the library bundled with DruiManaBar

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
        elseif name and NB.SPELLCACHE[buffName] and string.lower(NB.SPELLCACHE[buffName]) == string.lower(name) then
			gotbuff =  true;
        elseif name and NB.ITEMCACHE[buffName] and string.lower(NB.ITEMCACHE[buffName]) == string.lower(name) then
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
        elseif name and NB.SPELLCACHE[buffName] and string.lower(NB.SPELLCACHE[buffName]) == string.lower(name) then
			gotbuff =  true;
        elseif name and NB.ITEMCACHE[buffName] and string.lower(NB.ITEMCACHE[buffName]) == string.lower(name) then
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
-- Check: Type
--
function NB.check_type(unit, operator, typeName)
    if not typeName or not unit then
        return false;
    end
    typeName = NB.validate_type_name(typeName)

    if  operator ~= "!" and operator ~= "=" then
        NB.error("Invalid operator passed to type check, only = and ! are allowed.")
        return false
    end    

    -- do we have a valid type?
    local apitype = NB.validate_type_name(typeName)
    if not apitype then
        NB.error("Invalid type passed to check *"..typeName.."*")
        return false
    end

    local gottype = false
    local actual_type = UnitCreatureType(unit) 
    if string.lower(typeName) == string.lower(actual_type) then
        gottype = true
    else
        gottype = false
    end

    -- finally use the operator to decide on true/false  
    if operator == "=" and gottype == true then
        return true
    end
    if operator == "!" and gottype == false then
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
-- Check: Mod Keys
-- mod@player=shift
-- mod@player=ctrl
-- mod@player=alt
function NB.check_modifier(unit, operator, value)

    -- validate value and extract first character
    value = string.lower(value)
    if  value ~= "shift" and value ~= "s"  
    and value ~= "alt" and value ~= "a" 
    and value ~= "ctrl" and value ~= "c" 
    then
        NB.error("Invalid value passed to power modifier, only shift(s),alt(a),ctrl(c) are allowed.")
        return false
    end  
    value = string.sub(value, 1, 1)

    if  operator ~= "!" and operator ~= "=" then
        NB.error("Invalid operator passed to modifier check, only = and ! are allowed.")
        return false
    end    

    local shiftDown = IsShiftKeyDown();
    local ctrlDown  = IsControlKeyDown();
    local altDown   = IsAltKeyDown();

    local test = false
    -- finally use the operator to decide on true/false
    if operator == "=" and value == "s" and  shiftDown then return true end
    if operator == "!" and value == "s" and  not shiftDown then return true end
    if operator == "=" and value == "c" and  ctrlDown then return true end
    if operator == "!" and value == "c" and  not ctrlDown then return true end
    if operator == "=" and value == "a" and  altDown then return true end
    if operator == "!" and value == "a" and  not altDown then return true end

    return false

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
-- Check: Fake Cooldown
-- fcd@player>3Healing Touch
function NB.check_fakecooldown(unit, operator, spellAndCooldown)
    if  operator ~= ">" and operator ~= "<" then
        NB.error("Invalid operator passed to fake cooldown check, only > and < are allowed.")
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
-- Check: Cooldown
-- cd@player=Enrage
function NB.check_cooldown(unit, operator, spell)
    if  operator ~= "=" and operator ~= "!" then
        NB.error("Invalid operator passed to cooldown check, only = and ! are allowed.")
        return false
    end        

    -- look up spell
    local realSpellName = NB.getSpellFromCache(string.lower(spell))

    -- get slot
    local index, book = NB.FindSpell(realSpellName, '')

    local start, duration, enabled, modRate = GetSpellCooldown(index, book)

    if operator ==  "=" and start > 0 then
        -- on cooldown
        return true
    elseif operator ==  "!" and start == 0 then
        -- on cooldown
        return true        
    else
        -- off cooldown
        return false
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
function NB.check_mana(unit, operator, powerTest)

    -- if its not a druid then simply return the current power
    local _, class, _ = UnitClass(unit) 
    if class ~= "DRUID" then
        return NB.check_power(unit, operator, powerTest)
    end

    -- we have a druid :) check if we have acelibrary and druidmanabar installed
    -- if not throw and error message, if so then load the library so we can use it.
    local _, _, _, enabled, loadable, _, _ = GetAddOnInfo("DruidManaBar")
    if not enabled or not loadable then 
        NB.error("DruidManaBar addon is required to check mana in druid forms.")
        NB.error("Ensure DruidManaBar is installed and enabled.")
        return false
    else
        if not NB.DruidManaLib then
            NB.DruidManaLib = AceLibrary("DruidManaLib-1.0")
        end
    end

    -- if target is not a shapeshifted druid then return current power
    local DRUID_SHIFT_FORMS = { bear=1, aquatic=2, cat=3, travel=4, moonkin=5 };
    local in_form = false
    if class == "DRUID" then
        for i=1,5  do
            local _, _, active = GetShapeshiftFormInfo(i)
            if active then in_form = true end
            break
        end
    end 
    if not in_form then
        return NB.check_power(unit, operator, powerTest)
    end
      
    -- CUSTOM DRUID MANA CODE HERE
    if  operator ~= ">" and operator ~= "<" and operator ~= "=" and operator ~= "!" then
        NB.error("Invalid operator passed to mana check, only > < ! = are allowed.")
        return false
    end            

    -- get current and max mana from druidmanaliv :)
    local currentMana, maxMana = NB.DruidManaLib:GetMana()

    -- do we have a percentage at the end of the powerTest?
    local num = gsub(powerTest,"(.-)%%.*", "%1")
    local percent  = false
    local actualPower = 0
    if string.find(powerTest, "%%") then
        actualPower=100*currentMana/maxMana
    else
        actualPower=currentMana
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