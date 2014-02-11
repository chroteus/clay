Skill = Base:subclass("Skill")

function Skill:initialize(name, energy, cooldown, func)
    self.name = name
    self.energy = energy
    self.cooldown = cooldown
    self.cooldownReset = self.cooldown
    self.isReady = true
    self.func = func
end

function Skill:update(dt)
    if not self.isReady then
        self.cooldown = self.cooldown - dt
        if self.cooldown <= 0 then
            self.isReady = true
            self.cooldown = self.cooldownReset
        end
    end
end

function Skill:exec(fighter, target)
    if self.isReady then
        if fighter.energy - self.energy >= 0 then
            fighter.energy = fighter.energy - self.energy
            self.func(fighter, target)
        end
    
        self.isReady = false
    end
end

    
