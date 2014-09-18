Upgrade = Button:subclass "Upgrade"

function Upgrade:initialize(arg)
	self.text = tostring(arg.name) or "Undefined name"
	self.desc = tostring(arg.desc) or "Undefined desc"
	self.cost = tonumber(arg.cost) or error("No cost defined")
	self.upg_func = function(self, level) arg.func(self, level) end
	self.func = function() self:upgrade() end
									
	self.max_level = max_level or 10
	
	self.width  = arg.width  or 140
	self.height = arg.height or 60
	self.level = 0
	
	Button.initialize(self, 0,0, self.width, self.height, 
					 self.text, self.func)
end

function Upgrade:upgrade()
	if self.level + 1 > self.max_level and not self.tricked then
		
		local show = false
		
		if not self.tricked then
			DialogBoxes:new("Maximum level reached!",
							{"Unacceptable!", function() 
									 DialogBoxes:new(
										"Well, for triple the price, "..
										"we can upgrade disregarding"..
										" the level cap.\n *the merchant "..
										"is rubbing his hands*",
										{"Cancel", dbox2},
										{"Upgrade", function()
											self.tricked = true
											self:upgrade()
										end}
									 
									 ):show()
								 end
							
							},
							{"OK", function() end}
			):show()
		end
	else
		local cost
		if self.tricked then cost = self.cost*3 
		else cost = self.cost
		end
		
		if Player.money - cost >= 0 then
			if disregard then self.max_level = self.max_level+1 end
			self.level = self.level + 1
			self.upg_func(self.level)
			Player.money = Player.money - self.cost
		else
			DialogBoxes:new("Not enough money!",
							{"OK", function() end}
			):show()
		end
	end
end

function Upgrade:draw()
	Button.draw(self)
	
	local PADDING = 5
	local x = self.x + PADDING
	local width, height = self.width-PADDING*2, 10
	local y = self.y+self.height - height - PADDING
	
	love.graphics.setColor(guiColors.fg)
	if not self.tricked then
		love.graphics.rectangle("line", x,y,width,height)
		love.graphics.setColor(guiColors.bg)
		love.graphics.rectangle("fill", x,y, 
								(width/self.max_level)*self.level,height)
	else
		love.graphics.setFont(gameFont[12])
		love.graphics.printf("Level: " .. self.level, x,self.y+self.height-PADDING*4, width-PADDING, "right")
		love.graphics.setFont(gameFont["default"])
	end
	
	love.graphics.setColor(255,255,255)
	
	local cost
	if self.tricked then cost = self.cost*3
	else cost = self.cost
	end
	
	if checkCol(the.mouse, self) then
		guiInfoBox(the.mouse.x, the.mouse.y, self.text 
					.. " ("..cost.."G)",self.desc)
	end
end
	
		
		
	
