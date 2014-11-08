FighterItem = class "FighterItem"

function FighterItem:initialize(arg)
    self.name = arg.name or error("Name not defined.")
    self.text = arg.text or "Undefined text"
    
    if arg.type == "primary" or arg.type == "secondary"
    or arg.type == "tertiary" then
        self.type = arg.type
    else
        error("Type for an FighterItem must be either primary, secondary "..
              " or tertiary.")
    end
    
    self.onEquip = arg.onEquip or error("onEquip not defined.")
    self.onUnequip = arg.onUnequip or error("onUnequip not defined")
    
    --------------------------------------------------------------------
    -- VISUALS
    
    self.icon = love.graphics.newImage("assets/image/fighters/items/icons/" ..
                                        arg.name .. ".png")
    
    local frames
	if not arg.frames and self.name then 
        frames = "assets/image/fighters/items/images/" .. self.name .. ".png"
    elseif not arg.frames and not self.name then
        error("Neither name nor frames file defined")
    else
        frames = arg.frames
    end
    
    if type(frames) == "string" then
		self.frames = love.graphics.newImage(frames)
	else
		self.frames = frames
	end
	
	self.frames:setFilter("nearest", "nearest")
    
    -- size of frame
    self.width = 75; self.height = 70
    
	local grid = anim8.newGrid(self.width,self.height, self.frames:getWidth()-30, self.frames:getHeight(),15,0,0)
	self.anim = {
		still_south = anim8.newAnimation(grid(1,1), 0.1),
		south = anim8.newAnimation(grid("1-3", 1),  0.1),
		
		still_east  = anim8.newAnimation(grid(4, 1),  0.1),
		east  = anim8.newAnimation(grid("4-6", 1),  0.1),
		
		still_west  = anim8.newAnimation(grid(4, 1),  0.1):flipH(),
		west  = anim8.newAnimation(grid("4-6", 1),  0.1):flipH(),
		
		still_north = anim8.newAnimation(grid(7,1), 0.1),
		north = anim8.newAnimation(grid("7-9", 1), 0.1),
	}
    
    
    -- side: can be either "one" or "both"
    -- determines whether item will be drawn on both sides of the ball
    -- or only one
    self.side = arg.side or "one"
    
    
    self.anim_state = "still_south"
end

function FighterItem:update(dt)
    self.anim[self.anim_state]:update(dt)
end

function FighterItem:draw(state, x,y)
    -- state, x,y: passed down by Fighter
    self.anim_state = state
    self.anim[state]:draw(self.frames, x,y)
end
