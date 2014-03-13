Cell = Base:subclass("Cell")

function Cell:initialize(id, color)
    -- id [Number]: A single digit representing a cell. Used for inserting cells into <map> table according to the id.
    self.id = id
    
    -- color [Table]: Color of the cell. (Captain Obvious to the rescue!)
    self.color = color
    
    -- isSelected [Bool]: If a cell is selected, it is more opaque.
    self.isSelected = false
    
    -- isFaintClone [Bool]: Faint clones turn into "Sea" cells right away in map's update function.
    self.isFaintClone = false
    
    -- adjCells [Table]: A table with information about adjacent cells.
    -- This table will store information about adjacent cells which will be generated in /misc/map.lua
    self.adjCells = {{0,0,0}, 
                     {0,0,0},
                     {0,0,0}}
        
end

function Cell:draw(x, y)
    self.color[4] = 120 -- Set the alpha channel. Makes cell transparent.

    if self.name ~= "Sea" then -- Sea cells shouldn't be drawn as it greatly drops FPS.
        if self.isSelected then
            love.graphics.setColor(self.color) 
            self.color[4] = 220
            love.graphics.rectangle("fill", x, y, the.cell.width, the.cell.height)
            love.graphics.setColor(255,255,255)
       --     love.graphics.rectangle("line", x, y, the.cell.width, the.cell.height)
        else
            love.graphics.setColor(self.color)
            love.graphics.rectangle("fill", x, y, the.cell.width, the.cell.height)
            love.graphics.setColor(255,255,255)
        end
    end
end
