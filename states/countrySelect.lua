countrySelect = {}

function countrySelect:init()    
    countrySelect.btn = GuiOrderedTable()
    for _,country in pairs(countries) do
		if country.name ~= "Sea" then
			countrySelect.btn:insert(CountrySelectBtn(country))
		end
	end
    
    countrySelect.space = love.graphics.newImage("assets/image/polan_in_space.png")
    countryCam = Camera(the.screen.width/2, the.screen.height/2)
    
    local boundHeight = #countrySelect.btn.btn * countrySelect.btn.btn[1].height * 2 + 100
    countryCam:setBounds(0,0, the.screen.width, boundHeight)
end


function countrySelect:update(dt)
    -- Converting camera to mouse coordinates.
    the.mouse.x, the.mouse.y = countryCam:mousepos()

	countrySelect.btn:update()
end

local function text(txt, y)
    love.graphics.printf(txt, 0, y, the.screen.width, "center")
end

function countrySelect:draw()
    countryCam:attach()
    text("Scroll down!", 40)
    text("Down, not up!", -1000)
    text("OK, you've won the game.", -5000)
    text("I bet your finger is tired by this point, eh?", -15000)
    text("You're very stubborn! You will gain nothing from this, you know?", -25000)
    love.graphics.draw(countrySelect.space, the.screen.width/2 - countrySelect.space:getWidth()/2,
                                   -40000)
    
    countrySelect.btn:draw()

    countryCam:detach()
end

function countrySelect:mousepressed(x, y, button)
    if button == "wu" then
        Timer.tween(0.2, countryCam, {y = countryCam.y - 50}, "out-quad")
    elseif button == "wd" then
        Timer.tween(0.2, countryCam, {y = countryCam.y + 50}, "out-quad")
    end
end

function countrySelect:mousereleased(x, y, button)
	countrySelect.btn:mousereleased(x, y, button)
end

function countrySelect:leave()
    fightersScr.setCountry(nameToCountry(Player.country))
end
