Cell = class("Cell")

function Cell:initialize(id, color)
    -- id [String or Number]: A single character representing a cell. Used for drawing cells on map.
    self.id = id
    
    -- color [Table]: Color of a cell. (Captain Obvious to the rescue! :3)
    self.color = color
end

function Cell:draw(x, y)
    self.color[4] = 64 -- Sets the alpha channel. Makes cell transparent.
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", x, y, the.cell.width, the.cell.height)
    love.graphics.setColor(255,255,255)
end
