Skill = Base:subclass("Skill")

function Skill:initialize(name, energy, func)
    self.name = name
    self.energy = energy
    self.used = false
    self.func = func
end

function Skill:exec(fighter, target)
    if not self.used then
        if fighter.energy - self.energy >= 0 then
            fighter.energy = fighter.energy - self.energy
            self.func(fighter, target)
        end 
        
        self.used = true
    end
end
