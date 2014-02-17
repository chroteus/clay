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
function AttackSkill:initialize(barX, barY)
    self.name = "Attack"

    -- energy and cooldown are subtracted in self.func.
    self.energy = 0
    self.cooldown = 0

    self.slider = {
        x = barX,
        y = barY,
        width = 200,
        height = 60,
        enabled = false,
        power = 0
    }
    
    self.slider.powerRect = {
        x = self.slider.x,
        y = self.slider.y,
        width = self.slider.width,
        height = self.slider.height
    }

    self.func = function(fighter, target)
        self.slider.enabled = true
    end
    
    Skill.initialize(self, self.name, self.energy, self.cooldown, self.func)
end

function AttackSkill:updateSlider(dt)
    if self.slider.enabled then
        self.slider.powerRect.width = self.slider.powerRect.width - 10*dt
    end
end

function AttackSkill:keypressed(key)
    if key == " " then
       self.slider.power = self.slider.power + 1
    end
end

function AttackSkill:draw()

end
