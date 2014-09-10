Upgrade = Button:subclass "Upgrade"

function Upgrade:initialize(name, cost, func, max_level)
	self.name = tostring(name)
	self.cost = tonumber(cost)
	self.func = assert(func)
	self.max_level = max_level or 10
	
	self.level = 0
end

function Upgrade:upgrade(disregard)
	local disregard = disregard or false
	
	if self.level + 1 >= self.max_level and not disregard then
		local dbox2 = DialogBoxes:new(
			"Well, for triple the price, we can upgrade disregarding"..
			" the level cap.\n *the merchant is rubbing his hands*",
			{"Upgrade", function() self:upgrade(true) end},
			{"Cancel", dbox2}
		)
			
		DialogBoxes:new("Maximum level reached!",
						{"OK", function() end},
						{"Unacceptable!", function() dbox2:show() end}
		):show()
		
	else
		local player = Player:returnCountry()
		
		if player.money - self.cost >= 0 then
			self.level = self.level + 1
			player.money = player.money - self.cost
		else
			DialogBoxes:new("Not enough money!",
							{"OK", function() end}
			):show()
		end
	end
end
	
		
		
	
