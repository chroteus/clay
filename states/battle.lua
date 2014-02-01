leftCountry = 0
rightCountry = 0

function startBattle(argLeftCountry, argRightCountry) -- Sets opponents, and switched to battle gamestate.
    for _,country in pairs(countries) do
        if country.name == argLeftCountry or argRightCountry then
            if country.name == argLeftCountry then
                leftCountry = country
            elseif country.name == argRightCountry then
                rightCountry = country
            end
        end
    end
    
    Gamestate.switch(battle)
end

battle = {}

function battle:init()
    -- Shortcuts
    left = leftCountry 
    right = rightCountry
    
    left.image = left.rightImage
    left.x = 10
    left.y = 100
    
    right.image = right.leftImage
    right.x = the.screen.width - right.image:getWidth()
    right.y = 100
    
    battleCam = Camera(the.screen.width/2, the.screen.height/2)
end

function battle:update(dt)

end


function battle:draw()
    battleCam:attach()
    
    love.graphics.draw(left.image, left.x, left.y)
    love.graphics.draw(right.image, right.x, right.y)
    
    battleCam:detach()
end
