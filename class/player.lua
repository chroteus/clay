Player = {
    country = nil, -- Set in countrySelect.lua
    xp = 0,
    xpToUp = 20,
    unspentPoints = 0,
    level = 1,
    money = 100,
    attack = 0,
    defense = 0,
}

function Player:gainXP(amount)
    local leveledUp = false    
    local finXP = self.xp + amount
    self.showXP = self.xp
    Timer.tween(1, self, {showXP = finXP})
    
    self.xp = self.xp + amount
    
    if finXP >= self.xpToUp then
        self.level = self.level + 1
        self.unspentPoints = self.unspentPoints + 1
        self.xp = 0
        leveledUp = true
        self.xpToUp = self.xpToUp * self.level
    end
    
    return finXP, leveledUp
end

function Player:returnCountry(notClone)
    for _,country in pairs(countries) do
        if country.name == Player.country then
            if notClone then
                return country
            else
                return country:clone()
            end
        end
    end
end
