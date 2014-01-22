require "class.country"

-- NOTE: Countries' id should be put in order. First item in the table should have and id of 1. 
-- Second item and id of 2 and so on.

-- Images in tileset must appear in the SAME EXACT order as they appear here.
-- That means that the first tile in tileset.png MUST be "us". And the second one "ua".

-- WARNING! The name of miniature and ball image should be the same as Country's name!
-- Example: If we have an instance of Country with name "Ukraine",
-- both balls, /balls/left, /balls/right and miniatures folder should have a Ukraine.png image.

countries = {
    -- Country(id, color, name, attack, defense)
    Ukraine = Country(1, {255,255,0}, "Ukraine", 10, 5),
    UnitedStates = Country(2, {0,0,255}, "United States", 20, 20)
}
