require "class.skill"

-- Skills which can be given to balls.
skills = {
    -- Skill(name, energy, cooldown, func)
    
    attack = Skill("Attack", 2, 1, function(self, target) target:loseHP(math.random(target.defense+1, self.attack+5)) end),
    heal = Skill("Heal", 5, 10, function(self) self:gainHP(math.random(5,15)) end),
}
                

