-- Small GUI lib.

require("lib.middleclass")

Button = class("Button")
-- Button class: Base class for other buttons.
-- Not to be used by itself.

guiColors = {
    bg = {255,255,255,200},
    fg = {20,20,20}
}

function guiRect(x,y,width,height)
    love.graphics.setColor(guiColors.bg)
    love.graphics.rectangle("fill",x,y,width,height)
    love.graphics.setColor(guiColors.fg)
    love.graphics.rectangle("line",x,y,width,height)
    love.graphics.setColor(255,255,255)
end

function Button:initialize(x, y, width, height, text, func)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.func = assert(func)
    self.state = "idle"
    self.text = text
    
    self.colors = {
        idle = {    
            bg = guiColors.bg,
            fg = guiColors.fg
        },
        
        -- active = Mouse is hovering on the button.
        active = {
            bg = {80,80,80},
            fg = {200,200,200}
        },
    }
end

function Button:update(dt)
    if checkCol(self, the.mouse) then 
		if self:isInstanceOf(ShopButton) then
			if not self.used then
				self.state = "active"
			end
		else
			self.state = "active"
		end
	else 
		self.state = "idle"
    end
end

function Button:mousereleased(x, y, button)    
    if checkCol(self, the.mouse) then
        self.func()
        TEsound.play("assets/sounds/mouseclick.wav")
    end
end

function Button:draw(rgba)
	if rgba then
		love.graphics.setColor(rgba)
	else
		love.graphics.setColor(self.colors[self.state].bg)
	end
	
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.setColor(self.colors[self.state].fg)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(255, 255, 255)

    if not self:isInstanceOf(SelectBtn) then
        love.graphics.setColor(self.colors[self.state].fg)
        love.graphics.setFont(gameFont[18])
        local fontHeight = (gameFont[18]:getHeight(self.text))
        love.graphics.printf(self.text, self.x, self.y + self.height/2 - fontHeight/2, self.width, "center")
        love.graphics.setFont(gameFont[16])
    else
        local imageX = self.x + 4
        local imageY = self.y + 5
        
        love.graphics.draw(self.image, imageX, imageY)
    end
    
    love.graphics.setColor(255,255,255)
    
    if self:isInstanceOf(CountrySelectBtn) then
        love.graphics.push()
        love.graphics.scale(2)
        self:drawBall()
        love.graphics.pop()
    end

	if self:isInstanceOf(ShopButton) then
		local h = 120
		
		
		guiRect(self.x, self.y - h, self.width, h)
		
		if self.used then 
			love.graphics.setColor(0,0,0,128)
			love.graphics.rectangle("fill", self.x, self.y-h, self.width, self.height+h)
			love.graphics.setColor(255,255,255)
		end
		
		love.graphics.draw(self.img, self.x+(self.width/2-self.img:getWidth()/2), (self.y-h)+self.height/2-self.img:getHeight()/2)
	end
end

CountrySelectBtn = Button:subclass("CountrySelectBtn")
-- to be used with GuiOrderedList

function CountrySelectBtn:initialize(country, x, y)
	self.x = x or 0
	self.y = y or 0
	self.height = 50
	self.width = 150
	self.ball = country.miniature
	self.text = country.name
	self.func = function() 
		Player.country = country.name
		Player.attack, Player.defense = country.attack, country.defense
		loading.switch(game)
	end
	
	self.ball:setFilter("nearest", "nearest")
	
	Button.initialize(self, self.x, self.y, self.width, self.height, self.text, self.func)
end

function CountrySelectBtn:drawBall()
	local padding = 5
	local ballX = (self.x - self.ball:getWidth() - padding*2) / 2
	local ballY = (self.y + self.ball:getHeight() + padding*2) / 2
	love.graphics.draw(self.ball, ballX, ballY)
end

InvButton = Button:subclass("InvButton")
	
function InvButton:initialize(item, x, y)
	self.item = item
	
	if self.item.equipped then
		self.text = item.name .. " [EQUIPPED]"
	else
		self.text = item.name .. " [UNEQUIPPED]"
	end
	
	self.x = x or 0
	self.y = y or 0

	self.width = 150
	self.height = 60
	
	self.func = function()
		if self.item.equipped then
			self.text = self.item.name .. " [UNEQUIPPED]"
			self.item:unequip()
		else
			self.text = self.item.name .. " [EQUIPPED]"
			self.item:equip()
		end
	end

	Button.initialize(self, self.x, self.y, self.width, self.height, self.text, self.func)
end


GuiOrderedTable = class("GuiOrderedTable")
-- orders buttons in columns
-- Buttons of the same width and height should be used

function GuiOrderedTable:initialize(columns, yOrder)
	self.columns = columns or 3
	self.btn = {}
	self.xOrder = 1
	self.yOrder = yOrder or 1
end

function GuiOrderedTable:insert(button)
	button.x = self.xOrder*button.width*2
	button.y = self.yOrder*button.height*2
	
	table.insert(self.btn, button)
	button = nil
	
	self.xOrder = self.xOrder + 1
	
	if self.xOrder > self.columns then
		self.yOrder = self.yOrder + 1
		self.xOrder = 1
	end
end

function GuiOrderedTable:update()
	for _,btn in pairs(self.btn) do
		btn:update()
	end
end

function GuiOrderedTable:mousereleased(x,y,button)
	for _,btn in pairs(self.btn) do
		btn:mousereleased(x,y,button)
	end
end

function GuiOrderedTable:draw()
	for _,btn in pairs(self.btn) do
		btn:draw()
	end
end

GenericButton = Button:subclass("GenericButton")
-- Generic Button: A button to be used in menu, or anywhere else outside shop.
-- It's preferable to use GenericButton rather than Button because it has less arguments.

function GenericButton:initialize(order, text, action)
    -- <order> defines button's y position, in a grid-like system.
    -- if <order> is too high (>20) order becomes y value.    
    self.width = 180                 
    self.height = 50                   
    self.x = the.screen.width/2 - self.width/2
    self.text = text
    self.action = action
    
    if order > 20 then
        self.y = order
    else
        self.y = self.height * (order*2)
    end
    
    -- Initialize super class.
    Button.initialize(self, self.x, self.y, self.width, self.height, self.text, self.action)
end


ShopButton = Button:subclass("ShopButton")
-- To be used with GuiOrderedList

function ShopButton:initialize(item, x,y)
	local x = x or 0
	local y = y or 0
	
	self.width = 150
	self.height = 50
	
	self.img = item.img
    self.text = item.name .. ", " .. item.cost .. "G"
    
    local function buy()
        if Player.money >= item.cost then
			if table_count(Player.items, item) > 0 then
				DialogBoxes:new(
					"You already have " .. item.name .. "!",
					{"OK", function() end}
				):show()
			else
				Player.money = Player.money - item.cost
				item:add()
				
				DialogBoxes:new(
					"You've bought " .. item.name .. ". Equip " .. item.name .. "?",
					{"Yes", function() item:equip() end},
					{"No", function()  end}
				):show()
				
				self.used = true
				self.state = "idle"
			end
        else
			DialogBoxes:new(
				"Not enough money!",
				{"OK", function() end}
			):show()
		end
    end
    
    -- Superclass init.
    Button.initialize(self, x, y, self.width, self.height, self.text, buy)
end

function ShopButton:drawIcon()
    love.graphics.draw(self.icon, self.x - (35*scaleFactor), self.y)
    love.graphics.print(self.variable, self.x - (23*scaleFactor), self.y)
end
    
SkillBtn = Button:subclass("SkillBtn")
SkillBtn.static.width = 150
SkillBtn.static.height = 30

function SkillBtn:initialize(x, y, skill)
    self.name = skill.name
    self.text = skill.name.." ["..-skill.energy.."]"
    self.hotkey = string.match(skill.name, "%((.?)%)")
    if self.hotkey then self.hotkey = string.lower(self.hotkey) end
    
    Button.initialize(self, x, y, SkillBtn.width, SkillBtn.height, self.text, function() skill:exec(battle.player, battle.enemy) end)
end

function SkillBtn:keypressed(key)
    if self.hotkey and string.lower(key) == self.hotkey then
        self.func()
    end
end
