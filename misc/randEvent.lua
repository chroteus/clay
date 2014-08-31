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
		end
	end
end,   
 
function(country) -- peace
	for _,foe in pairs(country.foes) do
		country:peace(foe)
		break
	end
end

}


------------------------------------------------------------------------
local function randCountry()

    local r = math.random(#countries)
    
    while countries[r].name == "Sea" 
    or countries[r].name == Player.country do 
		r = math.random(#countries) 
    end
    
    return countries[r]
end

local randEventTimer = math.random(5,10)

function randEvent(dt)
    if not DEBUG then
        randEventTimer = randEventTimer - dt
        if randEventTimer <= 0 then
            local r = math.random(#randEvents)
            randEvents[r](randCountry())
            randEventTimer = math.random(5,10)
        end
    end
end
