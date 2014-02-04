require "class.country"

-- Images in tileset must appear in the SAME EXACT order as they appear here.
-- That means that the first tile in tileset.png MUST be "ua". And the second one "us", and so on.

-- WARNING! The name of miniature and ball image should be the same as Country's name!
-- Example: If we have an instance of Country with name "Ukraine",
-- both balls, /balls/left, /balls/right and miniatures folder should have a Ukraine.png image.


-- countries [Table]:
-- Where countries are instantiated.

countries = {
    -- Country(name, color, attack, defense, hp)
    Country("Sea", {255, 255, 255}, 0,0,0), -- A special "country". To be used for sea or as a placeholder if no countries are present.
    Country("Ukraine", {255,255,0}, 15,3, 50),
    Country("United States", {0,0,255}, 10,5, 100),
    Country("Canada", {255,0,0}, 10,2, 50),
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

