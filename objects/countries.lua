require "class.country"

-- WARNING! The name of miniature and ball image should be the same as Country's name!
-- Example: If we have an instance of Country with name "Ukraine",
-- both balls, /balls/left, /balls/right and miniatures folder should have a Ukraine.png image.

-- countries [Table]:
-- Where countries are instantiated.
countries = {
    -- WARNING: Countries should be added in order in which they are added to the game, or else maps will be corrupted.
    -- Country(name, color, attack, defense, hp)
    Country("Sea", {255, 255, 255}, 0,0,0), -- A special "country". To be used for sea or as a placeholder if no countries are present.
    Country("Ukraine", {255,255,0}, 8,2, 50),
    Country("United States", {0,0,255}, 12,4, 100),
    Country("Canada", {255,64,64}, 9,2, 50),
    Country("United Kingdom", {255,0,255}, 11, 4, 60),
    Country("Norway", {95,0,0}, 9, 4, 70),
    Country("Sweden", {0,0,60}, 10,4, 60),
    Country("Cyprus", {237,128,0}, 9, 3, 70),
    Country("Bavaria", {0,162,232}, 9,3, 65),
    Country("Germany", {255,0,0}, 11, 4, 90),
    Country("Finland", {0,53,128}, 9, 5, 65),
    Country("Denmark", {100,50,50}, 9, 4, 80),
    Country("France", {230,230,230}, 8, 5, 100),
    Country("Austria", {200,40,40}, 10, 4, 70),
    Country("Belarus", {38,127,0}, 9, 3, 80),
}

for i=1, #countries do
    countries[i].id = i
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

