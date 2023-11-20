if NB == nil then NB = {} end

-----------------------------------------
-- Action: Cancel buff
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
       NB.print(name)
       NB.print(buffName)
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


