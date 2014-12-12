-- not to be confused with "fightersScr", which is plural "fighters"
fighterScr = {}

function fighterScr.set(fighter)
    fighterScr.fighter = fighter
end


function fighterScr:init()
    fighterScr.fighter:setPos(200,the.screen.height/2 - fighterScr.fighter.height/2)
end

function fighterScr:enter()
    if fighterScr.fighter == nil then 
        error("Set fighter to display with fighterScr.set") 
    end
    
    fighterScr.fighter:setPos(200,the.screen.height/2 - fighterScr.fighter.height/2)
end

function fighterScr:update(dt)
    local fighter = fighterScr.fighter
    fighter.anim[fighter.anim_state]:update(dt)
end

function fighterScr:draw()
    fighterScr.fighter:draw()
end
