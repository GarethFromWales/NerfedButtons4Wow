if NB == nil then NB = {} end

-- checks if a spell is on cooldown
function NB.SpellReady(spell)
    local i,a=0
    while a~=spell do 
        i=i+1 
        a=GetSpellName(i,"spell")
    end 
    if GetSpellCooldown(i,"spell") == 0 then 
        return true
    end
end


-- dump a string or table
function NB.dump(...)
	for i=1, arg.n do
		local t=arg[i] and (arg[i]~="" and arg[i] or '-""-' )or "-nil-";
		if ( type(t)=="boolean") then
			t="-"..tostring(t).."-";
		end
		DEFAULT_CHAT_FRAME:AddMessage(t,1,1,1);
	end
end


function NB.print(msg)
    if (DEFAULT_CHAT_FRAME) then
        DEFAULT_CHAT_FRAME:AddMessage("NB: "..msg);
    end
end

function NB.error(msg)
    if (DEFAULT_CHAT_FRAME) then
        DEFAULT_CHAT_FRAME:AddMessage("NB: "..msg, 1, 0, 0);
    end
end


function NB.isFunctionDefined(func)
    return type(func) == "function"
end

function NB.isCharInList(char, list)
    for _, value in ipairs(list) do
        if value == char then
            return true
        end
    end
    return false
end


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