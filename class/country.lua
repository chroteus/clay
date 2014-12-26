require "class.region"

Country = Base:subclass("Country")

-- WARNING! The name of miniature and ball image should be the same as Country's name!
-- Example: If we have an instance of Country with name variable "Ukraine",
-- both balls and miniatures folder should have a Ukraine.png image.

local lg = love.graphics

function Country:initialize(name, color, attack, defense, hp, fighters)
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
    self.energy = 10
    self.money = 0
    
    self.foes = {}
    self.allies = {}
    
    self.isDead = false
    self.deadMessagePrinted = false
    
    self.maxHP = self.hp
    self.maxEnergy = self.energy
    
    self.skills = {
		-- default skills
        heal = skills.heal:clone(),
        attack = skills.attack:clone(),
        fire = skills.fire:clone(),
    } 
    
    -- table of fighters
    self.fighters = fighters or {}
    for k,fighter in pairs(self.fighters) do
        self.fighters[k] = FighterAI(fighter) -- init using stats of that fighter
    end
    
    self.invadeTimer = math.random(10,20)
    self.numOfInv = 0
    
    self.midpoint = nil -- generated at game:init after placing regions
    
    Base.initialize(self)
end

function Country:_midpoint()
    local xmidpointSum = 0
    local ymidpointSum = 0
    local regionsNum = 0
    
    for _,region in pairs(map) do
        if region.id == self.id then
            regionsNum = regionsNum + 1
            xmidpointSum = xmidpointSum + region.midpoint.x
            ymidpointSum = ymidpointSum + region.midpoint.y
        end
    end
    
    return {x = xmidpointSum / regionsNum, y = ymidpointSum / regionsNum}
end

local function strongEnough(self, foe)
    local winChance = (self.attack/(foe.defense*5))*100
    
    for _,fighter in pairs(self.fighters) do
        winChance = winChance + fighter.attack_stat/5
    end
    
    for _,fighter in pairs(foe.fighters) do
        winChance = winChance - fighter.defense/5
    end
    
    if winChance > 100 then winChance = 100
    elseif winChance < 1 then winChance = 1
    end
    
    math.randomseed(os.time())
    local r = math.random(100)
    
    return winChance >= r 
end

function Country:invade(dt)

    if not self.isDead and not self.inBattle 
    and self.name ~= Player.country and self.name ~= "Sea" then
    
		self.invadeTimer = self.invadeTimer - dt
		
		if self.invadeTimer <= 0 then
			self.invadeTimer = math.random(20*worldTime.dayLength,40*worldTime.dayLength)
			
			local possible_regions = {}
            
			for _,foe in pairs(self.foes) do
                -- add neighbour regions
				for _,region in pairs(map) do
					if region.country.name == foe.name then
                        if self:isNeighbour(region.name) then
                            table.insert(possible_regions, region)
                        end
                    end
                end
                
                -- add sea bordering enemy regions
                for _,region in pairs(map) do
                    if region.country.name == foe.name 
                    and region:hasSeaBorder() then
                        table.insert(possible_regions, region)
                    end
                end
                            
                        
                
                -- conquer region
                if #possible_regions > 0 then
                    for _,region in pairs(map) do
                        math.randomseed(math.random(os.time()))
                        
                        -- pick closest to country's center region
                        table.sort(possible_regions, 
                            function(a,b)
                                local a_d = math.dist(a.midpoint.x,a.midpoint.y,
                                                      self.midpoint.x,self.midpoint.y)
                                local b_d = math.dist(b.midpoint.x,b.midpoint.y,
                                                      self.midpoint.x,self.midpoint.y)
                                return a_d < b_d
                            end
                        )

                        local region = possible_regions[1]
                        
                        if self.numOfInv == 0 
                        and strongEnough(self, region.country) then
                        
                            self.numOfInv = self.numOfInv + 1
                            
                            if region.country.name == Player.country then
                                msgBox:add(self.name.." took your clay!")
                            end
                            
                            region:changeOwner(self)
                        end
                    end
                end
			end
			
			self.numOfInv = 0
		end
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

function Country:isFoe(country)
	local country = country
	if type(country) == "string" then 
		country = nameToCountry(country) 
	end
	
    for _,foe in pairs(country.foes) do
        if self.name == foe.name then
            return true
        end
    end
    
    return false
end

function Country:war(foe, noPrintMsg)
	if not self.isDead and not foe.isDead then
		local foe = foe
		if type(foe) == "string" then foe = nameToCountry(foe) end
		
		if foe.name ~= "Sea" and foe.name ~= self.name then
		
			if not self:isFoe(foe.name) and not noPrintMsg then
				msgBox:add(self.name.." declared war on "..foe.name.."!")
			end
			
			if  not foe:isFoe(Player.country) 
			and not self:isFoe(foe.name) then
				table.insert(foe.foes, self)
				table.insert(self.foes, foe)
			end
		end
	end
end

function Country:peace(country)
	if not self.isDead then
		local country = country
		if type(country) == "string" then country = nameToCountry(country) end

		if country.name ~= "Sea" and country.name ~= self.name then
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
					error("Country:peace method accepts the instance or name of country only.")
				end
			end
			
			if country.name == Player.country then
				local r = math.random(3)
				
				if r <= 2 then
					local dbox = DialogBoxes:new(self.name.." wants to sign a peace treaty with us.",
						{"Refuse", function() end}, 
						{"Accept", function() 
							peace(country) 
							if Gamestate.current == battle then
								Gamestate.switch(game)
							end
						end}
					)
					
					dbox:show(function() love.mouse.setVisible(false) end)
				else
					local moneyAmnt = math.random(self.attack*2, self.attack*3)
					local dbox = DialogBoxes:new(
						self.name.. " wants to sign a peace treaty with us. "
						..tostring(moneyAmnt).."G will be given as a compensation.",
						
						{"Refuse", function() end}, 
						{"Accept", 
							function()
								peace(country)
								country:addMoney(moneyAmnt)
								game.loadStatusbarText()
                                
								if Gamestate.current == battle then
									Gamestate.switch(game)
								end
							end
						})
					
					dbox:show(
						function() 
							if Gamestate.current == game then
								love.mouse.setVisible(false)
							end
						end)
				end
			else
				-- for AI
				peace(country)
			end
		end
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

    removeDuplicates(self.skills)
end

function Country:isNeighbour(regionName)
    local i = 0
    
    for _,region in pairs(map) do
        if region.country.id == self.id then
            for _,n in pairs(region.neighbours) do
                if n == regionName then
                    i = i + 1
                end
            end
            
        end
    end
    
    return i > 0
end
