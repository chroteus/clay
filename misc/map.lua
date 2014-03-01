require "objects.countries"

map = {}

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
    for i=0,100 do numMap[i] = {} end 

    for columnIndex, column in pairs(map) do
        for rowIndex, cell in pairs(column) do
            numMap[columnIndex][rowIndex] = cell.id
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
    mapCam = Camera(the.screen.width/2, the.screen.height/2)
    
    -- Map and grid images.
    mapImg = love.graphics.newImage("assets/image/map.png")
    gridImg = love.graphics.newImage("assets/image/grid.png")
    
    mapCam.scale = 2
    mapCam.x = 400
    mapCam.y = 240


    if love.filesystem.exists("map.lua") then
        loadMap()
    else
        createMap()
    end

    -------------------------------------------------------------------
    --Insert countries in the place of numbers representing countries--

    for columnIndex,column in pairs(map) do
        for rowIndex,num in pairs(column) do
            table.remove(column, rowIndex)
            table.insert(column, rowIndex, countries[num]:clone())
        end
    end
end


function enteredMap()
-- enterMap: Things to do every time game changes to "game" gamestate.
    
    -- Clear up current adjacent cells table so that none of the cells would be selected.
    currAdjCells = {}
    
    -- Camera isn't limited by borders if true.
    mapBorderCheck = true
end


function updateMap(dt)
    -- Converting camera to mouse coordinates.
    mapMouse = {}
    mapMouse.x, mapMouse.y = mapCam:mousepos()
    
    ---------------------------
    --Clean up "faint clones"--
    for columnIndex, column in pairs(map) do
        for rowIndex, cell in pairs(column) do
            if cell.isFaintClone then
                map[columnIndex][rowIndex] = countries[1]:clone()
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
        local mapX, mapY = mapCam:cameraCoords(800, 576)

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

    if mapCam.scale < 2 then
        mapCam.scale = 2
    elseif mapCam.scale > 3 then
        mapCam.scale = 3
    end
    
    ------------------------
    --Edit Mode "painting"--
    
    if editMode.enabled then
        if love.mouse.isDown("l") then
            for columnIndex, column in pairs(map) do
                for rowIndex, cell in pairs(column) do
                    local cellX = (rowIndex-1)*the.cell.width
                    local cellY = (columnIndex-1)*the.cell.height
                    for _,country in pairs(countries) do
                        if checkCollision(mapMouse.x,mapMouse.y,1,1, cellX,cellY,the.cell.width,the.cell.height) then
                            if editMode.country == country.name then
                                map[columnIndex][rowIndex] = country:clone()
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
            for columnIndex,column in pairs(map) do
                for rowIndex,cell in pairs(column) do
                    local cellX = (rowIndex-1)*the.cell.width
                    local cellY = (columnIndex-1)*the.cell.height
                    -- We make all cells non-selected first so that Player won't be able to select more than one cell.
                    cell.isSelected = false

                    -----------------------------------------
                    --Generate adjacent cells for all cells--

                    local adj = cell.adjCells
                    adj[1][1] = {rowIndex=rowIndex-1, columnIndex=columnIndex-1}
                    adj[1][2] = {rowIndex=rowIndex, columnIndex=columnIndex-1}
                    adj[1][3] = {rowIndex=rowIndex+1, columnIndex=columnIndex-1}
                            
                    adj[2][1] = {rowIndex=rowIndex-1, columnIndex=columnIndex}
                    adj[2][2] = {rowIndex=rowIndex, columnIndex=columnIndex}
                    adj[2][3] = {rowIndex=rowIndex+1, columnIndex=columnIndex}
                            
                    adj[3][1] = {rowIndex=rowIndex-1, columnIndex=columnIndex+1}
                    adj[3][2] = {rowIndex=rowIndex, columnIndex=columnIndex+1}
                    adj[3][3] = {rowIndex=rowIndex+1, columnIndex=columnIndex+1}
                    
                    -------------------------------------------------------
                    --Generate adjacent cells table for the selected cell--

                    if Player.country == cell.name then
                        if checkCollision(mapMouse.x, mapMouse.y, 1,1, cellX,cellY,the.cell.width-1,the.cell.height-1) then
                            cell.isSelected = true
                            currAdjCells = {{0,0,0},
                                            {0,0,0},
                                            {0,0,0}}
                        
                            local c = currAdjCells
                            local cAdj = cell.adjCells
                        
                            if cellX > 0  and cellY > 0 then
                                if cellX < 792 and cellY < 568 then
                                    c[1][1] = cAdj[1][1]
                                    c[1][2] = cAdj[1][2]
                                    c[1][3] = cAdj[1][3]
                                    
                                    c[2][1] = cAdj[2][1]
                                    c[2][2] = cAdj[2][2]
                                    c[2][3] = cAdj[2][3]
                                    
                                    c[3][1] = cAdj[3][1]
                                    c[3][2] = cAdj[3][2]
                                    c[3][3] = cAdj[3][3]
                                end
                            end
                        end
                    end
                end
                
                ------------------------------
                --Invasion of neighbor cells--
                
                for _,adjCellColumn in pairs(currAdjCells) do
                    for _,adjCell in pairs(adjCellColumn) do
                        if Player.country ~= map[adjCell.columnIndex][adjCell.rowIndex].name then
                            for _,country in pairs(countries) do
                                if Player.country == country.name then
                                    local adjCellX = (adjCell.rowIndex-1)*the.cell.width 
                                    local adjCellY = (adjCell.columnIndex-1)*the.cell.height
                                    local adjCellCountry = map[adjCell.columnIndex][adjCell.rowIndex].name
                                    
                                    if adjCellX > 0 and adjCellY > 0 then
                                        if adjCellX < 792 and adjCellY < 568 then
                                            if checkCollision(mapMouse.x,mapMouse.y,1,1, adjCellX,adjCellY,the.cell.width-1,the.cell.height-1) then
                                                -- Note: Conquering the cell is done in battle's leave function.
                                                -- Marking the selected as selected so that neighbor cells won't be claimed.
                                                map[adjCell.columnIndex][adjCell.rowIndex].isSelected = true
                                                if adjCellCountry == "Sea" then
                                                    map[adjCell.columnIndex][adjCell.rowIndex] = country:clone()
                                                    map[adjCell.columnIndex][adjCell.rowIndex].isFaintClone = true
                                                elseif not startedBattle then
                                                    -- Prevent switching to battle more than once.
                                                    startBattle(Player.country, map[adjCell.columnIndex][adjCell.rowIndex].name)
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
    love.graphics.scale(0.5)
    love.graphics.draw(mapImg, 0,0)
    love.graphics.pop()
    
    love.graphics.push()
    love.graphics.scale(0.25)
    love.graphics.draw(gridImg, -1*mapCam.scale, -1*mapCam.scale)
    love.graphics.pop()
    
    for _,adjCellColumn in pairs(currAdjCells) do
        for _,adjCell in pairs(adjCellColumn) do
            local adjCellX = (adjCell.rowIndex-1)*the.cell.width
            local adjCellY = (adjCell.columnIndex-1)*the.cell.height
                   
            local cell = map[adjCell.columnIndex][adjCell.rowIndex]
            
            cell.color[4] = 128
            
            love.graphics.setColor(cell.color)
            love.graphics.rectangle("fill", adjCellX, adjCellY, the.cell.width-1, the.cell.height-1)
            love.graphics.setColor(255,255,255,180)
            love.graphics.rectangle("fill", adjCellX, adjCellY, the.cell.width-1, the.cell.height-1)
            love.graphics.setColor(255,255,255)
        
        end
    end
    
    for columnIndex,column in pairs(map) do
        for rowIndex,cell in pairs(column) do
            local cellX = (rowIndex-1)*the.cell.width
            local cellY = (columnIndex-1)*the.cell.height
               
            cell:draw(cellX,cellY)
            
            if checkCollision(cellX, cellY, the.cell.width-1, the.cell.height-1, mapMouse.x, mapMouse.y, 1,1) then
                love.graphics.setLineWidth(0.5)
                love.graphics.setColor(255,255,255,64)
                love.graphics.rectangle("fill", cellX, cellY, the.cell.width-1, the.cell.height-1)
                love.graphics.setColor(255,255,255)
                love.graphics.rectangle("line", cellX, cellY, the.cell.width-1, the.cell.height-1)
                love.graphics.setLineWidth(1)
            end
        end
    end
    

    
    -- Detaches the camera. Things drawn after detach() will not be from camera's perspective.
    -- GUI should be drawn after this function is called.
    mapCam:detach()
end
