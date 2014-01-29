-- Small GUI lib.

require("lib.middleclass")

Button = class("Button")
-- Button class: Base class for other buttons.
-- Not to be used by itself.

guiColors = {
    bg = {225, 225, 225, 200},
    fg = {50, 50, 50, 200}
}

function Button:initialize(x, y, width, height, text, action)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.action = assert(action) -- Action to be executed when button is clicked.
    self.state = "idle" -- Default state is idle. State is used to change colors of button.
    self.text = text -- Text to be displayed.
    
    self.colors = {
        -- <self.colors> is table containing colors of button.
        -- Button's colors change if mouse is hovering or clicking on it.
        -- That depends on self.state.
    
        -- Idle = Mouse is outside of button.
        idle = {    
            bg = guiColors.bg,
            fg = guiColors.fg
        },
        
        -- active = Mouse is hovering on the button.
        active = {
            bg = {guiColors.bg[1] + 30, guiColors.bg[2] + 30, guiColors.bg[3] + 30, 255},
            fg = {guiColors.fg[1] + 30, guiColors.fg[2] + 30, guiColors.fg[3] + 30, 255}
        },
        
        -- clicked = Mouse clicked the button.
        clicked = {
            bg = {guiColors.bg[1] + 20, guiColors.bg[2] + 20, guiColors.bg[3] + 20, 1120},
            fg = {guiColors.fg[1] + 20, guiColors.fg[2] + 20, guiColors.fg[3] + 20, 1120}
        }
    }
end

function Button:update(dt)
    if checkCol(self, the.mouse) then -- Check if mouse and button overlap.
        self.state = "active"
    else
        self.state = "idle"
    end
end

function Button:mousepressed(x, y, button)
    -- To be used in mousepressed callback functions.
    
    if checkCol(self, the.mouse) then -- Check if mouse and button overlap.
        self.state = "clicked" -- Change state to "clicked" to change button's color.
    end
end

function Button:mousereleased(x, y, button)
    -- To be used in mousereleased callback functions.
    
    if checkCol(self, the.mouse) then -- Check if mouse and button overlap.
        self.action() -- Executes action of the button.
    end
end

function Button:draw()
    -- Change colors of button which depends on state of the buttton.

    if self.state == "idle" then
        love.graphics.setColor(self.colors.idle.bg)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        love.graphics.setColor(self.colors.idle.fg)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    elseif self.state == "active" then
        love.graphics.setColor(self.colors.active.bg)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        love.graphics.setColor(self.colors.active.fg)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    elseif self.state == "clicked" then
        love.graphics.setColor(self.colors.clicked.bg)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        love.graphics.setColor(self.colors.clicked.fg)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)       
    end
    

    love.graphics.setColor(255, 255, 255)

    if not self:isInstanceOf(CountryBtn) then
        love.graphics.setColor(self.colors.idle.fg)
        local fontHeight = (love.graphics.getFont():getHeight())/2
        love.graphics.printf(self.text, self.x, self.y + self.height/2 - fontHeight, self.width, "center")
    else
        local imageX = self.x + 4
        local imageY = self.y + 5
        
        love.graphics.draw(self.image, imageX, imageY)
    end
    
    love.graphics.setColor(255,255,255)
    
end


GenericButton = Button:subclass("GenericButton")
-- Generic Button: A button to be used in menu, or anywhere else outside shop.
-- It's preferable to use GenericButton rather than Button because it has less arguments.

function GenericButton:initialize(order, text, action)
    -- <order> defines button's y position, in a grid-like system.
    
    self.width = 120                 
    self.height = 45                   
    self.x = the.screen.width/2 - self.width/2
    self.y = self.height * (order*2)  -- y value depends on <order>.
    self.text = text
    self.action = action
    
    -- Initialize super class.
    Button.initialize(self, self.x, self.y, self.width, self.height, self.text, self.action)
end


ShopButton = Button:subclass("ShopButton")
-- Shop Button: Has icons, values of variables of something. ex: Player.maxHp
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
        if Player.money >= self.price then
            Player.money = Player.money - self.price
            self.variable = self.variable + self.amount
        end
    end
    
    -- Superclass init.
    Button.initialize(self, self.x, self.y, self.width, self.height, self.text, 
    function()
        if Player.money >= self.price then
            Player.money = Player.money - self.price
            self.variable = self.variable + self.amount
        end
    end
    ) -- End init.
end

function ShopButton:drawIcon()
    love.graphics.draw(self.icon, self.x - (35*scaleFactor), self.y)
    love.graphics.print(self.variable, self.x - (23*scaleFactor), self.y)
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
