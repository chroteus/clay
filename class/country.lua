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
    self.money = 0
    
    self.foes = {}
    self.allies = {}
    self.neutrals = {}
    
    self.isDead = false
    self.deadMessagePrinted = false
    
    self.maxHP = self.hp
    self.maxEnergy = self.energy
    
    self.skills = {
        skills.heal:clone(),
    } 
    
    self.invadeTimer = math.random(3,6)
    
    Cell.initialize(self, self.id, self.name, self.color)
end


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

local numOfInv = 0

function Country:invade(dt)
    -- Used for AI invasions
    self.invadeTimer = self.invadeTimer - dt
    
    if self.invadeTimer <= 0 then
        self.invadeTimer = math.random(3,6)
        if self.name ~= Player.country then
            if not self.isDead then
                for rowIndex, row in ipairs(map) do
                    for columnIndex, cell in ipairs(row) do
                        for _,foe in pairs(self.foes) do
                            if numOfInv == 0 then
                                if strongEnough(self, foe) then
                                    if map[rowIndex][columnIndex].name == self.name then
                                        local randRow = math.random(3)
                                        local randCol = math.random(3)
                                        local adj = adjCellsOf(rowIndex, columnIndex)[randRow][randCol]
                                                            
                                        if map[adj.rowIndex][adj.columnIndex].name == foe.name then
                                            if map[adj.rowIndex][adj.columnIndex].name == Player.country then
                                                msgBox:add(self.name.." took your clay!")
                                            end
                                            
                                            map[adj.rowIndex][adj.columnIndex] = self:clone()
                                            
                                            updateCellCanvas()
                                            numOfInv = numOfInv + 1
                                        end
                                        
                                    --[[
                                    elseif map[rowIndex][columnIndex].name == foe.name then
                                        map[rowIndex][columnIndex] = self:clone()
                                        updateCellCanvas()
                                        numOfInv = numOfInv + 1
                                    end
                                    ]]--
                                    end
                                end
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

function Country:isFoe(name)
    local r = false
    for _,foe in pairs(self.foes) do
        if name == foe.name then
            r = true
        else
            r = false
        end
    end
    
    return r
end

function Country:war(foe)
    if type(foe) == "table" then
        if #foe.foes == 0 then 
            table.insert(foe.foes, self)
        else
            if not foe:isFoe(Player.country) then
                table.insert(foe.foes, self)
            end
        end
        
        if #self.foes == 0 then
            table.insert(self.foes, foe)
        else
            if not self:isFoe(foe.name) then
                table.insert(self.foes, foe)
            end
        end
    else
        error("Country:war method accepts the instance of the country only.")
    end
end

function Country:peace(country)
    local function peace(country)
        if type(country) == "table" then
            if #self.foes > 0 then
                for i,foe in ipairs(self.foes) do
                    if country.name == foe.name then
                        table.remove(self.foes, i)
                    end
                end
                
            end
            if #country.foes > 0 then
                for i,foe in ipairs(country.foes) do
                    if self.name == foe.name then
                        table.remove(country.foes, i)
                    end
                end
            end
            
            msgBox:add(self.name.." signed a peace treaty with "..country.name..".")
        else
            error("Country:peace method accepts the instance of the country only.")
        end
    end
    
    if country.name == Player.country then
        DialogBoxes:new(self.name.." wants to sign a peace treaty with us.",
            {"<< Cancel", function() end}, {"Peace!", function() peace(country) end}
        )
    else
        peace(country)
    end
end

function Country:addMoney(amount)
    self.money = self.money + amount
    
    if self.money + amount < 0 then self.money = 0 end

    if self.name == Player.country then
        Player.money = self.money
    end
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
