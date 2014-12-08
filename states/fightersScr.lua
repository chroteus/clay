-- not to be confused with "fighterScr"
fightersScr = {}

function fightersScr.setCountry(country)
    fightersScr.fighters = country.fighters
end
-------

local function addFighters()
    local fy = the.screen.height - 200
    
    for xOrder,fighter in pairs(fightersScr.fighters) do
        fighter.orig_x = fighter.x
        fighter.orig_y = fighter.y

        fighter:setPos(xOrder*fighter.width - 5, fy + math.random(-3,3))
    end
end

function fightersScr:init()
    addFighters()
end

function fightersScr:enter()
    addFighters()
end

function fightersScr:update(dt)

end

function fightersScr:draw()
   for _,fighter in pairs(fightersScr.fighters) do
        fighter:draw()
    end
end

function fightersScr:leave()
    for _,fighter in pairs(fightersScr.fighters) do
        fighter.x = fighter.orig_x
        fighter.y = fighter.orig_y
    end
end
