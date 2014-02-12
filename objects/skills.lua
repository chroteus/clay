require "class.skill"

-- Skills which can be given to balls.

function knockback(target, speed)
    local origX = target.image.x
    local knockbackDist = -200
    if target.isLeft then knockbackDist = -knockbackDist end -- Reverse knockback if the target is on left.
    Timer.tween(0.6/speed, target.image, {x = target.image.x - knockbackDist}, "out-expo")
    Timer.tween(0.4/speed, target.image, {x = target.image.x + knockbackDist}, "out-quad")
end

skills = {
    -- Skill(name, energy, cooldown, func)
    quickAttack = Skill("(Q)uick Attack", 1, 1,
        function(fighter, target)
            target:loseHP(math.random(target.defense, fighter.attack))
            knockback(target, 1)
        end),
    
    attack = Skill("(A)ttack", 2, 3, 
        function(fighter, target) 
            target:loseHP(math.random(target.defense+5, fighter.attack+10))
            knockback(target, 0.5)
        end),
    
    heal = Skill("(H)eal", 5, 8, function(fighter) fighter:gainHP(math.random(5,15)) end),
   
   
}
                
