local infoBox = {}
infoBox.delay = 0.5
infoBox.delayReset = infoBox.delay
infoBox.width = 150
infoBox.height = 200

function infoBox:update(dt, vertices)
    if PointWithinShape(vertices, mapMouse.x, mapMouse.y) then
        self.delay = self.delay - dt
        if self.delay <= 0 then
            self.show = true
        end
    else
        self.show = false
        self.delay = self.delayReset
    end
end

function infoBox:draw(name, countryName)
    if self.show then
        guiRect(the.mouse.x, the.mouse.y, self.width, self.height)
        love.graphics.printf(countryName, the.mouse.x+5, the.mouse.y+5, self.width, "left")
    end
end
        
Region = Base:subclass("Region")

function Region:initialize(id, color, name, ...)
    self.id = id -- id which will link a region to a country
    self.color = color
    self.name = tostring(name)
    self.convex = true
        
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
    self.vertRadius = 1
end

function Region:update(dt)
    infoBox:update(dt, self.vertices)
end

function Region:mousereleased(x,y,button)
    if editMode.enabled then
    
        local radius = self.vertRadius
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
        end
    end
end

function Region:draw()
    self.color[4] = 128
    love.graphics.setColor(self.color)
   
    if #self.pairedVertices > 2 then
        if self.convex then
            love.graphics.polygon("fill", self.vertices)
        else
            for _,triangle in pairs(self.triangles) do
                love.graphics.polygon("fill", triangle)
            end
        end
        
        if editMode.enabled then
            love.graphics.setColor(255,255,255)    
            love.graphics.polygon("line",self.vertices)
        else
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
                   
    elseif #self.pairedVertices == 2 then
        love.graphics.line(self.vertices)
    end
    
    if editMode.enabled then
        local radius = self.vertRadius
        for _,vertex in pairs(self.pairedVertices) do
            if checkCollision(vertex[1],vertex[2],radius*2,radius*2, mapMouse.x,mapMouse.y,1,1) then
                love.graphics.circle("fill", vertex[1], vertex[2], radius+1, 100)
            else
                love.graphics.circle("line", vertex[1], vertex[2], radius, 100)
            end
        end
    end
            
        
    love.graphics.setColor(255,255,255)
end

function Region:drawInfoBox()
    -- info box shouldn't be scaled by map cam, and thus is called after mapCam:detach()
    infoBox:draw(self.name, countries[self.id].name)
end
