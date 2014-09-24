Soldier = class "Soldier"

function Soldier:initialize(arg)
	self.attack = arg.attack
	self.defense = arg.defense
	self.hp = arg.hp
	self.maxHP = self.hp
	self.image = arg.image
end

function Soldier:getDamage(attack)
	local netAtt = attack - self.defense
	if netAtt < 0 then netAtt = 0 end
	
	self.hp = self.hp - netAtt
end

function Soldier:attack(soldier)
	local origX,origY = self.x, self.y
	local function backToOrig()
		Timer.tween(0.5, self, {x = origX}, "out-quad")
		Timer.tween(0.5, self, {y = origY}, "out-quad")
	end
	
	soldier:getDamage(self.attack)
	
	Timer.tween(0.5, self, {x = soldier.x}, "out-quad")
	Timer.tween(0.5, self, {y = soldier.y}, "out-quad", backToOrig)
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
