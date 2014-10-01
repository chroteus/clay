local anim8 = require "lib.anim8"

Soldier = class("Soldier")

function Soldier:initialize(arg)
	self.attack_stat = arg.attack_stat or 10
	self.defense = arg.defense or 10
	self.hp = arg.hp or 10
	self.maxHP = self.hp or 10

	if not arg.frames then error("Frames for soldier not set") end
	
	if type(arg.frames) == "string" then
		self.frames = love.graphics.newImage(arg.frames)
	else
		self.frames = arg.frames
	end
	
	self.frames:setFilter("nearest", "nearest")
	local grid = anim8.newGrid(15,14, self.frames:getWidth()-6, self.frames:getHeight(),3,0,0)
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
	
	self.timer = Timer.new()
	self.anim_state = "still_south"
	self.scale = arg.scale or 1
end	

function Soldier:setPos(x,y)
	-- Sets either the true position, or if in Army,
	-- position relative to army
	self.x = x
	self.y = y
	
	return self
end

function Soldier:setScale(scale)
	self.scale = scale
	
	return self
end

function Soldier:getDamage(attack_arg)
	local netAtt = attack_arg - self.defense
	if netAtt < 0 then netAtt = 0 end
	
	self.hp = self.hp - netAtt
end

function Soldier:moveTo(x,y, finishFunc)
	self.timer:clear()
	local duration = math.dist(self.x,self.y, x,y)/50/self.scale
	local xDiff = math.abs(self.x - x)
	local yDiff = math.abs(self.y - y)
	
	if xDiff > yDiff then
		if self.x > x then self.anim_state = "west"
		elseif self.x < x then self.anim_state = "east"
		end
	else
		if self.y > y then self.anim_state = "north"
		elseif self.y < y then self.anim_state = "south"
		end
	end
	
	self.timer:tween(duration, self, {x = x})
	self.timer:tween(duration, self, {y = y})
	self.timer:add(duration, 
					function()
						self.anim_state = "still_" .. self.anim_state
						if finishFunc then finishFunc() end
					end)
end

function Soldier:attack(soldier)
	local origX,origY = self.x, self.y
	self:moveTo(soldier.x, soldier.y,
		function()
		-- finish func
			soldier:getDamage(self.attack_stat)
			self:moveTo(origX,origY)
		end
	)
end

function Soldier:update(dt)
	self.timer:update(dt)
	self.anim[self.anim_state]:update(dt)
end

function Soldier:draw()
	if not self.x or not self.y then error("Position for soldier not set") end

	self.anim[self.anim_state]:draw(self.frames, 
									self.x, self.y, 0,
									self.scale, self.scale)

end

------------------------------------------------------------------------

Army = class "Army"

function Army:initialize(arg)
	self.width = 2 or arg.width
	self.height = 5 or arg.height
	
	self.soldiers = {}
end

function Army:setPos(x,y)
	self.x = x
	self.y = y
	
	return self
end

function Army:addSoldier(soldier, padding)
	local padding = padding or 20
	local lastSoldier = self.soldiers[#self.soldiers] or {x = self.x, y = self.y}
	soldier:setPos(lastSoldier.x + padding + math.random(-2,2), 
				   lastSoldier.y + padding + math.random(-2,2))
	table.insert(self.soldiers, soldier)
end

function Army:populateWith(num, soldier)
	for i=1,num do
		self:addSoldier(Soldier(soldier))
	end
end

function Army:update(dt)
	for _,soldier in pairs(self.soldiers) do
		soldier:update(dt)
	end
end

function Army:draw()
	for _,soldier in pairs(self.soldiers) do
		soldier:draw()
	end
end

function Army:attack(army)
	for num,enemy in pairs(army.soldiers) do
		if self.soldiers[num] ~= nil then
			self.soldiers[num]:attack(enemy)
		else
			local rand = self.soldiers[math.random(#self.soldiers)]
			rand:attack(enemy)
		end
	end
end
			
function Army:moveTo(x,y)
	local padding = padding or 20
	for num,soldier in pairs(self.soldiers) do
		self.x, self.y = x,y
		soldier:moveTo(self.x + (num-1)*padding/2 + math.random(1,2), 
					   self.y + (num-1)*padding   + math.random(1,2))
	end
end
