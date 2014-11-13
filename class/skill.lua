Skill = Base:subclass("Skill")

function Skill:initialize(name, energy, func)
    self.name = name
    self.energy = energy
    self.used = false
    self.func = func
end

function Skill:exec(fighter, target)
    if not fighter.turnFinished then
        if fighter.energy - self.energy >= 0 then
            fighter.energy = fighter.energy - self.energy
            self.func(fighter, target)
        end
    
		-- finding the skill with lowest energy "usage"
		local minEnergy = math.huge
		for _,skill in pairs(fighter.skills) do
			if skill.energy < minEnergy then
				minEnergy = skill.energy
			end
		end
    end
end
