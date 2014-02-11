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

Buff = Skill:subclass("Buff")

function Buff:initialize(name, energy, duration, cooldown, variable, amount)
    -- Buff: Increases a variable for a certain amount. Reverts back after <duration> seconds have passed.
    self.name = name
    self.energy = energy
    self.duration = duration
    self.cooldown = cooldown
    self.amount = amount
    self.func = function() variable = variable + amount end
    
    function self:cancel()
        variable = variable - amount
    end
    
    Skill.initialize(self, self.name, self.energy, self.cooldown, self.func)
end

function Buff:updateDuration(dt, variable)
    self.duration = self.duration - dt
    if self.duration <= 0 then
        self:cancel()
    end
end
    
    
