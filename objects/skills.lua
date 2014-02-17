require "class.skill"

-- Skills which can be given to balls.

function knockback(target, speed, distance)
    local origX = target.image.x
    local knockbackDist = distance or 200
    if target.isRight then knockbackDist = -knockbackDist end -- Reverse knockback if the target is on left.
    Timer.tween(0.6/speed, target.image, {x = target.image.x - knockbackDist}, "out-expo")
    Timer.tween(0.4/speed, target.image, {x = target.image.x + knockbackDist}, "out-quad")
end

skills = {
    -- Skill(name, energy, cooldown, func)
    quickAttack = Skill("(1) Quick", 1, 2,
        function(fighter, target)
            target:loseHP(math.random(target.defense, fighter.attack))
            knockback(target, 1)
        end),
    
    attack = Skill("(2) Normal", 2, 4, 
        function(fighter, target) 
            target:loseHP(math.random(target.defense+5, fighter.attack+10))
            knockback(target, 0.5)
        end),
    slowAttack = Skill("(3) Slow", 4, 8,
        function(fighter, target)
            target:loseHP(math.random(target.defense+10, fighter.attack+20))
            knockback(target, 1, 300)
        end),
    
    heal = Skill("(H)eal", 5, 16, function(fighter) fighter:gainHP(math.random(5,15)) end),
   
   
}
                
