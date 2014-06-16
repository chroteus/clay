countrySelect = {}

function countrySelect:init()
    SelectBtn = Button:subclass("CountrySelectBtn")
    function SelectBtn:initialize(xOrder, yOrder, ball, text, func)
        self.height = 50
        self.width = 150
        self.y = self.height * (yOrder*2)
        self.ball = love.graphics.newImage("assets/image/miniatures/"..ball..".png")
        self.text = text
        self.func = func
        
        self.ball:setFilter("nearest", "nearest")
        
        if xOrder == 1 then
            self.x = the.screen.width/2 - self.width*3
        elseif xOrder == 2 then
            self.x = the.screen.width/2 - self.width/2
        elseif xOrder == 3 then
            self.x = the.screen.width/2 + self.width*2
        else
            error("xOrder passed to SelectBtn should be between 1-3")
        end
    
        Button.initialize(self, self.x, self.y, self.width, self.height, self.text, self.func)
    end
    
    function SelectBtn:drawBall()
        local padding = 5
        local ballX = (self.x - self.ball:getWidth() - padding*2) / 2
        local ballY = (self.y + self.ball:getHeight() + padding*2) / 2
        love.graphics.draw(self.ball, ballX, ballY)
    end
    
    countrySelect.btn = {}

    local xOrdNum = 1
    local yOrdNum = 1
    for i, country in ipairs(countries) do
        if country.name ~= "Sea" then
            table.insert(countrySelect.btn,
                SelectBtn(xOrdNum, yOrdNum, country.name, country.name,
                    function() 
                        Player.country = country.name
                        Player.attack, Player.defense = country.attack, country.defense 
                        Gamestate.switch(tutorial)
                    end)
            )
            
            xOrdNum = xOrdNum + 1
            if xOrdNum == 4 then 
                xOrdNum = 1 
                yOrdNum = yOrdNum + 1
            end
        end
    end
    
    countryCam = Camera(the.screen.width/2, the.screen.height/2)
end


function countrySelect:update(dt)
    -- Converting camera to mouse coordinates.
    the.mouse.x, the.mouse.y = countryCam:mousepos()

    for _,button in pairs(countrySelect.btn) do
        button:update()
    end
    
    if countryCam.y < 288 then
        countryCam.y = 288
    end
end

function countrySelect:draw()
    countryCam:attach()
    love.graphics.printf("Scroll down!", 0, 40, the.screen.width, "center")
    
    for _,button in pairs(countrySelect.btn) do
        button:draw()
    end
    
    countryCam:detach()
end

function countrySelect:mousepressed(x, y, button)
    if button == "wu" then
        Timer.tween(0.2, countryCam, {y = countryCam.y - 25}, "out-quad")
    elseif button == "wd" then
        Timer.tween(0.2, countryCam, {y = countryCam.y + 25}, "out-quad")
    end
end

function countrySelect:mousereleased(x, y, button)
    for _,button in pairs(countrySelect.btn) do
        button:mousereleased(x, y, button)
    end
end
