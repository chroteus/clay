require "objects.countries"

mapNewGame = false

map = {}
mapW = 10800
mapH = 4480
mapImgScale = 2700/10800

function initMap()
    game.seaId = 0 -- used to give id to sea regions

    if not mapNewGame then
        loadMap()
    else
        createMap()
    end
    
    game.finishedLoading = false
    game.neighbours = {} -- adjacent cells of the selected cell.

    -----------------------
    --Edit Mode variables--
    
    editMode = {
        enabled = false,
        country = "Ukraine", -- Selected country. Paints this country on map.
        buttons = {},
        
        currPoint = {
            x = -10,
            y = -10,
        },
        
        lastPoint = {
            x = -5,
            y = -5
        },
        
        prevLastPoint = {
            x = -30,
            y = -30,
        },
        
        firstPoint = {
            x = -20,
            y = -20,
        },
        
        fpActive = false, -- first point
            
        radius = 4,
        
        currPolygon = {},
        
        polFin = false,
        
    }
    
    function editMode.resetPoints()
        local fp = editMode.firstPoint
        local cp = editMode.currPoint
        local lp = editMode.lastPoint
        local plp = editMode.prevLastPoint
        
        fp.x,fp.y = -10,-10
        cp.x,cp.y = -20,-20
        lp.x,lp.y = -30,-30
        plp.x,plp.y = -40,-40
    end

    function editMode.pair() pairVertices(editMode.currPolygon) end
    
    Regions.generateNeighbours()
    Regions.generateBorders()

    -- Map images "stitching"
    local t = #love.filesystem.getDirectoryItems("assets/image/map")
    mapImgTable = {}
    
    for i=1,t do
        mapImgTable[i] = love.graphics.newImage("assets/image/map/"..i..".jpg")
    end
    
    local width,height = 2700,1120 --mapImgTable[1]:getWidth(),mapImgTable[1]:getHeight()
    
    function drawMapImg()
        local xOrder = -1
        local yOrder = 0
            
        for i,img in ipairs(mapImgTable) do
            xOrder = xOrder + 1
            love.graphics.draw(img, xOrder*width, yOrder*height)
            
            if i % 4 == 0 then
                yOrder = yOrder + 1
                xOrder = -1
            end
        end
    end
    
    -- Camera
    mapCam = Camera(mapW*mapImgScale/2, mapH*mapImgScale/2)
    

    local x1,y1 = 1,1
    local x2, y2 = mapW*mapImgScale-3, mapH*mapImgScale-3
    mapCam:setBounds(x1,y1, x2,y2)
    mapCam:zoomTo(1.5)

    mapMouse = {}
    mapMouse.x, mapMouse.y = mapCam:mousepos()
end         

function enteredMap()
    -- Camera isn't limited by borders if true.
    mapBorderCheck = true
end


function updateMap(dt)
    mapCam:update()
    -- Converting camera to mouse coordinates.
    mapMouse.x, mapMouse.y = mapCam:mousepos()
    
    
    for _,country in pairs(countries) do
        if #country.foes > 0 then
            country:invade(dt)
        end
    end
    
    ---------------------
    --Moving the camera--
    local cameraSpeed = 600/mapCam.scale
    local borderSize = 2
    if love.keyboard.isDown("d") or the.mouse.x > the.screen.width-borderSize then
        mapCam:setX(mapCam.x + cameraSpeed*dt)
    elseif  love.keyboard.isDown("a") or the.mouse.x < borderSize then
        mapCam:setX(mapCam.x - cameraSpeed*dt)
    end
    
    if love.keyboard.isDown("s") or the.mouse.y > the.screen.height-borderSize then 
        mapCam:setY(mapCam.y + cameraSpeed*dt)
    elseif love.keyboard.isDown("w") or the.mouse.y < borderSize then
        mapCam:setY(mapCam.y - cameraSpeed*dt)
    end

    --------------
    --Lımit zoom--

    if not DEBUG then
        if mapCam.scale < 1.5 then
            mapCam.scale = 1.5
        elseif mapCam.scale > 5 then
            mapCam.scale = 5
        end
    end
    
    -------------
    --Edit Mode--
    
    if editMode.enabled then
        local fp = editMode.firstPoint
        local radius = editMode.radius/mapCam.scale
        
        if pointCollidesMouse(fp.x, fp.y, 5) then
            editMode.fpActive = true
        else
            editMode.fpActive = false
        end
        
        -- point movement
        local radius = 10
        if love.mouse.isDown("l") and love.keyboard.isDown("lalt") then
            for _,region in pairs(map) do
                for i,vertex in ipairs(region.vertices) do
                    if pointCollidesMouse(vertex.x, vertex.y) then
                        vertex.x,vertex.y = mapCam:mousepos()
                    end
                end
            end
        end
    end
    
    -- loader
    if not game.finishedLoading then
        loader.update()
    end
end

function mousepressedMap(x, y, button)
    --------------
    --Zooming in--
    
    if button == "wu" then
        Timer.tween(0.3, mapCam, {scale = mapCam.scale + 0.1*mapCam.scale}, "out-quad")
    elseif button == "wd" then
        if mapCam.scale > 1.5 then
            Timer.tween(0.3, mapCam, {scale = mapCam.scale - 0.1*mapCam.scale}, "out-quad")
        end
    end
end

function mousereleasedMap(x,y,button)
    local fp = editMode.firstPoint
    local cp = editMode.currPoint
    local lp = editMode.lastPoint
    local plp = editMode.prevLastPoint

    if editMode.enabled then
        
        -- todo after movement of the point
        if button == "l" and love.keyboard.isDown("lalt") then
            for _,region in pairs(map) do            
                for _,vertex in pairs(region.vertices) do
                    vertex.x,vertex.y = math.round(vertex.x, 1), math.round(vertex.y, 1)
                end
                
                region.triangles = love.math.triangulate(region.unpairedVertices)
            end
        end
        
        local radius = editMode.radius/mapCam.scale
        
        if button == "l" and not love.keyboard.isDown("lalt") then
            if pointCollidesMouse(fp.x, fp.y, 5) then
                cp.x, cp.y = fp.x, fp.y
                
                if #editMode.currPolygon >= 6 then
                    local country = nameToCountry(editMode.country)
                    
                    local function dboxFunc()
                        table.insert(map, Region(country.id, country.color, InputDBoxText, editMode.currPolygon))
                        
                        editMode.currPolygon = {}
                        editMode.resetPoints()
                        Regions.generateBorders()
                    end
                    
                    local dbox = DialogBoxes:newInputDBox(20, function() dboxFunc() end)
                    
                    if editMode.country == "Sea" then
                        game.seaId = game.seaId + 1
                        table.insert(map, Region(1, countries[1].color, "sea"..game.seaId, editMode.currPolygon))
                        
                        --Regions.generateBorders()
                        editMode.currPolygon = {}
                        editMode.resetPoints()
                    else
                        dbox:show(function() love.mouse.setVisible(false) end)
                    end
                    
                    editMode.polFin = true
                end
                
            else
                cp.x, cp.y = math.round(mapMouse.x, 1), math.round(mapMouse.y, 1)
            end
            
            plp.x, plp.y = lp.x, lp.y
            lp.x, lp.y = cp.x, cp.y
            
        elseif button == "r" then
            if pointCollidesMouse(fp.x, fp.y, 5) then
                editMode.currPolygon = {}
                editMode.resetPoints()
            end
            
            if #editMode.currPolygon >= 2 then
                table.remove(editMode.currPolygon)
                table.remove(editMode.currPolygon)
                
                lp.x, lp.y = plp.x, plp.y
                cp.x, cp.y = lp.x, lp.y
            end
        end
    end
    
    for _,region in pairs(map) do
        region:mousereleased(x,y,button)
    end
    
    
    if editMode.enabled then
        if button == "l" and not love.keyboard.isDown("lalt") then
           if not editMode.polFin then
                table.insert(editMode.currPolygon, cp.x)
                table.insert(editMode.currPolygon, cp.y)
            end
        end
        
        editMode.polFin = false
    end
end

function drawMap()
    love.graphics.setBackgroundColor(110, 175, 177)

    local drawSelectRect = true
    
    -- Attaches a camera. Everything from now on will be drawn from camera's perspective.
    mapCam:attach()
    
    love.graphics.push()
    love.graphics.scale(mapImgScale)
    --love.graphics.draw(mapImg, -1,-1)
    drawMapImg()
    love.graphics.pop()
    
    love.graphics.setLineWidth(0.2)
    for _,region in pairs(map) do
        region:draw()
    end
    
    -- EDITOR
    love.graphics.setLineWidth(1)
    if editMode.enabled then
        love.graphics.setLineWidth(2/mapCam.scale)
        
        local radius = editMode.radius/mapCam.scale
        local lp = editMode.lastPoint
        local cp = editMode.currPoint
        local fp = editMode.firstPoint
        
       -- love.graphics.setColor(20,20,200)
        love.graphics.setColor(255,255,255)
        love.graphics.circle("fill", lp.x, lp.y, radius)
        love.graphics.circle("fill", cp.x, cp.y, radius)        
        

        if #editMode.currPolygon >= 4 then -- at least 2 vertices are needed to draw a line
            love.graphics.setColor(0,0,0)
            love.graphics.setLineWidth(6/mapCam.scale)
            love.graphics.line(editMode.currPolygon)
            love.graphics.setColor(255,255,255)
            love.graphics.setLineWidth(4.5/mapCam.scale)
            love.graphics.line(editMode.currPolygon)
        end
        
        local t = pairVertices(editMode.currPolygon)
        for _,vertex in pairs(t) do
            love.graphics.circle("fill", vertex.x, vertex.y, radius)
        end
        
        love.graphics.setColor(255,255,255)
        
        if lp.x > 0 then   
            love.graphics.line(lp.x,lp.y, cp.x,cp.y)
            
        end
        
        if cp.x > 0 then
            if #editMode.currPolygon > 0 then
                love.graphics.setColor(0,0,0)
                love.graphics.setLineWidth(6/mapCam.scale)
                love.graphics.line(cp.x,cp.y, mapMouse.x, mapMouse.y)
                love.graphics.setColor(255,255,255)
                love.graphics.setLineWidth(4.5/mapCam.scale)
                love.graphics.line(cp.x,cp.y, mapMouse.x, mapMouse.y)
            end
        end
        
        love.graphics.setColor(255,0,0)
        
        if not editMode.fpActive then
            love.graphics.circle("fill", fp.x, fp.y, radius)    
        else
            love.graphics.circle("fill", fp.x, fp.y, radius*2)
        end
        
        love.graphics.setColor(225,225,225)
    else -- if not editMode
        love.graphics.setLineWidth(1)
    end
        
    -- Detaches the camera. Things drawn after detach() will not be from camera's perspective.
    -- GUI should be drawn after this function is called. (or in game's draw func after drawMap())
    mapCam:detach()
    
    local radius = 4
    love.graphics.setColor(100,100,100)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", the.mouse.x, the.mouse.y, radius, 100)
    love.graphics.setLineWidth(1) 
    love.graphics.setColor(255,255,255)
    love.graphics.circle("fill", the.mouse.x, the.mouse.y, radius, 100)
end
