local msgBoxX = 5
local msgBoxY = 5
local msgBoxW = love.graphics.getWidth()/2-50
local msgBoxH = 90

local Msg = Base:subclass("Msg")
function Msg:initialize(str)
    self.str = str
    self.x = msgBoxX + 5
    self.y = msgBoxY + 5
    self.timer = 3
    self.timerReset = self.timer
end

function Msg:update(dt)

end

function Msg:print()
    love.graphics.printf(self.str, self.x, self.y, msgBoxW-5, "left")
end

msgBox = {}
msgBox.list = {}

local LIMIT = msgBoxW / 20

function msgBox:add(str)
    if #msgBox.list > 0 then
        for _,m in pairs(msgBox.list) do
            Timer.tween(0.3, m, {y = m.y + 20}, "out-quad") -- slide down
        end
    end
    
    table.insert(self.list, Msg(str))
    
    if #msgBox.list > 4 then
        table.remove(msgBox.list, 1)
    end
end

function msgBox:update(dt)
    for _,msg in pairs(msgBox.list) do
        msg:update(dt)
    end

    local orig = {x=msgBoxX,y=msgBoxY,w=msgBoxW,h=msgBoxH}
        
    if checkCollision(msgBoxX,msgBoxY,msgBoxW,msgBoxH, the.mouse.x,the.mouse.y,1,1) then
        if msgBoxX+msgBoxW+5 == the.screen.width then
            msgBoxX = 5
        else
            msgBoxX = the.screen.width - msgBoxW - 5
        end
    end
end

function msgBox:draw()
    love.graphics.setColor(guiColors.bg)
    love.graphics.rectangle("fill", msgBoxX,msgBoxY, msgBoxW, msgBoxH)
    love.graphics.setColor(guiColors.fg)
    love.graphics.rectangle("line", msgBoxX,msgBoxY, msgBoxW, msgBoxH)

    for _,msg in pairs(msgBox.list) do
        msg:print()
    end
    
    love.graphics.setColor(255,255,255)
end
        
