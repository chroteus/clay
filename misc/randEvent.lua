local function randCountry()

    r = math.random(#countries)
    while countries[r].name == "Sea" or countries[r].name == Player.country do r = math.random(#countries) end
    return countries[r]
end

randEvents = {
    function() -- war
        local randCountry = randCountry()
        for _,country in pairs(countries) do
            for _,region in pairs(map) do
                if region.country.name == randCountry.name then
                    for _,neighbour in pairs(region.neighbours) do
                        if num == 0 then
                            local foeRegion = getRegion(neighbour)
                            randCountry:war(foeRegion.country.name)
                            
                            num = num + 1
                        end
                    end
                end
            end
        end
                        
        num = 0
    end,
    
    function() -- peace
        local randCountry = randCountry()        
        local num = 0
        
        for _,foe in pairs(randCountry.foes) do
            if num == 0 then
                randCountry:peace(foe)
                num = num + 1
            end
        end
    end,
}
            
local randEventTimer = math.random(5,10)

function randEvent(dt)
    if not DEBUG then
        randEventTimer = randEventTimer - dt
        if randEventTimer <= 0 then
            local r = math.random(#randEvents)
            randEvents[r]()
            randEventTimer = math.random(5,10)
        end
    end
end
