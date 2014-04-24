-- A screen to choose countries to "paint" over map in edit mode.

selection = {}

function selection:init()
    -- Creating a special CountryBtn class to choose countries.
    CountryBtn = Button:subclass("CountryBtn")
    function CountryBtn:initialize(x,y,country)
        self.x = x
        self.y = y
        self.country = country
        self.image = self.country.miniature
        self.width = 25
        self.height = 25
        self.text = " "
        self.func = function()
                        editMode.country = self.country.name
                        editMode.enabled = true
                        switchState(game)
                      end
        
        Button.initialize(self, self.x, self.y, self.width, self.height, self.text, self.func)
    end
    
    countryButtons = {}
    
    local rowIndex = 1
    for i,country in pairs(countries) do
        if i*25 > the.screen.width-25 then rowIndex = rowIndex + 1 end
        table.insert(countryButtons, CountryBtn(i*25, 25*rowIndex, country))
    end
end

function selection:enter()
    love.mouse.setVisible(true)
    love.mouse.setGrabbed(false)
end

function selection:update(dt)
    for _,btn in pairs(countryButtons) do
        btn:update()
    end
end

function selection:draw()
    for _,btn in pairs(countryButtons) do
        btn:draw()
    end
    
    love.graphics.printf('Sea: A placeholder "country" to be placed in the place of countries which are not created yet or in the place of sea.', 20, the.screen.height - 30, the.screen.width, "left")
end

function selection:mousereleased(x,y,button)
    for _,btn in pairs(countryButtons) do
        btn:mousereleased(x,y,button)
    end
end


function selection:keyreleased(key)
    if key == "q" then
        switchState(game)
    end
end
