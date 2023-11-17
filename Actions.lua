-----------------------------------------
-- Check: Cancel buff
--
function NB.action_cancel(buffName)

    local unit="player"
    local text = getglobal(NBTooltip:GetName().."TextLeft1");
    for i=1, 32 do
       NBTooltip:SetOwner(UIParent, "ANCHOR_NONE");
       NBTooltip:SetUnitBuff(unit, i);
       local name = text:GetText();
       NBTooltip:Hide();
       buffName = string.gsub(buffName, "_", " ");
       if ( name and string.find(name, buffName) ) then
            CancelPlayerBuff(i-1);
            return true
       end
    end

end


-----------------------------------------
-- Check: Stop Casting
--
function NB.action_stopcast()

    SpellStopCasting()
    
end


-----------------------------------------
-- Check: Stop Casting
--
function NB.action_stopattack()

    local ma = nil

    -- get the button id of the button with attack
    if not ma then
        for i = 1,72 do
            if IsAttackAction(i) then
                ma = i
            end
        end
    end
    if ma then
        if not IsCurrentAction(ma) then
            UseAction(ma)
        end
    else
        NB.error("To use the stopattack action you must have the attack ability somewhere on one of your action bars.")
    end

end


-----------------------------------------
-- Check: Stop Casting and Attacking
--
function NB.action_stop()

    NB.action_stopattack()
    NB.action_stopcast()

end