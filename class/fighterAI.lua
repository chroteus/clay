FighterAI = Fighter:subclass("FighterAI")

function FighterAI:initialize(arg)
    Fighter.initialize(self, arg)
end

function FighterAI:attack(fighter)
    self.enemy_to_attack = fighter

    if self:inAttackZone() then
        self:_attackAnim()
    else
        self:moveTo(fighter, {attacking = true})
    end
end

function FighterAI:update(dt)
    Fighter.update(self, dt)
end

function FighterAI:ai()
    table.sort(self.enemies, function(a,b) return a.hp < b.hp end)
    self:attack(self.enemies[1])
end
