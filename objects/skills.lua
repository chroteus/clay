require "class.skill"

-- Skills which can be given to balls.
skills = {
    -- Skill(name, energy, cooldown, func)
    attack = Skill("(A)ttack", 1, 0.5, function(fighter, target) target:loseHP(math.random(target.defense+1, fighter.attack+5)) end),
    heal = Skill("(H)eal", 5, 5, function(fighter) fighter:gainHP(math.random(5,15)) end),
   
   
    -- Buff(name, energy, duration, cooldown, variable, amount)
   -- attackBuff = Buff("Attack Buff", 
}
                
