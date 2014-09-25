Soldier = class "Soldier"

function Soldier:initialize(arg)
	self.attack = arg.attack or 10
	self.defense = arg.defense or 10
	self.hp = arg.hp or 10
	self.maxHP = self.hp or 10
	self.image = arg.image or error("Image for soldier not set")
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
