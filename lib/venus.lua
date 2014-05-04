venus = {}
venus.current = "Didn't switch to a state yet"

local all_callbacks = {
	"update", "draw", "focus", "keypressed", "keyreleased",
	"mousepressed", "mousereleased", "joystickpressed",
	"joystickreleased", "textinput", "quit"
}

function venus.switch(to)
    if venus.current.leave then venus.current.leave() end
    
    if to.init then to.init() end
    to.init = nil
    
    if to.enter then to.enter(venus.current) end
    venus.current = to
    
    for _,callback in pairs(all_callbacks) do
        venus[callback] = function(...)
            if venus.current[callback] then 
                venus.current[callback](self, ...)
            end
        end
    end
end
