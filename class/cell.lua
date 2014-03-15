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

function Cell:draw(rowIndex, columnIndex)
    local x = (rowIndex-1)*the.cell.width
    local y = (columnIndex-1)*the.cell.height
    
    self.color[4] = 150 -- Set the alpha channel. Makes cell transparent.

    if self.name ~= "Sea" then -- Sea cells shouldn't be drawn as it greatly drops FPS.
        if self.isSelected then
            love.graphics.setColor(self.color) 
            self.color[4] = 220
            love.graphics.rectangle("fill", x, y, the.cell.width, the.cell.height)
            love.graphics.setColor(255,255,255)
        else
            local a = adjCellsOf(rowIndex, columnIndex)
            
            local top = {left = a[1][1], middle = a[2][1], right = a[3][1]}
            local middle = {left = a[1][2], middle = a[2][2], right = a[3][2]}
            local bottom = {left = a[1][3], middle = a[2][3], right = a[3][3]}
            
            local function check(pos)
                if map[pos.rowIndex][pos.columnIndex].name ~= self.name then return true end
            end
            
            love.graphics.setColor(self.color)
            
            if check(top.middle) or check(bottom.middle) or check(middle.left) or check(middle.right) then
                self.color[4] = 220
                love.graphics.setColor(self.color)
                love.graphics.rectangle("fill", x, y, the.cell.width, the.cell.height)
            else
                self.color[4] = 150
                love.graphics.rectangle("fill", x, y, the.cell.width, the.cell.height)
            end
            
            love.graphics.setColor(255,255,255)
        end
    end
end
