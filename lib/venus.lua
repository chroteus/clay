venus = {}
venus.current = "No state"
venus.noState = true

venus.currentFx = "fade"

local transitions = {
    fade = {},
    slide = {}
}
--[[ 
List of transitions:

1) fade: Default one. Fades in to a black rectangle which covers whole screen, then fades out to the next state.
2) slide: Slides between states from right to left.
]]--

local all_callbacks = {
	"update", "draw", "focus", "keypressed", "keyreleased",
	"mousepressed", "mousereleased", "joystickpressed",
	"joystickreleased", "textinput", "quit"
}

function venus.registerEvents()
    for _,callback in pairs(all_callbacks) do
        local backupFunc = love[callback]
        love[callback] = function(...)
            if backupFunc then backupFunc(...) end
            if venus.current[callback] then venus.current[callback](self, ...) end
        end
    end
end

-- globalCalls: Add your functions which you want to be called with every state's callback
-- NOTE: Must be one of the callbacks from the all_callbacks list
--[[ Example: 
    venus.globalCalls = {
        update = function() print("test...") end, -- this will call print("test...") every frame.
    }
]]--

venus.globalCalls = {
}

function venus._switch(to, ...)
    -- internal switch function which directly switches without any transitions
    if venus.current.leave then venus.current.leave() end
    
    if to.init then to.init() end
    to.init = nil
    
    if to.enter then to.enter(venus.current, ...) end
    venus.current = to
    
    for _,callback in pairs(all_callbacks) do
        venus[callback] = function(...)
            if venus.current[callback] then
                
                for k,v in pairs(venus.globalCalls) do
                    if callback == k then
                        local backupFunc = venus.current[callback] 
                        
                        venus.current[callback] = function(self, ...)
                            v()
                            backupFunc()
                        end
                    end
                end
                
                if venus.noState then
                    venus.current[callback](self, ...)
                else                    
                    if callback == "draw" then
                        venus.current[callback](self, ...)
                        transitions[venus.currentFx].draw()
                    else
                        venus.current[callback](self, ...)
                    end
                end
            end
        end
    end
    
    venus.noState = false
end

function venus.switch(to, effect)
    if venus.noState then
        venus._switch(to)
    else
        local effect = effect or venus.currentFx
        assert(transitions[effect], '"'..effect..'"'.." animation does not exist.")
        
        if venus.currentFx ~= effect then venus.currentFx = effect end
        transitions[effect].switch(to)
    end
end

--#################--
--###--EFFECTS--###--

venus.timer = Timer

-- SLIDE ----------------------
local ts = transitions.slide

transitions.slide.state = {}

function transitions.slide.state:draw()
    if ts.pre then
        love.graphics.push()
        love.graphics.translate(ts.pre.x, ts.pre.y)
        if ts.pre.state.draw then ts.pre.state:draw() end
        love.graphics.pop()
    end
    
    if ts.to then 
        love.graphics.push()
        love.graphics.translate(ts.to.x, ts.to.y)
        if ts.to.state.draw then ts.to.state:draw() end
        love.graphics.pop()
    end
end

transitions.slide.switch = function(to, ...)
    ts.pre = {x = 0, y = 0, state = venus.current}
    ts.to = {x = love.window.getWidth(), y = 0, state = to}  
    
    if to.init then to.init(); to.init = nil end
    venus._switch(ts.state)

    venus.timer.tween(1, ts.pre, {x = -love.window.getWidth()}, "out-quad")
    venus.timer.tween(1, ts.to, {x = 0}, "out-quad", function() venus._switch(to) end)
end

transitions.slide.draw = function()
    ts.state:draw()
end


-- FADE ----------------------
local tf = transitions.fade

tf.rect = {
    color = {10,10,10},
    alpha = 0
}

tf.state = {}

function tf.state:draw()
    if tf.switched then
        if tf.to then 
            if tf.to.draw then tf.to:draw() end
        end
    else
        if tf.pre then
            if tf.pre.draw then tf.pre:draw() end
        end
    end
    
    love.graphics.setColor(tf.rect.color[1], tf.rect.color[2], tf.rect.color[3], tf.rect.alpha)
    love.graphics.rectangle("fill", 0, 0, love.window.getDimensions())
    love.graphics.setColor(255,255,255)
end

transitions.fade.switch = function(to, ...)
    tf.switched = false
    tf.pre = venus.current
    tf.to = to
    
    if to.init then to.init(); to.init = nil end
    venus._switch(tf.state)
    
    venus.timer.tween(0.3, tf.rect, {alpha = 255}, "out-quad", 
        function() 
            tf.switched = true 
            randBg()
            venus.timer.tween(0.3, tf.rect, {alpha = 0}, "out-quad", function() venus._switch(to) end)
        end
    )
end

transitions.fade.draw = function()
    tf.state:draw()
end


return venus
