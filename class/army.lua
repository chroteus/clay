local anim8 = require "anim8"

Soldier = class "Soldier"

function Soldier:initialize(arg)
	self.attack = arg.attack or 10
	self.defense = arg.defense or 10
	self.hp = arg.hp or 10
	self.maxHP = self.hp or 10
	
	if not arg.frames then error("Frames for soldier not set")
	local frames = love.graphics.newImage(arg.frames)
	local grid = anim8.newGrid(14,14, frames:getWidth(), frames:getHeight())
	self.anim = {
		still_south = anim8.newAnimation(grid(1,1), 0.1),
		south = anim8.newAnimation(grid("2-3", 1),  0.1),
		east  = anim8.newAnimation(grid("4-6", 1),  0.1),
		west  = anim8.newAnimation(grid("4-6", 1),  0.1):flipH(),
		still_north = anim8.newAnimation(grid(7,1), 0.1),
		north = anim8.newAnimation(grid("8-9", 1), 0.1),
	}
end	

function Soldier:setPos(x,y)
	self.x = x
	self.y = y
end

function Soldier:getDamage(attack)
	local netAtt = attack - self.defense
	if netAtt < 0 then netAtt = 0 end
	
	self.hp = self.hp - netAtt
end

function Soldier:moveTo(x,y, duration)
	local duration = duration or 0.5
	Timer.tween(duration, self, {x = x}, "out-quad")
	Timer.tween(duration, self, {y = y}, "out-quad")
end

function Soldier:attack(soldier)
	local origX,origY = self.x, self.y
	self:moveTo(soldier.x, soldier.y)
	soldier:getDamage(self.attack)
	self:moveTo(origX,origY)
end

function Soldier:update(dt)
end

function Soldier:draw()
	if not self.x or self.y then error("Position for soldier not set") end
	
	love.graphics.draw(self.image, self.x, self.y)
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
