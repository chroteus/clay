randEvents = {

function(country) -- war
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
end,   

function(country) -- peace
	if #country.foes == 0 then
		randEvent(math.huge)
	else
		for _,foe in pairs(country.foes) do
			country:peace(foe)
			break
		end
	end
end,

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
            local r = math.random(#randEvents)
            
            local country = randCountry()
            randEvents[r](country)
            lastCountry = country.name
            
            randEventTimer = math.random(5,10)
        end
    end
end
