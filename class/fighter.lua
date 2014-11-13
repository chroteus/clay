Fighter = class("Fighter")

function Fighter:initialize(arg)
    self.name = arg.name or "Undefined name"

    -- "attack_stat" is not "attack" to prevent conflict 
    -- with method named "attack"
	self.attack_stat = arg.attack or 5
	self.attack_stat = math.ceil(self.attack_stat)
    
    self.defense = arg.defense or 5
	self.defense = math.ceil(self.defense)
    
    self.hp = arg.hp or 50
    self.hp = math.ceil(self.hp)
    self.max_hp = self.hp

    local frames
	if not arg.frames and self.name then 
        frames = "assets/image/fighters/balls/" .. self.name .. ".png"
    elseif not arg.frames and not self.name then
        error("Neither name nor frames file defined")
    else
        frames = arg.frames
    end
        
	if type(frames) == "string" then
		self.frames = love.graphics.newImage(frames)
	else
		self.frames = frames
	end
	
	--self.frames:setFilter("nearest", "nearest")
    
    -- size of frame
    self.width = 75; self.height = 70
    
	local grid = anim8.newGrid(self.width,self.height, self.frames:getWidth()-30, self.frames:getHeight(),15,0,0)
	self.anim = {
		still_south = anim8.newAnimation(grid(1,1), 0.1),
		south = anim8.newAnimation(grid("1-3", 1),  0.1),
		
		still_east  = anim8.newAnimation(grid(4, 1),  0.1),
		east  = anim8.newAnimation(grid("4-6", 1),  0.1),
		
		still_west  = anim8.newAnimation(grid(4, 1),  0.1):flipH(),
		west  = anim8.newAnimation(grid("4-6", 1),  0.1):flipH(),
		
		still_north = anim8.newAnimation(grid(7,1), 0.1),
		north = anim8.newAnimation(grid("7-9", 1), 0.1),
	}

    setmetatable(self.anim, {__index = function(t,k) error("Animation " .. k .. " doesn't exist") end})
    
	self.timer = Timer.new()
	self.anim_state = "still_south"
	self.scale = arg.scale or 1
    self.speed = arg.speed or 200
    
    self.stop_moving = true
    self.enemies = {}
    
    self.attack_zone = arg.attack_zone or math.floor(self.width/1.5)
    self.timer = Timer.new()
    
    self.items = {}
    self.alpha = 255
    
	return self
end

function Fighter:setPos(x,y)
    self.x = x
    self.y = y
end

function Fighter:loseHP(attack_arg)
	local netAtt = attack_arg - (self.defense/2)
	if netAtt < 1 then netAtt = 1 end
	
	self.hp = self.hp - math.floor(netAtt)
end

function Fighter:knockback(angle, power, onEnd)
    local power = power or 90
    
    self.timer:add(0.3, onEnd)
    self.timer:tween(0.3, self, {x = self.x + power*math.cos(angle)}, "out-quad")
    self.timer:tween(0.3, self, {y = self.y + power*math.sin(angle)}, "out-quad")
end

function Fighter:inAttackZone(arg_dist)
    if self.enemy_to_attack then
        local enemy = self.enemy_to_attack
        local d = math.dist(self.x+self.width/2,self.y+self.height/2, 
                            enemy.x+enemy.width/2,enemy.y+enemy.height/2)
        
        
        return d < (arg_dist or self.attack_zone)
    else
        return false
    end
end


function Fighter:moveTo(x,y, arg)
    -- can either accept this syntax: moveTo(entity, arg)
    -- or: moveTo(x,y, arg)
    if type(x) == "table" then
        self.goal_entity = x
    else
        self.goal_x = x
        self.goal_y = y
    end
    
    local arg
    if type(y) == "table" then
        arg = y
    end
    
    
    if arg then
        if arg.onArrival then self.funcOnArrival = arg.onArrival end
        if arg.attacking then 
            self.attacking = true
        else
            self.attacking = false
        end
    end
    
    return self
end

function Fighter:lookAt(x,y, arg)
	local xDiff = math.abs(self.x - x)
	local yDiff = math.abs(self.y - y)
    
    local still
    if arg and arg.still then still = arg.still end
	    
	if xDiff > yDiff then
		if self.x > x then self.anim_state = "west"
		elseif self.x < x then self.anim_state = "east"
		end
	else
		if self.y > y then self.anim_state = "north"
		elseif self.y < y then self.anim_state = "south"
		end
	end
    
    if still then self.anim_state = "still_"..self.anim_state end
end
    

function Fighter:_attackAnim()
    if not self.attack_anim_played then
        local enemy = self.enemy_to_attack
        local angle = math.atan2(enemy.y - self.y, enemy.x - self.x)
        
        -- time it will take for attack animation to finish
        local total_time = 0.6
        
        self.timer:add(total_time/3, 
            function()
                self:_onArrival()
                self:_onAttack(enemy)
            end)
        
        local enemyX,enemyY
        
        if enemy:isInstanceOf(Fighter) then
            enemyX, enemyY = enemy.x + enemy.width/2, enemy.y + enemy.height/2
            print("Attacked enemy is a Fighter!")
        else
            enemyX, enemyY = enemy.x + enemy.width/2, enemy.y + enemy.height - self.height
            print("Attacked enemy is a Country!")
        end
        
        self.timer:tween(total_time/3, self, {x = self.x - self.width/3  * math.cos(angle)}, "in-quint")
        self.timer:tween(total_time/3, self, {y = self.y - self.height/3 * math.sin(angle)}, "in-quint",
            function()
                self.timer:tween(total_time/1.5, self, {x = enemyX + math.random(-10,10)}, "out-quint")
                self.timer:tween(total_time/1.5, self, {y = enemyY + math.random(-10,10)}, "out-quint",
                    function() self.attack_anim_played = false end)
            end
        )
        
        self.attack_anim_played = true
    end
end

------------------------------------------------------------------------
function Fighter:_onArrival()
    self.goal_x = nil
    self.goal_y = nil
    self.goal_entity = nil
    
    if self.funcOnArrival then self.funcOnArrival(self) end
    
    if self.anim_state:match("still") == nil then
        self.anim_state = "still_" .. self.anim_state
    end
end

function Fighter:_onHit()
end

function Fighter:_onDie()
    self.dead = true
end

function Fighter:_onAttack(enemy)
    local angle = math.atan2(enemy.y - self.y, enemy.x - self.x)
    enemy:loseHP(self.attack_stat)
    
    if enemy:isInstanceOf(Fighter) then
        if enemy.hp <= 0 then
            enemy:knockback(angle, 200, function() enemy:_onDie() end)
            enemy.timer:tween(0.3, enemy, {alpha = 0}, "out-quad")
        else
            enemy:knockback(angle)
        end
    
        enemy:_onHit()
    else
        knockback(enemy, 1)
    end
    
    self:lookAt(enemy.x, enemy.y, {still = true})
end
------------------------------------------------------------------------    

-- Internal function, thus prefixed with an underscore.
function Fighter:_move(dt)
    if type(self.goal_x) == "table" then self.goal_x = nil end
    if type(self.goal_y) == "table" then self.goal_y = nil end
    
    local goal_x = self.goal_x or self.goal_entity.x + self.goal_entity.width/2
    local goal_y = self.goal_y or self.goal_entity.y + self.goal_entity.height/2
    
    self:lookAt(goal_x, goal_y)

    local angle = math.atan2(goal_y - self.y, goal_x - self.x)
    self.x = self.x + (self.speed * math.cos(angle)) * dt
    self.y = self.y + (self.speed * math.sin(angle)) * dt
    
    if  (goal_x-3 <= self.x and self.x <= goal_x+3) 
    and (goal_y-3 <= self.y and self.y <= goal_y+3)  then
        self:_onArrival()
    end
    
    if self:inAttackZone() then
        self.x = self.x - (self.speed * math.cos(angle)) * dt
        self.y = self.y - (self.speed * math.sin(angle)) * dt
    
        if self.attacking then
            self:_attackAnim()
        end
    end
end

function Fighter:addEnemy(fighter)
    table.insert(self.enemies, fighter)

    return self
end

function Fighter:addEnemies(team)
    for _,enemy in pairs(team) do
        self:addEnemy(enemy)
    end
    
    return self
end

------------------------------------------------------------------------

function Fighter:equip(item)
    self.items[item.type] = Item(item)
    self.items[item.type].onEquip(self)
end

function Fighter:unequip(slot)
    self.items[slot].onUnequip(self)
    self.items[slot] = nil
end

------------------------------------------------------------------------

function Fighter:update(dt)
    self.timer:update(dt)

    if (self.goal_x and self.goal_y) or self.goal_entity
    and not self.attack_anim_played then
        self:_move(dt) 
    end
    
    self.anim[self.anim_state]:update(dt)
    for _,item in pairs(self.items) do
        item:update(dt)
    end
end

function Fighter:draw(x,y, noHP)
    local x = x or self.x
    local y = y or self.y
    local function drawItems()
        for k,item in pairs(self.items) do
            item:draw(self.anim_state, x,y)
        end
    end
    
    -- drawing item from behind
    if self.anim_state == "east" or self.anim_state == "still_east" then
        drawItems()
    end
    
    love.graphics.setColor(255,255,255,self.alpha)
	if not x or not y then error("Position for fighter not set") end
	self.anim[self.anim_state]:draw(self.frames, x,y)
    love.graphics.setColor(255,255,255)
    
    if self.anim_state ~= "east" and self.anim_state ~= "still_east" then
        drawItems()
    end

    if not noHP then
        love.graphics.setColor(160,40,40, self.alpha)
        love.graphics.rectangle("line", self.x, self.y-10, self.width, 12)
        love.graphics.rectangle("fill", self.x, self.y-10, (self.width/self.max_hp)*self.hp, 12)
        love.graphics.setColor(255,255,255)
        love.graphics.setFont(gameFont[14])
        love.graphics.print(self.hp .. "/" .. self.max_hp, 
                            self.x, self.y - 10 - gameFont[14]:getHeight()/4 + 2)
        love.graphics.setColor(255,255,255)
    end
end
