require "class.skill"

-- Skills which can be given to balls.
function knockback(target, speed, distance)
    local origX = target.x
    local knockbackDist = distance or 300
    if target.x > the.screen.width/2 then knockbackDist = -knockbackDist end -- Reverse knockback if the target is on left.
    Timer.tween(0.6/speed, target, {x = target.x - knockbackDist}, "out-expo")
    Timer.tween(0.4/speed, target, {x = target.x + knockbackDist}, "out-quad")
end

skills = {
    -- Skill(name, energy, func)

    attack = Skill("(A)ttack", 3, 
        function(fighter, target)
			target:loseHP(math.floor(math.random(fighter.attack/1.5, fighter.attack*1.5)))
			knockback(target, 1)
        end),
        
    heal = Skill("(H)eal", 7, function(fighter) fighter:gainHP(math.random(10,20)) end),
    
    fire = Skill("(F)ire", 10, function(fighter, target) buffs.fire:apply(target) end),
}
                
