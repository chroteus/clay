local anim8 = require "lib.anim8"

Soldier = class "Soldier"

function Soldier:initialize(arg)
	self.attack = arg.attack or 10
	self.defense = arg.defense or 10
	self.hp = arg.hp or 10
	self.maxHP = self.hp or 10

	if not arg.frames then error("Frames for soldier not set") end
	self.frames = love.graphics.newImage(arg.frames)
	self.frames:setFilter("nearest", "nearest")
	local grid = anim8.newGrid(15,14, self.frames:getWidth()-4, self.frames:getHeight(),3,0,0)
	self.anim = {
		still_south = anim8.newAnimation(grid(1,1), 0.1),
		south = anim8.newAnimation(grid("2-3", 1),  0.1),
		east  = anim8.newAnimation(grid("4-6", 1),  0.1),
		west  = anim8.newAnimation(grid("4-6", 1),  0.1):flipH(),
		still_north = anim8.newAnimation(grid(7,1), 0.1),
		north = anim8.newAnimation(grid("8-9", 1), 0.1),
	}
	
	self.timer = Timer.new()
	self.anim_state = "still_south"
	self.scale = 1
end	

function Soldier:setPos(x,y)
	self.x = x
	self.y = y
	
	return self
end

function Soldier:setScale(scale)
	self.scale = scale
	
	return self
end

function Soldier:getDamage(attack)
	local netAtt = attack - self.defense
	if netAtt < 0 then netAtt = 0 end
	
	self.hp = self.hp - netAtt
end

function Soldier:moveTo(x,y)
	local duration = math.dist(self.x,self.y, x,y)/50/self.scale
	if self.x > x then self.anim_state = "west"
	elseif self.x < x then self.anim_state = "east"
	end
	
	self.timer:tween(duration, self, {x = x})
	self.timer:tween(duration, self, {y = y})
	self.timer:add(duration, function() self.anim_state = "still_south" end)
end

function Soldier:attack(soldier)
	local origX,origY = self.x, self.y
	self:moveTo(soldier.x, soldier.y)
	soldier:getDamage(self.attack)
	self:moveTo(origX,origY)
end

function Soldier:update(dt)
	self.timer:update(dt)
	self.anim[self.anim_state]:update(dt)
end

function Soldier:draw()
	if not self.x or not self.y then error("Position for soldier not set") end

	self.anim[self.anim_state]:draw(self.frames, self.x, self.y, 0,
									self.scale, self.scale)

end
	
	

Army = class "Army"

function Army:initialize(country)
	self.country = country
	self.soldiers = {}
end

function Army:addSoldier(soldier)
	table.insert(self.solders, soldier)
end

function Army:formation()
	table.sort(self.soldiers)
end
