DialogBox = Base:subclass("DialogBox")

local padding = 5

function DialogBox:initialize(text, ...)
    local argFunc = {...}
        
    self.width = 350
    self.height = 150
    self.x = the.screen.width/2-self.width/2
    self.y = the.screen.height/2-self.height/2
    
    self.enabled = false
 
    self.text = tostring(text)
    
    self.buttons = {}
    for i=1,#argFunc do
        local width = (self.width/#argFunc)
        local height = self.height/3
        local x = self.x + ((width*(i-1)))
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

function DialogBox:show()
    self.enabled = true
    self.y = -self.height
    
    Timer.tween(0.8, self, {y = the.screen.height/2-self.height/2}, "out-quad")
    
    for _,btn in pairs(self.buttons) do
        btn.y = -btn.height
        Timer.tween(0.8, btn, {y = (the.screen.height/2-self.height/2)+self.height}, "out-quad")
    end
end

function DialogBox:hide()
    Timer.tween(0.8, self, {y = the.screen.width+self.height}, "out-quad", function() self.enabled = false end)
    for _,btn in pairs(self.buttons) do
        Timer.tween(0.8, btn, {y = the.screen.width+btn.height}, "out-quad")
    end
end

function DialogBox:update()
    if self.enabled then
        for _,btn in pairs(self.buttons) do
            btn:update()
        end
    end
end

function DialogBox:draw()
    if self.enabled then
        love.graphics.setColor(guiColors.bg)
        love.graphics.rectangle("fill",self.x,self.y,self.width,self.height)
        love.graphics.setColor(guiColors.fg)
        love.graphics.rectangle("line",self.x,self.y,self.width,self.height)    
        love.graphics.printf(self.text,self.x+padding,self.y+padding,self.width-padding,"left")
        love.graphics.setColor(255,255,255)
        
        for _,btn in pairs(self.buttons) do
            btn:draw()
        end
    end
end

function DialogBox:mousereleased(x,y,button)
    if self.enabled then
        for _,btn in pairs(self.buttons) do
            btn:mousereleased(x,y,button)
        end
    end
end

DialogBoxes = {}
DialogBoxes.list = {}

function DialogBoxes:new(text, ...)
    local box = DialogBox(text, ...)
    table.insert(DialogBoxes.list, box)
    
    return DialogBoxes.list[#DialogBoxes.list]
end

function DialogBoxes:update()
    for _,box in pairs(DialogBoxes.list) do
        box:update()
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
    
        
    


        

    
