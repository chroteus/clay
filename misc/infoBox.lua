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
	infoBox.name = ""
	infoBox.id = 1
end

function infoBox:update(dt)
	for _,region in pairs(map) do
		if PointWithinShape(region.vertices, mapMouse.x, mapMouse.y) then
			self.countryName = countries[region.id].name
			self.name = region.name
			self.region = region
			self.id = region.id
		end
	end
end

function infoBox:draw(x,y)
	local x = x or self.x
	local y = y or self.y
	
	guiRect(x, y, self.width, self.height)
	

	love.graphics.setColor(guiColors.fg)
	
	if countries[self.id].name ~= "Sea" then
		love.graphics.printf(self.name..", "..self.countryName, x+5, y+5, self.width, "left")
	else
		love.graphics.printf(self.countryName, x+5, y+5, self.width, "left")
	end
	
	love.graphics.setColor(255,255,255)
end
