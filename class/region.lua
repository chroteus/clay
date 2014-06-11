Region = Base:subclass("Region")

function Region:initialize(id, color, name, ...)
    self.id = id -- id which will link a region to a country
    self.color = color
    self.name = tostring(name)
    self.convex = true
    
    self.country = countries[self.id]
    
    self.selected = false
    
    local arg = {...}
    
    -- unpaired vertices are needed for drawing and triangulation (Löve2D doesn't accept paired ones)
    if type(arg[1]) == "table" then
        self.vertices = pairVertices(arg[1]) -- pairing for a cleaner code
        self.unpairedVertices = arg[1]
    elseif type(arg[1]) == "number" then
        self.vertices = pairVertices(arg)
        self.unpairedVertices = arg
    else
        error("Region only accepts a table or number as a polygon.")
    end
    
    if not love.math.isConvex(self.unpairedVertices) then
        self.convex = false
        
        if #self.vertices >= 3 then
            self.triangles = love.math.triangulate(self.unpairedVertices)
        end
    end
    
    self.vertRadius = 10
    
    self.border = {} -- filled after all regions are initialized
    self.neighbours = {} -- filled after all regions are initialized
end

function Region:mousereleased(x,y,button)
    if button == "l" then
        if PointWithinShape(self.vertices, mapMouse.x, mapMouse.y) then
            for _,region in pairs(map) do
                region.selected = false
            end
            
            if Player.country == self.country.name or self.country.name == "Sea" then
                self.selected = true
                game.neighbours = self.neighbours                 
            else
                if not editMode.enabled then
                    for _,mapNeighbour in pairs(game.neighbours) do
                        if self.name == mapNeighbour then
                            local battleFunc = function() startBattle(Player.country, self.country.name); battle.attackedRegion = self.name end
                            
                            if not Player:returnCountry():isFoe(self.country.name) then
                                local dbox = DialogBoxes:new(
                                    "Declare war on "..self.country.name.."?",
                                    {"No", function() end},
                                    {"Yes", function() Player:returnCountry():war(self.country.name); battleFunc() end}
                                )
                                
                                dbox:show()
                            else
                                battleFunc()
                            end
                        end
                    end 
                end
            end
        end
    end

    if editMode.enabled then    
        local radius = self.vertRadius/mapCam.scale
        local cp = editMode.currPoint
        local fp = editMode.firstPoint
        
        if button == "l" and not love.keyboard.isDown("lalt") then
            for _,vertex in pairs(self.vertices) do
                if pointCollidesMouse(vertex.x, vertex.y, self.vertRadius) then
                    cp.x,cp.y = vertex.x,vertex.y
                    
                    if fp.x < 0 and fp.y < 0 then
                        fp.x,fp.y = vertex.x,vertex.y
                    end
                end
            end
        end
        
        if button == "r" then
            for i,vertex in ipairs(self.vertices) do
                if pointCollidesMouse(vertex.x, vertex.y, self.vertRadius) then
                    table.remove(self.vertices, i)
                    
                    if #self.vertices > 3 then    
                        self.triangles = love.math.triangulate(self.vertices)
                    end
                
                end
            end
        
            
            if love.keyboard.isDown("lshift") then
                if PointWithinShape(self.vertices, mapMouse.x, mapMouse.y) then
                    DialogBoxes:new(
                        "Delete region?",
                        {"Cancel", function() end},
                        {"Yes", function()
                                    for k,region in pairs(map) do
                                        if region.name == self.name then map[k] = nil end
                                        Regions.generateBorders()
                                    end
                                end
                        }
                    ):show(function() love.mouse.setVisible(false) end)
                end
            end
        end             
    end
end

function Region:draw()
    self.color[4] = 225
    love.graphics.setColor(self.color)
    
    local drawRegion = false
    local camX, camY = mapCam:worldCoords(0,0)
    for _,vertex in pairs(self.vertices) do
        if checkCollision(camX, camY, the.screen.width, the.screen.height, vertex.x, vertex.y, self.vertRadius/mapCam.scale, self.vertRadius/mapCam.scale) then
            drawRegion = true
            break
        end
    end
   
    if drawRegion then
        if #self.unpairedVertices > 2 then
            if self.country.name ~= "Sea" then
                if self.convex then
                    love.graphics.polygon("fill", self.unpairedVertices)
                else
                    for _,triangle in pairs(self.triangles) do
                        love.graphics.polygon("fill", triangle)
                    end
                end
            end
            
            if editMode.enabled then
                if self.country.name == editMode.country then
                    love.graphics.setColor(255,255,255)    
                    love.graphics.polygon("line",self.unpairedVertices)
                end
            else
        
                if PointWithinShape(self.unpairedVertices, mapMouse.x, mapMouse.y) then
                    if self.color[1] >= 128 or self.color[2] >= 128 or self.color[3] >= 128 then
                        love.graphics.setColor(0,0,0,100)
                    else
                        love.graphics.setColor(255,255,255,100)
                    end
                    
                    if self.convex then
                        love.graphics.polygon("fill", self.unpairedVertices)
                    else
                        for _,triangle in pairs(self.triangles) do
                            love.graphics.polygon("fill", triangle)
                        end
                    end
                end
            end

            if self.selected then
                love.graphics.setColor(255,255,255,100)
                if self.convex then
                    love.graphics.polygon("fill", self.unpairedVertices)
                else
                    for _,triangle in pairs(self.triangles) do
                        love.graphics.polygon("fill", triangle)
                    end
                end
                love.graphics.setColor(255,255,255)
            end
            
            for _,neighbour in pairs(game.neighbours) do
                if self.name == neighbour then
                
                    love.graphics.setColor(255,255,255,64)
                    if self.convex then
                        love.graphics.polygon("fill", self.unpairedVertices)
                    else
                        for _,triangle in pairs(self.triangles) do
                            love.graphics.polygon("fill", triangle)
                        end
                    end
                    love.graphics.setColor(255,255,255)
                end
            end
                       
        elseif #self.unpairedVertices == 2 then
            love.graphics.line(self.unpairedVertices)
        end
        
        if editMode.enabled then
            local radius = self.vertRadius/mapCam.scale
            love.graphics.setColor(255,50,50)
            if PointWithinShape(self.unpairedVertices, mapMouse.x, mapMouse.y) then
                for _,vertex in pairs(self.vertices) do
                    if pointCollidesMouse(vertex.x, vertex.y, self.vertRadius) then
                        love.graphics.circle("line", vertex.x, vertex.y, radius+0.2, 100)
                    else
                        love.graphics.circle("line", vertex.x, vertex.y, radius, 100)
                    end
                end
            end
            
            for _,vertex in pairs(self.vertices) do
                if pointCollidesMouse(vertex.x, vertex.y, self.vertRadius) then
                    love.graphics.circle("line", vertex.x, vertex.y, radius+0.2, 100)
                end
            end
        end
                
            
        love.graphics.setColor(255,255,255)
    end
end

function Region:changeOwner(owner)
    if type(owner) == "string" then owner = nameToCountry(owner) end
    
    if type(owner) == "table" then
        self.id = owner.id
        self.color = owner.color
        self.country = owner
    else
        error("Region:changeOwner accepts instance of a country or its name only")
    end
end

Regions = {} -- Table to hold functions which affect all regions.

function Regions.generateNeighbours()
    -- Generating neighbours for regions
    -- NOTE: Must be called AFTER map's regions are loaded.
    -- It is checked if regions share points and add those who share it are added to neighbors table.
    -- Since multiple points can be shared, duplicates are removed later on.
    for _,region in pairs(map) do
        for _,vertex in pairs(region.vertices) do
            for _,regionB in pairs(map) do
                for _,vertexB in pairs(regionB.vertices) do
                    if vertexB.x == vertex.x and vertexB.y == vertex.y then
                        if region.name ~= regionB.name then
                            table.insert(region.neighbours, regionB.name)
                        end
                    end
                end
            end
        end
        
        region.neighbours = removeDuplicates(region.neighbours)
    end
end

function Regions.generateBorders()
    for _,region in pairs(map) do
        region.border = {} -- empty table
        for _,neighbourName in pairs(region.neighbours) do
            local neighbour = getRegion(neighbourName)
            
            if neighbour ~= nil then
                if neighbourName ~= region.name then
                    if neighbour.country.name ~= region.country.name then
                        for _,region_vertex in pairs(region.vertices) do
                            for _,neigh_vertex in pairs(neighbour.vertices) do
                                if region_vertex.x == neigh_vertex.x
                                and region_vertex.y == neigh_vertex.y then
                                    table.insert(region.border, region_vertex.x)
                                    table.insert(region.border, region_vertex.y)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

