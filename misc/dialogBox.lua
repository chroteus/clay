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

function DialogBox:update()
    if self.enabled then
        for _,btn in pairs(self.buttons) do
            btn:update()
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
    
        
    


        

    
