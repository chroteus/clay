-- transition state
-- used to save the last state of screenBtn states.
transState = {}
transState.lastState = charScr -- set in screenBtn

function transState:init()
end

function transState:enter()
    randBg()
    
    if prefs.firstPlay then
        prefs.firstPlay = false
        savePrefs()
    end
    
    switchState(transState.lastState)
end

function transState:draw()
end
