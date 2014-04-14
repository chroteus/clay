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
        self.triangles = love.math.triangulate(self.vertices)
    end
    
    self.pairedVertices = editMode.pair(self.vertices)
    self.vertRadius = 2 
end

function Region:mousereleased(x,y,button)
    if editMode.enabled then
        local radius = self.vertRadius
        local cp = editMode.currPoint
        local fp = editMode.firstPoint
        
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
end

function Region:draw()
    self.color[4] = 128
    love.graphics.setColor(self.color)
   
    if self.convex then
        love.graphics.polygon("fill", self.vertices)
    else
        for _,triangle in pairs(self.triangles) do
            love.graphics.polygon("fill", triangle)
        end
    end
    
    if editMode.enabled then
        love.graphics.setColor(255,255,255)    
        
        local radius = self.vertRadius
        for _,vertex in pairs(self.pairedVertices) do
            if checkCollision(vertex[1],vertex[2],radius*2,radius*2, mapMouse.x,mapMouse.y,1,1) then
                love.graphics.circle("fill", vertex[1], vertex[2], radius+1, 100)
            else
                love.graphics.circle("line", vertex[1], vertex[2], radius, 100)
            end
        end
        
        love.graphics.polygon("line",self.vertices)
    else
        self.color[4] = 255
        love.graphics.polygon("line",self.vertices)
        love.graphics.setColor(255,255,255,64)
        love.graphics.polygon("line",self.vertices)
    end
        
    love.graphics.setColor(255,255,255)
end
