-- not to be confused with "fighterScr"
fightersScr = {}

function fightersScr.setCountry(country)
    fightersScr.fighters = country.fighters
end
-------

function fightersScr:init()
end

function fightersScr:enter()
end

function fightersScr:update(dt)
    for _,fighter in pairs(fighterScr.fighters) do
        fighter:update(dt)
    end
end

function fightersScr:draw()
   for _,fighter in pairs(fightersScr.fighters) do
        fighter:draw()
    end
end
