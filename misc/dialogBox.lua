DialogBox = Base:subclass("DialogBox")

local padding = 5

function DialogBox:initialize(text, ...)
    local argFunc = {...}
        
    self.width = 350
    self.height = 150
    self.x = the.screen.width/2-self.width/2
    self.y = the.screen.height/2-self.height/2
    self.hideFunc = "" -- Defined in show() method. Called after DialogBox is hidden. Often used to hide the mouse cursor again.
    self.alpha = 255
    
    self.enabled = false
 
    self.text = tostring(text)
    
    self.buttons = {}
    for i=1,#argFunc do
        local width = (self.width/#argFunc)
        local height = self.height/3
        local x = self.x + (width*(i-1))
        local y = self.y+self.height
        local text = argFunc[i][1]
        local func = function() 
            self:hide()
            argFunc[i][2]()
        end
        
        table.insert(self.buttons,
            Button(x,y,width,height,text, func)
        )
    end
end

function DialogBox:show(hideFunc)
    if not self.enabled then
        self.hideFunc = hideFunc
        
        love.mouse.setVisible(true)
        self.enabled = true
        self.y = -self.height
        self.x = the.screen.width/2-self.width/2
        
        Timer.tween(0.6, self, {y = the.screen.height/2-self.height/2}, "out-quad")
        
        for i,btn in ipairs(self.buttons) do
            btn.y = -btn.height
            btn.x = self.x + (btn.width*(i-1))
            Timer.tween(0.6, btn, {y = (the.screen.height/2-self.height/2)+self.height}, "out-quad")
        end
    end
end

function DialogBox:hide()
    if self.enabled then
        
        if self:isInstanceOf(InputDBox) then
            if self.enteredData then
                InputDBoxText = self.text
                self.func()
            end
        end
        
        Timer.tween(0.5, self, {x = -self.width}, "out-quad", function() self.enabled = false end)
        for i,btn in ipairs(self.buttons) do
            Timer.tween(0.5, btn, {x = the.screen.width+btn.width}, "out-quad", 
                function() 
                    if self.hideFunc then
                        self.hideFunc() 
                    end
                end
            )
        end
    end
end

function DialogBox:update(dt)
    if self.enabled then
        for _,btn in pairs(self.buttons) do
            btn:update()
        end
        
        if self:isInstanceOf(InputDBox) then
            self.beamDelay = self.beamDelay - dt
            if self.beamDelay <= 0 then
                if self.drawBeam then
                    self.drawBeam = false
                else
                    self.drawBeam = true
                end
                
                self.beamDelay = self.beamDelayReset
            end
        end
    end
end

function DialogBox:draw()
    if self.enabled then
        love.graphics.setColor(guiColors.bg[1],guiColors.bg[2],guiColors.bg[3],self.alpha)
        love.graphics.rectangle("fill",self.x,self.y,self.width,self.height)
        love.graphics.setColor(guiColors.fg)
        love.graphics.rectangle("line",self.x,self.y,self.width,self.height)    
        love.graphics.printf(self.text,self.x+padding,self.y+padding,self.width-padding,"left")
        
        if self:isInstanceOf(InputDBox) then
            love.graphics.printf("Character limit: "..#self.text.."/"..self.charLimit,self.x-padding,self.y+self.height-padding-love.graphics.getFont():getHeight(),self.width-padding,"right")
            if self.drawBeam then
                love.graphics.rectangle("fill", self.x+padding+gameFont[16]:getWidth(self.text), self.y+padding, 2, love.graphics.getFont():getHeight())
            end
        end
        
        for _,btn in pairs(self.buttons) do
            btn:draw()
        end
        
        love.graphics.setColor(255,255,255)
    end
end

function DialogBox:mousereleased(x,y,button)
    if self.enabled then
        for _,btn in pairs(self.buttons) do
            btn:mousereleased(x,y,button)
        end
    end
end

InputDBoxText = ""

InputDBox = DialogBox:subclass("InputDBox")
function InputDBox:initialize(charLimit, func)
    self.text = ""
    self.charLimit = charLimit
    self.func = assert(func)
    
    self.drawBeam = false
    self.beamDelay = 1
    self.beamDelayReset = self.beamDelay
    
    
    DialogBox.initialize(self, self.text, {"Cancel", function() end}, {"Enter", function() self.enteredData = true end})
end

function InputDBox:textinput(t)
    if #self.text < self.charLimit then
        self.text = self.text..t
    end
end

function InputDBox:keypressed(key)
    if key == "backspace" then
        self.text = self.text:sub(1, -2)
    elseif key == "return" then
        self.enteredData = true
        self:hide()
    end
    
    self.drawBeam = true
    self.beamDelay = self.beamDelayReset
end



DialogBoxes = {}
DialogBoxes.list = {}

function DialogBoxes:new(text, ...)
    local box = DialogBox(text, ...)
    table.insert(DialogBoxes.list, box)
    
    return DialogBoxes.list[#DialogBoxes.list]
end

function DialogBoxes:newInputDBox(charLimit, func)
    local box = InputDBox(charLimit, func)
    table.insert(DialogBoxes.list, box)
    
    return DialogBoxes.list[#DialogBoxes.list]
end

function DialogBoxes:update(dt)
    for _,box in pairs(DialogBoxes.list) do
        box:update(dt)
    end
end

function DialogBoxes:present()
    local result = false
    for _,box in pairs(DialogBoxes.list) do
        if box.enabled then
            result = true
        else
            result = false
        end
    end
    
    return result
end
    
function DialogBoxes:draw()
    -- this function shouldn't be called in love.draw because state's functions will draw over the dialogbox.
    for _,box in pairs(DialogBoxes.list) do
        box:draw()
    end
end

function DialogBoxes:mousereleased(x,y,button)
    for _,box in pairs(DialogBoxes.list) do
        box:mousereleased(x,y,button)
    end
end

function DialogBoxes:textinput(t)
    for _,box in pairs(DialogBoxes.list) do
        if box:isInstanceOf(InputDBox) then
            box:textinput(t)
        end
    end
end

function DialogBoxes:keypressed(key)
    for _,box in pairs(DialogBoxes.list) do
        if box:isInstanceOf(InputDBox) then
            box:keypressed(key)
        end
    end
end
