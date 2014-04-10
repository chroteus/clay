Base = class("Base")

function Base:initialize()
end

function Base:clone()
    -- Clone method: A method which takes an instance and clones it.
    -- Used in cases where we want multiple clones (like Cells).
    -- Used to separate the data, so that change in one clone won't affect another one.
    local t = {}
    for k,v in pairs(self) do
        t[k] = v
    end

    if self:isInstanceOf(Country) then
        t.loseHP = function(self, damage) Country.loseHP(self, damage) end
        t.loseEnergy = function(self, amount) Country.loseEnergy(self, amount) end
        t.gainHP = function(self, amount) Country.gainHP(self, amount) end
        t.addSkill = function(self, argSkill) Country.addSkill(self, argSkill) end
        t.invade = function(self, rowIndex, columnIndex) Country.invade(self, rowIndex, columnIndex) end
    elseif self:isInstanceOf(Skill) then
        t.update = function(self, dt) Skill.update(self, dt) end
        t.exec = function(self, fighter, target) Skill.exec(self, fighter, target) end
        
        if self:isInstanceOf(AttackSkill) then
            t.updateSlider = function(self, dt) AttackSkill.updateSlider(self, dt) end
            t.keypressed = function(self, key) AttackSkill.keypressed(self, key) end
            t.drawSlider = function(self) AttackSkill.drawSlider(self) end
        end
        
    end
    
    return t
end
