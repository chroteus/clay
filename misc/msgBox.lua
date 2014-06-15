local PADDING = 5

msgBox = {
    x = PADDING,
    y = PADDING,
    width = 350,
    height = 120,
    headSize = 18,
    bodySize = 16,
}
function msgBox:reset()
    self.x = PADDING
    self.y = PADDING
    self.width = 350
    self.height = 120
end

msgBox.list = {}

local LIMIT = msgBox.height/(love.graphics.getFont():getHeight()+10)

function msgBox:add(str)
    --[[
    if #msgBox.list > 0 then
        for _,m in pairs(msgBox.list) do
            --Timer.tween(0.3, m, {y = m.y + 20}, "out-quad") -- slide down
        end
    end
    ]]
    
    table.insert(self.list, str)
    
    if #msgBox.list > LIMIT then
        table.remove(msgBox.list, 1)
    end
end

function msgBox:update(dt)    
    if venus.current ~= battle then
        if checkCollision(msgBox.x,msgBox.y,msgBox.width,msgBox.height, the.mouse.x,the.mouse.y,1,1) then
            if msgBox.x+msgBox.width+PADDING == the.screen.width then
                msgBox.x = PADDING
            else
                msgBox.x = the.screen.width - msgBox.width - PADDING
            end
        end
    end
end

function msgBox:draw()
    love.graphics.setColor(guiColors.bg)
    love.graphics.rectangle("fill", msgBox.x,msgBox.y, msgBox.width, msgBox.height)
    love.graphics.rectangle("fill", msgBox.x,msgBox.y, msgBox.width, gameFont[self.headSize]:getHeight()+PADDING*2)
    love.graphics.setColor(guiColors.fg)
    love.graphics.rectangle("line", msgBox.x,msgBox.y, msgBox.width, msgBox.height)
    love.graphics.rectangle("line", msgBox.x,msgBox.y, msgBox.width, gameFont[self.headSize]:getHeight()+PADDING*2)

    love.graphics.setFont(gameFont[self.headSize])
    love.graphics.printf("Global News", msgBox.x+PADDING, msgBox.y+PADDING, msgBox.width-PADDING, "left")
    love.graphics.setFont(gameFont[self.bodySize])
    
    for i,msg in ipairs(msgBox.list) do
        love.graphics.printf(msg, msgBox.x+PADDING, msgBox.y + self.headSize*(i-1)+PADDING*7, msgBox.width-PADDING, "left")
    end
    
    love.graphics.setColor(255,255,255)
end
