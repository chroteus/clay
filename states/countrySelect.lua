countrySelect = {}

function countrySelect:init()    
    countrySelect.btn = GuiOrderedTable()
    for _,country in pairs(countries) do
		if country.name ~= "Sea" then
			countrySelect.btn:insert(CountrySelectBtn(country))
		end
	end
    
    countryCam = Camera(the.screen.width/2, the.screen.height/2)
    
    local boundHeight = #countrySelect.btn.btn * countrySelect.btn.btn[1].height * 2 + 100
    countryCam:setBounds(0,0, the.screen.width, boundHeight)
end


function countrySelect:update(dt)
    -- Converting camera to mouse coordinates.
    the.mouse.x, the.mouse.y = countryCam:mousepos()

	countrySelect.btn:update()
end

function countrySelect:draw()
    countryCam:attach()
    love.graphics.printf("Scroll down!", 0, 40, the.screen.width, "center")
    
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
