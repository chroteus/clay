-- transition state
-- used to save the last state of screenBtn states.
transState = {}
transState.lastState = charScr -- set in screenBtn

function transState:init()
end

function transState:enter()
    randBg()
    Gamestate.switch(transState.lastState)
end
