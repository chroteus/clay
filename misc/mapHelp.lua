-- map's helper functions
-- added here so that map.lua won't be cluttered.

function pairVertices(pol)
    local t = {}
    for i=2,#pol, 2 do
        table.insert(t, {x = pol[i-1], y = pol[i]})
    end
    
    return t
end

function unpairVertices(pol)
    -- Turns paired vertices table like {{x = 20, y = 10},...} into {20,10, ...}
    local t = {}
    for _,vertex in pairs(pol) do
        table.insert(t, vertex.x)
        table.insert(t, vertex.y)
    end
    
    return t
end

function pointCollidesMouse(x, y, radius)
    local radius = radius or 1
    return checkCollision(x,y,(radius*2)/mapCam.scale,(radius*2)/mapCam.scale, 
						  mapMouse.x,mapMouse.y,5/mapCam.scale,5/mapCam.scale)
end

function getRegion(name)
    for _,region in pairs(map) do
        if region.name == name then
            return region
        end
    end
end

function rmSpc(str)
    local s = str
    s = string.gsub(s, " ", "")
    
    return s
end

function convertStr(str)
    -- converts a string like "UnitedStates" into "United States"
    local s = str
    s = string.gsub(s, "%u", " %1") -- put a space before each upper case letter
    s = string.gsub(s, " ", "", 1) -- remove first space
    return s
end

-- load and saving of game

function createMap() -- Fresh map. Used to load map at first play.
    if love.filesystem.exists("assets/map.lua") then
        love.filesystem.remove("map.lua")
        local mapFile = love.filesystem.newFile("assets/map.lua")
        mapFile:open("r")
        local mapString = mapFile:read()
        local mapTable = assert(loadstring(mapString))()
        
        for _,region in pairs(mapTable.map) do
            local country = countries[region[1]]
            table.insert(map, Region(country.id, country.color, region[2], region[3])) 
            map[#map].pairedVertices = pairVertices(map[#map].vertices)
            
            if map[#map].country.name == Player.country then
				map[#map]:createUpgState()
			end
        end
        
        mapFile:close()
        game.seaId = mapTable.seaId
    end
end

function loadMap() -- Load an existing map.
    local mapFile = love.filesystem.load("map.lua")
    local mapTable = mapFile() -- Call the return of mapFile
    
    for k,v in pairs(mapTable.player) do
        Player[k] = v
        Player.items = {}
    end
    
     for _,save_region in pairs(mapTable.map) do
        local country = countries[save_region[1]]
        table.insert(map, Region(country.id, country.color, save_region[2], save_region[3]))
     
		-- Region upgrades loading.
		local region_inst = map[#map]
        if region_inst.country.name == Player.country 
        and save_region.u then
        
			region_inst:createUpgState()
			region_inst.state.init()
			region_inst.state.init = nil
			
			for k_reg,region_upg in pairs(region_inst.state.btn.btn) do
				for k_sv, save_upg in pairs(save_region.u) do
					print(save_upg[1])
					if region_upg.name == save_upg[1] then
						local level = tonumber(save_upg[2])
						
						local region_upg = region_inst.state.btn.btn[k_reg]
						print(region_upg)
						region_upg.level = level
						region_upg.upg_func(level, region_inst)
					end
				end
			end
		end			
    end
    
    for k,item in pairs(mapTable.player.items) do
		items[rmSpc(item[1])]:add()
		Player.items[#Player.items].equipped = item[2]
	end
    
    for countryN,foeTable in pairs(mapTable.foes) do
        local countryName = convertStr(countryN)
    
        for _,country in pairs(countries) do
            for _,foeId in pairs(foeTable) do
                local foe = countries[foeId]
                if country.name == countryName then
                    if not foe:isFoe(country.name) then
                        foe:war(country, true)
                    end
                end
            end
        end
    end
    
    
    -- load money values
    for countryN,moneyV in pairs(mapTable.money) do
        local countryName = convertStr(countryN)
        
        for _,country in pairs(countries) do
            if country.name == countryName then
                country.money = moneyV
            end
        end
    end

    -- load sea id
    game.seaId = mapTable.seaId

	-- load time
	for k,v in pairs(mapTable.time) do
		worldTime[k] = v
	end

    local player = Player:returnCountry()
    player.attack  = Player.attack
    player.defense = Player.defense
    player.money   = Player.money
    
    -- load fighters
    player.fighters = {}
    for _,fighter in pairs(mapTable.fighters) do
        table.insert(player.fighters,
            FighterAI{name = fighter[1], defense = fighter[2],
                      hp = fighter[3], speed = fighter[4], attack = fighter[5]}
        )
    end
end

function saveMap(name)
    local mapFile = name or "map.lua" -- An optional name for map.

    local strToApp = ""
    local function append(str)
        strToApp = strToApp..str
    end
    
    append("return {")
    
    append("map = {")
    for k,region in pairs(map) do
        append("{")
			append(region.id..",")
			append('"'..region.name..'"'..",")
				
			append("{")
				for k,vertex in pairs(region.unpairedVertices) do
					append(vertex..",")
				end
			append("},")
			
			if region.state and region.state.btn then
				append("u={")
					for _,upg in pairs(region.state.btn.btn) do
						if upg.level > 0 then
							append("{" .. '"'..upg.name..'"' .. "," .. upg.level .. "},")
						end
					end
				append("},")
			end
			
		append("},")
    end
    append("},")
    
    append("player = {")
    for k,v in pairs(Player) do
        local stringV = ""
        if type(v) == "string" then
            stringV = '"'..v..'"'
        elseif type(v) == "table" then
			
			-- items
            stringV = "{"
            for k,v in pairs(v) do 
				stringV = stringV.. '{"' .. v.name .. '",' 
				.. tostring(v.equipped) .. "},"
            end
            stringV = stringV.."}"
        
        else
            stringV = tostring(v)
        end
        
        if type(v) ~= "function" then
            append(tostring(k).."="..stringV..",")
        end
    end
    

    
    append("},")

    -- save foes
    append("foes = {")
    for _,country in pairs(countries) do
        if #country.foes > 0 then
            local countryName = country.name
            countryName = rmSpc(countryName)
            
            append(countryName.."={")
            for _,foe in pairs(country.foes) do
                append(foe.id..",")
            end
            append("},")
        end
    end
    append("},")
    
    -- save money for each country
    append("money = {")
    for _,country in pairs(countries) do
        append(rmSpc(country.name).."="..tostring(country.money)..",")
    end
    append("},")
   
    --save latest sea id
    append("seaId = "..game.seaId..",")
    
    --save time
    append("time = { day=" .. worldTime.day .. ", month=".. worldTime.month .. ",year=" .. worldTime.year .. "},")
    
    --save fighters
    append("fighters = {")
    for _,fighter in pairs(Player:returnCountry().fighters) do
        append(fighter:_saveString())
        append(",")
    end
    append("},")
    
    -- finish
    append("}")
    
    love.filesystem.write(mapFile, strToApp)
end
