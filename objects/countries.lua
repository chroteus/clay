require "class.country"

-- WARNING! The name of miniature and ball image should be the same as Country's name!
-- Example: If we have an instance of Country with name "Ukraine",
-- both balls, /balls/left, /balls/right and miniatures folder should have a Ukraine.png image.

-- countries [Table]:
-- Where countries are instantiated.
countries = {    
    -- Country(name, color, attack, defense, hp)
    Country("Sea", {0,0,0}, 0,0,0), -- A special "country". To be used for sea or as a placeholder if no countries are present.
    Country("Ukraine", {200,200,0}, 8,2, 50),
    Country("United States", {0,0,255}, 12,5, 95),
    Country("Canada", {255,64,64}, 9,4, 80),
    Country("United Kingdom", {255,0,255}, 11, 4, 80),
    Country("Norway", {95,0,0}, 9, 4, 70),
    Country("Sweden", {0,0,60}, 10,4, 60),
    Country("Cyprus", {237,128,0}, 9, 3, 70),
    Country("Bavaria", {0,162,232}, 9,3, 65),
    Country("Germany", {255,0,0}, 11, 4, 90),
    Country("Finland", {0,83,255}, 9, 5, 65),
    Country("Denmark", {100,50,50}, 9, 4, 80),
    Country("France", {230,230,230}, 8, 5, 100),
    Country("Austria", {180,80,80}, 10, 4, 70),
    Country("Belarus", {0, 60, 0}, 9, 3, 80),
    Country("Poland", {220,20,60}, 8, 4, 70),
    Country("Netherlands", {66,140,255}, 9,4, 75),
    Country("Hungary", {0,128,0}, 8, 4, 80),
}

for i=1, #countries do
    countries[i].id = i
end

function checkIfDead()
        if not Player:returnCountry().isDead then
        -- checking for the number of regions a country posseses
        -- kills the country if there are none

        for _,country in pairs(countries) do
            local num = 0
            
            for _,region in pairs(map) do
                if region.id == country.id then
                    num = num + 1
                end
            end
            
            if num == 0 then 
                country.isDead = true
                
                if country.name == Player.country then
                    venus._switch(gameOver)
                else
                    if not country.deadMessagePrinted then
                        msgBox:add(country.name.." is defeated!")
                        country.deadMessagePrinted = true
                    end
                end
            end
        end
    end
end

function funcCountry(countryName, func)
    assert(type(countryName) == "string", "funcCountry function needs string as its first argument.")
    assert(type(func) == "function", "funcCountry function needs function as its second argument.")
    for _,country in pairs(countries) do
        if country.name == countryName then
            func()
        end
    end
end

function nameToCountry(name)
    for _,country in pairs(countries) do
        if country.name == name then
            return country
        end
    end
end

function idToCountry(id)
    for _,country in pairs(countries) do
        if country.id == id then
            return country
        end
    end
end

