Upgrade = Button:subclass "Upgrade"

function Upgrade:initialize(arg)
	self.text = tostring(arg.name) or "Undefined name"
	self.desc = tostring(arg.desc) or "Undefined desc"
	self.cost = tonumber(arg.cost) or error("No cost defined")
	self.upg_func = function(level) arg.func(level) end
	self.func = function() self:upgrade() end
									
	self.max_level = max_level or 10
	
	self.width  = arg.width  or 140
	self.height = arg.height or 60
	self.level = 0
	
	Button.initialize(self, 0,0, self.width, self.height, 
					 self.text, self.func)
end

function Upgrade:upgrade(disregard)
	local disregard = disregard or false
	
	if self.level + 1 > self.max_level and not disregard then
		
		local show = false
		DialogBoxes:new("Maximum level reached!",
						{"Unacceptable!", function() 
								 DialogBoxes:new(
									"Well, for triple the price, "..
									"we can upgrade disregarding"..
									" the level cap.\n *the merchant "..
									"is rubbing his hands*",
									{"Cancel", dbox2},
									{"Upgrade", function() 
										self:upgrade(true)
										self.tricked = true
									end}
								 
								 ):show()
							 end
						
						},
						{"OK", function() end}
		):show()
		
	else
		local cost
		if disregard then cost = self.cost*3 
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
		love.graphics.printf(self.level, x,self.y+self.height-PADDING*4, width-PADDING, "right")
	end
	
	love.graphics.setColor(255,255,255)
	
	-- draw info
	if checkCol(the.mouse, self) then
		local x,y = the.mouse.x, the.mouse.y
		local PADDING = 5
		local w = 150
		local title_h = 30
		
		local font = love.graphics.getFont()
		local _,linenum = font:getWrap(self.desc, w)
		local h = linenum * font:getHeight() + title_h + PADDING*2

		local fontHeight = font:getHeight()
		
		guiRect(x,y,w+PADDING,h)
		guiRect(x,y,w+PADDING,title_h)
		
		love.graphics.setColor(guiColors.fg)
		love.graphics.printf(self.text, x+PADDING, y+title_h/2-fontHeight/2, w, "left")
		love.graphics.printf(self.desc, x+PADDING, y+title_h+PADDING, w, "left")
		love.graphics.setColor(255,255,255)
	end
end
	
		
		
	
