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
    
    self.stats = {
        attack = attack,
        defense = defense,
        hp = hp,
        energy = 100,
    }
    
    self.maxHP = self.stats.hp
    self.maxEnergy = self.stats.energy
    
    self.skills = {
        skills.heal:clone(),
    } 
    
    Cell.initialize(self, self.id, self.color)
end

local soundT = love.filesystem.getDirectoryItems("assets/sounds/attack")

-- Loses HP by subtracting defense variable from the attack.
function Country:loseHP(damage)
    local netDamage = damage - self.stats.defense
    if netDamage < 0 then netDamage = 0 end
    
    local randNum = math.random(#soundT)
    local randSnd = soundT[randNum]
    TEsound.play("assets/sounds/attack/"..randSnd)
    self.stats.hp = self.stats.hp - netDamage
end

function Country:gainHP(amount)
    self.stats.hp = self.stats.hp + amount
    if self.stats.hp > self.maxHP then
        self.stats.hp = self.maxHP
    end
end

function Country:loseEnergy(amount)
    self.stats.energy = self.stats.energy - amount
end


function Country:addSkill(argSkill, order)    
    local order = order or 1
    table.insert(self.skills, order, skills[argSkill]:clone())
    
    local count = 0
    
    for _,skill in pairs(self.skills) do
        if skill.name == skills[argSkill].name then
            count = count + 1
        end
        
        if count > 1 then
            table.remove(self.skills, order) -- Remove last item from table.
        end
    end
end
