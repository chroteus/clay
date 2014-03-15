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
    -- rightImage [Image]: Picture of ball facing to right.
    -- leftImage [Image]: Picture of ball facing to left. 
    self.rightImage = lg.newImage("assets/image/balls/right/"..self.name..".png")
    self.leftImage = lg.newImage("assets/image/balls/left/"..self.name..".png")
    
    -- Minature: A small pixel-art version of the ball.
    self.miniature = lg.newImage("assets/image/miniatures/"..self.name..".png")
    
    self.attack = attack
    self.defense = defense
    self.hp = hp
    self.energy = 100
    
    self.foes = {}
    self.allies = {}
    self.neutrals = {}
    
    self.isDead = false
    self.maxHP = self.hp
    self.maxEnergy = self.energy
    
    self.skills = {
        skills.heal:clone(),
    } 
    
    self.invadeTimer = 5
    self.invadeTimerReset = self.invadeTimer
    
    Cell.initialize(self, self.id, self.color)
end

local numOfInv = 0
local function strongEnough(self, foe)
    local winChance = (self.attack/(foe.defense*5))*100
    
    if winChance > 100 then winChance = 100
    elseif winChance < 1 then winChance = 1
    end
    
    local success = false
    
    math.randomseed(os.time())
    local r = math.random(100)
    
    if winChance >= r then 
        success = true
    else 
        success = false
    end
    
    return success
end
        
function Country:invade(dt)
    -- Used for AI invasions
    self.invadeTimer = self.invadeTimer - dt
    
    -- Total number of clones of self on map. Country becomes dead if it has no cells on the map.
    local selfTotalNo = 0
    
    local hasAccessToFoeLand = true
    
    if self.invadeTimer <= 0 then
        self.invadeTimer = self.invadeTimerReset
        if self.name ~= Player.country then
            for _,foe in pairs(self.foes) do
                for rowIndex, row in ipairs(map) do
                    for columnIndex, cell in ipairs(row) do
                        
                        -- Mechanism to prevent invasions if there are no cells.
                        if map[rowIndex][columnIndex].name == self.name then
                            selfTotalNo = selfTotalNo + 1
                        end
                    
                        if numOfInv == 0 then
                            if strongEnough(self, foe) then
                                if selfTotalNo > 0 then
                                    if map[rowIndex][columnIndex].name == self.name then
                                        local randRow = math.random(3)
                                        local randCol = math.random(3)
                                        local adj = adjCellsOf(rowIndex, columnIndex)[randRow][randCol]
                                                            
                                        if map[adj.rowIndex][adj.columnIndex].name == foe.name then
                                            map[adj.rowIndex][adj.columnIndex] = self:clone()
                                            msgBox:add(self.name.." took your clay!")
                                            updateCellCanvas()
                                            numOfInv = numOfInv + 1
                                        else
                                            hasAccessToFoeLand = false
                                        end

                                    elseif map[rowIndex][columnIndex].name == foe.name then
                                        if not hasAccessToFoeLand then
                                            map[rowIndex][columnIndex] = self:clone()
                                            msgBox:add(self.name.." took your clay!")
                                            updateCellCanvas()
                                            numOfInv = numOfInv + 1
                                        end
                                    end
                                end
                            else -- if not strong enough
                                if msgBox.list[#msgBox.list].str ~= self.name.." tried to attack you but failed!" then
                                    msgBox:add(self.name.." tried to attack you but failed!")
                                end
                                
                                break
                            end
                        end
                    end         
                end
            end
        end
        numOfInv = 0
    end
end

local soundT = love.filesystem.getDirectoryItems("assets/sounds/attack")
function Country:loseHP(damage)
    local netDamage = damage - self.defense
    if netDamage < 0 then netDamage = 0 end
    
    local randNum = math.random(#soundT)
    local randSnd = soundT[randNum]
    TEsound.play("assets/sounds/attack/"..randSnd)
    self.hp = self.hp - netDamage
end

function Country:gainHP(amount)
    self.hp = self.hp + amount
    if self.hp > self.maxHP then
        self.hp = self.maxHP
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
