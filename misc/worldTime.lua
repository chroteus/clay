worldTime = {
	day = 01,
	month = 01,
	year = 2000,
	
	dayLength = 0.5, -- length of world day in RL seconds
	
	leapYearCount = 4, -- 4 because we start at 2000
	
	prevMonthWas31 = false, -- handling July and August
	stopProgress = true,
}

function worldTime:start()
	self.stopProgress = false
	self:progress()
end

function worldTime:progress()
	if not self.stopProgress then
	
		local function progressMonth()
			if self.month == 12 then 
				self.year = self.year + 1
				self.leapYearCount = self.leapYearCount + 1
				self.month = 0 
			end
			
			self.month = self.month + 1
			
			if self.day == 31 then self.prevMonthWas31 = true
			else self.prevMonthWas31 = false end
			
			if self.month == 7 or self.month ==  8 then  
				self.prevMonthWas31 = false -- for July and August
			end
			
			self.day = 0
		
			if self.leapYearCount > 4 then self.leapYearCount = 0 end
		end
			
		if self.month ~= 2 then
			
			if self.day == 30 and self.prevMonthWas31
			or self.day == 31 and not self.prevMonthWas31 then
				progressMonth()
			end
			
		elseif self.month == 2 then
			
			local isNewCentury = self.year % 100 == 0
			
			if self.day == 29 and self.leapYearCount == 4 then
				if isNewCentury and self.year % 400 == 0 then 
					progressMonth()
				elseif not isNewCentury then
					progressMonth()
				end
				
				self.leapYearCount = 0
			end
			
			if self.day == 28  and self.leapYearCount ~= 4 then progressMonth() end
		end
		
		self.day = self.day + 1	
		Timer.add(self.dayLength, function() worldTime:progress() end)
	end
end

function worldTime:stop()
	self.stopProgress = true
end

local months = {
	"January", "February", "March", "April", "May", "June", 
	"July", "August", "September", "October", "November", "December"
}

function worldTime:draw()
	love.graphics.setColor(guiColors.fg)
	love.graphics.printf(self.day .. " " .. months[self.month] .. " " .. self.year, 0, the.screen.height-25, the.screen.width-15, "right")
	love.graphics.setColor(255,255,255)
end
