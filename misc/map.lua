require "objects.countries"

map = {}
mapW = 300
mapH = 130

function createMap() -- Fresh map. Used to load map at first play.
    love.filesystem.remove("map.lua")
    local mapFile = love.filesystem.newFile("assets/map.lua")
    mapFile:open("r")
    local mapString = mapFile:read()
    local mapTable = assert(loadstring(mapString))()
    
    map = mapTable[1]
    mapFile:close()
end

function loadMap() -- Load an existing map.
    local mapFile = love.filesystem.load("map.lua")
    -- mapTable's first item is the map itself, and second items is the Player's country.
    local mapTable = mapFile() -- Call the return of mapFile
    
    map = mapTable[1]
    
    for k,v in pairs(mapTable[2]) do
        Player[k] = v
    end
    
    Player:returnCountry(true).attack = Player.attack
    Player:returnCountry(true).defense = Player.defense
end

function saveMap(name)
    -- Turn the map into a table of numbers which represent countries.
    local numMap = {}
    name = name or "map.lua" -- An optional name for map.
    -- Create rows
    for i=0,#map do numMap[i] = {} end 

    for rowIndex,row in ipairs(map) do
        for columnIndex, cell in ipairs(row) do
            numMap[rowIndex][columnIndex] = cell.id
        end
    end
    
    local mapString = serialize(numMap) -- numMap converted into a string.
    love.filesystem.write(name, "return {")
    string.gsub(mapString, ",", "")
    love.filesystem.append(name, mapString)
    love.filesystem.append(name, ",".."{")
    for k,v in pairs(Player) do
        local stringV = ""
        if type(v) == "string" then
            stringV = '"'..v..'"'
        else
            stringV = tostring(v)
        end
        
        if type(v) ~= "function" then
            love.filesystem.append(name, tostring(k).."="..stringV..",")
        end
    end
    love.filesystem.append(name, "} }")
end

function initMap()    
    currAdjCells = {} -- adjacent cells of the selected cell.

    -----------------------
    --Edit Mode variables--
    
    editMode = {
        enabled = false,
        country = "Ukraine", -- Selected country. Paints this country on map.
        buttons = {}
    }
    

    -- Camera
    mapCam = Camera(2400, 1040)
    
    -- Map and grid images.
    mapImg = love.graphics.newImage("assets/image/map.jpg")
    gridImg = love.graphics.newImage("assets/image/grid.png")
    
    mapCam.scale = math.ceil(the.screen.width/2400)
    mapCam.x = 400
    mapCam.y = 240


    if love.filesystem.exists("map.lua") then
        loadMap()
    else
        createMap()
    end
    

    -------------------------------------------------------------------
    --Insert countries in the place of numbers representing countries--

    for rowIndex,row in ipairs(map) do
        for columnIndex,num in ipairs(row) do
            table.remove(row, columnIndex)
            table.insert(row, columnIndex, countries[num]:clone())
        end
    end
    
    -----------------------------------------
    --Generate adjacent cells for all cells--

    for rowInd,row in pairs(map) do
        for columnInd,cell in pairs(row) do
            local adj = cell.adjCells
            adj[1][1] = {rowIndex=rowInd-1, columnIndex=columnInd-1}
            adj[1][2] = {rowIndex=rowInd, columnIndex=columnInd-1}
            adj[1][3] = {rowIndex=rowInd+1, columnIndex=columnInd-1}
                            
            adj[2][1] = {rowIndex=rowInd-1, columnIndex=columnInd}
            adj[2][2] = {rowIndex=rowInd, columnIndex=columnInd}
            adj[2][3] = {rowIndex=rowInd+1, columnIndex=columnInd}
                            
            adj[3][1] = {rowIndex=rowInd-1, columnIndex=columnInd+1}
            adj[3][2] = {rowIndex=rowInd, columnIndex=columnInd+1}
            adj[3][3] = {rowIndex=rowInd+1, columnIndex=columnInd+1}
        end
    end
    
    
    function resetMap()
        map = {}
        for i=1,mapW do
            map[i] = {}
        end
        
        for _,row in ipairs(map) do
            for i=1,mapH do
                table.insert(row, countries[1]:clone())
            end
        end
    end
end


function enteredMap()
    -- Clear up current adjacent cells table so that none of the cells would be selected.
    currAdjCells = {}
    
    -- Camera isn't limited by borders if true.
    mapBorderCheck = true
    
    
    local function invasion()
        for rowIndex, row in pairs(map) do
            for columnIndex, cell in pairs(row) do
                for _,country in pairs(countries) do
                   -- country:invade(columnIndex, rowIndex)
                end
            end
        end
    end
    
    --Timer.addPeriodic(1, invasion)
end


function updateMap(dt)
    -- Converting camera to mouse coordinates.
    mapMouse = {}
    mapMouse.x, mapMouse.y = mapCam:mousepos()
    
    ---------------------------
    --Clean up "faint clones"--
    for rowIndex,row in ipairs(map) do
        for columnIndex, cell in ipairs(row) do
            if cell.isFaintClone then
                map[rowIndex][columnIndex] = countries[1]:clone()
            end
        end
    end

    

    ---------------------
    --Moving the camera--
    
    local cameraSpeed = 500/mapCam.scale
    local borderSize = 2

    if love.keyboard.isDown("d") or the.mouse.x > the.screen.width-borderSize then 
        mapCam.x = mapCam.x + cameraSpeed*dt
    elseif  love.keyboard.isDown("a") or the.mouse.x < borderSize then
        mapCam.x = mapCam.x - cameraSpeed*dt
    end
    
    if love.keyboard.isDown("s") or the.mouse.y > the.screen.height-borderSize then 
        mapCam.y = mapCam.y + cameraSpeed*dt
    elseif love.keyboard.isDown("w") or the.mouse.y < borderSize then
        mapCam.y = mapCam.y - cameraSpeed*dt
    end

    
    -----------------------------------
    --Limiting the movement of camera--
    
    if mapBorderCheck then
        local mapWidth, mapHeight = mapCam:worldCoords(the.screen.width, the.screen.height)        
        local mapX, mapY = mapCam:cameraCoords(2400,1040) -- 2400, 1040: Halves of width and height of map image

        if mapCam.x < (the.screen.width/2/mapCam.scale)-1 then
            mapCam.x = (the.screen.width/2/mapCam.scale)-1
        elseif the.screen.width > mapX then
            mapCam.x,_ = mapCam:worldCoords(mapX/2, mapY)
            mapCam.x = mapCam.x - cameraSpeed/2*dt
        end
        
        if mapCam.y < (the.screen.height/2/mapCam.scale)-1 then
            mapCam.y = (the.screen.height/2/mapCam.scale)-1
        elseif the.screen.height > mapY then
            _,mapCam.y = mapCam:worldCoords(mapX, mapY/2)
            mapCam.y = mapCam.y - cameraSpeed/2*dt
        end
    end
    
    --------------
    --Lımit zoom--

    if mapCam.scale < 1 then
        mapCam.scale = 1
    elseif mapCam.scale > 2.5 then
        mapCam.scale = 2.5
    end
    
    ------------------------
    --Edit Mode "painting"--
    
    if editMode.enabled then
        if love.mouse.isDown("l") then
            for rowIndex, row in pairs(map) do
                for columnIndex, cell in pairs(row) do
                    local cellX = (rowIndex-1)*the.cell.width
                    local cellY = (columnIndex-1)*the.cell.height
                    for _,country in pairs(countries) do
                        if checkCollision(mapMouse.x,mapMouse.y,1,1, cellX,cellY,the.cell.width,the.cell.height) then
                            if editMode.country == country.name then
                                map[rowIndex][columnIndex] = country:clone()
                            end
                        end
                    end
                end
            end
        end
    end
end

function mousepressedMap(x, y, button)
    --------------
    --Zooming in--
       
    if button == "wu" then
        Timer.tween(0.3, mapCam, {scale = mapCam.scale + 0.1}, "out-quad")
    elseif button == "wd" then
        if mapCam.scale > 1 then
            Timer.tween(0.3, mapCam, {scale = mapCam.scale - 0.1}, "out-quad")
        end
    end

    if not editMode.enabled then
        if button == "l" then
            for rowIndex,row in ipairs(map) do
                for columnIndex,cell in ipairs(row) do
                    
                    local cellX = (rowIndex-1)*the.cell.width
                    local cellY = (columnIndex-1)*the.cell.height

                    
                    -- We make all cells non-selected first so that player won't be able to select more than one cell.
                    cell.isSelected = false
                    
                    -------------------------------------------------------
                    --Generate adjacent cells table for the selected cell--
                    
                    if Player.country == cell.name then
                        if checkCollision(mapMouse.x, mapMouse.y, 1,1, cellX,cellY,the.cell.width-1,the.cell.height-1) then
                            cell.isSelected = true
                            currAdjCells = {{0,0,0},
                                            {0,0,0},
                                            {0,0,0}}
                        
                            local currAdj = currAdjCells
                            if cellX > 0  and cellY > 0 then
                                if cellX < (mapW-3)*the.cell.width and cellY < (mapH-3)*the.cell.height then
                                    currAdj[1][1] = {rowIndex=rowIndex-1, columnIndex=columnIndex-1}
                                    currAdj[1][2] = {rowIndex=rowIndex, columnIndex=columnIndex-1}
                                    currAdj[1][3] = {rowIndex=rowIndex+1, columnIndex=columnIndex-1}

                                    currAdj[2][1] = {rowIndex=rowIndex-1, columnIndex=columnIndex}
                                    currAdj[2][2] = {rowIndex=rowIndex, columnIndex=columnIndex}
                                    currAdj[2][3] = {rowIndex=rowIndex+1, columnIndex=columnIndex}
                                                            
                                    currAdj[3][1] = {rowIndex=rowIndex-1, columnIndex=columnIndex+1}
                                    currAdj[3][2] = {rowIndex=rowIndex, columnIndex=columnIndex+1}
                                    currAdj[3][3] = {rowIndex=rowIndex+1, columnIndex=columnIndex+1}
                                end
                            end
                        end
                    end
                end
                
                ------------------------------
                --Invasion of neighbor cells--
                
                for _,adjCellRow in pairs(currAdjCells) do
                    for _,adjCell in pairs(adjCellRow) do
                        if Player.country ~= map[adjCell.rowIndex][adjCell.columnIndex].name then
                            for _,country in pairs(countries) do
                                if Player.country == country.name then
                                    local adjCellX = (adjCell.rowIndex-1)*the.cell.width 
                                    local adjCellY = (adjCell.columnIndex-1)*the.cell.height
                                    local adjCellCountry = map[adjCell.rowIndex][adjCell.columnIndex].name
                                    
                                    if adjCellX > 0 and adjCellY > 0 then
                                        if adjCellX < (mapW-3)*the.cell.width and (mapH-3)*the.cell.height then
                                            if checkCollision(mapMouse.x,mapMouse.y,1,1, adjCellX,adjCellY,the.cell.width-1,the.cell.height-1) then
                                                -- Note: Conquering the cell is done in battle's leave function.
                                                -- Marking the selected as selected so that neighbor cells won't be claimed.
                                                map[adjCell.rowIndex][adjCell.columnIndex].isSelected = true
                                                if adjCellCountry == "Sea" then
                                                    map[adjCell.rowIndex][adjCell.columnIndex] = country:clone()
                                                    map[adjCell.rowIndex][adjCell.columnIndex].isFaintClone = true
                                                elseif not startedBattle then
                                                    for _,country in pairs(countries) do
                                                        if country.name == map[adjCell.rowIndex][adjCell.columnIndex].name then
                                                            table.insert(country.foes, Player:returnCountry(true))
                                                        end
                                                    end
                                                    
                                                    -- Prevent switching to battle more than once.
                                                    startBattle(Player.country, map[adjCell.rowIndex][adjCell.columnIndex].name)
                                                    startedBattle = true
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
        end
    end
end

function drawMap()
    love.graphics.setBackgroundColor(110, 175, 177)


    
    -- Attaches a camera. Everything from now on will be drawn from camera's perspective.
    mapCam:attach() 

    love.graphics.push()
    love.graphics.scale(2400/mapImg:getWidth())
    love.graphics.draw(mapImg, -1*mapCam.scale,-1*mapCam.scale)
    love.graphics.pop()
        
--[[
    love.graphics.push()
    love.graphics.scale(0.25)
    love.graphics.draw(gridImg, -1*mapCam.scale, -1*mapCam.scale)
    love.graphics.pop()
]]--
    for _,adjCellRow in ipairs(currAdjCells) do
        for _,adjCell in ipairs(adjCellRow) do
            local adjCellX = (adjCell.rowIndex-1)*the.cell.width
            local adjCellY = (adjCell.columnIndex-1)*the.cell.height
                   
            local cell = map[adjCell.rowIndex][adjCell.columnIndex]
            
            cell.color[4] = 128
            
            love.graphics.setColor(cell.color)
            love.graphics.rectangle("fill", adjCellX, adjCellY, the.cell.width-1, the.cell.height-1)
            love.graphics.setColor(255,255,255,180)
            love.graphics.rectangle("fill", adjCellX, adjCellY, the.cell.width-1, the.cell.height-1)
            love.graphics.setColor(255,255,255)
        
        end
    end
    
    for rowIndex,row in ipairs(map) do
        for columnIndex,cell in ipairs(row) do
            local cellX = (rowIndex-1)*the.cell.width
            local cellY = (columnIndex-1)*the.cell.height
               
            cell:draw(cellX,cellY)

                
            if checkCollision(cellX, cellY, the.cell.width-1, the.cell.height-1, mapMouse.x, mapMouse.y, 1,1) then
                love.graphics.setLineWidth(0.5)
                love.graphics.setColor(255,255,255,64)
                love.graphics.rectangle("fill", cellX, cellY, the.cell.width-1, the.cell.height-1)
                
                if cell.name == "Sea" then
                    love.graphics.setColor(90,90,90)
                else
                    love.graphics.setColor(220,220,220)
                end
                
                love.graphics.rectangle("line", cellX, cellY, the.cell.width-1, the.cell.height-1)
                love.graphics.setColor(cell.color)
                love.graphics.rectangle("line", cellX+1, cellY+1, the.cell.width-3, the.cell.height-3)
                love.graphics.setColor(255,255,255)
                love.graphics.setLineWidth(1)
            end
        end
    end
    

    
    -- Detaches the camera. Things drawn after detach() will not be from camera's perspective.
    -- GUI should be drawn after this function is called.
    mapCam:detach()
end
