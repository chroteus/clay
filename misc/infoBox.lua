------------
--Info Box--
infoBox = {}

function infoBox:init()
	infoBox.delay = 0.5
	infoBox.delayReset = infoBox.delay
	infoBox.width = 280
	infoBox.height = 120
	infoBox.x = the.screen.width/2-infoBox.width/2
	infoBox.y = 5
	infoBox.countryName = ""
	infoBox.id = 1
end

function infoBox:update(dt)
	for _,region in pairs(map) do
		if PointWithinShape(region.vertices, mapMouse.x, mapMouse.y) then
			self.countryName = countries[region.id].name
			self.region = region
			self.id = region.id
		end
	end
end

function infoBox:draw(x,y)
	local x = x or self.x
	local y = y or self.y
	
	guiRect(x, y, self.width, self.height)
	
	local fontH = love.graphics.getFont():getHeight()
	local padding = 5
	guiRect(x,y,self.width, fontH + padding*2)

	love.graphics.setColor(guiColors.fg)	
    love.graphics.printf(self.countryName, x+5, y+5, self.width, "left")
	
	love.graphics.setColor(255,255,255)
end
