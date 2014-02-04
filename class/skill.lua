Skill = class("Skill")

function Skill:initialize(name, energy, func)
    self.name = name
    self.energy = energy
    self.func = func
end

function Skill:exec(...)
    self.func(...)
end
