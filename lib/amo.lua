local amo = {
    x = love.window.getWidth()/2,
    y = love.window.getHeight()/2,
    scale = 1,
}

amo.__index = amo

local function new(x,y, zoom)
	x,y  = x or love.window.getWidth()/2, y or love.window.getHeight()/2
	zoom = zoom or 1
	return setmetatable({x = x, y = y, scale = zoom}, amo)
end

function amo:setBounds(x1,y1, x2,y2)
    local width,height = love.window.getDimensions()   
    self.bounds = {min = {x=(x1*self.scale)+width/2, y=(y1*self.scale)+height/2}, max = {x=(x2*self.scale)-width/2, y=(y2*self.scale)-height/2}}

    self.origBounds = {min = {x = x1, y = y1}, max = {x = x2, y = y2}}
end

function amo:setX(x)
    self.x = math.clamp(self.bounds.min.x, x, self.bounds.max.x)
end

function amo:setY(y)
    self.y = math.clamp(self.bounds.min.y, y, self.bounds.max.y)
end

function amo:setPos(x,y)
    self:setX(x)
    self:setY(y)
end

function amo:update()
    local width,height = love.window.getDimensions()
    local orig = self.origBounds
    
    self.bounds.min.x, self.bounds.min.y = orig.min.x*self.scale + width/2, orig.min.y*self.scale + height/2
    self.bounds.max.x, self.bounds.max.y = orig.max.x*self.scale - width/2, orig.max.y*self.scale - height/2
    
    self.bounds.min.x = (self.bounds.min.x)/self.scale
    self.bounds.max.x = (self.bounds.max.x)/self.scale
    self.bounds.min.y = (self.bounds.min.y)/self.scale
    self.bounds.max.y = (self.bounds.max.y)/self.scale
    
    self.x = math.clamp(self.bounds.min.x, self.x, self.bounds.max.x)
    self.y = math.clamp(self.bounds.min.y, self.y, self.bounds.max.y)
end

function amo:getViewport()
    return self:cameraCoords(0,0)
end

function amo:zoomTo(zoom)
    self.scale = zoom
end

function amo:worldCoords(x,y)
	local width,height = love.window.getDimensions()
	local x,y = (x - width/2) / self.scale, (y - height/2) / self.scale
	return x+self.x, y+self.y
end

function amo:cameraCoords(x,y)
	local width,height = love.window.getDimensions()
	local x,y = x - self.x, y - self.y
	return x*self.scale + width/2, y*self.scale + height/2
end

function amo:mousepos()
    return self:worldCoords(love.mouse.getPosition())
end

function amo:attach()
    local cx,cy = love.window.getWidth()/2, love.window.getHeight()/2
    love.graphics.push()
    love.graphics.translate(cx,cy)
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function amo:detach()
    love.graphics.pop()
    
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})

    
