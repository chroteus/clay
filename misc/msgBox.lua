local PADDING = 5

msgBox = {
    x = PADDING,
    y = PADDING,
    width = 350,
    height = 120,
    headSize = 18,
    bodySize = 16,
}

local Msg = class("Msg")
function Msg:initialize(str)
	self.str = str
	self.x = PADDING
	
	if love.graphics.getFont():getWidth(self.str) > msgBox.width then
		-- double-line
		self.y = msgBox.y + msgBox.height - msgBox.bodySize*2 - PADDING*3
		self.dbline = true
	else
		-- single-line
		self.y = msgBox.y + msgBox.height - msgBox.bodySize - PADDING*2.5
	end
end

function Msg:draw(x,y)
	if self.y > PADDING then
		love.graphics.printf(self.str, x + self.x, y + self.y, msgBox.width, "left")
	end
end

function msgBox:reset()
    self.x = PADDING
    self.y = PADDING
    self.width = 350
    self.height = 120
end

msgBox.list = {}

function msgBox:add(str)
	print(#msgBox.list)
	local function slide(amount)
		for _,m in pairs(msgBox.list) do 
            Timer.tween(0.3, m, {y = m.y + amount}, "out-quad")
        end
    end
    
	if love.graphics.getFont():getWidth(str) > self.width then			
		slide(-40)
	else
		slide(-20)
    end
    
    table.insert(self.list, Msg(str))
    
    for k,msg in pairs(msgBox.list) do
		if msg.y < PADDING then
			table.remove(msgBox.list, k)
		end
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

function msgBox:draw(x,y)
	local x = x or self.x
	local y = y or self.y
	
    love.graphics.setColor(guiColors.bg)
    love.graphics.rectangle("fill", x,y, msgBox.width, msgBox.height)
    love.graphics.setColor(guiColors.fg)
    love.graphics.rectangle("line", x,y, msgBox.width, msgBox.height)
    
    for i,msg in ipairs(msgBox.list) do
        msg:draw(x,y)
    end
    
    love.graphics.setColor(guiColors.bg[1], guiColors.bg[2], guiColors.bg[3], 255)
	love.graphics.rectangle("fill", x,y, msgBox.width, gameFont[self.headSize]:getHeight()+PADDING*2)
	love.graphics.setColor(guiColors.fg)
	love.graphics.rectangle("line", x,y, msgBox.width, gameFont[self.headSize]:getHeight()+PADDING*2)
	
	love.graphics.setFont(gameFont[self.headSize])
    love.graphics.printf("Global News", x+PADDING, y+PADDING, msgBox.width-PADDING, "left")
    love.graphics.setFont(gameFont[self.bodySize])
    
    love.graphics.setColor(255,255,255)
end
