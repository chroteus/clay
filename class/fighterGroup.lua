-- like arena, manages fighters, but unlike Arena, deals with
-- fighters' position
FighterGroup = class "FighterGroup"

function FighterGroup:initialize(fighters)
    local fighters = fighters or {}
    self.fighters = {}
    
    for k,fighter in pairs(fighters) do
        table.insert(self.fighters, FighterAI(fighter))
    end
    
    fighters = nil
end

function FighterGroup:setPos(x,y)
    self.x = x
    self.y = y
    
    self:formation(5)
end

function FighterGroup:getWidth()
    local smallestX,biggestX = math.huge,0
    
    for _,fighter in pairs(self.fighters) do
        print(fighter.x)
        if fighter.x < smallestX then
            smallestX = fighter.x
        end
        
        if fighter.x > biggestX then
            biggestX = fighter.x+fighter.width
        end
    end
    
    return biggestX-smallestX
end

function FighterGroup:getHeight()
    local smallestY,biggestY = math.huge,0
    
    for _,fighter in pairs(self.fighters) do
        if fighter.y < smallestY then
            smallestY = fighter.y
        end
        
        if fighter.y > biggestY then
            biggestY = fighter.y+fighter.width
        end
    end
    
    return biggestY-smallestY
end
    
function FighterGroup:getBBox()
    return self.x, self.y, self:getWidth(), self.getHeight()
end

function FighterGroup:add(fighter)
    table.insert(self.fighters, fighter)
end

function FighterGroup:formation(maxWidth, noAnim)
    assert(self.x and self.y, "Position for group not set")
    local maxWidth = maxWidth or 5
    local noAnim = noAnim or false
    
    local xPos = 0
    local yPos = 0
    
    for _,fighter in pairs(self.fighters) do
        fighter:setPos(self.x + (fighter.width  * xPos),
                       self.y + (fighter.height * yPos))
                       
        xPos = xPos + 1
        if xPos > maxWidth then yPos = yPos + 1; xPos = 0 end
        
    end
end

function FighterGroup:lookAt(x,y, arg)
    for _,fighter in pairs(self.fighters) do
        fighter:lookAt(x,y, arg)
    end
end

function FighterGroup:addEnemy(enemy)
    for _,fighter in pairs(self.fighters) do
        fighter:addEnemy(enemy)
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
