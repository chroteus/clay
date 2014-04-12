Region = Base:subclass("Region")

function Region:initialize(color, name, ...)
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
end

function Region:draw()
    love.graphics.setColor(self.color)
   
    if self.convex then
        love.graphics.polygon("fill", self.vertices)
    else
        for _,triangle in pairs(self.triangles) do
            love.graphics.polygon("fill", triangle)
        end
    end
         
    love.graphics.setColor(255,255,255)
end
