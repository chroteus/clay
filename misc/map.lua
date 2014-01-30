require "objects.countries"

function createMap() -- Fresh map. Used to load map at first play.
    love.filesystem.remove("map.lua")
    local mapFile = love.filesystem.newFile("assets/map.lua")
    mapFile:open("r")
    local mapString = mapFile:read()

    map = assert(loadstring(mapString))()
    mapFile:close()
end

function loadMap() -- Load an existing map.
    local mapFile = love.filesystem.load("map.lua")
    -- mapTable's first item is the map itself, and second items is the Player's country.
    local mapTable = mapFile() -- Call the return of mapFile
    
    map = mapTable[1]
    
    Player.country = mapTable[2]
end

function initMap()
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
    
    -- Create 0th row and column so that even cell on 1st column or row will have proper adjacent cells table.
    map[0] = {}
    for i=0,100 do map[0][i] = countries[1] end
    for i=0,72  do map[i][0] = countries[1] end
            
    
    currAdjCells = {} -- adjacent cells of the selected cell.
    
    
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
        love.filesystem.append(name, mapString)
        love.filesystem.append(name, ","..'"'..Player.country..'" '.."}")
    end
    -----------------------
    --Edit Mode variables--
    
    editMode = {
        enabled = false,
        selection = false, -- True if Country Selection screen is present.
        country = "Ukraine", -- Selected country. Paints this country on map.
        buttons = {}
            
    }

    -- Camera
    mapCam = Camera(the.screen.width/2, the.screen.height/2)
    
    -- Map and grid images.
    mapImg = love.graphics.newImage("assets/image/map.png")
    gridImg = love.graphics.newImage("assets/image/grid.png")
end

function updateMap(dt)
    ---------------------
    --Moving the camera--
    
    local cameraSpeed = 200
    
    if the.mouse.x == 799 or love.keyboard.isDown("d") then 
        mapCam.x = mapCam.x + cameraSpeed*dt
    elseif the.mouse.x == 0 or love.keyboard.isDown("a") then
        mapCam.x = mapCam.x - cameraSpeed*dt
    end
    
    if the.mouse.y == 575 or love.keyboard.isDown("s") then 
        mapCam.y = mapCam.y + cameraSpeed*dt
    elseif the.mouse.y == 0 or love.keyboard.isDown("w") then
        mapCam.y = mapCam.y - cameraSpeed*dt
    end
    
    
    -----------------------------------
    --Limiting the movement of camera--

    if mapCam.x < 400/mapCam.scale then 
        mapCam.x = 400/mapCam.scale
    elseif mapCam.x > 400*mapCam.scale then 
        mapCam.x = 400*mapCam.scale
    end
    
    if mapCam.y < 288/mapCam.scale then 
        mapCam.y = 288/mapCam.scale 
    elseif mapCam.y > 288*mapCam.scale then 
        mapCam.y = 288*mapCam.scale 
    end

    -----------------
    --Lımiting zoom--

    if mapCam.scale < 1 then
        mapCam.scale = 1
    elseif mapCam.scale > 2.5 then
        mapCam.scale = 2.5
    end
    
    ------------------------
    --Edit Mode "painting"--
    
    if editMode.enabled then
        if love.mouse.isDown("l") then
            for columnIndex, column in pairs(map) do
                for rowIndex, cell in pairs(column) do
                    for _,country in pairs(countries) do
                    
                        local cellX = (rowIndex-1)*the.cell.width -- Cell's x value
                        local cellY = (columnIndex-1)*the.cell.height -- Y value.
                    
                        if checkCollision(the.mouse.x,the.mouse.y,1,1, cellX,cellY,the.cell.width,the.cell.height) then
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
                    local cellX = (rowIndex-1)*the.cell.width -- Cell's x value
                    local cellY = (columnIndex-1)*the.cell.height -- Y value.
                
                    -- We make all cells non-selected first so that Player won't be able to select more than one cell.
                    cell.isSelected = false
                    
                
                    -------------------------------------------------------
                    --Generate adjacent cells table for the selected cell--

                    if Player.country == cell.name then
                        if checkCollision(x,y,1,1, cellX,cellY,the.cell.width,the.cell.height) then
                            cell.isSelected = true
                            currAdjCells = {{0,0,0},
                                            {0,0,0},
                                            {0,0,0}}
                        
                            local c = currAdjCells
                        
                            c[1][1] = {rowIndex=rowIndex-1, columnIndex=columnIndex-1}
                            c[1][2] = {rowIndex=rowIndex, columnIndex=columnIndex-1}
                            c[1][3] = {rowIndex=rowIndex+1, columnIndex=columnIndex-1}
           
                            c[2][1] = {rowIndex=rowIndex-1, columnIndex=columnIndex}
                            c[2][2] = {rowIndex=rowIndex, columnIndex=columnIndex}
                            c[2][3] = {rowIndex=rowIndex+1, columnIndex=columnIndex}
            
                            c[3][1] = {rowIndex=rowIndex-1, columnIndex=columnIndex+1}
                            c[3][2] = {rowIndex=rowIndex, columnIndex=columnIndex+1}
                            c[3][3] = {rowIndex=rowIndex+1, columnIndex=columnIndex+1}
                        
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
                                    
                                    if checkCollision(the.mouse.x,the.mouse.y,1,1, adjCellX,adjCellY,the.cell.width,the.cell.height) then
                                        map[adjCell.columnIndex][adjCell.rowIndex] = country:clone()
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
    -- Attaches a camera. Everything from now on will be drawn from camera's perspective.
    mapCam:attach() 
    
    love.graphics.draw(mapImg, 0,0)
    love.graphics.draw(gridImg, 0,0)
    
    for columnIndex,column in pairs(map) do
        for rowIndex,cell in pairs(column) do
            local x = (rowIndex-1)*the.cell.width -- Cell's x value
            local y = (columnIndex-1)*the.cell.height -- Y value
               
            cell:draw(x,y)
            
            if checkCollision(x, y, the.cell.width, the.cell.height, the.mouse.x, the.mouse.y, 1,1) then
                love.graphics.setColor(255,255,255,16)
                love.graphics.rectangle("fill", x, y, the.cell.width, the.cell.height)
                love.graphics.setColor(255,255,255)
                love.graphics.rectangle("line", x, y, the.cell.width, the.cell.height)
            end
        end
    end
    
    for _,adjCellColumn in pairs(currAdjCells) do
        for _,adjCell in pairs(adjCellColumn) do
            local adjCellX = (adjCell.rowIndex-1)*the.cell.width
            local adjCellY = (adjCell.columnIndex-1)*the.cell.height
                   
            local cell = map[adjCell.columnIndex][adjCell.rowIndex]
            
            cell.color[4] = 128
            
            love.graphics.setColor(cell.color)
            love.graphics.rectangle("fill", adjCellX, adjCellY, the.cell.width, the.cell.height)
            
            
            if adjCell == currAdjCells[1][1] then
                love.graphics.rectangle("line", adjCellX, adjCellY, the.cell.width*3, the.cell.height*3)
            end
            
            love.graphics.setColor(255,255,255)
        
        end
    end
    
    -- Detaches the camera. Things drawn after detach() will not be from camera's perspective.
    -- GUI should be drawn after this function is called.
    mapCam:detach()


    if editMode.enabled then
        love.graphics.printf("Edit Mode: Q - Select Country, E - Exit out of edit mode.", 0, 0, the.screen.width, "left")
        love.graphics.printf("Current chosen country: "..editMode.country, 0, 20, the.screen.width, "left")
    else
        if DEBUG then
            love.graphics.printf("E - Enter edit mode.", 0, 0, the.screen.width, "left")
        end
    end
end
