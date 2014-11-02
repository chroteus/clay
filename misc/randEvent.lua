randEvents = {

war = {
    chance = 5,

    fn = function(country)
        for _,region in pairs(map) do
            if region.country.name == country.name then
                for _,neighbour in pairs(region.neighbours) do
                    local foeRegion = getRegion(neighbour)
                    
                    if country:isFoe(foeRegion.country) then
                        randEvent(math.huge)
                    else
                        country:war(foeRegion.country.name)
                    end
                    
                    break
                end
                
                break
            end
        end
    end
},

peace = {
    chance = 3,
    
    fn = function(country)
        if #country.foes == 0 then
            randEvent(math.huge)
        else
            for _,foe in pairs(country.foes) do
                country:peace(foe)
                break
            end
        end
    end
},

riots = {
    chance = 1,
    
    fn = function(country)
        local cost = math.random(5,15)
        msgBox:add("Riots in " .. country.name .. " caused "
                   .. cost .. "G worth of damage.")
    
        country.money = country.money - cost
    end

},

}


------------------------------------------------------------------------
local lastCountry = ""

local function randCountry()

    local r = math.random(#countries)
    
    while countries[r].name == "Sea" 
    or countries[r].name == Player.country
    or countries[r].name == lastCountry do 
		r = math.random(#countries) 
    end
    
    return countries[r]
end

local randEventTimer = math.random(10*worldTime.dayLength,20*worldTime.dayLength)

function randEvent(dt)
    if not DEBUG then
        randEventTimer = randEventTimer - dt
        if randEventTimer <= 0 then
            local possible_events = {}
            
            for k,rand_e in pairs(randEvents) do
                for i=1,rand_e.chance do
                    table.insert(possible_events, k)
                end
            end
            
            local randE_k = possible_events[math.random(#possible_events)]
            
            local country = randCountry()
            print(randE_k)
            randEvents[randE_k]["fn"](country)
            lastCountry = country.name
            
            randEventTimer = math.random(5,10)
        end
    end
end
