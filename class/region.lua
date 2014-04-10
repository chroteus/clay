Region = Base:subclass("Region")

function Region:initialize(id, color, name, ...)
    self.id = id
    self.color = color
    self.name = tostring(name)
    
    self.vertices = {...}
end

function Region:draw()
    love.graphics.setColor(self.color)
    love.graphics.polygon("fill", self.vertices)
    love.graphics.setColor(255,255,255)
end
