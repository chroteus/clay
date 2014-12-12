require "class.country"

-- WARNING! The name of miniature and ball image should be the same as Country's name!
-- Example: If we have an instance of Country with name "Ukraine",
-- both balls, /balls/left, /balls/right and miniatures folder should have a Ukraine.png image.

-- countries [Table]:
-- Where countries are instantiated.
countries = {

	-- indent width: 4
	--	    ######			  #######	  ########  #########  ####
    --      #name#            #color#     #attack#  #defense#  #hp#

    --      ##########
    --      #fighters#  
  
    Country("Sea", 			  {255,255,255}, 0,  		0, 		0),
  
    Country("Ukraine", 		  {200,200,0},   8,  		2, 		50),
    Country("United States",  {0,0,255},     10, 		5, 		70),
    Country("Canada", 		  {255,64,64},   9,  		4, 		80),
    Country("United Kingdom", {255,0,255},   9, 		4, 		80),
    Country("Norway", 		  {95,0,0},      9,  		4, 		70),
    Country("Sweden", 		  {0,0,60},      10, 		4, 		60),
    Country("Cyprus", 		  {237,128,0},   9,  		3, 		70),
    Country("Bavaria", 		  {0,162,232},   9,  		3, 		65),
    
    Country("Germany", 		  {255,0,0},     11, 		4, 		90,
            {{name = "Bundeswehr", attack = 6}}),
            
    Country("Finland", 		  {0,83,255},    9,  		5, 		65),
    Country("Denmark", 		  {100,50,50},   9,  		4, 		80),
    Country("France", 		  {230,230,230}, 8,  		5, 		90),
    Country("Austria", 		  {180,80,80},   10, 		4, 		70),
    Country("Belarus", 		  {0, 60, 0},    9,  		3, 		80),
    Country("Poland", 		  {200,0,40},    8,  		4, 		70,
            {{name = "Poland"}}),
    Country("Netherlands", 	  {96,170,255},  9,  		4, 		75),
    Country("Hungary", 		  {0,128,0},     8,  		4, 		80),
}

for i=1, #countries do countries[i].id = i end

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
				
				if #country.foes > 0 then
					for _,foe in pairs(country.foes) do		
						for i,_foe in ipairs(foe.foes) do
							if country.name == _foe then
								table.remove(foe.foes, i)
							end
						end
					end
				end

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

function nameToCountry(name)
    for _,country in pairs(countries) do
        if country.name == name then
            return country
        end
    end
end
