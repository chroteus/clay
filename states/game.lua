game = {}

function game:init()
    initMap()
end

function game:update(dt)
    updateMap(dt)
end

function game:draw()
    drawMap()
end

function game:mousepressed(x, y, button)
    mousepressedMap(x, y, button)
end
