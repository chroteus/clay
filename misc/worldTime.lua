worldTime = {
	time = {
		day = 01,
		month = 01,
		year = 2000
	},
	
	dayLength = 0.2, -- length of world day in RL seconds
	
	leapYearCount = 4, -- 4 because we start at 2000
	
	prevMonthWas31 = false, -- handling July and August
	stop = true,
}

function worldTime:start()
	self.stop = false
	self:progress()
end

function worldTime:progress()
	if not self.stop then
	
		local function progressMonth()
			if self.time.month == 12 then 
				self.time.year = self.time.year + 1
				self.leapYearCount = self.leapYearCount + 1
				self.time.month = 0 
			end
			
			self.time.month = self.time.month + 1
			
			if self.time.day == 31 then self.prevMonthWas31 = true
			else self.prevMonthWas31 = false end
			
			if self.time.month == 7 or self.time.month ==  8 then  
				self.prevMonthWas31 = false -- for July and August
			end
			
			self.time.day = 0
		
			if self.leapYearCount > 4 then self.leapYearCount = 0 end
		end
			
		if self.time.month ~= 2 then
			
			if self.time.day == 30 and self.prevMonthWas31
			or self.time.day == 31 and not self.prevMonthWas31 then
				progressMonth()
			end
			
		elseif self.time.month == 2 then
			
			local isNewCentury = self.time.year % 100 == 0
			
			if self.time.day == 29 and self.leapYearCount == 4 then
				if isNewCentury and self.time.year % 400 == 0 then 
					progressMonth()
				elseif not isNewCentury then
					progressMonth()
				end
				
				self.leapYearCount = 0
			end
			
			if self.time.day == 28  and self.leapYearCount ~= 4 then progressMonth() end
		end
		
		self.time.day = self.time.day + 1	
		Timer.add(self.dayLength, function() worldTime:progress() end)
	end
end

function worldTime:stop()
	self.stop = true
end

local months = {
	"January", "February", "March", "April", "May", "June", 
	"July", "August", "September", "October", "November", "December"
}

function worldTime:draw()
	love.graphics.setColor(guiColors.fg)
	love.graphics.printf(self.leapYearCount ..  " " .. self.time.day .. " " .. months[self.time.month] .. " " .. self.time.year, 0, the.screen.height-25, the.screen.width-15, "right")
	love.graphics.setColor(255,255,255)
end
