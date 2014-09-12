Upgrade = Button:subclass "Upgrade"

function Upgrade:initialize(name, cost, func, max_level)
	self.text = tostring(name)
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
			{"Cancel", dbox2}
			{"Upgrade", function() self:upgrade(true) end},
		)
			
		DialogBoxes:new("Maximum level reached!",
						{"Unacceptable!", function() dbox2:show() end}
						{"OK", function() end},
		):show()
		
	else
		local player = Player:returnCountry()
		
		local cost
		if disregard then cost = self.cost*3 
		else cost = self.cost
		end
		
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

function Upgrade:draw()
end
	
		
		
	
