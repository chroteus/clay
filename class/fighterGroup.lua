-- like arena, manages fighters, but unlike Arena, deals with
-- fighters' position
FighterGroup = class "FighterGroup"

function FighterGroup:initialize(fighters)
    self.fighters = fighters or {}
end

function FighterGroup:setPos(x,y)
    self.x = x
    self.y = y
    
    self:formation(5)
end

function FighterGroup:add(fighter)
    table.insert(self.fighters, fighter)
end

function FighterGroup:formation(maxWidth, noAnim)
    assert(self.x and self.y, "Position for group not set")
    
    local noAnim = noAnim or false
    
    local xPos = 0
    local yPos = 0
    
    for _,fighter in pairs(self.fighters) do
        print(fighter:isInstanceOf(Fighter))
        fighter:setPos(self.x + (fighter.width  * xPos),
                       self.y + (fighter.height * yPos))
                       
        xPos = xPos + 1
        if xPos > maxWidth then yPos = yPos + 1; xPos = 0 end
        
        print(fighter.x)
    end
end

function FighterGroup:update(dt)
    for _,fighter in pairs(self.fighters) do
        fighter:update(dt)
    end
end

function FighterGroup:draw()
    for _,fighter in pairs(self.fighters) do
        fighter:draw()
    end
end
