randEvents = {
    function() -- war
        local num = 0
        
        math.randomseed(os.time())
        local r = math.random(#countries)
        local randCountry = countries[r]
                
        for rowIndex, row in ipairs(map) do
            for columnIndex, cell in ipairs(row) do
                if cell.name == randCountry.name then
                    for _,adjCellRow in ipairs(adjCellsOf(rowIndex,columnIndex)) do
                        for _,adjCell in ipairs(adjCellRow) do
                            if adjCell.rowIndex > 0 and adjCell.columnIndex > 0 then
                                if adjCell.rowIndex < mapW-3 and adjCell.columnIndex < mapH-3 then
                                    local foe = map[adjCell.rowIndex][adjCell.columnIndex]
                                    if foe.name ~= randCountry.name and foe.name ~= "Sea" and randCountry.name ~= "Sea" and randCountry.name ~= Player.country then
                                        if num == 0 then
                                            if not randCountry:isFoe(foe.name) and not nameToCountry(foe.name):isFoe(randCountry.name) then
                                                
                                                randCountry:war(nameToCountry(foe.name))
                                                nameToCountry(foe.name):war(randCountry)
                                                
                                                msgBox:add(randCountry.name.." has declared war on "..foe.name.."!")
                                                num = num + 1
                                           end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        num = 0
    end,
    
    function() -- peace
        local randCountry = countries[math.random(#countries)]
        local num = 0
        
        for _,foe in pairs(randCountry.foes) do
            if num == 0 then
                randCountry:peace(foe)
                num = num + 1
            end
        end
    end,
}
            
local randEventTimer = math.random(5,20)

function randEvent(dt)
    if not DEBUG then
        randEventTimer = randEventTimer - dt
        if randEventTimer <= 0 then
            local r = math.random(#randEvents)
            randEvents[r]()
            randEventTimer = math.random(5,20)
        end
    end
end
