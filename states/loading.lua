-- Since map takes quite a while to load, switching to loading state should reduce the feeling of lag.
loading = {}

local state

function loading.switch(stateToSwitch)
	venus.switch(loading)
	state = stateToSwitch
end

function loading:enter()
	Timer.add(0.1, function() venus.switch(state) end)
	if state.init then state:init(); state.init = nil end
end

function loading:draw()
	--love.graphics.setColor(50,50,50)
	--love.graphics.rectangle("fill", 0,0, the.screen.width,the.screen.height)
	
	love.graphics.setColor(255,255,255)
	local fontSize = 50
	love.graphics.setFont(gameFont[fontSize])
	love.graphics.printf("Loading", 0, the.screen.height - fontSize*2, the.screen.width - fontSize, "right")
end


