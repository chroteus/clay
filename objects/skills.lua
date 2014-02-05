require "class.skill"

-- Abilities which can be given to balls.
skills = {
    attack = Skill("Attack", 2,
                function(self, target) 
                    target:loseHP(math.random(target.defense+1, self.attack+5))
                end),
}
                

