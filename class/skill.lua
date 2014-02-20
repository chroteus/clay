Skill = Base:subclass("Skill")

function Skill:initialize(name, energy, cooldown, func)
    self.name = name
    self.energy = energy
    self.cooldown = cooldown
    self.cooldownReset = self.cooldown
    self.isReady = true
    self.func = func
end

function Skill:update(dt)
    if not self.isReady then
        self.cooldown = self.cooldown - dt
        if self.cooldown <= 0 then
            self.isReady = true
            self.cooldown = self.cooldownReset
        end
    end
end

function Skill:exec(fighter, target)
    if self.isReady then
        if fighter.energy - self.energy >= 0 then
            fighter.energy = fighter.energy - self.energy
            self.func(fighter, target)
        end 
        
        self.isReady = false
    end
end


AttackSkill = Skill:subclass("AttackSkill")
function AttackSkill:initialize(extraFunc)
    self.name = "Attack"

    -- energy is subtracted based on the power of attack.
    self.energy = 1
    self.cooldown = 5

    self.slider = {
        -- x and y values are set in battle state.
        x = 0,
        y = 0,
        width = 300,
        height = 20,
        enabled = false,
        power = 0,
        countdown = self.cooldown,
    }
    
    self.slider.countdownReset = self.slider.countdown
    
    self.slider.powerRect = {
        x = self.slider.x,
        y = self.slider.y,
        width = 0,
        height = self.slider.height
    }

    self.func = function(...)
        self.slider.enabled = true
        extraFunc(...)
    end
    
    Skill.initialize(self, self.name, self.energy, self.cooldown, self.func)
end

function AttackSkill:updateSlider(dt)
    self.slider.powerRect.x = self.slider.x
    self.slider.powerRect.y = self.slider.y
    
    if self.slider.enabled then
        self.slider.powerRect.width = self.slider.powerRect.width - 150*dt
        
        if self.slider.powerRect.width <= 0 then
            self.slider.powerRect.width = 0
        elseif self.slider.powerRect.width >= self.slider.width then
            self.slider.powerRect.width = self.slider.width
        end
        
        self.slider.countdown = self.slider.countdown - dt
        if self.slider.countdown <= 0 then
            self.slider.enabled = false
        
            player.energy = player.energy - math.floor(self.slider.powerRect.width / 30)
            enemy:loseHP(math.floor(self.slider.powerRect.width / 15) + player.attack)
            
            Timer.tween(0.5, self.slider.powerRect, {width = 0}, "out-quad")
            
            self.slider.countdown = self.slider.countdownReset
        end
    end
end

function AttackSkill:keypressed(key)
    if self.slider.enabled then
        if key == " " then
           self.slider.power = self.slider.power + 1
           self.slider.powerRect.width = self.slider.powerRect.width + 30
        end
    end
end

function AttackSkill:drawSlider()
    local widthColor = self.slider.powerRect.width
    if widthColor > 255 then widthColor = 255 end
    
    love.graphics.setColor(widthColor,0,0)
    love.graphics.rectangle("line", self.slider.x, self.slider.y, self.slider.width, self.slider.height)

    love.graphics.setColor(widthColor,0,0)
    love.graphics.rectangle("fill", self.slider.powerRect.x, self.slider.powerRect.y, self.slider.powerRect.width, self.slider.powerRect.height)
    love.graphics.setColor(255,255,255)
end
