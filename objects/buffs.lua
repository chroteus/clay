buffs = {
	-- Buff(name, duration, effect)
	fire = Buff("Fire", 4, 
				function(target) 
					target.hp = target.hp - math.random(10,15) 
					battle.flash(target, {255,0,0})
				end),
}
