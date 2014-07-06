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
    self.state = "idle" -- Default state is idle. State is used to change colors of button.
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
    if checkCol(self, the.mouse) then self.state = "active"
	else self.state = "idle"
    end
end

function Button:mousereleased(x, y, button)    
    if checkCol(self, the.mouse) then
        self.func()
        TEsound.play("assets/sounds/mouseclick.wav")
    end
end

function Button:draw(rgba)
    -- Change colors of button which depends on state of the buttton.

	if rgba then
		love.graphics.setColor(rgba)
	else
		love.graphics.setColor(self.colors[self.state].bg)
	end
	
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)


	if self.state == "active" then love.graphics.setLineWidth(2) end
	love.graphics.setColor(self.colors[self.state].fg)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(255, 255, 255)

    if not self:isInstanceOf(CountryBtn) then
        love.graphics.setColor(self.colors[self.state].fg)
        love.graphics.setFont(gameFont[18])
        local fontHeight = (love.graphics.getFont():getHeight())/2
        love.graphics.printf(self.text, self.x, self.y + self.height/2 - fontHeight, self.width, "center")
        love.graphics.setFont(gameFont[16])
    else
        local imageX = self.x + 4
        local imageY = self.y + 5
        
        love.graphics.draw(self.image, imageX, imageY)
    end
    
    love.graphics.setColor(255,255,255)
    
    if self:isInstanceOf(SelectBtn) then
        love.graphics.push()
        love.graphics.scale(2)
        self:drawBall()
        love.graphics.pop()
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
-- Shop Button: Has icons, values of variables of something. ex: fighter.maxHP
-- Used solely in shop.

function ShopButton:initialize(order, icon, variable, price, amount, text)
    self.width = 280
    self.height = 120
    self.x = the.screen.width/2 - self.width/2
    self.y = ((self.height + 20) * order)
    self.icon = love.graphics.newImage("assets/graphics/"..icon)
    self.variable = variable
    self.price = price
    self.amount = amount
    self.text = "+"..self.amount.." "..text..", "..self.price.."$"
    
    local function buy()
        if fighter.money >= self.price then
            fighter.money = fighter.money - self.price
            self.variable = self.variable + self.amount
        end
    end
    
    -- Superclass init.
    Button.initialize(self, self.x, self.y, self.width, self.height, self.text, 
    function()
        if fighter.money >= self.price then
            fighter.money = fighter.money - self.price
            self.variable = self.variable + self.amount
        end
    end
    ) -- End init.
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
