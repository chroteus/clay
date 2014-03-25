Cell = Base:subclass("Cell")

function Cell:initialize(id, name, color)
    -- id [Number]: A single digit representing a cell. Used for inserting cells into <map> table according to the id.
    self.id = id
    
    -- color [Table]: Color of the cell. (Captain Obvious to the rescue!)
    self.color = color
    
    -- name [String]: Name of the cell
    self.name = name
    
    -- isSelected [Bool]: If a cell is selected, it is more opaque.
    self.isSelected = false
    
    -- isFaintClone [Bool]: Faint clones turn into "Sea" cells right away in map's update function.
    self.isFaintClone = false
    
    -- adjCells [Table]: A table with information about adjacent cells.
    self.adjCells = {{0,0,0}, 
                     {0,0,0},
                     {0,0,0}}
        
end

function Cell:cellClone()
    -- clones only the needed stuff so that memory won't be occupied for no reason.
    local t = {}
    t.id = self.id
    t.name = self.name
    t.color = self.color
    t.isSelected = self.isSelected
    
    t.draw = function(self, rowIndex, columnIndex) Cell.draw(self, rowIndex, columnIndex) end
    return t
end

function Cell:draw(rowIndex, columnIndex)
    local x = (rowIndex-1)*the.cell.width
    local y = (columnIndex-1)*the.cell.height
    
    self.color[4] = 180 -- Set the alpha channel. Makes cell transparent.

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
            else
                self.color[4] = 150
            end
            love.graphics.rectangle("fill", x+1, y+1, the.cell.width-1, the.cell.height-1)
            love.graphics.setColor(255,255,255)
        end
    end
end
