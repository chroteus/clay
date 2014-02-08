Cell = class("Cell")

function Cell:initialize(id, color)
    -- id [String or Number]: A single character representing a cell. Used for drawing cells on map.
    self.id = id
    
    -- color [Table]: Color of a cell. (Captain Obvious to the rescue! :3)
    self.color = color
    
    -- isSelected [Bool]: If a cell is selected, it has a line around it and is more opaque.
    self.isSelected = false
    
    -- adjCells [Table]: A table with information about adjacent cells.
    -- This table will store information about adjacent cells which will be generated in initMap() function in /misc/map.lua
    self.adjCells = {{0,0,0}, 
                     {0,0,0},
                     {0,0,0}}
end

function Cell:draw(x, y)

    self.color[4] = 80 -- Set the alpha channel. Makes cell transparent.

    if self.name ~= "Sea" then -- Sea cells shouldn't be drawn as it drops FPS.
        if self.isSelected then self.color[4] = 180 end
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", x, y, the.cell.width, the.cell.height)
        love.graphics.setColor(255,255,255)
        if self.isSelected then
            love.graphics.rectangle("line", x, y, the.cell.width, the.cell.height)
        end
    end
end

function Cell:clone()
    -- Since we will edit individual cells, cells will be cloned and then edited,
    -- so that changes applied to one cell, won't be seen in another.
    local t = {}
    for k,v in pairs(self) do
        t[k] = v
    end
      
    -- For loop above clones variables only. We also need other methods for clones to work properly.
    t.draw = function(self,x,y) Cell.draw(self,x,y) end 
    
    if self:isInstanceOf(Country) then
        t.loseHP = function(self, damage) Country.loseHP(self, damage) end
        t.loseEnergy = function(self, amount) Country.loseEnergy(self, amount) end
        t.gainHP = function(self, amount) Country.gainHP(self, amount) end
        t.addSkill = function(self, argSkill) Country.addSkill(self, argSkill) end
    end
    
    return t
end
