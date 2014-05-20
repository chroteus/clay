-- map's helper functions
-- added here so that map.lua won't be cluttered.

function pairVertices(pol, name)
    local name = name or false
    
    
    local t = {}
    for i=2,#pol, 2 do
        if name then
            table.insert(t, {x = pol[i-1], y = pol[i]})
        else
            table.insert(t, {pol[i-1], pol[i]})
        end
    end
    
    return t
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


function createMap() -- Fresh map. Used to load map at first play.
    if love.filesystem.exists("assets/map.lua") then
        love.filesystem.remove("map.lua")
        local mapFile = love.filesystem.newFile("assets/map.lua")
        mapFile:open("r")
        local mapString = mapFile:read()
        local mapTable = assert(loadstring(mapString))()
        
        for _,region in pairs(mapTable[1]) do
            local country = idToCountry(region[1])
            table.insert(map, Region(country.id, country.color, region[2], region[3]))
            map[#map].pairedVertices = pairVertices(map[#map].vertices)
        end
        
        mapFile:close()
    end
end

function loadMap() -- Load an existing map.
    local mapFile = love.filesystem.load("map.lua")
    local mapTable = mapFile() -- Call the return of mapFile
    
    for _,region in pairs(mapTable[1]) do
        local country = idToCountry(region[1])
        table.insert(map, Region(country.id, country.color, region[2], region[3]))
    end
    
    for k,v in pairs(mapTable[2]) do
        Player[k] = v
    end
    
    for countryN,foeTable in pairs(mapTable[3]) do
        local countryName = convertStr(countryN)
    
        for _,country in pairs(countries) do
            for _,foeId in pairs(foeTable) do
                local foe = countries[foeId]
                if country.name == countryName then
                    if not foe:isFoe(country.name) then
                        foe:war(country)
                    end
                end
            end
        end
    end
    
    
    -- load money values
    for countryN,moneyV in pairs(mapTable[4]) do
        local countryName = convertStr(countryN)
        
        for _,country in pairs(countries) do
            if country.name == countryName then
                country.money = moneyV
            end
        end
    end
    
    Player:returnCountry(true).attack = Player.attack
    Player:returnCountry(true).defense = Player.defense
    Player:returnCountry(true).money = Player.money
end

function saveMap(name)
    local mapFile = name or "map.lua" -- An optional name for map.

    local strToApp = ""
    local function append(str)
        strToApp = strToApp..str
    end
    
    append("return {")
    
    append("{")
    for k,region in pairs(map) do
        append("{"..region.id..",")
        append('"'..region.name..'"'..",")
        
        append("{")
        for k,vertex in pairs(region.vertices) do
            append(vertex..",")
        end
        
        append("}")
        append("},")
    end
    append("},")
    
    append("{")
    for k,v in pairs(Player) do
        local stringV = ""
        if type(v) == "string" then
            stringV = '"'..v..'"'
        elseif type(v) == "table" then
            stringV = "{"
            for k,v in pairs(v) do
                stringV = stringV..tostring(k).."="..tostring(v.name)
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
    append("{")
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
    append("{")
    for _,country in pairs(countries) do
        append(rmSpc(country.name).."="..tostring(country.money)..",")
    end
        
    append("},")
    
    append("}")
    
    love.filesystem.write(mapFile, strToApp)
end