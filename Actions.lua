if NB == nil then NB = {} end


-----------------------------------------
-- Action: Powershift
-- /nb ps or /nb powershift
-- /nb ps@Healing Potion
--
function NB.action_powershift(consumable)

    if consumable ~= nil then 
        consumable = NB.trim(consumable)
    end

    -- this action will shift you out of form on one key press and shift you back
    -- into the same form on the second keypress. It will also help protect you from 
    -- leaving form again if you press the key a 3rd time within a 1s window.

    -- globals that we need to store between keypress presses
    if NB.PS_LastForm==nil then NB.PS_LastForm = 0 end
    if NB.PS_LastShiftTime == nil then NB.PS_LastShiftTime = 0 end

    -- locals
    local timeNow = GetTime()   
    local active_form = 0
    local can_shift = false

    -- get consumable info
    local bagId = -1
    local itemSlot = -1
    if consumable ~= "player" then
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, GetContainerNumSlots(bag) do
                local item = GetContainerItemLink(bag, slot)
                if item and string.find(string.lower(item), string.lower(consumable), 1, true) then
                    bagId = bag
                    itemSlot = slot
                    break
                end
            end
        end
    end
    local _, potCD = GetContainerItemCooldown(bagId, itemSlot)
    local canPot = potCD == 0
    if bagId == -1 or itemSlot == -1 then
        if consumable ~= "player" then
            NB.error('Item ' .. consumable .. ' not found in bags.')
        end
        canPot = false
    end    

    -- get active form and store as global (nil if out of form)
    UIErrorsFrame:UnregisterEvent"UI_ERROR_MESSAGE"
    for i = 1, 4, 1 do 
        local _, _, active, castable = GetShapeshiftFormInfo(i) 
        if active then
            active_form = i
            can_shift = castable 
        end 
        if i == 2 then 
            UIErrorsFrame:RegisterEvent"UI_ERROR_MESSAGE" 
        end 
    end

    -- get time since last shift
    local timeDelta = timeNow-NB.PS_LastShiftTime

    -- if we have an active form then shift out of it, 
    -- but only if last shift into form was more than 1s ago 
    -- (to help stop key spamming causing you to leave form on the 3rd click)
    if active_form > 0 and can_shift and timeDelta > 1.5 then 
        NB.PS_LastForm=active_form 
        CastShapeshiftForm(active_form)       
    end

    -- if we are out of form, shift into last form, but only if we shifted out less than 1.5s ago
    if active_form == 0 and NB.PS_LastForm > 0 then 
        if canPot and consumable ~= "player" then
            UseContainerItem(bagId, itemSlot, true)
        end           
        CastShapeshiftForm(NB.PS_LastForm) 
        NB.PS_LastForm = 0 
        NB.PS_LastShiftTime=timeNow 
    end

end


-----------------------------------------
-- Action: Cancel buff
--
function NB.action_cancel(buffName)

    buffName = string.lower(buffName)

    local unit="player"
    local text = getglobal(NBTooltip:GetName().."TextLeft1");
    for i=1, 32 do
       NBTooltip:SetOwner(UIParent, "ANCHOR_NONE");
       NBTooltip:SetUnitBuff(unit, i);
       local name = text:GetText();
       NBTooltip:Hide();
       if name then name = string.lower(name) end
       if ( name and string.find(name, buffName) ) then
            CancelPlayerBuff(i-1);
            return true
       end
    end
end


-----------------------------------------
-- Action: Stop Casting and Attacking
--
function NB.action_stop()

    NB.action_stopattack()
    NB.action_stopcast()

end


-----------------------------------------
-- Action: Stop Casting
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
-- Action: Stop Casting
--
function NB.action_stopcast()

    SpellStopCasting()
    
end


-----------------------------------------
-- Action: Target
--
function NB.action_target(unit)

    TargetUnit(unit)
    
end


-----------------------------------------
-- Action: Target Last
--
function NB.action_targetlasttarget()

    TargetLastTarget();
    
end


-----------------------------------------
-- Action: Target friend
--
function NB.action_targetfriend()

    TargetNearestFriend();
    
end


-----------------------------------------
-- Action: Target enemy
--
function NB.action_targetenemy()

    TargetNearestEnemy();
    
end


-----------------------------------------
-- Action: Target enemy player
--
function NB.action_targetenemyplayer()

    TargetNearestEnemyPlayer();
    
end


