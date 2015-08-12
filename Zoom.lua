lineHeight = 8;
bottomLine = 225;

function debugger(v)
    gui.text(100, bottomLine, v);
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function toCallTypeString(callType)
    if (callType == 0) then
        return 'earf';
    elseif (callType == 1) then
        return 'pyramids';
    elseif (callType == 2) then
        return 'phonebook';
    elseif (callType == 3) then
        return 'uranus';
    else
        return '???';
    end
end

function numPhonesInDay(day)
    if (day == 0 or day == 3) then
        return 2;
    elseif (day == 1 or day == 2 or day == 5) then
        return 3;
    elseif (day == 4) then  -- dream
        return 0;
    else                    -- days 6 and 7 
        return 4;
    end
end

function numRingsLeft(state)
    if (state == 1) then
        return 3;
    elseif (state == 2) then
        return 2;
    elseif (state == 3) then
        return 1;
    else
        return 0;
    end
end

while true do
    inLevel = memory.readbyte('0x01D5');
    if (inLevel == 21) then
        day = memory.readbyte('0x06E9');
        baseCountdownAddr = '0x0623';
        baseNextAddr = '0x062f';
        basePhoneState = '0x062B';
        
        phones = {}
        
        for i = 0, numPhonesInDay(day)-1, 1 do
            phoneData = {}
            
            phoneCountdownLoops = memory.readbyte(baseCountdownAddr + i*2 + 1);
            phoneCountdownSeconds = math.floor(memory.readbyte(baseCountdownAddr + i*2) / 60);
            phoneCountdownTenths = round((memory.readbyte(baseCountdownAddr + i*2) % 60) * 0.166666666666, 1);
            phoneNext = toCallTypeString(memory.readbyte(baseNextAddr + i));
            phoneState = memory.readbyte(basePhoneState + i);
            
            phoneData[1] = phoneCountdownLoops;
            phoneData[2] = phoneCountdownSeconds;
            phoneData[3] = phoneCountdownTenths;
            phoneData[4] = phoneNext;
            phoneData[5] = phoneState;
            
            phones[i+1] = phoneData;
            
            --gui.text(0, lineHeight + (i*lineHeight), 'Phone ' .. i+1 .. ': (' .. phoneCountdownLoops .. ') ' .. phoneCountdownSeconds .. '.' .. string.format("%01d", phoneCountdownTenths) .. ' | ' .. phoneNext);
        end
        
        phoneNum = 0;
        for phone, data in spairs(phones, function(t,a,b) return t[b][2]+t[b][3]/10+t[b][1]*255+numRingsLeft(t[b][5])*200 > t[a][2]+t[a][3]/10+t[a][1]*255+numRingsLeft(t[a][5])*200 end) do
            if (data[5] == 0) then
                gui.text(80, ((phoneNum+1)*lineHeight), phone .. ' ' .. data[4]);
                phoneNum = phoneNum + 1;
            end
        end
        
        --debugger(phones[2][2] + phones[2][3]/10);
    end
    
    emu.frameadvance();
end