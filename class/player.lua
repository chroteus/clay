Player = {
    country = nil, -- Set in countrySelect.lua
    xp = 0,
    xpToUp = 20,
    level = 1,
    money = 100
}

function Player:gainXP(amount)
    local finXP = self.xp + amount    
    Timer.tween(1, self, {xp = finXP})
    
    if finXP >= self.xpToUp then
        self.level = self.level + 1
        self.xpToUp = self.xpToUp * (self.level*2)
    end
    
    return finXP
end

