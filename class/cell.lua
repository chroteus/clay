Cell = class("Cell")

function Cell:initialize(id, color)
    -- id [String or Number]: A single character representing a cell. Used for drawing cells on map.
    self.id = id
    
    -- color [Table]: Color of a cell. (Captain Obvious to the rescue! :3)
    self.color = color
    
    -- adjCells [Table]: A table with information about adjacent cells.
    -- This table is filled with information about adjacent cells in initMap() function in /misc/map.lua
    self.adjCells = {} 
end

function Cell:draw(x, y)

    self.color[4] = 64 -- Sets the alpha channel. Makes cell transparent.

    if self.name ~= "Sea" then -- Sea cells shouldn't be drawn as it drops FPS.
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", x, y, the.cell.width, the.cell.height)
        love.graphics.setColor(255,255,255)
    end
end
