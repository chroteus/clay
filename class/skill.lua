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
		
		-- end turn only if there are no usable moves left
		
		if fighter.energy < minEnergy then
			fighter.turnFinished = true
			target.turnFinished = false
		
			if target == battle.enemy then
				Timer.add(1, function() battle.ai() end)
			end
			
			fighter.energy = fighter.maxEnergy
		end
    end
end
