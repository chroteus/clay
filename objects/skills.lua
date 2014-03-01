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

    -- Attack skill for the player
    attack = AttackSkill(
        function(fighter, target)
            knockback(target, 1)
        end),
        
    -- Attack skill for the AI
    aiAttack = Skill("AI Attack", 1, 1, 
        function(fighter, target) 
            target:loseHP(math.random(fighter.defense+1, target.attack + 10)) 
            knockback(target, 1)
        end),
        
    heal = Skill("(H)eal", 5, 5, function(fighter) fighter:gainHP(math.random(5,15)) end),
   
   
}
                
