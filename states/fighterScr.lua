-- not to be confused with "fightersScr", which is plural "fighters"
fighterScr = {}

function fighterScr.set(fighter)
    fighterScr.fighter = fighter
end


function fighterScr:init()
end

function fighterScr:enter()
    if fighterScr.fighter == nil then 
        error("Set fighter to display with fighterScr.set") 
    end
end

function fighterScr:update(dt)
    fighterScr.fighter:update(dt)
end

function fighterScr:draw()
    fighterScr.fighter:draw()
end
