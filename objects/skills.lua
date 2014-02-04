require "class.skill"

-- Abilities which can be given to balls.
skills = {
    attack = Skill("Attack", 2,
                function(self, target) 
                    target:loseHP(self.attack) 
                end),
}
                

