Region = Base:subclass("Region")

function Region:initialize(id, color, name, ...)
    self.id = id -- id which will link a region to a country
    self.color = color
    self.name = tostring(name)
    self.convex = true
    
    self.country = countries[self.id]
    
    self.selected = false
    
    local arg = {...}
    
    if type(arg[1]) == "table" then
        self.vertices = arg[1]
    else
        self.vertices = arg
    end
    
    if not love.math.isConvex(self.vertices) then
        self.convex = false
        
        if #self.vertices >= 6 then
            self.triangles = love.math.triangulate(self.vertices)
        end
    end
    
    self.pairedVertices = pairVertices(self.vertices)
    self.vertRadius = 5
    
    
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
                    startBattle(Player.country, self.country.name)
                    battle.attackedRegion = self.name
                end
            end
        end
    end

    if editMode.enabled then    
        local radius = self.vertRadius/mapCam.scale
        local cp = editMode.currPoint
        local fp = editMode.firstPoint
        
        if button == "l" then
            for _,vertex in pairs(self.pairedVertices) do
                if checkCollision(vertex[1],vertex[2],radius*2,radius*2, mapMouse.x,mapMouse.y,1,1) then
                    cp.x,cp.y = vertex[1],vertex[2]
                    
                    if fp.x > 0 then
                        if editMode.polFin then
                            fp.x,fp.y = vertex[1],vertex[2]
                        end
                    end
                end
            end
        end
        
        if button == "r" then
            for i,vertex in ipairs(self.pairedVertices) do
                if checkCollision(vertex[1],vertex[2],radius*2,radius*2, mapMouse.x,mapMouse.y,1,1) then
                    table.remove(self.pairedVertices, i)
                    table.remove(self.vertices, i*2)
                    table.remove(self.vertices, (i*2)-1)
                    
                    if #self.pairedVertices > 3 then    
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
    self.color[4] = 80
    love.graphics.setColor(self.color)
    
   
    if #self.pairedVertices > 2 then
        if self.country.name ~= "Sea" then
            if self.convex then
                love.graphics.polygon("fill", self.vertices)
            else
                for _,triangle in pairs(self.triangles) do
                    love.graphics.polygon("fill", triangle)
                end
            end
        end
        
        if editMode.enabled then
            love.graphics.setColor(255,255,255)    
            love.graphics.polygon("line",self.vertices)
        else
            if self.country.name ~= "Sea" then
                self.color[4] = 255
                love.graphics.setColor(self.color)
                love.graphics.polygon("line",self.vertices)
                
                if PointWithinShape(self.vertices, mapMouse.x, mapMouse.y) then
                    love.graphics.setColor(255,255,255,64)
                else
                    love.graphics.setColor(255,255,255,32)
                end
                
                love.graphics.polygon("line",self.vertices)
            end
        end
        
        if PointWithinShape(self.vertices, mapMouse.x, mapMouse.y) then
            love.graphics.setColor(255,255,255,32)
            if self.convex then
                love.graphics.polygon("fill", self.vertices)
            else
                for _,triangle in pairs(self.triangles) do
                    love.graphics.polygon("fill", triangle)
                end
            end
            love.graphics.setColor(255,255,255)
        end
        
        if self.selected then
            love.graphics.setColor(255,255,255,64)
            if self.convex then
                love.graphics.polygon("fill", self.vertices)
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
                    love.graphics.polygon("fill", self.vertices)
                else
                    for _,triangle in pairs(self.triangles) do
                        love.graphics.polygon("fill", triangle)
                    end
                end
                love.graphics.setColor(255,255,255)
            end
        end
                   
    elseif #self.pairedVertices == 2 then
        love.graphics.line(self.vertices)
    end
    
    if editMode.enabled then
        love.graphics.setColor(255,50,50)
        if PointWithinShape(self.vertices, mapMouse.x, mapMouse.y) then
            local radius = self.vertRadius/mapCam.scale
            for _,vertex in pairs(self.pairedVertices) do
                if checkCollision(vertex[1],vertex[2],radius*2,radius*2, mapMouse.x,mapMouse.y,1,1) then
                    love.graphics.circle("line", vertex[1], vertex[2], radius+0.2, 100)
                else
                    love.graphics.circle("line", vertex[1], vertex[2], radius, 100)
                end
            end
        end
    end
            
        
    love.graphics.setColor(255,255,255)
end
