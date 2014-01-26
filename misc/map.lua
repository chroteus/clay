require "objects.countries"

function initMap()
    local widthLimit = the.screen.width / the.cell.width    -- Width and height limit are used 
    local heightLimit = the.screen.height / the.cell.height -- to limit the generation of cells.

    local tiledMap = require "assets.maps.default.mapData" -- Returns a table created by Tiled.
    mapData = tiledMap.layers[2].data -- tiledMap has lots of unneeded stuff, so we choose the needed data, the map itself.
    
    map = {}
    
    -------------------------------------
    --Convert tiled map into a 2D array--
    -------------------------------------
    
    local rowNumber = #mapData/tiledMap.width
    for i=1,rowNumber do map[i] = {} end
    
    local columnIndex, rowIndex = 1,1
    
    for i,num in pairs(mapData) do
        map[columnIndex][rowIndex] = num
        rowIndex = rowIndex + 1
        if i % tiledMap.width == 0 then
            columnIndex = columnIndex + 1
            rowIndex = 1
        end
    end 
    
    -------------------------------------------------------
    --Insert countries according to number and country id--
    -------------------------------------------------------
    for columnIndex,column in pairs(map) do
        for rowIndex,num in pairs(column) do
            table.remove(column, rowIndex)
            table.insert(column, rowIndex, countries[num]:clone())
        end
    end
    
    -------------------------------------------
    --Generate adjacent cells table for cells--
    -------------------------------------------
    map[0] = {}
    for i=0,tiledMap.width do map[0][i] = countries[1] end
    for i=0,tiledMap.height do map[i][0] = countries[1] end
            
    for columnIndex,column in pairs(map) do
        for rowIndex,cell in pairs(column) do
            if columnIndex ~= 0 then
                if rowIndex ~= 0 then    
                    for t=1,3 do
                        for i=1,3 do
                            for c=-1,1 do
                                if rowIndex+c < 101 then
                                    if columnIndex+c < 73 then
                                        cell.adjCells[t][i] = map[columnIndex+c][rowIndex+c]
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    mapCam = Camera(the.screen.width/2, the.screen.height/2)
    mapImg = love.graphics.newImage("assets/image/map.png")
    gridImg = love.graphics.newImage("assets/image/grid.png")
end

function updateMap(dt)
    ---------------------
    --Moving the camera--
    ---------------------
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
    
    
    -------------------------
    --Limiting the movement--
    -------------------------
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
    -----------------
    if mapCam.scale < 1 then
        mapCam.scale = 1
    elseif mapCam.scale > 2.5 then
        mapCam.scale = 2.5
    end
end

function mousepressedMap(x, y, button)
    --------------
    --Zooming in--
    --------------
       
    if button == "wu" then
        Timer.tween(0.3, mapCam, {scale = mapCam.scale + 0.1}, "out-quad")
    elseif button == "wd" then
        if mapCam.scale > 1 then
            Timer.tween(0.3, mapCam, {scale = mapCam.scale - 0.1}, "out-quad")
        end
    end
    
    if button == "l" then
        for columnIndex,column in pairs(map) do
            for rowIndex,cell in pairs(column) do
                local cellX = (rowIndex-1)*the.cell.width -- Cell's x value
                local cellY = (columnIndex-1)*the.cell.height -- Y value
                cell.isSelected = false
                if checkCollision(x,y,1,1, cellX,cellY,the.cell.width,the.cell.height) then
                    cell.isSelected = true
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
    
    -- Detaches the camera. Things drawn after this will not be from camera's perspective.
    -- GUI should be drawn after this function is called.
    mapCam:detach()
end
