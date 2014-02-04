require "class.cell"

Country = Cell:subclass("Country")

-- WARNING! The name of miniature and ball image should be the same as Country's name!
-- Example: If we have an instance of Country with name variable "Ukraine",
-- both balls and miniatures folder should have a Ukraine.png image.

local lg = love.graphics

function Country:initialize(name, color, attack, defense, hp)
    self.id = nil -- Id is defined in for-loop in coutries.lua
    self.name = name
    self.color = color
    
    -- Ball Images: If one of them is not present, one of the other images is used.
    -- Image [Image]: Image to be used in battles and such. Frontal view.
    -- rightImage [Image]: Picture of ball facing to right.
    -- leftImage [Image]: Picture of ball facing to left. 
    self.image = lg.newImage("assets/image/balls/"..self.name..".png")
    self.rightImage = lg.newImage("assets/image/balls/right/"..self.name..".png")
    self.leftImage = lg.newImage("assets/image/balls/left/"..self.name..".png")
    
    -- Minature: A small pixel-art version of the ball.
    self.miniature = lg.newImage("assets/image/miniatures/"..self.name..".png")
    
    self.attack = attack
    self.defense = defense
    self.hp = hp
    self.energy = 100
    
    -- A table which holds all skills a country might have. A country cannot have more than 3 skills.
    self.skills = {} 
    
    Cell.initialize(self, self.id, self.color)
end

-- Loses HP by subtracting defense variable from the attack.
function Country:loseHP(damage)
    local netDamage = damage - self.defense
    if netDamage < 0 then netDamage = 0 end

    self.hp = self.hp - netDamage
end

function Country:loseEnergy(amount)
    self.energy = self.energy - amount
end


function Country:addSkill(skill)
    table.insert(self.skills, skill)
end
